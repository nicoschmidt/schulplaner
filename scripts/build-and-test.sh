#!/usr/bin/env bash
# Build the app and run every test: the package's with `swift test`, in
# seconds; then the app's and the package's in the app's scheme, on a
# simulator. What CI's job `iOS` runs, and what to run before a pull request.
#
#   bash scripts/build-and-test.sh
#   DESTINATION='platform=iOS Simulator,name=iPhone 16e,OS=18.6' bash scripts/build-and-test.sh
#
# DESTINATION picks the simulator. The default exists in Xcode 27 on every
# Mac and on CI's runner; xcodebuild takes the newest iOS it has for it.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$(git -C "$HERE" rev-parse --show-toplevel)"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"

echo "== SchulplanerKit: swift test"
swift test --package-path SchulplanerKit

echo "== Schulplaner: xcodebuild test on $DESTINATION"
xcodebuild test \
  -project Schulplaner.xcodeproj \
  -scheme Schulplaner \
  -destination "$DESTINATION"
