---@class Migration
local Migration = QuestieLoader:CreateModule("Migration")

-- add functions to this table to migrate users who have not yet run said function.
-- make sure to always add to the end of the table as it runs first to last
local migrationFunctions = {
    [1] = function()
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
    end,
    [2] = function()
        Questie.db.global.stickyDurabilityFrame = false
    end
}

local targetVersion = table.getn(migrationFunctions)

function Migration:Migrate()
    Questie:Debug(DEBUG_DEVELOP, "[Migration] Starting Questie migration for targetVersion", targetVersion)
    local currentVersion = Questie.db.char.migrationVersion or 0
    while currentVersion < targetVersion do
        currentVersion = currentVersion + 1
        migrationFunctions[currentVersion]()
    end

    Questie.db.char.migrationVersion = targetVersion
end
