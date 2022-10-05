---@class QuestieLink
local QuestieLink = QuestieLoader:CreateModule("QuestieLink")
-------------------------
--Import modules
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieLink.lastItemRefTooltip = ""

-- Forward declaration
local _AddQuestTitle, _AddQuestStatus, _AddQuestDescription, _AddQuestRequirements, _GetQuestStarter, _GetQuestFinisher, _AddPlayerQuestProgress
local _AddTooltipLine, _AddColoredTooltipLine


local oldItemSetHyperlink = ItemRefTooltip.SetHyperlink
--- Override of the default SetHyperlink function to filter Questie links
---@param link string
function ItemRefTooltip:SetHyperlink(link, ...)
    local questiePrefix, questId = string.match(link, "(questie):(%d+):")
    local isQuestieLink = questiePrefix == "questie"

    if (not ItemRefTooltip:IsShown()) then
        QuestieLink.lastItemRefTooltip = ""
    else
        QuestieLink.lastItemRefTooltip = QuestieLink.lastItemRefTooltip or link
    end

    if isQuestieLink and questId then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTooltips:ItemRefTooltip] SetHyperlink:", link)
        ShowUIPanel(ItemRefTooltip)
        ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
        QuestieLink:CreateQuestTooltip(link)
        ItemRefTooltip:Show()

        local tooltipText = ItemRefTooltipTextLeft1:GetText()
        if QuestieLink.lastItemRefTooltip == tooltipText then
            ItemRefTooltip:Hide()
            QuestieLink.lastItemRefTooltip = ""
            return
        end

        QuestieLink.lastItemRefTooltip = tooltipText
        return
    else
        -- Make sure to call the default function so everything that is not Questie can be handled (item links e.g.)
        oldItemSetHyperlink(self, link, ...)
    end
end

---@return string
function QuestieLink:GetQuestLinkStringById(questId)
    local questName = QuestieDB.QueryQuestSingle(questId, "name");
    local questLevel, _ = QuestieLib.GetTbcLevel(questId);
    return QuestieLink:GetQuestLinkString(questLevel, questName, questId)
end

---@return string
function QuestieLink:GetQuestLinkString(questLevel, questName, questId)
    return "[["..tostring(questLevel).."] "..questName.." ("..tostring(questId)..")]"
end

---@return string
function QuestieLink:GetQuestHyperLink(questId, senderGUID)
    local coloredQuestName = QuestieLib:GetColoredQuestName(questId, Questie.db.global.trackerShowQuestLevel, true, false)
    local questLevel, _ = QuestieLib.GetTbcLevel(questId)
    local isRepeatable = QuestieDB.IsRepeatable(questId)

    if (not senderGUID) then
        senderGUID = UnitGUID("player")
    end

    return "|Hquestie:"..questId..":"..senderGUID.."|h"..QuestieLib:PrintDifficultyColor(questLevel, "[", isRepeatable)..coloredQuestName..QuestieLib:PrintDifficultyColor(questLevel, "]", isRepeatable).."|h"
end

function QuestieLink:CreateQuestTooltip(link)
    local isQuestieLink, _, _ = string.match(link, "questie:(%d+):.*")
    if isQuestieLink then
        ---@type string
        local questIdStr = select(2, strsplit(":", link))
        local questId = tonumber(questIdStr)
        local quest = QuestieDB:GetQuest(questId)

        if quest then
            _AddQuestTitle(quest)
            _AddQuestStatus(quest)

            _AddTooltipLine(" ")

            _AddQuestDescription(quest)
            _AddQuestRequirements(quest)
            local starterName, starterZoneName = _GetQuestStarter(quest)
            local finisherName, finisherZoneName = _GetQuestFinisher(quest)
            _AddPlayerQuestProgress(quest, starterName, starterZoneName, finisherName, finisherZoneName)
        end
    end
end

---@param text string
---@param wrapText boolean?
_AddTooltipLine = function (text, wrapText)
    ItemRefTooltip:AddLine(text, 1, 1, 1, wrapText)
end

---@param text string
---@param color string
---@param wrapText boolean?
_AddColoredTooltipLine = function (text, color, wrapText)
    text = Questie:Colorize(text, color)
    ItemRefTooltip:AddLine(text, 1, 1, 1, wrapText)
end

_AddQuestTitle = function(quest)
    local questLevel = QuestieLib:GetLevelString(quest.Id, quest.name, quest.level, false)

    local titleColor = "gold"
    if quest.specialFlags == 1 then
        titleColor = "blizzardBlue"
    end

    if Questie.db.global.trackerShowQuestLevel and Questie.db.global.enableTooltipsQuestID then
        _AddColoredTooltipLine(questLevel .. quest.name .. " (" .. quest.Id .. ")", titleColor)
    elseif Questie.db.global.trackerShowQuestLevel and (not Questie.db.global.enableTooltipsQuestID) then
        _AddColoredTooltipLine(questLevel .. quest.name, titleColor)
    elseif Questie.db.global.enableTooltipsQuestID and (not Questie.db.global.trackerShowQuestLevel) then
        _AddColoredTooltipLine(quest.name .. " (" .. quest.Id .. ")", titleColor)
    else
        _AddColoredTooltipLine(quest.name, titleColor)
    end
end

_AddQuestStatus = function (quest)
    if QuestiePlayer.currentQuestlog[quest.Id] then
        local onQuestText = l10n("You are on this quest")
        local stateText
        local questIsComplete = QuestieDB.IsComplete(quest.Id)
        if questIsComplete == 1 then
            stateText = Questie:Colorize(l10n("Complete"), "green")
        elseif questIsComplete == -1 then
            stateText = Questie:Colorize(l10n("Failed"), "red")
        end

        if stateText then
            _AddTooltipLine(onQuestText .. " (" .. stateText .. ")")
        else
            _AddColoredTooltipLine(onQuestText, "green")
        end
    elseif Questie.db.char.complete[quest.Id] then
        _AddColoredTooltipLine(l10n("You have completed this quest"), "green")
    elseif (UnitLevel("player") < quest.requiredLevel or (not QuestieDB.IsDoable(quest.Id))) and (not Questie.db.char.hidden[quest.Id]) then
        _AddColoredTooltipLine(l10n("You are ineligible for this quest"), "red")
    elseif quest.specialFlags == 1 then
        _AddColoredTooltipLine(l10n("This quest is repeatable"), "yellow")
    else
        _AddColoredTooltipLine(l10n("You have not done this quest"), "yellow")
    end
end

_AddQuestDescription = function (quest)
    if quest and quest.Description and quest.Description[1] then
        _AddColoredTooltipLine(quest.Description[1], "white", true)
        if #quest.Description > 2 then
            for i = 2, #quest.Description do
                _AddTooltipLine(" ")
                _AddColoredTooltipLine(quest.Description[i], "white", true)
            end
        end
    else
        _AddColoredTooltipLine(l10n("This quest is an automatic completion quest and does not contain an objective."), "white", true)
    end
end

_AddQuestRequirements = function (quest)
    if #quest.ObjectiveData > 0 and not (QuestiePlayer.currentQuestlog[quest.Id] or Questie.db.char.complete[quest.Id]) then
        for i = 1, #quest.ObjectiveData do
            local currentObjective = quest.ObjectiveData[i]
            if currentObjective then
                if currentObjective.Text then
                    if currentObjective == quest.ObjectiveData[1] then
                        _AddTooltipLine(" ")
                        _AddColoredTooltipLine(l10n("Requirements"), "gold")
                    end
                    _AddColoredTooltipLine(currentObjective.Text, "white")
                else
                    local objectiveName
                    if currentObjective.Type == "monster" then
                        objectiveName = QuestieDB.QueryNPCSingle(currentObjective.Id, "name")
                    else
                        objectiveName = QuestieDB.QueryItemSingle(currentObjective.Id, "name")
                    end

                    if objectiveName then
                        if currentObjective == quest.ObjectiveData[1] then
                            _AddTooltipLine(" ")
                            _AddColoredTooltipLine(l10n("Requirements"), "gold")
                        end
                        _AddColoredTooltipLine(objectiveName, "white")
                    end
                end
            end
        end
    end
end

_GetQuestStarter = function (quest)
    if quest.Starts then
        local starterName, starterZoneName
        if quest.Starts.NPC ~= nil then
            local npc = QuestieDB:GetNPC(quest.Starts.NPC[1])
            starterName = npc.name

            if npc.zoneID ~= 0 then
                starterZoneName = TrackerUtils:GetZoneNameByID(npc.zoneID)
            else
                starterZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
            end
        elseif quest.Starts.Item ~= nil then
            local item = QuestieDB:GetItem(quest.Starts.Item[1])
            starterName = item.name

            if item.Sources and item.Sources[1] and item.Sources[1].Type then
                local itemSource = item.Sources[1]
                local dropStart

                if itemSource.Type == "monster" then
                    dropStart = QuestieDB:GetNPC(itemSource.Id)
                elseif itemSource.Type == "object" then
                    dropStart = QuestieDB:GetObject(itemSource.Id)
                end

                if item.zoneID ~= 0 then
                    starterZoneName = TrackerUtils:GetZoneNameByID(dropStart.zoneID)
                else
                    starterZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
                end
            else
                starterZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
            end
        elseif quest and quest.Starts and quest.Starts.GameObject and quest.Starts.GameObject[1] then
            local object = QuestieDB:GetObject(quest.Starts.GameObject[1])
            starterName = object.name
            if object.zoneID ~= 0 then
                starterZoneName = TrackerUtils:GetZoneNameByID(object.zoneID)
            else
                starterZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
            end
        end

        return starterName, starterZoneName
    end

    return nil, nil
end

_GetQuestFinisher = function (quest)
    if quest.Finisher and quest.Finisher.Id then
        local finisherName, finisherZoneName
        if quest.Finisher.Type == "monster" then
            local npc = QuestieDB:GetNPC(quest.Finisher.Id)
            finisherName = npc.name

            if npc.zoneID ~= 0 then
                finisherZoneName = TrackerUtils:GetZoneNameByID(npc.zoneID)
            else
                finisherZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
            end
        elseif quest.Finisher.Type == "object" then
            local object = QuestieDB:GetObject(quest.Finisher.Id)
            finisherName = object.name

            if object.zoneID ~= 0 then
                finisherZoneName = TrackerUtils:GetZoneNameByID(object.zoneID)
            else
                finisherZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
            end
        else
            finisherZoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)
        end

        return finisherName, finisherZoneName
    end

    return nil, nil
end

_AddPlayerQuestProgress = function (quest, starterName, starterZoneName, finisherName, finisherZoneName)
    if QuestiePlayer.currentQuestlog[quest.Id] then
        -- On Quest: display quest progress
        if (QuestieDB.IsComplete(quest.Id) == 0) then
            _AddTooltipLine(" ")
            _AddTooltipLine(l10n("Your progress")..":")
            for _, objective in pairs(quest.Objectives) do
                local objDesc = objective.Description:gsub("%.", "")

                if objective.Needed > 0 then
                    local lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)
                    _AddTooltipLine(" - " .. QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding.."|r")
                end
            end
        -- Completed Quest (not turned in): display quest ended by npc and zone
        else
            if finisherName then
                _AddTooltipLine(" ")
                _AddTooltipLine((l10n("Ended by")..": " .. Questie:Colorize(finisherName, "gray")))
            end
            if finisherZoneName then
                _AddTooltipLine(" ")
                _AddTooltipLine((l10n("Found in")..": " .. Questie:Colorize(finisherZoneName, "gray")))
            end
        end
    else
        -- Completed Quest (turned in)
        if Questie.db.char.complete[quest.Id] == true then
            if Questie.db.char.journey then
                local timestamp
                for i = 1, #Questie.db.char.journey do
                    if Questie.db.char.journey[i].Quest ~= nil and Questie.db.char.journey[i].Quest == quest.Id then
                        local year = tonumber(date("%Y", Questie.db.char.journey[i].Timestamp))
                        local day = CALENDAR_WEEKDAY_NAMES[ tonumber(date("%w", Questie.db.char.journey[i].Timestamp)) + 1 ]
                        local month = CALENDAR_FULLDATE_MONTH_NAMES[ tonumber(date("%m", Questie.db.char.journey[i].Timestamp)) ]
                        timestamp = Questie:Colorize(date( "[ "..day ..", ".. month .." %d, "..year.." @ %H:%M ]  " , Questie.db.char.journey[i].Timestamp), "blue")
                    end
                end
                if timestamp then
                    _AddTooltipLine(" ")
                    _AddTooltipLine(l10n("Completed on:"))
                    _AddTooltipLine(timestamp)
                end
            end
        -- Not on Quest: display quest started by npc and zone
        else
            if starterName then
                _AddTooltipLine(" ")
                _AddTooltipLine((l10n("Started by")..": " .. Questie:Colorize(starterName, "gray")))
            end
            if starterZoneName then
                _AddTooltipLine((l10n("Found in")..": " .. Questie:Colorize(starterZoneName, "gray")))
            end
        end
    end
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(...)
    local _, link, _, button = ...
    if (IsShiftKeyDown() and ChatEdit_GetActiveWindow() and button == "LeftButton") then
        local linkType, questId, _ = string.split(":", link)
        if linkType and linkType == "questie" and questId then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTooltips:OnHyperlinkShow] Relinking Quest Link to chat:", link)
            questId = tonumber(questId)

            local quest = QuestieDB:GetQuest(questId)
            if quest then
                local msg = ChatFrame1EditBox:GetText()
                if msg then
                    ChatFrame1EditBox:SetText("")
                    ChatEdit_InsertLink(string.gsub(msg, "%|Hquestie:" .. questId .. ":.*%|h", "%[%[" .. quest.level .. "%] " .. quest.name .. " %(" .. questId .. "%)%]"))
                end
            end
        end
    end
end)
