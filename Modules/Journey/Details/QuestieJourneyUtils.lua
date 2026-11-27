---@class QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:CreateModule("QuestieJourneyUtils")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

function QuestieJourneyUtils:GetSortedZoneKeys(zones)
    local function compare(a, b)
        return zones[a] < zones[b]
    end

    local zoneNames = {}
    for k, _ in pairs(zones) do
        table.insert(zoneNames, k)
    end
    table.sort(zoneNames, compare)
    return zoneNames
end

---@param id AreaId
---@return string
function QuestieJourneyUtils:GetZoneName(id)
    for _, zones in pairs(l10n.zoneLookup) do
        if zones[id] then
            return l10n(zones[id])
        end
    end
    local dungeonName = l10n.zoneCategoryLookup[9][id]
    return l10n(dungeonName or "Unknown Zone")
end

---@param desc table | string
---@return string
function QuestieJourneyUtils.CreateObjectiveText(desc)
    local objText = ""

    if desc then
        if type(desc) == "table" then
            for _, v in ipairs(desc) do
                objText = objText .. v .. "\n"
            end
        else
            objText = objText .. tostring(desc) .. "\n"
        end
    else
        objText = Questie:Colorize(l10n('This quest is an automatic completion quest and does not contain an objective.'), 'yellow')
    end

    return objText
end

return QuestieJourneyUtils
