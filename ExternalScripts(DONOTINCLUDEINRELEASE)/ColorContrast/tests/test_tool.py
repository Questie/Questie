"""Focused checks of the color contrast tool: its color and coordinate math, the rating fit, and its contracts with
Questie's source (the palette it reads, the overrides it applies, the Lua data it writes).

Run from the tool folder:
  uv run --no-project --with numpy --with pillow --with pytest python -m pytest tests
"""

import subprocess
import sys
from pathlib import Path

import numpy as np
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import calibration  # noqa: E402
import colorcontrast as cc  # noqa: E402
import report  # noqa: E402
from sources import FLAVORS, PaletteColor, Zone, minimap_tile, read_named_colors, read_palette  # noqa: E402

FOREVER = FLAVORS["forever"]


def test_oklab_matches_published_reference_values():
    # Björn Ottosson's reference values: sRGB red is (0.62796, 0.22486, 0.12585), white is (1, 0, 0).
    assert cc.oklab([255, 0, 0]) == pytest.approx([0.62796, 0.22486, 0.12585], abs=2e-4)
    assert cc.oklab([255, 255, 255]) == pytest.approx([1, 0, 0], abs=2e-4)


def test_minimap_tiles_follow_the_client_layout():
    # World (0, 0) is the corner of tile 32_32; a tile north (world x+) is a row up, a tile west (world y+) a
    # column left.
    assert minimap_tile(0, 0) == (32, 32)
    assert minimap_tile(1600 / 3, 0) == pytest.approx((32, 31))
    assert minimap_tile(0, 1600 / 3) == pytest.approx((31, 32))


def test_map_fractions_follow_the_zone_world_rect():
    zone = Zone(FOREVER, 1, "Test", 0, 100.0, 200.0, -300.0, -400.0)
    assert zone.world_position(0, 0) == (100.0, 200.0)
    assert zone.world_position(1, 1) == (-300.0, -400.0)
    # Map x runs east along world y; map y runs south along world x.
    assert zone.world_position(1, 0) == (100.0, -400.0)


def test_weighted_distance_weighs_blue_and_yellow_shifts_separately():
    weights = cc.Weights(lightness=1, red_green=1, blue=0.5, yellow=2)
    shifts = np.array([[0, 0, -2.0], [0, 0, 2.0], [3.0, 4.0, 0]])
    assert cc.weighted_distance(shifts, weights) == pytest.approx([1, 4, 5])


def test_threshold_fit_separates_cleanly_rated_scores():
    scores = np.array([1, 2, 3, 6, 7, 8, 11, 12], float)
    ratings = np.array([3, 3, 3, 2, 2, 2, 1, 1])
    faint, clear, loss = calibration._fit_thresholds(scores, ratings)
    assert 3 < faint < 6
    assert 8 < clear < 11
    assert loss == 0


def test_palette_parser_keeps_order_and_skips_retired_entries(tmp_path):
    source = tmp_path / "ObjectiveColors.lua"
    source.write_text('local PALETTE = {\n    {80, 113, 255, "Blizzard Polygon-blue"},\n'
                      '    -- {128, 120, 217, "Medium Purple"},\n    {149, 229, 14, "Inch Worm"},\n}\n')
    assert read_palette(source) == [PaletteColor(1, "Blizzard Polygon-blue", (80, 113, 255)),
                                    PaletteColor(2, "Inch Worm", (149, 229, 14))]
    # Old rating cells may show a retired color, so redrawing them needs those too.
    assert read_named_colors(source)["Medium Purple"] == (128, 120, 217)


def test_rated_pixels_load_from_every_round(tmp_path, monkeypatch):
    monkeypatch.setattr(calibration, "RATINGS", tmp_path)
    np.savez_compressed(tmp_path / "shifts-round1.npz", c01=np.ones((2, 3), np.float32))
    np.savez_compressed(tmp_path / "shifts-round2.npz", c02=np.zeros((2, 3), np.float32))
    shifts = calibration._load_shifts()
    assert sorted(shifts) == ["c01", "c02"]
    assert shifts["c01"].sum() == 6


def test_overrides_apply_per_flavor_by_color_name(tmp_path):
    palette = [PaletteColor(1, "Lime", (0, 249, 0)), PaletteColor(2, "Aqua", (0, 252, 255))]
    path = tmp_path / "overrides.csv"
    path.write_text("flavor,ui_map_id,color,verdict,note\nforever,1426,Aqua,allow,fits\nmists,1,Lime,ban,no\n")
    assert cc.read_overrides(palette, FOREVER, {1426}, path) == {1426: {2: ("allow", "fits")}}

    # A retired or misspelled color, or a zone the flavor doesn't have, must fail loudly rather than override
    # nothing.
    with pytest.raises(SystemExit):
        cc.read_overrides(palette, FOREVER, {1429}, path)
    path.write_text("flavor,ui_map_id,color,verdict,note\nforever,1426,Medium Purple,allow,fits\n")
    with pytest.raises(SystemExit):
        cc.read_overrides(palette, FOREVER, {1426}, path)


@pytest.mark.parametrize("arguments", [["--zones", "1426", "--write-addon"], ["--fill-min", "4", "--write-addon"]])
def test_write_addon_refuses_runs_that_would_ship_partial_or_uncalibrated_data(arguments):
    script = Path(cc.__file__)
    result = subprocess.run([sys.executable, str(script), *arguments], capture_output=True, text=True)
    assert result.returncode != 0
    assert "--write-addon needs" in result.stderr


def test_session_keys_keep_flavors_apart_where_zone_ids_collide():
    manifest = {"cells": [
        {"flavor": "forever", "ui_map_id": 1426, "view": "map", "terrain": 2, "color": "Lime"},
        {"flavor": "mists", "ui_map_id": 1426, "view": "map", "terrain": 2, "color": "Lime"},
    ]}
    taken, used = calibration._session_keys(manifest)
    assert taken == {("forever", 1426, "map", 2, "Lime"), ("mists", 1426, "map", 2, "Lime")}
    assert used == {("forever", 1426): 1, ("mists", 1426): 1}


def test_addon_data_wraps_long_ban_lists_into_valid_lua(tmp_path):
    palette = [PaletteColor(i, f"Color {i}", (i, i, i)) for i in range(1, 41)]
    zone = Zone(FOREVER, 1426, "Dun Morogh", 0, 0, 0, 0, 0)
    path = tmp_path / "Long.lua"
    report.write_addon_bans([cc.ZoneResult(zone, [], {}, set(range(1, 41)), {})], palette,
                            cc.load_settings(4.5, 0.2, 50, 6, 5), FOREVER, path)

    assert all(len(line) <= report.LUA_LINE_LIMIT for line in path.read_text().splitlines())
    stub = ('QuestieLoader = {ImportModule = function() return {AddBans = function(_, data) '
            'print(#data.byUiMapId[1426], data.byUiMapId[1426][40]) end} end}')
    output = subprocess.run(["lua", "-e", stub, str(path)], capture_output=True, text=True, check=True).stdout
    assert output.split() == ["40", "40"]


def test_addon_data_registers_valid_lua_with_the_palette(tmp_path):
    palette = [PaletteColor(1, "Lime", (0, 249, 0)), PaletteColor(2, "Aqua", (0, 252, 255)),
               PaletteColor(3, "Scarlet", (255, 38, 0))]
    zone = Zone(FOREVER, 1426, "Dun Morogh", 0, 0, 0, 0, 0)
    quiet = Zone(FOREVER, 1429, "Elwynn Forest", 0, 0, 0, 0, 0)
    results = [cc.ZoneResult(zone, [], {}, {3, 1}, {}), cc.ZoneResult(quiet, [], {}, set(), {})]
    settings = cc.load_settings(4.5, 0.2, 50, 6, 5)
    path = tmp_path / "Test.lua"
    report.write_addon_bans(results, palette, settings, FOREVER, path)

    assert all(len(line) <= report.LUA_LINE_LIMIT for line in path.read_text().splitlines())
    # Run it against a stub ObjectiveColors that prints what it registers.
    stub = ('QuestieLoader = {ImportModule = function() return {AddBans = function(source, data) '
            'local zones = {} for id in pairs(data.byUiMapId) do zones[#zones + 1] = id end '
            'print(source, table.concat(data.paletteNames, ","), table.concat(zones, ","), '
            'table.concat(data.byUiMapId[1426], ",")) end} end}')
    output = subprocess.run(["lua", "-e", stub, str(path)], capture_output=True, text=True, check=True).stdout
    assert output.split() == ["Forever", "Lime,Aqua,Scarlet", "1426", "1,3"]
