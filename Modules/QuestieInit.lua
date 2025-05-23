---@class QuestieInit
local QuestieInit = QuestieLoader:CreateModule("QuestieInit")
local _QuestieInit = QuestieInit.private

---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type Migration
local Migration = QuestieLoader:ImportModule("Migration")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
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
---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type EventHandler
local EventHandler = QuestieLoader:ImportModule("EventHandler")
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
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieSlash
local QuestieSlash = QuestieLoader:ImportModule("QuestieSlash")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")
---@type Tutorial
local Tutorial = QuestieLoader:ImportModule("Tutorial")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")
---@type WorldMapButton
local WorldMapButton = QuestieLoader:ImportModule("WorldMapButton")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type WatchFrameHook
local WatchFrameHook = QuestieLoader:ImportModule("WatchFrameHook")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

local coYield = coroutine.yield

local function loadFullDatabase()
    print("\124cFF4DDBFF [1/9] " .. l10n("Loading database") .. "...")

    QuestieInit:LoadBaseDB()

    print("\124cFF4DDBFF [2/9] " .. l10n("Applying database corrections") .. "...")

    coYield()
    QuestieCorrections:Initialize()

    print("\124cFF4DDBFF [3/9] " .. l10n("Initializing townfolks") .. "...")
    coYield()
    Townsfolk.Initialize()

    print("\124cFF4DDBFF [4/9] " .. l10n("Initializing locale") .. "...")
    coYield()
    l10n:Initialize()

    coYield()
    QuestieDB.private:DeleteGatheringNodes()

    print("\124cFF4DDBFF [5/9] " .. l10n("Optimizing waypoints") .. "...")
    coYield()
    QuestieCorrections:PreCompile()
end

---Run the validator
local function runValidator()
    if type(QuestieDB.questData) == "string" or type(QuestieDB.npcData) == "string" or type(QuestieDB.objectData) == "string" or type(QuestieDB.itemData) == "string" then
        Questie:Error("Cannot run the validator on string data, load database first")
        return
    end
    -- Run validator
    if Questie.db.profile.debugEnabled then
        coYield()
        print("Validating NPCs...")
        QuestieDBCompiler:ValidateNPCs()
        coYield()
        print("Validating objects...")
        QuestieDBCompiler:ValidateObjects()
        coYield()
        print("Validating items...")
        QuestieDBCompiler:ValidateItems()
        coYield()
        print("Validating quests...")
        QuestieDBCompiler:ValidateQuests()
    end
end

-- ********************************************************************************
-- Start of QuestieInit.Stages ******************************************************

-- stage worker functions. Most are coroutines.
QuestieInit.Stages = {}

QuestieInit.Stages[1] = function() -- run as a coroutine
    Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieInit:Stage1] Starting the real init.")

    -- This needs to happen after ADDON_LOADED
    l10n.InitializeUILocale()

    local dbCompiled = false

    local dbIsCompiled, dbCompiledOnVersion, dbCompiledLang
    if Questie.IsSoD then
        dbIsCompiled = Questie.db.global.sod.dbIsCompiled or false
        dbCompiledOnVersion = Questie.db.global.sod.dbCompiledOnVersion
        dbCompiledLang = Questie.db.global.sod.dbCompiledLang
    else
        dbIsCompiled = Questie.db.global.dbIsCompiled or false
        dbCompiledOnVersion = Questie.db.global.dbCompiledOnVersion
        dbCompiledLang = Questie.db.global.dbCompiledLang
    end

    -- Check if the DB needs to be recompiled
    if (not dbIsCompiled) or (QuestieLib:GetAddonVersionString() ~= dbCompiledOnVersion) or (l10n:GetUILocale() ~= dbCompiledLang) or (Questie.db.global.dbCompiledExpansion ~= WOW_PROJECT_ID) then
        print("\124cFFAAEEFF" .. l10n("Questie DB has updated!") .. "\124r\124cFFFF6F22 " .. l10n("Data is being processed, this may take a few moments and cause some lag..."))
        loadFullDatabase()
        QuestieDBCompiler:Compile()
        dbCompiled = true
    else
        l10n:Initialize()
        coYield()
        QuestieCorrections:MinimalInit()
    end

    local dbCompiledCount = Questie.IsSoD and Questie.db.global.sod.dbCompiledCount or Questie.db.global.dbCompiledCount

    if (not Questie.db.char.townsfolk) or (dbCompiledCount ~= Questie.db.char.townsfolkVersion) or (Questie.db.char.townsfolkClass ~= UnitClass("player")) then
        Questie.db.char.townsfolkVersion = dbCompiledCount
        coYield()
        Townsfolk:BuildCharacterTownsfolk()
    end

    coYield()
    QuestieDB:Initialize()

    Tutorial.Initialize()
    coYield()

    --? Only run the validator on recompile if debug is enabled, otherwise it's a waste of time.
    if Questie.db.profile.debugEnabled and dbCompiled then
        if Questie.db.profile.skipValidation ~= true then
            runValidator()
            print("\124cFF4DDBFF Load and Validation complete.")
        else
            print("\124cFF4DDBFF Validation skipped, load complete.")
        end
    end

    QuestieCleanup:Run()
end

QuestieInit.Stages[2] = function()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage2] Stage 2 start.")
    -- We do this while we wait for the Quest Cache anyway.
    l10n:PostBoot()
    QuestiePlayer:Initialize()
    coYield()
    QuestieJourney:Initialize()

    local keepWaiting = true
    -- We had users reporting that a quest did not reach a valid state in the game cache.
    -- In this case we still need to continue the initialization process, even though a specific quest might be bugged
    C_Timer.After(3, function()
        if keepWaiting then
            Questie:Debug(Questie.DEBUG_CRITICAL, "QuestieInit: Timeout waiting for Game Cache validation. Continuing.")
            keepWaiting = false
        end
    end)

    -- Continue to the next Init Stage once Game Cache's Questlog is good
    while (not QuestieValidateGameCache.IsCacheGood()) and keepWaiting do
        coYield()
    end
    keepWaiting = false
end

QuestieInit.Stages[3] = function() -- run as a coroutine
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Stage 3 start.")

    -- register events that rely on questie being initialized
    EventHandler:RegisterLateEvents()

    QuestieTooltips:Initialize()
    TrackerQuestTimers:Initialize()
    QuestieComms:Initialize()

    coYield()

    if Questie.db.profile.dbmHUDEnable then
        QuestieDBMIntegration:EnableHUD()
    end

    QuestieMap:InitializeQueue()

    coYield()
    QuestieQuest:Initialize()
    coYield()
    WorldMapButton.Initialize()
    Townsfolk.PostBoot()
    coYield()

    -- Fill the QuestLogCache for first time
    local cacheMiss, _, questIdsChecked = QuestLogCache.CheckForChanges(nil, false)

    if cacheMiss then
        Questie:Debug(Questie.DEBUG_CRITICAL, "QuestieInit: Game Cache did not fill in time, waiting for valid cache.")
        questIdsChecked = QuestieInit.WaitForValidGameCache()
    end

    QuestEventHandler.InitQuestLogStates(questIdsChecked)

    coYield()
    QuestieQuest:GetAllQuestIdsNoObjectives()
    QuestieQuest:GetAllQuestIds()
    coYield()

    QuestEventHandler:Initialize()

    coYield()
    QuestieCombatQueue.Initialize()

    -- Initialize the tracker
    coYield()
    QuestieTracker.Initialize()
    Hooks:HookQuestLogTitle()
    coYield()
    ChatFilter:RegisterEvents()

    local dateToday = date("%y-%m-%d")

    if (not Questie.IsSoD) and Questie.db.profile.showAQWarEffortQuests and ((not Questie.db.profile.aqWarningPrintDate) or (Questie.db.profile.aqWarningPrintDate < dateToday)) then
        Questie.db.profile.aqWarningPrintDate = dateToday
        C_Timer.After(2, function()
            print("|cffff0000-----------------------------|r")
            Questie:Print("|cffff0000The AQ War Effort quests are shown for you. If your server is done you can hide those quests in the General settings of Questie!|r");
            print("|cffff0000-----------------------------|r")
        end)
    end

    if Questie.IsTBC and (not Questie.db.profile.isIsleOfQuelDanasPhaseReminderDisabled) then
        C_Timer.After(2, function()
            Questie:Print(l10n("Current active phase of Isle of Quel'Danas is '%s'. Check the General settings to change the phase or disable this message.", IsleOfQuelDanas.localizedPhaseNames[Questie.db.global.isleOfQuelDanasPhase]))
        end)
    end

    coYield()
    QuestieMenu:OnLogin()

    coYield()
    if Questie.db.profile.debugEnabled then
        QuestieLoader:PopulateGlobals()
    end

    Questie.started = true

    -- ! Never implemented
    if (Questie.IsWotlk or Questie.IsTBC) and QuestiePlayer.IsMaxLevel() then
        local lastRequestWasYesterday = Questie.db.global.lastDailyRequestDate ~= date("%d-%m-%y"); -- Yesterday or some day before
        local isPastDailyReset = Questie.db.global.lastDailyRequestResetTime < GetQuestResetTime();

        if lastRequestWasYesterday or isPastDailyReset then
            Questie.db.global.lastDailyRequestDate = date("%d-%m-%y");
            Questie.db.global.lastDailyRequestResetTime = GetQuestResetTime();
        end
    end

    -- We do this last because it will run for a while and we don't want to block the rest of the init
    AvailableQuests.CalculateAndDrawAll()

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Questie init done.")
end

-- End of QuestieInit.Stages ******************************************************
-- ********************************************************************************



function QuestieInit:LoadDatabase(key)
    if QuestieDB[key] then
        coYield()
        local func, err = loadstring(QuestieDB[key]) -- load the table from string (returns a function)
        if (not func) then
            Questie:Error("Failed to load database: ", key, err)
            return
        end
        QuestieDB[key] = func
        coYield()
        QuestieDB[key] = QuestieDB[key]()           -- execute the function (returns the table)
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

function _QuestieInit.StartStageCoroutine()
    for i = 1, #QuestieInit.Stages do
        QuestieInit.Stages[i]()
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:StartStageCoroutine] Stage " .. i .. " done.")
    end
end

-- The UI elements might not be loaded at this point, so we must only initialize modules that do not rely on the UI
function QuestieInit.OnAddonLoaded()
    -- Loading everything for that it is totally irrelevant when exactly it is done
    ThreadLib.ThreadError(function()
        HBDHooks:Init()
        QuestieShutUp:ToggleFilters(Questie.db.profile.questieShutUp)
        QuestieCoords:Initialize()
        QuestieSlash.RegisterSlashCommands()

        IsleOfQuelDanas.Initialize() -- This has to happen before option init
        QuestieOptions.Initialize()
    end, 0,"Error during AddonLoaded initialization!")

    MinimapIcon:Init()

    Questie.SetIcons()

    Migration:Migrate()

    ZoneDB.Initialize()
    AvailableQuests.Initialize()
    QuestieProfessions:Init()
    QuestXP.Init()
    Phasing.Initialize()

    if Questie.IsSoD then
        SeasonOfDiscovery.Initialize()
    end
end

-- called by the PLAYER_LOGIN event handler
function QuestieInit:Init()
    ThreadLib.ThreadError(_QuestieInit.StartStageCoroutine, 0, l10n("Error during initialization!"))

    if Questie.db.profile.trackerEnabled then
        -- This needs to be called ASAP otherwise tracked Achievements in the Blizzard WatchFrame shows upon login
        WatchFrameHook.Hide()

        if Expansions.Current < Expansions.Wotlk then
            -- Need to hook this ASAP otherwise the scroll bars show up
            hooksecurefunc("ScrollFrame_OnScrollRangeChanged", function()
                if TrackedQuestsScrollFrame then
                    TrackedQuestsScrollFrame.ScrollBar:Hide()
                end

                if QuestieProfilerScrollFrame then
                    QuestieProfilerScrollFrame.ScrollBar:Hide()
                end
            end)
        end
    end
end


--- We really want to wait for the cache to be filled before we continue.
--- Other addons (e.g. ATT) can interfere with the cache and we need to make sure it's correct.
---@return table<number>
function QuestieInit.WaitForValidGameCache()
    local doWait = true
    local retries = 0
    local questIdsChecked

    local timer
    timer = C_Timer.NewTicker(1, function()
        local cacheMiss, _, newQuestIdsChecked = QuestLogCache.CheckForChanges(nil, false)
        if (not cacheMiss) or retries >= 3 then
            if retries == 3 then
                Questie:Error("QuestieInit: Game Cache did not become valid in 3 seconds, continuing with initialization.")
            end
            doWait = false
            timer:Cancel()
        end
        questIdsChecked = newQuestIdsChecked
        retries = retries + 1
    end)

    while doWait do
        coYield()
    end

    return questIdsChecked
end
