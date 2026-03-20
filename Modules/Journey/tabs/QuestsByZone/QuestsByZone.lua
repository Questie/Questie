---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
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
        if (sel == nil or sel == "a" or sel == "p" or sel == "c" or sel == "r" or sel == "u" or sel == "b" or sel == "h") and (not questId) then
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

    local HIDE_ON_MAP = QuestieQuestBlacklist.HIDE_ON_MAP
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local playerlevel = UnitLevel("player")
    local DoableStates = QuestieDB.DoableStates

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        ---@type number
        local questId = levelAndQuest[2]
        -- Only show quests which are not hidden
        if hiddenQuests and (((not hiddenQuests[questId]) or hiddenQuests[questId] == HIDE_ON_MAP) or QuestieEvent.IsEventQuest(questId)) and QuestieDB.QuestPointers[questId] then
            temp.value = questId
            temp.text = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)

            local breadcrumbForQuestId = QuestieDB.QueryQuest(questId,{"breadcrumbForQuestId"})[1] or {}
            local eligibilityText, _, returnReason = QuestieDB.IsDoableVerbose(questId, false, true, true)

            -- Breadcrumb quests
            if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                tinsert(zoneTree[1].children, temp)
                breadcrumbCounter = breadcrumbCounter + 1
            end

            if returnReason then
                if returnReason == DoableStates.AVAILABLE then -- available quests
                    if QuestieDB.IsRepeatable(questId) then
                        tinsert(zoneTree[3].children, temp)
                        repeatableCounter = repeatableCounter + 1
                    else
                        tinsert(zoneTree[2].children, temp)
                        availableCounter = availableCounter + 1
                    end
                elseif returnReason == DoableStates.COMPLETED then -- completed quests
                    tinsert(zoneTree[4].children, temp)
                    completedCounter = completedCounter + 1
                    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                        breadcrumbCompleteCounter = breadcrumbCompleteCounter + 1
                    end
                elseif returnReason == DoableStates.QUEST_LOG then -- player is on quest
                    if QuestieDB.IsRepeatable(questId) then
                        tinsert(zoneTree[3].children, temp)
                        repeatableCounter = repeatableCounter + 1
                    else
                        tinsert(zoneTree[2].children, temp)
                        availableCounter = availableCounter + 1
                    end
                -- elseif returnReason == DoableStates.BLACKLISTED then -- blacklisted quests -- already filtered earlier
                -- elseif returnReason == DoableStates.HIDDEN then -- manually hidden quests -- no longer applicable
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
                            if QuestiePlayer.currentQuestlog[exclusiveToQuestId] or Questie.db.char.complete[exclusiveToQuestId] then
                                tinsert(zoneTree[4].children, temp)
                                completedCounter = completedCounter + 1
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
                                    tinsert(zoneTree[3].children, temp)
                                    repeatableCounter = repeatableCounter + 1
                                else
                                    tinsert(zoneTree[2].children, temp)
                                    availableCounter = availableCounter + 1
                                end
                            end
                        end
                    end
                -- elseif returnReason == DoableStates.WRONG_RACE then -- wrong race -- not shown at all
                elseif returnReason == DoableStates.NO_PREQUESTSINGLE then -- no preQuestSingle completed
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                -- elseif returnReason == DoableStates.WRONG_CLASS then -- wrong class -- not shown at all
                elseif returnReason == DoableStates.MISSING_REPUTATION then -- no reputation
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                elseif returnReason == DoableStates.PROFESSION_SKILL then -- no profession and skill
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.NO_PREQUESTGROUP then -- no preQuestGroup completed
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                elseif returnReason == DoableStates.PARENT_INACTIVE then -- inactive parent
                    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
                    if Questie.db.char.complete[parentQuest] then
                        tinsert(zoneTree[4].children, temp)
                        completedCounter = completedCounter + 1
                    else
                        tinsert(zoneTree[5].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED then -- nextQuestInChain completed or in quest log
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.EXCLUSIVE_COMPLETED or returnReason == DoableStates.EXCLUSIVE_IN_QUEST_LOG then -- exclusive quest completed or in quest log
                    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
                    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
                    local questDecidedCategory = false
                    -- checking for some weird cases where the exclusiveTo is on the same level as other preQuestSingle values
                    if preQuestSingle then
                        for i = 1,#preQuestSingle do
                            local exclusivePreQuests = QuestieDB.QueryQuestSingle(preQuestSingle[i], "exclusiveTo")
                            if exclusivePreQuests then
                                for _, exclusivePreQuestId in pairs(exclusivePreQuests) do
                                    if Questie.db.char.complete[exclusivePreQuestId] or QuestiePlayer.currentQuestlog[exclusivePreQuestId] then
                                        tinsert(zoneTree[6].children, temp)
                                        unobtainableCounter = unobtainableCounter + 1
                                        questDecidedCategory = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    -- checking for some weird cases where the exclusiveTo is on the same level as other nextQuestInChain values
                    if nextQuestInChain and nextQuestInChain ~= 0 and not questDecidedCategory then
                        local exclusiveFollowups = QuestieDB.QueryQuestSingle(nextQuestInChain, "exclusiveTo")
                        if exclusiveFollowups then
                            for _, exclusiveFollowupId in pairs(exclusiveFollowups) do
                                if Questie.db.char.complete[exclusiveFollowupId] or QuestiePlayer.currentQuestlog[exclusiveFollowupId] then
                                    tinsert(zoneTree[6].children, temp)
                                    unobtainableCounter = unobtainableCounter + 1
                                    questDecidedCategory = true
                                    break
                                end
                            end
                        end
                    end
                    -- "Regular" exclusives
                    if not questDecidedCategory then
                        tinsert(zoneTree[4].children, temp)
                        completedCounter = completedCounter + 1
                    end
                elseif returnReason == DoableStates.MISSING_DAILY then -- not today's daily quest
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.PROFESSION_SPECIALIZATION then -- wrong profession specialization
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.SPELL_MISSING then -- missing spell, so quest unavailable
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                elseif returnReason == DoableStates.SPELL_KNOWN then -- learned spell, so quest unavailable
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.MISSING_ACHIEVEMENT then -- missing achievement
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                elseif returnReason == DoableStates.BREADCRUMB_FOLLOWUP then -- breadcrumb's follow up active or completed
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- The next case is commented out since it's not a valid check to have. Breadcrumbs to the same quest are not always exclusive to eachother
                --[[elseif returnReason == DoableStates.EXCLUSIVE_BREADCRUMB then -- another breadcrumb active
                    tinsert(zoneTree[4].children, temp)
                    completedCounter = completedCounter + 1]]
                elseif returnReason == DoableStates.BREADCRUMB_ACTIVE then -- quest not available because breadcrumb in quest log
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                elseif returnReason == DoableStates.INACTIVE_DAILY then -- daily quests detected not present today
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.LEVEL_TOO_HIGH then -- player is higher level than quest bracket
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.LEVEL_TOO_LOW then -- player is too low
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                elseif returnReason == DoableStates.DISABLING_QUEST_COMPLETED then -- quest that hides it already turned in
                    -- Repeatables are considered complete
                    if QuestieDB.IsRepeatable(questId) then
                        tinsert(zoneTree[4].children, temp)
                        completedCounter = completedCounter + 1
                    -- The others are considered unobtainable
                    else
                        tinsert(zoneTree[6].children, temp)
                        unobtainableCounter = unobtainableCounter + 1
                    end
                elseif returnReason == DoableStates.ENABLING_QUEST_MISSING then -- quest that enables this quest is not picked up or turned in
                    tinsert(zoneTree[5].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                end
            end

            -- show event quests outside event dates
            if QuestieEvent.IsEventQuest(questId) and not QuestieEvent.IsEventActiveForQuest(questId) then
                tinsert(zoneTree[6].children, temp)
                unobtainableCounter = unobtainableCounter + 1
            -- AQ War Effort quests (one-time world event that has ended for all realms)
            elseif (not Questie.IsSoD) and QuestieQuestBlacklist.AQWarEffortQuests[questId] then
                tinsert(zoneTree[6].children, temp)
                unobtainableCounter = unobtainableCounter + 1
            end

            -- show manually hidden quests 
            if Questie.db.char.hidden[questId] then
                if not zoneTree[7] then
                    zoneTree[7] = {
                        value = "h",
                        text = l10n("Hidden Quests"),
                        children = {},
                    }
                end
                tinsert(zoneTree[7].children, temp)
                hiddenCounter = hiddenCounter + 1
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
    zoneTree[3].text = zoneTree[3].text .. ' [ '..  repeatableCounter ..' ]'
    zoneTree[4].text = zoneTree[4].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    zoneTree[5].text = zoneTree[5].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    zoneTree[6].text = zoneTree[6].text .. ' [ '..  unobtainableCounter ..' ]'

    -- only show hidden quests when there are some
    if zoneTree[7] then
        zoneTree[7].text = zoneTree[7].text .. ' [ '..  hiddenCounter ..' ]'
    end

    zoneTree.numquests = totalCounter + repeatableCounter + breadcrumbCounter + unobtainableCounter + hiddenCounter

    return zoneTree
end
