
-- Global debug levels, see bottom of this file and `debugLevel` in QuestieOptionsAdvanced.lua for relevant code
-- When adding a new level here it MUST be assigned a number and name in `debugLevel.values` as well added to Questie:Debug below
DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"


-------------------------
--Import modules.
-------------------------
---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer");
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
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
---@type QuestieSlash
local QuestieSlash = QuestieLoader:ImportModule("QuestieSlash")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- check if user has updated but not restarted the game (todo: add future new source files to this)
if  --Libs
    (not QuestieLib) or
    (not QuestiePlayer) or
    (not QuestieSerializer) or
    --Comms
    (not QuestieComms) or
    (not QuestieComms.data) or
    --Options
    (not QuestieOptions) or
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
        print(Questie:Colorize(l10n("WARNING!"), "red") .. " " .. l10n("You have updated Questie without restarting the game, this will likely cause problems. Please restart the game before continuing"))
    end)
end


function Questie:OnInitialize()
    Questie.TBC_BETA_BUILD_VERSION_SHORTHAND = ""

    QuestieEventHandler:RegisterAllEvents(function()
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
        Questie:Debug(DEBUG_DEVELOP, l10n("Setting clustering value, clusterLevelHotzone set to %s : Redrawing!", Questie.db.global.clusterLevelHotzone))

        -- Creating the minimap config icon
        Questie.minimapConfigIcon = LibStub("LibDBIcon-1.0");
        Questie.minimapConfigIcon:Register("Questie", QuestieOptionsMinimapIcon:Get(), Questie.db.profile.minimap);

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
    end)
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
        c = '|cFFff0000';
    elseif color == 'gray' then
        c = '|cFFa6a6a6';
    elseif color == 'purple' then
        c = '|cFFB900FF';
    elseif color == 'blue' then
        c = '|cB900FFFF';
    elseif color == 'lightBlue' then
        c = '|cB900FFFF';
    elseif color == 'blizzardBlue' then
        c = '|cFF00c0ff';
    elseif color == 'yellow' then
        c = '|cFFffff00';
    elseif color == 'orange' then
        c = '|cFFFF6F22';
    elseif color == 'green' then
        c = '|cFF00ff00';
    elseif color == "white" then
        c = '|cFFffffff';
    elseif color == "gold" then
        c = "|cFFffd100" -- this is the default game font
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

function Questie:Warning(...)
    if Questie.db.global.debugEnabled then -- prints regardless of "debugPrint" toggle
        Questie:Print("|cffffff00[WARNING]|r", ...)
    end
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

        if Questie.db.global.debugEnabledPrint then
            Questie:Print(...)
        end
    end
end
