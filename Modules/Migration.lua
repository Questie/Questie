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
    end,
    [3] = function()
        local optionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults"):Load()

        local journey = nil
        local migrationTable = nil

        if Questie.db.char then
            journey = Questie.db.char.journey
        end

        if Questie.db.global then
            migrationTable = Questie.db.global.migrationVersion
        end

        Questie.db.global = {}
        Questie.db.char = {}

        for k,v in pairs(optionsDefaults.global) do
            Questie.db.global[k] = v
        end

        -- only toggle questie if it's off (must be called before resetting the value)
        if (not Questie.db.char.enabled) then
            Questie.db.char.enabled = true
        end

        for k,v in pairs(optionsDefaults.char) do
            Questie.db.char[k] = v
        end

        Questie.db.profile.minimap.hide = optionsDefaults.profile.minimap.hide;

        if journey then
            Questie.db.char.journey = journey
        end

        if migrationTable then
            Questie.db.global.migrationVersion = migrationTable
        end

        Questie.db.global.dbIsCompiled = false
    end
}

function Migration:Migrate()

    if not Questie.db.global.migrationVersion then
        Questie.db.global.migrationVersion = {}
    end

    local player = UnitName("Player") .. GetRealmName()
    Questie:Debug(DEBUG_DEVELOP, "[Migration] Starting Questie migration for targetVersion", targetVersion)

    local currentVersion = Questie.db.global.migrationVersion[player] or 0
    local targetVersion = table.getn(migrationFunctions)

    while currentVersion < targetVersion do
        currentVersion = currentVersion + 1
        migrationFunctions[currentVersion]()
    end

    Questie.db.global.migrationVersion[player] = currentVersion

end
