# ========================================
# Copyright & Licensing
# ========================================
# Copyright (C) 2025-2026 The TeamWin Recovery Project
# SPDX-License-Identifier: Apache-2.0
#
# TWRP Device Config for MT6878
# Maintainer: LazymeaoProjects
# Date: 2026-08-XX
#

# Build Flags for Minimal Manifests & Broken Dependencies
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# CPU Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic

# 64-bit only build
TARGET_IS_64_BIT := true
TARGET_BOARD_SUFFIX := _64
TARGET_USES_64_BIT_BINDER := true

# CPUSETS and SCHEDBOOST support
ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

# bootloader and recovery are not built
TARGET_NO_BOOTLOADER := true

# Uefi support
TARGET_USES_UEFI := true

# Board Info File
TARGET_BOARD_INFO_FILE ?= $(DEVICE_PATH)/board-info.txt

# Kernel & DTB Configuration
TARGET_NO_KERNEL := true
BOARD_KERNEL_SEPARATED_DTBO := true

TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64

# Prebuilt DTB Image
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_MKBOOTIMG_ARGS += --dtb $(BOARD_PREBUILT_DTBIMAGE_DIR)
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

# Boot Image Header Version
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

# Offsets 
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_TAGS_OFFSET := 0x07c88000
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_TAGS_OFFSET)
BOARD_RAMDISK_OFFSET := 0x26f08000
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)

# Page Size
BOARD_PAGE_SIZE := 4096
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_PAGE_SIZE) --board ""

# Command line
BOARD_VENDOR_CMDLINE := "bootopt=64S3,32N2,64N2 androidboot.selinux=permissive"
BOARD_MKBOOTIMG_ARGS += --vendor_cmdline $(BOARD_VENDOR_CMDLINE)

# Recovery Config
TARGET_NO_RECOVERY := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
BOARD_RAMDISK_USE_LZ4 := true

# Metadata Partition Support
BOARD_USES_METADATA_PARTITION := true

# Encryption / Decryption Support (FBE)
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2
TW_FORCE_KEYMASTER_VER := true

# Enables proper handling of /data/media
RECOVERY_SDCARD_ON_DATA := true

# Anti rollback / Security Patch Level
PLATFORM_SECURITY_PATCH := 2127-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# Wipe Handling / Misc
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SUPPRESS_SECURE_ERASE := true

# Vendor Modules
TW_LOAD_VENDOR_BOOT_MODULES := true
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true
TW_LOAD_VENDOR_MODULES := "mtk_disp_notify.ko mediatek-drm-panel-drv.ko bootinfo.ko focaltech_tp.ko hbt.ko"

# AVB (Android Verified Boot)
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# Fstab Configuration
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TW_SKIP_ADDITIONAL_FSTAB := true

# Screenshot support
TW_INCLUDE_FB2PNG := true

# apex image generation for dexpreopt
DEXPREOPT_GENERATE_APEX_IMAGE := true

# TWRP Configuration
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TARGET_USES_MKE2FS := true

# Core tools for filesystem and debugging
TW_INCLUDE_NTFS_3G := true
TW_INCLUDE_FUSE_EXFAT := true
TW_INCLUDE_FUSE_NTFS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_REPACKTOOLS := true

# Clean up the default lpdump
TW_EXCLUDE_LPDUMP := true

# Clean up the default USB init to avoid conflicts with TWRP's USB handling
TW_EXCLUDE_DEFAULT_USB_INIT := true

# Fastbootd support
TW_INCLUDE_FASTBOOTD := true

# Disable haptics
TW_NO_HAPTICS := true

# Debugging tools for twrp
ifeq ($(LAZY_INCLUDE_DEBUG_FLAGS), true)
    TWRP_INCLUDE_LOGCAT := true
    TWRP_EVENT_LOGGING := true
    TARGET_USES_LOGD := true
    TARGET_RECOVERY_DEVICE_MODULES += debuggerd
    RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd
    RECOVERY_LIBRARY_SOURCE_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libdebuggerd_client.so
    RECOVERY_LIBRARY_SOURCE_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libprocinfo.so
    TARGET_RECOVERY_DEVICE_MODULES += strace
    RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/strace
    TARGET_RECOVERY_DEVICE_MODULES += lsof
    RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/lsof
endif
