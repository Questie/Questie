---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private

---@type QuestDetailsFrame
local QuestDetailsFrame = QuestieLoader:ImportModule("QuestDetailsFrame")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")
local zoneTreeFrame

local function FinalizeZoneQuestDetails(master, scrollFrame, quest, questId)
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
---The native tree has two notifications (click and selection); this helper
---keeps pane construction independent from which notification caused it.
---@param group table
---@param questId number
---@return boolean
local function ShowZoneQuestDetails(group, questId)
    if not group or group ~= zoneTreeFrame or (group.IsReleasing and group:IsReleasing()) then
        return false
    end

    local master = group.frame and group.frame.obj
    if not master then
        return false
    end

    local getQuestOk, quest = pcall(QuestieDB.GetQuest, questId)
    if not getQuestOk then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[questsByZone] Quest lookup failed:", questId, quest)
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
            Questie.Debug(Questie.DEBUG_CRITICAL, "[questsByZone] Quest detail draw failed:", questId, drawError)
        end
    else
        local name = QuestieDB.QueryQuestSingle and QuestieDB.QueryQuestSingle(questId, "name")
        local missingLabel = QuestieGUI:Create("Label")
        missingLabel:SetText(name or ("Quest " .. tostring(questId)))
        missingLabel:SetFullWidth(true)
        scrollFrame:AddChild(missingLabel)
    end

    FinalizeZoneQuestDetails(master, scrollFrame, quest, questId)
    return quest ~= nil
end

function _QuestieJourney.questsByZone:ResetTree()
    zoneTreeFrame = nil
end

---Select and open a quest that is present in the currently displayed zone tree.
---@param questId QuestId
---@return boolean opened
function _QuestieJourney.questsByZone:OpenQuest(questId)
    if not zoneTreeFrame or not zoneTreeFrame.tree then
        return false
    end

    for _, category in ipairs(zoneTreeFrame.tree) do
        for _, quest in ipairs(category.children or {}) do
            if tonumber(quest.value) == questId then
                local selection = tostring(category.value) .. "\001" .. tostring(questId)
                _QuestieJourney.lastZoneSelection[3] = selection
                zoneTreeFrame:SelectByValue(selection)
                return true
            end
        end
    end

    return false
end

---Render a quest in the current Zone details pane when it is not in the tree.
---@param questId QuestId
---@return boolean opened
function _QuestieJourney.questsByZone:OpenQuestDetails(questId)
    if not zoneTreeFrame or not zoneTreeFrame.frame or not zoneTreeFrame.frame.obj then
        return false
    end

    return ShowZoneQuestDetails(zoneTreeFrame, questId)
end

---Restore the previously selected quest in the zone tree
---@param treeFrame table @The QuestieGUI TreeGroup frame
---@param zoneTree table @The zone tree table
function _QuestieJourney.questsByZone:RestoreSavedQuestSelection(treeFrame, zoneTree)
    if not treeFrame or not zoneTree then return end

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
            -- A zone/category change can replace this tree before the
            -- deferred restore runs. Do not let the old tree repaint the new
            -- zone's detail pane with stale quest data.
            if zoneTreeFrame ~= treeFrame then return end
            if _QuestieJourney.lastZoneSelection[3] ~= currentSelection then return end
            if not treeFrame.frame or not treeFrame.frame.obj then return end

            ShowZoneQuestDetails(treeFrame, questId)
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

    zoneTreeFrame = QuestieGUI:Create("TreeGroup")
    zoneTreeFrame:SetFullWidth(true)
    zoneTreeFrame:SetFullHeight(true)
    zoneTreeFrame:EnableButtonTooltips(false)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyTreeGroup then
        QuestieOptionsControls.ApplyJourneyTreeGroup(zoneTreeFrame)
    end
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
        QuestieOptionsControls.ApplyModernScrollbar(zoneTreeFrame.scrollbar)
    end
    zoneTreeFrame:SetTree(zoneTree)
    zoneTreeFrame:CollapseAllGroups()

    zoneTreeFrame.treeframe:SetWidth(415)

    _QuestieJourney.questsByZone:RestoreSavedQuestSelection(zoneTreeFrame, zoneTree)

    local lastRenderedTreeValue
    local function RenderQuestDetails(group, treeValue, force)
        if group ~= zoneTreeFrame or (group.IsReleasing and group:IsReleasing()) then
            return
        end

        if type(treeValue) ~= "string" then
            Questie.Debug(Questie.DEBUG_CRITICAL, "[zoneTreeFrame:OnGroupSelected] No tree path given in Journey.")
            return
        end
        -- if they clicked on a header, don't do anything
        local _, questId = strsplit("\001", treeValue)
        if not questId then
            return
        end

        if not force and lastRenderedTreeValue == treeValue then
            return
        end

        -- save the selected quest for persistence
        _QuestieJourney.lastZoneSelection[3] = treeValue

        ---@type number
        questId = tonumber(questId)

        ShowZoneQuestDetails(group, questId)
        lastRenderedTreeValue = treeValue
    end

    zoneTreeFrame.renderQuestDetails = RenderQuestDetails
    zoneTreeFrame:SetCallback("OnClick", function(group, _, treeValue)
        if type(treeValue) ~= "string" then
            return
        end

        local _, questId = strsplit("\001", treeValue)
        local getQuestOk, quest = false, nil
        if questId then
            getQuestOk, quest = pcall(QuestieDB.GetQuest, tonumber(questId))
        end
        if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() and getQuestOk and quest then
            ChatEdit_InsertLink(QuestieLink.GetQuestLinkStringById(quest.Id))
        end
    end)
    zoneTreeFrame:SetCallback("OnGroupSelected", function(group, _, treeValue, force)
        RenderQuestDetails(group, treeValue, force)
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
            temp.text = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)

            local breadcrumbForQuestId = QuestieDB.QueryQuest(questId, {"breadcrumbForQuestId"})[1] or {}
            local _, _, returnReason = QuestieDB.IsDoableVerbose(questId, false, true, false)

            -- Breadcrumb quests
            if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
                tinsert(zoneTree[1].children, temp)
                breadcrumbCounter = breadcrumbCounter + 1
            end

            -- Filtering logic. If changing anything here, also change in QuestsByFaction.lua
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
                    if not QuestieDB.IsRepeatable(questId) then
                        completedCounter = completedCounter + 1
                    end
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
                                tinsert(zoneTree[4].children, temp)
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
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                    -- elseif returnReason == DoableStates.WRONG_CLASS then -- wrong class -- not shown at all
                elseif returnReason == DoableStates.MISSING_REPUTATION then -- too low reputation
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.EXCEED_REPUTATION then -- too high reputation
                    if not QuestieDB.questsOnlyAvailableUntilReputationValue[questId] then
                        tinsert(zoneTree[5].children, temp)
                        if not QuestieDB.IsRepeatable(questId) then
                            prequestMissingCounter = prequestMissingCounter + 1
                        end
                    else
                        tinsert(zoneTree[6].children, temp)
                        unobtainableCounter = unobtainableCounter + 1
                    end
                elseif returnReason == DoableStates.PROFESSION_SKILL then -- no profession skill
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.PROFESSION_RANK then -- no profession rank
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.NO_PREQUESTGROUP then -- no preQuestGroup completed
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.PARENT_INACTIVE then -- inactive parent
                    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
                    if Questie.db.char.complete[parentQuest] then
                        tinsert(zoneTree[6].children, temp)
                        unobtainableCounter = unobtainableCounter + 1
                    else
                        tinsert(zoneTree[5].children, temp)
                        if not QuestieDB.IsRepeatable(questId) then
                            prequestMissingCounter = prequestMissingCounter + 1
                        end
                    end
                elseif returnReason == DoableStates.NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED then -- nextQuestInChain completed or in quest log
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.EXCLUSIVE_COMPLETED or returnReason == DoableStates.EXCLUSIVE_IN_QUEST_LOG then -- exclusive quest completed or in quest log
                    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
                    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
                    local questDecidedCategory = false
                    -- checking for cases where the exclusiveTo is on the same level as other preQuestSingle values
                    if preQuestSingle then
                        for i = 1, #preQuestSingle do
                            local exclusivePreQuests = QuestieDB.QueryQuestSingle(preQuestSingle[i], "exclusiveTo")
                            if exclusivePreQuests then
                                for _, exclusivePreQuestId in pairs(exclusivePreQuests) do
                                    if not questDecidedCategory and (Questie.db.char.complete[exclusivePreQuestId] or ActiveQuests.Get(exclusivePreQuestId)) then
                                        tinsert(zoneTree[6].children, temp)
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
                        if QuestieDB.IsRepeatable(questId) then
                            tinsert(zoneTree[6].children, temp)
                            unobtainableCounter = unobtainableCounter + 1
                        else
                            tinsert(zoneTree[4].children, temp)
                            completedCounter = completedCounter + 1
                        end
                    end
                elseif returnReason == DoableStates.MISSING_DAILY then -- not today's daily quest
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.PROFESSION_SPECIALIZATION then -- wrong profession specialization
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.SPELL_MISSING then -- missing spell, so quest unavailable
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.SPELL_KNOWN then -- learned spell, so quest unavailable
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.MISSING_ACHIEVEMENT then -- missing achievement
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.BREADCRUMB_FOLLOWUP then -- breadcrumb's follow up active or completed
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.EVENT_INACTIVE then -- event inactive
                    -- show event quests outside event dates
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.BREADCRUMB_ACTIVE then -- quest not available because breadcrumb in quest log
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.INACTIVE_DAILY then -- daily quests detected not present today
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.LEVEL_TOO_HIGH then -- player is higher level than quest bracket
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.LEVEL_TOO_LOW then -- player is too low
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.DISABLING_QUEST_COMPLETED then -- quest that hides it already turned in
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.ENABLING_QUEST_MISSING then -- quest that enables this quest is not picked up or turned in
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                elseif returnReason == DoableStates.PROFESSION_MISSING then -- profession missing completely
                    tinsert(zoneTree[6].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                elseif returnReason == DoableStates.DISABLED_BY then -- disabling quest is active
                    tinsert(zoneTree[6].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        unobtainableCounter = unobtainableCounter + 1
                    end
                elseif returnReason == DoableStates.ARENA_RATING then -- missing arena rating
                    tinsert(zoneTree[5].children, temp)
                    if not QuestieDB.IsRepeatable(questId) then
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                end
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
        zoneTree[1].text = zoneTree[1].text .. " [ " .. breadcrumbCompleteCounter .. "/" .. breadcrumbCounter .. " ]"
    else
        zoneTree[1].text = zoneTree[1].text .. " [ " .. breadcrumbCounter .. " ]"
    end

    zoneTree[2].text = zoneTree[2].text .. " [ " .. availableCounter .. "/" .. totalCounter .. " ]"
    zoneTree[3].text = zoneTree[3].text .. " [ " .. repeatableCounter .. " ]"
    zoneTree[4].text = zoneTree[4].text .. " [ " .. completedCounter .. "/" .. totalCounter .. " ]"
    zoneTree[5].text = zoneTree[5].text .. " [ " .. prequestMissingCounter .. "/" .. totalCounter .. " ]"
    zoneTree[6].text = zoneTree[6].text .. " [ " .. unobtainableCounter .. " ]"

    -- only show hidden quests when there are some
    if zoneTree[7] then
        zoneTree[7].text = zoneTree[7].text .. " [ " .. hiddenCounter .. " ]"
    end

    zoneTree.numquests = totalCounter + repeatableCounter + breadcrumbCounter + unobtainableCounter + hiddenCounter

    return zoneTree
end
