---@class Sounds
local Sounds = QuestieLoader:CreateModule("Sounds")

local soundTable = {
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
        -- the commented sounds are not wrath/vanilla
        --["Goblin Male"]                = "Sound/Character/PCGoblinMale/VO_PCGoblinMale_Congratulations01.ogg",
        --["Goblin Female"]              = "Sound/Character/PCGoblinFemale/VO_PCGoblinFemale_Congratulations01.ogg",
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


local shouldPlayObjectiveSound = false

function Sounds.GetSelectedSoundFile(typeSelected)
    return soundTable[typeSelected]
end

function Sounds.PlayObjectiveComplete()
    if (not Questie.db.char.soundOnObjectiveComplete) then
        return
    end

    if (not shouldPlayObjectiveSound) then
        shouldPlayObjectiveSound = true
        C_Timer.After(0.5, function ()
            if shouldPlayObjectiveSound then
                PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.char.objectiveCompleteSoundChoiceName), "Master")
                shouldPlayObjectiveSound = false
            end
        end)
    end
end

function Sounds.PlayQuestComplete()
    if (not Questie.db.char.soundOnQuestComplete) then
        return
    end

    shouldPlayObjectiveSound = false
    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.char.questCompleteSoundChoiceName), "Master")
end