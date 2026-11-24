#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/xiaomi/sm4450-common

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a-branchprot
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := parrot
TARGET_NO_BOOTLOADER := true

# Kernel
# The kernel tree is GKI 6.12.52 with the CLO 6.12 vendor overlay and our own
# parrot build wiring on top. See:
#   kernel_xiaomi_sky-6.12            GKI + CLO + build.config.msm.parrot
#   kernel_xiaomi_sky-devicetrees-6.12  ravelin DTS
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_RAMDISK_USE_LZ4 := true
TARGET_NEEDS_DTBOIMAGE := true
BOARD_USES_QCOM_MERGE_DTBS_SCRIPT := true

TARGET_KERNEL_SOURCE := kernel/xiaomi/sky
TARGET_KERNEL_VERSION := 6.12
TARGET_KERNEL_ADDITIONAL_FLAGS := TARGET_PRODUCT=$(PRODUCT_DEVICE)

# Kernel modules
# The lists live in the kernel repo under modules-lists/, generated for the
# parrot board. They must reference modules the parrot configs actually build.
first_stage_modules := $(strip $(shell cat $(TARGET_KERNEL_SOURCE)/modules-lists/modules.list.msm.parrot))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD += $(first_stage_modules)
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD += $(first_stage_modules)
BOOT_KERNEL_MODULES += $(first_stage_modules)

BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules-lists/modules.vendor_blocklist.msm.parrot
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE)
BOARD_SYSTEM_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules-lists/modules.systemdlkm_blocklist.msm.parrot

BOARD_VENDOR_RAMDISK_FRAGMENTS := dlkm
BOARD_VENDOR_RAMDISK_FRAGMENT.dlkm.KERNEL_MODULE_DIRS := top

# Platform
BOARD_USES_QCOM_HARDWARE := true
TARGET_USES_QCOM_BSP := true
TARGET_USES_UEFI := true

# Filesystem
TARGET_FS_CONFIG_GEN := $(COMMON_PATH)/configs/config.fs

# Metadata
BOARD_USES_METADATA_PARTITION := true

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(COMMON_PATH)/sepolicy/vendor

# VINTF
# The device manifest is generated from the stock vendor image, matching the
# sm8450-common convention.
DEVICE_MANIFEST_FILE := $(COMMON_PATH)/vintf/manifest_ravelin.xml
DEVICE_MATRIX_FILE := hardware/qcom-caf/common/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := \
    hardware/qcom-caf/common/framework_compatibility_matrix.xml \
    $(COMMON_PATH)/vintf/framework_compatibility_matrix.xml

# Properties
TARGET_SYSTEM_PROP += $(COMMON_PATH)/configs/props/system.prop
TARGET_VENDOR_PROP += $(COMMON_PATH)/configs/props/vendor.prop
TARGET_PRODUCT_PROP += $(COMMON_PATH)/configs/props/product.prop

# Init
TARGET_INIT_VENDOR_LIB := libinit_sm4450
TARGET_RECOVERY_DEVICE_MODULES := libinit_sm4450
