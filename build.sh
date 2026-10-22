#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
ROOT_DIR="$PWD"
APP_NAME="Cleany"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/${APP_NAME}.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "==> Building Cleany in Release mode..."
swift build -c release

echo "==> Preparing bundle directory at $APP_BUNDLE..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

echo "==> Copying binary..."
cp "$ROOT_DIR/.build/release/CleanyApp" "$MACOS_DIR/CleanyApp"
chmod +x "$MACOS_DIR/CleanyApp"

echo "==> Generating AppIcon if needed..."
if [ ! -f "$ROOT_DIR/Resources/AppIcon.icns" ]; then
    python3 "$ROOT_DIR/scripts/generate_icon.py"
fi
cp "$ROOT_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"

echo "==> Writing Info.plist..."
cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>CleanyApp</string>
    <key>CFBundleIdentifier</key>
    <string>org.woadlab.cleany</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Cleany</string>
    <key>CFBundleDisplayName</key>
    <string>Cleany</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Woadlab &amp; Cleany Contributors. Open Source (MIT).</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "==> Writing PkgInfo..."
printf "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "==> Applying local code signature with Cleany.entitlements..."
codesign --force --deep --sign - --entitlements "$ROOT_DIR/Cleany.entitlements" "$APP_BUNDLE"

echo "==> Verifying signature..."
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

echo "==> Packaging Cleany.dmg and Cleany.zip..."
DMG_STAGING="$ROOT_DIR/.build/dmg"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"
rm -f "$DIST_DIR/${APP_NAME}.dmg" "$DIST_DIR/${APP_NAME}.zip"

hdiutil create -volname "${APP_NAME}" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DIST_DIR/${APP_NAME}.dmg"
(cd "$DIST_DIR" && zip -q -r -y "${APP_NAME}.zip" "${APP_NAME}.app")
rm -rf "$DMG_STAGING"

echo "=========================================================="
echo " Successfully created:"
echo "   - $DIST_DIR/${APP_NAME}.app"
echo "   - $DIST_DIR/${APP_NAME}.dmg"
echo "   - $DIST_DIR/${APP_NAME}.zip"
echo "=========================================================="
