# Forever remaining work

This is the single current work list, consolidated from the compatibility audit, temporary review notes, manual checklist, tooltip reference, development log, and hardening backlog. It contains only unfinished work. Older status lists in those documents are historical; use this document to decide what remains.

Baseline: checkout through `57df4c3ad`. No new gameplay validation accompanied this consolidation. **Pending validation** means no completed result is recorded here, not proof that nobody has tried the scenario elsewhere.

The first beta requires ordinary gameplay to work without errors on native Forever UI. Deferred refactors and exploratory tests are not automatically release blockers. A finding below is not necessarily a reproduced bug, and listing it does not authorize implementation or live testing.

## 1. Release verification and missing regression tests

Use the steps in [MANUAL_TESTS_REQUIRED.md](MANUAL_TESTS_REQUIRED.md). That file is currently local-only and Git-ignored; sharing it is tracked in section 7.

| Item | Status | Remaining check |
|---|---|---|
| Native Forever baseline | Pending validation | Run with Blizzard's normal UI, Questie, and QuestieDB, without ForeverClassicUI. Check normal login, quest log, settings, map, tracker, and objective counts. Record the actual build and addon revisions. |
| Tracking and tracker visibility | Pending combined-release validation | Track/untrack through the native log and Questie menu; repeat with automatic tracking on/off and tracker disable/enable. Check repeated additions, combat transitions, and unintended duplicate/missing trackers. See manual §2 and behavior work below. |
| Native Forever quest greetings | Partial: implementation present, live acceptance pending | Use a genuine quest-greeting NPC, ideally with available and accepted quests. Check correct icons on initial opening, reopening, acceptance/completion refreshes, and no incorrectly disappearing map markers. Gossip-only NPCs do not exercise this path. See manual §3 and commit `f2222741a`: native list-based availability, pooled/numbered button adapters, and both XML-bound and explicit rebuild hooks. Unresolved list entries must not cause negative availability broadcasts. |
| Mixed Classic greeting buttons | Missing automated test | Cover active and available numbered buttons together, including the correct list indices and completion icons. Current tests do not cover this combination. Target: `Modules/Quest/QuestgiverFrame.test.lua`. |
| Classic greeting display/rebuild | Missing automated test | Cover initial XML-bound OnShow and subsequent native rebuilds with numbered buttons, ensuring Questie's icons survive both. Pooled-button coverage does not establish the Classic layout. Same test file as above. |
| Ordinary quest progression | Pending release-candidate validation | Accept a non-first quest where possible, progress objectives, loot quest items, finish quests, and choose rewards manually. Compare native and Questie state. Manual §3. |
| Forever Object tooltip callbacks | Partial: implementation present, live acceptance pending | Check physical object hovers, leaving/re-entering, repeated hovers, clear/rebuild, stationary progress updates, primary/appended data, and stale/duplicate additions. Existing Classic checks do not establish this behavior on Forever. Manual §4; [tooltip test matrix](docs/forever-tooltips.md#open-questions-and-focused-tests). |
| Item/Unit tooltips and combat | Pending combined-release validation | Check creature, player, bag-item and linked-item tooltips before/during/after combat, including progress updates and repeated hovers. Capture the actual failing call before selecting a restriction workaround. Manual §4; [tooltip restrictions](docs/forever-tooltips.md#security-combat-and-restricted-data). |
| Quest-item buttons and map actions | Pending gameplay validation | Use physical clicks on suitable quest items. Check charges, range, cooldown, allowed combat use, tracker changes, and recovery after combat. Open objectives, finishers and quest details from the tracker. Manual §5. |
| Journey and item information | Pending gameplay validation | Check item names/icons/details and first-time loading, plus faction-tab selection for a watched reputation. Manual §6. |
| Automatic questing | Pending gameplay validation and workflow review | Check eligible acceptance/turn-in, modifier suppression, zero/one/multiple reward choices, and cancellation. Use only quests the tester intends to accept/finish. Manual §7; section 3 below. |
| Deletion warnings | Pending cancel-only validation | Check the expected quest-item warning, cancellation, then an unrelated item's dialog. Confirm text does not carry over and no item is deleted. This does not validate actual deletion. Manual §8. |
| Timed quests, party progress and reward displays | Pending when scenarios are available | Check Blizzard's timer with Questie enabled, shared progress/announcements, and XP/reputation tooltips with known bonus buffs. Manual §9. |
| Classic gameplay regression | Pending for the combined release | Run a short ordinary-questing, tracker, greeting and tooltip check on supported Classic clients. Read-only Era getter probes are not equivalent. |
| Skyborne eligibility and starting zones | Partial: rules/data present, live eligibility pending | Verify race-specific and faction-wide quest eligibility on a Skyborne character, plus new-zone navigation and supported quest content. Do not treat missing provider content as an API failure. [Development limits](docs/forever-development.md#remaining-limits). |
| Profession refresh | Not exhaustively live-validated | Observe normal profession acquisition/change and availability refresh where an agreed test scenario exists. Do not unlearn professions merely to test it. [Development boundaries](docs/forever-development.md#compatibility-boundaries). |
| Results and release limitations | Pending as checks run | Record pass/fail/skipped scenarios, build/revision, UI addons, combat state, and useful screenshots/stacks. Document incomplete Forever content and the known SavedVariables limitation without claiming they are fixed. Keep historical results in the development log; remove completed tasks from this list. |

## 2. Deferred simplification candidates

These are the remaining cleanup favorites and related opportunities. Preserve native returns, cache misses, event/hook behavior, and meaningful identity conversions. Do not replace every wrapper or introduce a generic compatibility framework.

| Item | Status | Next step and reference |
|---|---|---|
| Supported client/build floor | Decision required | Decide whether support means current Blizzard channels, all manifest versions, or additional historical/private clients. Confirm older Cata, Era and Mists coverage before removing fallbacks. Wiki snapshot versions are not policy; see the evidence baseline below. |
| Unnecessary local aliases | Deferred; removal not approved | Classify actual call paths before replacing aliases with direct Compat calls. **Keep useful hot-path aliases**, with a short comment identifying the hot path where helpful. Also preserve intentional function capture around hooks. Centralizing API selection is not permission to remove all aliases. |
| Container information converter | Proposed, not implemented | In `Modules/Tracker/LinePool/TrackerItemButton.lua`, read guarded `iconFileID`/`itemID` from `C_Container.GetContainerItemInfo`. In `Modules/Quest/QuestieQuest.lua`, use `C_Container.GetContainerItemID`. Preserve empty-slot behavior, bag ranges and equipped-item fallback, then remove the eleven-value converter if the build floor permits. |
| Thin item/addon/date/completion fallbacks | Conditional on build floor | Consider direct APIs for item information/icons/counts, bag slot counts, item spell/equippability/range, addon loading/metadata, completed-quest flags and daily reset. Calendar fallback fabricates midnight, while `Database/Corrections/Holidays/QuestieEvent.lua` uses hours/minutes. Preserve missing-API diagnostics in `Modules/VersionCheckDB.lua` and `Database/SupportValidation.lua`, item cache misses, nil range results, charge counting, and both addon loading flags. |
| Presentation fallbacks | Conditional on build floor and loading | Review old resize implementations, including `Modules/Profiler/QuestieProfilerUI.lua`; mouse-over globals; chat-filter naming fallbacks; numbered popups and the legacy resize helper in `Modules/EventHandler/QuestEventHandler.lua`; tooltip-backdrop shim; and `QuestTimerFrame or WatchFrame` in `Modules/Tracker/TrackerQuestTimers.lua`. Preserve top/bottom/left/right offset order, optional bounds and chat retries. The profiler tolerates individually missing resize methods; Compat's old path errors, so they are not interchangeable on partial environments. |
| Gossip selection by quest ID | Proposed, not implemented | `Modules/Auto/AutoQuesting.lua` is the consumer of Compat's index-based selectors. Pass `quest.questID` to `C_GossipInfo.SelectAvailableQuest`/`SelectActiveQuest` instead of fetching lists again. Review old tuple/count fallbacks and numbered gossip UI in `Modules/Quest/QuestgiverFrame.lua` against the floor. Keep `GetActiveQuests` enrichment: native false/nil can become complete through `QuestieDB.IsComplete`. Greeting and automation policy are separate. |
| Watched-faction lookup | Proposed, not implemented | In `Modules/Journey/tabs/QuestsByFaction/QuestsByFactionsTab.lua`, consider `C_Reputation.GetWatchedFactionData` instead of expanding/scanning all headers. Preserve nil/zero and the current exclusion of header factions; deliberately decide to remove the native header-expansion side effect. |
| Seasons and trivial-range fallbacks | Insufficient evidence for removal | Establish native Forever seasons support without mistaking Questie's installed shim for a native API. Classic source still uses `GetQuestGreenRange`; Forever uses `UnitQuestTrivialLevelRange("player")`. Establish cross-client support before removing either boundary in `Modules/QuestieCompat.lua`; consumers include VersionCheck, QuestieDB, QuestieLib and AvailableQuests. |
| Profession enumeration simplification | Deferred; equivalence unproven | In `Modules/QuestieProfessions.lua` and `Modules/EventHandler/EventHandler.lua`, establish Riding/skill-ID coverage, sparse secondary-profession handling, and learn/unlearn event behavior before replacing skill-line enumeration. |
| Ace3 update and desaturation shim | Waiting on upstream; GitHub issue open | Update embedded Ace3 when a Forever-supporting release is available. Review/remove `QuestieCompat.SetDesaturation` and its global installation once updated widgets no longer need them, with tests/docs updated. Keep the current library and shim until then. [Questie #7864](https://github.com/Questie/Questie/issues/7864) is the upstream-follow-up record. |

## 3. Open contract and lifecycle findings

Do not treat API existence, a passing mock, or an out-of-combat probe as proof of contract equivalence or combat safety.

### Small contract questions

| Item | Status | Next step and reference |
|---|---|---|
| Cooldown enabled flag | Open latent mismatch | `C_Item.GetItemCooldown` returns a boolean while `Modules/Tracker/LinePool/TrackerItemButton.lua` expects numeric `1`. Current container-first selection avoids that fallback on inspected builds. Normalize it or establish a floor permitting only the container API. Forever declarations: `ContainerDocumentation.lua:337–352` versus `ItemDocumentation.lua:434–448`. |
| `ExpandFactionHeader(0)` | Unverified modern contract | Callers in `Modules/QuestieReputation.lua` and Journey's faction tab use zero to expand all headers. Determine whether modern `ExpandFactionHeader` preserves that convention or adapt explicitly to `ExpandAllFactionHeaders`. Forever `ReputationInfoDocumentation.lua:33–45` declares them separately. |
| Action-status force-show argument | Open argument loss | Compat drops the second argument supplied by `Modules/Tracker/LinePool/TrackerMenu.lua`. Preserve it if retaining the native status helper: Classic `Blizzard_UIParent/Classic/WorldFrame.lua:105–112` uses it to bypass `showNewbieTips`. |
| XP spell-known query | Open semantic choice | `Database/QuestXP/QuestieXP.lua` uses legacy `IsSpellKnown` for Fast Track (78632). Blizzard's `Blizzard_DeprecatedSpellBook/Deprecated_SpellBook.lua:11–26` maps that to `C_SpellBook.IsSpellInSpellBook`, but maps `IsPlayerSpell` to `C_SpellBook.IsSpellKnown`. Choose exact spellbook membership or Questie's broader Compat check deliberately. This consumer runs for WotLK+ content, not Forever's Era content. |
| Watch-redraw selection | Unresolved precedence | `Modules/Tracker/QuestieTracker.lua` and `Modules/QuestLinks/Hooks.lua` prefer `QuestWatch_Update`; Compat prefers `WatchFrame_Update`. Choose behavior before consolidating, especially when another UI addon exposes both. |
| Mouse focus | Open consumer assumption | Preserve first-element extraction from `GetMouseFoci`; account for an empty list or unnamed frame before `GetName`/text matching in `Modules/Tracker/QuestieTracker.lua`. |
| Quest-link capability selection | Insufficient replacement evidence | `Modules/QuestLinks/Link.lua` checks global `GetQuestLink` before calling Compat, whose namespaced probe is not established by inspected declarations. Native Forever UI still calls the global. Retain the consumer's Questie-link fallback: Compat itself errors if neither API exists. |
| Map-scale capability guard | Still present; not corrected | `QuestieMap.GetScaleValue` checks `C_Map.GetAreaInfo` but calls `GetMapInfo`. Check the actual capability and handle a missing map record. Original investigator finding; `Modules/Map/QuestieMap.lua:234–248`. |
| Quest-specific timer detection | Behavioral question, not changed | Acceptance checks for any numeric timer although the Forever wrapper ignores the supplied quest ID. Decide whether this should identify the accepted quest specifically; do not hide that change inside an API rename. Original investigator finding; `Modules/EventHandler/QuestEventHandler.lua` and `QuestieCompat.GetQuestTimers`. |

### Watch ownership and timers

**Status: deferred refactor with open validation questions.** Consumers: `Modules/Tracker/QuestieTracker.lua`, `TrackerUtils.lua`, `TrackerQuestTimers.lua`, and the watch/timer adapters in `Modules/QuestieCompat.lua`.

- Separate Questie's own count/state queries from native watch globals before considering removal of Forever interception. `TrackerUtils` uses synthetic `GetNumQuestWatches(true)` and `IsQuestWatched`; ordinary callers of the intercepted count receive zero. Compat's modern count ignores the private argument, so it is not a substitute.
- Preserve native watches, repeated-add idempotency, manual untracking, index/ID conversion, and combat-deferred visibility. Do not simply delete hook assignments.
- Define teardown ownership: restoring a captured global can overwrite another addon's later replacement. Inter-addon behavior remains unverified.
- Resolve conflicting progression-Classic evidence: loaded Mists `Blizzard_UIPanels_Game/Wrath/QuestMapFrame.lua:207–208` uses namespaced watches, but generated declarations do not confirm them and Questie's namespace hooks are Forever-only. Check the real call path before generalizing the Forever behavior. Modern watch type 0 is valid; test absence with nil, not truthiness of the enum.
- Observe a timed quest with Blizzard timers enabled. Forever's `Blizzard_QuestTimer/Mainline/Blizzard_QuestTimer.xml:3` parents the timer to the objective tracker, so showing it cannot overcome a hidden parent. Keep timer record-to-varargs conversion and legacy selection restoration unless consumers migrate together.

### Deletion popup ownership

**Status: open investigation, not a proven universal combat failure.** Consumer: `Modules/EventHandler/QuestEventHandler.lua`. Forever `Blizzard_StaticPopup_Game/GameDialogDefs.lua:1552–1574` describes native deletion and cancellation paths.

- Match the actual deletion dialog/item rather than relying only on a shared text argument; assess writes to Blizzard-owned text and resizing.
- Check cancellation, dialog reuse, sequential quest/non-quest items, and whether `deletedQuestItem` still identifies a relevant deletion.
- Account for native `C_Item.DeleteItem(itemGUID)` as well as `DeleteCursorItem`; the current hook covers only the latter.
- Preserve explicit user confirmation. Cancel live test dialogs unless deletion of a disposable item is separately approved. Never queue or automate deletion as a workaround.

### Aura-dependent rewards and secure UI

**Status: conservative reward-buff fallback implemented, live validation pending; secure UI questions remain open.** Consumers: `Modules/QuestieReputation.lua`, `Database/QuestXP/QuestieXP.lua`, `Modules/Tracker/LinePool/TrackerItemButton.lua`, and `Modules/Tracker/TrackerUtils.lua`. See [tooltip restrictions](docs/forever-tooltips.md#security-combat-and-restricted-data).

- Validate reward estimates before/during/after combat. Each reward-buff calculation returns zero bonus (or false for the money-buff check) before reading auras during Forever combat. The original `QuestieCompat.UnitAura` loops remain; there is no shared search helper, cache, new error handling, or forced tooltip refresh. Classic/SoD combat calculations are unchanged.
- Check accepted estimate limitations: Forever combat displays omit temporary aura bonuses, not base rewards, racial bonuses or other non-aura modifiers. Actual rewards and quest eligibility are unchanged. Non-combat aura restrictions remain unresolved; see [Questie #7868](https://github.com/Questie/Questie/issues/7868). This combat guard does not establish general aura access or tooltip safety.
- Audit every path configuring/reusing/hiding secure item buttons, including option changes, depletion and disable/enable. Queued work must recheck combat and current state when it executes.
- Check range/count/charge/cooldown indicators independently of the secure item action. Physical clicks are required to validate hardware actions.
- Establish the supported map-opening path per client. Raw `WorldMapFrame:Show()` is not equivalent to `HandleUserActionOpenSelf`/`ShowUIPanel`; preserve always-open rather than toggle behavior. Inconsistent combat guards alone do not prove a forbidden action.

### Automatic questing workflow

**Status: API names inspected; complete event-driven behavior remains unvalidated.** Sources: `Modules/Auto/AutoQuesting.lua`, event registration in `Modules/EventHandler/EventHandler.lua`, and manual §7.

- Keep gossip IDs, greeting indices, quest-log indices and quest IDs distinct. Verify list changes and missing provider records cannot select the wrong quest.
- Establish the interaction owner: `target`, `questnpc`, and a quest sharer are not automatically the same entity.
- Review confirmation events, which currently check less policy than other handlers. Preserve modifier suppression and NPC/quest/trivial/repeatable/PvP exclusions where intended.
- Test zero/one/multiple reward choices, inventory/reward failure, repeated events, cancellation, and delayed resets crossing into a new interaction.
- Establish combat/hardware restrictions through ordinary interactions. Do not replay blocked accept/turn-in/reward actions later against potentially changed quest identity.
- Verify supported alternate quest-dialog addons separately from the native-UI baseline.

### Other lifecycle/dependency questions

| Item | Status | Next step and reference |
|---|---|---|
| Chat-filter retry after disabling | Unverified pre-existing concern | A delayed add retry could re-register a disabled ShutUp filter. Check cancellation/current-setting ownership without changing error propagation blindly. Consumer: `Modules/QuestieShutUp.lua`; registration delegates to `QuestieCompat.AddMessageEventFilter`. |
| Embedded dropdown mouse fallback | Old-client dependency concern | Its locally named `GetMouseFocus` fallback appears self-recursive when `GetMouseFoci` is absent. Check supported old-client exposure before an upstream fix. Original investigator finding; `Libs/LibUIDropDownMenu/LibUIDropDownMenu.lua:126–130`. |
| AceComm addon-prefix fallback | Low-priority upstream cleanup candidate | Review old `RegisterAddonMessagePrefix` selection against the library's other modern dependencies. Do not fork embedded code solely to remove this fallback. Original investigator finding; `Libs/AceComm-3.0/AceComm-3.0.lua:64–68`. |

## 4. Future tooltip work and exploratory checks

These are separate from the release checks in section 1. Do not reopen the Object implementation or change public tooltip/Comms contracts without a concrete need. Sources: [remaining tooltip work](docs/forever-tooltips.md#remaining-migration-and-validation) and [test matrix](docs/forever-tooltips.md#open-questions-and-focused-tests).

| Item | Status | Remaining work |
|---|---|---|
| Structured Unit/Item identity | Future proposal | Use accessible callback GUID/ID fields instead of re-reading mutable frame/token/link state. Preserve absent/restricted-data behavior, quest-start logic and provider/party enrichment. |
| Unit/Item duplicate handling | Future work | Evaluate remaining FontString/count-based detection. Verify rebuilds, appended blocks, hidden/reused frames and rapid entity changes before extending the Object approach. |
| Native versus Questie quest lines | Policy decision | Decide whether to retain both or avoid duplicate native content without losing drop rates, party attribution, settings or quest markers. |
| Multiple quests and party context | Pending targeted tests | Verify line association without assuming positional objective identity, and distinguish native party data from Questie's additions. |
| Eligible tooltip frames | Pending targeted tests | Check bag/link/comparison/Journey tooltips and ensure scanning or unrelated frames are not augmented accidentally. |
| Item query/cache equivalence | Pending evidence | Compare ID, hyperlink and bag-slot contexts, including cold-cache completion and rendered layout readiness. Do not remove Journey's scanning tooltip based on warm-cache results. |
| Object identity and localization | Pending broader evidence | Check interactable categories, same-name objects and non-English clients. Keep provider name/zone resolution where payloads lack stable identity. |
| Restricted data and deferred callbacks | Pending evidence before design | Reproduce actual failures through ordinary addon callbacks. If deferral is needed, recheck entity identity, not just frame visibility. Do not blanket-disable all combat enrichment. |
| Additional tooltip coverage | Optional research | Achievement, quest, party-progress, aura and other types; failed/completed/timed quests; PvP-restricted units; settings combinations and other client flavors. Enum presence alone does not establish a usable scenario. |
| Performance measurement | Optional research | Measure real update cost rather than inferring CPU improvement from callback counts. |

## 5. Broader resilience proposals

These are deferred design work, not implemented recovery guarantees. Detailed rationale remains in [docs/forever-hardening-backlog.md](docs/forever-hardening-backlog.md).

| Item | Status | Remaining work |
|---|---|---|
| Unknown-zone recovery | Future proposal | Provide a non-throwing runtime lookup while retaining strict validation. Handle missing map records, skip only unsupported enrichment/placement, retry appropriately and report once. Do not substitute area 0 or guess by ambiguous names. |
| Missing quest/entity data | Known coverage gap; recovery proposal | Distinguish missing provider records from cache misses and unavailable quests. Retain reliable native title/progress where dependencies allow, without inventing spawns, rewards or prerequisites. Keep other quests working. |
| Optional initialization isolation | Future hardening | Prevent optional hooks/UI failures from leaving core data or modules half-initialized. Track partial feature availability and leave Blizzard's tracker usable if Questie's tracker fails. Do not indiscriminately catch every startup error. |
| Quest-event recovery | Future hardening | Validate event identities, avoid half-written state, make optional timer failures nonfatal, and reconcile retryable failures without duplicate announcements, sounds or breadcrumb actions. |
| Unknown client/race metadata | General policy deferred | Diagnose unsupported identity without silently defaulting to Era/Human or broadening faction eligibility. Keep race IDs separate from playable-race bits and preserve reliable active-quest information. |
| Independent optional tooltip details | Future resilience work | Preserve title/objectives when optional reward enrichment fails. Keep errors diagnosable and avoid presenting guessed values as exact. Overlaps the aura policy in section 3. |
| Unsupported geometry and UI layouts | Partial safeguards; broader validation deferred | Omit unsupported world placement rather than fabricating coordinates. Validate transforms and optional UI parent/method assumptions; retain supported zone/minimap behavior. |
| Provider storage/import safeguards | Verification pending | Check high-bit race masks against actual Source/Baked/read/correction contracts before importing new records. Preserve usable data and never truncate bits or widen only one side of a format. Do not carry the removed consumer compiler's limitation forward as a provider claim. |
| Support-gap reporting | Future proposal | Show bounded, deduplicated notices describing what is unavailable and what is verified to work. Retain the first useful diagnostic and counts without collecting unrelated player/chat data or hiding unexpected errors. |

## 6. Provider, upstream and parked work

| Item | Status | Reference/next step |
|---|---|---|
| New Forever quest/NPC/object/spawn content | Known incomplete provider coverage | Map/race metadata alone cannot supply quest pins. Keep this separate from API defects and disclose limitations. [Development limits](docs/forever-development.md#remaining-limits). |
| Zone-parent exporter handoff | Deferred provider/exporter work | Replace temporary reviewed relationships only when the reviewed exporter output supplies them. Preserve existing relationships; do not regenerate over the protected handoff or alter the linked provider casually. [Integration status](docs/forever-development.md#current-integration-status). |
| Provider Baked/localization coverage | Separate validation work | Consumer tests and earlier Source-mode runs do not establish complete Baked behavior/content. Generate/test in an agreed disposable copy, not the linked checkout. [Packaging/validation notes](docs/forever-development.md#packaging-and-validation). |
| Camelot release packaging | Handled in other branches | Outside this workstream; completion elsewhere has not been verified here. Coordinate rather than starting a duplicate change. |
| SavedVariables cold-start issue | Known beta-client limitation; parked | Record limitations. No new persistence workaround is approved; reload-only success is insufficient. [SavedVariables investigation](docs/saved-variables-investigation.md). |
| Reported 5% XP cooking buff | Unidentified, nonblocking follow-up | Identify food/buff name and spell ID; determine quest XP versus kill XP applicability before adding a multiplier. A missing displayed bonus alone does not prove aura access failed. Originally recorded in local `MEMORY.md`. |

## 7. Documentation and handoff cleanup

| Item | Status | Next step |
|---|---|---|
| Share the manual checklist | Pending | `MANUAL_TESTS_REQUIRED.md` is Git-ignored. Decide how to distribute it, preferably as a tracked teammate-facing guide. This consolidation does not change local excludes or stage it. |
| Retire competing status lists | Pending | Keep development/tooltip material as evidence, not independent backlogs. Add pointers to this work list and retire temporary `MEMORY.md` after preserving any useful rationale. Do not delete evidence or claim old observations establish current validation. |
| Old greeting patch | Local caution | Ignored `forever-quest-greeting.patch` contains the older tracer-inclusive snapshot. Do not reapply it blindly or ship its diagnostics. Any cleanup/removal of the patch is a separate decision. |

## Evidence baseline for unfinished compatibility work

The [saved API availability reference](docs/classic-api-availability.md) records Wiki revision `6802278`: Era 1.15.9 (69109), Anniversary 2.5.6 (69110), progression Classic 5.5.4 (69155), and Retail 12.1.0 (69189). It has no Forever column. Blank cells and absent rows are not negative evidence.

The audit inspected these cached Blizzard sources without refreshing them. They are evidence snapshots, not minimum supported builds or guarantees about the currently installed client:

| Branch | Commit | Version/build |
|---|---|---|
| `classic_era` | `33e177d9bf38d76d5c6c6e05d5da78db1899659a` | 1.15.9 / 69722 |
| `classic_anniversary` | `1463c686270b6c64e2c5c228f447c4597c0f8ba6` | 2.5.6 / 69795 |
| `classic` | `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` | 5.5.4 / 69585 |
| `classic_titan` | `84ef503f0d2617494db84cc9c7e7b530e976f6e7` | 3.80.2 / 69874 |
| `forever` | `70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e` | 1.60.1 / 69913 |

Resolve Blizzard paths against `https://github.com/Gethe/wow-ui-source/blob/<commit>/Interface/AddOns/`; unqualified declaration filenames are under `Blizzard_APIDocumentationGenerated/`. Inspect the relevant loaded UI path too, rather than treating declarations as runtime proof.

Manifests at the audit baseline included Era `11508,11509`, BCC `20506`, WotLK/Titan `38002`, Cata `40402`, Mists `50503,50504`, and Forever `16001`. Those declarations do not by themselves settle minimum support. Matching historical Cata/Era/Mists validation and external UI/widget overrides remain outside the evidence gathered. The original detailed audit and completed-work history remain available in Git history through `57df4c3ad`.

Additional source locations supporting remaining decisions:

- Container records and empty slots: Classic `ContainerDocumentation.lua:139–170`, Forever `:175–208`. Consumers need record fields, not a function-name substitution.
- Gossip IDs versus indices: Classic `GossipInfoDocumentation.lua:154–171`, Forever `:177–195`; loaded buttons store `questInfo.questID`.
- Watched faction: Classic `ReputationInfoDocumentation.lua:40–47`; Forever's loaded `Blizzard_StatusTrackingBar/Shared/ReputationBar.lua:51–55,77–81` handles nil and faction ID zero.
- Presentation: Classic's loaded `Blizzard_UIParent/Shared/UIParent.lua:530–532` forwards mouse offsets in top/bottom/left/right order; `SimpleFrameAPIDocumentation.lua:1252–1263` declares modern resize bounds. The inspected Classic/Era/Anniversary branches already contain modern chat and popup helpers; expansion labels alone are not reliable cutoffs.
- Aura access: Forever `UnitAuraDocumentation.lua:207–223` declares access requirements and potentially secret results. Map opening: `Blizzard_WorldMap/QuestLogOwnerMixin.lua:101–107` calls `ShowUIPanel`, not just frame `Show`.

## Working rules

- Keep meaningful quest/faction/aura/stable return conversions, native/Questie watch distinctions, load-order guards and data-quality fallbacks unless their actual consumers are deliberately adapted. Preserve quest IDs versus indices, nil/zero/failed sentinels, abandonment item-name formatting and selection restoration. Legacy UI selection and plain native selection have different side effects.
- Keep item-cache and nil-result semantics. `C_Item.GetItemIconByID` accepts item identifiers; `C_Item.GetItemIcon` takes an ItemLocation. `GetNumQuestWatches(true)` is private Questie policy, not native watch state. Stable-food arrays cannot replace varargs without adapting the caller. `SetCVar` also performs conversions that a direct native call may not preserve.
- Blank reference cells are not proof of API absence. A modern namespace or Retail project ID does not prove Forever contracts or restrictions.
- Preserve Classic behavior and unrelated changes. No live client, installation, provider, character or settings changes without an agreed test scope. Use test characters, physical clicks where required, and restore temporary settings.
- No destructive inventory tests, quest abandonment, profession unlearning, or persistence workarounds merely to exercise a path.
- Keep current status here. Link evidence and detailed test instructions rather than maintaining another overlapping work list. Remove finished entries; keep their results in commit history or the development log.
