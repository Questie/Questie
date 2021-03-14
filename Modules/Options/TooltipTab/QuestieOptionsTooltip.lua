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
        name = function() return l10n('Tooltips'); end,
        type = "group",
        order = 16,
        args = {
            tooltip_options = {
                type = "header",
                order = 1,
                name = function() return l10n('Tooltip options'); end,
            },
            enableTooltipsToggle = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Enable Tooltips'); end,
                desc = function() return l10n('When this is enabled, quest info will be added to relevant mob/item tooltips.'); end,
                width = 1.5,
                get = function () return Questie.db.global.enableTooltips; end,
                set = function (info, value) Questie.db.global.enableTooltips = value end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.2,
                name = function() return l10n('Show Quest Level in Tooltips'); end,
                desc = function() return l10n('When this is checked, the level of quests will show in the tooltips.'); end,
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
                name = function() return l10n('Only show party members'); end,
                desc = function() return l10n('When this is enabled, shared quest info will only show players in your party.'); end,
                width = 1.5,
                get = function () return Questie.db.global.onlyPartyShared; end,
                set = function (info, value) Questie.db.global.onlyPartyShared = value end
            },
            questsInNpcTooltip = {
                type = "toggle",
                order = 1.4,
                name = function() return l10n('Show quests in NPC tooltips'); end,
                desc = function() return l10n('Show quests (available/complete) in the NPC tooltips.'); end,
                width = 1.5,
                get = function () return Questie.db.char.showQuestsInNpcTooltip; end,
                set = function (info, value) Questie.db.char.showQuestsInNpcTooltip = value end
            }
        }
    }
end