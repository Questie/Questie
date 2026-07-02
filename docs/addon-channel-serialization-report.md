# Addon-channel serialization and SAY/YELL transport report

## Scope

This report summarizes live Questie communication experiments run against a running Classic client. The goal was to compare QuestieComms packet shapes, Questie's current serializer, Blizzard's built-in `C_EncodingUtil` CBOR/compression APIs, and Classic-only `SAY`/`YELL` addon-channel byte behavior.

No production protocol change is implied by this report. The tests used temporary QuestieComms debug self-send helpers and direct in-client snippets.

## Terminology

The report separates three concerns that are easy to conflate:

- **V1 packet shape**: the existing keyed QuestieComms quest packet shape used by normal quest update messages (`msgId = 1`) and the older full quest-list packets (`msgId = 10`). It contains keys such as `quest`, `objectives`, `id`, `typ`, `fin`, `ful`, and `req`.
- **QuestieComms V2 packet shape**: the compact positional/numeric packet shape already present in `QuestieComms.lua`. Full quest-list V2 (`msgId = 12`) is used for modern full-list replies. Single quest update V2 (`msgId = 14`) has a handler but is not the normal active quest-update sender.
- **CBOR/transport encoding**: an alternative way to serialize a chosen packet shape, independent of whether that shape is V1 or V2. CBOR and compression output are binary and require a safe encoding step before addon-channel transport.

## Test environment and method

- Client/addon context: Questie running in WoW Classic.
- Character observed during tests: `Teastd-Mirage Raceway`.
- Main quest-update round trips used a debug AceComm prefix, `qstiedbgself`, and self `WHISPER` to `UnitName("player")`.
- The debug helper built QuestieComms quest update packets, sent them via addon comms, decoded them on receive, and dispatched them through QuestieComms packet readers with a fake sender.
- `SAY`, `YELL`, and `CHANNEL` behavior was tested directly with `C_ChatInfo.RegisterAddonMessagePrefix` and `C_ChatInfo.SendAddonMessage`.
- AceSerializer follow-up measurements used a live Classic Era `1.15.8` client, build `67156` / interface `11508`, with `AceSerializer-3.0`, `LibDeflate`, `C_EncodingUtil`, and Questie modules available.

## Current quest log tested

| Quest ID | Quest name | Quest objectives in packet |
| ---: | --- | ---: |
| 47 | Gold Dust Exchange | 1 |
| 54 | Report to Goldshire | 0 |
| 60 | Kobold Candles | 1 |
| 62 | The Fargodeep Mine | 1 |
| 2158 | Rest and Relaxation | 0 |

## Round-trip validation evidence

The test path verified more than local serialization size:

1. A packet was sent through the real addon-channel API path using AceComm/`SendCommMessage`.
2. The client received it through a registered addon prefix callback.
3. The debug receive handler decoded the payload.
4. For QuestieSerializer codecs, the handler invoked the QuestieComms receive/read path for the tested packet shape.
5. For CBOR codecs, the handler decoded/deserialized and dispatched to the same QuestieComms packet reader.
6. Injected fake remote quest state was verified with `QuestieComms:GetQuest(questId, "QuestieSelfTest")` when state preservation was enabled.

Representative successful V1 results:

| Codec | Received | Decoded | Normal packet read path | Notes |
| --- | --- | --- | --- | --- |
| `questie` | yes | yes | yes | V1 packet shape with existing QuestieSerializer path |
| `cbor` | yes | yes | yes | V1 packet shape, CBOR plus addon-channel-safe wrapper |
| `cbor-deflate` | yes | yes | yes | V1 packet shape, CBOR, built-in Deflate, addon-channel-safe wrapper |

Representative V2 results:

| V2 packet | Codec | Result |
| --- | --- | --- |
| Single quest update 47 (`msgId = 14`) | QuestieSerializer | OK |
| Single quest update 47 (`msgId = 14`) | CBOR + Deflate, addon-safe | OK |
| Full quest-list block 47+60 (`msgId = 12`) | QuestieSerializer | OK |
| Full quest-list block 47+60 (`msgId = 12`) | CBOR + Deflate, addon-safe | OK |
| Current full-log block, 5 current quests (`msgId = 12`) | QuestieSerializer / CBOR + Deflate | Failed decode: `QuestieComms.lua:369: table index is nil` |

Raw binary CBOR/compressed variants were received by the callback, but their payloads were corrupted or truncated in several cases, so they failed decode/decompress.

## Serializer and compression size results

### V1 single quest-update payload sizes

Values are payload bytes before the debug nonce envelope. CBOR variants in this table used addon-channel-safe wrapping where needed. These are V1 keyed-table quest update packets.

| Quest ID | V1 QuestieSerializer | CBOR | CBOR + Deflate | CBOR + Zlib | CBOR + Gzip |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 47 | 91 | 82 | 81 | 87 | 108 |
| 54 | 62 | 53 | 54 | 60 | 81 |
| 60 | 91 | 82 | 81 | 87 | 108 |
| 62 | 89 | 82 | 79 | 85 | 106 |
| 2158 | 64 | 54 | 55 | 61 | 82 |

For V1 normal single quest update packets, CBOR without compression was consistently smaller than QuestieSerializer. Deflate sometimes saved one to three bytes, but sometimes added one byte. Zlib and Gzip were worse for these small packets.

### V1 quest 47 local size comparison

| Variant | Raw bytes | Addon-channel-safe bytes | Result |
| --- | ---: | ---: | --- |
| V1 `QuestieSerializer` | 91 | 93 | Current normal QuestieComms baseline; wrapper not required for normal PARTY/WHISPER/RAID |
| AceSerializer | 126 | not tested | Larger; not used by QuestieComms |
| V1 CBOR | 80 | 82 | Smaller and fast |
| V1 CBOR + built-in Deflate | 80 | 81 | Tiny size win, extra CPU |
| V1 CBOR + built-in Zlib | 86 | 87 | Worse than CBOR/Deflate for small packets |
| V1 CBOR + built-in Gzip | 98 | 108 | Poor fit for small packets |
| V1 QuestieSerializer + built-in Deflate | 88 | 91 | Roughly tied with current after safe wrapping |
| V1 QuestieSerializer + built-in Zlib | 94 | 97 | Worse |
| V1 QuestieSerializer + built-in Gzip | 106 | 118 | Worse |
| V1 CBOR + LibDeflate Deflate | 80 | 80 | Smallest in this sample, but pure-Lua compression was much slower |

### V1 full current quest-list packet sample

A local V1 full-list packet containing the five current quest-log entries showed compression becoming useful:

| Variant | Bytes |
| --- | ---: |
| V1 Questie full-list packet | 221 |
| V1 CBOR full-list packet, addon-safe | 231 |
| V1 Questie + built-in Deflate, addon-safe | 142 |
| V1 CBOR + built-in Deflate, addon-safe | 135 |

This suggests compression is not worthwhile for tiny V1 single quest-update packets, but may be worthwhile for larger full quest-list or multi-quest packets.

### QuestieComms V2 single quest-update payload sizes

Values are payload bytes before the debug nonce envelope. CBOR variants used addon-channel-safe wrapping where needed. These are compact positional V2 single quest update packets (`msgId = 14`).

| Quest ID | V2 QuestieSerializer | CBOR | CBOR + Deflate | CBOR + Zlib | CBOR + Gzip |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 47 | 45 | 43 | 41 | 47 | 68 |
| 54 | 37 | 31 | 31 | 37 | 58 |
| 60 | 45 | 43 | 41 | 47 | 68 |
| 62 | 47 | 42 | 40 | 46 | 67 |
| 2158 | 37 | 31 | 31 | 37 | 58 |

V2 removes most of the V1 keyed-table overhead. CBOR remains faster and slightly smaller, but the byte-size win is much smaller than it was for V1.

### QuestieComms V2 full quest-list payload sizes

Valid two-quest V2 full-list block containing quests 47 and 60:

| Variant | Bytes |
| --- | ---: |
| V2 QuestieSerializer | 54 |
| V2 QuestieSerializer + Deflate, addon-safe | 55 |
| V2 CBOR, addon-safe | 56 |
| V2 CBOR + Deflate, addon-safe | 51 |
| V2 CBOR + Zlib, addon-safe | 57 |
| V2 CBOR + Gzip, addon-safe | 78 |

Current full-log V2 block containing the five current quests:

| Variant | Bytes |
| --- | ---: |
| V2 QuestieSerializer | 77 |
| V2 QuestieSerializer + Deflate, addon-safe | 78 |
| V2 CBOR, addon-safe | 67 |
| V2 CBOR + Deflate, addon-safe | 60 |
| V2 CBOR + Zlib, addon-safe | 66 |
| V2 CBOR + Gzip, addon-safe | 87 |

The current full-log V2 block was smaller with CBOR + Deflate, but it failed decode in the live test. The clearest failure mode is zero-objective quests being counted in the V2 full-list count even when no V2 quest tuple is emitted, causing decode to read a nil quest ID. This is a packet construction/reader issue, not a serializer issue.

### V2 dictionary compression note

A small stable schema dictionary can shrink V2 further, but only through LibDeflate's pure-Lua dictionary compressor.

| V2 packet | CBOR safe | CBOR + Deflate safe | CBOR + LibDeflate dictionary safe |
| --- | ---: | ---: | ---: |
| Single update 47 | 43 | 41 | 31 |
| Single update 54 | 31 | 31 | 21 |
| Full block 47+60 | 56 | 51 | 40 |

CPU caveat from the same test context:

| Operation | Approx. microseconds per operation |
| --- | ---: |
| Native Deflate compress | 4.3 |
| Native Deflate decompress | 0.9 |
| LibDeflate dictionary compress | 200 |
| LibDeflate dictionary decompress | 34 |

Dictionary compression improves size, but it is much slower and adds protocol/dictionary-version coupling. Reusing and hardening the V2 packet shape is a cleaner first step than inventing a V1 dictionary layer.

### Synthetic larger V1 objective-count packets

Synthetic V1 quest-update shaped packets with many objectives showed Deflate becoming increasingly beneficial as payload repetition grows:

| Synthetic objectives | Questie raw | CBOR raw | Questie + Deflate safe | CBOR + Deflate safe |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 66 | 55 | 68 | 57 |
| 1 | 95 | 83 | 93 | 84 |
| 2 | 124 | 111 | 105 | 95 |
| 4 | 182 | 167 | 119 | 110 |
| 8 | 298 | 279 | 144 | 135 |
| 16 | 530 | 503 | 187 | 181 |
| 32 | 994 | 952 | 240 | 237 |
| 64 | 1924 | 1848 | 340 | 335 |
| 128 | 3780 | 3640 | 530 | 544 |

Synthetic V2 objective-count packets were much smaller because they avoid repeated string keys. CBOR + Deflate remained smaller than CBOR alone, but the gains were less dramatic than the V1 synthetic table.

### AceSerializer follow-up measurements

A follow-up live probe checked `AceSerializer-3.0` because it is already embedded and is simple to use for structured addon events. The probe used the same current quest log and live Questie packet builders where practical: `QuestieComms.private:CreatePacket(...)`, `QuestieComms:CreateQuestDataPacket(...)`, `QuestieComms:PopulateQuestDataPacketV2_noclass_renameme(...)`, `QuestieSerializer:Serialize(...)`, `AceSerializer:Serialize(...)`, `C_EncodingUtil` compression, and `LibDeflate:EncodeForWoWAddonChannel(...)`.

These tables are a follow-up snapshot rather than a rewrite of the older baseline rows above. The live recompute for quest `62` differed from the original report because the current live packet omitted one objective ID.

#### V1 single quest-update payloads with AceSerializer

| Quest ID | Objectives | QuestieSerializer | Questie + Deflate safe | AceSerializer | Ace + Deflate safe | Ace + Zlib safe | Ace + Gzip safe | CBOR safe | CBOR + Deflate safe |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 47 | 1 | 91 | 91 | 126 | 102 | 108 | 129 | 82 | 81 |
| 54 | 0 | 62 | 64 | 78 | 73 | 79 | 100 | 53 | 54 |
| 60 | 1 | 91 | 88 | 125 | 101 | 107 | 128 | 82 | 81 |
| 62 | 1 | 84 | 86 | 116 | 94 | 100 | 121 | 77 | 76 |
| 2158 | 0 | 64 | 66 | 80 | 75 | 81 | 102 | 54 | 55 |

AceSerializer is consistently larger than QuestieSerializer and CBOR for these small keyed V1 packets. Deflating AceSerializer helps, but still does not beat CBOR + Deflate. Deflating the existing QuestieSerializer payload is roughly break-even for these tiny single-quest packets.

#### V1 full current quest-list packet with AceSerializer

Five-quest full-list packet for quests `47`, `54`, `60`, `62`, and `2158`:

| Variant | Bytes |
| --- | ---: |
| V1 QuestieSerializer full-list | 216 |
| V1 AceSerializer full-list | 359 |
| V1 AceSerializer + Deflate safe | 158 |
| V1 AceSerializer + Zlib safe | 164 |
| V1 AceSerializer + Gzip safe | 185 |
| V1 CBOR full-list safe | 226 |
| V1 CBOR + Deflate safe | 135 |

For larger repeated keyed V1 packets, AceSerializer + Deflate becomes much smaller than raw AceSerializer, but still loses to CBOR + Deflate.

#### V2 single quest-update payloads with AceSerializer

| Quest ID | Tuple count | QuestieSerializer | Questie + Deflate safe | AceSerializer | Ace + Deflate safe | Ace + Zlib safe | Ace + Gzip safe | CBOR safe | CBOR + Deflate safe |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 47 | 1 | 45 | 46 | 93 | 73 | 79 | 100 | 43 | 41 |
| 54 | 0 | 37 | 38 | 51 | 46 | 52 | 73 | 31 | 31 |
| 60 | 1 | 45 | 46 | 92 | 77 | 83 | 104 | 43 | 41 |
| 62 | 1 | 47 | 48 | 84 | 68 | 74 | 95 | 42 | 40 |
| 2158 | 0 | 37 | 38 | 51 | 46 | 52 | 73 | 31 | 31 |

AceSerializer is a poor size fit for compact positional V2 packets. The type/key overhead is large relative to the tiny payload. Deflating QuestieSerializer also slightly increases these compact single-update packets.

#### V2 full quest-list blocks with AceSerializer

Valid two-quest V2 block containing quests `47` and `60`:

| Variant | Bytes |
| --- | ---: |
| V2 QuestieSerializer | 54 |
| V2 AceSerializer | 144 |
| V2 AceSerializer + Deflate safe | 95 |
| V2 AceSerializer + Zlib safe | 101 |
| V2 AceSerializer + Gzip safe | 122 |
| V2 CBOR safe | 56 |
| V2 CBOR + Deflate safe | 51 |

Current five-quest V2 block:

| Variant | Bytes |
| --- | ---: |
| V2 QuestieSerializer | 77 |
| V2 AceSerializer | 182 |
| V2 AceSerializer + Deflate safe | 110 |
| V2 AceSerializer + Zlib safe | 116 |
| V2 AceSerializer + Gzip safe | 137 |
| V2 CBOR safe | 67 |
| V2 CBOR + Deflate safe | 60 |

The five-quest V2 numbers are size measurements only. They do not change the earlier decode caveat: the current full-log V2 block still has the known zero-objective quest count issue.

## Serializer and compression speed results

### V1 speed results

Benchmark: 20,000 iterations on a live V1 quest 47 packet.

| Operation | Approx. microseconds per operation |
| --- | ---: |
| QuestieSerializer serialize | 74.5 |
| QuestieSerializer deserialize | 65.7 |
| CBOR serialize | 1.8 |
| CBOR deserialize | 1.9 |
| Built-in Deflate compress CBOR | 4.9 |
| Built-in Deflate decompress | 1.0 |
| Built-in Zlib compress CBOR | 5.2 |
| Built-in Zlib decompress | 1.1 |
| Built-in Gzip compress CBOR | 4.9 |
| Built-in Gzip decompress | 1.0 |
| LibDeflate addon-channel encode | 1.8 |
| LibDeflate addon-channel decode | 2.2 |
| LibDeflate pure-Lua Deflate compress | 351.0 |
| LibDeflate pure-Lua Deflate decompress | 39.8 |

### V2 single-update speed results

Benchmark: live V2 single quest update packet.

| Operation | Approx. microseconds per operation |
| --- | ---: |
| QuestieSerializer serialize | 36 |
| QuestieSerializer deserialize | 34 |
| CBOR serialize | 1.4 |
| CBOR deserialize | 1.2 |
| Built-in Deflate compress CBOR | 3.8 |
| Built-in Deflate decompress | 0.9 |
| LibDeflate addon-channel encode | 1.2 |
| LibDeflate addon-channel decode | 1.6 |

CBOR was much faster than Questie's custom serializer in both V1 and V2 tests. Blizzard's built-in compression was also much faster than LibDeflate's pure-Lua compression. LibDeflate remains useful as a safe text/binary transform for addon/chat channels.

### AceSerializer follow-up speed results

Benchmark: 20,000 iterations with `debugprofilestop()` in the same live client used for the AceSerializer size follow-up.

V1 quest `47`:

| Operation | Approx. microseconds per operation |
| --- | ---: |
| QuestieSerializer serialize | 79.5 |
| QuestieSerializer deserialize | 81.5 |
| AceSerializer serialize | 19.1 |
| AceSerializer deserialize | 21.6 |
| CBOR serialize | 1.9 |
| CBOR deserialize | 2.2 |

V2 quest `47`:

| Operation | Approx. microseconds per operation |
| --- | ---: |
| QuestieSerializer serialize | 43.6 |
| QuestieSerializer deserialize | 34.6 |
| AceSerializer serialize | 18.6 |
| AceSerializer deserialize | 18.4 |
| CBOR serialize | 1.5 |
| CBOR deserialize | 1.3 |

AceSerializer was worth checking: it is much faster than QuestieSerializer, but much larger for QuestieComms packet shapes. AceSerializer + Deflate improves larger/repetitive packets, but still usually loses to CBOR + Deflate. AceSerializer remains reasonable for simple daily `Questie` structured events where simplicity matters; it is a poor size fit for legacy/V2 quest-log packets where addon-channel budget matters most.

## Realistic worst-case guardrail fixture

The earlier full-list tables use two small/live samples:

| Sample | Meaning |
| --- | --- |
| `47 + 60` block | Small valid V2 full-list block containing two quests. |
| Current five-quest block | The live character quest log used in this report: `47`, `54`, `60`, `62`, `2158`. |

The 25-quest numbers below are a different sample. They come from the local comms emulator guardrail in `Modules/Network/QuestieComms.test.lua`: a full 25-quest log built from real Questie quest IDs and real objective IDs with synthetic progress values. It is meant to stress the worst realistic packet shape Questie should protect in tests. It is **not** the `47 + 60` block and **not** the live five-quest log.

| Objective count | Quest IDs |
| ---: | --- |
| 6 | `14106`, `9246`, `9243`, `9236` |
| 5 | `32317` |
| 4 | `33161`, `33100`, `32872`, `32862`, `32819`, `32816`, `32811`, `32809`, `32805`, `32588`, `32586`, `32537`, `32492`, `32418`, `32411`, `32330`, `32255`, `32209`, `32208`, `31776` |

Total: **25 quests and 109 objective entries**. The quest/objective IDs are real data; the progress counts are synthetic because the size stress is driven by packet shape and objective count.

### Actual legacy AceComm path for the 25-quest fixture

The current legacy path block-splits and then sends through AceComm. In the local emulator guardrail, Bob received all 25 remote quest logs.

| Metric | Value |
| --- | ---: |
| Quests received | 25 |
| Low-level AceComm chunks | 26 |
| Total low-level chunk bytes | 5230 |
| Max chunk length | 248 |

### Hypothetical unsplit 25-quest serializer comparison

The next two tables compare serializers against the same 25-quest data as one unsplit full-list payload. Production legacy sending block-splits before AceComm, so these are serializer-efficiency comparisons from the local harness, not live WoW transport proof.

Lower percentages are smaller/better, with the current QuestieSerializer path as the `100% (<bytes>)` baseline.

| 25-quest full-list fixture | Questie baseline | Questie + Deflate | Ace | Ace + Deflate | CBOR | CBOR + Deflate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| V1 keyed shape | 100% (3862) | 18% (701) | 167% (6441) | 20% (779) | 104% (4012) | 17% (673) |
| V2 compact positional shape | 100% (962) | 50% (477) | 487% (4685) | 169% (1627) | 132% (1266) | 50% (477) |

For big keyed V1 packets, compression dominates and AceSerializer + Deflate gets close to the compressed alternatives. For compact positional V2 packets, AceSerializer remains a poor size fit: raw AceSerializer is almost five times the QuestieSerializer payload, and AceSerializer + Deflate is still larger than the uncompressed QuestieSerializer baseline.

These 25-quest values are local emulator measurements. Any exact near-limit transport behavior should still be verified in a live WoW client before relying on byte counts for production decisions.

## Raw binary over addon channels

Raw CBOR and raw compressed strings are not safe to send directly over addon channels in all cases. In the self-WHISPER debug tests, raw variants were received but corrupted or truncated.

For V1 quest 47:

| Codec | Addon-safe wrapped | Payload bytes | Receive result |
| --- | ---: | ---: | --- |
| `questie` | no | 91 | OK |
| `cbor` | yes | 82 | OK |
| `cbor-raw` | no | 80 | Failed CBOR deserialize |
| `cbor-deflate` | yes | 81 | OK |
| `cbor-deflate-raw` | no | 80 | Failed decompress |
| `cbor-zlib` | yes | 87 | OK |
| `cbor-zlib-raw` | no | 86 | Failed decompress |
| `cbor-gzip` | yes | 108 | OK |
| `cbor-gzip-raw` | no | 98 | Failed decompress |

Use an encoding step before sending binary CBOR/compression output through addon channels. V2 raw tests showed the same general risk: some raw compressed samples happened to survive, but raw binary transport is not reliable.

## SAY and YELL addon-channel behavior

Classic supports addon messages over `SAY` and `YELL`, but the payload is not fully binary-safe.

### Safe byte set

Live scan result for both `YELL` and `SAY`:

- Bytes `1..9`: delivered exactly.
- Byte `10` (`LF`, `\n`): truncates the received message before this byte.
- Bytes `11..12`: delivered exactly.
- Byte `13` (`CR`, `\r`): truncates the received message before this byte.
- Bytes `14..255`: delivered exactly.
- Byte `0` (`NUL`): unsafe; a message consisting only of NUL failed to send, and a message containing NUL was truncated before it.

Therefore the practical safe byte set for `SAY`/`YELL` is:

```text
1..9, 11..12, 14..255
```

Equivalently, avoid:

```lua
string.char(0)
string.char(10)
string.char(13)
```

### Why the common 1..255 reproduction truncates at 9 bytes

A payload containing bytes `1..255` receives only the first 9 bytes over `SAY`/`YELL` because byte `10` is the first disallowed/truncating byte.

A follow-up scan from byte `11` receives two bytes before truncating at byte `13`. A scan from byte `14` through `255` is delivered intact.

### SAY/YELL length limit

Safe repeated `A` payloads showed:

| Sent bytes | Received bytes | Exact match |
| ---: | ---: | --- |
| 240 | 240 | yes |
| 255 | 255 | yes |
| 256 | 255 | no, truncated |
| 300 | 255 | no, truncated |

Final encoded `SAY`/`YELL` addon messages should be kept at or below 255 bytes.

### SAY/YELL throttling

A burst test sent 12 immediate `YELL` addon messages on one prefix:

- Sends 1 through 10 succeeded.
- Sends 11 and 12 failed.

This matches the expected per-prefix burst allowance behavior. `SAY`/`YELL` should be treated as heavily throttled and used sparingly.

### Encoding implications for SAY/YELL

Tested over `YELL` with a normal quest update packet:

| Payload form | YELL result |
| --- | --- |
| QuestieSerializer raw | truncated |
| QuestieSerializer `b89` mode | exact |
| CBOR raw | truncated |
| CBOR with `LibDeflate:EncodeForWoWAddonChannel` | truncated in sample |
| CBOR with `LibDeflate:EncodeForWoWChatChannel` | exact |
| CBOR + Deflate raw | truncated |
| CBOR + Deflate with addon-channel encoding | exact in sample, but not guaranteed by alphabet |
| CBOR + Deflate with chat-channel encoding | exact |

`LibDeflate:EncodeForWoWAddonChannel` is not sufficient for `SAY`/`YELL` because its alphabet can include byte `10` or `13`. Use a chat-safe encoding instead.

## CHANNEL addon messages on Classic

A direct Classic `CHANNEL` addon-message send was tested against the General channel:

```lua
C_ChatInfo.SendAddonMessage(prefix, "PING", "CHANNEL", channelId)
```

Observed return values:

```lua
false, 4
```

`4` corresponds to `Enum.SendAddonMessageResult.InvalidChatType`. This confirms `CHANNEL` addon messages are disabled in this tested Classic client.

## Recommendations for Questie

### Current modern runtime note

The benchmark tables and transport tests in this report refer to LibDeflate's addon/chat-channel encoders because that was the tested source implementation. Questie's modern typed-prefix runtime now uses `Modules/Network/CommsEncoding.lua`, which preserves the needed LibDeflate/LibCompress addon-channel codec machinery and attribution, but does not load the full LibDeflate runtime library. Compression is Blizzard's built-in Deflate through `C_EncodingUtil`.

### Packet-shape direction

Prefer hardening and reusing the existing QuestieComms V2 packet shape before inventing a V1 dictionary layer.

Rationale:

- V2 already removes most V1 string-key overhead.
- V2 single quest update packets are roughly half the size of V1 packets before changing serializers.
- A V1 dictionary can reduce size, but it adds pure-Lua compression cost and protocol coupling.
- The active V2 full-list path appears fragile and should be fixed before optimizing its serialization.

### V2 single quest-update packets

Recommended candidates:

1. If adopting V2 while minimizing serializer changes: keep the V2 packet shape with QuestieSerializer.
2. If optimizing speed and modest size: serialize the V2 packet shape with `C_EncodingUtil.SerializeCBOR`, then addon-channel-safe encode the binary CBOR output.
3. If optimizing smallest non-dictionary payload: V2 CBOR + built-in Deflate + addon-channel-safe encoding.

Rationale:

- V2 QuestieSerializer is already compact.
- V2 CBOR is still faster and slightly smaller.
- Built-in Deflate saves only a few bytes on single quest updates, so default compression may not be worth the extra complexity.

### V2 full quest-list packets

Recommended candidate after hardening V2 decode/encode correctness:

1. Serialize the V2 packet shape with CBOR.
2. Compress with `C_EncodingUtil.CompressString(..., Enum.CompressionMethod.Deflate)`.
3. Encode for the target transport.

Rationale:

- V2 full-list CBOR + Deflate was smallest in the tested full-list blocks.
- Built-in Deflate is much faster than LibDeflate pure-Lua compression.
- Full-list and multi-quest packets are large enough for compression to pay off more often.

### SAY/YELL packet encoding

For any future or restored Questie `SAY`/`YELL` addon messages:

- Keep the final encoded message at `<= 255` bytes.
- Avoid bytes `0`, `10`, and `13`.
- Prefer one of:
  - `QuestieSerializer:Serialize(packet, "b89")` for existing Questie serializer paths.
  - `LibDeflate:EncodeForWoWChatChannel(binaryPayload)` for CBOR/compressed binary payloads.
- Do not use raw CBOR/compressed bytes.
- Do not rely on `LibDeflate:EncodeForWoWAddonChannel` for `SAY`/`YELL`.

### CHANNEL

Do not plan on custom `CHANNEL` addon messages for Classic. The tested client returned `InvalidChatType`.

## Caveats

- Tests were run on one live Classic client and one character.
- Round-trip tests used self `WHISPER` and debug prefixes, not a second account or real party/raid recipient.
- `SAY`/`YELL` behavior was tested locally by receiving self-originated range messages; server behavior could change.
- Questie's current full-list packet samples were small because the current quest log had five quests.
- The V2 full-list path currently appears fragile for zero-objective quests based on the live current-log test; zero-objective quests can be counted without emitting a corresponding V2 quest tuple.
- V2 single quest update (`msgId = 14`) has a handler but is not the normal active quest-update sender today.
- CBOR map key ordering is not deterministic according to Blizzard documentation. This is fine for decode/encode transport, but raw byte equality should not be used as a semantic hash unless a deterministic representation is imposed.
- Any migration of QuestieComms packet formats would need version negotiation and compatibility handling. This report only compares packet shapes, serializers, compression, and transport behavior.
