---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.questsByZone = {}
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local AceGUI = LibStub("AceGUI-3.0")
local zoneTreeFrame = nil

-- Manage the zone tree itself and the contents of the per-quest window
function _QuestieJourney.questsByZone:ManageTree(container, zt)
    if not zoneTreeFrame then
        zoneTreeFrame = AceGUI:Create("TreeGroup");
        zoneTreeFrame:SetFullWidth(true);
        zoneTreeFrame:SetFullHeight(true);
        zoneTreeFrame:SetTree(zt);

        zoneTreeFrame.treeframe:SetWidth(220);

        zoneTreeFrame:SetCallback("OnGroupSelected", function(group)

            -- if they clicked on the header, don't do anything
            local sel = group.localstatus.selected;
            if sel == "a" or sel == "c" or sel == "r" or sel == "u" then
                return;
            end

            -- get master frame and create scroll frame inside
            local master = group.frame.obj;
            master:ReleaseChildren();
            master:SetLayout("fill");
            master:SetFullWidth(true);
            master:SetFullHeight(true);

            ---@class ScrollFrame
            local scrollFrame = AceGUI:Create("ScrollFrame");
            scrollFrame:SetLayout("flow");
            scrollFrame:SetFullHeight(true);
            master:AddChild(scrollFrame);

            local _, qid = strsplit("\001", sel);
            qid = tonumber(qid);

            -- TODO replace with fillQuestDetailsFrame and remove the questFrame function
            local quest = QuestieDB:GetQuest(qid);
            if quest then
                _QuestieJourney:DrawQuestDetailsFrame(scrollFrame, quest);
            end
        end);

        container:AddChild(zoneTreeFrame);

    else
        container:ReleaseChildren();
        zoneTreeFrame = nil;
        _QuestieJourney.questsByZone:ManageTree(container, zt);
    end
end
