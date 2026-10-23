---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

---@type NpcId[]
local trainers = {}

if Questie.IsMoP then
    trainers = {
        25263,26916,26959,26977,26995,28702,30706,30709,30710,30711,30713,30715,30716,30717,30721,30722,33603,33638,33679,46716,
        56065,62327,64691,
    }
elseif Questie.IsCata then
    trainers = {
        25263,26916,26959,26977,26995,28702,30706,30709,30710,30711,30713,30715,30716,30717,30721,30722,33603,33638,33679,46716,
    }
elseif Questie.IsWotlk then
    trainers = {
        26916,26959,26977,26995,28702,30706,30709,30710,30711,30713,30715,30716,30717,30721,30722,33603,33638,33679,
    }
end

Townsfolk.SetProfessionTrainerIds(QuestieProfessions.professionKeys.INSCRIPTION, trainers)
