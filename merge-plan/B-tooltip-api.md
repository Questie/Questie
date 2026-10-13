# Area B: MapIconTooltip API and the tooltip state contract

Scope: `Modules/Tooltips/MapIconTooltip.lua`, its test, and every module that reads or writes the state Questie hangs on tooltip frames.

`WP` is `origin/waypoints` (`7c1e28bd8`), `B` is `blob` (`715031ef6`) and `M` is `origin/master` (`3e8baa279`). Line numbers are for that ref.

**Summary**
- Resolve the rebase with WP's 4-argument `ShowOnTooltip` layered on B's `ShowForIcons`. That passes both branches' tests: 19 after `dfb97c802` and 22 after `715031ef6`.
- After stacking, MapIconTooltip owns the tooltip state privately and exposes `GetOwner`, `Release` and `Redraw`. The loose fields `_Rebuild`, `ShownAsMapIcon` and `_mapIconOwner` go, and `_owner` goes back to the tracker.
- The minimap path tooltip moves to `ShowForIcons`, and `ShowOnTooltip` returns to master's two arguments.
- Hover side effects move out of the tooltip module, beside their resets. This is not done through callbacks.

I validated all of this with throwaway copies outside both checkouts: `git merge-file` replays of the two commits, a `git archive` export of `origin/waypoints`, and prototype runs of every affected test file. Nothing in either checkout was changed.

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

### 3.2 Public API (final, after F1–F4)

```lua
---@class MapIconTooltip
local MapIconTooltip = QuestieLoader:CreateModule("MapIconTooltip")

---What a tooltip frame last showed for MapIconTooltip. File-local; one entry per tooltip frame.
---@class MapIconTooltipShown
---@field owner Frame The frame it was shown for, which holds and anchors it.
---@field rebuild fun(tooltip: GameTooltip) Adds its rows to the cleared tooltip, reading Shift.

---Shows a hovered map icon's tooltip: the quests and notes of the icon and of the visible icons clustered
---around it on its map. An icon faded out shows nothing, and the icon's own tooltip shown less than 0.05 s
---ago is kept.
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

- `MapIconTooltip:Show()` remains the IconFrame OnEnter script until F4, then is deleted.
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

| Field | After F1 |
|---|---|
| `_Rebuild` | Removed. It becomes `shown[tooltip].rebuild`, and only `Redraw` calls it. |
| `ShownAsMapIcon` | Removed. Its readers in `Tooltip.lua` call `MapIconTooltip.GetOwner(tooltip)` (truthy means a map icon tooltip is showing). The state is derived from live ownership, so it can't go stale. |
| `_mapIconOwner` | Removed. It becomes `shown[tooltip].owner`. |
| `_owner` | MapIconTooltip stops writing it. It is again only the tracker's, as the sizer's re-anchor frame (`TrackerBaseFrame:545`, `TrackerHeaderFrame:87`, EventHandler sizer branch). |
| `npcAndObjectOrder`, `questOrder`, `manualOrder`, `miniMapIcon` | Kept as render inputs, written per show and read only by `rebuild`. The wording tests read `questOrder`. Moving them into the closure would rewrite 12 test expectations for no behavior gain. |
| `data.touchedPins` | Hover tint state. MapIconTooltip writes it until F4, then `QuestieFrame` writes it. `QuestieFrame.ResetHoverHighlights` clears it. Tinting happens only while it is nil, which is fix F3. |

### 3.4 Data flow per caller

| Caller | Shows | Ends |
|---|---|---|
| Icon mouse hover (`QuestieFramePool.lua:56/57` → `Show`) | `ShowOnTooltip(icon, GameTooltip)` → `ShowForIcons(icon, cluster, GameTooltip)` | `_QuestieFrame.OnLeave` → `Release(icon, GameTooltip)` (F1) |
| Gamepad (`GamepadMapHover.lua:101`) | `ShowOnTooltip(icon, QuestieGamepadMapTooltip)`, then re-anchored to ANCHOR_RIGHT | `tooltip:Hide()` (unchanged). The leftover state is inert because the tooltip is hidden. |
| Polygon areas (`B QuestiePolygon.lua:341-374`) | `ShowForIcons(ScrollContainer, markerIcons, GameTooltip, _AreaSwatch)` | `Release(ScrollContainer, GameTooltip)`. "Already mine" can become `GetOwner(GameTooltip) == owner`, which is Area A's call. |
| Minimap path (`WP WaypointHover.lua:50`) | `ShowForIcons(Minimap, QuestieWaypoints.MinimapIcons(path), QuestieWaypointMinimapTooltip)` (F2) | `Release(Minimap, minimapTooltip)` (F1) |
| World map path (`WP WaypointHover.lua:53-59`) | the icon's OnEnter, as an icon hover | its OnLeave, or `Release(icon, GameTooltip)` when another frame took GameTooltip (F1, replacing WP :90) |
| Shift (`EventHandler.lua`, map branch) | `MapIconTooltip.Redraw()` while the mouse is over the world map or minimap (F1) | — |
| `Tooltip.lua` ×3 | reads `MapIconTooltip.GetOwner(tooltip)` (F1) | — |

### 3.5 Invariants

1. Only MapIconTooltip writes map icon tooltip state.
2. There is one state per tooltip frame. A show replaces it, and `Release(owner)` forgets only that owner's state.
3. State counts only while `tooltip:IsShown() and tooltip:IsOwned(state.owner)`. When another frame takes the tooltip, no cleanup is needed, and it can never be redrawn over.
4. `Release` hides the tooltip only while `owner` still holds it.
5. **Owner identity is the frame.**
   - Never show on GameTooltip for a frame that Blizzard also anchors GameTooltip to. On Forever, `Minimap_OnUpdate` takes GameTooltip with owner `Minimap` (WP `docs/waypoints.md:228`), so minimap-owned tooltips use a private tooltip frame.
   - Two features must not share an owner frame unless one arbiter decides for both.
6. `ShowForIcons` is synchronous: it calls `ObjectiveData:Update()` and does DB and Comms lookups. Call it on hover change, never every frame. Use `GetOwner` to skip when it is already shown.
7. After F4, MapIconTooltip changes nothing but the tooltip: no tints, highlights or previews.

### 3.6 Dependency direction: relocate, don't invert

Today the tooltip module starts hover effects for three features: `WaypointHover.End` (in `Show`), `QuestiePolygon.EnterMarker` and `QuestieWaypoints.SetHighlighted` (in `ShowOnTooltip`). Their counterparts that end those effects already live in the hover owners: `_QuestieFrame.OnLeave` (`LeaveMarker`), `QuestieFrame.ResetHoverHighlights` (`SetHighlighted(false)`, untint), `GamepadMapHover.Leave` and `WaypointHover._Leave`.

Splitting each begin/end pair across modules is what caused bugs (d), (e) and (f). **Decision:**
- Move each begin effect next to its end effect, in the hover owner.
- MapIconTooltip then imports no feature module.
- This needs no hooks and no registry.
- F4 does it after Area A settles who calls what.

If David prefers to keep the direct calls, the one-line fix for (e) is to move `EnterMarker` from `ShowOnTooltip` into `Show`, for mouse hover only, mirroring `LeaveMarker` in `OnLeave`.

### 3.7 Highlighting

- The final path is WP's `QuestieWaypoints.SetHighlighted(data, highlighted)`, colored by the profile settings `waypointHighlight` and `waypointHighlightColor`.
  - Defaults and migration are on WP. The default `{0.93, 0.46, 0.13, 0.8}` equals the old `DEFAULT_WAYPOINT_HOVER_COLOR`.
- **Per-zone hover overrides no longer matter.** On master both tables are empty (M `QuestieMap.lua:729-737`).
  - The system arrived in `18405fa8a` (2020).
  - `a5bfaad83` (2020-09-07) commented out its only entries, Durotar and Loch Modan, "Not needed after `769ea832f`", the commit that added borders to the lines.
  - WP's user setting supersedes them.
- Delete B's recolor (B :109-113), `DEFAULT_WAYPOINT_HOVER_COLOR` (B :51), the `QuestieMap` import (B :6-7) and the test stub (B test :38).
- `SetHighlighted` keys on `icon.data.waypointPaths`. A polygon marker highlights routes only if its data carries the paths, which Area C decides.
- Area tooltips (`ShowForIcons`) highlight no routes. Whether area hover should is Area A's call.

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
- **Registered "before show" callbacks per feature.** The flow becomes implicit and ordered by registration, while the end effects still live elsewhere.
- **WP-shaped `ShowOnTooltip(self, tooltip, owner?, icons?)` as the only entry.** It can't express an owner with no hovered icon, and `owner` silently changes the alpha gate.
- **A separate state module.** It would be shallow, with one writer.
- **A per-tooltip throttle timestamp.** It is churn with no bug behind it.

---

## 4. Sequencing

### 4(a) During the rebase (`git rebase --onto waypoints origin/master blob`)

**`dfb97c802` *feat(polygon): integrate cached objective areas with Questie***
- `MapIconTooltip.lua`: the import-block conflict. Keep WP's `QuestieWaypoints` and `WaypointHover` imports, then add B's `QuestiePolygon` import. The `EnterMarker` line auto-merges after WP's `if alpha == 0 and not owner` gate. Leave it there, before the throttle.
- `MapIconTooltip.test.lua`: auto-merges (B's two polygon tests join WP's file). No edit.
- Check: `busted Modules/Tooltips/MapIconTooltip.test.lua` should give **19 successes**. Validated.
- `QuestieFrame.lua` (Area C's conflict): keep `_QuestieFrame.OnLeave`'s GameTooltip lines exactly as both branches have them. F1 replaces them.

**`715031ef6` *chore: wip snapshot of uncommitted blob work*.** If David splits this snapshot first, apply the same steps to whichever commit introduces `ShowForIcons` and `Release`.
- `MapIconTooltip.lua`:
  - Hunk 1 (`_owner`/`SetOwner` in `ShowOnTooltip`): take B's side, deleting both lines. `ShowForIcons` does this.
  - Hunk 2 (inside `handleMapIcon`): WP's `near` logic, appending to the list.
  - Silent fix 1: rename B's cluster list so it no longer shadows `icons`.
  - Silent fix 2: pass `owner or self`.
  - Silent fix 3: throttle on `IsOwned(owner or self)`.
  - Silent fix 4: delete the `CustomTooltipData` branch from `ShowForIcons`.
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
    self.data.touchedPins = {}
    local function handleMapIcon(icon, listed)
        -- (nil-data error, hidden/faded skip unless self or listed, touchedPins tint: unchanged from WP)
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

  - Keep WP's doc comment for `ShowOnTooltip`, with its last sentence changed to "ShowForIcons renders them, again on a modifier key." `ShowForIcons` and `Release` are otherwise B's, and their fields stay until F1.
- `MapIconTooltip.test.lua`: one conflict at the end. Keep both sides: WP's `describe("for a patrol path")` and `describe("order")`, and B's `ShowForIcons`/`Release` tests. The `before_each` auto-merges to WP's stubs plus B's `IsOwned` line. Confirm that master's `QuestieMap.zoneWaypointHoverColorOverrides` stub line is gone.
- Checks, all validated:
  - `busted Modules/Tooltips/MapIconTooltip.test.lua` should give **22 successes**.
  - `busted Modules/Map/Waypoints/WaypointHover.test.lua` should give 7.
  - `busted Modules/Map/GamepadMapHover.test.lua` should give 10.
  - `luacheck -q Modules/Tooltips` should be clean.
- This commit's `EventHandler.lua` guard, `QuestiePolygon.lua` area tooltip and `Polygon/README.md` replay without conflict. Leave them.

**Interim behavior after the rebase:** collision (a) and bugs (d), (e) and (f) remain until the follow-ups below. Land F1 in the same PR as the stack.

### 4(b) Follow-up commits

**F1 `refactor(tooltips): keep map icon tooltip state in MapIconTooltip`.** It doesn't depend on Area A, and was prototyped with every listed test passing.

| File | Change |
|---|---|
| `Modules/Tooltips/MapIconTooltip.lua` | Add the "Shown tooltips" section: a header comment, `---@class MapIconTooltipShown`, and `local shown = {}`. `ShowForIcons` stops writing `_owner`, `_mapIconOwner`, `_Rebuild` and `ShownAsMapIcon`; `_Rebuild` becomes `local function rebuild(self)`, followed by `shown[tooltip] = {owner = owner, rebuild = rebuild}`. Rewrite `Release` on the state. Add `GetOwner` and `Redraw`. Rename the `Tooltip` parameters to `tooltip`. |
| `Modules/EventHandler/EventHandler.lua` | Import `MapIconTooltip`. The body of the map branch (B :500-509) becomes `MapIconTooltip.Redraw()`, under the unchanged mouse-over gate. Don't touch the sizer branch. |
| `Modules/FramePool/QuestieFrame.lua` | Import `MapIconTooltip`. In `_QuestieFrame.OnLeave`, replace the `GameTooltip:Hide()`, `_Rebuild = nil` and `ShownAsMapIcon = false` lines with `MapIconTooltip.Release(self, GameTooltip)` before `ResetHoverHighlights`. |
| `Modules/Map/Waypoints/WaypointHover.lua` | In `_Leave`, the minimap branch calls `MapIconTooltip.Release(Minimap, _MinimapTooltip())` instead of `:Hide()`. The "another frame took it" branch calls `MapIconTooltip.Release(icon, GameTooltip)` instead of clearing fields, with the comment "Shift must not redraw it". |
| `Modules/Tooltips/Tooltip.lua` | Import `MapIconTooltip`. Each of the three `tooltip.ShownAsMapIcon` / `self.ShownAsMapIcon` reads becomes `MapIconTooltip.GetOwner(tooltip/self)`. |
| Tests | See §5. |

**F2 `refactor(waypoints): list a minimap path's quests through ShowForIcons`**

| File | Change |
|---|---|
| `Modules/Map/Waypoints/WaypointHover.lua` | `_Enter` (WP :50) becomes `MapIconTooltip.ShowForIcons(Minimap, QuestieWaypoints.MinimapIcons(path), _MinimapTooltip())`. |
| `Modules/Tooltips/MapIconTooltip.lua` | `ShowOnTooltip(self, tooltip)`. Delete `owner`, `icons`, `listed`, the alpha exemption and the given-icons loop. The throttle uses `IsOwned(self)`. The cluster check becomes one condition that appends to `clustered`. |
| Tests | See §5. |
| `docs/waypoints.md` | Lines 226 and 228 (see §6). |

**F3 `fix(tooltips): keep icon colors when a hovered icon's tooltip opens again`.** This fixes WP's bug (d). It is independent of blob, so it can land on `waypoints` before that branch merges.

| File | Change |
|---|---|
| `Modules/Tooltips/MapIconTooltip.lua` | Use `local tint = not self.data.touchedPins; if tint then self.data.touchedPins = {} end`, and guard the tint branch of `handleMapIcon` with `tint and …`. Comment: tinting again before the hover's reset would save the tinted colors as the ones to restore. |
| Test | See §5. |

**F4 `refactor(map): start icon hover effects beside their reset`.** This lands after Area A's arbitration commits, or folds into them.

| File | Change |
|---|---|
| `Modules/FramePool/QuestieFrame.lua` | Add `_QuestieFrame.OnEnter(self)`: call `WaypointHover.End(self)` (unless Area A's arbiter owns that), then `MapIconTooltip.ShowOnTooltip(self, GameTooltip)`. If `MapIconTooltip.GetOwner(GameTooltip) ~= self`, return, because a faded icon is not hovered. Otherwise call `EnterMarker` for a polygon marker, then `QuestieFrame.HighlightHover(self)`. Add `QuestieFrame.HighlightHover(self)`: `SetHighlighted(data, true)` plus the `touchedPins` tint for world map icons, moved from MapIconTooltip with the F3 guard. Have `CreateIconFrame(frameId)` set its own OnEnter, as it does OnLeave. |
| `Modules/FramePool/QuestieFramePool.lua` | `CreateIconFrame(numberOfFrames)` (WP :56). Drop the import if it becomes unused. |
| `Modules/Tooltips/MapIconTooltip.lua` | Delete `Show`. From `ShowOnTooltip`, delete `EnterMarker`, `SetHighlighted` and the tint. Drop the `QuestieWaypoints`, `WaypointHover` and `QuestiePolygon` imports. |
| `Modules/Map/GamepadMapHover.lua` | In `Enter`, after a shown tooltip, call `QuestieFrame.HighlightHover(icon)`. This keeps master's tint and WP's path highlight for gamepad. Add an `EnterMarker`/`LeaveMarker` pair if Area A wants gamepad previews; otherwise none, which fixes (e). |
| `Modules/Map/Waypoints/WaypointHover.lua` | Its partial leave (`_ResetTooltipChanges`) must also end a marker preview, which fixes (f). How is Area A's call; see §9. |

---

## 5. Tests

Conventions: `dofile("setupTests.lua")`, stubs through `QuestieLoader`, and `.was.called*`.

**After the rebase**, `MapIconTooltip.test.lua` is the union of both sides and passes 22 tests:
- the 12 wording tests from master;
- WP's patrol-path tests (3) and order tests (2);
- B's throttle and polygon tests (3);
- B's `ShowForIcons`/`Release` tests (2).

**F1, all prototyped and passing:**
- `MapIconTooltip.test.lua`, in a `describe("for given icons")` that uses a `HoldingTooltip()` stub. The stub records `SetOwner`, `IsOwned`, `IsShown`, `GetAnchorType` and a `Hide` spy, and acts like GameTooltip.
  - Replace B's "prefixes … and keeps Shift redrawing" with **"prefixes the icons' own objective lines, not party lines"**. Drop the field asserts.
  - Replace B's "releases only the tooltip its owner opened" with **"releases only the tooltip shown for its owner"**. This proves `Release(area)` after `other` showed keeps `other` as `GetOwner`, and that `Release(other)` hides it.
  - Add **"stops counting a tooltip another frame took, and leaves that frame's tooltip alone"**. This proves a pin taking the tooltip, with the tracker's `_owner` set, makes `GetOwner` nil and `Redraw` a no-op, and that `Release` doesn't hide the pin's tooltip. It carries over B's EventHandler scenario.
  - Add **"redraws every tooltip its owner still holds, at the same anchor"**. This proves GameTooltip and a private tooltip both re-render, and that an ANCHOR_RIGHT tooltip keeps its anchor.
  - The 12 wording tests and the order tests stay.
- `EventHandler.test.lua`: replace B's "redraws a map tooltip on Shift only while its owner still holds it" with **"redraws Questie's map icon tooltips on Shift while the cursor is over a map"**. It spies on `Redraw`: no call off the map, one call over it. Ownership logic now lives at MapIconTooltip's interface; replace, don't layer.
- `Tooltip.test.lua`: before the first `dofile("Modules/Tooltips/Tooltip.lua")`, stub `QuestieLoader:ImportModule("MapIconTooltip").GetOwner = function() return mapIconOwner end`. The two tests that set `GameTooltip.ShownAsMapIcon` (WP :397, :790) set `mapIconOwner = {}` instead. All 75 pass.
- `WaypointHover.test.lua`: stub `ShowForIcons` and `Release`.
  - The minimap leave asserts `Release(Minimap, minimapTooltip)`.
  - "undoes the NPC's tooltip changes when another frame takes the tooltip" asserts `Release(icon, GameTooltip)` instead of fields.
  - All 7 pass.
- `QuestieFrame.test.lua` (B's "polygon marker interaction" block): stub `MapIconTooltip.Release`, which `OnLeave` now calls. Extend "clears temporary polygon preview on marker leave" with `assert.spy(MapIconTooltip.Release).was.called_with(QuestieFrameInstance, GameTooltip)`.
- `TooltipHandler.test.lua`, `QuestEventHandler.test.lua`, `WaypointMap.test.lua`, `GamepadMapHover.test.lua`: unchanged and passing.

**F2:**
- `MapIconTooltip.test.lua`: WP's `describe("for a patrol path")` folds into "for given icons" as **"lists them wherever they are and however faded, for the frame given"**. This uses `ShowForIcons(Minimap, {icon, faraway}, …)` and asserts `GetOwner == Minimap`, and needs no zoom stubs.
- Add **"a faded out icon's own hover shows nothing"** (`ShowOnTooltip` at alpha 0 never calls `Show`). It keeps master's gate pinned once the exemption is gone.
- The two order tests call `ShowForIcons({}, {…})`.
- `WaypointHover.test.lua` asserts `ShowForIcons(Minimap, listed, minimapTooltip)`.

**F3:**
- Add **"keeps the colors to restore when a hovered icon's tooltip shows again before its reset"**. It shows twice, more than 0.05 s apart, then asserts the saved color is the original and there is one entry. It fails on WP's code.

**F4:**
- Move B's "previews polygon markers even when the tooltip refresh is throttled" and "does not call polygon preview for ordinary objective icons" to `QuestieFrame.test.lua`, as `OnEnter` tests.
- Move the F3 tint test to `QuestieFrame.test.lua` as `HighlightHover` idempotence.
- Add an `OnEnter` test: "an icon whose tooltip doesn't show highlights nothing".
- Remove the `QuestieWaypoints` and `WaypointHover` stubs from `MapIconTooltip.test.lua`.
- `GamepadMapHover.test.lua`: Enter highlights only when the tooltip shows. Add a Leave test if previews are kept.

---

## 6. Docs and comments

- **`MapIconTooltip.lua`**:
  - A short "Shown tooltips" section comment: what the module owns, who asks `GetOwner`, who calls `Release` and `Redraw`.
  - Doc comments as in §3.2.
  - Delete the stale `-- we separate this so things like MODIFIER_STATE_CHANGED can redraw the tooltip`.
  - Keep `ShowOnTooltip`'s doc comment true at each stage (rebase, F2, F4).
- **`EventHandler.lua`**: the map branch comment becomes "Questie's map icon tooltips show more detail while Shift is held."
- **`WaypointHover.lua`**:
  - The header (WP :13-21) names `ShowForIcons` for the minimap.
  - The `_Leave` comments (F1).
  - `End`'s doc comment once F4 moves its caller.
- **`docs/waypoints.md`**:
  - :52: "`MapIconTooltip` highlights through it" becomes "an icon's hover highlights through it (`QuestieFrame`)" after F4.
  - :226: drop "A minimap tooltip collects its entries from the minimap icons HereBeDragons shows near the hovered one." The path tooltip lists exactly the route's icons (F2).
  - :228: "A modifier key doesn't rebuild this tooltip" becomes "Shift redraws it, as GameTooltip's" (F1).
- **`Polygon/README.md`**:
  - :13: "so icons and waypoint lines keep their own tooltips" becomes Area A's precedence rule. Waypoint lines take no mouse input after WP.
  - :109: mention `GetOwner` if Area A adopts it.
- `docs/tracker-objective-text.md:54, :95`: no change, since the wording behavior is unchanged.

---

## 7. Verification

**Rebase:**
- After each of `dfb97c802` and `715031ef6`, run `busted Modules/Tooltips/MapIconTooltip.test.lua` (19, then 22).
- After `715031ef6`, also run `busted Modules/Map/Waypoints/WaypointHover.test.lua Modules/Map/GamepadMapHover.test.lua`.
- `luacheck -q Modules/Tooltips`.

**F1–F4:** these were run in the prototype, except `Polygon/QuestiePolygon.test.lua`. That file exists only after stacking; it stubs `ShowForIcons` and `Release`, whose signatures don't change.

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
2. **Any client, tint (F3).**
   - Take a kill quest whose target's patrol draws in the hostile route color.
   - On the world map, hover the route, slide onto the target's icon, pause, then move away.
   - The quest's other objective icons must return to their own colors. Before F3 they stay blueish, or white with objective colors on.
3. **Forever, minimap path (F1/F2).**
   - Hover a patrol path on the minimap: the private tooltip lists all of the NPC's quests, even when its icon is out of range.
   - Press Shift: the detail appears. This is new.
4. **Forever, blob mode** (`enableQuestiePolygons`).
   - Hover an objective area: the tooltip shows color swatches.
   - Shift adds detail.
   - Move onto a marker: its tooltip replaces the area's at once.
   - Back on bare map inside the area: the area tooltip returns.
   - After F1: leaving a route that crosses an area must not stop Shift from redrawing the area tooltip.
5. **Any client, regression for the `Tooltip.lua` gate.**
   - After hovering a map icon, mouse over a quest object in the world (for example, a quest herb or chest): Questie's quest lines still appear.
   - While a map icon tooltip shows, no object lines are appended to it.
6. **Forever, gamepad.** The map hover still shows its tooltip anchored right. After F4, a marker's area preview ends when the gamepad cursor leaves.
7. **Tracker.** The sizer's Shift tooltip still switches, since it still uses `_owner`.

---

## 8. Risks and open questions

| # | Risk or question | Recommendation |
|---|---|---|
| R1 | Removing `GameTooltip.ShownAsMapIcon` breaks any third-party addon that reads it. No reader exists in the repo besides `Tooltip.lua`. | Remove it. |
| R2 | `GetOwner` trusts that only MapIconTooltip shows tooltips for its owners. That holds for icons and private frames. Another addon could anchor GameTooltip to `ScrollContainer`; the vanilla UI source in `WoW-API/_UI` never does. B's `IsOwned` check has the same exposure, and forgetting state on `Release` narrows it. | Accept it. If in doubt, check the Forever UI source with the `wow-ui-source` skill. |
| R3 | `Redraw` re-anchors with `GetAnchorType()`. Classic's own `Classic_GameTooltip.lua:554` uses it. | Accept it. Check the gamepad Shift case in game (check 6). |
| R4 | `_QuestieFrame.OnLeave` now hides GameTooltip only while the icon holds it; before, it always did. This is release-only-if-mine. | Accept it. Check 1 covers it. |
| R5 | The minimap path tooltip loses the cluster neighbors of the NPC's icon (F2). These are icons within `0.3–0.5 / (1 + zoom)` percent of the zone's map, which is roughly 3–17 yards in an Elwynn-sized zone. The world map path tooltip, which is the icon's own tooltip, keeps them. | Accept it. A path hover is about its NPC. |
| R6 | The interim state after the rebase still has collision (a) and bugs (d), (e) and (f). | Land F1–F3 in the same PR. F4 with Area A. |
| R7 | F4 overlaps Area A: `OnEnter`/`OnLeave`, gamepad, and the `End` placement. | Area A decides the placement. F4 keeps only the rule that MapIconTooltip imports no feature. |
| R8 | The WIP snapshot may be split before rebasing. | Apply the `715031ef6` recipe to the commit that adds `ShowForIcons`/`Release`. |
| R9 | `ShowForIcons` with an empty list shows an empty box. The polygon caller guards against it; WP's `MinimapIcons` is never empty while a path is hovered. | Document "at least one icon", and don't guard. |

**Decisions for David** (also in §3):
- **D1:** owned state (`GetOwner`/`Release`/`Redraw`) rather than loose fields. Recommended.
- **D2:** the minimap path tooltip lists the route's icons only (R5). Recommended.
- **D3:** move hover begin effects beside their resets (F4), not callbacks. Recommended. The fallback is to keep the direct calls and move `EnterMarker` into `Show`.
- **D4:** `Redraw` covers every MapIconTooltip tooltip, which fixes Shift on minimap paths and gamepad. Recommended.
- **D5:** land F3 on `waypoints` before it merges, since it is waypoints' own bug.

---

## 9. Contracts with other areas

**I provide to all areas:**
- The API in §3.2.
- Invariants 1–7 (§3.5).
- Release-only-if-mine, through `Release(owner, tooltip)`.
- "Is it showing for X", through `GetOwner(tooltip) == X`.
- Shift handled centrally by `Redraw`.

**Area A, hover arbitration. I need:**
- Precedence between icon, path and area tooltips, and who calls `ShowForIcons`/`Release` and when. Area A may switch `_UpdateAreaTooltip`'s "already mine" check (B :350) to `GetOwner(GameTooltip) == owner`.
- **No two features share an owner frame without one arbiter.** If the path tooltip moves to `ScrollContainer` like the area tooltip, the area's `Release(ScrollContainer)` would end the path's tooltip.
- Every hover end must undo every hover begin.
  - The partial leave of `WaypointHover._Leave` (WP :86-91) must also end a polygon marker preview; that is bug (f).
  - Gamepad Leave must end what gamepad Enter starts; that is bug (e).
- Placement of `WaypointHover.End`. It must still run before any icon's tooltip and tint, because the tint ordering relies on it.
- Call `ShowForIcons` only on hover change (invariant 6).

**Area C, quest drawing and the line model. I need:**
- During the rebase, leave `_QuestieFrame.OnLeave`'s tooltip lines as both branches have them. F1 replaces them.
- Delete `QuestieMap.zoneWaypoint(Hover)ColorOverrides` and `lineFrames` freely. MapIconTooltip stops reading them at the rebase (WP's side wins).
- Route highlighting keys on `icon.data.waypointPaths`, so Area C decides which data carries which paths (finding 5).
- `_FallbackIconData` must not copy `touchedPins`, which is hover state.
- Linking `minimapTwin` for fallback markers (finding 4) decides whether `QuestieWaypoints.MinimapIcons` can list them in the minimap path tooltip.

**Area D, the minimap layer. I need:**
- Any minimap-owned map icon tooltip uses a private tooltip frame, never GameTooltip (invariant 5).
- If a second minimap hover appears, such as polygon areas, move `WaypointHover`'s `_MinimapTooltip()` into MapIconTooltip rather than creating another frame. Until then, YAGNI.

**Area E, geometry and scheduling. I need:**
- If the two world map hover pollers merge, keep a "changed" signal: B's `onHover(shapes, changed)` or WP's cursor-moved check. That way tooltips rebuild only on change.
- `ShowForIcons` is not frame-budgeted work, and must not run inside a coroutine `Checkpoint`.
