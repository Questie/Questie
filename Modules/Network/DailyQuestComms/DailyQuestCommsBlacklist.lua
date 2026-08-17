---@class DailyQuestCommsBlacklist
local DailyQuestCommsBlacklist = QuestieLoader:CreateModule("DailyQuestCommsBlacklist")

-- These quests are excluded from broadcasting and incoming broadcasts are rejected for them.
---@type table<QuestId, boolean>
local blacklistedQuestIds = {
    -- Blackrock Eruption SoD event
    [84348] = true, -- Priority Target: Duke Tectonis
    [84349] = true, -- Priority Target: Duke Searbrand
    [84350] = true, -- Grinding Them Down
    [84351] = true, -- Work Smarter, Not Harder
    [84355] = true, -- More Like Lame-bringers!
    [84356] = true, -- Oh, Shiny!
    [84359] = true, -- Sleepless Nights
    [84360] = true, -- Firefighting
    [84372] = true, -- Lava Diving
}

---@param questId QuestId @The quest ID to check.
---@return boolean @True if the quest ID is blacklisted.
function DailyQuestCommsBlacklist.IsBlacklisted(questId)
    if (not Questie.IsSoD) then
        return false
    end

    return blacklistedQuestIds[questId] == true
end

---@param questIds QuestId[] @The original list of quest IDs.
---@return QuestId[] @A new list with blacklisted quest IDs removed.
function DailyQuestCommsBlacklist.FilterQuestIds(questIds)
    if (not Questie.IsSoD) then
        return questIds
    end

    local filtered = {}
    for _, questId in ipairs(questIds) do
        if (not blacklistedQuestIds[questId]) then
            filtered[#filtered + 1] = questId
        end
    end
    return filtered
end
