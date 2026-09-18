---@class VersionCheckDB
local VersionCheckDB = QuestieLoader:CreateModule("VersionCheckDB")

---Reads the active flavor's TOC; an absent or malformed requirement must never default to a supported version.
---@return integer? required
---@return string? message
function VersionCheckDB.GetRequiredContract()
    local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local value = getMetadata and getMetadata("Questie", "X-QuestieDB-Contract")
    local required = type(value) == "string" and value:match("^[1-9][0-9]*$") and tonumber(value)
    if not required or required == math.huge or required % 1 ~= 0 then
        return nil, "Questie's TOC has a missing or invalid X-QuestieDB-Contract. Reinstall Questie."
    end
    return required
end

---Checks the declared consumer contract against the provider's supported range, not version equality.
---This does not stop TOC file loading; callers must stop their own initialization on failure.
---@return boolean supported
---@return string? message
function VersionCheckDB.Check()
    local required, message = VersionCheckDB.GetRequiredContract()
    if not required then
        return false, message
    end

    local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local installedVersion = getMetadata and getMetadata("QuestieDB", "Version") or "unknown"
    local context = ("Questie requires QuestieDB contract %d; installed QuestieDB version: %s. ")
        :format(required, installedVersion)
    if type(LibQuestieDB) ~= "table" or type(LibQuestieDB.RequireContract) ~= "function" then
        return false, context .. "The provider contract API is unavailable. Install or update QuestieDB and reload."
    end

    local supported, contractError = LibQuestieDB.RequireContract(required)
    if supported ~= true then
        return false, context .. (contractError or "The installed provider does not support this contract. Update Questie or QuestieDB.")
    end
    return true
end
