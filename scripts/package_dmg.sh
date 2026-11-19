#!/bin/bash
set -e

echo "📦 Packaging Headroom.dmg for direct distribution..."

# 1. Build latest binaries
./build.sh

# 2. Setup clean staging directory in /tmp (avoids iCloud/FileProvider xattrs)
DMG_STAGE="/tmp/headroom_dmg_stage"
rm -rf "$DMG_STAGE" Headroom.dmg docs/downloads/Headroom.dmg
mkdir -p "$DMG_STAGE" docs/downloads

# 3. Copy with -X to strip any EAs and resource forks
cp -X -R Headroom.app "$DMG_STAGE/"

# 4. Clean any residual attributes
xattr -cr "$DMG_STAGE/Headroom.app" 2>/dev/null || true
find "$DMG_STAGE" -name ".DS_Store" -delete 2>/dev/null || true

# 5. Ad-hoc codesign the staged bundle
echo "🔏 Signing app bundle..."
codesign --force --deep --sign - "$DMG_STAGE/Headroom.app"
codesign --verify --deep --strict --verbose=2 "$DMG_STAGE/Headroom.app"

# 6. Add /Applications drag-and-drop symlink
ln -s /Applications "$DMG_STAGE/Applications"

# 7. Create read-only compressed DMG
echo "💿 Creating DMG image..."
hdiutil create -volname "Headroom" \
               -srcfolder "$DMG_STAGE" \
               -ov -format UDZO \
               Headroom.dmg

# Strip attributes from output DMG
xattr -cr Headroom.dmg 2>/dev/null || true

# 8. Copy to web distribution downloads
cp Headroom.dmg docs/downloads/Headroom.dmg

# Clean up staging
rm -rf "$DMG_STAGE"

echo "✅ Headroom.dmg created successfully!"
echo "   File: $(pwd)/Headroom.dmg"
echo "   Web download copy: docs/downloads/Headroom.dmg"
echo "   Size: $(du -h Headroom.dmg | cut -f1)"
