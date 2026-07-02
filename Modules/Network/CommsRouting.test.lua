dofile("setupTests.lua")

describe("CommsRouting", function()
    ---@type CommsRouting
    local CommsRouting

    before_each(function()
        _G.UnitName = function() return "Player" end
        _G.UnitInParty = function(unit) return unit == "PartyFriend" end
        _G.UnitInRaid = function(unit) return unit == "RaidFriend" end

        dofile("Modules/Network/CommsRouting.lua")
        CommsRouting = QuestieLoader:ImportModule("CommsRouting")
    end)

    describe("GetGroupBroadcastDistribution", function()
        it("normalizes Questie group types", function()
            assert.are_equal("PARTY", CommsRouting:GetGroupBroadcastDistribution("party"))
            assert.are_equal("RAID", CommsRouting:GetGroupBroadcastDistribution("raid"))
            assert.are_equal("INSTANCE_CHAT", CommsRouting:GetGroupBroadcastDistribution("instance"))
        end)

        it("accepts already-normalized AceComm group distributions", function()
            assert.are_equal("PARTY", CommsRouting:GetGroupBroadcastDistribution("PARTY"))
            assert.are_equal("RAID", CommsRouting:GetGroupBroadcastDistribution("RAID"))
            assert.are_equal("INSTANCE_CHAT", CommsRouting:GetGroupBroadcastDistribution("INSTANCE_CHAT"))
        end)

        it("rejects non-group and unknown inputs", function()
            assert.is_nil(CommsRouting:GetGroupBroadcastDistribution("WHISPER"))
            assert.is_nil(CommsRouting:GetGroupBroadcastDistribution("GUILD"))
            assert.is_nil(CommsRouting:GetGroupBroadcastDistribution("solo"))
            assert.is_nil(CommsRouting:GetGroupBroadcastDistribution(nil))
        end)
    end)

    describe("IsSelf", function()
        it("uses AceComm's short-name sender normalization", function()
            assert.is_true(CommsRouting:IsSelf("Player"))
            assert.is_false(CommsRouting:IsSelf("Player-OtherRealm"))
        end)
    end)

    describe("IsMessageFromGroupMember", function()
        it("accepts grouped senders on supported distributions", function()
            assert.is_true(CommsRouting:IsMessageFromGroupMember("PARTY", "PartyFriend"))
            assert.is_true(CommsRouting:IsMessageFromGroupMember("RAID", "RaidFriend"))
            assert.is_true(CommsRouting:IsMessageFromGroupMember("INSTANCE_CHAT", "PartyFriend"))
            assert.is_true(CommsRouting:IsMessageFromGroupMember("WHISPER", "RaidFriend"))
        end)

        it("rejects unsupported distributions and non-group senders", function()
            assert.is_false(CommsRouting:IsMessageFromGroupMember("GUILD", "PartyFriend"))
            assert.is_false(CommsRouting:IsMessageFromGroupMember("PARTY", "Stranger"))
            assert.is_false(CommsRouting:IsMessageFromGroupMember("WHISPER", "Stranger"))
        end)
    end)
end)
