---@class BlacklistFilter
local BlacklistFilter = QuestieLoader:CreateModule("BlacklistFilter")

-- TODO: Reuse these at all other places where QuestieCorrections.X are used
-- Bitmask flags to blacklist DB entries in specific expansions
BlacklistFilter.CLASSIC_HIDE = 1 -- Hide in Classic
BlacklistFilter.TBC_HIDE = 2 -- Hide in TBC
BlacklistFilter.WOTLK_HIDE = 4 -- Hide in Wotlk
BlacklistFilter.CATA_HIDE = 8 -- Hide in Cata
BlacklistFilter.SOD_HIDE = 16 -- Hide when Season of Discovery; use to hide quests that are not available in SoD

local bitband = bit.band

---@param blacklist table<QuestId, boolean>
---@return table<QuestId, boolean>
function BlacklistFilter.filterExpansion(blacklist)
    for questId, flag in pairs(blacklist) do
        if flag ~= true and flag ~= false then
            if BlacklistFilter.IsFlagged(flag) then
                blacklist[questId] = true
            end

            if blacklist[questId] ~= true then
                blacklist[questId] = nil
            end
        end
    end

    return blacklist
end

---@param flag string
---@return boolean
function BlacklistFilter.IsFlagged(flag)
    if flag ~= true and flag ~= false then
        if Questie.IsClassic and bitband(flag, BlacklistFilter.CLASSIC_HIDE) ~= 0 then
            return true
        end
        if Questie.IsTBC and bitband(flag, BlacklistFilter.TBC_HIDE) ~= 0 then
            return true
        end
        if Questie.IsWotlk and bitband(flag, BlacklistFilter.WOTLK_HIDE) ~= 0 then
            return true
        end
        if Questie.IsCata and bitband(flag, BlacklistFilter.CATA_HIDE) ~= 0 then
            return true
        end
        if Questie.IsSoD and bitband(flag, BlacklistFilter.SOD_HIDE) ~= 0 then
            return true
        end
    end
    return false
end

return BlacklistFilter
