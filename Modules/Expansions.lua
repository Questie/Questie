---@class Expansions
local Expansions = QuestieLoader:CreateModule("Expansions")

-- Make sure these are available
-- Provided by blizzard
local expansionOrderLookup = {
    [2] = 1,
    [5] = 2,
    [11] = 3,
    [14] = 4,
    [19] = 5,
    -- Forever reports WOW_PROJECT_MAINLINE (1) but ships Era content: Questie-Camelot.toc
    -- loads the same file list as Questie-Classic.toc. It is deliberately not the
    -- "far future" ordinal retail would want, which would switch on every
    -- `>= Wotlk/Cata/MoP` correction block on top of the Era database.
    [1] = 1,
}
-- Expansions.Retail = expansionOrderLookup[WOW_PROJECT_MAINLINE or 1]
Expansions.Era = expansionOrderLookup[WOW_PROJECT_CLASSIC or 2]
Expansions.Tbc = expansionOrderLookup[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5]
Expansions.Wotlk = expansionOrderLookup[WOW_PROJECT_WRATH_CLASSIC or 11]
Expansions.Cata = expansionOrderLookup[WOW_PROJECT_CATACLYSM_CLASSIC or 14]
Expansions.MoP = expansionOrderLookup[WOW_PROJECT_MISTS_CLASSIC or 19]

-- Resolved last so an unrecognised client can fall back to Era. The `or 2` inside
-- the brackets only covers a missing global, not a lookup miss: clients newer than
-- the table (Forever) report a real ID that is not a key here, which left Current
-- nil and errored on the first `Expansions.Current >= ...` comparison.
Expansions.Current = expansionOrderLookup[WOW_PROJECT_ID or 2] or Expansions.Era