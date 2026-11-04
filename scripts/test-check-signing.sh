#!/usr/bin/env bash
# Exercise check-signing.sh against repositories made up for the purpose.
#
#   bash scripts/test-check-signing.sh

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
FAILURES=0

check() {
  if [ "$2" = "$3" ]; then
    echo "  ok    $1"
  else
    echo "  FAIL  $1"
    echo "        expected: $2"
    echo "        actual:   $3"
    FAILURES=$((FAILURES + 1))
  fi
}

# repo <file> <content>: a fresh repository with one tracked file in it.
repo() {
  REPO="$(mktemp -d)"
  git -C "$REPO" init -q
  mkdir -p "$REPO/$(dirname "$1")"
  printf '%s\n' "$2" > "$REPO/$1"
  git -C "$REPO" add -f "$1"
}

run() {
  OUTPUT="$(GITHUB_ACTIONS='' bash "$HERE/check-signing.sh" "$REPO" 2>&1)"
  STATUS=$?
}

echo "an empty team passes"
repo Config/Signing.xcconfig $'CODE_SIGN_STYLE = Automatic\nDEVELOPMENT_TEAM =\n#include? "Signing.local.xcconfig"'
run
check "exit status" 0 "$STATUS"

echo "a team written into the project fails, and the line is named"
repo App.xcodeproj/project.pbxproj $'\t\t\t\tCODE_SIGN_STYLE = Automatic;\n\t\t\t\tDEVELOPMENT_TEAM = ABCDE12345;'
run
check "exit status" 1 "$STATUS"
check "line named" 1 "$(grep -c 'App.xcodeproj/project.pbxproj:2 sets a personal signing value: DEVELOPMENT_TEAM = ABCDE12345;' <<<"$OUTPUT")"

echo "a provisioning profile and a team per SDK fail"
repo Config/Release.xcconfig $'PROVISIONING_PROFILE_SPECIFIER = "Schulplaner Dev"\nDEVELOPMENT_TEAM[sdk=iphoneos*] = ABCDE12345'
run
check "exit status" 1 "$STATUS"
check "both named" 2 "$(grep -c 'sets a personal signing value' <<<"$OUTPUT")"

echo "a team per SDK as Xcode writes it, quoted, fails"
repo App.xcodeproj/project.pbxproj $'\t\t\t\t"DEVELOPMENT_TEAM[sdk=iphoneos*]" = ABCDE12345;'
run
check "exit status" 1 "$STATUS"

echo "the signing identity is not personal"
repo App.xcodeproj/project.pbxproj $'\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Development";'
run
check "exit status" 0 "$STATUS"

echo "a committed local signing file fails"
repo Config/Signing.local.xcconfig 'DEVELOPMENT_TEAM ='
run
check "exit status" 1 "$STATUS"

echo "an untracked local signing file is not looked at"
repo Config/Signing.xcconfig 'DEVELOPMENT_TEAM ='
printf 'DEVELOPMENT_TEAM = ABCDE12345\n' > "$REPO/Config/Signing.local.xcconfig"
run
check "exit status" 0 "$STATUS"

echo "the repository itself passes"
OUTPUT="$(bash "$HERE/check-signing.sh" 2>&1)"
check "exit status" 0 "$?"

if [ "$FAILURES" -ne 0 ]; then
  echo "$FAILURES check(s) failed"
  exit 1
fi
echo "all checks passed"
