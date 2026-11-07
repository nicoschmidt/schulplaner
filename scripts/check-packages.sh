#!/usr/bin/env bash
# Fail when a resolved package dependency is not on allowed-packages.txt, and
# name it. Read-only. Runs in CI, after the packages have been resolved.
#
#   bash scripts/check-packages.sh [repository root]
#
# Hard rule 1 in CLAUDE.md: student data stays with the student, so nothing
# third-party enters the app without an ADR (ADR-0002). This compares every
# Package.resolved in the repository — the app's and SchulplanerKit's, written
# when Xcode or `swift package` resolves — with the list, and checks that each
# line of the list names an accepted ADR. Needs jq.

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-$(git -C "$HERE" rev-parse --show-toplevel)}"
LIST="allowed-packages.txt"

command -v jq >/dev/null || { echo "jq is needed: brew install jq"; exit 1; }
[ -f "$ROOT/$LIST" ] || { echo "No $LIST in $ROOT"; exit 1; }

failed=0
fail() {
  echo "$1"
  [ -n "${GITHUB_ACTIONS:-}" ] && echo "::error file=$2::$1"
  failed=1
}

# Lower case, without a trailing slash or ".git": how two URLs are compared.
normalize() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's#/+$##; s#\.git$##'
}

# The list: every line names a package and the accepted ADR that allows it.
allowed=""
number=0
while IFS= read -r raw || [ -n "$raw" ]; do
  number=$((number + 1))
  read -r url adr extra <<<"${raw%%#*}"
  [ -z "${url:-}" ] && continue
  where="$LIST:$number"
  if [ -z "${adr:-}" ] || [ -n "${extra:-}" ] || ! [[ "$adr" =~ ^ADR-[0-9]{4}$ ]]; then
    fail "$where: expected '<repository URL> ADR-NNNN', found: $url ${adr:-} ${extra:-}" "$LIST"
    continue
  fi
  record="$(find "$ROOT/docs/adr" -name "${adr#ADR-}-*.md" 2>/dev/null | head -n 1)"
  if [ -z "$record" ]; then
    fail "$where: $adr does not exist in docs/adr/" "$LIST"
  elif ! grep -qE '^- \*\*Status:\*\* accepted' "$record"; then
    fail "$where: $adr is not accepted, so it allows nothing yet" "$LIST"
  else
    allowed="$allowed$(normalize "$url")"$'\n'
  fi
done <"$ROOT/$LIST"

# The resolved packages. Checkouts of dependencies carry their own
# Package.resolved, which says nothing about what this project resolved.
checked=0
while IFS= read -r -d '' resolved; do
  file="${resolved#"$ROOT"/}"
  # Package.resolved version 2 and 3 have "pins" with identity and location;
  # version 1 had "object.pins" with package and repositoryURL.
  if ! pins="$(jq -r '(.pins // .object.pins // [])[]
      | [(.identity // .package // ""), (.location // .repositoryURL // "")] | @tsv' "$resolved")"; then
    fail "$file: not a Package.resolved that jq can read" "$file"
    continue
  fi
  while IFS=$'\t' read -r identity location; do
    [ -z "$identity$location" ] && continue
    checked=$((checked + 1))
    if ! grep -qxF "$(normalize "${location:-$identity}")" <<<"$allowed"; then
      fail "$file: resolves $identity (${location:-no location}), which no ADR allows. To allow it, accept an ADR that decides it in docs/adr/, then add the line '${location:-$identity} ADR-NNNN' to $LIST." "$file"
    fi
  done <<<"$pins"
done < <(find "$ROOT" \( -name .git -o -name .build -o -name build -o -name DerivedData -o -name SourcePackages \) -prune \
           -o -name Package.resolved -type f -print0)

if [ "$failed" -ne 0 ]; then
  exit 1
fi
echo "every resolved package is allowed by an ADR ($checked resolved)"
