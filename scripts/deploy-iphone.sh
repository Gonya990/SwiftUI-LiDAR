#!/usr/bin/env bash
# Build, install, and launch Lidar Scan on connected iPhone (LiDAR device required).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE_ID="${IOS_DEVICE_ID:-00008130-0002183A1AF9001C}"
CORE_DEVICE="${IOS_CORE_DEVICE:-E2386A00-2FF7-572E-9B77-C22D4F03FECE}"
DERIVED="${DERIVED_DATA:-/tmp/LidarScanDerived}"
BUNDLE_ID="com.igorgoncharenko.lidarscan"

# Keep project clean — regenerate if Xcode bloated it again
LINES=$(wc -l < "Lidar Scan.xcodeproj/project.pbxproj" | tr -d ' ')
if [[ "$LINES" -gt 500 ]]; then
  echo "Regenerating bloated xcodeproj ($LINES lines)..."
  rm -rf "Lidar Scan.xcodeproj"
  xcodegen generate
fi

echo "Building for device $DEVICE_ID..."
xcodebuild -project "Lidar Scan.xcodeproj" -scheme "Lidar Scan" \
  -destination "platform=iOS,id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  -derivedDataPath "$DERIVED" \
  build

APP="$DERIVED/Build/Products/Debug-iphoneos/Lidar Scan IGORAN.app"
echo "Installing..."
xcrun devicectl device install app --device "$CORE_DEVICE" "$APP"
echo "Launching $BUNDLE_ID..."
xcrun devicectl device process launch --device "$CORE_DEVICE" "$BUNDLE_ID"
echo "Done — check iPhone screen."
