# ========================================
# Copyright & Licensing
# ========================================
# Copyright (C) 2024-2025 The TeamWin Recovery Project
# SPDX-License-Identifier: Apache-2.0
#
# TWRP Device Config for MT6878
# Maintainer: LazymeaoProjects
# Date: 2025-05-XX
#

# ========================================
# Makefile Dependencies
# ========================================
# Include the specific device makefile for mt6878 (twrp_mt6878.mk)
PRODUCT_MAKEFILES := $(LOCAL_DIR)/twrp_mt6878.mk

# ========================================
# Lunch Choices
# ========================================
# Define available lunch choices for the device. These define different build types.
COMMON_LUNCH_CHOICES := \
    twrp_mt6878-user \
    twrp_mt6878-userdebug \
    twrp_mt6878-eng
