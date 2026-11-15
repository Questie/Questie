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
                PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveProgressSoundChoiceName), Questie.db.profile.soundChannel)
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
                PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.objectiveCompleteSoundChoiceName), Questie.db.profile.soundChannel)
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
    PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel)
end

function Sounds.GetSelectedSoundFile(typeSelected)
    local soundFile = soundTable[typeSelected]
    if (not soundFile) then
        soundFile = LSM30:Fetch("sound", typeSelected)
    end
    return soundFile
end

-- Check https://www.wowhead.com/sounds for all available sounds.
-- !!! Make sure to test new/changed sounds across all expansions !!!
soundTable = {
    ["QuestDefault"]       = 558132, -- "Sound/Creature/Peon/PeonBuildingComplete1.ogg",
    ["GameDefault"]        = 567439, -- "Sound/Interface/iquestcomplete.ogg",
    ["Troll Male"]         = 543307, -- "Sound/Character/Troll/TrollVocalMale/TrollMaleCongratulations01.ogg",
    ["Troll Female"]       = 543273, -- "Sound/Character/Troll/TrollVocalFemale/TrollFemaleCongratulations01.ogg",
    ["Tauren Male"]        = 561484, -- "Sound/Creature/Tauren/TaurenYes3.ogg",
    ["Tauren Female"]      = 542997, -- "Sound/Character/Tauren/TaurenVocalFemale/TaurenFemaleCongratulations01.ogg",
    ["Undead Male"]        = 542775, -- "Sound/Character/Scourge/ScourgeVocalMale/UndeadMaleCongratulations02.ogg",
    ["Undead Female"]      = 542684, -- "Sound/Character/Scourge/ScourgeVocalFemale/UndeadFemaleCongratulations01.ogg",
    ["Orc Male"]           = 541401, -- "Sound/Character/Orc/OrcVocalMale/OrcMaleCongratulations02.ogg",
    ["Orc Female"]         = 541317, -- "Sound/Character/Orc/OrcVocalFemale/OrcFemaleCongratulations01.ogg",
    ["Night Elf Male"]     = 541085, -- "Sound/Character/NightElf/NightElfVocalMale/NightElfMaleCongratulations01.ogg",
    ["Night Elf Female"]   = 541031, -- "Sound/Character/NightElf/NightElfVocalFemale/NightElfFemaleCongratulations02.ogg",
    ["Human Male"]         = 540703, -- "Sound/Character/Human/HumanVocalMale/HumanMaleCongratulations01.ogg",
    ["Human Female"]       = 540654, -- "Sound/Character/Human/HumanVocalFemale/HumanFemaleCongratulations01.ogg",
    ["Gnome Male"]         = 540512, -- "Sound/Character/Gnome/GnomeVocalMale/GnomeMaleCongratulations03.ogg",
    ["Gnome Female"]       = 540432, -- "Sound/Character/Gnome/GnomeVocalFemale/GnomeFemaleCongratulations01.ogg",
    ["Dwarf Male"]         = 540042, -- "Sound/Character/Dwarf/DwarfVocalMale/DwarfMaleCongratulations04.ogg",
    ["Dwarf Female"]       = 539981, -- "Sound/Character/Dwarf/DwarfVocalFemale/DwarfFemaleCongratulations01.ogg",
    ["Draenei Male"]       = 539661, -- "Sound/Character/Draenei/DraeneiMaleCongratulations02.ogg",
    ["Draenei Female"]     = 539676, -- "Sound/Character/Draenei/DraeneiFemaleCongratulations03.ogg",
    ["Blood Elf Male"]     = 539400, -- "Sound/Character/BloodElf/BloodElfMaleCongratulations02.ogg",
    ["Blood Elf Female"]   = 539175, -- "Sound/Character/BloodElf/BloodElfFemaleCongratulations03.ogg",
    ["Goblin Male"]        = 542005, -- "Sound/Character/PCGoblinMale/VO_PCGoblinMale_Congratulations01.ogg",
    ["Goblin Female"]      = 541735, -- "Sound/Character/PCGoblinFEMale/VO_PCGoblinFemale_Congratulations01.ogg",
    ["Worgen Male"]        = 542207, -- "Sound/Character/PCWorgenMale/VO_PCWorgenMale_Cheer01.ogg",
    ["Worgen Female"]      = 542104, -- "Sound/Character/PCWorgenFemale/VO_PCWorgenFemale_Cheer03.ogg",
    ["Gilnean Male"]       = 541630, -- "Sound/Character/PCGilneanMale/VO_PCGilneanMale_Cheer02.ogg",
    ["Gilnean Female"]     = 541446, -- "Sound/Character/PCGilneanFemale/VO_PCGilneanFemale_Cheer01.ogg",
    ["Pandaren Male"]      = 630068, -- "Sound/Character/PCPandarenMale/VO_PCPandarenMale_Congratulations01.ogg",
    ["Pandaren Female"]    = 636417, -- "Sound/Character/PCPandarenFemale/VO_PCPandarenFemale_Congratulations01.ogg",
    ["Zug Zug"]            = 557827, -- "Sound/Creature/OrcMaleShadyNPC/OrcMaleShadyNPCGreeting05.ogg",
    ["ObjectiveDefault"]   = 567516, -- "Sound/Interface/iquestupdate.ogg",
    ["Map Ping"]           = 567416, -- "Sound/Interface/MapPing.ogg",
    ["Window Close"]       = 567499, -- "Sound/Interface/AuctionWindowClose.ogg",
    ["Window Open"]        = 567482, -- "Sound/Interface/AuctionWindowOpen.ogg",
    ["Boat Docked"]        = 566652, -- "Sound/Doodad/BoatDockedWarning.ogg",
    ["Bell Toll Alliance"] = 566564, -- "Sound/Doodad/BellTollAlliance.ogg",
    ["Bell Toll Horde"]    = 565853, -- "Sound/Doodad/BellTollHorde.ogg",
    ["Explosion"]          = 566982, -- "Sound/Doodad/Hellfire_Raid_FX_Explosion05.ogg",
    ["Shing!"]             = 566240, -- "Sound/Doodad/PortcullisActive_Closed.ogg",
    ["Wham!"]              = 566946, -- "Sound/Doodad/PVP_Lordaeron_Door_Open.ogg",
    ["Simon Chime"]        = 566076, -- "Sound/Doodad/SimonGame_LargeBlueTree.ogg",
    ["War Drums"]          = 567275, -- "Sound/Event Sounds/Event_wardrum_ogre.ogg",
    ["Humm"]               = 569518, -- "Sound/Spells/SimonGame_Visual_GameStart.ogg",
    ["Short Circuit"]      = 568975, -- "Sound/Spells/SimonGame_Visual_BadPress.ogg",
    ["ObjectiveProgress"]  = 567482, -- "Sound/Interface/AuctionWindowOpen.ogg",
}