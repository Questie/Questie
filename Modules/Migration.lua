---@class Migration
local Migration = QuestieLoader:CreateModule("Migration")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

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
        if (not Questie.IsWotlk) and (not Questie.IsCata) and
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
        if (not Questie.IsWotlk) and (not Questie.IsCata) and
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
