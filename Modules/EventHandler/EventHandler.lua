---@class EventHandler
local EventHandler = QuestieLoader:CreateModule("EventHandler")
local _EventHandler = {}

-------------------------
--Import modules.
-------------------------
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
---@type AchievementEventHandler
local AchievementEventHandler = QuestieLoader:ImportModule("AchievementEventHandler")
---@type GroupEventHandler
local GroupEventHandler = QuestieLoader:ImportModule("GroupEventHandler")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
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
---@type AutoQuesting
local AutoQuesting = QuestieLoader:ImportModule("AutoQuesting")
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
---@type QuestieDebugOffer
local QuestieDebugOffer = QuestieLoader:ImportModule("QuestieDebugOffer")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type WatchFrameHook
local WatchFrameHook = QuestieLoader:ImportModule("WatchFrameHook")
---@type AutoCompleteFrame
local AutoCompleteFrame = QuestieLoader:ImportModule("AutoCompleteFrame")

local questAcceptedMessage = string.gsub(ERR_QUEST_ACCEPTED_S, "(%%s)", "(.+)")
local questCompletedMessage = string.gsub(ERR_QUEST_COMPLETE_S, "(%%s)", "(.+)")

local trackerMinimizedByDungeon = false

--* Calculated in _EventHandler:PlayerLogin()
---en/br/es/fr/gb/it/mx: "You are now %s with %s." (e.g. "You are now Honored with Stormwind."), all other languages are very alike
local FACTION_STANDING_CHANGED_PATTERN

function EventHandler:RegisterEarlyEvents()
    Questie:RegisterEvent("PLAYER_LOGIN", _EventHandler.PlayerLogin)
end

function EventHandler:RegisterLateEvents()
    Questie:RegisterEvent("PLAYER_LEVEL_UP", _EventHandler.PlayerLevelUp)
    Questie:RegisterEvent("PLAYER_REGEN_DISABLED", _EventHandler.PlayerRegenDisabled)
    Questie:RegisterEvent("PLAYER_REGEN_ENABLED", _EventHandler.PlayerRegenEnabled)

    -- Miscellaneous Events
    Questie:RegisterEvent("MAP_EXPLORATION_UPDATED", _EventHandler.MapExplorationUpdated)
    Questie:RegisterEvent("MODIFIER_STATE_CHANGED", function(...)
        _EventHandler.ModifierStateChanged(...)
    end)
    Questie:RegisterEvent("PLAYER_ALIVE", function(...)
        QuestieTracker:UpdateDurabilityFrame()
        QuestieTracker:UpdateVoiceOverFrame()
    end)

    -- Events to update a players professions and reputations
    Questie:RegisterBucketEvent("CHAT_MSG_SKILL", 2, _EventHandler.ChatMsgSkill)
    Questie:RegisterBucketEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", 2, function()
        QuestEventHandler.ReputationChange()
        _EventHandler:ChatMsgCompatFactionChange()
    end)
    Questie:RegisterEvent("CHAT_MSG_SYSTEM", _EventHandler.ChatMsgSystem)

    -- Spell objectives
    Questie:RegisterEvent("NEW_RECIPE_LEARNED", function() -- Needed for some spells that don't necessarily appear in the spellbook, but are definitely spells
        Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] NEW_RECIPE_LEARNED")
        QuestEventHandler.NewRecipeLearned()
        AvailableQuests.CalculateAndDrawAll()
    end)

    -- UI Quest Events
    Questie:RegisterEvent("UI_INFO_MESSAGE", _EventHandler.UiInfoMessage)
    Questie:RegisterEvent("QUEST_FINISHED", function()
        AutoQuesting.OnQuestFinished()
        if Expansions.Current >= Expansions.Cata then
            -- There might be other quest events which need to finish first, so we wait a bit before checking.
            -- This is easier, than actually figuring out which events are fired in which order for this logic.
            C_Timer.After(0.5, function()
                AutoCompleteFrame.CheckAutoCompleteQuests()
            end)
        end
    end)
    Questie:RegisterEvent("QUEST_ACCEPTED", function(_, questLogIndex, questId)
        QuestEventHandler.QuestAccepted(questLogIndex, questId)
    end)
    Questie:RegisterEvent("QUEST_DETAIL", function() -- When the quest is presented!
        AutoQuesting.OnQuestDetail()
        if Questie.IsSoD or Questie.db.profile.enableBugHintsForAllFlavors then
            QuestieDebugOffer.QuestDialog()
        end
    end)
    Questie:RegisterEvent("QUEST_PROGRESS", AutoQuesting.OnQuestProgress)
    Questie:RegisterEvent("GOSSIP_SHOW", function()
        AutoQuesting.OnGossipShow()
        QuestgiverFrame.GossipMark()
    end)
    Questie:RegisterEvent("QUEST_GREETING", function()
        AutoQuesting.OnQuestGreeting()
        QuestgiverFrame.GreetingMark()
    end)
    Questie:RegisterEvent("QUEST_ACCEPT_CONFIRM", AutoQuesting.OnQuestAcceptConfirm) -- If an escort quest is taken by people close by
    Questie:RegisterEvent("GOSSIP_CLOSED", AutoQuesting.OnGossipClosed)              -- Called twice when the stopping to talk to an NPC
    Questie:RegisterEvent("QUEST_COMPLETE", function()                               -- When complete window shows
        AutoQuesting.OnQuestComplete()
        if Questie.IsSoD or Questie.db.profile.enableBugHintsForAllFlavors then
            QuestieDebugOffer.QuestDialog()
        end
    end)
    Questie:RegisterEvent("QUEST_REMOVED", function(_, questId) QuestEventHandler.QuestRemoved(questId) end)
    Questie:RegisterEvent("QUEST_TURNED_IN", function(_, questId) QuestEventHandler.QuestTurnedIn(questId) end)
    Questie:RegisterEvent("QUEST_LOG_UPDATE", QuestEventHandler.QuestLogUpdate)
    Questie:RegisterEvent("QUEST_WATCH_UPDATE", function(_, questId) QuestEventHandler.QuestWatchUpdate(questId) end)
    Questie:RegisterEvent("QUEST_AUTOCOMPLETE", function(_, questId) QuestEventHandler.QuestAutoComplete(questId) end)
    Questie:RegisterEvent("UNIT_QUEST_LOG_CHANGED", function(_, unitTarget) QuestEventHandler.UnitQuestLogChanged(unitTarget) end)
    Questie:RegisterEvent("CURRENCY_DISPLAY_UPDATE", QuestEventHandler.CurrencyDisplayUpdate)
    Questie:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function(_, eventType) QuestEventHandler.PlayerInteractionManagerFrameHide(eventType) end)

    Questie:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ZONE_CHANGED_NEW_AREA")
        -- By my tests it takes a full 6-7 seconds for the world to load. There are a lot of
        -- backend Questie updates that occur when a player zones in/out of an instance. This
        -- is necessary to get everything back into it's "normal" state after all the updates.
        local isInInstance, instanceType = IsInInstance()

        if isInInstance then
            C_Timer.After(8, function()
                Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ZONE_CHANGED_NEW_AREA: Entering Instance")
                if Questie.db.profile.hideTrackerInDungeons then
                    trackerMinimizedByDungeon = true

                    QuestieCombatQueue:Queue(function()
                        QuestieTracker:Collapse()
                    end)
                end
            end)

            -- We only want this to fire outside of an instance if the player isn't dead and we need to reset the Tracker
        elseif (not Questie.db.char.isTrackerExpanded and not UnitIsGhost("player")) and trackerMinimizedByDungeon == true then
            C_Timer.After(8, function()
                Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] ZONE_CHANGED_NEW_AREA: Exiting Instance")
                if Questie.db.profile.hideTrackerInDungeons then
                    trackerMinimizedByDungeon = false

                    QuestieCombatQueue:Queue(function()
                        QuestieTracker:Expand()
                    end)
                end
            end)
        end
    end)

    -- UI Achievement Events
    if Expansions.Current >= Expansions.Wotlk and Questie.db.profile.trackerEnabled then
        Questie:RegisterEvent("ACHIEVEMENT_EARNED", function(_, achieveId)
            AchievementEventHandler.AchievementEarned(achieveId)
        end)

        Questie:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE", AchievementEventHandler.TrackedAchievementUpdate)
        Questie:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED", function(_, achieveId)
            AchievementEventHandler.TrackedAchievementListChanged(achieveId)
        end)

        -- This fires pretty often, multiple times for a single Achievement change and also for things most likely not related to Achievements at all.
        -- We use a bucket to hinder this from spamming
        Questie:RegisterBucketEvent("CRITERIA_UPDATE", 2, AchievementEventHandler.CriteriaUpdate)

        Questie:RegisterEvent("CHAT_MSG_MONEY", AchievementEventHandler.ChatMsgMoney)
        Questie:RegisterEvent("CHAT_MSG_TEXT_EMOTE", AchievementEventHandler.ChatMsgTextEmote)
        Questie:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", AchievementEventHandler.PlayerEquipmentChanged)
    end

    -- Questie Debug Offer
    if Questie.IsSoD or Questie.db.profile.enableBugHintsForAllFlavors then
        Questie:RegisterEvent("LOOT_OPENED", QuestieDebugOffer.LootWindow)
    end

    if Expansions.Current >= Expansions.Cata and Questie.db.profile.trackerEnabled then
       -- This is fired pretty often when an auto complete quest frame is showing. We want the default one to be hidden though.
        Questie:RegisterEvent("UPDATE_ALL_UI_WIDGETS", function()
            QuestieCombatQueue:Queue(WatchFrameHook.Hide)
        end)
    end

    -- Questie Comms Events

    -- Party join event for QuestieComms, Use bucket to hinder this from spamming (Ex someone using a raid invite addon etc)
    Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, GroupEventHandler.GroupRosterUpdate)
    Questie:RegisterEvent("GROUP_JOINED", GroupEventHandler.GroupJoined)
    Questie:RegisterEvent("GROUP_LEFT", GroupEventHandler.GroupLeft)

    -- Nameplate / Target Frame Objective Events
    Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated)
    Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed)
    Questie:RegisterEvent("PLAYER_TARGET_CHANGED", function(...)
        QuestieNameplate:DrawTargetFrame()
        --if Questie.IsSoD then QuestieDebugOffer.NPCTarget() end;
    end)

    -- quest announce
    Questie:RegisterEvent("CHAT_MSG_LOOT", function(_, text, notPlayerName, _, _, playerName)
        QuestieTracker.QuestItemLooted(_, text)
        QuestieAnnounce.ItemLooted(_, text, notPlayerName, _, _, playerName)
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
            deDE = "%%%d$s",     --deDE  "Die Fraktion '%2$s' ist Euch gegenüber jetzt '%1$s' eingestellt." or "Die Fraktion %2$s ist Euch gegenüber jetzt '%1$s' eingestellt."
            zhCNkoKR = "%%%d$s", --zhCN(zhTW?)/koKR "你在%2$s中的声望达到了%1$s。" / "%2$s에 대해 %1$s 평판이 되었습니다."
            enPlus = "%%s",      -- European languages except (deDE)
        }

        if locale == "zhCN" or locale == "koKR" then                                                                                       --CN/KR "你在%2$s中的声望达到了%1$s。" / "%2$s에 대해 %1$s 평판이 되었습니다."
            FACTION_STANDING_CHANGED_PATTERN, replaceCount = string.gsub(FACTION_STANDING_CHANGED_LOCAL, replaceTypes.zhCNkoKR, replaceString)
        elseif locale == "deDE" then                                                                                                       --DE  "Die Fraktion '%2$s' ist Euch gegenüber jetzt '%1$s' eingestellt." or "Die Fraktion %2$s ist Euch gegenüber jetzt '%1$s' eingestellt."
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
    if Questie.db.profile.hideUnexploredMapIcons then
        QuestieMap.utils:MapExplorationUpdate()
    end

    -- Exploratory based Achievement updates
    if Expansions.Current >= Expansions.Wotlk then
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
    QuestieJourney:PlayerLevelUp(level)

    AvailableQuests.ResetLevelRequirementCache()
    AvailableQuests.CalculateAndDrawAll()
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
            if GameTooltip and GameTooltip:IsShown() and GameTooltip._Rebuild then
                GameTooltip:Hide()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR")
                GameTooltip:_Rebuild() -- rebuild the tooltip
                GameTooltip:SetFrameStrata("TOOLTIP")
                GameTooltip:Show()
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

    if Questie.db.profile.trackerLocked then
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
        AvailableQuests.CalculateAndDrawAll()
    end

    -- Skill based Achievement updates
    if Expansions.Current >= Expansions.Wotlk then
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

        AvailableQuests.CalculateAndDrawAll()
    end
end

local trackerHiddenByCombat, optionsHiddenByCombat, journeyHiddenByCombat = false, false, false
function _EventHandler:PlayerRegenDisabled()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_DISABLED")

    -- Let's make sure the frame exists - might be nil if player is in combat upon login
    if QuestieTracker then
        if Questie.db.profile.hideTrackerInCombat and Questie.db.char.isTrackerExpanded and (not trackerHiddenByCombat) then
            trackerHiddenByCombat = true
            QuestieTracker:Collapse()
        end

        if IsInInstance() and Questie.db.profile.hideTrackerInDungeons then
            QuestieTracker:Collapse()
        end
    end

    -- Let's make sure the frame exists - might be nil if player is in combat upon login
    if QuestieConfigFrame then
        if QuestieConfigFrame:IsShown() then
            optionsHiddenByCombat = true
            QuestieConfigFrame:Hide()
        end
    end

    -- Let's make sure the frame exists - might be nil if player is in combat upon login
    if QuestieJourney then
        if QuestieJourney:IsShown() then
            journeyHiddenByCombat = true
            QuestieJourney:ToggleJourneyWindow()
        end
    end
end

function _EventHandler:PlayerRegenEnabled()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_ENABLED")
    if Questie.db.profile.hideTrackerInCombat and trackerHiddenByCombat then
        if (not Questie.db.profile.hideTrackerInDungeons) or (not IsInInstance()) then
            trackerHiddenByCombat = false
            QuestieTracker:Expand()
        end

        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end

    if optionsHiddenByCombat then
        QuestieConfigFrame:Show()
        optionsHiddenByCombat = false
    end

    if journeyHiddenByCombat then
        QuestieJourney:ToggleJourneyWindow()
        journeyHiddenByCombat = false
    end
end
