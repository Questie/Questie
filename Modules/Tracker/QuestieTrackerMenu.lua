---@type QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
QuestieTracker.menu = {}
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")


local tinsert = table.insert

function QuestieTracker.menu:GetMenuForQuest(quest)
    local menu = {}
    local subMenu = {}

    for _, objective in pairs(quest.Objectives) do
        local objectiveMenu = {}
        if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
            tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
        else
            tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_FOCUS_OBJECTIVE'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusObjective(quest, objective); QuestieQuest:UpdateHiddenNotes() end})
        end
        tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
            LQuestie_CloseDropDownMenus()
            local spawn, zone, name = QuestieMap:GetNearestSpawn(objective)
            if spawn then
                QuestieTracker.utils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
            end
        end})
        if objective.HideIcons then
            tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
                LQuestie_CloseDropDownMenus()
                objective.HideIcons = nil;
                QuestieQuest:UpdateHiddenNotes()
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = nil
            end})
        else
            tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
                LQuestie_CloseDropDownMenus()
                objective.HideIcons = true;
                QuestieQuest:UpdateHiddenNotes()
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = true
            end})
        end

        tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
            LQuestie_CloseDropDownMenus()
            local needHiddenUpdate
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
            if needHiddenUpdate then QuestieQuest:UpdateHiddenNotes(); end
            QuestieTracker.utils:ShowObjectiveOnMap(objective)
        end})

        tinsert(subMenu, {text = objective.Description, hasArrow = true, menuList = objectiveMenu})
    end

    if quest.SpecialObjectives then
        for _,Objective in pairs(quest.SpecialObjectives) do
            local objectiveMenu = {}

            if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(Objective.Index) then
                tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
            else
                tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_FOCUS_OBJECTIVE'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusObjective(quest, Objective, true); QuestieQuest:UpdateHiddenNotes() end})
            end
            tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
                LQuestie_CloseDropDownMenus()
                local spawn, zone, name = QuestieMap:GetNearestSpawn(Objective)
                if spawn then
                    QuestieTracker.utils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
                end
            end})
            if Objective.HideIcons then
                tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
                    LQuestie_CloseDropDownMenus()
                    Objective.HideIcons = nil;
                    QuestieQuest:UpdateHiddenNotes()
                    Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(Objective.Index)] = nil
                end})
            else
                tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
                    LQuestie_CloseDropDownMenus()
                    Objective.HideIcons = true;
                    QuestieQuest:UpdateHiddenNotes()
                    Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(Objective.Index)] = true
                end})
            end

            tinsert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
                LQuestie_CloseDropDownMenus()
                local needHiddenUpdate
                if (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus ~= tostring(quest.Id) .. " " .. tostring(Objective.Index))
                or (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus ~= quest.Id) then
                    QuestieTracker:UnFocus()
                    needHiddenUpdate = true
                end
                if Objective.HideIcons then
                    Objective.HideIcons = nil
                    needHiddenUpdate = true
                end
                if quest.HideIcons then
                    quest.HideIcons = nil
                    needHiddenUpdate = true
                end
                if needHiddenUpdate then QuestieQuest:UpdateHiddenNotes(); end
                QuestieTracker.utils:ShowObjectiveOnMap(Objective)
            end})

            tinsert(subMenu, {text = Objective.Description, hasArrow = true, menuList = objectiveMenu})
        end
    end

    tinsert(menu, {text=quest:GetColoredQuestName(), isTitle = true})
    if not QuestieQuest:IsComplete(quest) then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_OBJECTIVES'), hasArrow = true, menuList = subMenu})
    end
    if quest.HideIcons then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
            quest.HideIcons = nil
            QuestieQuest:UpdateHiddenNotes()
            Questie.db.char.TrackerHiddenQuests[quest.Id] = nil
        end})
    else
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
            quest.HideIcons = true
            QuestieQuest:UpdateHiddenNotes()
            Questie.db.char.TrackerHiddenQuests[quest.Id] = true
        end})
    end
    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
        LQuestie_CloseDropDownMenus()
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)
        if spawn then
            QuestieTracker.utils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    end})
    if QuestieQuest:IsComplete(quest) then
        tinsert(menu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
            LQuestie_CloseDropDownMenus()
            QuestieTracker.utils:ShowFinisherOnMap(quest)
        end})
    end
    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG'), func = function()
        LQuestie_CloseDropDownMenus()
        QuestieTracker.utils:ShowQuestLog(quest)
    end})
    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNTRACK'), func = function()
        LQuestie_CloseDropDownMenus();
        QuestieTracker:Untrack(quest)
    end})
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
    else
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_FOCUS_QUEST'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusQuest(quest); QuestieQuest:UpdateHiddenNotes()  end})
    end

    tinsert(menu, {text="|cFF39c0edWowhead URL|r", func = function()
        StaticPopup_Show("QUESTIE_WOWHEAD_URL", quest.Id)
    end})

    if Questie.db.global.trackerLocked then
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNLOCK'), func = function() LQuestie_CloseDropDownMenus(); Questie.db.global.trackerLocked = false end})
    else
        tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_LOCK'), func = function() LQuestie_CloseDropDownMenus(); Questie.db.global.trackerLocked = true end})
    end

    tinsert(menu, {text=QuestieLocale:GetUIString('TRACKER_CANCEL'), func = function() end})

    return menu
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
