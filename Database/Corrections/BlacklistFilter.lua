---@class BlacklistFilter
local BlacklistFilter = QuestieLoader:CreateModule("BlacklistFilter")

--- Removes all entries from the blacklist that are not marked as `true`.
---@param blacklist table<QuestId, boolean>
---@return table<QuestId, boolean>
function BlacklistFilter.filterExpansion(blacklist)
    for questId, flag in pairs(blacklist) do
        if flag ~= true then
            blacklist[questId] = nil
        end
    end

    return blacklist
end

return BlacklistFilter
