---@class QuestieSearch
local QuestieSearch = QuestieLoader:CreateModule("QuestieSearch");
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

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
function QuestieSearch:ResetResults()
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
    QuestieSearch:ResetResults()
    for k, type in pairs(QuestieSearch.types) do
        QuestieSearch:Search(query, type)
    end
    return QuestieSearch.LastResult
end

-- Execute a search by ID for all types
function QuestieSearch:ByID(query)
    QuestieSearch:ResetResults()
    for k,type in pairs(QuestieSearch.types) do
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
function QuestieSearch:Search(query, searchType, queryType)
    -- Set up defaults
    queryType = queryType or "chars"
    local minLengthInt = 1
    local minLengthChars = 1
    -- Search type specific preparations
    local actualDatabase;
    local databaseKeys;
    local NAME_KEY;
    if searchType == "npc" then
        actualDatabase = QuestieDB.QueryNPCSingle--QuestieDB.npcData;
        databaseKeys = QuestieDB.NPCPointers
        NAME_KEY = QuestieDB.npcKeys.name;
    elseif searchType == "object" then
        actualDatabase = QuestieDB.QueryObjectSingle--QuestieDB.objectData;
        databaseKeys = QuestieDB.ObjectPointers
        NAME_KEY = QuestieDB.objectKeys.name;
    elseif searchType == "item" then
        actualDatabase = QuestieDB.QueryItemSingle--QuestieDB.itemData;
        databaseKeys = QuestieDB.ItemPointers
        NAME_KEY = QuestieDB.itemKeys.name;
    elseif searchType == "quest" then
        actualDatabase = QuestieDB.QueryQuestSingle--QuestieDB.questData;
        databaseKeys = QuestieDB.QuestPointers
        NAME_KEY = QuestieDB.questKeys.name;
    else
        return
    end
    if not QuestieFavourites then
        QuestieFavourites = {
            quest = {},
            npc = {},
            object = {},
            item = {},
        }
    end
    -- By default the favourites are displayed
    local database = QuestieFavourites[searchType];
    local queryLength = string.len(query)
    -- We have a query meeting the minimal search length criteria, change to actualDatabase
    if  (queryLength >= minLengthChars)
        or
        ((tonumber(query) ~= nil) and (queryLength >= minLengthInt))
    then
        database = actualDatabase;
        -- We had a previous whole database search, we can use the smaller QuestieSearch.LastResult to search now
        --[[if  ((tonumber(query) ~= nil) and (queryLength > minLengthInt))
            or
            ((queryLength > minLengthChars) and (queryLength > string.len(QuestieSearch.LastResult.query)))
        then
            database = QuestieSearch.LastResult[searchType];
        end]]--
    else
        databaseKeys = database;
    end
    -- iterate the seleceted database
    local searchCount = 0;
    for id, entryOrBoolean in pairs(databaseKeys) do
        -- This condition does the actual comparison for the search
        if (
                ( -- text search
                    (queryType == "chars")
                    and
                    (
                        (string.len(query) < minLengthChars) -- Too short, display favourites
                        or
                        (string.find(string.lower(actualDatabase(id, "name")), string.lower(query))) -- Perform search
                    )
                )
                or
                ( -- id search
                    (queryType == "int" and tonumber(query) ~= nil)
                    and
                    (
                        (string.len(query) < minLengthInt) -- Too short, display favourites
                        or
                        (string.find(tostring(id), query)) -- Perform search
                    )
                )
            )
        then -- We have a search result or a favourite to display
            searchCount = searchCount + 1;
            QuestieSearch.LastResult[searchType][id] = true;
        else -- This entry doesn't meet the search criteria, removed from the last results
            QuestieSearch.LastResult[searchType][id] = nil;
        end
    end
    QuestieSearch.LastResult.query = query
    QuestieSearch.LastResult.queryType = queryType
    return QuestieSearch.LastResult[searchType]
end
