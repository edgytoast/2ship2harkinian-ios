#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
O2R="${1:-$ROOT/oracle/build-cmake/mm/2ship.o2r}"
VENDOR="$ROOT/vendor/2ship2harkinian"

PORTVER="$(sed -n 's/^project(2s2h VERSION \([0-9.]*\) .*/\1/p' "$VENDOR/CMakeLists.txt" | head -1)"
[[ -n "$PORTVER" ]] || { echo "FATAL: could not read project version from $VENDOR/CMakeLists.txt" >&2; exit 1; }

[[ -f "$O2R" ]] || { echo "FATAL: missing port archive $O2R" >&2; exit 1; }

O2RVER="$(python3 - "$O2R" <<'PY'
import struct, sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as z:
    b = z.read("portVersion")
if len(b) < 7:
    sys.exit("FATAL: portVersion record is %d bytes, expected >= 7" % len(b))
print("%d.%d.%d" % struct.unpack(">HHH", b[1:7]))
PY
)"

if [[ "$O2RVER" != "$PORTVER" ]]; then
    cat >&2 <<MSG
FATAL: port archive version mismatch — the app would exit on launch.
       $O2R
         carries portVersion $O2RVER
         vendored upstream is $PORTVER
       2S2H requires an EXACT major.minor.patch match for 2ship.o2r.
       Regenerate it from a PRISTINE vendor tree:
         git -C '$VENDOR' submodule foreach --recursive 'git reset --hard -q && git clean -fdq'
         git -C '$VENDOR' reset --hard && git -C '$VENDOR' clean -fd
         cmake -S '$VENDOR' -B '$ROOT/oracle/build-cmake' -GNinja \\
             -DCMAKE_BUILD_TYPE:STRING=Release "-DCMAKE_IGNORE_PREFIX_PATH=\$HOME/Miniforge3"
         cmake --build '$ROOT/oracle/build-cmake' --target Generate2ShipOtr --parallel 8
         '$ROOT/scripts/apply-overlay.sh'
MSG
    exit 1
fi
echo "port archive 2ship.o2r: portVersion $O2RVER (matches vendored $PORTVER)"
