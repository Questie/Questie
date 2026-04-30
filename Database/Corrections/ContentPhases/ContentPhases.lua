---@class ContentPhases
local ContentPhases = QuestieLoader:CreateModule("ContentPhases")

-- TODO: Use API function which hopefully will come in the future
-- Central place to define the active phases of the different game modes
ContentPhases.activePhases = {
    SoM = 5,
    SoD = 7,
    Anniversary = 6, -- Phase 6 is the final state of the game, with invasions inactive.
    MoP = 4,
    TBC = 1,
}

-- Central place to activate Invasion event
ContentPhases.IsInvasionActive = {
    [1] = Questie.IsSoD and true or false, -- Era
    [2] = false, -- TBC
    [3] = false, -- Wotlk - Remember Questie.IsTitanReforged is WotLK technically
}

return ContentPhases
