#!/bin/bash
set -euo pipefail

PIN="a7e3e7c29be41cf67d89bdcb2f501d36d6106544" # develop, 4.0.2 lineage, 2026-07-09
REPO="https://github.com/HarbourMasters/2ship2harkinian.git"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="$ROOT/vendor/2ship2harkinian"

if [[ ! -d "$VENDOR/.git" ]]; then
    git clone --recurse-submodules "$REPO" "$VENDOR"
fi
git -C "$VENDOR" fetch --tags origin
git -C "$VENDOR" checkout --detach "$PIN"
git -C "$VENDOR" submodule update --init --recursive

echo "vendor pinned: $(git -C "$VENDOR" rev-parse HEAD)"
echo "submodules:"
git -C "$VENDOR" submodule status
