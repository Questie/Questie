---@class QuestieAnnounce
local QuestieAnnounce = QuestieLoader:CreateModule("QuestieAnnounce")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieAnnounce._itemCache = {} -- cache data since this happens on item looted it could happen a lot with auto loot

QuestieAnnounce._AlreadySentBandaid = {} -- TODO: rewrite the entire thing its a lost cause

function QuestieAnnounce:Announce(questId, progressType, itemId, objectiveText, objectiveProgress)
    if "disabled" ~= Questie.db.char.questAnnounce and UnitInParty("player") then
        local message

        local questName = QuestieDB.QueryQuestSingle(questId, "name")
        local questLevel, _ = QuestieLib:GetTbcLevel(questId);

        if progressType == "objective" then
            local objective
            if itemId then
                objective = objectiveProgress.." "..(select(2,GetItemInfo(itemId)))
            else
                objective = objectiveProgress.." "..objectiveText
            end
            message = "{rt1} Questie : " .. l10n("%s for %s!", objective, "[["..tostring(questLevel).."] "..questName.." ("..tostring(questId)..")]")
        elseif progressType == "item" then
            message = "{rt1} Questie : " .. l10n("Picked up %s which starts %s!", (select(2,GetItemInfo(itemId))), "[["..tostring(questLevel).."] "..questName.." ("..tostring(questId)..")]")
        end

        if (not message) or QuestieAnnounce._AlreadySentBandaid[message] then
            return
        end

        QuestieAnnounce._AlreadySentBandaid[message] = true

        SendChatMessage(message, "PARTY")
    end
end

local _playerName
local function _GetPlayerName()
    _playerName = UnitName("Player")
    return _playerName
end

function QuestieAnnounce:ItemLooted(text, notPlayerName, _, _, playerName)
    if (_playerName or _GetPlayerName()) == playerName or (string.len(playerName) == 0 and _playerName == notPlayerName) then
        local itemId = tonumber(string.match(text, "item:(%d+)"))
        if not QuestieAnnounce._itemCache[itemId] and QuestieDB.QueryItemSingle then -- check QueryItemSingle because this event can fire before db init is complete
            QuestieAnnounce._itemCache[itemId] = QuestieDB.QueryItemSingle(itemId, "startQuest") or false -- we do "or false" here because nil cant be inserted into _itemCache
        end
        local startQuest = QuestieAnnounce._itemCache[itemId]
        if startQuest and startQuest > 0 then
            QuestieAnnounce:Announce(startQuest, "item", itemId)
        end
    end
end

