
-- Global debug levels, see bottom of this file and `debugLevel` in QuestieOptionsAdvanced.lua for relevant code
-- When adding a new level here it MUST be assigned a number and name in `debugLevel.values` as well added to Questie:Debug below
Questie.DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
Questie.DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
Questie.DEBUG_INFO = "|cff00bc32[INFO]|r"
Questie.DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
Questie.DEBUG_SPAM = "|cffff8484[SPAM]|r"

local band = bit.band

-------------------------
--Import modules.
-------------------------
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieEventHandler
local QuestieEventHandler = QuestieLoader:ImportModule("QuestieEventHandler");
---@type QuestieValidateGameCache
local QuestieValidateGameCache = QuestieLoader:ImportModule("QuestieValidateGameCache")


function Questie:OnInitialize()
    -- This has to happen OnInitialize to be available asap
    Questie.db = LibStub("AceDB-3.0"):New("QuestieConfig", QuestieOptionsDefaults:Load(), true)

    QuestieEventHandler:RegisterEarlyEvents()
end

function Questie:OnEnable()
    -- Called when the addon is enabled
end

function Questie:OnDisable()
    -- Called when the addon is disabled
end

--- Colorize a string with a color code
---@param str string @The string colorize
--Name or string in the format "RRGGBB" i.e "FF0000" for red
---@param color "red"|"gray"|"purple"|"blue"|"lightBlue"|"reputationBlue"|"yellow"|"orange"|"green"|"white"|"gold"|string
---@return string
function Questie:Colorize(str, color)
    local c = "|cFF"..color;

    if color == "red" then
        c = "|cFFff0000";
    elseif color == "gray" then
        c = "|cFFa6a6a6";
    elseif color == "purple" then
        c = "|cFFB900FF";
    elseif color == "blue" then
        c = "|cB900FFFF";
    elseif color == "lightBlue" then
        c = "|cB900FFFF";
    elseif color == "reputationBlue" then
        c = "|cFF8080ff";
    elseif color == "yellow" then
        c = "|cFFffff00";
    elseif color == "orange" then
        c = "|cFFFF6F22";
    elseif color == "green" then
        c = "|cFF00ff00";
    elseif color == "white" then
        c = "|cFFffffff";
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
    if (Questie.db.global.debugEnabled) then
        local optionsDebugLevel = Questie.db.global.debugLevel
        local msgDebugLevel = select(1, ...)
        -- Exponents are defined by `debugLevel.values` in QuestieOptionsAdvanced.lua
        -- DEBUG_CRITICAL = 0
        -- DEBUG_ELEVATED = 1
        -- DEBUG_INFO = 2
        -- DEBUG_DEVELOP = 3
        -- DEBUG_SPAM = 4
        if ((band(optionsDebugLevel, 2^4) == 0) and (msgDebugLevel == Questie.DEBUG_SPAM)) then return; end
        if ((band(optionsDebugLevel, 2^3) == 0) and (msgDebugLevel == Questie.DEBUG_DEVELOP)) then return; end
        if ((band(optionsDebugLevel, 2^2) == 0) and (msgDebugLevel == Questie.DEBUG_INFO)) then return; end
        if ((band(optionsDebugLevel, 2^1) == 0) and (msgDebugLevel == Questie.DEBUG_ELEVATED)) then return; end
        if ((band(optionsDebugLevel, 2^0) == 0) and (msgDebugLevel == Questie.DEBUG_CRITICAL)) then return; end

        if Questie.db.global.debugEnabledPrint then
            Questie:Print(...)
        end
    end
end

-- Start checking the game's cache.
QuestieValidateGameCache.StartCheck()
