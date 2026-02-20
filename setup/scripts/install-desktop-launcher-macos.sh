#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "ERROR: This installer only supports macOS."
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
launcher_cmd_path="$repo_root/setup/scripts/Open PocketPostdoc Safe.command"
launcher_app_path="$HOME/Desktop/Open PocketPostdoc Safe.app"
app_exec_name="Open PocketPostdoc Safe"
icon_png_path="$repo_root/setup/assets/icons/appicon.png"

cat > "$launcher_cmd_path" <<EOF
#!/usr/bin/env bash
set -euo pipefail
if ! "$repo_root/setup/scripts/open-safe-workspace.sh"; then
  echo
  echo "Launcher failed. Press Enter to close."
  read -r _
  exit 1
fi
EOF

chmod +x "$launcher_cmd_path"

app_contents_path="$launcher_app_path/Contents"
app_macos_path="$app_contents_path/MacOS"
app_resources_path="$app_contents_path/Resources"
mkdir -p "$app_macos_path" "$app_resources_path"

cat > "$app_contents_path/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$app_exec_name</string>
  <key>CFBundleIdentifier</key>
  <string>com.pocketpostdoc.safe-launcher</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Open PocketPostdoc Safe</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
</dict>
</plist>
EOF

cat > "$app_macos_path/$app_exec_name" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec /usr/bin/open -a Terminal "$launcher_cmd_path"
EOF
chmod +x "$app_macos_path/$app_exec_name"

if [ -f "$icon_png_path" ] && command -v sips >/dev/null 2>&1 && command -v iconutil >/dev/null 2>&1; then
  iconset_tmp_root="$(mktemp -d)"
  iconset_tmp_path="$iconset_tmp_root/AppIcon.iconset"
  mkdir -p "$iconset_tmp_path"

  sips -z 16 16 "$icon_png_path" --out "$iconset_tmp_path/icon_16x16.png" >/dev/null
  sips -z 32 32 "$icon_png_path" --out "$iconset_tmp_path/icon_16x16@2x.png" >/dev/null
  sips -z 32 32 "$icon_png_path" --out "$iconset_tmp_path/icon_32x32.png" >/dev/null
  sips -z 64 64 "$icon_png_path" --out "$iconset_tmp_path/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 "$icon_png_path" --out "$iconset_tmp_path/icon_128x128.png" >/dev/null
  sips -z 256 256 "$icon_png_path" --out "$iconset_tmp_path/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 "$icon_png_path" --out "$iconset_tmp_path/icon_256x256.png" >/dev/null
  sips -z 512 512 "$icon_png_path" --out "$iconset_tmp_path/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 "$icon_png_path" --out "$iconset_tmp_path/icon_512x512.png" >/dev/null
  sips -z 1024 1024 "$icon_png_path" --out "$iconset_tmp_path/icon_512x512@2x.png" >/dev/null

  iconutil -c icns "$iconset_tmp_path" -o "$app_resources_path/AppIcon.icns"
  rm -rf "$iconset_tmp_root"
fi

touch "$launcher_app_path"

echo "Desktop launcher created:"
echo "  $launcher_app_path"
echo "  (script: $launcher_cmd_path)"
