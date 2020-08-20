---@type QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
QuestieTracker.menu = {}
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")


local tinsert = table.insert

-- forward declaration
local _AddFocusOption, _AddTomTomOption, _AddShowHideObjectivesOption, _AddShowHideQuestsOption, _AddShowObjectivesOnMapOption, _AddShowFinisherOnMapOption, _AddObjectiveOption, _AddLinkToChatOption, _AddShowInQuestLogOption, _AddUntrackOption, _AddFocusUnfocusOption, _AddLockUnlockOption


function QuestieTracker.menu:GetMenuForQuest(quest)
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

    if quest.SpecialObjectives then
        for _, objective in pairs(quest.SpecialObjectives) do
            local objectiveMenu = {}

            _AddFocusOption(objectiveMenu, quest, objective)
            _AddTomTomOption(objectiveMenu, nil, objective)
            _AddShowHideObjectivesOption(objectiveMenu, quest, objective)
            _AddShowObjectivesOnMapOption(objectiveMenu, quest, objective)

            tinsert(subMenu, {text = objective.Description, hasArrow = true, menuList = objectiveMenu})
        end
    end


    tinsert(menu, {text=quest:GetColoredQuestName(), isTitle = true})

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

    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_CANCEL'), func = function() end})

    return menu
end

_AddFocusOption = function (menu, quest, objective)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
        tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:ToggleNotes(true) end})
    else
        tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_FOCUS_OBJECTIVE'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusObjective(quest.Id, objective.Index); QuestieQuest:ToggleNotes(false) end})
    end
end

_AddTomTomOption = function (menu, quest, objective)
    tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
        LQuestie_CloseDropDownMenus()
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)
        if spawn == nil and objective ~= nil then
            spawn, zone, name = QuestieMap:GetNearestSpawn(objective)
        end
        if spawn then
            QuestieTracker.utils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    end})
end

_AddShowHideObjectivesOption = function (menu, quest, objective)
    if objective.HideIcons then
        tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
            LQuestie_CloseDropDownMenus()
            objective.HideIcons = nil;
            Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = nil
            QuestieQuest:ToggleNotes(true)
        end})
    else
        tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
            LQuestie_CloseDropDownMenus()
            objective.HideIcons = true;
            Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = true
            QuestieQuest:ToggleNotes(false)
        end})
    end
end

_AddShowHideQuestsOption = function (menu, quest)
    if quest.HideIcons then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
            quest.HideIcons = nil
            Questie.db.char.TrackerHiddenQuests[quest.Id] = nil
            QuestieQuest:ToggleNotes(true)
        end})
    else
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
            quest.HideIcons = true
            Questie.db.char.TrackerHiddenQuests[quest.Id] = true
            QuestieQuest:ToggleNotes(false)
        end})
    end
end

_AddShowObjectivesOnMapOption = function (menu, quest, objective)
    tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
        LQuestie_CloseDropDownMenus()
        local needHiddenUpdate = false
        if (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus ~= tostring(quest.Id) .. " " .. tostring(objective.Index))
        or (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus ~= quest.Id) then
            QuestieTracker:UnFocus()
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
        QuestieTracker.utils:ShowObjectiveOnMap(objective)
    end})
end

_AddShowFinisherOnMapOption = function (menu, quest)
    if quest:IsComplete() == 1 then
        tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
            LQuestie_CloseDropDownMenus()
            QuestieTracker.utils:ShowFinisherOnMap(quest)
        end})
    end
end

_AddObjectiveOption = function (menu, subMenu, quest)
    if quest:IsComplete() == 0 then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_OBJECTIVES'), hasArrow = true, menuList = subMenu})
    end
end

_AddLinkToChatOption = function (menu, quest)
    tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_LINK_TO_CHAT'), func = function()
        LQuestie_CloseDropDownMenus()

        if ( not ChatFrame1EditBox:IsVisible() ) then
            if Questie.db.global.trackerShowQuestLevel then
                ChatFrame_OpenChat("[["..quest.level.."] "..quest.name.." ("..quest.Id..")]")
            else
                ChatFrame_OpenChat("["..quest.name.." ("..quest.Id..")]")
            end
        else
            if Questie.db.global.trackerShowQuestLevel then
                ChatEdit_InsertLink("[["..quest.level.."] "..quest.name.." ("..quest.Id..")]")
            else
                ChatEdit_InsertLink("["..quest.name.." ("..quest.Id..")]")
            end
        end

    end})
end

_AddShowInQuestLogOption = function (menu, quest)
    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG'), func = function()
        LQuestie_CloseDropDownMenus()
        QuestieTracker.utils:ShowQuestLog(quest)
    end})
end

_AddUntrackOption = function (menu, quest)
    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNTRACK'), func = function()
        LQuestie_CloseDropDownMenus();
        QuestieTracker:Untrack(quest)
    end})
end

_AddFocusUnfocusOption = function (menu, quest)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:ToggleNotes(true) end})
    else
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_FOCUS_QUEST'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusQuest(quest.Id); QuestieQuest:ToggleNotes(false) end})
    end
end

_AddLockUnlockOption = function (menu)
    if Questie.db.global.trackerLocked then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNLOCK'), func = function() LQuestie_CloseDropDownMenus(); Questie.db.global.trackerLocked = false; QuestieTracker.private.baseFrame:Update() end})
    else
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_LOCK'), func = function() LQuestie_CloseDropDownMenus(); Questie.db.global.trackerLocked = true; QuestieTracker.private.baseFrame:Update() end})
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

        local langShort = string.sub(QuestieLocale:GetUILocale(), 1, 2) .. "."
        if langShort == "en." then
            langShort = ""
        end
        self.editBox:SetText("https://" .. langShort .. "classic.wowhead.com/quest=" .. questID);
        self.editBox:SetFocus();
        self.editBox:HighlightText();
    end,

    whileDead = true,
    hideOnEscape = true
}
