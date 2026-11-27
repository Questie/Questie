---What the Journey shows about an NPC or object. Items have JourneyItemDetails.
---@class JourneyEntityDetails
local JourneyEntityDetails = QuestieLoader:CreateModule("JourneyEntityDetails")

---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyRawData
local JourneyRawData = QuestieLoader:ImportModule("JourneyRawData")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type ManualNotes
local ManualNotes = QuestieLoader:ImportModule("ManualNotes")
---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type JourneyNameColors
local JourneyNameColors = QuestieLoader:ImportModule("JourneyNameColors")
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

---@class JourneyEntityZone
---@field zoneId AreaId
---@field count number Of the spawns there
---@field hasCoordinates boolean Something inside an instance has none

---Where an NPC or object spawns, the zones with coordinates first, and of those the one with the most spawns.
---@param spawns table<AreaId, CoordPair[]>?
---@return JourneyEntityZone[]
local function _GetZones(spawns)
    local zones = {}
    for zoneId, coordinates in pairs(spawns or {}) do
        local first = coordinates[1]
        table.insert(zones, {
            zoneId = zoneId,
            count = #coordinates,
            hasCoordinates = first ~= nil and first[1] ~= nil and first[2] ~= nil and (first[1] ~= -1 or first[2] ~= -1),
        })
    end
    table.sort(zones, function(a, b)
        if a.hasCoordinates ~= b.hasCoordinates then
            return a.hasCoordinates
        elseif a.count ~= b.count then
            return a.count > b.count
        end
        return a.zoneId < b.zoneId
    end)
    return zones
end

---Where an NPC or object is most of all: the zone with the most spawns, preferring those with coordinates.
---@param spawns table<AreaId, CoordPair[]>?
---@return AreaId? zoneId Nil without spawns
function JourneyEntityDetails.GetZoneId(spawns)
    local zone = _GetZones(spawns)[1]
    return zone and zone.zoneId
end

---@param coordinate number
---@return string text Those below 10 start with two spaces, which are as wide as the digit others have there
local function _FormatCoordinate(coordinate)
    local text = ("%.1f"):format(coordinate)
    return #text < 4 and "  " .. text or text
end

---@param kind ManualNoteKind
---@param id number
---@param zoneId AreaId
---@return fun()? showOnMap Nil when there is no map of the zone
local function _GetShowOnMap(kind, id, zoneId)
    local uiMapId = ManualNotes.GetMap(zoneId)
    return uiMapId and function()
        if ManualNotes.OpenMap(kind, id, uiMapId) then
            JourneyWindow.Hide() -- It would cover the map
        end
    end
end

---Where an NPC or object is: the zone with the most spawns. Its coordinates only with one spawn, which they lead to. TomTom
---leads to the first spawn in the zone either way.
---@param kind ManualNoteKind
---@param entity NPC|Object
---@return string? text
---@return fun()? showOnMap
---@return fun()? setTomTomTarget
function JourneyEntityDetails.GetPlace(kind, entity)
    local zones = _GetZones(entity.spawns)
    local zone = zones[1]
    if not zone then
        return nil
    end
    local text = QuestieJourneyUtils:GetZoneName(zone.zoneId)
    local x, y
    if zone.hasCoordinates then
        x, y = entity.spawns[zone.zoneId][1][1], entity.spawns[zone.zoneId][1][2]
        if zone.count == 1 and #zones == 1 then
            text = text .. "  " .. _FormatCoordinate(x) .. ", " .. _FormatCoordinate(y)
        end
    end
    local setTomTomTarget = x and TomTom and TomTom.AddWaypoint and function()
        TrackerUtils:SetTomTomTarget(entity.name, zone.zoneId, x, y)
    end
    return text, _GetShowOnMap(kind, entity.id, zone.zoneId), setTomTomTarget
end

---A small map at the right edge of a row, which puts something on the map or removes it again.
---@param kind ManualNoteKind
---@param id number
---@param onChanged fun() Called after it was clicked
---@return JourneyDetails.Action action
---@return string state Differs when the action does
function JourneyEntityDetails.GetMapAction(kind, id, onChanged)
    local isShown = ManualNotes.IsShown(kind, id)
    local action = {
        isOn = isShown,
        tooltip = isShown and l10n("Remove from Map") or l10n("Show on Map"),
        onClick = function()
            if ManualNotes.IsShown(kind, id) then ManualNotes.Hide(kind, id) else ManualNotes.Show(kind, id) end
            onChanged()
        end,
    }
    return action, isShown and "shown" or "not shown"
end

---What the game shows about an NPC: its title below the name, and its level with the dragon of its rank. Then whom it is
---friendly to.
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

    local lines = {}
    if npc.subName then
        table.insert(lines, "<" .. npc.subName .. ">")
    end
    local level = JourneyDetails.GetFactText("Level", _Range(npc.minLevel, npc.maxLevel))
    local rank = QuestieLib.GetRankMarkup(npc.rank)
    table.insert(lines, rank and level .. " " .. rank or level)
    table.insert(lines, JourneyDetails.GetFactText("Friendly to", l10n(friendlyTo)))
    return lines
end

---What the player can do here now, in the words and colors of the status of a quest. Nil when there is nothing.
---@param starts JourneyQuestCategories.Entry[]
---@param ends JourneyQuestCategories.Entry[]
---@return string? text
local function _GetStatus(starts, ends)
    local ready, available, active = 0, 0, 0
    for _, entry in ipairs(ends) do
        if entry.category == "log" then
            local state = JourneyQuestCategories.GetLogState(entry.questId)
            if state == "ready" then
                ready = ready + 1
            elseif state == "active" then
                active = active + 1
            end
        end
    end
    for _, entry in ipairs(starts) do
        if entry.category == "available" or entry.category == "repeatable" then
            available = available + 1
        end
    end

    local parts = {}
    if ready > 0 then
        table.insert(parts, JourneyIcon.GetMarkup(Questie.icons["complete"]) .. Questie:Colorize(QUEST_WATCH_QUEST_READY .. l10n(": "), "green") .. ready)
    end
    if available > 0 then
        table.insert(parts, JourneyIcon.GetMarkup(Questie.icons["available"]) .. Questie:Colorize(l10n("Available") .. l10n(": "), "gold") .. available)
    end
    if active > 0 then
        -- Not QUEST_TOOLTIP_ACTIVE of the quest's status, which is a sentence: "You are on this quest"
        table.insert(parts, JourneyIcon.GetMarkup(Questie.icons["incomplete"]) .. Questie:Colorize(l10n("Active") .. l10n(": "), "lightBlue") .. active)
    end
    return #parts > 0 and table.concat(parts, "     ") or nil
end

---Each zone it spawns in, when there are several, leading to the map there.
---@param rows JourneyDetails.Row[]
---@param kind ManualNoteKind
---@param id number
---@param zones JourneyEntityZone[]
---@param onChanged fun()
local function _AddZones(rows, kind, id, zones, onChanged)
    if #zones < 2 then
        return
    end
    table.insert(rows, {type = "caption", text = l10n("Where")})
    for _, zone in ipairs(zones) do
        local showOnMap = _GetShowOnMap(kind, id, zone.zoneId)
        table.insert(rows, {
            type = "step",
            text = QuestieJourneyUtils:GetZoneName(zone.zoneId),
            tag = zone.count > 1 and tostring(zone.count) or nil, -- How many spawns, like the zones of a faction say how many quests
            onClick = showOnMap and function()
                showOnMap()
                onChanged() -- It is on the map now, also when the map can't be opened in combat
            end,
            showTooltip = showOnMap and function() GameTooltip:AddLine(l10n("Show on Map")) end,
        })
    end
end

---Puts it on the map or removes it again, and leads TomTom there.
---@param kind ManualNoteKind
---@param id number
---@param setTomTomTarget fun()?
---@param onChanged fun()
---@return JourneyDetails.Row
local function _GetFooter(kind, id, setTomTomTarget, onChanged)
    local action, state = JourneyEntityDetails.GetMapAction(kind, id, onChanged)
    local buttons = {{text = action.tooltip, icon = JourneyIcon.MAP, onClick = action.onClick}}
    if setTomTomTarget then
        table.insert(buttons, {text = "TomTom", icon = JourneyIcon.ARROW, onClick = setTomTomTarget})
    end
    return {type = "footer", buttons = buttons, state = state .. " " .. tostring(setTomTomTarget ~= nil)}
end

---@param kind ManualNoteKind
---@param id number
---@param onChanged fun() Called after the user changed something the rows show
---@return JourneyDetails.Row[] rows Empty when it isn't in the database
function JourneyEntityDetails.GetRows(kind, id, onChanged)
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

    local place, showOnMap, setTomTomTarget = JourneyEntityDetails.GetPlace(kind, entity)
    local lines = isNpc and _GetNpcLines(entity) or {}
    if place then
        table.insert(lines, place)
    end
    ---@type JourneyDetails.Row[]
    local rows = {
        {
            type = "page",
            text = isNpc and JourneyNameColors.Npc(id, entity.name) or JourneyNameColors.Object(entity.name),
            tag = l10n(isNpc and "NPC ID" or "Object ID") .. l10n(": ") .. id,
        },
        {type = "gap", height = 6},
        {
            type = "entity",
            npcId = isNpc and id or nil,
            -- Objects have no face, so they have the icon of their objectives
            icon = not isNpc and Questie.icons["object"] or nil,
            text = table.concat(lines, "\n"),
            onShowMap = showOnMap and function()
                showOnMap()
                onChanged() -- It is on the map now, also when the map can't be opened in combat
            end,
        },
    }
    if not entity.spawns then
        table.insert(rows, {type = "text", text = l10n("No spawn data available.")})
    end

    local starts, startEntries = JourneyLinks.GetQuestSteps(entity.questStarts)
    local ends, endEntries = JourneyLinks.GetQuestSteps(entity.questEnds)
    local status = _GetStatus(startEntries, endEntries)
    if status then
        table.insert(rows, {type = "gap", height = 4})
        table.insert(rows, {type = "status", text = status})
    end

    _AddZones(rows, kind, id, _GetZones(entity.spawns), onChanged)
    JourneyDetails.AddSection(rows, l10n("Starts the following quests"), starts)
    JourneyDetails.AddSection(rows, l10n("Ends the following quests"), ends)
    JourneyRawData.AddRows(rows, entity, isNpc and QuestieDB.npcKeys or QuestieDB.objectKeys)
    if entity.spawns then
        table.insert(rows, _GetFooter(kind, id, setTomTomTarget, onChanged))
    end
    return rows
end

return JourneyEntityDetails
