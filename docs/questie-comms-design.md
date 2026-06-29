# Questie comms and hello design

## Status and scope

This is a design note for Questie's current and future party communication direction. It is not a complete rewrite specification and it does not replace the existing `QuestieComms` protocol in one step.

The purpose of this document is to preserve the core decisions behind the `QuestieH1` hello module and the next communication layers we expect to build on top of it.

## Core principle: absolute remote party state

Questie needs an up-to-date, factual view of party members' quest-log and objective-progress state.

Today that state is represented by `QuestieComms.remoteQuestLogs`:

```lua
remoteQuestLogs[questId][playerName] = objectives
```

That table means: the remote player has this quest, and this is the objective progress Questie knows for that player.

Absence from `remoteQuestLogs` must not be overloaded to mean "hidden", "untracked", or "not shown". A missing entry should mean the quest is actually absent, removed, unknown, or not yet synchronized. UI/display preferences are a different kind of state.

Future hidden/tracked/shown behavior should live in a separate store and protocol. For example, a later module may keep remote visibility state keyed by player and quest, but that state must not create, remove, or corrupt `remoteQuestLogs` entries by itself.

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
    questie = true,
    Questie = true,
    REPUTABLE = true,
}
```

The payload does not describe feature names, schemas, codecs, or semantic meaning. Local code decides what each prefix means.

`CommsHello` owns a static local prefix manifest. Known prefixes default to `false`. The module that actually registers and parses a prefix marks that prefix active only after registering its AceComm receiver:

```lua
Questie:RegisterComm("questie", _QuestieComms.OnCommReceived)
CommsHello:RegisterLocalPrefix("questie")
```

Unknown prefixes cannot be added dynamically. If local code tries to register an undefined prefix, that is a programming error and should produce a visible delayed error. Remote hello payloads are also sanitized: only known prefixes with boolean values are stored.

Peer state is stored separately from quest-log state. The hello module exposes prefix-state queries such as:

```lua
CommsHello:GetPeerPrefixState(playerName, prefix)
CommsHello:IsPeerListening(playerName, prefix)
CommsHello:DoesPeerRejectPrefix(playerName, prefix)
```

`QuestieH1` receive handling is group-gated. `PARTY`, `RAID`, `INSTANCE_CHAT`, and `WHISPER` are accepted only when the sender is a current group member. Whisper is useful for peer-specific negotiation, but it must not become an unrestricted external input channel.

## Module ownership

`CommsHello` owns only:

- the static prefix manifest,
- local prefix active/inactive state,
- peer prefix state,
- hello send/receive mechanics.

`QuestieComms` continues to own the legacy absolute quest-log/progress transport and `remoteQuestLogs` semantics.

The existing `Comms` module and the old `REPUTABLE` path register their current prefixes as active through `CommsHello` after their receivers are registered. That allows the hello payload to reflect reality instead of a hardcoded assumption.

Future modern comm modules should follow the same pattern: define the prefix in the hello manifest, register the AceComm receiver in the owning module, then call `CommsHello:RegisterLocalPrefix(prefix)`. If that module is later removed, the prefix will naturally remain false or disappear from the manifest, instead of being accidentally advertised as supported.

## Wire and codec direction

The future comms direction is typed prefixes with body-only payloads. The prefix should imply message type, schema, and codec. Modern packets should not carry `msgId`, `msgVer`, `codec`, or `schema` fields in every payload when the prefix already defines those things.

The current `QuestieH1` wire path is:

```text
Lua table
-> C_EncodingUtil.SerializeCBOR
-> C_EncodingUtil.CompressString(..., Enum.CompressionMethod.Deflate)
-> LibDeflate:EncodeForWoWAddonChannel
-> Questie:SendCommMessage("QuestieH1", encodedPayload, distribution)
```

The receive path reverses that process:

```text
LibDeflate:DecodeForWoWAddonChannel
-> C_EncodingUtil.DecompressString(..., Enum.CompressionMethod.Deflate)
-> C_EncodingUtil.DeserializeCBOR
```

In this path, LibDeflate is used only for addon-channel-safe encoding and decoding. Compression is Blizzard's built-in Deflate through `C_EncodingUtil`, not LibDeflate compression.

If a future prefix changes wire shape or codec incompatibly, create a new prefix instead of adding per-packet negotiation fields.

## Future visibility/show-hide design

Remote visibility, show/hide, and tracking intent should be implemented as a separate module and prefix when the receiver exists. Until then, no visibility prefix should be advertised as known support.

That future state should be stored separately from `remoteQuestLogs`, for example as a remote UI-state or visibility table keyed by player and quest. The exact name and shape should be chosen when the feature is implemented.

The important contract is:

- visibility updates may influence party-objective display,
- visibility updates must never create quest-log entries,
- visibility updates must never remove quest-log entries,
- quest-log remove/sync messages remain the source of truth for remote quest presence/progress.

This keeps "not shown" distinct from "not in the quest log".

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

A peer that only understands `OldPrefix` can distinguish that from an unknown client and may show a clear update message if appropriate.

When a prefix is unknown to this build, it remains `nil`. Unknown remote claims are ignored for behavior. Unknown local registration attempts are errors because every advertised prefix must be intentionally defined in the hello manifest first.

Legacy prefixes such as `questie`, `Questie`, and `REPUTABLE` are included so their support can eventually be sunset deliberately. As long as their parser modules exist and register receivers, they advertise `true`. If a handler is removed and no longer calls `RegisterLocalPrefix`, the prefix stops being advertised as active.

## Testing and contracts

Tests should protect these contracts:

- known local prefixes default to `false`,
- owning modules flip prefixes to `true` only after registering their receivers,
- unknown local prefixes are not added dynamically and produce a visible delayed error,
- remote hello payloads store only known boolean prefix values,
- `WHISPER` hello messages are accepted only from current group members,
- self echoes and cross-realm same-name players are handled correctly,
- same-size roster swaps prune stale peers and schedule a new hello,
- `remoteQuestLogs` remains absolute quest-log/progress state and is not filtered by visibility/tracking preferences.

Future visibility tests should explicitly verify that visibility packets do not create or remove `remoteQuestLogs` entries.
