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

# Include the specific device makefile for mt6878 (twrp_mt6878.mk)
PRODUCT_MAKEFILES := $(LOCAL_DIR)/twrp_mt6878.mk

# Define available lunch choices for the device. These define different build types.
COMMON_LUNCH_CHOICES := \
    twrp_mt6878-userdebug \
    twrp_mt6878-eng
