---@class QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:CreateModule("QuestieCombatQueue")
local _Queue = {}

-- This will limit the amount of updates Questie does to the UI and will reduce the chance to lag the game
local maxUpdatesPerCircle = 5

function QuestieCombatQueue:Initialize()
    C_Timer.NewTicker(0.1, function()
        if InCombatLockdown() then
            return
        end

        local func = tremove(_Queue, 1)
        local count = 0
        while func do
            func.func(func.obj)
            if InCombatLockdown() or count >= maxUpdatesPerCircle then
                break
            end
            func = tremove(_Queue, 1)
            count = count + 1
        end
    end)
end

function QuestieCombatQueue:Queue(func, obj)
    tinsert(_Queue, {func=func, obj=obj})
end