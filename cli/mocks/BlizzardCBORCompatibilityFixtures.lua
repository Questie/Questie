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

-- This file intentionally starts without captured bytes. Run the external
-- BlizzardCBORCompat helper in-game, then copy successful Blizzard hex/error
-- results into the cases table below.
return {
    metadata = {
        formatVersion = 1,
        source = "QuestieBlizzardCBORCompatDB.latestRun.results",
        capturedWith = nil,
        capturedAt = nil,
        wowBuild = nil,
        interfaceVersion = nil,
    },

    cases = {
        -- Example success fixture:
        -- ["nil-value"] = {
        --     blizzardHex = "f6",
        --     wowBuild = "5.5.0.XXXXX",
        --     interfaceVersion = 50500,
        -- },
        --
        -- Example expected-error fixture:
        -- ["unsupported-function-root"] = {
        --     blizzardError = "unsupported value type: function",
        --     wowBuild = "5.5.0.XXXXX",
        --     interfaceVersion = 50500,
        -- },
    },
}
