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
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")

QuestieLink.lastItemRefTooltip = ""

-- Forward declaration
local _AddQuestTitle, _AddQuestStatus, _AddQuestDescription, _AddQuestRequirements, _GetQuestStarter, _GetQuestFinisher, _AddPlayerQuestProgress
local _AddTooltipLine, _AddColoredTooltipLine


local oldItemSetHyperlink = ItemRefTooltip.SetHyperlink
--- Override of the default SetHyperlink function to filter Questie links
---@param link string
function ItemRefTooltip:SetHyperlink(link, ...)
    local _, _, isQuestieLink, questId = string.find(link, "(questie):(%d+):")
    QuestieLink.lastItemRefTooltip = QuestieLink.lastItemRefTooltip or link

    if isQuestieLink and questId then
        Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltips:ItemRefTooltip] SetHyperlink: " .. link)
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

function QuestieLink:CreateQuestTooltip(link)
    local isQuestieLink, _, _ = string.find(link, "questie:(%d+):.*")
    if isQuestieLink then
        local questId = select(2, strsplit(":", link))
        questId = tonumber(questId)
        local senderGUID = select(3, strsplit(":", link))
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
---@param wrapText boolean
_AddTooltipLine = function (text, wrapText)
    ItemRefTooltip:AddLine(text, 1, 1, 1, wrapText)
end

---@param text string
---@param color string
---@param wrapText boolean
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
        local onQuestText = QuestieLocale:GetUIString("TOOLTIPS_ON_QUEST")
        local stateText = nil
        local questIsComplete = QuestieDB:IsComplete(quest.Id)
        if questIsComplete == 1 then
            stateText = Questie:Colorize(QuestieLocale:GetUIString("COMPLETE"), "green")
        elseif questIsComplete == -1 then
            stateText = Questie:Colorize(QuestieLocale:GetUIString("FAILED"), "red")
        end

        if stateText then
            _AddTooltipLine(onQuestText .. " (" .. stateText .. ")")
        else
            _AddColoredTooltipLine(onQuestText, "green")
        end
    elseif Questie.db.char.complete[quest.Id] then
        _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_DONE_QUEST"), "green")
    elseif (UnitLevel("player") < quest.requiredLevel or (not QuestieDB:IsDoable(quest.Id))) and (not Questie.db.char.hidden[quest.Id]) then
        _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_CANTDO_QUEST"), "red")
    elseif quest.specialFlags == 1 then
        _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_REPEAT_QUEST"), "yellow")
    else
        _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_NOTDONE_QUEST"), "yellow")
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
        _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_AUTO_QUEST"), "white", true)
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
                        _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_REQUIRE_QUEST"), "gold")
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
                            _AddColoredTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_REQUIRE_QUEST"), "gold")
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
                starterZoneName = QuestieTracker.utils:GetZoneNameByID(npc.zoneID)
            else
                starterZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
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
                    starterZoneName = QuestieTracker.utils:GetZoneNameByID(dropStart.zoneID)
                else
                    starterZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
                end
            else
                starterZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
            end
        elseif quest and quest.Starts and quest.Starts.GameObject and quest.Starts.GameObject[1] then
            local object = QuestieDB:GetObject(quest.Starts.GameObject[1])
            starterName = object.name
            if object.zoneID ~= 0 then
                starterZoneName = QuestieTracker.utils:GetZoneNameByID(object.zoneID)
            else
                starterZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
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
                finisherZoneName = QuestieTracker.utils:GetZoneNameByID(npc.zoneID)
            else
                finisherZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
            end
        elseif quest.Finisher.Type == "object" then
            local object = QuestieDB:GetObject(quest.Finisher.Id)
            finisherName = object.name

            if object.zoneID ~= 0 then
                finisherZoneName = QuestieTracker.utils:GetZoneNameByID(object.zoneID)
            else
                finisherZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
            end
        else
            finisherZoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)
        end

        return finisherName, finisherZoneName
    end

    return nil, nil
end

_AddPlayerQuestProgress = function (quest, starterName, starterZoneName, finisherName, finisherZoneName)
    if QuestiePlayer.currentQuestlog[quest.Id] then
        -- On Quest: display quest progress
        if (QuestieDB:IsComplete(quest.Id) == 0) then
            _AddTooltipLine(" ")
            _AddTooltipLine(QuestieLocale:GetUIString("TOOLTIPS_PROGRESS_QUEST")..":")
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
                _AddTooltipLine((QuestieLocale:GetUIString("TOOLTIPS_END_QUEST")..": " .. Questie:Colorize(finisherName, "gray")))
            end
            if finisherZoneName then
                _AddTooltipLine(" ")
                _AddTooltipLine((QuestieLocale:GetUIString("TOOLTIPS_FOUND_QUEST")..": " .. Questie:Colorize(finisherZoneName, "gray")))
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
                    _AddTooltipLine("Completed on:")
                    _AddTooltipLine(timestamp)
                end
            end
        -- Not on Quest: display quest started by npc and zone
        else
            if starterName then
                _AddTooltipLine(" ")
                _AddTooltipLine((QuestieLocale:GetUIString("TOOLTIPS_START_QUEST")..": " .. Questie:Colorize(starterName, "gray")))
            end
            if starterZoneName then
                _AddTooltipLine((QuestieLocale:GetUIString("TOOLTIPS_FOUND_QUEST")..": " .. Questie:Colorize(starterZoneName, "gray")))
            end
        end
    end
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(...)
    local chatFrame, link, text, button = ...
    if (IsShiftKeyDown() and ChatEdit_GetActiveWindow() and button == "LeftButton") then
        local linkType, questId, playerGUID = string.split(":", link)
        if linkType and linkType == "questie" and questId then
            Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltips:OnHyperlinkShow] Relinking Quest Link to chat: "..link)
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
