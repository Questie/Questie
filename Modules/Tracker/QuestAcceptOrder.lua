---@class QuestAcceptOrder
local QuestAcceptOrder = QuestieLoader:CreateModule("QuestAcceptOrder")

-- The journey already records every quest accept in the order it happened, so it is the source of the accept order.
-- Rebuilding the lookup scans the whole journey, so it is cached until the journey changes. Entries are appended on
-- every journey event and removed when a note is deleted; resetting the journey replaces the table.
local cachedJourney
local cachedLength
local cachedLastEntry
---@type table<QuestId, number>
local cachedOrder = {}

--- Returns the journey position of each quest's latest accept. A higher position means the quest was accepted more
--- recently. Quests whose accept the journey didn't record (e.g. accepted before Questie was installed) are absent.
---@return table<QuestId, number>
function QuestAcceptOrder.Get()
    local journey = Questie.db.char.journey or {}
    local length = #journey
    local lastEntry = journey[length]
    if journey == cachedJourney and length == cachedLength and lastEntry == cachedLastEntry then
        return cachedOrder
    end

    local order = {}
    for i = 1, length do
        local entry = journey[i]
        if entry.Event == "Quest" and entry.SubType == "Accept" and entry.Quest then
            -- Later accepts overwrite earlier ones, so a re-accepted quest counts from its latest accept.
            order[entry.Quest] = i
        end
    end

    cachedJourney = journey
    cachedLength = length
    cachedLastEntry = lastEntry
    cachedOrder = order
    return order
end
