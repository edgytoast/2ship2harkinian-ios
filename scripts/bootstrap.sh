#!/bin/bash
set -euo pipefail

PIN="8a24047fbce8915993804e7819f4df4fa591551f" # tag 5.0.1 "Battler Bravo", 2026-08-30
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
