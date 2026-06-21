local band = bit.band

-------------------------
--Import modules.
-------------------------
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type EventHandler
local EventHandler = QuestieLoader:ImportModule("EventHandler")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type QuestieValidateGameCache
local QuestieValidateGameCache = QuestieLoader:ImportModule("QuestieValidateGameCache")
---@type QuestieInit
local QuestieInit = QuestieLoader:ImportModule("QuestieInit")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---Called on ADDON_LOADED - Saved Variables are loaded at this point
function Questie:OnInitialize()
    -- This has to happen OnInitialize to be available asap
    Questie.db = LibStub("AceDB-3.0"):New("QuestieConfig", QuestieOptionsDefaults:Load(), true)

    -- These events basically all mean the same: The active profile changed.
    Questie.db.RegisterCallback(Questie, "OnProfileChanged", "RefreshConfig")
    Questie.db.RegisterCallback(Questie, "OnProfileCopied", "RefreshConfig")
    Questie.db.RegisterCallback(Questie, "OnProfileReset", "RefreshConfig")

    EventHandler:RegisterEarlyEvents()

    QuestieInit.OnAddonLoaded()
end

function Questie:OnEnable()
    if Expansions.Current >= Expansions.Wotlk then
        -- Called when the addon is enabled
        if (Questie.db.profile.trackerEnabled and not Questie.db.profile.showBlizzardQuestTimer) then
            QuestieCompat.HideWatchFrame()
        end
    end
end

function Questie:OnDisable()
    if Expansions.Current >= Expansions.Wotlk then
        -- Called when the addon is disabled
        QuestieCompat.ShowWatchFrame()
    end
end

function Questie:RefreshConfig(_, db, profileName)
    Questie:SetIcons()
    QuestieQuest:SmoothReset()
    TrackerBaseFrame:OnProfileChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "Switched Ace Profile!")
end

---@class QuestieColor
---@field hex string Six-character RGB hex color used in WoW color escape sequences.
---@field rgb number[] Normalized RGB components, ordered as `{r, g, b}` for WoW tooltip APIs.

---@alias QuestieNamedColor
---| "red"
---| "gray"
---| "purple"
---| "blue"
---| "lightBlue"
---| "reputationBlue"
---| "repeatableBlue"
---| "yellow"
---| "orange"
---| "green"
---| "white"
---| "gold"
---| "lime"
---| "pvpRed"

---Creates a named color entry from a six-character RGB hex string.
---@param hex string Six-character RGB hex color.
---@return QuestieColor color
local function Color(hex)
    local r, g, b = string.match(hex, "^(%x%x)(%x%x)(%x%x)$")

    return {
        hex = hex,
        rgb = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255},
    }
end

---@type table<QuestieNamedColor, QuestieColor>
local COLORS = {
    red = Color("ff0000"),
    gray = Color("a6a6a6"),
    purple = Color("B900FF"),
    blue = Color("0000FF"),
    lightBlue = Color("00BBFF"),
    reputationBlue = Color("8080ff"),
    repeatableBlue = Color("21CCE7"),
    yellow = Color("ffff00"),
    orange = Color("FF6F22"),
    green = Color("00ff00"),
    white = Color("ffffff"),
    gold = Color("ffd100"), -- this is the default game color
    lime = Color("6ce314"), -- holiday green
    pvpRed = Color("E35639"),
}

---Colorizes a string with a color code.
---@param str string @The string to colorize.
---@param color QuestieNamedColor|string? @Named color or hex string in the format "RRGGBB".
---@return string colorizedText
function Questie:Colorize(str, color)
    if not color then
        color = "yellow"
    end

    local namedColor = COLORS[color]
    local hex = namedColor and namedColor.hex or color

    return "|cFF" .. hex .. str .. "|r"
end

---Returns the requested color as normalized RGB components.
---@param color string? @Named color, "RRGGBB", "AARRGGBB", or "|cAARRGGBB..." color string.
---@return number? r @Red component, or nil for invalid input.
---@return number? g @Green component, or nil for invalid input.
---@return number? b @Blue component, or nil for invalid input.
function Questie:ColorizeRGB(color)
    if color == nil then
        color = "yellow"
    end

    local namedColor = COLORS[color]
    if namedColor then
        return namedColor.rgb[1], namedColor.rgb[2], namedColor.rgb[3]
    end

    if type(color) ~= "string" then
        return nil, nil, nil
    end

    local hex = string.match(color, "^|[cC]%x%x(%x%x%x%x%x%x)") or string.match(color, "^%x%x(%x%x%x%x%x%x)$") or color
    if not string.match(hex, "^%x%x%x%x%x%x$") then
        return nil, nil, nil
    end

    local rgb = Color(hex).rgb
    return rgb[1], rgb[2], rgb[3]
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
    if Questie.db.profile.debugEnabled then -- prints regardless of "debugPrint" toggle
        Questie:Print("|cffffff00[WARNING]|r", ...)
    end
end

-- Global debug levels
-- When adding a new level here it MUST be assigned a corresponding number and name in
-- `debugLevel.values` of QuestieOptionsAdvanced.lua as well as text in Questie:Debug below
Questie.DEBUG_CRITICAL = 2 ^ 0
Questie.DEBUG_ELEVATED = 2 ^ 1
Questie.DEBUG_INFO = 2 ^ 2
Questie.DEBUG_DEVELOP = 2 ^ 3
Questie.DEBUG_SPAM = 2 ^ 4

function Questie:Debug(msgDebugLevel, ...)
    if (Questie.db.profile.debugEnabled) then
        local optionsDebugLevel = Questie.db.profile.debugLevel

        if (band(optionsDebugLevel, msgDebugLevel) == 0) or (not Questie.db.profile.debugEnabledPrint) then
            return
        end

        local prefix = ""
        if (band(msgDebugLevel, Questie.DEBUG_CRITICAL) ~= 0) then prefix = prefix.."|cff00f2e6[CRITICAL]|r" end
        if (band(msgDebugLevel, Questie.DEBUG_ELEVATED) ~= 0) then prefix = prefix.."|cffebf441[ELEVATED]|r" end
        if (band(msgDebugLevel, Questie.DEBUG_INFO) ~= 0) then prefix = prefix.."|cff00bc32[INFO]|r" end
        if (band(msgDebugLevel, Questie.DEBUG_DEVELOP) ~= 0) then prefix = prefix.."|cff7c83ff[DEVELOP]|r" end
        if (band(msgDebugLevel, Questie.DEBUG_SPAM) ~= 0) then prefix = prefix.."|cffff8484[SPAM]|r" end

        Questie:Print(prefix, ...)
    end
end

Questie.icons = {
    ["slay"] = "Interface\\Addons\\Questie\\Icons\\slay.blp",
    ["loot"] = "Interface\\Addons\\Questie\\Icons\\loot.blp",
    ["event"] = "Interface\\Addons\\Questie\\Icons\\event.blp",
    ["object"] = "Interface\\Addons\\Questie\\Icons\\object.blp",
    ["talk"] = "Interface\\Addons\\Questie\\Icons\\chatbubblegossipicon.blp",
    ["available"] = "Interface\\Addons\\Questie\\Icons\\available.blp",
    ["available_gray"] = "Interface\\Addons\\Questie\\Icons\\available_gray.blp",
    ["complete"] = "Interface\\Addons\\Questie\\Icons\\complete.blp",
    ["incomplete"] = "Interface\\Addons\\Questie\\Icons\\incomplete.blp",
    ["interact"] = "Interface\\Addons\\Questie\\Icons\\interact.blp",
    ["mount_up"] = "Interface\\Addons\\Questie\\Icons\\mount_up.blp",
    ["glow"] = "Interface\\Addons\\Questie\\Icons\\glow.blp",
    ["repeatable"] = "Interface\\Addons\\Questie\\Icons\\repeatable.blp",
    ["repeatable_complete"] = "Interface\\Addons\\Questie\\Icons\\repeatable_complete.blp",
    ["eventquest"] = "Interface\\Addons\\Questie\\Icons\\eventquest.blp",
    ["eventquest_complete"] = "Interface\\Addons\\Questie\\Icons\\eventquest_complete.blp",
    ["pvpquest"] = "Interface\\Addons\\Questie\\Icons\\pvpquest.blp",
    ["pvpquest_complete"] = "Interface\\Addons\\Questie\\Icons\\pvpquest_complete.blp",
    ["node"] = "Interface\\Addons\\Questie\\Icons\\node.tga",
    ["player"] = "Interface\\WorldMap\\WorldMapPartyIcon",
    ["fav"] = "Interface\\Addons\\Questie\\Icons\\fav.tga",
    ["hand"] = "Interface\\Addons\\Questie\\Icons\\hand.blp",
    ["faction_alliance"] = "Interface\\Addons\\Questie\\Icons\\icon_alliance.tga",
    ["faction_horde"] = "Interface\\Addons\\Questie\\Icons\\icon_horde.tga",
    ["loot_mono"] = "Interface\\Addons\\Questie\\Icons\\loot_mono.tga",
    ["node_cut"] = "Interface\\Addons\\Questie\\Icons\\node_cut.tga",
    ["object_mono"] = "Interface\\Addons\\Questie\\Icons\\object_mono.tga",
    ["route"] = "Interface\\Addons\\Questie\\Icons\\route.tga",
    ["slay_mono"] = "Interface\\Addons\\Questie\\Icons\\slay_mono.tga",
    ["sod_rune"] = "Interface\\Addons\\Questie\\Icons\\sod_rune.tga",
    ["startend"] = "Interface\\Addons\\Questie\\Icons\\startend.tga",
    ["startendstart"] = "Interface\\Addons\\Questie\\Icons\\startendstart.tga",
    ["tracker_clean"] = "Interface\\Addons\\Questie\\Icons\\tracker_clean.tga",
    ["tracker_close"] = "Interface\\Addons\\Questie\\Icons\\tracker_close.tga",
    ["tracker_database"] = "Interface\\Addons\\Questie\\Icons\\tracker_database.tga",
    ["tracker_giver"] = "Interface\\Addons\\Questie\\Icons\\tracker_giver.tga",
    ["tracker_quests"] = "Interface\\Addons\\Questie\\Icons\\tracker_quests.tga",
    ["tracker_search"] = "Interface\\Addons\\Questie\\Icons\\tracker_search.tga",
    ["tracker_settings"] = "Interface\\Addons\\Questie\\Icons\\tracker_settings.tga",
    ["node_fish"] = "Interface\\Addons\\Questie\\Icons\\node_fish.blp",
    ["node_herb"] = "Interface\\Addons\\Questie\\Icons\\node_herb.blp",
    ["node_ore"] = "Interface\\Addons\\Questie\\Icons\\node_ore.blp",
    ["chest"] = "Interface\\Addons\\Questie\\Icons\\chest.blp",
    ["petbattle"] = "Interface\\Addons\\Questie\\Icons\\petbattle.png",
}

Questie.usedIcons = {}

Questie.ICON_TYPE_SLAY = 1
Questie.ICON_TYPE_LOOT = 2
Questie.ICON_TYPE_EVENT = 3
Questie.ICON_TYPE_OBJECT = 4
Questie.ICON_TYPE_TALK = 5
Questie.ICON_TYPE_AVAILABLE = 6
Questie.ICON_TYPE_AVAILABLE_GRAY = 7
Questie.ICON_TYPE_COMPLETE = 8
Questie.ICON_TYPE_GLOW = 9
Questie.ICON_TYPE_REPEATABLE = 10
Questie.ICON_TYPE_REPEATABLE_COMPLETE = 11
Questie.ICON_TYPE_INCOMPLETE = 12
Questie.ICON_TYPE_EVENTQUEST = 13
Questie.ICON_TYPE_EVENTQUEST_COMPLETE = 14
Questie.ICON_TYPE_PVPQUEST = 15
Questie.ICON_TYPE_PVPQUEST_COMPLETE = 16
Questie.ICON_TYPE_INTERACT = 17
Questie.ICON_TYPE_SODRUNE = 18
Questie.ICON_TYPE_MOUNT_UP = 19
Questie.ICON_TYPE_NODE_FISH = 20
Questie.ICON_TYPE_NODE_HERB = 21
Questie.ICON_TYPE_NODE_ORE = 22
Questie.ICON_TYPE_CHEST = 23
Questie.ICON_TYPE_PET_BATTLE = 24

-- Load icon pathes from SavedVariables or set the default ones
function Questie.SetIcons()
    Questie.usedIcons[Questie.ICON_TYPE_SLAY] = Questie.db.profile.ICON_SLAY or Questie.icons["slay"]
    Questie.usedIcons[Questie.ICON_TYPE_LOOT] = Questie.db.profile.ICON_LOOT or Questie.icons["loot"]
    Questie.usedIcons[Questie.ICON_TYPE_EVENT] = Questie.db.profile.ICON_EVENT or Questie.icons["event"]
    Questie.usedIcons[Questie.ICON_TYPE_OBJECT] = Questie.db.profile.ICON_OBJECT or Questie.icons["object"]
    Questie.usedIcons[Questie.ICON_TYPE_TALK] = Questie.db.profile.ICON_TALK or Questie.icons["talk"]
    Questie.usedIcons[Questie.ICON_TYPE_AVAILABLE] = Questie.db.profile.ICON_AVAILABLE or Questie.icons["available"]
    Questie.usedIcons[Questie.ICON_TYPE_AVAILABLE_GRAY] = Questie.db.profile.ICON_AVAILABLE_GRAY or Questie.icons["available_gray"]
    Questie.usedIcons[Questie.ICON_TYPE_COMPLETE] = Questie.db.profile.ICON_COMPLETE or Questie.icons["complete"]
    Questie.usedIcons[Questie.ICON_TYPE_INCOMPLETE] = Questie.db.profile.ICON_INCOMPLETE or Questie.icons["incomplete"]
    Questie.usedIcons[Questie.ICON_TYPE_GLOW] = Questie.db.profile.ICON_GLOW or Questie.icons["glow"]
    Questie.usedIcons[Questie.ICON_TYPE_REPEATABLE] = Questie.db.profile.ICON_REPEATABLE or Questie.icons["repeatable"]
    Questie.usedIcons[Questie.ICON_TYPE_REPEATABLE_COMPLETE] = Questie.db.profile.ICON_REPEATABLE_COMPLETE or Questie.icons["repeatable_complete"]
    Questie.usedIcons[Questie.ICON_TYPE_EVENTQUEST] = Questie.db.profile.ICON_EVENTQUEST or Questie.icons["eventquest"]
    Questie.usedIcons[Questie.ICON_TYPE_EVENTQUEST_COMPLETE] = Questie.db.profile.ICON_EVENTQUEST_COMPLETE or Questie.icons["eventquest_complete"]
    Questie.usedIcons[Questie.ICON_TYPE_PVPQUEST] = Questie.db.profile.ICON_PVPQUEST or Questie.icons["pvpquest"]
    Questie.usedIcons[Questie.ICON_TYPE_PVPQUEST_COMPLETE] = Questie.db.profile.ICON_PVPQUEST_COMPLETE or Questie.icons["pvpquest_complete"]
    Questie.usedIcons[Questie.ICON_TYPE_INTERACT] = Questie.db.profile.ICON_INTERACT or Questie.icons["interact"]
    Questie.usedIcons[Questie.ICON_TYPE_SODRUNE] = Questie.icons["sod_rune"]
    Questie.usedIcons[Questie.ICON_TYPE_MOUNT_UP] = Questie.icons["mount_up"]
    Questie.usedIcons[Questie.ICON_TYPE_NODE_FISH] = Questie.icons["node_fish"]
    Questie.usedIcons[Questie.ICON_TYPE_NODE_HERB] = Questie.icons["node_herb"]
    Questie.usedIcons[Questie.ICON_TYPE_NODE_ORE] = Questie.icons["node_ore"]
    Questie.usedIcons[Questie.ICON_TYPE_CHEST] = Questie.icons["chest"]
    Questie.usedIcons[Questie.ICON_TYPE_PET_BATTLE] = Questie.db.profile.ICON_TYPE_PET_BATTLE or Questie.icons["petbattle"]
end

function Questie:GetIconNameFromPath(path)
    for k, v in pairs(Questie.icons) do
        if path == v then return k end
    end
end

Questie.LOWLEVEL_NONE = 1
Questie.LOWLEVEL_ALL = 2
Questie.LOWLEVEL_OFFSET = 3
Questie.LOWLEVEL_RANGE = 4

-- Start checking the game's cache.
QuestieValidateGameCache.StartCheck()