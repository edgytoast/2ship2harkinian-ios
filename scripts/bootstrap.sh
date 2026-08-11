#!/bin/bash
set -euo pipefail

PIN="d35196ad7e93a77184e0745abc9865f04f9a9378" # tag 5.0.0 "Battler Alfa", 2026-08-11
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
