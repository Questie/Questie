# Potential tracker simplifications

Unchecked items are candidates for follow-up work, not an agreed implementation plan. Keep the Blizzard-first tracker data module and preserve existing loading, completion and combat behavior.

## 1. Give objective loading one owner

- [x] Make `QuestLogCache` the sole owner of objective loading and last-valid progress for the tracker.

`TrackerData` now uses the existing read-only `QuestLogCache.questLog_DO_NOT_MODIFY` table to obtain the last valid snapshot or nil without logging or fetching. The tracker no longer falls back to objective API reads, validates readiness, or maintains its own last-valid fallback. Native quest-log metadata still supplies titles before objectives load.

The cache handles unavailable responses and missing objective types. Loading-screen regression protection remains active through incomplete scans. One cancellable 20-second timer provides a fallback when no further event arrives: it resets the marker timestamp and calls `QuestLogUpdate`. Natural full scans cancel it; a cache miss or pending acceptance rearms it. Startup also schedules a fallback when quests are present.

Tests cover recovery without new events, cancellation by natural scans, delayed acceptance, removal before retry, and retained progress through loading-screen cache misses. The shared loading helper remains available to other consumers, including party quests outside the local quest log.

## 2. Remove unused map-field copies

- [x] Remove unused map-state and raw-text copies from display objectives.

Removed `AlreadySpawned`, `Icon`, and `RawText` copies from display objectives. Map actions already use the original Questie objective through `enrichment`; they do not need copied icon state. Full objective wording still uses the cached raw text when constructing `FullDescription`.

Retained `spawnList`, which `DistanceUtils` reads for proximity and navigation. Objective identity and index fields are unchanged. Missing-source-item objectives copy their display fields explicitly instead of cloning every original field. Familiar field names remain, but future additions to the original object will not silently introduce map state or behavior into the display record.

Tests verify navigation, source-item wording and counters, and hide/show map actions using original enrichment objects. Loading, completion and map-eligibility rules are unchanged.

## 3. Make reads and refreshes explicit

- [x] Separate snapshot getters from full and single-quest refresh operations.

- `GetQuest(id)` and `GetQuests()` only read the current snapshot. They do not query the client or change membership.
- `Refresh()` updates all display records once at the start of a full tracker layout, before visibility and sorting reads.
- `RefreshQuest(id)` explicitly refreshes one quest for tracking changes, combat-safe text updates and commands that must revalidate current state.

Sorting and menu construction no longer refresh implicitly. Focus restoration uses an explicit single-quest refresh before the first full layout. Snapshot objects retain their existing identity and are updated by refresh operations, not copied on reads.

Tests cover side-effect-free getters, explicit metadata/progress updates, layout ordering, combat-safe updates and startup focus restoration.

## 4. Define map eligibility once

- [ ] Share the rules that decide whether a quest or objective supports focus or navigation.

`TrackerData`, `TrackerMenu` and `TrackerUtils` currently make related enrichment checks independently. During implementation, the menu could offer focus for a completed quest while the focus function rejected it.

Use the same eligibility rules for menu construction and action execution. Keep any distinction between focus and navigation explicit; they may need different data.

Actions must recheck eligibility because a quest can change or disappear while its menu is open. Continue operating on verified original enrichment objects.

## Constraints

Do not simplify away:

- Delayed objective loading and last-valid-state behavior.
- Numeric completion/failure, Questie's additional completion boolean, and source-item exceptions.
- Protection against associating live progress with the wrong database objective.
- Combat-safe text updates and secure item-button restrictions.

Review wording-based objective matching separately. It can reject valid enrichment, but removing it would weaken protection against changed objectives.

Suggested order: remove unused fields, unify map eligibility, make refreshes explicit, then consolidate objective loading.
