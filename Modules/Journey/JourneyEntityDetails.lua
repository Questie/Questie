---What the Journey shows about an NPC, object or item.
---@class JourneyEntityDetails
local JourneyEntityDetails = QuestieLoader:CreateModule("JourneyEntityDetails")

---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyRawData
local JourneyRawData = QuestieLoader:ImportModule("JourneyRawData")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type ManualNotes
local ManualNotes = QuestieLoader:ImportModule("ManualNotes")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---@param low number
---@param high number
---@return string|number
local function _Range(low, high)
    return low == high and low or (low .. " - " .. high)
end

---Where an NPC or object is. Prefers a place with coordinates, which something inside an instance doesn't have.
---@param spawns table<AreaId, CoordPair[]>?
---@return AreaId? zoneId
---@return number? x
---@return number? y
local function _GetPlace(spawns)
    local anyZoneId
    for zoneId, coordinates in pairs(spawns or {}) do
        anyZoneId = anyZoneId or zoneId
        local x, y = coordinates[1] and coordinates[1][1], coordinates[1] and coordinates[1][2]
        if x and y and (x ~= -1 or y ~= -1) then
            return zoneId, x, y
        end
    end
    return anyZoneId
end

---Adds where something is, as a link that opens the map. Adds nothing when that isn't known.
---@param rows JourneyDetails.Row[]
---@param kind ManualNoteKind
---@param entity NPC|Object
function JourneyEntityDetails.AddPlace(rows, kind, entity)
    local zoneId, x, y = _GetPlace(entity.spawns)
    if not zoneId then
        return
    end

    local text = QuestieJourneyUtils:GetZoneName(zoneId)
    if x then
        text = text .. ("   X%s%.2f || Y%s%.2f"):format(l10n(": "), x, l10n(": "), y)
    end

    local uiMapId = ManualNotes.GetMap(zoneId)
    if not uiMapId then
        table.insert(rows, {type = "text", text = text})
        return
    end
    table.insert(rows, {
        type = "link",
        text = "|T" .. JourneyWindow.MAP_ICON .. ":14|t " .. text,
        onClick = function()
            if ManualNotes.OpenMap(kind, entity.id, uiMapId) then
                JourneyWindow.Hide() -- It would cover the map
            end
        end,
        showTooltip = function() GameTooltip:AddLine(l10n("Show on Map")) end,
    })
end

---Adds a button for TomTom. Adds nothing without it, or without coordinates.
---@param rows JourneyDetails.Row[]
---@param entity NPC|Object
function JourneyEntityDetails.AddTomTom(rows, entity)
    local zoneId, x, y = _GetPlace(entity.spawns)
    if x and TomTom and TomTom.AddWaypoint then
        table.insert(rows, {
            type = "button",
            text = l10n("Set |cFF54e33bTomTom|r Target"),
            onClick = function() TrackerUtils:SetTomTomTarget(entity.name, zoneId, x, y) end,
        })
    end
end

---@param isShown boolean
---@param onClick fun()
---@return JourneyDetails.Row
local function _GetNoteButton(isShown, onClick)
    return {type = "button", text = l10n(isShown and "Remove from Map" or "Show on Map"), onClick = onClick}
end

---@param npc NPC
---@return string[] lines
local function _GetNpcLines(npc)
    local friendlyTo = "no faction"
    if npc.friendlyToFaction == "AH" then
        friendlyTo = "both factions"
    elseif npc.friendlyToFaction == "A" then
        friendlyTo = "Alliance"
    elseif npc.friendlyToFaction == "H" then
        friendlyTo = "Horde"
    end

    local lines = {JourneyDetails.GetFactText("NPC ID", npc.id)}
    if npc.subName then
        table.insert(lines, JourneyDetails.GetFactText("Title", npc.subName))
    end
    table.insert(lines, JourneyDetails.GetFactText("Level", _Range(npc.minLevel, npc.maxLevel)))
    table.insert(lines, JourneyDetails.GetFactText("Health", _Range(npc.minLevelHealth, npc.maxLevelHealth)))
    table.insert(lines, JourneyDetails.GetFactText("Friendly to", l10n(friendlyTo)))
    return lines
end

---@param kind ManualNoteKind
---@param id number
---@param onChanged fun() Called after the user changed something the rows show
---@return JourneyDetails.Row[]
local function _GetSpawnRows(kind, id, onChanged)
    local isNpc = kind == "npc"
    local entity
    if isNpc then
        entity = QuestieDB:GetNPC(id)
    else
        entity = QuestieDB:GetObject(id)
    end
    if not entity then
        return {}
    end

    local lines = isNpc and _GetNpcLines(entity) or {JourneyDetails.GetFactText("Object ID", id)}
    ---@type JourneyDetails.Row[]
    local rows = {
        {type = "heading", text = entity.name},
        {type = "entity", npcId = isNpc and id or nil, text = table.concat(lines, "\n")},
    }
    if entity.spawns then
        JourneyEntityDetails.AddPlace(rows, kind, entity)
        table.insert(rows, _GetNoteButton(ManualNotes.IsShown(kind, id), function()
            if ManualNotes.IsShown(kind, id) then
                ManualNotes.Hide(kind, id)
            else
                ManualNotes.Show(kind, id)
            end
            onChanged()
        end))
        JourneyEntityDetails.AddTomTom(rows, entity)
    else
        table.insert(rows, {type = "text", text = l10n("No spawn data available.")})
    end

    JourneyDetails.AddBox(rows, l10n("Starts the following quests"), JourneyLinks.GetRows("quest", entity.questStarts or {}))
    JourneyDetails.AddBox(rows, l10n("Ends the following quests"), JourneyLinks.GetRows("quest", entity.questEnds or {}))
    JourneyRawData.AddRows(rows, entity, isNpc and QuestieDB.npcKeys or QuestieDB.objectKeys)
    return rows
end

---@class JourneyItemSource
---@field field string
---@field kind ManualNoteKind
---@field heading string
---@field countText string
---@field noneText string

---@type JourneyItemSource[]
local ITEM_SOURCES = {
    {field = "npcDrops", kind = "npc", heading = "NPCs", countText = "%d NPCs drop this item", noneText = "No NPC drops this item"},
    {field = "objectDrops", kind = "object", heading = "Objects", countText = "%d Objects drop this item", noneText = "No Object drops this item"},
    {field = "vendors", kind = "npc", heading = "Vendors", countText = "%d Vendors sell this item", noneText = "No Vendor sells this item"},
}

---@param source JourneyItemSource
---@param ids number[]?
---@return number[] ids Those that can be found by the player
local function _GetReachableIds(source, ids)
    local reachableIds = {}
    for _, id in pairs(ids or {}) do
        local spawns
        if source.kind == "npc" then
            spawns = QuestieDB.QueryNPCSingle(id, "spawns")
        else
            spawns = QuestieDB.QueryObjectSingle(id, "spawns")
        end
        local isHostileVendor = source.field == "vendors"
            and not QuestieDB.IsFriendlyToPlayer(QuestieDB.QueryNPCSingle(id, "friendlyToFaction"))
        if spawns and not isHostileVendor then
            table.insert(reachableIds, id)
        end
    end
    return reachableIds
end

---@param itemId ItemId
---@return JourneyDetails.Row
local function _GetItemRow(itemId)
    return {
        type = "entity",
        icon = QuestieCompat.GetItemIcon(itemId),
        text = JourneyDetails.GetFactText("Item ID", itemId),
        onClick = function()
            local _, link = QuestieCompat.GetItemInfo(itemId)
            if not link then
                return -- The client doesn't know the item yet
            end
            if IsShiftKeyDown() then
                if ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(link)
                else
                    ChatFrame_OpenChat(link)
                end
            elseif IsControlKeyDown() then
                DressUpItemLink(link)
            end
        end,
    }
end

---@param itemId ItemId
---@param onChanged fun()
---@return JourneyDetails.Row[]
local function _GetItemRows(itemId, onChanged)
    local name = QuestieDB.QueryItemSingle(itemId, "name")
    if not name then
        return {}
    end

    ---@type JourneyDetails.Row[]
    local rows = {
        {type = "heading", text = name},
        _GetItemRow(itemId),
        {type = "itemTooltip", itemId = itemId},
    }
    if QuestieCorrections.questItemBlacklist[itemId] then
        table.insert(rows, {type = "text", text = l10n("This item is blacklisted because it has too many sources")})
        return rows
    end

    local idsBySource = QuestieDB.QueryItem(itemId, {"npcDrops", "objectDrops", "vendors"})
    for index, source in ipairs(ITEM_SOURCES) do
        local ids = _GetReachableIds(source, idsBySource[index])
        local hasSources = idsBySource[index] and next(idsBySource[index]) ~= nil

        table.insert(rows, {type = "heading", text = l10n(source.heading)})
        table.insert(rows, {type = "text", text = hasSources and l10n(source.countText, #ids) or l10n(source.noneText)})
        if #ids > 0 then
            local group = "item " .. itemId .. " " .. source.field
            local isShown = ManualNotes.IsGroupShown(group)
            table.insert(rows, _GetNoteButton(isShown, function()
                if isShown then
                    ManualNotes.HideGroup(group, source.kind, ids)
                else
                    ManualNotes.ShowGroup(group, source.kind, ids)
                end
                onChanged()
            end))
            JourneyDetails.AddBox(rows, "", JourneyLinks.GetRows(source.kind, ids))
        end
    end

    JourneyRawData.AddRows(rows, QuestieDB:GetItem(itemId), QuestieDB.itemKeys)
    return rows
end

---@param kind "npc"|"object"|"item"
---@param id number
---@param onChanged fun() Called after the user changed something the rows show
---@return JourneyDetails.Row[] rows Empty when it isn't in the database
function JourneyEntityDetails.GetRows(kind, id, onChanged)
    if kind == "item" then
        return _GetItemRows(id, onChanged)
    end
    return _GetSpawnRows(kind, id, onChanged)
end

return JourneyEntityDetails
