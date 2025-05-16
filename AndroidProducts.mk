# ========================================
# Copyright & Licensing
# ========================================
# Copyright (C) 2024-2025 The TeamWin Recovery Project
# SPDX-License-Identifier: Apache-2.0
#
# TWRP Device Config for tetris
# Maintainer: LazymeaoProjects
# Date: 2025-05-XX
#

# ========================================
# Makefile Dependencies
# ========================================
# Include the specific device makefile for tetris (twrp_tetris.mk)
PRODUCT_MAKEFILES := $(LOCAL_DIR)/twrp_tetris.mk

# ========================================
# Lunch Choices
# ========================================
# Define available lunch choices for the device. These define different build types.
COMMON_LUNCH_CHOICES := \
    twrp_tetris-user \
    twrp_tetris-userdebug \
    twrp_tetris-eng
