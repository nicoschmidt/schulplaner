#!/usr/bin/env bash
# Put the app on the iPhone connected to this Mac, with a provisioning profile
# that is valid for seven days from now. Installs over the app that is there,
# so the student's data stays. docs/install-on-device.md says when and why.
#
#   bash scripts/install-on-iphone.sh
#   DEVICE='<the iPhone's name>' bash scripts/install-on-iphone.sh
#
# DEVICE picks one when several iPhones are connected. Needs the one-time
# setup of that guide: an Apple Account in Xcode, its team in
# Config/Signing.local.xcconfig, the iPhone paired and in Developer Mode.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$(git -C "$HERE" rev-parse --show-toplevel)"
BUNDLE_ID="io.github.nicoschmidt.schulplaner"
PROFILES="$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

command -v jq >/dev/null || { echo "jq is needed: brew install jq"; exit 1; }

# An entry of a provisioning profile, such as ExpirationDate.
profile_value() {
  security cms -D -i "$1" 2>/dev/null | plutil -extract "$2" raw -o - - 2>/dev/null
}

# 1. The iPhone: a physical one, by name or UDID when DEVICE is set.
xcrun devicectl list devices --json-output "$WORK/devices.json" >/dev/null
jq -r --arg want "${DEVICE:-}" '.result.devices[]
  | select(.hardwareProperties.reality == "physical" and .hardwareProperties.deviceType == "iPhone")
  | select($want == "" or .deviceProperties.name == $want or .hardwareProperties.udid == $want)
  | [.hardwareProperties.udid, .deviceProperties.name] | @tsv' "$WORK/devices.json" > "$WORK/iphones"
case "$(wc -l < "$WORK/iphones" | tr -d ' ')" in
  0)
    echo "No iPhone${DEVICE:+ called '$DEVICE'} is connected. Connect it by cable, or put it on the"
    echo "same Wi-Fi as this Mac, and unlock it (docs/install-on-device.md, section 2)."
    exit 1 ;;
  1) IFS=$'\t' read -r udid name < "$WORK/iphones" ;;
  *)
    echo "Several iPhones are connected. Pick one:"
    cut -f2 "$WORK/iphones" | sed "s/^/  DEVICE='/; s/\$/' bash scripts\/install-on-iphone.sh/"
    exit 1 ;;
esac
echo "== $name"

# 2. A fresh profile. Xcode reuses a profile while it is valid, so running
# again would not add a day; without this app's old profile, it makes a new one.
if [ -d "$PROFILES" ]; then
  for profile in "$PROFILES"/*.mobileprovision; do
    [ -e "$profile" ] || continue
    case "$(profile_value "$profile" Entitlements.application-identifier)" in
      *."$BUNDLE_ID")
        echo "Removing the old profile, valid until $(profile_value "$profile" ExpirationDate)"
        rm "$profile" ;;
    esac
  done
fi

# 3. Build what the student uses: Release, signed with the team from
# Config/Signing.local.xcconfig.
echo "== Building"
xcodebuild build \
  -project Schulplaner.xcodeproj \
  -scheme Schulplaner \
  -configuration Release \
  -destination "id=$udid" \
  -derivedDataPath "$WORK/build" \
  -allowProvisioningUpdates \
  -quiet
app="$WORK/build/Build/Products/Release-iphoneos/Schulplaner.app"

# 4. Install over the app that is there, and start it.
echo "== Installing"
xcrun devicectl device install app --device "$udid" "$app" >/dev/null
if ! xcrun devicectl device process launch --terminate-existing --device "$udid" "$BUNDLE_ID" >/dev/null 2>&1; then
  echo "Installed, but it did not start: unlock the iPhone and open Schulplaner. If iOS"
  echo "says the developer is not trusted: docs/install-on-device.md, section 4, step 3."
fi

expires="$(profile_value "$app/embedded.mobileprovision" ExpirationDate)"
until_local="$(date -j -r "$(TZ=UTC date -j -f '%Y-%m-%dT%H:%M:%SZ' "$expires" '+%s')" '+%A, %d.%m.%Y, %H:%M')"
echo "Schulplaner is on $name and opens until $until_local."
