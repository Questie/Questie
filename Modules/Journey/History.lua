---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")


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
            text = QuestieLocale:GetUIString('JOURNEY_TABLE_YEAR', year),
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
        if not dateTable[year] then
            dateTable[year] = {}
        end

        local month = tonumber(date('%m', v.Timestamp))

        if not dateTable[year][month] then
            dateTable[year][month] = {}
        end

        ---@class SortedJourneyEntry
        local entry = {}
        ---@type integer
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
        entryText = QuestieLocale:GetUIString('JOURNEY_LEVELREACH', entry.NewLevel)
    elseif entry.Event == "Note" then
        entryText = QuestieLocale:GetUIString('JOURNEY_TABLE_NOTE', entry.Title)
    elseif entry.Event == "Quest" then
        local state = ""
        if entry.SubType == "Accept" then
            state = QuestieLocale:GetUIString('JOURNEY_ACCEPT')
        elseif entry.SubType == "Complete" then
            state = QuestieLocale:GetUIString('JOUNREY_COMPLETE')
        elseif entry.SubType == "Abandon" then
            state = QuestieLocale:GetUIString('JOURNEY_ABADON')
        else
            state = "ERROR!!"
        end
        local qName = QuestieDB.QueryQuestSingle(entry.Quest, "name")
        if qName then
            entryText = QuestieLocale:GetUIString('JOURNEY_TABLE_QUEST', state, qName)
        else
            entryText = QuestieLocale:GetUIString('JOURNEY_MISSING_QUEST')
        end
    end
    return entryText
end
