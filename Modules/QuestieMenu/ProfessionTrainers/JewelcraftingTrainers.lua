---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

---@type NpcId[]
local trainers = {}

if Questie.IsMoP then
    trainers = {
        15465,15501,18751,18774,19063,19539,19775,19778,26915,26960,26982,26997,28701,33590,33637,33680,44582,45286,46675,47384,
        47396,47400,47418,47419,47420,47421,47431,48619,50247,52586,52587,52645,52657,57620,65043,65098,
    }
elseif Questie.IsCata then
    trainers = {
        15465,15501,18751,18774,19063,19539,19775,19778,26915,26960,26982,26997,28701,33590,33637,33680,44582,45286,46675,47384,
        47396,47400,47418,47419,47420,47421,47431,48619,50247,52586,52587,52645,52657,
    }
elseif Questie.IsWotlk then
    trainers = {
        15501,18751,18774,19063,19539,19775,19778,26915,26960,26982,26997,28701,33590,33637,33680,
    }
elseif Questie.IsTBC then
    trainers = {
        15501,18751,18774,19063,19539,19775,19778,
    }
end

Townsfolk.SetProfessionTrainerIds(QuestieProfessions.professionKeys.JEWELCRAFTING, trainers)
