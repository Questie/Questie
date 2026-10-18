# Frame buffers for group opacity: investigated and rejected

How WoW's frame buffers (`Frame:SetIsFrameBuffer`) can stop overlapping half-transparent textures from drawing darker, the client quirks we measured getting there, how to work around each one, and why Questie's [waypoint lines](waypoints.md) do not use them.

## Synopsis

**Probably not worth it.** We built it, got it working on Forever 1.60.1, and removed it again:

1. **The behaviour is undocumented, and it fails silently.** Blizzard uses frame buffers only as an XML attribute on a few top-level windows, and never from Lua. Four quirks surfaced, none of them in the documentation:
   - squeezed, misplaced drawing inside clipping frames;
   - double fading through black;
   - a creation-order trap;
   - a full-screen cost per buffer.

   Each one failed without errors and took screenshots and pixel measurements to diagnose. Any client patch can change them, and we verified only one client.
2. **Working around the quirks dictates the design.** It needs hosts outside every clipping frame, clip frames inside the buffers, and grouping paths by opacity. On top of that come following the map's scale and opacity by hand, ordering frame levels, and a `Sync` step every caller must remember. That came to roughly 200 lines plus tests that mock client quirks, for a cosmetic effect.
3. **Each shown buffer costs a pass over the whole screen.** 30 buffers took a client from its 30 fps cap to 23.5 fps; 5 stayed at the cap.
4. **The visible problem had a simpler cause.** The route that looked worst was one NPC's patrol drawn once per quest icon, three copies stacking to nearly opaque. Drawing each route once fixes that directly. The darkening that remains, where an NPC walks over its own path again, is arguably information.

**What we do instead:** each identical route on a map draws once ([What we did instead](#what-we-did-instead)). A patrol that crosses or retraces itself still draws darker there.

**When to reconsider:** if self-overlaps turn out to matter to players, or Blizzard documents frame buffers or starts using them for something comparable. Re-verify every quirk below on each client first.

## The problem

Questie draws NPC patrols as half-transparent outlined lines (`{1, 0.72, 0, 0.5}`). Wherever two parts overlap, both blend, so the overlap is darker:

- where a patrol crosses itself;
- along the whole length of an out-and-back patrol;
- in the slight inside overlap that very tight mitered joins leave;
- where several icons draw the same patrol. Courier Hammerfall's 403-point Ironforge route was drawn once per quest he offered, three times at 50% each, so about 88% opaque.

"Group opacity" fixes this the way image editors do: draw the group opaque into a separate image, then fade that image once. Overlaps inside the group then show once.

## The API

| Method | What it does |
| --- | --- |
| `Frame:SetIsFrameBuffer(isFrameBuffer)` | "Controls whether or not a frame is rendered to its own framebuffer prior to being composited atop the UI." The frame renders "as if it were fully opaque", and "the alpha value assigned to the frame is only applied once the framebuffer is composited atop the UI scene." |
| `Frame:SetFlattensRenderLayers(flatten)` | "Controls whether all subregions are composited into a single render layer." Required: without it a frame buffer "may result in an invisible frame, or potentially assertion errors on test clients." Set it before `SetIsFrameBuffer(true)`. |
| `Frame:GetEffectivelyFlattensRenderLayers()` | Includes implicit flattening: `SetClipsChildren(true)` and `SetToplevel(true)` both flatten. |
| `Frame:DoesClipChildren()` | Whether a frame clips its children; needed to avoid the first quirk below. |
| `Frame:IsFrameBuffer()` | Present on Forever 1.60.1. The wiki dates it to retail 11.2.0. |

Quotes are from the wiki pages [API Frame:SetIsFrameBuffer](https://warcraft.wiki.gg/wiki/API:Frame_SetIsFrameBuffer) and [API Frame:SetFlattensRenderLayers](https://warcraft.wiki.gg/wiki/API:Frame_SetFlattensRenderLayers). The `SetIsFrameBuffer` page also has a runnable example (`FrameBufferTestMixin`) with a checkbox to toggle the flag.

**Availability:**
- **Declared everywhere we need it:** `SetIsFrameBuffer`, `SetFlattensRenderLayers` and `DoesClipChildren` are in `Blizzard_APIDocumentationGenerated/SimpleFrameAPIDocumentation.lua` on `classic_era` 1.15.9, `classic_anniversary` 2.5.6, `classic` 5.5.4 (Mists) and `forever` 1.60.1.
- **History:** the wiki says Classic patch 2.5.2 added `SetIsFrameBuffer`. On retail it was added in 9.1.0 and renamed from `SetFrameBuffer` in 10.0.0.
- **Blizzard's own use:** Blizzard sets the XML attribute `frameBuffer="true"` on `WorldMapFrame` (all four branches, for example `Blizzard_WorldMap/Blizzard_WorldMap.xml:29` on `classic_era`), on `CharacterSelect`, and on Forever's Monthly Activities. All three are whole top-level windows faded as one, with no clipping frame above them. No Blizzard Lua calls `:SetIsFrameBuffer(`.
- **Secret values:** on Forever and retail, the documentation marks `SetIsFrameBuffer`'s argument as `SecretArguments = "NotAllowed"`, so it can't be a secret value. Plain booleans are fine.

## Quirks, measured

**Method.** Test frames created in a running Forever 1.60.1 client through a development Lua bridge, at 2560×1440 with `UIParent` at an effective scale of 0.64, so 1 `UIParent` unit is 1.2 px. Each test drew solid magenta inside a buffer next to a cyan outline drawn normally where the magenta should land. A script found both colours' pixel bounding boxes in the screenshot. Colours are sampled on a white backing panel.

| # | Setup | Result |
| --- | --- | --- |
| 1 | Buffer straight on `UIParent` | Exact. 240–599 × 900–1079 px against the expected 240–600 × 900–1080. |
| 2 | Buffer inside the world map's `ScrollContainer`, which clips | Squeezed toward the screen centre: drawn at 1091–1373 × 570–737 instead of 968–1434 × 512–745. The scale per axis is the clip rectangle's share of the screen: 1556/2560 = 0.607 and 1037/1440 = 0.721. |
| 3 | Buffer inside a clipping frame over the screen's left half | Predicted from 2: 120–300 × 900–1080. Drawn: 120–299 × 900–1079. The buffer renders the whole screen and is then mapped into the nearest clipping ancestor's rectangle. |
| 4 | Buffer frame smaller than its content | Not cut at the frame. The full 180–659 × 840–1139 of the content drew, so a buffer covers the screen and the frame's size doesn't matter. |
| 5 | Clipping frame *inside* the buffer | Correct, and cut at the clip frame: 300–539 × 936–1055 against 300–540 × 936–1056. |
| 6 | Buffer at alpha 0.5, textures on the buffer frame itself | (223, 214, 191) on white, instead of the (255, 219, 127) of plain 50% yellow. That is 0.125 × yellow + 0.75 × white + 0.125 × black. |
| 7 | Buffer at alpha 0.5, textures in a child frame | (255, 219, 127), identical to plain 50% drawing. |
| 8 | Child frame attached *after* the buffer got its alpha | (223, 214, 191) again, and the child reports `GetEffectiveAlpha()` 0.5 instead of 1. |
| 9 | Variants of 8 | Setting the same alpha again: no fix. Hiding and showing the buffer: no fix. Changing the alpha and back: fixed. Toggling `SetIsFrameBuffer` off and on: fixed. |
| 10 | Clip frame attached *before* the buffer gets its alpha, with views and textures added later | All (255, 219, 127), effective alpha 1. That includes frames attached to the correct child, textures created later, and textures moved in from another frame. |
| 11 | Mask texture on a texture inside a buffer | Works, whether the mask belongs to a frame inside the buffer or outside it. Clean 240 px circles. |
| 12 | 30 shown buffers, each holding one 10×10 texture | 30 fps (the background frame cap) fell to 23.5 fps. 5 buffers stayed at 30. |

## The rules, and how to live with them

1. **Never put a buffer inside a frame that clips its children** (rows 2–3). Not even indirectly: the squeeze uses the nearest clipping ancestor.
   - **Workaround:** hang the buffer off a frame outside the clipping area, and crop with a clipping frame *inside* the buffer (row 5).
   - **Checking at runtime:** walk the parents with `DoesClipChildren()`. If any ancestor clips, fall back to plain fading.
2. **A buffer does not crop to its own frame** (row 4). Crop with a clip frame inside it, as in rule 1.
3. **Keep textures off the buffer frame itself** (rows 6–7). The frame's alpha fades its own regions inside the buffer too, and the result fades through black. Put them in child frames.
   - This matches the wiki example, where the frame's own row of textures "will become less opaque while enabled".
4. **Attach the direct children before the buffer gets its alpha** (rows 8–10). The client gives a buffer's children full opacity only while it applies the buffer's alpha. A direct child attached afterwards inherits the alpha normally, and everything below it fades twice.
   - **Order:** create the buffer, then its direct child, then `SetFlattensRenderLayers`, `SetIsFrameBuffer` and `SetAlpha`. Frames and textures below a correctly set-up child can join any time.
   - **Repair:** change the alpha and back, or toggle the buffer flag off and on.
   - **Checking:** `GetEffectiveAlpha()` on a frame inside the buffer reports the state reliably. 1 is right; the buffer's alpha means it will draw faded twice.
   - **How it shows up:** the creation order was wrong in our first build. Something else re-applying alpha down the tree, presumably the map frame's own alpha, usually repaired it before anyone looked. Roetten Stonehammer's path in the Hall of Explorers was one that stayed broken. Its line core measured (121, 121, 66) over a (125, 135, 85) background, which is exactly 12.5% yellow plus 75% background, against the (187, 158, 44) of a correct 50%. Paths in the same buffer, drawn the same way, looked fine.
5. **Keep shown buffers few** (row 12). Each one costs a pass over the whole screen.
   - **Workaround:** share a buffer among everything at the same opacity, and hide it while nothing in it shows.
   - **Side effect:** overlaps between different paths at that opacity then also draw once.
6. **Flatten before buffering**, as the documentation requires. Masks keep working (row 11).

## The design that worked

```text
host            covers the visible area, outside every clipping frame
 |              world map: a WorldMapFrame child over the ScrollContainer
 |              minimap: the layer's root, which no longer clips
 +- buffer      one per opacity, in hundredths: default 0.5, hostile 0.7, highlighted 0.8, fades
     +- clip    SetClipsChildren, covers the host; scale = canvas effective scale / host's
         +- view    one frame per path; line textures opaque, anchored to the canvas in canvas units
```

```lua
local buffer = CreateFrame("Frame", nil, host)
buffer:SetAllPoints(host)
local clip = CreateFrame("Frame", nil, buffer)    -- attached before the alpha applies (rule 4)
clip:SetAllPoints(host)
clip:SetScale(canvas:GetEffectiveScale() / host:GetEffectiveScale())
clip:SetClipsChildren(true)                       -- crops inside the buffer (rules 1-2)
buffer:SetFlattensRenderLayers(true)              -- before the buffer flag (rule 6)
buffer:SetIsFrameBuffer(true)
buffer:SetAlpha(opacity)
-- Each path's view: CreateFrame("Frame", nil, clip); lines tinted (r, g, b, 1) (rule 3).
```

Integration details it needed:

- **Following the canvas:** the paths no longer sit inside the canvas, so the clip frames copy its scale. A post-hook on `WorldMapFrame:OnCanvasScaleChanged` resynced right after the scroll container scaled the canvas, every frame of a zoom. Textures stayed anchored to the canvas, so panning needed nothing.
- **Map opacity:** the host copied `ScrollContainer:GetAlpha()` each frame. The windowed map's opacity setting (Era, Anniversary, Wrath, Cata) fades only the scroll container.
- **Visibility:** a `Sync` after every show, hide or restyle showed exactly the groups that had a shown view.
- **Draw order:** groups took up to four frame levels by opacity, so a highlighted path drew over hostile and normal ones. A buffer, its clip frame and its views shared a level.
- **Fallback:** where an ancestor clipped, groups faded as plain frames instead.
- **Toggle:** `WaypointRenderer.groupOpacity` for comparing in game.

**Verified in game on Forever 1.60.1:**
- Courier Hammerfall's route drew exactly where plain drawing put it, zoomed out and at maximum zoom, and was cut at the map window's edge.
- Its crossings no longer darkened, and its three copies drew as one line.
- A highlighted copy drew on top.
- After a reload, highlighting, unhighlighting and switching maps, every shown path reported an effective alpha of 1.
- On the minimap, a test path drew centred on the player, stopped at the round mask and left the hole over the player arrow, with Questie's icons above it.

**Never checked:**
- the world map's fade while moving. `WorldMapFrame` is itself a frame buffer, so the waypoint buffers nested inside it.
- the windowed map's opacity setting;
- frame rate in a dense zone with several opacities shown;
- any client other than Forever.

The implementation changed `WaypointRenderer`, `WaypointMap` and `WaypointMinimap` and was never committed. The layout and code above are the reference.

## What we did instead

Several icons can own the same patrol: an NPC who starts three quests gets three quest icons, and each one draws his route. Each route on a map now draws once.
- **Matching copies:** `QuestieMap:DrawWaypoints` takes whose waypoints they are, as Questie's tooltip keys (`"m_<npcId>"`, `"o_<objectId>"`). `QuestieWaypoints.Add` gives each path a `route` from that key, its area and its part of the patrol, so every icon drawing the same NPC's patrol produces the same routes.
- **World map:** `WaypointMap` draws one view per route. It shows the copy whose owner is hovered, otherwise the most visible one.
- **Minimap:** `WaypointMinimap` likewise draws the most visible copy.

A patrol that crosses or retraces itself still draws darker where it overlaps. That is accepted: it marks where the NPC walks twice.
