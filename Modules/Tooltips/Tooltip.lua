---@class QuestieTooltips
local QuestieTooltips = QuestieLoader:CreateModule("QuestieTooltips");
local _QuestieTooltips = QuestieTooltips.private
-------------------------
--Import modules.
-------------------------
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local tinsert = table.insert
QuestieTooltips.lastGametooltip = ""
QuestieTooltips.lastGametooltipCount = -1;
QuestieTooltips.lastGametooltipType = "";
QuestieTooltips.lastFrameName = "";

QuestieTooltips.lookupByKey = {
    --["u_Grell"] = {questid, {"Line 1", "Line 2"}}
}
QuestieTooltips.lookupKeysByQuestId = {
    --["questId"] = {"u_Grell", ... }
}

local MAX_GROUP_MEMBER_COUNT = 6

local _InitObjectiveTexts

--[[
IMPORTANT!
If you change the way the tooltip keys are structured and/or the return value of GetTooltip,
we need to let the Plater addon devs know about it.
--]]

---@param questId number
---@param key string monster: m_, items: i_, objects: o_ + string name of the objective
---@param objective table
function QuestieTooltips:RegisterObjectiveTooltip(questId, key, objective)
    if not QuestieTooltips.lookupByKey[key] then
        QuestieTooltips.lookupByKey[key] = {};
    end
    if not QuestieTooltips.lookupKeysByQuestId[questId] then
        QuestieTooltips.lookupKeysByQuestId[questId] = {}
    end
    local tooltip = {
        questId = questId,
        objective = objective,
    };
    QuestieTooltips.lookupByKey[key][tostring(questId) .. " " .. objective.Index] = tooltip
    tinsert(QuestieTooltips.lookupKeysByQuestId[questId], key)
end

---@param questId number
---@param name string The name of the object or NPC the tooltip should show on
---@param starterId number The ID of the object or NPC the tooltip should show on
---@param key string @Either m_<npcId> or o_<objectId>
---@param type string Indicates the type of quest starter; this changes icon in tooltip
function QuestieTooltips:RegisterQuestStartTooltip(questId, name, starterId, key, type)
    if not QuestieTooltips.lookupByKey[key] then
        QuestieTooltips.lookupByKey[key] = {};
    end
    if not QuestieTooltips.lookupKeysByQuestId[questId] then
        QuestieTooltips.lookupKeysByQuestId[questId] = {}
    end
    local tooltip = {
        questId = questId,
        name = name,
        starterId = starterId,
        type = type,
    };
    QuestieTooltips.lookupByKey[key][tostring(questId) .. " " .. name .. " " .. starterId] = tooltip
    tinsert(QuestieTooltips.lookupKeysByQuestId[questId], key)
end

---@param questId number
function QuestieTooltips:RemoveQuest(questId)
    if (not QuestieTooltips.lookupKeysByQuestId[questId]) then
        -- Tooltip has already been removed
        return
    end

    -- Remove tooltip related keys from quest table so that
    -- it can be readded/registered by other quest functions.
    local quest = QuestieDB.GetQuest(questId)

    if quest then
        for _, objective in pairs(quest.Objectives) do
            objective.hasRegisteredTooltips = false
            objective.registeredItemTooltips = false
        end

        for _, objective in pairs(quest.SpecialObjectives) do
            objective.hasRegisteredTooltips = false
            objective.registeredItemTooltips = false
        end
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieTooltips:RemoveQuest]", questId)

    for _, key in pairs(QuestieTooltips.lookupKeysByQuestId[questId] or {}) do
        --Count to see if we should remove the main object
        local totalCount = 0
        local totalRemoved = 0
        for _, tooltipData in pairs(QuestieTooltips.lookupByKey[key] or {}) do
            --Remove specific quest
            if (tooltipData.questId == questId and tooltipData.objective) then
                QuestieTooltips.lookupByKey[key][tostring(tooltipData.questId) .. " " .. tooltipData.objective.Index] = nil
                totalRemoved = totalRemoved + 1
            elseif (tooltipData.questId == questId and tooltipData.name) then
                QuestieTooltips.lookupByKey[key][tostring(tooltipData.questId) .. " " .. tooltipData.name .. " " .. tooltipData.starterId] = nil
                totalRemoved = totalRemoved + 1
            end
            totalCount = totalCount + 1
        end
        if (totalCount == totalRemoved) then
            QuestieTooltips.lookupByKey[key] = nil
        end
    end

    QuestieTooltips.lookupKeysByQuestId[questId] = nil
end

-- This function contains the rules for formatting text for drop rate tooltips.
---@param rate number
---@return string
local function FormatDropText(rate)
    if rate >= 10 then
        return string.format("%.0f", rate)
    elseif rate >= 2 then
        return string.format("%.1f", rate)
    elseif rate >= 0.01 then
        return string.format("%.2f", rate)
    else
        return string.format("%.3f", rate)
    end
end

-- This code is related to QuestieComms, here we fetch all the tooltip data that exist in QuestieCommsData
-- It uses a similar system like here with i_ID etc as keys.
local function _FetchTooltipsForGroupMembers(key, tooltipData)
    local anotherPlayer = false;
    if QuestieComms.data:KeyExists(key) then
        ---@tooltipData @tooltipData[questId][playerName][objectiveIndex].text
        local tooltipDataExternal = QuestieComms.data:GetTooltip(key);
        for questId, playerList in pairs(tooltipDataExternal) do
            if (not tooltipData[questId]) then
                tooltipData[questId] = {
                    title = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true)
                }
            end
            for playerName, _ in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                if playerInfo or QuestieComms.remotePlayerEnabled[playerName] then
                    anotherPlayer = true
                    break
                end
            end
            if anotherPlayer then
                break
            end
        end
    end

    if QuestieComms.data:KeyExists(key) and anotherPlayer then
        ---@tooltipData @tooltipData[questId][playerName][objectiveIndex].text
        local tooltipDataExternal = QuestieComms.data:GetTooltip(key);
        for questId, playerList in pairs(tooltipDataExternal) do
            if (not tooltipData[questId]) then
                tooltipData[questId] = {
                    title = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true)
                }
            end
            for playerName, objectives in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                if playerInfo or QuestieComms.remotePlayerEnabled[playerName] then
                    anotherPlayer = true;
                    for objectiveIndex, objective in pairs(objectives) do
                        if (not objective) then
                            objective = {}
                        end

                        tooltipData[questId].objectivesText = _InitObjectiveTexts(tooltipData[questId].objectivesText, objectiveIndex, playerName)

                        local text;
                        local color = QuestieLib:GetRGBForObjective(objective)

                        if objective.required then
                            text = "   " .. color .. tostring(objective.fulfilled) .. "/" .. tostring(objective.required) .. " " .. objective.text;
                        else
                            text = "   " .. color .. objective.text;
                        end

                        tooltipData[questId].objectivesText[objectiveIndex][playerName] = { ["color"] = color, ["text"] = text };
                    end
                end
            end
        end
    end
    return anotherPlayer
end

---@param key string
---@param playerZone AreaId|nil @Only needed for object tooltips, otherwise it can be nil. 0 disables the zone filter
---@return table<number, string>|nil tooltipLines
function QuestieTooltips.GetTooltip(key, playerZone)
    Questie.Debug(Questie.DEBUG_SPAM, "[QuestieTooltips.GetTooltip]", key)
    if (not key) then
        return nil
    end

    if QuestiePlayer.numberOfGroupMembers > MAX_GROUP_MEMBER_COUNT then
        return nil -- temporary disable tooltips in raids, we should make a proper fix
    end

    -- Something calls this method with table, perhaps a bad interaction with Plater? /tanoh 2024-08-29
    if type(key) ~= "string" then
        return nil
    end

    -- Most provider name matches have no quest lines. Avoid reading their spawn tables just to
    -- discover that neither the local registry nor Comms has anything to show.
    if not QuestieTooltips.lookupByKey[key] and not (IsInGroup() and QuestieComms.data:KeyExists(key)) then
        return nil
    end

    local isObjectTooltip = key:sub(1, 2) == "o_"
    if isObjectTooltip then
        -- We want to only show object tooltips for objects that are in the current player zone.
        -- Otherwise quests from Wanted! posters and Midsummer Bonfires will show up incorrectly.
        local objectIsInCurrentZone = false
        if playerZone == 0 then
            objectIsInCurrentZone = true
        elseif (not playerZone) then
            Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieTooltips.GetTooltip] was called without a playerZone for objects")
            objectIsInCurrentZone = true
        else
            local objectId = tonumber(key:sub(3))
            local spawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
            if spawns and next(spawns) then
                -- Dungeon floors and sub areas report their own AreaId while objects are usually
                -- listed under the dungeon or zone itself, so the parent zone counts as a match too.
                local parentZone = ZoneDB:GetParentZoneId(playerZone)
                for zoneId in pairs(spawns) do
                    if zoneId == playerZone or zoneId == parentZone then
                        objectIsInCurrentZone = true
                        break
                    end
                end
            else
                -- No spawn data at all, so there is nothing to compare the zone against
                objectIsInCurrentZone = true
            end
        end

        if (not objectIsInCurrentZone) then
            return nil
        end
    end

    --Do not remove! This is the datastrucutre for tooltipData!
    --[[tooltipdata[questId] = {
        title = coloredTitle,
        objectivesText = {
            [objectiveIndex] = {
                [playerName] = {
                    [color] = color,
                    [text] = text
                }
            }
        }
    }]]
    --
    local tooltipData = {}
    local tooltipLines

    if QuestieTooltips.lookupByKey[key] then
        tooltipLines = {}
        local playerName = UnitName("player")

        local finishedAndUnacceptedQuests = {}
        if Questie.db.profile.showQuestsInNpcTooltip then
            -- We built a table of all quests in the tooltip that can be accepted or turned in, to not show the objectives for those
            -- and also don't add the quest title twice.
            for _, tooltip in pairs(QuestieTooltips.lookupByKey[key]) do
                if tooltip.name then
                    finishedAndUnacceptedQuests[tooltip.questId] = true
                end
            end
        end

        for k, tooltip in pairs(QuestieTooltips.lookupByKey[key]) do
            local questId = tooltip.questId

            if tooltip.name then
                if Questie.db.profile.showQuestsInNpcTooltip then
                    local questString = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true)
                    if tooltip.type then
                        local level, _ = QuestieLib.GetEffectiveQuestLevel(questId)
                        local colorText
                        if QuestieEvent.IsEventQuest(questId) then
                            colorText = ":108:227:20"
                        elseif QuestieDB.IsPvPQuest(questId) then
                            colorText = ":227:86:57"
                        elseif QuestieDB.IsRepeatable(questId) then
                            colorText = ":33:204:231"
                        else -- normal quest, use leveled colors
                            local r, g, b = QuestieLib:GetDifficultyColorPercent(level)
                            colorText = ":" .. tostring(math.floor(r * 255)) .. ":" .. tostring(math.floor(g * 255)) .. ":" .. tostring(math.floor(b * 255))
                        end
                        if tooltip.type == "NPC" then
                            questString = "|TInterface\\Addons\\Questie\\Icons\\tooltip_available.png:14:14:0:0:32:32:0:32:0:32" .. colorText .. "|t" .. questString
                        elseif tooltip.type == "Finisher" then
                            questString = "|TInterface\\Addons\\Questie\\Icons\\tooltip_complete.png:14:14:0:0:32:32:0:32:0:32" .. colorText .. "|t" .. questString
                        elseif tooltip.type == "itemFromMonster" or tooltip.type == "itemFromObject" then
                            questString = "|TInterface\\Addons\\Questie\\Icons\\available_mobdrop.png:14|t" .. questString
                        elseif tooltip.type == "Object" then
                            questString = "|TInterface\\Addons\\Questie\\Icons\\available_object.png:14|t" .. questString
                        end
                    end
                    tinsert(tooltipLines, questString)
                end
            elseif (not finishedAndUnacceptedQuests[questId]) then
                local objective = tooltip.objective
                if not (objective.IsSourceItem or objective.IsRequiredSourceItem) then
                    -- Tooltip was registered for a real "objective" and not for a sourceItem or requiredSourceItem
                    objective:Update()
                end
                local objectiveIndex = objective.Index;
                if (not tooltipData[questId]) then
                    tooltipData[questId] = {
                        title = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true)
                    }
                end
                if not QuestiePlayer.currentQuestlog[questId] then
                    -- TODO: Is this still required?
                    QuestieTooltips.lookupByKey[key][k] = nil
                else
                    tooltipData[questId].objectivesText = _InitObjectiveTexts(tooltipData[questId].objectivesText, objectiveIndex, playerName)
                    local text;
                    local color = QuestieLib:GetRGBForObjective(objective)

                    local npcId = tonumber(key:sub(3))
                    local objectiveId = objective.Id
                    if objective.Type == "spell" and objective.spawnList[npcId].ItemId then
                        text = "   " .. color .. tostring(QuestieDB.QueryItemSingle(objective.spawnList[npcId].ItemId, "name"));
                        tooltipData[questId].objectivesText[objectiveIndex][playerName] = { ["color"] = color, ["text"] = text };
                    else
                        local dropIcon, dropRateText = "", ""
                        local dropRateData = QuestieDB.GetItemDroprate(objectiveId, npcId)
                        if dropRateData and dropRateData[1] and Questie.db.profile.enableTooltipDroprates then
                            if Questie.db.profile.debugEnabled and dropRateData and dropRateData[2] then
                                if dropRateData[2] == "cmangos" then
                                    dropIcon = "|TInterface\\Addons\\Questie\\Icons\\cmangos.png:10|t "
                                elseif dropRateData[2] == "mangos3" then
                                    dropIcon = "|TInterface\\Addons\\Questie\\Icons\\mangos3.png:12|t "
                                elseif dropRateData[2] == "wowhead" then
                                    dropIcon = "|TInterface\\Addons\\Questie\\Icons\\wowhead.png:12|t "
                                elseif dropRateData[2] == "questie" then
                                    dropIcon = "|TInterface\\Addons\\Questie\\Icons\\questie_flat.png:12|t "
                                end
                            end
                            dropRateText = "  |cFF999999" .. dropIcon .. "[" .. FormatDropText(dropRateData[1]) .. "%]|r";
                        end
                        if objective.Needed and ((not finishedAndUnacceptedQuests[questId]) or objective.Collected ~= objective.Needed) then
                            text = "   " .. color .. tostring(objective.Collected) .. "/" .. tostring(objective.Needed) .. " " ..QuestieLib:GetObjectiveDescription(objective) .. dropRateText;
                            tooltipData[questId].objectivesText[objectiveIndex][playerName] = { ["color"] = color, ["text"] = text };
                        else
                            text = "   " .. color .. QuestieLib:GetObjectiveDescription(objective) .. dropRateText;
                            tooltipData[questId].objectivesText[objectiveIndex][playerName] = { ["color"] = color, ["text"] = text };
                        end
                    end
                end
            end
        end
    end

    local anotherPlayer = false
    if IsInGroup() then
        anotherPlayer = _FetchTooltipsForGroupMembers(key, tooltipData)
    end

    local playerName = UnitName("player")

    for questId, questData in pairs(tooltipData) do
        local hasObjective = false
        local tempObjectives = {}
        for _, playerList in pairs(questData.objectivesText or {}) do
            for objectivePlayerName, objectiveInfo in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(objectivePlayerName)
                local playerColor
                local playerType = ""
                if playerInfo then
                    playerColor = "|c" .. playerInfo.colorHex
                elseif QuestieComms.remotePlayerEnabled[objectivePlayerName] and QuestieComms.remoteQuestLogs[questId] and QuestieComms.remoteQuestLogs[questId][objectivePlayerName] and (not Questie.db.profile.onlyPartyShared or UnitInParty(objectivePlayerName)) then
                    playerColor = QuestieComms.remotePlayerClasses[objectivePlayerName]
                    if playerColor then
                        playerColor = Questie:GetClassColor(playerColor)
                        playerType = " (" .. l10n("Nearby") .. ")"
                    end
                end
                if objectivePlayerName == playerName and anotherPlayer then -- Add current player name to own objective
                    local playerClass = UnitClassBase("player")
                    local _, _, _, argbHex = GetClassColor(playerClass)
                    local dropIndex = string.find(objectiveInfo.text, "  |cFF999999")
                    local playerString = " (|c" .. argbHex .. objectivePlayerName .. "|r" .. objectiveInfo.color .. ")|r"
                    if dropIndex then
                        objectiveInfo.text = objectiveInfo.text:sub(1,dropIndex-1)..playerString.." "..objectiveInfo.text:sub(dropIndex+1) -- Ensures drop data is shown after player name
                    else
                        objectiveInfo.text = objectiveInfo.text .. playerString
                    end
                elseif playerColor and objectivePlayerName ~= playerName then -- Add other player name to their objective
                    objectiveInfo.text = objectiveInfo.text .. " (" .. playerColor .. objectivePlayerName .. "|r" .. objectiveInfo.color .. ")|r" .. playerType
                end
                -- We want the player to be on top.
                if objectivePlayerName == playerName then
                    tinsert(tempObjectives, 1, objectiveInfo.text);
                    hasObjective = true
                elseif playerColor then
                    tinsert(tempObjectives, objectiveInfo.text);
                    hasObjective = true
                end
            end
        end
        if hasObjective then
            if (not tooltipLines) then
                -- We only have tooltips from other players
                tooltipLines = {}
            end

            tinsert(tooltipLines, questData.title);
            for _, text in pairs(tempObjectives) do
                tinsert(tooltipLines, text);
            end
        end
    end
    return tooltipLines
end

_InitObjectiveTexts = function(objectivesText, objectiveIndex, playerName)
    if (not objectivesText) then
        objectivesText = {}
    end
    if (not objectivesText[objectiveIndex]) then
        objectivesText[objectiveIndex] = {}
    end
    if (not objectivesText[objectiveIndex][playerName]) then
        objectivesText[objectiveIndex][playerName] = {}
    end
    return objectivesText
end

---Object lookup only accepts public data, even when the client can render restricted tooltip content.
---@param value any
---@return boolean
local function _IsPublicTooltipTable(value)
    if issecretvalue and issecretvalue(value) then return false end
    return type(value) == "table" and (not issecrettable or not issecrettable(value))
end

---@return nil
local function _RegisterObjectTooltipCallback()
    local objectAugmented = false
    GameTooltip:HookScript("OnTooltipCleared", function()
        -- A rebuild can reuse the same name and dataInstanceID. The rendered content, not identity, resets our work.
        objectAugmented = false
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object,
        ---@param tooltip GameTooltip
        ---@param data table
        ---@return nil
        function(tooltip, data)
            if tooltip ~= GameTooltip or objectAugmented or tooltip:IsForbidden() or tooltip.ShownAsMapIcon
                or not Questie.db.profile.enableTooltips or QuestiePlayer.numberOfGroupMembers > MAX_GROUP_MEMBER_COUNT then
                return
            end

            -- Appended blocks and scanning frames do not describe the hovered world object.
            if not _IsPublicTooltipTable(data) then return end
            local primaryData = tooltip:GetPrimaryTooltipData()
            if not _IsPublicTooltipTable(primaryData) or data ~= primaryData then return end
            if not _IsPublicTooltipTable(data.lines) then return end
            local titleLine = data.lines[1]
            if not _IsPublicTooltipTable(titleLine) then return end
            local name = titleLine.leftText
            if (issecretvalue and issecretvalue(name)) or type(name) ~= "string" or name == "" then return end

            -- Object payloads also include location captions and do not reliably supply an ID.
            -- Keep provider name/zone resolution; unmatched captions simply add no quest lines.
            local playerZone = QuestiePlayer:GetCurrentZoneId()
            objectAugmented = true
            _QuestieTooltips.AddObjectDataToTooltip(name, playerZone)
            -- Blizzard calls Show after post-calls. Calling it here would run OnShow in the middle of its rebuild.
        end)
end

local initialized = false

---@return nil
function QuestieTooltips:Initialize()
    -- Processor callbacks cannot be unregistered; settings are checked when each callback runs.
    if initialized then return end
    initialized = true

    ---@param tooltip GameTooltip
    ---@return nil
    local function AddUnitData(tooltip)
        if tooltip ~= GameTooltip or QuestiePlayer.numberOfGroupMembers > MAX_GROUP_MEMBER_COUNT then
            -- The processor also runs for other tooltip frames; unit rendering below owns GameTooltip only.
            return
        end
        _QuestieTooltips.AddUnitDataToTooltip(tooltip)
    end

    -- Classic exposes the processor but its native tooltips only fire legacy scripts. Check the frame's data pipeline too.
    local usesTooltipData = type(GameTooltip.GetPrimaryTooltipData) == "function"
        and TooltipDataProcessor and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
        and Enum and Enum.TooltipDataType
    if usesTooltipData then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,
            ---@param tooltip GameTooltip
            ---@return nil
            function(tooltip)
                if tooltip == GameTooltip or tooltip == ItemRefTooltip then
                    _QuestieTooltips.AddItemDataToTooltip(tooltip)
                end
            end)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, AddUnitData)
        if Enum.TooltipDataType.Object then
            _RegisterObjectTooltipCallback()
        end
    else
        -- Classic native tooltips still own these scripts. Never install a removed script on an unfamiliar client.
        if ItemRefTooltip:HasScript("OnTooltipSetItem") then
            ItemRefTooltip:HookScript("OnTooltipSetItem", _QuestieTooltips.AddItemDataToTooltip)
        end
        if GameTooltip:HasScript("OnTooltipSetItem") then
            GameTooltip:HookScript("OnTooltipSetItem", _QuestieTooltips.AddItemDataToTooltip)
        end
        if GameTooltip:HasScript("OnTooltipSetUnit") then
            GameTooltip:HookScript("OnTooltipSetUnit", AddUnitData)
        end
    end

    -- For the clicked item frame.
    ItemRefTooltip:HookScript("OnHide", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltip = ""
            QuestieTooltips.lastItemRefTooltip = ""
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
            QuestieTooltips.lastFrameName = "";
        end
    end)

    -- For the hover frame.
    GameTooltip:HookScript("OnShow", function(self)
        if QuestiePlayer.numberOfGroupMembers > MAX_GROUP_MEMBER_COUNT then
            -- When in a raid, we want as little code running as possible
            return
        end

        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
            QuestieTooltips.lastFrameName = "";
        end
    end)
    GameTooltip:HookScript("OnHide", function(self)
        if QuestiePlayer.numberOfGroupMembers > MAX_GROUP_MEMBER_COUNT then
            -- When in a raid, we want as little code running as possible
            return
        end

        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltip = ""
            QuestieTooltips.lastItemRefTooltip = ""
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
        end
    end)

    -- Forever receives Object post-calls on rebuild. Only Classic still needs per-frame object discovery.
    if not usesTooltipData then
        GameTooltip:HookScript("OnUpdate", function(self)
            if not Questie.db.profile.enableTooltips then return end

            if QuestiePlayer.numberOfGroupMembers > MAX_GROUP_MEMBER_COUNT then
                -- When in a raid, we want as little code running as possible
                return
            end

            if (not self.IsForbidden) or (not self:IsForbidden()) then
                --Because this is an OnUpdate we need to check that it is actually not a Unit or Item to think its a
                local uName, unit = self:GetUnit()
                local iName, link = self:GetItem()
                local sName, spell = self:GetSpell()
                local objectName = GameTooltipTextLeft1:GetText()
                if objectName
                    and (uName == nil and unit == nil and iName == nil and link == nil and sName == nil and spell == nil) and (
                        QuestieTooltips.lastGametooltip ~= objectName or
                        (not QuestieTooltips.lastGametooltipCount) or
                        _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount
                        or QuestieTooltips.lastGametooltipType ~= "object"
                    ) and (not self.ShownAsMapIcon) then -- We are hovering over a Questie map icon which adds its own tooltip
                    local playerZone = QuestiePlayer:GetCurrentZoneId()
                    _QuestieTooltips.AddObjectDataToTooltip(objectName, playerZone)
                    GameTooltip:Show() -- Classic must resize after appending lines outside the native render pass.
                    QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
                end
                QuestieTooltips.lastGametooltip = objectName
            end
        end)
    end

    QuestieTooltips:InitBlizzardTooltips()
end

------------------------------------------------------------
-- The following code was modified from https://www.curseforge.com/wow/addons/noquesttooltips (MIT license)
-- It hides Blizzard's objective tooltips when ours are enabled
-- This is only relevant for Forever and MoP+ (where these tooltips exist)
------------------------------------------------------------

local TooltipLineType = Enum.TooltipDataLineType
local TooltipType = Enum.TooltipDataType
-- Line types that carry quest-helper information
local BLOCKED_NAMES = { "QuestObjective", "QuestTitle", "QuestPlayer" }
local blocked = {}

---@param tooltip table
---@return table|nil
--- Returns the type (unit, object, item, spell, etc) of this tooltip.
local function _GetTooltipKind(tooltip)
    local info = tooltip.processingInfo
    local data = info and info.tooltipData
    return data and data.type
end

---@param tooltip table
---@return boolean|nil
--- Returns true/false/nil (fallback) based upon whether we should be filtering this type of tooltip.
--- This is also where we enable/disable filtering based on whether Questie tooltips are currently shown.
local function _ShouldBlock(tooltip)
    if not Questie.db.profile.enableTooltips then return false end
    local kind = _GetTooltipKind(tooltip)
    if kind == TooltipType.Unit or kind == TooltipType.Object then return true end
    -- Unknown context: blizzard quest objective lines only appear on units/objects anyway
    return kind == nil
end

---@return nil
function QuestieTooltips:InitBlizzardTooltips()
    if not (TooltipDataProcessor and Enum and Enum.TooltipDataLineType and Enum.TooltipDataType) then
        Questie.Debug(Questie.DEBUG_INFO, "TooltipDataProcessor not found on this client. Skipping hooks.")
        return
    else
        for _, name in ipairs(BLOCKED_NAMES) do
            if TooltipLineType[name] then blocked[TooltipLineType[name]] = name end
        end
        for lineType in pairs(blocked) do
            TooltipDataProcessor.AddLinePreCall(lineType, function(tooltip, lineData)
                if _ShouldBlock(tooltip) then
                    return true
                end
            end)
        end
    end
end

-- End Blizzard tooltip hiding code