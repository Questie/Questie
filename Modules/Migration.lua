---@class Migration
local Migration = QuestieLoader:CreateModule("Migration")

-- add functions to this table to migrate users who have not yet run said function.
-- make sure to always add to the end of the table as it runs first to last
local migrationFunctions = {
    [1] = function(hasRunAccountWide)
        Questie:Print("[Migration] Migrating Questie for v6.0.0")
    
        -- This is not needed anymore since we calculate the quests with zones at each login.
        -- If not we would have to store the zoneMap for each character because we only show
        -- quests in the Journey a character (race + class) can accept.
        if not hasRunAccountWide then
            Questie.db.global.zoneMapCache = nil
        end
    
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
    [2] = function(hasRunAccountWide)
        if not hasRunAccountWide then
            Questie.db.global.stickyDurabilityFrame = false
        end
    end,
    [3] = function(hasRunAccountWide)
        local optionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults"):Load()

        local journey
        local migrationTable, globalMigrationTable

        if Questie.db.char then
            journey = Questie.db.char.journey
        end

        if not hasRunAccountWide then
            if Questie.db.global then
                migrationTable = Questie.db.global.migrationVersion
                globalMigrationTable = Questie.db.global.globalMigrationSteps
            end
            Questie.db.global = {}
        end

        Questie.db.char = {}

        if not hasRunAccountWide then
            for k,v in pairs(optionsDefaults.global) do
                Questie.db.global[k] = v
            end
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

        if not hasRunAccountWide then 
            if migrationTable then
                Questie.db.global.migrationVersion = migrationTable
            end

            if globalMigrationTable then
                Questie.db.global.globalMigrationSteps = globalMigrationTable
            end

            Questie.db.global.dbIsCompiled = false
        end
    end,
    [4] = function()
        Questie.db.char.enableMinimalisticIcons = nil -- Remove unused remnants of minimalistic icons
    end,
    [5] = function()
        Questie.db.char.showEventQuests = true -- Enable event quests again since some might have disabled it to hide the delayed Midsummer quests
        if Questie.db.char.townsfolkConfig then
            Questie.db.char.townsfolkConfig["Meeting Stones"] = true
        end
    end,
    [6] = function()
        if (not Questie.db.char.questAnnounce) or Questie.db.char.questAnnounce == "disabled" then
            Questie.db.char.questAnnounce = false
        else
            Questie.db.char.questAnnounce = true
        end
    end,
    [7] =  function()
        Questie.db.global.hasSeenBetaMessage = nil
    end,
    [8] =  function()
        if not Questie.db.char.questAnnounceChannel then
            if (not Questie.db.char.questAnnounce) or Questie.db.char.questAnnounce == "disabled" then
                Questie.db.char.questAnnounceChannel = "disabled"
                Questie.db.char.questAnnounceObjectives = false
            else
                Questie.db.char.questAnnounceChannel = "group"
                Questie.db.char.questAnnounceObjectives = true
            end
        end
    end,
    [9] = function()
        if Questie.db.char.hiddenDailies and Questie.db.char.hiddenDailies.hc and next(Questie.db.char.hiddenDailies.hc) then
            table.insert(Questie.db.char.hiddenDailies.hc, 11499, true) -- Add new HC daily to hiddenDailies
        end
    end,
    [10] = function()
        if Questie.db.char.questAnnounceObjectives == nil then
            Questie.db.char.questAnnounceObjectives = true
        end
    end,
    [11] = function()
        Questie.db.global.trackerEnabled = true
    end,
    [12] = function()
        Questie.db.char.collapsedQuests = {}
    end,
    [13] = function()
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
    end,
    [14] = function()
        if Questie.db.char.isAchievementsExpanded == nil then
            Questie.db.char.isAchievementsExpanded = true
        end
    end
}

function Migration:Migrate()

    if not Questie.db.global.migrationVersion then
        Questie.db.global.migrationVersion = {}
    end

    if not Questie.db.global.globalMigrationSteps then
        Questie.db.global.globalMigrationSteps = {}
    end

    local player = UnitName("Player") .. GetRealmName()
    local currentVersion = Questie.db.global.migrationVersion[player] or 0
    local targetVersion = table.getn(migrationFunctions)

    Questie:Debug(Questie.DEBUG_DEVELOP, "[Migration] Starting Questie migration for targetVersion", targetVersion)

    while currentVersion < targetVersion do
        currentVersion = currentVersion + 1
        migrationFunctions[currentVersion](Questie.db.global.globalMigrationSteps[currentVersion])
        Questie.db.global.globalMigrationSteps[currentVersion] = true
    end

    Questie.db.global.migrationVersion[player] = currentVersion

end
