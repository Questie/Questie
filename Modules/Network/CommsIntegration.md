# Comms Test Emulator Handoff

## Overview

Questie's comms tests now use a shared fake WoW/AceComm emulator, but the tests themselves live with the module or feature that owns the behavior under test.

The emulator is test infrastructure:

```lua
local AceCommTestHarness = dofile("cli/mocks/AceCommTestHarness.lua")
```

It provides isolated clients, real AceComm/AceEvent/AceTimer/AceBucket/ChatThrottleLib, real serializer libraries where needed, fake WoW APIs, deterministic timers, and fake addon-channel routing. Protocol assertions stay in the owning test files instead of being centralized in one large integration suite.

## Why This Emulator Exists

Questie comms bugs often happen at the seams between modules, AceComm, serializers, timers, roster state, and WoW addon-channel delivery. These tests intentionally use the real Ace stack instead of mocking `Questie:RegisterComm` or `Questie:SendCommMessage`, so registration order, callback signatures, chunking, throttled delivery, and serializer boundaries are exercised together.

The fake boundary sits below AceComm at the WoW client API layer:

- frames and events through `CreateFrame`;
- addon prefix registration and sends through `C_ChatInfo`;
- timers through `C_Timer`;
- group/guild/trust state through roster APIs.

That shape catches integration mistakes in Questie module registration, routing, encoding, and state convergence while still running deterministically in Busted.

The harness has two modes because they answer different questions:

- the single-runtime harness is useful for focused module tests that want one Questie runtime with real Ace libraries and a fake WoW boundary;
- the isolated network creates multiple independent Questie runtimes and is the right tool for cross-client state, trust-boundary, and addon-channel routing behavior.

## Background and Philosophy

The emulator is a deterministic lab for Questie comms, not a perfect clone of the WoW client or server. It should be realistic enough to catch addon-side mistakes in registration, routing, serialization, timers, and trust boundaries, while staying predictable enough that failures explain the Questie behavior under test.

Keep the ownership line clear: the harness supplies mechanics, and owner modules protect protocol behavior. H1 assertions belong with `CommsPrefixRegistry`, V1 assertions belong with `CommsVisibility`, legacy quest-log assertions belong with `QuestieComms`, and daily `Questie` assertions belong with `Comms`. `CommsIntegration.test.lua` should remain a harness-mechanics safety net, not a second protocol inventory.

Prefer real Ace libraries and real serializer paths over mocked `Questie:RegisterComm` / `Questie:SendCommMessage` flows. The bugs this suite is meant to catch often happen because the callback signature, prefix registration, chunking, compression, or timer boundary is slightly different from what a mock assumed.

Assert final observable protocol state when possible: remote prefix caches, visibility decisions, remote quest logs, received daily removals, and routed addon messages. Use captured sinks or spies at true side-effect boundaries, such as tooltip registration or daily removal callbacks, where there is no more meaningful state to inspect.

Use real Questie data for payload guardrails. Synthetic maxima can look scary while missing the actual production shape, or compress unrealistically well compared with real quest IDs/objective IDs. If future data creates a larger realistic case, update the guardrail fixture to that new real case.

## Current Test Organization

### `Modules/Network/CommsIntegration.test.lua`

Harness mechanics only:

- isolated clients do not share Questie module state, LibStub, or AceComm instances;
- deterministic fake timers advance without real waiting;
- PARTY broadcasts do not echo to the sender;
- WHISPER routes to exact full names and same-realm short names;
- unregistered prefixes are dropped at delivery;
- invalid prefixes, oversized messages, and invalid topology sends are rejected before trace/queue;
- disconnected targets are skipped;
- missing WHISPER targets are rejected;
- large ChatThrottleLib queues are flushed before the network reports idle;
- multipart AceComm chunks route and reassemble once.

If a test asserts Questie protocol behavior, it belongs in that protocol's owning file instead.

### `Modules/Network/CommsPrefixRegistry.test.lua`

`QuestieH1` ownership:

- local prefix manifest behavior;
- H1 scheduling/debounce and reply behavior;
- H1 sanitization and malformed payload handling;
- isolated H1 round-trips over PARTY and INSTANCE_CHAT;
- H1 payload budget guardrail.

`REPUTABLE` is intentionally not part of H1 discovery. Production may still receive the old direct `REPUTABLE` callback for compatibility, but H1 does not advertise it.

### `Modules/Network/CommsVisibility.test.lua`

`QuestieV1` ownership:

- local visibility snapshot building;
- max group-size suppression;
- receive sanitization/capping;
- `ShouldShowPartyObjective` behavior;
- isolated V1 round-trip, full snapshot replacement, trust-boundary rejection, and large-group suppression;
- V1 separation from legacy `QuestieComms.remoteQuestLogs`;
- V1 realistic payload budget guardrails using real Questie quest IDs.

### `Modules/EventHandler/GroupEventHandler.test.lua`

Group lifecycle ownership:

- unit-level group join/roster/left behavior;
- isolated GROUP_JOINED convergence through H1, V1, and full quest-log request messages;
- isolated GROUP_ROSTER_UPDATE V1 resync on size changes without H1 broadcasts;
- isolated online-status changes resend V1 without H1 broadcasts, while zone-change-like no-op roster updates stay quiet;
- isolated GROUP_LEFT reset and pending timer cancellation.

### `Modules/Network/QuestieComms.test.lua`

Legacy `questie` prefix ownership:

- production initialization/register behavior;
- full quest-list request/response;
- quest update and remove packets;
- malformed/incompatible packet rejection;
- realistic 25-quest full-log guardrail built from real quest/objective IDs.

The emulator loads real `QuestieStream`, `QuestieSerializer`, and `QuestieComms`, while fixture-stubbing broad DB/tooltip dependencies.

### `Modules/Network/Comms.test.lua`

Daily `Questie` prefix ownership:

- unit-level daily message validation and routing decisions;
- isolated AceSerializer-backed PARTY/RAID/GUILD routing;
- guild+group duplicate delivery, matching production behavior;
- self/malformed message rejection;
- realistic high-count daily payload guardrail.

### `Modules/Network/CommsEncoding.test.lua`

Encoding implementation only:

- real LibDeflate addon-channel escaping;
- encode path: CBOR -> Deflate -> addon-channel-safe payload;
- decode path and failure cases;
- missing codec support behavior.

Feature-specific payload budget tests live with the feature that owns the payload shape.

## Emulator Boundary

### Real code used

The emulator can load real:

- `LibStub`
- `LibDeflate`
- `CallbackHandler-1.0`
- `AceEvent-3.0`
- `AceTimer-3.0`
- `AceBucket-3.0`
- `AceComm-3.0`
- `AceSerializer-3.0`
- `ChatThrottleLib`
- `CommsEncoding`
- `CommsRouting`
- `CommsPrefixRegistry`
- `CommsVisibility`
- `GroupEventHandler`
- `Comms`
- `QuestieStream`
- `QuestieSerializer`
- `QuestieComms`

Each isolated client owns its own `_G`, QuestieLoader registry, LibStub registry, Ace singletons, fake frames, timers, and module state. The shared network owns only the deterministic clock, topology rosters, pending addon messages, and delivery trace.

### Fake WoW client APIs

The harness fakes the WoW client pieces that do not exist in Busted:

- `CreateFrame` and frame scripts/events;
- `C_ChatInfo.RegisterAddonMessagePrefix`;
- `C_ChatInfo.SendAddonMessage` / `SendAddonMessageLogged`;
- fake `CHAT_MSG_ADDON` delivery;
- `C_Timer.NewTimer`, `NewTicker`, and `After`;
- `GetTime`, `GetFramerate`;
- roster APIs such as `UnitName`, `UnitFullName`, `GetNumGroupMembers`, `UnitInParty`, `UnitInRaid`, `UnitIsConnected`;
- guild/group state helpers used by daily comms;
- WoW-style `xpcall`, `securecallfunction`, `wipe`, and `DEFAULT_CHAT_FRAME`.

Invalid sends are rejected at the fake `C_ChatInfo` boundary before they enter `network.trace` or `pendingMessages`: invalid prefixes, non-string or oversized messages, missing whisper targets, and impossible topology all fail there. Valid sends may still be undelivered if the target is disconnected or has not registered the prefix.

`INSTANCE_CHAT` has separate routing, but Questie's current receive trust checks still ask party/raid-style roster APIs. The emulator models instance members as party-like only for that trust boundary; it is not a full WoW unit-token emulator.

## Single-Runtime Harness API

Use the single-runtime harness when a test needs one Questie runtime with real AceComm/AceEvent/AceTimer/AceBucket and a fake WoW client boundary:

```lua
local harness = AceCommTestHarness.New()
harness:InstallWoWClient({
    playerName = "Player",
    realmName = "HomeRealm",
    groupMemberCount = 2,
    partyMembers = {["Friend-Realm"] = true},
})
harness:LoadRealAceCommInto(Questie)
harness:InstallBlizzardDeflateCompression()
```

Common helpers:

```lua
local envelope = harness:BuildEncodedAddonMessage("QuestieH1", {
    QuestieH1 = true,
    QuestieV1 = true,
})

harness:FireWoWEvent("GROUP_JOINED")
harness:DeliverAddonMessage(envelope, "Friend-Realm", "PARTY")
harness:RunTimers()
harness:FlushAddonTraffic()

local sent = harness:FindSentAddonMessage("QuestieH1", "PARTY")
```

`Restore()` must run after a single-runtime harness test. It restores the globals the harness replaces, selected `Enum` fields, `table.wipe`, `C_EncodingUtil` compression hooks, and the captured top-level `Questie` table/settings leaves:

```lua
harness:Restore()
```

Prefer the isolated network for multi-client behavior. Use the single-runtime harness for narrow tests that only need one client and where sharing the process-global Questie runtime is intentional.

## Isolated Network API

Create a network and clients:

```lua
local network = AceCommTestHarness.NewIsolatedNetwork()
local alice = network:CreateClient({playerName = "Alice", realmName = "TestRealm"})
local bob = network:CreateClient({playerName = "Bob", realmName = "TestRealm"})
```

Configure topology:

```lua
network:SetParty({alice, bob})
network:SetRaid({alice, bob})
network:SetInstance({alice, bob})
network:SetGuild({alice, bob})
network:SetConnected(bob, false)
```

Load the stack needed by the owning test:

```lua
alice:LoadModernHelloStack()        -- H1 only
alice:LoadModernCommsStack()        -- H1 + V1
alice:LoadModernGroupStack()        -- H1 + V1 + GroupEventHandler
alice:LoadLegacyQuestieCommsStack() -- legacy questie packets too
alice:LoadDailyCommsStack()         -- daily Questie prefix too
```

Drive time/events:

```lua
network:FireAll("GROUP_JOINED")
assert.is_true(network:FlushUntilIdle())
```

`FlushUntilIdle()` advances fake time through timers, AceComm/ChatThrottleLib frame work, addon delivery, and receiver-side AceComm reassembly. It does not report idle while client timers, pending addon messages, or ChatThrottleLib priority queues still contain work. Tests should assert it returns `true` so partial delivery cannot masquerade as success.

## Required realistic worst-case payload guardrails

These guardrails should remain required when comm payload schemas change. If new expansions add larger real cases, update the fixture to the newer real worst case rather than replacing it with synthetic oversized IDs.

- `CommsPrefixRegistry.test.lua` keeps the H1 manifest under the conservative local single-message budget.
- `CommsVisibility.test.lua` builds max-size V1 snapshots from real Questie quest IDs, including the 50 largest MoP quest IDs currently in the DB, and keeps the local estimator under `<= 245`.
- `QuestieComms.test.lua` builds a 25-quest legacy full-log fixture from real quests with large objective lists, verifies all 25 remote quest logs arrive, and requires every low-level AceComm chunk to stay `<= 255`.
- `Comms.test.lua` sends a realistic high-count daily `Questie` payload for NPC `58646` and asserts the single low-level message stays within AceComm's `255` character limit while preserving the exact received quest ID list.

## Codec Setup Boundary

`setupTests.lua` installs the Blizzard CBOR mock so CLI tests can call `C_EncodingUtil.SerializeCBOR` and `C_EncodingUtil.DeserializeCBOR` without a live WoW client. It intentionally does **not** install compression support. Tests that need modern comm encoding must install Deflate hooks explicitly.

The single-runtime harness uses `InstallBlizzardDeflateCompression()` to back `C_EncodingUtil.CompressString` and `C_EncodingUtil.DecompressString` with LibDeflate. Isolated clients install the same LibDeflate-backed compression through their stack loaders. This keeps codec support opt-in, so tests still notice when a comm module tries to initialize without the required compression boundary.

## Codec and length caveats

Production modern encoding is:

```text
Lua table
  -> C_EncodingUtil.SerializeCBOR
  -> C_EncodingUtil.CompressString(..., Deflate)
  -> LibDeflate:EncodeForWoWAddonChannel
```

Busted uses the live-verified CBOR mock plus LibDeflate-backed Deflate. This is useful for conservative budget tests, but it is not exact Blizzard compression proof. Keep local assertions below the hard 255-character boundary, and verify any near-threshold production payload in a live WoW client.

Representative live Classic Era probes showed the local estimator is close but not exact:

| Payload | Live final length | Local estimate | Difference |
| --- | ---: | ---: | ---: |
| H1 payload | 39 | 38 | -1 |
| V1 50 large quest IDs | 224 | 223 | -1 |
| V1 50 mixed-width IDs | 190 | 194 | +4 |

## Maintenance Notes and Limits

- `cli/mocks/AceCommTestHarness.lua` is opt-in test support. Do not move it into `Modules/` or another release-loaded path unless packaging behavior is reviewed.
- Deterministic timers and AceBucket handling model convergence, not frame-perfect WoW timing. They are meant to prove ordered comm behavior without real waiting.
- `INSTANCE_CHAT` support is intentionally narrow: routing is separate, and instance members are treated as party-like only where Questie's current receive trust checks require `UnitInParty` / `UnitInRaid` style answers.
- Local payload lengths are guardrails, not exact production wire lengths. Use a live WoW client check when a payload approaches the 255-character addon-message boundary.
- New protocol tests should live with the owning module or feature. Keep `CommsIntegration.test.lua` focused on shared emulator mechanics so it does not become a second protocol test inventory.

## Validation commands

Focused owner files:

```bash
busted -p ".test.lua" Modules/Network/CommsIntegration.test.lua Modules/Network/CommsPrefixRegistry.test.lua Modules/Network/CommsVisibility.test.lua Modules/EventHandler/GroupEventHandler.test.lua Modules/Network/QuestieComms.test.lua Modules/Network/Comms.test.lua Modules/Network/CommsEncoding.test.lua
```

Broader comms suite, including the group lifecycle owner outside `Modules/Network`:

```bash
busted -p ".test.lua" Modules/Network Modules/EventHandler/GroupEventHandler.test.lua
```

Full suite:

```bash
busted -p ".test.lua" .
```

Targeted lint:

```bash
luacheck -q -- cli/mocks/AceCommTestHarness.lua Modules/Network/CommsIntegration.test.lua Modules/Network/CommsPrefixRegistry.test.lua Modules/Network/CommsVisibility.test.lua Modules/EventHandler/GroupEventHandler.test.lua Modules/Network/QuestieComms.test.lua Modules/Network/Comms.test.lua Modules/Network/CommsEncoding.test.lua
```

Diff health:

```bash
git diff --check
```
