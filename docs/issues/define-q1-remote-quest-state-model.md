# Define the QuestieQ1 remote quest state model

**Type:** HITL

## Current behavior

`Modules/Network/PRD/questie-q1-compact-quest-log-prd.md` requires QuestieQ1 to carry factual quest presence, whole-quest complete/incomplete/failed state, zero-objective quests, and compact objective progress.

The current consumer-facing shape is effectively:

```lua
QuestieComms.remoteQuestLogs[questId][playerName] = objectives
```

That shape represents objective rows but has no defined place for authoritative quest-level state, especially for complete, failed, or incomplete quests with no objectives. It is also indexed quest-first, while QuestieQ1 requires atomic replacement of one sender's complete validated snapshot.

Implementing the wire protocol before selecting a storage and compatibility model would force protocol code to invent domain ownership and migration policy during implementation.

## What to decide and document

Produce an approved design for the canonical remote quest record and its owning API before QuestieQ1 implementation begins. The design must cover:

- factual quest presence only; tracking, hidden state, and display policy never affect inclusion;
- quest-level complete/incomplete/failed state, including zero-objective quests;
- rich reconstructed objective rows required by existing map and tooltip consumers;
- atomic per-sender snapshot commit after complete validation;
- preservation of prior state when a snapshot is incomplete or invalid;
- compatibility for existing consumers of `remoteQuestLogs`;
- coexistence and source precedence when legacy and Q1 state arrive for the same player;
- reset, roster-prune, and player-removal behavior;
- ownership boundaries between absolute state and QuestieV1 display intent.

Compare at least these implementation shapes before selecting one:

1. a new player-first canonical store with a compatibility projection for `remoteQuestLogs`;
2. a richer quest-first record with an atomic staging/commit API;
3. a separate quest-level-state store paired with existing objective rows.

The decision should optimize for clear ownership and atomic replacement, not merely the smallest initial diff.

## Acceptance criteria

- [ ] An approved design document defines the canonical record shape with LuaCATS-style example types.
- [ ] The model can retain all three quest states for quests with zero objectives.
- [ ] The model preserves the rich objective data needed by current map and tooltip consumers.
- [ ] A named owner exposes atomic `prepare/validate/commit` or equivalent snapshot semantics per sender.
- [ ] Missing quests are removed only by committing a complete valid factual snapshot; invalid input leaves prior state unchanged.
- [ ] Legacy-versus-Q1 source precedence and duplicate delivery behavior are explicit.
- [ ] Reset, roster pruning, and sender removal are explicit.
- [ ] Existing `remoteQuestLogs` consumers are inventoried and each has a migration, adapter, or compatibility plan.
- [ ] QuestieV1 remains separate and cannot mutate the canonical factual store.
- [ ] Required implementation and integration tests are listed before the QuestieQ1 prefix is registered or advertised.
- [ ] A human maintainer approves the selected shape and ownership boundary.

## Validation

- Review the design against:
  - `docs/questie-comms-design.md`
  - `Modules/Network/AGENTS.md`
  - `Modules/Network/PRD/questie-q1-compact-quest-log-prd.md`
- Use `rg -n -F 'remoteQuestLogs' -- Modules Public Questie.lua` to verify that the consumer inventory is complete.
- Run `git diff --check` on the resulting documentation change.

## Blocked by

None - can start immediately.

**Blocks:** QuestieQ1 protocol implementation, prefix registration, and H1 advertisement.

## Non-goals

- Implementing or registering QuestieQ1 in this issue.
- Filtering factual state by tracking, hidden state, or any UI preference.
- Rewriting the legacy `questie` wire protocol.
- Selecting a design solely to preserve every internal table access unchanged.
