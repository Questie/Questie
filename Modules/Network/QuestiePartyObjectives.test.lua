dofile("setupTests.lua")

describe("QuestiePartyObjectives", function()
    local QUEST_ID = 101

    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives
    ---@type QuestieComms
    local QuestieComms
    ---@type CommsVisibility
    local CommsVisibility

    local onlinePlayers
    local renderedObjectives
    local renderedMapIcons

    local function countActiveMapIcons()
        local count = 0
        for _, mapIcon in ipairs(renderedMapIcons) do
            if mapIcon.data then
                count = count + 1
            end
        end
        return count
    end

    local function setRemoteObjective(playerName, finished)
        onlinePlayers[playerName] = true
        QuestieComms.remoteQuestLogs[QUEST_ID] = QuestieComms.remoteQuestLogs[QUEST_ID] or {}
        QuestieComms.remoteQuestLogs[QUEST_ID][playerName] = {
            [1] = {
                id = 9001,
                type = "m",
                finished = finished,
            },
        }
    end

    before_each(function()
        Questie.db.profile = {
            showPartyQuestObjectives = true,
            trimObjectiveText = true,
        }
        Questie.Debug = function() end

        onlinePlayers = {}
        renderedObjectives = {}
        renderedMapIcons = {}

        _G.GetNumGroupMembers = function() return 2 end
        _G.UnitIsConnected = function(playerName) return onlinePlayers[playerName] == true end

        local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}

        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function(questId)
            if questId == QUEST_ID then
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {
                        [1] = {
                            Id = 9001,
                            Type = "monster",
                            Text = "Defeat the target",
                        },
                    },
                    SpecialObjectives = {},
                }
            end
        end

        -- Keep QuestiePartyObjectives aggregation real; replace only the map-rendering boundary
        -- with icon refs that make draw and unload behavior observable.
        local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.PopulateObjective = spy.new(function(_questieQuest, _quest, _objectiveIndex, objective)
            local iconData = {ObjectiveData = objective}
            local mapIcon = {
                data = iconData,
                Unload = spy.new(function(self)
                    self.data = nil
                end),
            }
            objective.AlreadySpawned[1] = {
                data = iconData,
                mapRefs = {mapIcon},
                minimapRefs = {},
            }
            renderedObjectives[#renderedObjectives + 1] = objective
            renderedMapIcons[#renderedMapIcons + 1] = mapIcon
        end)

        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.remoteQuestVisibility = {}
        dofile("Modules/Network/CommsVisibility.lua")
        dofile("Modules/Network/QuestiePartyObjectives.lua")
        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
    end)

    it("does not draw unfinished objectives for a player with explicit false visibility", function()
        setRemoteObjective("Hidden-Realm", false)
        CommsVisibility.remoteQuestVisibility["Hidden-Realm"] = {[QUEST_ID] = false}

        QuestiePartyObjectives:Update()

        assert.are_equal(0, countActiveMapIcons())
        assert.are_equal(0, #renderedObjectives)
    end)

    it("draws an unfinished objective for a player with true visibility", function()
        setRemoteObjective("Visible-Realm", false)
        CommsVisibility.remoteQuestVisibility["Visible-Realm"] = {[QUEST_ID] = true}

        QuestiePartyObjectives:Update()

        assert.are_equal(1, countActiveMapIcons())
        assert.are_equal(1, #renderedObjectives)
        assert.are_equal(QUEST_ID, renderedObjectives[1].questId)
        assert.are_equal(1, renderedObjectives[1].Index)
        assert.is_true(renderedObjectives[1].IsPartyObjective)
    end)

    it("draws for a player whose visibility is unknown because no snapshot was received", function()
        setRemoteObjective("Legacy-Realm", false)

        QuestiePartyObjectives:Update()

        assert.are_equal(1, countActiveMapIcons())
        assert.are_equal(1, #renderedObjectives)
    end)

    it("does not draw an omitted quest after the player sent a known snapshot", function()
        setRemoteObjective("Modern-Realm", false)
        CommsVisibility.remoteQuestVisibility["Modern-Realm"] = {}

        QuestiePartyObjectives:Update()

        assert.are_equal(0, countActiveMapIcons())
        assert.are_equal(0, #renderedObjectives)
    end)

    it("draws a shared objective when at least one player needing it is visible", function()
        setRemoteObjective("Hidden-Realm", false)
        setRemoteObjective("Visible-Realm", false)
        CommsVisibility.remoteQuestVisibility["Hidden-Realm"] = {[QUEST_ID] = false}
        CommsVisibility.remoteQuestVisibility["Visible-Realm"] = {[QUEST_ID] = true}

        QuestiePartyObjectives:Update()

        assert.are_equal(1, countActiveMapIcons())
        assert.are_equal(1, #renderedObjectives)
    end)

    it("clears prior drawn state when all players needing the objective become suppressed", function()
        setRemoteObjective("First-Realm", false)
        setRemoteObjective("Second-Realm", false)
        CommsVisibility.remoteQuestVisibility["First-Realm"] = {[QUEST_ID] = true}
        CommsVisibility.remoteQuestVisibility["Second-Realm"] = {[QUEST_ID] = true}
        QuestiePartyObjectives:Update()
        assert.are_equal(1, countActiveMapIcons())
        local priorMapIcon = renderedMapIcons[1]

        CommsVisibility.remoteQuestVisibility["First-Realm"][QUEST_ID] = false
        CommsVisibility.remoteQuestVisibility["Second-Realm"][QUEST_ID] = false
        QuestiePartyObjectives:Update()

        assert.are_equal(0, countActiveMapIcons())
        assert.are_equal(1, #renderedObjectives)
        assert.spy(priorMapIcon.Unload).was.called(1)
        assert.is_nil(priorMapIcon.data)
    end)

    it("does not draw a finished objective even when its player is visible", function()
        setRemoteObjective("Finished-Realm", true)
        CommsVisibility.remoteQuestVisibility["Finished-Realm"] = {[QUEST_ID] = true}

        QuestiePartyObjectives:Update()

        assert.are_equal(0, countActiveMapIcons())
        assert.are_equal(0, #renderedObjectives)
    end)

    it("does not draw an unfinished objective for an offline visible player", function()
        setRemoteObjective("Offline-Realm", false)
        onlinePlayers["Offline-Realm"] = false
        CommsVisibility.remoteQuestVisibility["Offline-Realm"] = {[QUEST_ID] = true}

        QuestiePartyObjectives:Update()

        assert.are_equal(0, countActiveMapIcons())
        assert.are_equal(0, #renderedObjectives)
    end)
end)
