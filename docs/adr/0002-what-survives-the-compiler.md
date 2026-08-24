# What survives when the compiler is removed

[ADR 0001](./0001-questie-as-database-consumer.md) moves the database into QuestieTDB and
removes `Database/compiler.lua`. That decision is unchanged. This record exists because the
compiler is not the only thing in the pre-compile path: `Modules/QuestieInit.lua:118-134`
runs four transforms over the entity tables between loading corrections and compiling, and
they look like compiler machinery without being it.

```
QuestieCorrections:Initialize()            -- correction files, then a derived requiredRaces patch
Townsfolk.Initialize()                     -- not entity data
l10n:Initialize()                          -- writes lookup translations into the entity tables
QuestieDB.private:DeleteGatheringNodes()   -- strips spawns from 24 gathering objects
QuestieCorrections:PreCompile()            -- waypoint simplification, every NPC and object
```

Deleting them alongside the compiler would be a silent behaviour change, because every one
of them is visible through `QueryQuestSingle` and friends today. Each therefore has a
declared disposition. None of this was discovered by reading — it came out of
QuestieTDB's reference-implementation differential, which compares this compiled database
field by field against QuestieTDB's reads.

## Dispositions

**`DeleteGatheringNodes` stays in Questie, as a registered Dynamic Correction.** This is the
one that would otherwise be lost. Objects 1617, 1731 and the other 22 gathering nodes
genuinely have spawns — 17,191 of them — and QuestieTDB ships every one. Declining to draw
them is a rendering decision, which ADR 0001 already assigns to Questie ("hiding an entity
is consumer policy, not a database fact, so blacklists deliberately stay here"). It is
re-registered through QuestieTDB's public API, exactly like the faction fixes:

```lua
local registrar = LibQuestieDB.GetRegistrar("Questie")
registrar.RegisterRuntimeCorrection("Object", "gathering-nodes", function()
    local objectKeys = LibQuestieDB.Meta.ObjectMeta.objectKeys
    return { [1617] = { [objectKeys.spawns] = {} }, ... }
end, <loadOrder>)
```

`{}` is QuestieTDB's delete idiom: the field reads back nil, the object still exists, its
name still reads, and withdrawing the correction restores the spawns.

**`l10n:Initialize`'s writes into the entity tables are deleted outright.** Copying lookup
translations into `questData` / `npcData` / `itemData` / `objectData` before compiling is
precisely what made the compiled database locale-specific and forced the `dbCompiledLang`
recompile that ADR 0001 removes. QuestieTDB serves the same six fields — quest `name` and
`objectivesText`, npc `name` and `subName`, item `name`, object `name` — from a locale
overlay, switchable at runtime with no rebuild. The rest of `l10n` (UI translations, zone and
category lookups) is untouched.

**`PreCompile`'s waypoint simplification moves to QuestieTDB** as a derived pass, along with
`Modules/Libs/RamerDouglasPeucker.lua`, which QuestieTDB copies byte-identically and diffs in
CI. It must keep running somewhere: it is not an optimisation of stored size, it changes the
waypoints consumers draw, in 454 of the 480 Vanilla NPCs that have them.

**The derived `requiredRaces` patch at the end of `QuestieCorrections:Initialize` is
unresolved.** It infers a quest's faction from its NPC starters when the data supplies none,
and it decides `requiredRaces` for 7 to 696 quests per flavour — a field that gates quest
availability. It must not be deleted until it has been replaced, and the intended replacement
is explicit correction data rather than a port of the loop. Tracked in
`TASK-derived-requiredRaces.md` at the workspace root.

## Consequences

- `QuestieCorrections.lua` cannot simply be deleted with the rest of the correction loading.
  It is the file where derived logic hid, and it needs an audit rather than a removal —
  QuestieTDB's port copies correction *files*, so anything living in the orchestrator was
  never carried across.
- Questie gains a small registration block for the gathering nodes. That is the whole cost of
  keeping 17,191 spawn points available to every other QuestieTDB consumer.
- QuestieTDB's differential will keep reporting those 24 objects as divergent, permanently and
  correctly, because it loads QuestieTDB standalone and never sees Questie's corrections. The
  divergence is recorded there as `POLICY`, pointing back at this record.
- The full disposition ledger, including verification status per item, is
  `QuestieTDB/docs/questie-handover.md`.
