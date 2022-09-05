---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByZone = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")
local zoneTreeFrame

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

    zoneTreeFrame.treeframe:SetWidth(220)
    zoneTreeFrame:SetCallback("OnClick", function(group, ...)
        local treePath = {...}

        if not treePath[2] then
            Questie:Debug(Questie.DEBUG_CRITICAL, "[zoneTreeFrame:OnClick] No tree path given in Journey.")
            return
        end
        -- if they clicked on a header, don't do anything
        local sel, questId = strsplit("\001", treePath[2]) -- treePath[2] looks like "a?1234" for an available quest with ID 1234
        if (sel == nil or sel == "a" or sel == "p" or sel == "c" or sel == "r" or sel == "u") and (not questId) then
            return
        end

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
        local quest = QuestieDB:GetQuest(questId)

        -- Add the quest to the open chat window if it was a shift click
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            if Questie.db.global.trackerShowQuestLevel then
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
    local quests = QuestieJourney.zoneMap[zoneId]--QuestieDB:GetQuestsByZoneId(zoneId)

    if (not quests) then
        return nil
    end


    local zoneTree = {
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

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        ---@type number
        local questId = levelAndQuest[2]
        -- Only show quests which are not hidden
        if QuestieCorrections.hiddenQuests and ((not QuestieCorrections.hiddenQuests[questId]) or QuestieEvent:IsEventQuest(questId)) and QuestieDB.QuestPointers[questId] then
            temp.value = questId
            temp.text = QuestieLib:GetColoredQuestName(questId, Questie.db.global.enableTooltipsQuestLevel, false, true)

            -- Completed quests
            if Questie.db.char.complete[questId] then
                tinsert(zoneTree[3].children, temp)
                completedCounter = completedCounter + 1
            else
                local queryResult = QuestieDB.QueryQuest(
                        questId,
                        "exclusiveTo",
                        "nextQuestInChain",
                        "parentQuest",
                        "preQuestSingle",
                        "preQuestGroup",
                        "requiredMinRep",
                        "requiredMaxRep"
                ) or {}
                local exclusiveTo = queryResult[1]
                local nextQuestInChain = queryResult[2]
                local parentQuest = queryResult[3]
                local preQuestSingle = queryResult[4]
                local preQuestGroup = queryResult[5]
                local requiredMinRep = queryResult[6]
                local requiredMaxRep = queryResult[7]

                -- Exclusive quests will never be available since another quests permanently blocks them.
                -- Marking them as complete should be the most satisfying solution for user
                if (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
                    tinsert(zoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- The parent quest has been completed
                elseif parentQuest and Questie.db.char.complete[parentQuest] then
                    tinsert(zoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- Unoptainable reputation quests
                elseif not QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep) then
                    tinsert(zoneTree[5].children, temp)
                    unobtainableQuestIds[questId] = true
                    unobtainableCounter = unobtainableCounter + 1
                -- A single pre Quest is missing
                elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
                    -- The pre Quest is unobtainable therefore this quest is it as well
                    if unobtainableQuestIds[preQuestSingle] ~= nil then
                        tinsert(zoneTree[5].children, temp)
                        unobtainableQuestIds[questId] = true
                        unobtainableCounter = unobtainableCounter + 1
                    else
                        tinsert(zoneTree[2].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- Multiple pre Quests are missing
                elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
                    local hasUnobtainablePreQuest = false
                    for _, preQuestId in pairs(preQuestGroup) do
                        if unobtainableQuestIds[preQuestId] ~= nil then
                            tinsert(zoneTree[5].children, temp)
                            unobtainableQuestIds[questId] = true
                            unobtainableCounter = unobtainableCounter + 1
                            hasUnobtainablePreQuest = true
                            break
                        end
                    end

                    if not hasUnobtainablePreQuest then
                        tinsert(zoneTree[2].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- Repeatable quests
                elseif QuestieDB.IsRepeatable(questId) then
                    tinsert(zoneTree[4].children, temp)
                    repeatableCounter = repeatableCounter + 1
                -- Available quests
                else
                    tinsert(zoneTree[1].children, temp)
                    availableCounter = availableCounter + 1
                end
            end
            temp = {}
        end
    end

    local totalCounter = availableCounter + completedCounter + prequestMissingCounter
    zoneTree[1].text = zoneTree[1].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    zoneTree[2].text = zoneTree[2].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    zoneTree[3].text = zoneTree[3].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    zoneTree[4].text = zoneTree[4].text .. ' [ '..  repeatableCounter ..' ]'
    zoneTree[5].text = zoneTree[5].text .. ' [ '..  unobtainableCounter ..' ]'

    zoneTree.numquests = totalCounter + repeatableCounter + unobtainableCounter

    return zoneTree
end
