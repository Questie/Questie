---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByFaction = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieJourneyFactions
local QuestieJourneyFactions = QuestieLoader:ImportModule("QuestieJourneyFactions")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")

local factionTreeFrame
local factionQuestMap

local factionIDs = QuestieDB.factionIDs

local expansionDefinitions = {
    { key = "classic", label = EXPANSION_NAME0, order = Expansions.Era },
    { key = "tbc", label = EXPANSION_NAME1, order = Expansions.Tbc },
    { key = "wotlk", label = EXPANSION_NAME2, order = Expansions.Wotlk },
    { key = "cata", label = EXPANSION_NAME3, order = Expansions.Cata },
    { key = "mop", label = EXPANSION_NAME4, order = Expansions.MoP },
}

local expansionKeyByOrder = {}
local expansionOrderByKey = {}
for _, expansion in ipairs(expansionDefinitions) do
    expansionKeyByOrder[expansion.order] = expansion.key
    expansionOrderByKey[expansion.key] = expansion.order
end

local expansionFactionCandidates = QuestieJourneyFactions.expansionFactionCandidates
local factionIntroductionOrder = QuestieJourneyFactions.BuildFactionIntroductionOrder(expansionOrderByKey)

QuestieJourney.availableFactionExpansions = QuestieJourney.availableFactionExpansions or {}
QuestieJourney.availableFactionExpansionOrder = QuestieJourney.availableFactionExpansionOrder or {}
QuestieJourney.factionsByExpansion = QuestieJourney.factionsByExpansion or {}

local _EnsureFactionQuestData

local referencedFactionFields = {
    "requiredMinRep",
    "requiredMaxRep",
    "reputationReward",
    "requiredRaces",
    "requiredClasses",
}

local referencedFactionIds
local factionDataInitialized = false

local function _RegisterFactionForExpansion(factionId, introOrder)
    local factionName = QuestieReputation.GetFactionName(factionId)
    if not factionName or factionName == "" then
        return
    end

    local expansionKey = expansionKeyByOrder[introOrder]
    if not expansionKey then
        return
    end

    local bucket = QuestieJourney.factionsByExpansion[expansionKey]
    if not bucket then
        bucket = {}
        QuestieJourney.factionsByExpansion[expansionKey] = bucket
    end

    if not bucket[factionId] then
        bucket[factionId] = factionName
    end
end

local function _EnsureFactionRegistered(factionId)
    if not factionId then
        return
    end

    if not factionIntroductionOrder[factionId] then
        factionIntroductionOrder[factionId] = Expansions.MoP
    end

    _RegisterFactionForExpansion(factionId, factionIntroductionOrder[factionId])
end

local function _IsQuestAvailableToPlayer(requiredRaces, requiredClasses)
    return QuestiePlayer.HasRequiredRace(requiredRaces) and QuestiePlayer.HasRequiredClass(requiredClasses)
end

local function _CollectReferencedFactionIds()
    if referencedFactionIds then
        return referencedFactionIds
    end

    if not QuestieDB.QuestPointers then
        return {}
    end

    local refs = {}

    for questId in pairs(QuestieDB.QuestPointers) do
        local result = QuestieDB.QueryQuest(questId, referencedFactionFields)
        if result then
            local requiredMinRep = result[1]
            local requiredMaxRep = result[2]
            local reputationReward = result[3]
            local requiredRaces = result[4]
            local requiredClasses = result[5]

            if _IsQuestAvailableToPlayer(requiredRaces, requiredClasses) then
                if requiredMinRep then
                    local factionId = requiredMinRep[1]
                    if factionId then
                        refs[factionId] = true
                    end
                end

                if requiredMaxRep then
                    local factionId = requiredMaxRep[1]
                    if factionId then
                        refs[factionId] = true
                    end
                end

                if reputationReward then
                    for _, reward in pairs(reputationReward) do
                        local factionId = reward[1]
                        if factionId then
                            refs[factionId] = true
                        end
                    end
                end

                if requiredRaces and requiredRaces ~= QuestieDB.raceKeys.NONE then
                    if bit.band(requiredRaces, QuestieDB.raceKeys.ALL_ALLIANCE) == requiredRaces then
                        refs[factionIDs.ALLIANCE] = true
                    elseif bit.band(requiredRaces, QuestieDB.raceKeys.ALL_HORDE) == requiredRaces then
                        refs[factionIDs.HORDE] = true
                    end
                end
            end
        end
    end

    referencedFactionIds = refs
    return referencedFactionIds
end

local function _BuildExpansionDropdownData()
    wipe(QuestieJourney.availableFactionExpansions)
    wipe(QuestieJourney.availableFactionExpansionOrder)

    for _, expansion in ipairs(expansionDefinitions) do
        if Expansions.Current >= expansion.order then
            QuestieJourney.availableFactionExpansions[expansion.key] = expansion.label
            table.insert(QuestieJourney.availableFactionExpansionOrder, expansion.key)
        end
    end
end

local function _PopulateFactionsByExpansion()
    local referenced = _CollectReferencedFactionIds()

    QuestieJourney.factionsByExpansion = QuestieJourney.factionsByExpansion or {}

    for key in pairs(QuestieJourney.factionsByExpansion) do
        QuestieJourney.factionsByExpansion[key] = nil
    end

    for _, expansion in ipairs(expansionDefinitions) do
        QuestieJourney.factionsByExpansion[expansion.key] = {}
    end

    for factionId, introOrder in pairs(factionIntroductionOrder) do
        if referenced[factionId] then
            _RegisterFactionForExpansion(factionId, introOrder)
        end
    end

    for factionId in pairs(referenced) do
        if not factionIntroductionOrder[factionId] then
            _EnsureFactionRegistered(factionId)
        end
    end
end

local function _EnsureFactionDataInitialized()
    if factionDataInitialized then
        return
    end

    _BuildExpansionDropdownData()
    _PopulateFactionsByExpansion()

    factionDataInitialized = true
end

function _QuestieJourney.questsByFaction:InitializeFactionData()
    _EnsureFactionDataInitialized()
end

function _QuestieJourney.questsByFaction:InitializeFactionQuestData()
    _EnsureFactionQuestData()
end

local function _AddQuestToFaction(factionId, questId)
    if not factionId or not questId then
        return
    end

    _EnsureFactionRegistered(factionId)

    if not factionQuestMap[factionId] then
        factionQuestMap[factionId] = {}
    end

    factionQuestMap[factionId][questId] = true
end

local function _IsAllianceRaceMask(raceMask)
    if not raceMask or raceMask == QuestieDB.raceKeys.NONE then
        return false
    end

    return bit.band(raceMask, QuestieDB.raceKeys.ALL_ALLIANCE) == raceMask
end

local function _IsHordeRaceMask(raceMask)
    if not raceMask or raceMask == QuestieDB.raceKeys.NONE then
        return false
    end

    return bit.band(raceMask, QuestieDB.raceKeys.ALL_HORDE) == raceMask
end

function _EnsureFactionQuestData()
    if factionQuestMap then
        return
    end

    factionQuestMap = {}

    local HIDE_ON_MAP = QuestieQuestBlacklist.HIDE_ON_MAP
    local hiddenQuests = QuestieCorrections.hiddenQuests

    local queryFields = {
        "requiredMinRep",
        "requiredMaxRep",
        "reputationReward",
        "requiredRaces",
        "requiredClasses",
    }

    for questId in pairs(QuestieDB.QuestPointers) do
        local queryResult = QuestieDB.QueryQuest(questId, queryFields) or {}
        local requiredMinRep = queryResult[1]
        local requiredMaxRep = queryResult[2]
        local reputationReward = queryResult[3]
        local requiredRaces = queryResult[4]
        local requiredClasses = queryResult[5]

        if _IsQuestAvailableToPlayer(requiredRaces, requiredClasses) then
            -- Filter out hidden quests
            if hiddenQuests and (((not hiddenQuests[questId]) or hiddenQuests[questId] == HIDE_ON_MAP) or QuestieEvent.IsEventQuest(questId)) then
                if requiredMinRep then
                    _AddQuestToFaction(requiredMinRep[1], questId)
                end

                if requiredMaxRep then
                    _AddQuestToFaction(requiredMaxRep[1], questId)
                end

                if reputationReward then
                    for _, factionPair in pairs(reputationReward) do
                        _AddQuestToFaction(factionPair[1], questId)
                    end
                end

                -- Only add to ALLIANCE/HORDE factions if the quest provides reputation
                -- Do we even want this? You can select each faction individually in the dropdown.
                if reputationReward and next(reputationReward) then
                    if _IsAllianceRaceMask(requiredRaces) then
                        _AddQuestToFaction(factionIDs.ALLIANCE, questId)
                    elseif _IsHordeRaceMask(requiredRaces) then
                        _AddQuestToFaction(factionIDs.HORDE, questId)
                    end
                end
            end
        end
    end

    QuestieJourney.factionMap = factionQuestMap

    if QuestieJourney.factionsByExpansion then
        for expansionKey, bucket in pairs(QuestieJourney.factionsByExpansion) do
            if bucket then
                for factionId in pairs(bucket) do
                    local questsForFaction = factionQuestMap[factionId]
                    if (not questsForFaction) or (not next(questsForFaction)) then
                        bucket[factionId] = nil
                    end
                end
            end
        end
    end
end

---Manage the faction tree itself and the contents of the per-quest window
---@param container AceSimpleGroup
---@param factionTree table
function _QuestieJourney.questsByFaction:ManageTree(container, factionTree)
    if factionTreeFrame then
        container:ReleaseChildren()
        factionTreeFrame = nil
        _QuestieJourney.questsByFaction:ManageTree(container, factionTree)
        return
    end

    factionTreeFrame = AceGUI:Create("TreeGroup")
    factionTreeFrame:SetFullWidth(true)
    factionTreeFrame:SetFullHeight(true)
    factionTreeFrame:SetTree(factionTree)

    factionTreeFrame.treeframe:SetWidth(415)
    factionTreeFrame:SetCallback("OnClick", function(group, ...)
        local treePath = {...}

        if not treePath[2] then
            Questie:Debug(Questie.DEBUG_CRITICAL, "[factionTreeFrame:OnClick] No tree path given in Journey.")
            return
        end

        local sel, questId = strsplit("\001", treePath[2])
        if (sel == nil or sel == "a" or sel == "p" or sel == "c" or sel == "r" or sel == "u") and (not questId) then
            return
        end

        local master = group.frame.obj
        master:ReleaseChildren()
        master:SetLayout("fill")
        master:SetFullWidth(true)
        master:SetFullHeight(true)

        ---@class ScrollFrame
        local scrollFrame = AceGUI:Create("ScrollFrame")
        scrollFrame:SetLayout("flow")
        scrollFrame:SetFullHeight(true)
        master:AddChild(scrollFrame)

        questId = tonumber(questId)
        local quest = QuestieDB.GetQuest(questId)

        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            if Questie.db.profile.trackerShowQuestLevel then
                ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(quest.level, quest.name, quest.Id))
            else
                ChatEdit_InsertLink("[" .. quest.name .. " (" .. quest.Id .. ")]")
            end
        end

        _QuestieJourney:DrawQuestDetailsFrame(scrollFrame, quest)
    end)

    container:AddChild(factionTreeFrame)
end

---Build the quest tree for a faction grouping
---@param factionId number
---@return table<number, any> | nil
function _QuestieJourney.questsByFaction:CollectFactionQuests(factionId)
    local quests = QuestieJourney.factionMap and QuestieJourney.factionMap[factionId]
    if (not quests) then
        return nil
    end

    local factionTree = {
        [1] = {
            value = "a",
            text = l10n('Available Quests'),
            children = {}
        },
        [2] = {
            value = "p",
            text = l10n('Missing Pre Quest'),
            children = {}
        },
        [3] = {
            value = "c",
            text = l10n('Completed Quests'),
            children = {}
        },
        [4] = {
            value = "r",
            text = l10n('Repeatable Quests'),
            children = {},
        },
        [5] = {
            value = "u",
            text = l10n('Unobtainable Quests'),
            children = {},
        }
    }

    local sortedQuestByLevel = QuestieLib:SortQuestIDsByLevel(quests)

    local availableCounter = 0
    local prequestMissingCounter = 0
    local completedCounter = 0
    local unobtainableCounter = 0
    local repeatableCounter = 0

    local unobtainableQuestIds = {}
    local temp = {}

    local playerlevel = UnitLevel("player")

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local questId = levelAndQuest[2]
        if QuestieDB.QuestPointers[questId] then
            temp.value = questId
            local queryResult = QuestieDB.QueryQuest(
                questId,
                {
                    "exclusiveTo",
                    "nextQuestInChain",
                    "parentQuest",
                    "preQuestSingle",
                    "preQuestGroup",
                    "requiredMinRep",
                    "requiredMaxRep",
                    "requiredSpell",
                    "requiredSpecialization",
                    "requiredMaxLevel",
                    "requiredSkill",
                }
            ) or {}

            local questName = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)

            local reputationRewards = QuestieReputation.GetReputationReward(questId)
            if reputationRewards and next(reputationRewards) then
                local rewardString = QuestieReputation.GetReputationRewardString(reputationRewards)
                if rewardString and rewardString ~= "" then
                    local rewardText = Questie:Colorize(" (" .. rewardString .. ")", "reputationBlue")
                    questName = questName .. rewardText
                end
            end

            temp.text = questName

            if Questie.db.char.complete[questId] then
                tinsert(factionTree[3].children, temp)
                completedCounter = completedCounter + 1
            else
                local exclusiveTo = queryResult[1]
                local nextQuestInChain = queryResult[2]
                local parentQuest = queryResult[3]
                local preQuestSingle = queryResult[4]
                local preQuestGroup = queryResult[5]
                local requiredMinRep = queryResult[6]
                local requiredMaxRep = queryResult[7]
                local requiredSpell = queryResult[8]
                local requiredSpecialization = queryResult[9]
                local requiredMaxLevel = queryResult[10]
                local requiredSkill = queryResult[11]

                if requiredSkill then
                    local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
                    if (not (hasProfession and hasSkillLevel)) then
                        tinsert(factionTree[5].children, temp)
                        unobtainableCounter = unobtainableCounter + 1
                    end
                elseif (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
                    tinsert(factionTree[3].children, temp)
                    completedCounter = completedCounter + 1
                elseif parentQuest and Questie.db.char.complete[parentQuest] then
                    tinsert(factionTree[3].children, temp)
                    completedCounter = completedCounter + 1
                elseif not QuestieReputation.HasReputation(requiredMinRep, requiredMaxRep) then
                    tinsert(factionTree[5].children, temp)
                    unobtainableQuestIds[questId] = true
                    unobtainableCounter = unobtainableCounter + 1
                elseif (not QuestieProfessions.HasSpecialization(requiredSpecialization)) then
                    tinsert(factionTree[5].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
                    if unobtainableQuestIds[preQuestSingle] ~= nil then
                        tinsert(factionTree[5].children, temp)
                        unobtainableQuestIds[questId] = true
                        unobtainableCounter = unobtainableCounter + 1
                    else
                        tinsert(factionTree[2].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
                    local hasUnobtainablePreQuest = false
                    for _, preQuestId in pairs(preQuestGroup) do
                        if unobtainableQuestIds[preQuestId] ~= nil then
                            tinsert(factionTree[5].children, temp)
                            unobtainableQuestIds[questId] = true
                            unobtainableCounter = unobtainableCounter + 1
                            hasUnobtainablePreQuest = true
                            break
                        end
                    end

                    if not hasUnobtainablePreQuest then
                        tinsert(factionTree[2].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif requiredMaxLevel and requiredMaxLevel ~= 0 and playerlevel > requiredMaxLevel then
                    tinsert(factionTree[5].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif QuestieDB.IsRepeatable(questId) then
                    tinsert(factionTree[4].children, temp)
                    repeatableCounter = repeatableCounter + 1
                elseif requiredSpell and requiredSpell < 0 and (IsSpellKnownOrOverridesKnown(math.abs(requiredSpell)) or IsPlayerSpell(math.abs(requiredSpell))) then
                    tinsert(factionTree[5].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif requiredSpell and requiredSpell > 0 and not (IsSpellKnownOrOverridesKnown(math.abs(requiredSpell)) or IsPlayerSpell(math.abs(requiredSpell))) then
                    tinsert(factionTree[5].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                else
                    tinsert(factionTree[1].children, temp)
                    availableCounter = availableCounter + 1
                end
            end
            temp = {}
        end
    end

    local totalCounter = availableCounter + completedCounter + prequestMissingCounter
    factionTree[1].text = factionTree[1].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    factionTree[2].text = factionTree[2].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    factionTree[3].text = factionTree[3].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    factionTree[4].text = factionTree[4].text .. ' [ '..  repeatableCounter ..' ]'
    factionTree[5].text = factionTree[5].text .. ' [ '..  unobtainableCounter ..' ]'

    factionTree.numquests = totalCounter + repeatableCounter + unobtainableCounter

    return factionTree
end
