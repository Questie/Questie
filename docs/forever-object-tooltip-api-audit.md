# Forever hovered-object quest API audit

## Answer

**No supported, public combat relation has been established for these two hovered world objects.** The observed native Object tooltip carries the correct quest ID out of combat, but that ID and all useful objective content become secret in the supplied combat capture. Public quest-log data describes both quests; it does not say which world object is under the cursor.

This is not an exhaustive proof that no native API can ever identify an object. In particular, Forever has real **GameObject unit/nameplate support**. Whether either collection object supplies a usable `mouseover` token and public identity in ordinary addon combat code remains a targeted runtime question. Do not dismiss that possibility using the old assumption that objects never have unit tokens.

For implementation now: retain native secret display and do not choose a quest from its level, objective type, count, location, or last out-of-combat hover. Only enrich a tooltip when a current identity is independently public and validated. A supported display path is not permission to inspect its text.

## Scope and provenance

- Target: Forever **1.60.1 (70338)**, interface **16001**. Supplied JSON captures report this identity.
- Read-only source: `/home/logon/.cache/wow-ui-source/forever`, commit **`943764493e6b16d63ded3ab304150d1f05e58b57`**, subject `1.60.1 (70338)`. HEAD was checked before and after research and matched. No refresh, network fetch, bridge call, reload, or gameplay action was performed.
- Gethe publishes Blizzard's Lua/XML and generated API declarations, not the complete native implementation or an official guarantee of addon availability. Citations below are immutable links to that matching commit.
- Secondary snapshot: `/home/logon/projects/Questie-clones/fix-forever-native-quest-tooltips/WoW-API/reference/functions/`. The consulted pages identify their source usage as `forever @ 15666a6`, **1.60.1 (70245)**. They are older than this target, with stale-data risk. They are used for historical global signatures, not as current native authority.
- The live artifacts were supplied by the parent investigation. This audit inspected the redacted JSON, not the raw secret values or collector implementation.

## Existing live evidence

| Quest | Public quest-log objective in combat | Database association, not a native hover result |
|---|---|---|
| 97279, Wayward Weapons, level 2 | `type = "item"`, `objectiveType = 1`, `0/6 Abandoned Training Weapon`, unfinished | item **277653**, dropped by object **673476** |
| 4402, Galgar's Cactus Apple Surprise, level 3 | `type = "item"`, `objectiveType = 1`, `0/10 Cactus Apple`, unfinished | item **11583**, dropped by object **171938** |

The supplied database artifact lists both sets of object spawns in area 14, with overlapping coverage. An objective's `"item"` type describes what is collected, not whether its source is a creature or a world object. The distinct item/object IDs above come from Questie's database. Neither is an ID returned by these quest-log objective rows.

Artifacts inspected:

- `/tmp/questie-two-object-quests.json`: out-of-combat Cactus Apple, `dataInstanceID = 3077`, QuestTitle `id = 4402`.
- `/tmp/questie-two-object-quests-weapon.json`: out-of-combat Abandoned Training Weapon, `dataInstanceID = 3079`, QuestTitle `id = 97279`.
- `/tmp/questie-two-object-quests-weapon-combat.json`: combat true, shown GameTooltip, primary getter `GetWorldCursor`, `dataInstanceID = 3088`, tooltip type **Object (4)**.
- `/tmp/questie-two-object-quests-db.json`: the database associations and overlapping spawns above, plus quest 786's actual `"object"` objectives.

Combat tooltip 3088 has only these captured fields:

| Row | Public structure | Secret content |
|---|---|---|
| Object caption | `type = 0`, `lineIndex = 1` | `leftText`, `leftColor` |
| Quest title | `type = 17` | `id`, `leftText`, `leftColor` |
| Quest objective | `type = 8` | `leftText`, `numFulfilled`, `numRequired`, `completed`, `wrapText`, `leftColor` |

No captured top-level object ID, GUID, item ID, unit token, or objective index supplies an alternative join. That describes these samples, not every Object payload the engine can produce. The capture has one objective row for either item quest. Public row types/counts alone cannot distinguish them.

**Context qualification:** the parent reports operation probes in `ForceTaint_Strong` bridge context: length, `sub`, `find`, `match`, `gsub`, and comparisons fail on secrets; formatting succeeds but leaves a secret result. Those operation results are parent-reported, not encoded in the four JSON files. They must not be generalized to every addon execution context. The parent also reports ordinary addon rendering corroborated secret-display behavior, but this audit has not inspected a current 70338 addon-context capture. Older addon-context findings in `docs/forever-tooltip-secrets.md` target **70291**, not 70338. Reproduce current native getters and secrecy markers from the addon's normal event/callback path before making a universal combat claim.

## Concrete tooltip path and flavor loading

This Forever checkout ships `Mainline/GameTooltip.lua`, not a Classic replacement. The GameTooltip TOC selects `[Family]` Lua/XML; the source inventory explicitly contains its Mainline implementation. The Game TOC also contains Camelot-specific additions. Thus the modern path is relevant here despite the vanilla-era quest content. Native family selection itself is not implemented in this repository; the supplied runtime getter `GetWorldCursor` corroborates this path.

Sources: [GameTooltip TOC, lines 1-8][tooltip-toc], [source inventory, lines 1904-1924][inventory], [Game TOC, lines 1-20][game-toc], [GameTooltip XML, lines 4-36][tooltip-xml].

Trace:

1. `WORLD_CURSOR_TOOLTIP_UPDATE(anchorType)` means entering/leaving something in-world. Its declared payload contains **only the anchor type**, no object/quest ID. [Cursor docs, lines 50-58][cursor-event]
2. Mainline event routing calls `GameEvent.HandleWorldCursorTooltipUpdate`; that calls `GameTooltip:SetWorldCursor(anchorType)`. [Routing, line 117][event-routing], [implementation, lines 889-891][event-handler]
3. `GameTooltipDataMixin:SetWorldCursor(anchorType, parent)` calls **`C_TooltipInfo.GetWorldCursor()`**. It places the returned data in `{ getterName = "GetWorldCursor", tooltipData = ..., fadeOut = ... }` and calls `ProcessInfo`. There is no Lua quest/object resolver in this function. [GameTooltip, lines 987-1030][world-cursor]
4. The same function explicitly warns that addon taint can make secret world-cursor lines display no content. Blizzard uses `securecallfunction` for its own processing; this is not an addon declassification mechanism. [GameTooltip, lines 1003-1020][world-cursor-taint]
5. `GameTooltipDataMixin` derives from `TooltipDataHandlerMixin`. `GetPrimaryTooltipData()` returns the stored primary data. `HasDataInstanceID(id)` checks tooltip instances, and the event handler uses those IDs for **refresh**, not world-object identity. [GameTooltip, lines 960-984][refresh], [handler, lines 394-431][primary-data]
6. `TooltipDataProcessor.AddTooltipPostCall(type, callback)` / `AddLinePostCall(type, callback)` are callback registration paths. Addon callbacks are explicitly wrapped with `forceinsecure()`. Receiving data through them does not grant access to secret fields. [handler, lines 184-218][callback-context]

The matching docs declare `C_TooltipInfo.GetWorldCursor() -> TooltipData` (may return nothing). They do not declare a public hovered-object ID return. The enum distinguishes Object **4**, QuestTitle **17**, and QuestObjective **8**; these are presentation categories, not entity IDs. [Getter docs, lines 1344-1369][tooltip-getters], [line enums, lines 34-52][line-enums], [tooltip enums, lines 96-103][tooltip-enums]

Blizzard's `TooltipDataRules.QuestObjective(tooltip, lineData)` chooses an icon from `lineData.completed`; it does not look up a quest or objective index. This file is included under `AllowLoadGameType mainline`. Its privileged rendering does not establish that an addon may branch on the same secret boolean. [Rules, lines 100-113][objective-rule], [SharedXMLGame TOC, lines 7-11][shared-toc]

## Quest/objective APIs do not supply the missing cursor association

### `C_QuestLog.GetQuestObjectives(questID)`

Signature: `objectives = C_QuestLog.GetQuestObjectives(questID)`; may return nothing. Each declared `QuestObjectiveInfo` has:

```lua
text, type, finished, numFulfilled, numRequired, objectiveType
```

There is **no declared `objectID`, item ID, GUID, or objective-ID field**. The array position supplies an objective index within a known quest. It does not identify the hovered entity. The supplied combat capture demonstrates public quest-log content for these quests, not public Object-tooltip content. [QuestLog docs, lines 476-491][quest-objectives], [structure, lines 1580-1592][objective-structure]

Do not equate the numeric `objectiveType` with tooltip line type 8. The former is the gameplay category; the latter says this tooltip row presents an objective. The matching generated files reference `QuestObjectiveType` but do not define its enumeration here. The observed `1` accompanies `type = "item"`; it is not item 277653 or object 673476.

### Historical globals

- `text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questID, objectiveIndex, displayComplete)`.
- `description, objectiveType, isCompleted = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex [, suppressProgressPercentageInObjectiveText])`. The third input is used by the matching tracker implementation; older vendored documentation lists only the first two.

Matching Blizzard Lua consumes **five** values from `GetQuestObjectiveInfo` and **three** from `GetQuestLogLeaderBoard`. No consumed return is an object/item ID. [GameTooltip, lines 722-736][objective-global], [quest tracker, lines 211-220][leaderboard-call]

The older vendored pages `GetQuestObjectiveInfo.md` and `GetQuestLogLeaderBoard.md` document those five and three returns respectively, with no object ID. This supports the historical distinction but does not prove that native code has no undocumented extra return on 70338. If that specific doubt remains, collect all return slots in ordinary addon code, including count and per-slot secrecy/type markers. Do not infer an entity ID from an extra numeric slot without a supported definition.

### Special quest item is not a hovered collection source

- `link, icon, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)`.
- `C_TooltipInfo.GetQuestLogSpecialItem(questIndex) -> TooltipData` (may return nothing).

Blizzard uses the global to set up the objective tracker's **usable quest-item button**, queries cooldown/range, and uses `UseQuestLogSpecialItem`. `icon` is passed to `SetItemButtonTexture`, not used as an entity ID. Its item ID helper obtains an item ID from the returned link. None of this associates a world cursor with the collectible item or its source object. [Tracker item button, lines 88-110 and 145-150][special-item], [tooltip docs, lines 816-830][special-tooltip]

### Unit quest helpers

`C_QuestLog.IsUnitOnQuest(unit, questID) -> boolean` is concretely used to count **party members on a quest**. It is not evidence that a GameObject is an objective source for that quest. [Declaration, lines 1065-1079][unit-on-quest], [party caller, lines 1061-1070][party-quest]

`C_QuestLog.UnitIsRelatedToActiveQuest(unit) -> boolean` and `UnitIsQuestBoss(unit) -> boolean` provide a relationship flag, not which quest or objective. The former has no concrete callers in this checkout. Even a public true result could fit both item quests. [QuestLog declaration, lines 1286-1300][unit-related], [Unit declaration, lines 2318-2332][quest-boss]

## Other credible identity paths and their limits

| Path | Matching source evidence | What is still missing for these hovers |
|---|---|---|
| Unit/GameObject identity | `UnitIsGameObject(unit) -> boolean`; `UnitGUID(unit) -> WOWGUID?`. Camelot nameplate level code handles GameObjects explicitly; shared nameplate health-bar code does too. | A token demonstrably referring to **this cursor's** object, and a public GUID/name in combat. `UnitGUID` is tagged `SecretWhenUnitIdentityRestricted`; existence of the API is not permission to inspect its result. |
| Displayed tooltip unit/item | `GameTooltip:GetUnit()` delegates to `TooltipUtil.GetDisplayedUnit`, which accepts only **Unit** tooltip type; `GetItem()` similarly accepts only **Item**. | An Object (4) tooltip is not converted into a Unit/Item tooltip by these wrappers. |
| Nameplates/soft interaction | Nameplate add events give a unit token; Blizzard compares a plate token to `softinteract` to draw a cursor icon. | A nearby plate/soft target is not necessarily the physical mouse hover. Neither path declares a quest/objective ID. Do not substitute `target`/`softinteract` without proving correspondence. |
| Closest object position | `ClosestGameObjectPosition(gameObjectID) -> x, y, distance`, tagged **`SecretReturns = true`**. | It takes an already-known object ID, not a cursor, and returns proximity rather than hovered identity. Not a public location-based join. |
| Task/map quest POIs | `C_TaskQuest.GetQuestsOnMap(uiMapID) -> QuestPOIMapInfo[]?`; `GetQuestLocation(questID, uiMapID) -> x, y`. Map cache uses these quest records. | POI records have quest ID, map, position and objective count, not hovered object identity. Both sample quests report `isTask = false`. Overlapping ordinary quest areas cannot choose the cursor's quest. |
| Minimap | `C_TooltipInfo.GetMinimapMouseover() -> TooltipData?` is used by `Minimap_OnUpdate`; `C_Minimap.IsInsideQuestBlob(questID) -> boolean`. | Minimap hover is a different UI context. A quest-blob membership boolean describes an area, not the hovered object. No public mapping from world-cursor dataInstanceID to minimap data is shown. |
| Vignettes | `C_VignetteInfo.GetVignettes()` and `GetVignetteInfo(vignetteGUID)` can supply **objectGUID** and **rewardQuestID**. The map provider enumerates these. | A credible relation for vignette-backed content, but no evidence either collection object has a vignette. Reward quest ID is not necessarily the collection quest. A matching current public object GUID is still needed to associate a vignette with this cursor. |
| Interaction/WorldLootObject | `C_PlayerInteractionManager` exposes interaction-type checks/events and restricted `InteractUnit`. `C_WorldLootObject.GetWorldLootObjectInfo(unitToken)` returns inventory type/quality/upgrade metadata. | Interaction state is not passive hover identity. The WorldLootObject schema has no quest/objective ID and is not proof these ordinary collection objects belong to that system. No interaction should be initiated as a probe. |

Sources for this table:

- Unit/GameObject: [Unit docs, lines 1992-2005][is-gameobject], [GUID docs, lines 1240-1254][unit-guid], [Camelot level frame, lines 1-10][camelot-object], [health bar, lines 36-43][object-health]. The generated secrecy predicate describes non-player/non-party identity restrictions; exact application in this flavor/context still needs runtime evidence. [Predicate, lines 125-128][identity-secrecy]
- Tooltip wrappers: [TooltipUtil, lines 9-42][tooltip-util], [GameTooltip, lines 1036-1046][tooltip-wrappers].
- Nameplate/soft target: [driver, lines 168-203][nameplate-driver], [TOC, lines 5-22][nameplate-toc]. The TOC explicitly selects Camelot object-aware level code. This does not prove both sample objects receive plates.
- Closest position: [Unit docs, lines 33-50][closest-object].
- Task POIs: [TaskQuest docs, lines 44-60 and 144-158][task-quest], [POI structure, lines 26-44][poi-structure], [map cache, lines 365-400][task-cache].
- Minimap: [implementation, lines 269-272][minimap-call], [tooltip docs, lines 618-627][minimap-tooltip], [blob docs, lines 150-163][quest-blob].
- Vignettes: [docs, lines 58-101][vignette-getters], [structure, lines 124-148][vignette-structure], [map provider, lines 114-123][vignette-caller].
- Interaction: [PlayerInteractionManager docs, lines 31-84 and 100-119][interaction], [WorldLootObject getters, lines 42-71][worldloot-getters], [WorldLootObject structure, lines 147-155][worldloot-structure]. The tooltip rule for WorldLootObject pickup indicators registers for **Spell**, not Object. [Rule, lines 204-212][worldloot-rule]

## Live follow-up on build 70338

The parent ran read-only bridge probes after the source audit. The same response confirmed combat active and an Object tooltip visible. Raw sanitized results: `/tmp/questie-object-hover-api-probes.json`. The user had reported hovering the training weapon; secret payload identity was not independently decoded.

| Probe | Observed result |
|---|---|
| Stored primary Object tooltip, instance 4895 | Quest ID, text, counters, completion, wrapping and colors secret |
| Fresh `C_TooltipInfo.GetWorldCursor()`, instance 4896 | Same field structure and secrecy; refetching did not supply public identity |
| `UnitExists("mouseover")`, `UnitIsGameObject("mouseover")` | Both false |
| `UnitGUID("mouseover")`, `UnitName("mouseover")` | Nil GUID; nil name/realm |
| `softinteract` exists/GameObject/GUID/name | False/false/nil/nil |
| `target` control | Exists; not a GameObject; public Mottled Boar name and Creature GUID containing NPC 3098 |
| `C_QuestLog.UnitIsRelatedToActiveQuest` | False for mouseover, softinteract and target; no quest identity provided |
| `GameTooltip:GetUnit()`, `GameTooltip:GetItem()` | No return values for this Object tooltip |
| `GetQuestObjectiveInfo(97279, 1, false)` | Exactly five returns: public text, `"item"`, false, 0, 6 |
| `GetQuestObjectiveInfo(4402, 1, false)` | Exactly five returns: public text, `"item"`, false, 0, 10 |
| `GetQuestLogLeaderBoard(1, logIndex)` | Exactly three returns: public description, `"item"`, false, for both quests |
| `GetQuestLogSpecialItemInfo(logIndex)` | No return values for either quest |
| `C_NamePlate.GetNamePlates()` | Empty collection at this capture |
| `C_VignetteInfo.GetVignettes()` | Empty collection at this capture |
| Later `ClosestGameObjectPosition(171938)` / `(673476)` combat probe | API available; both calls succeeded but returned zero values |

The `true` reported by the position probe belonged to `pcall`, not to `ClosestGameObjectPosition`. No coordinates or distance, secret or public, were returned. The cause of the absent data was not established; this is not proof of a Blizzard-only permission rule.

Blizzard's matching [TutorialRangeManager](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_TutorialManager/Blizzard_TutorialRangeManager.lua#L24-L75) selects this getter for known object IDs and checks the returned distance against a tutorial range. That source use supports a proximity role, not a current mouse-hover association. It does not establish that this tutorial module is loaded on the current client.

The raw helper includes `pcall`'s success boolean in its return counts. Counts above exclude that boolean. These are bridge-context observations, not a new ordinary-addon callback capture. There were no permanent hooks, targeting changes, interactions, CVar changes or reloads.

**Result:** the legitimate GameObject unit-token lead did not identify this hover in the tested context. Neither legacy objective getter has an extra entity-ID return on this client. No tested alternate API joins the public quest log to the secret world-object tooltip. This does not prove every GameObject category behaves the same or replace an ordinary-addon-context check.

## Remaining targeted checks

The follow-up above covers several checks below in bridge context. No ordinary-addon callback diagnostic was installed. Prefer a small diagnostic in the addon's ordinary event or `TooltipDataProcessor` callback, not bridge-injected raw reads. Record build, context, combat state, getter, and sample sequence in the same capture. Redact secrets before storing or printing. Capability-check each function; generated declarations do not guarantee runtime presence.

1. **Current addon-context control:** alternate physical hovers between the two collection objects while remaining in combat, then repeat out of combat. Record public/secret markers for every actual field in primary Object tooltip data, including QuestTitle `id`. Do not parse or compare secret content. This verifies whether the supplied bridge result generalizes to ordinary addon code and rules out stale last-hover state.
2. **Best unresolved public identity lead:** at each of those same hovers, read `UnitIsGameObject("mouseover")`, `UnitExists("mouseover")`, `UnitGUID("mouseover")`, and `UnitName("mouseover")` if available. Record secrecy before any string processing or comparison. Include a nearby ordinary creature as a control. `UnitIsGameObject` deserves its own probe even if `UnitExists` is false; Blizzard has call sites that treat these separately. A public GameObject GUID would justify evaluating a current identity-based database join, not secret inspection.
3. **Only if needed, nameplate/soft-target coverage:** record available nameplate tokens and public `UnitIsGameObject` flags, plus `softinteract` identity markers. Have the user move only the physical cursor between the objects without changing the selected target. A stable soft target while cursor changes disproves it as a substitute. Do not mutate targeting/CVars or operate forbidden frames.
4. **Legacy return uncertainty:** capture all slots/counts from `GetQuestObjectiveInfo(97279, 1, false)` / `(4402, 1, false)` and `GetQuestLogLeaderBoard(1, currentLogIndex)` in combat. Similarly inspect `GetQuestLogSpecialItemInfo(currentLogIndex)` without using the item. This is a signature check, not a search for ways to extract a secret.
5. **Vignette coverage, only if a public current identity exists:** enumerate `C_VignetteInfo.GetVignettes()` and public fields of corresponding records. Verify a matching public `objectGUID` before interpreting `rewardQuestID`. Absence of a sample's vignette ends that path for this sample, not every object.

Never use error/success differences, secret string lengths, formatting, hidden tooltips, or comparisons against known quest names/counts to recover the value. Formatting that leaves a secret can be used for supported display, not identity lookup. Do not retain a previous public title ID as the identity of a later secret tooltip.

## Confidence and boundary

- **High:** the supplied combat Object payload does not provide a public quest/item/object identity; fully public quest-log objectives do not themselves fill that missing relation. Matching Blizzard world-cursor Lua renders native data rather than resolving a public quest ID.
- **High:** the documented objective structures and consumed historical return shapes are descriptive/progress data, not source-object IDs. Special quest items, party quest membership, POI proximity and generic relation flags are not equivalent to current hover identity.
- **Open:** public GameObject identity through unit/nameplate tokens in ordinary addon combat context for objects 673476 and 171938. The bridge follow-up found no mouseover/softinteract token, no current nameplates and no vignettes. The matching source makes ordinary-addon corroboration a legitimate check, not an established solution.
- **Limit:** source review is bounded to the relevant paths above. Native implementation, undocumented APIs/returns, every gameobject category, and all taint contexts were not exhaustively tested. Do not publish an absolute statement that no supported API could ever work.

[tooltip-toc]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Blizzard_GameTooltip.toc#L1-L8
[inventory]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/ui-code-list.txt#L1904-L1924
[game-toc]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_Game/Blizzard_Game.toc#L1-L20
[tooltip-xml]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.xml#L4-L36
[cursor-event]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/CursorDocumentation.lua#L50-L58
[event-routing]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_Game/Mainline/EventRouting.lua#L117
[event-handler]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_Game/Mainline/EventImplementation.lua#L889-L891
[world-cursor]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L987-L1030
[world-cursor-taint]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L1003-L1020
[refresh]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L960-L984
[primary-data]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua#L394-L431
[callback-context]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua#L184-L218
[tooltip-getters]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua#L1344-L1369
[line-enums]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua#L34-L52
[tooltip-enums]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua#L96-L103
[objective-rule]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataRules.lua#L100-L113
[shared-toc]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedXMLGame/Blizzard_SharedXMLGame.toc#L7-L11
[quest-objectives]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L476-L491
[objective-structure]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L1580-L1592
[objective-global]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L722-L736
[leaderboard-call]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_QuestObjectiveTracker.lua#L211-L220
[special-item]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_ObjectiveTrackerShared.lua#L88-L150
[special-tooltip]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua#L816-L830
[unit-on-quest]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L1065-L1079
[party-quest]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_FrameXMLUtil/Mainline/QuestUtils.lua#L1061-L1070
[unit-related]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L1286-L1300
[quest-boss]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua#L2318-L2332
[is-gameobject]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua#L1992-L2005
[unit-guid]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua#L1240-L1254
[camelot-object]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_NamePlates/Camelot/Blizzard_NamePlateLevelFrame.lua#L1-L10
[object-health]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlateHealthBar.lua#L36-L43
[identity-secrecy]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/SecretPredicatesDocumentation.lua#L125-L128
[tooltip-util]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipUtil.lua#L9-L42
[tooltip-wrappers]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L1036-L1046
[nameplate-driver]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.lua#L168-L203
[nameplate-toc]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.toc#L5-L22
[closest-object]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua#L33-L50
[task-quest]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestTaskInfoDocumentation.lua#L44-L158
[poi-structure]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestInfoSharedDocumentation.lua#L26-L44
[task-cache]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedMapDataProviders/SharedMapPoiTemplates.lua#L365-L400
[minimap-call]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_Minimap/Mainline/Minimap.lua#L269-L272
[minimap-tooltip]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua#L618-L627
[quest-blob]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/MinimapDocumentation.lua#L150-L163
[vignette-getters]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/VignetteInfoDocumentation.lua#L58-L101
[vignette-structure]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/VignetteInfoDocumentation.lua#L124-L148
[vignette-caller]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedMapDataProviders/VignetteDataProvider.lua#L114-L123
[interaction]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/PlayerInteractionManagerDocumentation.lua#L31-L119
[worldloot-getters]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/WorldLootObjectDocumentation.lua#L42-L71
[worldloot-structure]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/WorldLootObjectDocumentation.lua#L147-L155
[worldloot-rule]: https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataRules.lua#L204-L212
