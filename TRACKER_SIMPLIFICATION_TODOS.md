# Potential tracker simplifications

Unchecked items are candidates for follow-up work, not an agreed implementation plan. Keep the Blizzard-first tracker data module and preserve existing loading, completion and combat behavior.

## 1. Give objective loading one owner

- [x] Make `QuestLogCache` the sole owner of objective loading and last-valid progress for the tracker.

`TrackerData` now uses the existing read-only `QuestLogCache.questLog_DO_NOT_MODIFY` table to obtain the last valid snapshot or nil without logging or fetching. The tracker no longer falls back to objective API reads, validates readiness, or maintains its own last-valid fallback. Native quest-log metadata still supplies titles before objectives load.

The cache handles unavailable responses and missing objective types. Loading-screen regression protection remains active through incomplete scans. One cancellable 20-second timer provides a fallback when no further event arrives: it resets the marker timestamp and calls `QuestLogUpdate`. Natural full scans cancel it; a cache miss or pending acceptance rearms it. Startup also schedules a fallback when quests are present.

Tests cover recovery without new events, cancellation by natural scans, delayed acceptance, removal before retry, and retained progress through loading-screen cache misses. The shared loading helper remains available to other consumers, including party quests outside the local quest log.

## 2. Remove unused map-field copies

- [ ] Remove display-record fields that have no consumer or duplicate data accessed through `enrichment`.

Display objectives retain their original Questie objective through `enrichment`, but also copy fields such as `AlreadySpawned` and `Icon`. Map interactions now operate on the original object. `RawText` is also assigned without a current consumer.

Audit consumers before removing fields. Keep the display data and original-object reference, plus any fields still required by existing callers. Do not replace original map objects with display copies in actions that mutate map state.

## 3. Make reads and refreshes explicit

- [ ] Separate snapshot getters from full and single-quest refresh operations.

The current interface mixes behaviors:

- `Refresh()` updates all display records.
- `GetQuests()` reads the snapshot.
- `GetQuest(id)` refreshes one quest and scans preceding quest-log entries for its header.

Make getters read-only and invoke refreshes explicitly from update paths. This should prevent menu and focus reads from unexpectedly fetching or rebuilding data.

Preserve single-quest refreshes for combat-safe progress updates. Check startup and event ordering so consumers do not receive stale or missing records after the change.

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
