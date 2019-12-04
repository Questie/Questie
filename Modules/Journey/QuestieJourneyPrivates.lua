---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")

local _QuestieJourney = QuestieJourney.private


--- Get a sorted copy of the journey entries.
---@return table<string, table<string, SortedJourneyEntry>>
function _QuestieJourney:GetJourneyEntries()
    local dateTable = {}
    -- -- Sort all of the entries by year and month
    -- ---@param v JourneyEntry
    for i, v in ipairs(Questie.db.char.journey) do
        local year = tonumber(date('%Y', v.Timestamp))
        if not dateTable[year] then
            dateTable[year] = {};
        end

        local month = tonumber(date('%m', v.Timestamp))

        if not dateTable[year][month] then
            dateTable[year][month] = {};
        end

        ---@class SortedJourneyEntry
        local entry = {};
        ---@type integer
        entry.idx = i;
        ---@type JourneyEntry
        entry.value = v;

        tinsert(dateTable[year][month], entry);
    end

    return dateTable
end

--- Get the month and year of the latest entry in the Journey.
--- This is used to select it in the tree view.
---@return integer @The month of the latest entry
---@return integer @The year of the latest entry
function _QuestieJourney:GetMonthAndYearOfLatestEntry()
    local journeyEntries = _QuestieJourney:GetJourneyEntries()
    local years = {}
    local months = {}

    for year, _ in pairs(journeyEntries) do
        table.insert(years, year)
    end
    if not next(years) then
        return nil, nil
    end
    local maxYear = math.max(unpack(years))

    for month, _ in pairs(journeyEntries[maxYear]) do
        table.insert(months, month)
    end
    local maxMonth = math.max(unpack(months))

    return maxMonth, maxYear
end