---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type WorldMapButton
local WorldMapButton = QuestieLoader:ImportModule("WorldMapButton")

QuestieOptions.tabs.map = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.map:Initialize()
    return {
        name = function() return l10n('Map'); end,
        type = "group",
        order = 12,
        args = {
        },
    }
end
