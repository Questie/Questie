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
            for k, v in pairs(optionsDefaults.global) do
                Questie.db.global[k] = v
            end
        end

        -- only toggle questie if it's off (must be called before resetting the value)
        if (not Questie.db.char.enabled) then
            Questie.db.char.enabled = true
        end

        for k, v in pairs(optionsDefaults.char) do
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
    [7] = function()
        Questie.db.global.hasSeenBetaMessage = nil
    end,
    [8] = function()
        if not Questie.db.char.questAnnounceChannel then
            if (not Questie.db.char.questAnnounce) or Questie.db.char.questAnnounce == "disabled" then
                Questie.db.char.questAnnounceChannel = "disabled"
                Questie.db.char.questAnnounceObjectives = false
            else
                Questie.db.char.questAnnounceChannel = "party"
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
        if Questie.db.global.trackerEnabled then   -- old value
            Questie.db.global.trackerEnabled = nil -- kill old value
            Questie.db.char.trackerEnabled = true  -- create new value
        end
    end,
    [12] = function()
        Questie.db.char.collapsedQuests = {}
    end,
    [13] = function()
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
    end,
    [14] = function()
        -- Empty on purpose
    end,
    [15] = function()
        if Questie.db.global.clusterLevelHotzone == 70 then -- old default value
            Questie.db.global.clusterLevelHotzone = 50
        end
        if Questie.db.global.availableScale == 1.3 then -- old default value
            Questie.db.global.availableScale = 1.2
        end
        if Questie.db.global.globalScale == 0.7 then -- old default value
            Questie.db.global.globalScale = 0.6
        end
        if Questie.db.global.nameplateTargetFrameEnabled == false then -- old default value
            Questie.db.global.nameplateTargetFrameEnabled = true
        end
    end,
    [16] = function()
        if Questie.db.char.questAnnounceChannel == "group" then
            Questie.db.char.questAnnounceChannel = "party"
        end
    end,
    [17] = function()
        if Questie.IsWotlk then
            Questie.db.global.isleOfQuelDanasPhase = 9 -- Last Isle Of Quel Danas Phase
        end
    end,
    [18] = function()
        if Questie.db.char.enableQuestFrameIcons == nil then
            Questie.db.char.enableQuestFrameIcons = true
        end
    end,
    [19] = function()
        Questie.db.global.ICON_REPEATABLE_COMPLETE = Questie.icons["complete"]
        Questie.db.global.ICON_EVENTQUEST_COMPLETE = Questie.icons["complete"]
        Questie.db.global.ICON_PVPQUEST_COMPLETE = Questie.icons["complete"]
    end,
    [20] = function()
        if Questie.db.global.trackerEnabled then                                    -- old value
            Questie.db.global.trackerEnabled = nil                                  -- kill old value
            Questie.db.char.trackerEnabled = true                                   -- create new value
        end
        if Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "AUTO" then -- old default value
            Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "TOPLEFT"
        end
        if Questie.db.global.trackerHeaderAutoMove == false then
            Questie.db.global.trackerHeaderAutoMove = nil               -- kill old key
            Questie.db.global.autoMoveHeader = false                    -- migrate previous setting to new key
        end
        if Questie.db.global.sizerHidden == nil then                    -- new option
            Questie.db.global.sizerHidden = false                       -- set default
        end
        if Questie.db.global.hideCompletedQuestObjectives == nil then   -- new option
            Questie.db.global.hideCompletedQuestObjectives = false      -- set default
        end
        if Questie.db.global.hideCompletedAchieveObjectives == nil then -- new option
            Questie.db.global.hideCompletedAchieveObjectives = false    -- set default
        end
        if Questie.db.global.currentHeaderEnabledSetting == nil then    -- new option
            Questie.db.global.currentHeaderEnabledSetting = true        -- set trackerHeaderEnabled default
        end
    end,
    [21] = function()
        if Questie.db.char.soundOnQuestComplete == nil then -- new option
            Questie.db.char.soundOnQuestComplete = false
        end
        if Questie.db.char.soundOnObjectiveComplete == nil then -- new option
            Questie.db.char.soundOnObjectiveComplete = false
        end
    end,
    [22] = function()
        Questie.db.global.hideCompletedAchieveObjectives = true
    end,
    [23] = function()
        if Questie.db.global.currentBackdropEnabled == nil then                                 -- new option
            Questie.db.global.currentBackdropEnabled = Questie.db.global.trackerBackdropEnabled -- set trackerBackdropEnabled default
        end
        if Questie.db.global.currentBorderEnabled == nil then                                   -- new option
            Questie.db.global.currentBorderEnabled = Questie.db.global.trackerBorderEnabled     -- set trackerBorderEnabled default
        end
        if Questie.db.global.currentBackdropFader == nil then                                   -- new option
            Questie.db.global.currentBackdropFader = Questie.db.global.trackerBackdropFader     -- set trackerBackdropFader default
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

    if currentVersion == targetVersion then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[Migration] Nothing to migrate. Already on latest version:", targetVersion)
        return
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[Migration] Starting Questie migration for targetVersion", targetVersion)

    while currentVersion < targetVersion do
        currentVersion = currentVersion + 1
        migrationFunctions[currentVersion](Questie.db.global.globalMigrationSteps[currentVersion])
        Questie.db.global.globalMigrationSteps[currentVersion] = true
    end

    Questie.db.global.migrationVersion[player] = currentVersion
end
