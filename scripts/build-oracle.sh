#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="$ROOT/vendor/2ship2harkinian"
BUILD="$ROOT/oracle/build-cmake"

[[ -d "$VENDOR/.git" ]] || { echo "FATAL: vendor/2ship2harkinian missing — run scripts/bootstrap.sh" >&2; exit 1; }

if [[ -n "$(git -C "$VENDOR" status --porcelain 2>/dev/null)" ]]; then
    echo "FATAL: vendor tree is dirty — the oracle must build from PRISTINE upstream." >&2
    echo "       The overlay is applied. Reset it first:" >&2
    echo "         git -C '$VENDOR' submodule foreach --recursive 'git reset --hard -q && git clean -fdq'" >&2
    echo "         git -C '$VENDOR' reset --hard && git -C '$VENDOR' clean -fd" >&2
    echo "       then re-run this script, and scripts/apply-overlay.sh afterwards." >&2
    exit 1
fi
[[ "${1:-}" == "--clean" ]] && rm -rf "$BUILD"

cmake -S "$VENDOR" -B "$BUILD" -GNinja -DCMAKE_BUILD_TYPE:STRING=Release \
    "-DCMAKE_IGNORE_PREFIX_PATH=$HOME/Miniforge3"
cmake --build "$BUILD" --target Generate2ShipOtr --parallel 8
cmake --build "$BUILD" --parallel 8

BIN="$BUILD/mm/2s2h-macos"
[[ -x "$BIN" ]] || { echo "FATAL: expected oracle binary at $BIN" >&2; exit 1; }
echo "oracle built: $BIN"
