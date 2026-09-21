# Legacy WoW API and compatibility audit

## Audit result

**The highest-confidence simplification is removing duplicated API selection, not deleting QuestieCompat wholesale.** Several wrappers preserve essential contracts; others merely forward calls and can disappear once the supported-build floor is explicit.

Seven API-family investigations and a separate skeptical review completed the original read-only audit. Implementation and additional validation followed in separate sessions. The status below records the completed follow-up, including the greeting fix in `f2222741a` and API-selection cleanup; remaining proposals still require review before implementation.

## Priorities and current status

### Favorites for the first Forever release

These are the preferred cleanup candidates, not a requirement to finish every refactor before release.

| Priority | Candidate | Status and next decision |
|---|---|---|
| 1 | Remove unused compatibility surface and dead checks | **Implemented.** The three unused wrappers, Journey wrapper-presence checks, QuestFinisher fallback, and unused Announce chat-filter alias are removed. See the completed work below. |
| 2 | Make item API usage consistent | **Partly implemented.** Eleven item selectors now use Compat without repeating its API choice. Local aliases and the existing fallbacks remain. Migrating the two container-info consumers to records/item IDs, then deleting their tuple adapter, is still proposed (§4.1). Direct-native calls and fallback deletion need a supported-build decision. |
| 3 | Remove historical presentation branches | **Deferred pending supported-build evidence.** Candidates are resize, mouse-over, chat-filter, numbered-popup, and tooltip-backdrop fallbacks (§3.2). Do not combine this with popup ownership or combat-policy changes. |
| 4 | Simplify gossip selection around quest IDs | **Not implemented.** Use IDs from the records AutoQuesting already inspected; then remove redundant list fetches and eligible historical paths (§4.3). Preserve completion enrichment and keep acceptance/reward workflow changes separate. |
| 5 | Remove the unnecessary spell bridge if confirmed | **Implemented locally.** Removed `QuestieCompat.GetSpellInfo` and its Forever global shim. Bundled AceGUI spell widgets already prefer `C_Spell.GetSpellName` on the inspected Forever build. The library version and required desaturation shim are unchanged. |

**API selection centralized:** all 11 remaining consumer selectors for `IsAddOnLoaded`, `GetItemSpell`, `IsEquippableItem`, and chat filter add/remove now use Compat. Its five new functions retain modern-first selection, legacy fallbacks, native return values, and error propagation. Existing local aliases and consumer chat initialization retries remain unchanged. Removing unnecessary aliases is a separate, still-deferred step.

Compatibility selection and local caching are separate decisions. **Keep useful hot-path aliases.** Add a short nearby comment naming the actual reason, such as a per-frame item-button update, when that explains why an alias remains. Also preserve intentional function capture around hooks. Do not remove every local alias or introduce a generic compatibility framework.

**Keep outside the mechanical cleanup:** watch-global interception/teardown, aura restrictions, popup cancellation/deletion ownership, profession enumeration, and tooltip/cache timing. They need behavior-focused work and validation, not name replacement. Manual Forever checks remain necessary regardless of how much cleanup ships.

### Completed work

| Commit | Change | Scope |
|---|---|---|
| `16d1231d3` | Removed unused `QuestieCompat.AddQuestWatch`, `GetNumTrackedAchievements`, and `CollapseFactionHeader` | No replacement functions were needed: there were no production callers. Native watch hooks, `AQW_Insert`, and the tracker's separate achievement-count global remain. Tests of surviving contracts were retained. |
| `8afca4893` | Removed duplicated consumer selection and dead checks | Eleven item aliases and QuestieLib metadata now use Compat directly. Removed QuestFinisher's unreachable alternative, Journey's dead wrapper checks, and Announce's unused remove-filter alias. Historical fallbacks remain. |
| `3074adaf4` | Clarified compatibility comments and fixed quest-title return slot 10 | Purpose-first function comments, localized explanations of meaningful differences, corrected annotations/links, and removal of implicit `---@return nil` annotations. Modern `GetQuestLogTitle` now returns `GetCVarBool("displayQuestID")` in slot 10 instead of repeating the quest ID. Slots 11–17 were not shifted. Two focused tests cover the display-ID setting. |

The first cleanup reduced production code by 48 lines. Local aliases were deliberately retained in that pass; further alias cleanup is still a discussion item.

**Master-history check:** neither cached `origin/master` at `180c8cb13` nor shared ancestor `bd177929e` contained the three removed Compat wrappers. They entered this branch in `9c5e723c7` without production callers. Earlier Forever work did install an `AddQuestWatch` global shim; that arrangement had already changed during integration. The deletion did not remove an active master call path. External addons importing undocumented Compat methods were not ruled out.

### Findings from the later function-by-function review

The follow-up reviewed 65 functions individually. Its comment changes and confirmed runtime correction are in `3074adaf4`.

| Finding | Disposition |
|---|---|
| Modern quest-title slot 10 contained a duplicate quest ID rather than the display-ID boolean | **Fixed** in `3074adaf4`, with enabled/disabled-setting tests. This is an addition to the original audit's quest-title analysis (§5.1). |
| `GetItemIcon` might be selecting the wrong modern function | **Resolved: keep `C_Item.GetItemIconByID`.** It accepts the item identifiers used by callers; no caller migration was needed. |
| Reputation tuple slot 16 might need a different field | **Resolved: retain `canSetInactive`.** Evidence did not justify changing it based on older `canBeLFGBonus` terminology. |
| `C_Item.GetItemCooldown` boolean versus the consumer's numeric enabled flag | **Still open** (§4.2). Comments clarify the difference; runtime behavior was not fixed. |
| Modern `ExpandFactionHeader(0)` versus the legacy expand-all convention | **Still open** (§4.5). Do not infer equivalent zero handling from the function name. |
| Spell bridge does not preserve the legacy spellbook-slot/bank overload | **Removed with the unused wrapper.** Questie no longer supplies global `GetSpellInfo`. Bundled AceGUI uses its existing modern path on Forever and retains its native legacy fallback for other clients. |
| `ActionStatus_DisplayMessage` wrapper drops its caller's second argument | **Still open** (§4.8). No runtime correction yet. |

### Review of the five new API-selection functions

Each new function received a separate source-backed investigation after centralization: `GetItemSpell`, `IsEquippableItem`, `IsAddOnLoaded`, `AddMessageEventFilter`, and `RemoveMessageEventFilter`. Investigators checked consumers, the five cached Blizzard baselines listed below, and immutable online source copies. No dispatch correction was indicated; this was not live-client validation or a new minimum-support decision.

- Item-spell results preserve both values and the no-values case. Equippability is not a query for whether the item is currently equipped. See Forever [ItemDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua), lines 970–984 and 1324–1336.
- Addon-load results distinguish loaded-or-loading from completed loading. The comment now identifies folder names/list indices and the second result's `ADDON_LOADED` meaning. See Forever [AddOnsDocumentation.lua:322–335](https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua#L322-L335) and [EventUtil.lua:67–75](https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_SharedXML/EventUtil.lua#L67-L75).
- Chat comments now describe callback arguments, hide/rewrite behavior, and removal using the original callback object for the same event. Registration/removal errors remain visible to consumers. See Forever [ChatFrameFilters.lua:96–170](https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_ChatFrameBase/Shared/ChatFrameFilters.lua#L96-L170).
- Consumer retry comments no longer claim that every `CreateSecureFiltersArray` error proves the namespace is not ready. Retry behavior is unchanged. A pre-existing delayed-add retry could re-register a ShutUp filter after it is disabled; this remains an unverified lifecycle concern for separate work, not a defect introduced by centralization.

### Validation recorded so far

- Spell-shim removal: **2,003 tests passed**, lint and loader checks passed. Removed the obsolete spell-bridge test and retained desaturation startup coverage. No library update or live-client validation was performed; external widget overrides remain outside this check.
- API-selection cleanup: **2,004 tests passed**, lint and loader checks passed, and focused review found no actionable issues. No live-client validation was performed. This preserves the local aliases and does not remove historical fallbacks.
- First cleanup: **1,964 tests passed**, lint and loader checks passed, and focused review found no actionable issues. No live client was touched for that cleanup.
- Comment/quest-title follow-up: **1,966 tests passed**, lint and loader checks passed, and reviewer assessment completed.
- Read-only Era checks used **1.15.9, build 69722**. They covered item icons/counts/cooldowns, the 18-field item-information tuple, reputation getters, quest selection/counts/IDs, and native versus Questie watch counts. No new live errors, reloads, or character/UI/tracking/settings changes were recorded.
- Those Era results do **not** establish Forever restrictions, full Forever workflow correctness, or historical client support. The modern quest-title correction has focused automated coverage; the Era checks are not proof of that modern branch in live Forever.
- Use [MANUAL_TESTS_REQUIRED.md](MANUAL_TESTS_REQUIRED.md) for teammate-facing checks. Existing tooltip evidence and outstanding cases remain in [docs/forever-tooltips.md](docs/forever-tooltips.md); this cleanup does not reopen the Object migration.

### Greeting fix committed; live verification pending

The numbered-frame incompatibility in §4.4 is addressed in `f2222741a` (`[fix] Support native Forever quest greetings`). Recorded live verification remains pending:

- `AvailableQuests` reads the native active/available greeting lists, not rendered frames. Unresolved entries prevent negative availability broadcasts and leave the NPC retryable; known positive entries can still be restored.
- `QuestieCompat` resolves native greeting IDs with Classic title lookup as a fallback, and visits pooled Forever or numbered Classic buttons without creating frames.
- `QuestgiverFrame` decorates after both the XML-bound OnShow script and explicit Blizzard rebuild calls. Stale button indices are skipped until the native list is rebuilt.
- Runtime source and manifests contain no explicit ForeverClassicUI dependency. Earlier live tests did have that separate addon enabled; those observations are not a native-UI acceptance test. Native Blizzard UI is the baseline, and the [manual checklist](MANUAL_TESTS_REQUIRED.md) now states that explicitly.
- Source comparison used cached Forever `70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e` (69913) and Era `33e177d9bf38d76d5c6c6e05d5da78db1899659a` (69722). Relevant Blizzard files are `Blizzard_UIPanels_Game/Mainline/QuestFrame.lua:304–410`, `Mainline/QuestFrame.xml:279–280`, and the Classic equivalents.
- Validation: **1,984 tests passed**, lint and loader checks passed. Review caught and corrected the distinction between XML-bound OnShow and global-function hooks; the final focused review found no further issue. No client interaction, installation changes, or provider changes accompanied implementation. The temporary chat tracer and its two tests were removed before committing; the actual regression tests remain.

Further discussion notes are in [MEMORY.md](MEMORY.md). Broader behavior work remains in [FOREVER_WORK_LEFT_TO_DO.md](FOREVER_WORK_LEFT_TO_DO.md).

## Original audit snapshot

Sections 1–7 below preserve the original findings, evidence, recommendations, and line references. Statements about unimplemented changes or unperformed tests there describe the audit at that time. Use the status above for subsequent work; old line numbers may no longer match current files.

## 1. Safe simplification candidates

### 1.1 Remove duplicate item API selection in consumers

The consumers and wrappers choose the same modern functions:

| Consumer expression | Existing boundary |
|---|---|
| `C_Item.GetItemInfo or QuestieCompat.GetItemInfo` | `Modules/QuestieCompat.lua:500–507` |
| `C_Item.GetItemIconByID or QuestieCompat.GetItemIcon` | `Modules/QuestieCompat.lua:643–650` |
| `C_Item.GetItemCount or QuestieCompat.GetItemCount` | `Modules/QuestieCompat.lua:630–637` |

**Recommendation:** Alias the corresponding Compat function directly while retaining its fallback. If the eventual support policy guarantees the modern API, instead migrate directly and remove the wrapper together.

**Affected selectors and calls:**

| API | File: selector; calls |
|---|---|
| Item information | `Modules/Network/QuestieCommsData.lua:14;84` |
| | `Modules/QuestieAnnounce.lua:15;131,150` |
| | `Modules/QuestieDebugOffer.lua:25;309` |
| | `Modules/EventHandler/QuestEventHandler.lua:54;105,112` |
| | `Modules/Journey/QuestieJourneyUtils.lua:16;153,163,174` |
| | `Modules/Journey/QuestieSearchResults.lua:44;675` |
| | `Modules/Tracker/QuestieTracker.lua:58;444` |
| Item icon | `Modules/Journey/QuestieJourneyUtils.lua:17;159` |
| Item count | `Modules/Tracker/TrackerUtils.lua:44;1028,1033,1039` |
| | `Modules/Tracker/QuestieTracker.lua:96;455,458` |
| | `Modules/Tracker/LinePool/TrackerItemButton.lua:17;67,135` |

**Evidence:** `docs/classic-api-availability.md:5807,5814,5818` marks these APIs across all snapshot clients. All five inspected Blizzard branches declare them.

**Contracts preserved:** Item information remains a tuple and can be uncached; count arguments, including charge/use counting, remain unchanged. `GetItemIconByID` accepts these item identifiers. **`C_Item.GetItemIcon` is not the interchangeable replacement: it takes an ItemLocation.**

**Confidence:** High. One qualification: current aliases capture native functions at load time; wrappers resolve them at call time and add dispatch overhead. No relevant first-party replacement was found. This is simplification, not a claimed performance improvement.

### 1.2 Remove other demonstrably redundant selectors and checks

| Location | Recommendation | Why safe |
|---|---|---|
| `Modules/Quest/QuestFinisher.lua:21`, call `:32` | Keep only `QuestieCompat.IsQuestFlaggedCompleted` | Its function is unconditionally defined before the consumer loads; the `or C_QuestLog…` operand is unreachable. |
| `Modules/Libs/QuestieLib.lua:4`, calls `:532,543` | Alias `QuestieCompat.GetAddOnMetadata` directly | Wrapper at `Modules/QuestieCompat.lua:1130–1134` already performs identical selection. |
| `Modules/Journey/tabs/QuestsByFaction/QuestsByFactionsTab.lua:80–96` | Remove the wrapper-existence checks | Locals at `:17` reference unconditional Compat functions. These checks cannot detect unavailable underlying APIs. |

**Availability:** Reference rows `7308` and `2698` mark modern completion and metadata APIs across the snapshot. Removing these outer checks does not depend on proving an older-build floor.

**Important exception:** Do not make the same metadata substitution in:

- `Modules/VersionCheckDB.lua:8–15,27–30`
- `Database/SupportValidation.lua:48–55`

Those paths deliberately tolerate both APIs being absent and produce useful diagnostics. The Compat wrapper would instead call a missing global.

**Confidence:** High; independently supported by skeptical review.

### 1.3 Remove unused internal wrappers

Repository-wide consumer searches found:

| Wrapper | Definition | References |
|---|---|---|
| `QuestieCompat.AddQuestWatch` | `Modules/QuestieCompat.lua:572–587` | Tests only |
| `QuestieCompat.GetNumTrackedAchievements` | `Modules/QuestieCompat.lua:1043–1048` | No production consumers |
| `QuestieCompat.CollapseFactionHeader` | `Modules/QuestieCompat.lua:704–712` | No production consumers |

**Recommendation:** Remove as unused internal surface, assuming QuestieCompat is not intended as an externally supported API.

This does not justify removing native watch hooks or synthetic achievement counts. Those remain active.

**Confidence:** High within this checkout. `QuestieLoader` exposes modules, so absence of external-addon consumers cannot be proved. The documented stable API is `Questie.API`, not every imported module.

## 2. Supported-build policy and evidence

**No explicit minimum-build policy was established.** Current manifests retain:

| Manifest | Interface |
|---|---|
| `Questie-Classic.toc:1` | `11508,11509` |
| `Questie-BCC.toc:1` | `20506` |
| `Questie-WOTLKC.toc:1` | `38002` |
| `Questie-Cata.toc:1` | `40402` |
| `Questie-Mists.toc:1` | `50503,50504` |
| `Questie-Camelot.toc:1` | `16001` |

`Modules/VersionCheck.lua:57–110` retains these flavor distinctions, including Titan. Packaging still knows Cata. Neither manifest interfaces nor old compatibility comments establish how far backward support is promised.

**Decision needed:** Does support mean current Blizzard channels, every manifest-listed version, or additional historical/private clients?

The Wiki snapshot describes Era 69109, Anniversary 69110 and progression Classic 69155. It is availability evidence, not support policy. Blank cells and missing rows were not treated as proof of absence.

### Blizzard source used

Existing caches were inspected read-only, without refreshing, to honor the no-Git-state constraint. Their heads were rechecked at completion.

| Branch | Commit | Version/build |
|---|---|---|
| `classic_era` | `33e177d9bf38d76d5c6c6e05d5da78db1899659a` | 1.15.9 / 69722 |
| `classic_anniversary` | `1463c686270b6c64e2c5c228f447c4597c0f8ba6` | 2.5.6 / 69795 |
| `classic` | `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` | 5.5.4 / 69585 |
| `classic_titan` | `84ef503f0d2617494db84cc9c7e7b530e976f6e7` | 3.80.2 / 69874 |
| `forever` | `70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e` | 1.60.1 / 69913 |

These differ from the Wiki builds. Forever matches the documented historical runtime baseline, not a new live observation.

Blizzard paths below are relative to `Interface/AddOns/` at these commits. They can be resolved as:

`https://github.com/Gethe/wow-ui-source/blob/<commit>/Interface/AddOns/<path>`

Line references describe the checkout at audit time and may shift after subsequent edits.

## 3. Conditional on supported-build policy

### 3.1 Thin item, addon, completion and date fallbacks

The following modern branches do not need contract conversion:

| Legacy function/fallback | Modern replacement | Wrapper/consumers |
|---|---|---|
| Item information/icon/count | `C_Item.GetItemInfo`, `GetItemIconByID`, `GetItemCount` | Finding 1.1 |
| `GetContainerNumSlots` | `C_Container.GetContainerNumSlots` | Compat `:170`; `TrackerItemButton.lua:41`; `QuestieQuest.lua:906` |
| `GetItemSpell`, `IsEquippableItem` | Corresponding `C_Item` functions | `TrackerUtils.lua:45–46,360` |
| `IsItemInRange` | `C_Item.IsItemInRange` | `TrackerItemButton.lua:18,160–168` |
| `IsQuestFlaggedCompleted` | `C_QuestLog.IsQuestFlaggedCompleted` | Compat `:513`; `QuestFinisher.lua:21,32`; already direct in `Quest/IsleOfThunder.lua:21–26` |
| `GetQuestResetTime` | `C_DateAndTime.GetSecondsUntilDailyReset` | Compat `:765`; `AvailableQuests.lua:128`; `QuestieLib.lua:799` |
| `GetCurrentCalendarTime` fallback | `C_DateAndTime.GetCurrentCalendarTime` | Compat `:255–269`; `Database/Corrections/Holidays/QuestieEvent.lua:200,285,454` |

Here and below, abbreviated consumer filenames refer to their full paths elsewhere in the report or their matching module directory. Compat refers to `Modules/QuestieCompat.lua`.

**Availability:** Reference rows `4039`, `5839`, `5861`, `5876`, `7308`, `4354–4355` mark these modern APIs across the snapshot. All five cached branches provide supporting declarations.

Concrete loaded Classic bag code already uses `C_Container` in `Blizzard_UIPanels_Game/Classic/ContainerFrame_Shared.lua:453–466`. Forever's selected `Camelot/PaperDollFrame.lua:1761–1762` uses modern item spell/equippability queries.

**Contract caveats:**

- Item range is boolean or nil. Preserve nil as unknown.
- Item information remains asynchronous/cache-dependent.
- The old calendar fallback fabricates midnight. `QuestieEvent.lua:454–469` uses hours/minutes for holiday boundaries; this fallback is not truly equivalent.
- Count calls using `(itemID, nil, true)` must retain charge/use-count semantics.

**Recommendation:** Delete these fallback branches only after establishing the oldest retained build. No need to introduce new wrappers for simple APIs already guaranteed by that policy.

**Confidence:** High for inspected builds; historical floor unresolved.

#### Repeated addon-load fallbacks

`C_AddOns.IsAddOnLoaded or IsAddOnLoaded` appears at:

- `Modules/QuestieCoordinates.lua:20`, call `:116`
- `Modules/Options/TrackerTab/QuestieOptionsTracker.lua:33`, calls `:654,679`
- `Modules/Tracker/TrackerHeaderFrame.lua:32`, call `:103`
- `Modules/Tracker/TrackerUtils.lua:43`, call `:938`
- `Modules/Tracker/QuestieTracker.lua:94`, calls `:141,2394`

Reference `:2708` and all cached branches support the modern function. Forever declares two results, loaded-or-loading and loaded, at `AddOnsDocumentation.lua:322–335`. These consumers use the first; preserve that meaning.

### 3.2 Presentation fallbacks now obsolete on inspected channels

| Candidate | Modern replacement and affected consumers | Contract/evidence |
|---|---|---|
| `MouseIsOver` wrapper, Compat `:856–867` | `frame:IsMouseOver`; `EventHandler.lua:478,491`; `TrackerUtils.lua:948,957,970` | All current callers pass frames without offsets. Classic's loaded `Blizzard_UIParent/Shared/UIParent.lua:530–532` already delegates to this method. Preserve offset order: top, bottom, left, right. |
| Resize wrapper, Compat `:60–76` | `frame:SetResizeBounds`; `QuestieOptions.lua:51`; `QuestieJourney.lua:134`; `TrackerHeaderFrame.lua:253`; `QuestieTracker.lua:1837,1840`; separate profiler helper `QuestieProfilerUI.lua:345–356,2428` | Declared in all cached branches: Classic `SimpleFrameAPIDocumentation.lua:1252–1263`, Forever `:1445`. Preserve nullable maximums and existing explicit zero arguments. |
| Chat filter selectors | `ChatFrameUtil.AddMessageEventFilter` / `RemoveMessageEventFilter`; `QuestieAnnounce.lua:23–42`; `QuestieShutUp.lua:7–43`; `QuestLinks/ChatFilter.lua:9,138–169` | Loaded `Blizzard_ChatFrameBase/Shared/ChatFrameFilters.lua` supplies them across inspected clients; deprecated globals explicitly alias them. Preserve filter-initialization retries, which address timing. |
| Numbered popup fallback | Existing `StaticPopup_ForEachShownDialog` / `StaticPopup_ResizeShownDialogs` branch | `QuestEventHandler.lua:140–173`; obsolete branch's only resize-wrapper call at `:166`; Compat wrapper `:993–997`. Both modern helpers exist in all five loaded StaticPopup implementations. |
| `TooltipBackdropTemplateMixin` shim | Native mixin | Compat `:43–45`; consumer `LibUIDropDownMenu.lua:509`. All caches define/load it through `Blizzard_SharedXML/SharedTooltipTemplates.lua:226`. |
| `QuestTimerFrame or WatchFrame` | Retain only `QuestTimerFrame`, with nil guards | `TrackerQuestTimers.lua:14–16,26–53`. All cached timer XMLs create QuestTimerFrame; startup/load timing still needs confirmation. |

**Recommendation:** Remove these historical branches after floor confirmation, rather than preserving outdated "Pre-MoP" or "Dragonflight-only" assumptions.

**Confidence:** High for API/layout evidence, conditional for older clients and load timing. Do not mechanically consolidate the profiler resize helper first: unlike Compat, it tolerates individually missing legacy methods without error.

### 3.3 Spell bridge appears unnecessary for bundled AceGUI on Forever 69913

**Candidate:** `QuestieCompat.GetSpellInfo`, `Modules/QuestieCompat.lua:1100–1111`, and the missing-global bridge at `:1123`.

**Actual consumers:**

- `Libs/AceGUI-3.0/widgets/AceGUIWidget-EditBox.lua:81–93`
- `Libs/AceGUI-3.0/widgets/AceGUIWidget-MultiLineEditBox.lua:106–114`

Both already prefer `C_Spell.GetSpellName(extra)`. No first-party production caller uses the Compat wrapper.

**Evidence:** Reference `:7866` marks `GetSpellName` across the snapshot. Forever declares it at `SpellDocumentation.lua:501–515`; loaded `Blizzard_ObjectAPI/Mainline/Spell.lua:41–42` uses it by spell ID.

**Contract warning:** AceGUI's legacy fallback passes a spellbook slot and bank. Compat accepts one spell identifier and cannot faithfully emulate that fallback.

**Recommendation:** Remove the spell wrapper/bridge if the agreed Forever floor guarantees `GetSpellName`. Keep the desaturation bridge: AceGUI checkbox still calls it directly.

**Confidence:** High for bundled-code dependency analysis; medium for complete removal safety. Other addons can win AceGUI widget-version arbitration. Earlier Forever builds and externally supplied widget implementations remain unverified.

## 4. Requires contract adaptation

### 4.1 Container information: replace tuple unpacking deliberately

**Wrapper:** `Modules/QuestieCompat.lua:194–216`.

**All consumers:**

- `Modules/Tracker/LinePool/TrackerItemButton.lua:42`: tuple fields 1 and 10, texture and item ID.
- `Modules/Quest/QuestieQuest.lua:907`: tuple field 10 only.

**Modern replacements:**

- Tracker button: `C_Container.GetContainerItemInfo`, reading guarded `iconFileID` and `itemID`.
- Source-item scan: `C_Container.GetContainerItemID`.

**Evidence:** Reference `:4031–4032` marks both across the snapshot. Classic `ContainerDocumentation.lua:139–170` and Forever `:175–208` establish optional returns.

**Recommendation:** Migrate these two consumers, then remove the tuple wrapper once the floor permits. Preserve empty-slot handling, bag range and equipped-item fallback.

**Confidence:** High. A function-name substitution alone would break both consumers.

### 4.2 Cooldown fallback has a latent boolean/numeric mismatch

**Wrapper:** `Modules/QuestieCompat.lua:224–232`.

**Only consumer:** `Modules/Tracker/LinePool/TrackerItemButton.lua:126–133`, requiring `enabled == 1`.

The wrapper chooses:

1. `C_Container.GetItemCooldown`
2. `C_Item.GetItemCooldown`
3. Legacy global

Forever declarations distinguish:

- `ContainerDocumentation.lua:337–352`: numeric `enable`
- `ItemDocumentation.lua:434–448`: boolean `enableCooldownTimer`

**Consequence:** If the `C_Item` fallback becomes active, `true` fails the consumer's `== 1` check.

**Recommendation:** Prefer `C_Container.GetItemCooldown` once its support floor is guaranteed. Otherwise normalize the fallback contract explicitly. Do not replace it with `C_Item.GetItemCooldown` merely because that namespace looks newer.

**Availability:** Reference `:4041` marks the container function across the snapshot. All cached branches declare it. Current container-first selection means this is a latent mismatch, not a reproduced failure.

**Confidence:** High, confirmed independently. Smallest follow-up: read-only return-type comparison for an existing item; no item use required.

### 4.3 Gossip selectors can use the identity already returned by the list

**Wrappers:**

- Compat `SelectAvailableQuest`, `:143–150`
- Compat `SelectActiveQuest`, `:156–163`

**Only callers:** `Modules/Auto/AutoQuesting.lua:142,98`.

These callers pass list positions. The wrappers fetch the list again and extract `questID`; modern `C_GossipInfo.SelectAvailableQuest` and `SelectActiveQuest` accept quest IDs.

**Evidence:** Reference `:5169–5170`; Classic `GossipInfoDocumentation.lua:154–171`, Forever `:177–195`; loaded gossip buttons store and select `questInfo.questID`.

**Recommendation:** Once old gossip support is dropped, select the ID from the record AutoQuesting already inspected. Remove both translation wrappers and the second list fetch. Do not pass the existing index directly.

Related removals:

- Old tuple fallback branches: Compat `:80–137`.
- Old numbered gossip UI: `Modules/Quest/QuestgiverFrame.lua:54–88,143–151`.
- Count wrappers `:871–888`, whose only consumers are that old UI path.

List consumers are `AutoQuesting.lua:86,105`, `QuestgiverFrame.lua:60–61`, and `AvailableQuests.lua:371,391`. Modern getters are marked at reference `:5155–5162` and used across all cached branches.

**Keep:** `GetActiveQuests` completion enrichment at Compat `:110–114`. It substitutes `QuestieDB.IsComplete(...) == 1` when native completion is false/nil. Removing that changes automation behavior.

**Confidence:** High on contracts; fallback removal conditional on floor and mixin load timing. Later tests should cover non-first quests, empty/reordered lists and completion enrichment.

### 4.4 Forever greeting frames differ from Classic's numbered globals

**Consumers:**

- `Modules/Quest/QuestgiverFrame.lua:95–104`
- `Modules/Quest/AvailableQuests/AvailableQuests.lua:498–510`

They enumerate `QuestTitleButton1`, `QuestTitleButton2`, etc.

**Source difference:**

- Classic `Blizzard_UIPanels_Game/Classic/QuestFrame.lua:328–409` uses numbered frames.
- Forever's loaded `Mainline/QuestFrame.lua:304–309,331,377` uses an unnamed button pool.
- Forever obtains identities through `GetActiveQuestID(i)` and `GetAvailableQuestInfo(i)` at `:347,378`.

**Recommendation:** Separate quest-data enumeration from rendered-frame enumeration, and adapt icon decoration to the actual layout. Retain Classic's layout path where needed.

Do not replace `MAX_NUM_QUESTS` with `C_QuestLog.GetMaxNumQuestsCanAccept`: these consumers need a button enumeration limit, not the player's accepted-quest capacity.

**Confidence:** High that native layouts differ. Additional UI addons might supply compatibility globals, so an observed failure is not established. A read-only frame/capability inspection is the smallest follow-up.

### 4.5 Watched faction can avoid expanding and scanning every header

**Current algorithm:** `Modules/Journey/tabs/QuestsByFaction/QuestsByFactionsTab.lua:80–96`.

**Replacement:** `C_Reputation.GetWatchedFactionData()`.

**Evidence:** Reference `:7505` marks all snapshot clients. Classic declares nullable `FactionData` at `ReputationInfoDocumentation.lua:40–47`; its loaded reputation bar uses the getter. Forever's equivalent checks nil and faction ID zero in `Blizzard_StatusTrackingBar/Shared/ReputationBar.lua:51–55,77–81`.

**Required decisions:**

- Preserve the current exclusion of header factions if exact behavior is required.
- Handle nil and ID zero.
- Intentionally stop expanding all native faction headers.

**Recommendation:** Simplify this consumer after floor confirmation. Do not eliminate the broader faction tuple adapters.

**Confidence:** High for the opportunity.

**Separate uncertainty:** `QuestieReputation.lua:28` and this Journey algorithm use `ExpandFactionHeader(0)`. Forever separately declares `ExpandAllFactionHeaders` and `ExpandFactionHeader(factionSortIndex)`. Source does not establish the legacy zero sentinel for the modern function. Preserve or explicitly adapt that behavior; do not assume identical arguments.

### 4.6 XP's legacy `IsSpellKnown` is not a transparent rename

**Direct call:** `Database/QuestXP/QuestieXP.lua:35`, querying Fast Track spell 78632.

**Existing boundary:** Compat `IsSpellKnown`, `Modules/QuestieCompat.lua:276–283`.

Blizzard's gated deprecated spellbook implementation explicitly maps:

- Legacy `IsPlayerSpell` → `C_SpellBook.IsSpellKnown`
- Legacy `IsSpellKnown` → `C_SpellBook.IsSpellInSpellBook(..., false)`

See `Blizzard_DeprecatedSpellBook/Deprecated_SpellBook.lua:11–26` across inspected branches. Reference `:7957–7959` marks the modern functions.

**Recommendation:** Choose between exact legacy spellbook semantics and alignment with Questie's passive-aware Compat query. The latter is already used by:

- `Modules/QuestieReputation.lua:320–321`
- `Modules/QuestieProfessions.lua:24,162,237–267`
- `Database/QuestieDB.lua:1023,1464`

**Confidence:** High that semantics differ. A read-only comparison on a relevant progression/Titan character would resolve the practical Fast Track case. This is not a demonstrated Forever failure; that XP branch is WotLK+ content.

### 4.7 Remove Forever watch interception only after separating Questie's own state

**Installation:** `Modules/Tracker/QuestieTracker.lua:2041–2080`.

**Restoration:** `:1953–1980`.

**Internal synthetic-state consumers:**

- `Modules/Tracker/TrackerUtils.lua:1142`: `GetNumQuestWatches(true)`
- `:1157`: `IsQuestWatched(logIndex)`

These globals describe Questie's tracking policy. Ordinary count callers receive zero. Native `C_QuestLog` functions describe Blizzard watches.

Forever already has independent namespace hooks at `QuestieTracker.lua:2000–2020`, preserves native watches, and treats additions idempotently.

**Recommendation:** Introduce explicit internal Questie count/state queries, migrate those consumers, then evaluate removing global interception on Forever only. Preserve synchronization and visibility ownership.

Do not substitute `QuestieCompat.GetNumQuestWatches(true)`: its modern branch intentionally ignores the argument.

**Evidence:** Forever `QuestLogDocumentation.lua:15–27,564–577,1189–1202` establishes quest-ID watch operations and nullable watch type. Zero is a valid automatic watch type.

**Confidence:** High on the required separation. Lifecycle validation remains necessary, including another addon replacing the global after Questie's installation. Current teardown can overwrite that later replacement.

### 4.8 UI contract issues to keep separate from fallback deletion

| Finding | Evidence and recommendation |
|---|---|
| Watch redraw precedence differs | Consumers at `QuestieTracker.lua:95` and `QuestLinks/Hooks.lua:4` prefer `QuestWatch_Update`; Compat `:815–821` prefers `WatchFrame_Update`. Consolidating changes behavior if both exist. Preserve chosen precedence; alternate-UI behavior remains unverified. |
| Map opening is more than `Show()` | `TrackerUtils.lua:138–156`, called by `TrackerMenu.lua:197,208`, uses raw `Show`/`SetMapID`. Forever `Blizzard_WorldMap/QuestLogOwnerMixin.lua:101–107` implements `HandleUserActionOpenSelf` using `ShowUIPanel`. Adapt by flavor; preserve always-open rather than toggle semantics. Combat behavior remains unproven. |
| Mouse focus is table-to-first-frame adaptation | Compat `:235–242`; sole caller `QuestieTracker.lua:2395`. `GetMouseFoci()` returns a table, not a frame. Preserve `[1]` and account for an absent/unnamed frame before `GetName`/`strmatch`. Reference `:934` supports availability. |
| Action-status wrapper drops an argument | Compat `:1001–1008`; `TrackerMenu.lua:390,553` passes `true` as a second argument. Classic `Blizzard_UIParent/Classic/WorldFrame.lua:105–112` uses it to bypass `showNewbieTips`. Preserve that flag if revisiting the wrapper; the UIErrorsFrame fallback is different presentation. |
| Popup modernization does not solve ownership | `QuestEventHandler.lua:140–189` matches text arguments and retains a deletion flag. Forever `Blizzard_StaticPopup_Game/GameDialogDefs.lua:1552–1574` can delete through either `C_Item.DeleteItem(itemGUID)` or `DeleteCursorItem`; Questie hooks only the latter. Cancellation/state identity needs separate review, not a renamed hook. |

These are source-backed contract differences, not claims of reproduced combat failures.

## 5. Keep: meaningful compatibility behavior

### 5.1 Quest-log identities, tuples, sentinels and sets

Retain these adapters unless their consumers migrate together:

| Compat function/location | Behavior that must survive |
|---|---|
| `GetQuestLogTitle`, `:386–418` | Record → tuple; tag in slot 3; incomplete nil, complete `1`, failed `-1`; header guards |
| `GetQuestLogIndexByID`, `:738–747` | Missing modern index nil → legacy `0` |
| `SelectQuestLogEntry`, `:423–437` | Log index → quest ID; reject headers |
| `GetQuestLogSelection`, `:442–452` | Selected quest ID → log index/zero |
| `GetNumQuestLeaderBoards`, `:526–536` | Optional selected-entry default, ID conversion, zero for missing/header |
| `GetQuestsCompleted`, `:777–790` | ID array → boolean set; augment supplied table |
| `GetQuestTagInfo`, `:795–807` | Record → positional tag tuple |
| Abandonment helpers, `:894–953` | Prepared target, cached item IDs → comma-separated names/nil, selection restoration |

**Affected consumers:** `QuestLogCache.lua:19,208,336`; `QuestieValidateGameCache.lua:22,73,84`; `QuestieDebugOffer.lua:538–540`; `QuestEventHandler.lua:90,236`; `EventHandler.lua:147`; `AutoCompleteFrame.lua:55,66`; `TrackerUtils.lua:99–100,372,999,1157`; `TrackerMenu.lua:250–263`; `VoiceOverPlayButton.lua:49`; `BreadcrumbQuests.lua:23–27`; `TrackerQuestTimers.lua:107–122`; `QuestLinks/Hooks.lua:39–46`; `QuestieTracker.lua:185,194,2006,2050,2153,2206`; `QuestieQuest.lua:86,387`; `Database/QuestieDB.lua:751–778`.

Modern quest-log parity is not established across Classic. Loaded Classic quest-log source still uses legacy tuple/index APIs. Forever declarations explicitly establish the changed shapes at `QuestLogDocumentation.lua:116–124,191–220,303–325,1243–1251`.

Also retain separate `SelectQuestLogEntry` and `QuestLog_SetSelection` contracts. Classic's latter function updates selection highlighting and details UI, not just native selection.

**Confidence:** High. These are not rename-only wrappers.

### 5.2 Timers, visibility and achievement tracking

- **Timers:** Compat `:832–845` returns seconds as varargs; `QuestEventHandler.lua:222` expects numeric/no-value. `TrackerQuestTimers.lua:97–131` instead needs modern `{questID, questTimer}` records or legacy selection-preserving lookup. These differing consumer paths are justified.
- **Visibility:** Compat `:290–364` preserves Forever combat deferral/content-aware restoration and Titan's alpha workaround. Callers: `Questie.lua:47,55`, `WatchFrameHook.lua:14`, `TrackerBaseFrame.lua:140,149`.
- **Achievement tracking:** Compat `:1035,1052` supports list/removal behavior consumed throughout `QuestieTracker.lua:82,226,236,238,2364–2386`. Current loaded Mists achievement UI still uses legacy tracking APIs. `C_ContentTracking` would change identity, events and state, not simplify a spelling.

**Concrete dependency:** Forever's `QuestTimerFrame` is parented to `ObjectiveTrackerFrame` in `Blizzard_QuestTimer/Mainline/Blizzard_QuestTimer.xml:3`. Showing the child cannot overcome parent suppression. This needs an actual timed-quest observation before visibility changes.

**Confidence:** High on retained contracts; live timed-quest behavior unverified.

### 5.3 Faction, aura, profession and stable adapters

- **Faction tuples:** Compat `:655–733`; consumers `QuestieReputation.lua:20,28,33–34,308,400` and Journey's watched-faction loop. They consume positional standing/header/bonus fields. Current Classic UI still uses legacy faction APIs.
- **Auras:** Compat `:460–478`; all production consumers are `QuestieReputation.lua:343` and `Database/QuestXP/QuestieXP.lua:45,129`. Each reads spell ID from tuple slot 10. Direct record access requires migrating them together.
- **Professions:** `QuestieProfessions.lua:74–96` retains skill-line versus sparse modern enumeration; unlearning/event behavior is at `:26–40` and `EventHandler.lua:114–117`. The model includes Riding; modern profession enumeration is not proven equivalent.
- **Stable food:** Compat `:1062–1068`; `QuestieMenu/Townsfolk.lua:540` packs varargs into a table. Native `C_StableInfo` returns an array; direct substitution would nest it.

**Aura restriction evidence:** Forever `UnitAuraDocumentation.lua:207–223` declares aura-access requirements and potentially secret data. This affects XP as well as reputation. A modern API name does not make spell-ID comparison safe in every context.

**Recommendation:** Keep until specific consumer adaptations and restricted-data policy are agreed. Do not add blanket `pcall` or interpret inaccessible data as "no buff."

### 5.4 Tooltip and embedded-library boundaries

Keep:

- `Modules/Tooltips/Tooltip.lua:526–552` capability selection requiring actual structured frame support, not processor presence alone.
- Template-derived Unit/Item getters and presentation measurement.
- Journey's item-cache scanner at `QuestieSearchResults.lua:397–425`; modern data loading has not been shown equivalent to tooltip-layout readiness.
- Desaturation bridge at Compat `:1116–1124`; real AceGUI checkbox callers remain at `AceGUIWidget-CheckBox.lua:100–130`.
- Optional legacy redraw/achievement UI guards where absent/load-on-demand frames are legitimate.

Documented Anniversary runtime evidence confirms processor presence without modern callback delivery. The completed Object-tooltip migration was not reopened.

### 5.5 Seasons, geometry and native globals that remain current

- **Keep `C_Seasons` shim for now:** Compat `:27–40`; VersionCheck consumers `:84–110`. Forever source does not establish native seasons support. A post-startup probe can see Questie's own shim, so simple presence testing is misleading.
- **Keep HBD geometry fallback:** `HereBeDragons-2.0.lua:249–278` handles missing/degenerate rectangles, not missing API names.
- **Keep Krowi correction:** `WorldMapButton.lua:15–19` corrects Forever layout classification and parent behavior.
- **Keep greeting/action globals:** `GetActiveTitle`, `SelectAvailableQuest`, `AcceptQuest`, `CompleteQuest`, `ConfirmAcceptQuest`, and `GetQuestReward` remain native APIs in matching Forever UI.
- **Do not blanket-replace `SetCVar`:** Blizzard's loaded helper performs boolean/string conversion; direct native calls do not automatically preserve numeric callers.

No supported replacement was established for ordinary group globals, inventory getters or nameplate integrations merely because their names are unnamespaced.

## 6. Insufficient evidence and disagreements resolved

1. **"Every `native or Compat` selector is redundant."** Rejected. Item and QuestieLib metadata selectors match their wrappers; watch-redraw precedence does not. Diagnostic metadata paths preserve additional failure behavior.

2. **"AceGUI still requires both Forever global bridges."** Current source contradicts that broad rationale. Bundled spell widgets prefer `C_Spell.GetSpellName`; checkbox widgets still require `SetDesaturation`. Spell removal remains qualified by build and external widget arbitration.

3. **"Modern namespace availability makes quest wrappers obsolete."** Rejected by tuple/index/set/watch contracts and loaded Classic source.

4. **Progression watch API evidence conflicts.** Loaded Mists `Wrath/QuestMapFrame.lua:207–208` calls namespaced watch functions, while its generated declarations and Wiki marks do not confirm them. Compat selects by capability, but tracker namespace hooks are Forever-only. Resolve with read-only progression capability/call-path verification, not assumptions from either source alone.

5. **Quest-link modern replacement is unproven.** `QuestLinks/Link.lua:61–69` checks global `GetQuestLink` before Compat, whose `:753–760` probes a namespaced function. Matching Forever UI still uses the global; no established namespaced declaration was found. Preserve the consumer's graceful fallback rather than routing blindly into an erroring wrapper.

6. **`GetQuestGreenRange` is not proven obsolete on Classic.** Compat `:611–621`; callers `QuestieDB.lua:1621`, `QuestieLib.lua:64,84`, `AvailableQuests.lua:32,585`. Loaded Classic UI uses the legacy helper; Forever uses `UnitQuestTrivialLevelRange("player")`. Keep the distinction.

## 7. Coverage, limits and implementation order

### Audited families

1. Items, containers, inventory, cooldowns and cache behavior.
2. Quest logs, identities, completion, selection and abandonment.
3. Gossip, greeting, acceptance and reward APIs.
4. Reputation, spells, auras, professions and stable data.
5. Tooltips, mouse/frame methods, popup/chat/UI compatibility.
6. Maps, addons, seasons, calendar, units/groups and library boundaries.
7. Watches, timers, native tracker ownership and achievement tracking.

### Important limits

- No matching historical Cata 4.4.2, Era 1.15.8 or Mists 5.5.3 verification.
- No live interaction, combat/secret-data proof, hardware-action testing or timing validation.
- AutoQuesting's action names were audited; its full event/state workflow remains unvalidated.
- Third-party UI/widget overrides and watch-interceptor interoperability are not certified.
- Embedded libraries were inspected for concrete dependencies, not comprehensively audited.
- QuestieDB's separate checkout was not needed or touched.
- Existing tests were inspected, not executed. Passing mocks would not establish native restrictions.

### Proposed later implementation order

1. **Mechanical cleanup:** identical selectors, dead checks and unused internal wrappers.
2. **Decide the supported-build floor.**
3. **Remove proven historical forwarding fallbacks:** item/addon/date and selected presentation APIs.
4. **Small contract migrations:** container records, gossip IDs, watched-faction lookup; resolve cooldown and spell-known semantics separately.
5. **Lifecycle work:** explicit Questie watch queries before removing interception; greeting layout, popup ownership and map opening in separate reviewed changes.
6. **Targeted validation:** focused tests and loader/lint checks, followed only by the smallest agreed runtime probes. Do not bundle unrelated tooltip or persistence work.

### Audit checkout state

The audit issued no writes. The API reference, now at `docs/classic-api-availability.md`, was already untracked. During the audit, `FOREVER_WORK_LEFT_TO_DO.md` gained a section describing this separately running audit; that concurrent change was observed and left untouched. This report file was subsequently created at the user's request.
