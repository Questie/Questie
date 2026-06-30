dofile("setupTests.lua")

describe("CommsRouting", function()
    ---@type CommsRouting
    local CommsRouting

    before_each(function()
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
end)
