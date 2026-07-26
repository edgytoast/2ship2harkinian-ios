#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/spikes/2s2h-sim-build/mm/Release-iphonesimulator/2ship.app"
BUNDLE_ID="com.harbourmasters.2s2h"
MM="$ROOT/oracle/shiphome/mm.o2r"
SHOT="${1:-sim-boot}"
UDID="5B40BEAC-0576-400A-9B34-5C347D5BEAE7"

[[ -d "$APP" ]] || { echo "FATAL: no sim app at $APP — run scripts/build-sim.sh" >&2; exit 1; }
[[ -f "$MM" ]] || { echo "FATAL: no mm.o2r — run scripts/extract-mm-o2r.sh" >&2; exit 1; }

xcrun simctl bootstatus "$UDID" -b   # boots if needed, waits until ready
xcrun simctl install "$UDID" "$APP"

CONTAINER=$(xcrun simctl get_app_container "$UDID" "$BUNDLE_ID" data)
mkdir -p "$CONTAINER/Documents"
cp "$MM" "$CONTAINER/Documents/mm.o2r"
echo "seeded mm.o2r into $CONTAINER/Documents"

xcrun simctl launch "$UDID" "$BUNDLE_ID" || true
echo "launched $BUNDLE_ID on sim; waiting for boot (first launch compiles shaders, 30-45s)…"

for _ in $(seq 1 12); do
    xcrun simctl spawn "$UDID" log show --last 30s 2>/dev/null | grep -qE "Cutscene_HandleConditionalTriggers|Starting 2 Ship 2 Harkinian" && break
    sleep 5
done

mkdir -p "$ROOT/artifacts"
xcrun simctl io "$UDID" screenshot "$ROOT/artifacts/$SHOT.png"
echo "captured artifacts/$SHOT.png"
sips -g pixelWidth -g pixelHeight "$ROOT/artifacts/$SHOT.png" 2>/dev/null | tail -2 || true

LOGDIR="$CONTAINER/Documents/logs"
if [[ -d "$LOGDIR" ]]; then
    cp -R "$LOGDIR" "$ROOT/artifacts/$SHOT-logs"
    echo "--- SOH_PERF (simulator, non-authoritative) ---"
    grep -h "SOH_PERF" "$ROOT/artifacts/$SHOT-logs"/* 2>/dev/null | tail -3 || echo "(no perf lines yet)"
fi
