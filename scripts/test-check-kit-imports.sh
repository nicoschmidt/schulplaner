#!/usr/bin/env bash
# Exercise check-kit-imports.sh against packages made up for the purpose.
#
#   bash scripts/test-check-kit-imports.sh

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

# package <file> <content>: a fresh package with one Swift file in it.
package() {
  PKG="$(mktemp -d)"
  mkdir -p "$PKG/$(dirname "$1")"
  printf '%s\n' "$2" > "$PKG/$1"
}

run() {
  OUTPUT="$(GITHUB_ACTIONS='' bash "$HERE/check-kit-imports.sh" "$PKG" 2>&1)"
  STATUS=$?
}

echo "plain Foundation passes"
package Sources/SchulplanerKit/Day.swift $'import Foundation\n\nstruct Day {}'
run
check "exit status" 0 "$STATUS"

echo "each forbidden framework fails, and the file is named"
for line in 'import SwiftUI' 'import UIKit' 'import SwiftData' '@preconcurrency import SwiftData' \
            'import struct SwiftUI.Color' 'import UIKit.UIColor' '  import SwiftUI // indented'; do
  package Sources/SchulplanerKit/Rule.swift $'import Foundation\n'"$line"
  run
  check "'$line' fails" 1 "$STATUS"
  check "'$line' is named" 1 "$(grep -c 'SchulplanerKit/Sources/SchulplanerKit/Rule.swift:2 ' <<<"$OUTPUT")"
done

echo "tests are checked too"
package Tests/SchulplanerKitTests/RuleTests.swift $'@testable import SchulplanerKit\nimport SwiftData'
run
check "exit status" 1 "$STATUS"

echo "names that only begin like a forbidden one pass"
package Sources/SchulplanerKit/Fine.swift $'import SwiftUIBackports\nimport UIKitLike\n// import SwiftUI in a comment'
run
check "exit status" 0 "$STATUS"

echo "the build directory is not checked"
package .build/checkouts/Other/View.swift 'import SwiftUI'
run
check "exit status" 0 "$STATUS"

echo "the repository's own package passes"
OUTPUT="$(bash "$HERE/check-kit-imports.sh" 2>&1)"
check "exit status" 0 "$?"

if [ "$FAILURES" -ne 0 ]; then
  echo "$FAILURES check(s) failed"
  exit 1
fi
echo "all checks passed"
