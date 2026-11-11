dofile("setupTests.lua")

describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives
    ---@type QuestieSerializer
    local QuestieSerializer
    local originalQuestieSerializerDeserialize

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
        QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer")
        originalQuestieSerializerDeserialize = QuestieSerializer.Deserialize

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
        QuestieSerializer.Deserialize = originalQuestieSerializerDeserialize
    end)

    describe("remote group quests", function()
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

        it("should remove all group snapshots on GROUP_LEFT", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(43, 456), playerName)

            QuestieComms:RemoveAllRemoteGroupPlayers()

            assert.is_nil(next(QuestieComms.remoteQuestLogs))
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 43, playerName)
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called_with(QuestiePartyObjectives)
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

        it("should remove a quest and its tooltip keys when the group removes it", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)

            QuestieComms.private.packets[2].read({
                playerName = playerName,
                id = 42,
            })

            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
        end)

        it("should keep a current member's data through the public removal API", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)

            QuestieComms:RemoveRemotePlayer(playerName)

            assert.are_equal(123, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.is_nil(QuestieComms.remotePlayerTimes[playerName])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.not_called()
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should remove a departed player's data through the public removal API", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)
            isPlayerInGroup = false

            QuestieComms:RemoveRemotePlayer(playerName)

            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)

        it("should keep a current member's data when their timestamp expires", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)
            QuestieComms.remotePlayerTimes[playerName] = currentTime - (60 * 4) - 1

            QuestieComms:SortRemotePlayers()

            assert.are_equal(123, QuestieComms.remoteQuestLogs[42][playerName][1].id)
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.not_called()
            assert.is_nil(QuestieComms.remotePlayerTimes[playerName])
        end)

        it("should remove an expired non-member's data on the lazy cleanup", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)
            isPlayerInGroup = false
            QuestieComms.remotePlayerTimes[playerName] = currentTime - (60 * 4) - 1

            QuestieComms:SortRemotePlayers()

            assert.is_nil(QuestieComms.remoteQuestLogs[42])
            assert.spy(QuestieComms.data.RemoveQuestFromPlayer).was.called_with(QuestieComms.data, 42, playerName)
        end)

        it("should reset remote quest data and the group registry", function()
            QuestieComms:InsertQuestDataPacket(groupQuestPacket(42, 123), playerName)

            QuestieComms:ResetAll()

            assert.is_nil(next(QuestieComms.remoteQuestLogs))
            assert.spy(QuestieComms.data.ResetAll).was.called_with(QuestieComms.data)

            isPlayerInGroup = false
            assert.is_false(QuestieComms:PruneRemotePlayers())
        end)
    end)

    describe("OnCommReceived_unsafe", function()
        it("should reject group transports from a player who already left", function()
            local deserializeCalls = 0
            QuestieSerializer.Deserialize = function()
                deserializeCalls = deserializeCalls + 1
                return {}
            end
            isPlayerInGroup = false

            for _, distribution in ipairs({"PARTY", "RAID", "INSTANCE_CHAT", "WHISPER"}) do
                QuestieComms.private:OnCommReceived_unsafe("payload", distribution, playerName)
            end

            assert.are_equal(0, deserializeCalls)
        end)

        it("should accept group transports from a current party member", function()
            local deserializeCalls = 0
            QuestieSerializer.Deserialize = function()
                deserializeCalls = deserializeCalls + 1
                return {}
            end

            for _, distribution in ipairs({"PARTY", "RAID", "INSTANCE_CHAT", "WHISPER"}) do
                QuestieComms.private:OnCommReceived_unsafe("payload", distribution, playerName)
            end

            assert.are_equal(4, deserializeCalls)
        end)

        it("should accept YELL from a player outside the group", function()
            local deserializeEncoding
            QuestieSerializer.Deserialize = function(_, _, encoding)
                deserializeEncoding = encoding
                return {}
            end
            isPlayerInGroup = false

            QuestieComms.private:OnCommReceived_unsafe("payload", "YELL", playerName)

            assert.are_equal("b89", deserializeEncoding)
        end)

        it("should leave non-group transports unchanged", function()
            local deserializeCalls = 0
            QuestieSerializer.Deserialize = function()
                deserializeCalls = deserializeCalls + 1
                return {}
            end
            isPlayerInGroup = false

            for _, distribution in ipairs({"GUILD", "CHANNEL"}) do
                QuestieComms.private:OnCommReceived_unsafe("payload", distribution, playerName)
            end

            assert.are_equal(2, deserializeCalls)
        end)
    end)
end)
