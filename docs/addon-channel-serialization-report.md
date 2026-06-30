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
