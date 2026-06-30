---@class CommsRouting : QuestieModule
local CommsRouting = QuestieLoader:CreateModule("CommsRouting")

local groupBroadcastByInput = {
    party = "PARTY",
    raid = "RAID",
    instance = "INSTANCE_CHAT",
    PARTY = "PARTY",
    RAID = "RAID",
    INSTANCE_CHAT = "INSTANCE_CHAT",
}

---Normalizes Questie group types and AceComm group distributions to an AceComm broadcast distribution.
---@param input string?
---@return string?
function CommsRouting:GetGroupBroadcastDistribution(input)
    return groupBroadcastByInput[input]
end
