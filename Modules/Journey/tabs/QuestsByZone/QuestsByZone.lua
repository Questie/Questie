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

local AceGUI = LibStub("AceGUI-3.0")
local zoneTreeFrame = nil

-- Manage the zone tree itself and the contents of the per-quest window
function _QuestieJourney.questsByZone:ManageTree(container, zt)
    if zoneTreeFrame then
        container:ReleaseChildren()
        zoneTreeFrame = nil
        _QuestieJourney.questsByZone:ManageTree(container, zt)
        return
    end

    zoneTreeFrame = AceGUI:Create("TreeGroup")
    zoneTreeFrame:SetFullWidth(true)
    zoneTreeFrame:SetFullHeight(true)
    zoneTreeFrame:SetTree(zt)

    zoneTreeFrame.treeframe:SetWidth(220)

    zoneTreeFrame:SetCallback("OnGroupSelected", function(group)

        -- if they clicked on a header, don't do anything
        local sel = group.localstatus.selected
        if sel == "a" or sel == "c" or sel == "r" or sel == "u" then
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

        local _, qid = strsplit("\001", sel)
        qid = tonumber(qid)

        -- TODO replace with fillQuestDetailsFrame and remove the questFrame function
        local quest = QuestieDB:GetQuest(qid)
        if quest then
            _QuestieJourney:DrawQuestDetailsFrame(scrollFrame, quest)
        end
    end)

    container:AddChild(zoneTreeFrame)
end

-- Get all the available/completed/repeatable/unavailable quests

---@param zoneId integer @The zone ID (Check `LangZoneLookup`)
---@return table<integer,any> @The zoneTree table which represents the list of all the different quests
function _QuestieJourney.questsByZone:CollectZoneQuests(zoneId)
    local quests = QuestieDB:GetQuestsByZoneId(zoneId)
    local temp = {}

    local zoneTree = {
        [1] = {
            value = "a",
            text = QuestieLocale:GetUIString('JOURNEY_AVAILABLE_TITLE'),
            children = {}
        },
        [2] = {
            value = "c",
            text = QuestieLocale:GetUIString('JOURNEY_COMPLETE_TITLE'),
            children = {}
        },
        [3] = {
            value = "r",
            text = QuestieLocale:GetUIString('JOURNEY_REPEATABLE_TITLE'),
            children = {},
        },
        [4] = {
            value = "u",
            text = QuestieLocale:GetUIString('JOURNEY_UNOBTAINABLE_TITLE'),
            children = {},
        }
    }

    local sortedQuestByLevel = QuestieLib:SortQuestsByLevel(quests)

    local availableCounter = 0
    local completedCounter = 0
    local unobtainableCounter = 0
    local repeatableCounter = 0

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local quest = levelAndQuest[2]
        local qId = quest.Id

        -- Only show quests which are not hidden
        if not quest.isHidden and QuestieCorrections.hiddenQuests and not QuestieCorrections.hiddenQuests[qId] then
            temp.value = qId
            temp.text = quests[qId]:GetColoredQuestName()

            -- Completed quests
            if Questie.db.char.complete[qId] then
                tinsert(zoneTree[2].children, temp)
                completedCounter = completedCounter + 1
            else
                -- Exclusive quests will never be available since another quests blocks them. Marking them as complete
                -- should be the most satisfying solution for user
                if quest.exclusiveTo then
                    for _, exId in pairs(quest.exclusiveTo) do
                        if Questie.db.char.complete[exId] and zoneTree[4].children[qId] == nil then
                            tinsert(zoneTree[2].children, temp)
                            completedCounter = completedCounter + 1
                        end
                    end
                -- Unoptainable profession quests
                elseif not QuestieProfessions:HasProfessionAndSkill(quest.requiredSkill) then
                    tinsert(zoneTree[4].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Unoptainable reputation quests
                elseif not QuestieReputation:HasReputation(quest.requiredMinRep, quest.requiredMaxRep) then
                    tinsert(zoneTree[4].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Repeatable quests
                elseif quest.Repeatable then
                    tinsert(zoneTree[3].children, temp)
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

    local totalCounter = availableCounter + completedCounter
    zoneTree[1].text = zoneTree[1].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    zoneTree[2].text = zoneTree[2].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    zoneTree[3].text = zoneTree[3].text .. ' [ '..  repeatableCounter ..' ]'
    zoneTree[4].text = zoneTree[4].text .. ' [ '..  unobtainableCounter ..' ]'

    return zoneTree
end