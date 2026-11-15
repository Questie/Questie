---@type Townsfolk
local Townsfolk = QuestieLoader:ImportModule("Townsfolk")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

---@type NpcId[]
local trainers = {}

if Questie.IsMoP then
    trainers = {
        39718,44238,47346,47382,47568,47569,47570,47571,47572,47573,47574,47575,47576,47577,47578,47579,47683,51997,53421,64922,
    }
elseif Questie.IsCata then
    trainers = {
        39718,44238,47346,47382,47568,47569,47570,47571,47572,47573,47574,47575,47576,47577,47578,47579,47683,51997,53421,
    }
end

Townsfolk.SetProfessionTrainerIds(QuestieProfessions.professionKeys.ARCHAEOLOGY, trainers)
