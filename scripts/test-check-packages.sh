#!/usr/bin/env bash
# Exercise check-packages.sh against repositories made up for the purpose.
#
#   bash scripts/test-check-packages.sh

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
FAILURES=0
APP_RESOLVED="Schulplaner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

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

# A repository with an accepted ADR-0005, a proposed ADR-0006, and the given
# lines in allowed-packages.txt.
repo() {
  ROOT="$(mktemp -d)"
  mkdir -p "$ROOT/docs/adr"
  printf '# ADR-0005\n\n- **Status:** accepted\n' > "$ROOT/docs/adr/0005-a-package.md"
  printf '# ADR-0006\n\n- **Status:** proposed\n' > "$ROOT/docs/adr/0006-another-package.md"
  printf '# allowed\n%s' "${1:-}" > "$ROOT/allowed-packages.txt"
}

# resolved <path> <identity> <location> [<identity> <location> ...]: a
# Package.resolved in the format Xcode 27 writes (version 3).
resolved() {
  local path="$1"; shift
  local pins=""
  while [ "$#" -gt 0 ]; do
    pins="$pins${pins:+,}{\"identity\":\"$1\",\"kind\":\"remoteSourceControl\",\"location\":\"$2\",\"state\":{\"revision\":\"0123456789abcdef\",\"version\":\"1.0.0\"}}"
    shift 2
  done
  mkdir -p "$ROOT/$(dirname "$path")"
  printf '{"originHash":"abc","pins":[%s],"version":3}\n' "$pins" > "$ROOT/$path"
}

run() {
  OUTPUT="$(GITHUB_ACTIONS='' bash "$HERE/check-packages.sh" "$ROOT" 2>&1)"
  STATUS=$?
}

echo "no package and an empty list pass"
repo
run
check "exit status" 0 "$STATUS"

echo "an allowed package passes, whatever its case and .git"
repo $'https://github.com/example/Swift-Thing ADR-0005\n'
resolved "$APP_RESOLVED" swift-thing https://github.com/example/swift-thing.git
run
check "exit status" 0 "$STATUS"

echo "a package nobody allowed fails, named with what to do"
repo
resolved "$APP_RESOLVED" swift-thing https://github.com/example/swift-thing.git
run
check "exit status" 1 "$STATUS"
check "package named" 1 "$(grep -c 'resolves swift-thing (https://github.com/example/swift-thing.git), which no ADR allows' <<<"$OUTPUT")"
check "how to allow it" 1 "$(grep -c "add the line 'https://github.com/example/swift-thing.git ADR-NNNN' to allowed-packages.txt" <<<"$OUTPUT")"

echo "a package a dependency brings along needs its own line"
repo $'https://github.com/example/swift-thing ADR-0005\n'
resolved "$APP_RESOLVED" swift-thing https://github.com/example/swift-thing.git \
                         swift-helper https://github.com/example/swift-helper.git
run
check "exit status" 1 "$STATUS"
check "only the helper named" "1 0" \
  "$(grep -c 'resolves swift-helper' <<<"$OUTPUT") $(grep -c 'resolves swift-thing' <<<"$OUTPUT")"

echo "the domain package's own Package.resolved is checked too"
repo
resolved SchulplanerKit/Package.resolved swift-thing https://github.com/example/swift-thing
run
check "exit status" 1 "$STATUS"
check "file named" 1 "$(grep -c '^SchulplanerKit/Package.resolved: resolves swift-thing' <<<"$OUTPUT")"

echo "the old format, version 1, is read as well"
repo
mkdir -p "$ROOT/SchulplanerKit"
printf '{"object":{"pins":[{"package":"Thing","repositoryURL":"https://github.com/example/thing.git","state":{"version":"1.0.0"}}]},"version":1}\n' \
  > "$ROOT/SchulplanerKit/Package.resolved"
run
check "exit status" 1 "$STATUS"

echo "checkouts of dependencies are not looked at"
repo
resolved SchulplanerKit/.build/checkouts/swift-thing/Package.resolved swift-other https://github.com/example/swift-other
resolved build/SourcePackages/checkouts/swift-thing/Package.resolved swift-other https://github.com/example/swift-other
run
check "exit status" 0 "$STATUS"

echo "the list names an accepted ADR, in the expected form"
for line in 'https://github.com/example/swift-thing ADR-0006' \
            'https://github.com/example/swift-thing ADR-0042' \
            'https://github.com/example/swift-thing' \
            'https://github.com/example/swift-thing ADR-5'; do
  repo "$line"
  resolved "$APP_RESOLVED" swift-thing https://github.com/example/swift-thing
  run
  check "'$line' fails" 1 "$STATUS"
  check "'$line' names the list's line" 1 "$(grep -c '^allowed-packages.txt:2: ' <<<"$OUTPUT")"
done

echo "a file jq cannot read fails"
repo
mkdir -p "$ROOT/SchulplanerKit"
printf 'not json\n' > "$ROOT/SchulplanerKit/Package.resolved"
run
check "exit status" 1 "$STATUS"

echo "the repository itself passes"
OUTPUT="$(bash "$HERE/check-packages.sh" 2>&1)"
check "exit status" 0 "$?"

if [ "$FAILURES" -ne 0 ]; then
  echo "$FAILURES check(s) failed"
  exit 1
fi
echo "all checks passed"
