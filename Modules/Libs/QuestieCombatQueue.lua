---@class QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:CreateModule("QuestieCombatQueue")

---@type QuestieLib
local QuestieLib = QuestieLoader:CreateModule("QuestieLib")

local tpack = QuestieLib.tpack
local tunpack = QuestieLib.tunpack

local _Queue = {}
local started = false
local trackerUpdateCheck = false

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
            trackerUpdateCheck = false
        end
    end)
    started = true
end

function QuestieCombatQueue:Queue(func, ...)
    if started then
        if trackerUpdateCheck then
            return
        else
            tinsert(_Queue, { func = func, args = tpack(...) })

            for index in pairs(_Queue) do
                if _Queue[index].args[1] == "QuestieTracker:Update" then
                    trackerUpdateCheck = true
                end
            end
        end
    end
end
