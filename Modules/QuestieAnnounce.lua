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

local GetItemInfo = C_Item.GetItemInfo or GetItemInfo

local itemCache = {} -- cache data since this happens on item looted it could happen a lot with auto loot
local alreadySentBandaid = {} -- TODO: rewrite the entire thing its a lost cause

-- === Below code borrowed from ShutUp to implement Questie logo swapping for chat messages ===

-- Compatibility: 2.5.5+ uses ChatFrameUtil.AddMessageEventFilter/RemoveMessageEventFilter instead of ChatFrame_AddMessageEventFilter/RemoveMessageEventFilter
local ChatFrameAddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter
local ChatFrameRemoveMessageEventFilter = ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter or ChatFrame_RemoveMessageEventFilter

-- Safe wrapper for ChatFrameAddMessageEventFilter that handles initialization timing issues
local function SafeAddMessageEventFilter(event, filter)
    local success, err = pcall(function()
        ChatFrameAddMessageEventFilter(event, filter)
    end)
    if not success then
        -- If ChatFrameUtil isn't ready yet, retry after a short delay
        if err and string.find(err, "CreateSecureFiltersArray") then
            C_Timer.After(0.1, function()
                SafeAddMessageEventFilter(event, filter)
            end)
        else
            Questie:Error("Failed to register chat filter for", event, ":", err)
        end
    end
end

local pattern = ""
local patternRU = ""

function QuestieAnnounce.LogoFilter(self, event, msg, author, ...)
    if msg:find(pattern) then
        return false, gsub(msg, pattern, "|TInterface\\Addons\\Questie\\Icons\\questie.png:0|t"), author, ...
    end
    -- Adding this check for messages sent by ruRU clients where {rt1} doesnt work (thanks Blizz)
    -- We want those to also be replaced with our Questie icon
    if msg:find(patternRU) then
        return false, gsub(msg, patternRU, "|TInterface\\Addons\\Questie\\Icons\\questie.png:0|t"), author, ...
    end
end

function QuestieAnnounce:InitializeLogoFilter()
    pattern = "{rt1}" .. " Questie%s?:"
     -- ruRU clients don't have {rt1} so we also want to filter these
    patternRU = "{звезда}" .. " Questie%s?:"
    SafeAddMessageEventFilter("CHAT_MSG_PARTY", QuestieAnnounce.LogoFilter)
    SafeAddMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieAnnounce.LogoFilter)
    SafeAddMessageEventFilter("CHAT_MSG_RAID", QuestieAnnounce.LogoFilter)
    SafeAddMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieAnnounce.LogoFilter)
    SafeAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", QuestieAnnounce.LogoFilter)
    SafeAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestieAnnounce.LogoFilter)
end

-- === End logo swapping code block ===

local _GetAnnounceMarker

---@return string
_GetAnnounceMarker = function()
    local locale = l10n:GetUILocale()
    if IsInRaid() or IsInGroup() then
        if locale == "ruRU" then
            -- ruRU clients don't have {rt1} so we also want to filter these
            return "{звезда} Questie: ";
        elseif locale == "frFR" then
            return "{rt1} Questie : ";
        else
            return "{rt1} Questie: "
        end
    else
        return ""
    end
end

---@param questId QuestId
---@param objectiveText string
---@param objectiveProgress string
function QuestieAnnounce:AnnounceObjectiveToChannel(questId, objectiveText, objectiveProgress)
    if _QuestieAnnounce:AnnounceEnabledAndPlayerInChannel() and Questie.db.profile.questAnnounceObjectives then
        local questLink = QuestieLink:GetQuestLinkStringById(questId);
        local objective = objectiveProgress .. " " .. objectiveText
        local message = l10n("%s for %s!", objective, questLink)

        local localMessage
        if Questie.db.profile.questAnnounceLocally == true then
            localMessage = l10n("%s for %s!", objective, QuestieLink:GetQuestHyperLink(questId))
        end

        _QuestieAnnounce:AnnounceToChannel(message, localMessage)
    end
end

local _has_seen_incomplete = {}
local _has_sent_announce = {}

---@param questId QuestId
---@param text string
---@param numFulfilled number
---@param numRequired number
function QuestieAnnounce:ObjectiveChanged(questId, text, numFulfilled, numRequired)
    -- Announce completed objective
    if (numRequired ~= numFulfilled) then
        _has_seen_incomplete[text] = true
    elseif _has_seen_incomplete[text] and not _has_sent_announce[text] then
        _has_seen_incomplete[text] = nil
        _has_sent_announce[text] = true
        QuestieAnnounce:AnnounceObjectiveToChannel(questId, text, tostring(numFulfilled) .. "/" .. tostring(numRequired))
    end
end

---@param questId QuestId
---@param itemId ItemId
function QuestieAnnounce:AnnounceQuestItemLootedToChannel(questId, itemId)
    if _QuestieAnnounce:AnnounceEnabledAndPlayerInChannel() and Questie.db.profile.questAnnounceItems then
        local questLink = QuestieLink:GetQuestLinkStringById(questId);
        local itemLink = select(2, GetItemInfo(itemId))
        local message = l10n("Picked up %s which starts %s!", itemLink, questLink)

        local localMessage
        if Questie.db.profile.questAnnounceLocally == true then
            localMessage = l10n("Picked up %s which starts %s!", itemLink, QuestieLink:GetQuestHyperLink(questId))
        end

        _QuestieAnnounce:AnnounceToChannel(message, localMessage)
        return true
    else
        return false
    end
end

---@param questId QuestId
---@param itemId ItemId
function _QuestieAnnounce:AnnounceSelf(questId, itemId)
    local questHyperLink = QuestieLink:GetQuestHyperLink(questId);
    local itemLink = select(2, GetItemInfo(itemId));

    Questie:Print(l10n("You picked up %s which starts %s!", itemLink, questHyperLink));
end

---@return boolean
local function _ShouldAnnounceToGroup()
    local channel = Questie.db.profile.questAnnounceChannel
    if channel == "both" then
        return IsInRaid() or IsInGroup()
    elseif channel == "raid" then
        return IsInRaid()
    elseif channel == "party" then
        return IsInGroup() and not IsInRaid()
    else
        return false
    end
end

---@return boolean
function _QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()
    if Questie.db.profile.questAnnounceLocally == true then
        return true -- we always want to print if this option is enabled
    end
    return _ShouldAnnounceToGroup()
end

function _QuestieAnnounce.GetChatMessageChannel()
    if IsInRaid() then
        return "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    else
        return "PARTY"
    end
end

---@param message string
---@param localMessage? string
function _QuestieAnnounce:AnnounceToChannel(message, localMessage)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAnnounce] raw msg: ", message)
    if (not message) or alreadySentBandaid[message] or Questie.db.profile.questieShutUp then
        return
    end

    alreadySentBandaid[message] = true

    if Questie.db.profile.questAnnounceLocally == true then
        Questie:Print(localMessage)
    end

    if _ShouldAnnounceToGroup() then
        SendChatMessage(_GetAnnounceMarker() .. message, _QuestieAnnounce.GetChatMessageChannel())
    end
end

local playerNameCache
---@return string
local function _GetPlayerName()
    playerNameCache = UnitName("player")
    return playerNameCache
end

---@param text string
---@param notPlayerName string
---@param playerName string
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

---@param questId QuestId
function QuestieAnnounce:AcceptedQuest(questId)
    if (_QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()) and Questie.db.profile.questAnnounceAccepted then
        local questLink = QuestieLink:GetQuestLinkStringById(questId)
        local message = l10n("Quest %s: %s", l10n('Accepted'), questLink or "no quest name")

        local localMessage
        if Questie.db.profile.questAnnounceLocally == true then
            localMessage = l10n("Quest %s: %s", l10n('Accepted'), QuestieLink:GetQuestHyperLink(questId) or "no quest name")
        end

        _QuestieAnnounce:AnnounceToChannel(message, localMessage)
    end
end

---@param questId QuestId
function QuestieAnnounce:AbandonedQuest(questId)
    if (_QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()) and Questie.db.profile.questAnnounceAbandoned then
        local questLink = QuestieLink:GetQuestLinkStringById(questId)
        local message = l10n("Quest %s: %s", l10n('Abandoned'), questLink or "no quest name")

        local localMessage
        if Questie.db.profile.questAnnounceLocally == true then
            localMessage = l10n("Quest %s: %s", l10n('Abandoned'), QuestieLink:GetQuestHyperLink(questId) or "no quest name")
        end

        _QuestieAnnounce:AnnounceToChannel(message, localMessage)
    end
end

---@param questId QuestId
function QuestieAnnounce:CompletedQuest(questId)
    if (_QuestieAnnounce:AnnounceEnabledAndPlayerInChannel()) and Questie.db.profile.questAnnounceCompleted then
        local questLink = QuestieLink:GetQuestLinkStringById(questId)
        local message = l10n("Quest %s: %s", l10n('Completed'), questLink or "no quest name")

        local localMessage
        if Questie.db.profile.questAnnounceLocally == true then
            localMessage = l10n("Quest %s: %s", l10n('Completed'), QuestieLink:GetQuestHyperLink(questId) or "no quest name")
        end

        _QuestieAnnounce:AnnounceToChannel(message, localMessage)
    end
end

---@param questId QuestId
---@param breadcrumbQuestId QuestId
function QuestieAnnounce.IncompleteBreadcrumbQuest(questId, breadcrumbQuestId)
    local questLink = QuestieLink:GetQuestHyperLink(questId)
    local breadcrumbQuestLink = QuestieLink:GetQuestHyperLink(breadcrumbQuestId)

    local message = l10n("You have accepted %s without completing its breadcrumb quest %s", questLink, breadcrumbQuestLink)
    Questie:Print(message)
end

return QuestieAnnounce
