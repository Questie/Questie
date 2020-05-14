---@class QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:CreateModule("QuestieCombatQueue")
local _Queue = {}

function QuestieCombatQueue:Initialize()
    C_Timer.NewTicker(0.1, function()
        if InCombatLockdown() then return end
        local func = tremove(_Queue, 1)
        while func do
            func.func(func.obj)
            if InCombatLockdown() then break end
            func = tremove(_Queue, 1)
        end
    end)
end

function QuestieCombatQueue:Queue(func, obj)
    tinsert(_Queue, {func=func, obj=obj})
end