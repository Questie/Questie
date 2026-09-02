# QuestieTDB integration simplification

**Status:** Section 1 and items 2.1, 2.5, and 2.6 are implemented in both repositories, in a
stronger form than proposed: the slot moved into the provider as
`LibQuestieDB.Corrections.Set(owner, datatype, name, rows)` (write-through, per-datatype
recomposition/publish, memoized function-entry materialization, owner rank fixed at first write),
so Questie holds no slot table at all — `QuestieCorrections.SetCorrection` forwards and performs
2.1's targeted eviction via `QuestieDB.RefreshAfterCorrectionApply(datatype, changedIds)`. The
"late registration" prerequisite was verified against the real provider, and 2.8's Era `{}`
registration is gone (Era publishes no ContentPhase slot). Still open: 2.2, 2.3, 2.4, 2.7, the
producer flattening in 2.8, 2.9, and the mock-vs-provider conformance run from §4 step 1.
Details: "Write-through simplification record" in `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md`.
The proposal below was written against `QuestieTDB-implementation` at
`9857ed5f46d4c44ae3a11b04639ddb280ea98cad`, after the fresh integration landed green (1530 tests,
luacheck clean) and was reviewed.

The integration works, but it carries ceremony that came from transcribing the handover packet's
"suggested state" rather than from the QuestieTDB Contract itself. Two smells repeat: Questie doing
work the provider should own, and files or functions that exist because the packet named them.

Related deferred items (Item repair apply batching, Townsfolk SavedVariables writes, mock
conformance) already live in `TDB-IMPLEMENTATION-ISSUES.md` under "Deferred follow-ups" and are only
referenced here where the sequencing depends on them.

## 1. The corrections seam is per-correction ceremony

### Finding

Every dynamic Policy Correction currently costs a full change to `Database/Corrections/QuestieCorrections.lua`:

1. a load-order constant (`DARKMOON_LOAD_ORDER = 100`);
2. a captured module local (`local activeDarkmoonNpcCorrections = {}`);
3. a provider closure that returns that local (`_DarkmoonFaireCorrections`);
4. a registration line in `InitializePolicyCorrections`;
5. a public setter (`SetDarkmoonNpcCorrections`) so the owning module can mutate the local;
6. tests for the setter.

The owning module (`QuestieEvent`, `QuestieLib`, `EntityLocale`) cannot add or change a correction
without the central module learning about it. That is the handover's prescribed design, not a
Contract requirement.

The Contract already identifies a correction by its second argument:

```lua
registrar.RegisterRuntimeCorrection(datatype, name, provider, loadOrder)
```

The provider function exists because the Contract wants a function, not because each correction
needs bespoke code. A generic slot reader satisfies the Contract identically.

### Proposed seam

```lua
local activeRows    = { Quest = {}, Npc = {}, Item = {}, Object = {} }  -- [datatype][name] = rows
local registeredAt  = { Quest = {}, Npc = {}, Item = {}, Object = {} }  -- [datatype][name] = "file:line"
local nextLoadOrder = 0

---@param datatype "Quest"|"Npc"|"Item"|"Object"
---@param name string                 -- correction name, unique per datatype
---@param rows PolicyCorrectionRows   -- full replacement; {} withdraws
function QuestieCorrections.ApplyCorrection(datatype, name, rows)
    if not activeRows[datatype][name] then
        nextLoadOrder = nextLoadOrder + 1
        questieRegistrar.RegisterRuntimeCorrection(datatype, name,
            function() return activeRows[datatype][name] end, nextLoadOrder)
        registeredAt[datatype][name] = debugstack(2, 1, 0)
    end
    activeRows[datatype][name] = rows
    questieRegistrar.Apply()
    QuestieDB.RefreshAfterCorrectionApply(datatype, rows)   -- see section 2.1
end
```

Plus `QuestieCorrections.GetActiveCorrections()` returning the slot table for a debug dump.

Ownership moves to where the state lives:

| Correction | Today | Proposed caller |
| --- | --- | --- |
| Darkmoon Faire NPCs | `QuestieEvent` -> `SetDarkmoonNpcCorrections(rows)` | `QuestieEvent`: `ApplyCorrection("Npc", "DarkmoonFaire", rows)`; `{}` when the Faire leaves |
| Content Phase | `_ContentPhasePolicy` closure; returns `{}` on Era | `ApplyCorrection("Quest", "ContentPhase", QuestieTBCPolicyCorrections:LoadContentPhaseFixes())`; not called on Era |
| Gathering node display | `_GatheringNodeDisplayPolicy` closure over 24 IDs | one static call at init; the only correction with no runtime state |
| Runtime Item repair | `RepairMissingItem(itemId, name)` mutates a captured local | `QuestieLib` owns `repairedItemNames` and re-sends it |
| External locale (4) | `InitializePolicyCorrections(externalLocaleCorrections)` + `SetExternalLocaleCorrections(builder)` withdraw-first switch | `EntityLocale`: four calls at init, empty ones skipped; the switch function is deleted (locale changes reload the UI) |

What disappears: the eight load-order constants, three captured locals, eight provider closures,
`InitializePolicyCorrections`, `ReapplyPolicyCorrections`, `SetDarkmoonNpcCorrections`,
`RepairMissingItem`, `WithdrawExternalLocaleCorrections`, `SetExternalLocaleCorrections`, and most
of `QuestieCorrections.test.lua` (25 tests become roughly six; Darkmoon and Content Phase tests move
next to their owners).

### Trade-offs

- **Load order becomes registration order.** Acceptable today: none of Questie's own corrections
  touch the same field, and Login Initialization order is pinned by `QuestieInit.test.lua`. If two
  ever overlap, the later-registered one wins. Do not add an optional `loadOrder` parameter until that
  happens.
- **The single-file inventory goes away.** `rg "ApplyCorrection\("` recovers it in source;
  `GetActiveCorrections()` and `LibQuestieDB.Corrections.GetProvenance` recover it at runtime.
- **String names are the one real footgun.** `"DarkmoonFair"` on the way out creates a second slot and
  the first never withdraws. Owners keep the name in a local constant and use it at both ends.
- **Key by correction name, not owning module.** `EntityLocale` owns four datatypes under one name;
  `QuestieEvent` may own a second holiday later. `debugstack` already records the caller.
- **`debugstack`** is captured at first registration only, never per apply, and needs a
  `debug.traceback` fallback under busted.
- **Debug surface.** A `/questie corrections` dump is ten lines; an options-panel "loaded corrections"
  list is fine later if a user asks for it, but it should not drive the design.
- **Item repair still applies once per Item.** Unchanged, but batching now has exactly one place to
  live.

### Prerequisite to verify

The Contract text says registration is append-only and each provider is registered once. It does not
say registration must precede the owner's first `Apply()`. This design needs late registration (Item
repair and Darkmoon cannot happen at Stage 1). The test double allows it; the test double has been
wrong about provider semantics before (the `0`-for-absent-number default). Check against the real
provider before writing code. If late registration is disallowed, that is a small provider change,
not a reason to keep the ceremony.

### Docs to update

`TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` "Target Questie design" prescribes the named setters, captured
locals, and load-order constants, and `TDB-RELAND-HANDOVER.md` fixes "eight Policy Correction names
... and load orders". Both need a paragraph: one registrar, one generic slot table, registrations
created on first use. The rules "do not scatter `GetRegistrar` calls" and "single owner of captured
state" still hold.

## 2. Further simplifications, ranked

### 2.1 Cache coherence is leaked across the boundary, and it is asymmetric

`QuestieDB.*Pointers` are snapshots of maps the provider replaces on every apply, and
`QuestieDB.RefreshAfterCorrectionApply` clears Questie's NPC, Item, Object, zone, and creature-level
caches wholesale on every apply. Quest objects are deliberately kept to avoid identity splits
(review blocker B2), so a post-init Quest correction never reaches an existing quest object. That is
a trap with a doc note on it.

**Change:** the `rows` handed to `ApplyCorrection` are the touched IDs. Evict exactly those (old rows
union new rows) from every cache, quest objects included. No blanket clears, no asymmetry, no
"keep quests" special case. Pointer rebinding stays: Lua 5.1 has no `__pairs`, so a proxy cannot
replace a snapshot that callers iterate.

### 2.2 Questie schedules the provider's name index

`LibQuestieDB.Object.BuildNameIndex()` is called from `Modules/QuestieInit.lua:174` (Stage 2, when
`enableTooltipsObjectID` is on) and `Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua:396`
(toggle on). Questie knowing when a provider-internal index must be warm is the provider's concern
leaking out; it exists only because a lazy build hitches on first hover.

**Change:** provider side. Build lazily in chunks, or build on `SetLocale`. Then both Questie call
sites and the Stage 2 conditional disappear. `QUESTIE-OBJECT-NAME-INDEX.md` documents the current
agreement and would be updated with it.

### 2.3 `RequireContract(1)` runs five times

`Modules/QuestieInit.lua:127` plus `Database/{quest,npc,item,object}DB.lua:5`. The four file-load
checks are the worse ones: `error()` there aborts that one file, leaving Questie half-loaded with
confusing downstream errors, while the Login Initialization check produces the clean message.

**Change:** keep the Login Initialization check only.

### 2.4 Four adapter files for four one-liners

`Database/questDB.lua` (56 lines), `npcDB.lua` (35), `itemDB.lua` (36), `objectDB.lua` (27) each do
`QuestieDB.xKeys = LibQuestieDB.Meta.XMeta.xKeys` plus the inverse `_xAdapterQueryOrder` array used by
the rich projections in `QuestieDB.lua:498/527/1600/1980`. That is a six-line loop.

**Change:** one loop in `Database/QuestieDB.lua` over `{Quest = "quest", Npc = "npc", Item = "item",
Object = "object"}`. Keep the `---@class DatabaseQuestKeys` style annotations, in one place. Remove
the four files from all five TOCs. They exist because they historically existed and the packet named
them.

### 2.5 `QuestieDB.IsInitialized` has one reader

Set at `Database/QuestieDB.lua:412/445/476`; read only by the guard at
`Database/Corrections/QuestieCorrections.lua:154`. The guard protects against nothing much:
refreshing before init rebinds maps and clears empty tables. Packet-mandated.

**Change:** delete the flag and the guard. `RefreshAfterCorrectionApply` is safe at any time.

### 2.6 `EntityLocale.ForwardProviderLocale` is a pass-through

`Localization/EntityLocale.lua:15` wraps `LibQuestieDB.l10n.SetLocale(locale)` in one line. Pure
navigation tax.

**Change:** inline at `Modules/QuestieInit.lua:135`. `BuildExternalLocaleCorrections` is the only
real function in that module.

### 2.7 Seventeen aliases bound at `QuestieDB.Initialize`

`QueryQuestSingle = LibQuestieDB.Quest.Get` and sixteen siblings (eight queries, four pointer maps,
five Objective Order tables) are bound at init for no runtime reason: QuestieTDB is a `RequiredDep`
and is present at file load. Pointer maps must still rebind on apply (2.1).

**Change:** bind the queries and Objective Order tables statically at file load; `Initialize`
becomes "reset caches and bind pointers". Longer term the `QueryNPCSingle` vocabulary is legacy and
callers could use `LibQuestieDB.Npc.Get` directly. That is a mechanical rename for another day.

### 2.8 Retained producer classes

`QuestieTBCPolicyCorrections:LoadDarkmoonFixes(isInMulgore, isInTerokkar)`, the Classic twin,
`LoadContentPhaseFixes()`, and the `Questie.IsTBC` selection in `QuestieEvent._LoadDarkmoonFaire`.
Method-call style, "Load...Fixes" naming, two classes for one holiday. Under the seam in section 1
these are just "return rows" and belong as plain data next to the holiday code. The Era Content
Phase registration that returns `{}` to keep "exactly eight" goes with them.

### 2.9 `_QuestieDB.objectCache` is never written

`Database/QuestieDB.lua:494` reads it; the store at `:513` is commented out. Pre-existing dead code.

**Change:** delete it or enable it. Not both halves.

## 3. Looked at and kept

- Questie's entity object caches: they cache constructed objects, not provider reads, so they are not
  double-caching the provider.
- Pointer snapshots: see 2.1; no `__pairs` in Lua 5.1.
- The Login Initialization stage order in `Modules/QuestieInit.lua`: reads fine as is.
- The `QuestieCorrections.Initialize()` blacklists (`hiddenQuests` and friends): Questie-side UI
  filtering, a different concept from provider corrections. Only the shared module name is confusing.

## 4. Suggested sequence

1. Provider conformance first: run the `test/QuestieTDBMock.test.lua` semantics against the real
   `LibQuestieDB` and confirm late registration after the first `Apply()`. The double has lied once.
2. Section 1 seam rewrite, with 2.1 targeted eviction and 2.8 producer flattening, since the seam
   unlocks both.
3. One "remove packet ceremony" commit for 2.3 through 2.7 and 2.9; all deletions.
4. Push 2.2 to the provider; delete the Questie call sites when it lands.
5. Item repair batching, in the one place it now has.

Net effect is roughly 300 lines removed, one fewer concept per future correction, and the quest
object staleness trap closed.
