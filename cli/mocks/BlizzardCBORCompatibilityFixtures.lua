---@class BlizzardCBORCompatibilityFixture
---@field blizzardHex string? Lowercase hex output from C_EncodingUtil.SerializeCBOR.
---@field blizzardError string? Error text captured from C_EncodingUtil.SerializeCBOR.
---@field wowBuild string? Build/version string reported by GetBuildInfo.
---@field interfaceVersion number? Interface version reported by select(4, GetBuildInfo()).
---@field capturedAt string? Client-local capture timestamp when available.
---@field compareLocally boolean? Set true for map cases only when local table iteration order is known to match the capture.
---@field notes string? Human-readable fixture caveat.

---@class BlizzardCBORCompatibilityFixtures
---@field metadata table Fixture-set metadata copied from the in-game helper.
---@field cases table<string, BlizzardCBORCompatibilityFixture> Fixtures keyed by BlizzardCBORCompatibilityCase.id.

-- Captured from a live WoW Classic Era client through wow-lua-bridge.
-- Map-order-unstable cases intentionally do not set compareLocally; the
-- compatibility test skips those byte comparisons unless explicitly enabled.
return {
    metadata = {
        formatVersion = 1,
        source = "wow-lua-bridge direct C_EncodingUtil.SerializeCBOR capture",
        capturedWith = "wow-lua-bridge",
        capturedAt = "2026-07-01 20:47:53",
        wowBuild = "67156",
        wowVersion = "1.15.8",
        buildDate = "Apr 22 2026",
        interfaceVersion = 11508,
        locale = "enUS",
        projectId = 2,
    },

    cases = {
        ["omitted-value"] = {
            blizzardError = "bad argument #1 to '?' (value expected)",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["nil-value"] = {
            blizzardHex = "f6",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["boolean-false"] = {
            blizzardHex = "f4",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["boolean-true"] = {
            blizzardHex = "f5",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["string-empty"] = {
            blizzardHex = "40",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["string-ascii"] = {
            blizzardHex = "4c517565737469652043424f52",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["string-null-byte"] = {
            blizzardHex = "4461006200",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["string-high-bytes"] = {
            blizzardHex = "4500017f80ff",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-zero"] = {
            blizzardHex = "00",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-23"] = {
            blizzardHex = "17",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-24"] = {
            blizzardHex = "1818",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-255"] = {
            blizzardHex = "18ff",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-256"] = {
            blizzardHex = "190100",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-65535"] = {
            blizzardHex = "19ffff",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-65536"] = {
            blizzardHex = "1a00010000",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-uint32-max"] = {
            blizzardHex = "1affffffff",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-uint32-plus-one"] = {
            blizzardHex = "1b0000000100000000",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["integer-safe-max"] = {
            blizzardHex = "1b0020000000000000",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["negative-one"] = {
            blizzardHex = "20",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["negative-24"] = {
            blizzardHex = "37",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["negative-25"] = {
            blizzardHex = "3818",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["negative-256"] = {
            blizzardHex = "38ff",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["negative-65536"] = {
            blizzardHex = "39ffff",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["float-half-exact"] = {
            blizzardHex = "f93800",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["float-double-typical"] = {
            blizzardHex = "fb3ff199999999999a",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["float-positive-infinity"] = {
            blizzardHex = "f97c00",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["float-negative-infinity"] = {
            blizzardHex = "f9fc00",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["float-nan"] = {
            blizzardHex = "f97e00",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["float-negative-zero"] = {
            blizzardHex = "00",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["table-empty"] = {
            blizzardHex = "80",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["table-dense-array"] = {
            blizzardHex = "83416141624163",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["table-sparse-small-gap"] = {
            blizzardHex = "834161f64163",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["table-sparse-large-gap"] = {
            blizzardHex = "a20141611864417a",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["table-zero-index"] = {
            blizzardHex = "a200447a65726f01436f6e65",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["table-string-key-map"] = {
            blizzardHex = "a2446e616d6547517565737469654776657273696f6e01",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["table-mixed-key-map"] = {
            blizzardHex = "a2014b61727261792d76616c7565456164646f6e4751756573746965",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["table-boolean-key-map"] = {
            blizzardHex = "a2f44966616c73652d6b6579f548747275652d6b6579",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["table-table-key-map"] = {
            blizzardHex = "a181497461626c652d6b65794f7461626c652d6b65792d76616c7565",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["table-nested-depth-100"] = {
            blizzardHex = "81818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818180",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["table-nested-depth-101"] = {
            blizzardError = "attempted to serialize a table structure that is too deep (cannot exceed 100 levels)\nLua Taint: *** ForceTaint_Strong ***",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["table-recursive"] = {
            blizzardError = "attempted to serialize a recursive table structure\nLua Taint: *** ForceTaint_Strong ***",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["unsupported-function-root"] = {
            blizzardError = "attempted to serialize a function value\nLua Taint: *** ForceTaint_Strong ***",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["unsupported-function-root-ignored"] = {
            blizzardHex = "f7",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["unsupported-function-in-map"] = {
            blizzardError = "attempted to serialize a function value\nLua Taint: *** ForceTaint_Strong ***",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["unsupported-function-in-map-ignored"] = {
            blizzardHex = "a2426f6b4f6265666f72652d66756e6374696f6e4b756e737570706f72746564f7",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
            notes = "Map byte order can depend on Lua table iteration order; compareLocally intentionally omitted.",
        },
        ["unsupported-function-map-key"] = {
            blizzardError = "attempted to serialize a function value\nLua Taint: *** ForceTaint_Strong ***",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
        ["unsupported-function-map-key-ignored"] = {
            blizzardHex = "a1f75266756e6374696f6e2d6b65792d76616c7565",
            wowBuild = "67156",
            interfaceVersion = 11508,
            capturedAt = "2026-07-01 20:47:53",
        },
    },
}
