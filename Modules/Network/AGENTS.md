# Network/comms guidance

These instructions apply to files under `Modules/Network/`.

Before changing any network/comms module, hello/capability behavior, protocol shape, serialization, compression, addon-channel transport, or remote quest/party state semantics, read:

- `../../docs/questie-comms-design.md`
- `../../docs/addon-channel-serialization-report.md`

Key contracts to preserve:

- `QuestieComms.remoteQuestLogs` is absolute remote quest-log/progress state. Do not filter or mutate it based on UI visibility, tracked, hidden, or shown state.
- `QuestieH1` hello is a dumb boolean map of comm prefixes. Prefix meaning belongs to the owning modules, not the hello payload.
- Known prefixes default to `false`; owning modules mark active support only after their receiver/parser is registered. Never trust or register prefixes dynamically from remote input.
- Modern typed-prefix payloads use `CommsEncoding`: Lua table/body -> `C_EncodingUtil.SerializeCBOR` -> Blizzard Deflate via `C_EncodingUtil.CompressString` -> addon-channel-safe encoding.
- Modern comm modules should register their static prefix receiver first, then call `CommsHello:RegisterLocalPrefix(prefix)`.
- `QuestieV1` is a full visibility snapshot `{ [questId] = boolean }` for party objective map/minimap pins only. It must not hide contextual tooltip progress and must not touch `remoteQuestLogs`.
- Missing `QuestieV1` visibility for a peer/quest means unknown and defaults to shown for backward compatibility.
