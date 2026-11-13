# Map frame levels

How Questie orders what it draws on the world map and the minimap, and why it never registers levels with Blizzard.

## Why levels matter

WoW draws frames by strata, then by frame level. Frames sharing both draw in an order nobody controls, and draw layers only order regions within one frame. So whatever must draw above something else in another frame needs a higher level: icons above paths above areas, and a smaller quest area above a larger one it overlaps.

## Why Questie keeps its own levels

The world map hands out levels through Blizzard's pin level manager (`MapCanvasPinFrameLevelsManagerMixin`). Each pin type registers a range, and pins ask for their level as they place themselves. Questie only reads it:

- **Never write.** `AddFrameLevel`, `InsertFrameLevelAbove` and `InsertFrameLevelBelow` shift the start of every level type above the insert, from addon code. Blizzard's quest pins read those tainted values as they place themselves, so their protected `SetPassThroughButtons` could be blocked in combat. This was inferred from Blizzard's source and never confirmed in the client. It is why commit `fcf84ebdc` removed Questie's own level type.
- **Read fresh.** Other addons can move the levels, so every draw asks again.
- **Lacking types.** A level type the client lacks answers `PIN_FRAME_LEVEL_DEFAULT`'s 2000. Each reader checks for that.

## Who uses which levels

| Drawing | Levels | Where |
| --- | --- | --- |
| World map quest areas | From `PIN_FRAME_LEVEL_QUEST_BLOB` to the end of Blizzard's debug pins' range (`PIN_FRAME_LEVEL_DEBUG`, 4 levels), clamped below the paths. That is 2007–2013 on Forever, 2004–2010 on Era and TBC, 2002–2007 on Wrath, and 2002–2008 on Cata and Mists. Every client registers the debug range just above quest areas, with only scenario areas and map highlights between, below the first pins that areas must not cover. | `WorldMapLayers.FrameLevels("areas")` |
| World map patrol paths | 2015, fixed | `WorldMapLayers.FrameLevels("paths")` |
| World map icons | A block of their own just below Blizzard's quest pins (`PIN_FRAME_LEVEL_ACTIVE_QUEST`), inside the 500 levels Blizzard keeps for world quest pins, which Classic clients don't draw. Without that block, fixed levels from 2016. | `QuestieMap.utils.SetDrawOrder` |
| Minimap layers | The canvas root sits one level above the minimap, and each layer `MinimapCanvas.LAYER_LEVELS` (8) above the one before: areas, then paths. Minimap icons use fixed levels from 2016. | `MinimapCanvas.AddLayer` |
| Tutorial objective preview | Its canvas, 8 levels of areas, then its markers, `ObjectivePreview.LEVELS` in all. The popup border goes above them. | `ObjectivePreview`, `ChooseObjectiveType` |

## Stacking overlapping areas

Within its levels, `PolygonStacking.Levels` puts each quest area one level above the highest larger area it overlaps. The renderer applies the levels each time it publishes the visible areas. [PolygonStacking.lua](../Modules/Map/Polygon/PolygonStacking.lua) explains the rule, its grazes and why blend modes cannot replace it.

## Pitfalls

- Equal levels mean an arbitrary order: two frames at one level can draw either way round, and that can change between sessions.
- A range is only safe while nothing Blizzard draws shares it. Before widening one, check every flavor's `Blizzard_WorldMap.lua` registrations in [Gethe's wow-ui-source](https://github.com/Gethe/wow-ui-source).
- Raising minimap levels lifts drawings over the minimap's own low-level children, such as Era's zoom buttons and other addons' pins.
