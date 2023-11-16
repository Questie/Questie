---@class Sounds
local Sounds = QuestieLoader:CreateModule("Sounds")

local soundTable
local shouldPlayObjectiveSound = false
local shouldPlayObjectiveProgress = false

function Sounds.PlayObjectiveProgress()
    if (not Questie.db.char.soundOnObjectiveProgress) then
        return
    end

    if (not shouldPlayObjectiveProgress) then
        shouldPlayObjectiveProgress = true
        C_Timer.After(0.5, function ()
            if shouldPlayObjectiveProgress then
                PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.char.objectiveProgressSoundChoiceName), "Master")
                shouldPlayObjectiveProgress = false
            end
        end)
    end
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
    shouldPlayObjectiveProgress = false
    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.char.questCompleteSoundChoiceName), "Master")
end

function Sounds.GetSelectedSoundFile(typeSelected)
    return soundTable[typeSelected]
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
    ["Night Elf Female"]   = "Sound/Character/NightElf/NightElfVocalFemale/NightElfFemaleCongratulations02.ogg",
    ["Night Elf Male"]     = "Sound/Character/NightElf/NightElfVocalMale/NightElfMaleCongratulations01.ogg",
    ["Human Female"]       = "Sound/Character/Human/HumanVocalFemale/HumanFemaleCongratulations01.ogg",
    ["Human Male"]         = "Sound/Character/Human/HumanVocalMale/HumanMaleCongratulations01.ogg",
    ["Gnome Male"]         = "Sound/Character/Gnome/GnomeVocalMale/GnomeMaleCongratulations03.ogg",
    ["Gnome Female"]       = "Sound/Character/Gnome/GnomeVocalFemale/GnomeFemaleCongratulations01.ogg",
    ["Dwarf Male"]         = "Sound/Character/Dwarf/DwarfVocalMale/DwarfMaleCongratulations04.ogg",
    ["Dwarf Female"]       = "Sound/Character/Dwarf/DwarfVocalFemale/DwarfFemaleCongratulations01.ogg",
    ["Draenei Male"]       = "Sound/Character/Draenei/DraeneiMaleCongratulations02.ogg",
    ["Draenei Female"]     = "Sound/Character/Draenei/DraeneiFemaleCongratulations03.ogg",
    ["Blood Elf Female"]   = "Sound/Character/BloodElf/BloodElfFemaleCongratulations03.ogg",
    ["Blood Elf Male"]     = "Sound/Character/BloodElf/BloodElfMaleCongratulations02.ogg",
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