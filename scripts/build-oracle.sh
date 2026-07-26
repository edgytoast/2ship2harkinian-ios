#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="$ROOT/vendor/2ship2harkinian"
BUILD="$ROOT/oracle/build-cmake"

[[ -d "$VENDOR/.git" ]] || { echo "FATAL: vendor/2ship2harkinian missing — run scripts/bootstrap.sh" >&2; exit 1; }
[[ "${1:-}" == "--clean" ]] && rm -rf "$BUILD"

cmake -S "$VENDOR" -B "$BUILD" -GNinja -DCMAKE_BUILD_TYPE:STRING=Release
cmake --build "$BUILD" --target Generate2ShipOtr --parallel 8
cmake --build "$BUILD" --parallel 8

BIN="$BUILD/mm/2s2h-macos"
[[ -x "$BIN" ]] || { echo "FATAL: expected oracle binary at $BIN" >&2; exit 1; }
echo "oracle built: $BIN"
