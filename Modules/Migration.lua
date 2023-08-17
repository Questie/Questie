---@class Migration
local Migration = QuestieLoader:CreateModule("Migration")

-- add functions to this table to migrate users who have not yet run said function.
-- make sure to always add to the end of the table as it runs first to last
local migrationFunctions = {
    [1] = function()
        local optionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults"):Load()
        Questie:Print("[Migration] Migrating Questie for v8.9.0")

        local journey
        if Questie.db.char then
            journey = Questie.db.char.journey
        end

        Questie.db.profile = nil
        Questie.db.global = nil
        Questie.db.char = optionsDefaults.char
        Questie.db.char.journey = journey

        Questie:Print("[Migration] Migrated Questie to v8.9.0")
    end
}

function Migration:Migrate()
    print("|cff30fc96Questie|r: |cffff0000Please note:|r One of the next Questie releases will reset your settings. We advice you to backup your Questie related Saved Variables as precaution.")

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
