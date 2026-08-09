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

local allowedGroupMessageDistributions = {
    PARTY = true,
    RAID = true,
    INSTANCE_CHAT = true,
    WHISPER = true,
}

---Normalizes Questie group types and AceComm group distributions to an AceComm broadcast distribution.
---@param input string?
---@return string?
function CommsRouting:GetGroupBroadcastDistribution(input)
    return groupBroadcastByInput[input]
end

---AceComm calls Ambiguate(sender, "none"), so our own sender is the short player name.
---@param sender string
---@return boolean
function CommsRouting:IsSelf(sender)
    return sender == UnitName("player")
end

---Returns true when the addon message arrived over a grouped distribution from a grouped sender.
---@param distribution string
---@param sender string Full sender name, including realm when AceComm provided one.
---@return boolean
function CommsRouting:IsMessageFromGroupMember(distribution, sender)
    return allowedGroupMessageDistributions[distribution] == true
        and (UnitInParty(sender) or UnitInRaid(sender))
end
