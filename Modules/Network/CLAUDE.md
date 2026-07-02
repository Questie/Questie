# Claude guidance for Questie network/comms

Read `AGENTS.md` in this directory before changing files under `Modules/Network/`.

Also read the comms design documents before changing any network/comms module, hello/capability behavior, protocol shape, serialization, compression, addon-channel transport, or remote quest/party state semantics:

- `../../docs/questie-comms-design.md`
- `../../docs/addon-channel-serialization-report.md`

Preserve the documented contracts around absolute `remoteQuestLogs`, dumb `QuestieH1` prefix-state hello, module-owned prefix registration, and CBOR -> Blizzard Deflate -> addon-channel-safe modern payloads via `CommsEncoding`.
