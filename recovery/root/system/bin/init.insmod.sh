#!/system/bin/sh

########################################################
### init.insmod.cfg format:                          ###
### -----------------------------------------------  ###
### [insmod|setprop|enable|modprobe] [path|prop name] ###
### [mount|unmount] [partition|mount_point]          ###
### [wait] [timeout_seconds]                         ###
### Additional format: [wait] [timeout_seconds]      ###
########################################################

# Logging function
log_info() {
    echo "[INSMOD] $1"
    [ -w /dev/kmsg ] && echo "[INSMOD] $1" > /dev/kmsg
}

log_error() {
    echo "[INSMOD ERROR] $1" >&2
    [ -w /dev/kmsg ] && echo "[INSMOD ERROR] $1" > /dev/kmsg
}

# Check if running in recovery mode
is_recovery_mode() {
    [ -f /system/bin/recovery ] || [ -f /system/recovery-resource-res ] || [ "$(getprop ro.bootmode)" = "recovery" ]
}

# Validate input parameters
if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    log_error "Usage: $0 <config_file> [max_retries]"
    exit 1
fi

cfg_file="$1"
max_global_retries="${2:-3}"

# Check if config file exists and is readable
if [ ! -f "$cfg_file" ]; then
    log_error "Config file not found: $cfg_file"
    exit 2
fi

if [ ! -r "$cfg_file" ]; then
    log_error "Config file not readable: $cfg_file"
    exit 3
fi

log_info "Starting module loading from: $cfg_file"

# Set module search paths based on mode
if is_recovery_mode; then
    MODULE_PATHS="/lib/modules /vendor_dlkm/lib/modules"
    log_info "Running in recovery mode"
else
    MODULE_PATHS="/system_dlkm/lib/modules /vendor_dlkm/lib/modules"
    log_info "Running in normal mode"
fi

# Function to wait for a condition
wait_for_condition() {
    local condition="$1"
    local timeout="${2:-30}"
    local count=0
    
    while [ $count -lt $timeout ]; do
        if eval "$condition"; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    return 1
}

# Function to set property with better retry logic
set_property_safe() {
    local prop_name="$1"
    local prop_value="${2:-1}"
    local max_attempts="${3:-10}"
    local attempt=1
    
    log_info "Setting property: $prop_name=$prop_value"
    
    while [ $attempt -le $max_attempts ]; do
        if setprop "$prop_name" "$prop_value"; then
            # Verify the property was actually set
            if [ "$(getprop "$prop_name")" = "$prop_value" ]; then
                log_info "Property $prop_name set successfully"
                return 0
            fi
        fi
        
        log_info "Property set attempt $attempt failed, retrying..."
        sleep 0.1
        attempt=$((attempt + 1))
    done
    
    log_error "Failed to set property $prop_name after $max_attempts attempts"
    return 1
}

# Function to load module with dependency resolution
load_module_safe() {
    local module_path="$1"
    local module_name
    
    # Extract module name from path
    module_name=$(basename "$module_path" .ko)
    
    # Check if module is already loaded
    if lsmod | grep -q "^$module_name "; then
        log_info "Module $module_name already loaded, skipping"
        return 0
    fi
    
    # Check if module file exists
    if [ ! -f "$module_path" ]; then
        log_error "Module file not found: $module_path"
        return 1
    fi
    
    log_info "Loading module: $module_path"
    
    if insmod "$module_path"; then
        log_info "Module $module_name loaded successfully"
        return 0
    else
        log_error "Failed to load module: $module_path"
        return 1
    fi
}

# Function to check if a partition is mounted
is_mounted() {
    local mount_point="$1"
    mount | grep -q " $mount_point "
}

# Function to find partition device
find_partition_device() {
    local partition_name="$1"
    local device_path
    
    # Try different methods to find the partition
    # Method 1: Check /dev/block/by-name/
    if [ -L "/dev/block/by-name/$partition_name" ]; then
        device_path=$(readlink -f "/dev/block/by-name/$partition_name")
        echo "$device_path"
        return 0
    fi
    
    # Method 2: Check /dev/block/platform/*/by-name/
    for by_name_dir in /dev/block/platform/*/by-name/; do
        if [ -L "${by_name_dir}$partition_name" ]; then
            device_path=$(readlink -f "${by_name_dir}$partition_name")
            echo "$device_path"
            return 0
        fi
    done
    
    # Method 3: Check /proc/cmdline for partition info
    if grep -q "$partition_name" /proc/cmdline 2>/dev/null; then
        device_path=$(grep -o "${partition_name}=[^ ]*" /proc/cmdline | cut -d'=' -f2)
        if [ -b "$device_path" ]; then
            echo "$device_path"
            return 0
        fi
    fi
    
    return 1
}

# Function to mount partition safely
mount_partition_safe() {
    local partition_name="$1"
    local mount_point="$2"
    local fs_type="${3:-ext4}"
    local mount_options="${4:-ro}"
    local device_path
    
    log_info "Attempting to mount $partition_name at $mount_point"
    
    # Check if already mounted
    if is_mounted "$mount_point"; then
        log_info "$mount_point already mounted"
        return 0
    fi
    
    # Create mount point if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        log_info "Creating mount point: $mount_point"
        mkdir -p "$mount_point"
    fi
    
    # Find partition device
    device_path=$(find_partition_device "$partition_name")
    if [ -z "$device_path" ]; then
        log_error "Could not find device for partition: $partition_name"
        return 1
    fi
    
    log_info "Found device: $device_path for partition: $partition_name"
    
    # Try mounting with specified filesystem type
    if mount -t "$fs_type" -o "$mount_options" "$device_path" "$mount_point"; then
        log_info "Successfully mounted $partition_name ($device_path) at $mount_point"
        return 0
    fi
    
    # If ext4 failed, try other common filesystems
    if [ "$fs_type" = "ext4" ]; then
        for alt_fs in erofs f2fs ext2; do
            log_info "Trying alternative filesystem: $alt_fs"
            if mount -t "$alt_fs" -o "$mount_options" "$device_path" "$mount_point"; then
                log_info "Successfully mounted $partition_name with $alt_fs at $mount_point"
                return 0
            fi
        done
    fi
    
    log_error "Failed to mount $partition_name at $mount_point"
    return 1
}

# Function to unmount partition safely
unmount_partition_safe() {
    local mount_point="$1"
    local force="${2:-false}"
    
    log_info "Attempting to unmount: $mount_point"
    
    if ! is_mounted "$mount_point"; then
        log_info "$mount_point is not mounted"
        return 0
    fi
    
    # Try normal unmount first
    if umount "$mount_point"; then
        log_info "Successfully unmounted: $mount_point"
        return 0
    fi
    
    # If force unmount is requested
    if [ "$force" = "true" ]; then
        log_info "Attempting force unmount: $mount_point"
        if umount -f "$mount_point" || umount -l "$mount_point"; then
            log_info "Force unmount successful: $mount_point"
            return 0
        fi
    fi
    
    log_error "Failed to unmount: $mount_point"
    return 1
}

# Function to setup module partitions
setup_module_partitions() {
    local mounted_partitions=""
    
    log_info "Setting up module partitions..."
    
    # Define partitions that might contain modules
    if is_recovery_mode; then
        # Recovery mode - minimal mounts
        if mount_partition_safe "vendor_dlkm" "/vendor_dlkm" "ext4" "ro"; then
            mounted_partitions="$mounted_partitions /vendor_dlkm"
        fi
    else
        # Normal mode - full module partition support
        if mount_partition_safe "system_dlkm" "/system_dlkm" "ext4" "ro"; then
            mounted_partitions="$mounted_partitions /system_dlkm"
        fi
        
        if mount_partition_safe "vendor_dlkm" "/vendor_dlkm" "ext4" "ro"; then
            mounted_partitions="$mounted_partitions /vendor_dlkm"
        fi
        
        if mount_partition_safe "vendor" "/vendor" "ext4" "ro"; then
            mounted_partitions="$mounted_partitions /vendor"
        fi
        
        if mount_partition_safe "system" "/system" "ext4" "ro"; then
            mounted_partitions="$mounted_partitions /system"
        fi
    fi
    
    # Store mounted partitions for cleanup
    setprop vendor.insmod.mounted.partitions "$mounted_partitions"
    
    if [ -n "$mounted_partitions" ]; then
        log_info "Successfully mounted partitions:$mounted_partitions"
        return 0
    else
        log_error "Failed to mount any module partitions"
        return 1
    fi
}

# Function to cleanup mounted partitions
cleanup_module_partitions() {
    local mounted_partitions
    local cleanup_on_exit="${1:-false}"
    
    mounted_partitions=$(getprop vendor.insmod.mounted.partitions)
    
    if [ -n "$mounted_partitions" ] && [ "$cleanup_on_exit" = "true" ]; then
        log_info "Cleaning up mounted partitions..."
        for mount_point in $mounted_partitions; do
            unmount_partition_safe "$mount_point" "false"
        done
        setprop vendor.insmod.mounted.partitions ""
    fi
}

# Function to handle modprobe with multiple search paths
modprobe_safe() {
    local modprobe_args="$1"
    local success=0
    
    for module_dir in $MODULE_PATHS; do
        if [ -d "$module_dir" ]; then
            log_info "Trying modprobe in: $module_dir"
            
            case "$modprobe_args" in
                "-b *" | "-b")
                    if [ -f "$module_dir/modules.load" ]; then
                        modprobe_args="-b $(cat "$module_dir/modules.load")"
                    else
                        log_info "No modules.load found in $module_dir, skipping"
                        continue
                    fi
                    ;;
                "*" | "")
                    if [ -f "$module_dir/modules.load" ]; then
                        modprobe_args="$(cat "$module_dir/modules.load")"
                    else
                        log_info "No modules.load found in $module_dir, skipping"
                        continue
                    fi
                    ;;
            esac
            
            if modprobe -a -d "$module_dir" $modprobe_args; then
                log_info "Modprobe successful in $module_dir"
                success=1
            else
                log_error "Modprobe failed in $module_dir"
            fi
        fi
    done
    
    if [ $success -eq 0 ]; then
        log_error "Modprobe failed in all search paths"
        return 1
    fi
    
    return 0
}

# Main processing loop with error handling
process_config() {
    local line_number=0
    local failed_actions=0
    
    while IFS="|" read -r action arg || [ -n "$action" ]; do
        line_number=$((line_number + 1))
        
        # Skip empty lines and comments
        case "$action" in
            "" | "#"*) continue ;;
        esac
        
        log_info "Processing line $line_number: $action|$arg"
        
        case "$action" in
            "insmod")
                if ! load_module_safe "$arg"; then
                    failed_actions=$((failed_actions + 1))
                fi
                ;;
                
            "setprop")
                if ! set_property_safe "$arg"; then
                    failed_actions=$((failed_actions + 1))
                fi
                ;;
                
            "enable")
                log_info "Enabling: $arg"
                if echo 1 > "$arg" 2>/dev/null; then
                    log_info "Successfully enabled: $arg"
                else
                    log_error "Failed to enable: $arg"
                    failed_actions=$((failed_actions + 1))
                fi
                ;;
                
            "modprobe")
                if ! modprobe_safe "$arg"; then
                    failed_actions=$((failed_actions + 1))
                fi
                ;;
                
            "wait")
                timeout_val="${arg:-10}"
                log_info "Waiting for $timeout_val seconds..."
                sleep "$timeout_val"
                ;;
                
            "mount")
                # Format: mount|partition_name|mount_point|fs_type|options
                IFS='|' read -r part_name mount_pt fs_type mount_opts <<< "$arg"
                mount_pt="${mount_pt:-/$part_name}"
                fs_type="${fs_type:-ext4}"
                mount_opts="${mount_opts:-ro}"
                
                if ! mount_partition_safe "$part_name" "$mount_pt" "$fs_type" "$mount_opts"; then
                    failed_actions=$((failed_actions + 1))
                fi
                ;;
                
            "unmount")
                # Format: unmount|mount_point|force
                IFS='|' read -r mount_pt force_flag <<< "$arg"
                force_flag="${force_flag:-false}"
                
                if ! unmount_partition_safe "$mount_pt" "$force_flag"; then
                    failed_actions=$((failed_actions + 1))
                fi
                ;;
                
            *)
                log_error "Unknown action: $action (line $line_number)"
                failed_actions=$((failed_actions + 1))
                ;;
        esac
    done < "$cfg_file"
    
    log_info "Processing complete. Failed actions: $failed_actions"
    return $failed_actions
}

# Main execution with retry logic
main() {
    local retry=0
    local exit_code
    
    # Setup module partitions first
    if ! setup_module_partitions; then
        log_error "Failed to setup module partitions"
        exit 5
    fi
    
    while [ $retry -lt $max_global_retries ]; do
        if process_config; then
            log_info "Module loading completed successfully"
            cleanup_module_partitions "false"  # Don't cleanup by default
            exit 0
        else
            retry=$((retry + 1))
            if [ $retry -lt $max_global_retries ]; then
                log_info "Retrying module loading (attempt $((retry + 1))/$max_global_retries)..."
                sleep 2
            fi
        fi
    done
    
    log_error "Module loading failed after $max_global_retries attempts"
    cleanup_module_partitions "true"  # Cleanup on failure
    exit 4
}

# Trap signals for cleanup
trap 'log_error "Script interrupted"; cleanup_module_partitions "true"; exit 130' INT TERM

# Execute main function
main