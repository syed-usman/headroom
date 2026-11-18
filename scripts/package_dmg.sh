#!/bin/bash
set -e

echo "📦 Packaging Headroom.dmg for direct distribution..."

# 1. Setup DMG staging directory
DMG_STAGE=".build/dmg_stage"
rm -rf "$DMG_STAGE" Headroom.dmg docs/downloads/Headroom.dmg
mkdir -p "$DMG_STAGE" docs/downloads

# 2. Copy .app bundle
cp -R Headroom.app "$DMG_STAGE/"

# 3. Create symlink to /Applications for easy drag-and-drop
ln -s /Applications "$DMG_STAGE/Applications"

# 4. Create compressed read-only APFS/HFS+ DMG
echo "💿 Creating DMG image..."
hdiutil create -volname "Headroom" \
               -srcfolder "$DMG_STAGE" \
               -ov -format UDZO \
               Headroom.dmg

# 5. Copy to web distribution downloads folder
cp Headroom.dmg docs/downloads/Headroom.dmg

# 6. Clean up staging
rm -rf "$DMG_STAGE"

echo "✅ Headroom.dmg created successfully!"
echo "   File: $(pwd)/Headroom.dmg"
echo "   Web download copy: docs/downloads/Headroom.dmg"
echo "   Size: $(du -h Headroom.dmg | cut -f1)"
