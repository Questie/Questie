local Questie = _G.Questie
---@class QuestieAnnounce
local QuestieAnnounce = QuestieLoader:CreateModule("QuestieAnnounce")
local _QuestieAnnounce = {}
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local itemCache = {} -- cache data since this happens on item looted it could happen a lot with auto loot

local alreadySentBandaid = {} -- TODO: rewrite the entire thing its a lost cause

---@return table<string, number, string>
local function _GetQuestInfos(questId)
    local questName = QuestieDB.QueryQuestSingle(questId, "name");
    local questLevel, _ = QuestieLib:GetTbcLevel(questId);
    local questLink = QuestieLink:GetQuestLinkString(questLevel, questName, questId);

    return questName, questLevel, questLink
end

---@return string
local function _GetAnnounceMarker()
    return l10n:GetUILocale() == "ruRU" and "{звезда}" or "{rt1}";
end

local function _AnnounceParty(message, allowRepeat)
    if (not message) or (not allowRepeat and alreadySentBandaid[message]) then
        return
    end

    alreadySentBandaid[message] = true

    SendChatMessage(message, "PARTY")
end

function QuestieAnnounce:AnnounceParty(questId, progressType, itemId, objectiveText, objectiveProgress)
    if Questie.db.char.questAnnounce and UnitInParty("player") then
        local message
        local _, _, questLink = _GetQuestInfos(questId);

        if progressType == "objective" then
            local objective
            if itemId then
                local itemLink = select(2, GetItemInfo(itemId))
                objective = objectiveProgress.." "..itemLink
            else
                objective = objectiveProgress.." "..objectiveText
            end
            message = _GetAnnounceMarker() .. " Questie : " .. l10n("%s for %s!", objective, questLink)
        elseif progressType == "item" then
            local itemLink = select(2, GetItemInfo(itemId))
            message = _GetAnnounceMarker() .. " Questie : " .. l10n("Picked up %s which starts %s!", itemLink, questLink)
        end

        _AnnounceParty(message, false)
    end
end

function _QuestieAnnounce:AnnounceSelf(questId, itemId)
    local questLink = QuestieLink:GetQuestHyperLink(questId);
    local itemLink = select(2, GetItemInfo(itemId));

    Questie:Print(l10n("You picked up %s which starts %s!", itemLink, questLink));
end

local playerNameCache
---@return string
local function _GetPlayerName()
    playerNameCache = UnitName("player")
    return playerNameCache
end

function QuestieAnnounce:ItemLooted(text, notPlayerName, _, _, playerName)
    if (playerNameCache or _GetPlayerName()) == playerName or (string.len(playerName) == 0 and playerNameCache == notPlayerName) then
        local itemId = tonumber(string.match(text, "item:(%d+)"))

        local startQuestId = itemCache[itemId]
        if (startQuestId == nil) and QuestieDB.QueryItemSingle then -- check QueryItemSingle because this event can fire before db init is complete
            startQuestId = QuestieDB.QueryItemSingle(itemId, "startQuest")
            -- filter 0 values away so itemCache value is a valid questId if it evaluates to true
            -- we do "or false" here because nil would mean not cached
            startQuestId = (startQuestId and startQuestId > 0) and startQuestId or false
            itemCache[itemId] = startQuestId
        end

        if startQuestId then
            if (not UnitInParty("player")) or (not Questie.db.char.questAnnounce) then
                _QuestieAnnounce:AnnounceSelf(startQuestId, itemId)
                return
            end

            QuestieAnnounce:AnnounceParty(startQuestId, "item", itemId)
        end
    end
end


function QuestieAnnounce:AcceptQuest(questId)
    if Questie.db.char.questAnnounce and Questie.db.char.questAnnounceAccepted and UnitInParty("player") then
        local questName, _, questLink = _GetQuestInfos(questId);
        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Quest %s: %s", l10n('Accepted'), questLink or questName or "no quest name")

        _AnnounceParty(message, true)
    end
end

function QuestieAnnounce:AbandonQuest(questId)
    if Questie.db.char.questAnnounce and Questie.db.char.questAnnounceAbandoned and UnitInParty("player") then
        local questName, _, questLink = _GetQuestInfos(questId);
        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Quest %s: %s", l10n('Abandoned'), questLink or questName or "no quest name")

        _AnnounceParty(message, true)
    end
end

function QuestieAnnounce:CompleteQuest(questId)
    if Questie.db.char.questAnnounce and Questie.db.char.questAnnounceCompleted and UnitInParty("player") then
        local questName, _, questLink = _GetQuestInfos(questId);
        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Quest %s: %s", l10n('Completed'), questLink or questName or "no quest name")

       _AnnounceParty(message, true)
    end
end
