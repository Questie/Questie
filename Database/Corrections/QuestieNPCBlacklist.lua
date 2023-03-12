---@class QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:CreateModule("QuestieNPCBlacklist")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

---@return table<NpcId, boolean>
function QuestieNPCBlacklist:Load()
    return {
        [8001] = true,
        [13151] = QuestieCorrections.CLASSIC_ONLY, -- Syndicate Master Ryson
        [13153] = QuestieCorrections.CLASSIC_ONLY, -- Commander Mulfort
        [13154] = QuestieCorrections.CLASSIC_ONLY, -- Commander Louis Philips
        [13319] = QuestieCorrections.CLASSIC_ONLY, -- Commander Duffy
        [13320] = QuestieCorrections.CLASSIC_ONLY, -- Commander Karl Philips
        [13377] = QuestieCorrections.CLASSIC_ONLY, -- Master Engineer Zinfizzlex
        [13446] = QuestieCorrections.CLASSIC_ONLY, -- Field Marshal Teravaine
        [13449] = QuestieCorrections.CLASSIC_ONLY, -- Warmaster Garrick
        [15799] = QuestieCorrections.CLASSIC_ONLY, -- Colossus Researcher Eazel (AQ Opening event)
        [21155] = true, -- Bloodelf War Effort Recruiter
    }
end
