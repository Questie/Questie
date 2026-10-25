---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

---@type NpcId[]
local trainers

if Questie.IsMoP then
    trainers = {
        3690,4732,4752,4753,4772,4773,7953,7954,16280,20500,20511,20914,28746,31238,31247,35093,35100,35133,35135,43693,
        43769,44919,48513,53407,60166,60167,70296,70301,
    }
elseif Questie.IsCata then
    trainers = {
        3690,4732,4752,4753,4772,4773,7953,7954,16280,20500,20511,20914,28746,31238,31247,35093,35100,35133,35135,43693,
        43769,44919,48513,53407,
    }
elseif Questie.IsWotlk then
    trainers = {
        3690,4732,4752,4753,4772,4773,7953,7954,16280,20500,20511,20914,28746,31238,31247,35093,35100,35133,35135,
    }
elseif Questie.IsTBC then
    trainers = {
        3690,4732,4752,4753,4772,4773,7953,7954,16280,20500,20511,20914,
    }
elseif Questie.IsForever then
    trainers = {
        3690,4732,4752,4753,4772,4773,7953,7954,265756,
    }
else
    trainers = {
        3690,4732,4752,4753,4772,4773,7953,7954,
    }
end

Townsfolk.SetProfessionTrainerIds(QuestieProfessions.professionKeys.RIDING, trainers)
