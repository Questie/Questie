---@class QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:CreateModule("QuestieCombatQueue")

---@type QuestieLib
local QuestieLib = QuestieLoader:CreateModule("QuestieLib")

local tpack =  QuestieLib.tpack
local tunpack = QuestieLib.tunpack

local _Queue = {}
local started = false

-- This will limit the amount of updates Questie does to the UI and will reduce the chance to lag the game
local maxUpdatesPerCircle = 5

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