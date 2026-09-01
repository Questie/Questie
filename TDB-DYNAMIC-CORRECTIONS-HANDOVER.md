# QuestieTDB Dynamic Corrections handover

## Purpose

This document is the implementation handover for moving every runtime entity correction to the
QuestieTDB Correction Overlay without moving Questie-owned policy into the Database Addon.

A new agent should be able to implement this packet by reading this file, `CONTEXT.md`, and the
applicable `AGENTS.md` files. `TDB-REFACTOR.md` remains the plan for the wider compiler removal.
Where its Dynamic Correction guidance conflicts with this document, this document is current.
In particular, QuestieTDB no longer exposes `ApplyParameterized`.

## Scope

This packet includes all active Dynamic Correction paths, including:

- Darkmoon Faire NPC presentation selected by `QuestieEvent`;
- gathering-node suppression;
- TBC Content Phase prerequisites;
- provider-owned faction, class, race, expansion, season, SoD, and Titan Reforged corrections;
- built-in and externally supplied entity localization behavior;
- asynchronous missing-Item repair;
- Event Quest state that interacts with corrected entities;
- correction-time cache invalidation and entity-ID map refresh.

Do not depend on or copy work from the separate `DMF-locations` clone. Use the Darkmoon functions
and event logic currently present in this Questie branch. A later Darkmoon cleanup can change its
location model independently.

This packet does not finish release packaging, support-data migration, compiler UI deletion,
Saved Variables cleanup, or physical deletion of all old correction files. It must leave a clear
path for those later work items.

## Current repository state

At the time of this handover:

- Questie branch `QuestieTDB` contains completed TDB-01 and TDB-02 work.
- All five Questie TOC Manifests declare `## RequiredDeps: QuestieTDB`.
- `QuestieDB:Initialize()` binds entity queries, Database Key Enums, entity-ID maps, Objective
  Order Correction tables, and semantic caches to `LibQuestieDB`.
- `test/QuestieTDBMock.lua` covers the read seam but does not yet implement the Correction
  registrar.
- Login Initialization still executes the old compiler lifecycle.
- Questie still has raw `*DataOverrides` tables and runtime writers.
- Unrelated untracked icon files may exist under `Icons/`. Do not modify or remove them.

The corresponding Database Addon implementation is currently on the sibling QuestieTDB
`ownership` branch. Before implementation, verify that the checkout being used exposes the
contract described below. Do not implement against a stale QuestieTDB `master` that still has
`ApplyParameterized`.

## Required terminology

Use the terms from `CONTEXT.md`:

- **Database Addon** means QuestieTDB.
- **Database Correction** means an authored change to entity facts owned by the Database Addon.
- **Policy Correction** means a Database Correction Questie registers because selecting or
  constructing it depends on Questie state or policy.
- **Correction Registration** means Questie registering a Policy Correction through the
  Database Addon's owner-scoped registrar.
- **Quest Blacklist** is Questie policy and is not a Database Correction.
- **Login Initialization** is the `PLAYER_LOGIN`-driven staged initialization path.

Avoid the retired term "override" in new code. Existing names such as `npcDataOverrides` describe
legacy storage that this packet removes.

## Ownership rule

Ownership follows the information needed to choose or construct a Correction.

### Database Addon ownership

QuestieTDB owns a Correction when it depends only on provider data or generic WoW facts it can
determine itself, including:

- class;
- race;
- faction;
- expansion;
- season;
- SoD activation;
- Titan Reforged activation.

Questie must not register duplicate copies of those Corrections.

### Questie ownership

Questie owns a Policy Correction when it depends on Questie runtime state or policy, including:

- Darkmoon Faire event state and selected location;
- gathering-node display suppression;
- Questie's Content Phase selection;
- Questie settings;
- external locale-addon data;
- Questie runtime projections and caches;
- asynchronous Item repair initiated by Questie.

The Database Addon owns the generic Correction Overlay. It must not learn Questie's schedule,
settings, event representation, cache lifecycle, or consumer-specific data format.

## QuestieTDB contract available to Questie

QuestieTDB Contract Version 1 provides:

```lua
local registrar = LibQuestieDB.GetRegistrar("Questie")

registrar.RegisterRuntimeCorrection(
    datatype,
    name,
    correctionProvider,
    loadOrder
)

registrar.Apply()
```

`datatype` is one of `"Quest"`, `"Npc"`, `"Item"`, or `"Object"`.

A correction provider is a function returning:

```lua
{
    [entityId] = {
        [fieldIndex] = correctedValue,
    },
}
```

Contract behavior already proven in QuestieTDB:

- registration retains the provider function;
- every `Apply()` invokes providers again;
- reapplying owner `"Questie"` rebuilds that owner rather than accumulating old values;
- replacing a captured table changes the next composed view;
- returning an empty top-level table withdraws that provider's previous contribution;
- `{}` as a field value clears that field;
- owner precedence is fixed by the owner's first apply and does not change on reapply;
- `loadOrder` orders registrations within one owner;
- normal entity reads use the composed view;
- `GetRaw` bypasses Corrections and localization;
- `LibQuestieDB.Corrections.GetProvenance(datatype, id, key)` reports the winning owner;
- Correction application invalidates provider read caches and composed entity-ID maps;
- a Correction may add an entity absent from the base data.

Registration is append-only. Register each Questie provider exactly once. Calling
`RegisterRuntimeCorrection` repeatedly with the same name creates duplicate entries.

There is no `ApplyParameterized`, `LoadDarkmoonFixes`, or Darkmoon-specific Database Addon API.
Do not reintroduce one.

## Target Questie design

`QuestieCorrections` is the single owner of the Questie registrar and all captured Policy
Correction state. Do not add another pass-through module. Do not scatter `GetRegistrar` calls
through Event, localization, options, or Item code.

Other Questie modules update state through focused `QuestieCorrections` functions. Those
functions reapply owner `"Questie"` and refresh Questie's projections after Login Initialization.

Suggested state:

```lua
local questieRegistrar
local dynamicCorrectionsRegistered = false

local activeDarkmoonNpcCorrections = {}
local activeExternalQuestLocaleCorrections = {}
local activeExternalNpcLocaleCorrections = {}
local activeExternalItemLocaleCorrections = {}
local activeExternalObjectLocaleCorrections = {}
local activeRuntimeItemCorrections = {}
```

Suggested load-order constants:

```lua
local DARKMOON_LOAD_ORDER = 100
local GATHERING_NODE_LOAD_ORDER = 200
local CONTENT_PHASE_LOAD_ORDER = 300
local RUNTIME_ITEM_LOAD_ORDER = 400
local EXTERNAL_LOCALE_LOAD_ORDER = 500
```

Load order matters only between entries for the same datatype and owner. Keeping values spaced
and named makes later additions explicit.

QuestieDB must expose a real lifecycle flag and refresh operation. Add
`QuestieDB.IsInitialized = false`, set it to `false` at the start of `QuestieDB:Initialize()`, and
set it to `true` only after query bindings, ID maps, Objective Order hints, and caches are ready.
Tests must reset this field between cases.

Suggested owner lifecycle:

```lua
local function _ApplyQuestieCorrections()
    questieRegistrar.Apply()

    if QuestieDB.IsInitialized then
        QuestieDB.RefreshAfterCorrectionApply()
    end
end
```

Use the project's preferred function syntax and naming conventions in the final implementation.
The example shows responsibility, but the lifecycle flag and guarded refresh are required. Test
both application before initialization and application after initialization.

The initial apply happens before `QuestieDB:Initialize()`. Later event, locale, phase, or Item
changes call the same apply path and then refresh Questie's entity-ID maps and semantic caches.

## Complete correction inventory

### Provider-owned Corrections Questie must stop applying

The current `QuestieCorrections:MinimalInit()` duplicates provider behavior into legacy raw
override tables. Remove these calls from Questie's runtime orchestration.

| Current Questie behavior | Current source | Final owner and evidence |
| --- | --- | --- |
| Era faction corrections for Quest, NPC, Item, and Game Object | `Database/Corrections/QuestieCorrections.lua`, `MinimalInit`, Era block | QuestieTDB manifest registers each expansion's `LoadFactionFixes` as Dynamic. |
| TBC faction corrections | Same function, TBC block | QuestieTDB manifest registers TBC `LoadFactionFixes`. |
| WotLK faction corrections | Same function, WotLK block | QuestieTDB manifest registers WotLK `LoadFactionFixes`. |
| Cata faction corrections | Same function, Cata block | QuestieTDB manifest registers Cata `LoadFactionFixes`. |
| MoP faction corrections | Same function, MoP block | QuestieTDB manifest registers MoP `LoadFactionFixes`. |
| SoD entities and faction quest corrections | `QuestieCorrections:Initialize()` and `MinimalInit()` | QuestieTDB manifest registers the SoD base and correction sets and gates them through `C_Seasons`. |
| Titan Reforged Quest, NPC, and Item corrections duplicated by Questie | `MinimalInit`, calls to WotLK `LoadTitanReforgedFixes` | QuestieTDB has separate `Titan/*` Dynamic Correction modules for Quest, NPC, Item, and Game Object, gated to WotLK and active season `109`. Questie currently duplicates only Quest, NPC, and Item; the provider additionally owns its Game Object corrections. |
| Class/race/faction-derived entity facts inside those providers | Expansion correction functions | QuestieTDB may read generic WoW character facts directly. Do not reproduce them in Questie. |

Current Questie anchors:

- `Database/Corrections/QuestieCorrections.lua`, `MinimalInit()`
- `QuestieItemFixes:LoadFactionFixes()` and corresponding entity/expansion functions
- `QuestieWotlk*Fixes:LoadTitanReforgedFixes()`
- `SeasonOfDiscovery:LoadFactionQuestFixes()`

Current QuestieTDB anchors:

- `src/corrections/manifest.lua`
- `src/corrections/register.lua`
- `register.IsSodActive()`
- `register.IsTitanReforgedActive()`
- `docs/adr/0007-dynamic-correction-ownership.md`

Do not remove Questie's ordinary `Quest:CheckRace`, `Quest:CheckClass`, availability, or player
state logic. Those are semantic checks, not duplicate Database Corrections.

### Questie-owned Policy Corrections to register

#### 1. Gathering-node display policy

Current behavior:

- `_QuestieDB:DeleteGatheringNodes()` in `Database/QuestieDB.lua`
- called from `loadFullDatabase()` in `Modules/QuestieInit.lua`
- mutates raw Game Object `spawns` before compilation.

Register one Object Correction named `"GatheringNodeDisplayPolicy"`. For each ID below, clear
`objectKeys.spawns` with `{}`:

```text
1617 1618 1619 1620 1621 1622 1623 1624 1628
1731 1732 1733 1734 1735 123848 150082 175404
176643 177388 324 150079 176645 2040 123310
```

There are exactly 24 IDs. The correction provider is static from Questie's perspective, but it
is a Dynamic Correction because it belongs to consumer policy and is applied through the
runtime overlay.

After registering it:

- remove the production call to `DeleteGatheringNodes`;
- remove the helper when no tests or callers remain;
- test that normal reads hide spawns while `Object.GetRaw` still returns provider spawns;
- test provenance is `"Questie"` for the composed `spawns` field.

#### 2. TBC Content Phase prerequisite policy

Current behavior:

- `QuestieTBCQuestFixes:LoadContentPhaseFixes()` in
  `Database/Corrections/tbcQuestFixes.lua`;
- merged from `QuestieCorrections:MinimalInit()`.

Register one Quest Correction named `"ContentPhasePolicy"`. Preserve the exact current fields:

- Quest `10944`
  - `preQuestGroup`
  - `preQuestSingle`
- Quest `11007`
  - `preQuestSingle`

The provider must return `{}` when `Expansions.Current < Expansions.Tbc`. This gate is required:
without it, the overlay can create malformed Quest rows for IDs `10944` and `11007` on Era.
Preserve the current cumulative `>= Tbc` behavior for TBC and later flavors unless a separate
change proves it should differ.

When the flavor is eligible, the provider function must read the current
`ContentPhases.activePhases.TBC` value every time it is applied. Do not calculate the table only
once at registration if the phase can change later.

Any settings or automatic phase transition that changes the input must call the shared Questie
Correction apply path. Blacklisting Isle of Quel'Danas quests remains blacklist policy and does
not become an entity Correction. Add an Era test proving these Quest IDs are not introduced.

The three MoP `LoadContentPhaseFixes()` functions currently return `{}`. Do not register no-op
providers. If they gain data later, they follow the same Questie ownership rule.

#### 3. Darkmoon Faire NPC policy

Ignore the `DMF-locations` branch. Preserve the current Questie branch behavior:

- `QuestieEvent` determines event state and location;
- Era/SoD use `QuestieNPCFixes:LoadDarkmoonFixes(isInMulgore)`;
- TBC uses `QuestieTBCNpcFixes:LoadDarkmoonFixes(isInMulgore, isInTerokkar)`;
- those functions return NPC corrections for `spawns` and `zoneID`;
- announcement-quest visibility remains in `QuestieEvent`.

Register one NPC provider named `"DarkmoonFaire"` that returns
`activeDarkmoonNpcCorrections`.

Change `_LoadDarkmoonFaire()` so it:

1. determines the location with the existing logic;
2. selects the existing correction table with the existing Era/TBC functions;
3. updates the captured Darkmoon table through `QuestieCorrections`;
4. applies owner `"Questie"` once;
5. updates Event Quest and announcement-quest state;
6. never writes `QuestieDB.npcDataOverrides`.

When no Darkmoon location is active, set the captured table to `{}` and apply. That withdrawal is
required to remove coordinates from a previous state. Applying the NPC table must not be nested
inside the loop over Event Quests; the number of visible Event Quests must not control entity
correction application.

Do not redesign the Event module into a live location-transition system in this packet. The
current module registers a one-shot calendar callback and later releases `eventQuests`. Prove
location-to-location replacement and withdrawal through the `QuestieCorrections` setter/provider
unit tests. Event integration tests should prove the initial active or inactive selection and
preserve existing Event Quest behavior. A future live Event refresh would also need to retain
source event data and explicitly reconcile `activeQuests`, `hiddenQuests`, and announcement
quests.

Keep these as Questie policy, not Database Corrections:

- `QuestieEvent.activeQuests`;
- `QuestieCorrections.hiddenQuests` changes;
- event announcements;
- calendar and date calculations;
- Horde/Alliance announcement-quest selection;
- Titan holiday-date selection.

The first green commit on `baseline` moves the two Darkmoon producers and the TBC Content Phase
producer into expansion-split Questie policy files before any provider-owned correction file is
deleted. Preserve their inputs and returned tables in that commit. Each new file records its source
file, source commit, and Questie ownership reason. This extraction does not depend on
`DMF-locations`.

#### 4. External Locale Override entity data

Built-in entity localization belongs to QuestieTDB. Keep `l10n:SetUILocale()` responsible for
Questie's UI-locale state only. During boot, a separate entity-locale application path must
forward the effective locale to `LibQuestieDB.l10n.SetLocale()` after the Contract Version check.
Runtime locale changes use that same explicit entity-locale path after updating UI state.

Data supplied by another addon through `QUESTIE_LOCALES_OVERRIDE` is Questie-owned runtime input.
Preserve it as four Questie Policy Corrections:

- Item name;
- Quest name and `objectivesText`;
- NPC name and `subName`;
- Game Object name.

Preserve the current existence filter. QuestieTDB Corrections can add entities, so blindly
registering every external lookup row can create stale, wrong-flavor, or cross-flavor name-only
entities and add them to pointer maps.

At initial boot, build external locale tables only for IDs where the corresponding composed
Entity `Exists(id)` is true before the external locale provider has contributed anything. This
accepts base entities and provider-owned SoD/Titan additions while rejecting unknown IDs.

For a later external-locale switch, use this exact sequence:

1. Replace all four captured external locale tables with `{}`.
2. Call the shared Questie apply path to withdraw the old locale layer.
3. Build the new tables, accepting only IDs where the now-clean composed Entity `Exists(id)` is
   true. Other Questie providers remain active during this check.
4. Replace the captured tables and apply again.
5. Refresh Questie caches and locale-derived indexes after the final apply.

This withdrawal-first sequence prevents an entity created only by the previous external locale
from validating itself. Build ordinary correction rows with Database Key Enums. Add tests proving
unknown external IDs remain absent from normal reads, `GetAllIds`, and Questie pointer maps, while
provider-owned SoD/Titan entities remain eligible.

Do not use Policy Corrections for Questie's built-in generated entity lookups or Titan zhCN
provider defects. Those are Database Addon data and remain gated on QuestieTDB issue #14. Do not
silently delete the old built-in lookup path before #14 is complete and verified.

After locale changes:

- call `LibQuestieDB.l10n.SetLocale()` for built-in provider localization;
- reapply Questie Corrections if external entity data changed;
- clear Questie's semantic caches;
- clear and rebuild `QuestieTooltips.objectNameLookup` from composed Object reads;
- keep UI Translation Entries, Zone/Category Lookups, and External Locale Override UI strings in
  Questie.

Questie's UI-string module owns no entity index. Run the tooltip-owned clear-before-build operation
through the existing staged coroutine or `ThreadLib`; do not call a yielding rebuild directly from
an arbitrary options callback. Repeated rebuilds must remove old-locale names and must not append
duplicate Object IDs.

#### 5. Asynchronous missing-Item repair

Current behavior is in `QuestieLib:CacheItemNames()`:

```lua
QuestieDB.itemDataOverrides[itemId] = {itemName, {questId}, {}, {}}
```

The second Item slot is `npcDrops`, so writing `{questId}` there is not a valid relationship.
Do not preserve that tuple accidentally.

Register one Item provider named `"RuntimeItemRepair"` backed by an accumulating
`activeRuntimeItemCorrections` table. When the client loads a missing Item name, add:

```lua
[itemId] = {
    [itemKeys.name] = itemName,
}
```

Then reapply owner `"Questie"`, refresh entity-ID maps, and clear semantic Item projections. The
Correction Overlay may add the previously unknown Item ID to the composed view.

If investigation proves another Item field is required, record the evidence before adding it.
Do not put a Quest ID into `npcDrops`.

Guard asynchronous callbacks:

- do nothing when the Item name is nil;
- preserve all previously repaired Items when adding another;
- avoid registering the provider again;
- ensure repeated callbacks for one Item are idempotent.

### Runtime policy that is not a Database Correction

Do not force all dynamic Questie behavior through the Correction Overlay.

Keep these as Questie-owned tables and logic:

- `QuestieCorrections.hiddenQuests`;
- `questItemBlacklist` and `questNPCBlacklist`;
- Quest Blacklists and Map-only Quest Blacklists;
- Hardcore filtering;
- Titan Reforged blacklist additions;
- Isle of Quel'Danas quest hiding and automatic phase selection;
- `QuestieEvent.activeQuests` and event date tables;
- Quest Log, player, reputation, class, and race availability checks;
- Questie semantic caches themselves.

They decide what Questie shows or what the player can do. They do not change composed entity
facts unless a specific Policy Correction above says so.

## Titan Reforged and SoD requirements

This packet includes Titan Reforged and SoD by removing Questie's duplicate entity-correction
application and proving the Database Addon owns it.

### Titan Reforged

Remove runtime calls to:

- `QuestieWotlkNpcFixes:LoadTitanReforgedFixes()`;
- `QuestieWotlkQuestFixes:LoadTitanReforgedFixes()`;
- `QuestieWotlkItemFixes:LoadTitanReforgedFixes()`.

QuestieTDB's `Titan/*` manifest entries own Quest, NPC, Item, and Game Object corrections. Its
gate requires WotLK plus season `109`.

Keep Questie's Titan-specific blacklists and event schedules. Those are policy, not duplicate
entity data.

`Questie.LoadTitanQuestLookupOverrides()` is provider-owned localization data because locale and
season are generic WoW facts. Do not convert it into a permanent Questie Policy Correction.
QuestieTDB issue #14 must provide it before the legacy path is deleted.

### Season of Discovery

Remove runtime entity Correction calls from Questie. QuestieTDB owns and season-gates:

- SoD base Quests, NPCs, Items, and Game Objects;
- SoD authored entity corrections;
- SoD faction quest corrections.

Keep Questie-specific SoD display behavior, settings, and blacklists.

### Required races

A separate QuestieTDB work item owns `requiredRaces`. The project instruction for this packet is
to assume that companion work will be correct and not create a new Questie Policy Correction.

Current QuestieTDB ownership-branch documentation may still report missing SoD post-composition
inference under issue #13. Therefore:

- do not solve `requiredRaces` inside this Dynamic Correction packet;
- do not delete Questie's old compiler inference as evidence that the provider is already ready;
- before TDB-03/TDB-09 remove the compiler path, verify that the companion provider change has
  landed and covers SoD;
- if it has not landed, block the compiler-free cutover rather than silently losing behavior.

This external prerequisite does not block implementing and testing the owner-scoped Policy
Correction lifecycle described in this document.

## QuestieDB refresh after Correction application

QuestieTDB invalidates its own caches. It cannot invalidate Questie's rich projections or update
references Questie retained earlier.

Add one plain QuestieDB function for post-apply refresh. It must:

1. rebind all four ID maps:

```lua
QuestieDB.QuestPointers = LibQuestieDB.Quest.GetAllIds(true)
QuestieDB.NPCPointers = LibQuestieDB.Npc.GetAllIds(true)
QuestieDB.ItemPointers = LibQuestieDB.Item.GetAllIds(true)
QuestieDB.ObjectPointers = LibQuestieDB.Object.GetAllIds(true)
```

2. clear:

- private Quest cache;
- private Item cache;
- private NPC cache;
- private Game Object cache;
- private zone cache;
- `QuestieDB._CreatureLevelCache`.

QuestieTDB replaces composed ID-union structures after overlay changes. Keeping an old pointer-map
reference can hide a correction-added entity or retain a withdrawn entity.

The initial correction apply happens before `QuestieDB:Initialize()`, which binds current maps and
starts with empty semantic caches. Later applications must call the refresh function.

The locale-derived `QuestieTooltips.objectNameLookup` is owned by the tooltip module and must be
rebuilt when relevant entity data changes.

## Registration and initialization order

Separate UI-locale selection from entity-locale application. `InitializeUILocale()` currently
calls `SetUILocale()`, so do not make `SetUILocale()` immediately register or apply Corrections.
Keep it responsible for resolving Questie's UI locale state. Add a separate provider-locale
application path used after the Contract Version check; setting QuestieTDB's built-in locale does
not require the Questie registrar. Registrar readiness is required later when building and
applying Questie-owned External Locale Override Corrections.

The final Login Initialization order is:

1. `l10n.InitializeUILocale()` resolves Questie's effective UI locale without applying entity
   Corrections.
2. `LibQuestieDB.RequireContract(1)` succeeds.
3. `LibQuestieDB.l10n.SetLocale(l10n:GetUILocale())` selects built-in provider localization.
4. Questie initializes blacklists and other non-Correction policy.
5. `QuestieCorrections` obtains `GetRegistrar("Questie")`.
6. Questie registers every Policy Correction exactly once with empty or initial captured tables.
7. Questie builds gathering, Content Phase, and any other immediately available captured state.
8. Questie builds initial External Locale Override tables by filtering against composed Entity
   `Exists` before the external providers have contributed.
9. Questie applies owner `"Questie"` once, fixing owner precedence.
10. `QuestieDB:Initialize()` binds queries, current ID maps, Objective Order hints, caches, and
    finally sets `QuestieDB.IsInitialized = true`.
11. Townsfolk and other database consumers initialize.
12. The coroutine-safe Object name index rebuild runs from composed Object reads.
13. `QuestieEvent.Initialize()` begins calendar/event detection.
14. Later initialization stages continue.

At runtime, a locale change first updates UI locale state, then changes QuestieTDB's provider
locale, withdraws old external locale Corrections, filters/builds the new external tables,
applies them, refreshes QuestieDB, and schedules the coroutine-safe Object index rebuild.

Event callbacks and asynchronous Item callbacks may run after step 10. Their setter calls must
reapply and refresh QuestieDB.

During this Dynamic Correction packet, the old compiler path may still exist until TDB-03. Keep
the packet buildable by separating old Static Correction/validator code from the runtime
`MinimalInit()` path. Do not retain duplicate runtime corrections merely because the compiler is
still scheduled for deletion.

A safe intermediate shape is:

- retain `_LoadCorrections`, Static Correction loading, and compiler validator entry points until
  TDB-03/TDB-10 remove them;
- repurpose `MinimalInit()` or replace its callers so runtime initialization registers Questie
  Policy Corrections and builds blacklists;
- remove all provider-owned `addOverride` calls from the runtime path;
- guard registration so compile and cached paths cannot register twice;
- remove the raw gathering-node call;
- remove raw entity localization writes once provider/external correction parity is ready.

Do not introduce a compiler fallback or a second entity-query backend.

## Test-double work

Extend `test/QuestieTDBMock.lua` only with behavior Questie consumes. It needs:

- `LibQuestieDB.GetRegistrar(owner)`;
- `RegisterRuntimeCorrection`;
- `Apply`;
- provider invocation on every apply;
- rebuilding instead of accumulating the Questie layer;
- field clearing through `{}`;
- correction-added and withdrawn IDs;
- `GetRaw` returning base values;
- `Corrections.GetProvenance`;
- stable base data with composed normal reads;
- reset of registrations, captured overlay, provenance, and call history between tests;
- inspection helpers for registration count and apply count.

It does not need QuestieTDB encoding, Source/Baked modes, generic multi-owner precedence, static
Correction generation, or storage normalization.

Add `LibQuestieDB.l10n.SetLocale` as a spy/state recorder when localization tests consume it. Do
not reproduce QuestieTDB's built-in locale overlay in the fake. Questie tests should prove that
the effective locale is forwarded and that Questie-owned external locale Corrections compose;
QuestieTDB's own tests prove built-in localized reads. Add `Support.Get` only in the later
support-data packet.

## Required tests

### QuestieCorrections tests

Create `Database/Corrections/QuestieCorrections.test.lua`.

Cover:

1. Contract owner is exactly `"Questie"`.
2. Every provider registers once even if runtime initialization is called again.
3. Initial apply happens before `QuestieDB:Initialize()` in the integration flow.
4. Gathering-node spawns are cleared in composed reads for all 24 IDs.
5. Gathering-node `GetRaw` values remain unchanged.
6. Gathering-node provenance reports `"Questie"`.
7. TBC Content Phase transitions replace prerequisite fields instead of accumulating.
8. Empty captured tables withdraw previous fields.
9. Multiple Questie registrations survive one owner's reapply.
10. Questie does not register faction, SoD, or Titan entity Corrections.
11. Blacklist construction remains unchanged and separate from registrar state.

### Darkmoon tests

Update `Database/Corrections/Holidays/QuestieEvent.test.lua` and add focused provider/setter tests
where appropriate.

Cover the current branch's supported Era, Anniversary Era, Anniversary Hardcore, SoD, and TBC
behavior without depending on `DMF-locations`:

1. initial active location supplies expected composed NPC `spawns` and `zoneID`;
2. direct setter/provider tests move between every supported correction table without retaining
   the old location;
3. an empty captured table withdraws the correction;
4. `Npc.GetRaw` remains unchanged;
5. provenance is `"Questie"` while active;
6. repeated application is idempotent;
7. the NPC correction applies once regardless of Event Quest count;
8. Event Quest and announcement-quest behavior remains unchanged;
9. Anniversary phases 1–2 do not apply the Era Darkmoon correction;
10. Anniversary phase 3 and later use the current Era location behavior;
11. no Darkmoon-specific call is made into QuestieTDB.

Do not make these tests imply that `QuestieEvent:Load()` currently supports repeated live
location transitions. Test the registrar transition lifecycle through the QuestieCorrections
setter. Event tests cover the one-shot initial selection.

### Titan, SoD, and provider-ownership tests

Add focused integration assertions that Questie's runtime initializer does not call or register:

- expansion `LoadFactionFixes` providers;
- WotLK `LoadTitanReforgedFixes` providers;
- SoD entity providers.

Do not duplicate QuestieTDB's internal season-gate tests. Questie only needs to prove it does not
apply a second copy.

### External locale tests

Keep `Localization/l10n.test.lua` focused on Questie-owned UI strings and UI locale selection. Test
the fresh entity-locale seam separately for:

- effective locale forwarded to QuestieTDB without raw entity-table writes;
- external Item, Quest, NPC, and Game Object data registered under owner `"Questie"`;
- switching or removing an external locale withdraws old values;
- semantic caches and `QuestieTooltips.objectNameLookup` refresh;
- UI translations and Zone/Category Lookups remaining Questie-owned.

### Runtime Item tests

Update the relevant `QuestieLib` test to cover:

- missing Item name creates a name-only Item Correction;
- no Quest ID is inserted into `npcDrops`;
- a correction-added Item appears in refreshed `ItemPointers`;
- later Items do not remove earlier repairs;
- duplicate callbacks are idempotent;
- nil names do nothing;
- `GetRaw` remains absent or unchanged;
- provenance is `"Questie"`.

### QuestieDB refresh tests

Extend `Database/QuestieDB.test.lua` to cover:

- all four ID maps rebound after apply;
- every semantic cache cleared;
- correction-added IDs become visible;
- withdrawn IDs disappear;
- refresh before initialization is not required and does not run accidentally.

## Files expected to change

Central ownership files:

- `Database/Corrections/QuestieCorrections.lua`
- new `Database/Corrections/QuestieCorrections.test.lua`
- `Database/QuestieDB.lua`
- `Database/QuestieDB.test.lua`
- `test/QuestieTDBMock.lua`
- `Modules/QuestieInit.lua` only for correction ordering and removal of raw gathering-node calls
- `TDB-DYNAMIC-CORRECTIONS-HANDOVER.md` for implementation evidence

Policy callers:

- `Database/Corrections/Holidays/QuestieEvent.lua`
- `Database/Corrections/Holidays/QuestieEvent.test.lua`
- `Modules/Libs/QuestieLib.lua`
- its existing test file
- `Localization/l10n.lua`
- `Localization/l10n.test.lua`
- Content Phase settings or transition callers that can change correction input

Legacy declarations/helpers to remove when no caller remains:

- `QuestieDB.itemDataOverrides`
- `QuestieDB.npcDataOverrides`
- `QuestieDB.objectDataOverrides`
- `QuestieDB.questDataOverrides`
- `_QuestieDB:DeleteGatheringNodes()`
- runtime `addOverride` usage in `QuestieCorrections:MinimalInit()`

This completed packet did not delete the old Static Correction files because compiler validators and
Objective Order side effects still loaded them. On `baseline`, WP-00 first extracts the Questie-owned
producers and validates the behavior-neutral move. TDB-09/TDB-10 then delete the provider-owned
files. Objective Order stays provider-owned through `LibQuestieDB.ObjectiveFirst`.

## Implementation sequence and ownership

One agent should own the central packet because the fake, `QuestieCorrections`, `QuestieDB`, and
Login Initialization order are coupled.

Recommended sequence:

1. Read `CONTEXT.md`, `AGENTS.md`, this file, and current QuestieTDB ADR 0007.
2. Record baseline `git status`; preserve unrelated icon files.
3. Add failing registrar lifecycle tests to the focused fake.
4. Implement the minimal fake registrar.
5. Add `QuestieDB.RefreshAfterCorrectionApply()` and tests.
6. Register gathering-node and TBC Content Phase providers.
7. Separate blacklist initialization from provider-owned entity Correction calls.
8. Remove duplicate faction, Titan, and SoD runtime application.
9. Convert current Darkmoon writes to captured Questie Correction state.
10. Convert asynchronous Item repair.
11. Forward provider locale and convert External Locale Override entity data.
12. Remove remaining production writes to legacy `*DataOverrides` tables.
13. Adjust correction ordering in Login Initialization without adding a second backend.
14. Run targeted tests after each vertical slice.
15. Run full validation and request fresh correction/lifecycle review.
16. Update this document and `TDB-REFACTOR.md` with changed files, evidence, and deferred work.

Do not parallel-edit the central files listed above. Read-only reviewers may work concurrently.

## Blockers and decisions

### Hard gates for full behavior parity

- QuestieTDB issue #14 must provide built-in lookup overrides and Titan zhCN entity localization
  before Questie deletes those legacy built-in lookup paths.
- The current QuestieTDB `ownership` implementation must be merged or otherwise available to the
  Questie development environment. A stale provider with `ApplyParameterized` is the wrong
  contract.

### Decisions already made

- Darkmoon is a Questie Policy Correction. The Database Addon owns no Darkmoon selector or table.
- The separate `DMF-locations` branch is not required for this packet.
- Gathering-node suppression is Questie policy.
- Content Phase entity changes are Questie policy.
- Faction, class, race, expansion, season, SoD, and Titan entity corrections belong to the
  Database Addon.
- External Locale Override entity data belongs to Questie; built-in entity translations belong
  to the Database Addon.
- Runtime Item repair, if retained, is Questie-owned and name-only unless new evidence supports
  another field.
- `requiredRaces` is owned by separate companion work; this packet does not reimplement it, and the compiler-free cutover must verify that work has landed.
- No compiler fallback or dual query backend will be added.

### Not blockers for this packet

- QuestieTDB support-data synchronization issue #15. Keep current support datasets until TDB-11.
- ObjectiveFirst Source-mode issue #17. TDB-02 already binds the correct interface; provider
  parity remains separate.
- Differential coverage issue #19. It affects release confidence, not registrar capability.
- Distribution automation. TOC dependency/loading is already complete.

### Documentation cautions

- Older `TDB-REFACTOR.md` text under TDB-07 still instructs callers to use
  `ApplyParameterized`. That is obsolete and must not guide implementation.
- QuestieTDB `InvalidateCache` does not apply changed Correction providers. Call
  `registrar.Apply()` first; cache invalidation alone cannot recompose the overlay.
- Owner precedence follows first apply. Reapplying must not be used to reorder owners.

## Validation commands

Use red-green cycles and focused tests first:

```bash
busted Database/Corrections/QuestieCorrections.test.lua
busted Database/Corrections/Holidays/QuestieEvent.test.lua
busted Database/QuestieDB.test.lua
busted Localization/l10n.test.lua
busted Modules/Libs/QuestieLib.test.lua
```

Adjust the QuestieLib test path if its current colocated filename differs.

Run affected semantic tests, including Available Quests and Townsfolk, because pointer and cache
changes can affect them:

```bash
busted Modules/Quest/AvailableQuests/AvailableQuests.test.lua
busted Modules/QuestieMenu/Townsfolk.test.lua
```

Then run:

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
git diff --check
```

Static retirement checks:

```bash
rg -n 'ApplyParameterized|LoadDarkmoonFixes' Database Modules Localization test
rg -n 'QuestieDB\.(itemDataOverrides|npcDataOverrides|objectDataOverrides|questDataOverrides)' \
  Database Modules Localization Public
rg -n 'LoadFactionFixes|LoadTitanReforgedFixes|LoadFactionQuestFixes' \
  Database/Corrections/QuestieCorrections.lua
rg -n 'DeleteGatheringNodes' Database Modules
```

Expected interpretation:

- `ApplyParameterized` must have no production usage.
- Before WP-00, `LoadDarkmoonFixes` may remain in the mixed correction files. After WP-00, it may
  remain only in the expansion-split Questie policy files and must not be ported into QuestieTDB.
- no production code should write legacy `*DataOverrides` after this packet;
- provider-owned faction, Titan, and SoD calls must be absent from Questie's runtime
  orchestrator;
- `DeleteGatheringNodes` must have no runtime caller.

Before final acceptance, run a live or emulator smoke test with the current Database Addon for:

- ordinary Era;
- SoD;
- TBC before and after phase 3;
- WotLK;
- Titan Reforged season 109;
- one built-in non-English locale;
- one External Locale Override if a fixture is available.

## Acceptance criteria

This packet is complete when all of the following are true:

1. Questie registers all Policy Corrections once under owner `"Questie"`.
2. QuestieTDB-owned faction, class/race, SoD, and Titan corrections are not duplicated.
3. Gathering-node suppression is visible only in composed Object reads.
4. TBC Content Phase transitions replace old prerequisite state.
5. Darkmoon transitions and withdrawal use the generic registrar with no provider-specific API.
6. Event Quest and announcement behavior remains unchanged.
7. External Locale Override entity values use Questie Policy Corrections.
8. Built-in entity localization comes from QuestieTDB.
9. Runtime missing-Item repair uses a name-only Item Correction and refreshes IDs.
10. Every post-initialization apply refreshes Questie's ID maps and semantic caches.
11. `GetRaw` remains unchanged for every Questie Policy Correction.
12. Provenance reports `"Questie"` for active Questie fields.
13. Empty captured tables withdraw old values.
14. Repeated apply is idempotent and does not duplicate registration.
15. No production code writes legacy `*DataOverrides` tables.
16. No production code calls `ApplyParameterized`.
17. Focused tests, the full Busted suite, luacheck, and `git diff --check` pass.
18. A fresh reviewer checks lifecycle order, correction ownership, withdrawal, caches, and test
    value.

## Follow-up after this packet

The wider refactor still needs:

- TDB-03 final compiler-free Login Initialization;
- TDB-05 completion after provider lookup parity;
- TDB-06 raw-table consumer conversion;
- TDB-08 compiler UI and Saved Variables cleanup;
- WP-00 behavior-neutral policy extraction on `baseline`, then TDB-09/TDB-10 TOC removal and
  physical deletion;
- TDB-11 support-data migration after issue #15;
- TDB-12 pinned Database Integration Check;
- release bundling and diagnostics.

Before the old correction files are deleted, WP-00 moves the embedded Questie-owned data into the
expansion-split policy files:

- Classic and TBC Darkmoon correction tables;
- TBC Content Phase prerequisites for quests `10944` and `11007`.

Questie blacklists, Event Quest data, and Content Phase state are already separate and remain in
place. Do not extract Objective Order tables into Questie; consumers stay bound to
`LibQuestieDB.ObjectiveFirst`.

## Evidence map

Questie:

- `CONTEXT.md`
- `TDB-REFACTOR.md`
- `Database/Corrections/QuestieCorrections.lua`
- `Database/QuestieDB.lua`
- `Database/Corrections/Holidays/QuestieEvent.lua`
- `Database/Corrections/tbcQuestFixes.lua`
- `Modules/Libs/QuestieLib.lua`
- `Localization/l10n.lua`
- `Modules/QuestieInit.lua`
- `test/QuestieTDBMock.lua`

QuestieTDB:

- `docs/adr/0007-dynamic-correction-ownership.md`
- `docs/api.md`
- `docs/questie-handover.md`
- `src/api.lua`
- `src/corrections/manifest.lua`
- `src/corrections/register.lua`
- `src/corrections/registry.lua`
- `src/read/shared.lua`
- `tools/port-corrections.lua`

## Agent completion record

The implementation agent must update this section before handoff:

- State: implemented and reviewed; live/emulator smoke testing still outstanding
- Owner: Dynamic Corrections packet session (orchestrator with one central worker, three
  policy-caller workers, one review-fix worker, two fresh reviewers)
- Changed files:
  - `Database/Corrections/QuestieCorrections.lua` — registrar lifecycle, eight Policy Correction
    registrations under owner `"Questie"` (`DarkmoonFaire` Npc/100, `GatheringNodeDisplayPolicy`
    Object/200, `ContentPhasePolicy` Quest/300, `RuntimeItemRepair` Item/400, four external-locale
    providers 500–503), setter API (`SetDarkmoonNpcCorrections`, `RepairMissingItem`,
    `WithdrawExternalLocaleCorrections`, `SetExternalLocaleCorrections`), shared apply path with
    guarded refresh; provider-owned faction/SoD/Titan/zhCN runtime application and `addOverride`
    removed; blacklist construction unchanged
  - new `Database/Corrections/QuestieCorrections.test.lua` (21 tests)
  - `Database/QuestieDB.lua` — `IsInitialized` lifecycle flag, `RefreshAfterCorrectionApply()`
    (rebinds four pointer maps, clears six semantic caches), `DeleteGatheringNodes` and the four
    `*DataOverrides` declarations removed
  - `Database/QuestieDB.test.lua` (56 tests)
  - `test/QuestieTDBMock.lua` — registrar fake (rebuild-not-accumulate, `{}` clears, withdrawal,
    correction-added ids, fresh id-map identity per refresh matching the real union swap),
    `GetRaw`, `Corrections.GetProvenance`, `l10n.SetLocale` recorder, inspection helpers,
    extended `Reset()`
  - new `test/QuestieTDBMock.test.lua` (26 tests)
  - `Modules/QuestieInit.lua` — Stage 1 `RequireContract(1)` hard gate before any correction or
    locale work, entity-locale forward, external-locale build before the initial apply,
    `QuestieEvent.Initialize()` moved after `QuestieDB:Initialize()`, gathering-node call removed
  - `Database/Corrections/Holidays/QuestieEvent.lua` — `_LoadDarkmoonFaire` uses one
    `SetDarkmoonNpcCorrections` call hoisted out of the Event Quest loop; NONE location withdraws;
    announcement/activeQuests/hiddenQuests policy unchanged (+ test file, 33 tests)
  - `Modules/Libs/QuestieLib.lua` — `CacheItemNames` name-only `RepairMissingItem` conversion; the
    invalid `{questId}`-in-`npcDrops` tuple was verified wrong and dropped (+ test file, 50 tests)
  - Historical `Localization/l10n.lua` work placed provider/external entity-locale orchestration and
    Object-name rebuilding in the UI-string module. The clean baseline deliberately removes that
    placement; fresh implementation keeps `l10n` UI-only and designs a focused entity-locale seam
    plus `QuestieTooltips.objectNameLookup` lifecycle (+ historical test file, 26 tests)
  - `Localization/lookups/lookupOverrides.lua` — issue #14 retention marker on the now
    caller-less `Questie.LoadTitanQuestLookupOverrides`
- Focused validation: QuestieCorrections 21/0, QuestieTDBMock 26/0, QuestieDB 56/0,
  QuestieEvent 33/0, QuestieLib 50/0, l10n 26/0
- Full validation: `busted -p ".test.lua" .` 1526 successes / 0 failures (baseline 1451);
  `luacheck -q` 0 warnings / 0 errors in 348 files; `git diff --check` clean; all four static
  retirement greps match the expected interpretation (`LoadDarkmoonFixes` remains only in
  Questie-owned fix files called by `QuestieEvent`; no production `*DataOverrides` references
  remain at all)
- Review: two fresh reviewers (lifecycle/ownership/withdrawal/caches; test value/mock fidelity).
  No blocking correctness findings. All actionable findings fixed: Stage 1 contract gate moved
  before locale/correction work; mock id-map identity made honest (red-proof: the previously
  vacuous refresh tests now fail when the pointer rebinds are removed); dead test scaffolding
  removed; issue #14 retention marker added
- Remaining blockers: QuestieTDB issue #14 for built-in lookup/Titan zhCN localization parity
  before the legacy lookup path is deleted; live or emulator smoke testing across the flavor
  matrix still needs an accessible `ownership` Database Addon installation
- Deferred/noted for later packets: pre-existing Isle of Quel'Danas split (options dropdown
  writes `Questie.db.profile.isleOfQuelDanasPhase`, the blacklist merge reads `global`) — Questie
  blacklist policy, untouched here; `RepairMissingItem` applies per async callback (full
  recompose each time; batching is an easy later optimization); the compiler-era locale-change
  path is historical evidence only, and the fresh runtime switch belongs outside `l10n`;
  QuestieInit Stage 1 has no test harness, so the login order is enforced by review and the
  QuestieCorrections integration-flow test rather than a Stage 1 test; pre-existing test-suite
  isolation leaks (`Expansions.Current`, `C_Calendar`, unrestored module stubs) continue in the
  Event/QuestieLib suites
