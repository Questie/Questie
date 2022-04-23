---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByFaction = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")
local factionTreeFrame

---Manage the zone tree itself and the contents of the per-quest window
---@param container AceSimpleGroup @The container for the zone tree
---@param factionTree table @The zone tree table
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

    factionTreeFrame.treeframe:SetWidth(220)
    factionTreeFrame:SetCallback("OnClick", function(group, ...)
        local treePath = {...}

        if not treePath[2] then
            Questie:Debug(Questie.DEBUG_CRITICAL, "[factionTreeFrame:OnClick]", "No tree path given in Journey.")
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

    container:AddChild(factionTreeFrame)
end

---Get all the available/completed/repeatable/unavailable quests
---@param faction number @The faction ID (Check `l10n.factionLookup`)
---@return table<number,any> @The factionTree table which represents the list of all the different quests
function _QuestieJourney.questsByFaction:CollectFactionQuests(factionId)
    local quests = QuestieJourney.factionMap[factionId]
    return QuestieJourneyUtils:CollectQuests(quests)
end
