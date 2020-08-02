-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent");

QuestieOptions.tabs.tooltip = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()

function QuestieOptions.tabs.tooltip:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('TOOLTIP_TAB'); end,
        type = "group",
        order = 16,
        args = {
            tooltip_options = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('TOOLTIP_OPTIONS_HEADER'); end,
            },
            enableTooltipsToggle = {
                type = "toggle",
                order = 1.1,
                name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.global.enableTooltips; end,
                set = function (info, value) Questie.db.global.enableTooltips = value end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.2,
                name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL_DESC'); end,
                width = 1.5,
                disabled = function() return not Questie.db.global.enableTooltips; end,
                get = function() return Questie.db.global.enableTooltipsQuestLevel; end,
                set = function (info, value)
                    Questie.db.global.enableTooltipsQuestLevel = value
                    if value and not Questie.db.global.trackerShowQuestLevel then
                        Questie.db.global.trackerShowQuestLevel = true
                        QuestieTracker:Update()
                    end
                end
            },
            partyOnlyToggle = {
                type = "toggle",
                order = 1.3,
                name = function() return QuestieLocale:GetUIString('SHARED_TOOLTIP_PARTY_ONLY'); end,
                desc = function() return QuestieLocale:GetUIString('SHARED_TOOLTIP_PARTY_ONLY_DESC'); end,
                width = 1.5,
                get = function () return Questie.db.global.onlyPartyShared; end,
                set = function (info, value) Questie.db.global.onlyPartyShared = value end
            }
        }
    }
end