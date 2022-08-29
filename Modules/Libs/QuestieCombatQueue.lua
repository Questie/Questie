---@class QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:CreateModule("QuestieCombatQueue")
local _Queue = {}
local started = false

-- This will limit the amount of updates Questie does to the UI and will reduce the chance to lag the game
local maxUpdatesPerCircle = 5

local tpack = function(...) return { n = select("#", ...), ... } end
local function tunpack(tbl) -- wow's own unpack stops at first nil. this version is not speed optimized. supports just above tpack func as requires n field.
    if tbl.n == 0 then
        return nil
    end

    local function recursion(i)
        if i == tbl.n then
            return tbl[i]
        end
        return tbl[i], recursion(i+1)
    end

    return recursion(1)
end

function QuestieCombatQueue.Initialize()
    C_Timer.NewTicker(0.1, function()
        if InCombatLockdown() then
            return
        end

        local entry = tremove(_Queue, 1)
        local count = 0
        while entry do
            entry.func(tunpack(entry.args))

            if InCombatLockdown() or count >= maxUpdatesPerCircle then
                break
            end
            entry = tremove(_Queue, 1)
            count = count + 1
        end
    end)
    started = true
end

function QuestieCombatQueue:Queue(func, ...)
    if started then
        tinsert(_Queue, {func=func, args=tpack(...)})
    end
end