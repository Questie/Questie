# Objective colors

Every quest objective has one color. It fills and outlines the objective's area (its blob) on the world map and
minimap, tints its map icons' glow, and marks it in the tracker. This covers why colors were picked badly before,
how their visibility is measured, the palette that came out of it, how Questie picks a color now, and how it was
checked.

## The problem

Two things went wrong, and players saw both.

**Some colors vanished on some ground.** A blob is a fill at 25% opacity with a border at 75%
([`PolygonMinimap`](../Modules/Map/Polygon/PolygonMinimap.lua)), so it only shows where its color moves the ground's
color enough. Stocking Jetsteam's (317) Chunk of Boar Meat was Medium Purple on Dun Morogh's snowy minimap: a faint
lavender tint, while the green blobs beside it stood out. Pale colors faded on light ground, reds on red rock, greens
on forest, and orange on the world map's tan parchment.

**Objectives in one zone shared colors.** Colors came from a fixed palette through one global cursor, so the next
objective got the next color. The palette alternates hues so that *consecutive* objectives differ, but objectives in
one zone are rarely consecutive. Other zones' objectives took colors in between, the cursor wrapped, and it
restarted every session while saved colors stayed. Two objectives in a zone could get the same color, or close
neighbors such as Lime and Spring Green.

## Measuring visibility

The color contrast tool ([`ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast`](../ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast/README.md))
measures every palette color in every outdoor zone, on the world map and the minimap. It reads the client's own art,
prepared by wow-lua-emulator: each zone's explored map art, its minimap tiles and its exploration overlays.

1. **Terrains.** It clusters a zone's ground by color (k-means in OKLab), so snow, a lake and an oasis's grass each
   become a terrain. Sub-areas didn't work for this: every Barrens sub-area, oases included, has the same median
   color as the savanna.
2. **Scores.** A color's score on a terrain is how far its 25% fill moves the ground's color, in OKLab × 100, as the
   median over the terrain's pixels. Each axis has a weight: lightness, red-green, and the blue and yellow halves of
   blue-yellow.
3. **Verdict.** A color is banned in a zone when it is too faint on at least 20% of either view's ground. One faint
   lake doesn't ban a color; faint across most of the zone does. A hand-kept overrides file settles single cases,
   such as Persian Green in Dun Morogh, which works everywhere there except one lake.

**The score is fitted to a person's eye.** The tool's rating page shows one blob on one terrain at a time, at
in-game size, blind (no scores or color names) and in shuffled order. You rate each one clear, hard but works, or
too faint. 158 ratings in two rounds fitted these weights:

| Lightness | Red-green | Blue | Yellow | Faint below (map / minimap) |
| --- | --- | --- | --- | --- |
| 0.6 | 1 | 0.9 | 1.1 | 4.80 / 4.73 |

The fit agrees with the rater on 75% of held-out cells; the rater agreed with themself on 81% of repeated cells.
These extra terms were tried and fitted to nothing:

- texture masking;
- ground lightness;
- whether a color shifts the ground along or across its own hue;
- separate weights for lightening and darkening;
- the border;
- a factor per color.

Per-color oddities belong in overrides, not in more parameters.

**What to keep in mind about the bans:**

- **They are threshold-sensitive.** Moving the faint threshold 10% either way gives between 23 and 103 bans instead
  of 47. They come from one rater.
- **They're measured on a model of the blob,** not the real one: an ellipse at each terrain's densest spot, on the
  minimap at its widest zoom. Indoor minimaps and the capitals aren't measured.
- **They matter less than spreading does.** A wrong ban only narrows the choice, and a wrong allow is at worst
  hard to see. Keeping a zone's colors apart does most of the work.

## The palette: 25 colors to 17

Before release was the free moment to curate the palette. Eight colors were banned in more than half the zones and
were retired by hand, in two steps as the calibration improved. They stay in
[`ObjectiveColors.lua`](../Modules/Quest/ObjectiveColors.lua) as comments.

| Retired | Zones banned (of 44) | Why |
| --- | --- | --- |
| *After the first rating round, out of the legacy 25:* | | |
| Alloy Orange | 44 | faint on the map's parchment and on most minimaps |
| Medium Purple | 42 | blue-violet lavender that disappears on snow and grey |
| Orange, Salmon Pink | 38, 37 | faint on the world map's tan parchment |
| *After the second round, out of the remaining 21:* | | |
| Primrose, Mauve, Downy | 40, 38, 35 | pastels barely shift any ground at 25% |
| Smalt | 35 | dark navy that vanishes on dark ground; Navy Blue covers its hue |

The rule was "banned in more than half the zones" as a one-off decision, not an automated one: a new zone can't
retire colors by itself. The remaining 17 leave 47 bans across 44 zones, and 24 zones ban nothing. By color: Persian
Green 10, Slimy Green 9, White 7, Vine Green 6, Medium Violet Red 5, Deep Cerise 4, Scarlet 4, Inch Worm 2.

Open palette questions:

- **Slimy Green and Vine Green** look the same at 25% fill. The picker keeps them apart within a zone, but one of
  them could go.
- **Orange.** None is left; only the two legacy oranges were measured, and a saturated one (say 255, 110, 0) might
  survive the parchment.

## Picking a color

[`ObjectiveColors.Get`](../Modules/Quest/ObjectiveColors.lua) picks an objective's color the first time
`QuestieQuest:PopulateObjective` draws it, after its spawn list is built, and saves it for good.

### The objective's zone: one primary zone

An objective's spawns can cover many zones. Chunk of Boar Meat drops in seven: Durotar 315 spawns, Dun Morogh 236,
Elwynn 153, Westfall 115, Loch Modan 77, Redridge 30, Teldrassil 20. Treating all seven alike fails: their bans
cover nearly every color, their neighbors use every color, and spawn counts would place an Alliance quest from Dun
Morogh in Durotar. So each objective gets **one primary zone**, from the first rule that applies:

1. **The quest's zone** (`zoneOrSort` > 0), if the objective has spawns there. That covers Stocking Jetsteam.
2. **The nearest quest giver's zone,** if the objective has spawns there. That covers quests given in a capital and
   done outside it.
3. **The zone with the most spawns,** ties going to the lowest AreaId. That covers category quests: class,
   profession, seasonal.
4. Without spawns: the quest's zone, or none for a category quest.

Every zone in these rules goes through `ZoneDB:GetParentZoneId`, so sub-zones and alternative dungeon AreaIds count as
their zone. The objective's other spawn zones are its **secondary zones**, and they only break ties.

### Neighbors

A color is in use in a zone when an objective satisfying all of these has it:

- its saved primary zone is that zone,
- its quest is in the log, and
- it isn't finished.

Primary zone rather than "has spawns there": Chunk of Boar Meat is drawn in Westfall too, but nobody works on it
there, and counting it would use up colors Westfall's own objectives need.

Special objectives (`Index` 65 and up) aren't in the quest log cache. One tied to a real objective hides when that
objective finishes, so it stops counting then. It is tied only when `RealObjectiveIndex` names an existing objective,
as `PopulateQuestLogInfo` links them. Most special objectives (about 1,370 of 1,540 in QuestieDB) carry 0 and count
until their quest completes.

### The pick

```
allowed = palette minus the primary zone's bans   (a zone banning everything still allows every color)
gap(c)  = distance from c to the nearest color in use (0 if c is in use, infinite if none are)
pick the allowed color with the largest gap
ties: used least, then banned by the fewest secondary zones, then the first at or after the session cursor
```

With nothing in use every gap ties, which keeps the legacy rotation. With every color in use the gaps are all 0, so
colors repeat as rarely as possible.

**Distance is colorblind-aware.** It is the smallest OKLab distance over three kinds of vision: normal, deuteranopia
and protanopia, using Machado 2009's simulations at full severity in linear RGB. Red-green color blindness affects
about 8% of men. Slimy Green and Scarlet are far apart for most players (0.37) but nearly the same for a deuteranope
(0.027), so the picker treats them as close.

### Login order

`GetAllQuestIds` adds quests to `QuestiePlayer.currentQuestlog` one at a time and draws each one right away, so that
list misses the quests later in the pass. Two choices make the order irrelevant without a second pass:

- **Each saved color records its primary zone,** so neighbors need no spawn lists.
- **The quest log is read from `QuestLogCache`,** which `QuestieInit` fills before the pass.

Objectives colored in the same pass see each other, since each record is written as it is picked.

### Saved colors

`Questie.db.char.objectiveColors[questId][objectiveIndex]`:

```lua
{color = "Lime", zone = 1426} -- color name, primary UiMapId (nil without a zone)
{color = "Scarlet", zone = 1426, real = 2} -- a special objective that hides once objective 2 finishes
```

- **Colors are saved by name, not palette position.** Retiring, adding or reordering palette entries recolors no
  other color's objectives; objectives saved with a retired or renamed color get a new one.
- **Saved colors never change while their quest can return.** Accepting or abandoning quests never recolors the
  map, and an abandoned or repeated quest gets its colors back. That includes the one case where order matters: a
  re-accepted quest keeps its old color even if a neighbor took that color in the meantime.
- **Quests done for good are pruned** once per session, on the first pick. A quest done for good is completed, not
  in the log, and not repeatable, daily, weekly, monthly or a holiday quest. Without pruning, saved variables would
  grow with every quest a character ever did.
- **Party members' objectives** use a saved color when there is one, and otherwise keep their pick for the session
  only. Their quests aren't in the player's log, so a saved party color would never count as anyone's neighbor, and
  the player's later picks could collide with it. The real pick happens when the player accepts the quest.

### Ban data

[`ObjectiveColorBans/Forever.lua`](../Modules/Quest/ObjectiveColorBans/Forever.lua) is generated by the tool's
`--write-addon` and registers itself through `ObjectiveColors.AddBans`. Bans name their colors, and names no longer in
the palette are skipped. The file also records:

- the TOCs meant to load it;
- each color's sRGB;
- the blob opacity.

`ObjectiveColors.test.lua` checks all three against the live TOCs, palette and `PolygonMinimap`, so changing either
without regenerating fails the build.

**The TOC decides where bans apply.** There is one generated file per measured client, listed only in the TOCs of
clients with the same UiMapIds and art. `Forever.lua` is in `Questie_Camelot.toc` alone. Elsewhere neighbor picking
still works, just without bans.

`--write-addon` refuses runs that would ship partial or unchecked data:

- subset runs;
- uncalibrated scores or non-default terrain settings;
- outdoor zones whose art wasn't prepared;
- ground without overlay, art or minimap tiles.

## Code

| File | Role |
| --- | --- |
| [`Modules/Quest/ObjectiveColors.lua`](../Modules/Quest/ObjectiveColors.lua) | Palette, saved colors, primary zone, neighbors and the pick. Public: `Get`, `GetPalette`, `AddBans`, `PrimaryZone`. |
| [`Modules/Quest/ObjectiveColorBans/Forever.lua`](../Modules/Quest/ObjectiveColorBans/Forever.lua) | Generated bans for Forever. |
| [`Modules/Quest/QuestieQuest.lua`](../Modules/Quest/QuestieQuest.lua) | `PopulateObjective` calls `ObjectiveColors.Get` after building the spawn list. |
| [`ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast/`](../ExternalScripts(DONOTINCLUDEINRELEASE)/ColorContrast/README.md) | The measuring tool, its calibration and rating session, and how to rerun them. |

The rating session is kept in git as data (each cell's place and rated pixels, and the ratings). Its pictures are
redrawn on demand, pixel for pixel, from the zones' art.

## How it was checked

- **In game:** Stocking Jetsteam with other Dun Morogh quests active. Colors differ and none is banned there, and
  every color survives `/reload`.
- **Tests:** `ObjectiveColors.test.lua` covers each rule above. Its mocks answer only what the real modules would.
  Expected colors come from an independent Python implementation of the same OKLab and vision simulations. Every
  deliberate mutation tried by the reviewers fails at least one test.
- **Reviews:** five independent reviewers covered runtime, architecture, tests, the tool and a devil's advocate,
  then a sixth checked their fixes. Their findings shaped what is described here:
  - names instead of palette positions;
  - colorblind-aware distance;
  - the `RealObjectiveIndex` rule;
  - pruning;
  - the tool's refusals.

## Known limits

- **Cache timeouts.** If the quest log cache times out at login, quests missing from it don't count as neighbors
  during that pass.
- **The giver rule inside instances.** Rule 2 measures from the player's position, which is unknown inside
  instances. For a quest with several givers, a pick made there may choose a giver zone at random. It is saved like
  any other.
- **Hidden objectives still count.** Failed quests and objectives hidden in the tracker count as neighbors, though
  they aren't drawn.
- **Drawn but not counted.** Objectives drawn outside their primary zone don't count there, such as Chunk of Boar
  Meat in Westfall, or the minimap at a zone border.

## Next: measure MoP, for the Cata and MoP clients

MoP's zones match the Cata and MoP clients: the same UiMapIds and the same post-Cataclysm art. Era, TBC and Wrath draw
Kalimdor and Eastern Kingdoms in the older art, and TBC Classic numbers Outland differently, so MoP's data must not
be listed in their TOCs.

**The work:**

1. **Prepare MoP's assets in a folder of their own.** That means every continent's minimap tiles, its db2 tables
   and its zone rects. The clients share continent IDs but not their tiles.
2. **Add a `mists` flavor to the tool.**
3. **Review the sheets,** and rate a round from MoP's new kinds of ground.
4. **Write `ObjectiveColorBans/Mists.lua`,** and list it in `Questie_Cata.toc` and `Questie_Mists.toc`.

The tool README's "Adding a flavor" has the steps.
