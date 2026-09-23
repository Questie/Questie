---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");

local GetItemInfo = QuestieCompat.GetItemInfo

--[i_1337][playerName][questId] = objective
local commsTooltipLookup = {}

--[playerName] = {
    --[questId] = {["i_1337"]=true,["o_1338"]=true,}
--}
local playerRegisteredTooltips = {}

---@param tooltipKey string @A key in the form of "i_1337"
---@return boolean @true if exist false if not
function QuestieComms.data:KeyExists(tooltipKey)
    if commsTooltipLookup[tooltipKey] then
        return true;
    else
        return false;
    end
end

---Builds remote objective rows for an entity key; callers must check KeyExists first.
---Returns available wording immediately. Loading callbacks can update the returned rows later,
---but do not refresh strings a tooltip has already rendered.
---@param tooltipKey string @A key in the form of "i_1337"
---@return table @tooltipData[questId][playerName][objectiveIndex].text
function QuestieComms.data:GetTooltip(tooltipKey)
    local tooltipData = {}
    for playerName, questData in pairs(commsTooltipLookup[tooltipKey]) do
        for questId, objectives in pairs(questData) do
            if(not tooltipData[questId]) then
                tooltipData[questId] = {};
            end
            if(not tooltipData[questId][playerName]) then
                tooltipData[questId][playerName] = {};
            end
            -- Prefer Blizzard's wording, even when this quest is absent from our own quest log.
            local questObjectives = QuestieLib.GetLoadedQuestObjectives(questId)
            for objectiveIndex, objective in pairs(objectives) do
                if(not tooltipData[questId][playerName][objectiveIndex]) then
                    tooltipData[questId][playerName][objectiveIndex] = {};
                end

                -- Wording comes from quest data; progress must remain the remote player's comms values.
                local row = tooltipData[questId][playerName][objectiveIndex]
                local questObjective = questObjectives and questObjectives[objectiveIndex]
                if questObjective then
                    -- Keep the full instruction; only remove the API's local-player progress counters.
                    local text = QuestieLib.GetFullObjectiveText(questObjective.text) or questObjective.text
                    row.text = text ~= "" and text or nil
                end
                row.fulfilled = objective.fulfilled
                row.required = objective.required

                if not row.text then
                    -- Use entity names as interim text while the quest wording loads.
                    ---@type (fun(): boolean)?
                    local itemCallbackCancel

                    if (not row.text) and (objective.type == "monster" or objective.type == "m") and objective.id then
                        local npc = QuestieDB:GetNPC(objective.id)
                        row.text = npc and npc.name
                    elseif (not row.text) and (objective.type == "object" or objective.type == "o") and objective.id then
                        local object = QuestieDB:GetObject(objective.id)
                        row.text = object and object.name
                    elseif (not row.text) and (objective.type == "item" or objective.type == "i") and objective.id then
                        local dbItem = QuestieDB:GetItem(objective.id);
                        if(dbItem and dbItem.name and (not dbItem.Hidden)) then
                            row.text = dbItem.name;
                        else
                            -- Missing or hidden DB item: try the client cache, then request its name.
                            local itemName = GetItemInfo(objective.id)
                            if(itemName) then
                                row.text = itemName;
                            else
                                row.text = "Item missing from DB, fetching from server!";
                                local item = Item:CreateFromItemID(objective.id)
                                itemCallbackCancel = item:ContinueWithCancelOnItemLoad(function()
                                    row.text = item:GetItemName() or row.text
                                end)
                            end
                        end
                    end

                    -- Upgrade this returned row when quest text arrives; timeout leaves the fallback intact.
                    QuestieLib.ContinueOnQuestObjectivesLoad(questId, function(loadedObjectives)
                        local questObjective = loadedObjectives[objectiveIndex]
                        if questObjective then
                            local text = QuestieLib.GetFullObjectiveText(questObjective.text) or questObjective.text
                            if text ~= nil and text ~= "" then
                                -- A late item-name callback must not overwrite valid API wording.
                                if itemCallbackCancel then
                                    itemCallbackCancel()
                                end
                                row.text = text
                            end
                        end
                    end)
                end
                -- Tooltip consumers concatenate this field even when neither source supplies a name.
                row.text = row.text or ""
            end
        end
    end
    return tooltipData;
end

---@param questId number
---@param playerName string
---@param objectives table @Contains objectives o[index].text
function QuestieComms.data:RegisterTooltip(questId, playerName, objectives)
    if(not playerRegisteredTooltips[playerName]) then
        playerRegisteredTooltips[playerName] = {}
    end
    if(not playerRegisteredTooltips[playerName][questId]) then
        playerRegisteredTooltips[playerName][questId] = {}
    end
    for objectiveIndex, objective in pairs(objectives) do
        if (objective.type and objective.id) then
            local lookupKey = objective.type .. "_" .. objective.id;

            -- Item Objective
            if(objective.type == "i") then
                local item = QuestieDB:GetItem(objective.id);
                if item and not item.Hidden then
                    -- Show this item objective when hovering entities that can provide the item.
                    for _, source in pairs(item.Sources or {}) do
                        local sourceType = string.sub(source.Type, 1, 1);
                        local sourceId = source.Id;
                        local sourceLookupKey = sourceType.."_"..sourceId;
                        QuestieComms.data:AddTooltip(playerName, questId, sourceLookupKey, objectiveIndex, objective);
                    end
                end

                -- Show this objective when hovering the item itself.
                QuestieComms.data:AddTooltip(playerName, questId, lookupKey, objectiveIndex, objective);
            else
                -- Show non-item objectives when hovering their direct objective entity.
                QuestieComms.data:AddTooltip(playerName, questId, lookupKey, objectiveIndex, objective);
            end
        end
    end

    -- Prime Blizzard's cache before the first hover; GetTooltip reads and validates the result later.
    C_QuestLog.GetQuestObjectives(questId)
    C_Timer.After(0.2, function()
        C_QuestLog.GetQuestObjectives(questId)
    end)
end

function QuestieComms.data:AddTooltip(playerName, questId, lookupKey, objectiveIndex, data)
    if(not commsTooltipLookup[lookupKey]) then
        commsTooltipLookup[lookupKey] = {}
    end
    if(not commsTooltipLookup[lookupKey][playerName]) then
        commsTooltipLookup[lookupKey][playerName] = {};
    end
    if(not commsTooltipLookup[lookupKey][playerName][questId]) then
        commsTooltipLookup[lookupKey][playerName][questId] = {};
    end
    commsTooltipLookup[lookupKey][playerName][questId][objectiveIndex] = data;

    playerRegisteredTooltips[playerName][questId][lookupKey] = true;
end

--Totally removes a player from the tooltip lookups
function QuestieComms.data:RemovePlayer(playerName)
    for questId, tooltipList in pairs(playerRegisteredTooltips[playerName] or {}) do
        QuestieComms.data:RemoveQuestFromPlayer(questId, playerName);
    end
    if(playerRegisteredTooltips[playerName]) then
        playerRegisteredTooltips[playerName] = nil;
    end
end

function QuestieComms.data:RemoveQuestFromPlayer(questId, playerName)
    --First check if the player exists and if it has tooltip related quests.
    if(playerRegisteredTooltips[playerName] and playerRegisteredTooltips[playerName][questId]) then
        --Loop through the tooltips to find which should be removed
        for tooltip, active in pairs(playerRegisteredTooltips[playerName][questId]) do
            --Check if the registered tooltip exists and if the player exists in it.
            if(commsTooltipLookup[tooltip] and commsTooltipLookup[tooltip][playerName]) then
                --Does the questId we want to remove exist?
                if(commsTooltipLookup[tooltip][playerName][questId]) then
                    --Remove questID
                    commsTooltipLookup[tooltip][playerName][questId] = nil;
                    --Do we not have any quests left in the tooltip? If not remove it
                    if(QuestieLib:Count(commsTooltipLookup[tooltip][playerName]) == 0) then
                        commsTooltipLookup[tooltip][playerName] = nil;
                        --Are there any other players with this tooltip registered? If not remove it.
                        if(QuestieLib:Count(commsTooltipLookup[tooltip]) == 0) then
                            commsTooltipLookup[tooltip] = nil;
                        end
                    end
                end
            end
        end
        playerRegisteredTooltips[playerName][questId] = nil;
    end
end

-- Resets everything.
function QuestieComms.data:ResetAll()
    commsTooltipLookup = {}
    playerRegisteredTooltips = {}
end
