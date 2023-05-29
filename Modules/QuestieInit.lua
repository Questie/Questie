---@class QuestieInit
local QuestieInit = QuestieLoader:CreateModule("QuestieInit")
local _QuestieInit = QuestieInit.private

---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

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
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieSlash
local QuestieSlash = QuestieLoader:ImportModule("QuestieSlash")

local coYield = coroutine.yield

local function loadFullDatabase()
    print("\124cFF4DDBFF [1/9] " .. l10n("Loading database") .. "...")

    QuestieInit:LoadBaseDB()

    print("\124cFF4DDBFF [2/9] " .. l10n("Applying database corrections") .. "...")

    coYield()
    QuestieCorrections:Initialize()

    print("\124cFF4DDBFF [3/9] " .. l10n("Initializing townfolks") .. "...")
    coYield()
    QuestieMenu:PopulateTownsfolk()

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
    if Questie.db.global.skipValidation then
        -- TODO: We need a checkbox for this setting
        return
    end

    if type(QuestieDB.questData) == "string" or type(QuestieDB.npcData) == "string" or type(QuestieDB.objectData) == "string" or type(QuestieDB.itemData) == "string" then
        Questie:Error("Cannot run the validator on string data, load database first")
        return
    end
    -- Run validator
    if Questie.db.global.debugEnabled then
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

    --? This was moved here because the lag that it creates is much less noticable here, while still initalizing correctly.
    Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieInit:Stage1] Starting QuestieOptions.Initialize Thread.")
    ThreadLib.ThreadSimple(QuestieOptions.Initialize, 0)

    MinimapIcon:Init()

    HBDHooks:Init()

    Questie:SetIcons()

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        l10n:SetUILocale(Questie.db.global.questieLocale);
    else
        l10n:SetUILocale(GetLocale());
    end

    QuestieShutUp:ToggleFilters(Questie.db.global.questieShutUp)

    coYield()
    ZoneDB:Initialize()

    coYield()
    Migration:Migrate()

    IsleOfQuelDanas.Initialize() -- This has to happen before option init

    QuestieProfessions:Init()
    coYield()

    local dbCompiled = false

    -- Check if the DB needs to be recompiled
    if (not Questie.db.global.dbIsCompiled) or QuestieLib:GetAddonVersionString() ~= Questie.db.global.dbCompiledOnVersion or (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale()) ~= Questie.db.global.dbCompiledLang then
        print("\124cFFAAEEFF" .. l10n("Questie DB has updated!") .. "\124r\124cFFFF6F22 " .. l10n("Data is being processed, this may take a few moments and cause some lag..."))
        loadFullDatabase()
        QuestieDBCompiler:Compile()
        dbCompiled = true
    else
        l10n:Initialize()
        coYield()
        QuestieCorrections:MinimalInit()
    end

    if (not Questie.db.char.townsfolk) or Questie.db.global.dbCompiledCount ~= Questie.db.char.townsfolkVersion then
        Questie.db.char.townsfolkVersion = Questie.db.global.dbCompiledCount
        coYield()
        QuestieMenu:BuildCharacterTownsfolk()
    end

    coYield()
    QuestieDB:Initialize()

    --? Only run the validator on recompile if debug is enabled, otherwise it's a waste of time.
    if Questie.db.global.debugEnabled and dbCompiled then
        runValidator()
        print("\124cFF4DDBFF Load and Validation complete...")
    end

    QuestieCleanup:Run()
end

QuestieInit.Stages[2] = function()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Stage 2 start.")
    -- We do this while we wait for the Quest Cache anyway.
    l10n:PostBoot()
    QuestiePlayer:Initialize()
    coYield()
    QuestieJourney:Initialize()

    -- Continue to the next Init Stage once Game Cache's Questlog is good
    while not QuestieValidateGameCache:IsCacheGood() do
        coYield()
    end
end

QuestieInit.Stages[3] = function() -- run as a coroutine
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Stage 3 start.")

    -- register events that rely on questie being initialized
    QuestieEventHandler:RegisterLateEvents()

    -- ** OLD ** Questie:ContinueInit() ** START **
    QuestieTooltips:Initialize()
    QuestieCoords:Initialize()
    TrackerQuestTimers:Initialize()
    QuestieComms:Initialize()

    QuestieSlash.RegisterSlashCommands()

    coYield()

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


    coYield()
    QuestEventHandler:RegisterEvents()
    coYield()
    ChatFilter:RegisterEvents()
    QuestieMap:InitializeQueue()

    coYield()
    QuestieQuest:Initialize()
    coYield()
    QuestieQuest:GetAllQuestIdsNoObjectives()
    coYield()
    QuestieMenu:PopulateTownsfolkPostBoot()
    coYield()
    QuestieQuest:GetAllQuestIds()

    -- Initialize the tracker
    coYield()
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

    coYield()
    QuestieMenu:OnLogin()

    coYield()
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

    -- We do this last because it will run for a while and we don't want to block the rest of the init
    coYield()
    QuestieQuest.CalculateAndDrawAvailableQuestsIterative()

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieInit:Stage3] Questie init done.")
end

-- End of QuestieInit.Stages ******************************************************
-- ********************************************************************************



function QuestieInit:LoadDatabase(key)
    if QuestieDB[key] then
        coYield()
        QuestieDB[key] = loadstring(QuestieDB[key]) -- load the table from string (returns a function)
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

-- called by the PLAYER_LOGIN event handler
function QuestieInit:Init()
    ThreadLib.ThreadError(_QuestieInit.StartStageCoroutine, 0, l10n("Error during initialization!"))

    if Questie.db.char.trackerEnabled then
        -- This needs to be called ASAP otherwise tracked Achievements in the Blizzard WatchFrame shows upon login
        local WatchFrame = QuestTimerFrame or WatchFrame

        if Questie.IsWotlk then
            -- Classic WotLK
            WatchFrame:Hide()
        else
            -- Classic WoW: This moves the QuestTimerFrame off screen. A faux Hide().
            -- Otherwise, if the frame is hidden then the OnUpdate doesn't work.
            WatchFrame:ClearAllPoints()
            WatchFrame:SetPoint("TOP", -10000, -10000)
        end

        -- Need to hook this ASAP otherwise the scroll bars show up
        hooksecurefunc("ScrollFrame_OnScrollRangeChanged", function()
            if TrackedQuestsScrollFrame then
                TrackedQuestsScrollFrame.ScrollBar:Hide()
            end
        end)
    end
end
