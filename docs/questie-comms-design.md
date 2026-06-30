# Questie comms and hello design

## Status and scope

This is a design note for Questie's current and future party communication direction. It is not a complete rewrite specification and it does not replace the existing `QuestieComms` protocol in one step.

The purpose of this document is to preserve the core decisions behind the modern comm modules that now start with `QuestieH1` hello, `CommsEncoding`, and `QuestieV1` party-objective visibility.

## Core principle: absolute remote party state

Questie needs an up-to-date, factual view of party members' quest-log and objective-progress state.

Today that state is represented by `QuestieComms.remoteQuestLogs`:

```lua
remoteQuestLogs[questId][playerName] = objectives
```

That table means: the remote player has this quest, and this is the objective progress Questie knows for that player.

Absence from `remoteQuestLogs` must not be overloaded to mean "hidden", "untracked", or "not shown". A missing entry should mean the quest is actually absent, removed, unknown, or not yet synchronized. UI/display preferences are a different kind of state.

`CommsVisibility` stores party-objective pin display intent separately. Visibility updates must never create, remove, or mutate `remoteQuestLogs` entries. This keeps "not shown as a party pin" distinct from "not in the quest log".

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
    REPUTABLE = true,
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
    REPUTABLE = true,
}
CommsPrefixRegistry.remotePlayerLastSeen["Friend-Realm"] = GetTime()
```

The hello module exposes prefix-state queries such as:

```lua
CommsPrefixRegistry:AcceptsPrefix(playerName, prefix)
CommsPrefixRegistry:RejectsPrefix(playerName, prefix)
```

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

The existing `Comms` module and the old `REPUTABLE` path register their current prefixes as active through `CommsPrefixRegistry` after their receivers are registered. That allows the hello payload to reflect reality instead of a hardcoded assumption.

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

`CommsEncoding` contains only the trimmed addon-channel-safe codec pieces Questie needs, with LibDeflate/LibCompress attribution preserved. Compression is Blizzard's built-in Deflate through `C_EncodingUtil`, not LibDeflate compression.

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

- only positive integer quest IDs are accepted,
- only boolean values are accepted,
- at most 50 entries are stored from one snapshot,
- malformed values are ignored,
- missing quest IDs mean unknown and default to shown,
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

Legacy prefixes such as `questie`, `Questie`, and `REPUTABLE` are included so their support can eventually be sunset deliberately. As long as their parser modules exist and register receivers, they advertise `true`. If a handler is removed and no longer calls `RegisterLocalPrefix`, the prefix stops being advertised as active.

## Testing and contracts

Tests should protect these contracts:

- known local prefixes default to `false`,
- owning modules flip prefixes to `true` only after registering their receivers,
- unknown local prefixes are not added dynamically and produce a visible delayed error,
- remote hello payloads store only known boolean prefix values,
- `WHISPER` hello and visibility messages are accepted only from current group members,
- self echoes and cross-realm same-name players are handled correctly,
- scheduled hello and visibility sends are debounced and canceled by `ResetAll()`,
- detected group-size changes prune stale remote players and schedule a new hello/snapshot; quest-sharing online-status changes schedule party objective redraws,
- `remoteQuestLogs` remains absolute quest-log/progress state and is not filtered by visibility/tracking preferences,
- visibility packets do not create or remove `remoteQuestLogs` entries,
- `QuestieV1` affects party objective pins, not contextual tooltip progress.
