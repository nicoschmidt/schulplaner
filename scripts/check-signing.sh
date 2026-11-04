#!/usr/bin/env bash
# Fail when the repository carries personal signing settings. Read-only. Runs
# in CI.
#
#   bash scripts/check-signing.sh [repository root]
#
# Hard rule 3 in CLAUDE.md: no signing settings tied to a personal account.
# The development team belongs in Config/Signing.local.xcconfig, which git
# ignores. Choosing a team in Xcode's Signing & Capabilities tab writes it into
# project.pbxproj instead; this catches that before it is merged. To undo it,
# set the team back to "None" in that tab, or delete the DEVELOPMENT_TEAM lines
# from project.pbxproj, and put the team into the local file.

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-$(git -C "$HERE" rev-parse --show-toplevel)}"

found=0
fail() {
  echo "$1"
  [ -n "${GITHUB_ACTIONS:-}" ] && echo "::error file=$2::$1"
  found=1
}

while IFS= read -r file; do
  case "$file" in
    *Signing.local.xcconfig)
      fail "$file is personal and must not be committed: git rm --cached $file" "$file"
      continue ;;
  esac
  # A team or a profile with a value, DEVELOPMENT_TEAM = ABCDE12345, also per
  # SDK; an empty one is fine. The signing identity is not personal
  # ("Apple Development") and may be set.
  while IFS=: read -r line text; do
    fail "$file:$line sets a personal signing value: $(echo "$text" | sed 's/^[[:space:]]*//')" "$file"
  done < <(grep -nE '(DEVELOPMENT_TEAM|PROVISIONING_PROFILE(_SPECIFIER)?)(\[[^]]*\])?"?[[:space:]]*=[[:space:]]*"?[A-Za-z0-9]' "$ROOT/$file")
done < <(git -C "$ROOT" ls-files '*.pbxproj' '*.xcconfig' '*.xcscheme')

if [ "$found" -ne 0 ]; then
  echo "Signing settings are personal: they go into Config/Signing.local.xcconfig (see Config/Signing.xcconfig)."
  exit 1
fi
echo "no personal signing settings in the repository"
