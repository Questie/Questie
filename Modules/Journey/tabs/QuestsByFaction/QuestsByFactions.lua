---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByFaction = {}

---@type QuestDetailsFrame
local QuestDetailsFrame = QuestieLoader:ImportModule("QuestDetailsFrame")

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
---@type QuestieJourneyFactions
local QuestieJourneyFactions = QuestieLoader:ImportModule("QuestieJourneyFactions")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

local factionTreeFrame
local factionQuestMap

local function FinalizeFactionQuestDetails(master, scrollFrame, quest, questId)
    -- The replacement widgets can be sized by the parent one pass after they
    -- are added. Finish the pane only after that pass so its labels are laid
    -- out against the real right-pane width rather than the 1px initial width.
    if master.content then master.content:Show() end
    if master.frame then master.frame:Show() end
    if scrollFrame.frame then scrollFrame.frame:Show() end
    if scrollFrame.content then scrollFrame.content:Show() end
    if scrollFrame.layoutSuspended and scrollFrame.layoutSuspended > 0 then
        scrollFrame.layoutSuspended = 0
    end
    if scrollFrame.RefreshLayout then
        scrollFrame:RefreshLayout()
    end

    -- Keep a valid selection visibly actionable even if a malformed optional
    -- relation made the detailed renderer produce no children.
    if not scrollFrame.children or #scrollFrame.children == 0 then
        local nameOk, name = pcall(QuestieDB.QueryQuestSingle, questId, "name")
        name = nameOk and name or nil
        local fallback = QuestieGUI:Create("Label")
        fallback:SetText((quest and quest.name) or name or ("Quest " .. tostring(questId)))
        fallback:SetFullWidth(true)
        scrollFrame:AddChild(fallback)
        if scrollFrame.RefreshLayout then
            scrollFrame:RefreshLayout()
        end
    end
end

---Create and populate the right-hand quest pane from one tree selection.
---@param group table
---@param questId number
---@return boolean
local function ShowFactionQuestDetails(group, questId)
    if not group or group ~= factionTreeFrame or (group.IsReleasing and group:IsReleasing()) then
        return false
    end

    local master = group.frame and group.frame.obj
    if not master then
        return false
    end

    local getQuestOk, quest = pcall(QuestieDB.GetQuest, questId)
    if not getQuestOk then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[questsByFaction] Quest lookup failed:", questId, quest)
        quest = nil
    end

    master:ReleaseChildren()
    master:SetLayout("fill")
    master:SetFullWidth(true)
    master:SetFullHeight(true)
    if master.content then master.content:Show() end
    if master.frame then master.frame:Show() end

    local scrollFrame = QuestieGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    master:AddChild(scrollFrame)
    if master.RefreshLayout then
        master:RefreshLayout()
    end
    if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyPane then
        QuestieOptionsControls.ApplyJourneyPane(scrollFrame.frame)
    end
    if scrollFrame.frame then scrollFrame.frame:Show() end
    if scrollFrame.content then scrollFrame.content:Show() end

    if quest then
        local drawOk, drawError = pcall(QuestDetailsFrame.Draw, QuestDetailsFrame, scrollFrame, quest)
        if not drawOk then
            Questie.Debug(Questie.DEBUG_CRITICAL, "[questsByFaction] Quest detail draw failed:", questId, drawError)
        end
    else
        local name = QuestieDB.QueryQuestSingle and QuestieDB.QueryQuestSingle(questId, "name")
        local missingLabel = QuestieGUI:Create("Label")
        missingLabel:SetText(name or ("Quest " .. tostring(questId)))
        missingLabel:SetFullWidth(true)
        scrollFrame:AddChild(missingLabel)
    end

    FinalizeFactionQuestDetails(master, scrollFrame, quest, questId)
    return quest ~= nil
end

---Select and open a quest that is present in the currently displayed faction tree.
---@param questId QuestId
---@return boolean opened
function _QuestieJourney.questsByFaction:OpenQuest(questId)
    if not factionTreeFrame or not factionTreeFrame.tree then
        return false
    end

    for _, category in ipairs(factionTreeFrame.tree) do
        for _, quest in ipairs(category.children or {}) do
            if tonumber(quest.value) == questId then
                local selection = tostring(category.value) .. "\001" .. tostring(questId)
                factionTreeFrame:SelectByValue(selection)
                return true
            end
        end
    end

    return false
end

---Render a quest in the current Faction details pane when it is not in the tree.
---@param questId QuestId
---@return boolean opened
function _QuestieJourney.questsByFaction:OpenQuestDetails(questId)
    if not factionTreeFrame or not factionTreeFrame.frame or not factionTreeFrame.frame.obj then
        return false
    end

    return ShowFactionQuestDetails(factionTreeFrame, questId)
end

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
    local yieldCounter = 0

    for questId in pairs(QuestieDB.QuestPointers) do
        yieldCounter = yieldCounter + 1
        if yieldCounter >= 1000 then
            yieldCounter = 0
            coroutine.yield()
        end
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

    local yieldCounter = 0
    for questId in pairs(QuestieDB.QuestPointers) do
        yieldCounter = yieldCounter + 1
        if yieldCounter >= 1000 then
            yieldCounter = 0
            coroutine.yield()
        end
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

    factionTreeFrame = QuestieGUI:Create("TreeGroup")
    factionTreeFrame:SetFullWidth(true)
    factionTreeFrame:SetFullHeight(true)
    factionTreeFrame:EnableButtonTooltips(false)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyTreeGroup then
        QuestieOptionsControls.ApplyJourneyTreeGroup(factionTreeFrame)
    end
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
        QuestieOptionsControls.ApplyModernScrollbar(factionTreeFrame.scrollbar)
    end
    factionTreeFrame:SetTree(factionTree)
    factionTreeFrame:CollapseAllGroups()

    factionTreeFrame.treeframe:SetWidth(415)
    local lastRenderedTreeValue
    local function RenderFactionQuestDetails(group, treeValue, force)
        if group ~= factionTreeFrame or (group.IsReleasing and group:IsReleasing()) then
            return
        end

        if type(treeValue) ~= "string" then
            Questie.Debug(Questie.DEBUG_CRITICAL, "[factionTreeFrame:OnGroupSelected] No tree path given in Journey.")
            return
        end

        local _, questId = strsplit("\001", treeValue)
        if not questId then
            return
        end

        if not force and lastRenderedTreeValue == treeValue then
            return
        end

        questId = tonumber(questId)
        ShowFactionQuestDetails(group, questId)
        lastRenderedTreeValue = treeValue
    end

    factionTreeFrame:SetCallback("OnClick", function(group, _, treeValue)
        if type(treeValue) ~= "string" then
            return
        end

        local _, questId = strsplit("\001", treeValue)
        local getQuestOk, quest = false, nil
        local numericQuestId = questId and tonumber(questId)
        if numericQuestId then
            getQuestOk, quest = pcall(QuestieDB.GetQuest, numericQuestId)
        end
        if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() and getQuestOk and quest then
            ChatEdit_InsertLink(QuestieLink.GetQuestLinkStringById(quest.Id))
        end

    end)
    factionTreeFrame:SetCallback("OnGroupSelected", function(group, _, treeValue, force)
        RenderFactionQuestDetails(group, treeValue, force)
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
            value = "b",
            text = l10n("Breadcrumb Quests"),
            children = {},
        },
        [2] = {
            value = "a",
            text = l10n("Available Quests"),
            children = {}
        },
        [3] = {
            value = "r",
            text = l10n("Repeatable Quests"),
            children = {},
        },
        [4] = {
            value = "c",
            text = l10n("Completed Quests"),
            children = {}
        },
        [5] = {
            value = "p",
            text = l10n("Missing Requirement"),
            children = {}
        },
        [6] = {
            value = "u",
            text = l10n("Unobtainable Quests"),
            children = {},
        },
    }

    local sortedQuestByLevel = QuestieLib:SortQuestIDsByLevel(quests)

    local availableCounter = 0
    local prequestMissingCounter = 0
    local completedCounter = 0
    local unobtainableCounter = 0
    local repeatableCounter = 0
    local breadcrumbCompleteCounter = 0
    local breadcrumbCounter = 0
    local hiddenCounter = 0

    local temp = {}

    local hiddenQuests = QuestieCorrections.hiddenQuests
    local DoableStates = QuestieDB.DoableStates

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local questId = levelAndQuest[2]
        if QuestieDB.QuestPointers[questId] then
            temp.value = questId

            temp.iconSize = 14
            temp.useIconGutter = true
            temp.iconGutterOffset = -3
            if ActiveQuests.Get(questId) then
                if QuestieDB.IsComplete(questId) == 1 then
                    temp.icon = Questie.icons["complete"]
                else
                    temp.icon = Questie.icons["incomplete"]
                end
            end

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

            local breadcrumbForQuestId = QuestieDB.QueryQuest(questId,{"breadcrumbForQuestId"})[1] or {}
            local _, _, returnReason = QuestieDB.IsDoableVerbose(questId, false, true, false)

            -- Breadcrumb quests
            if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                tinsert(factionTree[1].children, temp)
                breadcrumbCounter = breadcrumbCounter + 1
            end

            -- Filtering logic. If changing anything here, also change in QuestsByZone.lua
            if returnReason then
                if returnReason == DoableStates.AVAILABLE then -- available quests
                    if QuestieDB.IsRepeatable(questId) then
                        tinsert(factionTree[3].children, temp)
                        repeatableCounter = repeatableCounter + 1
                    else
                        tinsert(factionTree[2].children, temp)
                        availableCounter = availableCounter + 1
                    end
                elseif returnReason == DoableStates.COMPLETED then -- completed quests
                    tinsert(factionTree[4].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        completedCounter = completedCounter + 1
                    end
                    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                        breadcrumbCompleteCounter = breadcrumbCompleteCounter + 1
                    end
                elseif returnReason == DoableStates.QUEST_LOG then -- player is on quest
                    if QuestieDB.IsRepeatable(questId) then
                        tinsert(factionTree[3].children, temp)
                        repeatableCounter = repeatableCounter + 1
                    else
                        tinsert(factionTree[2].children, temp)
                        availableCounter = availableCounter + 1
                    end
                -- elseif returnReason == DoableStates.BLACKLISTED then -- blacklisted quests -- already filtered earlier
                elseif returnReason == DoableStates.PARENT_ACTIVE then -- parent quest active
                -- reused the logic from AvailableQuests.lua _DrawChildQuests
                -- if this is modified, also make sure the changes are reflected in the other file(s)
                    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")
                    if (not Questie.db.char.complete[questId]) and (not hiddenQuests[questId]) and (QuestiePlayer.HasRequiredRace(requiredRaces)) then
                        -- some childQuest remain completed after abandoning and retaking parentQuest
                        -- here we are checking against
                        local childQuestExclusiveTo = QuestieDB.QueryQuestSingle(questId, "exclusiveTo")
                        local blockedByExclusiveTo = false
                        for _, exclusiveToQuestId in pairs(childQuestExclusiveTo or {}) do
                            if ActiveQuests.Get(exclusiveToQuestId) or Questie.db.char.complete[exclusiveToQuestId] then
                                tinsert(factionTree[4].children, temp)
                                completedCounter = completedCounter + 1
                                blockedByExclusiveTo = true
                                break
                            end
                        end
                        if (not blockedByExclusiveTo) then
                            local isPreQuestSingleFulfilled = true
                            local isPreQuestGroupFulfilled = true

                            local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
                            if preQuestSingle then
                               isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
                            else
                               local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
                                if preQuestGroup then
                                    isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
                                end
                            end

                            if isPreQuestSingleFulfilled and isPreQuestGroupFulfilled then
                                if QuestieDB.IsRepeatable(questId) then
                                    tinsert(factionTree[3].children, temp)
                                    repeatableCounter = repeatableCounter + 1
                                else
                                    tinsert(factionTree[2].children, temp)
                                    availableCounter = availableCounter + 1
                                end
                            end
                        end
                    end
                -- elseif returnReason == DoableStates.WRONG_RACE then -- wrong race -- not shown at all
                elseif returnReason == DoableStates.NO_PREQUESTSINGLE then -- no preQuestSingle completed
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- elseif returnReason == DoableStates.WRONG_CLASS then -- wrong class -- not shown at all
                elseif returnReason == DoableStates.MISSING_REPUTATION then -- too low reputation
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.EXCEED_REPUTATION then -- too high reputation
                    if not QuestieDB.questsOnlyAvailableUntilReputationValue[questId] then
                        tinsert(factionTree[5].children, temp)
                        if not QuestieDB.IsRepeatable(questId) then
                            prequestMissingCounter = prequestMissingCounter + 1
                        end
                    else
                        tinsert(factionTree[6].children, temp)
                        unobtainableCounter = unobtainableCounter + 1
                    end
                elseif returnReason == DoableStates.PROFESSION_SKILL then -- no profession skill
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.PROFESSION_RANK then -- no profession rank
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.NO_PREQUESTGROUP then -- no preQuestGroup completed
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.PARENT_INACTIVE then -- inactive parent
                    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
                    if Questie.db.char.complete[parentQuest] then
                        tinsert(factionTree[4].children, temp)
                        completedCounter = completedCounter + 1
                    else
                        tinsert(factionTree[5].children, temp)
                        if not QuestieDB.IsRepeatable(questId) then
                            prequestMissingCounter = prequestMissingCounter + 1
                        end
                    end
                elseif returnReason == DoableStates.NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED then -- nextQuestInChain completed or in quest log
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.EXCLUSIVE_COMPLETED or returnReason == DoableStates.EXCLUSIVE_IN_QUEST_LOG then -- exclusive quest completed or in quest log
                    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
                    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
                    local questDecidedCategory = false
                    -- checking for cases where the exclusiveTo is on the same level as other preQuestSingle values
                    if preQuestSingle then
                        for i = 1,#preQuestSingle do
                            local exclusivePreQuests = QuestieDB.QueryQuestSingle(preQuestSingle[i], "exclusiveTo")
                            if exclusivePreQuests then
                                for _, exclusivePreQuestId in pairs(exclusivePreQuests) do
                                    if not questDecidedCategory and (Questie.db.char.complete[exclusivePreQuestId] or ActiveQuests.Get(exclusivePreQuestId)) then
                                        tinsert(factionTree[6].children, temp)
                                        unobtainableCounter = unobtainableCounter + 1
                                        questDecidedCategory = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    -- checking for cases where the exclusiveTo is on the same level as other nextQuestInChain values
                    if nextQuestInChain and nextQuestInChain ~= 0 then
                        local exclusiveFollowups = QuestieDB.QueryQuestSingle(nextQuestInChain, "exclusiveTo")
                        if exclusiveFollowups then
                            for _, exclusiveFollowupId in pairs(exclusiveFollowups) do
                                if not questDecidedCategory and (Questie.db.char.complete[exclusiveFollowupId] or ActiveQuests.Get(exclusiveFollowupId)) then
                                    tinsert(factionTree[6].children, temp)
                                    unobtainableCounter = unobtainableCounter + 1
                                    questDecidedCategory = true
                                    break
                                end
                            end
                        end
                    end
                    -- "Regular" exclusives
                    if not questDecidedCategory then
                        if QuestieDB.IsRepeatable(questId) then
                            tinsert(factionTree[6].children, temp)
                            unobtainableCounter = unobtainableCounter + 1
                        else
                            tinsert(factionTree[4].children, temp)
                            completedCounter = completedCounter + 1
                        end
                    end
                elseif returnReason == DoableStates.MISSING_DAILY then -- not today's daily quest
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.PROFESSION_SPECIALIZATION then -- wrong profession specialization
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.SPELL_MISSING then -- missing spell, so quest unavailable
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.SPELL_KNOWN then -- learned spell, so quest unavailable
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.MISSING_ACHIEVEMENT then -- missing achievement
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.BREADCRUMB_FOLLOWUP then -- breadcrumb's follow up active or completed
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- show event quests outside event dates
                elseif returnReason == DoableStates.EVENT_INACTIVE then -- event inactive
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.BREADCRUMB_ACTIVE then -- quest not available because breadcrumb in quest log
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.INACTIVE_DAILY then -- daily quests detected not present today
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.LEVEL_TOO_HIGH then -- player is higher level than quest bracket
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.LEVEL_TOO_LOW then -- player is too low
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.DISABLING_QUEST_COMPLETED then -- quest that hides it already turned in
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.ENABLING_QUEST_MISSING then -- quest that enables this quest is not picked up or turned in
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.PROFESSION_MISSING then -- profession missing completely
                    tinsert(factionTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.DISABLED_BY then -- disabling quest is active
                    tinsert(factionTree[6].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        unobtainableCounter = unobtainableCounter + 1
                    end
                elseif returnReason == DoableStates.ARENA_RATING then -- missing arena rating
                    tinsert(factionTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                end
            end

            -- show manually hidden quests
            if Questie.db.char.hidden[questId] then
                if not factionTree[7] then
                    factionTree[7] = {
                        value = "h",
                        text = l10n("Hidden Quests"),
                        children = {},
                    }
                end
                tinsert(factionTree[7].children, temp)
                hiddenCounter = hiddenCounter + 1
            end
            temp = {}
        end
    end

    local totalCounter = availableCounter + completedCounter + prequestMissingCounter

	if breadcrumbCounter and breadcrumbCounter >= 1 then
       factionTree[1].text = factionTree[1].text .. ' [ '..  breadcrumbCompleteCounter ..'/'.. breadcrumbCounter ..' ]'
    else
       factionTree[1].text = factionTree[1].text .. ' [ '..  breadcrumbCounter ..' ]'
    end

    factionTree[2].text = factionTree[2].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    factionTree[3].text = factionTree[3].text .. ' [ '..  repeatableCounter ..' ]'
    factionTree[4].text = factionTree[4].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    factionTree[5].text = factionTree[5].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    factionTree[6].text = factionTree[6].text .. ' [ '..  unobtainableCounter ..' ]'

    -- only show hidden quests when there are some
    if factionTree[7] then
        factionTree[7].text = factionTree[7].text .. ' [ '..  hiddenCounter ..' ]'
    end

    factionTree.numquests = totalCounter + repeatableCounter + unobtainableCounter

    return factionTree
end
