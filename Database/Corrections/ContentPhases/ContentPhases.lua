---@class ContentPhases
local ContentPhases = QuestieLoader:CreateModule("ContentPhases")

-- TODO: Use API function which hopefully will come in the future
-- Central place to define the active phases of the different game modes
ContentPhases.activePhases = {
    SoM = 5,
    SoD = 7,
    Anniversary = 5,
    MoP = 1,
}

return ContentPhases
