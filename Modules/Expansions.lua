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
}
Expansions.Era = expansionOrderLookup[WOW_PROJECT_CLASSIC or 2]
Expansions.Tbc = expansionOrderLookup[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5]
Expansions.Wotlk = expansionOrderLookup[WOW_PROJECT_WRATH_CLASSIC or 11]
Expansions.Cata = expansionOrderLookup[WOW_PROJECT_CATACLYSM_CLASSIC or 14]
Expansions.MoP = expansionOrderLookup[WOW_PROJECT_MISTS_CLASSIC or 19]

-- Only a missing project ID defaults to Era. Unknown IDs, including actual Retail, remain unmapped.
Expansions.Current = expansionOrderLookup[WOW_PROJECT_ID or 2]
if Questie and Questie.IsForever then
    -- VersionCheck runs first in every TOC. Forever's API family does not determine its content expansion.
    Expansions.Current = Expansions.Era
end

-- Era content is also used by Forever, but Era-specific presentation is not.
-- Keep Current numeric for data selection and expose the client-aware predicate separately.
function Expansions:IsEra()
    return self.Current == self.Era and not (Questie and Questie.IsForever)
end
