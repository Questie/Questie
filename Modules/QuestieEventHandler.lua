---@class QuestieEventHandler
local QuestieEventHandler = QuestieLoader:CreateModule("QuestieEventHandler")
local _EventHandler = {}

-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerQuestFrame
local TrackerQuestFrame = QuestieLoader:ImportModule("TrackerQuestFrame")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieInit
local QuestieInit = QuestieLoader:ImportModule("QuestieInit")
---@type MinimapIcon
local MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
---@type QuestgiverFrame
local QuestgiverFrame = QuestieLoader:ImportModule("QuestgiverFrame")

local questAcceptedMessage = string.gsub(ERR_QUEST_ACCEPTED_S, "(%%s)", "(.+)")
local questCompletedMessage = string.gsub(ERR_QUEST_COMPLETE_S, "(%%s)", "(.+)")

--* Calculated in _EventHandler:PlayerLogin()
---en/br/es/fr/gb/it/mx: "You are now %s with %s." (e.g. "You are now Honored with Stormwind."), all other languages are very alike
local FACTION_STANDING_CHANGED_PATTERN

function QuestieEventHandler:RegisterEarlyEvents()
    Questie:RegisterEvent("PLAYER_LOGIN", _EventHandler.PlayerLogin)
end

function QuestieEventHandler:RegisterLateEvents()
    Questie:RegisterEvent("PLAYER_LEVEL_UP", _EventHandler.PlayerLevelUp)
    Questie:RegisterEvent("PLAYER_REGEN_DISABLED", _EventHandler.PlayerRegenDisabled)
    Questie:RegisterEvent("PLAYER_REGEN_ENABLED", _EventHandler.PlayerRegenEnabled)

    -- Miscellaneous Events
    Questie:RegisterEvent("MAP_EXPLORATION_UPDATED", _EventHandler.MapExplorationUpdated)
    Questie:RegisterEvent("MODIFIER_STATE_CHANGED", function(...)
        _EventHandler.ModifierStateChanged(...)
    end)
    Questie:RegisterEvent("PLAYER_ALIVE", function(...)
        QuestieTracker:CheckDurabilityAlertStatus()
        QuestieTracker:UpdateVoiceOverFrame()
    end)

    -- Events to update a players professions and reputations
    Questie:RegisterBucketEvent("CHAT_MSG_SKILL", 2, _EventHandler.ChatMsgSkill)
    Questie:RegisterBucketEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", 2, _EventHandler.ChatMsgCompatFactionChange)
    Questie:RegisterEvent("CHAT_MSG_SYSTEM", _EventHandler.ChatMsgSystem)

    -- UI Quest Events
    Questie:RegisterEvent("UI_INFO_MESSAGE", _EventHandler.UiInfoMessage)
    Questie:RegisterEvent("QUEST_FINISHED", QuestieAuto.QUEST_FINISHED)
    Questie:RegisterEvent("QUEST_ACCEPTED", QuestieAuto.QUEST_ACCEPTED)
    Questie:RegisterEvent("QUEST_DETAIL", QuestieAuto.QUEST_DETAIL) -- When the quest is presented!
    Questie:RegisterEvent("QUEST_PROGRESS", QuestieAuto.QUEST_PROGRESS)
    Questie:RegisterEvent("GOSSIP_SHOW", function(...)
        QuestieAuto.GOSSIP_SHOW(...)
        QuestgiverFrame.GossipMark(...)
    end)
    Questie:RegisterEvent("QUEST_GREETING", function(...)
        QuestieAuto.QUEST_GREETING(...)
        QuestgiverFrame.GreetingMark(...)
    end)
    Questie:RegisterEvent("QUEST_ACCEPT_CONFIRM", QuestieAuto.QUEST_ACCEPT_CONFIRM) -- If an escort quest is taken by people close by
    Questie:RegisterEvent("GOSSIP_CLOSED", QuestieAuto.GOSSIP_CLOSED)               -- Called twice when the stopping to talk to an NPC
    Questie:RegisterEvent("QUEST_COMPLETE", QuestieAuto.QUEST_COMPLETE)             -- When complete window shows

    -- UI Achievement Events
    if Questie.IsWotlk then
        -- Earned Achievement update
        Questie:RegisterEvent("ACHIEVEMENT_EARNED", function(index, achieveId, alreadyEarned)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ACHIEVEMENT_EARNED")
            QuestieTracker:UntrackAchieveId(achieveId)
            QuestieTracker:UpdateAchieveTrackerCache(achieveId)

            if (not AchievementFrame) then
                AchievementFrame_LoadUI()
            end

            AchievementFrameAchievements_ForceUpdate()

            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)

        -- Track/Untrack Achievement updates
        Questie:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED", function(index, achieveId, added)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] TRACKED_ACHIEVEMENT_LIST_CHANGED")
            QuestieTracker:UpdateAchieveTrackerCache(achieveId)
        end)

        -- Timed based Achievement updates
        -- TODO: Fired when a timed event for an achievement begins or ends. The achievement does not have to be actively tracked for this to trigger.
        Questie:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE", function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] TRACKED_ACHIEVEMENT_UPDATE")
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)

        --[[ TODO: This fires FAR too often. Until Blizzard figures out a way to allow us to trigger achievement updates this needs to remain disabled for now.
        Questie:RegisterEvent("CRITERIA_UPDATE", function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CRITERIA_UPDATE")
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)
        --]]
        -- Money based Achievement updates
        Questie:RegisterEvent("CHAT_MSG_MONEY", function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_MONEY")
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)

        -- Emote based Achievement updates
        Questie:RegisterEvent("CHAT_MSG_TEXT_EMOTE", function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_TEXT_EMOTE")
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)

        -- Player equipment changed based Achievement updates
        Questie:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_EQUIPMENT_CHANGED")
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)
    end

    -- Questie Comms Events

    -- Party join event for QuestieComms, Use bucket to hinder this from spamming (Ex someone using a raid invite addon etc)
    Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, _EventHandler.GroupRosterUpdate)
    Questie:RegisterEvent("GROUP_JOINED", _EventHandler.GroupJoined)
    Questie:RegisterEvent("GROUP_LEFT", _EventHandler.GroupLeft)

    -- Nameplate / Target Frame Objective Events
    Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated)
    Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed)
    Questie:RegisterEvent("PLAYER_TARGET_CHANGED", QuestieNameplate.DrawTargetFrame)

    -- quest announce
    Questie:RegisterEvent("CHAT_MSG_LOOT", function(_, text, notPlayerName, _, _, playerName)
        QuestieTracker.QuestItemLooted(_, text)
        QuestieAnnounce.ItemLooted(_, text, notPlayerName, _, _, playerName)
    end)

    -- since icon updates are disabled in instances, we need to reset on P_E_W
    Questie:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if Questie.started then
            QuestieMap:InitializeQueue()
            local isInInstance, instanceType = IsInInstance()

            if (not isInInstance) or instanceType ~= "raid" then -- only run map updates when not in a raid
                QuestieQuest:SmoothReset()
            end
        end
    end)
end

function _EventHandler:PlayerLogin()
    -- Check config exists
    if not Questie.db or not QuestieConfig then
        -- Did you move Questie.db = LibStub("AceDB-3.0"):New("QuestieConfig",.......) out of Questie:OnInitialize() ?
        Questie:Error("Config DB from saved variables is not loaded and initialized. Please report this issue on Questie github or discord.")
        error("Config DB from saved variables is not loaded and initialized. Please report this issue on Questie github or discord.")
        return
    end

    do
        -- All this information was researched here: https://www.townlong-yak.com/framexml/live/GlobalStrings.lua

        local locale = GetLocale()
        local FACTION_STANDING_CHANGED_LOCAL = FACTION_STANDING_CHANGED or "You are now %s with %s."
        local replaceCount -- Just init it with an impossible value
        local replaceString = ".+"

        --! Has to got from least likely to work to most, otherwise you will get false positives
        local replaceTypes = {
            ruRU = "%(%%%d$s%)", --ruRU "|3-6(%2$s) |3-6(%1$s)." ("Ваша репутация с %2$s теперь %1$s.
            zhTW = "%%s%(%%s%)", --zhTW "你在%2$s中的聲望達到了%1$s。"")
            deDE = "'%%%d$s'",   --deDE  "Die Fraktion '%2$s' ist Euch gegenüber jetzt '%1$s' eingestellt."
            zhCNkoKR = "%%%d$s", --zhCN(zhTW?)/koKR "你在%2$s中的声望达到了%1$s。" / "%2$s에 대해 %1$s 평판이 되었습니다."
            enPlus = "%%s",      -- European languages except (deDE)
        }

        if locale == "zhCN" or locale == "koKR" then                                                                                       --CN/KR "你在%2$s中的声望达到了%1$s。" / "%2$s에 대해 %1$s 평판이 되었습니다."
            FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceTypes.zhCNkoKR, replaceString)
        elseif locale == "deDE" then                                                                                                       --DE  "Die Fraktion '%2$s' ist Euch gegenüber jetzt '%1$s' eingestellt."
            FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceTypes.deDE, replaceString) -- Germans are always special
        elseif locale == "zhTW" then                                                                                                       --TW "你的聲望已達到%s(%s)。", should we remove the parentheses?
            FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceTypes.zhTW, replaceString)
        elseif locale == "ruRU" then                                                                                                       --RU "|3-6(%2$s) |3-6(%1$s).", should we remove the parentheses?
            FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceTypes.ruRU, replaceString)
        else
            FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceTypes.enPlus, replaceString)
        end

        --? A fallback to try everything if the replaceCount is still -1 or 0
        if replaceCount and replaceCount < 1 then
            for _, replaceType in pairs(replaceTypes) do
                FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceType, replaceString)
                if replaceCount > 0 then
                    break
                end
            end
        end

        --? Nothing worked :(
        if replaceCount and replaceCount < 1 then --- Error: Default to match EVERYTHING, because it's better that it works
            FACTION_STANDING_CHANGED_PATTERN = ".+"
            Questie:Error("Something went wrong with the FACTION_STANDING_CHANGED_PATTERN!")
            Questie:Error("FACTION_STANDING_CHANGED is set to " .. tostring(FACTION_STANDING_CHANGED) .. ", please report this on GitHub!")
        end
    end

    -- Start real Questie init
    QuestieInit:Init()
end

--- Fires when a System Message (yellow text) is output to the main chat window
---@param message string The message value from the CHAT_MSG_SYSTEM event
function _EventHandler:ChatMsgSystem(message)
    -- When a new quest is accepted or completed quest is turned in, update the LibDataBroker text with the appropriate message
    if string.find(message, questCompletedMessage) == 1 or string.find(message, questAcceptedMessage) == 1 then
        MinimapIcon:UpdateText(message)
    elseif string.find(message, FACTION_STANDING_CHANGED_PATTERN) then -- When you discover a new faction or increase standing eg. Neutral -> Friendly
        QuestieReputation:Update()
    end
end

--- Fires when a UI Info Message (yellow text) appears near the top of the screen
---@param errorType number The error type value from the UI_INFO_MESSAGE event
---@param message string The message value from the UI_INFO_MESSAGE event
function _EventHandler:UiInfoMessage(errorType, message)
    local messages = {
        ["ERR_QUEST_OBJECTIVE_COMPLETE_S"] = true,
        ["ERR_QUEST_UNKNOWN_COMPLETE"] = true,
        ["ERR_QUEST_ADD_KILL_SII"] = true,
        ["ERR_QUEST_ADD_FOUND_SII"] = true,
        ["ERR_QUEST_ADD_ITEM_SII"] = true,
        ["ERR_QUEST_ADD_PLAYER_KILL_SII "] = true,
        ["ERR_QUEST_FAILED_S"] = true,
    }

    if messages[GetGameMessageInfo(errorType)] then
        MinimapIcon:UpdateText(message)
    end
end

--- Fires on MAP_EXPLORATION_UPDATED.
function _EventHandler:MapExplorationUpdated()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] MAP_EXPLORATION_UPDATED")
    if Questie.db.char.hideUnexploredMapIcons then
        QuestieMap.utils:MapExplorationUpdate()
    end

    -- Exploratory based Achievement updates
    if Questie.IsWotlk then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end
end

--- Fires when the player levels up
---@param level number
function _EventHandler:PlayerLevelUp(level)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_LEVEL_UP", level)

    QuestiePlayer:SetPlayerLevel(level)

    -- deferred update (possible desync fix?)
    C_Timer.After(3, function()
        QuestiePlayer:SetPlayerLevel(level)

        QuestieQuest.CalculateAndDrawAvailableQuestsIterative()
    end)

    QuestieJourney:PlayerLevelUp(level)
end

--- Fires when a modifier key changed
function _EventHandler:ModifierStateChanged(key, down)
    if key == "LSHIFT" or key == "RSHIFT" then
        -- Unless the Shift Key is down, don't run this code. We've recieved reports that our tooltips
        -- are apperearing when using the Shift Modifier for other areas of the UI and other addons.
        -- Since we're hooking into Blizzards GameTooltip, it's possible that certain edge cases would
        -- cause our Tooltips to appear instead and since the mouse isn't over "our" frame, it's not
        -- getting reset properly and getting stuck to the Mouse Cursor.

        -- Questie Map Icons
        if MouseIsOver(WorldMapFrame) and WorldMapFrame:IsShown() or MouseIsOver(Minimap) then
            if down == 1 then
                if GameTooltip and GameTooltip:IsShown() and GameTooltip._Rebuild then
                    GameTooltip:Hide()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR")
                    GameTooltip:_Rebuild() -- rebuild the tooltip
                    GameTooltip:SetFrameStrata("TOOLTIP")
                    GameTooltip:Show()
                end
            else
                if GameTooltip:IsShown() then
                    GameTooltip:Hide()
                    GameTooltip._Rebuild = nil
                end
            end
        end

        -- Questie Tracker Sizer
        if QuestieTracker.started then
            if MouseIsOver(Questie_BaseFrame.sizer) then
                if down == 1 then
                    if GameTooltip and GameTooltip:IsShown() and GameTooltip._SizerToolTip then
                        GameTooltip:Hide()
                        GameTooltip:ClearLines()
                        GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR")
                        GameTooltip._SizerToolTip()
                        GameTooltip:SetFrameStrata("TOOLTIP")
                        GameTooltip:Show()
                    end
                else
                    if GameTooltip:IsShown() then
                        GameTooltip:Hide()
                        GameTooltip._SizerToolTip = nil
                    end
                end
            end
        end
    end

    if QuestieTracker.started then
        -- AI_VoiceOver PlayButtons
        TrackerUtils:ShowVoiceOverPlayButtons()
    end

    if Questie.db.global.trackerLocked then
        if QuestieTracker.started then
            -- This is a safety catch for race conditions to prevent the Tracker Sizer
            -- from becoming stuck to the mouse pointer when the player releases the
            -- CTRL key first before releasing the Left Mouse Button.
            if (key == "LCTRL" or key == "RCTRL") and down == 0 then
                if IsMouseButtonDown("LeftButton") then
                    -- Tracker is being sized
                    if TrackerBaseFrame.isSizing ~= false and TrackerBaseFrame.isMoving ~= true then
                        TrackerBaseFrame.OnResizeStop(self, "LeftButton")
                        return
                    end
                    -- Tracker is being moved
                    if TrackerBaseFrame.isMoving ~= false and TrackerBaseFrame.isSizing ~= true then
                        TrackerBaseFrame.OnDragStop(self, "LeftButton")
                        return
                    end
                end
            end
            QuestieCombatQueue:Queue(function()
                TrackerBaseFrame:Update()
                TrackerQuestFrame:Update()
            end)
        end
    end
end

--- Fires when some chat messages about skills are displayed
function _EventHandler:ChatMsgSkill()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_SKILL")

    -- This needs to be done to draw new quests that just came available
    local isProfUpdate, isNewProfession = QuestieProfessions:Update()
    if isProfUpdate or isNewProfession then
        QuestieQuest.CalculateAndDrawAvailableQuestsIterative()
    end

    -- Skill based Achievement updates
    if Questie.IsWotlk then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end
end

--- Fires when some chat messages about reputations are displayed
function _EventHandler:ChatMsgCompatFactionChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] CHAT_MSG_COMBAT_FACTION_CHANGE")
    local factionChanged, newFaction = QuestieReputation:Update(false)
    if factionChanged or newFaction then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)

        QuestieQuest.CalculateAndDrawAvailableQuestsIterative()
    end
end

function _EventHandler.GroupRosterUpdate()
    local currentMembers = GetNumGroupMembers()
    -- Only want to do logic when number increases, not decreases.
    if QuestiePlayer.numberOfGroupMembers < currentMembers then
        -- Tell comms to send information to members.
        --Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST")
        QuestiePlayer.numberOfGroupMembers = currentMembers
    else
        -- We do however always want the local to be the current number to allow up and down.
        QuestiePlayer.numberOfGroupMembers = currentMembers
    end
end

function _EventHandler:GroupJoined()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] GROUP_JOINED")
    local checkTimer
    --We want this to be fairly quick.
    checkTimer = C_Timer.NewTicker(0.2, function()
        local partyPending = UnitInParty("player")
        local isInParty = UnitInParty("party1")
        local isInRaid = UnitInRaid("raid1")
        if partyPending then
            if (isInParty or isInRaid) then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieEventHandler] Player joined party/raid, ask for questlogs")
                --Request other players log.
                Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
                checkTimer:Cancel()
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieEventHandler] Player no longer in a party or pending invite. Cancel timer")
            checkTimer:Cancel()
        end
    end)
end

function _EventHandler:GroupLeft()
    --Resets both QuestieComms.remoteQuestLog and QuestieComms.data
    QuestieComms:ResetAll()
end

local trackerHiddenByCombat, optionsHiddenByCombat, journeyHiddenByCombat = false, false, false
function _EventHandler:PlayerRegenDisabled()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_DISABLED")
    if Questie.db.global.hideTrackerInCombat and Questie.db.char.isTrackerExpanded and (not trackerHiddenByCombat) then
        trackerHiddenByCombat = true
        QuestieTracker:Collapse()
    end

    if IsInInstance() and Questie.db.global.hideTrackerInDungeons then
        QuestieTracker:Collapse()
    end

    if QuestieConfigFrame:IsShown() then
        optionsHiddenByCombat = true
        QuestieConfigFrame:Hide()
    end

    if QuestieJourney:IsShown() then
        journeyHiddenByCombat = true
        QuestieJourney.ToggleJourneyWindow()
    end
end

function _EventHandler:PlayerRegenEnabled()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_ENABLED")
    if Questie.db.global.hideTrackerInCombat and trackerHiddenByCombat then
        if (not Questie.db.global.hideTrackerInDungeons) or (not IsInInstance()) then
            trackerHiddenByCombat = false
            QuestieTracker:Expand()
        end
    end

    if optionsHiddenByCombat then
        QuestieConfigFrame:Show()
        optionsHiddenByCombat = false
    end

    if journeyHiddenByCombat then
        QuestieJourney.ToggleJourneyWindow()
        journeyHiddenByCombat = false
    end

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end
