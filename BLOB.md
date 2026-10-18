# Questie blobs: decisions

Questie blobs is the opt-in objective style that marks each objective's spawns as quest areas ("polygons"), each with a marker icon. This file records what David decided for blobs while the `blob` branch was merged with `waypoints` and polished to match the patrol paths, and what was built from each decision.

- How the code works: [Modules/Map/Polygon/README.md](Modules/Map/Polygon/README.md).
- How patrol paths work: [docs/waypoints.md](docs/waypoints.md).
- The full merge plan and its decision tables: [merge-plan/](merge-plan/README.md).

## How hovering and clicking work now

| You do | World map | Minimap |
|---|---|---|
| Hover a marker | The marker grows. Its quest is in the spotlight, as for any Questie objective icon: the quest's objective icons show fully opaque with their glow ring grown, and other quests' objective icons dim. Quest givers, turn-ins and townsfolk keep their look. All of its objective's areas show, every one highlighted, and other quests' areas dim with their markers. Its patrol paths highlight. | The minimap icon grows. All of its objective's areas show on the minimap, every one highlighted. Its patrol paths highlight. Nothing dims. |
| Hover an area | Only that area lights up, and the marker icon attached to it grows. Overlapping areas each grow their own marker. Nothing dims. | The same, with the marker's minimap icon. |
| Click a marker | Shows or hides its objective's areas. | The same, with a plain left-click on its minimap icon. With chat open, the click inserts the quest link instead. |
| Hover a tracker objective | Its icons grow and its quest is in the spotlight. Its patrol paths highlight, and its areas show, every one highlighted, on both maps. This works in both icon modes; only blob mode has areas. | Its areas and paths, as on the world map. |
| Hover a tracker quest title | The same for every objective of the quest. | |

**Tooltips:**
- A marker's tooltip and an area's tooltip follow the same rule. They list the areas at that spot and the icons around it, using the distance icon tooltips already use (1% on zone maps).
- In blob mode, every objective line starts with a swatch in its area's color.
- A marker's tooltip names every NPC or object its area holds (with Shift).
- A marker's own tooltip ends with a gray "Click to hide areas" or "Click to show areas".

## Decisions

### Merging `blob` with `waypoints` (2026-10-16)

| Topic | Decision |
|---|---|
| Who owns a patrol in blob mode (C-5) | The cluster the patrolling NPC spawns in, on the patrol's own zone map. Otherwise the zone's marker. |
| The MIT notice in `PolygonGeometry` (E-5) | Removed, along with the outline reduction it came with. |
| Where the polygon code lives (F-6) | `Polygon/` moved to `Modules/Map/Polygon/`, beside `Modules/Map/Waypoints/`. David: "i like a folder structure because the project keeps growing." |
| The import rule | Kept. Drawing features never import each other. Core reaches a feature only at the entry points listed in `test/MapFeatureImports.test.lua`. When core needs a feature, it adds one reviewed line to that list rather than a new hook. |

### The polish list (2026-10-16)

The numbers are the ones we discussed.

| # | Topic | Decision | Commit |
|---|---|---|---|
| 1 | Click a minimap marker | Yes: it shows or hides its areas. | `588c3dfa1` |
| 2 | Hovering a minimap marker | Yes: it shows and highlights its areas on the minimap. Since 2026-10-17 it highlights all of its objective's areas (see 6). | `f3d5ef204` |
| 3 | Hovering minimap areas | Yes, as on the world map, beneath patrol paths. | `263eedf33` |
| 4 | Hovering a world map marker also showing areas on the minimap | No, at least for now. | none |
| 5 | Hovering an area | First: an area hover counts as hovering its marker. Changed on 2026-10-17: it lights up only the area and its own marker (see the follow-ups below). | `54506c0a7`, then `339210c37` |
| 6 | Which areas highlight | First: "highlight only the one you hover". Changed on 2026-10-17: hovering a marker highlights all of its objective's areas; hovering an area highlights that area. | `339210c37` |
| 7 | Area color on tooltip lines | The color already on the icon data (the objective's color) is used. Blob mode only. | `8e806aec3` |
| 8 | Tooltip rule | List every area under the cursor and every icon within 1%. Keep the import rule and use an allowlisted entry point. | `dac9bd28f` |
| 9 | Clusters holding several NPCs | Name them all. | `78b6fc8cd` |
| 10 | Click hint | Add it; remove it if David doesn't like it. It is short and gray, and shows on a marker's own tooltip only. | `eb0298b9f` |
| 11 | Highlight strength | Keep the current highlight: the border 20% thicker and 25% brighter. Iterate later. | none |
| 12 | Marker icon color | Dropped. The glow ring already shows the area color. "Unique Map Icon Colors" is meant to give one color per quest. | none |
| 13 | Coloring routes in the area color | No. | none |
| 14 | Duplicate areas, such as quests 317 and 384 sharing the same boars | Decide later, after feeling how it flows in game. The wow-lua-bridge may be used. | open |
| 15 | Tracker hover | Hovering an objective tints its quest's icons and highlights its paths and areas. Hovering the quest title does all of that for every objective ("lets try with it highlighting all"). At first this worked in blob mode only, because it went through the markers; since 2026-10-18 it works in both icon modes (see the hover look below). | `a0ec14c90`, `a9247214d` |
| 16 | Settings | Last, once everything else is in. | open |

### Follow-ups (2026-10-17)

- **Hovering an area tints only its own marker icon.** David: "hovering on an area lights up all objectives for a quest? That makes no sense." The quest-wide tint came from treating an area hover as a hover of its marker. That uses Questie's normal icon hover, which tints every icon of the quest.
- **Hovering a marker highlights all of its objective's areas,** and tints its quest's icons as before.
- **Hovering an area no longer highlights patrol paths,** because an area hover lights up "only that area and the icon". This brings back the merge plan's decision A-6.

### The hover look (2026-10-18)

David: "I don't know if i like the icon highlighting at all, it looks cheap compared to a lot of the other things." The tint was master's own hover. Without "Unique Map Icon Colors" it tints a quest's icons `0.6, 1, 1`, which turns Questie's brown loot bags a murky green; with the setting, the icons go white. No setting turns it off.

Six looks were mocked up in game and compared side by side (`hover-compare-*.png`, untracked): dim the rest (A), grow the glow ring (B), scale up (C), brighten additively (D), A+B, and, for an area hover, glow plus scale.

| Topic | Decision |
|---|---|
| The look | **A+B**: the hovered quest's objective icons show fully opaque with their glow ring grown, and other quests' objective icons dim to at most 0.5. An area hover grows its marker and that marker's ring, and dims nothing. Additive brightening was dropped: it washes the icons out. |
| Normal mode | One look for both icon modes, replacing the tint everywhere. Two styles would mean maintaining and testing two looks to keep the worse one. Blob mode only adds things to highlight (areas, markers); core has no blob checks. |
| Glow off | David: "if we remove the icon tint, we basically cannot allow the user to disable the glow because then there would be no indication." Answer: the dimming is the main signal, so "Map Icons Glow" stays a free choice. Only a ring the player shows grows; with glows off, the dimming and the size show it. No ring appears just for the hover. |
| The hovered icon grows | Added while building, not asked: the directly hovered icon also grows 1.35×, like an area's marker. Otherwise moving from an area onto its marker shrinks the marker under the cursor. It also fixes the minimap gap where a marker's light went out as the cursor reached it. Easy to drop. |
| Tracker preview | Through a core `MapPreview` instead of the polygon feature, so hovering a tracker line previews the quest in normal mode too. Blob mode adds the areas by listening. The tracker no longer imports `QuestiePolygon`. |
| Quest givers, turn-ins, notes | A layer of their own. David: "objectives and relations should be their own pipes". Hovering one grows it but starts no spotlight, since it has nothing of its own to show, and a spotlight never dims them, whichever quest they belong to. They look different from objective icons already; dimming them only hid where the next turn-in is. |
| Draw order | David: "we have the blizzard quest offers and quest pins etc, shouldn't we just add ourselves above or below Blizzards own Quest pins?" Questie's world map icons have their own block of frame levels in Blizzard's pin level manager, just below Blizzard's active quest pins, instead of fixed levels from 2016 shared with flight points and other points of interest. Below, so Blizzard's one pin per quest stays clickable over our many icons, and the player's arrow stays on top. In the block: tiers by icon type as before, then lower on the map in front, and a grown (hovered) icon in front of all. The minimap keeps fixed levels. |
| Settings | None for now. The dim level (0.5), ring growth (1.5×) and icon growth (1.35×) are constants until item 16. |

## Technical choices made while building

These weren't asked of David. They are recorded here for review.

- **One minimap tooltip.** The minimap has one private tooltip (`MapIconTooltip.MinimapTooltip`) shared by path and area hovers, each with its own owner frame. Forever's minimap takes over `GameTooltip` every frame, so it can't be used there.
- **Highlighting** (`Modules/Map/IconHighlight.lua`, core, since 2026-10-18; it replaced the tint):
  - One quest is in the spotlight at a time, once for all of its overlapping hovers. Hovering quest 317's title in the tracker took 45 ms with one tint per marker; one shared spotlight takes about 2.4 ms in blob mode.
  - An icon can be grown by several marks at once, such as an area's and then its own hover's. The last to end shrinks it back.
  - Growing re-anchors the icon's picture, not its frame, so where the cursor finds the icon never changes and a grown icon never steals a hover.
  - The spotlight puts an icon's opacity back only if nothing changed it meanwhile, such as the tracker's focus fade or a redraw.
  - An unloading icon is let go at once, so the pool never hands out a grown icon.
  - Areas fade with their marker's opacity, so the polygon feature redraws its areas whenever any icon's hover starts or ends.
- **Route highlights:** an NPC's patrol highlight is held separately by a hover of its icon and a hover of one of its paths, so one ending keeps the other's.
- **Hovers, previews and pooled icons:**
  - A hover always ends with the data it started with, since the pool can hand an icon out again before the cursor leaves.
  - A preview (`Modules/Map/MapPreview.lua`, since 2026-10-18) belongs to the tracker line or quest log box that started it. It ends:
    - when the cursor leaves it;
    - when the same line or box is hovered again, for a leave that never came;
    - for quest log boxes, also when the box hides.
  - Closing the map ends only the areas' preview. The icons' hovers last until the preview ends.
- **Which areas count:** only areas the objective actually shows can be hovered or listed. Areas drawn just as a preview don't count.
- **Nearby icons:** they are looked up on the hovered marker's own map, not through `ZoneDB`, which throws for maps it doesn't know, such as caves.

## Still open

- **Duplicate areas (14)** and **settings (16)**.
- **Optional items left from the merge plan:**
  - A5: gamepad picking of markers nudged apart. Deferred.
  - M5: move the nudging test case out of the HereBeDragons-Pins test.
  - M4 and M6: David's local icon work.
- **Small known gaps, accepted for now:**
  - When the minimap projects again, the old cursor is checked once before the real one in the same frame.
  - Icons drawn anew during a spotlight, such as by a progress update, show at full opacity until the hover ends.
  - In normal mode a large quest's tracker preview costs a frame hitch: quest 317's title hovers 608 icons in 8.3 ms and ends in 5.3 ms.
  - Sweeping the cursor across many icons dims and undims the whole map each time. To judge by feel; a short fade could follow.
  - Other quests' patrol paths don't dim with their icons; only icons and areas do.
  - A tracker preview started with the world map closed doesn't dim the map if it opens during the preview.
  - The duplicate turn-in icons the new hover made visible are master's bug, filed as [#8067](https://github.com/Questie/Questie/issues/8067).
- **In-game checks with a real mouse:**
  - The new hover look in both icon modes, with glows on and off, and with the tracker's focus fade.
  - Area and marker hover on both maps.
  - Tracker objective and title hover.
  - The click hint.
  - Highlight strength.
  - Quests 317 and 384 overlapping.
- **Before the pull request:**
  - Drop the `merge-plan/` commits from history.
  - Decide the order relative to waypoints PR #8026.
  - Rebase onto `master`.

## Commits of the polish

| Commit | What |
|---|---|
| `e212ba745` | Move `Polygon/` into `Modules/Map/Polygon/` |
| `588c3dfa1` | Click a minimap marker to show or hide its areas |
| `f3d5ef204` | Preview areas on the minimap while a minimap marker is hovered |
| `54506c0a7` | Hovering an area hovers its marker (replaced by `339210c37`) |
| `8e806aec3` | Area color on every objective line in blob mode |
| `dac9bd28f` | Tooltips list the areas and icons at the hovered spot |
| `2dd2e9a06` | Review fixes: tints and previews no longer stick |
| `263eedf33` | Hover quest areas on the minimap |
| `78b6fc8cd` | Name every NPC and object of an area |
| `eb0298b9f` | Click hint on marker tooltips |
| `e2cfcdf05` | Tint a quest once for all its hovers |
| `a0ec14c90` | Preview an objective or a whole quest from the tracker |
| `a6f3b3d99` | Hold an NPC's route highlight per hover kind |
| `cdf9fd6e0` | Review fixes: hovers and previews end with their data; safe nearby lookup |
| `339210c37` | Light up only a hovered area and its marker; marker hover highlights all of its objective's areas |
| `5af8a3d22` | Review fix: an area's tint keeps the icon's own opacity |
| `8dc647ce1` | Move the hover tint into a core `IconHighlight` module |
| `95c5e88dd` | The new hover look: dim the rest, grow the quest's rings and the hovered icon |
| `a9247214d` | Tracker and quest log previews through a core `MapPreview`, in both icon modes |
| `926f6201e` | Review fixes: previews end with a hidden tracker line; a closed map and the minimap never dim; the badge grows with the icon; hovers told apart by icon |
| `2ee3d35e0` | Quest givers, turn-ins and townsfolk are left out of the spotlight |
| `38dc99651` | The spotlight check named by its role (`_InSpotlight`) |
| `58f25a401` | Quest icons get their own frame levels below Blizzard's quest pins; lower on the map in front; a hovered icon on top |
| `181caa81a` | Icon type numbers come from QuestieDB's enum alone; the draw order lists every icon type explicitly |
