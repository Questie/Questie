# Forever tooltip data and integration reference

Forever exposes structured tooltip data through `C_TooltipInfo` and renders it through template mixins and `TooltipDataProcessor`. Our live probes confirm that Unit callbacks can include quest IDs and objective progress, and Object callbacks can identify the displayed object text. These are useful alternatives to reading rendered FontStrings every frame.

**The narrow Object callback migration is implemented; broader tooltip refactoring remains pending.** Forever now uses primary Object post-calls instead of the per-frame object scanner. Classic retains native Item/Unit scripts and object polling. The historical Forever experiments below preceded this change; the new implementation has been live-tested only on Classic, out of combat. See [implementation and validation](#implemented-object-callback-path).

For integration status, see [Forever development](forever-development.md). Broader recovery work remains in [the hardening backlog](forever-hardening-backlog.md). Provider-owned name lookup is described in [QuestieDB integration](questiedb-integration.md#object-hover-name-resolution).

## Scope and evidence

### Client and source identity

- Live client: Forever `1.60.1`, build `69913`, interface `16001`.
- The client reports `WOW_PROJECT_ID = 1`, but uses Classic-family content. API capability and content family are separate decisions.
- All tooltip captures described here were **out of combat** and used English text. The Classic migration checks have a separate build/source record [below](#classic-validation).
- Questie and its Source-mode QuestieDB provider were running. ForeverClassicUI was also loaded; this was not an isolated-addon test.
- Diagnostics ran through WoWDevBridge, with callbacks/timers executing in the session. No new tooltip frames were created by the probes.
- Matching Blizzard source: Gethe's `forever` branch, refreshed at commit `70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e`, subject `1.60.1 (69913)`.

The source links below are pinned to that commit. Its Lua/XML explains published behavior, not every native restriction or future client version. We did not test current Retail or establish a Retail support guarantee.

### Three kinds of evidence

| Evidence | What it establishes | What it does not establish |
| --- | --- | --- |
| Live API/callback samples | Those calls and fields worked in the observed context. | Universal field presence, combat access, all locales, or all frames. |
| Matching Blizzard implementation | The published retrieval, rendering, callback, and refresh sequence. | Every native access rule or exact behavior under a different taint identity. |
| Proposed Questie changes | A direction supported by the observations. | Implemented behavior or proven replacement coverage. |

A bridge is not a neutral security context. Repeat restricted-access tests through Questie's ordinary addon callbacks before attributing a bridge-only failure to the production path.

## The modern tooltip pipeline

### Retrieval and rendering are separate

The relevant layers are:

```text
C_TooltipInfo.GetX(arguments)
  -> structured TooltipData
  -> template/mixin ProcessInfo
  -> tooltip pre-calls
  -> line processing and line callbacks
  -> tooltip-specific post-call
  -> global tooltip post-calls
  -> Show and remaining presentation work
```

A direct `C_TooltipInfo` query retrieves data without requiring a tooltip frame. A template method such as `tooltip:SetItemByID(id)` retrieves data and processes it into a frame. These operations should not be treated as interchangeable.

In one synchronous probe, direct item/player queries generated **zero** registered tooltip post-call callbacks. This agrees with the source separation: callbacks belong to `ProcessInfo`, not arbitrary data retrieval. It is not a benchmark or a guarantee about every API's side effects.

The matching [data handler][handler] retains an information list, resolves a getter when data was not supplied, clears lines for non-append processing, processes lines, runs post-calls, and shows the frame. An absent data result hides a non-append tooltip and returns failure.

### Templates restore familiar methods

The migration statement that native GameTooltip methods were removed does not mean every familiar method is absent from the resulting frame. [GameTooltipTemplate][template] mixes in `GameTooltipDataMixin`, which derives from `TooltipDataHandlerMixin`.

The source supplies:

- Setter delegates such as `SetItemByID`, `SetUnit`, `SetSpellByID`, and `SetHyperlink` through the data handler.
- Compatibility getters `GetItem`, `GetSpell`, and `GetUnit` through [GameTooltipDataMixin][mixin].
- Getter interpretation through [TooltipUtil][util], using primary structured data rather than scraping displayed lines.
- `supportsDataRefresh = true` and the event wiring needed for data refresh.

For example, the current `GetUnit` compatibility implementation resolves a unit token from the primary data's GUID. A GUID can exist while a usable unit token is unavailable. Callers must not assume the two always arrive together.

The source marks `GetTooltipData()` as an alias to be deprecated in favor of `GetPrimaryTooltipData()`. The former worked in our probe; its presence is not a reason to prefer it for new code.

The loading path is visible in [Blizzard_GameTooltip's TOC][tooltip-toc] through `[Family]` Lua/XML, and in [Blizzard_SharedXMLGame's TOC][shared-toc]. The latter includes the handler and mainline-gated utility/rule files. The matching runtime exposed the corresponding methods and event registration. A directory named `Mainline` alone would not prove loading on Forever.

### Global callbacks require frame filtering

`TooltipDataProcessor.AddTooltipPostCall(type, callback)` registers with a shared processor, not a single tooltip instance. The callback receives the tooltip and the processed data.

The live value of `TooltipDataProcessor.AllTypes` was `"ALL"`. The recorder used it to observe all types passing through the processor. Production handlers should register the types they actually handle and explicitly restrict supported frames.

Current Questie policy is:

- Item: `GameTooltip` and `ItemRefTooltip`.
- Unit: `GameTooltip` only.
- Other frames, including comparison and scanning tooltips: not automatically eligible for those augmentations.

This matters because hidden scanning frames and other addons' frames can use the same pipeline. A global callback must not assume its target is visible or is `GameTooltip`.

A post-call runs after that information block's lines have been processed, but before the handler's final `Show()`. It is not an unconditional “all UI work has finished” event. Append processing and comparison tooltips can introduce other blocks or frames.

### Ordering and security isolation

The pinned handler maintains separate secure and insecure callback tables. Registration selects a table using `issecure()`; insecure callbacks are wrapped with `forceinsecure()` and dispatched through `securecallfunction` and an attribute delegate.

Within each category, `AllTypes` callbacks run before type-specific callbacks. Callbacks for a given key are appended and traversed in registration order. Secure post-calls are processed before insecure post-calls. Therefore, our `AllTypes` recorder must not be treated as a snapshot taken after every addon's type-specific callback.

Post-call return values do not terminate processing. Pre-calls can consume processing. The exported processor in this source provides registration functions, but no removal function. Repeated registration would accumulate callbacks unless the caller prevents it.

These mechanisms isolate callback execution; they do **not** make arbitrary addon reads, comparisons, or writes secure. A callback cannot use this registration API to bypass secret-value or protected-frame rules.

### Payloads are not private mutable state

The handler stores the information/data tables used during processing. Blizzard's own rules can modify line presentation, such as color and indentation, and the handler sets `lineIndex` while rendering.

Questie should treat callback payloads as shared inputs. Do not attach Questie state to them or rewrite them merely to simplify later rendering. Copy only the accessible fields required for a particular operation into Questie-owned state.

This is an ownership recommendation, not a claim that every returned table is frozen. We did not test payload mutability or table-freezing contracts here.

## Updates, rebuilding, and transient state

### Data updates are keyed by instance identity

[GameTooltipDataMixin][mixin] handles `TOOLTIP_DATA_UPDATE` as follows:

1. Read the event's `dataInstanceID`.
2. Accept the event if no ID was supplied or if `HasDataInstanceID` matches one of the frame's information blocks.
3. Schedule refresh for an upcoming tooltip update.
4. By default, rebuild the tooltip from the retained information list. The [update dispatcher][update-dispatch] first calls `owner:UpdateTooltip()` or `self:UpdateTooltip()` if present; those override the default `RefreshData()` path.

The handler's rebuild path clears cached data for information blocks with a getter, then processes them again. Data supplied without a getter is treated as complete. Primary append state is normalized to avoid duplicating the first block; optional rebuild callbacks also exist.

Consequences for an addon:

- Rebuilding can run post-calls again without the user moving the cursor.
- Rendering augmentation must be repeatable without growing duplicate lines.
- A retained `dataInstanceID` is an update key, not a stable quest/entity ID.
- Information blocks can be appended; primary data is not necessarily the block currently being processed.
- Absence of a callback in a short recording is not proof that a type cannot update.

We verified registration of the update event on Questie's existing scanner. We did **not** deliberately trigger an uncached-item completion or a quest-progress change under a stationary tooltip. Those lifecycle cases remain tests to run.

### Visible text can outlive primary data

During the timed sampling, some visible tooltips briefly had text but no type reported by `GetTooltipData()`. The source's world-cursor path can clear handler information and fade the old tooltip when the cursor leaves its object. That provides a plausible explanation, but no event trace proved the cause of every sampled transition.

`GetWorldCursor()` and `GetUnit("mouseover")` also briefly differed during cursor transitions. They are separate queries, not an atomic snapshot. Do not combine a name from one instant with a GUID from another without checking identity.

Deferring a callback to the next frame requires the same care: “the tooltip is still shown” is insufficient. It may now display another entity. Preserve and recheck accessible identity or update state before applying deferred work.

## Capability and coverage inventory

| Surface | Evidence on build 69913 | Remaining limit |
| --- | --- | --- |
| `AddTooltipPostCall` / `AllTypes` | Worked for five observed tooltip types. | Not every frame or type was exercised. |
| `C_TooltipInfo.GetUnit("player")` | Returned type, GUID, and typed lines. | No combat/PvP restriction matrix. |
| `C_TooltipInfo.GetUnit("mouseover")` | Returned NPC/player data while hovering units; no unit data for the observed Object case. | Cursor transitions are transient. |
| `C_TooltipInfo.GetWorldCursor()` | Returned Unit and Object data; no data over empty ground. | No exhaustive cursor-content matrix. |
| `C_TooltipInfo.GetItemByID` | IDs 159 and 4739 returned item data. | Cold-cache/update behavior not exercised. |
| `C_TooltipInfo.GetSpellByID` | ID 20552 returned spell data. | No aura or restricted-combat test. |
| `C_TooltipInfo.GetBagItem` | Function presence confirmed. | Not directly invoked by this test. |
| `C_TooltipInfo.GetHyperlink` | Function presence confirmed. | Not directly invoked by this test. |
| `TooltipUtil.SurfaceArgs` | Absent at runtime; data fields already populated. | Older clients may have a different representation. |
| `QuestieScanningTooltip` | Existing frame, setter/data getter methods, and `TOOLTIP_DATA_UPDATE` registration confirmed. | Does not prove all custom frames refresh correctly. |
| `issecretvalue` | Function presence confirmed; recorders used it for redaction. | No claimed secret-value/combat coverage. |

### Initial callback counts

These counts cover exactly the first two 20-second manual hover windows. They exclude the later direct-API and quest-objective probes.

| Tooltip type | Numeric value | First window | Second window | Total |
| --- | ---: | ---: | ---: | ---: |
| Unit | 2 | 54 | 12 | 66 |
| Item | 0 | 0 | 25 | 25 |
| Spell | 1 | 0 | 11 | 11 |
| Object | 4 | 2 | 8 | 10 |
| Macro | 25 | 0 | 9 | 9 |
| Total | | 56 | 65 | 121 |

These are callback invocations, not distinct entities or user hovers. The recorders reported no errors and no dropped records in those windows. That is narrower than a claim that the whole addon session had no errors.

## Reading the data correctly

### Tooltip types and line types are different enums

Use `Enum.TooltipDataType` for a complete data block and `Enum.TooltipDataLineType` for an individual row. Their numbers overlap and have different meanings.

| Observed line type | Value | Meaning in the sample |
| --- | ---: | --- |
| `None` | 0 | General text, such as level, class, faction, or object caption. |
| `UnitName` | 2 | Unit name and, in the observed cases, a unit token. |
| `QuestObjective` | 8 | Native objective text and progress fields. |
| `SellPrice` | 11 | Item price information, not necessarily visible left text. |
| `SpellName` | 13 | Spell title. |
| `QuestTitle` | 17 | Quest title with quest ID. |
| `ItemBinding` | 20 | For item 4739, “Quest Item”. |
| `ItemName` | 22 | Item title, sometimes with quality. |
| `SpellDescription` | 34 | Spell description. |
| `ItemSpellTriggerOnUse` | 44 | Use-effect text in the direct item-159 query. |

Names and values are corroborated by [the matching enum definitions][enums]. `QuestTitle` and `QuestObjective` were also checked against runtime enum values.

A Unit tooltip containing quest lines is still `TooltipDataType.Unit`. It does not become `TooltipDataType.Quest` merely because a row refers to a quest.

### Observed fields and their boundaries

| Location | Fields seen | How to interpret them |
| --- | --- | --- |
| Data block | `type`, `lines`, `dataInstanceID` | Content type, ordered rows, and observed update identity. Instance ID was present in callback samples. |
| Unit block | `guid`, `healthGUID` | Unit identity and health-bar association; neither is a bare NPC ID. |
| Item/Spell/Macro block | `id` | Meaning depends on the block type. |
| Item block | `guid`, `isAzeriteItem`, `isAzeriteEmpoweredItem`, `isCorruptedItem` | Context/instance and presentation fields. The sampled booleans were false. |
| Line | `type`, `leftText`, `rightText`, colors, `wrapText`, `lineIndex` | Presentation plus type-specific fields. Not every field appears on every row. |
| Unit-name line | `unitToken` | A token such as `mouseover` or `player`, not persistent identity. |
| Quest-title line | `id` | In the objective-mob sample, quest ID 747. |
| Quest-objective line | `completed`, `numFulfilled`, `numRequired` | Native progress; absence is different from zero or false. |
| Item-name / price line | `quality`, `price`, `maxPrice` | Item context observed in a callback; not a universal item schema. |

`lineIndex` is not a quest objective index. The handler writes it using the rendered line count, and some rules render special content. Captured item/spell rows even share a `lineIndex`. Do not use it as stable entity or objective identity.

### Do not parse fixed display positions

The player samples included a class line before the faction line, and another sample included a guild line. A rule such as “line 3 is always faction” is wrong for this evidence.

Prefer typed fields and stable IDs where available. Ordinary `None` rows do not acquire a semantic meaning merely from their position. Localized text is not an identifier.

### Examples are projections, not a complete schema

The examples below retain observed fields relevant to Questie. Colors and incidental rows are omitted. Player identifiers are replaced with explicit placeholders; NPC spawn-specific GUID portions are redacted. Placeholder strings are documentation redactions, not API values or valid identifiers to send back to the client.

The diagnostic formats also omit nil fields and bound nested data. A missing field in a dump is evidence about that dump, not proof that the API can never return it.

## Unit data

A simplified player callback looked like this:

```lua
{
    type = 2, -- Enum.TooltipDataType.Unit
    guid = "<redacted-player-guid>",
    healthGUID = "<redacted-player-guid>",
    dataInstanceID = 202,
    lines = {
        {type = 2, leftText = "<player name>", unitToken = "mouseover", lineIndex = 1},
        {type = 0, leftText = "Level 1 Tauren (Player)", lineIndex = 2},
        {type = 0, leftText = "Druid", lineIndex = 3},
        {type = 0, leftText = "Horde", lineIndex = 4},
    },
}
```

A separate direct player query returned the same kind of structure with `unitToken = "player"`. NPC Grull Hawkwind returned matching Unit data from `GetWorldCursor()` and `GetUnit("mouseover")` in one sample.

Questie currently parses Creature/Vehicle GUIDs to resolve NPC IDs. A future callback consumer can use the supplied GUID rather than recovering it through the frame and a mutable `mouseover` token. It must still distinguish Players, Creatures, Vehicles, absent data, and inaccessible values.

### Quest-objective mobs

The first short 10-second attempt captured no visible tooltip. A retry with a three-second lead-in and ten-second window captured Plainstrider, NPC 2955, associated with quest 747, “The Hunt Begins”.

The relevant callback data was:

```lua
{
    type = 2, -- Unit, not Quest
    guid = "Creature-<redacted-instance-fields>-2955-<redacted-spawn>",
    dataInstanceID = 501,
    lines = {
        {type = 2, leftText = "Plainstrider", unitToken = "mouseover", lineIndex = 1},
        {type = 0, leftText = "Level 1", lineIndex = 2},
        {type = 0, leftText = "Beast", lineIndex = 3},
        {type = 17, id = 747, leftText = "The Hunt Begins", lineIndex = 4},
        {
            type = 8, leftText = "0/7 Plainstrider Meat", lineIndex = 5,
            completed = false, numFulfilled = 0, numRequired = 7, wrapText = true,
        },
        {
            type = 8, leftText = "0/7 Plainstrider Feather", lineIndex = 6,
            completed = false, numFulfilled = 0, numRequired = 7, wrapText = true,
        },
    },
}
```

This establishes that native Unit tooltip data can already contain quest identity and numeric objective progress. Extracting those fields does not require parsing `"0/7"` from text.

It does not establish a stable objective index or item ID for each objective line. The sampled objective rows contained neither. Associating lines with a preceding quest title is plausible for this example but requires multiple-quest, party, special-objective, and reordering tests before becoming a general parser contract.

The rendered tooltip contained both native title/objective lines and Questie's appended title/objectives with `80%` drop rates. The native sample ordered meat before feathers; Questie's displayed additions ordered feathers before meat. Positional matching between the two representations is therefore unsafe even in this small case.

The 80% values came from Questie's additions, not from the sampled native objective rows. Native text does not replace provider drop data, party attribution, spawn information, availability policy, or Questie's richer annotations.

## Item, spell, and macro data

### Items

The sampled item callback for Refreshing Spring Water contained `type = 0`, `id = 159`, an item GUID, a quality-bearing ItemName row, and a SellPrice row with `price = 2` and `maxPrice = -1`. Its sampled left text on the price row was empty; special rendering rules can still use that row.

A direct `GetItemByID(159)` query instead included the use-effect description:

```lua
{
    type = 0,
    id = 159,
    lines = {
        {type = 22, leftText = "Refreshing Spring Water"},
        {type = 44, leftText = "Use: Restores 145 mana over 18 sec.  Must remain seated while drinking."},
        {type = 11, leftText = ""},
    },
}
```

The hover callback and generic-ID query were not identical contexts or synchronized snapshots. This difference does not prove that callbacks lose item data or that the generic getter is always more complete. Bag slot, item instance, link modifiers, cache state, and rendering rules need their own comparisons.

For quest item 4739, the direct query returned ItemName “Plainstrider Meat” and ItemBinding “Quest Item”. It did not contain Questie's appended quest title/progress. Use structured data for native facts, not as a readback of every addon-rendered line.

Using callback `data.id` could remove the modern item path's need to parse a hyperlink just to identify an item. Legacy clients and existing presentation behavior still need explicit handling.

### Spells and macros

Spell 20552, “Cultivation”, supplied `type = 1`, its ID, a SpellName row, ordinary text rows, and a SpellDescription. A hover sample included `rightText = "Racial"`; the separate direct query did not. Again, do not assume context-independent formatting.

A Macro callback supplied `type = 25`, `id = 1`, and a line naming a reload macro. This confirms delivery for that tooltip, not permission to inspect or execute arbitrary macros. Questie's current Item/Unit augmentation does not need to handle it.

## Object data and the remaining name lookup

Observed Object callbacks included Burning Embers and Bloodhoof Village:

```lua
{
    type = 4, -- Enum.TooltipDataType.Object
    dataInstanceID = 248,
    lines = {
        {type = 0, leftText = "Burning Embers", lineIndex = 1},
    },
}
```

No object ID or GUID appeared in these Object examples. This is an observed limitation, not a declaration that no Object tooltip can ever contain identity fields.

`GetWorldCursor()` also returned Object data for Bloodhoof Village while `GetUnit("mouseover")` returned no data. Object classification alone does not establish an interactable quest object; captions such as these must not be turned into assumed entity IDs.

The current provider lookup remains necessary when only a name is available:

```text
accessible object name
  -> LibQuestieDB.Object.IdsByName(name)
  -> provider-wide name uniqueness determines zone disambiguation
  -> local/eligible party registrations and spawn checks
  -> Questie tooltip lines, with duplicate lines removed
```

[TooltipHandler.lua](../Modules/Tooltips/TooltipHandler.lua) uses zone filter `0` only for a provider-wide unique name. Ambiguous names use the player's area/parent relationship. No matches or no relevant registrations are valid results, not reasons to invent an ID.

The implemented Object post-call replaces Forever's per-frame “not a unit/item/spell” classification. It does not solve unknown zones, missing provider content, localization gaps, or ambiguous names.

## Current Questie implementation

| Area | Current behavior | Consequence for migration |
| --- | --- | --- |
| [Tooltip initialization](../Modules/Tooltips/Tooltip.lua) | Requires both the processor and the frame's `GetPrimaryTooltipData` pipeline for post-calls. Classic retains available tooltip-set scripts, checked with `HasScript`. Initialization registers hooks only once. | Processor presence alone does not prove native callback delivery. Unit/Item handlers still do not consume callback data. |
| [Unit handler](../Modules/Tooltips/TooltipHandler.lua) | Calls frame `GetUnit`, queries GUID, falls back to mouseover, and appends registry-derived lines. | Structured identity could avoid re-reading mutable frame/token state. |
| Item handler | Calls frame `GetItem`, extracts `item:<ID>`, and performs quest-start/registered-objective lookup. | Preserve named-color support and quest-start behavior if switching to callback IDs. |
| Object frontend | Forever handles public text from primary Object post-calls. Classic retains the frame-getter/FontString `OnUpdate` scanner. Both use the existing provider-backed name/zone resolver. | No Object polling or `CountTooltip()` reads on the structured path; its live Forever coverage remains to be verified. |
| Duplicate detection | Forever Object callbacks use a per-clear flag. Unit/Item and Classic paths retain shared last-name/type/frame/count state and `CountTooltip()` reads. | Same-payload rebuilds are covered by tests; actual Forever clears/refreshes and the remaining FontString readers still need validation. |
| Custom row layout | [TooltipLayout](../Modules/Tooltips/TooltipLayout.lua) measures and renders Questie-owned rows, with a template-based gap-measurement tooltip. | This is presentation measurement, not native entity scanning. Structured retrieval does not replace it. |
| Journey item pre-cache | [QuestieSearchResults](../Modules/Journey/QuestieSearchResults.lua) creates `QuestieScanningTooltip` with `GameTooltipTemplate`, calls `SetItemByID`, and waits for cached item data. | Do not remove the scanner based only on warm direct-query success; its cache/layout purpose needs separate validation. |

Unit/Item handlers reject forbidden frames and disabled tooltip settings. Several tooltip paths also skip processing above the existing group-size threshold. These are existing policies, not new losses introduced by the probes.

The live scanner check confirmed `SetItemByID`, `GetTooltipData`, and `TOOLTIP_DATA_UPDATE` registration. The inspected other custom tooltip constructors also specify `GameTooltipTemplate`. No missing-template fix was demonstrated or applied.

The older migration notice lists removed tooltip-set script handlers. It does not imply a one-to-one tooltip-type replacement for every behavior: for example, the matching Blizzard rules handle sell-price money through a `SellPrice` line post-call. Preserve the intended behavior rather than mechanically translating script names.

## Implemented Object callback path

[Tooltip.lua](../Modules/Tooltips/Tooltip.lua) selects structured callbacks only when `GameTooltip.GetPrimaryTooltipData`, processor registration, and tooltip enums are available. The Object callback additionally requires its enum. Classic exposes some of these shared APIs without using the structured rendering pipeline, so neither project ID nor processor presence alone selects this path.

The Forever Object callback:

- Accepts only `GameTooltip` and its primary data block, not appended blocks, scanning frames, or comparison frames.
- Preserves forbidden-frame, enabled-tooltip, group-size, and map-icon exclusions.
- Rejects secret values and tables with secret contents before inspecting payloads, line containers, the title row, or its text. Missing, empty, or non-string names add nothing. These conservative checks do not attempt to recover restricted data.
- Uses the public first-line name with the existing provider name/zone resolver. Object IDs are not guessed; captions with no matching registrations add no quest lines.
- Marks augmentation before rendering and resets that flag on `OnTooltipCleared`, not `OnShow`. A repeated callback adds once; clearing permits the same payload and `dataInstanceID` to be rendered again.

The Object renderer now only appends lines. Classic's scanner explicitly calls `Show()` afterward to resize; Forever leaves the final `Show()` to Blizzard's processing pass. Initialization is idempotent because processor callbacks cannot be unregistered.

This change does not migrate Unit/Item identity handling, remove their `CountTooltip()` reads, alter native-versus-Questie objective duplication, or change the public `GetTooltip`/Comms contracts. It adds no blanket combat early-return. Unknown-zone lookup remains an independent failure boundary.

### Classic validation

The tested Classic client was **2.5.6, build 69795, interface 20506, project ID 5**. Matching refreshed source was `classic_anniversary` commit `1463c686270b6c64e2c5c228f447c4597c0f8ba6`. Era was not separately live-tested. The earlier Forever source remains pinned to build `69913`; no new Forever implementation run was performed in this phase.

Before reloading the change, Classic exposed processor registration and Item/Unit/Object enums, but lacked `C_TooltipInfo`, `GetPrimaryTooltipData`, `GetTooltipData`, and `RefreshData`. A disposable `GameTooltipTemplate` probe produced one native Item script and one native Unit script, **zero modern callbacks**, and no probe errors. This demonstrated why the former processor-only selection was wrong for Classic.

After reloading the change:

- Questie reported started and API ready, with no visible error dialog.
- A native item setter rendered Questie's Item ID line; a player-unit setter reached Questie's Unit handler.
- Explicit `ClearLines()` on a temporary template fired one `OnTooltipCleared` event.
- A public synthetic caption, taken from provider Object 2843 and displayed for 0.2 seconds, exercised Classic polling and produced one Object ID line without duplicates.

These were out-of-combat setter/synthetic-caption probes, not physical world-object hover or combat tests. Temporary tooltip settings were restored. No installation links or provider data changed.

Recorded automated validation: 62 focused tooltip tests and 1,958 full-suite tests passed. Focused source lint passed. Review found no production issue; its secret-text test concern was addressed by marking a nonempty string secret in the mock, so ordinary type rejection cannot satisfy that test. Mocks do not reproduce native secret-value enforcement.

Local, ignored evidence is under `cli/output/forever/tooltip-migration/`: `classic-capabilities.json`, `classic-delivery.json`, `classic-reload.json`, `classic-native-render.json`, `classic-clear-lifecycle.json`, and `classic-object-render.json`. The new Forever callback still needs live primary/append, clear/rebuild, stationary-update, physical-hover, and combat checks.

## Security, combat, and restricted data

### What the evidence says

All successful examples were out of combat. No captured normal value proves that the same field will remain accessible during combat, PvP, another unit category, or another taint context.

The matching generated documentation declares:

- [FontString `GetText`][fontstring] can return secret data for the Text aspect.
- [Unit aura lookup][aura-api] requires unit-aura access and can return secret data when auras are restricted.
- [`C_TooltipInfo.GetUnit`][unit-api] takes a `UnitTokenPvPRestrictedForAddOns` and permits secret arguments only under its stated untainted-call policy.
- [`GetWorldCursor`][cursor-api] may return nothing. Its declaration does not establish unrestricted inspection of every field it might return.

`IsForbidden()` concerns access to a frame. A non-forbidden frame is not proof that its text or associated data is safe to compare, concatenate, hash, use as a table key, or otherwise inspect.

Rendering and inspecting are also different capabilities. The handler's secure setter delegates are specifically designed to let permitted callers display standard tooltips while preserving access checks. That does not grant the addon permission to unpack all underlying secret data.

### The scanner report remains unproven

The outsider's updated 303 zip attributed combat taint to the object `OnUpdate` scanner and proposed an early return in combat. That workaround, deferred callbacks, protected-text fallback, and blanket aura `pcall` were not adopted.

The removed Forever scanner combined repeated frame getter calls, text comparisons, FontString counting, zone lookup, and optional augmentation. Classic still uses that scanner. Forever's new Object callback avoids those scans and rejects secret inputs, but the evidence does not yet identify the original combat failure or establish combat safety. Unit/Item FontString reads and aura inspection remain separate risks.

Avoid two unsupported conclusions:

- “The modern callback API makes the whole tooltip path combat-safe.” It does not validate Questie's callback body.
- “All tooltip/aura access is forbidden in combat.” Our investigation has not established such a blanket rule.

A protective boundary should skip only unsupported enrichment when safe, preserve native content, and leave unexpected programming errors diagnosable. A `pcall` can record an error; it does not establish that silently omitting the result is correct.

### Diagnostic limitations

The recorders use `issecretvalue` to replace observed secret values with a marker before serialization. That is diagnostic redaction, not a reviewed production strategy for every nested secret or restricted operation. The probes themselves were not combat-tested.

Zero recorder errors means no error reached the recorder's guarded operations in those windows. It is not a complete game-error audit, taint-log analysis, or proof of secure hardware execution.

## Remaining migration and validation

1. **Validate the implemented capability boundary.** Classic rendering was checked on the build above; verify other supported clients separately.
2. **Validate the implemented Object replacement on Forever.** The structured path no longer installs the old scanner. Check physical hovers, primary versus appended blocks, clears, refreshes, and transitions before treating replacement coverage as established.
3. **Use callback identity for Unit and Item.** Prefer accessible GUID/ID fields over frame getter/text recovery, with explicit handling of absent identity.
4. **Verify Object idempotence live and extend it deliberately.** Tests cover per-clear behavior, including reused payloads. Exercise native rebuilds, appended blocks, hidden/reused frames, and rapid entity changes; Unit/Item deduplication remains unchanged.
5. **Choose a duplicate-content policy.** Native quest lines already overlap Questie's. Decide whether to retain both or add only information missing from native rendering. Preserve drop rates, party attribution, quest-start/turn-in markers, and user settings.
6. **Define restricted-data behavior from evidence.** Identify a narrow skip/defer boundary rather than disabling every tooltip in combat or swallowing every exception.

A native quest-title/progress fallback could help display an active quest absent from the provider. It would not establish spawn coordinates, item drops, prerequisites, stable objective IDs, or complete Questie tracking. That remains the [partial-support proposal](forever-hardening-backlog.md#missing-entity-data-should-be-an-explicit-partial-support-state), not functionality supplied by these samples.

Do not change `GetTooltip` key/return contracts casually: the existing source notes external consumers such as Plater. A frontend callback migration should not silently alter the registry/Comms contract.

## Open questions and focused tests

The live scenarios below remain future checks. Unit tests cover several Object branches, and Classic synthetic probes establish only the narrower behavior recorded above. Use physical hovering and the ordinary addon path where security matters. Agree on combat testing before starting; no inventory destruction, quest abandonment, purchases, or binding changes are needed for this matrix.

| Priority | Question | Smallest useful scenario | Evidence to retain and cleanup |
| --- | --- | --- | --- |
| 1 | Which operation becomes restricted in combat? | Hover the same quest mob, player, item, and object before/during/after ordinary combat. | Build, combat state, callback type, redacted fields, exact error/stack and addon-context comparison. Stop all timers afterward. |
| 1 | Can Object callbacks fully replace modern polling? | Hover object, empty ground, object again; include a quest object and a location caption. | Callback/visibility sequence, accessible identity/text, final additions, and no stale lines. Leave panels as found. |
| 1 | Does stationary content refresh correctly? | Hold a tooltip while an ordinary quest-progress or metadata update occurs. | Instance/update identity, callbacks, counts, and rendered lines before/after. Do not manufacture progress by altering inventory. |
| 1 | Are additions idempotent? | Re-hover one mob/item repeatedly, then switch rapidly between two. | No accumulating titles/objectives and no previous entity's additions. Stop recorder and close temporary panels. |
| 2 | How are multiple quest groups associated? | Hover a mob relevant to two existing quests. | QuestTitle IDs, intervening line types, objective fields and order. No assumption that row index equals quest objective index. |
| 2 | What party data is native versus Questie-owned? | With consenting party members, hover a shared objective at different progress. | QuestPlayer/group structure, attribution, privacy-redacted samples, and retained Comms additions. Restore temporary group/UI setup. |
| 2 | Which frame contexts should be augmented? | Bag hover, item link, comparison tooltip, and an ordinary Journey item view. | Frame identity and data type; no additions to unintended scanning/comparison frames. Close opened panels. |
| 2 | Are direct item queries equivalent for the intended use? | Compare ID, hyperlink, and bag-slot getters for one existing item. | Context parameters, modifiers, price/use rows and cache state. No item movement required. |
| 2 | Does a cold-cache query complete asynchronously? | Inspect a safe, initially uncached item through its normal UI. | Initial nil/partial result, update event, rebuild and final layout. Bound waits; do not clear unrelated caches. |
| 2 | Can object identity be supplied directly? | Hover several interactable object categories, including same-name objects. | Full accessible identity fields and provider name/zone result. Do not infer IDs from labels. |
| 2 | Does localization change grouping assumptions? | Repeat representative hovers on a supported non-English client. | Typed fields versus translated text and provider name matching. Coordinate locale changes with the user. |
| 3 | What other types carry useful quest information? | Safe Achievement, Quest, EquipmentSet, aura, or QuestPartyProgress tooltip views where available. | Type-specific payloads and restrictions; no claim of unavailability if not encountered. |
| 3 | What is the actual polling cost removed? | Measure ordinary hover paths before/after an implemented replacement. | Calls/work per interval and frame impact on the same client. Callback counts alone are not CPU measurements. |

Also untested: currency, corpse, pet, mount, toy, recipe, instance-lock, and other declared types; failed/completed/timed quests; PvP-restricted units; all combinations of tooltip settings; and other live client flavors. An enum entry is not proof that a suitable example exists on this character.

## Diagnostic method and local evidence

### Recorder behavior

`QuestieTooltipProbe` registered one `AllTypes` post-call and used a 0.1-second timer to sample the main tooltip's visibility, first line, and current data type. `Start` resets its histories; `Stop` deactivates the callback and cancels its ticker/stop timer.

Its snapshot bounds were:

- 80 entries per callback/sample/error history, with a dropped counter.
- Three table levels, at most 30 entries per copied table.
- Strings truncated to 400 bytes.
- Secret values replaced by `"<secret>"`; deeper tables by markers such as `"<table>"`.

The direct-API recorder, `QuestieTooltipInfoProbe`, queried cursor and mouseover data every 0.15 seconds, retaining up to 60 identity-change samples. Its projection kept up to 15 lines and 500-byte strings, not every returned field. Getter/projection failures were returned as error records.

The objective-mob probe separately sampled up to 20 rendered left-side FontStrings every 0.2 seconds and retained up to 25 changed snapshots. Its separate ticker received its own timed cancellation; the base recorder's `Stop()` does not know about that extra ticker.

These caps and projections make the results inspectable, not exhaustive. In particular:

- `"<table>"`, `"<secret>"`, and the recorder's `truncated` key are not native payload fields.
- Colors were often reduced to table markers, not measured or fully copied.
- JSON object keys representing Lua indices do not change the original array meaning.
- Nil fields disappear from the exported JSON. Empty results are not necessarily API errors.
- Identity-based sample deduplication can omit changes to lower lines when identity stays the same.
- Timers sampled only selected moments; they did not prove every event transition.

The timers stopped at the end of each window. Registered callbacks remain installed but inactive until reload; cancellation is not unregistration. Globals and histories are session-only, not SavedVariables. Reinstallation in the same session must avoid registering duplicate callbacks.

Do not treat these small diagnostic scripts as reusable production security wrappers. Retain bounded output and redaction, but review timer ownership, all failure paths, and ordinary-addon execution before using a collector for combat research.

### Evidence index

The following paths are under ignored `cli/output/forever/integration/`. They are local evidence, not tracked dependencies or links required to understand this document.

| File | Contents |
| --- | --- |
| `tooltip-probe.lua` | AllTypes callback and main-tooltip timer recorder. |
| `tooltip-callback-examples.json` | First-window Unit and Burning Embers Object examples. |
| `tooltip-second-pass.json` | Second-window counts, representative Item/Spell/Macro/Unit/Object payloads, recorder status. |
| `tooltip-info-probe.lua` | Direct structured-API projection and cursor/mouseover timer. |
| `tooltip-info-direct.json` | Direct player/item/spell queries and absent SurfaceArgs. |
| `tooltip-info-hover-summary.json` | Cursor/mouseover transitions and callback-recorder status during that window. |
| `tooltip-info-hover-examples.json` | NPC and Object direct-query examples. |
| `tooltip-info-template.json` | Zero callbacks from the synchronous direct-read check, native quest-item data, scanner methods/event registration. |
| `tooltip-objective-mob.json` | Plainstrider callback data and final rendered FontString lines from the short retry. |

The first-window total was recorded in the live session response and development log; the local callback-examples file is only a selection, not all 56 events. Do not attempt to reconstruct that total by counting its three exported examples.

Keep raw player GUIDs/names and unrelated tooltip contents local. Sanitize shared examples as above. No chat history is needed to validate tooltip structure.

## Conclusions and next step

The narrow event-driven Object frontend is implemented, and Classic fallback rendering has been checked on the recorded client. The earlier Forever evidence also shows that native quest progress is richer than a plain string scanner suggests; Unit/Item identity and objective-content policy remain future work.

The remaining work is not another API rename. It is defining ownership of overlapping native/Questie content, proving update and identity behavior, preserving provider/party enrichment, and establishing the narrow boundary for inaccessible data.

The next useful session is live Forever validation of the Object callback, including clears, stationary refreshes, same-entity rebuilds, and a bounded combat comparison. Do not generalize the Classic checks or mocked restrictions into a Forever combat-safety claim.

## Pinned Blizzard references

All links use the matching `forever` commit, not a moving branch. The cache was read-only during documentation work.

- [TooltipDataHandler.lua][handler]: processor registration, secure/insecure dispatch, processing, rebuilds, accessors.
- [TooltipDataRules.lua][rules]: UnitName, QuestObjective, SellPrice, health and item presentation rules.
- [TooltipUtil.lua][util]: displayed-item/spell/unit compatibility interpretation and typed-line helpers.
- [Mainline GameTooltip.lua][mixin]: template lifecycle, refresh, world-cursor handling, compatibility getters.
- [Mainline GameTooltip.xml][template]: mixin, refresh flag, event wiring.
- [TooltipInfoSharedDocumentation.lua][enums]: tooltip-type and line-type enums.
- [TooltipInfoDocumentation.lua, GetUnit][unit-api] and [GetWorldCursor][cursor-api]: native declarations.
- [SimpleFontStringAPIDocumentation.lua, GetText][fontstring]: secret Text aspect.
- [UnitAuraDocumentation.lua, GetAuraDataByIndex][aura-api]: aura-access restrictions.

[handler]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua
[rules]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipDataRules.lua
[util]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_SharedXMLGame/Tooltip/TooltipUtil.lua
[mixin]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L955-L1041
[update-dispatch]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.lua#L445-L467
[template]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_GameTooltip/Mainline/GameTooltip.xml#L4-L38
[tooltip-toc]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_GameTooltip/Blizzard_GameTooltip.toc
[shared-toc]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_SharedXMLGame/Blizzard_SharedXMLGame.toc
[enums]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua
[unit-api]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua#L1180-L1197
[cursor-api]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoDocumentation.lua#L1344-L1353
[fontstring]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFontStringAPIDocumentation.lua#L352-L365
[aura-api]: https://github.com/Gethe/wow-ui-source/blob/70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitAuraDocumentation.lua#L206-L223
