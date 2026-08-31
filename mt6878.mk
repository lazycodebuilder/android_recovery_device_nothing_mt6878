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

# CPU Variant for Runtime
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

# OTA Assert Devices
TARGET_OTA_ASSERT_DEVICE := Tetris,tetris,A015,mt6878

# PBootloader Board Name
TARGET_BOOTLOADER_BOARD_NAME := mt6878
TARGET_BOARD_PLATFORM := mt6878

# MTK Hardware Support
BOARD_HAS_MTK_HARDWARE := true
BOARD_USES_MTK_HARDWARE := true
TW_USE_MODEL_HARDWARE_ID_FOR_DEVICE_ID := true

# Partition Sizes & File Systems
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_USERDATAIMAGE_PARTITION_SIZE := 115913752576

# Use F2FS for userdata
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Workaround for build errors with ramdisk copying
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4

# Mount points
TARGET_COPY_OUT_SYSTEM := system
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

## Dynamic Partitions
# Total size of the super partition as reported by the device or extracted from partition table
BOARD_SUPER_PARTITION_SIZE := 9663676416  # 9.0 GiB total super partition size
BOARD_SUPER_PARTITION_GROUPS := mt6878_dynamic_partitions
BOARD_MT6878_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    odm odm_dlkm product system system_ext vendor vendor_dlkm
# Subtract 4MB from the super partition size to reserve space for partition metadata
# 4MB = 4 * 1024 * 1024 = 4194304 bytes
# 9663676416 - 4194304 = 9659482112 bytes
BOARD_MT6878_DYNAMIC_PARTITIONS_SIZE := 9659482112 # 8.996 GiB ≈ 9.66 GB usable for dynamic partitions

## Display / UI
# Fixes wrong theme color
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# Brightness flags
TW_BRIGHTNESS_PATH := /sys/class/leds/lcd-backlight/brightness
TW_MAX_BRIGHTNESS := 4095
TW_DEFAULT_BRIGHTNESS := 140

# CPU temp sysfs path, if it is zero all the time
TW_CUSTOM_CPU_TEMP_PATH := /sys/devices/virtual/thermal/thermal_zone11/temp
