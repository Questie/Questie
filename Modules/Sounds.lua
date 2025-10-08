---@class Sounds
local Sounds = QuestieLoader:CreateModule("Sounds")

local LSM30 = LibStub("LibSharedMedia-3.0")

local soundTable
local shouldPlayObjectiveProgress = false
local shouldPlayObjectiveComplete = false

function Sounds.PlayObjectiveProgress()
    if (not Questie.db.profile.soundOnObjectiveProgress) then
        return
    end

    if (not shouldPlayObjectiveProgress) then
        shouldPlayObjectiveProgress = true
        C_Timer.After(Questie.db.profile.soundDelay, function ()
            if shouldPlayObjectiveProgress then
                PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveProgressSoundChoiceName), "Master")
                shouldPlayObjectiveProgress = false
            end
        end)
    end
end

function Sounds.PlayObjectiveComplete()
    if (not Questie.db.profile.soundOnObjectiveComplete) then
        return
    end

    if (not shouldPlayObjectiveComplete) then
        shouldPlayObjectiveComplete = true
        C_Timer.After(Questie.db.profile.soundDelay, function ()
            if shouldPlayObjectiveComplete then
                PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveCompleteSoundChoiceName), "Master")
                shouldPlayObjectiveComplete = false
            end
        end)
    end
end

function Sounds.PlayQuestComplete()
    if (not Questie.db.profile.soundOnQuestComplete) then
        return
    end

    shouldPlayObjectiveProgress = false
    shouldPlayObjectiveComplete = false
    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), "Master")
end

function Sounds.GetSelectedSoundFile(typeSelected)
    local soundFile = soundTable[typeSelected]
    if (not soundFile) then
        soundFile = LSM30:Fetch("sound", typeSelected)
    end
    return soundFile
end

soundTable = {
    ["QuestDefault"]       = "Sound/Creature/Peon/PeonBuildingComplete1.ogg",
    ["GameDefault"]        = "Sound/Interface/iquestcomplete.ogg",
    ["Troll Male"]         = "Sound/Character/Troll/TrollVocalMale/TrollMaleCongratulations01.ogg",
    ["Troll Female"]       = "Sound/Character/Troll/TrollVocalFemale/TrollFemaleCongratulations01.ogg",
    ["Tauren Male"]        = "Sound/Creature/Tauren/TaurenYes3.ogg",
    ["Tauren Female"]      = "Sound/Character/Tauren/TaurenVocalFemale/TaurenFemaleCongratulations01.ogg",
    ["Undead Male"]        = "Sound/Character/Scourge/ScourgeVocalMale/UndeadMaleCongratulations02.ogg",
    ["Undead Female"]      = "Sound/Character/Scourge/ScourgeVocalFemale/UndeadFemaleCongratulations01.ogg",
    ["Orc Male"]           = "Sound/Character/Orc/OrcVocalMale/OrcMaleCongratulations02.ogg",
    ["Orc Female"]         = "Sound/Character/Orc/OrcVocalFemale/OrcFemaleCongratulations01.ogg",
    ["Night Elf Male"]     = "Sound/Character/NightElf/NightElfVocalMale/NightElfMaleCongratulations01.ogg",
    ["Night Elf Female"]   = "Sound/Character/NightElf/NightElfVocalFemale/NightElfFemaleCongratulations02.ogg",
    ["Human Male"]         = "Sound/Character/Human/HumanVocalMale/HumanMaleCongratulations01.ogg",
    ["Human Female"]       = "Sound/Character/Human/HumanVocalFemale/HumanFemaleCongratulations01.ogg",
    ["Gnome Male"]         = "Sound/Character/Gnome/GnomeVocalMale/GnomeMaleCongratulations03.ogg",
    ["Gnome Female"]       = "Sound/Character/Gnome/GnomeVocalFemale/GnomeFemaleCongratulations01.ogg",
    ["Dwarf Male"]         = "Sound/Character/Dwarf/DwarfVocalMale/DwarfMaleCongratulations04.ogg",
    ["Dwarf Female"]       = "Sound/Character/Dwarf/DwarfVocalFemale/DwarfFemaleCongratulations01.ogg",
    ["Draenei Male"]       = "Sound/Character/Draenei/DraeneiMaleCongratulations02.ogg",
    ["Draenei Female"]     = "Sound/Character/Draenei/DraeneiFemaleCongratulations03.ogg",
    ["Blood Elf Male"]     = "Sound/Character/BloodElf/BloodElfMaleCongratulations02.ogg",
    ["Blood Elf Female"]   = "Sound/Character/BloodElf/BloodElfFemaleCongratulations03.ogg",
    ["Goblin Male"]        = "Sound/Character/PCGoblinMale/VO_PCGoblinMale_Congratulations01.ogg",
    ["Goblin Female"]      = "Sound/Character/PCGoblinFEMale/VO_PCGoblinFemale_Congratulations01.ogg",
    ["Worgen Male"]        = "Sound/Character/PCWorgenMale/VO_PCWorgenMale_Cheer01.ogg",
    ["Worgen Female"]      = "Sound/Character/PCWorgenFemale/VO_PCWorgenFemale_Cheer03.ogg",
    ["Gilnean Male"]       = "Sound/Character/PCGilneanMale/VO_PCGilneanMale_Cheer02.ogg",
    ["Gilnean Female"]     = "Sound/Character/PCGilneanFemale/VO_PCGilneanFemale_Cheer01.ogg",
    ["Zug Zug"]            = "Sound/Creature/OrcMaleShadyNPC/OrcMaleShadyNPCGreeting05.ogg",
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
    ["ObjectiveProgress"]  = "Sound/Interface/AuctionWindowOpen.ogg",
}

return Sounds
