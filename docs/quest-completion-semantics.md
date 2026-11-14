# Quest completion signals in Blizzard's UI

This is a historical investigation. Objective wording/status changes were implemented afterward, and the positively classified sequenced-quest completion fix is documented in [sequence-quests.md](sequence-quests.md#completion-fix-after-the-capture). Code-departure notes and line numbers below describe the investigated version, not the current checkout.

## Scope and source versions

This is a source-backed investigation, not a code change. The native client and server implementations of completion checks are not published in this source tree. The Lua establishes how Blizzard consumes the signals, not how the native criteria engine calculates them.

Both read-only source caches were successfully refreshed for this investigation:

| Branch | Commit | Commit subject | Comparison target |
| --- | --- | --- | --- |
| `forever` | `966519cf0ad2c10301ea011a88c14b25697c9687` | `1.60.1 (70124)` | Matches the live bridge identity confirmed during this investigation. |
| `classic_era` | `8165d4cd6e48d606369336cc3a7977902310e81e` | `1.15.9 (70003)` | Source comparison only; no live Era client was probed. |

Source paths in citations are relative to `https://github.com/Gethe/wow-ui-source`. No live calls, quest changes, reloads, or provider changes were performed by the source-research pass. The parent investigation's screenshot, runtime, and offline findings are recorded separately below.

## The signals are not interchangeable

| Signal | What Blizzard uses it for | What it does not establish |
| --- | --- | --- |
| `C_QuestLog.IsComplete(questID)`; legacy `IsQuestComplete(questID)` | Quest-wide current completion, including ready-for-turn-in presentation and completed map-pin presentation. | Whether the quest has already been turned in, or whether a particular objective's displayed count is a sufficient completion rule. |
| Legacy `GetQuestLogTitle(index)` completion slot | Signed completion/failure status in the old quest log. Modern callers obtain completion and failure separately. | A distinct, independently calculated modern status source when an addon synthesizes the tuple using the boolean APIs. |
| Objective `finished` | Completed objective labels, colors, hiding, and completion animations. | Whole-quest readiness in the presence of other conditions such as money requirements. |
| Objective `numFulfilled` / `numRequired` | Numeric progress exposed alongside the objective's completion flag. | A documented guarantee that equality means `finished == true`. |
| `C_QuestLog.IsQuestFlaggedCompleted(questID)` | Completed-history/turn-in state, separate from active quest objective completion. | Readiness of an active quest. |
| `IsQuestCompletable()` | Whether the current NPC quest-progress dialog enables its completion button. It takes no quest ID. | A replacement for querying an arbitrary quest in the log. |

The distinction between active completion and turn-in history is particularly explicit in Blizzard's tutorial manager: it raises `Quest_ObjectivesComplete` from `C_QuestLog.IsComplete`, then later raises `Quest_TurnedIn` from `IsQuestFlaggedCompleted` ([source][tutorial]). The ordinary tracker uses `IsComplete` to select completion text or `QUEST_WATCH_QUEST_READY` ([source][tracker-state]). The NPC progress dialog separately calls `IsQuestCompletable()` to enable its button, whose click handler calls `CompleteQuest()` ([source][dialog-completion]).

## Forever's actual display policy

### Whole quest

`QuestObjectiveTrackerMixin:UpdateSingle` reads `quest:IsComplete()`. That method is a direct call to `C_QuestLog.IsComplete(self:GetID())`, not a loop over objective counters ([quest object][quest-object]).

The tracker separately calls `C_QuestLog.IsFailed(questID)`. When complete, it shows completion/turn-in instructions; when failed, it shows a failed line; otherwise it renders objectives and any unmet money requirement. It passes the same quest completion value into `block:SetPOIInfo` ([source][tracker-state]). This is the completion state consumed by Blizzard's quest tracker, not a claim about server-side reward acceptance.

The quest log independently follows the same policy: `C_QuestLog.IsComplete` selects completion text; otherwise it loops through `GetQuestLogLeaderBoard` and shows unfinished rows. It also handles unmet required money separately ([source][quest-list]).

### Individual objective

`QuestObjectiveTrackerMixin:DoQuestObjectives` reads `text, objectiveType, finished = GetQuestLogLeaderBoard(...)` ([source][tracker-objectives]).

- If the whole quest is complete, existing lines can finish their completion animation even if their individual objective was not marked finished. Blizzard explicitly comments on this case.
- Otherwise, `finished` controls the completed/unfinished line state. This path does not reconstruct completion from numeric progress.
- An unfinished `objectiveType == "progressbar"` gets a separate progress bar using `GetQuestProgressBarPercent(questID)`. The percentage is presentation data, not the condition deciding the `finished` branch.

Quest detail text also appends `" (Complete)"` only when the returned `finished` value is truthy ([source][quest-details]).

Generated documentation exposes **both** `finished: bool` and `numFulfilled`/`numRequired: number` in `QuestObjectiveInfo`, plus optional numeric `objectiveType`. It specifies no equivalence between those fields ([structure][objective-structure]). The field is `numRequired`, not `numNeeded`.

### Load-path check

These are not merely unrelated Retail files found in the branch:

- `Blizzard_ObjectiveTracker.toc` loads `Blizzard_QuestObjectiveTracker.lua` and then explicitly loads the Camelot override ([manifest][tracker-toc]).
- The complete Camelot override only changes `CanShowTimerBar` to return false. It does not replace objective or completion logic ([override][tracker-override]).
- `Blizzard_ObjectAPI.toc` includes `[Family]\\Quest.lua` for the mainline family ([manifest][object-toc]).
- `Blizzard_UIPanels_Game.toc` loads the family QuestInfo and QuestMapFrame implementations, with explicit Camelot overrides/utilities for the latter ([QuestInfo manifest][panels-toc], [QuestMapFrame manifest][map-panels-toc]). The inspected Camelot QuestMapFrame override/utilities contain no replacement of the completion checks above.

## Legacy status versus modern status

Classic Era's Vanilla quest log reads the sixth return from `GetQuestLogTitle` and displays Failed for negative values or Complete for positive values ([source][era-title]). Its code guards with `isComplete and ...`, so this source does not justify claiming that an unfinished quest always returns exactly numeric zero.

The Era objective detail view uses `GetQuestLogLeaderBoard(...).finished`, not parsed counts, for the completed suffix ([source][era-objectives]). Its legacy quest watch also uses `finished`, with a historical nil-to-true fallback, and brightens the quest title when all objective flags are finished. That title-color policy is not a new quest-wide turn-in predicate ([source][era-watch]).

Legacy shared map-pin code calls `IsQuestComplete(questID)` for completed-pin styling ([source][era-pin]); its Classic manifest includes that provider ([manifest][era-pin-toc]). This establishes the corresponding legacy caller, not that the old and namespaced Lua handles are aliases of one native function on every client. Their runtime availability still needs capability checks. No `IsQuestComplete = C_QuestLog.IsComplete` assignment was found in the prepared Forever tree.

Forever's generated `C_QuestLog.GetInfo` result **does not contain `isComplete` or `isFailed`**. It contains metadata such as `isAutoComplete`, which is not a completion result ([structure][quest-info]). Completion and failure are separate boolean API calls ([declarations][complete-failed]).

In this checkout, `Modules/QuestieCompat.lua:440–469` already synthesizes the legacy title tuple from those calls: failure gives `-1`, completion gives `1`, and unfinished remains `nil`. Thus on Forever the tuple's status and `C_QuestLog.IsComplete` are not independent corroborating votes. Questie's downstream `0` state is its own normalization/policy.

## Criteria-tree objectives and the reported 1/1 unfinished case

The prepared Forever documentation references the type name `QuestObjectiveType`, but this source tree does not define its enum members. In particular, it does not independently establish the supplied numeric mapping `14 = CriteriaTree`. That mapping needs the separately collected runtime enum or a matching-build extraction. Do not promote a server-emulator enum list into a Blizzard API contract.

For a reported row with `numFulfilled = 1`, `numRequired = 1`, and `finished = false`, Blizzard's ordinary incomplete-quest display path treats the objective as unfinished. There is no special counter-equality override for type 14 in the inspected code. It is therefore unsafe for Questie to turn the numeric equality into objective completion merely because the numbers resemble a kill/item counter.

This source cannot explain *why* that criteria-tree row has those counts. It contains neither quest 92598's criteria tree nor the native evaluator. Claims such as a dummy count, rounded progress, a hidden child criterion, or a delayed server update would need further evidence. Before/after runtime records can establish which flags change without needing to reconstruct that evaluator.

### Available detail APIs and limits

- The ordinary quest UI consumes `GetQuestLogLeaderBoard`; `C_QuestLog.GetQuestObjectives` exposes structured objective summaries ([declaration][objectives-api]). Neither cited interface exposes a full criteria-tree graph.
- `GetQuestProgressBarPercent(questID)` is the explicit percentage source for `"progressbar"` display rows ([tracker source][tracker-objectives]). Its presence does not mean every criteria-tree objective is a progress bar.
- `GetQuestLogCriteriaSpell()` is used for a **spell-learning** objective widget ([source][criteria-spell]); despite its name, it is not a general quest criteria-tree query.
- The branch also contains scenario criteria APIs such as `C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)` and `GetCriteriaInfoByStep(stepID, criteriaIndex)`. They are scenario-scoped, not a demonstrated arbitrary quest-ID-to-criteria-tree API ([declarations][scenario-criteria]). Do not substitute them for quest 92598 without a supported association.

## Screenshot and runtime evidence

The supplied screenshots show the same objective for quest **92598**, "Use Skysight near the Elemental Convergence":

| Field | `92598-not-complete.png`, 23:45:09 | `92598-complete.png`, 23:47:31 |
| --- | --- | --- |
| `type` | `"object"` | `"object"` |
| `objectiveType` | `14` | `14` |
| `numFulfilled` | `1` | `1` |
| `numRequired` | `1` | `1` |
| `finished` | `false` | `true` |

Images were read from `/mnt/c/Users/Logon/Downloads/`. Neither image includes a quest-wide `IsComplete` result, a client build, or the legacy leaderboard result. They prove that counter equality cannot distinguish these two objective states; they do not establish what those other APIs returned at either timestamp.

Read-only bridge probes confirmed Forever **1.60.1, build 70124, interface 16001**. `C_QuestLog.IsComplete` is callable; globals `IsQuestComplete` and `GetQuestLogTitle` are absent. `Enum.QuestObjectiveType` is absent too. At the initial probe, quest 92598 was not in the logged-in character's quest log and returned no objective data. That initial false completion result is not evidence about the screenshot transition. A subsequent in-log probe is recorded below.

The current quest **92461** provides a control: both structured objectives and `GetQuestLogLeaderBoard` return unfinished `0/8 Juvenile Vuldren slain`; `IsComplete` and `IsFailed` are false, and Questie's compatibility title tuple has nil completion status. No quests were accepted, advanced, or turned in, and no reload or settings change was performed.

The supplied research note was found at `/home/logon/projects/Questie-clones/Questie-PR-Review/quest-objective-types.forever.md`. It describes build-70009 captures, not this runtime build. It explicitly attributes numeric names to TrinityCore rather than a Blizzard enum definition. Its six observed numeric categories exclude 14; the screenshots supply the additional observed value. The nearby `quest-objectives-horde.forever.json` entry for 92598 records a timeout and empty placeholder row, not a valid objective capture. It cannot override the screenshot evidence.

## Sequenced quests

`IsQuestSequenced(questID)` is available in the observed Forever build. Blizzard's quest search explicitly says that sequenced quests' objectives can change, and revisits their objectives rather than treating an earlier unsuccessful search as final ([search implementation](https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestMapFrame.lua#L17-L83)).

The tracker uses this classification to omit previously completed rows, defer a new row while another is completing, and animate newly appearing rows ([objective rendering][tracker-objectives]). Completed rows fade out for sequenced quests ([line animation](https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_QuestObjectiveTracker.lua#L419-L430)). Quest-wide completion still comes from `C_QuestLog.IsComplete`.

This establishes "this quest uses sequenced objectives", not "there is definitely another objective after this one" or a remaining-stage count. The inspected code supplies no basis for interpreting false as proof that objective enumeration is exhaustive, or for equating sequencing with numeric objective type 14.

Live read-only results: quest 92461 returned `sequenced=false`, `HaveQuestData=true`, and was in the log. Quest 92598 also returned `sequenced=false` and `HaveQuestData=true`, but was not in the log; this does not establish its sequencing status during the supplied screenshot transition.

### Follow-up with quest 92598 in the log

After the user reported accepting the quest, a read-only probe on the same build confirmed **The Gift of Skysight (92598)** at quest-log index 4:

- `HaveQuestData=true`, `IsQuestSequenced=false`.
- `C_QuestLog.IsComplete=false`, `IsFailed=false`, `IsQuestFlaggedCompleted=false`; Questie's signed title status was nil.
- Structured objective: `type="object"`, `objectiveType=14`, `numFulfilled=1`, `numRequired=1`, `finished=false`.
- Legacy `GetQuestLogLeaderBoard` also returned `finished=false` for "Use Skysight near the Elemental Convergence".
- Questie's cache retained `finished=false`, counts 1/1, and quest `isComplete=0`.
- The tracker quest remained incomplete, but its objective had **`Completed=true`**.
- The enriched quest had empty `ObjectiveData` and `Objectives`, yet **`isComplete=true`**, matching the separate missing-objective fallback problem observed for 92461.

This corroborates the screenshot's unfinished objective state and the predicted tracker misclassification in the live addon. It also establishes that the active type-14 objective is not classified as sequenced in this observed state. The completed transition has not yet been captured with all APIs together. The probe did not advance the quest or change addon state.

## Optional objectives

The inspected Forever tracker does not parse an "Optional" label or calculate which objective rows are required. It uses native quest-wide completion, and otherwise renders each row according to its `finished` flag ([tracker state][tracker-state], [objective rendering][tracker-objectives]). Consequently, an unfinished optional row need not prevent the UI from showing a complete quest when the quest-wide API says complete. The native evaluator's rules are not visible in this Lua source, and no optional-objective completion transition was captured in this investigation.

`QuestObjectiveInfo` has no declared `isOptional` field, and `objectiveType` is not an optionality flag ([structure][objective-structure]). In the supplied build-70009 capture at `/home/logon/projects/Questie-clones/Questie-PR-Review/quest-objectives-horde.forever.json`, quest 92679's second successful `delayedRead` row is `"0/1 Listen to Alvarion Windfield's Story (Optional)"`, with `type="monster"`, `objectiveType=0`, counts 0/1, and `finished=false`. This is historical captured data, not a new live test. It demonstrates that an optional-labeled objective can share the same numeric category as ordinary creature credit.

A separate UI concept is optional waypoint guidance: `C_QuestLog.GetNextWaypointText` is explicitly formatted with `WAYPOINT_OBJECTIVE_FORMAT_OPTIONAL`, outside the objective-row loop ([details][quest-details], [tracker][tracker-state]). This does not expose optionality for arbitrary objective rows.

For Questie, neither "every objective must be finished" nor "all visible objectives finished means the quest is complete" is a generally sufficient quest-wide rule. Keep raw objective status separate from quest-wide status; Blizzard may complete/fade displayed rows when the whole quest finishes without asserting that each raw objective flag became true. Do not parse localized "(Optional)" text to decide completion.

## Where Questie currently departs from Blizzard

These references describe the inspected working tree, including pre-existing tracker changes:

- `Modules/Tracker/TrackerData.lua:84–85` treats `"object"` as countable and marks equal positive counts complete even when `live.finished == false`. Type 14 still arrives with that coarse string type. `GetObjectiveText` also appends counts for it at lines 205–215.
- `Modules/Quest/QuestieQuest.lua:1475–1476` makes the same counter-equality inference for enriched objectives. `UpdateQuest` at lines 563–597 can then promote all enriched objectives being complete into a quest-level completion override and finisher icon. That route requires those enriched objectives to exist; it is not an observation that it occurred for quest 92598.
- `Modules/Quest/QuestLogCache.lua:170–180` retains raw `finished` and counts but drops numeric `objectiveType`. Its completion fallback at lines 201–205 promotes all objective flags being finished into whole-quest completion when the native tuple reports nil. This is separate from the counter-equality bug and can ignore conditions not represented by those rows.
- The empty-enriched-objectives fallback at `Modules/Quest/QuestieQuest.lua:1443–1450` is another independent override. It explains the live false finisher for quest 92461, whose provider has no structured objectives despite the client's unfinished row.
- `Modules/Libs/QuestieLib.lua:103–129` colors objectives using their counts, so changing only the `Completed` field would not resolve all misleading completed-looking presentation. Objective-completion sounds in `QuestLogCache.lua:160–162` also use counter equality.

A small isolated Lua probe loaded the actual `TrackerData` and `TrackerQuestieBehavior` modules with mocked client/cache dependencies, without changing source files. Given a type-14 `"object"` row and cached quest completion 0, it produced:

```text
input=1/1 finished=false; display objective.Completed=true; quest completionState=0
input=1/1 finished=true;  display objective.Completed=true; quest completionState=0
```

This confirms the objective misclassification in current tracker code. The quest-wide state was deliberately held at 0 in the probe; this is not a reproduction of quest 92598's full live lifecycle.

## Implications for a Questie change

These are recommendations derived from the source, not implemented behavior:

1. Preserve the native quest completion/failure result as the baseline for quest-wide readiness. Do not replace an explicitly incomplete result just because all known database objectives are absent or numeric counts match.
2. Use objective `finished` as the baseline for objective status. Keep counters for progress display. A completed whole quest can still require Blizzard's documented UI behavior of marking remaining displayed rows complete.
3. Retain raw `finished`, raw counters, numeric `objectiveType`, and any Questie override separately enough to diagnose disagreements. Avoid silently losing the numeric objective type at the cache boundary.
4. Treat existing Classic workarounds as explicit, evidenced exceptions. The source comparison alone does not prove it is safe to remove all of them, or that every current native API result is free of loading/transient bugs.
5. Do not use `IsQuestFlaggedCompleted` or dialog-only `IsQuestCompletable()` as a generic replacement for active quest completion.

No production code or tests were changed by this research. Validation consisted of reading complete relevant functions, checking flavor inclusion, and rechecking both source SHAs before writing the citations.

[quest-object]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectAPI/Mainline/Quest.lua#L50-L52
[tracker-state]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_QuestObjectiveTracker.lua#L291-L375
[tracker-objectives]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_QuestObjectiveTracker.lua#L208-L288
[quest-list]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestMapFrame.lua#L1879-L1948
[quest-details]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestInfo.lua#L193-L271
[objective-structure]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L1581-L1592
[tracker-toc]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_ObjectiveTracker.toc#L35-L37
[tracker-override]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectiveTracker/Camelot/Blizzard_QuestObjectiveTrackerOverride.lua#L1-L3
[object-toc]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_ObjectAPI/Blizzard_ObjectAPI.toc#L13
[panels-toc]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Blizzard_UIPanels_Game.toc#L100-L104
[era-title]: https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_UIPanels_Game/Vanilla/QuestLogFrame.lua#L150-L200
[era-objectives]: https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_UIPanels_Game/Vanilla/QuestLogFrame.lua#L383-L403
[era-watch]: https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_UIPanels_Game/Vanilla/QuestLogFrame.lua#L636-L701
[era-pin]: https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_SharedMapDataProviders/QuestDataProvider.lua#L134-L166
[era-pin-toc]: https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_SharedMapDataProviders/Blizzard_SharedMapDataProviders_Classic.toc#L9
[quest-info]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L1547-L1579
[complete-failed]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L734-L777
[tutorial]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_TutorialManager/Blizzard_TutorialQuestManager.lua#L122-L145
[objectives-api]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua#L477-L490
[criteria-spell]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestInfo.lua#L273-L306
[scenario-criteria]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_APIDocumentationGenerated/ScenarioInfoDocumentation.lua#L11-L43
[dialog-completion]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/QuestFrame.lua#L166-L216
[map-panels-toc]: https://github.com/Gethe/wow-ui-source/blob/966519cf0ad2c10301ea011a88c14b25697c9687/Interface/AddOns/Blizzard_UIPanels_Game/Blizzard_UIPanels_Game.toc#L173-L178
