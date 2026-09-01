dofile("setupTests.lua")

describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    local playerName = "OtherPlayer-FancyRealm"
    local isPlayerInGroup

    local function questPacket()
        return {
            id = 42,
            objectives = {
                {
                    id = 123,
                    typ = "m",
                    fin = false,
                    ful = 0,
                    req = 1,
                },
            },
        }
    end

    before_each(function()
        isPlayerInGroup = true
        _G.IsInRaid = function() return false end
        _G.UnitInParty = spy.new(function(name)
            return isPlayerInGroup and name == playerName
        end)
        _G.UnitInRaid = function() return false end
        _G.UnitName = function() return "LocalPlayer" end

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)

        dofile("Modules/Network/QuestieComms.lua")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestieComms.remotePlayerClasses = {}
        QuestieComms.remotePlayerEnabled = {}
        QuestieComms.remotePlayerTimes = {}
        QuestieComms.data.RegisterTooltip = spy.new(function() end)
        QuestieComms.data.RemovePlayer = spy.new(function() end)
    end)

    describe("PruneRemotePlayers", function()
        it("should remove a cross-realm player who left the group", function()
            QuestieComms:InsertQuestDataPacket(questPacket(), playerName)
            QuestieComms.remotePlayerClasses[playerName] = "MAGE"
            QuestieComms.remotePlayerEnabled[playerName] = true
            QuestieComms.remotePlayerTimes[playerName] = 123
            isPlayerInGroup = false

            local changed = QuestieComms:PruneRemotePlayers()

            assert.is_true(changed)
            assert.is_nil(QuestieComms.remoteQuestLogs[42][playerName])
            assert.is_nil(QuestieComms.remotePlayerClasses[playerName])
            assert.is_nil(QuestieComms.remotePlayerEnabled[playerName])
            assert.is_nil(QuestieComms.remotePlayerTimes[playerName])
            assert.spy(QuestieComms.data.RemovePlayer).was.called_with(QuestieComms.data, playerName)
            assert.spy(_G.UnitInParty).was.called_with(playerName)
        end)

        it("should keep a tracked player who is still in the group", function()
            QuestieComms:InsertQuestDataPacket(questPacket(), playerName)

            local changed = QuestieComms:PruneRemotePlayers()

            assert.is_false(changed)
            assert.is_not_nil(QuestieComms.remoteQuestLogs[42][playerName])
            assert.spy(QuestieComms.data.RemovePlayer).was.not_called()
        end)

        it("should keep nearby player data that was not received from a group member", function()
            isPlayerInGroup = false
            QuestieComms:InsertQuestDataPacket(questPacket(), playerName)
            QuestieComms.remotePlayerTimes[playerName] = 123
            QuestieComms.remotePlayerEnabled[playerName] = true

            local changed = QuestieComms:PruneRemotePlayers()

            assert.is_false(changed)
            assert.is_not_nil(QuestieComms.remoteQuestLogs[42][playerName])
            assert.is_true(QuestieComms.remotePlayerEnabled[playerName])
            assert.spy(QuestieComms.data.RemovePlayer).was.not_called()
        end)
    end)
end)
