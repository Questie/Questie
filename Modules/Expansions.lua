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
    -- [1] = 100000000, -- Retail is in the far future
}
-- Fallbacks in case the global variables are not defined
EXPANSION_NAME0 = EXPANSION_NAME0 or "Classic"
EXPANSION_NAME1 = EXPANSION_NAME1 or "The Burning Crusade"
EXPANSION_NAME2 = EXPANSION_NAME2 or "Wrath of the Lich King"
EXPANSION_NAME3 = EXPANSION_NAME3 or "Cataclysm"
EXPANSION_NAME4 = EXPANSION_NAME4 or "Mists of Pandaria"

Expansions.Current = expansionOrderLookup[WOW_PROJECT_ID or 2] -- If not found, default to classic(era)
-- Expansions.Retail = expansionOrderLookup[WOW_PROJECT_MAINLINE or 1]
Expansions.Era = expansionOrderLookup[WOW_PROJECT_CLASSIC or 2]
Expansions.Tbc = expansionOrderLookup[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5]
Expansions.Wotlk = expansionOrderLookup[WOW_PROJECT_WRATH_CLASSIC or 11]
Expansions.Cata = expansionOrderLookup[WOW_PROJECT_CATACLYSM_CLASSIC or 14]
Expansions.MoP = expansionOrderLookup[WOW_PROJECT_MISTS_CLASSIC or 19]

return Expansions
