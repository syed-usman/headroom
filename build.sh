#!/bin/bash
set -e

echo "🔨 Building Headroom (Core, CLI, and SwiftUI App)..."
mkdir -p .build /tmp/swift_cache Headroom.app/Contents/MacOS Headroom.app/Contents/Resources

# 1. Compile Core Library
swiftc -emit-module -emit-module-path .build/HeadroomCore.swiftmodule \
       -module-name HeadroomCore -parse-as-library -whole-module-optimization \
       -module-cache-path /tmp/swift_cache Sources/HeadroomCore/*.swift \
       -c -o .build/HeadroomCore.o

# 2. Compile CLI Executable
swiftc -I .build -parse-as-library -module-cache-path /tmp/swift_cache \
       Sources/HeadroomCLI/main.swift .build/HeadroomCore.o \
       -o .build/headroom

# 3. Compile SwiftUI App Executable
swiftc -I .build -parse-as-library -module-cache-path /tmp/swift_cache \
       Sources/HeadroomApp/*.swift .build/HeadroomCore.o \
       -o .build/HeadroomApp

# 4. Assemble macOS .app Bundle
cp .build/HeadroomApp Headroom.app/Contents/MacOS/HeadroomApp
chmod +x Headroom.app/Contents/MacOS/HeadroomApp

# 5. Bundle Icon & Plist
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns Headroom.app/Contents/Resources/AppIcon.icns
fi

echo "✅ Build succeeded!"
echo "   CLI: .build/headroom"
echo "   App: Headroom.app (open with 'open Headroom.app')"
