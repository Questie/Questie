# Forever tooltip secrets: display versus inspection

## Scope and evidence

Initial investigation: Forever 1.60.1, build 70291. Matching Gethe `forever` source: `9465cb273b5513495d8ecc12fbb19930dd6b8957`.

A later build-70338 investigation compared two overlapping object-collection quests and checked alternate identity APIs. See [Forever hovered-object quest API audit](forever-object-tooltip-api-audit.md) for the matching source, full field comparison and live results.

This investigation distinguishes native display support from access to values in addon logic. It does not establish that every GameTooltip operation is safe in combat.

The hover observations came from `TooltipDataDebug` running inside Questie's ordinary line callback. The bridge read the inspector's already-sanitized snapshot afterward; it did not inspect the raw secret tooltip fields to produce those markers.

- Flintfire's Shipment's first Object snapshot marked text, quest ID and progress secret. After the user reported hovering it out of combat, the next snapshot exposed quest ID 98321 and progress, and the bridge confirmed combat was false. The first snapshot did not record its own combat flag, so this is a user-driven comparison, not an exhaustive test proving combat is the sole cause of secrecy.
- Crag Boar's out-of-combat Unit snapshot used `unitToken = "mouseover"`. After the user entered combat with that boar, a new snapshot used `unitToken = "target"`, retained readable GUID/NPC ID 1125, quest ID 384 and progress, and included `100% Threat`. The bridge confirmed combat was true at that read. This does not prove identical combat behavior for the world-mouseover path.

The temporary inspector retained the last snapshot after mouseout. Combat state queried separately by the bridge describes the moment of that query, not an independently timestamped state attached to the capture.

The operation tests below used `secretwrap("QUESTIE_SECRET_PROBE_70291")`, not hidden game data. They ran through the bridge, which reported an insecure context and no permission to access the synthetic secret. Failure messages identify `ForceTaint_Strong`. This is a bridge-context test, not a normal-addon combat certification. No reload, targeting change, combat-state change, or existing tooltip mutation was performed.

## Build 70338 follow-up

The user physically hovered Cactus Apple and Abandoned Training Weapon out of combat, then the training weapon in combat. These bridge captures recorded combat state and tooltip visibility in the same query:

| Data | Out of combat | Training-weapon combat capture |
|---|---|---|
| QuestTitle ID | 4402 for Galgar; 97279 for Wayward Weapons | Secret |
| Object caption, quest title and objective text | Readable | Secret |
| Objective counters | 0/10 for Galgar; 0/6 for Wayward Weapons | Secret |
| Completion, colors and wrapping | Readable | Secret |
| Tooltip/line types | Object 4; generic 0; QuestTitle 17; QuestObjective 8 | Same public categories |
| Quest-log objectives | Both public item objectives, objectiveType 1 | Still public, including IDs, text and counters |

Neither tooltip exposed an object GUID/ID, item ID or objective index. Knowing both quest-log objectives does not connect either to a secret hover. The audit's later combat probe also found no mouseover/softinteract unit identity, nameplate or vignette association. Fresh native tooltip data remained secret.

Direct operation probes on the combat Object tooltip confirmed that length, `string.len`, substring, search, pattern matching and comparisons fail. Formatting succeeds but leaves a secret result. Separate synthetic probes also rejected `string.gsub`, including replacement of a known title or just its `[??]` prefix. These operation probes ran through the force-tainted bridge, not a new ordinary-addon diagnostic.

A screenshot showed the active prototype rendering Cactus Apple's yellow `[??]` quest title and indented objective with no objective icon during the combat test sequence. The same sequence recorded combat active and the tooltip visible; no uncaught errors were recorded. The installed prototype commit was not recorded, so this is a narrow presentation smoke check, not certification of every path in PR #8014.

## Captured fields and identity

The relevant runtime enums on build 70291 were:

| Location | Value | Meaning |
|---|---:|---|
| `tooltipData.type` | 2 | `Enum.TooltipDataType.Unit` |
| `tooltipData.type` | 4 | `Enum.TooltipDataType.Object` |
| `lineData.type` | 0 | `Enum.TooltipDataLineType.None`, ordinary presentation text |
| `lineData.type` | 2 | `Enum.TooltipDataLineType.UnitName` |
| `lineData.type` | 8 | `Enum.TooltipDataLineType.QuestObjective` |
| `lineData.type` | 17 | `Enum.TooltipDataLineType.QuestTitle` |
| `lineData.type` | 18 | `Enum.TooltipDataLineType.QuestPlayer` |

These categories are not entity IDs. In particular, a Unit tooltip containing quest objectives remains a Unit tooltip. Use the public tooltip type to distinguish objects from units; do not infer Object merely from the presence of secrets.

### Object comparison: Flintfire's Shipment

| Field | Initial restricted snapshot | Out-of-combat re-hover |
|---|---|---|
| Tooltip type | 4, Object | 4, Object |
| `dataInstanceID` | 8093 | 8097 |
| Object caption | secret | `Flintfire's Shipment` |
| Quest-title `id` | secret | 98321 |
| Quest-title text | secret | `Flintfire's Shipment` |
| Objective text | secret | `0/8 Flintfire's Shipment` |
| `numFulfilled` / `numRequired` | secret / secret | 0 / 8 |
| `completed` | secret | false |
| Colors and wrapping fields | secret | readable |

The line types and visible structural indices remained public in the restricted snapshot. Neither captured Object payload supplied an explicit gameobject ID or GUID. The objective row did not supply an item ID or quest-objective index. This describes these samples, not every possible tooltip payload.

`dataInstanceID` identifies a tooltip data instance for refresh, not the world object. `lineIndex` is a rendered tooltip-row index, not a quest-log objective index.

### Unit comparison: Crag Boar

| Field | Out-of-combat hover | Combat read |
|---|---|---|
| Tooltip type | 2, Unit | 2, Unit |
| `dataInstanceID` | 8103 | 8112 |
| Unit token | `mouseover` | `target` |
| Name | `Crag Boar` | `Crag Boar` |
| GUID / health GUID | readable Creature GUID | same readable Creature GUID |
| NPC ID encoded in GUID | 1125 | 1125 |
| Quest-title `id` | 384 | 384 |
| Quest title | `Beer Basted Boar Ribs` | `Beer Basted Boar Ribs` |
| Objective text | `0/6 Crag Boar Rib` | `0/6 Crag Boar Rib` |
| `numFulfilled` / `numRequired` | 0 / 6 | 0 / 6 |
| `completed` | false | false |
| Other combat data | not recorded | `hasDynamicData = true`, `100% Threat` |

The Creature GUID's entry component supplies an NPC ID; it is not an item-drop ID. The objective row still supplied no explicit item ID or objective index. Public access in this sample does not establish access for all unit categories, PvP contexts or combat mouseovers.

### Quest-log objective comparison

A live `C_QuestLog.GetQuestObjectives(98321)` query returned this first array entry:

```lua
{
    type = "item",
    objectiveType = 1,
    text = "0/8 Flintfire's Shipment",
    numFulfilled = 0,
    numRequired = 8,
    finished = false,
}
```

This is a different type system: the quest-log API describes the objective's gameplay category, whereas tooltip line type 8 means an objective presentation row. `Enum.QuestObjectiveType` was not exposed in the queried client environment. The numeric value 1 above is the observed field alongside `type = "item"`, not a tooltip enum or an entity ID. The quest-log API uses `finished`; the tooltip row uses `completed`.

## Synthetic live results

| Operation | Result |
|---|---|
| `tostring(secret)` | Succeeds; result remains secret |
| `string.format("Value: %s", secret)` | Succeeds; result remains secret |
| `"Value: " .. secret` | Succeeds; result remains secret |
| `#secret` | Errors: attempt to get length of a secret string |
| Comparing the secret with the known original string in a branch | Errors: attempt to compare a secret string |
| `FontString:SetText(secret)` | Succeeds; `GetText()` returns a secret |
| `FontString:SetFormattedText("Value: %s", secret)` | Succeeds; `GetText()` returns a secret |
| Reading that FontString's `GetStringWidth()` | Succeeds; width remains secret |
| `scrubsecretvalues(secret)` | Call succeeds; documented behavior is removal, not disclosure |
| `print("Questie synthetic secret test:", secret)` | Outer call succeeds; no error-handler entry; chat capture records `<inaccessible value>` |

The temporary test FontString was on a hidden frame and cleared afterward. Formatting and concatenation are therefore not categorically forbidden, contrary to the earlier working assumption. Their outputs are still unsuitable for public comparisons, parsing, or identity lookup.

The chat capture is evidence that protected text reached the chat path. Its `<inaccessible value>` is the recorder's redaction, not a claim that Blizzard prints that literal marker. The later screenshot did not establish the exact visible test line because bridge diagnostic chatter had displaced it from the visible chat area.

## What Blizzard's code says

### Printing is an insecure display path, not declassification

[Blizzard_PrintHandler.lua:29-96](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_PrintHandler/Blizzard_PrintHandler.lua#L29-L96) converts print arguments using `tostring`, joins them, and sends the result to `DEFAULT_CHAT_FRAME:AddMessage`.

`print_inner` explicitly calls `forceinsecure()`. It catches handler failures itself and forwards them to the error handler. Consequently, `pcall(print, secret)` returning success is insufficient on its own; the live check also inspected the error stream and chat capture.

### Text widgets explicitly accept secret arguments

[SimpleFontStringAPIDocumentation.lua:539-547](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFontStringAPIDocumentation.lua#L539-L547) declares `SetFormattedText` as `AllowedWhenTainted`, adding the Text secret aspect.

[SetText and SetTextColor:664-688](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFontStringAPIDocumentation.lua#L664-L688) have analogous secret-aware presentation contracts. [GetText:353-365](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFontStringAPIDocumentation.lua#L353-L365) returns a secret when the Text aspect is secret. Rendering and reading back the text does not produce a public value.

Blizzard's [Dump.lua:97-113](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_SharedXML/Dump.lua#L97-L113) also formats primitive values for display. Its string-length/truncation path is guarded by `canaccessvalue`; formatting is separate from content inspection.

### The tooltip pipeline offers callbacks, not permission to inspect secrets

[TooltipDataHandler.lua:279-354](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua#L279-L354) runs pre-calls, renders lines, invokes post-calls, then shows the tooltip. A line pre-call returning true consumes a line; false allows normal rendering.

That provides an integration point for presentation. It does not transfer Blizzard's access privileges to addon callbacks. Avoid mutating `processingInfo.tooltipData` or replacing Blizzard's functions to attempt to gain privileges.

### Scrubbing is not unwrapping

[FrameScriptDocumentation.lua:374-439](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_APIDocumentationGenerated/FrameScriptDocumentation.lua#L374-L439) specifies that `scrubsecretvalues` replaces secret inputs with nil. `secretunwrap` is restricted and was absent in the live addon environment. `secretwrap` was available.

For presentation-specific choices, [C_CurveUtil.EvaluateColorFromBoolean and EvaluateColorValueFromBoolean](https://github.com/Gethe/wow-ui-source/blob/9465cb273b5513495d8ecc12fbb19930dd6b8957/Interface/AddOns/Blizzard_APIDocumentationGenerated/CurveUtilDocumentation.lua#L30-L63) explicitly accept potentially secret booleans in tainted code. They offer supported color transformations rather than a Lua branch on the secret. These helpers were not live-tested in this investigation.

## Consequences for Questie

- We can potentially improve presentation without first identifying the object. Pass secret text or progress to documented secret-capable widgets, keeping the values secret.
- A diagnostic view could show a public `secret` label beside a separate FontString rendering the actual value. It must not parse the rendered text or use text measurements as public layout decisions. The temporary inspector substituted markers and was not that renderer.
- Do not put secret values into the current generic string dump. Its sorting, truncation and layout measurements are designed for public snapshots. A display-only view needs a separate, bounded layout.
- Readable Unit GUIDs and quest IDs can support normal addon lookups when public. Secret Object names and quest IDs cannot become database keys simply because `tostring`, concatenation, printing, or a widget setter accepted them.
- Appending a public or secret line through the exact GameTooltip path still merits an ordinary-addon combat test. The hidden FontString probe does not prove every tooltip helper, measurement, or protected-frame operation is safe.
- No supported way to turn the secret Object payload into public identity data was established. Independent proximity inference remains an inference, not a revealed native ID.

## Object inference remains an untested idea

We discussed narrowing candidates by public tooltip type, active quests, current zone, known object spawns and player proximity. A single plausible candidate may permit an explicitly labelled inference without recovering native secret identity.

This has not been implemented or validated:

- Quest and objective sorting rules have not been established. One-quest, one-objective samples cannot establish ordering.
- A tooltip contains a filtered subset of relevant quests/objectives, not the entire quest log. Ordering alone cannot identify which entries were selected.
- Ambiguity can occur across different quests or within one quest when several object types satisfy the same objective or provide the same item.
- Render/server visibility bounds could narrow the search, but the actual Forever limits and their relationship have not been measured. No radius is approved for hardcoding.
- A unique candidate in our database is not proof if spawns are missing, stale, phase-dependent or incorrectly positioned. Do not silently choose the nearest when several candidates remain.

The display-only styling prototype below does not depend on this idea. It can present native secret text without knowing which object produced it.

## Temporary inspector (removed)

`TooltipDataDebug` was an investigation-only inspector that observed native quest line pre-calls without consuming them. It sanitized payloads inside the ordinary addon callback before displaying or retaining a snapshot. Secret values became markers; inaccessible tables were not enumerated. Work was bounded, and no history was stored in SavedVariables.

The inspector, its tests, TOC entries and `/qtooltipdata` command have been removed from the shipping implementation. The findings above remain as evidence; native styling does not depend on the inspector.

A line pre-call returning true means the line was consumed; false or nil permits ordinary rendering. For secret-data styling, a line is consumed only after adding its display-only replacement. For readable data, native quest lines are consumed up front and the normal Questie post-call supplies the replacement.

## Native-row styling prototype

Forever selects the rendering path before handling its QuestTitle, QuestObjective and QuestPlayer lines:

- Readable payloads use the normal Questie path: hide Blizzard's quest rows and let the existing Unit/Object post-call add Questie's richer replacement. Readable NPC data takes this path even during combat.
- Secret or inaccessible payloads use the native-data fallback described below. The predicate examines the full payload before hiding a public title, because a later objective or the entity identity can be secret. It does not compare or parse secret values.
- Secrecy, not a blanket combat check, selects styling. Readable native rows stay visible when the legacy instance or group-size policy prevents Questie replacement.

- `Forever` selects a known quest's current level and Questie's standard title difficulty color using public quest-log candidates and secret-capable native helpers. Candidate colors come from `QuestieLib:GetDifficultyColorPercent`, matching normal Questie titles rather than Blizzard's different RGB palette. No selected ID or match boolean becomes public. Missing candidates/APIs or native-helper errors retain yellow `[??]` rather than dropping text or guessing.
- Show Quest Levels (`enableTooltipsQuestLevel`) controls the level prefix. Show Quest IDs (`enableTooltipsQuestID`) displays the supplied native ID through formatting, or `???` when no usable ID was supplied. A secret ID is formatted directly for display without a lookup.
- Public candidate levels/colors are built lazily once per native tooltip rebuild and discarded on `OnTooltipCleared`. Secret input payloads and outputs are not cached.
- Objective/player text receives three spaces of indentation and Questie's default near-white color. Text is not parsed, measured or stripped of markup.
- `GameTooltip:AddLine` receives the formatted value, which can remain secret. Title rows are unwrapped so native sizing includes the full title and optional quest ID; objective/player rows still wrap. Native tooltip code owns sizing and the final Show call. This does not use `TooltipLayout` or replace the tooltip with `SetText`.
- In the secret-data fallback, unknown two-column rows and inaccessible payloads keep their native rendering. Fallback ownership prevents a second legacy Questie quest block and its FontString reads. Public payloads outside the instance/group-size exceptions do not take ownership away from normal Questie augmentation.
- Ownership resets on OnTooltipCleared, including rebuilds that reuse a dataInstanceID.
- Other clients retain the previous native-line suppression and legacy augmentation. No diagnostic UI or callbacks are included.

A further synthetic live probe formatted a secret string and secret numeric ID together, then successfully passed the result to AddLine on a hidden GameTooltip. It explicitly recorded `inCombat = false`. At that point, visible combat styling still required a reload and a physical hover test; no reload was performed by that implementation task. The later build-70338 presentation smoke check is recorded above.

This is a restricted-data fallback, not a replacement for normal Questie tooltips. A selected level/color comes from public quest data through a native secret-preserving selector. Yellow and `[??]` remain the unknown fallback, not a claimed quest difficulty or level. When the secret native quest block owns rendering, the legacy block is not appended, so its separate drop-rate, provider, party and ID annotations are not automatically retained. With readable data, the normal replacement and its annotations remain enabled. The later Cactus Apple screenshot had no objective icon; other payloads and locales remain unverified. The prototype deliberately assumes no icon needs stripping and passes native text unchanged apart from its prefix.

## Validation and next checks

Recorded automated validation in the original blob workspace after the styling review fixes:

- 70 focused tooltip/inspector tests passed.
- 3,233 full-suite tests passed; local log: `cli/output/forever/tooltip-styling/busted.log`.
- Focused source lint and loader-usage validation passed.
- Review fixes preserve non-Forever suppression, prevent the inspector starting on other clients, and keep fallback-only native blocks from also invoking legacy augmentation.

Before inspector removal, PR-worktree validation on `master` base `ffefa6362` (without the unrelated blob changes): 77 focused tests and 2,788 full-suite tests passed after restricting styling to secret data, along with full source lint and loader validation. At that point the inspector was opt-in. Review found no non-Forever behavior regression; this is code/test coverage, not live certification of every Classic client.

After inspector removal and wiring ID display to Show Quest IDs, 69 tooltip tests and 2,780 full-suite tests passed, along with source lint and loader validation. Focused review of inspector removal found no dangling dependencies or callback-order reliance. The ID-display setting now matches normal Questie tooltips.

The later implementation adds `Forever.CreateFormatter` to the Forever title path. Its focused tests cover public candidate selection, unknown fallback, both display settings, duplicate entries, cache refresh, native failures and opaque-ID forwarding. Unit tests use public native-helper stand-ins; actual secret behavior was established by the synthetic and combat bridge probes in the [API audit](forever-object-tooltip-api-audit.md#actual-combat-object-title-probe). Ordinary-addon callback integration still needs a live hover after loading this revision. Validation of the integrated implementation passed 84 focused tests and 2,795 full-suite tests, full source lint and loader validation. Focused review found no concrete security/correctness issue; follow-up tests cover partially secret candidate metadata and all-unavailable candidates becoming readable on a later rebuild.

Still needed before claiming production combat safety:

1. Complete a controlled before/during/after-combat hover sequence with the exact PR commit recorded. The build-70338 captures and screenshot cover only part of this check.
2. Compare NPC world mouseover with the target-token path during combat.
3. Exercise multiple quests/objectives, completion and stationary progress refreshes. Verify wrapping, native fallback, ordering and absence of duplicate/stale rows.
4. Check Show Quest IDs, disabled tooltip settings, party rows, non-English text and any icon markup. Never infer general availability from an unobserved payload shape.

Successful synthetic formatting is not proof of every protected UI operation. Combat lockdown, forbidden frames and secret-value access are separate constraints, not a blanket prohibition on rendering addon text.
