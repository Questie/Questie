"""Focused checks of the color contrast tool: its color and coordinate math, the rating fit, and its contracts with
Questie's source (the palette it reads, the overrides it applies, the Lua data it writes).

Run from the tool folder:
  uv run --no-project --with numpy --with pillow --with pytest python -m pytest tests
"""

import csv
import json
import subprocess
import sys
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer
from pathlib import Path
from threading import Thread

import numpy as np
import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import calibration  # noqa: E402
import colorcontrast as cc  # noqa: E402
import fetch  # noqa: E402
import report  # noqa: E402
import sources  # noqa: E402
from sources import (  # noqa: E402
    FLAVORS, Flavor, PaletteColor, Zone, minimap_tile, read_named_colors, read_outdoor_maps, read_palette,
    unmeasured_zones,
)

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
    zone = Zone(FOREVER, 1, "Test", 0, 100.0, 200.0, -300.0, -400.0, 0, 0)
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


@pytest.mark.parametrize("arguments", [
    ["--zones", "1426"], ["--fill-min", "4"], ["--percentile", "40"], ["--clusters", "8"], ["--merge-distance", "3"],
])
def test_write_addon_refuses_runs_that_would_ship_partial_or_uncalibrated_data(arguments, monkeypatch):
    # In process, with every way to reach the data or write it stubbed out: a broken guard fails this test instead
    # of overwriting the shipped file.
    def must_not_run(*_args, **_kwargs):
        raise AssertionError("the guard let the run through")
    monkeypatch.setattr(cc, "read_zones", must_not_run)
    monkeypatch.setattr(report, "write_addon_bans", must_not_run)
    monkeypatch.setattr(sys, "argv", ["colorcontrast.py", "--write-addon", *arguments])
    with pytest.raises(SystemExit, match="--write-addon needs"):
        cc.main()


def _write_map_tables(flavor, maps, assignments, arts, instances):
    """A flavor's UiMap, UiMapAssignment, UiMapXMapArt and Map tables with just the columns the tool reads."""
    tables = {
        "UiMap": (["ID", "Name_lang", "Type"], maps),
        "UiMapAssignment": (["ID", "UiMapID", "OrderIndex", "MapID", "UiMin_0", "UiMin_1", "UiMax_0", "UiMax_1",
                             "Region_0", "Region_1", "Region_2", "Region_3", "Region_4", "Region_5", "AreaID"],
                            assignments),
        "UiMapXMapArt": (["ID", "PhaseID", "UiMapArtID", "UiMapID"], arts),
        "Map": (["ID", "InstanceType"], instances),
    }
    flavor.db2.mkdir(parents=True)
    for table, (columns, rows) in tables.items():
        with (flavor.db2 / f"{table}.csv").open("w", newline="", encoding="utf-8") as handle:
            csv.writer(handle).writerows([columns, *rows])


def _whole_map(row_id, ui_map_id, order, instance, x_min=-1, y_min=-1, x_max=1, y_max=1, area=0):
    return [row_id, ui_map_id, order, instance, 0, 0, 1, 1, x_min, y_min, -1e6, x_max, y_max, 1e6, area]


def test_outdoor_maps_are_open_world_zones_with_their_world_rect_and_default_art(tmp_path, monkeypatch):
    monkeypatch.setattr(sources, "ASSETS", tmp_path)
    flavor = Flavor("test", "Test", (), "wow_test", "1.0.0.1")
    _write_map_tables(
        flavor,
        maps=[[1411, "Durotar", 3], [378, "The Wandering Isle", 6], [12, "Kalimdor", 2], [91, "Alterac Valley", 3],
              [390, "Vale of Eternal Blossoms", 3]],
        # Durotar's row from Forever's UiMapAssignment; its second assignment must not win.
        assignments=[_whole_map(46721, 1411, 0, 1, -1716.6666259766, -7249.9995117188, 1808.3332519531,
                                -1962.4998779297),
                     _whole_map(46799, 1411, 1, 2),
                     _whole_map(2, 378, 0, 860), _whole_map(3, 12, 0, 1), _whole_map(4, 91, 0, 30),
                     _whole_map(5, 390, 0, 870)],
        arts=[[1, 0, 2, 1411], [2, 0, 390, 378], [3, 0, 96, 91], [4, 25585, 402, 390], [5, 25583, 1972, 390]],
        instances=[[1, 0], [2, 0], [860, 0], [30, 3], [870, 0]],
    )

    zones = {zone.ui_map_id: zone for zone in read_outdoor_maps(flavor)}

    # Continents are no zones, and a battleground is no open world.
    assert sorted(zones) == [378, 390, 1411]
    # Forever's live client: C_Map.GetWorldPosFromMapPos(1411, (0, 0)) and (1, 1).
    durotar = zones[1411]
    assert (durotar.continent, durotar.x0, durotar.y0, durotar.x1, durotar.y1) == pytest.approx(
        (1, 1808.3332519531, -1962.4998779297, -1716.6666259766, -7249.9995117188))
    # Without a default (phase 0) art, the oldest art is measured.
    assert zones[390].art == 402


def test_a_client_measured_on_another_ships_its_bans_under_its_own_ids_by_area(tmp_path, monkeypatch):
    # Cata draws MoP's art but numbers old-world zones like Classic: MoP's Durotar (1) is Cata's 1411.
    monkeypatch.setattr(sources, "ASSETS", tmp_path)
    mop = Flavor("mop", "MoP", (), "wow_test", "5.0.0.1")
    cata = Flavor("cat", "Cat", (), "wow_test", "4.0.0.1", measured_on="mop")
    monkeypatch.setitem(cc.FLAVORS, "mop", mop)
    _write_map_tables(mop, maps=[[1, "Durotar", 3], [371, "The Jade Forest", 3], [85, "Orgrimmar", 3]],
                      assignments=[_whole_map(1, 1, 0, 1, area=14), _whole_map(2, 371, 0, 870, area=5785),
                                   _whole_map(3, 85, 0, 1, area=1637)],
                      arts=[[1, 0, 2, 1], [2, 0, 383, 371], [3, 0, 90, 85]], instances=[[1, 0], [870, 0]])
    _write_map_tables(cata, maps=[[1411, "Durotar", 3], [1454, "Orgrimmar", 3], [1999, "Cata only", 3]],
                      assignments=[_whole_map(1, 1411, 0, 1, area=14), _whole_map(2, 1454, 0, 1, area=1637),
                                   _whole_map(3, 1999, 0, 1, area=999)],
                      arts=[[1, 0, 2, 1411], [2, 0, 90, 1454], [3, 0, 7, 1999]], instances=[[1, 0]])
    durotar, jade_forest = (Zone(mop, ui_map_id, name, 0, 0, 0, 0, 0, 0, area)
                            for ui_map_id, name, area in ((1, "Durotar", 14), (371, "The Jade Forest", 5785)))
    results = [cc.ZoneResult(zone, [], {}, {3}, {}) for zone in (durotar, jade_forest)]

    # A map MoP doesn't have would ship without bans unnoticed; it must be measured or skipped.
    with pytest.raises(SystemExit, match="Cata only"):
        cc.under_own_ids(results, cata)

    cata = Flavor("cat", "Cat", (), "wow_test", "4.0.0.1", skip_zones=((1999, "test"),), measured_on="mop")
    shipped = cc.under_own_ids(results, cata)
    # Durotar's bans move to 1411; Pandaria's zones don't exist in Cata.
    assert [(result.zone.ui_map_id, result.banned) for result in shipped] == [(1411, {3})]


def test_unmeasured_zones_name_outdoor_maps_without_art_unless_skipped(tmp_path, monkeypatch):
    monkeypatch.setattr(sources, "ASSETS", tmp_path)
    flavor = Flavor("test", "Test", (), "wow_test", "1.0.0.1", skip_zones=((3, "capital"),))
    _write_map_tables(flavor, maps=[[1, "Measured", 3], [2, "New", 3], [3, "Capital", 3]],
                      assignments=[_whole_map(i, i, 0, 0) for i in (1, 2, 3)],
                      arts=[[i, 0, i, i] for i in (1, 2, 3)], instances=[[0, 0]])
    (flavor.explored / "1").mkdir(parents=True)
    assert unmeasured_zones(flavor) == [(2, "New")]


def _write_table(path, columns, rows):
    with path.open("w", newline="", encoding="utf-8") as handle:
        csv.writer(handle).writerows([columns, *rows])


def test_explored_art_is_composed_only_from_overlays_with_tiles(tmp_path, monkeypatch):
    # Wintergrasp's overlays are hit areas without tiles (TextureWidth 0). They must not make the map look measurable.
    monkeypatch.setattr(sources, "ASSETS", tmp_path)
    flavor = Flavor("test", "Test", (), "wow_test", "1.0.0.1")
    _write_map_tables(flavor, maps=[[1, "Hit areas only", 3], [2, "Explored", 3]],
                      assignments=[_whole_map(1, 1, 0, 0), _whole_map(2, 2, 0, 0)],
                      arts=[[1, 0, 101, 1], [2, 0, 102, 2]], instances=[[0, 0]])
    _write_table(flavor.db2 / "WorldMapOverlay.csv",
                 ["ID", "UiMapArtID", "TextureWidth", "TextureHeight", "OffsetX", "OffsetY"],
                 [[11, 101, 0, 0, 0, 0], [12, 102, 0, 0, 0, 0], [20, 102, 256, 256, 0, 0]])
    _write_table(flavor.db2 / "WorldMapOverlayTile.csv",
                 ["ID", "RowIndex", "ColIndex", "LayerIndex", "FileDataID", "WorldMapOverlayID"], [[1, 0, 0, 0, 9, 20]])
    for ui_map_id in (1, 2):
        (flavor.maps / str(ui_map_id)).mkdir(parents=True)
        Image.new("RGBA", (256, 256), (0, 0, 255, 255)).save(flavor.maps / str(ui_map_id) / "r0c0.png")
    Image.new("RGBA", (256, 256), (255, 0, 0, 255)).save(flavor.maps / "2" / "o20-r0c0.png")

    fetch.compose_explored(flavor)

    assert not (flavor.explored / "1").exists()
    with Image.open(flavor.explored / "2" / "r0c0.png") as tile:
        assert tile.getpixel((128, 128)) == (255, 0, 0, 255)


def test_overlay_tiles_smaller_than_their_visible_part_leave_the_rest_clear(tmp_path):
    # Some of Era's last-row tiles are 32 pixels tall where the overlay's 289-pixel height leaves 33 to show.
    Image.new("RGBA", (256, 256), (0, 0, 0, 255)).save(tmp_path / "o5-r0c0.png")
    Image.new("RGBA", (256, 32), (0, 0, 0, 255)).save(tmp_path / "o5-r1c0.png")
    alpha = sources._overlay_alpha(tmp_path, {"ID": "5", "TextureWidth": "256", "TextureHeight": "289"})
    assert alpha.shape == (289, 256)
    assert alpha[287].min() == 255 and alpha[288].max() == 0


def test_rating_server_takes_ratings_only_from_its_own_page(tmp_path, monkeypatch):
    monkeypatch.setattr(calibration, "RATINGS", tmp_path)
    calibration._RatingHandler.manifest = {"order": ["c01"], "cells": []}
    server = ThreadingHTTPServer(("127.0.0.1", 0), calibration._RatingHandler)
    Thread(target=server.serve_forever, daemon=True).start()
    port = server.server_port

    def post(body, origin=None, content_type="application/json", host=None):
        headers = {"Content-Type": content_type, **({"Origin": origin} if origin else {}),
                   **({"Host": host} if host else {})}
        request = urllib.request.Request(f"http://127.0.0.1:{port}/api/rate", json.dumps(body).encode(), headers)
        try:
            return urllib.request.urlopen(request).status
        except urllib.error.HTTPError as error:
            return error.code

    try:
        assert post({"key": "c01", "rating": 2}, origin="http://evil.example") == 403
        assert post({"key": "c01", "rating": 2}, content_type="text/plain") == 403
        assert post({"key": "c01", "rating": 2}, host=f"evil.example:{port}") == 403  # DNS rebinding
        assert post({"key": "c01", "rating": True}) == 400  # a JSON true is not the rating 1
        assert post({"key": "c99", "rating": 2}) == 400
        assert post({"key": "c01", "rating": 3}, origin=f"http://127.0.0.1:{port}") == 200
    finally:
        server.shutdown()
    assert [json.loads(line)["rating"] for line in (tmp_path / "judgments.jsonl").read_text().splitlines()] == [3]


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
    zone = Zone(FOREVER, 1426, "Dun Morogh", 0, 0, 0, 0, 0, 0, 1)
    path = tmp_path / "Long.lua"
    report.write_addon_bans([cc.ZoneResult(zone, [], {}, set(range(1, 41)), {})], palette,
                            cc.load_settings(4.5, 0.2, 50, 6, 5), FOREVER, (0.25, 0.75), path)

    assert all(len(line) <= report.LUA_LINE_LIMIT for line in path.read_text().splitlines())
    stub = ('QuestieLoader = {ImportModule = function() return {AddBans = function(data) '
            'print(#data.byUiMapId[1426], (data.byUiMapId[1426][40]:gsub(" ", "_"))) end} end}')
    output = subprocess.run(["lua", "-e", stub, str(path)], capture_output=True, text=True, check=True).stdout
    assert output.split() == ["40", "Color_40"]


def test_addon_data_registers_valid_lua_with_the_palette(tmp_path):
    palette = [PaletteColor(1, "Lime", (0, 249, 0)), PaletteColor(2, "Aqua", (0, 252, 255)),
               PaletteColor(3, "Scarlet", (255, 38, 0))]
    zone = Zone(FOREVER, 1426, "Dun Morogh", 0, 0, 0, 0, 0, 0, 1)
    quiet = Zone(FOREVER, 1429, "Elwynn Forest", 0, 0, 0, 0, 0, 0, 12)
    results = [cc.ZoneResult(zone, [], {}, {3, 1}, {}), cc.ZoneResult(quiet, [], {}, set(), {})]
    settings = cc.load_settings(4.5, 0.2, 50, 6, 5)
    path = tmp_path / "Test.lua"
    report.write_addon_bans(results, palette, settings, FOREVER, (0.25, 0.75), path)

    assert all(len(line) <= report.LUA_LINE_LIMIT for line in path.read_text().splitlines())
    # Run it against a stub ObjectiveColors that prints what it registers.
    stub = ('QuestieLoader = {ImportModule = function() return {AddBans = function(data) '
            'local zones = {} for id in pairs(data.byUiMapId) do zones[#zones + 1] = id end '
            'print(table.concat(data.tocs, ","), table.concat(data.measuredOpacity, ","), '
            'table.concat(data.measuredColors.Scarlet, ","), table.concat(zones, ","), '
            'table.concat(data.byUiMapId[1426], ",")) end} end}')
    output = subprocess.run(["lua", "-e", stub, str(path)], capture_output=True, text=True, check=True).stdout
    assert output.split() == ["Questie_Camelot.toc", "0.25,0.75", "255,38,0", "1426", "Lime,Scarlet"]
