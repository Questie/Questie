---@class QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:CreateModule("QuestieNPCBlacklist")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@return table<NpcId, boolean>
function QuestieNPCBlacklist:Load()
    return {
        [3032] = Expansions.Current >= Expansions.Cata, -- Beram Skychaser
        [7666] = Expansions.Current >= Expansions.Cata, -- Archmage Allistarj
        [8001] = true,
        [12397] = Questie.IsSoD, -- Lord Kazzak
        [13151] = Expansions.Current == Expansions.Era, -- Syndicate Master Ryson
        [13153] = Expansions.Current == Expansions.Era, -- Commander Mulfort
        [13154] = Expansions.Current == Expansions.Era, -- Commander Louis Philips
        [13319] = Expansions.Current == Expansions.Era, -- Commander Duffy
        [13320] = Expansions.Current == Expansions.Era, -- Commander Karl Philips
        [13377] = Expansions.Current == Expansions.Era, -- Master Engineer Zinfizzlex
        [13446] = Expansions.Current == Expansions.Era, -- Field Marshal Teravaine
        [13449] = Expansions.Current == Expansions.Era, -- Warmaster Garrick
        [15799] = Expansions.Current == Expansions.Era, -- Colossus Researcher Eazel (AQ Opening event)
        [17544] = true, -- M'uru in Silvermoon City removed starting with SWP patch
        [21155] = true, -- Bloodelf War Effort Recruiter
        [30676] = Expansions.Current >= Expansions.Cata, -- Chronicler Bah'Kini (outside of dungeon version of this NPC)
        [178420] = Expansions.Current >= Expansions.Wotlk,
    }
end
