---@class QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:CreateModule("QuestieNPCBlacklist")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

---@return table<NpcId, boolean>
function QuestieNPCBlacklist:Load()
    return {
        [8001] = true,
        [13151] = QuestieCorrections.CLASSIC_HIDE, -- Syndicate Master Ryson
        [13153] = QuestieCorrections.CLASSIC_HIDE, -- Commander Mulfort
        [13154] = QuestieCorrections.CLASSIC_HIDE, -- Commander Louis Philips
        [13319] = QuestieCorrections.CLASSIC_HIDE, -- Commander Duffy
        [13320] = QuestieCorrections.CLASSIC_HIDE, -- Commander Karl Philips
        [13377] = QuestieCorrections.CLASSIC_HIDE, -- Master Engineer Zinfizzlex
        [13446] = QuestieCorrections.CLASSIC_HIDE, -- Field Marshal Teravaine
        [13449] = QuestieCorrections.CLASSIC_HIDE, -- Warmaster Garrick
        [15799] = QuestieCorrections.CLASSIC_HIDE, -- Colossus Researcher Eazel (AQ Opening event)
        [17544] = true, -- M'uru in Silvermoon City removed starting with SWP patch
        [21155] = true, -- Bloodelf War Effort Recruiter
        [178420] =  QuestieCorrections.WOTLK_HIDE + QuestieCorrections.CATA_HIDE, -- removed in WotLK
        [3032] =  QuestieCorrections.CATA_HIDE, -- removed in Cata
    }
end
