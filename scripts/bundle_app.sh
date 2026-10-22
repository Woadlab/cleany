#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

echo "==> Building Cleany in Release mode..."
swift build -c release

APP_NAME="Cleany"
DIST_DIR="${ROOT_DIR}/dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "==> Preparing bundle directory at ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

echo "==> Copying binary..."
cp "${ROOT_DIR}/.build/release/CleanyApp" "${MACOS_DIR}/CleanyApp"
chmod +x "${MACOS_DIR}/CleanyApp"

echo "==> Generating AppIcon if needed..."
if [ ! -f "${ROOT_DIR}/Resources/AppIcon.icns" ]; then
    python3 "${ROOT_DIR}/scripts/generate_icon.py"
fi
cp "${ROOT_DIR}/Resources/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"

echo "==> Writing Info.plist..."
cat << 'EOF' > "${CONTENTS_DIR}/Info.plist"
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
    <string>13.0</string>
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
printf "APPL????" > "${CONTENTS_DIR}/PkgInfo"

echo "==> Applying local code signature with Cleany.entitlements..."
codesign --force --deep --sign - --entitlements "${ROOT_DIR}/Cleany.entitlements" "${APP_BUNDLE}"

echo "==> Verifying signature..."
codesign --verify --deep --strict --verbose=2 "${APP_BUNDLE}"

echo "=========================================================="
echo " Successfully created: ${APP_BUNDLE}"
echo " To run the app:"
echo "   open ${APP_BUNDLE}"
echo " To install to /Applications:"
echo "   cp -R ${APP_BUNDLE} /Applications/"
echo "=========================================================="
