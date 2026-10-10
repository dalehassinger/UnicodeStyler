#!/bin/bash
# Builds "Unicode Styler.app" from UnicodeStyler.swift — no Xcode project needed.
# Usage: ./build.sh            -> build/Unicode Styler.app (universal: Apple silicon + Intel)
#        ./build.sh --install  -> also copies to /Applications and launches it
#        ./build.sh --release  -> also zips it to build/UnicodeStyler.zip for GitHub Releases
set -euo pipefail

APP_NAME="Unicode Styler"
EXEC_NAME="UnicodeStyler"
BUNDLE_ID="info.vcrocs.unicodestyler"
VERSION="1.1"
BUILD_NUMBER="2"
MIN_MACOS="13.0"

cd "$(dirname "$0")"
APP_DIR="build/${APP_NAME}.app"
ZIP_PATH="build/UnicodeStyler.zip"

rm -rf "$APP_DIR" "$ZIP_PATH" build/obj
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" build/obj

# Prefer full Xcode's toolchain when installed: it includes the SwiftUI macro
# plugins that the Command Line Tools leave out.
if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
echo "Using toolchain: $(xcode-select -p 2>/dev/null) ${DEVELOPER_DIR:+(override: $DEVELOPER_DIR)}"

# Compile once per architecture, then merge into one universal binary,
# so the same download runs on Apple silicon and Intel Macs.
for ARCH in arm64 x86_64; do
    echo "Compiling ($ARCH)..."
    xcrun swiftc -parse-as-library -O \
        -target "${ARCH}-apple-macos${MIN_MACOS}" \
        UnicodeStyler.swift -o "build/obj/${EXEC_NAME}-${ARCH}"
done
lipo -create "build/obj/${EXEC_NAME}-arm64" "build/obj/${EXEC_NAME}-x86_64" \
     -output "$APP_DIR/Contents/MacOS/$EXEC_NAME"
rm -rf build/obj
echo "Architectures: $(lipo -archs "$APP_DIR/Contents/MacOS/$EXEC_NAME")"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>               <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>        <string>${APP_NAME}</string>
    <key>CFBundleExecutable</key>         <string>${EXEC_NAME}</string>
    <key>CFBundleIdentifier</key>         <string>${BUNDLE_ID}</string>
    <key>CFBundlePackageType</key>        <string>APPL</string>
    <key>CFBundleShortVersionString</key> <string>${VERSION}</string>
    <key>CFBundleVersion</key>            <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>     <string>${MIN_MACOS}</string>
    <key>LSUIElement</key>                <true/>
    <key>NSHighResolutionCapable</key>    <true/>
</dict>
</plist>
PLIST

# Ad-hoc sign so it runs locally. This is not an Apple Developer ID signature,
# so downloaded copies show a Gatekeeper prompt the first time (see README).
codesign --force --deep -s - "$APP_DIR"
echo "Built: $APP_DIR (v${VERSION})"

case "${1:-}" in
    --install)
        rm -rf "/Applications/${APP_NAME}.app"
        cp -R "$APP_DIR" /Applications/
        open "/Applications/${APP_NAME}.app"
        echo "Installed to /Applications and launched — look for the icon in your menu bar."
        ;;
    --release)
        # ditto keeps the bundle structure and code signature intact (plain zip can break them).
        ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"
        echo "Release zip: $ZIP_PATH"
        echo "Publish:     gh release create v${VERSION} \"$ZIP_PATH\" --title \"Unicode Styler ${VERSION}\""
        ;;
esac
