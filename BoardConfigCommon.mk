#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/xiaomi/sm4450-common

# Architecture
# 64-bit only: see device/xiaomi/sky/BoardConfig.mk for why 32-bit is dropped.
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a-branchprot
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo

TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_SUPPORTS_32_BIT_APPS := false

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

# merge_dtbs flow: dtb.img is built first (it creates DTB_OBJ/{base,out} and
# runs merge_dtbs.py), and dtbo.img then packs the *.dtbo that flow produced.
# Without BOARD_INCLUDE_DTB_IN_BOOTIMG the dtb.img rule never runs, so
# DTB_OBJ/out does not exist and mkdtboimg gets an empty file list.
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
TARGET_KERNEL_DTB := dtbs

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

# SoC family. BoardConfigQcom.mk (hardware/qcom-caf/common) maps this through
# qcom_defs.mk to pick QCOM_HARDWARE_VARIANT and to decide which
# hardware/qcom-caf/* trees become soong namespaces. parrot is in UM_5_10_FAMILY.
# Without this the lookup falls through to
# QCOM_HARDWARE_VARIANT := $(TARGET_BOARD_PLATFORM), i.e. empty, and every module
# from the CAF layer is reported as non-existent.
TARGET_BOARD_PLATFORM := parrot

# The device builds against the sm8450-6.6 CAF trees, not the plain sm8450 ones.
# The stock river JP image ships vendor/bin/hw/android.hardware.audio.service_64,
# the AIDL audio HAL, and audiohalservice.qti exists only under sm8450-6.6 -- the
# plain sm8450 tree has no hal/service at all. AUDIO_HAL_DIR below, the vibrator
# libpalclient namespace and this tree's Android.bp imports all point at
# sm8450-6.6 for the same reason.
#
# BoardConfigQcom.mk would not pick that on its own: parrot is in UM_5_10_FAMILY
# and qcom_defs.mk only folds that family into UM_6_6_FAMILY when
# TARGET_KERNEL_VERSION is exactly 6.6. Ours is 6.12, so QCOM_HARDWARE_VARIANT
# resolves to plain sm8450 and BoardConfigQcom.mk namespaces
# hardware/qcom-caf/sm8450 alongside the sm8450-6.6 this tree adds in common.mk.
# Both trees define init.qti.display_boot.rc, audioadsprpcd, libar-pal, libagm
# and friends, so soong fails with "found in multiple namespaces".
#
# QCOM_SOONG_NAMESPACE is `?=`, and the device BoardConfig is parsed from
# build/make/core/envsetup.mk:367 while BoardConfigLineage.mk (which includes
# BoardConfigQcom.mk) is included at build/make/core/config.mk:502, so this value
# is in place first and wins.
#
# QCOM_HARDWARE_VARIANT cannot be pinned the same way -- BoardConfigQcom.mk
# assigns it with plain `:=` inside its if/else chain and would overwrite
# anything set here.
QCOM_SOONG_NAMESPACE := hardware/qcom-caf/sm8450-6.6

# Do not let BoardConfigQcom.mk add hardware/qcom-caf/$(QCOM_HARDWARE_VARIANT)/
# data-ipa-cfg-mgr to PRODUCT_SOONG_NAMESPACES. That tree defines liboffloadhal,
# and the vendor repo ships the same name as a prebuilt of the stock blob, so
# soong reports it in two namespaces. The device runs the stock IPA stack
# (ipacm_bin, libipanat, liboffloadhal, both IPACM XMLs -- all declared in the
# vendor repo), so the CAF source ipacm is not wanted. This is the only place the
# variable is read; QCOM_HARDWARE_VARIANT itself cannot be pinned because
# BoardConfigQcom.mk assigns it with plain := inside its if/else chain.
USE_DEVICE_SPECIFIC_DATA_IPA_CFG_MGR := true

# WiFi
# BOARD_WLAN_DEVICE selects the qcacld driver flavour and the private driver
# command libraries (lib_driver_cmd_<device>). WLAN_DEVICE is the in-tree
# hardware/qcom/wlan backend, qcwcn, matching the wifihal_qcom_defaults backend in
# hardware/qcom-caf/wlan.
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WPA_SUPPLICANT_VERSION := VER_0_8_X
WIFI_FEATURE_HOSTAPD_11AX := true
WIFI_FEATURE_SUPPLICANT_11AX := true

# wifihal powers the chip through /dev/wlan using these literals.
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wlan"
WIFI_DRIVER_STATE_OFF := "OFF"
WIFI_DRIVER_STATE_ON := "ON"

# One supplicant .rc carrying the hidl-supplicant service entry.
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true

# Capabilities the wifihal qcwcn backend reads. The stock sky firmware advertises
# NAN, concurrent interfaces and dual AP/STA, matching the rest of the SoC family.
WIFI_HIDL_FEATURE_AWARE := true
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
QC_WIFI_HIDL_FEATURE_DUAL_AP := true
QC_WIFI_HIDL_FEATURE_DUAL_STA := true

# Not setting WIFI_DRIVER_BUILT/DEFAULT := qca_cld3 yet: modules.list.msm.parrot
# ships only cfg80211.ko, so there is no qca_cld3_wlan.ko for the driver to come
# from. Add them once the wlan module is in the vendor_boot module list.

# No BOARD_SUPPORTS_OPENSOURCE_STHAL here on purpose. Enabling it makes
# BoardConfigQcom.mk namespace vendor/qcom/opensource/audio-hal/st-hal-ar-legacy
# (the branch parrot takes), and that repo defines a module named
# sound_trigger.primary.parrot -- the same name as the prebuilt we already ship
# from the stock image. Two modules, one name, build error. The device uses the
# stock HIDL sound-trigger HAL, which is installed as a prebuilt.

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
    hardware/qcom-caf/common/vendor_framework_compatibility_matrix.xml \
    $(COMMON_PATH)/vintf/framework_compatibility_matrix.xml

# Properties
TARGET_VENDOR_PROP += $(COMMON_PATH)/configs/props/vendor.prop
TARGET_PRODUCT_PROP += $(COMMON_PATH)/configs/props/product.prop

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    product \
    recovery \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# Recovery
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/init/fstab.qcom

# Init
TARGET_INIT_VENDOR_LIB := libinit_sm4450
TARGET_RECOVERY_DEVICE_MODULES := libinit_sm4450
