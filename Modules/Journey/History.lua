---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


function _QuestieJourney:GetHistory()
    local journeyEntries = _QuestieJourney:GetJourneyEntries()
    local years = {}
    for k in pairs(journeyEntries) do
        table.insert(years, k)
    end
    table.sort(years)

    local history = {}
    for _, year in pairs(years) do
        local yearTable = {
            value = year,
            text = l10n('Year %s', year),
            children = {},
        }

        for month=12, 1, -1 do -- Iterate the month from last to newest
            if journeyEntries[year][month] then -- Only check month with events
                local monthView = {
                    value = month,
                    text = CALENDAR_FULLDATE_MONTH_NAMES[month] .. ' '.. year,
                    children = {},
                }

                for entryIndex=#journeyEntries[year][month], 1, -1 do -- Iterate backwards to show newest first

                    ---@type JourneyEntry
                    local entry = journeyEntries[year][month][entryIndex]
                    local entryIdx = entry.idx
                    local entryText = _QuestieJourney:GetEntryText(entry.value)

                    local entryView = {
                        value = entryIdx,
                        text = entryText,
                    }

                    tinsert(monthView.children, entryView)
                end

                tinsert(yearTable.children, monthView)
            end
        end

        tinsert(history, yearTable)
    end

    return history
end

--- Get a sorted copy of the journey entries.
---@return table<string, table<string, SortedJourneyEntry>>
function _QuestieJourney:GetJourneyEntries()
    local dateTable = {}
    -- -- Sort all of the entries by year and month
    -- ---@param v JourneyEntry
    for i, v in ipairs(Questie.db.char.journey) do
        local year = tonumber(date('%Y', v.Timestamp))
        if (not dateTable[year]) then
            dateTable[year] = {}
        end

        local month = tonumber(date('%m', v.Timestamp))

        if (not dateTable[year][month]) then
            dateTable[year][month] = {}
        end

        ---@class SortedJourneyEntry
        local entry = {}
        ---@type number
        entry.idx = i
        ---@type JourneyEntry
        entry.value = v

        tinsert(dateTable[year][month], entry)
    end

    return dateTable
end

function _QuestieJourney:GetEntryText(entry)
    local entryText = ""

    if entry.Event == "Level" then
        entryText = l10n('You Reached Level %s', entry.NewLevel)
    elseif entry.Event == "Note" then
        entryText = l10n('Note: %s', entry.Title)
    elseif entry.Event == "Quest" then
        local state
        if entry.SubType == "Accept" then
            state = l10n('Accepted')
        elseif entry.SubType == "Complete" then
            state = l10n('Completed')
        elseif entry.SubType == "Abandon" then
            state = l10n('Abandoned')
        else
            state = "ERROR!!"
        end
        local qName = QuestieDB.QueryQuestSingle(entry.Quest, "name")
        entryText = l10n('Quest %s: %s', state or "no state", qName or "no quest name")
    end
    return entryText
end
