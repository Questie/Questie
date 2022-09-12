---@class TrackerMenu
local TrackerMenu = QuestieLoader:CreateModule("TrackerMenu")

---@type TrackerUtils
local TrackerUtils = QuestieLoader:CreateModule("TrackerUtils")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

TrackerMenu.menuFrame = LibDropDown:Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

local tinsert = table.insert

-- forward declaration
local _AddFocusOption, _AddTomTomOption, _AddShowHideObjectivesOption, _AddShowHideQuestsOption, _AddShowObjectivesOnMapOption, _AddShowFinisherOnMapOption, _AddObjectiveOption, _AddLinkToChatOption, _AddShowInQuestLogOption, _AddUntrackOption, _AddFocusUnfocusOption, _AddLockUnlockOption

local _UpdateTrackerBaseFrame, _UntrackQuest

function TrackerMenu.Initialize(UpdateTrackerBaseFrame, UntrackQuest)
    _UpdateTrackerBaseFrame = UpdateTrackerBaseFrame
    _UntrackQuest = UntrackQuest
end

function TrackerMenu:GetMenuForQuest(quest)
    local menu = {}
    local subMenu = {}

    for _, objective in pairs(quest.Objectives) do
        local objectiveMenu = {}

        _AddFocusOption(objectiveMenu, quest, objective)
        _AddTomTomOption(objectiveMenu, nil, objective)
        _AddShowHideObjectivesOption(objectiveMenu, quest, objective)
        _AddShowObjectivesOnMapOption(objectiveMenu, quest, objective)

        tinsert(subMenu, {text = objective.Description, hasArrow = true, menuList = objectiveMenu})
    end

    if next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local objectiveMenu = {}

            _AddFocusOption(objectiveMenu, quest, objective)
            _AddTomTomOption(objectiveMenu, nil, objective)
            _AddShowHideObjectivesOption(objectiveMenu, quest, objective)
            _AddShowObjectivesOnMapOption(objectiveMenu, quest, objective)

            tinsert(subMenu, {text = objective.Description, hasArrow = true, menuList = objectiveMenu})
        end
    end

    local coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.enableTooltipsQuestLevel, true, true)
    tinsert(menu, {text=coloredQuestName, isTitle = true})

    _AddObjectiveOption(menu, subMenu, quest)
    _AddShowHideQuestsOption(menu, quest)
    _AddLinkToChatOption(menu, quest)
    _AddTomTomOption(menu, quest, nil)
    _AddShowFinisherOnMapOption(menu, quest)
    _AddShowInQuestLogOption(menu, quest)
    _AddUntrackOption(menu, quest)
    _AddFocusUnfocusOption(menu, quest)

    tinsert(menu, {text="|cFF39c0edWowhead URL|r", func = function()
        StaticPopup_Show("QUESTIE_WOWHEAD_URL", quest.Id)
    end})

    _AddLockUnlockOption(menu)

    tinsert(menu, { text= l10n('Cancel'), func = function() end})

    return menu
end

_AddFocusOption = function (menu, quest, objective)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
        tinsert(menu, { text = l10n('Unfocus'), func = function() LibDropDown:CloseDropDownMenus(); TrackerUtils:UnFocus(); QuestieQuest:ToggleNotes(true) end})
    else
        tinsert(menu, { text = l10n('Focus Objective'), func = function() LibDropDown:CloseDropDownMenus(); TrackerUtils:FocusObjective(quest.Id, objective.Index); QuestieQuest:ToggleNotes(false) end})
    end
end

_AddTomTomOption = function (menu, quest, objective)
    tinsert(menu, {text = l10n('Set |cFF54e33bTomTom|r Target'), func = function()
        LibDropDown:CloseDropDownMenus()
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)
        if (not spawn) and objective ~= nil then
            spawn, zone, name = QuestieMap:GetNearestSpawn(objective)
        end
        if spawn then
            TrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    end})
end

_AddShowHideObjectivesOption = function (menu, quest, objective)
    if objective.HideIcons then
        tinsert(menu, {text = l10n('Show Icons'), func = function()
            LibDropDown:CloseDropDownMenus()
            objective.HideIcons = nil;
            Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = nil
            QuestieQuest:ToggleNotes(true)
        end})
    else
        tinsert(menu, {text = l10n('Hide Icons'), func = function()
            LibDropDown:CloseDropDownMenus()
            objective.HideIcons = true;
            Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = true
            QuestieQuest:ToggleNotes(false)
        end})
    end
end

_AddShowHideQuestsOption = function (menu, quest)
    if quest.HideIcons then
        tinsert(menu, { text= l10n('Show Icons'), func = function()
            quest.HideIcons = nil
            Questie.db.char.TrackerHiddenQuests[quest.Id] = nil
            QuestieQuest:ToggleNotes(true)
        end})
    else
        tinsert(menu, { text= l10n('Hide Icons'), func = function()
            quest.HideIcons = true
            Questie.db.char.TrackerHiddenQuests[quest.Id] = true
            QuestieQuest:ToggleNotes(false)
        end})
    end
end

_AddShowObjectivesOnMapOption = function (menu, quest, objective)
    tinsert(menu, {text = l10n('Show on Map'), func = function()
        LibDropDown:CloseDropDownMenus()
        local needHiddenUpdate = false
        if (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus ~= tostring(quest.Id) .. " " .. tostring(objective.Index))
        or (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus ~= quest.Id) then
            TrackerUtils:UnFocus()
            needHiddenUpdate = true
        end
        if objective.HideIcons then
            objective.HideIcons = nil
            needHiddenUpdate = true
        end
        if quest.HideIcons then
            quest.HideIcons = nil
            needHiddenUpdate = true
        end
        if needHiddenUpdate then
            QuestieQuest:ToggleNotes(true)
        end
        TrackerUtils:ShowObjectiveOnMap(objective)
    end})
end

_AddShowFinisherOnMapOption = function (menu, quest)
    if quest:IsComplete() == 1 then
        tinsert(menu, {text = l10n('Show on Map'), func = function()
            LibDropDown:CloseDropDownMenus()
            TrackerUtils:ShowFinisherOnMap(quest)
        end})
    end
end

_AddObjectiveOption = function (menu, subMenu, quest)
    if quest:IsComplete() == 0 then
        tinsert(menu, { text= l10n('Objectives'), hasArrow = true, menuList = subMenu})
    end
end

_AddLinkToChatOption = function (menu, quest)
    tinsert(menu, {text = l10n('Link Quest to chat'), func = function()
        LibDropDown:CloseDropDownMenus()

        if ( not ChatFrame1EditBox:IsVisible() ) then
            if Questie.db.global.trackerShowQuestLevel then
                ChatFrame_OpenChat(QuestieLink:GetQuestLinkString(quest.level, quest.name, quest.Id))
            else
                ChatFrame_OpenChat("["..quest.name.." ("..quest.Id..")]")
            end
        else
            if Questie.db.global.trackerShowQuestLevel then
                ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(quest.level, quest.name, quest.Id))
            else
                ChatEdit_InsertLink("["..quest.name.." ("..quest.Id..")]")
            end
        end

    end})
end

_AddShowInQuestLogOption = function (menu, quest)
    tinsert(menu, {text= l10n('Show in Quest Log'), func = function()
        LibDropDown:CloseDropDownMenus()
        TrackerUtils:ShowQuestLog(quest)
    end})
end

_AddUntrackOption = function (menu, quest)
    tinsert(menu, {text= l10n('Untrack Quest'), func = function()
        LibDropDown:CloseDropDownMenus();
        _UntrackQuest(quest)
    end})
end

_AddFocusUnfocusOption = function (menu, quest)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then
        tinsert(menu, {text= l10n('Unfocus'), func = function() LibDropDown:CloseDropDownMenus(); TrackerUtils:UnFocus(); QuestieQuest:ToggleNotes(true) end})
    else
        tinsert(menu, {text= l10n('Focus Quest'), func = function() LibDropDown:CloseDropDownMenus(); TrackerUtils:FocusQuest(quest.Id); QuestieQuest:ToggleNotes(false) end})
    end
end

_AddLockUnlockOption = function (menu)
    if Questie.db.global.trackerLocked then
        tinsert(menu, {text= l10n('Unlock Tracker'), func = function() LibDropDown:CloseDropDownMenus(); Questie.db.global.trackerLocked = false; _UpdateTrackerBaseFrame() end})
    else
        tinsert(menu, {text= l10n('Lock Tracker'), func = function() LibDropDown:CloseDropDownMenus(); Questie.db.global.trackerLocked = true; _UpdateTrackerBaseFrame() end})
    end
end


-- Register the Wowhead popup dialog
StaticPopupDialogs["QUESTIE_WOWHEAD_URL"] = {
    text = "Wowhead URL",
    button2 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 280,

    EditBoxOnEnterPressed = function(self)
        self:GetParent():Hide()
    end,

    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,

    OnShow = function(self)
        local questID = self.text.text_arg1;
        local quest_wow = QuestieDB:GetQuest(questID);
        local name = quest_wow.name;

        -- self.text:SetText(self.text:GetText() .. "\n\n|cffff7f00" .. name .. "|r");
        self.text:SetFont("GameFontNormal", 12)
        -- self.text:SetText(self.text:GetText() .. "\n\n|c FFFFB9 00" .. name .. "|r");
        self.text:SetText(self.text:GetText() .. Questie:Colorize("\n\n" .. name, "gold"));

        local langShort = string.sub(l10n:GetUILocale(), 1, 2) .. "."
        if langShort == "en." then
            langShort = ""
        end

        local wowheadLink

        if Questie.IsWotlk then
            if langShort then
                langShort = langShort:gsub("%.", "/") -- The Wotlk wowhead URL differs to the other Classic URLs
            end
            wowheadLink = "https://" .. "wowhead.com/wotlk/" .. langShort .. "quest=" .. questID
        elseif Questie.IsTBC then
            wowheadLink = "https://" .. langShort .. "tbc.wowhead.com/quest=" .. questID
        else
            wowheadLink = "https://" .. langShort .. "classic.wowhead.com/quest=" .. questID
        end

        self.editBox:SetText(wowheadLink);
        self.editBox:SetFocus();
        self.editBox:HighlightText();
    end,

    whileDead = true,
    hideOnEscape = true
}
