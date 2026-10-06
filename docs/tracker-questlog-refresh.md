# Quest-log tracker refresh

`QUEST_LOG_UPDATE` still reconciles quest data and retries loading quests. It requests `QuestieTracker:Update(true)`, which refreshes native tracker data before deciding whether a full layout is needed. Opening an unchanged quest log can therefore skip sorting, pool resets and frame formatting without removing the resync check.

Ordinary `QuestieTracker:Update()` calls bypass the unchanged-data check. Settings, resizing, tracking commands and the delayed rebuild after objective changes retain that behavior. These calls still obey the existing startup, combat and throttle guards; they do not guarantee an immediate rebuild.

## Snapshot lifetime

`TrackerQuestLogSnapshot` copies the display inputs for ordinary quest layouts: membership, titles, levels, grouping, sorting tags, completion, objective values, completion instructions, tracking and collapse state, and the native quest count used by the header.

The tracker captures candidate inputs before changing frames and saves them as the baseline only after a full layout completes. Incremental combat-time text updates do not advance that baseline. Explicit update requests invalidate it even when throttled, so later reconciliation cannot hide an outstanding UI change.

A throttled quest-log check schedules one trailing retry through the combat queue. Its pending guard spans both the timer and the queue. It reads current data when delivered, rather than retaining an earlier quest snapshot. This retry is separate from the quest event handler's coalesced update request.

## Conservative fallbacks

The tracker retains full rebuilds for:

- Active quest-item button candidates or quest timers anywhere in the native quest log, including untracked quests.
- Proximity sorting or an unknown sort mode.
- Tracked achievements, scenarios and challenge modes.
- VoiceOver integration, startup and interactive movement/resizing.

Item selection is shared with the renderer through `TrackerUtils.GetQuestItemIds`. Ordinary collection objectives without a usable item do not require the item-button fallback.

## Validation

Offline tests cover unchanged reconciliation, late metadata/objective loading, removal, completion, sorting tags, mutable display records, explicit updates, throttle/combat retries and failed layouts.

Live CPU timings and visual checks are still required. With the same quest log and settings, compare repeated openings after startup, then test objective progress, accepting/removing a quest, completion and a combat-to-out-of-combat transition. Confirm fallback cases still rebuild. Do not interpret reduced layout call counts as a measured millisecond improvement.
