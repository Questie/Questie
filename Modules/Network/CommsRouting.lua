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

---Realm names differ between APIs only by spaces, dashes and case ("Classic Beta PvE" vs "ClassicBetaPvE").
---@param realm string?
---@return string?
local function _NormalizeRealm(realm)
    if type(realm) ~= "string" or realm == "" then
        return nil
    end
    return realm:gsub("[%s%-]", ""):lower()
end

---AceComm calls Ambiguate(sender, "none"), which usually makes our own sender the short player name.
---Realms whose display name differs from the normalized one (e.g. "Classic Beta PvE") can keep the
---realm suffix, so compare the full name with both realms normalized the same way.
---@param sender string
---@return boolean
function CommsRouting:IsSelf(sender)
    if type(sender) ~= "string" or sender == "" then
        return false
    end
    local playerName, playerRealm = UnitFullName("player")
    -- Character names never contain dashes or spaces, so the first one starts the realm suffix.
    local senderName, senderRealm = sender:match("^([^%-%s]+)[%-%s]?(.*)$")
    if (not senderName) or senderName ~= playerName then
        return false
    end
    senderRealm = _NormalizeRealm(senderRealm)
    if not senderRealm then
        return true
    end
    return senderRealm == _NormalizeRealm(playerRealm)
        or senderRealm == _NormalizeRealm(GetNormalizedRealmName and GetNormalizedRealmName())
        or senderRealm == _NormalizeRealm(GetRealmName())
end

---Returns true when the addon message arrived over a grouped distribution from a grouped sender.
---@param distribution string
---@param sender string Full sender name, including realm when AceComm provided one.
---@return boolean
function CommsRouting:IsMessageFromGroupMember(distribution, sender)
    return allowedGroupMessageDistributions[distribution] == true
        and (UnitInParty(sender) or UnitInRaid(sender))
end
