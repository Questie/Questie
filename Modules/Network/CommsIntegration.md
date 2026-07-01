# Comms Integration Test Handoff

## Overview

This document records the current state and design intent for the new Questie comms integration testing work. It is meant as a durable handoff note for continuing this work from a fresh context or another machine.

The short version: we are building an integration-style test suite for Questie's addon communication layer that uses as much real Questie and Ace code as possible while replacing the actual WoW client with a controlled emulator/fake boundary. The goal is to validate modern comms behavior (`QuestieH1`, `QuestieV1`) through realistic paths: Questie modules, AceComm/AceEvent/AceBucket/ChatThrottleLib, addon-channel encoding, fake `C_ChatInfo`, and fake `CHAT_MSG_ADDON` delivery.

The current implementation is intentionally focused on the newer modern protocols. Legacy packet formats (`questie`, `Questie`, `REPUTABLE`) are kept in mind as future extension points, but they are not the main target yet.

## Core Testing Philosophy

The main decision we made was:

> Use real Questie modules and the real Ace stack, and fake the WoW client boundary.

Earlier versions of the test faked `Questie:RegisterComm` and `Questie:SendCommMessage` directly. That was useful as a tracer bullet, but it was too high-level: it skipped AceComm, ChatThrottleLib, frame event delivery, prefix registration, and `CHAT_MSG_ADDON` callback behavior.

The current direction moves the fake boundary lower:

```text
Questie comm modules
  -> real AceComm / AceEvent / AceTimer / AceBucket / ChatThrottleLib
  -> fake WoW client APIs (`CreateFrame`, `C_ChatInfo`, timers, roster APIs)
  -> fake `CHAT_MSG_ADDON` delivery
  -> real Ace receive path
  -> real Questie comm receive handlers
```

This gives better confidence that the code paths Questie actually uses in-game are wired correctly, while still keeping tests deterministic and runnable under Busted/Lua 5.1.

## Current Files Involved

### `Modules/Network/CommsIntegration.test.lua`

This is the main integration test suite. It keeps protocol-specific policy and assertions visible:

- modern comm module loading/reset order;
- minimal Questie module fixtures;
- `QuestieH1` and `QuestieV1` scenarios;
- `GroupEventHandler` first-layer event scenarios;
- the first two-client isolated `QuestieH1` handshake prototype.

The test intentionally avoids hiding Questie protocol behavior inside the harness. The harness owns mechanics; this file owns behavior.

### `cli/mocks/AceCommTestHarness.lua`

This is the reusable, opt-in fake WoW/Ace test harness. It is loaded with:

```lua
local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")
```

It returns a plain table, following the existing `cli/mocks` style. It is **not** installed from `setupTests.lua` because it enables real Ace behavior and full codec support; tests should opt into that deliberately.

It owns reusable mechanics:

- fake frame/event system;
- fake `C_ChatInfo`;
- fake timers and clock;
- fake group/roster APIs;
- real Ace library loading and embedding;
- LibDeflate-backed compression glue;
- cleanup/restore of globals and `Questie` state;
- a small isolated two-client prototype using `setfenv`.

### `cli/mocks/BlizzardCBOR.lua`

This mock provides `C_EncodingUtil.SerializeCBOR` and `C_EncodingUtil.DeserializeCBOR` in CLI/Busted runs. `setupTests.lua` installs these methods globally.

For the purpose of the integration tests, we are assuming this CBOR mock is byte-compatible with Blizzard's CBOR serializer. Real Blizzard fixture captures can be added later to prove/maintain that compatibility.

Important: `setupTests.lua` intentionally does **not** install compression functions. The integration harness installs compression only for tests that opt into full codec support.

### `Modules/EventHandler/GroupEventHandler.lua`

This is now used as the first real layer above modern comms in the integration test. Rather than only calling `CommsPrefixRegistry:ScheduleHello(...)` and `CommsVisibility:ScheduleSnapshot(...)` directly, some tests drive WoW-style group events through real AceEvent/AceBucket:

- `GROUP_JOINED`
- `GROUP_ROSTER_UPDATE`
- `GROUP_LEFT`

This proves that group events can trigger modern comm convergence through the production handler layer.

## What Is Real vs Faked

### Real Code Used

The integration path currently uses real:

- `LibStub`
- `LibDeflate`
- `CallbackHandler-1.0`
- `AceEvent-3.0`
- `AceTimer-3.0`
- `AceBucket-3.0`
- `AceComm-3.0`
- `ChatThrottleLib`
- `CommsEncoding`
- `CommsRouting`
- `CommsPrefixRegistry`
- `CommsVisibility`
- `GroupEventHandler`

The single-runtime tests embed Ace into the normal test `Questie` table via the harness.

The isolated two-client prototype loads its own env-local copies of enough Questie/Ace state to test `QuestieH1` handshake isolation.

### Faked WoW Client Boundary

The harness fakes the WoW client pieces that do not exist in CLI tests:

- `CreateFrame`
- frame scripts/events (`SetScript`, `RegisterEvent`, `UnregisterEvent`, `UnregisterAllEvents`)
- `C_ChatInfo.RegisterAddonMessagePrefix`
- `C_ChatInfo.SendAddonMessage`
- `C_ChatInfo.SendAddonMessageLogged`
- fake `CHAT_MSG_ADDON` delivery by firing registered frame `OnEvent` handlers
- `C_Timer.NewTimer`
- `C_Timer.NewTicker`
- `C_Timer.After`
- `GetTime`
- `GetFramerate`
- `UnitName`
- `UnitFullName`
- `GetRealmName`
- `GetNormalizedRealmName`
- `GetNumGroupMembers`
- `UnitInParty`
- `UnitInRaid`
- `UnitIsConnected`
- `Ambiguate`
- `securecallfunction`
- WoW-style `xpcall` vararg behavior
- `DEFAULT_CHAT_FRAME`
- `wipe` / `table.wipe`

### Codec Boundary

The encoding path in production is:

```text
Lua payload table
  -> C_EncodingUtil.SerializeCBOR(payload)
  -> C_EncodingUtil.CompressString(cbor, Deflate, Default)
  -> LibDeflate:EncodeForWoWAddonChannel(compressed)
```

and decode is the reverse.

In tests:

- `SerializeCBOR` / `DeserializeCBOR` come from `cli/mocks/BlizzardCBOR.lua` via `setupTests.lua`.
- `CompressString` / `DecompressString` are installed by `AceCommTestHarness:InstallBlizzardDeflateCompression()` and are backed by `LibDeflate:CompressDeflate` / `LibDeflate:DecompressDeflate`.
- `EncodeForWoWAddonChannel` / `DecodeForWoWAddonChannel` are real LibDeflate methods used by `CommsEncoding`.

Important caveat: even if the CBOR mock is byte-for-byte with Blizzard, the final compressed wire bytes and exact compressed message length are not guaranteed to match Blizzard because the compression implementation is LibDeflate-backed, not Blizzard `CompressString`.

## Current Test Coverage

At the time this document was written, `Modules/Network/CommsIntegration.test.lua` contains 15 integration tests. Exact counts may change as more tests are added.

### Modern Prefix Bootstrap

- Verifies `QuestieH1` and `QuestieV1` register through real AceComm.
- Uses the fake `C_ChatInfo.RegisterAddonMessagePrefix` capture exposed by the harness.

### `GROUP_JOINED` First-Layer Convergence

- Fires `GROUP_JOINED` through the fake WoW event system:

  ```lua
  harness:FireWoWEvent("GROUP_JOINED")
  ```

- Uses real AceEvent registration.
- Exercises `GroupEventHandler.GroupJoined`.
- Uses fake `C_Timer.NewTicker` to confirm group membership before scheduling comms.
- Verifies:
  - `QuestieH1` PARTY message is sent;
  - `QuestieV1` PARTY message is sent;
  - `QC_ID_REQUEST_FULL_QUESTLIST` is dispatched through real AceEvent message handling.

### `GROUP_ROSTER_UPDATE` First-Layer Resync via AceBucket

- Registers roster updates through real AceBucket:

  ```lua
  Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, GroupEventHandler.GroupRosterUpdate)
  ```

- Fires `GROUP_ROSTER_UPDATE` through the harness.
- Verifies a group-size change schedules modern comm resync:
  - `QuestieH1` sent;
  - `QuestieV1` sent;
  - party objective update scheduled;
  - `QuestiePlayer.numberOfGroupMembers` updated.

### Online/Offline Roster Resync

- Seeds `QuestieComms.remoteQuestLogs` with a quest-sharing player.
- Uses `connectedMembers` in the harness to control `UnitIsConnected`.
- Verifies:
  - first roster event establishes online snapshot and resyncs;
  - repeated roster event with same group size and same online state does **not** churn comms/redraws;
  - flipping the member offline with unchanged group size triggers modern comm resync and party objective update.

This protects the intended behavior in `GroupEventHandler`: zone changes can fire `GROUP_ROSTER_UPDATE`, but they should not cause unnecessary comm churn unless group size or online status changed.

### `GROUP_LEFT` Cleanup and Timer Cancellation

- Delivers crafted H1/V1 remote state first.
- Schedules pending `QuestieH1` / `QuestieV1` timers.
- Fires `GROUP_LEFT` through real AceEvent/fake WoW event delivery.
- Verifies:
  - minimal `QuestieComms:ResetAll` stub was called;
  - `QuestiePartyObjectives:Clear` stub was called;
  - `CommsPrefixRegistry` remote state was cleared;
  - `CommsVisibility` remote state was cleared/defaults back to shown;
  - pending H1/V1 timers were canceled and did not emit stale addon traffic after leaving.

### `QuestieH1` Hello Round-Trip

- Directly schedules `CommsPrefixRegistry:ScheduleHello(...)` for protocol-specific coverage.
- Runs timers and flushes Ace/ChatThrottle traffic.
- Captures outbound `QuestieH1` PARTY message.
- Delivers it as a grouped sender via fake `CHAT_MSG_ADDON`.
- Verifies:
  - remote `QuestieH1` accepted;
  - remote `QuestieV1` accepted;
  - legacy `questie` remains false/not accepted in this modern-only setup;
  - a direct `WHISPER` reply is sent to the sender.

### `QuestieV1` Visibility Snapshot Round-Trip

- Sets local quest log/tracker/hidden state.
- Schedules `CommsVisibility:ScheduleSnapshot(...)`.
- Captures outbound `QuestieV1` PARTY message.
- Delivers it as a grouped sender.
- Verifies public visibility behavior via:

  ```lua
  CommsVisibility:ShouldShowPartyObjective(playerName, questId)
  ```

- Covers tracked, untracked, hidden, and unknown quest IDs.
- Verifies `QuestiePartyObjectives.ScheduleUpdate` was called once.

### Trust-Boundary Rejection

- Sends a `QuestieV1` snapshot but then changes roster state so the sender is outside the group.
- Delivers the message as `Stranger-Realm`.
- Verifies it is ignored and no party objective update occurs.

### Crafted Inbound `QuestieH1` Sanitization

Uses:

```lua
harness:BuildEncodedAddonMessage("QuestieH1", payload)
```

to craft a remote message rather than replaying our own outbound message.

Covers:

- known boolean prefixes are stored;
- known `false` prefixes are stored as rejection;
- invalid prefix values are ignored;
- unknown prefixes are ignored;
- broadcast H1 causes one WHISPER reply.

Example payload shape tested:

```lua
{
    QuestieH1 = true,
    QuestieV1 = false,
    questie = "yes",
    Questie = true,
    REPUTABLE = false,
    QuestieZ9 = true,
}
```

### `QuestieH1` WHISPER No-Ping-Pong

- Delivers a crafted H1 payload over `WHISPER`.
- Verifies remote state is stored.
- Verifies no WHISPER reply is sent.

This protects the no-ping-pong rule: group broadcasts are answered directly; direct whispers are not answered again.

### Malformed `QuestieH1` Ignored

- Delivers raw invalid addon-channel data.
- Verifies no remote prefix state is stored and no reply is sent.

### `QuestieV1` Large Group Suppression

- Sets group size to 6.
- Schedules visibility snapshot.
- Verifies no `QuestieV1` PARTY message is sent.

`QuestieV1` only affects small-group party objective pin visibility, so it should avoid raid/large-group churn.

### `QuestieV1` Full Snapshot Replacement

- Delivers a crafted snapshot with `[101] = false`.
- Verifies quest 101 is hidden for that remote player.
- Delivers a replacement snapshot that omits 101 and includes `[202] = true`.
- Verifies quest 101 defaults back to shown.

This protects the rule that `QuestieV1` is a full snapshot, not a patch stream.

### Malformed `QuestieV1` Ignored

- Delivers raw invalid addon-channel data.
- Verifies default-show behavior and no party objective update.

### Two-Client `setfenv` `QuestieH1` Handshake Prototype

The harness now has a first isolated network prototype:

```lua
local network = AceCommTestHarness.NewIsolatedNetwork()
local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
network:SetParty({alice, bob})
```

Each client calls:

```lua
client:LoadModernHelloStack()
```

This loads enough env-local real code for `QuestieH1`:

- `setupTests.lua`
- env-local fake WoW APIs
- real LibStub/LibDeflate/CallbackHandler/AceEvent/AceComm/ChatThrottleLib
- CBOR mock and LibDeflate-backed compression
- `CommsEncoding`
- `CommsRouting`
- `CommsPrefixRegistry`

The test asserts:

- Alice and Bob have different `CommsPrefixRegistry` tables;
- Alice and Bob have different env-local AceComm libraries;
- Alice broadcasts H1 to PARTY;
- Bob stores Alice's H1 and replies by WHISPER;
- Alice stores Bob's H1;
- network trace contains exactly two messages and no ping-pong third message.

Current prototype scope is **H1 only**. It does not yet load `CommsVisibility` or `GroupEventHandler` in isolated clients.

## Current Harness API

### Single-Runtime Harness

Create a harness:

```lua
local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")
local harness = AceCommTestHarness.New()
```

Install fake WoW APIs and roster state:

```lua
harness:InstallWoWClient({
    clock = 100,
    playerName = "Player",
    realmName = "HomeRealm",
    groupMemberCount = 2,
    partyMembers = {["Friend-Realm"] = true},
    raidMembers = {},
    connectedMembers = {["Friend-Realm"] = true},
})
```

Load real Ace/AceComm stack into Questie:

```lua
harness:LoadRealAceCommInto(Questie)
```

This loads and embeds:

- `LibStub`
- `LibDeflate`
- `CallbackHandler-1.0`
- `AceEvent-3.0`
- `AceTimer-3.0`
- `AceBucket-3.0`
- `ChatThrottleLib`
- `AceComm-3.0`

Install test compression:

```lua
harness:InstallBlizzardDeflateCompression()
```

Build crafted inbound wire payloads:

```lua
local envelope = harness:BuildEncodedAddonMessage("QuestieH1", {
    QuestieH1 = true,
    QuestieV1 = true,
})
```

Timer and traffic helpers:

```lua
harness:RunTimers()
harness:FlushAddonTraffic()
```

Event/message delivery helpers:

```lua
harness:FireWoWEvent("GROUP_JOINED")
harness:DeliverAddonMessage(envelope, "Friend-Realm", "PARTY")
```

Sent-message lookup:

```lua
local message = harness:FindSentAddonMessage("QuestieH1", "PARTY")
```

Roster mutation:

```lua
harness:SetGroupRoster({
    groupMemberCount = 2,
    partyMembers = {["Friend-Realm"] = true},
    raidMembers = {},
    connectedMembers = {["Friend-Realm"] = false},
})
```

Cleanup:

```lua
harness:Restore()
```

`Restore()` restores globals, `table.wipe`, selected `Enum` fields, `C_EncodingUtil` compression hooks, and the top-level `Questie` table/settings leaves captured before harness installation.

### Isolated Network Prototype API

Create a network:

```lua
local network = AceCommTestHarness.NewIsolatedNetwork()
```

Create clients:

```lua
local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
```

Put clients in party:

```lua
network:SetParty({alice, bob})
```

Load the current isolated H1 stack:

```lua
alice:LoadModernHelloStack()
bob:LoadModernHelloStack()
```

Drive network/timers:

```lua
alice.CommsPrefixRegistry:ScheduleHello("integration-test")
network:Flush()
```

The network has:

- `network.pendingMessages`
- `network.trace`
- `network:DeliverPendingAddonMessages()`
- `network:Flush()`

The current isolated network routes:

- PARTY-like messages to other party clients registered for the prefix;
- WHISPER messages to the target full name, if registered for the prefix.

## Important Implementation Caveats

### Helper is test-only and opt-in

`cli/mocks/AceCommTestHarness.lua` is intentionally not loaded by `setupTests.lua`. Tests should opt into the real Ace/fake WoW client behavior explicitly.

### Do not move the helper into `Modules/`

The helper lives under `cli/mocks/` because it is test support. Avoid putting non-test helpers under `Modules/` unless release packaging behavior is considered carefully. Production/release builds should not include this harness.

### Exact final wire length is not production-proof

The tests use the real CBOR mock and real addon-channel escaping, but compression is approximated with LibDeflate. Blizzard `C_EncodingUtil.CompressString` may produce a different valid Deflate stream. Therefore exact compressed message bytes/length should not be treated as production proof.

Useful claims from these tests:

- payloads are serializable;
- payloads round-trip through the modern encode/decode stack;
- addon-channel-safe encoding/decoding is exercised;
- AceComm and fake WoW event delivery are exercised.

Not proven:

- exact production compressed byte length;
- exact Blizzard compression byte output.

### Same-runtime tests are not full cross-client isolation

Most tests still run inside one Lua runtime and replay or craft inbound messages. That is useful and much more realistic now because real Ace and fake WoW events are involved, but it is not the same as two independent clients.

The isolated two-client prototype exists for that purpose, but it currently covers only `QuestieH1`.

### Two-client prototype is H1-only

`LoadModernHelloStack()` currently loads:

- setup/module basics;
- AceComm path;
- codec path;
- `CommsEncoding`;
- `CommsRouting`;
- `CommsPrefixRegistry`.

It does not load:

- `CommsVisibility`;
- `GroupEventHandler`;
- `QuestieComms`;
- legacy comm packet handling.

### Minimal `QuestieComms` stub

The integration test currently does **not** load full `QuestieComms.lua`. It stubs only the surface `GroupEventHandler` needs:

- `QuestieComms.remoteQuestLogs`
- `QuestieComms:ResetAll()`

This keeps the modern comm suite focused and avoids pulling in broader legacy quest-log sharing dependencies too early.

### AceBucket timing is deterministic, not fully realistic

The harness has deterministic `C_Timer.After` / `NewTimer` / `NewTicker` behavior. For AceBucket, the goal is currently to prove the bucket path eventually dispatches, not to perfectly emulate real debounce timing. If future tests care about bucket coalescing or exact timing, the timer model may need refinement.

## Future Plan / Suggested Next Slices

### 1. Expand the isolated two-client prototype to `QuestieV1`

A good next step is a true Alice/Bob visibility test:

1. Alice and Bob load a modern stack including `CommsVisibility`.
2. Alice has tracked/untracked/hidden quest state.
3. Alice sends `QuestieV1` snapshot.
4. Network routes it to Bob.
5. Bob's `CommsVisibility:ShouldShowPartyObjective("Alice-Realm", questId)` reflects Alice's snapshot.

This would validate the modern visibility side-channel with truly separate module state.

### 2. Optionally route `GroupEventHandler` in isolated clients

After H1/V1 isolated comms are stable, extend isolated clients to load/register `GroupEventHandler` and drive `GROUP_JOINED` / `GROUP_ROSTER_UPDATE` across the fake network.

This is more complex because the isolated env would need more Questie fixtures and likely AceBucket/AceTimer support there too.

### 3. Add legacy `questie` / `Questie` packet integration later

Legacy packet formats should be added later when the modern harness is stable. Candidate paths:

- old `questie` quest-log sharing packets;
- daily quest availability prefix `Questie`;
- `REPUTABLE` if still relevant.

Do not rush this: full `QuestieComms.lua` has more dependencies and behavior surface.

### 4. Load full `QuestieComms` only when needed

Right now we use a minimal `QuestieComms` stub for `GroupEventHandler`. Load full `QuestieComms.lua` only for tests that actually need legacy quest-log sharing or full quest-list request/response behavior.

### 5. Add real Blizzard CBOR fixtures when available

`cli/mocks/BlizzardCBOR.lua` is assumed byte-compatible for current tests, but real fixture captures should be added when possible.

Useful fixtures:

- primitives;
- binary strings;
- dense arrays;
- string-key maps;
- numeric-key maps;
- nested tables;
- unsupported values with/without `ignoreSerializationErrors`;
- malformed deserialize inputs.

### 6. Test AceComm multipart/chunking if payloads grow

Current modern payloads are small. If future modern comm payloads become large enough to trigger AceComm multipart behavior, add explicit tests for chunking/reassembly.

This may require making the fake network deliver multipart chunks in order and possibly testing loss/out-of-order behavior separately.

### 7. Consider splitting a lower-level `WowClientEmulator`

`AceCommTestHarness` is already large. If it keeps growing, split mechanics into two layers:

- lower-level `WowClientEmulator` owning frames/events/timers/`C_ChatInfo`/roster/network;
- higher-level `AceCommTestHarness` owning Ace loading, codec glue, and Questie-facing conveniences.

Do this only when the helper's size starts creating real maintenance friction. For now, one helper is acceptable and easier to evolve.

## Validation Commands

Current known passing commands at the time of this document:

```bash
busted -p ".test.lua" Modules/Network/CommsIntegration.test.lua
# 15 successes / 0 failures / 0 errors / 0 pending
```

```bash
busted -p ".test.lua" Modules/Network
# 93 successes / 0 failures / 0 errors / 0 pending
```

```bash
luacheck -q -- cli/mocks/AceCommTestHarness.lua Modules/Network/CommsIntegration.test.lua
# 0 warnings / 0 errors in 2 files
```

These counts are informational and will change as more tests are added.

## Git / Staging Note

At the last check during implementation, these files showed partially staged status:

```text
AM Modules/Network/CommsIntegration.test.lua
AM cli/mocks/AceCommTestHarness.lua
```

That means they were staged as added, but had additional unstaged modifications. Before committing, run:

```bash
git add Modules/Network/CommsIntegration.test.lua cli/mocks/AceCommTestHarness.lua Modules/Network/CommsIntegration.md
```

Then verify status and rerun the targeted validation if desired.

## Quick Mental Model for Continuing

When adding a new modern comm integration scenario, ask:

1. Is this testing protocol behavior directly?
   - Keep it in `CommsIntegration.test.lua` and use `BuildEncodedAddonMessage`, `DeliverAddonMessage`, or direct scheduler calls where appropriate.

2. Is this testing how WoW/group events trigger comm convergence?
   - Drive it through `GroupEventHandler` with `FireWoWEvent` and real AceEvent/AceBucket.

3. Is this testing cross-client independence?
   - Use or extend `NewIsolatedNetwork()` and isolated clients.

4. Is this just fake WoW/Ace plumbing?
   - Put it in `AceCommTestHarness`, not in the test file.

5. Does it require legacy quest-log sharing?
   - Consider whether the minimal `QuestieComms` stub is enough. If not, plan a separate slice for loading full `QuestieComms.lua` and its dependencies.
