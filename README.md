# TWRP Recovery for Nothing CMF Phone 1 (Tetris)

A custom recovery tree for the Nothing CMF Phone 1 (codename: Tetris), supporting TWRP, PBRP(soon), OFRP(soon), and SHRP(soon) recovery projects.


## Build Instructions

1. Set up build environment variables:
```bash
# Required: Set recovery project type
export LAZY_TARGET_RECOVERY_TYPE=twrp  # Options: twrp, pbrp, ofrp, shrp

# Optional flags
export LAZY_INCLUDE_DEBUG_FLAGS=false   # Debug flags inclusion
```

2. Initialize build environment:
```bash
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export SOONG_VERBOSE=true
```

3. Build recovery (choose one):
```bash
# For TWRP/SHRP(soon)
lunch twrp_mt6878-eng && mka vendorbootimage -j"$(nproc --all)" 2>&1 | tee out/mt6878-rec.log

# For PBRP(soon)
lunch twrp_mt6878-eng && mka pbrp -j"$(nproc --all)" 2>&1 | tee out/mt6878-rec.log

# For OFRP(soon)
lunch twrp_mt6878-eng && mka adbd vendorbootimage -j"$(nproc --all)" 2>&1 | tee out/mt6878-rec.log
```

The output log will be saved to `out/mt6878-rec.log` for debugging purposes.