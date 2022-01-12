---@class QuestieInit
local QuestieInit = QuestieLoader:CreateModule("QuestieInit")
local _QuestieInit = {}

---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Migration
local Migration = QuestieLoader:ImportModule("Migration")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type Cleanup
local QuestieCleanup = QuestieLoader:ImportModule("Cleanup")
---@type DBCompiler
local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieEventHandler
local QuestieEventHandler = QuestieLoader:ImportModule("QuestieEventHandler")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type HBDHooks
local HBDHooks = QuestieLoader:ImportModule("HBDHooks")
---@type ChatFilter
local ChatFilter = QuestieLoader:ImportModule("ChatFilter")
---@type Hooks
local Hooks = QuestieLoader:ImportModule("Hooks")

local stringSub = string.sub
local GetNumQuestLogEntries, GetQuestLogTitle, GetQuestObjectives = GetNumQuestLogEntries, GetQuestLogTitle, C_QuestLog.GetQuestObjectives

-- 3 * (Max possible number of quests in game quest log)
-- This is a safe value, even smaller would be enough. Too large won't effect performance
local MAX_QUEST_LOG_INDEX = 75

local MAX_INIT_QUEST_LOG_TRIES = 5
local initQuestLogTries = 0
local eventFrame


-- ********************************************************************************
-- Start of QuestieInit.Stages ******************************************************

-- stage worker functions. Most are coroutines.
QuestieInit.Stages = {}

QuestieInit.Stages[1] = function() -- run as a coroutine
    HBDHooks:Init()

    QuestieFramePool:SetIcons()

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        l10n:SetUILocale(Questie.db.global.questieLocale);
    else
        l10n:SetUILocale(GetLocale());
    end

    Questie:Debug(Questie.DEBUG_CRITICAL, "[Questie:OnInitialize] Questie addon loaded")

    coroutine.yield()
    ZoneDB:Initialize()

    coroutine.yield()
    Migration:Migrate()

    QuestieProfessions:Init()

    -- check if the DB needs to be recompiled
    if (not Questie.db.global.dbIsCompiled) or QuestieLib:GetAddonVersionString() ~= Questie.db.global.dbCompiledOnVersion or (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale()) ~= Questie.db.global.dbCompiledLang then
        print("\124cFFAAEEFF"..l10n("Questie DB has updated!").. "\124r\124cFFFF6F22 " .. l10n("Data is being processed, this may take a few moments and cause some lag..."))
        print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

        QuestieInit:LoadBaseDB()
        _QuestieInit:OverrideDBWithTBCData()

        print("\124cFF4DDBFF [2/7] " .. l10n("Applying database corrections") .. "...")

        coroutine.yield()
        QuestieCorrections:Initialize()
        coroutine.yield()
        QuestieMenu:PopulateTownsfolk()

        print("\124cFF4DDBFF [3/7] " .. l10n("Initializing locale") .. "...")
        coroutine.yield()
        l10n:Initialize()

        coroutine.yield()
        QuestieDB.private:DeleteGatheringNodes()

        coroutine.yield()
        QuestieCorrections:PreCompile()
        QuestieDBCompiler:Compile()
    else
        _QuestieInit:OverrideDBWithTBCData()

        coroutine.yield()
        l10n:Initialize()

        coroutine.yield()
        QuestieCorrections:MinimalInit()
    end

    if (not Questie.db.char.townsfolk) or Questie.db.global.dbCompiledCount ~= Questie.db.char.townsfolkVersion then
        Questie.db.char.townsfolkVersion = Questie.db.global.dbCompiledCount
        coroutine.yield()
        QuestieMenu:BuildCharacterTownsfolk()
    end

    coroutine.yield()
    QuestieDB:Initialize()

    QuestieCleanup:Run()

    -- continue to next Init Stage
    return QuestieInit.Stages[2]
end

QuestieInit.Stages[2] = function() -- not a coroutine
    _QuestieInit.WaitForGameCache()
    -- continues to next Init Stage in above function
end

QuestieInit.Stages[3] = function() -- run as a coroutine
    -- register events that rely on questie being initialized
    QuestieEventHandler:RegisterLateEvents()
    QuestEventHandler:RegisterEvents()
    ChatFilter:RegisterEvents()
    coroutine.yield()

    QuestieMap:InitializeQueue()

    coroutine.yield()
    QuestiePlayer:Initialize()
    l10n:PostBoot()

    coroutine.yield()
    QuestieJourney:Initialize()
    coroutine.yield()
    QuestieQuest:Initialize()
    coroutine.yield()
    QuestieQuest:GetAllQuestIdsNoObjectives()
    coroutine.yield()
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
    coroutine.yield()
    QuestieNameplate:Initialize()
    coroutine.yield()
    QuestieMenu:PopulateTownsfolkPostBoot()
    Questie:Debug(Questie.DEBUG_ELEVATED, "PLAYER_ENTERED_WORLD")

    coroutine.yield()
    QuestieQuest:GetAllQuestIds()

    -- Initialize the tracker
    coroutine.yield()
    QuestieTracker:Initialize()
    Hooks:HookQuestLogTitle()

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

    if Questie.IsTBC and QuestiePlayer:GetPlayerLevel() == 70 then
        local lastRequestWasYesterday = Questie.db.char.lastDailyRequestDate ~= date("%d-%m-%y"); -- Yesterday or some day before
        local isPastDailyReset = Questie.db.char.lastDailyRequestResetTime < GetQuestResetTime();

        if lastRequestWasYesterday or isPastDailyReset then
            -- We send empty Reputable events to ask for the current daily quests. Other users of the addon will answer if they have better data.
            C_ChatInfo.SendAddonMessage("REPUTABLE", "send:1.21-bcc::::::::::", "GUILD");
            C_ChatInfo.SendAddonMessage("REPUTABLE", "send:1.21-bcc::::::::::", "YELL");
            Questie.db.char.lastDailyRequestDate = date("%d-%m-%y");
            Questie.db.char.lastDailyRequestResetTime = GetQuestResetTime();
        end
    end
end

-- End of QuestieInit.Stages ******************************************************
-- ********************************************************************************



function QuestieInit:LoadDatabase(key)
    if QuestieDB[key] then
        coroutine.yield()
        QuestieDB[key] = loadstring(QuestieDB[key]) -- load the table from string (returns a function)
        coroutine.yield()
        QuestieDB[key] = QuestieDB[key]() -- execute the function (returns the table)
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "Database is missing, this is likely do to era vs tbc: ", key)
    end
end

function QuestieInit:LoadBaseDB()

    -- load NPC data
    QuestieInit:LoadDatabase("npcData")
    QuestieInit:LoadDatabase("npcDataTBC")

    -- load object data
    QuestieInit:LoadDatabase("objectData")
    QuestieInit:LoadDatabase("objectDataTBC")

    -- load quest data
    QuestieInit:LoadDatabase("questData")
    QuestieInit:LoadDatabase("questDataTBC")

    -- load item data
    QuestieInit:LoadDatabase("itemData")
    QuestieInit:LoadDatabase("itemDataTBC")

end

function _QuestieInit:OverrideDBWithTBCData()
    if QuestieDB.questDataTBC then
        -- we loaded the TBC db, alias the tables
        QuestieDB.questData = QuestieDB.questDataTBC
        QuestieDB.objectData = QuestieDB.objectDataTBC
        QuestieDB.npcData = QuestieDB.npcDataTBC
        QuestieDB.itemData = QuestieDB.itemDataTBC
    end
end


local function _WaitForGameCache_TryAgainAtEvent()
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", _QuestieInit.WaitForGameCache)
        eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    end
end

local function _WaitForGameCache_DestroyEventFrame()
    if eventFrame then
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
        eventFrame:SetParent(nil)
        eventFrame = nil
    end
end

-- called directly and OnEvent
function _QuestieInit.WaitForGameCache()
    local numEntries, numQuests = GetNumQuestLogEntries()
    print("--> _QuestieInit.WaitForGameCache() numEntries:", numEntries, "numQuests:", numQuests)

    -- Player can have 0 quests in questlog OR game's cache can have empty questlog while cache is invalid
    -- This is a workaround to wait and see if player really has 0 quests.
    -- Without cached information the first QLU does not have any quest log entries.
    -- After MAX_INIT_QUEST_LOG_TRIES tries we stop trying
    if numEntries == 0 then
        if initQuestLogTries < MAX_INIT_QUEST_LOG_TRIES then
            initQuestLogTries = initQuestLogTries + 1
            print("--> _QuestieInit.WaitForGameCache()", GetTime(), "Game's quest log is empty. Tries:", initQuestLogTries.."/"..MAX_INIT_QUEST_LOG_TRIES)
            _WaitForGameCache_TryAgainAtEvent()
            return
        else
            print("--> _QuestieInit.WaitForGameCache()", GetTime(), "Decide player has no quests for real.")
        end
    end

    local isGameCacheGood = true
    local goodQuestsCount = 0 -- for debug stats

    for i = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(i)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) then
            local hasInvalidObjective -- for debug stats
            local objectiveList = GetQuestObjectives(questId)
            for _, objective in pairs(objectiveList) do -- objectiveList may be {} and that is validly cached quest in game log
                if (not objective.text) or stringSub(objective.text, 1, 1) == " " then
                    -- Game hasn't cached the quest fully yet
                    isGameCacheGood = false
                    hasInvalidObjective = true

                    -- No early "return false" here to force iterate whole quest log and speed up caching
                end
            end
            if not hasInvalidObjective then
                goodQuestsCount = goodQuestsCount + 1
            end
        end
    end

    if not isGameCacheGood then
        print("--> _QuestieInit.WaitForGameCache()", GetTime(), "Game's quest log is not yet okey. Good quest: "..goodQuestsCount.."/"..numQuests)
        _WaitForGameCache_TryAgainAtEvent()
        return
    end

    if goodQuestsCount ~= numQuests then
        -- This shouldn't be possible
        Questie:Error("Report this error! Game QuestLog cache is broken. Good quest: "..goodQuestsCount.."/"..numQuests) -- TODO fix message and add translations?
        -- TODO should we stop whole addon loading progress?
    end

    print("--> _QuestieInit.WaitForGameCache()", GetTime(), "Game's quest log is |cff00bc32".."OK".."|r. Good quest: "..goodQuestsCount.."/"..numQuests)

    -- Destroy eventFrame
    _WaitForGameCache_DestroyEventFrame()

    -- Continue to next Init Stage
    _QuestieInit:StartStageCoroutine(3)
end


-- this function creates coroutine to run a function from QuestieInit.Stages[]
---@param stage number @the stage to start
function _QuestieInit:StartStageCoroutine(stage)
    local initFrame = CreateFrame("Frame")
    local routine = coroutine.create(QuestieInit.Stages[stage])

    local function InitOnUpdate()
        local success, ret = coroutine.resume(routine)
        if success then
            if coroutine.status(routine) == "dead" then
                initFrame:SetScript("OnUpdate", nil)
                initFrame:SetParent(nil)
                initFrame = nil
                if type(ret) == "function" then -- continue to next stage, if it was returned by coroutine
                    ret()
                end
            end
        else
            Questie:Error(l10n("Error during initialization!"), ret)
            initFrame:SetScript("OnUpdate", nil)
            initFrame:SetParent(nil)
            initFrame = nil
        end
    end

    initFrame:SetScript("OnUpdate", InitOnUpdate)
    InitOnUpdate() -- starts the coroutine imediately instead at next OnUpdate
end

-- called by the PLAYER_LOGIN event handler
function QuestieInit:Init()
--[[ debugs
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(self, ...) print("Event:", ...) end)
    f:RegisterEvent("LOADING_SCREEN_DISABLED")
]]--
    _QuestieInit:StartStageCoroutine(1)
end
