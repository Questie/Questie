# Blizzard CBOR mock compatibility workflow

This directory contains a test-only pure Lua mock for Blizzard's
`C_EncodingUtil.SerializeCBOR` and `C_EncodingUtil.DeserializeCBOR` APIs. It is
used by Busted/CLI tests where Blizzard APIs do not exist.

This mock is not Questie runtime code. Do not add it to normal Questie TOCs. If
it needs to be loaded in-game for manual comparison, add it temporarily for that
local test only.

## Contract to emulate

Use Blizzard's API documentation as the source of truth:

- `C_EncodingUtil.SerializeCBOR([value [, options]]) -> string`
  - Live Classic Era fixtures show the value argument is required; explicit `nil`
    serializes as CBOR null.
  - `options.ignoreSerializationErrors` may replace unsupported values with CBOR
    `undefined` where Blizzard supports doing so.
  - Serializes a limited RFC 8949 CBOR subset.
  - Uses preferred serialization for numbers.
  - Supports NaN and infinities.
  - Serializes Lua strings as major type `2` byte strings, never text strings.
  - Does not serialize indefinite-length strings/tables.
  - Serializes tables as arrays or maps.
  - Live fixtures show positive-integer-key sparse tables become arrays when at
    least half of their slots are occupied; nil gaps serialize as CBOR null.
  - Does not sort map keys.
  - Does not preserve table references and errors on recursive tables.
  - Does not produce major type `6` tags.
  - Errors when nested table depth exceeds `100` levels.
- `C_EncodingUtil.DeserializeCBOR(source) -> any`
  - Does not support indefinite-length items.
  - Does not support major type `6` tags.
  - Treats major type `3` text strings like byte strings; no UTF-8 validation.
  - Errors when nested table depth exceeds `100` levels.

## Files

- `cli/mocks/BlizzardCBOR.lua`
  - The pure Lua mock. `dofile` returns the mock table.
  - `setupTests.lua` installs only `SerializeCBOR` and `DeserializeCBOR` from it
    into `_G.C_EncodingUtil`.
  - It intentionally does not install compression methods.
- `cli/mocks/BlizzardCBOR.test.lua`
  - Local behavior tests for known CBOR bytes and round-trips.
- `cli/mocks/BlizzardCBORCompatibilityCases.lua`
  - Shared case list for fixture capture.
- `cli/mocks/BlizzardCBORCompatibilityFixtures.lua`
  - Live Blizzard fixture captures used by the compatibility test; refresh or extend it when new client captures are taken.
- `cli/mocks/BlizzardCBORCompatibility.test.lua`
  - Compares populated Blizzard fixtures against the mock.
- `ExternalScripts(DONOTINCLUDEINRELEASE)/BlizzardCBORCompat/`
  - Temporary addon used to capture Blizzard bytes in-game.

## Local baseline

Run before and after changing the mock:

```bash
busted cli/mocks/BlizzardCBOR.test.lua cli/mocks/BlizzardCBORCompatibility.test.lua
busted Modules/Network/CommsEncoding.test.lua
```

With no captured Blizzard fixtures, the compatibility test has one pending case.
That is expected.

Also confirm the mock is not loaded by normal Questie TOCs:

```bash
rg -n -F 'BlizzardCBOR' Questie-Classic.toc Questie-BCC.toc Questie-WOTLKC.toc Questie-Cata.toc Questie-Mists.toc
```

Expected result: no output.

## In-game capture steps

1. Copy the helper addon into WoW:

   ```text
   ExternalScripts(DONOTINCLUDEINRELEASE)/BlizzardCBORCompat
   -> Interface/AddOns/BlizzardCBORCompat
   ```

2. Enable the addon at character select.

3. Optional, but useful for map cases: temporarily load
   `cli/mocks/BlizzardCBOR.lua` before the helper. The mock exposes
   `_G.QuestieBlizzardCBORMock`, and the helper compares it against Blizzard in
   the same Lua runtime.

4. Log in and run:

   ```text
   /qcborcompat
   ```

5. Reload or log out so WoW writes SavedVariables.

6. Copy results from:

   ```lua
   QuestieBlizzardCBORCompatDB.latestRun
   ```

   into `cli/mocks/BlizzardCBORCompatibilityFixtures.lua`.

## Fixture shape

Successful serialization:

```lua
["nil-value"] = {
    blizzardHex = "f6",
    wowBuild = "5.5.0.XXXXX",
    interfaceVersion = 50500,
},
```

Expected serialization error:

```lua
["unsupported-function-root"] = {
    blizzardError = "<captured error text>",
    wowBuild = "5.5.0.XXXXX",
    interfaceVersion = 50500,
},
```

Do not set both `blizzardHex` and `blizzardError` for one fixture.

## Map-order caveat

Blizzard does not sort CBOR map keys, so map byte order can depend on Lua table
iteration order. Prefer the helper's same-process comparison for map cases.

The local compatibility test skips map-order-unstable fixtures unless the
fixture explicitly sets:

```lua
compareLocally = true
```

Only set that after confirming local Busted table order matches the captured WoW
client for that case.

## What to verify first

Prioritize fixtures for:

- `nil`, booleans, strings, and integer width boundaries;
- strings always using major type `2` byte strings;
- NaN, infinities, negative zero, and representative float widths;
- empty tables, dense arrays, sparse integer-keyed tables, and maps;
- unsupported values with and without `ignoreSerializationErrors`;
- unsupported map keys with `ignoreSerializationErrors` (Blizzard emits CBOR
  `undefined` for the key, which is serialize-compatible but may not
  deserialize back into a Lua table);
- recursive tables and depth `100` / `101` boundaries;
- deserialization-only behavior for text strings, tags, indefinite lengths, and
  malformed inputs if deserialization fixture support is expanded later.

## When a mismatch appears

Classify it before changing code:

1. Fixture copy mistake.
2. Map key order difference.
3. Sparse table array-vs-map heuristic mismatch.
4. Float width or NaN canonicalization mismatch.
5. Unsupported value/key policy mismatch, especially ignored map keys encoding
   as CBOR `undefined`.
6. Lua 5.1 numeric representation limitation.

Only tune the mock after the captured Blizzard fixture clearly identifies the
behavior.
