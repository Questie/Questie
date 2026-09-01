dofile("setupTests.lua")

describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives
    ---@type QuestieLib
    local QuestieLib
    local originalQuestieLibCount

    local playerName = "OtherPlayer-FancyRealm"
    local isPlayerInGroup
    local currentTime

    local function groupQuestPacket(questId, objectiveId)
        return {
            id = questId,
            objectives = {
                {
                    id = objectiveId,
                    typ = "m",
                    fin = false,
                    ful = 0,
                    req = 1,
                },
            },
        }
    end

    local function nearbyQuestPacket(questId, objectiveId, fulfilled, required)
        return {
            questId,
            1,
            3, -- MAGE
            objectiveId,
            string.byte("m"),
            fulfilled or 0,
            required or 1,
        }
    end

    local function groupQuestPacketV2(questId, objectiveId)
        return {
            questId,
            1,
            objectiveId,
            string.byte("m"),
            0,
            1,
        }
    end

    local function insertNearbyQuest(questId, objectiveId)
        QuestieComms.remotePlayerTimes[playerName] = currentTime
        QuestieComms:InsertQuestDataPacketV2(nearbyQuestPacket(questId, objectiveId), playerName, 1, true)
    end

    before_each(function()
        isPlayerInGroup = true
        currentTime = 1000
        _G.IsInRaid = function() return false end
        _G.UnitInParty = spy.new(function(name)
            return isPlayerInGroup and name == playerName
        end)
        _G.UnitInRaid = function() return false end
        _G.UnitName = function() return "LocalPlayer" end
        _G.GetTime = function() return currentTime end

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        originalQuestieLibCount = QuestieLib.Count

        dofile("Modules/Network/QuestieComms.lua")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestieComms.remotePlayerClasses = {}
        QuestieComms.remotePlayerEnabled = {}
        QuestieComms.remotePlayerTimes = {}
        QuestieComms.data.RegisterTooltip = spy.new(function() end)
        QuestieComms.data.RemoveQuestFromPlayer = spy.new(function() end)
        QuestieComms.data.RemovePlayer = spy.new(function() end)
        QuestieComms.data.ResetAll = spy.new(function() end)
    end)

    after_each(function()
        QuestieLib.Count = originalQuestieLibCount
    end)

    describe("remote quest sources", function()
        it("should remove group-only data for a cross-realm player who left", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)
            isPlayerInGroup = false

            local changed = QuestieComms:PruneRemotePlayers()

            assert.is_true(changed)
            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
            assert.spy(_G.UnitInParty).was.called_with(playerName)
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should keep a tracked player who is still in the group", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)

            local changed = QuestieComms:PruneRemotePlayers()

            assert.is_false(changed)
            assert.are_equal(123, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.not_called()
        end)

        it("should not store a group packet from a player outside the group", function()
            isPlayerInGroup = false

            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)

            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RegisterTooltip).was.not_called()
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should restore Nearby data and remove unrelated group quests after party leave", function()
            insertNearbyQuest(42, 101)
            insertNearbyQuest(44, 404)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(43, 303), playerName)
            QuestieComms.remotePlayerEnabled[playerName] = true

            QuestieComms.data.RegisterTooltip = spy.new(function() end)
            QuestieComms.data.RemoveQuestFromPlayer = spy.new(function() end)
            isPlayerInGroup = false

            local changed = QuestieComms:PruneRemotePlayers()

            assert.is_true(changed)
            assert.are_equal(101, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.is_nil(QuestieComms.remoteQuestLogs[43])
            assert.are_equal(404, QuestieComms.remoteQuestLogs[44][playerName][1].id)
            assert.are_equal(currentTime, QuestieComms.remotePlayerTimes[playerName])
            assert.is_true(QuestieComms.remotePlayerEnabled[playerName])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 43, playerName)
            assert.spy(QuestieComms.data.RegisterTooltip).was.called_with(
                QuestieComms.data,
                42,
                playerName,
                QuestieComms.remoteQuestLogs[42][playerName]
            )
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should replace stale tooltip keys when falling back to Nearby data", function()
            QuestieLib.Count = function(_, values)
                local count = 0
                for _ in pairs(values) do
                    count = count + 1
                end
                return count
            end
            QuestieComms.data = {}
            dofile("Modules/Network/QuestieCommsData.lua")

            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(43, 303), playerName)

            assert.is_false(QuestieComms.data:KeyExists("m_101"))
            assert.is_true(QuestieComms.data:KeyExists("m_202"))
            assert.is_true(QuestieComms.data:KeyExists("m_303"))

            isPlayerInGroup = false
            QuestieComms:PruneRemotePlayers()

            assert.is_true(QuestieComms.data:KeyExists("m_101"))
            assert.is_false(QuestieComms.data:KeyExists("m_202"))
            assert.is_false(QuestieComms.data:KeyExists("m_303"))
        end)

        it("should restore Nearby data when the group removes the same quest", function()
            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)

            QuestieComms.private.packets[2].read({
                playerName = playerName,
                id = 42,
            })

            assert.are_equal(101, QuestieComms.remoteQuestLogs[42][playerName][1].id)
        end)

        it("should keep group data when Nearby reports the quest complete", function()
            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)

            QuestieComms:InsertQuestDataPacketV2(nearbyQuestPacket(42, 101, 1, 1), playerName, 1, true)

            assert.are_equal(202, QuestieComms.remoteQuestLogs[42][playerName][1].id)
        end)

        it("should expire Nearby data without removing the group projection", function()
            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)
            QuestieComms.remotePlayerTimes[playerName] = currentTime - (60 * 4) - 1

            QuestieComms:SortRemotePlayers()

            assert.are_equal(202, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.is_nil(QuestieComms.remotePlayerTimes[playerName])
            assert.is_nil(QuestieComms.remotePlayerClasses[playerName])
        end)

        it("should remove an expired Nearby-only projection", function()
            insertNearbyQuest(42, 101)
            QuestieComms.remotePlayerTimes[playerName] = currentTime - (60 * 4) - 1

            QuestieComms:SortRemotePlayers()

            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
        end)

        it("should remove all Nearby data without damaging group data", function()
            insertNearbyQuest(42, 101)
            insertNearbyQuest(43, 303)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)

            QuestieComms:RemoveAllRemotePlayers()

            assert.are_equal(202, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.is_nil(QuestieComms.remoteQuestLogs[43])
            assert.is_nil(QuestieComms.remotePlayerTimes[playerName])
        end)

        it("should remove all group data while preserving Nearby projections", function()
            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(43, 303), playerName)

            QuestieComms:RemoveAllRemoteGroupPlayers()

            assert.are_equal(101, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.is_nil(QuestieComms.remoteQuestLogs[43])
            assert.are_equal(currentTime, QuestieComms.remotePlayerTimes[playerName])
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should preserve current group data through the public removal API", function()
            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)

            QuestieComms:RemoveRemotePlayer(playerName)

            assert.are_equal(202, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.is_nil(QuestieComms.remotePlayerTimes[playerName])
            assert.spy(QuestieComms.data.RemovePlayer).was.not_called()

            isPlayerInGroup = false
            QuestieComms:RemoveRemotePlayer(playerName)

            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RemovePlayer).was.called_with(QuestieComms.data, playerName)
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should parse but not store a V2 group packet from a departed player", function()
            isPlayerInGroup = false

            local offset = QuestieComms:InsertQuestDataPacketV2_noclass_RenameMe(
                groupQuestPacketV2(42, 123),
                playerName,
                1,
                false
            )

            assert.are_equal(7, offset)
            assert.is_nil(QuestieComms.remoteQuestLogs[42])
        end)

        it("should accumulate group quest-list blocks", function()
            QuestieComms.private.packets[10].read({
                playerName = playerName,
                rawQuestList = {groupQuestPacket(42, 123)},
            })
            QuestieComms.private.packets[10].read({
                playerName = playerName,
                rawQuestList = {groupQuestPacket(43, 456)},
            })

            assert.are_equal(123, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.are_equal(456, QuestieComms.remoteQuestLogs[43][playerName][1].id)
        end)

        it("should reset all source projections and Nearby metadata", function()
            insertNearbyQuest(42, 101)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 202), playerName)
            QuestieComms.remotePlayerEnabled[playerName] = true

            QuestieComms:ResetAll()

            assert.is_nil(next(QuestieComms.remoteQuestLogs))
            assert.is_nil(next(QuestieComms.remotePlayerTimes))
            assert.is_nil(next(QuestieComms.remotePlayerEnabled))
            assert.is_nil(next(QuestieComms.remotePlayerClasses))
            assert.spy(QuestieComms.data.ResetAll).was.called_with(QuestieComms.data)

            isPlayerInGroup = false
            assert.is_false(QuestieComms:PruneRemotePlayers())
            assert.is_nil(next(QuestieComms.remoteQuestLogs))
        end)
    end)
end)
