---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.tooltip = {...}

function QuestieOptions.tabs.tooltip:Initialize()
    return {
        name = function() return l10n('Tooltips'); end,
        type = "group",
        order = 16,
        args = {
            tooltip_options = {
                type = "header",
                order = 1,
                name = function() return l10n('Tooltip Options'); end,
            },
            enableTooltipsToggle = {
                type = "toggle",
                order = 1.1,
                name = function() return l10n('Enable Tooltips'); end,
                desc = function() return l10n('When this is enabled, quest info will be added to relevant mob/item tooltips.'); end,
                width = 1.5,
                get = function () return Questie.db.profile.enableTooltips; end,
                set = function (_, value) Questie.db.profile.enableTooltips = value end
            },
            showQuestLevels = {
                type = "toggle",
                order = 1.2,
                name = function() return l10n('Show Quest Level in Tooltips'); end,
                desc = function() return l10n('When this is checked, the level of quests will show in the tooltips.'); end,
                width = 1.5,
                disabled = function() return not Questie.db.profile.enableTooltips; end,
                get = function() return Questie.db.profile.enableTooltipsQuestLevel; end,
                set = function (_, value)
                    Questie.db.profile.enableTooltipsQuestLevel = value
                    if value and not Questie.db.profile.trackerShowQuestLevel then
                        Questie.db.profile.trackerShowQuestLevel = true
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
                get = function () return Questie.db.profile.onlyPartyShared; end,
                set = function (_, value) Questie.db.profile.onlyPartyShared = value end
            },
            questsInNpcTooltip = {
                type = "toggle",
                order = 1.4,
                name = function() return l10n('Show quests in NPC tooltips'); end,
                desc = function() return l10n('Show quests (available/complete) in the NPC tooltips.'); end,
                width = 1.5,
                get = function () return Questie.db.profile.showQuestsInNpcTooltip; end,
                set = function (_, value) Questie.db.profile.showQuestsInNpcTooltip = value end
            },
            questXpAtMaxLevel = {
                type = "toggle",
                order = 1.5,
                name = function() return l10n('Show quest XP at max level'); end,
                desc = function() return l10n('Shows the quest XP values on quests even at max level.'); end,
                width = 1.5,
                get = function () return Questie.db.profile.showQuestXpAtMaxLevel; end,
                set = function (_, value) Questie.db.profile.showQuestXpAtMaxLevel = value end
            },
        }
    }
end
