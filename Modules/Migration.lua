---@class Migration
local Migration = QuestieLoader:CreateModule("Migration")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

-- add functions to this table to migrate users who have not yet run said function.
-- make sure to always add to the end of the table as it runs first to last
local migrationFunctions = {
    [1] = function()
        -- this is the big Questie v9.0 settings refactor, implementing profiles
        if Questie.db.char then -- if you actually have previous settings, then on first startup we should notify you of this
            Questie:Print("[Migration] Migrated Questie for v9.0. This will reset all Questie settings to default. Journey history has been preserved.")
        end
        -- theres no need to delete old settings, since we read/write to different addresses now;
        -- old settings can linger unused unless you roll back versions, no harm no foul
    end,
    [2] = function()
        -- Blizzard removed some sounds from Era/SoD, which are present in WotLK
        local objectiveSound = Questie.db.profile.objectiveCompleteSoundChoiceName
        if Expansions.Current < Expansions.Wotlk and -- Are these sounds present in TBC as well?
            objectiveSound == "Explosion" or
            objectiveSound == "Shing!" or
            objectiveSound == "Wham!" or
            objectiveSound == "Simon Chime" or
            objectiveSound == "War Drums" or
            objectiveSound == "Humm" or
            objectiveSound == "Short Circuit"
        then
            Questie.db.profile.objectiveCompleteSoundChoiceName = "ObjectiveDefault"
        end

        local progressSound = Questie.db.profile.objectiveProgressSoundChoiceName
        if Expansions.Current < Expansions.Wotlk and -- Are these sounds present in TBC as well?
            progressSound == "Explosion" or
            progressSound == "Shing!" or
            progressSound == "Wham!" or
            progressSound == "Simon Chime" or
            progressSound == "War Drums" or
            progressSound == "Humm" or
            progressSound == "Short Circuit"
        then
            Questie.db.profile.objectiveProgressSoundChoiceName = "ObjectiveProgress"
        end
    end,
    [3] = function()
        if Questie.IsSoD then
            if Questie.db.profile.showSoDRunes then
                Questie.db.profile.showRunesOfPhase = {
                    phase1 = true,
                    phase2 = false,
                    phase3 = false,
                    phase4 = false,
                }
            else
                Questie.db.profile.showRunesOfPhase = {
                    phase1 = false,
                    phase2 = false,
                    phase3 = false,
                    phase4 = false,
                }
            end
        end
    end,
    [4] = function()
        Questie.db.profile.tutorialShowRunesDone = false
    end,
    [5] = function()
        Questie.db.profile.enableTooltipsNextInChain = true
    end,
    [6] = function()
        Questie.db.profile.tutorialShowRunesDone = false
    end,
    [7] = function()
        Questie.db.profile.tutorialShowRunesDone = false
    end,
    [8] = function()
        if Questie.IsSoD then
            Questie.db.profile.showAQWarEffortQuests = true
        end
    end,
    [9] = function()
        Questie.db.profile.autoAccept = {
            enabled = Questie.db.profile.autoaccept,
            trivial = Questie.db.profile.acceptTrivial,
            repeatable = true,
        }
        Questie.db.profile.autoaccept = nil
        Questie.db.profile.acceptTrivial = nil
    end,
    [10] = function()
        -- The previous release had the default value set to "true", which was incorrect.
        Questie.db.profile.autoAccept.enabled = false
    end,
    [11] = function()
        Questie.db.profile.autoAccept.pvp = true
    end,
    [12] = function()
        Questie.db.profile.autoAccept.rejectSharedInBattleground = false
        Questie.db.profile.tutorialRejectInBattlegroundsDone = false
    end,
    [13] = function()
        Questie.db.profile.questAnnounceIncompleteBreadcrumb = true
    end,
    [14] = function()
        Questie.db.profile.hideTrackerInPetBattles = true
    end,
    [15] = function()
        Questie.db.profile.globalTownsfolkScale = 0.6
        Questie.db.profile.globalMiniMapTownsfolkScale = 0.7
    end,
    [16] = function()
        if (not Questie.db.global.isleOfQuelDanasPhase) then
            if Expansions.Current > Expansions.Tbc then
                Questie.db.global.isleOfQuelDanasPhase = 9 -- Max phase for everything that comes after TBC
            elseif Expansions.Current == Expansions.Tbc then
                Questie.db.global.isleOfQuelDanasPhase = 1
            end
        end
    end,
    [17] = function()
        Questie.db.global.unavailableQuestsDeterminedByTalking = {}
        ---@type table<string, number>
        Questie.db.global.lastKnownDailyReset = {}
    end,
    [18] = function()
        Questie.db.profile.trackerDisableHoverFade = false
    end,
    [19] = function()
        -- Only migrate if the user has a previous migration
        local previousVersion = Questie.db.profile.migrationVersion or 0
        if previousVersion == 0 then
            return
        end

        -- Preserve previous dungeon hide preference for both new flags
        local previousHideInDungeons = Questie.db.profile.hideTrackerInDungeons

        Questie.db.profile.minimizeTrackerInCombat = false
        Questie.db.profile.minimizeTrackerInDungeons = previousHideInDungeons
        Questie.db.profile.hideTrackerInCombat = false
        Questie.db.profile.hideTrackerInDungeons = false
    end,
    [20] = function()
        Questie.db.profile.alwaysGlowMinimap = true
    end,
    [21] = function()
        if Questie.IsTBC then
            Questie.db.profile.showAQWarEffortQuests = false
        end
    end,
}

function Migration:Migrate()
    if not Questie.db.profile.migrationVersion then
        Questie.db.profile.migrationVersion = 0
    end

    local currentVersion = Questie.db.profile.migrationVersion
    local targetVersion = table.getn(migrationFunctions)

    if currentVersion == targetVersion then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[Migration] Nothing to migrate. Already on latest version:", targetVersion)
        return
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[Migration] Starting Questie migration for targetVersion", targetVersion)

    while currentVersion < targetVersion do
        currentVersion = currentVersion + 1
        migrationFunctions[currentVersion]()
    end

    Questie.db.profile.migrationVersion = currentVersion
end
