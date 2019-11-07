---@class QuestieTrackerMenu
local QuestieTrackerMenu = QuestieLoader:CreateModule("QuestieTrackerMenu")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieTrackerUtils
local QuestieTrackerUtils = QuestieLoader:ImportModule("QuestieTrackerUtils")


function QuestieTrackerMenu:GetMenuForQuest(quest)
    local menu = {}
    local subMenu = {}

    for _, objective in pairs(quest.Objectives) do
        local objectiveMenu = {}
        if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
        else
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_FOCUS_OBJECTIVE'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusObjective(quest, objective); QuestieQuest:UpdateHiddenNotes() end})
        end
        table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
            LQuestie_CloseDropDownMenus()
            local spawn, zone, name = QuestieMap:GetNearestSpawn(objective)
            if spawn then
                QuestieTrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
            end
        end})
        if objective.HideIcons then
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
                LQuestie_CloseDropDownMenus()
                objective.HideIcons = nil;
                QuestieQuest:UpdateHiddenNotes()
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = nil
            end})
        else
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
                LQuestie_CloseDropDownMenus()
                objective.HideIcons = true;
                QuestieQuest:UpdateHiddenNotes()
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = true
            end})
        end

        table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
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
            QuestieTrackerUtils:ShowObjectiveOnMap(objective)
        end})

        table.insert(subMenu, {text = objective.Description, hasArrow = true, menuList = objectiveMenu})
    end

    if quest.SpecialObjectives then
        for _,Objective in pairs(quest.SpecialObjectives) do
            local objectiveMenu = {}

            if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(Objective.Index) then
                table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
            else
                table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_FOCUS_OBJECTIVE'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusObjective(quest, Objective, true); QuestieQuest:UpdateHiddenNotes() end})
            end
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
                LQuestie_CloseDropDownMenus()
                local spawn, zone, name = QuestieMap:GetNearestSpawn(Objective)
                if spawn then
                    QuestieTrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
                end
            end})
            if Objective.HideIcons then
                table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
                    LQuestie_CloseDropDownMenus()
                    Objective.HideIcons = nil;
                    QuestieQuest:UpdateHiddenNotes()
                    Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(Objective.Index)] = nil
                end})
            else
                table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
                    LQuestie_CloseDropDownMenus()
                    Objective.HideIcons = true;
                    QuestieQuest:UpdateHiddenNotes()
                    Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(Objective.Index)] = true
                end})
            end

            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
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
                QuestieTrackerUtils:ShowObjectiveOnMap(Objective)
            end})

            table.insert(subMenu, {text = Objective.Description, hasArrow = true, menuList = objectiveMenu})
        end
    end

    table.insert(menu, {text=quest:GetColoredQuestName(), isTitle = true})
    if not QuestieQuest:IsComplete(quest) then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_OBJECTIVES'), hasArrow = true, menuList = subMenu})
    end
    if quest.HideIcons then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function()
            quest.HideIcons = nil
            QuestieQuest:UpdateHiddenNotes()
            Questie.db.char.TrackerHiddenQuests[quest.Id] = nil
        end})
    else
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
            quest.HideIcons = true
            QuestieQuest:UpdateHiddenNotes()
            Questie.db.char.TrackerHiddenQuests[quest.Id] = true
        end})
    end
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function()
        LQuestie_CloseDropDownMenus()
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)
        if spawn then
            QuestieTrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    end})
    if QuestieQuest:IsComplete(quest) then
        table.insert(menu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
            LQuestie_CloseDropDownMenus()
            QuestieTrackerUtils:ShowFinisherOnMap(quest)
        end})
    end
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG'), func = function()
        LQuestie_CloseDropDownMenus()
        QuestieTrackerUtils:ShowQuestLog(quest)
    end})
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNTRACK'), func = function()
        LQuestie_CloseDropDownMenus();
        if GetCVar("autoQuestWatch") == "0" then
            Questie.db.char.TrackedQuests[quest.Id] = nil
        else
            Questie.db.char.AutoUntrackedQuests[quest.Id] = true
        end
        QuestieTracker:Update()
    end})
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
    else
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_FOCUS_QUEST'), func = function() LQuestie_CloseDropDownMenus(); QuestieTracker:FocusQuest(quest); QuestieQuest:UpdateHiddenNotes()  end})
    end
    if Questie.db.global.trackerLocked then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNLOCK'), func = function() LQuestie_CloseDropDownMenus(); Questie.db.global.trackerLocked = false end})
    else
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_LOCK'), func = function() LQuestie_CloseDropDownMenus(); Questie.db.global.trackerLocked = true end})
    end
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_CANCEL'), func = function() end})

    return menu
end