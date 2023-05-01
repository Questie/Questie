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
    if Questie.IsWotlk then
        -- Called when the addon is enabled
        if (Questie.db.char.trackerEnabled and not Questie.db.global.showBlizzardQuestTimer) then
            WatchFrame:Hide()
        end
    end
end

function Questie:OnDisable()
    if Questie.IsWotlk then
        -- Called when the addon is disabled
        WatchFrame:Show()
    end
end

--- Colorize a string with a color code
---@param str string @The string colorize
--Name or string in the format "RRGGBB" i.e "FF0000" for red
---@param color "red"|"gray"|"purple"|"blue"|"lightBlue"|"reputationBlue"|"yellow"|"orange"|"green"|"white"|"gold"|string
---@return string
function Questie:Colorize(str, color)
    local c = "|cFF" .. color;

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
        if ((band(optionsDebugLevel, 2 ^ 4) == 0) and (msgDebugLevel == Questie.DEBUG_SPAM)) then return; end
        if ((band(optionsDebugLevel, 2 ^ 3) == 0) and (msgDebugLevel == Questie.DEBUG_DEVELOP)) then return; end
        if ((band(optionsDebugLevel, 2 ^ 2) == 0) and (msgDebugLevel == Questie.DEBUG_INFO)) then return; end
        if ((band(optionsDebugLevel, 2 ^ 1) == 0) and (msgDebugLevel == Questie.DEBUG_ELEVATED)) then return; end
        if ((band(optionsDebugLevel, 2 ^ 0) == 0) and (msgDebugLevel == Questie.DEBUG_CRITICAL)) then return; end

        if Questie.db.global.debugEnabledPrint then
            Questie:Print(...)
        end
    end
end

Questie.sounds = {
        ["None"]                       = nil ,
        ["QuestDefault"]               = "Sound/Creature/Peon/PeonBuildingComplete1.ogg",
        ["Troll Male"]                 = "Sound/Character/Troll/TrollVocalMale/TrollMaleCongratulations01.ogg",
        ["Troll Female"]               = "Sound/Character/Troll/TrollVocalFemale/TrollFemaleCongratulations01.ogg",
        ["Tauren Male"]                = "Sound/Creature/Tauren/TaurenYes3.ogg",
        ["Tauren Female"]              = "Sound/Character/Tauren/TaurenVocalFemale/TaurenFemaleCongratulations01.ogg",
        ["Undead Male"]                = "Sound/Character/Scourge/ScourgeVocalMale/UndeadMaleCongratulations02.ogg",
        ["Undead Female"]              = "Sound/Character/Scourge/ScourgeVocalFemale/UndeadFemaleCongratulations01.ogg",
        ["Orc Male"]                   = "Sound/Character/Orc/OrcVocalMale/OrcMaleCongratulations02.ogg",
        ["Orc Female"]                 = "Sound/Character/Orc/OrcVocalFemale/OrcFemaleCongratulations01.ogg",
        ["NightElf Female"]            = "Sound/Character/NightElf/NightElfVocalFemale/NightElfFemaleCongratulations02.ogg",
        ["NightElf Male"]              = "Sound/Character/NightElf/NightElfVocalMale/NightElfMaleCongratulations01.ogg",
        ["Human Female"]               = "Sound/Character/Human/HumanVocalFemale/HumanFemaleCongratulations01.ogg",
        ["Human Male"]                 = "Sound/Character/Human/HumanVocalMale/HumanMaleCongratulations01.ogg",
        ["Gnome Male"]                 = "Sound/Character/Gnome/GnomeVocalMale/GnomeMaleCongratulations03.ogg",
        ["Gnome Female"]               = "Sound/Character/Gnome/GnomeVocalFemale/GnomeFemaleCongratulations01.ogg",
        ["Dwarf Male"]                 = "Sound/Character/Dwarf/DwarfVocalMale/DwarfMaleCongratulations04.ogg",
        ["Dwarf Female"]               = "Sound/Character/Dwarf/DwarfVocalFemale/DwarfFemaleCongratulations01.ogg",
        ["Draenei Male"]               = "Sound/Character/Draenei/DraeneiMaleCongratulations02.ogg",
        ["Draenei Female"]             = "Sound/Character/Draenei/DraeneiFemaleCongratulations03.ogg",
        ["BloodElf Female"]            = "Sound/Character/BloodElf/BloodElfFemaleCongratulations03.ogg",
        ["BloodElf Male"]              = "Sound/Character/BloodElf/BloodElfMaleCongratulations02.ogg",
        ["Goblin Male"]                = "Sound/Character/PCGoblinMale/VO_PCGoblinMale_Congratulations01.ogg",
        ["Goblin Female"]              = "Sound/Character/PCGoblinFemale/VO_PCGoblinFemale_Congratulations01.ogg",
        -- the commented sounds are not wrath/vanilla
        --["Worgen Male"]                = "Sound/Character/PCWorgenMale/VO_PCWorgenMale_Congratulations01.ogg",
        --["Worgen Female"]              = "Sound/Character/PCWorgenFemale/VO_PCWorgenFemale_Congratulations01.ogg",
        --["Pandaren Male"]              = "Sound/Character/PCPandarenMale/VO_PCPandarenMale_Congratulations02.ogg",
        --["Pandaren Female"]            = "Sound/Character/PCPandarenFemale/VO_PCPandarenFemale_Congratulations02.ogg",	
        --["Void Elf Male"]              = "Sound/Character/pc_-_void_elf_male/vo_735_pc_-_void_elf_male_28_m.ogg",
        --["Void Elf Female"]            = "Sound/Character/pc_-_void_elf_female/vo_735_pc_-_void_elf_female_28_f.ogg",
        --["Highmountain Tauren Male"]   = "Sound/Character/pc_-_highmountain_tauren_male/vo_735_pc_-_highmountain_tauren_male_28_m.ogg",
        --["Highmountain Tauren Female"] = "Sound/Character/pc_-_highmountain_tauren_female/vo_735_pc_-_highmountain_tauren_female_28_f.ogg",
        --["Lightforged Draenei Male"]   = "Sound/Character/pc_-_lightforged_draenei_male/vo_735_pc_-_lightforged_draenei_male_28_m.ogg",
        --["Lightforged Draenei Female"] = "sound/character/pc_-_lightforged_draenei_female/vo_735_pc_-_lightforged_draenei_female_28_f.ogg",
        --["Nightborne Male"]            = "Sound/Character/pc_-_nightborne_elf_male/vo_735_pc_-_nightborne_elf_male_28_m.ogg",
        --["Nightborne Female"]          = "Sound/Character/pc_-_nightborne_elf_female/vo_735_pc_-_nightborne_elf_female_28_f.ogg",        
        --["Dark Iron Dwarf Male"]       = "Sound/Character/pc_dark_iron_dwarf_male/vo_801_pc_dark_iron_dwarf_male_284_m.ogg",
        --["Dark Iron Dwarf Female"]     = "Sound/Character/pc_dark_iron_dwarf_female/vo_801_pc_dark_iron_dwarf_female_284_f.ogg",
        --["Mag'har Orc Male"]           = "Sound/Character/pc_maghar_orc_male/vo_801_pc_maghar_orc_male_114_m.ogg",
        --["Mag'har Orc Female"]         = "Sound/Character/pc_maghar_orc_female/vo_801_pc_maghar_orc_female_114_f.ogg",
        ["ObjectiveDefault"]   = "Sound/Interface/iquestupdate.ogg",
        ["Map Ping"]           = "Sound/Interface/MapPing.ogg",
        ["Window Close"]       = "Sound/Interface/AuctionWindowClose.ogg",
        ["Window Open"]        = "Sound/Interface/AuctionWindowOpen.ogg",
        ["Boat Docked"]        = "Sound/Doodad/BoatDockedWarning.ogg",
        ["Bell Toll Alliance"] = "Sound/Doodad/BellTollAlliance.ogg",
        ["Bell Toll Horde"]    = "Sound/Doodad/BellTollHorde.ogg",
        ["Explosion"]          = "Sound/Doodad/Hellfire_Raid_FX_Explosion05.ogg",
        ["Shing!"]             = "Sound/Doodad/PortcullisActive_Closed.ogg",
        ["Wham!"]              = "Sound/Doodad/PVP_Lordaeron_Door_Open.ogg",
        ["Simon Chime"]        = "Sound/Doodad/SimonGame_LargeBlueTree.ogg",
        ["War Drums"]          = "Sound/Event Sounds/Event_wardrum_ogre.ogg",
        ["Humm"]               = "Sound/Spells/SimonGame_Visual_GameStart.ogg",
        ["Short Circuit"]      = "Sound/Spells/SimonGame_Visual_BadPress.ogg",
}

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
    ["faction_alliance"] = "Interface\\Addons\\Questie\\Icons\\icon_alliance.tga",
    ["faction_horde"] = "Interface\\Addons\\Questie\\Icons\\icon_horde.tga",
    ["loot_mono"] = "Interface\\Addons\\Questie\\Icons\\loot_mono.tga",
    ["node_cut"] = "Interface\\Addons\\Questie\\Icons\\node_cut.tga",
    ["object_mono"] = "Interface\\Addons\\Questie\\Icons\\object_mono.tga",
    ["route"] = "Interface\\Addons\\Questie\\Icons\\route.tga",
    ["slay_mono"] = "Interface\\Addons\\Questie\\Icons\\slay_mono.tga",
    ["startend"] = "Interface\\Addons\\Questie\\Icons\\startend.tga",
    ["startendstart"] = "Interface\\Addons\\Questie\\Icons\\startendstart.tga",
    ["tracker_clean"] = "Interface\\Addons\\Questie\\Icons\\tracker_clean.tga",
    ["tracker_close"] = "Interface\\Addons\\Questie\\Icons\\tracker_close.tga",
    ["tracker_database"] = "Interface\\Addons\\Questie\\Icons\\tracker_database.tga",
    ["tracker_giver"] = "Interface\\Addons\\Questie\\Icons\\tracker_giver.tga",
    ["tracker_quests"] = "Interface\\Addons\\Questie\\Icons\\tracker_quests.tga",
    ["tracker_search"] = "Interface\\Addons\\Questie\\Icons\\tracker_search.tga",
    ["tracker_settings"] = "Interface\\Addons\\Questie\\Icons\\tracker_settings.tga",
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

-- Load icon pathes from SavedVariables or set the default ones
function Questie:SetIcons()
    Questie.usedIcons[Questie.ICON_TYPE_SLAY] = Questie.db.global.ICON_SLAY or Questie.icons["slay"]
    Questie.usedIcons[Questie.ICON_TYPE_LOOT] = Questie.db.global.ICON_LOOT or Questie.icons["loot"]
    Questie.usedIcons[Questie.ICON_TYPE_EVENT] = Questie.db.global.ICON_EVENT or Questie.icons["event"]
    Questie.usedIcons[Questie.ICON_TYPE_OBJECT] = Questie.db.global.ICON_OBJECT or Questie.icons["object"]
    Questie.usedIcons[Questie.ICON_TYPE_TALK] = Questie.db.global.ICON_TALK or Questie.icons["talk"]
    Questie.usedIcons[Questie.ICON_TYPE_AVAILABLE] = Questie.db.global.ICON_AVAILABLE or Questie.icons["available"]
    Questie.usedIcons[Questie.ICON_TYPE_AVAILABLE_GRAY] = Questie.db.global.ICON_AVAILABLE_GRAY or Questie.icons["available_gray"]
    Questie.usedIcons[Questie.ICON_TYPE_COMPLETE] = Questie.db.global.ICON_COMPLETE or Questie.icons["complete"]
    Questie.usedIcons[Questie.ICON_TYPE_INCOMPLETE] = Questie.db.global.ICON_INCOMPLETE or Questie.icons["incomplete"]
    Questie.usedIcons[Questie.ICON_TYPE_GLOW] = Questie.db.global.ICON_GLOW or Questie.icons["glow"]
    Questie.usedIcons[Questie.ICON_TYPE_REPEATABLE] = Questie.db.global.ICON_REPEATABLE or Questie.icons["repeatable"]
    Questie.usedIcons[Questie.ICON_TYPE_REPEATABLE_COMPLETE] = Questie.db.global.ICON_REPEATABLE_COMPLETE or Questie.icons["complete"]
    Questie.usedIcons[Questie.ICON_TYPE_EVENTQUEST] = Questie.db.global.ICON_EVENTQUEST or Questie.icons["eventquest"]
    Questie.usedIcons[Questie.ICON_TYPE_EVENTQUEST_COMPLETE] = Questie.db.global.ICON_EVENTQUEST_COMPLETE or Questie.icons["complete"]
    Questie.usedIcons[Questie.ICON_TYPE_PVPQUEST] = Questie.db.global.ICON_PVPQUEST or Questie.icons["pvpquest"]
    Questie.usedIcons[Questie.ICON_TYPE_PVPQUEST_COMPLETE] = Questie.db.global.ICON_PVPQUEST_COMPLETE or Questie.icons["complete"]
    Questie.usedIcons[Questie.ICON_TYPE_INTERACT] = Questie.db.global.ICON_TYPE_INTERACT or Questie.icons["interact"]
end

function Questie:GetIconNameFromPath(path)
    for k, v in pairs(Questie.icons) do
        if path == v then return k end
    end
end

-- Start checking the game's cache.
QuestieValidateGameCache.StartCheck()
