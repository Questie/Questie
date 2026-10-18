# Area B: MapIconTooltip API and the tooltip state contract

Scope: `Modules/Tooltips/MapIconTooltip.lua`, its test, and every module that reads or writes the state Questie hangs on tooltip frames.

`WP` is `origin/waypoints` (`7c1e28bd8`), `B` is `blob` (`715031ef6`) and `M` is `origin/master` (`3e8baa279`). Line numbers are for that ref. `F` is Area F's `F-seams.md`.

This version follows David's architecture (`01-architecture.md`) and Area F's seams. The previous version is in commit `e71e6dd38`. B's own commits are **B-F1**, **B-F2** and **B-F3**, as the README names them. **F-1…F-7** are Area F's seam commits.

**Summary**
- Resolve the rebase with WP's 4-argument `ShowOnTooltip` layered on B's `ShowForIcons`. With B-F3 already on `waypoints` (Phase 0), that passes both branches' tests: 20 after `dfb97c802` and 23 after `715031ef6`.
- After stacking, MapIconTooltip owns the tooltip state privately and exposes `GetOwner`, `Release` and `Redraw`. The loose fields `_Rebuild`, `ShownAsMapIcon` and `_mapIconOwner` go, and `_owner` goes back to the tracker.
- The minimap path tooltip moves to `ShowForIcons`, and `ShowOnTooltip` returns to master's two arguments.
- Hover side effects move out of the tooltip module, into `QuestieFrame`'s `ApplyHoverHighlights`/`ResetHoverHighlights` and the features' `HoverStart`/`HoverEnd` listeners (Area F, F-3/F-4).
- **Order:** B-F3 lands on `waypoints` in Phase 0. In Phase 2, F-1…F-6 come first, then B-F1, then B-F2. B's former F4 is gone, because F-4 does that work.

I validated all of this with throwaway copies outside both checkouts: `git merge-file` replays of the two commits, a `git archive` export of `origin/waypoints`, and prototype runs of every affected test file. For this version I also:
- replayed both commits onto a `waypoints` export that already has B-F3;
- applied B-F1's and B-F2's `QuestieFrame` and `WaypointHover` rows on top of Area F's prototype (F-1 and F-3 to F-5 on a `waypoints` export).

Nothing in either checkout was changed.

---

## 1. Problem

### 1.1 What each branch did to `MapIconTooltip.lua`, function by function, against master

| Function | M | WP | B |
|---|---|---|---|
| Imports | `QuestieMap` (:6-7) and data modules | Drops `QuestieMap`. Adds `QuestieWaypoints` and `WaypointHover` (:30-33) | Keeps `QuestieMap` (:6-7). Adds `QuestiePolygon` (:32-33) |
| `DEFAULT_WAYPOINT_HOVER_COLOR` | :49 | deleted | kept (:51) |
| `MapIconTooltip:Show()` (the IconFrame OnEnter, `QuestieFramePool.lua` M :57, WP :56) | `ShowOnTooltip(self, GameTooltip)` | Calls `WaypointHover.End(self)` first (:65-69) | unchanged (:67-69) |
| `ShowOnTooltip` | `(self, Tooltip)` (:71). Alpha 0 gate; 50 ms throttle; `_owner`/`SetOwner(self)`; cluster distance; `lineFrames` recolor through `zoneWaypointHoverColorOverrides` (:108-112); `touchedPins` tint; collects entries from the visible icons near `self`, `CustomTooltipData` included; sets the render fields; `_Rebuild` closure (:225); `ShownAsMapIcon = true` (:474) | `(self, Tooltip, owner?, icons?)` (:79). Skips the alpha gate when given an owner (:82). `SetOwner(owner or self)` (:93). `QuestieWaypoints.SetHighlighted(self.data, true)` replaces the recolor (:117). `handleMapIcon(icon, listed)`: given icons skip the hidden, faded and distance checks (:140, :149, :166-170, :210-213). `CustomTooltipData` dropped. The render closure sorts givers by name (:246-249), a giver's quests by level (:266-270) and active quests by level (:391) | `(self, Tooltip)` (:73). Calls `QuestiePolygon.EnterMarker(self)` before the throttle (:79). The throttle adds `Tooltip:IsOwned(self)` (:80-84). Keeps the `lineFrames` recolor (:109-113). Only collects the nearby icons (:128-173), then calls `ShowForIcons(self, icons, Tooltip)` (:175) |
| `ShowForIcons` | — | — | New (:178-499): `(owner, icons, Tooltip, objectivePrefix?)`. Writes `_owner` and `_mapIconOwner` and calls `SetOwner(owner)` (:186-189). Collects entries from exactly these icons, `CustomTooltipData` included (:220-222). `miniMapIcon = owner.miniMapIcon` (:231). Master's unsorted render closure (:248). `ShownAsMapIcon = true` (:497) |
| `Release` | — | — | New (:501-512): clears the fields if `_mapIconOwner == owner`, and hides the tooltip if `IsOwned(owner)` |
| `GetObjectiveTooltip` | `(icon)` | unchanged | `(icon, prefix?)`: the prefix goes before the local objective line only, never party lines (:606-608, :696) |
| `IsMinimapInside`, `_GetQuestTag`, `GetAvailableOrCompleteTooltip`, `AddTooltipsForQuest`, `GetLevelString`, `GetNextQuestInChainLines` | — | unchanged | unchanged |

Two corrections to the brief:
- **Party progress lines are unchanged on both branches.** They are master's code (M :591-652). B's only wording change is the objective prefix.
- **B's objective colors never reach this file directly.** The palette in `QuestieLib:GetObjectiveColor` (from B commit `6bdc1ad30`) reaches the tooltip only through the polygon swatch prefix (`B QuestiePolygon.lua:331-335`). Tooltip text colors still come from `QuestieLib:GetRGBForObjective`, which is unchanged on both branches.

### 1.2 The loose tooltip state

| Field | Written by | Cleared by | Read by |
|---|---|---|---|
| `_owner` | MapIconTooltip (M :83, WP :92, B :186). Also the tracker: `TrackerBaseFrame.lua:545` and `TrackerHeaderFrame.lua:87` (all refs) | nobody | EventHandler Shift redraw: map branch (M/WP :503; B guard :502 and :505) and the tracker sizer branch (M :517; B :519) |
| `_Rebuild` | MapIconTooltip (M :225, WP :235, B :248) | `_QuestieFrame.OnLeave` (M :143, WP :147, B :148); `WaypointHover._Leave` (WP :90); `Release` (B :508) | EventHandler (M/WP :500/:504; B :501/:506) |
| `ShownAsMapIcon` | MapIconTooltip (M :474, WP :494, B :497) | `OnLeave` (M :147, WP :151, B :152); `WaypointHover._Leave` (WP :90); `Release` (B :509) | `Tooltip.lua` object post-call, Classic OnUpdate hook, native quest lines (M/B :505, :654, :719; WP :517, :666, :731) |
| `_mapIconOwner` (B only) | `ShowForIcons` (:188) | `Release` (:507) | `Release` (:506) |
| `npcAndObjectOrder`, `questOrder`, `manualOrder`, `miniMapIcon` | the show functions (M :205-208, WP :215-218, B :228-231) | overwritten by the next show | the render closure only. The tests also read `GameTooltip.questOrder` |
| `data.touchedPins` (on the icon's data) | `ShowOnTooltip` tint (M :132, WP :137, B :130) | `QuestieFrame.ResetHoverHighlights` (M :159-166, WP :158-165, B :164-171) | the same |

### 1.3 Where the branches collide, and what breaks

**Text conflicts during the rebase.** These were reproduced with `git merge-file`. Only two blob commits touch these files:
- `dfb97c802` *feat(polygon): integrate cached objective areas with Questie* conflicts only in the import block. Its test file auto-merges.
- `715031ef6` *chore: wip snapshot of uncommitted blob work* conflicts in two hunks of `MapIconTooltip.lua` and one in the test file.

**Silent hazards outside the conflict markers** in the `715031ef6` auto-merge:
1. B's `local icons = {}` (the cluster list) shadows WP's `icons` parameter. WP's "given icons" loop, `for _, icon in ipairs(icons or {}) do handleMapIcon(icon, true) end`, then walks the list it appends to. With B's side of the hunk, `handleMapIcon` appends every near icon, and the hovered icon is always near. **The result is an infinite loop on the first hover, which freezes the client.**
2. `CustomTooltipData` comes back inside `ShowForIcons`. WP deleted it on purpose in `10f276e2d`, because nothing has set it since 2022. Its title-string key would also break `SortQuestIDsByLevel(self.questOrder, true)`.
3. `MapIconTooltip.ShowForIcons(self, icons, Tooltip)` drops WP's `owner`. The minimap path tooltip would then be owned by an icon that HereBeDragons may hide, so it would not show.

**Runtime collisions once combined.** These are not textual conflicts.
- (a) `WaypointHover._Leave` (WP :86-91) clears `_Rebuild` and `ShownAsMapIcon` whenever another frame holds GameTooltip. Over an area, that frame is B's area tooltip, so the area tooltip loses its Shift redraw and its `ShownAsMapIcon`. This is half of finding 7.
- (b) B's EventHandler guard (:501-502) trusts `_owner`, which the tracker also writes.
- (c) Shift never redraws WP's `QuestieWaypointMinimapTooltip` (WP `docs/waypoints.md:228` says so).
- (d) **WP bug, confirmed by a probe test against WP's code:** re-entrant tint. A world map path hover opens its NPC's tooltip through OnEnter. When the cursor reaches the icon itself more than 50 ms later, `ShowOnTooltip` runs again before any reset. It replaces `data.touchedPins` with the already tinted colors, so on leave the quest's objective icons stay tinted. The probe saved `{0.6, 1, 1, 1}` instead of the original color.
- (e) **B bug:** gamepad hover of a polygon marker calls `EnterMarker` inside `ShowOnTooltip`. `GamepadMapHover.Leave` (:109-119) never calls `LeaveMarker`, so the area preview stays until a map change.
- (f) **Combined:** a route owned by a blob-mode fallback marker opens that marker's OnEnter on path hover, which previews its areas. If another frame then takes GameTooltip, such as the area tooltip, `_Leave` takes its partial branch (`_ResetTooltipChanges`, WP :86-91). That branch never ends the marker preview, so the preview leaks.

**Fixed by:**
- B-F1 fixes (a), (b) and (c).
- B-F3 fixes (d) in Phase 0, before the rebase.
- F-3 fixes (e) and (f). Every hover end emits `HoverEnd`, and polygon's listener ends the preview.

---

## 2. Comparison

| | WP | B |
|---|---|---|
| Generalization | Optional `owner` and `icons` on the hovered-icon function. `owner` also silently switches off the alpha gate. Cannot express "exactly these icons, no hovered icon", which the area tooltip needs | Splits collecting from rendering: `ShowOnTooltip` collects the cluster and `ShowForIcons` renders an explicit list. This is the right seam. |
| Ownership | Re-anchors with `owner or self`, but writes `_owner = self` even when the owner is the minimap | `_mapIconOwner` and `Release` add "release only if mine", but state is still loose fields, and B's guard reads the tracker-shared `_owner` |
| Highlight | `QuestieWaypoints.SetHighlighted` with a profile color: correct and complete | Recolors `lineFrames` through dead per-zone overrides; the model is gone after WP |
| Wording | Deterministic order: givers by name, quests by level | Objective prefix (area swatch) on the own line only |
| Feature coupling | Imports `WaypointHover` and `QuestieWaypoints` | Imports `QuestiePolygon`. The begin effect lives in the tooltip module and the end effect in `QuestieFrame.OnLeave`, which caused bug (e) |

**From WP keep:** `SetHighlighted`, the deterministic sort, deleting `CustomTooltipData`, the minimap path tooltip on its own frame owned by `Minimap`, and the ordering guarantee that `WaypointHover.End` gives.

**From B keep:** `ShowForIcons` as the one renderer, `objectivePrefix`, `Release` with release-only-if-mine semantics, and the throttle that applies only to the icon's own tooltip.

**Drop:** the loose fields, the `lineFrames` recolor and its zone overrides, `ShowOnTooltip`'s `owner` and `icons` parameters, and the feature imports in MapIconTooltip.

---

## 3. Target design

### 3.1 Ownership

`MapIconTooltip` is a deep module that **renders map icon tooltips and is the only owner of their state**. Callers say what to show, for which owner frame, and on which tooltip frame. They ask who a tooltip shows for, and they end their own tooltip. Nothing outside this module reads or writes fields on a tooltip frame for map icon tooltips.

The tracker keeps `_owner` and `_SizerToolTip`, which are its own business. The state stays inside `MapIconTooltip.lua`, not in a separate module: it has one writer, and its rebuild closure is built there.

### 3.2 Public API (final, after B-F1, B-F2 and Area F's F-4)

```lua
---@class MapIconTooltip
local MapIconTooltip = QuestieLoader:CreateModule("MapIconTooltip")

---What a tooltip frame last showed for MapIconTooltip. File-local; one entry per tooltip frame.
---@class MapIconTooltipShown
---@field owner Frame The frame it was shown for, which holds and anchors it.
---@field rebuild fun(tooltip: GameTooltip) Adds its rows to the cleared tooltip, reading Shift.

---Shows a hovered map icon's tooltip: the quests and notes of the icon and of the visible icons clustered
---around it on its map. An icon faded out shows nothing, and the icon's own tooltip shown less than 0.05 s
---ago is kept. It changes nothing but the tooltip: QuestieFrame.ApplyHoverHighlights starts the hover's
---effects.
---@param self IconFrame
---@param tooltip GameTooltip GameTooltip, or a private tooltip such as the gamepad's.
function MapIconTooltip.ShowOnTooltip(self, tooltip) end

---Shows the map icon tooltip for exactly these icons, wherever they are and however faded, at the
---cursor. `owner` holds it until another frame takes the tooltip or `Release` ends it; Redraw renders
---it again meanwhile.
---@param owner Frame Holds the tooltip, which hides with it. Only a world map icon owner adds Journey's shift-click hint.
---@param icons IconFrame[] At least one icon with data. Objectives repeated across icons are listed once.
---@param tooltip GameTooltip
---@param objectivePrefix (fun(icon: IconFrame): string)? Text before each icon's own objective line; party lines get none.
function MapIconTooltip.ShowForIcons(owner, icons, tooltip, objectivePrefix) end

---Ends the map icon tooltip shown for `owner`: hides the tooltip while `owner` still holds it, and
---stops Redraw from rendering it. A map icon tooltip shown since for another frame is left alone.
---@param owner Frame
---@param tooltip GameTooltip
function MapIconTooltip.Release(owner, tooltip) end

---The frame a map icon tooltip shows for on `tooltip`, while that frame still holds it. Answers both
---"is a map icon tooltip showing" and, compared with a frame, "is mine still showing".
---@param tooltip GameTooltip
---@return Frame? owner nil while the tooltip is hidden, was released, or another frame took it.
function MapIconTooltip.GetOwner(tooltip) end

---Renders every map icon tooltip still held by its owner again, at the same anchor: Shift changes
---the detail it shows.
function MapIconTooltip.Redraw() end
```

- `MapIconTooltip:Show()` remains the IconFrame OnEnter script until F-4 (Area F). F-4 makes `_QuestieFrame.OnEnter` the script and deletes `Show`.
- Area A's "is the tooltip showing for owner X" is `MapIconTooltip.GetOwner(tooltip) == X`.
- "Release only if I own it" is `Release(X, tooltip)`.

The core of the implementation, as prototyped and passing:

```lua
local shown = {} ---@type table<GameTooltip, MapIconTooltipShown>

function MapIconTooltip.Release(owner, tooltip)
    local state = shown[tooltip]
    if state and state.owner == owner then shown[tooltip] = nil end
    if tooltip:IsOwned(owner) then tooltip:Hide() end
end

function MapIconTooltip.GetOwner(tooltip)
    local state = shown[tooltip]
    if state and tooltip:IsShown() and tooltip:IsOwned(state.owner) then
        return state.owner
    end
end

function MapIconTooltip.Redraw()
    for tooltip, state in pairs(shown) do
        if tooltip:IsShown() and tooltip:IsOwned(state.owner) then
            local anchor = tooltip:GetAnchorType() -- gamepad tooltips sit ANCHOR_RIGHT
            tooltip:Hide()
            tooltip:ClearLines()
            tooltip:SetOwner(state.owner, anchor)
            state.rebuild(tooltip)
            tooltip:SetFrameStrata("TOOLTIP")
            tooltip:Show()
        end
    end
end
-- ShowForIcons: SetOwner(owner, "ANCHOR_CURSOR"), collect, local function rebuild(self) ... end,
-- shown[tooltip] = {owner = owner, rebuild = rebuild}, rebuild(tooltip), SetFrameStrata, Show.
```

### 3.3 State contract: the fate of each field

| Field | After B-F1 |
|---|---|
| `_Rebuild` | Removed. It becomes `shown[tooltip].rebuild`, and only `Redraw` calls it. |
| `ShownAsMapIcon` | Removed. Its readers in `Tooltip.lua` call `MapIconTooltip.GetOwner(tooltip)` (truthy means a map icon tooltip is showing). The state is derived from live ownership, so it can't go stale. |
| `_mapIconOwner` | Removed. It becomes `shown[tooltip].owner`. |
| `_owner` | MapIconTooltip stops writing it. It is again only the tracker's, as the sizer's re-anchor frame (`TrackerBaseFrame:545`, `TrackerHeaderFrame:87`, EventHandler sizer branch). |
| `npcAndObjectOrder`, `questOrder`, `manualOrder`, `miniMapIcon` | Kept as render inputs, written per show and read only by `rebuild`. The wording tests read `questOrder`. Moving them into the closure would rewrite 12 test expectations for no behavior gain. |
| `data.touchedPins` | Hover tint state. MapIconTooltip writes it until F-4. After that only `QuestieFrame` writes it, in `_TintQuestIcons`; it is core-private (F 3.4). `QuestieFrame.ResetHoverHighlights` clears it. Tinting happens only while it is nil, which is fix B-F3. F-4 moves that guard into `_TintQuestIcons` along with the tint. |

### 3.4 Data flow per caller

| Caller | Shows | Ends |
|---|---|---|
| Icon mouse hover: `_QuestieFrame.OnEnter`, the icon's own script from F-4 on (before F-4, `MapIconTooltip:Show`, set at `WP QuestieFramePool.lua:56`) | `ApplyHoverHighlights(icon)`, then `ShowOnTooltip(icon, GameTooltip)` → `ShowForIcons(icon, cluster, GameTooltip)` | `_QuestieFrame.OnLeave` → `Release(icon, GameTooltip)` (B-F1), then `ResetHoverHighlights(icon)` |
| Gamepad (`GamepadMapHover.lua:97-107`) | `ApplyHoverHighlights(icon)` (F-4), then `ShowOnTooltip(icon, QuestieGamepadMapTooltip)`, re-anchored to ANCHOR_RIGHT | `ResetHoverHighlights(icon, data)` (F-3), then `tooltip:Hide()` (unchanged). The leftover state is inert because the tooltip is hidden. |
| Polygon areas: the areas layer of `WorldMapLayers` (F-2) → `onHover` → `_UpdateAreaTooltip` (`B QuestiePolygon.lua:341-374`, unchanged except its guard) | `ShowForIcons(ScrollContainer, markerIcons, GameTooltip, _AreaSwatch)` | `Release(ScrollContainer, GameTooltip)`. Its "already mine" check stays `IsOwned(owner) and IsShown()` (A §9). |
| Minimap path (`WP WaypointHover.lua:45-51`) | `SetHighlighted(path.data, true)`, then `ShowForIcons(Minimap, QuestieWaypoints.MinimapIcons(path), QuestieWaypointMinimapTooltip)` (B-F2) | `Release(Minimap, minimapTooltip)` (B-F1), then `SetHighlighted(path.data, false)` (B-F2) |
| World map path (`WP WaypointHover.lua:53-59`) | the icon's OnEnter, as an icon hover | Its OnLeave. When another frame took GameTooltip or the icon shows other data by now, it is `Release(icon, GameTooltip)` (B-F1, replacing WP :90 and :97) plus `ResetHoverHighlights(icon, path.data)` (F-3). |
| Shift (`EventHandler.lua`, map branch) | `MapIconTooltip.Redraw()` while the mouse is over the world map or minimap (B-F1) | — |
| `Tooltip.lua` ×3 | reads `MapIconTooltip.GetOwner(tooltip)` (B-F1) | — |

### 3.5 Invariants

1. Only MapIconTooltip writes map icon tooltip state.
2. There is one state per tooltip frame. A show replaces it, and `Release(owner)` forgets only that owner's state.
3. State counts only while `tooltip:IsShown() and tooltip:IsOwned(state.owner)`. When another frame takes the tooltip, no cleanup is needed, and it can never be redrawn over.
4. `Release` hides the tooltip only while `owner` still holds it.
5. **Owner identity is the frame.**
   - Never show on GameTooltip for a frame that Blizzard also anchors GameTooltip to. On Forever, `Minimap_OnUpdate` takes GameTooltip with owner `Minimap` (WP `docs/waypoints.md:228`), so minimap-owned tooltips use a private tooltip frame.
   - Two features must not share an owner frame unless one arbiter decides for both.
6. `ShowForIcons` is synchronous: it calls `ObjectiveData:Update()` and does DB and Comms lookups. Call it on hover change, never every frame. Use `GetOwner` to skip when it is already shown.
7. After F-4, MapIconTooltip changes nothing but the tooltip: no tints, highlights or previews.

### 3.6 Hover effects: relocated through QuestieFrame's icon events (Area F)

Today the tooltip module starts hover effects for three features: `WaypointHover.End` (in `Show`), `QuestiePolygon.EnterMarker` and `QuestieWaypoints.SetHighlighted` (in `ShowOnTooltip`). The code that ends those effects lives elsewhere: `_QuestieFrame.OnLeave` (`LeaveMarker`), `QuestieFrame.ResetHoverHighlights` (`SetHighlighted(false)`, untint), `GamepadMapHover.Leave` and `WaypointHover._Leave`.

Splitting each begin/end pair across modules is what caused bugs (d), (e) and (f).

**Decision.** This follows architecture rule 3. F-3 and F-4 build it.
- Each feature's begin effect is a `HoverStart` listener, and its end effect is a `HoverEnd` listener. Both sit side by side in that feature (`QuestieWaypoints`, `QuestiePolygon`; F 3.3).
- Core's tint and untint stay in `QuestieFrame.ApplyHoverHighlights`/`ResetHoverHighlights`, around the listeners.
- Every hover source calls that pair:
  - the icon's `OnEnter`/`OnLeave`;
  - `GamepadMapHover`;
  - `WaypointHover`, through the icon's own scripts.
- MapIconTooltip only renders, and imports no feature module.

### 3.7 Highlighting

- The final path is WP's `QuestieWaypoints.SetHighlighted(data, highlighted)`, colored by the profile settings `waypointHighlight` and `waypointHighlightColor`.
  - Defaults and migration are on WP. The default `{0.93, 0.46, 0.13, 0.8}` equals the old `DEFAULT_WAYPOINT_HOVER_COLOR`.
- **Per-zone hover overrides no longer matter.** On master both tables are empty (M `QuestieMap.lua:729-737`).
  - The system arrived in `18405fa8a` (2020).
  - `a5bfaad83` (2020-09-07) commented out its only entries, Durotar and Loch Modan, "Not needed after `769ea832f`", the commit that added borders to the lines.
  - WP's user setting supersedes them.
- Delete B's recolor (B :109-113), `DEFAULT_WAYPOINT_HOVER_COLOR` (B :51), the `QuestieMap` import (B :6-7) and the test stub (B test :38).
- `SetHighlighted` keys on `icon.data.waypointPaths`. A polygon marker highlights routes only if its data carries the paths, which Area C decides. For icon hovers, the waypoints `HoverEnd` listener (F-3) and `HoverStart` listener (F-4) call it, not MapIconTooltip. The minimap path hover still calls it directly from `WaypointHover`.
- Area tooltips (`ShowForIcons`) highlight no routes, because areas start no hover effects (A's D6).

### 3.8 Objective wording: behavior that must survive

Each item is listed with the test that pins it in the merged test file.

**From master (both branches keep it):**
1. Accepted native text is used verbatim, without appended counts and with punctuation kept. *"uses accepted native text…"*
2. No counter is invented for a native action objective. *"does not invent a counter…"*
3. Fallback wording keeps one counter and its punctuation. *"keeps fallback wording…"*
4. Synthetic source items never borrow native text. *"does not borrow native text…"*
5. Spell-item fallback. *"retains spell-item fallback…"*
6. Remote counters are replaced inside the native template, the local row is unchanged, and the local player is labeled `(Local Fullname)` from master's `GetUnitName("player", true)`. *"replaces remote counters…"*
7. Optional counters stay separate locally and remotely. *"keeps local and remote optional counters…"*
8. French `|4…;` plural progress. *"replaces French party progress…"*
9. Missing party counts don't show local counters as remote progress. *"does not show local counters…"*
10. Party-only objectives use their loaded native wording, with no local row. *"uses loaded party-only native wording…"*
11. Party-only objectives ignore a local cached row at the same index. *"ignores a local cached row…"*
12. Remote fallback for an instruction without a counter. *"keeps remote fallback…"*
13. Untested but unchanged:
    - `(Nearby)` for remote non-party players, and gray for an unknown class.
    - Creature level strings, `(Active)`, `Hold Shift`, XP and money, `Instance:`, reputation, breadcrumbs and next-in-chain.
    - Journey's "Shift-click to hide" only for a world map icon owner (`miniMapIcon == false`; area and minimap owners are nil).

**From WP:**
14. Givers sorted by name.
15. A giver's quests by level. *"lists a giver's quests by level"*
16. Active quests by level. *"lists active quests' objectives by level"*
17. `CustomTooltipData` stays deleted.

**From B:**
18. `objectivePrefix` goes on the icon's own line only, never party lines. *"prefixes the icons' own objective lines…"*
19. `ShowForIcons` lists the given icons regardless of distance or fade. *"lists them wherever they are…"*
20. Only the icon's own tooltip is throttled. *"replaces another owner's tooltip at once…"*

### 3.9 Why this holds up, and rejected alternatives

The interface is five functions and one rule (state counts only while its owner holds the tooltip). A new hover source joins without touching MapIconTooltip:
- it calls `ShowForIcons` with its own owner;
- it ends with `Release`;
- it asks `GetOwner`;
- Shift is handled once.

Examples are quest log boxes, minimap areas, or a merged path and area tooltip. Stale state can't be observed, because every query re-checks ownership.

Rejected:
- **Keep B's fields and `_mapIconOwner`.** Readers still see stale `ShownAsMapIcon`, EventHandler keeps reading the tracker's `_owner`, and three modules keep writing GameTooltip fields.
- **Auto-clear fields from GameTooltip `OnTooltipCleared`/`OnHide` hooks.** This depends on Blizzard's event order, and the redraw's own `ClearLines` would clear our flag.
- **Callbacks registered on `MapIconTooltip`.** The begin and end effects would still live in different modules. The chosen seam is `QuestieFrame`'s icon events (architecture rule 3, Area F).
- **WP-shaped `ShowOnTooltip(self, tooltip, owner?, icons?)` as the only entry.** It can't express an owner with no hovered icon, and `owner` silently changes the alpha gate.
- **A separate state module.** It would be shallow, with one writer.
- **A per-tooltip throttle timestamp.** It is churn with no bug behind it.

---

## 4. Sequencing

### 4(a) During the rebase (`git rebase --onto waypoints origin/master blob`)

**Phase 0 comes first.** B-F3 is on `waypoints` before the rebase starts, so `--ours` already has its `tint` guard in `ShowOnTooltip`. The steps and counts below assume that. They were checked with `git merge-file` replays of both commits onto a `waypoints` export with B-F3 applied.

**`dfb97c802` *feat(polygon): integrate cached objective areas with Questie***
- `MapIconTooltip.lua`: the import-block conflict. Keep WP's `QuestieWaypoints` and `WaypointHover` imports, then add B's `QuestiePolygon` import. The `EnterMarker` line auto-merges after WP's `if alpha == 0 and not owner` gate. Leave it there, before the throttle.
- `MapIconTooltip.test.lua`: auto-merges (B's two polygon tests join WP's file). No edit.
- Check: `busted Modules/Tooltips/MapIconTooltip.test.lua` should give **20 successes**: WP's 17, B-F3's 1 and B's 2. Validated.
- `QuestieFrame.lua` (Area C's conflict): keep `_QuestieFrame.OnLeave`'s GameTooltip lines exactly as both branches have them. B-F1 replaces them.

**`715031ef6` *chore: wip snapshot of uncommitted blob work*.** If David splits this snapshot first, apply the same steps to whichever commit introduces `ShowForIcons` and `Release`.
- `MapIconTooltip.lua` has three conflict hunks:
  - **Hunk 1** (`_owner`/`SetOwner` in `ShowOnTooltip`): take B's side, deleting both lines. `ShowForIcons` does this.
  - **Hunk 2** (B's cluster list against B-F3's `tint` lines):
    - Rename B's list to `tooltipIcons`, so it no longer shadows the `icons` parameter (N1).
    - Keep B-F3's two `tint` lines.
    - Drop WP's `usedText`, `npcAndObjectOrder`, `questOrder` and `manualOrder` locals, which `ShowForIcons` now owns.
  - **Hunk 3** (inside `handleMapIcon`): WP's `near` logic, appending to `tooltipIcons`. One `end` after the hunk is then left unmatched. Drop it.
- Silent fixes, outside the conflict markers:
  - pass `owner or self`;
  - throttle on `IsOwned(owner or self)`;
  - delete the `CustomTooltipData` branch from `ShowForIcons` (N2).
  - B-F3's `tint and …` condition in `handleMapIcon` auto-merges.
- The resolved block below is final for the rebase:

```lua
    if self.polygonMarker then QuestiePolygon.EnterMarker(self) end
    -- Only this tooltip's own owner is throttled; another owner's, such as a quest area's, is replaced.
    if GetTime() - lastTooltipShowTimestamp < 0.05 and Tooltip:IsShown() and Tooltip:IsOwned(owner or self) then
        ...
    end
    lastTooltipShowTimestamp = GetTime()
    -- (cluster distance, QuestieWaypoints.SetHighlighted, ObjectiveIndex default: unchanged)

    -- The hovered icon, the visible icons around it and any given icons share one tooltip.
    local tooltipIcons = {}
    -- Tinting again before this hover's reset would save the tinted colors as the ones to restore.
    local tint = not self.data.touchedPins
    if tint then self.data.touchedPins = {} end
    local function handleMapIcon(icon, listed)
        -- (nil-data error, hidden/faded skip unless self or listed, the `tint and …` tint: unchanged from waypoints)
        -- Listed icons count wherever they are; others only within the cluster distance of the hovered icon.
        local near = listed
        if not near and icon.x and icon.AreaID == self.AreaID then
            near = QuestieLib:Maxdist(icon.x, icon.y, self.x, self.y) < maxDistCluster
        end
        if near then
            tooltipIcons[#tooltipIcons + 1] = icon
        end
    end
    -- (enumerate minimap or world map pins: unchanged)
    -- HereBeDragons hides icons out of range, and distance fades them out; given icons count anyway.
    for _, icon in ipairs(icons or {}) do
        handleMapIcon(icon, true)
    end

    MapIconTooltip.ShowForIcons(owner or self, tooltipIcons, Tooltip)
end
```

  - Keep WP's doc comment for `ShowOnTooltip`, with its last sentence changed to "ShowForIcons renders them, again on a modifier key." `ShowForIcons` and `Release` are otherwise B's, and their fields stay until B-F1.
- `MapIconTooltip.test.lua`: one conflict at the end. Keep both sides:
  - WP's side: `describe("for a patrol path")`, B-F3's tint test and `describe("order")`;
  - B's `ShowForIcons`/`Release` tests;
  - add an `end)` that closes `describe("order")` before B's tests.

  The `before_each` auto-merges to WP's stubs plus B's `IsOwned` line. Confirm that master's `QuestieMap.zoneWaypointHoverColorOverrides` stub line is gone.
- Checks, all validated:
  - `busted Modules/Tooltips/MapIconTooltip.test.lua` should give **23 successes**.
  - `busted Modules/Map/Waypoints/WaypointHover.test.lua` should give 7.
  - `busted Modules/Map/GamepadMapHover.test.lua` should give 10.
  - `luacheck -q Modules/Tooltips` should be clean.
- This commit's `EventHandler.lua` guard, `QuestiePolygon.lua` area tooltip and `Polygon/README.md` replay without conflict. Leave them.
- **If Phase 0 was skipped:**
  - Hunk 2 doesn't conflict. B's `local icons = {}` then auto-merges and shadows the parameter silently (N1), so rename it anyway.
  - Keep `self.data.touchedPins = {}` in place of the two `tint` lines.
  - The counts are 19 and 22.

**Interim behavior after the rebase:**
- (d) is already fixed by B-F3.
- Collisions (a) to (c) remain until B-F1.
- Bugs (e) and (f) remain until F-3.

Land F-1 to F-6, B-F1 and B-F2 in the same PR as the stack.

### 4(b) Follow-up commits

**Order:**
- **Phase 0, on `waypoints`:** B-F3.
- **Phase 2:** Area F's seam commits F-1 to F-6 come first (F §4b). B-F1 and B-F2 follow, in that order.
- B's former F4 (`start icon hover effects beside their reset`) is deleted. F-4, `refactor(map): start icon hover effects through the HoverStart event`, does it through `HoverStart`, under the README's names (`ApplyHoverHighlights`, not `HighlightHover`). Its file list is in F §4(b) and its tests in F §5.

B-F1 and B-F2 add no core-to-feature import, so F-6's guard passes unchanged. Both add imports of `MapIconTooltip` only, which is core.

**B-F1 `refactor(tooltips): keep map icon tooltip state in MapIconTooltip`**
- **Depends on:** F-4. It is written against the `QuestieFrame` and `WaypointHover` that F-3 and F-4 leave behind.
- **Prototyped:**
  - The `MapIconTooltip`, `EventHandler` and `Tooltip.lua` rows were prototyped in B's first prototype: a `waypoints` export with the rebase replays applied. F doesn't touch these rows.
  - The `QuestieFrame` and `WaypointHover` rows were prototyped on Area F's prototype.
  - Every listed test passes.

| File | Change |
|---|---|
| `Modules/Tooltips/MapIconTooltip.lua` | Add the "Shown tooltips" section: a header comment, `---@class MapIconTooltipShown`, and `local shown = {}`. `ShowForIcons` stops writing `_owner`, `_mapIconOwner`, `_Rebuild` and `ShownAsMapIcon`; `_Rebuild` becomes `local function rebuild(self)`, followed by `shown[tooltip] = {owner = owner, rebuild = rebuild}`. Rewrite `Release` on the state. Add `GetOwner` and `Redraw`. Rename the `Tooltip` parameters to `tooltip`. |
| `Modules/EventHandler/EventHandler.lua` | Import `MapIconTooltip`. The body of the map branch (B :500-509) becomes `MapIconTooltip.Redraw()`, under the unchanged mouse-over gate. Don't touch the sizer branch. |
| `Modules/FramePool/QuestieFrame.lua` | F-4 already imports `MapIconTooltip`. After F-3, `_QuestieFrame.OnLeave` no longer calls `LeaveMarker`. Replace its `if GameTooltip then GameTooltip:Hide(); GameTooltip._Rebuild = nil end` and `GameTooltip.ShownAsMapIcon = false` (WP :145-151) with `MapIconTooltip.Release(self, GameTooltip)`, before `ResetHoverHighlights(self)`. |
| `Modules/Map/Waypoints/WaypointHover.lua` | Since F-3, `_ResetTooltipChanges` takes `(icon, path)` and calls `ResetHoverHighlights(icon, path.data)`. `Release` goes beside it in `_Leave`: <br>• **Minimap branch** (WP :79-83): `MapIconTooltip.Release(Minimap, _MinimapTooltip())` instead of `:Hide()`. <br>• **"Another frame took it"** (WP :86-92): `MapIconTooltip.Release(icon, GameTooltip)` instead of clearing `_Rebuild`/`ShownAsMapIcon`, with the comment "That frame keeps it, and Shift must not redraw the NPC's tooltip over it." <br>• **Fallback for an icon that shows other data by now** (WP :96-98): `MapIconTooltip.Release(icon, GameTooltip)` instead of `GameTooltip:Hide()`. Every path hover then ends its tooltip through `Release` (A's I4). |
| `Modules/Tooltips/Tooltip.lua` | Import `MapIconTooltip`. Each of the three `tooltip.ShownAsMapIcon` / `self.ShownAsMapIcon` reads becomes `MapIconTooltip.GetOwner(tooltip/self)`. |
| Tests | See §5. |

**B-F2 `refactor(waypoints): list a minimap path's quests through ShowForIcons`**
- **Depends on:** B-F1 (`Release`).

| File | Change |
|---|---|
| `Modules/Map/Waypoints/WaypointHover.lua` | `_Enter` (WP :50) becomes `MapIconTooltip.ShowForIcons(Minimap, QuestieWaypoints.MinimapIcons(path), _MinimapTooltip())`. `_Leave`'s minimap branch ends with `QuestieWaypoints.SetHighlighted(path.data, false)` instead of `_ResetTooltipChanges(icon, path)`, with the comment "A minimap path hover starts no icon hover: it only highlighted the NPC's paths." It mirrors `_Enter`'s `SetHighlighted(path.data, true)` (WP :48). F 3.3 counts the minimap path hover as no icon hover, so it emits no `HoverStart`, and now no `HoverEnd` either. `_ResetTooltipChanges` keeps its two world map call sites. |
| `Modules/Tooltips/MapIconTooltip.lua` | `ShowOnTooltip(self, tooltip)`. Delete `owner`, `icons`, `listed`, the alpha exemption and the given-icons loop. The throttle uses `IsOwned(self)`. F-4 already removed the tint, so `handleMapIcon` keeps only the nil-data error, the hidden/faded skip, and one cluster condition that appends to `tooltipIcons`. |
| Tests | See §5. |
| `docs/waypoints.md` | Lines 226 and 228 (see §6). |

**B-F3 `fix(tooltips): keep icon colors when a hovered icon's tooltip opens again`**
- **Lands in Phase 0, on `waypoints`.** It fixes WP's bug (d) (N4), which is independent of blob.
- **Later:** F-4 moves this guard into `QuestieFrame`'s `_TintQuestIcons`, and this test into `QuestieFrame.test.lua`'s "hovering" describe.

| File | Change |
|---|---|
| `Modules/Tooltips/MapIconTooltip.lua` | Use `local tint = not self.data.touchedPins; if tint then self.data.touchedPins = {} end`, and guard the tint branch of `handleMapIcon` with `tint and …`. Comment: tinting again before the hover's reset would save the tinted colors as the ones to restore. |
| Test | See §5. |

---

## 5. Tests

Conventions: `dofile("setupTests.lua")`, stubs through `QuestieLoader`, and `.was.called*`.

**After the rebase**, `MapIconTooltip.test.lua` is the union of both sides and passes 23 tests:
- the 12 wording tests from master;
- WP's patrol-path tests (3) and order tests (2);
- B-F3's tint test (1), from Phase 0;
- B's throttle and polygon tests (3);
- B's `ShowForIcons`/`Release` tests (2).

**B-F1, all prototyped and passing:**
- `MapIconTooltip.test.lua`, in a `describe("for given icons")` that uses a `HoldingTooltip()` stub. The stub records `SetOwner`, `IsOwned`, `IsShown`, `GetAnchorType` and a `Hide` spy, and acts like GameTooltip.
  - Replace B's "prefixes … and keeps Shift redrawing" with **"prefixes the icons' own objective lines, not party lines"**. Drop the field asserts.
  - Replace B's "releases only the tooltip its owner opened" with **"releases only the tooltip shown for its owner"**. This proves `Release(area)` after `other` showed keeps `other` as `GetOwner`, and that `Release(other)` hides it.
  - Add **"stops counting a tooltip another frame took, and leaves that frame's tooltip alone"**. This proves a pin taking the tooltip, with the tracker's `_owner` set, makes `GetOwner` nil and `Redraw` a no-op, and that `Release` doesn't hide the pin's tooltip. It carries over B's EventHandler scenario.
  - Add **"redraws every tooltip its owner still holds, at the same anchor"**. This proves GameTooltip and a private tooltip both re-render, and that an ANCHOR_RIGHT tooltip keeps its anchor.
  - The 12 wording tests and the order tests stay.
- `EventHandler.test.lua`: replace B's "redraws a map tooltip on Shift only while its owner still holds it" with **"redraws Questie's map icon tooltips on Shift while the cursor is over a map"**. It spies on `Redraw`: no call off the map, one call over it. Ownership logic now lives at MapIconTooltip's interface; replace, don't layer.
- `Tooltip.test.lua`: before the first `dofile("Modules/Tooltips/Tooltip.lua")`, stub `QuestieLoader:ImportModule("MapIconTooltip").GetOwner = function() return mapIconOwner end`. The two tests that set `GameTooltip.ShownAsMapIcon` (WP :397, :790) set `mapIconOwner = {}` instead. All 75 pass.
- `WaypointHover.test.lua` (F-3's version): stub `Release` next to the `ShowOnTooltip` stub.
  - "shows a minimap hover on a tooltip of its own…" and "ends a minimap hover once the NPC's minimap icon opens its own tooltip" assert `Release(Minimap, minimapTooltip)` instead of `minimapTooltip.Hide`.
  - "moves a path's hover from one map to the other with its tooltip" asserts that `Release` was not called.
  - "undoes the NPC's tooltip changes when another frame takes the tooltip" asserts `Release(icon, GameTooltip)` instead of the fields. F-3's `ResetHoverHighlights(icon, data)` assertion stays.
  - All 7 pass.
- `QuestieFrame.test.lua`. F-3 removed B's "polygon marker interaction" block.
  - Stub `MapIconTooltip.Release` with a spy in the top-level `before_each`.
  - Add **"ends only its own tooltip when the cursor leaves the icon, and leaves another holder's"**. `OnLeave` calls `Release(QuestieFrameInstance, GameTooltip)` and never calls `GameTooltip:Hide()` itself (R4).
  - 44 pass on Area F's prototype. The new test fails without B-F1.
- `TooltipHandler.test.lua`, `QuestEventHandler.test.lua`, `WaypointMap.test.lua`, `GamepadMapHover.test.lua`: unchanged and passing.

**B-F2:**
- `MapIconTooltip.test.lua`: WP's `describe("for a patrol path")` folds into "for given icons" as **"lists them wherever they are and however faded, for the frame given"**. This uses `ShowForIcons(Minimap, {icon, faraway}, …)` and asserts `GetOwner == Minimap`, and needs no zoom stubs.
- Add **"a faded out icon's own hover shows nothing"** (`ShowOnTooltip` at alpha 0 never calls `Show`). It keeps master's gate pinned once the exemption is gone.
- The two order tests call `ShowForIcons({}, {…})`.
- `WaypointHover.test.lua`: stub `ShowForIcons` in place of `ShowOnTooltip`.
  - Three tests assert `ShowForIcons(Minimap, listed, minimapTooltip)`.
  - The minimap leave asserts `SetHighlighted(data, false)`, and that `ResetHoverHighlights` was not called.
  - All 7 pass on Area F's prototype.

**B-F3 (Phase 0):**
- Add **"keeps the colors to restore when a hovered icon's tooltip shows again before its reset"**. It shows twice, more than 0.05 s apart, then asserts the saved color is the original and there is one entry.
- It fails on WP's code. With the fix there are 18 passes on `waypoints`.
- F-4 moves it to `QuestieFrame.test.lua` as "keeps the colors to restore when the hover starts again before its reset".

**Area F's F-4 owns the former F4 tests:**
- the `QuestieFrame.test.lua` "hovering" describe;
- the `MapIconTooltip.test.lua` edits, which delete B's two polygon preview tests and the `QuestieWaypoints`/`WaypointHover` stubs;
- the `GamepadMapHover.test.lua` `ApplyHoverHighlights` spy.

See F §5.

---

## 6. Docs and comments

- **`MapIconTooltip.lua`**:
  - A short "Shown tooltips" section comment: what the module owns, who asks `GetOwner`, who calls `Release` and `Redraw`.
  - Doc comments as in §3.2.
  - Delete the stale `-- we separate this so things like MODIFIER_STATE_CHANGED can redraw the tooltip`.
  - Keep `ShowOnTooltip`'s doc comment true at each stage:
    - the rebase;
    - F-4, which says hover effects belong to `QuestieFrame.ApplyHoverHighlights`;
    - B-F2, which gives the final text in §3.2.
- **`EventHandler.lua`**: the map branch comment becomes "Questie's map icon tooltips show more detail while Shift is held."
- **`WaypointHover.lua`**:
  - The header (WP :13-21) names `ShowForIcons` for the minimap (B-F2). This goes on top of the sentence F-1 adds there (A §6).
  - The `_Leave` comments: the "another frame took it" branch (B-F1) and the minimap branch (B-F2).
  - `End`'s doc comment belongs to F-4.
- **`docs/waypoints.md`**:
  - :52 belongs to F-3/F-4.
  - :226: drop "A minimap tooltip collects its entries from the minimap icons HereBeDragons shows near the hovered one." The path tooltip lists exactly the route's icons (B-F2).
  - :228: "A modifier key doesn't rebuild this tooltip" becomes "Shift redraws it, as GameTooltip's" (B-F1).
- **`Polygon/README.md`**: no edit of B's own.
  - The hover wording (:13, :21, :104-118, :198) is Area A's (A §6), applied by F-2.
  - :109 already describes `ShowForIcons` and `Release`, and stays true after B-F1, because Area A keeps the `IsOwned` check.
- `docs/tracker-objective-text.md:54, :95`: no change, since the wording behavior is unchanged.

---

## 7. Verification

**Phase 0 (B-F3, on `waypoints`):** `busted Modules/Tooltips/MapIconTooltip.test.lua` (18) and `luacheck -q Modules/Tooltips`.

**Rebase:**
- After each of `dfb97c802` and `715031ef6`, run `busted Modules/Tooltips/MapIconTooltip.test.lua` (20, then 23).
- After `715031ef6`, also run `busted Modules/Map/Waypoints/WaypointHover.test.lua Modules/Map/GamepadMapHover.test.lua`.
- `luacheck -q Modules/Tooltips`.

**B-F1 and B-F2, after F-1 to F-6.** These were run in the prototypes. The one exception is `Polygon/QuestiePolygon.test.lua`, which exists only after stacking; it stubs `ShowForIcons` and `Release`, whose signatures don't change.

```bash
busted Modules/Tooltips/MapIconTooltip.test.lua
busted Modules/Tooltips/Tooltip.test.lua
busted Modules/Tooltips/TooltipHandler.test.lua
busted Modules/EventHandler/EventHandler.test.lua
busted Modules/EventHandler/QuestEventHandler.test.lua
busted Modules/FramePool/QuestieFrame.test.lua
busted Modules/Map/Waypoints/WaypointHover.test.lua
busted Modules/Map/GamepadMapHover.test.lua
busted Polygon/QuestiePolygon.test.lua
lua cli/validate-loader-usage.lua   # new file-scope imports in Tooltip/EventHandler/QuestieFrame
luacheck -q -- Database Localization Modules Polygon Public Questie.lua
```

Run the full suite (`busted -p ".test.lua" .`) once, before the PR.

**In game, for David:**
1. **Any client, world map.**
   - Hover a quest giver with several quests: they list by level, and givers by name.
   - Hold Shift: XP, breadcrumbs and next-in-chain appear. Release Shift: the short form returns.
   - Leave: the tooltip hides.
2. **Any client, tint (B-F3, then again after F-4 moves it).**
   - Take a kill quest whose target's patrol draws in the hostile route color.
   - On the world map, hover the route, slide onto the target's icon, pause, then move away.
   - The quest's other objective icons must return to their own colors. Before B-F3 they stay blueish, or white with objective colors on.
3. **Forever, minimap path (B-F1/B-F2).**
   - Hover a patrol path on the minimap: the private tooltip lists all of the NPC's quests, even when its icon is out of range.
   - Press Shift: the detail appears. This is new.
   - Move off the path: the tooltip hides and the NPC's paths stop highlighting.
4. **Forever, blob mode** (`enableQuestiePolygons`).
   - Hover an objective area: the tooltip shows color swatches.
   - Shift adds detail.
   - Move onto a marker: its tooltip replaces the area's at once.
   - Back on bare map inside the area: the area tooltip returns.
   - After B-F1: leaving a route that crosses an area must not stop Shift from redrawing the area tooltip.
5. **Any client, regression for the `Tooltip.lua` gate.**
   - After hovering a map icon, mouse over a quest object in the world (for example, a quest herb or chest): Questie's quest lines still appear.
   - While a map icon tooltip shows, no object lines are appended to it.
6. **Forever, gamepad.** The map hover still shows its tooltip anchored right, and Shift redraws it there (B-F1). Area F's checks cover the preview ending when the gamepad cursor leaves (F-3, F §7 check 3).
7. **Tracker.** The sizer's Shift tooltip still switches, since it still uses `_owner`.

---

## 8. Risks and open questions

| # | Risk or question | Recommendation |
|---|---|---|
| R1 | Removing `GameTooltip.ShownAsMapIcon` breaks any third-party addon that reads it. No reader exists in the repo besides `Tooltip.lua`. | Remove it. |
| R2 | `GetOwner` trusts that only MapIconTooltip shows tooltips for its owners. That holds for icons and private frames. Another addon could anchor GameTooltip to `ScrollContainer`; the vanilla UI source in `WoW-API/_UI` never does. B's `IsOwned` check has the same exposure, and forgetting state on `Release` narrows it. | Accept it. If in doubt, check the Forever UI source with the `wow-ui-source` skill. |
| R3 | `Redraw` re-anchors with `GetAnchorType()`. Classic's own `Classic_GameTooltip.lua:554` uses it. | Accept it. Check the gamepad Shift case in game (check 6). |
| R4 | `_QuestieFrame.OnLeave` now hides GameTooltip only while the icon holds it; before, it always did. This is release-only-if-mine. | Accept it. Check 1 covers it. |
| R5 | The minimap path tooltip loses the cluster neighbors of the NPC's icon (B-F2). These are icons within `0.3–0.5 / (1 + zoom)` percent of the zone's map, which is roughly 3–17 yards in an Elwynn-sized zone. The world map path tooltip, which is the icon's own tooltip, keeps them. | Accept it. A path hover is about its NPC. |
| R6 | The interim state after the rebase still has collisions (a) to (c) and bugs (e) and (f). Phase 0 has already fixed (d). | Land F-1 to F-6, B-F1 and B-F2 in the same PR as the stack. |
| R7 | ~~F4 overlaps Area A~~ | **Resolved by F-4.** Area F owns `OnEnter`, the gamepad `Enter` and where `End` runs. B keeps the rule that MapIconTooltip imports no feature. |
| R8 | The WIP snapshot may be split before rebasing. | Apply the `715031ef6` recipe to the commit that adds `ShowForIcons`/`Release`. |
| R9 | `ShowForIcons` with an empty list shows an empty box. The polygon caller guards against it; WP's `MinimapIcons` is never empty while a path is hovered. | Document "at least one icon", and don't guard. |
| R10 | B-F1 is written against the code F-3 and F-4 leave behind: `QuestieFrame`'s `MapIconTooltip` import, `OnLeave` without `LeaveMarker`, and `_ResetTooltipChanges(icon, path)`. | Keep the README order. If B-F1 must land before F-3/F-4, add the import, keep `LeaveMarker` in `OnLeave`, and keep `_ResetTooltipChanges(path)`. |

**Decisions for David** (also in §3):
- **D1:** owned state (`GetOwner`/`Release`/`Redraw`) rather than loose fields. Recommended.
- **D2:** the minimap path tooltip lists the route's icons only (R5). Recommended.
- **D3:** ~~move hover begin effects beside their resets (F4)~~. **Superseded** by architecture rule 3: icon events, built by F-3/F-4.
- **D4:** `Redraw` covers every MapIconTooltip tooltip, which fixes Shift on minimap paths and gamepad. Recommended.
- **D5:** land B-F3 on `waypoints` before it merges (Phase 0), since it is waypoints' own bug. Decided in the README.

---

## 9. Contracts with other areas

**I provide to all areas:**
- The API in §3.2.
- Invariants 1–7 (§3.5).
- Release-only-if-mine, through `Release(owner, tooltip)`.
- "Is it showing for X", through `GetOwner(tooltip) == X`.
- Shift handled centrally by `Redraw`.

**Areas A and F, hover arbitration and seams. I need:**
- **Precedence and callers.** The precedence between icon, path and area tooltips, and who calls `ShowForIcons`/`Release` and when. This is A's policy, encoded by `WorldMapLayers` (F-1, F-2). `_UpdateAreaTooltip`'s "already mine" check stays `IsOwned(owner) and IsShown()` (A §9).
- **No two features share an owner frame without one arbiter.** The path tooltip stays owned by the NPC's icon (A §9). If it moved to `ScrollContainer` like the area tooltip, the area's `Release(ScrollContainer)` would end it.
- **Every hover end undoes every hover begin.** `ResetHoverHighlights(icon, data)` emits `HoverEnd` from every way an icon hover ends (F-3):
  - `WaypointHover._Leave`'s partial branch, which fixes bug (f);
  - gamepad `Leave`, which fixes bug (e).
- **Where `WaypointHover.End` runs.** It runs in the waypoints `HoverStart` listener, before the core tint (F 3.3 guarantee 2). So a path hover's tints are restored before the new icon's colors are saved.
- **`ShowForIcons` only on hover change** (invariant 6). `WorldMapLayers` offers the cursor only when it, the zoom or a drawing changed. The area tooltip rebuilds only on `changed`, or to take the tooltip back.
- **The `QuestieFrame` and `WaypointHover` that F-3 and F-4 leave behind**, which B-F1 is written against (R10).

**I provide to Area F:**
- `ShowForIcons`, `Release` and `GetOwner` as in §3.2.
- B-F3 in Phase 0. F-4 moves its guard and test.
- `_UpdateAreaTooltip` keeps its `onHover(shapes, changed)` use, unchanged by B.

**Area C, quest drawing and the line model. I need:**
- During the rebase, leave `_QuestieFrame.OnLeave`'s tooltip lines as both branches have them. B-F1 replaces them.
- Delete `QuestieMap.zoneWaypoint(Hover)ColorOverrides` and `lineFrames` freely. MapIconTooltip stops reading them at the rebase (WP's side wins).
- Route highlighting keys on `icon.data.waypointPaths`, so Area C decides which data carries which paths (finding 5).
- `_FallbackIconData` must not copy `touchedPins`, which is hover state. C-F1 deletes `_FallbackIconData` (F 3.4), which settles this.
- C-F2 links polygon markers' `minimapTwin`, as the IconFrame contract says (F 3.5). That decides whether `QuestieWaypoints.MinimapIcons` can list them in the minimap path tooltip.

**Area D, the minimap layer. I need:**
- Any minimap-owned map icon tooltip uses a private tooltip frame, never GameTooltip (invariant 5).
- If a second minimap hover appears, such as polygon areas, move `WaypointHover`'s `_MinimapTooltip()` into MapIconTooltip rather than creating another frame. Until then, YAGNI.

**Area E, geometry and scheduling. I need:**
- The one poller (`WorldMapLayers`) keeps the "changed" signal: it offers the cursor only on change, and `PolygonRenderer` still passes `onHover(shapes, changed)`. That way tooltips rebuild only on change.
- `ShowForIcons` is not frame-budgeted work, and must not run inside a coroutine `Checkpoint`. `WorldMapLayer.Hover` runs it in E's presentation tier.

---

## Open issues with Area F

None of these changes F's design. B applied every item of F §10's B delta.

1. **F §10 B.9 (minimap leave: "either works").** Agreed: polygon's `HoverEnd` listener ignores a minimap twin, since `LeaveMarker` checks `frame.polygonMarker` (`B QuestiePolygon.lua:590-596`). B takes `SetHighlighted(path.data, false)` in B-F2, which passes on Area F's prototype with B-F1 and B-F2 applied. A minimap path hover emits no `HoverStart`, so ending it through `ResetHoverHighlights` would emit the only `HoverEnd` without one. This is a choice F left open, not a disagreement.
2. **Phase 0 moves Phase 1 numbers, which the README quotes.** F 4(a) points at B §4a for stop #36, and F-4 depends on B-F3 in Phase 0. With B-F3 on `waypoints`:
   - `MapIconTooltip.test.lua` gives 20 at stop #6 and 23 at stop #36 (the README says 19 and 22);
   - stop #36 gets a third `MapIconTooltip.lua` conflict hunk, at the N1 site.

   This is for the orchestrator, not F.
3. **F §5, F-4's `MapIconTooltip.test.lua`.** "17 pass on WP's file" was measured without B-F3. In the real order the file also holds B-F3's tint test, which F-4 deletes there when it moves the test to `QuestieFrame.test.lua`. F's text ("moved from") already implies this.
