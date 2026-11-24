/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/properties.h>

#include <string>

#define _REALLY_INCLUDE_SYS_ASM_LINUX_H_
#include <sys/asm/hwcap.h>

#include "vendor_init.h"

using android::base::GetProperty;
using android::base::SetProperty;

static void set_hw_variant() {
    // SM4450 has a single RAM/storage SKU mix; expose it for the OTA client so
    // builds can be matched to the right firmware.
    std::string hw = GetProperty("ro.boot.hardware.sku", "");
    if (!hw.empty()) {
        SetProperty("ro.vendor.product.device_sku", hw);
    }
}

void vendor_load_properties() {
    set_hw_variant();

    // The stock bootloader reports the board, not the retail codename.
    std::string hw = GetProperty("ro.boot.hardware", "");
    LOG(INFO) << "vendor_load_properties: ro.boot.hardware=" << hw;
}
