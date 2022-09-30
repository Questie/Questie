---@class QuestieInit
local QuestieInit = QuestieLoader:CreateModule("QuestieInit")
local _QuestieInit = QuestieInit.private

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
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type QuestieEventHandler
local QuestieEventHandler = QuestieLoader:ImportModule("QuestieEventHandler")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type HBDHooks
local HBDHooks = QuestieLoader:ImportModule("HBDHooks")
---@type ChatFilter
local ChatFilter = QuestieLoader:ImportModule("ChatFilter")
---@type QuestieShutUp
local QuestieShutUp = QuestieLoader:ImportModule("QuestieShutUp")
---@type Hooks
local Hooks = QuestieLoader:ImportModule("Hooks")
---@type QuestieValidateGameCache
local QuestieValidateGameCache = QuestieLoader:ImportModule("QuestieValidateGameCache")
---@type MinimapIcon
local MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration");
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieSlash
local QuestieSlash = QuestieLoader:ImportModule("QuestieSlash")


-- ********************************************************************************
-- Start of QuestieInit.Stages ******************************************************

-- stage worker functions. Most are coroutines.
QuestieInit.Stages = {}

QuestieInit.Stages[1] = function() -- run as a coroutine
    Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieInit:Stage1] Starting the real init.")

    MinimapIcon:Init()

    HBDHooks:Init()

    QuestieFramePool:SetIcons()

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        l10n:SetUILocale(Questie.db.global.questieLocale);
    else
        l10n:SetUILocale(GetLocale());
    end

    QuestieShutUp:ToggleFilters(Questie.db.global.questieShutUp)

    coroutine.yield()
    ZoneDB:Initialize()

    coroutine.yield()
    Migration:Migrate()

    IsleOfQuelDanas.Initialize() -- This has to happen before option init

    QuestieProfessions:Init()
    coroutine.yield()

    -- check if the DB needs to be recompiled
    if (not Questie.db.global.dbIsCompiled) or QuestieLib:GetAddonVersionString() ~= Questie.db.global.dbCompiledOnVersion or (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale()) ~= Questie.db.global.dbCompiledLang then
        print("\124cFFAAEEFF"..l10n("Questie DB has updated!").. "\124r\124cFFFF6F22 " .. l10n("Data is being processed, this may take a few moments and cause some lag..."))
        print("\124cFF4DDBFF [1/7] " .. l10n("Loading database") .. "...")

        QuestieInit:LoadBaseDB()

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
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Stage 3 start.")

    -- register events that rely on questie being initialized
    QuestieEventHandler:RegisterLateEvents()

    -- ** OLD ** Questie:ContinueInit() ** START **
    QuestieTooltips:Initialize()
    QuestieCoords:Initialize()
    QuestieQuestTimers:Initialize()
    QuestieComms:Initialize()

    QuestieSlash.RegisterSlashCommands()

    QuestieOptions:Initialize()

    --Initialize the DB settings.
    Questie:Debug(Questie.DEBUG_DEVELOP, l10n("Setting clustering value, clusterLevelHotzone set to %s : Redrawing!", Questie.db.global.clusterLevelHotzone))


    -- Update the default text on the map show/hide button for localization
    if Questie.db.char.enabled then
        Questie_Toggle:SetText(l10n("Hide Questie"));
    else
        Questie_Toggle:SetText(l10n("Show Questie"));
    end

    -- Update status of Map button on hide between play sessions
    if Questie.db.global.mapShowHideEnabled then
        Questie_Toggle:Show();
    else
        Questie_Toggle:Hide();
    end

    -- Change position of Map button when continent dropdown is hidden
    C_Timer.After(1, function()
        if not WorldMapContinentDropDown:IsShown() then
            Questie_Toggle:ClearAllPoints();
            if AtlasToggleFromWorldMap and AtlasToggleFromWorldMap:IsShown() then -- #1498
                AtlasToggleFromWorldMap:SetScript("OnHide", function() Questie_Toggle:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', 0, 0) end)
                AtlasToggleFromWorldMap:SetScript("OnShow", function() Questie_Toggle:SetPoint('RIGHT', AtlasToggleFromWorldMap, 'LEFT', 0, 0) end)
                Questie_Toggle:SetPoint('RIGHT', AtlasToggleFromWorldMap, 'LEFT', 0, 0);
            else
                Questie_Toggle:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', 0, 0);
            end
        end
    end)

    if Questie.db.global.dbmHUDEnable then
        QuestieDBMIntegration:EnableHUD()
    end
    -- ** OLD ** Questie:ContinueInit() ** END **


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
    QuestieTracker.Initialize()
    Hooks:HookQuestLogTitle()
    QuestieCombatQueue.Initialize()

    local dateToday = date("%y-%m-%d")

    if Questie.db.char.showAQWarEffortQuests and ((not Questie.db.char.aqWarningPrintDate) or (Questie.db.char.aqWarningPrintDate < dateToday)) then
        Questie.db.char.aqWarningPrintDate = dateToday
        C_Timer.After(2, function()
            print("|cffff0000-----------------------------|r")
            Questie:Print("|cffff0000The AQ War Effort quests are shown for you. If your server is done you can hide those quests in the General settings of Questie!|r");
            print("|cffff0000-----------------------------|r")
        end)
    end

    if Questie.IsTBC and (not Questie.db.global.isIsleOfQuelDanasPhaseReminderDisabled) then
        C_Timer.After(2, function()
            Questie:Print(l10n("Current active phase of Isle of Quel'Danas is '%s'. Check the General settings to change the phase or disable this message.", IsleOfQuelDanas.localizedPhaseNames[Questie.db.global.isleOfQuelDanasPhase]))
        end)
    end

    QuestieMenu:OnLogin()

    if Questie.db.global.debugEnabled then
        QuestieLoader:PopulateGlobals()
    end

    Questie.started = true

    if Questie.IsWotlk and QuestiePlayer.GetPlayerLevel() == 70 then
        local lastRequestWasYesterday = Questie.db.char.lastDailyRequestDate ~= date("%d-%m-%y"); -- Yesterday or some day before
        local isPastDailyReset = Questie.db.char.lastDailyRequestResetTime < GetQuestResetTime();

        if lastRequestWasYesterday or isPastDailyReset then
            Questie.db.char.lastDailyRequestDate = date("%d-%m-%y");
            Questie.db.char.lastDailyRequestResetTime = GetQuestResetTime();
        end
    end

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Questie init done.")
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
    QuestieInit:LoadDatabase("npcData")
    QuestieInit:LoadDatabase("objectData")
    QuestieInit:LoadDatabase("questData")
    QuestieInit:LoadDatabase("itemData")
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
