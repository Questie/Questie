#!/usr/bin/env bash
# Renders each texture SVG here to a PNG of the SVG's own size.
set -euo pipefail
cd "$(dirname "$0")"
for svg in *.svg; do
    rsvg-convert "$svg" -o "${svg%.svg}.png"
    echo "${svg%.svg}.png"
done
