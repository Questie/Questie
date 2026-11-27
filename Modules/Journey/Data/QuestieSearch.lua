---Finds quests, NPCs, objects and items by a part of their name or ID.
---@class QuestieSearch
local QuestieSearch = QuestieLoader:CreateModule("QuestieSearch")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")

---@alias JourneyKind "quest"|"npc"|"object"|"item"

---@type JourneyKind[]
QuestieSearch.KINDS = {"quest", "npc", "object", "item"}

---@param kind JourneyKind
---@return fun(id: number, field: string): any query
---@return table<number, any> pointers
local function _GetDatabase(kind)
    if kind == "quest" then
        return QuestieDB.QueryQuestSingle, QuestieDB.QuestPointers
    elseif kind == "npc" then
        return QuestieDB.QueryNPCSingle, QuestieDB.NPCPointers
    elseif kind == "object" then
        return QuestieDB.QueryObjectSingle, QuestieDB.ObjectPointers
    elseif kind == "item" then
        return QuestieDB.QueryItemSingle, QuestieDB.ItemPointers
    end
    error("Unknown kind: " .. tostring(kind))
end

---@param kind JourneyKind
---@param id number
---@return string? name
function QuestieSearch.GetName(kind, id)
    return (_GetDatabase(kind))(id, "name")
end

---Goes through a whole database, so it yields. Every caller runs it in a thread.
---@async
---@param kind JourneyKind
---@param query string In quotes, only an exact match counts
---@return number[] ids In ascending order
function QuestieSearch.Search(kind, query)
    local queryName, pointers = _GetDatabase(kind)
    local isIdSearch = tonumber(query) ~= nil

    local first, last = query:sub(1, 1), query:sub(-1)
    local isExact = #query > 1 and (first == '"' or first == "'") and first == last
    if isExact then
        query = query:sub(2, -2)
    end
    query = query:lower()

    local ids = {}
    for id in pairs(pointers) do
        local text = isIdSearch and tostring(id) or (queryName(id, "name") or ""):lower()
        local isMatch = isExact and text == query or not isExact and text:find(query, 1, true)
        -- Some entries don't have a name because of the way we load corrections
        if isMatch and queryName(id, "name") then
            table.insert(ids, id)
        end
        JourneyThread.YieldIfNeeded()
    end
    table.sort(ids)
    return ids
end

return QuestieSearch
