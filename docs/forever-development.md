# Forever compatibility work

Future resilience work is tracked in [the hardening backlog](forever-hardening-backlog.md). Those proposed fallbacks are not implemented yet.

The [SavedVariables timing investigation](saved-variables-investigation.md) includes a minimal cold-start failure on build `69913` without Questie or AceDB loaded: a strictly late probe saw nil while its file still contained count 4. Reload tests alone had appeared healthy. Normal addon states were restored and probes disabled. The unsuccessful startup-deferral prototype was removed. At the end of that investigation, `QuestieInit.cacheStatus` recorded cache reuse or compilation for the session. The QuestieDB migration has since removed the consumer compiler and that field; the investigation remains historical evidence about client persistence, not the current initialization path.

## Current integration status

`feature/forever` is rebased onto `origin/master` at `bd177929e`. The previous tip is preserved as `backup/forever-before-db-integration-20260919` (`71e88ae11`). Local investigation notes were restored; their stash and `.scratch/integration-backup/` copies remain. The consumer integration checkpoint is commit `9c5e723c7`; the provider parent-mapping checkpoint is `fe85e10`. Neither was pushed as part of this checkpoint.

Questie now uses the external provider described in [QuestieDB integration](questiedb-integration.md), not a local compiler or entity fallback. The intended provider checkout is `~/projects/Questie-clones/QuestieDB`, on `forever` at `fe85e10` (parent `eb31833`), with existing Baked artifacts. The Source-mode live results below were collected earlier using the separate `~/projects/QuestieDB` checkout at `f1567bd3`; its tracked tree matched `eb31833` before the parent-mapping checkpoint. The original beta symlink has since been restored. Startup and compatibility probes against that checkout's Baked setup passed during the consolidation below; the earlier broader Source-mode checks do not establish full Baked coverage.

Only the temporary runtime data edit remains in the intended provider: 64 additional relationships in `support/Forever/Zones/subZoneToParentZone.lua`. The supporting emulator, test, and documentation edits were removed as requested; the full patch is backed up under `.scratch/provider-patch-transfer.TAjbTB/forever-provider.patch`. The unchanged focused provider suites passed 185 checks after this reduction. No generation, reload, staging, or commit accompanied it.

The planned DBC support exporter should supersede this data-only patch when its reviewed output is adopted. Normal `generate.lua` builds currently load this support file rather than regenerate it. Preserve the relationships until the replacement supplies them; do not rerun the staging DBC generator over its protected manual handoff.

Provider native TOC conditions select Forever despite project ID 1. Its independent Forever inputs include the five reviewed maps below and all 65 reviewed parent relationships. Source mode has no Base translations; Dynamic Translation Corrections remain available. Provider content is not complete for new Forever entities. See the provider checkout's `docs/forever.md` and `docs/forever-data.md` for data provenance and Source/Baked limitations.

### Integration decisions

- Keep this branch's tracker ownership/combat deferral, native-watch synchronization, quest-ID timer lookup, event normalization, profession refresh, named-color item parsing, HBD 34 geometry, and Skyborne eligibility handling. The donor zip would regress several of these paths.
- Adopt the `compat-fixes` wrapper approach, but register `QuestieCompat` with QuestieLoader rather than publishing a global. First-party consumers import it. All client conversions now live in `Modules/QuestieCompat.lua`, with no separate Forever module or late method overrides.
- Preserve legacy return contracts at wrapper boundaries: quest tags occupy title-tuple slot 3, failed quests return `-1`, missing indices return `0`, abandonment items become names or nil, and stable food types return varargs. Header and missing-index guards avoid invalid modern API calls.
- Guard absent legacy hooks and quest-log frames rather than suppressing unrelated errors. This includes scroll-range, item-reference, popup, and cursor-item hooks, plus tracker menu/line/options refreshes.
- Keep zone facts in QuestieDB. The consumer overlay was removed, and 64 missing reviewed parent relationships were added to the provider alongside its existing Valley of Bones relationship.
- Defer the zip's combat tooltip early-return, deferred tooltip callbacks, protected-text fallback, and blanket aura `pcall` until live failures establish the needed boundary. These are not adopted fixes; see the [hardening backlog](forever-hardening-backlog.md#combat-tooltip-restrictions-need-live-reproduction).

### Compatibility consolidation

The separate `QuestieForever` module duplicated conversions already implemented in `QuestieCompat`. Its wrappers and tracker-visibility handling now live beside their shared counterparts in `Modules/QuestieCompat.lua`; the old source/test files and Camelot TOC entry are removed. The existing Forever tests moved into the shared module's test file.

Capability-based branches explain the conversion back to Classic contracts. Explicit Forever branches remain where legacy globals exist but are broken, where native watch state must bypass Questie's legacy interception, and where modern tracker visibility needs combat deferral. This file loads before `VersionCheck`, so its early Forever detection uses the same interface range, not the shared Retail project ID. Only Forever installs the missing `SetDesaturation` global for AceGUI checkboxes before embedded libraries load. The former `GetSpellInfo` shim and unused tuple wrapper were removed: bundled spell widgets already prefer `C_Spell.GetSpellName`. AceGUI itself is unchanged.

Validation: 45 focused compatibility tests and 1,938 full-suite tests passed; lint and loader-usage checks passed. Coverage includes early loading without `Questie`, Classic/Titan visibility, Forever combat deferral, existing broken globals, full aura/tag tuples, and library shims. At that checkpoint, review identified and guarded a possible self-call through the spell bridge if the native API disappeared. The subsequent spell-shim removal also removed that obsolete test; the results below describe the earlier implementation.

A beta reload on build `69913` with the restored Baked provider completed with Contract 2, `Questie.started` and `API.isReady` true, no visible error dialog, no global `QuestieCompat`, and no registered `QuestieForever` module. Quest 747's title/watch lookup, timer query, spell tuple, mouse-over method, aura query, tracker anchor, and both early library bridges were checked. No installation links or provider files changed. This consolidation does not change tooltip scanning or establish additional combat-taint safety.

### Beta deployment

Inspect actual Windows link targets before assuming which checkout is loaded. The first integrated consumer reload found a different Baked provider: beta's QuestieDB link resolved through Era to `~/projects/Questie-clones/QuestieDB` at `eb31833`. That checkout had three local commits and untracked files; it was left untouched.

During the Source-mode tests, only beta's provider link was repointed to `\\wsl.localhost\Ubuntu\home\logon\projects\QuestieDB`. As requested, that change was undone by moving the preserved original symlink back. Beta again points through `C:\Games\World of Warcraft\_classic_era_\Interface\AddOns\QuestieDB` to the intended `Questie-clones/QuestieDB` checkout. Shared Era/Classic provider links were not changed. Questie's existing shared source links remain as they were, so those clients will see consumer edits on their next load; they were not launched or reloaded for this validation.

During the temporary Source deployment, the client cached the old `QuestieDB_Camelot.toc` filename and initially reported the provider missing. An ignored local copy at `~/projects/QuestieDB/QuestieDB_Camelot.toc` supplied that filename in Source mode. That alias remains in the separate checkout but is no longer part of the restored beta installation.

The bridge's reload marker can time out even when the reload succeeds. Follow a timeout with one small readiness/version probe rather than assuming failure or issuing another reload blindly.

### Integration validation

Recorded offline checks:

- Consumer suite: 1,928 passing tests; lint clean across 315 files; loader-usage validation passed.
- Provider mock conformance: 34 passing cases against the linked provider. This suite selects Classic, so it does not validate Forever zone content.
- Provider native-TOC/TOC/Forever-data checks: 185 checks passed; Forever validators and self-check passed, with 15/15 validators and no findings.
- Independent review confirmed all five map mappings and 65 parents against the preserved consumer overlay.

Live startup exposed a consumer validation assumption: Forever uses Era content, but its native zone data does not contain Era's map-113 suppression entry. The validator now checks Forever's actual continent override and reviewed Zephras Isle relationships without weakening ordinary Era checks. Seven added tests and focused review cover that boundary; see [support validation](support-validation.md).

The integrated version was verified on build `69913`, interface `16001`, with Tauren Shaa Monn in Mulgore (map `1412`). ForeverClassicUI was also loaded; this was not an isolated-addon run.

- Source provider Contract 2 loaded; `Questie.started` and `Questie.API.isReady` were true. Imported compatibility methods were present and global `QuestieCompat` was nil.
- Quest 747, The Hunt Begins, showed native and cached `5/7` progress for meat and feathers. The tracker was visible; item 4739's tooltip included the quest title and `5/7 Plainstrider Meat`. The aura wrapper returned Mark of the Wild.
- Adding the native watch twice retained one watch. Removal set Questie's untracked flag; re-addition cleared it. The original absent native watch and tracking flags were restored.
- Tracker disable restored originally absent legacy watch globals to nil. Re-enable reinstated them after asynchronous initialization; the final tracker state was enabled and started. Opening the quest through `TrackerUtils:ShowQuestLog` selected quest 747 in the modern log.
- All five reviewed Forever maps, both continents, and Azeroth opened with the expected area IDs. Screenshots confirmed Mulgore map/minimap pins and aligned Azeroth pins. Zephras Isle had no visible quest pins, consistent with the content gap rather than proof of complete coverage.
- The nine-map, three-point geometry audit measured a maximum normalized error of `7.45895e-8` against native rectangles. Map opening used `HandleUserActionOpenSelf` rather than toggle semantics with ForeverClassicUI. Panels were closed and map/watch state restored afterward.

Evidence is local and ignored under `cli/output/forever/integration/`: `startup.json`, `map-coordinates.json`, `watch-check.json`, `map-navigation.json`, `item-tooltip.json`, `tracker-cycle.json`, `final-status.json`, and the Mulgore/Zephras/Azeroth screenshots. The tracker-cycle snapshot precedes asynchronous completion; `final-status.json` confirms completion.

Successful checks captured no addon errors. Raw capture is not empty: a diagnostic passed the C function `Screenshot` directly to `C_Timer.After` and failed; a Lua closure corrected it. A separate bridge-local probe passed a number where `ShowQuestLog` requires a quest table, then succeeded with the documented argument. Neither was an addon regression.

A final fresh reload also completed with Source Contract 2, Questie and tracker started, API ready, global `QuestieCompat` nil, and no visible error dialog. Its filtered chat output contained only the historical migration-reset message; evidence is `fresh-reload.json`.

That repeated reset message does not establish a fix for the [SavedVariables limitation](saved-variables-investigation.md). Real combat, active quest acceptance/progress/turn-in, live Skyborne identity, timed quests, and party synchronization remain untested in this integration.

### Object tooltip migration

Forever's structured Object path now uses a primary `GameTooltip` post-call instead of the object `OnUpdate` scanner. It preserves provider name/zone resolution, rejects secret inputs, and tracks augmentation until `OnTooltipCleared` rather than reading FontStrings to detect duplicates. Classic retains object polling and native Item/Unit scripts. Processor presence alone is insufficient: the frame must expose `GetPrimaryTooltipData` to select structured callbacks. Unit/Item rendering and their existing FontString reads remain unchanged.

The [tooltip reference](forever-tooltips.md#implemented-object-callback-path) describes the capability boundary, showing/resizing ownership, and validation limits. Recorded checks: 62 focused tooltip tests and 1,958 full-suite tests passed, with focused source lint clean. Review found no production issue.

Live Classic checks used 2.5.6, build `69795`, interface `20506`, project ID 5, matching `classic_anniversary` source `1463c686270b6c64e2c5c228f447c4597c0f8ba6`. Native setters fired legacy scripts but no processor callbacks before the change. After reload, Questie was ready; Item and Unit augmentation executed, `ClearLines()` fired `OnTooltipCleared`, and a short synthetic object-caption probe produced one Object ID line. Settings were restored; installation links and provider files were untouched. Evidence is ignored under `cli/output/forever/tooltip-migration/`.

These checks were out of combat and used setters/synthetic text, not physical world-object hovering. Era was not separately live-tested. The new Forever implementation still needs live clear/rebuild, hover, refresh, and combat validation; earlier Forever captures do not establish those results.

### Structured tooltip probes before migration

The [Forever tooltip reference](forever-tooltips.md) documents the data model, callback/update lifecycle, payload examples, current Questie consumers, and remaining tests. This section retains the session findings.

On build `69913`, two manual out-of-combat hover windows produced 121 `TooltipDataProcessor.AllTypes` callbacks: 66 Unit, 25 Item, 11 Spell, 10 Object, and 9 Macro. The session-only recorder reported no errors and stopped automatically. Unit payloads supplied GUIDs and unit tokens; Item and Spell payloads supplied IDs. Object payloads supplied text but no object ID in the observed cases, including Burning Embers and Bloodhoof Village. Object type is therefore not proof of an interactable quest object.

Direct `C_TooltipInfo.GetUnit`, `GetItemByID`, and `GetSpellByID` calls returned populated fields without a tooltip frame. `TooltipUtil.SurfaceArgs` is absent on this build; the older migration example must not be copied literally. A further timed hover probe confirmed `GetWorldCursor()` returns Unit or Object data and returns no data over empty ground. Unit cursor data and `GetUnit("mouseover")` matched for the observed NPC; sampling during cursor transitions can briefly return data from only one query.

Direct item/player reads generated no post-call callbacks. Item 4739's direct data contained Blizzard's item lines without Questie's rendered quest-progress additions. The existing `QuestieScanningTooltip` already inherits `GameTooltipTemplate`, exposes `SetItemByID`/`GetTooltipData`, and registers `TOOLTIP_DATA_UPDATE`.

This supports replacing Forever's object `OnUpdate` text scanner with Object post-call data while retaining name-based object resolution. It does not establish combat access, complete callback/update coverage, or the safety of secret-value comparisons. No production tooltip code changed during these probes. Other tooltip types and combat remain untested. Diagnostics redact secret values rather than attempting to inspect them; callbacks become inert when their timers stop.

A subsequent 10-second hover captured quest-objective mob Plainstrider (NPC 2955). Its Unit callback contained a `QuestTitle` line (`type = 17`) with quest ID 747, followed by two `QuestObjective` lines (`type = 8`) with `completed = false`, `numFulfilled = 0`, and `numRequired = 7`. The rendered tooltip contained those native objectives plus Questie's appended title/objectives and 80% drop rates. These callbacks already carry structured quest identity/progress; text parsing is unnecessary for those fields. This was out of combat with no recorder errors; evidence is `tooltip-objective-mob.json`.

Evidence and diagnostic scripts are ignored local files under `cli/output/forever/integration/tooltip-*`. The matching refreshed Blizzard source was `forever` commit `70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e` (`1.60.1 (69913)`).

## Historical live baseline before QuestieDB integration

Developed against Forever `1.60.1`, builds `69893` and `69913`, interface `16001`. Forever reports `WOW_PROJECT_ID = 1`, like Retail, but uses Classic content. No season was active during these checks.

Verified in-game on a Human character before the provider migration:

- Database compilation and initialization complete; `Questie.started` and `Questie.API.isReady` are true.
- Quests 783 (A Threat Within) and 33 (Wolves Across the Border) load into the quest state and tracker.
- World-map and minimap icons render, including objective locations.
- Native quest-log untracking/retracking updates Questie's state correctly. The original watch type was restored after testing.
- The Tough Wolf Meat tooltip includes the quest title and `0/8 Tough Wolf Meat`.
- Reputation reward lookup succeeds without the former aura error.
- A fresh session on build `69913` completed these checks without Lua or printed Questie errors.

The subsequent Skyborne zone/race fixes passed local tests and review. The integration checks above now cover map navigation and provider relationships; live Skyborne race/faction eligibility remains pending. Real combat transitions, timed quests, profession learn/unlearn, and party synchronization have not been exhaustively exercised. Do not unlearn professions or manipulate inventory merely to test compatibility.

## Compatibility boundaries

| Area | Implementation and reason |
| --- | --- |
| Content detection | `Modules/VersionCheck.lua` detects Forever using interface range `16000–16999`; `IsClassic` includes Forever. `Modules/Expansions.lua` maps only that flag to Era. Actual Retail and unknown project IDs stay unmapped. |
| Early API translations | `QuestieLoader.lua` precedes `Modules/QuestieCompat.lua` on every client. That single module owns the client conversions and installs the missing AceGUI `SetDesaturation` bridge only on Forever, before embedded libraries and first-party consumers load. |
| Quest acceptance | `Modules/EventHandler/EventHandler.lua` translates Forever's single quest-ID event argument into the existing index-plus-ID handler contract. A missing timer API had previously interrupted acceptance after an empty quest state was created. |
| Professions | `Modules/QuestieProfessions.lua` uses modern profession indices when skill-line APIs are absent. Sparse results preserve secondary professions; removals refresh availability through `SKILL_LINES_CHANGED`. A missing legacy hook no longer aborts the module before its constants are defined. |
| Tracker | Modern watch hooks use quest IDs and retain native watches. Classic retains its prior behavior. Modern additions are idempotent, not toggles. Namespaced watch-count functions retain their native meaning. |
| Native tracker visibility | `QuestieCompat` owns Forever suppression only while requested, defers changes during combat, and releases through Blizzard's content-aware `Update()`. Classic retains its legacy WatchFrame handling, including Titan's alpha workaround. |
| Quest timers | Modern timer records are matched by quest ID without changing selected quests. `QuestieCompat.GetQuestTimers` exposes seconds as varargs for remaining callers. |
| Reward buff estimates | XP/reputation buff multipliers and the money-buff check return zero bonus/false during Forever combat before reading auras. Original `QuestieCompat.UnitAura` loops remain, with no shared search helper, cache or new error handling. Classic/SoD combat behavior, base rewards, non-aura modifiers, actual rewards and eligibility are unchanged. Non-combat restrictions and live validation remain open; follow-up is tracked in [#7868](https://github.com/Questie/Questie/issues/7868). |
| Tooltips | `Tooltip.lua` requires the frame's structured-data getter as well as the processor for Forever callbacks. Its Object path no longer polls; Classic retains available native scripts and object polling. Unit/Item handlers still use existing getter/count logic and named-color-compatible item parsing. See the [tooltip reference](forever-tooltips.md#implemented-object-callback-path). |
| World-map buttons | `WorldMapButton.lua` corrects Krowi's `HasNoOverlay` flag on Forever. The library mistakes version `1.x` for the old Classic map and otherwise reparents Blizzard buttons to `ScrollContainer`, breaking parent `GetMapID`/`TriggerEvent` calls. Krowi's source is unchanged. |
| World-map geometry | HBD version 34 recognizes Forever as Classic map content and derives Era/Forever world transforms from native continent rectangles, with legacy fallback. See the measurements below. |

Prefer API capability checks in shared code. First-party code imports `QuestieCompat`; normal loading does not publish that module globally. On Forever, `QuestieCompat` supplies the missing `SetDesaturation` global for embedded AceGUI checkboxes. It no longer installs `GetSpellInfo`; the bundled spell widgets use their existing `C_Spell.GetSpellName` path. Shared compatibility still supplies missing pre-1.14 season/backdrop globals, and the tracker retains intentional legacy watch-function interception with restoration on disable. Some Forever legacy functions existed but failed internally, so presence alone was insufficient for watch count, aura, and mouse-over APIs.

Blizzard source used for the historical baseline: Gethe's `forever` branch, commit `4d5d706b8e01c5ebe01c8dd9b7a07151d8d37069`, subject `1.60.1 (69893)`. It matched the initial client but is older than the final observed build `69913`. Runtime checks remain the authority for availability.

## New-character round: Skyborne and Forever zones

A level 1 Alliance Mage, race 95 (`Skyborne` / High Order Skyborne), exposed:

```text
No AreaId found for UiMapId: 2521:Zephras Isle
```

The failure came from the object-tooltip update path. Native `C_Map.GetAreaInfo(16593)` confirmed Zephras Isle. The DBC support export for build `69893` supplied explicit map relationships and playable-race bits.

### Zone metadata

QuestieDB now owns these reviewed mappings under `support/Forever/Zones/`. Questie binds them through `LibQuestieDB.Support.Get("ZoneDB")`; `ZoneDB.Initialize()` decodes consumer-owned maps and validates them without modifying provider tables. The former `Database/Zones/data/Forever/zoneData.lua` consumer overlay is no longer loaded or retained.

| Zone | Area ID | Map ID |
| --- | --- | --- |
| Mount Hyjal | 616 | 2482 |
| Riverglades | 16591 | 2548 |
| Zephras Isle | 16593 | 2521 |
| Darkspear Islands | 16606 | 2524 |
| Shen'dralas | 16651 | 2652 |

The provider also contains all 65 parent relationships from the reviewed overlay. Existing area 2657 (Valley of Bones) belongs to Shen'dralas on Forever. Every original overlay row was checked against the source export; the handoff was independently compared against that overlay. These changes are scoped to the provider's Forever data, not its other flavors.

HBD already discovers these maps, including IDs above 2500. Zephras Isle and Darkspear Islands are separate instances (2991/2997) directly under Azeroth. Native world rectangles returned all zeroes; do not invent continent/world positions for them.

### Race masks

Skyborne race IDs 95/96 use playable-race bits 32/33, with masks `4294967296` and `8589934592`. `QuestiePlayer.Initialize()` now uses those documented masks on Forever instead of `2^(raceID-1)`. Arithmetic mask checks preserve the high bits.

Only for these races on Forever, exact legacy faction-wide masks `77`/`178` follow Alliance/Horde membership. Race-specific subsets still require the actual race bit; Human-only quests are not granted to Skyborne.

### Remaining limits

- Live Skyborne race/faction eligibility remains pending. The Tauren integration run confirmed area 16593, all five map lookups, and continent/world navigation, not behavior on a Skyborne character.
- The original DBC support export excludes quest/NPC/object payloads and spawn locations. Provider Forever data is now independent of Classic, but still lacks complete new Forever content; map metadata alone cannot supply quest pins.
- The old consumer compiler stored `requiredRaces` as `u32`; that compiler no longer exists here. Do not carry its schema limitation forward as a claim about QuestieDB. Verify high-bit entity masks and race-policy behavior through the provider's read/storage contracts before importing new records. The consumer retains its reviewed Skyborne and exact faction-wide-mask rules.

## Map navigation and coordinate validation

Before the provider migration, on build `69913`, tested five zones, both continents, and Azeroth using `WorldMapFrame:SetMapID()`, then returned to Elwynn. Screenshots were inspected at each step.

| View | Map ID | Visible Questie quest icons |
| --- | --- | --- |
| Elwynn Forest | 1429 | 32 |
| Westfall | 1436 | 1 |
| Dun Morogh | 1426 | 19 |
| Teldrassil | 1438 | 4 |
| The Barrens | 1413 | 0 |
| Eastern Kingdoms | 1415 | 52 |
| Kalimdor | 1414 | 6 |
| Azeroth | 947 | 58 |
| Return to Elwynn | 1429 | 32 |

Counts exclude minimap and townsfolk frames. The character was level 1 Alliance with unchanged availability filters. Sparse higher-level/Horde-zone icons are not evidence of missing map support. Navigation produced no Lua or printed Questie errors, but exposed a visual world-map displacement.

HBD selected Retail world transforms because Forever shares its project ID. For the same player position, Blizzard returned normalized world-map coordinates `(0.732438, 0.631989)` while HBD returned `(0.855365, 0.645588)`. The existing Classic constants produced `(0.732437, 0.631987)`.

HBD version 34 now recognizes Forever before Questie's client flags exist. Era and Forever independently derive Azeroth transforms from continent world bounds and `C_Map.GetMapRectOnMap(continent, 947)`:

- Divide continent width/height by the corresponding rectangle spans.
- Offset left/top by the rectangle minima multiplied by the derived width/height.
- Preserve valid edges outside `0..1`.
- Retain legacy bounds only when rectangles are missing or degenerate.
- Rebuild cached map data when upgrading from an older HBD version.

A live audit of three points on each of nine maps measured a maximum normalized error of `0.206976` before the fix and `7.46e-8` after a confirmed reload to version 34. Existing Classic constants differed from Forever's native rectangles by at most `2.74e-7`, consistent with rounding. Follow-up screenshots confirmed corrected pins on both continents and the world view, without Lua or printed Questie errors.

This validates geometry against Forever, not a live Era client. Era derives its own runtime values; focused tests use deliberately different geometry to verify that independence. Other expansion mapping policies remain unchanged.

## Historical per-character storage trial

A temporary Camelot-only trial moved all three variables to per-character storage. It wrote the character's file, but the next same-character reload still recompiled from a missing root. A full restart was not tested. Original files were backed up; no automatic migration was implemented.

The user requested reverting this trial. The manifest again declares `QuestieConfig` and `QuestieProfilerEnabled` account-wide, with only the legacy `QuestieConfigCharacter` per character. No SavedVariables files were changed during the revert. See the [investigation](saved-variables-investigation.md).

## Packaging and validation

`Questie-Camelot.toc` declares interface `16001`, `RequiredDeps: QuestieDB`, and Contract 2. It follows the current Classic file list, with `QuestieCompat` before embedded libraries and no separate Forever adapter or local entity/zone payloads. `LoadSavedVariablesFirst: 1` and the account/per-character declarations are preserved.

The manifest does not load the ignored `cli/forever/Capture.lua` recorder. Use local development tooling to inject diagnostics when needed; do not make tracked manifests depend on ignored files. Automated Questie release packaging still needs Camelot support. Provider Baked generation/localization and broader live acceptance remain separate work; generate in a disposable copy rather than silently changing the linked checkout's mode.

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
lua cli/validate-loader-usage.lua
QUESTIE_DB_PATH="$HOME/projects/Questie-clones/QuestieDB" busted test/QuestieDBMock.conformance.test.lua
```

Keep database-content differences separate from API migrations. Continue live checks of new-quest acceptance, objective progress, turn-in, and the new starting zones.
