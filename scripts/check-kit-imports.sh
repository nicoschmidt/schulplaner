#!/usr/bin/env bash
# Fail when a Swift file of SchulplanerKit imports SwiftUI, UIKit or SwiftData,
# and name the file. Read-only. Runs in CI.
#
#   bash scripts/check-kit-imports.sh [package directory]
#
# The package holds the domain logic as pure functions of plain values: it
# cannot see screens (ADR-0002) or the storage framework (ADR-0004). The
# compiler keeps it from importing the app; this keeps it from importing the
# frameworks the app is built on. Its tests are checked too: rules are tested
# without SwiftData as well.

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PACKAGE="${1:-$(git -C "$HERE" rev-parse --show-toplevel)/SchulplanerKit}"
FORBIDDEN='SwiftUI|UIKit|SwiftData'

[ -d "$PACKAGE" ] || { echo "No package at $PACKAGE"; exit 1; }

# `import X`, `import X.Sub`, `import struct X.Y`, with attributes such as
# @testable or @preconcurrency in front.
pattern="^[[:space:]]*(@[A-Za-z_]+[[:space:]]+)*import[[:space:]]+((struct|class|enum|protocol|typealias|func|let|var)[[:space:]]+)?($FORBIDDEN)([.[:space:]]|$)"

found=0
while IFS= read -r -d '' file; do
  while IFS=: read -r line text; do
    relative="${file#"$PACKAGE"/}"
    echo "SchulplanerKit/$relative:$line imports a framework the package must not see: ${text#"${text%%[![:space:]]*}"}"
    # An annotation on the pull request, when run in GitHub Actions.
    [ -n "${GITHUB_ACTIONS:-}" ] && echo "::error file=SchulplanerKit/$relative,line=$line::SchulplanerKit must not import SwiftUI, UIKit or SwiftData (ADR-0002, ADR-0004)"
    found=1
  done < <(grep -nE "$pattern" "$file")
done < <(find "$PACKAGE" -name .build -prune -o -name '*.swift' -type f -print0)

if [ "$found" -ne 0 ]; then
  echo "SchulplanerKit decides; the app shows and stores. Move the code that needs these into the app."
  exit 1
fi
echo "SchulplanerKit imports neither SwiftUI, UIKit nor SwiftData"
