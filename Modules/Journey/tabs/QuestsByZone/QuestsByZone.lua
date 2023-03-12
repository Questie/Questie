---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByZone = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
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
    local quests = QuestieJourney.zoneMap[zoneId]
    return QuestieJourneyUtils:CollectQuests(quests)
end
