#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROM="${1:-$ROOT/work/gamedata/mm-usa.z64}"
OUTDIR="${2:-$ROOT/oracle/shiphome}"
ZAPD="$ROOT/oracle/build-cmake/ZAPD/ZAPD.out"
VENDOR="$ROOT/vendor/2ship2harkinian"
ASSETS="$ROOT/oracle/build-cmake/mm/assets"
VERSION="N64_US"
PORTVER="$(sed -n 's/^project(2s2h VERSION \([0-9.]*\) .*/\1/p' "$VENDOR/CMakeLists.txt" | head -1)"
[[ -n "$PORTVER" ]] || { echo "FATAL: could not read project version from $VENDOR/CMakeLists.txt" >&2; exit 1; }
echo "extractor portVer: $PORTVER (from vendored CMakeLists)"

[[ -x "$ZAPD" ]] || { echo "FATAL: ZAPD not built at $ZAPD" >&2; exit 1; }
[[ -f "$ROM" ]] || { echo "FATAL: ROM not found at $ROM" >&2; exit 1; }
[[ -d "$ASSETS/xml/$VERSION" && -f "$ASSETS/Config_$VERSION.xml" ]] || { echo "FATAL: extractor assets missing $ASSETS/xml/$VERSION" >&2; exit 1; }

ROM="$(cd "$(dirname "$ROM")" && pwd)/$(basename "$ROM")"
mkdir -p "$OUTDIR"

TMP="$(mktemp -d /tmp/2s2h-extract.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
ln -s "$ASSETS" "$TMP/assets"

(cd "$TMP" && "$ZAPD" ed \
    -i "assets/xml/$VERSION" \
    -b "$ROM" \
    -fl assets/filelists \
    -gsf 0 \
    -rconf "assets/Config_$VERSION.xml" \
    -se OTR \
    --otrfile mm.o2r \
    --portVer "$PORTVER" \
    -o placeholder -osf placeholder)

[[ -s "$TMP/mm.o2r" ]] || { echo "FATAL: extraction produced no mm.o2r" >&2; exit 1; }
cp "$TMP/mm.o2r" "$OUTDIR/mm.o2r"
ls -la "$OUTDIR/mm.o2r"
echo "extracted OK: $OUTDIR/mm.o2r"
