# Future hardening from the Forever port

This is a backlog, not implemented behavior. It records recurring failure modes exposed by the Forever work, including cases whose immediate compatibility fix is already in place. Completed fixes and live evidence are in [the development log](forever-development.md).

The current provider migration and compatibility-wrapper integration do not implement this broader backlog. Zone data is now owned by QuestieDB; runtime recovery remains a consumer concern. Source-mode startup, tracking, tooltips, and map checks passed on build `69913`; their limits are recorded in [integration validation](forever-development.md#integration-validation). Historical failures below explain the proposals, not guarantees that these fallbacks exist.

Goal: missing support for one zone, quest, or optional feature should not make the rest of Questie unusable. Missing data must also not turn into fabricated coordinates, incorrect eligibility, or silently corrupted state.

## First: unknown zones must not throw from tooltip updates

**Observed:** `No AreaId found for UiMapId: 2521:Zephras Isle` in `Database/Zones/zoneDB.lua`, reached through the object-tooltip `OnUpdate` path in `Modules/Tooltips/Tooltip.lua`. Adding the missing mapping fixes this zone, but the next new zone can reproduce the failure.

Future behavior:

- Provide a non-throwing lookup for runtime UI consumers. Keep strict validation available for database checks and places where a mapping is genuinely required.
- If the current area is unknown, skip only the zone-dependent object-tooltip augmentation and affected map placement. Keep Blizzard's tooltip, existing quest tracking, and other supported zones working.
- Report the missing mapping once per map ID per session. Retain its build, map ID/name, parent map, and first call site for investigation.
- Handle missing `C_Map.GetMapInfo()` data too. The current error construction accesses `.name` directly and can itself fail when the map is unknown to the client.
- Distinguish a lookup that may become available after loading from a genuinely unsupported mapping. Retry at relevant map/data events, not every frame.

**Guardrail:** changing `error()` to `return nil` alone is not sufficient. Audit callers and their return contracts. Do not substitute area ID 0: it already has sentinel meanings, including disabling zone filtering in tooltip code. Do not choose an ambiguous area merely because its English name matches.

**Useful check:** repeated tooltip updates in an unsupported zone produce no exception and one actionable notice; returning to a supported zone restores normal augmentation.

## Missing entity data should be an explicit partial-support state

**Evidence:** the supplied Forever DBC support bundle contains map/race metadata, but explicitly excludes quest/NPC/object payloads and spawn locations. This is a confirmed coverage gap, not a demonstrated exception for a particular new quest yet.

Future behavior:

- Distinguish an unknown quest/entity ID from a temporary Blizzard cache miss and from a completed or unavailable quest.
- For a quest present in the native log, retain its title, objective progress, and tracking where the native API provides enough information. Omit unsupported Questie-specific locations or rewards.
- Keep processing other quests if one record is absent. Avoid permanently blacklisting a quest because metadata was temporarily missing.
- Report missing IDs in a bounded, deduplicated summary suitable for improving the database.

**Guardrail:** a runtime query does not establish spawn coordinates, prerequisite rules, or questgiver identity. Do not invent those to make an icon appear. Work through the actual dependencies before promising full native-only tracking.

## Optional initialization must not prevent core startup

**Observed:**

- The missing `AbandonSkill` hook aborted `QuestieProfessions.lua` before its profession constants and methods were defined. Later failures referenced nil `professionKeys`/`profKeys` in the menu and database corrections.
- Unsupported `OnTooltipSetItem`/`OnTooltipSetUnit` scripts stopped the initialization coroutine at tooltip setup.
- `QuestLogListScrollFrame` and old watch-frame assumptions failed before tracker setup completed.
- AceGUI's missing `SetDesaturation` call failed while options were being built.

Future behavior:

- Define required data independently of optional hook registration. A failed UI integration must not leave unrelated constants undefined.
- Separate core quest/database initialization from optional tooltips, menus, map controls, and presentation extras.
- At explicit feature boundaries, retain the original diagnostic and disable only that integration when continuing is safe.
- Track feature availability so dependent code does not later call half-initialized modules. Explain partial functionality rather than showing a success state for everything.
- If Questie's replacement tracker cannot initialize, leave or restore Blizzard's tracker instead of hiding both.

**Guardrail:** do not surround every initialization call with `pcall` and continue indiscriminately. Database/schema failures and missing core dependencies may require stopping the affected pipeline to avoid corrupting state.

## Quest events must not leave half-written state

**Observed:**

- Forever's changed `QUEST_ACCEPTED` payload produced `table index is nil` in `QuestEventHandler.QuestAccepted`.
- A missing `GetQuestTimers` call failed after `questLog[questId] = {}` but before normal acceptance handling. The native log contained quest 783 while Questie's quest state remained empty, despite `API.isReady` being true.

Future behavior:

- Normalize and validate event arguments at registration boundaries, including whether a value is a quest ID or log index.
- Treat timer information as optional to accepting an ordinary quest. Its failure should not prevent objective tracking.
- Commit a usable state transition only after required steps succeed, or retain an explicit retryable state.
- Reconcile recoverable failures against the native quest log on an appropriate later update. Make retries idempotent; do not replay every acceptance side effect blindly.

**Useful check:** unavailable timer support or an unresolved log index does not strand an accepted quest; later cache availability repairs tracking without duplicate sounds, announcements, or breadcrumb actions.

## Unknown races and client identities must not silently misclassify data

**Observed:**

- Project ID 1 selected an unmapped expansion before Forever detection existed, causing number-versus-nil comparisons in options and database corrections.
- Skyborne race ID 95 did not use bit 94. The old `2^(raceID-1)` formula rejected its actual bit-32 mask and legacy Alliance-wide masks without raising an error.

Future behavior:

- Validate content-family detection before entering expansion-dependent initialization. Unknown content should produce one clear unsupported-client diagnostic, not unrelated comparison errors.
- Keep content family separate from API capabilities; newer APIs do not mean Retail quest data.
- Treat an unknown playable race as missing eligibility metadata. Preserve native active-quest information while making uncertain available-quest predictions explicit.
- Represent race IDs and playable-race bits separately wherever metadata supplies the distinction.

**Guardrail:** do not default all unknown clients to Era, all unknown races to Human, or all same-faction race masks to allowed. Those choices hide errors by showing incorrect quests.

## Optional tooltip details should fail independently

**Observed:**

- The legacy `UnitAura` path failed while calculating reputation rewards for a map tooltip.
- Forever's named-color item link (`|cnIQ1:...`) confused the old parser and silently omitted objective text even though the objective lookup contained it.

Future behavior:

- Prefer stable payload IDs or native structured data over assumptions about localized text and color wrappers.
- If an optional detail such as a reputation modifier cannot be calculated, still show the quest title and objective information. Omit or qualify the uncertain detail rather than presenting a guessed reward.
- Make tooltip failure handling per-tooltip or per-detail, not a reason to abort the entire addon.
- Deduplicate failures from repeated hover/`OnUpdate` paths while keeping enough detail to diagnose them.

The current item-link parser fix is likely a one-time migration. Separating identity from presentation and isolating optional enrichment are the reusable improvements.

## Combat tooltip restrictions need live reproduction

See the [Forever tooltip reference](forever-tooltips.md#security-combat-and-restricted-data) for observed payloads, source-backed access boundaries, and the [focused test matrix](forever-tooltips.md#open-questions-and-focused-tests). Its proposed callback migration is not implemented yet.

The outsider's updated 303 zip attributes combat taint to the `GameTooltip` object-hover `OnUpdate` scanner. Its combat early-return, deferred modern callbacks, protected-text fallback, and blanket aura `pcall` were not adopted. The integrated client passed non-combat item-tooltip and aura checks, but real combat was not exercised. The scanner attribution therefore remains unverified; successful non-combat reads do not establish combat safety.

Next checks:

- Reproduce the exact failing read/call in and out of combat, recording client build and stack before selecting a workaround.
- If object scanning must stop in combat, document that loss of augmentation explicitly. An early-return is not proof that other taint paths are fixed.
- If a callback must be deferred, verify that the tooltip still represents the same entity when it runs, not merely that it is shown.
- Protect only demonstrated restricted-value operations. Preserve unexpected programming errors instead of wrapping all aura or tooltip work in `pcall`.

## Validate map geometry and UI assumptions without fabricating fallbacks

**Observed:**

- HBD selected Retail world-map transforms for Forever, shifting pins by up to roughly 20.7% of the map size without any Lua error.
- Krowi classified Forever's `1.x` version as the old Classic map and reparented Blizzard's modern buttons. Their parent `GetMapID`/`TriggerEvent` calls then failed.
- Native world rectangles for Zephras Isle and Darkspear Islands were all zeroes. Their zone maps are valid; a usable world placement was not supplied by those calls.

Future behavior:

- Validate geometry against native rectangles when available. Preserve valid out-of-range rectangle edges; reject missing or degenerate transforms.
- If world placement cannot be established, omit that world-level pin while retaining supported zone/minimap placement. Do not draw at `(0, 0)` or on an unrelated continent.
- Verify a third-party UI integration's expected frame/method structure before changing parents or installing hooks. If unsupported, leave Blizzard controls intact and skip Questie's optional control.
- Use capability/data checks instead of inferring an entire UI family from a version-string major number.

Some of this is already addressed by the current HBD and Krowi fixes. The remaining hardening is clear unsupported-placement behavior, broader validation, and safe handling of future layouts.

## Reject unsupported serialized data before it damages a cache

**Historical evidence, not an observed overflow:** Skyborne masks use bits 32/33, while the former consumer compiler stored `requiredRaces` as `u32`. That compiler was removed by the QuestieDB migration. This is no longer a claim about the active storage schema; validate high-bit values against the provider's actual Source/Baked and correction contracts.

Future behavior:

- Validate imported values against the provider storage/read contract before generation, correction publication, or cache replacement.
- Report the record ID, field, unsupported value, and schema/build involved.
- If the provider contract needs a wider representation, update its readers, writers, and caches together. Preserve existing usable data when an update cannot be encoded safely.

**Guardrail:** never truncate high bits, silently widen one side of the reader/writer contract, or reset unrelated user settings to hide a data failure.

## User-facing reporting for all of the above

A useful notice states what is unavailable, what still works, and what information is needed. For example, once partial-support behavior actually exists:

> Questie does not yet recognize Zephras Isle (map 2521). Zone-based tooltip details and affected map pins are unavailable here. Other Questie features remain available.

Keep the full technical record separately: addon/client version, operation, relevant IDs, first stack, occurrence count, and disabled capability. Avoid claiming a feature still works unless the fallback has been verified.

- Expected support gaps should not repeatedly open the Lua error window or print on every frame.
- Use notices visible to ordinary users; `Questie.Warning` currently depends on debug mode and is not sufficient for this purpose by itself.
- Keep unexpected programming errors observable. Deduplication must not erase the first useful stack or suppress unrelated failures.
- Bound diagnostic memory and avoid collecting unrelated chat/player data in a production diagnostic feature. Keep diagnostic collection focused on Questie's own failures.

## Suggested order

1. Non-throwing runtime zone lookup and deduplicated support-gap reporting.
2. Quest-event recovery and separation of optional startup/UI work from core state.
3. Missing entity/race metadata handling with explicit partial-support status.
4. Geometry/UI compatibility validation and import/schema safeguards as those areas are extended.

Already-correct API renames do not each need a new defensive framework. Harden the boundaries where absent, incomplete, or changed external data can recur, and add focused failure-path tests for those behaviors.
