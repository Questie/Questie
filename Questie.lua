if not QuestieConfigCharacter then
    QuestieConfigCharacter = {}
end

-- Global debug levels, see bottom of this file and `debugLevel` in QuestieOptionsAdvanced.lua for relevant code
-- When adding a new level here it MUST be assigned a number and name in `debugLevel.values` as well added to Questie:Debug below
DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"

--Initialized below
---@class Questie
Questie = {...}

-------------------------
--Import modules.
-------------------------
---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer");
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsMinimapIcon
local QuestieOptionsMinimapIcon = QuestieLoader:ImportModule("QuestieOptionsMinimapIcon");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto");
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
---@type QuestieEventHandler
local QuestieEventHandler = QuestieLoader:ImportModule("QuestieEventHandler");
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate");
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation");
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch");
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults");
---@type QuestieStreamLib
local QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib");
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieSlash
local QuestieSlash = QuestieLoader:ImportModule("QuestieSlash")
---@type Migration
local Migration = QuestieLoader:ImportModule("Migration")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

-- check if user has updated but not restarted the game (todo: add future new source files to this)
if  (not LQuestie_EasyMenu) or
    --Libs
    (not QuestieLib) or
    (not QuestiePlayer) or
    (not QuestieSerializer) or
    --Comms
    (not QuestieComms) or
    (not QuestieComms.data) or
    --Options
    (not QuestieOptions) or
    (not QuestieOptionsDefaults) or
    (not QuestieOptionsMinimapIcon) or
    (not QuestieOptionsUtils) or
    (not QuestieOptions.tabs) or
    (not QuestieOptions.tabs.advanced) or
    (not QuestieOptions.tabs.dbm) or
    (not QuestieOptions.tabs.general) or
    (not QuestieOptions.tabs.map) or
    (not QuestieOptions.tabs.minimap) or
    (not QuestieOptions.tabs.nameplate) or
    (not QuestieOptions.tabs.tracker) or

    (not QuestieAuto) or
    (not QuestieCoords) or
    (not QuestieEventHandler) or
    (not QuestieFramePool) or
    (not QuestieJourney) or
    --Map
    (not QuestieMap) or
    (not QuestieMap.utils) or

    (not QuestieNameplate) or
    (not QuestieProfessions) or
    (not QuestieQuest) or
    (not QuestieReputation) or
    --Search
    (not QuestieSearch) or
    (not QuestieSearchResults) or

    (not QuestieStreamLib) or
    (not QuestieTooltips) or
    (not QuestieSearchResults) or
    (not QuestieCombatQueue) or
    (not QuestieTracker) then
    --Delay the warning.
    C_Timer.After(8, function()
        if QuestieLocale.locale['enUS'] and QuestieLocale.locale['enUS']['QUESTIE_UPDATED_RESTART'] then -- sometimes locale doesnt update without restarting also
            print(QuestieLocale:GetUIString('QUESTIE_UPDATED_RESTART'))
        else
            print("|cFFFF0000WARNING!|r You have updated Questie without restarting the game, this will likely cause problems. Please restart the game before continuing")
        end
    end)
  else
    -- Initialize Questie
    Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceBucket-3.0")
    _Questie = {...}
end


function Questie:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("QuestieConfig", QuestieOptionsDefaults:Load(), true)
    QuestieFramePool:SetIcons()

    Migration:Migrate()

    -- Set proper locale. Either default to client Locale or override based on user.
    if Questie.db.global.questieLocaleDiff then
        QuestieLocale:SetUILocale(Questie.db.global.questieLocale);
    else
        QuestieLocale:SetUILocale(GetLocale());
    end

    Questie:Debug(DEBUG_CRITICAL, "[Questie:OnInitialize] Questie addon loaded")
    ZoneDB:Initialize()
    QuestieCorrections:Initialize()
    QuestieLocale:Initialize()

    QuestieEventHandler:RegisterAllEvents()

    --QuestieTracker:Initialize() --moved to stage 2 init event function
    QuestieTooltips:Initialize()
    QuestieCoords:Initialize()
    QuestieQuestTimers:Initialize()
    QuestieCombatQueue:Initialize()
    QuestieComms:Initialize()

    -- Register Slash Commands
    Questie:RegisterChatCommand("questieclassic", "HandleSlash")
    Questie:RegisterChatCommand("questie", "HandleSlash")

    QuestieOptions:Initialize()

    --Initialize the DB settings.
    Questie:Debug(DEBUG_DEVELOP, QuestieLocale:GetUIString('DEBUG_CLUSTER', Questie.db.global.clusterLevelHotzone))

    -- Creating the minimap config icon
    Questie.minimapConfigIcon = LibStub("LibDBIcon-1.0");
    Questie.minimapConfigIcon:Register("Questie", QuestieOptionsMinimapIcon:Get(), Questie.db.profile.minimap);

    -- Update the default text on the map show/hide button for localization
    if Questie.db.char.enabled then
        Questie_Toggle:SetText(QuestieLocale:GetUIString('QUESTIE_MAP_BUTTON_HIDE'));
    else
        Questie_Toggle:SetText(QuestieLocale:GetUIString('QUESTIE_MAP_BUTTON_SHOW'));
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
    end);

    if Questie.db.global.dbmHUDEnable then
        QuestieDBMIntegration:EnableHUD()
    end
end

function Questie:OnUpdate()

end

function Questie:OnEnable()
    -- Called when the addon is enabled
end

function Questie:OnDisable()
    -- Called when the addon is disabled
end

function Questie:HandleSlash(input)
    QuestieSlash:HandleCommands(input)
end

function Questie:Colorize(str, color)
    local c = '';

    if color == 'red' then
        c = '|cffff0000';
    elseif color == 'gray' then
        c = '|cFFCFCFCF';
    elseif color == 'purple' then
        c = '|cFFB900FF';
    elseif color == 'blue' then
        c = '|cB900FFFF';
    elseif color == 'yellow' then
        c = '|cFFFFB900';
    elseif color == "white" then
        c = '|cFFFFFFFF';
    elseif color == "gold" then
        c = "|cffffd100" -- this is the default game font
    end

    return c .. str .. "|r"
end

function Questie:GetClassColor(class)
    class = string.lower(class);

    if class == 'druid' then
        return '|cFFFF7D0A';
    elseif class == 'hunter' then
        return '|cFFABD473';
    elseif class == 'mage' then
        return '|cFF69CCF0';
    elseif class == 'paladin' then
        return '|cFFF58CBA';
    elseif class == 'priest' then
        return '|cFFFFFFFF';
    elseif class == 'rogue' then
        return '|cFFFFF569';
    elseif class == 'shaman' then
        return '|cFF0070DE';
    elseif class == 'warlock' then
        return '|cFF9482C9';
    elseif class == 'warrior' then
        return '|cFFC79C6E';
    else
        return '|cffff0000'; -- error red
    end
end

function Questie:Error(...)
    Questie:Print("|cffff0000[ERROR]|r", ...)
end

function Questie:Debug(...)
    if(Questie.db.global.debugEnabled) then
        -- Exponents are defined by `debugLevel.values` in QuestieOptionsAdvanced.lua
        -- DEBUG_CRITICAL = 0
        -- DEBUG_ELEVATED = 1
        -- DEBUG_INFO = 2
        -- DEBUG_DEVELOP = 3
        -- DEBUG_SPAM = 4
        if(bit.band(Questie.db.global.debugLevel, math.pow(2, 4)) == 0 and select(1, ...) == DEBUG_SPAM)then return; end
        if(bit.band(Questie.db.global.debugLevel, math.pow(2, 3)) == 0 and select(1, ...) == DEBUG_DEVELOP)then return; end
        if(bit.band(Questie.db.global.debugLevel, math.pow(2, 2)) == 0 and select(1, ...) == DEBUG_INFO)then return; end
        if(bit.band(Questie.db.global.debugLevel, math.pow(2, 1)) == 0 and select(1, ...) == DEBUG_ELEVATED)then return; end
        if(bit.band(Questie.db.global.debugLevel, math.pow(2, 0)) == 0 and select(1, ...) == DEBUG_CRITICAL)then return; end
        --Questie:Print(...)
        if(QuestieConfigCharacter.log) then
            QuestieConfigCharacter = {};
        end

        if Questie.db.global.debugEnabledPrint then
            Questie:Print(...)
        end
    end
end
