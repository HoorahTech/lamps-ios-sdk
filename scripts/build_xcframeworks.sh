#!/usr/bin/env bash
# 产出 LampsSDK / LampsCSJAdapter / LampsGDTAdapter / LampsNoahAdapter / LampsDevTools
# 共 5 个 xcframework、LampsSDKResources.bundle，以及可选 ThirdParty
# （汇川 Vendor；穿山甲/优量汇来自 Pods 时可一并拷贝）。
#
# 资源不能打进静态 xcframework：静态 linkage 下 .framework 不会进 App 包，
# 宿主拿不到里面的图片。因此单独编 LampsSDKResources.bundle，与 xcframework 并列分发。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/Distribution"
OUT="$ROOT/build/xcframeworks"
ARCHIVES="$ROOT/build/archives"
VERSION="${LAMPS_SDK_VERSION:-0.0.1}"

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# 将 xcassets 编成独立 bundle。静态二进制下必须与 xcframework 并列，由宿主拷进 App。
compile_resource_bundle() {
  local dest="$1"
  local assets="$ROOT/LampsSDK/Assets/LampsSDK.xcassets"
  local tmp partial
  if [[ ! -d "$assets" ]]; then
    echo "error: missing $assets" >&2
    exit 1
  fi

  echo "==> Compile LampsSDKResources.bundle"
  tmp="$(mktemp -d)"
  partial="$tmp/partial.plist"
  rm -rf "$dest"
  mkdir -p "$dest"

  xcrun actool \
    --output-format human-readable-text \
    --notices \
    --warnings \
    --compress-pngs \
    --enable-on-demand-resources NO \
    --output-partial-info-plist "$partial" \
    --platform iphoneos \
    --minimum-deployment-target 12.0 \
    --target-device iphone \
    --target-device ipad \
    --compile "$dest" \
    "$assets"

  if [[ ! -f "$dest/Assets.car" ]]; then
    echo "error: actool did not produce Assets.car in $dest" >&2
    rm -rf "$tmp"
    exit 1
  fi

  cat > "$dest/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleIdentifier</key>
	<string>org.cocoapods.LampsSDKResources</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>LampsSDKResources</string>
	<key>CFBundlePackageType</key>
	<string>BNDL</string>
	<key>CFBundleShortVersionString</key>
	<string>${VERSION}</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>12.0</string>
</dict>
</plist>
EOF
  rm -rf "$tmp"
}

echo "==> Root: $ROOT"
echo "==> Output: $OUT"
echo "==> 提示: 出包前请确保 LampsSDK.podspec 中 use_binary = false（从源码编 Core）"

rm -rf "$OUT" "$ARCHIVES"
mkdir -p "$OUT" "$ARCHIVES"

compile_resource_bundle "$OUT/LampsSDKResources.bundle"

cd "$DIST"
echo "==> pod install (Distribution)"
pod install

WORKSPACE="$DIST/XCBuildHost.xcworkspace"
if [[ ! -d "$WORKSPACE" ]]; then
  echo "error: missing $WORKSPACE after pod install" >&2
  exit 1
fi

COMMON_SETTINGS=(
  SKIP_INSTALL=NO
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES
  ONLY_ACTIVE_ARCH=NO
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGN_IDENTITY=
  CODE_SIGNING_REQUIRED=NO
)

archive_scheme() {
  local scheme="$1"
  local dest_name="$2"
  local destination="$3"
  local archive_path="$ARCHIVES/${scheme}-${dest_name}.xcarchive"

  echo "==> Archive $scheme ($dest_name)"
  xcodebuild archive \
    -workspace "$WORKSPACE" \
    -scheme "$scheme" \
    -destination "$destination" \
    -archivePath "$archive_path" \
    -configuration Release \
    "${COMMON_SETTINGS[@]}"
}

find_framework() {
  local archive_path="$1"
  local name="$2"
  local path
  path="$(find "$archive_path/Products" -name "${name}.framework" -type d 2>/dev/null | head -n 1 || true)"
  if [[ -z "$path" ]]; then
    echo "error: ${name}.framework not found in $archive_path" >&2
    find "$archive_path/Products" -type d -name '*.framework' 2>/dev/null || true
    ls -laR "$archive_path/Products" 2>/dev/null | head -80 || true
    exit 1
  fi
  echo "$path"
}

build_xcframework() {
  local name="$1"
  archive_scheme "$name" "ios" "generic/platform=iOS"
  archive_scheme "$name" "ios-simulator" "generic/platform=iOS Simulator"

  local fw_ios fw_sim
  fw_ios="$(find_framework "$ARCHIVES/${name}-ios.xcarchive" "$name")"
  fw_sim="$(find_framework "$ARCHIVES/${name}-ios-simulator.xcarchive" "$name")"

  echo "==> create-xcframework $name"
  rm -rf "$OUT/${name}.xcframework"
  xcodebuild -create-xcframework \
    -framework "$fw_ios" \
    -framework "$fw_sim" \
    -output "$OUT/${name}.xcframework"
}

xcodebuild -workspace "$WORKSPACE" -list

for scheme in LampsSDK LampsCSJAdapter LampsGDTAdapter LampsNoahAdapter LampsDevTools; do
  build_xcframework "$scheme"
done

RELEASE="$OUT/LampsSDK-iOS-${VERSION}"
rm -rf "$RELEASE"
mkdir -p "$RELEASE/Adapters" "$RELEASE/DevTools" "$RELEASE/ThirdParty"

cp -R "$OUT/LampsSDK.xcframework" "$RELEASE/"
cp -R "$OUT/LampsSDKResources.bundle" "$RELEASE/"
cp -R "$OUT/LampsCSJAdapter.xcframework" "$RELEASE/Adapters/"
cp -R "$OUT/LampsGDTAdapter.xcframework" "$RELEASE/Adapters/"
cp -R "$OUT/LampsNoahAdapter.xcframework" "$RELEASE/Adapters/"
cp -R "$OUT/LampsDevTools.xcframework" "$RELEASE/DevTools/"

# 同步到仓库 Binary 目录，供 LampsSDK.podspec use_binary = true 引用
BINARY_DIR="$ROOT/LampsSDK/Binary"
echo "==> Sync to $BINARY_DIR"
mkdir -p "$BINARY_DIR/Adapters" "$BINARY_DIR/DevTools"
rm -rf "$BINARY_DIR/LampsSDK.xcframework"
rm -rf "$BINARY_DIR/LampsSDKResources.bundle"
rm -rf "$BINARY_DIR/Adapters/LampsCSJAdapter.xcframework"
rm -rf "$BINARY_DIR/Adapters/LampsGDTAdapter.xcframework"
rm -rf "$BINARY_DIR/Adapters/LampsNoahAdapter.xcframework"
rm -rf "$BINARY_DIR/DevTools/LampsDevTools.xcframework"
cp -R "$OUT/LampsSDK.xcframework" "$BINARY_DIR/"
cp -R "$OUT/LampsSDKResources.bundle" "$BINARY_DIR/"
cp -R "$OUT/LampsCSJAdapter.xcframework" "$BINARY_DIR/Adapters/"
cp -R "$OUT/LampsGDTAdapter.xcframework" "$BINARY_DIR/Adapters/"
cp -R "$OUT/LampsNoahAdapter.xcframework" "$BINARY_DIR/Adapters/"
cp -R "$OUT/LampsDevTools.xcframework" "$BINARY_DIR/DevTools/"

if [[ -d "$ROOT/LampsSDK/Vendor/Noah" ]]; then
  mkdir -p "$RELEASE/ThirdParty/Noah"
  rsync -a --exclude '.git' "$ROOT/LampsSDK/Vendor/Noah/" "$RELEASE/ThirdParty/Noah/"
fi

PODS_ROOT="$DIST/Pods"
if [[ -d "$PODS_ROOT/Ads-CN" ]]; then
  mkdir -p "$RELEASE/ThirdParty/Ads-CN"
  rsync -a "$PODS_ROOT/Ads-CN/" "$RELEASE/ThirdParty/Ads-CN/" || true
fi
if [[ -d "$PODS_ROOT/GDTMobSDK" ]]; then
  mkdir -p "$RELEASE/ThirdParty/GDTMobSDK"
  rsync -a "$PODS_ROOT/GDTMobSDK/" "$RELEASE/ThirdParty/GDTMobSDK/" || true
fi

cat > "$RELEASE/VERSIONS.txt" <<EOF
LampsSDK=$VERSION
BuiltAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)
Note=对齐宿主广告 SDK 主版本；详见 README-手动集成.md / scripts/FRAMEWORK_INTEGRATION.md
EOF

if [[ -f "$DIST/Podfile.lock" ]]; then
  {
    echo ""
    echo "--- Podfile.lock (Distribution) ---"
    grep -E '^\s+- (Ads-CN|BUAdSDK|GDTMobSDK|GDTDevTool|LampsSDK|LampsCSJ|LampsGDT|LampsNoah|LampsDevTools)' "$DIST/Podfile.lock" || true
  } >> "$RELEASE/VERSIONS.txt"
fi

cp "$ROOT/scripts/FRAMEWORK_INTEGRATION.md" "$RELEASE/README-手动集成.md"

echo ""
echo "==> Done"
ls -la "$OUT"/*.xcframework "$OUT"/*.bundle
echo "Release folder: $RELEASE"
