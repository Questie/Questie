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
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
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

---@param coordinate number
---@return string text Those below 10 start with two spaces, which are as wide as the digit others have there
local function _FormatCoordinate(coordinate)
    local text = ("%.1f"):format(coordinate)
    return #text < 4 and "  " .. text or text
end

---@param kind ManualNoteKind
---@param entity NPC|Object
---@return string? text
---@return fun()? showOnMap
---@return fun()? setTomTomTarget
function JourneyEntityDetails.GetPlace(kind, entity)
    local zoneId, x, y = _GetPlace(entity.spawns)
    if not zoneId then
        return nil
    end
    local text = QuestieJourneyUtils:GetZoneName(zoneId)
    if x then
        text = text .. "  " .. _FormatCoordinate(x) .. ", " .. _FormatCoordinate(y)
    end
    local uiMapId = ManualNotes.GetMap(zoneId)
    local showOnMap = uiMapId and function()
        if ManualNotes.OpenMap(kind, entity.id, uiMapId) then
            JourneyWindow.Hide() -- It would cover the map
        end
    end
    local setTomTomTarget = x and TomTom and TomTom.AddWaypoint and function()
        TrackerUtils:SetTomTomTarget(entity.name, zoneId, x, y)
    end
    return text, showOnMap, setTomTomTarget
end

---A small map at the right edge of a row, which puts something on the map or removes it again.
---@param kind ManualNoteKind
---@param id number
---@param onChanged fun() Called after it was clicked
---@return {tooltip: string, isOn: boolean, onClick: fun()} action
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
        table.insert(lines, JourneyDetails.GetFactText("Title", npc.subName))
    end
    table.insert(lines, JourneyDetails.GetFactText("Level", _Range(npc.minLevel, npc.maxLevel)))
    if (npc.maxLevelHealth or 0) > 1 then
        table.insert(lines, JourneyDetails.GetFactText("Health", _Range(npc.minLevelHealth, npc.maxLevelHealth)))
    end
    table.insert(lines, JourneyDetails.GetFactText("Friendly to", l10n(friendlyTo)))
    return lines
end

---@param rows JourneyDetails.Row[]
---@param caption string
---@param questIds QuestId[]?
local function _AddQuests(rows, caption, questIds)
    local steps = JourneyLinks.GetQuestSteps(questIds)
    if #steps > 0 then
        table.insert(rows, {type = "caption", text = l10n(caption)})
        for _, step in ipairs(steps) do table.insert(rows, step) end
    end
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
        {type = "entity", npcId = isNpc and id or nil, text = table.concat(lines, "\n")},
    }
    local footer
    if entity.spawns then
        local isShown = ManualNotes.IsShown(kind, id)
        local buttons = {}
        rows[#rows].onShowMap = showOnMap
        if isShown then
            table.insert(buttons, {
                text = l10n("Remove from Map"),
                icon = JourneyIcon.HIDDEN,
                onClick = function()
                    ManualNotes.Hide(kind, id)
                    onChanged()
                end,
            })
        end
        if setTomTomTarget then
            table.insert(buttons, {text = "TomTom", icon = JourneyIcon.ARROW, onClick = setTomTomTarget})
        end
        footer = #buttons > 0 and {type = "footer", buttons = buttons, state = tostring(isShown)} or nil
    else
        table.insert(rows, {type = "text", text = l10n("No spawn data available.")})
    end

    _AddQuests(rows, "Starts the following quests", entity.questStarts)
    _AddQuests(rows, "Ends the following quests", entity.questEnds)
    JourneyRawData.AddRows(rows, entity, isNpc and QuestieDB.npcKeys or QuestieDB.objectKeys)
    table.insert(rows, footer)
    return rows
end

---@param kind ManualNoteKind
---@param id number
---@param onChanged fun() Called after the user changed something the rows show
---@return JourneyDetails.Row[] rows Empty when it isn't in the database
function JourneyEntityDetails.GetRows(kind, id, onChanged)
    return _GetSpawnRows(kind, id, onChanged)
end

return JourneyEntityDetails
