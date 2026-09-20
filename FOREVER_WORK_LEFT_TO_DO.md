# Forever work left to do

This is the remaining compatibility and combat-safety audit, not a list of confirmed failures. The behaviors below still exist after the QuestieDB integration, QuestieCompat consolidation, and scoped Forever Object-tooltip migration.

Keep Classic behavior intact unless a separate, tested change is justified. Do not equate Forever's modern API surface with identical Retail restrictions, or describe every insecure addon call as prohibited.

## Scope and current status

- **Finding 1, Object-tooltip scanning:** implemented, pending the documented manual validation. Forever uses structured Object callbacks; Classic retains its scanner. Unit/Item tooltip text and count handling remains separate work. Do not expand or reopen the tooltip implementation as part of the items below without agreement.
- **Findings 2–5:** audit the retained watch globals, confirmation-popup mutations, aura inspection, and secure item/map behavior.
- **Finding 6, QuestieAuto:** review automatic quest interaction as a complete event-driven workflow, not just individual API names.
- **Finding 7, legacy API and fallback audit:** complete; see the [audit report](LEGACY_API_AUDIT.md). Implementation awaits review and selection of follow-up changes.
- **SavedVariables:** parked as a known beta-client problem. Do not add persistence workarounds under this audit.

References:

- [Forever development and live evidence](docs/forever-development.md)
- [Tooltip implementation, evidence, and validation limits](docs/forever-tooltips.md)
- [Broader hardening backlog](docs/forever-hardening-backlog.md)
- [Required tooltip review recipe on PR #7848](https://github.com/Questie/Questie/pull/7848#discussion_r4055873073)

Historical Forever evidence used client `1.60.1 (69913)`. Record the actual build for each new test. The later Classic `2.5.6 (69795)` tooltip checks do not establish Era or Forever behavior.

## Security distinctions and validation rules

Keep three different mechanisms separate:

1. **Protected actions and frame changes:** an operation may require a secure hardware path or may not be permitted from insecure code during combat. A correctly configured secure item button is different from calling its action through a bridge.
2. **Taint and shared-state ownership:** replacing a Blizzard global or modifying a Blizzard-owned frame can affect subsequent native or addon execution. A write can succeed initially and cause trouble later.
3. **Restricted or secret data:** a getter can exist and return a value that cannot safely be compared, concatenated, or used as a table key in the current context. `IsForbidden()` on a frame does not establish that all associated data is accessible.

`hooksecurefunc` preserves the original function's execution boundary. It does not make arbitrary writes inside its callback secure. Similarly, `pcall` is not permission to read restricted data or perform a protected action.

For each item:

- Trace the ordinary addon caller, not only the compatibility wrapper.
- Separate source declarations, observed runtime results, and hypotheses.
- Use focused tests for return contracts, state ownership, and queued work. Mocks cannot prove the client's security rules.
- Validate through normal events and physical clicks where relevant. Bridge-injected code can have a different taint identity.
- Record the client build, addon/provider revisions, enabled UI addons, settings, combat state, and exact error/stack.
- Redact secret values before diagnostic serialization. Do not attempt to expose them.
- Preserve and restore settings and UI state. Do not change installation links, bindings, or other clients to run these checks without permission.

## 2. Replacing Blizzard watch globals

### Current behavior

[Modules/Tracker/QuestieTracker.lua](Modules/Tracker/QuestieTracker.lua), especially `HookBaseTracker()` and `Unhook()`, still replaces:

```lua
IsQuestWatched
GetNumQuestWatches
```

`IsQuestWatched` reports Questie's tracking policy. The replacement `GetNumQuestWatches(isQuestie)` counts Questie's tracked quests when passed its private truthy argument, but returns zero to ordinary callers without that argument. These are not transparent translations of Blizzard's API contracts.

The replacements are installed on Forever even though that client already has namespaced `C_QuestLog.AddQuestWatch` and `RemoveQuestWatch` post-hooks. Those hooks translate quest IDs to the existing tracker interface and synchronize native watch changes with Questie state.

Original globals are saved once and restored when unhooking. The implementation now restores nil too, which matters when Forever did not originally expose those legacy globals. Restoration is working behavior to preserve, not proof that installing the replacements is harmless.

### Why this needs investigation

Every addon calling those globals sees Questie's replacement, not just Questie. The zero count can mislead another addon even without a combat error. The writes also introduce a taint and ownership boundary around names Blizzard or another addon may use later.

There is a further lifecycle question: restoring the value captured at initial installation could overwrite a replacement another addon installed afterward. Establish whether that can happen and what ownership policy is appropriate before changing teardown.

### Proposed direction

Investigate whether Forever can avoid installing these replacements entirely:

- Keep native watch state and native API return values intact.
- Keep Questie's own tracking count/query as explicit module functions for its consumers.
- Use the existing namespaced watch hooks for synchronization.
- Use QuestieCompat's explicit, combat-deferred native-tracker visibility handling instead of falsifying watch counts to suppress native UI.

This is a direction, not permission to delete the assignments immediately. First find every consumer of the synthetic boolean/count, including the special `GetNumQuestWatches(true)` convention. Removing the global without migrating those callers would break Questie's tracker.

### Focused checks

- Compare native and Questie counts with automatic tracking on and off.
- Add a native watch twice: the second addition must remain an idempotent add, not toggle tracking off.
- Remove and re-add through the native log, Questie's menu, and another addon/API consumer.
- Exercise initially absent legacy globals, tracker enable/disable, and repeated initialization.
- Enter and leave combat while changing watches; verify the native and Questie trackers do not both disappear.
- Check interoperability with an addon that reads the legacy watch APIs or installs its own wrapper.

**Done when:** Forever no longer needs shared-global interception, all internal consumers use the intended count/state, native watches remain synchronized, and Classic's existing behavior passes separate checks. If interception is still necessary, document the exact caller and reason rather than retaining it by default.

## 3. Mutating Blizzard confirmation popups

### Current behavior

[Modules/EventHandler/QuestEventHandler.lua](Modules/EventHandler/QuestEventHandler.lua), in `Initialize()`, post-hooks `StaticPopup_Show`. For `DELETE_ITEM`, it searches the quest log and provider data to decide whether the named item is quest-related.

When it finds a match, it locates a shown dialog by its text argument, changes the displayed warning, writes `text.text_arg1`, and resizes the dialog. It supports both the newer dialog iterator and the older numbered popup frames. There is no combat guard around these mutations.

A separate `DeleteCursorItem` post-hook uses the shared `deletedQuestItem` flag to refresh quests after deletion, because deleting quest items does not always produce the expected quest-log update.

### Why this needs investigation

This combines two concerns: presenting an extra warning and detecting a later inventory change. Both depend on Blizzard-owned popup state and on identity surviving across callbacks.

Questions to resolve:

- Does the matched text argument identify the intended `DELETE_ITEM` dialog, or could another shown/reused dialog share it?
- Does writing `text.text_arg1` affect native formatting or later dialog reuse?
- What happens when the user cancels, opens another popup, or moves to another item before a later deletion?
- Does `deletedQuestItem` still describe the item actually deleted, or only a previously displayed warning?
- Are the text/resize operations permitted in combat on the active Forever build?

These are audit questions, not established security failures. Guarding the existence of `StaticPopup_Show` only prevents calling a missing API; it does not answer them.

### Investigation and acceptance

Trace the native deletion-popup lifecycle and its accept/cancel handlers. Check ownership and identity before selecting a replacement. If native mutation is unsafe, consider a separate Questie-owned notice that does not change Blizzard's confirmation action or arguments.

Preserve the user's explicit confirmation. Do not implement automatic deletion, delayed replay of a deletion, or a replacement secure-action flow merely to show a warning.

Test quest and non-quest items, cancelled warnings, sequential/reused dialogs, uncached item names, and combat transitions. Unit tests can exercise cancellation and stale flags without deleting anything. Live tests should cancel the dialog unless deletion of a disposable test item was explicitly agreed.

**Done when:** the warning applies only to the intended item/dialog, native confirmation behavior is unchanged, cancellation leaves no stale deletion state, and the quest refresh follows the relevant completed deletion without taint or blocked-action errors.

## 4. Aura inspection for reputation bonuses

### Current behavior

[Modules/QuestieReputation.lua](Modules/QuestieReputation.lua), in `_GetBuffMultiplier()`, scans up to 40 helpful player auras through `QuestieCompat.UnitAura`. It unpacks the legacy tuple and compares spell IDs to recognize reputation buffs.

[Modules/QuestieCompat.lua](Modules/QuestieCompat.lua) translates modern aura data back into that tuple. On Forever it avoids the legacy global, which can exist but fail internally.

The resulting buff multiplier contributes to displayed reputation rewards alongside other modifiers. This is optional reward enrichment, not a prerequisite for showing a quest title or objective.

### Evidence and remaining risk

The matching Forever source declares `GetAuraDataByIndex` with `RequiresUnitAuraAccess` and `SecretWhenUnitAuraRestricted`:

[UnitAuraDocumentation.lua, build 69913](https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitAuraDocumentation.lua#L206-L223)

Our out-of-combat Mark of the Wild query succeeded. It proves that one aura could be read in that context, not that every aura field remains inspectable during combat or under every caller's taint identity.

The risky operations include field access/unpacking and the later spell-ID comparisons. Changing the API name alone does not make the consumer restriction-aware. Also, an inaccessible aura list must not silently be treated as proof that no reputation buff is active.

### Proposed investigation

- Trace when reward calculation runs, including map/quest tooltip display during combat.
- Compare accessible aura data before, during, and after combat through the ordinary Questie path.
- Determine which fields are needed and whether an allowed alternative can establish the modifier reliably.
- Choose an explicit presentation policy when the modifier is unknown: omit the uncertain adjusted value or identify a base estimate. Do not present an unverified value as exact.
- If caching is considered, define invalidation for aura changes and expiry. A stale last-known multiplier is not automatically safer than omission.

We deliberately did not adopt the donor zip's blanket `pcall`. Catching an exception could preserve the rest of a tooltip, but it would still need a defined result contract and useful diagnostics. It must not hide unrelated programming errors or silently return a fabricated multiplier.

**Done when:** inaccessible aura information cannot abort unrelated quest rendering; uncertainty is represented deliberately; accessible buff calculations remain correct; and live combat transitions are tested. There is no basis for disabling all aura access on all clients.

## 5. Secure item buttons and map actions

### Secure quest-item buttons

[Modules/Tracker/LinePool/TrackerItemButton.lua](Modules/Tracker/LinePool/TrackerItemButton.lua) creates `SecureActionButtonTemplate` buttons. `SetItem` configures item actions using `type1` and `item1`, registers click edges, changes geometry, and shows or hides the button. `FakeHide` clears secure attributes and click handling.

These are secure **item actions**, not dynamic macro execution. The main tracker update path is combat-gated, and [QuestieCombatQueue](Modules/Libs/QuestieCombatQueue.lua) defers work until combat permits it. That is the intended architecture.

The individual button methods rely on their callers to honor those boundaries. Audit all callers, including pooled-frame reuse, option changes, item depletion, tracker hiding, and disable/enable. Do not assume that one guarded entry point covers every future call path.

The button's ongoing update code also reads cooldown, charges, and range, then compares those values. It already skips friendly-target range queries during combat. That guard does not establish unrestricted access for every other return value or target category.

### Map actions

[Modules/Tracker/TrackerUtils.lua](Modules/Tracker/TrackerUtils.lua) guards modern `ShowQuestLog` during combat. In contrast, `ShowObjectiveOnMap` and `ShowFinisherOnMap` call `WorldMapFrame:Show()` and `SetMapID()` directly, without that guard.

This is an inconsistent boundary to investigate, not proof that those map calls are prohibited. Determine the native supported opening path, whether its secure descendants or layout are affected, and how other UI addons change that flow.

### Focused checks

- Physically click a configured quest-item button before and during combat. A bridge `Click()` is not equivalent to a hardware action.
- Observe cooldown/range/charge updates with hostile, friendly, and absent targets.
- Deplete or remove an item only in an agreed disposable-item scenario; verify queued work does not mutate secure attributes during combat.
- Exercise tracker settings, frame reuse, and disable/enable around combat transitions.
- Start a new combat before previously queued work executes; the execution path must recheck its current restrictions.
- Open objectives, finishers, and quest details from tracker actions before/during/after combat; check errors, map selection, and native layout.

**Done when:** protected configuration stays outside combat, queued work cannot apply stale or newly forbidden changes, valid hardware item use still works, optional indicators handle inaccessible data, and map actions have an evidence-backed policy. Do not disable working item buttons merely because their optional range indicator needs a fallback.

## 6. QuestieAuto: automatic quest interaction

“QuestieAuto” here means the `AutoQuesting` module in [Modules/Auto/AutoQuesting.lua](Modules/Auto/AutoQuesting.lua), its [tests](Modules/Auto/AutoQuesting.test.lua), [disallowed IDs](Modules/Auto/DisallowedIDs.lua), and event registration in [EventHandler](Modules/EventHandler/EventHandler.lua). It needs a separate audit; the tooltip work did not validate it.

### Current behavior

The module drives a chain of native quest interactions:

| Entry point | Action |
| --- | --- |
| `OnGossipShow` | Select a completed or available quest through QuestieCompat. |
| `OnQuestGreeting` | Select through the distinct native quest-greeting APIs. |
| `OnQuestDetail` | Apply accept filters, then call `AcceptQuest`; optionally decline certain shared quests. |
| `OnQuestAcceptConfirm` | Call `ConfirmAcceptQuest` when autoaccept is enabled. |
| `OnQuestProgress` | Call `CompleteQuest` when the displayed quest is completable and policy allows it. |
| `OnQuestComplete` | Claim reward 1 when policy permits and there is at most one reward choice. |
| Close/finish handlers | Schedule a 0.5-second check that may reset the interaction's `shouldRunAuto` state. |

Most handlers check settings, the modifier override, NPC/quest exclusions, and interaction state. `OnQuestAcceptConfirm` currently checks only whether autoaccept is enabled. Review whether that difference is intentional for shared quests rather than assuming all handlers enforce the same policy.

There is no blanket combat guard around the interaction chain. This does **not** establish that all automatic quest actions are forbidden on Retail or Forever. Determine availability and restrictions per API, event, and client.

### Questions to answer

**API and identity contracts**

- Keep gossip selection and quest-greeting selection distinct. An index into the current gossip list must become the right quest ID for the namespaced API; it is not itself a quest ID.
- Confirm that the selected quest is still the intended quest when the next event arrives. Reordered lists, unavailable data, and closed dialogs must not select a different quest.
- `_IsAllowedNPC` reads the target GUID. Verify that the target is the interaction owner on Forever, including shared quests and interactions where the target changes. Do not confuse `target`, `questnpc`, and the quest sharer.

**User policy and control**

- Verify modifier suppression across the whole interaction, including confirmation events.
- Preserve disallowed NPC/quest rules and trivial, repeatable, and PvP filtering.
- Check provider-missing quests: do not crash or guess that an unknown quest is eligible merely because the client can display it.
- Preserve manual choice when multiple rewards exist. Test zero, one, and multiple choices and reward/inventory failure handling.

**Lifecycle and restrictions**

- Trace the actual accept, progress, reward, and close event order on Forever. Capability wrappers do not prove that the complete workflow is correct.
- Check whether repeated events can accept/select/claim twice or continue after a cancelled interaction.
- Exercise the delayed reset when dialogs briefly close between steps and when a different NPC interaction begins before the timer fires.
- Establish combat and hardware requirements through ordinary user interactions. Do not automatically queue blocked accept/turn-in/reward actions for after combat: by then the dialog or quest identity may have changed.
- Verify continued compatibility with supported alternate quest-dialog addons without treating their frame visibility as native quest identity.

### Validation and acceptance

Start with explicit tests for selection contracts, modifier policy, exclusions, repeated events, stale timers, and missing provider records. Then use a beta test character for an agreed accept/progress/turn-in cycle, including manual reward choice and cancellation. Accepting and turning in quests changes character state; record which quests are used and do not substitute destructive inventory tests.

**Done when:** normal configured automation works on Forever, the user's override consistently wins where intended, stale events cannot act on another interaction, native restrictions do not create retry loops or blocked-action spam, and any unsupported step falls back to ordinary manual interaction. Preserve separately tested Classic behavior.

## 7. Legacy API and redundant fallback audit

**Status: audit complete.** The [legacy API audit report](LEGACY_API_AUDIT.md) contains the findings, skeptical review, supported-build caveats, and proposed implementation order. Proposed simplifications are not approved or implemented changes.

### Goal and scope

Identify legacy API calls and compatibility branches whose modern replacements already exist across supported Classic clients and Forever. Namespaced APIs are not necessarily Retail-only. For example:

```lua
local GetItemInfo = C_Item.GetItemInfo or QuestieCompat.GetItemInfo
local GetItemIcon = C_Item.GetItemIconByID or QuestieCompat.GetItemIcon
```

The [Classic API availability reference](docs/classic-api-availability.md) marks both namespaced functions available across its sampled Classic and Retail builds. That makes these useful audit candidates, not automatic permission to remove their fallbacks. The reference has no Forever column and does not establish Questie's minimum supported build.

The audit divided functions into API families across seven read-only investigators. Each investigator traced its assigned functions through all consumers, including [QuestieCompat](Modules/QuestieCompat.lua), rather than reviewing isolated folders. Families cover items/inventory, quest logs/watches, gossip/quest interactions, reputation/spells/auras/professions, tooltips/UI, and maps/units/group APIs.

Look for:

- Legacy calls with supported modern replacements.
- Obsolete fallbacks and consumer-side API selection duplicated by QuestieCompat.
- Inconsistent selection between consumers.
- Deprecated Blizzard UI globals or frame assumptions.
- Wrappers that must remain because they preserve meaningful behavior rather than merely rename an API.

### Evidence and deliverable

Compare arguments, defaults, tuple/table returns, nil/false/zero semantics, IDs versus indices, cache behavior, event/hook effects, load order, and restricted-data rules. Some Forever legacy globals exist but fail internally; symbol presence alone does not prove compatibility.

Use the saved reference as availability evidence, with matching Blizzard source where needed. Blank cells and missing rows are not proof of absence. Make removal recommendations conditional when the supported-build policy is unclear.

The report should group findings by function/contract, list affected callers and source evidence, and classify them as:

- Safe simplification candidate.
- Conditional on supported-build policy.
- Requires contract adaptation.
- Keep: meaningful compatibility behavior.
- Insufficient evidence.

A separate skeptical reviewer challenged the strongest simplification recommendations. The report records remaining verification and a proposed implementation order. No production code changed, and the scoped tooltip migration was not reopened.

**Audit done when:** the consolidated, reviewed report identifies actionable candidates, justified retained wrappers, support-policy decisions, and coverage gaps. Audit completion does not mean those changes are implemented; track approved follow-up work separately.

## Recommended order and completion record

1. Audit Forever's watch-global replacements and their internal callers.
2. Audit deletion-popup ownership and cancellation state.
3. Define aura/reputation behavior when data is inaccessible.
4. Validate secure quest-item buttons and map actions through real combat transitions.
5. Audit QuestieAuto's full interaction lifecycle.

Review the [completed legacy API audit](LEGACY_API_AUDIT.md) before scheduling implementation; coordinate overlapping watch, aura, and quest-interaction changes with the items above.

The existing tooltip review recipe remains a separate merge-validation requirement, not an invitation to expand that implementation.

For each completed item, add the chosen behavior, rejected alternatives, affected files, focused tests, live build/results, and remaining limitations to [forever-development.md](docs/forever-development.md). Mark an item complete only for the scope actually validated. No single clean startup, passing mock suite, or out-of-combat probe establishes whole-addon combat safety.
