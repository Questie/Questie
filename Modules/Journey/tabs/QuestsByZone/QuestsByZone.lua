---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByZone = {}
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local AceGUI = LibStub("AceGUI-3.0")
local zoneTreeFrame = nil

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
            Questie:Debug(DEBUG_CRITICAL, "[zoneTreeFrame:OnClick]", "No tree path given in Journey.")
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

        ---@type QuestId
        questId = tonumber(questId)
        local quest = QuestieDB:GetQuest(questId)

        -- Add the quest to the open chat window if it was a shift click
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            if Questie.db.global.trackerShowQuestLevel then
                ChatEdit_InsertLink("[[" .. quest.level .. "] " .. quest.name .. " (" .. quest.Id .. ")]")
            else
                ChatEdit_InsertLink("[" .. quest.name .. " (" .. quest.Id .. ")]")
            end
        end

        _QuestieJourney:DrawQuestDetailsFrame(scrollFrame, quest)
    end)

    container:AddChild(zoneTreeFrame)
end

---Get all the available/completed/repeatable/unavailable quests
---@param zoneId integer @The zone ID (Check `LangZoneLookup`)
---@return table<integer,any> @The zoneTree table which represents the list of all the different quests
function _QuestieJourney.questsByZone:CollectZoneQuests(zoneId)
    local quests = QuestieJourney.zoneMap[zoneId]--QuestieDB:GetQuestsByZoneId(zoneId)

    if (not quests) then
        return nil
    end

    local temp = {}

    local zoneTree = {
        [1] = {
            value = "a",
            text = QuestieLocale:GetUIString('JOURNEY_AVAILABLE_TITLE'),
            children = {}
        },
        [2] = {
            value = "p",
            text = QuestieLocale:GetUIString('JOURNEY_PREQUEST_TITLE'),
            children = {}
        },
        [3] = {
            value = "c",
            text = QuestieLocale:GetUIString('JOURNEY_COMPLETE_TITLE'),
            children = {}
        },
        [4] = {
            value = "r",
            text = QuestieLocale:GetUIString('JOURNEY_REPEATABLE_TITLE'),
            children = {},
        },
        [5] = {
            value = "u",
            text = QuestieLocale:GetUIString('JOURNEY_UNOBTAINABLE_TITLE'),
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

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        ---@type QuestId
        local qId = levelAndQuest[2]
        -- Only show quests which are not hidden
        if QuestieCorrections.hiddenQuests and not QuestieCorrections.hiddenQuests[qId] and QuestieDB.QuestPointers[qId] then
            temp.value = qId
            temp.text = QuestieDB:GetColoredQuestName(qId)

            -- Completed quests
            if Questie.db.char.complete[qId] then
                tinsert(zoneTree[3].children, temp)
                completedCounter = completedCounter + 1
            else
                -- Exclusive quests will never be available since another quests permantly blocks them.
                -- Marking them as complete should be the most satisfying solution for user
                local exclusiveTo, parentQuest, preQuestSingle, preQuestGroup = unpack(QuestieDB.QueryQuest(qId, "exclusiveTo", "parentQuest", "preQuestSingle", "preQuestGroup"))
                if exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo) then
                    tinsert(zoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- The parent quest has been completed
                elseif parentQuest and Questie.db.char.complete[parentQuest] then
                    tinsert(zoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- Unoptainable profession quests
                elseif not QuestieProfessions:HasProfessionAndSkillLevel(QuestieDB.QueryQuestSingle(qId, "requiredSkill")) then
                    tinsert(zoneTree[5].children, temp)
                    unobtainableQuestIds[qId] = true
                    unobtainableCounter = unobtainableCounter + 1
                -- Unoptainable reputation quests
                elseif not QuestieReputation:HasReputation(unpack(QuestieDB.QueryQuest(qId, "requiredMinRep", "requiredMaxRep"))) then
                    tinsert(zoneTree[5].children, temp)
                    unobtainableQuestIds[qId] = true
                    unobtainableCounter = unobtainableCounter + 1
                -- A single pre Quest is missing
                elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
                    -- The pre Quest is unobtainable therefore this quest is it as well
                    if unobtainableQuestIds[preQuestSingle] ~= nil then
                        tinsert(zoneTree[5].children, temp)
                        unobtainableQuestIds[qId] = true
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
                            unobtainableQuestIds[qId] = true
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
                elseif QuestieDB:IsRepeatable(qId) then
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
