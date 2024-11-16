---@class ContentPhases
local ContentPhases = QuestieLoader:CreateModule("ContentPhases")

-- Central place to define the active phases of the different game modes
ContentPhases.activePhases = {
    SoM = 5,
    Anniversary = 1,
}
