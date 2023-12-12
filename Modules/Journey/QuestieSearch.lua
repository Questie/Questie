---@class QuestieSearch
local QuestieSearch = QuestieLoader:CreateModule("QuestieSearch");

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

QuestieSearch.types = {"npc", "object", "item", "quest"}

-- Save search results, so the next search has a smaller set to search
QuestieSearch.LastResult = {
    query = '',
    queryType = '',
    quest = {},
    npc = {},
    object = {},
    item = {},
}
local function _ResetResults()
    QuestieSearch.LastResult = {
        query = '',
        queryType = '',
        quest = {},
        npc = {},
        object = {},
        item = {},
    }
end

-- Execute a search by name for all types
function QuestieSearch:ByName(query)
    _ResetResults()
    for _, type in pairs(QuestieSearch.types) do
        QuestieSearch:Search(query, type, "chars")
    end
    return QuestieSearch.LastResult
end

-- Execute a search by ID for all types
function QuestieSearch:ByID(query)
    _ResetResults()
    for _,type in pairs(QuestieSearch.types) do
        QuestieSearch:Search(query, type, "int")
    end
    return QuestieSearch.LastResult
end

--[[
QuestieSearch:Search

This function searches a value from the database, including partial matches.

Adds the values to QuestieSearch.LastResult.

Returns table of found IDs for the selected search type.

Parameters:

query       The search string/int

searchType  Which database to search, possible values:
            "npc"
            "object"
            "item"
            "quest"

queryType   Which type of search to run, possible values:
            "chars"
            "int"
            Optional. Default: "chars"
--]]

function QuestieSearch:Search(rawQuery, searchType, queryType)
    queryType = queryType or "chars"

    local databaseQueryHandle
    local databaseKeys

    if searchType == "npc" then
        databaseQueryHandle = QuestieDB.QueryNPCSingle
        databaseKeys = QuestieDB.NPCPointers
    elseif searchType == "object" then
        databaseQueryHandle = QuestieDB.QueryObjectSingle
        databaseKeys = QuestieDB.ObjectPointers
    elseif searchType == "item" then
        databaseQueryHandle = QuestieDB.QueryItemSingle
        databaseKeys = QuestieDB.ItemPointers
    elseif searchType == "quest" then
        databaseQueryHandle = QuestieDB.QueryQuestSingle
        databaseKeys = QuestieDB.QuestPointers
    else
        return
    end

    local sanitizedQuery
    local strictSearch = false
    if type(rawQuery) ~= "number" then
        local stringFirst, stringLast = rawQuery:sub(1, 1), rawQuery:sub(-1)
        if (stringFirst == '"' or stringFirst == "'") and (stringLast == stringFirst) then
            strictSearch = true
            sanitizedQuery = rawQuery:sub(2, -2)
        else
            sanitizedQuery = rawQuery
        end
    else
        sanitizedQuery = rawQuery
    end

    local searchCount = 0;
    local isTextSearch = queryType == "chars"
    local isIdSearch = queryType == "int" and tonumber(sanitizedQuery) ~= nil

    local lastResults = QuestieSearch.LastResult[searchType]
    if isTextSearch then
        local queryToFind = string.lower(sanitizedQuery)
        for id, _ in pairs(databaseKeys) do
            local name = databaseQueryHandle(id, "name") -- Some entries don't have a 'name' because of the way we load corrections
            if strictSearch then
                if name and (string.lower(name) == queryToFind) then -- strict search
                    -- We have a search result or a favourite to display
                    searchCount = searchCount + 1;
                    QuestieSearch.LastResult[searchType][id] = true;
                else
                    -- This entry doesn't meet the search criteria, removed from the last results
                    QuestieSearch.LastResult[searchType][id] = nil;
                end
            else
                if name and string.find(string.lower(name), queryToFind) then -- fuzzy search
                    -- We have a search result or a favourite to display
                    searchCount = searchCount + 1;
                    QuestieSearch.LastResult[searchType][id] = true;
                else
                    -- This entry doesn't meet the search criteria, removed from the last results
                    QuestieSearch.LastResult[searchType][id] = nil;
                end
            end
        end
    elseif isIdSearch then
        for id, _ in pairs(databaseKeys) do
            if strictSearch then
                if tostring(id) == sanitizedQuery then -- strict search
                    -- We have a search result or a favourite to display
                    searchCount = searchCount + 1;
                    lastResults[id] = true;
                else
                    -- This entry doesn't meet the search criteria, removed from the last results
                    lastResults[id] = nil;
                end
            else
                if string.find(tostring(id), sanitizedQuery) then -- fuzzy search
                    -- We have a search result or a favourite to display
                    searchCount = searchCount + 1;
                    lastResults[id] = true;
                else
                    -- This entry doesn't meet the search criteria, removed from the last results
                    lastResults[id] = nil;
                end
            end
        end
    end

    QuestieSearch.LastResult.query = rawQuery
    return QuestieSearch.LastResult[searchType]
end
