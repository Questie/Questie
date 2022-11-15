---@class MapTooltip
local MapTooltip = QuestieLoader:CreateModule("MapTooltip")

local QuestieQuest = QuestieLoader:ImportModule("QQuest")
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local l10n = QuestieLoader:ImportModule("l10n")
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")

local QuestXP = QuestieLoader:ImportModule("QuestXP")
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")

--Up value
---@type GameTooltip
local questieTooltip = QuestieTooltip --Localize the tooltip

-- Keeps track of the currently shown tooltip
-- Gets reset on each ResetTooltip call
local _drawnTooltips = {}

--? Unregister all events on hide and register draw and reset call for the tooltip.
do
    --- This is a hook for hide to remove callbacks for the tooltip
    local function Hide()
        SystemEventBus:ObjectUnregisterAll(questieTooltip)
    end

    hooksecurefunc(questieTooltip, "Hide", Hide);

    local function ResetTooltip()
        wipe(_drawnTooltips)
        questieTooltip:ClearLines()
        questieTooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR")
    end

    local function DrawTooltip()
        if IsShiftKeyDown() then
            questieTooltip:SetMinimumWidth(375)
        else
            questieTooltip:SetMinimumWidth(0)
        end
        questieTooltip:Show()
    end

    MapEventBus:RegisterRepeating(MapEventBus.events.RESET_TOOLTIP, ResetTooltip)
    MapEventBus:RegisterRepeating(MapEventBus.events.DRAW_TOOLTIP, DrawTooltip)

    -- --? We force a minimum width when shift is held down.
    -- local function ShiftPressed()
    --     printE("Tooltip Setting Minimum Width")
    --     questieTooltip:SetMinimumWidth(200)
    --     questieTooltip:SetWidth(500)
    -- end
    -- local function ShiftReleased()
    --     if (questieTooltip:GetMinimumWidth() ~= 0) then
    --         printE("Tooltip Resetting Minimum Width")
    --         questieTooltip:SetMinimumWidth(0)
    --     end
    -- end
    -- C_Timer.After(0, function()
    --     SystemEventBus:RegisterRepeating(SystemEventBus.events.MODIFIER_PRESSED_SHIFT,  ShiftPressed)
    --     SystemEventBus:RegisterRepeating(SystemEventBus.events.MODIFIER_RELEASED_SHIFT,  ShiftReleased)
    -- end)
end



do
    local REPUTATION_ICON_PATH = QuestieLib.AddonPath .. "Icons\\reputation.blp"
    local REPUTATION_ICON_TEXTURE = "|T" .. REPUTATION_ICON_PATH .. ":14:14:2:0|t" -- IconID: 236681

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
        local rewardString = ""

        if (shift) then
            local xpReward = QuestXP:GetQuestLogRewardXP(questId, Questie.db.global.showQuestXpAtMaxLevel)
            if xpReward > 0 then
                local questLevel = QuestieDB.QueryQuestSingle(questId, "questLevel")
                rewardString = QuestieLib:PrintDifficultyColor(questLevel, "(" .. FormatLargeNumber(xpReward) .. l10n('xp') .. ") ",
                                                               QuestieDB.IsRepeatable(questId))
            end

            local moneyReward = GetQuestLogRewardMoney(questId)
            if moneyReward > 0 then
                ---@diagnostic disable-next-line: param-type-mismatch
                local coinTextureString = GetCoinTextureString(moneyReward)
                rewardString = rewardString .. Questie:Colorize("(" .. coinTextureString .. ") ", "white")
            end
        end
        rewardString = rewardString .. questType

        --* Write the questName, coinTexture and questType
        local reputationReward = QuestieDB.QueryQuestSingle(questId, "reputationReward")
        local questNameString = ""
        if shift then
            questNameString = questName
        else
            if reputationReward and next(reputationReward) then
                questNameString = REPUTATION_ICON_TEXTURE .. " " .. questName
            else
                questNameString = TRANSPARENT_ICON_TEXTURE .. " " .. questName
            end
        end
        questieTooltip:AddDoubleLine(questNameString, rewardString, 1, 1, 1, 1, 1, 0);

        -- if (not shift) and reputationReward and next(reputationReward) then
        --     -- questieTooltip:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
        --     questieTooltip:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questName, rewardString, 1, 1, 1, 1, 1, 0);
        -- else
        --     if shift then
        --         questieTooltip:AddDoubleLine(questName, rewardString, 1, 1, 1, 1, 1, 0);
        --     else
        --         -- We use a transparent icon because this eases setting the correct margin
        --         -- questieTooltip:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
        --         questieTooltip:AddDoubleLine(TRANSPARENT_ICON_TEXTURE .. " " .. questName, rewardString, 1, 1, 1, 1, 1, 0);
        --     end
        -- end

        --* Write the quest description
        if (shift) then
            local questDescription = QuestieDB.QueryQuestSingle(questId, "objectivesText")
            if questDescription then
                local dataType = type(questDescription)
                if dataType == "table" then
                    for _, rawLine in pairs(questDescription) do
                        local lines = QuestieLib:TextWrap(rawLine, "  ", true, true, math.max(375, questieTooltip:GetWidth())) --275 is the default questlog width
                        for _, line in pairs(lines) do
                            questieTooltip:AddLine(line, 0.86, 0.86, 0.86);
                        end
                    end
                elseif dataType == "string" then
                    local lines = QuestieLib:TextWrap(questDescription, "  ", true, true, math.max(375, questieTooltip:GetWidth())) --275 is the default questlog width
                    for _, line in pairs(lines) do
                        questieTooltip:AddLine(line, 0.86, 0.86, 0.86);
                    end
                end
            end
        end

        if (shift) then
            if reputationReward and next(reputationReward) then
                local playerIsHuman = QuestiePlayer:GetRaceId() == 1
                local playerIsHonoredWithShaTar = (not QuestieReputation:HasReputation(nil, { 935, 8999 }))
                local rewardTable = {}
                local factionId, factionName
                local rewardValue
                local aldorPenalty, scryersPenalty
                for _, rewardPair in pairs(reputationReward) do
                    factionId = rewardPair[1]

                    if factionId == 935 and playerIsHonoredWithShaTar and (scryersPenalty or aldorPenalty) then
                        -- Quests for Aldor and Scryers gives reputation to the Sha'tar but only before being Honored
                        -- with the Sha'tar
                        break
                    end

                    factionName = GetFactionInfoByID(factionId)
                    if factionName then
                        rewardValue = rewardPair[2]

                        if playerIsHuman and rewardValue > 0 then
                            -- Humans get 10% more reputation
                            rewardValue = math.floor(rewardValue * 1.1)
                        end

                        if factionId == 932 then -- Aldor
                            scryersPenalty = 0 - math.floor(rewardValue * 1.1)
                        elseif factionId == 934 then -- Scryers
                            aldorPenalty = 0 - math.floor(rewardValue * 1.1)
                        end

                        rewardTable[#rewardTable + 1] = (rewardValue > 0 and "+" or "") .. rewardValue .. " " .. factionName
                    end
                end

                if aldorPenalty then
                    factionName = GetFactionInfoByID(932)
                    rewardTable[#rewardTable + 1] = aldorPenalty .. " " .. factionName
                elseif scryersPenalty then
                    factionName = GetFactionInfoByID(934)
                    rewardTable[#rewardTable + 1] = scryersPenalty .. " " .. factionName
                end

                questieTooltip:AddLine(REPUTATION_ICON_TEXTURE .. " " .. Questie:Colorize(table.concat(rewardTable, " / "), "reputationBlue"), 1, 1, 1, 1)
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

            if not _drawnTooltips[giverName] then
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
                        _drawnTooltips[questId] = true
                    end
                end
                if ShowData.available then
                    for questId in pairs(ShowData.available) do
                        writeQuestRelations(questId)
                        _drawnTooltips[questId] = true
                    end
                end

                _drawnTooltips[giverName] = true
            end
        end
    end
end
