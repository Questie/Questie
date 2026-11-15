#!/usr/bin/env bash
# Renders each texture SVG here to a PNG of the SVG's own size in Icons/waypoints, which the addon
# loads. Needs rsvg-convert (librsvg).
set -euo pipefail
cd "$(dirname "$0")"
for svg in *.svg; do
    png="../../waypoints/${svg%.svg}.png"
    rsvg-convert "$svg" -o "$png"
    echo "$png"
done
