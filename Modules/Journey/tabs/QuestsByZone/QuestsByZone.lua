---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private

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
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")
local zoneTreeFrame

---Restore the previously selected quest in the zone tree
---@param treeFrame table @The AceGUI TreeGroup frame
---@param zoneTree table @The zone tree table
function _QuestieJourney.questsByZone:RestoreSavedQuestSelection(treeFrame, zoneTree)
    local savedSelection = _QuestieJourney.lastZoneSelection[3]
    if not savedSelection then return end

    local sel, questId = strsplit("\001", savedSelection)
    if not questId then return end

    questId = tonumber(questId)
    local questExists = false
    local currentSelection
    local foundSavedCategory = false

    for _, category in ipairs(zoneTree) do
        if category.children then
            for _, quest in ipairs(category.children) do
                if quest.value and quest.value == questId then
                    questExists = true
                    local selection = category.value .. "\001" .. questId
                    if category.value == sel then
                        currentSelection = selection
                        foundSavedCategory = true
                        break
                    end
                    if not currentSelection then
                        currentSelection = selection
                    end
                end
            end
        end
        if foundSavedCategory then break end
    end

    if questExists and currentSelection then
        _QuestieJourney.lastZoneSelection[3] = currentSelection
        treeFrame:SelectByValue(currentSelection)

        C_Timer.After(0.1, function()
            if not treeFrame.frame or not treeFrame.frame.obj then return end

            local quest = QuestieDB.GetQuest(questId)
            if quest then
                local master = treeFrame.frame.obj
                master:ReleaseChildren()
                master:SetLayout("fill")
                master:SetFullWidth(true)
                master:SetFullHeight(true)

                ---@class ScrollFrame
                local scrollFrame = AceGUI:Create("ScrollFrame")
                scrollFrame:SetLayout("flow")
                scrollFrame:SetFullHeight(true)
                master:AddChild(scrollFrame)

                _QuestieJourney:DrawQuestDetailsFrame(scrollFrame, quest)
            end
        end)
    else
        _QuestieJourney.lastZoneSelection[3] = nil
    end
end

---Manage the zone tree itself and the contents of the per-quest window
---@param container AceSimpleGroup @The container for the zone tree
---@param zoneTree table @The zone tree table
function _QuestieJourney.questsByZone:ManageTree(container, zoneTree)
    if zoneTreeFrame then
        container:ReleaseChildren()
        zoneTreeFrame = nil
        _QuestieJourney.questsByZone:ManageTree(container, zoneTree)
        return
    end

    zoneTreeFrame = AceGUI:Create("TreeGroup")
    zoneTreeFrame:SetFullWidth(true)
    zoneTreeFrame:SetFullHeight(true)
    zoneTreeFrame:SetTree(zoneTree)

    zoneTreeFrame.treeframe:SetWidth(415)

    _QuestieJourney.questsByZone:RestoreSavedQuestSelection(zoneTreeFrame, zoneTree)

    zoneTreeFrame:SetCallback("OnClick", function(group, ...)
        local treePath = {...}

        if not treePath[2] then
            Questie:Debug(Questie.DEBUG_CRITICAL, "[zoneTreeFrame:OnClick] No tree path given in Journey.")
            return
        end
        -- if they clicked on a header, don't do anything
        local sel, questId = strsplit("\001", treePath[2]) -- treePath[2] looks like "a?1234" for an available quest with ID 1234
        if (sel == nil or sel == "a" or sel == "p" or sel == "c" or sel == "r" or sel == "u" or sel == "b") and (not questId) then
            return
        end

        -- save the selected quest for persistence
        _QuestieJourney.lastZoneSelection[3] = treePath[2]

        -- get master frame and create scroll frame inside
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

        ---@type number
        questId = tonumber(questId)
        local quest = QuestieDB.GetQuest(questId)

        -- Add the quest to the open chat window if it was a shift click
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            if Questie.db.profile.trackerShowQuestLevel then
                ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(quest.level, quest.name, quest.Id))
            else
                ChatEdit_InsertLink("[" .. quest.name .. " (" .. quest.Id .. ")]")
            end
        end

        _QuestieJourney:DrawQuestDetailsFrame(scrollFrame, quest)
    end)

    container:AddChild(zoneTreeFrame)
end

---Get all the available/completed/repeatable/unavailable quests
---@param zoneId number @The zone ID (Check `l10n.zoneLookup`)
---@return table<number,any> @The zoneTree table which represents the list of all the different quests
function _QuestieJourney.questsByZone:CollectZoneQuests(zoneId)
    local quests = QuestieJourney.zoneMap[zoneId]

    if (not quests) then
        return nil
    end

    return _QuestieJourney.questsByZone:CategorizeQuests(quests)
end

---Categorize quests into available/completed/repeatable/unavailable categories
---@param quests table @A table of quest IDs (keys are quest IDs, values are truthy)
---@return table @The zoneTree table which represents the list of all the different quests
function _QuestieJourney.questsByZone:CategorizeQuests(quests)
    if not quests then
        return nil
    end

    local zoneTree = {
        [1] = {
            value = "b",
            text = l10n('Breadcrumb Quests'),
            children = {},
        },
        [2] = {
            value = "a",
            text = l10n('Available Quests'),
            children = {}
        },
        [3] = {
            value = "p",
            text = l10n('Missing Pre Quest'),
            children = {}
        },
        [4] = {
            value = "c",
            text = l10n('Completed Quests'),
            children = {}
        },
        [5] = {
            value = "r",
            text = l10n('Repeatable Quests'),
            children = {},
        },
        [6] = {
            value = "u",
            text = l10n('Unobtainable Quests'),
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

    local unobtainableQuestIds = {}
    local temp = {}

    local HIDE_ON_MAP = QuestieQuestBlacklist.HIDE_ON_MAP
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local playerlevel = UnitLevel("player")

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        ---@type number
        local questId = levelAndQuest[2]
        -- Only show quests which are not hidden
        if hiddenQuests and (((not hiddenQuests[questId]) or hiddenQuests[questId] == HIDE_ON_MAP) or QuestieEvent.IsEventQuest(questId)) and QuestieDB.QuestPointers[questId] then
            temp.value = questId
            temp.text = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)

            local breadcrumbForQuestId = QuestieDB.QueryQuest(questId,{"breadcrumbForQuestId"})[1] or {}

            -- Breadcrumb quests
            if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                tinsert(zoneTree[1].children, temp)
                breadcrumbCounter = breadcrumbCounter + 1
            end

            -- Completed quests
            if Questie.db.char.complete[questId] then
                tinsert(zoneTree[4].children, temp)
                completedCounter = completedCounter + 1
                if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                    breadcrumbCompleteCounter = breadcrumbCompleteCounter + 1
                end
            else
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
                        "requiredLevel"
                        }
                ) or {}
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
                local requiredLevel = queryResult[12]

                -- Exclusive quests will never be available since another quests permanently blocks them.
                -- Marking them as complete should be the most satisfying solution for user
                if (nextQuestInChain ~= 0 and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
                    tinsert(zoneTree[4].children, temp)
                    completedCounter = completedCounter + 1
                -- The parent quest has been completed
                elseif parentQuest and Questie.db.char.complete[parentQuest] then
                    tinsert(zoneTree[4].children, temp)
                    completedCounter = completedCounter + 1
                -- Unobtainable reputation quests
                elseif not QuestieReputation.HasReputation(requiredMinRep, requiredMaxRep) then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableQuestIds[questId] = true
                    unobtainableCounter = unobtainableCounter + 1
                -- Profession specialization
                elseif (not QuestieProfessions.HasSpecialization(requiredSpecialization)) then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Required profession not learned or skill level not reached
                elseif requiredSkill and (function()
                    local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
                    return not hasProfession or not hasSkillLevel
                end)() then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableQuestIds[questId] = true
                    unobtainableCounter = unobtainableCounter + 1
                -- A single pre Quest is missing
                elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
                    -- The pre Quest is unobtainable therefore this quest is it as well
                    if unobtainableQuestIds[preQuestSingle] ~= nil then
                        tinsert(zoneTree[6].children, temp)
                        unobtainableQuestIds[questId] = true
                        unobtainableCounter = unobtainableCounter + 1
                    else
                        tinsert(zoneTree[3].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- Multiple pre Quests are missing
                elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
                    local hasUnobtainablePreQuest = false
                    for _, preQuestId in pairs(preQuestGroup) do
                        if unobtainableQuestIds[preQuestId] ~= nil then
                            tinsert(zoneTree[6].children, temp)
                            unobtainableQuestIds[questId] = true
                            unobtainableCounter = unobtainableCounter + 1
                            hasUnobtainablePreQuest = true
                            break
                        end
                    end

                    if not hasUnobtainablePreQuest then
                        tinsert(zoneTree[3].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- Quests which you have outleveled
                elseif requiredMaxLevel and requiredMaxLevel ~= 0 and playerlevel > requiredMaxLevel then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Quests which you are too low level for
                elseif requiredLevel and requiredLevel > playerlevel then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Event quests where the event is not currently active
                elseif QuestieEvent.IsEventQuest(questId) and not QuestieEvent.IsEventActiveForQuest(questId) then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- AQ War Effort quests (one-time world event that has ended for all realms)
                elseif (not Questie.IsSoD) and QuestieQuestBlacklist.AQWarEffortQuests[questId] then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Repeatable quests
                elseif QuestieDB.IsRepeatable(questId) then
                    tinsert(zoneTree[5].children, temp)
                    repeatableCounter = repeatableCounter + 1
                -- Quests which require you to NOT have learned a spell (most likely a fake quest for SoD runes)
                elseif requiredSpell and requiredSpell < 0 and (IsSpellKnownOrOverridesKnown(math.abs(requiredSpell)) or IsPlayerSpell(math.abs(requiredSpell))) then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Quests which require you to HAVE learned a spell
                elseif requiredSpell and requiredSpell > 0 and not (IsSpellKnownOrOverridesKnown(math.abs(requiredSpell)) or IsPlayerSpell(math.abs(requiredSpell))) then
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Available quests
                else
                    tinsert(zoneTree[2].children, temp)
                    availableCounter = availableCounter + 1
                end
            end
            temp = {}
        end
    end

    local totalCounter = availableCounter + completedCounter + prequestMissingCounter

	if breadcrumbCounter and breadcrumbCounter >= 1 then
       zoneTree[1].text = zoneTree[1].text .. ' [ '..  breadcrumbCompleteCounter ..'/'.. breadcrumbCounter ..' ]'
    else
       zoneTree[1].text = zoneTree[1].text .. ' [ '..  breadcrumbCounter ..' ]'
    end

    zoneTree[2].text = zoneTree[2].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    zoneTree[3].text = zoneTree[3].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    zoneTree[4].text = zoneTree[4].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    zoneTree[5].text = zoneTree[5].text .. ' [ '..  repeatableCounter ..' ]'
    zoneTree[6].text = zoneTree[6].text .. ' [ '..  unobtainableCounter ..' ]'

    zoneTree.numquests = totalCounter + repeatableCounter + unobtainableCounter

    return zoneTree
end
