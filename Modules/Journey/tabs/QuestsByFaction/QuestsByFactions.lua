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
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
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
    { key = "classic", label = l10n("Classic"), order = Expansions.Era },
    { key = "tbc", label = l10n("Burning Crusade"), order = Expansions.Tbc },
    { key = "wotlk", label = l10n("Wrath of the Lich King"), order = Expansions.Wotlk },
    { key = "cata", label = l10n("Cataclysm"), order = Expansions.Cata },
    { key = "mop", label = l10n("Mists of Pandaria"), order = Expansions.MoP },
}

local expansionKeyByOrder = {}
local expansionOrderByKey = {}
for _, expansion in ipairs(expansionDefinitions) do
    expansionKeyByOrder[expansion.order] = expansion.key
    expansionOrderByKey[expansion.key] = expansion.order
end

local expansionFactionCandidates = {
    classic = {
        factionIDs.BOOTY_BAY,
        factionIDs.IRONFORGE,
        factionIDs.GNOMEREGAN,
        factionIDs.THORIUM_BROTHERHOOD,
        factionIDs.HORDE,
        factionIDs.UNDERCITY,
        factionIDs.DARNASSUS,
        factionIDs.SYNDICATE,
        factionIDs.STORMWIND,
        factionIDs.ORGRIMMAR,
        factionIDs.THUNDER_BLUFF,
        factionIDs.GELKIS_CLAN_CENTAUR,
        factionIDs.MAGRAM_CLAN_CENTAUR,
        factionIDs.STEAMWHEEDLE_CARTEL,
        factionIDs.ZANDALAR_TRIBE,
        factionIDs.RAVENHOLDT,
        factionIDs.GADGETZAN,
        factionIDs.ALLIANCE,
        factionIDs.RATCHET,
        factionIDs.THE_LEAGUE_OF_ARATHOR,
        factionIDs.THE_DEFILERS,
        factionIDs.ARGENT_DAWN,
        factionIDs.DARKSPEAR_TROLLS,
        factionIDs.TIMBERMAW_HOLD,
        factionIDs.EVERLOOK,
        factionIDs.WINTERSABER_TRAINERS,
        factionIDs.CENARION_CIRCLE,
        factionIDs.FROSTWOLF_CLAN,
        factionIDs.STORMPIKE_GUARD,
        factionIDs.HYDRAXIAN_WATERLORDS,
        factionIDs.SHEN_DRALAR,
        factionIDs.WARSONG_OUTRIDERS,
        factionIDs.SILVERWING_SENTINELS,
        factionIDs.ALLIANCE_FORCES,
        factionIDs.HORDE_FORCES,
        factionIDs.DARKMOON_FAIRE,
        factionIDs.BROOD_OF_NOZDORMU,
    },
    tbc = {
        factionIDs.SILVERMOON_CITY,
        factionIDs.TRANQUILLIEN,
        factionIDs.EXODAR,
        factionIDs.THE_ALDOR,
        factionIDs.THE_CONSORTIUM,
        factionIDs.THE_SCRYERS,
        factionIDs.THE_SHA_TAR,
        factionIDs.SHATTRATH_CITY,
        factionIDs.THE_MAGHAR,
        factionIDs.CENARION_EXPEDITION,
        factionIDs.HONOR_HOLD,
        factionIDs.THRALLMAR,
        factionIDs.THE_VIOLET_EYE,
        factionIDs.SPOREGGAR,
        factionIDs.KURENAI,
        factionIDs.THE_BURNING_CRUSADE,
        factionIDs.KEEPERS_OF_TIME,
        factionIDs.THE_SCALE_OF_THE_SANDS,
        factionIDs.LOWER_CITY,
        factionIDs.ASHTONGUE_DEATHSWORN,
        factionIDs.NETHERWING,
        factionIDs.SHA_TARI_SKYGUARD,
        factionIDs.OGRILA,
        factionIDs.SHATTERED_SUN_OFFENSIVE,
    },
    wotlk = {
        factionIDs.ALLIANCE_VANGUARD,
        factionIDs.VALIANCE_EXPEDITION,
        factionIDs.HORDE_EXPEDITION,
        factionIDs.THE_TAUNKA,
        factionIDs.THE_HAND_OF_VENGEANCE,
        factionIDs.EXPLORERS_LEAGUE,
        factionIDs.THE_KALUAK,
        factionIDs.WARSONG_OFFENSIVE,
        factionIDs.KIRIN_TOR,
        factionIDs.THE_WYRMREST_ACCORD,
        factionIDs.THE_SILVER_COVENANT,
        factionIDs.WRATH_OF_THE_LICH_KING,
        factionIDs.KNIGHTS_OF_THE_EBON_BLADE,
        factionIDs.FRENZYHEART_TRIBE,
        factionIDs.THE_ORACLES,
        factionIDs.ARGENT_CRUSADE,
        factionIDs.SHOLAZAR_BASIN,
        factionIDs.THE_SONS_OF_HODIR,
        factionIDs.THE_SUNREAVERS,
        factionIDs.THE_FROSTBORN,
        factionIDs.THE_ASHEN_VERDICT,
    },
    cata = {
        factionIDs.BILGEWATER_CARTEL,
        factionIDs.GILNEAS,
        factionIDs.THE_EARTHEN_RING,
        factionIDs.GUARDIANS_OF_HYJAL,
        factionIDs.THERAZANE,
        factionIDs.DRAGONMAW_CLAN,
        factionIDs.RAMKAHEN,
        factionIDs.WILDHAMMER_CLAN,
        factionIDs.BARADINS_WARDENS,
        factionIDs.HELLSCREAMS_REACH,
        factionIDs.AVENGERS_OF_HYJAL,
    },
    mop = {
        factionIDs.SHANG_XIS_ACADEMY,
        factionIDs.FOREST_HOZEN,
        factionIDs.PEARLFIN_JINYU,
        factionIDs.GOLDEN_LOTUS,
        factionIDs.SHADO_PAN,
        factionIDs.ORDER_OF_THE_CLOUD_SERPENT,
        factionIDs.THE_TILLERS,
        factionIDs.JOGU_THE_DRUNK,
        factionIDs.ELLA,
        factionIDs.OLD_HILLPAW,
        factionIDs.CHEE_CHEE,
        factionIDs.SHO,
        factionIDs.HAOHAN_MUDCLAW,
        factionIDs.TINA_MUDCLAW,
        factionIDs.GINA_MUDCLAW,
        factionIDs.FISH_FELLREED,
        factionIDs.FARMER_FUNG,
        factionIDs.THE_ANGLERS,
        factionIDs.THE_KLAXXI,
        factionIDs.THE_AUGUST_CELESTIALS,
        factionIDs.THE_LOREWALKERS,
        factionIDs.THE_BREWMASTERS,
        factionIDs.HUOJIN_PANDAREN,
        factionIDs.TUSHUI_PANDAREN,
        factionIDs.NOMI,
        factionIDs.NAT_PAGLE,
        factionIDs.THE_BLACK_PRINCE,
        factionIDs.BRAWLGAR_ARENA_SEASON_1,
        factionIDs.DOMINANCE_OFFENSIVE,
        factionIDs.OPERATION_SHIELDWALL,
        factionIDs.KIRIN_TOR_OFFENSIVE,
        factionIDs.SUNREAVER_ONSLAUGHT,
        factionIDs.AKAMAS_TRUST,
        factionIDs.BIZMOS_BRAWLPUB_SEASON_1,
        factionIDs.SHADO_PAN_ASSAULT,
        factionIDs.DARKSPEAR_REBELLION,
    },
}

local factionIntroductionOrder = {}
for expansionKey, factionList in pairs(expansionFactionCandidates) do
    local order = expansionOrderByKey[expansionKey]
    if order then
        for _, factionId in ipairs(factionList) do
            factionIntroductionOrder[factionId] = order
        end
    end
end

QuestieJourney.availableFactionExpansions = QuestieJourney.availableFactionExpansions or {}
QuestieJourney.availableFactionExpansionOrder = QuestieJourney.availableFactionExpansionOrder or {}
QuestieJourney.factionsByExpansion = QuestieJourney.factionsByExpansion or {}

local referencedFactionFields = {
    "requiredMinRep",
    "requiredMaxRep",
    "reputationReward",
    "requiredRaces",
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

local function _IsQuestAvailableToPlayer(requiredRaces, requiredClasses)
    return QuestiePlayer.HasRequiredRace(requiredRaces) and QuestiePlayer.HasRequiredClass(requiredClasses)
end

local function _GetFactionReputationRewardValue(questId, factionId)
    if not questId or not factionId then
        return nil
    end

    local reputationRewards = QuestieReputation.GetReputationReward(questId)
    if not reputationRewards then
        return nil
    end

    for _, rewardPair in pairs(reputationRewards) do
        if rewardPair[1] == factionId then
            return rewardPair[2]
        end
    end

    return nil
end

local function _EnsureFactionQuestData()
    if factionQuestMap then
        return
    end

    factionQuestMap = {}

    local queryFields = {
        "requiredMinRep",
        "requiredMaxRep",
        "reputationReward",
        "requiredRaces",
    }

    for questId in pairs(QuestieDB.QuestPointers) do
        local queryResult = QuestieDB.QueryQuest(questId, queryFields) or {}
        local requiredMinRep = queryResult[1]
        local requiredMaxRep = queryResult[2]
        local reputationReward = queryResult[3]
        local requiredRaces = queryResult[4]

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

        if _IsAllianceRaceMask(requiredRaces) then
            _AddQuestToFaction(factionIDs.ALLIANCE, questId)
        elseif _IsHordeRaceMask(requiredRaces) then
            _AddQuestToFaction(factionIDs.HORDE, questId)
        end
    end

    QuestieJourney.factionMap = factionQuestMap
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
    _EnsureFactionQuestData()

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

    local HIDE_ON_MAP = QuestieQuestBlacklist.HIDE_ON_MAP
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local playerlevel = UnitLevel("player")

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local questId = levelAndQuest[2]
        if hiddenQuests and (((not hiddenQuests[questId]) or hiddenQuests[questId] == HIDE_ON_MAP) or QuestieEvent.IsEventQuest(questId)) and QuestieDB.QuestPointers[questId] then
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
                    "requiredMaxLevel",
                    "requiredRaces",
                    "requiredClasses"
                }
            ) or {}

            local requiredRaces = queryResult[10]
            local requiredClasses = queryResult[11]

            if _IsQuestAvailableToPlayer(requiredRaces, requiredClasses) then
                local questName = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)
                local rewardValue = _GetFactionReputationRewardValue(questId, factionId)
                if rewardValue and rewardValue ~= 0 then
                    questName = questName .. " (" .. rewardValue .. ")"
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
                    local requiredMaxLevel = queryResult[9]

                    if (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
                        tinsert(factionTree[3].children, temp)
                        completedCounter = completedCounter + 1
                    elseif parentQuest and Questie.db.char.complete[parentQuest] then
                        tinsert(factionTree[3].children, temp)
                        completedCounter = completedCounter + 1
                    elseif not QuestieReputation.HasReputation(requiredMinRep, requiredMaxRep) then
                        tinsert(factionTree[5].children, temp)
                        unobtainableQuestIds[questId] = true
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


