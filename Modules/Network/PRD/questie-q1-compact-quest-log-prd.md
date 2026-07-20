# QuestieQ1 compact quest-log sharing PRD

## Problem statement

Questie currently shares party quest-log progress through the legacy `questie` protocol. That protocol sends repeated per-objective metadata such as objective IDs, objective type, fulfilled count, and required count. It works, but realistic worst-case quest logs can require many addon-channel chunks, which makes raid-scale sharing unattractive.

We want a new Questie-owned, prefix-versioned quest-log sharing format that can carry a full player quest-log snapshot in one message for realistic worst cases, or at most two addon-channel messages if future data grows. The new format should preserve high-fidelity objective progress while omitting data the receiver can reconstruct from its local Questie database or quest API/cache.

## Status

`QuestieQ1` is post-Milestone 1 work. Milestone 1 delivers `QuestieH1`, the shared modern encoding/routing foundation, and `QuestieV1` visibility only. This PRD remains the working Q1 design and rolls forward into a later milestone; it does not describe an implemented protocol. Implementation is blocked until the remote quest state model is decided in `docs/issues/define-q1-remote-quest-state-model.md`.

## Goals

- Add a new modern quest-log sharing protocol that coexists with the legacy `questie` protocol.
- Use a versioned addon prefix, provisionally `QuestieQ1`, instead of per-message `ver`, `msgVer`, or `msgId` fields.
- Advertise support through `QuestieH1` prefix discovery.
- Send absolute full quest-log snapshots rather than incremental update/remove packet families.
- Include every quest the sender currently has, independent of tracking or display policy.
- Preserve exact fulfilled progress counts and explicit objective completion state.
- Preserve whole-quest completion state, including quests with no objectives.
- Keep the realistic 25-quest worst-case payload comfortably within one addon-channel message after CBOR + Deflate + addon-channel-safe encoding.
- Reconstruct the existing rich `remoteQuestLogs` objective rows on receive so current UI consumers can continue to read the familiar shape.

## Non-goals

- Do not remove or rewrite the legacy `questie` protocol in the initial implementation.
- Do not send objective IDs, objective types, or required counts in the new packet unless later correctness work proves they are required.
- Do not add a low-fidelity raid-only protocol in the first version. A bitmask-only mode can be considered later if high-fidelity sharing becomes too expensive.
- Do not rely on per-message version fields. Version changes should use new prefixes or H1-negotiated capabilities.
- Do not claim exact live-client compression parity from local tests; near-limit payloads still need live client verification.

## Proposed protocol

### Prefix

Use a new fixed addon prefix, provisionally:

```text
QuestieQ1
```

The prefix defines the schema and codec. If the schema changes incompatibly, add a new prefix such as `QuestieQ2` instead of adding `msgVer` inside every payload.

`QuestieH1` advertises whether the client can receive `QuestieQ1`:

```lua
{
    QuestieH1 = true,
    QuestieV1 = true,
    QuestieQ1 = true,
    questie = true,
    Questie = true,
}
```

### Codec

Use the modern Questie comm encoding path:

```text
Lua table
-> C_EncodingUtil.SerializeCBOR
-> C_EncodingUtil.CompressString(..., Deflate)
-> addon-channel-safe byte encoding
-> AceComm / addon channel
```

The payload body does not contain codec, message type, schema, addon version, or QuestieComms message ID fields. Those are implied by the prefix and H1 capability negotiation.

## Payload contract

A `QuestieQ1` payload is a complete, absolute snapshot of the sender's current quest log:

```lua
{
    [questId] = {
        questState,
        {
            {fulfilled, objectiveCompleteOrNil},
            {fulfilled, objectiveCompleteOrNil},
        },
    },
}
```

### Quest state

`questState` is an integer enum:

```lua
QUEST_STATE_FAILED = -1
QUEST_STATE_INCOMPLETE = 0
QUEST_STATE_COMPLETE = 1
```

The quest-level state is intentionally explicit. Objective rows alone cannot represent a complete or failed quest that has no objectives.

### Objective rows

Each objective row is indexed by objective order:

```lua
{fulfilled, true} -- objective complete
{fulfilled}       -- objective incomplete
```

`fulfilled` is the sender's current fulfilled/progress count for that objective. `objectiveCompleteOrNil` is `true` only when the objective is complete; omitted/nil means incomplete.

The objective list is nested for parsing clarity:

```lua
local questState = questRow[1]
local objectives = questRow[2] or {}
for objectiveIndex, objectiveRow in ipairs(objectives) do
    local fulfilled = objectiveRow[1]
    local objectiveComplete = objectiveRow[2] == true
end
```

No objective count is sent. The count is naturally available as:

```lua
local objectiveCount = #objectives
```

### Zero-objective quests

A quest with no objectives is represented with an empty objective list:

```lua
[questId] = {QUEST_STATE_COMPLETE, {}}
[questId] = {QUEST_STATE_INCOMPLETE, {}}
[questId] = {QUEST_STATE_FAILED, {}}
```

This preserves quest presence and whole-quest state even when there are no objective rows to send.

## Snapshot semantics

`QuestieQ1` is absolute full-state only:

- The sender MUST include every quest currently in its quest log.
- A present quest means the sender currently has that quest.
- A quest missing from the next complete, validated snapshot means the sender no longer has that quest. No other meaning is permitted.
- Tracking, hidden state, display preference, UI policy, or whether the sender wants a quest represented MUST NOT affect inclusion.
- The receiver MUST decode, validate, and prepare the entire snapshot before changing the sender's prior state. It MUST then replace that state atomically.
- An incomplete, malformed, oversized, or truncated snapshot MUST NOT change prior state. The receiver MUST NOT apply rows incrementally.
- Incremental quest-update and quest-remove packets are not part of this protocol version.

`QuestieV1` remains the separate display-intent protocol for party objective pins. `QuestieV1` state and all other display policy MUST NOT affect `QuestieQ1` inclusion or mutate absolute remote quest-log state.

Full snapshots reduce packet-family complexity and avoid ambiguity around missed updates, reloads, and roster convergence.

## Receiver reconstruction

The sender omits per-objective metadata that should be recoverable by compatible Questie clients:

- objective ID;
- objective type;
- required count.

The blocking HITL issue in `docs/issues/define-q1-remote-quest-state-model.md` decides canonical remote quest-state storage, ownership, and the atomic commit API. On receive, Questie reconstructs rich objective rows before committing through that approved owner. Existing UI and tooltip consumers may receive the familiar `remoteQuestLogs` shape through a compatibility projection or adapter rather than treating it as the canonical storage sink:

```lua
{
    index = objectiveIndex,
    id = reconstructedObjectiveId,
    type = reconstructedObjectiveType,
    fulfilled = fulfilled,
    required = reconstructedRequiredCount,
    finished = objectiveComplete,
}
```

Potential reconstruction sources, in preferred order, should be decided during implementation:

1. local quest API/cache for the quest when available and trustworthy;
2. Questie database objective metadata for objective ID/type/order;
3. safe degraded behavior when required count or objective metadata is missing.

The completion flags from the packet should remain authoritative for complete/incomplete state. Required counts are needed for display such as `3/10`, but a missing or stale required count should not make a complete objective appear incomplete.

## Compatibility and rollout

- `QuestieQ1` must coexist with the legacy `questie` prefix.
- The legacy `questie` protocol remains the fallback for clients that do not advertise `QuestieQ1` support.
- H1 prefix discovery decides whether a peer can receive `QuestieQ1`.
- Initial rollout should prefer party/small-group sharing. Raid sharing can be enabled once the realistic payload guardrails and live-client checks show the payload consistently fits the target budget.
- If a future schema change is needed, add a new prefix rather than adding version fields to this payload.

## Size evidence

Measurements used the existing realistic 25-quest guardrail fixture:

- 25 real Questie quests;
- 109 total objectives;
- max 6 objectives on a quest;
- all objectives complete for the nested objective-list worst case;
- no old `ver`, `msgVer`, or `msgId` wrapper.

`safe` means Deflate compressed and addon-channel-safe encoded.

| Shape | Questie raw | Questie safe | Ace raw | Ace safe | CBOR raw | CBOR safe |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Current V2 compact payload | 930 | 426 | 4544 | 1563 | 1038 | 433 |
| New nested objective list, complete | 639 | 130 | 2542 | 172 | 479 | 127 |
| New nested objective list, incomplete | 530 | 129 | 1997 | 163 | 370 | 115 |
| New nested objective list plus two zero-objective examples | 659 | 149 | 2590 | 189 | 495 | 141 |

Quest-state enum values `-1`, `0`, and `1` had no meaningful size difference in the target CBOR + Deflate path during measurement. Negative values are acceptable for the failed state.

The key result is that the proposed high-fidelity nested format stays well below the 255-byte single-message threshold in the target CBOR-safe path for the current realistic worst case.

## Testing and guardrails

Tests should live with the owning modules, not in a centralized integration pile.

Required guardrails:

- `CommsPrefixRegistry` tests should cover H1 advertisement of `QuestieQ1` once the receiver exists.
- Quest-log protocol tests should cover encoding, decoding, atomic full-snapshot replacement, authoritative missing-quest removal, and fallback to legacy `questie` when a peer does not advertise `QuestieQ1`.
- Sender tests must prove every current quest is included despite tracked, untracked, hidden, shown, or other display-policy state.
- Receiver tests must prove incomplete or invalid snapshots leave the prior sender state unchanged and never apply partial rows.
- Reconstruction tests should prove that the compact payload produces rich objective rows with reconstructed ID/type/required fields through the approved canonical API or `remoteQuestLogs` compatibility projection.
- Tooltip-side tests should cover available required counts and degraded/missing required counts.
- Party-objective tests should prove `QuestieV1` affects only display intent and never `QuestieQ1` inclusion or absolute remote quest-log state.
- Realistic 25-quest payload guardrails must be kept or updated when quest data or schema changes.
- Zero-objective quest tests must cover complete, incomplete, and failed quest states.
- Trust-boundary tests must reject unsupported distributions and non-group senders.

Size guardrails should assert upper bounds and round-trip behavior. Avoid brittle lower-bound size assertions; document observed sizes instead.

## Risks and open questions

- **Objective order:** The compact format assumes sender and receiver agree on objective order for a quest. Tests must cover safe failure or degraded behavior when local data is missing or mismatched.
- **Required counts:** QuestieDB does not always contain required counts. The receiver may need local quest API/cache data for display. Completion flags should prevent correctness from depending entirely on required counts.
- **DB/API mismatch fallback:** The legacy protocol sends remote objective ID/type, which can help when local data disagrees. `QuestieQ1` drops that fallback, so implementation must decide whether degraded display is acceptable or whether rare fallback fields are needed.
- **Zero-objective quests:** The new shape supports them, but UI behavior for showing whole-quest state may need new consumers.
- **Raid policy:** Payload size appears suitable, but enabling raids also requires a product decision about traffic frequency, roster churn, and whether every raid member should exchange full snapshots.
- **Live-client parity:** Local CBOR/Deflate measurements are strong guardrails, but payloads near addon-channel limits should still be verified in a live WoW client.

## Future ideas

A low-fidelity raid-only format could send only quest state and objective completion state, omitting fulfilled counts. Current measurements suggest it would be even smaller, but the high-fidelity nested format is already small enough that a separate low-fidelity mode is not necessary for the first version.
