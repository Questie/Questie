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
---@type QuestieValidateGameCache
local QuestieValidateGameCache = QuestieLoader:ImportModule("QuestieValidateGameCache")



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
    -- Continue to the next Init Stage once Game Cache's Questlog is good
    QuestieValidateGameCache.AddCallback(_QuestieInit.StartStageCoroutine, _QuestieInit, 3)
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
    _QuestieInit:StartStageCoroutine(1)
end
