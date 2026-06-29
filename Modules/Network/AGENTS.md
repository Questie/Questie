# Network/comms guidance

These instructions apply to files under `Modules/Network/`.

Before changing any network/comms module, hello/capability behavior, protocol shape, serialization, compression, addon-channel transport, or remote quest/party state semantics, read:

- `../../docs/questie-comms-design.md`
- `../../docs/addon-channel-serialization-report.md`

Key contracts to preserve:

- `QuestieComms.remoteQuestLogs` is absolute remote quest-log/progress state. Do not filter or mutate it based on UI visibility, tracked, hidden, or shown state.
- `QuestieH1` hello is a dumb boolean map of comm prefixes. Prefix meaning belongs to the owning modules, not the hello payload.
- Known prefixes default to `false`; owning modules mark active support only after their receiver/parser is registered.
- Modern typed-prefix payloads use: Lua table/body -> `C_EncodingUtil.SerializeCBOR` -> Blizzard Deflate via `C_EncodingUtil.CompressString` -> `LibDeflate:EncodeForWoWAddonChannel`.
