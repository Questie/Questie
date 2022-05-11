
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.nameplate = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

function QuestieOptions.tabs.social:Initialize()
    return {
        name = function() return l10n("Social"); end,
        type = "group",
        order = 10,
        args = {
            social_header = {
                type = "header",
                order = 1,
                name = function() return l10n("Social Options"); end,
            },
        }
    }
end