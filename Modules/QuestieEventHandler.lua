--- COMPATIBILITY ---
local GetNumQuestLogEntries = GetNumQuestLogEntries or C_QuestLog.GetNumQuestLogEntries
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

--- GLOBAL ---
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
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieHash
local QuestieHash = QuestieLoader:ImportModule("QuestieHash")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type Migration
local Migration = QuestieLoader:ImportModule("Migration")
---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")
---@type Cleanup
local QuestieCleanup = QuestieLoader:ImportModule("Cleanup")
---@type DBCompiler
local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

--- LOCAL ---
--False -> true -> nil
local didPlayerEnterWorld = false
local hasFirstQLU = false
local shouldRunQLU = false

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local continueInit


function QuestieEventHandler:RegisterAllEvents(callback)

    local savedVarsTimer
    Questie:RegisterEvent("PLAYER_LOGIN", function()

        local maxTickerRuns = 50 -- 50 * 0.1 seconds = 5 seconds
        local tickCounter = 0

        savedVarsTimer = C_Timer.NewTicker(0.1, function()
            tickCounter = tickCounter + 1
            if (not QuestieConfig) or (not QuestieConfigCharacter) then
                -- The Saved Variables are not loaded yet
                if tickCounter == (maxTickerRuns - 1) then
                    -- The time is over, must be a fresh install
                    _EventHandler:PlayerLogin()
                end
                return
            end

            savedVarsTimer:Cancel()
            _EventHandler:PlayerLogin()
        end, maxTickerRuns)
    end)
    
    continueInit = function()
        Questie:RegisterEvent("PLAYER_LEVEL_UP", _EventHandler.PlayerLevelUp)
        Questie:RegisterEvent("PLAYER_REGEN_DISABLED", _EventHandler.PlayerRegenDisabled)
        Questie:RegisterEvent("PLAYER_REGEN_ENABLED", _EventHandler.PlayerRegenEnabled)

        -- Miscellaneous Events
        Questie:RegisterEvent("MAP_EXPLORATION_UPDATED", _EventHandler.MapExplorationUpdated)
        Questie:RegisterEvent("MODIFIER_STATE_CHANGED", _EventHandler.ModifierStateChanged)
        -- Events to update a players professions and reputations
        Questie:RegisterEvent("CHAT_MSG_SKILL", _EventHandler.ChatMsgSkill)
        Questie:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", _EventHandler.ChatMsgCompatFactionChange)

        -- Quest Events
        Questie:RegisterEvent("QUEST_ACCEPTED", _EventHandler.QuestAccepted)
        Questie:RegisterEvent("UNIT_QUEST_LOG_CHANGED", _EventHandler.UnitQuestLogChanged)
        Questie:RegisterEvent("QUEST_TURNED_IN", _EventHandler.QuestTurnedIn)
        Questie:RegisterEvent("QUEST_REMOVED", _EventHandler.QuestRemoved)
        Questie:RegisterEvent("QUEST_FINISHED", _EventHandler.QuestFinished)
        -- Use bucket for QUEST_LOG_UPDATE to let information propagate through to the blizzard API
        -- Might be able to change this to 0.5 seconds instead, further testing needed.
        Questie:RegisterBucketEvent("QUEST_LOG_UPDATE", 1, _EventHandler.QuestLogUpdate)
        Questie:RegisterEvent("QUEST_DETAIL", QuestieAuto.QUEST_DETAIL) -- When the quest is presented!
        Questie:RegisterEvent("QUEST_PROGRESS", QuestieAuto.QUEST_PROGRESS)
        Questie:RegisterEvent("GOSSIP_SHOW", QuestieAuto.GOSSIP_SHOW)
        Questie:RegisterEvent("QUEST_GREETING", QuestieAuto.QUEST_GREETING) -- The window when multiple quest from a NPC
        Questie:RegisterEvent("QUEST_ACCEPT_CONFIRM", QuestieAuto.QUEST_ACCEPT_CONFIRM) -- If an escort quest is taken by people close by
        Questie:RegisterEvent("GOSSIP_CLOSED", QuestieAuto.GOSSIP_CLOSED) -- Called twice when the stopping to talk to an NPC
        Questie:RegisterEvent("QUEST_COMPLETE", QuestieAuto.QUEST_COMPLETE) -- When complete window shows

        -- Questie Comms Events

        -- Party join event for QuestieComms, Use bucket to hinder this from spamming (Ex someone using a raid invite addon etc)
        Questie:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, _EventHandler.GroupRosterUpdate)
        Questie:RegisterEvent("GROUP_JOINED", _EventHandler.GroupJoined) -- This is not local because QuestieComms needs to call it
        Questie:RegisterEvent("GROUP_LEFT", _EventHandler.GroupLeft)

        -- Nameplate / Target Frame Objective Events
        Questie:RegisterEvent("NAME_PLATE_UNIT_ADDED", QuestieNameplate.NameplateCreated)
        Questie:RegisterEvent("NAME_PLATE_UNIT_REMOVED", QuestieNameplate.NameplateDestroyed)
        Questie:RegisterEvent("PLAYER_TARGET_CHANGED", QuestieNameplate.DrawTargetFrame)

        -- dropdown fix
        Questie:RegisterEvent("CURSOR_UPDATE", function() pcall(LibDropDown.CloseDropDownMenus) end)

        -- quest announce
        Questie:RegisterEvent("CHAT_MSG_LOOT", QuestieAnnounce.ItemLooted)

        -- since icon updates are disabled in instances, we need to reset on P_E_W
        Questie:RegisterEvent("PLAYER_ENTERING_WORLD", function()
            if Questie.started then
                QuestieMap:InitializeQueue()
                if not IsInInstance() then
                    QuestieQuest:SmoothReset()
                end
            end
        end)
        callback()
    end

end


local function _Hack_prime_log() -- this seems to make it update the data much quicker
    for i=1, GetNumQuestLogEntries() do
        GetQuestLogTitle(i)
        QuestieQuest:GetRawLeaderBoardDetails(i)
    end
end

function _EventHandler:PlayerLogin()

    Questie.db = LibStub("AceDB-3.0"):New("QuestieConfig", QuestieOptionsDefaults:Load(), true)

    QuestieFramePool:SetIcons()

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        l10n:SetUILocale(Questie.db.global.questieLocale);
    else
        l10n:SetUILocale(GetLocale());
    end

    Questie:Debug(DEBUG_CRITICAL, "[Questie:OnInitialize] Questie addon loaded")
    ZoneDB:Initialize()

    Migration:Migrate()

    local function stage1()
        QuestieDB:Initialize()
        QuestieLib:CacheAllItemNames()

        -- if compiled db exists and is up to date
            QuestieCleanup:Run()
        -- end
    end

    local function stage2()
        -- We want the framerate to be HIGH!!!
        continueInit()
        QuestieMap:InitializeQueue()
        _Hack_prime_log()
        QuestiePlayer:Initialize()
        l10n:PostBoot()
        QuestieJourney:Initialize()
        QuestieQuest:Initialize()
        QuestieQuest:GetAllQuestIdsNoObjectives()
        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
        QuestieNameplate:Initialize()
        QuestieMenu:PopulateTownsfolkPostBoot()
        Questie:Debug(DEBUG_ELEVATED, "PLAYER_ENTERED_WORLD")
        didPlayerEnterWorld = true
        -- manually fire QLU since enter has been delayed past the first QLU
        if hasFirstQLU then
            _EventHandler:QuestLogUpdate()
        end
        -- Initialize the tracker
        QuestieTracker:Initialize()

        local dateToday = date("%y-%m-%d")

        if Questie.db.char.showAQWarEffortQuests and (Questie.db.char.aqWarningPrintDate == nil or Questie.db.char.aqWarningPrintDate < dateToday) then
            Questie.db.char.aqWarningPrintDate = dateToday
            C_Timer.After(2, function()
                print("|cffff0000-----------------------------|r")
                Questie:Print("|cffff0000The AQ War Effort quests are shown for you. If your server is done you can hide those quests in the General settings of Questie!|r");
                print("|cffff0000-----------------------------|r")
            end)
        end

        QuestieMenu:OnLogin()

        if Questie.db.global.debugEnabled then
            QuestieLoader:PopulateGlobals()
        end

        Questie.started = true
    end

    if QuestieLib:GetAddonVersionString() ~= Questie.db.global.dbCompiledOnVersion or (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale()) ~= Questie.db.global.dbCompiledLang then
        Questie.db.global.dbIsCompiled = nil -- we need to recompile
    end

    if Questie.db.global.dbIsCompiled and Questie.db.global.factionSpecificTownsfolk then -- todo: check for updates or language change and recompile

        if not Questie.db.char.townsfolk then
            QuestieMenu:BuildCharacterTownsfolk()
        end

        QuestieCorrections:MinimalInit()
        C_Timer.After(1, stage1)
        C_Timer.After(4, stage2)
    else
        -- reset townsfolk on all characters before compile
        Questie.db.char.townsfolk = {}

        --Questie.minimapConfigIcon:Hide("Questie") -- prevent opening journey / settings while compiling
        local callTable = {
            [1] = function()
                print("\124cFFAAEEFF"..l10n("Questie DB has updated!").. "\124r\124cFFFF6F22 " .. l10n("Data is being processed, this may take a few moments and cause some lag..."))
                -- give it an extra second, this runs right at player_logged_in and we don't want to lag users too much
            end,
            [2] = function()
                print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")
                QuestieDB.npcData = loadstring(QuestieDB.npcData)
                QuestieDB.npcDataTBC = QuestieDB.npcDataTBC and loadstring(QuestieDB.npcDataTBC) or nil
            end,
            [3] = function() -- secondary function to avoid lag spikes
                QuestieDB.npcData = QuestieDB.npcData()
                QuestieDB.npcDataTBC = QuestieDB.npcDataTBC and QuestieDB.npcDataTBC() or nil
            end,
            [4] = function()
                QuestieDB.objectData = loadstring(QuestieDB.objectData)
                QuestieDB.objectDataTBC = QuestieDB.objectDataTBC and loadstring(QuestieDB.objectDataTBC) or nil
            end,
            [5] = function()
                QuestieDB.objectData = QuestieDB.objectData()
                QuestieDB.objectDataTBC = QuestieDB.objectDataTBC and QuestieDB.objectDataTBC() or nil
            end,
            [6] = function()
                QuestieDB.questData = loadstring(QuestieDB.questData)
                QuestieDB.questDataTBC = QuestieDB.questDataTBC and loadstring(QuestieDB.questDataTBC) or nil
            end,
            [7] = function()
                QuestieDB.questData = QuestieDB.questData()
                QuestieDB.questDataTBC = QuestieDB.questDataTBC and QuestieDB.questDataTBC() or nil
            end,
            [8] = function()
                QuestieDB.itemData = loadstring(QuestieDB.itemData)
                QuestieDB.itemDataTBC = QuestieDB.itemDataTBC and loadstring(QuestieDB.itemDataTBC) or nil
            end,
            [9] = function()
                QuestieDB.itemData = QuestieDB.itemData()
                QuestieDB.itemDataTBC = QuestieDB.itemDataTBC and QuestieDB.itemDataTBC() or nil
            end,
            [10] = function()
                print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

                if QuestieDB.questDataTBC then
                    -- combine tbc and classic db where relevant
                    QuestieDB.questData = QuestieDB.questDataTBC
                    QuestieDB.objectData = QuestieDB.objectDataTBC
                end
            end,
            [11] = function()
                if QuestieDB.questDataTBC then
                    QuestieDB.npcData = QuestieDB.npcDataTBC
                    QuestieDB.itemData = QuestieDB.itemDataTBC
                end
            end,
            [12] = function()
                QuestieCorrections:Initialize()
                QuestieMenu:PopulateTownsfolk()
            end,
            [13] = function()
                print("\124cFF4DDBFF [3/7] " .. l10n("Initializing locale") .. "...")
                l10n:Initialize()
            end,
            [14] = function()
                QuestieDB.private:DeleteGatheringNodes()
                QuestieCorrections:PreCompile(function()
                    QuestieDBCompiler:Compile(function()
                        stage1()
                        QuestieMenu:BuildCharacterTownsfolk()
                        QuestieMenu:PopulateTownsfolkPostBoot()
                        stage2()

                        if not Questie.db.global.hasSeenBetaMessage then
                            Questie.db.global.hasSeenBetaMessage = true
                            print("\124cFFFFFF00" ..l10n("[Questie] With the move to Burning Crusade, Questie is undergoing rapid development, as such you may encounter bugs. Please keep Questie up to date for the best experience! We will also be releasing a large update some time after TBC launch, with many improvements and new features."))
                        end

                        --Questie.minimapConfigIcon:Show("Questie")
                    end)
                end)
            end
        }
        local callIndex = 1
        C_Timer.NewTicker(0.5, function() 
            callTable[callIndex]()
            callIndex = callIndex + 1
        end, #callTable)
    end
end


--Fires when a quest is accepted in anyway.
function _EventHandler:QuestAccepted(questLogIndex, questId)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_ACCEPTED", "QLogIndex: "..questLogIndex,  "QuestId: "..questId)
    --Try and cache all the potential items required for the quest.
    QuestieLib:CacheItemNames(questId)
    _Hack_prime_log()
    local timer
    timer = C_Timer.NewTicker(0.5, function()
        if(QuestieLib:IsResponseCorrect(questId)) then
            QuestieQuest:AcceptQuest(questId)
            QuestieJourney:AcceptQuest(questId)
            timer:Cancel()
            Questie:Debug(DEBUG_DEVELOP, "Accept seems correct, cancel timer")
        else
            Questie:Debug(DEBUG_CRITICAL, "Response is wrong for quest, waiting with timer")
        end
    end)

end

--- Fires on MAP_EXPLORATION_UPDATED.
function _EventHandler:MapExplorationUpdated()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] MAP_EXPLORATION_UPDATED")
    if Questie.db.char.hideUnexploredMapIcons then
        QuestieMap.utils:MapExplorationUpdate()
    end
end

-- Needed to distinguish finished quests from abandoned quests
local questTurnedInEventReceived = false

--- Fires when a quest is removed from the questlog, this includes turning it in
--- and abandoning it.
---@param questId QuestId
function _EventHandler:QuestRemoved(questId)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_REMOVED", questId)
    _Hack_prime_log()
    if questTurnedInEventReceived == questId then
        questTurnedInEventReceived = false
        shouldRunQLU = false
        _EventHandler:CompleteQuest(questId)
        --Broadcast our removal!
        Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questId)
        return
    end
    QuestieQuest:AbandonedQuest(questId)
    QuestieJourney:AbandonQuest(questId)
    shouldRunQLU = false

    --Broadcast our removal!
    Questie:SendMessage("QC_ID_BROADCAST_QUEST_REMOVE", questId)
end

--- Helper function to remove quests correctly
---@param questId QuestId
---@param count number @The amount of calls already made in recursion
function _EventHandler:CompleteQuest(questId, count)
    if(not count) then
        count = 1
    end
    ---@type Quest
    local quest = QuestieDB:GetQuest(questId)
    if not quest then
        return
    end
    if(IsQuestFlaggedCompleted(questId) or quest.IsRepeatable or count > 50) then
        QuestieQuest:CompleteQuest(quest)
        QuestieJourney:CompleteQuest(questId)
    else
        Questie:Debug(DEBUG_INFO, "[QuestieEventHandler]", questId, ":Quest not complete starting timer! IsQuestFlaggedCompleted", IsQuestFlaggedCompleted(questId), "Repeatable:", quest.IsRepeatable, "Count:", count)
        C_Timer.After(0.1, function()
            _EventHandler:CompleteQuest(questId, count + 1)
        end)
    end
end

--- Fires when a quest is turned in, but before it is remove from the quest log.
--- We need to save the ID of the finished quest to check it in QR event.
---@param questId QuestId
---@param xpReward number
---@param moneyReward number
function _EventHandler:QuestTurnedIn(questId, xpReward, moneyReward)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_TURNED_IN", questId, xpReward, moneyReward)
    _Hack_prime_log()
    questTurnedInEventReceived = questId

    -- Some repeatable sub quests don't fire a UQLC event when they're completed.
    -- Therefore we have to check here to make sure the next QLU updates the state.
    ---@type Quest
    local quest = QuestieDB:GetQuest(questId)
    if quest and ((quest.parentQuest and quest.IsRepeatable) or quest.Description == nil or table.getn(quest.Description) == 0) then
        Questie:Debug(DEBUG_DEVELOP, "Enabling shouldRunQLU")
        shouldRunQLU = true
    end
end

function _EventHandler:QuestFinished()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_FINISHED")

    C_Timer.After(0.5, function()
        if _EventHandler:AllQuestWindowsClosed() then
            Questie:Debug(DEBUG_DEVELOP, "All quest windows closed! Resetting shouldRunAuto")
            QuestieAuto:ResetModifier()
        end
    end)

    -- Quests which are just turned in don't trigger QLU.
    -- So shouldRunQLU is still active from QUEST_TURNED_IN
    if shouldRunQLU then
        Questie:Debug(DEBUG_DEVELOP, "shouldRunQLU still active")
        if questTurnedInEventReceived then
            Questie:Debug(DEBUG_DEVELOP, "finishedEventReceived is questId")
            local quest = QuestieDB:GetQuest(questTurnedInEventReceived)
            Questie:Debug(DEBUG_DEVELOP, "Completing automatic completion quest")
            QuestieQuest:CompleteQuest(quest)
        else
            Questie:Debug(DEBUG_DEVELOP, "questTurnedInEventReceived is false. Something is off?")
        end
        shouldRunQLU = false
    end
end

--- Fires when the quest log changes. That includes visual changes and
--- client/server communication, so not every event really updates the log data.
function _EventHandler:QuestLogUpdate()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_LOG_UPDATE")
    if didPlayerEnterWorld then
        Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, START.")
        C_Timer.After(1, function ()
            Questie:Debug(DEBUG_DEVELOP, "---> Player entered world, DONE.")
            QuestieQuest:GetAllQuestIds()
            QuestieCombatQueue:Queue(function()
                QuestieTracker:ResetLinesForChange()
                QuestieTracker:Update()
            end)
            _EventHandler:GroupJoined()
        end)
        didPlayerEnterWorld = nil
    end

    -- QR or UQLC events have set the flag, so we need to update Questie state.
    if shouldRunQLU then
        local hashChanged = QuestieHash:CompareQuestHashes()
        QuestieNameplate:UpdateNameplate()
        if hashChanged then
            shouldRunQLU = false
        end
    end
end

--- Fired before data for quest log changes, including other players.
---@param unitTarget string @The unitTarget, e.g. "player"
function _EventHandler:UnitQuestLogChanged(unitTarget)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] UNIT_QUEST_LOG_CHANGED")
    -- If the unitTarget is "player" the changed log is from "our" player and
    -- we need to tell the next QLU event to check the quest log for updated
    -- data.
    if unitTarget == "player" then
        Questie:Debug(DEBUG_DEVELOP, "UNIT_QUEST_LOG_CHANGED: player")
        shouldRunQLU = true
    end
end

--- Fires when the player levels up
---@param level number
function _EventHandler:PlayerLevelUp(level)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_LEVEL_UP", level)

    QuestiePlayer:SetPlayerLevel(level)

    -- deferred update (possible desync fix?)
    C_Timer.After(3, function()
        QuestiePlayer:SetPlayerLevel(level)

        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    end)
    QuestieJourney:PlayerLevelUp(level)
end

--- Fires when a modifier key changed
function _EventHandler:ModifierStateChanged()
    if GameTooltip and GameTooltip:IsShown() and GameTooltip._Rebuild then
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(GameTooltip._owner, "ANCHOR_CURSOR")
        GameTooltip:_Rebuild() -- rebuild the tooltip
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end
    if Questie.db.global.trackerLocked then
        if QuestieTracker.private.baseFrame ~= nil then
            QuestieCombatQueue:Queue(function()
                QuestieTracker.private.baseFrame:Update()
            end)
        end
    end
end

--- Fires when some chat messages about skills are displayed
function _EventHandler:ChatMsgSkill()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_SKILL")
    local isProfUpdate = QuestieProfessions:Update()
    -- This needs to be done to draw new quests that just came available
    if isProfUpdate then
        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    end
end

--- Fires when some chat messages about reputations are displayed
function _EventHandler:ChatMsgCompatFactionChange()
    Questie:Debug(DEBUG_DEVELOP, "CHAT_MSG_COMBAT_FACTION_CHANGE")
    local factionChanged = QuestieReputation:Update(false)
    if factionChanged then
        QuestieCombatQueue:Queue(function()
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)
        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    end
end

local numberOfGroupMembers = -1
function _EventHandler:GroupRosterUpdate()
    local currentMembers = GetNumGroupMembers()
    -- Only want to do logic when number increases, not decreases.
    if numberOfGroupMembers < currentMembers then
        -- Tell comms to send information to members.
        --Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST")
        numberOfGroupMembers = currentMembers
    else
        -- We do however always want the local to be the current number to allow up and down.
        numberOfGroupMembers = currentMembers
    end
end

function _EventHandler:GroupJoined()
    Questie:Debug(DEBUG_DEVELOP, "GROUP_JOINED")
    local checkTimer
    --We want this to be fairly quick.
    checkTimer = C_Timer.NewTicker(0.1, function()
        local partyPending = UnitInParty("player")
        local isInParty = UnitInParty("party1")
        local isInRaid = UnitInRaid("raid1")
        if partyPending then
            if (isInParty or isInRaid) then
                Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "Player joined party/raid, ask for questlogs")
                --Request other players log.
                Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
                checkTimer:Cancel()
            end
        else
            Questie:Debug(DEBUG_DEVELOP, "[QuestieEventHandler]", "Player no longer in a party or pending invite. Cancel timer")
            checkTimer:Cancel()
        end
    end)
end

function _EventHandler:GroupLeft()
    --Resets both QuestieComms.remoteQuestLog and QuestieComms.data
    QuestieComms:ResetAll()
end

local previousTrackerState

function _EventHandler:PlayerRegenDisabled()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_DISABLED")
    if Questie.db.global.hideTrackerInCombat then
        previousTrackerState = Questie.db.char.isTrackerExpanded
        QuestieTracker:Collapse()
    end
    if InCombatLockdown() then
        if QuestieConfigFrame:IsShown() then
            QuestieOptions:HideFrame()
        end
    end
end

function _EventHandler:PlayerRegenEnabled()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] PLAYER_REGEN_ENABLED")
    if Questie.db.global.hideTrackerInCombat and (previousTrackerState == true) then
        QuestieTracker:Expand()
    end
end

function _EventHandler:AllQuestWindowsClosed()
    if GossipFrame and (not GossipFrame:IsVisible())
            and GossipFrameGreetingPanel and (not GossipFrameGreetingPanel:IsVisible())
            and QuestFrameGreetingPanel and (not QuestFrameGreetingPanel:IsVisible())
            and QuestFrameDetailPanel and (not QuestFrameDetailPanel:IsVisible())
            and QuestFrameProgressPanel and (not QuestFrameProgressPanel:IsVisible())
            and QuestFrameRewardPanel and (not QuestFrameRewardPanel:IsVisible()) then
        return true
    end
    return false
end
