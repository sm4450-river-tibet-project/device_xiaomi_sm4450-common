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

# gki_defconfig is the base; the vendor fragment adds the parrot/ravelin
# platform and all the =m symbols the module list needs.
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/parrot_perf.config

# Kernel modules
# modules.list.msm.parrot in the kernel repo is the build list: it tells the
# kernel build which modules to produce. The load lists below are separate
# and say which produced module goes into which partition image.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/configs/modules/modules.load.vendorboot))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/configs/modules/modules.load.recovery))
BOOT_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD)

BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules.vendor_blocklist.msm.parrot
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE)
BOARD_SYSTEM_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules.systemdlkm_blocklist.msm.parrot

# Module load lists. These tell the build which modules go into which
# partition, and they are what the init scripts read at boot.
#
# modules.load              -> vendor_dlkm
# modules.load.vendorboot   -> vendor_boot ramdisk
# modules.load.recovery     -> recovery ramdisk
# modules.load.system_dlkm  -> system_dlkm
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/configs/modules/modules.load))
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/configs/modules/modules.load.system_dlkm))

# External kernel modules (built out-of-tree against the sky 6.12 kernel).
# The list mirrors what the platform build wires: the xiaomi vendor modules
# plus every techpack whose modules appear in modules.list.msm.parrot.
TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sky-modules
TARGET_KERNEL_EXT_MODULES := \
    xiaomi \
    qcom/opensource/mmrm-driver \
    qcom/opensource/mm-drivers/msm_ext_display \
    qcom/opensource/mm-drivers/sync_fence \
    qcom/opensource/audio-kernel \
    qcom/opensource/securemsm-kernel \
    qcom/opensource/synx-kernel \
    qcom/opensource/camera-kernel \
    qcom/opensource/datarmnet-ext/mem \
    qcom/opensource/dataipa/drivers/platform/msm \
    qcom/opensource/datarmnet/core \
    qcom/opensource/datarmnet-ext/aps \
    qcom/opensource/datarmnet-ext/offload \
    qcom/opensource/datarmnet-ext/perf \
    qcom/opensource/datarmnet-ext/perf_tether \
    qcom/opensource/datarmnet-ext/sch \
    qcom/opensource/datarmnet-ext/shs \
    qcom/opensource/datarmnet-ext/wlan \
    qcom/opensource/display-drivers/msm \
    qcom/opensource/dsp-kernel \
    qcom/opensource/graphics-kernel \
    qcom/opensource/spu-kernel \
    qcom/opensource/video-driver \
    qcom/opensource/wlan/platform \
    qcom/opensource/wlan/qcacld-3.0/.adrastea \
    qcom/opensource/bt-kernel \
    nxp/opensource/driver


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
