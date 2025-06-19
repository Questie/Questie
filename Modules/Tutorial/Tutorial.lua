---@class Tutorial
local Tutorial = QuestieLoader:CreateModule("Tutorial")

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

function Tutorial.Initialize()
    if (Expansions.Current >= Expansions.Wotlk) and GetCVar("questPOI") ~= nil and (not Questie.db.global.tutorialObjectiveTypeChosen) then
        QuestieCombatQueue:Queue(function()
            Tutorial.CreateChooseObjectiveTypeFrame()
        end)
    end

    if Questie.IsSoD and (not Questie.db.profile.tutorialShowRunesDone) then
        QuestieCombatQueue:Queue(function()
            Tutorial.ShowRunes()
        end)
    end

    if (not Questie.db.profile.tutorialRejectInBattlegroundsDone) then
        QuestieCombatQueue:Queue(function()
            Tutorial.AutoRejectInBattlegroundsFrame()
        end)
    end
end
