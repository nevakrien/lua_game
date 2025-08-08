#!/usr/bin/env bash

#made by ChatGpt5 

set -euo pipefail

# -------- Config (paths are relative to THIS script's directory) --------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GAME_DIR="game"
ANDROID_DIR="../love-android"
OUT_DIR="build"
LOVE_FILE="$OUT_DIR/game.love"

# local gradle.properties you maintain:
LOCAL_PROPS="gradle.properties"
DEST_PROPS="$ANDROID_DIR/gradle.properties"

# Gradle variant + unsigned APK path (change if your variant/path differs)
APK_TASK="assembleEmbedNoRecordRelease"
UNSIGNED_APK="$ANDROID_DIR/app/build/outputs/apk/embedNoRecord/release/app-embed-noRecord-release-unsigned.apk"

# Signed APK stays local
SIGNED_APK="$OUT_DIR/app-signed.apk"

# Debug keystore expected in love-android (auto-generated if missing)
KEYSTORE="$ANDROID_DIR/debug.keystore"
KEY_ALIAS="androiddebugkey"
KEY_PASS="android"

# Tools (you can override by exporting env vars before running)
ADB_BIN="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"
APKSIGNER_BIN="${APKSIGNER:-apksigner}"

# -------- Helpers --------
die() { echo "❌ $*" >&2; exit 1; }
msg() { echo -e "▶ $*"; }

ensure_tools() {
  command -v "$ADB_BIN" >/dev/null 2>&1 || die "adb not found at '$ADB_BIN'"
  if ! command -v "$APKSIGNER_BIN" >/dev/null 2>&1; then
    # try to find apksigner under ANDROID_HOME build-tools
    if [[ -n "${ANDROID_HOME:-}" ]] && [[ -d "$ANDROID_HOME/build-tools" ]]; then
      local found
      found="$(ls -1d "$ANDROID_HOME"/build-tools/*/apksigner 2>/dev/null | sort -V | tail -n1 || true)"
      [[ -n "$found" ]] || die "apksigner not in PATH and not found under \$ANDROID_HOME/build-tools"
      APKSIGNER_BIN="$found"
    else
      die "apksigner not found; set APKSIGNER or ensure it’s in PATH"
    fi
  fi
}

ensure_outdir() {
  mkdir -p "$OUT_DIR"
}

make_love() {
  ensure_outdir
  msg "Zipping '$GAME_DIR' -> '$LOVE_FILE'"
  # Use absolute output path to avoid any rel-path weirdness
  local abs_out
  abs_out="$(readlink -f "$LOVE_FILE")"
  # Remove stale file if exists (zip appends otherwise)
  rm -f "$abs_out"
  ( cd "$GAME_DIR" && zip -9 -r "$abs_out" . \
      -x "*.git*" -x "*__pycache__*" -x "*.swp" -x "*.DS_Store" )
}

sync_props() {
  [[ -f "$LOCAL_PROPS" ]] || die "Missing $LOCAL_PROPS next to this script"
  msg "Syncing $LOCAL_PROPS -> $DEST_PROPS"
  cp -f "$LOCAL_PROPS" "$DEST_PROPS"
}

copy_love_to_android() {
  msg "Copying .love into Android assets"
  mkdir -p "$ANDROID_DIR/app/src/main/assets"
  cp -f "$LOVE_FILE" "$ANDROID_DIR/app/src/main/assets/game.love"
}

build_unsigned_apk() {
  msg "Building unsigned APK with Gradle task: $APK_TASK"
  ( cd "$ANDROID_DIR" && ./gradlew "$APK_TASK" )
  [[ -f "$UNSIGNED_APK" ]] || die "Unsigned APK not found at: $UNSIGNED_APK"
}

ensure_debug_keystore() {
  if [[ ! -f "$KEYSTORE" ]]; then
    msg "Generating debug keystore at $KEYSTORE"
    keytool -genkey -v -keystore "$KEYSTORE" \
      -storepass "$KEY_PASS" -alias "$KEY_ALIAS" -keypass "$KEY_PASS" \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -dname "CN=debug, OU=debug, O=debug, L=debug, ST=debug, C=US"
  fi
}

sign_apk() {
  ensure_outdir
  msg "Signing to $SIGNED_APK"
  "$APKSIGNER_BIN" sign \
    --ks "$KEYSTORE" \
    --ks-key-alias "$KEY_ALIAS" \
    --ks-pass pass:"$KEY_PASS" \
    --key-pass pass:"$KEY_PASS" \
    --out "$SIGNED_APK" \
    "$UNSIGNED_APK"
  "$APKSIGNER_BIN" verify --verbose "$SIGNED_APK" || die "apksigner verify failed"
}

install_apk() {
  msg "Installing on device: $SIGNED_APK"
  "$ADB_BIN" install -t -r -d "$SIGNED_APK"
}

# Pull APP_ID automatically from local gradle.properties; fallback if not present.
get_app_id() {
  local app_id
  if [[ -f "$LOCAL_PROPS" ]]; then
    app_id="$(grep -E '^app\.application_id=' "$LOCAL_PROPS" | sed 's/.*=//; s/[[:space:]]//g')"
  fi
  if [[ -z "${app_id:-}" ]]; then
    app_id="com.nevakrien.luagame"
  fi
  echo "$app_id"
}

launch_app() {
  local app_id
  app_id="$(get_app_id)"
  msg "Launching package: $app_id"
  "$ADB_BIN" shell monkey -p "$app_id" -c android.intent.category.LAUNCHER 1
}

open_out() {
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$OUT_DIR" >/dev/null 2>&1 || true
  fi
}

clean_all() {
  msg "Cleaning local output + Gradle build"
  rm -rf "$OUT_DIR"
  ( cd "$ANDROID_DIR" && ./gradlew clean )
}

# -------- Commands --------
cmd="${1:-run}"
case "$cmd" in
  love)
    ensure_tools
    make_love
    ;;
  build|apk)
    ensure_tools
    make_love
    sync_props
    copy_love_to_android
    build_unsigned_apk
    ;;
  sign)
    ensure_tools
    make_love
    sync_props
    copy_love_to_android
    build_unsigned_apk
    ensure_debug_keystore
    sign_apk
    ;;
  install)
    ensure_tools
    make_love
    sync_props
    copy_love_to_android
    build_unsigned_apk
    ensure_debug_keystore
    sign_apk
    install_apk
    ;;
  run|"")
    ensure_tools
    make_love
    sync_props
    copy_love_to_android
    build_unsigned_apk
    ensure_debug_keystore
    sign_apk
    install_apk
    launch_app
    open_out
    ;;
  open)
    open_out
    ;;
  device)
    "$ADB_BIN" devices
    ;;
  clean)
    clean_all
    ;;
  *)
    cat <<EOF
Usage: $0 [command]

Commands:
  love      Build the .love only
  apk|build Build unsigned APK (after syncing props + copying .love)
  sign      Build & sign APK to $SIGNED_APK
  install   Build, sign, and install on device
  run       Build, sign, install, and launch (default)
  device    List adb devices
  open      Open the local build folder
  clean     Remove local build/ and run Gradle clean

Config:
  GAME_DIR=$GAME_DIR
  ANDROID_DIR=$ANDROID_DIR
  OUT_DIR=$OUT_DIR
  LOVE_FILE=$LOVE_FILE
  LOCAL_PROPS=$LOCAL_PROPS -> $DEST_PROPS
  UNSIGNED_APK=$UNSIGNED_APK
  SIGNED_APK=$SIGNED_APK
EOF
    ;;
esac
