# Questie comms and hello design

## Status and scope

This is the canonical design note for Questie's modern party communication direction. It does not replace the legacy `QuestieComms` protocol in one step.

Milestone 1 delivers `QuestieH1` prefix discovery, the shared modern codec and routing foundation, and `QuestieV1` party-objective visibility as its first typed-prefix feature. Later milestones may add compact quest-log sharing through `QuestieQ1` or a successor, along with other typed prefixes. The existing Q1 design documents remain valid future work and roll forward beyond Milestone 1.

## Milestones

### Milestone 1 — Hello + visibility foundation (current)

Milestone 1 includes:

- `QuestieH1` static prefix discovery with `true`, `false`, and `nil` states,
- `CommsPrefixRegistry` ownership and group-gated hello convergence,
- the `CommsEncoding` CBOR -> Blizzard Deflate -> addon-channel-safe wire path with a shared 762-byte ceiling,
- shared group distribution and trust mechanics in `CommsRouting`,
- `QuestieV1` full visibility snapshots as the first modern typed-prefix feature,
- a party-objective pin consumer that respects V1 without mutating `remoteQuestLogs` or factual tooltip progress,
- automated unit and isolated-client tests for these contracts.

`QuestieH1` exposes `AcceptsPrefix` and `RejectsPrefix` for future capability-aware routing, fallback, and protocol migrations. Milestone 1 V1 broadcasts do not gate sends on `AcceptsPrefix`: V1 is a small-group broadcast limited to five members, a broadcast cannot exclude non-accepting members, and requiring known acceptance could lose initial convergence while H1 state is still unknown. Unknown must not be treated as rejection during bootstrap. An explicit `false` remains meaningful for known-but-disabled or sunset prefixes and future version negotiation; it does not merely mean that all knowledge of the prefix was removed. Receive paths do not gate otherwise valid incoming packets on the sender's advertised receive capability.

The following are outside Milestone 1:

- `QuestieQ1` and replacement of legacy quest-log sharing,
- capability-gated targeted routing or fallback selection in production send paths,
- live two-client or multi-client smoke testing in WoW; this remains deferred follow-up validation,
- a freshness or expiry policy for `remotePlayerLastSeen` beyond roster pruning,
- automatic H1 re-announcement when a prefix becomes active after initial startup, which is not required while H1/V1 initialization ordering is fixed,
- raising the shared 762-byte, three-message transport ceiling.

Milestone 1 is accepted when the design contracts in this document are implemented for H1, encoding/routing, and V1, and their owning automated tests cover the applicable items in [Testing and contracts](#testing-and-contracts). Live-client smoke testing is acknowledged follow-up validation, not a Milestone 1 blocker.

### Milestone 2+ — Compact quest-log sharing and capability-aware use (later)

Later milestones may include:

- `QuestieQ1`, or a successor, for absolute compact quest-log snapshots,
- H1-driven fallback between Q1 and legacy `questie` where needed,
- broader production use of `AcceptsPrefix` and `RejectsPrefix` for version and fallback selection,
- an optional V1 optimization after discovery converges, such as skipping its broadcast when every current member explicitly rejects V1; unknown state must still allow bootstrap sends,
- live multi-client validation as part of rollout confidence for new protocols.

The Q1 work rolls forward in:

- `Modules/Network/PRD/questie-q1-compact-quest-log-prd.md`,
- `docs/issues/define-q1-remote-quest-state-model.md`, the blocking design issue for Q1 implementation.

## Core principle: absolute remote party state

Questie needs an up-to-date, factual view of party members' quest-log and objective-progress state.

The canonical state is represented by `QuestieComms.remoteQuestLogs`:

```lua
remoteQuestLogs[questId][playerName] = objectives
```

That table means: the remote player has this quest, and this is the objective progress Questie knows for that player.

Quest-log transports MUST derive inclusion only from factual quest-log presence. Tracking, hidden state, display preference, UI policy, or whether the sender wants a quest represented MUST NOT affect inclusion.

For a complete, validated full snapshot, a present quest means the sender currently has it, and an omitted quest means the sender no longer has it. The receiver MUST validate the complete snapshot before atomically replacing prior sender state. Invalid or incomplete snapshots must leave prior state unchanged. Before any valid synchronization, absence may still mean unknown.

The planned `QuestieQ1` protocol would preserve this absolute contract in a compact full snapshot in a later milestone. The current `QuestieV1` protocol, owned by `CommsVisibility`, is the separate party-objective pin display-intent protocol. Visibility updates must never create, remove, or mutate `remoteQuestLogs` entries. This keeps "not shown as a party pin" distinct from "not in the quest log".

## Terms and semantics

`QuestieH1` uses a boolean prefix-state model:

- `true` means this client is listening to and parsing that prefix.
- `false` means this client knows the prefix contract, but intentionally does not support/listen to it right now.
- `nil` means unknown: no claim was made, or this build does not know that prefix.

`false` is for known disabled, sunset, or registered-later prefixes. It should not be used for speculative future versions. If a future prefix is not implemented yet, it should not be advertised until the receiver/parser exists and the prefix contract is real.

## `QuestieH1` hello design

`QuestieH1` is intentionally dumb. Its decoded payload is only a boolean map of Questie addon-message prefixes:

```lua
{
    QuestieH1 = true,
    QuestieV1 = true,
    questie = true,
    Questie = true,
}
```

The payload does not describe feature names, schemas, codecs, or semantic meaning. Local code decides what each prefix means.

`CommsPrefixRegistry` owns a static local prefix manifest. Known prefixes default to `false`. The module that actually registers and parses a prefix marks that prefix active only after registering its AceComm receiver:

```lua
Questie:RegisterComm("QuestieV1", CommsVisibility.OnCommReceived)
CommsPrefixRegistry:RegisterLocalPrefix("QuestieV1")
```

Unknown prefixes cannot be added dynamically. If local code tries to register an undefined prefix, that is a programming error and should produce a visible delayed error. Remote hello payloads are also sanitized: only known prefixes with boolean values are stored.

Remote player prefix state is stored separately from quest-log state:

```lua
CommsPrefixRegistry.remotePlayerPrefixes["Friend-Realm"] = {
    QuestieH1 = true,
    QuestieV1 = true,
    questie = true,
    Questie = true,
}
CommsPrefixRegistry.remotePlayerLastSeen["Friend-Realm"] = GetTime()
```

The hello module exposes prefix-state queries such as:

```lua
CommsPrefixRegistry:AcceptsPrefix(playerName, prefix)
CommsPrefixRegistry:RejectsPrefix(playerName, prefix)
```

Milestone 1 exposes these queries for later capability-aware routing; V1 group broadcasts do not consult them yet, as described in [Milestones](#milestones).

`QuestieH1` receive handling is group-gated. `PARTY`, `RAID`, `INSTANCE_CHAT`, and `WHISPER` are accepted only when the sender is a current group member. `CommsRouting` owns the shared modern comm routing mechanics: group broadcast distribution normalization, AceComm self filtering, and grouped-sender validation.

A group-broadcast `QuestieH1` means the sender is announcing a join/reload and needs our current state. Receivers store the sender's state and answer only that sender with a `WHISPER` `QuestieH1`, avoiding raid-wide response fanout. Incoming whispered hellos are stored but not answered, preventing ping-pong.

## Module ownership

`CommsPrefixRegistry` owns only:

- the static prefix manifest,
- local prefix active/inactive state,
- remote player prefix state,
- hello send/receive mechanics.

`CommsVisibility` owns `QuestieV1` party-objective pin display intent.

`QuestieComms` continues to own the legacy absolute quest-log/progress transport and `remoteQuestLogs` semantics.

The existing `Comms` module registers the Questie-owned daily quest prefix as active through `CommsPrefixRegistry` after its receiver is registered. That allows the hello payload to reflect reality instead of a hardcoded assumption. The old `REPUTABLE` receiver can remain registered for backward compatibility, but it is intentionally outside QuestieH1 capability discovery.

Future modern comm modules should follow the same pattern: define the prefix in the hello manifest, register the AceComm receiver in the owning module, then call `CommsPrefixRegistry:RegisterLocalPrefix(prefix)`. If that module is later removed, the prefix will naturally remain false or disappear from the manifest, instead of being accidentally advertised as supported.

## Wire and codec direction

The future comms direction is typed prefixes with body-only payloads. The prefix should imply message type, schema, and codec. Modern packets should not carry `msgId`, `msgVer`, `codec`, or `schema` fields in every payload when the prefix already defines those things.

The current modern-prefix wire path is owned by `CommsEncoding`:

```text
Lua table
-> C_EncodingUtil.SerializeCBOR
-> C_EncodingUtil.CompressString(..., Enum.CompressionMethod.Deflate)
-> addon-channel-safe byte encoding
-> Questie:SendCommMessage(prefix, encodedPayload, distribution)
```

The receive path reverses that process:

```text
addon-channel-safe byte decoding
-> C_EncodingUtil.DecompressString(..., Enum.CompressionMethod.Deflate)
-> C_EncodingUtil.DeserializeCBOR
```

Questie embeds the full LibDeflate library for its proven addon-channel-safe byte encoding and decoding. `CommsEncoding` uses only `EncodeForWoWAddonChannel` and `DecodeForWoWAddonChannel`; compression is Blizzard's built-in Deflate through `C_EncodingUtil`, not LibDeflate compression.

All protocols using `CommsEncoding` share a maximum final encoded payload of 762 bytes. AceComm reserves one byte from each 255-byte multipart message, so 762 bytes is exactly three multipart payloads of 254 bytes. Encoding returns nil above that ceiling, and decoding rejects oversized input before addon-channel decoding, decompression, or CBOR deserialization. AceComm may still reassemble incoming multipart traffic before calling Questie.

The existing `<= 245` H1 output guardrail remains intentionally stricter so normal hello traffic stays within one message. QuestieV1 relies on the shared three-message ceiling instead of defining a separate entry-count or encoded-size policy. If a future modern protocol needs more than three messages, changing that shared transport contract should be an explicit design decision.

If a future prefix changes wire shape or codec incompatibly, create a new prefix instead of adding per-packet negotiation fields.

## `QuestieV1` visibility snapshot protocol

`QuestieV1` is implemented by `CommsVisibility`. It is a full snapshot of party-objective map/minimap pin display intent:

```lua
{
    [questId] = true,   -- draw this player's party objective pins for the quest
    [questId] = false,  -- suppress this player's party objective pins for the quest
}
```

There are no incremental `QuestieV1` update packets, no count field, and no `msgId`/`msgVer`/`codec` fields. The prefix defines the schema.

Receive-side rules:

- every key must be a positive integer quest ID,
- every value must be boolean,
- the complete payload is validated before atomically replacing the player's prior snapshot; malformed or otherwise invalid payloads leave prior state unchanged,
- no stored snapshot for a player means unknown and defaults to shown for backward compatibility,
- after a valid full snapshot is stored, omitted quest IDs are authoritatively suppressed for that player's party pins,
- receiving visibility never creates, removes, or mutates `QuestieComms.remoteQuestLogs`.

`QuestieV1` is not a privacy or progress-data filter. It gates only party objective pins created for quests the local player does not have or has already completed. Contextual tooltip progress can still be shown from `remoteQuestLogs` when the user hovers a relevant mob, item, object, or existing icon.

`QuestieV1` snapshots are not scheduled or sent when `GetNumGroupMembers() > 5`. The prefix only affects party objective pins, and those pins are only useful in small party-sized groups, so suppressing snapshots in larger groups avoids raid/BG/formation churn traffic where the message cannot affect rendering.

The local snapshot includes only quests currently in `QuestLogCache.questLog_DO_NOT_MODIFY`. For each such quest, local policy is:

```lua
if Questie.db.char.hidden and Questie.db.char.hidden[questId] then
    return false
end

return QuestieQuest:IsQuestTracked(questId)
```

So manually hidden quests and untracked quests suppress party objective pins, while quest-log/progress truth continues through the normal quest-log comms.

## Scheduling and convergence

`CommsPrefixRegistry` and `CommsVisibility` schedule sends with cancellable `C_Timer.NewTimer` debounce.

- A new schedule call cancels the pending timer and starts a fresh one.
- The eventual send uses the latest full state.
- `ResetAll()` cancels pending timers, so group-leave cleanup stops queued hello or visibility traffic.
- `ScheduleHello()` and `ScheduleSnapshot()` are the public outbound paths for group-broadcast hello and visibility state.
- `ScheduleHello()` belongs to the joining or reloading client (`GROUP_JOINED`, including the already-grouped login/reload path). `GROUP_ROSTER_UPDATE` runs on every client, so it must not schedule H1.

`QuestieV1` snapshots are intentionally full-state and small. They are scheduled at convergence points where remote players may need fresh state:

- group join and meaningful roster changes,
- responding to a full quest-log request,
- quest accept, completion, or abandonment,
- quest hide/unhide,
- track/untrack and bulk tracker mode changes.

This avoids incremental visibility bookkeeping while keeping existing group members synchronized after reloads or quest/tracker state changes.

## Compatibility and sunsetting

The `true` / `false` / `nil` model gives Questie a long-term transition path.

During a transition, a client can advertise multiple active prefixes:

```lua
{
    OldPrefix = true,
    NewPrefix = true,
}
```

When a known prefix is intentionally disabled or sunset, a client can advertise:

```lua
{
    OldPrefix = false,
    NewPrefix = true,
}
```

A remote player that only understands `OldPrefix` can distinguish that from an unknown client and may show a clear update message if appropriate.

When a prefix is unknown to this build, it remains `nil`. Unknown remote claims are ignored for behavior. Unknown local registration attempts are errors because every advertised prefix must be intentionally defined in the hello manifest first.

Questie-owned prefixes such as `questie` and `Questie` are included so their support can eventually be sunset deliberately. As long as their parser modules exist and register receivers, they advertise `true`. If a handler is removed and no longer calls `RegisterLocalPrefix`, the prefix stops being advertised as active.

`REPUTABLE` is different: it is an old compatibility receiver, not a QuestieH1 capability. Questie can still accept that old receiver path until production support is removed separately, but remote hello claims for it are ignored like any other unknown prefix.

## Testing and contracts

Tests should protect these contracts:

- known local prefixes default to `false`,
- owning modules flip prefixes to `true` only after registering their receivers,
- unknown local prefixes are not added dynamically and produce a visible delayed error,
- remote hello payloads store only known boolean prefix values,
- `WHISPER` hello and visibility messages are accepted only from current group members,
- self echoes and cross-realm same-name players are handled correctly,
- scheduled hello and visibility sends are debounced and canceled by `ResetAll()`,
- detected group-size changes prune stale remote players, resend visibility, and redraw party objectives without broadcasting H1; quest-sharing online-status changes do the same,
- full quest-log snapshots include every current quest regardless of tracking, hidden state, display preference, or UI policy,
- complete validated snapshots replace prior sender state atomically, while invalid or incomplete snapshots leave it unchanged,
- `remoteQuestLogs` remains absolute quest-log/progress state,
- visibility packets do not create or remove `remoteQuestLogs` entries,
- no QuestieV1 snapshot defaults to shown, while omission from a valid full snapshot suppresses that player's party pins,
- invalid QuestieV1 snapshots preserve the player's prior valid visibility state,
- `QuestieV1` affects party objective pins, not quest-log inclusion or contextual tooltip progress,
- live multi-client smoke tests remain deferred follow-up validation outside the automated Milestone 1 suite.
