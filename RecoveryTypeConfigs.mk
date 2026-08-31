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
# ================================================================
# Configuration Validation and Defaults
# ================================================================
# Supported recovery types
VALID_RECOVERY_TYPES := twrp pbrp ofrp shrp

# Validate recovery type
ifeq ($(filter $(LAZY_TARGET_RECOVERY_TYPE),$(VALID_RECOVERY_TYPES)),)
    $(warning Invalid recovery type specified for LAZY_TARGET_RECOVERY_TYPE. Supported types are: '$(VALID_RECOVERY_TYPES)'. Using default value: 'twrp'.)
    # Set default recovery type to 'twrp'
    LAZY_TARGET_RECOVERY_TYPE ?= twrp
endif

# Validate debug flag inclusion value
ifeq ($(filter true false,$(LAZY_INCLUDE_DEBUG_FLAGS)),)
    $(warning Invalid value for LAZY_INCLUDE_DEBUG_FLAGS. Accepted values are 'true' or 'false'. Using default value: 'false'.)
    # Set default debug flag inclusion to 'true'
    LAZY_INCLUDE_DEBUG_FLAGS ?= true
endif

# ================================================================
# Recovery Type Specific Configurations
# ================================================================
ifeq ($(LAZY_TARGET_RECOVERY_TYPE), twrp)
    ## TWRP Configuration
    ## TWRP-specific flags here
    # Add TW_DEVICE_VERSION
    TW_DEVICE_VERSION := v0.1.0 | LazymeaoProjects
    # Statusbar icons flags
    TW_STATUS_ICONS_ALIGN := center
    #TW_CUSTOM_CPU_POS := 290
    #TW_CUSTOM_CLOCK_POS := 340
    #TW_CUSTOM_BATTERY_POS := 790
else ifeq ($(LAZY_TARGET_RECOVERY_TYPE), pbrp)
    ## PBRP Configuration
else ifeq ($(LAZY_TARGET_RECOVERY_TYPE), shrp)
    ## TWRP-specific flags here
    # Add TW_DEVICE_VERSION
    TW_DEVICE_VERSION := v0.1.0
    ## SHRP Configuration
endif