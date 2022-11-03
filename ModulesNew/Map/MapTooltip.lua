---@class MapTooltip
local MapTooltip = QuestieLoader:CreateModule("MapTooltip")

local QuestieQuest = QuestieLoader:ImportModule("QQuest")
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local l10n = QuestieLoader:ImportModule("l10n")
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")

--Up value
local questieTooltip = QuestieTooltip --Localize the tooltip

--? Unregister all events on hide and register draw and reset call for the tooltip.
do
    --- This is a hook for hide to remove callbacks for the tooltip
    local function Hide()
        SystemEventBus:ObjectUnregisterAll(questieTooltip)
    end

    hooksecurefunc(questieTooltip, "Hide", Hide);

    local function ResetTooltip()
        questieTooltip:ClearLines()
        questieTooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR")
    end

    local function DrawTooltip()
        questieTooltip:Show()
    end

    MapEventBus:RegisterRepeating(MapEventBus.events.TOOLTIP.RESET_TOOLTIP, ResetTooltip)
    MapEventBus:RegisterRepeating(MapEventBus.events.TOOLTIP.DRAW_TOOLTIP, DrawTooltip)
end



do
    local REPUTATION_ICON_PATH = QuestieLib.AddonPath .. "Icons\\reputation.blp"
    local REPUTATION_ICON_TEXTURE = "|T" .. REPUTATION_ICON_PATH .. ":14:14:2:0|t"

    local TRANSPARENT_ICON_PATH = "Interface\\Minimap\\UI-bonusobjectiveblob-inside.blp"
    local TRANSPARENT_ICON_TEXTURE = "|T" .. TRANSPARENT_ICON_PATH .. ":14:14:2:0|t"

    local function getType(questId)
        local type = ""
        if QuestieDB.IsComplete(questId) == 1 then
            type = "(" .. l10n("Complete") .. ")";
        else

            local questType, questTag = QuestieDB.GetQuestTagInfo(questId)

            if (QuestieDB.IsRepeatable(questId)) then
                type = "(" .. l10n("Repeatable") .. ")";
            elseif (questType == 41 or questType == 81 or questType == 83 or questType == 62 or questType == 1) then
                -- Dungeon or Legendary or Raid or Group(Elite)
                type = "(" .. questTag .. ")";
            elseif (QuestieEvent and QuestieEvent.activeQuests[questId]) then
                type = "(" .. l10n("Event") .. ")";
            else
                type = "(" .. l10n("Available") .. ")";
            end
        end
        local coloredTitle = QuestieLib:GetColoredQuestName(questId, Questie.db.global.enableTooltipsQuestLevel, false, true)

        return coloredTitle, type
    end

    local function writeQuestRelations(questId)
        local shift = IsShiftKeyDown()
        local questName, questType = getType(questId)
        local reputationReward = QuestieDB.QueryQuestSingle(questId, "reputationReward")
        local rewardString = questType
        if (not shift) and reputationReward and next(reputationReward) then
            -- questieTooltip:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
            questieTooltip:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questName, rewardString, 1, 1, 1, 1, 1, 0);
        else
            if shift then
                questieTooltip:AddDoubleLine(questName, rewardString, 1, 1, 1, 1, 1, 0);
            else
                -- We use a transparent icon because this eases setting the correct margin
                -- questieTooltip:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                questieTooltip:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " .. questName, rewardString, 1, 1, 1, 1, 1, 0);
            end
        end
    end

    ---comment
    ---@param id NpcId
    ---@param idType RelationPointType
    function MapTooltip.SimpleAvailableTooltip(id, idType, ShowData)
        --- TODO: This function is not finished, currently barebones and should probably be rewritten.
        local shift = IsShiftKeyDown()
        local firstLine = questieTooltip:NumLines() == 0
        if ShowData then
            local giverName
            if idType == "npc" or idType == "npcFinisher" then
                giverName = QuestieDB.QueryNPCSingle(id, "name")
            elseif idType == "object" or idType == "objectFinisher" then
                giverName = QuestieDB.QueryObjectSingle(id, "name")
            elseif idType == "item" then
                giverName = QuestieDB.QueryItemSingle(id, "name")
            end

            if shift and (not firstLine) then
                -- Spacer between NPCs
                questieTooltip:AddLine("             ")
            end
            if (firstLine and not shift) then
                questieTooltip:AddDoubleLine(giverName, "(" .. l10n('Hold Shift') .. ")", 0.2, 1, 0.2, 0.43, 0.43, 0.43);
            elseif (firstLine and shift) then
                questieTooltip:AddLine(giverName, 0.2, 1, 0.2);
            else
                questieTooltip:AddLine(giverName, 0.2, 1, 0.2);
            end
            if ShowData.finisher then
                for questId in pairs(ShowData.finisher) do
                    writeQuestRelations(questId)
                end
            end
            if ShowData.available then
                for questId in pairs(ShowData.available) do
                    writeQuestRelations(questId)
                end
            end
        end
    end
end
