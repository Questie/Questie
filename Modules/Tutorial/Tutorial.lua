---@class Tutorial
local Tutorial = QuestieLoader:CreateModule("Tutorial")

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

function Tutorial.Initialize()
    -- The objective style choice gained Questie blobs and reached every client, so each account is asked once
    -- more, whatever it chose before. A profile already showing blobs has made the choice in the options.
    if Questie.db.profile.enableQuestiePolygons then
        Questie.db.global.tutorialObjectiveStyleWithBlobsChosen = true
    end
    if not Questie.db.global.tutorialObjectiveStyleWithBlobsChosen then
        QuestieCombatQueue:Queue(function()
            Tutorial.CreateChooseObjectiveTypeFrame()
        end)
    end

    if Questie.IsSoD and (not Questie.db.profile.tutorialShowRunesDone) then
        QuestieCombatQueue:Queue(function()
            Tutorial.ShowRunes()
        end)
    end

    if (not Questie.db.profile.tutorialRejectInBattlegroundsDone) and not Questie.IsForever then
        QuestieCombatQueue:Queue(function()
            Tutorial.AutoRejectInBattlegroundsFrame()
        end)
    end
end
