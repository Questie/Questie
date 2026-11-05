# Objective style previews

Generates what the first-login objective style popup draws its **Questie Objectives** and **Questie blobs** previews
from (`Modules/Tutorial/ObjectivePreview.lua`):

- `Modules/Tutorial/Previews/<art set>.lua`: where each race starts and, for each start area, two of its first
  quests' objectives, with the icons Questie's icon mode draws for them and the clusters `PolygonGeometry` builds
  from their spawns, in percent of the preview image. Quest and target names are English fallbacks; the preview asks QuestieDB for the client's own.
  Each area is a function, so only the one shown is built.
- `Modules/Tutorial/Previews/<area>-<art set>.blp`: each start area's map, fully explored, as 256 by 256 DXT1.

There are two art sets, and each client's TOC loads only its own: `Classic` (Era, TBC, Wrath and Forever, from
Era's art) and `Cata` (Cataclysm, Mists and later, from Mists' art, where every start area has a map of its own).
The spec in `generate.lua` (`ART_SETS`) names each race's area and each area's map, quests, objectives and colors.
Races it does not name preview their faction's area: Northshire, or the Valley of Trials for the Horde.

## Requirements

- Lua 5.1 and `uv`.
- A QuestieDB checkout, for its `data/` folder.
- The ColorContrast tool's assets for `era` and `mists` (`uv run fetch.py --flavor era` and `--flavor mists` in
  `../ColorContrast`), for each map's explored art and world extent.

## Running

From the Questie repository root:

```sh
lua "ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews/generate.lua" \
    <QuestieDB>/data ~/.cache/questie-color-contrast/era-<build> ~/.cache/questie-color-contrast/mists-<build>
uv run --no-project --with pillow python -I "ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews/images.py" \
    ~/.cache/questie-color-contrast/era-<build> ~/.cache/questie-color-contrast/mists-<build>
busted Modules/Tutorial/ObjectivePreview.test.lua
```

`generate.lua` also writes `crops.tsv`, the art pixels each image shows, which `images.py` reads.

## Choices

- **Crop:** a square around each objective's widest cluster, 1.3 times their extent and at least 170 art pixels,
  kept on the map. Spawns and clusters more than 5% outside it are left out; the preview clips the rest.
- **Icons:** as QuestieQuest places objective icons on a zone map: nearest the player first, here the quest
  giver, skipping any closer than the default objective filter distance (2, the Questie preset's) to one already
  placed, across the whole zone. Blob mode draws no per-spawn icons, so its clusters use every spawn.
- **Clusters:** `PolygonGeometry.Build` with blob mode's defaults, on world yards from the map's `UiMapAssignment`
  extent, so the areas match what blob mode draws for those spawns.
- **Colors:** Blizzard Polygon-blue and Scarlet, or Yellow where the zone, or for a Cataclysm start area its
  parent zone, bans Scarlet (`Modules/Quest/ObjectiveColorBans`).
- **Quests:** each area's first kill quest and first loot quest where it has both; Mulgore's first classic quests
  are both loot quests. A kill objective counts its quest's kill credit NPCs too, as Questie draws them. The
  generator refuses a quest without a quest giver: Cataclysm removed the old start areas' quests that way.
