#!/bin/bash

if [ "$#" -lt 5 ]; then
    echo "Usage: $0 <ROM_NAME> <STOCK_DEVICE> <TARGET_DEVICE> <USE_UI_8_TETHERING_APEX> <OUTPUT_FILESYSTEM> [ROM_VERSION]"
    echo "Example: $0 ZineROM A52s5G SM-X216B true erofs 3.2.2"
    exit 1
fi

# ROM Config
export ROM_NAME="$1"
if [ "$#" -ge 6 ]; then
    export ROM_VERSION="$6"
else
    export ROM_VERSION="${ROM_VERSION:-3.2.2}"
fi

# Device info
export STOCK_DEVICE="$2"
export TARGET_DEVICE="$3"
export USE_UI_8_TETHERING_APEX="$4"
export OUTPUT_FILESYSTEM="$5"

# Directories
export FIRM_DIR="$(pwd)/FW"
export OUT_DIR="$(pwd)/OUT"
export WORK_DIR="$(pwd)/WORK"
export APKTOOL="$(pwd)/bin/java/apktool.jar"
export DEVICES_DIR="$(pwd)/QuantumROM/Devices"
export VNDKS_COLLECTION="$(pwd)/QuantumROM/vndks"

# Source
source "$(pwd)/scripts/debloat.sh"
source "$(pwd)/scripts/git_utils.sh"
source "$(pwd)/scripts/QuantumRom.sh"

# فحص الدعم محلياً لتفادي خطأ 404
if [ "$STOCK_DEVICE" != "None" ]; then
    if [ ! -d "$DEVICES_DIR/$STOCK_DEVICE" ]; then
        echo "❌ Unsupported: Device '$STOCK_DEVICE' not found in $DEVICES_DIR"
        exit 1
    fi
    echo "✅ Device supported locally: $STOCK_DEVICE"
else
    echo "ℹ️ STOCK_DEVICE is set to None."
fi

EXTRACT_FIRMWARE "$FIRM_DIR/$TARGET_DEVICE"
EXTRACT_SUPER_IMG "$FIRM_DIR/$TARGET_DEVICE"
EXTRACT_FIRMWARE_IMG "$FIRM_DIR/$TARGET_DEVICE" "all"

DECODE_OMC "$FIRM_DIR/$TARGET_DEVICE" "$WORK_DIR"
DEBLOAT "$FIRM_DIR/$TARGET_DEVICE"

APPLY_STOCK_CONFIG "$STOCK_DEVICE" "$FIRM_DIR/$TARGET_DEVICE"
PATCH_SELINUX "$FIRM_DIR/$TARGET_DEVICE"
DISABLE_SECURITY "$FIRM_DIR/$TARGET_DEVICE"
ADD_CHINA_SMART_MANAGER "$FIRM_DIR/$TARGET_DEVICE"
ADD_SAMSUNG_FLAGSHIP_APPS "$FIRM_DIR/$TARGET_DEVICE"
APPLY_CUSTOM_FEATURES "$FIRM_DIR/$TARGET_DEVICE"
INSTALL_FRAMEWORK "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/framework-res.apk"

DECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/ssrm.jar" "$WORK_DIR"
DECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/services.jar" "$WORK_DIR"

PATCH_SSRM "$WORK_DIR/ssrm"
PATCH_FLAG_SECURE "$FIRM_DIR/$TARGET_DEVICE" "$WORK_DIR/services"
PATCH_SECURE_FOLDER "$FIRM_DIR/$TARGET_DEVICE" "$WORK_DIR/services"

RECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$WORK_DIR/ssrm" "$WORK_DIR"
RECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$WORK_DIR/services" "$WORK_DIR"
mv -f "$WORK_DIR"/*.jar "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/"

PATCH_BT_LIB "$FIRM_DIR/$TARGET_DEVICE" "$WORK_DIR"

SET_ROM_BUILD_ID "$FIRM_DIR/$TARGET_DEVICE"

BUILD_IMG "$FIRM_DIR/$TARGET_DEVICE" "all" "$OUTPUT_FILESYSTEM" "$OUT_DIR"
