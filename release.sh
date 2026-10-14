#!/usr/bin/env bash

set -Eeuo pipefail

: "${ZIP_PATH:?ZIP_PATH is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${ROM_NAME:?ROM_NAME is required}"
: "${ROM_VERSION:?ROM_VERSION is required}"
: "${STOCK_DEVICE:?STOCK_DEVICE is required}"
: "${TARGET_DEVICE:?TARGET_DEVICE is required}"

TOKEN="${GIT_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -z "$TOKEN" ]; then
  echo "No GitHub token available; cannot create release." >&2
  exit 1
fi
if [ ! -s "$ZIP_PATH" ]; then
  echo "ZIP is missing or empty: $ZIP_PATH" >&2
  exit 1
fi

BUILD_TIME="${BUILD_TIME:-Unknown}"
CUSTOM_BUILD_ID="${CUSTOM_BUILD_ID:-${ROM_NAME}-v${ROM_VERSION}_Stable_${TARGET_DEVICE}}"
BASE_FIRMWARE_VERSION="${VERSION:-Unknown}"
ANDROID_VERSION="${ANDROID_VERSION:-Unknown}"
ONE_UI_VERSION="${ONE_UI_VERSION:-Unknown}"
CPU_ABILIST="${CPU_ABILIST:-Unknown}"
FILE_SIZE="$(du -h "$ZIP_PATH" | cut -f1)"
MD5_SUM="$(md5sum "$ZIP_PATH" | awk '{print $1}')"
SHA256_SUM="$(sha256sum "$ZIP_PATH" | awk '{print $1}')"

UPLOAD_LOG="$(mktemp)"
trap 'rm -f "$UPLOAD_LOG"' EXIT
if ! sudo bash upload.sh "$ZIP_PATH" >"$UPLOAD_LOG" 2>&1; then
  cat "$UPLOAD_LOG" >&2
  echo "GoFile upload failed." >&2
  exit 1
fi
GOFILE_LINK="$(grep -oE 'https://gofile\.io/d/[A-Za-z0-9]+' "$UPLOAD_LOG" | tail -n 1 || true)"
if [ -z "$GOFILE_LINK" ]; then
  cat "$UPLOAD_LOG" >&2
  echo "GoFile upload completed without a recognized download link." >&2
  exit 1
fi

echo "File uploaded here: $GOFILE_LINK"

RELEASE_BODY="$(cat <<EOF
#### Download
$GOFILE_LINK

#### ROM build
- ROM name: $ROM_NAME
- ROM version: $ROM_VERSION
- On-device build ID: $CUSTOM_BUILD_ID
- Target device profile: $STOCK_DEVICE
- Base device: $TARGET_DEVICE
- Base firmware version: $BASE_FIRMWARE_VERSION
- Android version: $ANDROID_VERSION
- One UI version: $ONE_UI_VERSION
- CPU ABI list: $CPU_ABILIST

#### Build details
- Filesystem: ${OUTPUT_FILESYSTEM:-Unknown}
- Compressed images: ${COMPRESS_IMG_TO_XZ:-Unknown}
- UI 8 tethering APEX: ${USE_UI_8_TETHERING_APEX:-Unknown}
- Build time: $BUILD_TIME
- ZIP size: $FILE_SIZE
- MD5: $MD5_SUM
- SHA-256: $SHA256_SUM
EOF
)"

TAG_PREFIX="$(printf '%s' "${ROM_NAME}-${ROM_VERSION}-${STOCK_DEVICE}-${TARGET_DEVICE}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+|-+$//g')"
TAG_SUFFIX="${GITHUB_RUN_ID:-$(date -u +%Y%m%d%H%M%S)}"
TAG_NAME="${TAG_PREFIX}-${TAG_SUFFIX}"
RELEASE_NAME="${ROM_NAME} v${ROM_VERSION} for ${STOCK_DEVICE} (base ${TARGET_DEVICE})"
JSON_BODY="$(printf '%s' "$RELEASE_BODY" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
JSON_NAME="$(printf '%s' "$RELEASE_NAME" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    printf '# %s\n\n' "$RELEASE_NAME"
    printf '%s\n\n' "$RELEASE_BODY"
  } >> "$GITHUB_STEP_SUMMARY"
fi

RELEASE_JSON="$(curl --silent --show-error --fail-with-body \
  --request POST "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --header "Content-Type: application/json" \
  --data "{\"tag_name\":\"${TAG_NAME}\",\"name\":${JSON_NAME},\"body\":${JSON_BODY},\"draft\":false,\"prerelease\":false}")"
RELEASE_URL="$(printf '%s' "$RELEASE_JSON" | jq -er '.html_url')"
echo "GitHub release created: $RELEASE_URL"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  printf '\n[Open GitHub release](%s)\n' "$RELEASE_URL" >> "$GITHUB_STEP_SUMMARY"
fi
