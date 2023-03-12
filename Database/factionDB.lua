---@class FactionDB
---@field factionIDs table
---@field GetZoneTables fun():table
local FactionDB = QuestieLoader:CreateModule("FactionDB")
local _FactionDB = {}

-------------------------
--Import modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local factionMap = {}
local factionsToParents

function FactionDB:GetFactionsWithQuests()
    for questId in pairs(QuestieDB.QuestPointers) do
        
        if (not QuestieCorrections.hiddenQuests[questId])
            and QuestiePlayer.HasRequiredRace(QuestieDB.QueryQuestSingle(questId, "requiredRaces"))
            and QuestiePlayer.HasRequiredClass(QuestieDB.QueryQuestSingle(questId, "requiredClasses"))
        then
            local reputationReward = QuestieDB.QueryQuestSingle(questId, "reputationReward")
            if reputationReward then
                for _, v in pairs(reputationReward) do
                    local factionId, reputationRewardAmount = unpack(v)
                    if reputationRewardAmount > 0 then
                        if (not factionMap[factionId]) then
                            factionMap[factionId] = {}
                        end
                        factionMap[factionId][questId] = true
                    end
                end
            end
        end
    end
    return factionMap
end

function FactionDB:GetRelevantFactions()
    local factions = {}
    for category, data in pairs(l10n.factionGroupLookup) do
        factions[category] = {}
        for id, factionName in pairs(data) do
            local factionQuests = factionMap[id]
            if (not factionQuests) then
                factions[category][id] = nil
            else
                factions[category][id] = l10n(factionName)
            end
        end
    end

    return factions
end

function FactionDB:GetFactionIdToParentIdTable()
    local factionsToParents = {}
    for parentFactionId, data in pairs(l10n.factionGroupLookup) do
        for factionId, _ in pairs(data) do
            factionsToParents[factionId] = parentFactionId
        end
    end
    return factionsToParents
end
