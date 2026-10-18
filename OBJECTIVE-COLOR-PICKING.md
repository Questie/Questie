# Objective colors that stay visible and apart

## Problem

Each objective gets one color, used for its blob, its map icons' glow and its tracker entry. Colors come from a
fixed 17-color palette through a single global cursor: the next objective gets the next color. The palette order
alternates hues so that *consecutive* objectives differ, but objectives in the same zone are rarely consecutive.
Other zones' objectives take colors in between, the cursor wraps after 17, and it restarts every session while
saved colors stay. Two objectives in one zone can end up with the same color or close neighbors, such as Lime
next to Spring Green.

Some colors are also too faint on some zones' ground. The color contrast tool
(`ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast`) measures that per zone and has already retired the colors
that were faint almost everywhere. A few per-zone bans remain (47 across 44 zones; for example, the reds in Durotar
and the greens in Teldrassil).

## Goal

When an objective gets its first color, pick one that is:

1. **allowed** in the zone where the player will work on it, and
2. **as far as possible** from the colors of the other objectives the player is working on in that zone.

## Not changing

- **Saved colors are permanent.** An objective that already has a color keeps it: no re-picking, no recoloring
  of a visible map when a quest is accepted or abandoned.
- **One color per objective, everywhere.** A color is not chosen per zone at draw time.
- **Quest colors** (`QuestieLib:ColorWheel`, `quest.Color`) are a separate system and stay as they are.

## Decisions

### An objective's zone: one primary zone

An objective's spawns can cover many zones. Stocking Jetsteam (317), checked in the live client:

| Objective | Spawns per zone |
| --- | --- |
| Chunk of Boar Meat | Durotar 315, Dun Morogh 236, Elwynn 153, Westfall 115, Loch Modan 77, Redridge 30, Teldrassil 20 |
| Thick Bear Fur | Dun Morogh 82 |

`zoneOrSort` = 1 (Dun Morogh).

Treating all seven zones equally fails. Combined, their bans cover nearly every color and their neighbors use
every color, so the constraints cancel out. Spawn counts would also pick Durotar for an Alliance quest in Dun
Morogh. So each objective gets **one primary zone**, chosen by the first rule that applies:

1. **The quest's zone:** `zoneOrSort` if it is a zone (> 0, sub-zones mapped through `ZoneDB:GetParentZoneId`)
   and the objective has spawns there. This covers Stocking Jetsteam.
2. **The quest giver's zone:** the zone of the nearest giver (`DistanceUtils.GetNearestFinisherOrStarter(quest.Starts)`),
   if the objective has spawns there. This covers quests given in a capital with objectives outside it.
3. **The zone with the most spawns.** This covers category quests (`zoneOrSort` < 0: class, profession,
   seasonal).
4. No spawns at all: the quest's zone if it has one, otherwise none.

All other spawn zones are **secondary zones**. They only break ties.

Rule 2 depends on where the player stands, because the nearest giver is relative to the player. That's fine: the
rule runs once, and its result is saved.

### Neighbors: the other objectives with the same primary zone

A color is "in use" in a zone when an objective satisfying all of these has it:

- its saved primary zone is that zone,
- its quest is in the quest log, and
- it isn't finished.

Primary zone rather than "has spawns there": Chunk of Boar Meat is drawn in Westfall too, but nobody works on it
there, and counting it would only use up colors that Westfall's own objectives need.

A special objective tied to a real objective (`RealObjectiveIndex`) hides once that objective finishes, so its
record saves `real` and stops counting then. Other special objectives count until their quest completes.

### Login order: save the primary zone, read the log from `QuestLogCache`

`GetAllQuestIds` adds quests to `QuestiePlayer.currentQuestlog` one at a time and draws each one right away
(`QuestieQuest.lua:669`, `:696`). Neighbor detection can't rely on it mid-pass, because later quests aren't in it
yet. Two choices remove the problem without a second pass:

- The **saved record stores the primary zone** with the color, so an objective's zone is known without building
  its spawn list.
- **Quests in the log** come from `QuestLogCache.questLog_DO_NOT_MODIFY`, which holds the whole log before the
  pass starts. It also has each objective's `finished` flag, by the same index as `objective.Index`
  (`QuestieQuest.lua:894`).
  - Special objectives (`Index` 65 and up) aren't in the cache. They count while their quest is in the log and
    not complete.

Objectives that get their first color in the same pass see each other, because each record is written when it is
assigned. Processing order then only decides who gets which color, never whether two objectives collide.

### Picking the color

```
allowed = palette minus the primary zone's bans      (no primary zone or no bans: the whole palette)
used    = colors of the neighbors (see above)

for each allowed color c: gap(c) = distance from c to the nearest used color (0 if c is used, infinite if none are)
pick the largest gap
ties: the color used least, then the one allowed in the most secondary zones, then the first at or after the cursor
advance the cursor past the pick
```

With no neighbors every gap is infinite, so the tie-breaks reproduce the legacy rotation (plus the
secondary-zone preference).

- **Distance** is OKLab, computed once at load from the 17 palette colors (a 17×17 table). The palette order
  stops mattering for spreading colors within a zone; it only breaks ties.
- **A crowded zone falls back naturally:** with every allowed color in use, the largest gap is 0, so the tie-breaks
  decide and colors repeat as rarely as possible.

### Saved format

`Questie.db.char.objectiveColors[questId][objectiveIndex]` changes from a palette index to a record:

```lua
{color = 3, zone = 1426} -- palette index, primary UiMapId (nil when the objective has no zone)
{color = 5, zone = 1426, real = 2} -- a special objective that hides once objective 2 finishes
```

Saved colors haven't shipped yet (they aren't on `origin/master`), so there's no migration. The default stays `{}`.
Entries that aren't records, such as the palette indexes on development characters, count as invalid and get a new
color, just as invalid indexes do today. Those development entries were already renumbered when the eight colors
were retired. To start clean: `/run Questie.db.char.objectiveColors = {}`.

### Ban data: one generated file per flavor, loaded by its TOC

`colorcontrast.py --write-addon` writes `Modules/Quest/ObjectiveColorBans/<Flavor>.lua`, which registers itself:

```lua
---@type ObjectiveColors
local ObjectiveColors = QuestieLoader:ImportModule("ObjectiveColors")

ObjectiveColors.AddBans("Forever", {
    paletteNames = {"Blizzard Polygon-blue", "Inch Worm", --[[ ... ]] "Scarlet"},
    byUiMapId = {
        [1411] = {5, 7, 17}, -- Durotar: Medium Violet Red, Deep Cerise, Scarlet
        -- ...
    },
})
```

- **The TOC decides where bans apply.** `Forever.lua` is listed only in `Questie_Camelot.toc` (Forever, interface
  16001), because the bans were measured on Forever's map art. A TOC may list several flavors' files, and their
  bans combine per UiMapId. Without a file, neighbor picking still works; it just has no bans.
- **Stale data is ignored.** `AddBans` drops data whose `paletteNames` don't match the palette, and
  `ObjectiveColors.test.lua` fails on the shipped file until it is regenerated. `AddBans` runs while the TOC
  loads, before `Questie.Warning` exists, so the warning waits for the first color pick.
- **Written only by a full run.** `--write-addon` refuses `--zones`, so a quick tuning run can't drop zones from
  shipped data.

## Modules

| File | Change |
| --- | --- |
| `Modules/Quest/ObjectiveColors.lua` (new) | Owns the palette (moved from `QuestieLib`, now with names), saved records, primary zone rules, neighbors and picking. Public: `Get(quest, objective, objectiveIndex)` → `Color`, `GetPalette()` → colors and names, `AddBans(source, data)`, and the pure helpers its tests use directly: `PrimaryZone(questId, starts, spawnList)` and `Pick(allowed, used, secondaryBans, from)`. |
| `Modules/Quest/ObjectiveColorBans/Forever.lua` (new, generated) | Data above. |
| `Modules/Libs/QuestieLib.lua` | Loses `objectivePalette`, `GetObjectivePalette` and `GetObjectiveColor`. Keeps `ColorWheel`. |
| `Modules/Quest/QuestieQuest.lua` | `objective.Color = ObjectiveColors.Get(quest, objective, objective.Index or objectiveIndex)`. The spawn list is already built a few lines above. |
| All six TOCs | `ObjectiveColors.lua` after `QuestLogCache.lua`, before `QuestieQuest.lua`. `Questie_Camelot.toc` also loads `ObjectiveColorBans\Forever.lua` right after it. |
| `Blob/ObjectiveColorPreview.lua`, the tool's `sources.py` | Read the palette from `ObjectiveColors`. |

Party objectives (`QuestiePartyObjectives`) also go through `PopulateObjective`. They're drawn for quests the
player doesn't have, so a pick for them knows nothing of the player's neighbors. They use a saved color when there
is one, and otherwise keep their pick **for the session only**. The player's own pick, and the saved record, come
when the player accepts the quest.

Known limits, accepted as minor:

- If the quest log cache times out at login, quests missing from it don't count as neighbors during that pass.
- Rule 2 measures from the player's position, which is unknown inside instances. For a quest with several givers,
  a pick made there may choose a giver zone at random. It is saved like any other.
- Failed quests and objectives hidden in the tracker still count as neighbors, although they aren't drawn.

## Tests (`ObjectiveColors.test.lua`)

Each one guards a behavior a plausible change could break:

- **Primary zone:** the quest's zone wins when it has spawns; a capital-given quest falls to the giver's zone;
  category quests fall to the zone with the most spawns; a sub-zone `zoneOrSort` maps to its parent zone.
- **Bans:** a color banned in the primary zone is never picked, even when it has the largest gap.
- **Spreading:** with Lime in use in the zone, the pick isn't Spring Green, its nearest palette color.
- **Neighbor filtering:** colors of finished objectives, of quests no longer in the log, and of other primary
  zones are ignored.
- **Login order:** two new objectives in one zone, assigned back to back, get different colors.
- **Crowding:** in a zone using every allowed color, the pick still succeeds and prefers colors allowed in the
  secondary zones.
- **Permanence:** a saved record is returned without re-picking, and survives a reload (`dofile`). A non-record
  entry gets a new color.
- **Stale data:** `ObjectiveColorBans.paletteNames` matches the palette. This catches a palette edit without
  regenerating the bans.

The `QuestieLib.test.lua` objective color tests move to the new file. The special-objective test in
`QuestieQuest.test.lua` (around line 627) changes its mock from `QuestieLib.GetObjectiveColor` to
`ObjectiveColors.Get`.

## The generator lives in git

The tool and its rating session are kept in `ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast`, next to the
data file they produce. The session is kept as data (cell manifest, rated pixels, ratings); the cell pictures are
redrawn from it on demand. Rerunning the tool needs the emulator's prepared assets, which aren't in this repository.

## Order of work

1. ✅ `ObjectiveColors`, with the moved palette and saved records; `QuestieQuest` switched to it, tests moved.
2. ✅ Primary zone, neighbors and picking, with their tests.
3. ✅ The generated `ObjectiveColorBans/Forever.lua`, written by `colorcontrast.py --write-addon`, with its TOC
   entry and the stale-data test.
4. ☐ Check in game: accept Stocking Jetsteam with other Dun Morogh quests active, and check that colors differ and
   none is banned there. Then `/reload` and check that every color stays. Start from clean saves:
   `/run Questie.db.char.objectiveColors = {}`.
5. ☐ **Last step: measure MoP.** Its client has nearly every zone Era, TBC, WotLK and Cata players see, so one more
   flavor covers most clients. Prepare MoP's assets (every continent's minimap tiles, its db2 tables, its zone
   rects), add a `mists` flavor to `ColorContrast/sources.py`, review the sheets, add a rating round for new kinds
   of ground, and write `ObjectiveColorBans/Mists.lua`. Then list it in each TOC whose client shares MoP's UiMapIds
   and art. Cata and MoP renumbered the revamped zones, and TBC Classic numbers Outland differently, so check per
   client. The tool README's "Adding a flavor" has the steps.
