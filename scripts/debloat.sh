#!/bin/bash

# GENERAL / SYSTEM / BLOAT
DEBLOAT_APPS=(
"HMT" "PaymentFramework" "DigitalWellbeing" "FactoryCameraFB"
"WlanTest" "AirGlance" "AirReadingGlass" "AndroidGlassesCore"
"SOAgent77" "ARCore" "ARDrawing" "ARZone" "BGMProvider"
"SingleTakeService" "BixbyWakeup" "BlockchainBasicKit"
"Cameralyzer" "DictDiotekForSec" "EasymodeContactsWidget81"
"Fast" "FunModeSDK" "GearManagerStub" "KidsHome_Installer"
"LinkSharing_v11" "LiveDrawing" "MAPSAgent" "MdecService"
"MinusOnePage" "MoccaMobile" "Netflix_stub" "Notes40"
"ParentalCare" "PhotoTable" "SmartReminder" "SmartSwitchStub"
"UnifiedWFC" "VideoEditorLite_Dream_N"
"VoiceAccess" "VTCameraSetting"
"WebManual" "WifiGuider" "AutomationTest_FB" "FactoryTestProvider"
"StickerCenter" "CIDManager" "FacAtFunction" "serviceModeApp_FB"
)

# KOREAN / CARRIER APPS
CARRIER_APPS=(
"KTAuth" "KTCustomerService" "KTUsimManager"
"LGUMiniCustomerCenter" "LGUplusTsmProxy"
"SKTMemberShip_new" "SktUsimService" "TWorld"
"KT114Provider2" "KTHiddenMenu" "KTOneStore"
"KTServiceAgent" "KTServiceMenu"
"LGUGPSnWPS" "LGUHiddenMenu" "LGUOZStore"
"SKTFindLostPhone" "SKTHiddenMenu" "SKTMemberShip"
"SKTOneStore" "SKTFindLostPhoneApp"
"TPhoneOnePackage" "TPhoneSetup" "TService"
"UsimRegistrationKOR" "HpsAgreement_new" "KTAuth_Stub"
)

# SAMSUNG APPS
SAMSUNG_APPS=(
"SamsungTTS" "SamsungBilling"
"OneDrive_Samsung_v3" "SamsungCarKeyFw"
"AppUpdateCenter" "AREmoji"
"AREmojiEditor" "AutoDoodle" "AvatarEmojiSticker"
"AvatarEmojiSticker_S" "AvatarPicker"
"GalleryWidget" "LiveStickers" "StoryService"
"StickerFaceARAvatar" "sticker"
)

# SAMSUNG AI (فارغة للحفاظ على خدمات الذكاء الاصطناعي)
SAMSUNG_AI=()

# GOOGLE APPS
GOOGLE_APPS=(
"SpeechServicesByGoogle" "Duo" "Photos"
"AssistantShell" "BardShell" "DuoStub"
"GoogleCalendarSyncAdapter" "AndroidDeveloperVerifier"
"YourPhone_Stub" "AndroidAutoStub" "FamilyLinkParentalControls"
"GoogleRestore"
"SearchSelector" "PlayAutoInstallConfig"
)

# FACEBOOK
FACEBOOK_APPS=(
"FBAppManager_NS" "FBInstaller_NS" "FBServices"
)

# DRIVERS
HARDWARE_DRIVERS=(
"DevGPUDriver-EX2200"
"GameDriver-EX2100" "GameDriver-EX2200" "GameDriver-SM8150"
)

# MISC / SERVICES
MISC_SERVICES=(
"Discover" "DiscoverSEP"
"EarphoneTypeC" "EasySetup" "FotaAgent"
"HashTagService" "LedCoverService"
"LinkToWindowsService" "MemorySaver_O_Refresh"
"OMCAgent5" "OneStoreService" "FactoryAirCommandManager"
"SOAgent7" "SOAgent75" "SOAgent76"
"SolarAudio-service" "SPPPushClient"
"SumeNNService" "SVoiceIME"
"SwiftkeyIme" "SwiftkeySetting"
"SystemUpdate" "TADownloader"
"TalkbackSE" "TalkBack"
"UltraDataSaving_O" "Upday"
"YourPhone_P1_5" "DsmsAPK"
"vexfwk_service" "VexScanner"
"LiveEffectService" "MyGalaxyService"
)

KNOX_APPS=()

REMOVE_FABRIC_CRYPTO() {
    [ "$#" -ne 1 ] && return 0
    local EXTRACTED_FIRM_DIR="$1"
    
    # استخدام التوجيه الآمن وعدم إيقاف السكربت لو الملف غير موجود
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/bin/fabric_crypto" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/etc/init/fabric_crypto.rc" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/etc/permissions/FabricCryptoLib.xml" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/etc/vintf/manifest/fabric_crypto_manifest.xml" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/framework/FabricCryptoLib.jar" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/lib64/com.samsung.security.fabric.cryptod-V1-cpp.so" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/lib64/vendor.samsung.hardware.security.fkeymaster-V1-ndk.so" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/priv-app/KmxService" 2>/dev/null
    return 0
}

KICK() {
    [ "$#" -lt 2 ] && return 0
    local EXTRACTED_FIRM_DIR="$1"
    shift
    local APPS_LIST=("$@")

    local APP_DIRS=(
        "$EXTRACTED_FIRM_DIR/system/system/app"
        "$EXTRACTED_FIRM_DIR/system/system/priv-app"
        "$EXTRACTED_FIRM_DIR/product/app"
        "$EXTRACTED_FIRM_DIR/product/priv-app"
        "$EXTRACTED_FIRM_DIR/system_ext/app"
        "$EXTRACTED_FIRM_DIR/system_ext/priv-app"
    )

    for app in "${APPS_LIST[@]}"; do
        for dir in "${APP_DIRS[@]}"; do
            if [ -d "$dir" ]; then
                find "$dir" -maxdepth 1 -type d -iname "$app*" -exec rm -rf {} + 2>/dev/null
            fi
        done
    done
    return 0
}

DEBLOAT() {
	local EXTRACTED_FIRM_DIR="$1"
	if [ ! -d "$EXTRACTED_FIRM_DIR/system" ]; then
        return 0
    fi

    KICK "$EXTRACTED_FIRM_DIR" "${DEBLOAT_APPS[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${CARRIER_APPS[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${SAMSUNG_APPS[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${SAMSUNG_AI[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${GOOGLE_APPS[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${FACEBOOK_APPS[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${HARDWARE_DRIVERS[@]}"
    KICK "$EXTRACTED_FIRM_DIR" "${MISC_SERVICES[@]}"
	REMOVE_FABRIC_CRYPTO "$EXTRACTED_FIRM_DIR"

    rm -rf "$EXTRACTED_FIRM_DIR/system/system/app"/SamsungTTS* 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/hidden" 2>/dev/null
    rm -rf "$EXTRACTED_FIRM_DIR/system/system/preload" 2>/dev/null
	rm -rf "$EXTRACTED_FIRM_DIR/system/system/etc/mediasearch" 2>/dev/null
	rm -rf "$EXTRACTED_FIRM_DIR/system/system/priv-app/MediaSearch" 2>/dev/null
	rm -rf "$EXTRACTED_FIRM_DIR/system/system/skt" 2>/dev/null
	rm -rf "$EXTRACTED_FIRM_DIR/system/system/tts" 2>/dev/null
    
    return 0
}
