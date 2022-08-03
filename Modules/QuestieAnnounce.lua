local Questie = _G.Questie
---@class QuestieAnnounce
local QuestieAnnounce = QuestieLoader:CreateModule("QuestieAnnounce")
local _QuestieAnnounce = {}
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local itemCache = {} -- cache data since this happens on item looted it could happen a lot with auto loot

local alreadySentBandaid = {} -- TODO: rewrite the entire thing its a lost cause

local _GetAnnounceMarker

---@return string
_GetAnnounceMarker = function()
    return l10n:GetUILocale() == "ruRU" and "{звезда}" or "{rt1}";
end

function QuestieAnnounce:AnnounceObjectiveToChannel(questId, itemId, objectiveText, objectiveProgress)
    if _QuestieAnnounce:AnnounceEnabledAndPlayerInChannel() and Questie.db.char.questAnnounceObjectives then
        -- no hyperlink required here
        local questLink = QuestieLink:GetQuestLinkStringById(questId);

        local objective
        if itemId then
            local itemLink = select(2, GetItemInfo(itemId))
            objective = objectiveProgress.." "..itemLink
        else
            objective = objectiveProgress.." "..objectiveText
        end

        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("%s for %s!", objective, questLink)
        _QuestieAnnounce:AnnounceToChannel(message)
    end
end

local _has_seen_incomplete = {}
local _has_sent_announce = {}

function QuestieAnnounce:ObjectiveChanged(questId, text, numFulfilled, numRequired)
    -- Announce completed objective
    if (numRequired ~= numFulfilled) then
        _has_seen_incomplete[text] = true
    elseif _has_seen_incomplete[text] and not _has_sent_announce[text] then
        _has_seen_incomplete[text] = nil
        _has_sent_announce[text] = true
        QuestieAnnounce:AnnounceObjectiveToChannel(questId, nil, text, tostring(numFulfilled) .. "/" .. tostring(numRequired))
    end
end


function QuestieAnnounce:AnnounceQuestItemLootedToChannel(questId, itemId)
    if _QuestieAnnounce:AnnounceEnabledAndPlayerInChannel() and Questie.db.char.questAnnounceItems then
        local questHyperLink = QuestieLink:GetQuestLinkStringById(questId);
        local itemLink = select(2, GetItemInfo(itemId))

        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Picked up %s which starts %s!", itemLink, questHyperLink)
        _QuestieAnnounce:AnnounceToChannel(message)
        return true
    else
        return false
    end
end

function _QuestieAnnounce:AnnounceSelf(questId, itemId)
    local questHyperLink = QuestieLink:GetQuestHyperLink(questId);
    local itemLink = select(2, GetItemInfo(itemId));

    Questie:Print(l10n("You picked up %s which starts %s!", itemLink, questHyperLink));
end

---@return boolean
function _QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()
    if Questie.db.char.questAnnounceChannel == "both" then
        return IsInRaid() or IsInGroup()
    elseif Questie.db.char.questAnnounceChannel == "raid" then
        return IsInRaid()
    elseif Questie.db.char.questAnnounceChannel == "group" then
        return IsInGroup() and not IsInRaid()
    else
        return false
    end
end

function _QuestieAnnounce:AnnounceToChannel(message)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAnnounce] raw msg: ", message)
    if (not message) or alreadySentBandaid[message] or Questie.db.global.questieShutUp then
        return
    end

    alreadySentBandaid[message] = true

    SendChatMessage(message, (IsInRaid() and "RAID") or (IsInGroup() and "PARTY"))
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
        if not itemId then return end

        local startQuestId = itemCache[itemId]
        -- startQuestId can have boolean false as value, need to compare to nil
        -- check QueryItemSingle because this event can fire before db init is complete
        if (startQuestId == nil) and QuestieDB.QueryItemSingle then
            startQuestId = QuestieDB.QueryItemSingle(itemId, "startQuest")
            -- filter 0 values away so itemCache value is a valid questId if it evaluates to true
            -- we do "or false" here because nil would mean not cached
            startQuestId = (startQuestId and startQuestId > 0) and startQuestId or false
            itemCache[itemId] = startQuestId
        end

        if startQuestId then
            if not QuestieAnnounce:AnnounceQuestItemLootedToChannel(startQuestId, itemId) then
                _QuestieAnnounce:AnnounceSelf(startQuestId, itemId)
            end
        end
    end
end

function QuestieAnnounce:AcceptedQuest(questId)
    if (_QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()) and Questie.db.char.questAnnounceAccepted then
        local questLink = QuestieLink:GetQuestLinkStringById(questId)

        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Quest %s: %s", l10n('Accepted'), questLink or "no quest name")
        _QuestieAnnounce:AnnounceToChannel(message)
    end
end

function QuestieAnnounce:AbandonedQuest(questId)
    if (_QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()) and Questie.db.char.questAnnounceAbandoned then
        local questLink = QuestieLink:GetQuestLinkStringById(questId)

        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Quest %s: %s", l10n('Abandoned'), questLink or "no quest name")
        _QuestieAnnounce:AnnounceToChannel(message)
    end
end

function QuestieAnnounce:CompletedQuest(questId)
    if (_QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()) and Questie.db.char.questAnnounceCompleted then
        local questLink = QuestieLink:GetQuestLinkStringById(questId)

        local message = _GetAnnounceMarker() .. " Questie : " .. l10n("Quest %s: %s", l10n('Completed'), questLink or "no quest name")
        _QuestieAnnounce:AnnounceToChannel(message)
    end
end
