---@class QuestieInit
local QuestieInit = QuestieLoader:CreateModule("QuestieInit")

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

-- initialize all questie modules
-- this function runs inside a coroutine
function QuestieInit:InitAllModules()

    HBDHooks:Init()

    QuestieFramePool:SetIcons()

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        l10n:SetUILocale(Questie.db.global.questieLocale);
    else
        l10n:SetUILocale(GetLocale());
    end

    Questie:Debug(DEBUG_CRITICAL, "[Questie:OnInitialize] Questie addon loaded")

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
        
        if not Questie.db.global.hasSeenBetaMessage then
            Questie.db.global.hasSeenBetaMessage = true
            print("\124cFFFFFF00" ..l10n("[Questie] With the move to Burning Crusade, Questie is undergoing rapid development, as such you may encounter bugs. Please keep Questie up to date for the best experience! We will also be releasing a large update some time after TBC launch, with many improvements and new features."))
        end
    else
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

    QuestieLib:CacheAllItemNames() -- todo: remove this, blizzard said we shouldn't query more than once a second
    QuestieCleanup:Run()

    -- register events that rely on questie being initialized
    QuestieEventHandler:RegisterLateEvents()
    ChatFilter:RegisterEvents()

    QuestieMap:InitializeQueue()

    coroutine.yield()
    for i=1, GetNumQuestLogEntries() do
        GetQuestLogTitle(i)
        coroutine.yield()
        QuestieQuest:GetRawLeaderBoardDetails(i)
    end

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
    Questie:Debug(DEBUG_ELEVATED, "PLAYER_ENTERED_WORLD")

    coroutine.yield()
    QuestieQuest:GetAllQuestIds()

    -- Initialize the tracker
    coroutine.yield()
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

function QuestieInit:LoadDatabase(key)
    if QuestieDB[key] then
        coroutine.yield()
        QuestieDB[key] = loadstring(QuestieDB[key]) -- load the table from string (returns a function)
        coroutine.yield()
        QuestieDB[key] = QuestieDB[key]() -- execute the function (returns the table)
    else
        Questie:Debug(DEBUG_DEVELOP, "Database is missing, this is likely do to era vs tbc: ", key)
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

    if QuestieDB.questDataTBC then
        -- we loaded the TBC db, alias the tables
        QuestieDB.questData = QuestieDB.questDataTBC
        QuestieDB.objectData = QuestieDB.objectDataTBC
        QuestieDB.npcData = QuestieDB.npcDataTBC
        QuestieDB.itemData = QuestieDB.itemDataTBC
    end

end

-- called by the PLAYER_LOGIN event handler
-- this function creates the coroutine that runs "InitAllModules"
function QuestieInit:Init()
    local initFrame = CreateFrame("Frame")
    local routine = coroutine.create(QuestieInit.InitAllModules)
    initFrame:SetScript("OnUpdate", function()
        local success, error = coroutine.resume(routine)
        if success then
            if coroutine.status(routine) == "dead" then
                initFrame:SetScript("OnUpdate", nil)
            end
        else
            Questie:Error(l10n("Error during initialization!"), error)
            initFrame:SetScript("OnUpdate", nil)
        end
    end)
end
