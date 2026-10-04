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

---AceComm calls Ambiguate(sender, "none"), which usually makes our own sender the short player name.
---Realms whose display name differs from the normalized one (e.g. "Classic Beta PvE") can keep the
---realm suffix, so also resolve the name as a unit before treating it as another player.
---@param sender string
---@return boolean
function CommsRouting:IsSelf(sender)
    if type(sender) ~= "string" or sender == "" then
        return false
    end
    return sender == UnitName("player") or UnitIsUnit(sender, "player") == true
end

---Returns true when the addon message arrived over a grouped distribution from a grouped sender.
---@param distribution string
---@param sender string Full sender name, including realm when AceComm provided one.
---@return boolean
function CommsRouting:IsMessageFromGroupMember(distribution, sender)
    return allowedGroupMessageDistributions[distribution] == true
        and (UnitInParty(sender) or UnitInRaid(sender))
end
