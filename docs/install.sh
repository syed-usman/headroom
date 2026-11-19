#!/bin/bash
set -e

echo "=================================================="
echo "          🚀 Installing Headroom for macOS         "
echo "=================================================="

# Check OS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "❌ Error: Headroom is only available for macOS."
  exit 1
fi

TEMP_DIR=$(mktemp -d)
DMG_PATH="$TEMP_DIR/Headroom.dmg"
MOUNT_DIR="$TEMP_DIR/mount"

cleanup() {
  if [ -d "$MOUNT_DIR" ]; then
    hdiutil detach "$MOUNT_DIR" -quiet 2>/dev/null || true
  fi
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "⬇️  Downloading latest Headroom release..."
curl -fsSL "https://syed-usman.github.io/headroom/downloads/Headroom.dmg" -o "$DMG_PATH"

echo "💿 Mounting installer package..."
mkdir -p "$MOUNT_DIR"
hdiutil attach "$DMG_PATH" -nobrowse -mountpoint "$MOUNT_DIR" -quiet

echo "📦 Installing Headroom.app to /Applications..."
rm -rf /Applications/Headroom.app
cp -R "$MOUNT_DIR/Headroom.app" /Applications/

# Strip quarantine attribute so Gatekeeper allows immediate execution
xattr -cr /Applications/Headroom.app 2>/dev/null || true

echo "✅ Headroom installed successfully to /Applications/Headroom.app!"
echo "✨ Launching Headroom..."
open /Applications/Headroom.app
