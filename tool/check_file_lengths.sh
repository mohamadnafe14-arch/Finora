#!/usr/bin/env bash
# Fails when any Dart source file exceeds the 200-line limit.
set -euo pipefail

limit=200
status=0

while IFS= read -r file; do
  lines=$(wc -l < "$file")
  if (( lines > limit )); then
    echo "ERROR: $file has $lines lines (limit: $limit)"
    status=1
  fi
done < <(find lib test -type f -name '*.dart')

exit "$status"