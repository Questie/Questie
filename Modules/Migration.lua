---@class Migration
local Migration = QuestieLoader:CreateModule("Migration")

-- This version should only be increased, not decreased.
-- Also it should only be increased when some changes break the settings/code for users
-- and would require a clean install (which we don't want user to do)
local targetVersion = 1

-- forward declaration
local _MigrateForV600

function Migration:Migrate()
    Questie:Debug(DEBUG_DEVELOP, "[Migration] Starting Questie migration for targetVersion", targetVersion)
    if Questie.db.char.migrationVersion == targetVersion then
        return
    elseif Questie.db.char.migrationVersion == nil then
        _MigrateForV600()
    end
end

_MigrateForV600 = function()
    Questie:Print("[Migration] Migrating Questie for v6.0.0")

    -- This is not needed anymore since we calculate the quests with zones at each login.
    -- If not we would have to store the zoneMap for each character because we only show
    -- quests in the Journey a character (race + class) can accept.
    Questie.db.global.zoneMapCache = nil

    if Questie.db.char.manualMinLevelOffset and Questie.db.char.absoluteLevelOffset then
        Questie.db.char.manualMinLevelOffset = false
        Questie.db.char.absoluteLevelOffset = false
    end

    local removedPartyEntries = 0

    for _, entry in pairs(Questie.db.char.journey) do
        if entry.Party then
            entry.Party = nil
            removedPartyEntries = removedPartyEntries + 1
        end
    end

    Questie:Print("[Migration] Migrated Questie to v6.0.0 and removed", removedPartyEntries, "party entries from the Journey")
    Questie.db.char.migrationVersion =  targetVersion
end