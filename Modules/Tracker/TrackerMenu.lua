---@class TrackerMenu
local TrackerMenu = QuestieLoader:CreateModule("TrackerMenu")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

TrackerMenu.menuFrame = LibDropDown:Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

local tinsert = table.insert

-- Create local Quest Menu functions
TrackerMenu.addFocusOption = function(menu, quest, objective)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
        tinsert(menu, {
            text = l10n('Unfocus'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                TrackerUtils:UnFocus()
                QuestieQuest:ToggleNotes(true)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Focus Objective'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                TrackerUtils:FocusObjective(quest.Id, objective.Index)
                QuestieQuest:ToggleNotes(false)
            end
        })
    end
end

TrackerMenu.addTomTomOption = function(menu, quest, objective)
    tinsert(menu, {
        text = l10n('Set |cFF54e33bTomTom|r Target'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)
            if (not spawn) and objective ~= nil then
                spawn, zone, name = QuestieMap:GetNearestSpawn(objective)
            end

            if spawn then
                TrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
            end
        end
    })
end

TrackerMenu.minMaxQuestOption = function(menu, quest)
    if Questie.db.char.collapsedQuests[quest.Id] then
        tinsert(menu, {
            text = l10n('Maximize Quest'),
            func = function()
                Questie.db.char.collapsedQuests[quest.Id] = false

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Minimize Quest'),
            func = function()
                Questie.db.char.collapsedQuests[quest.Id] = true

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
            end
        })
    end
end

TrackerMenu.addShowHideObjectivesOption = function(menu, quest, objective)
    if objective.HideIcons then
        tinsert(menu, {
            text = l10n('Show Icons'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                objective.HideIcons = nil
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = nil
                QuestieQuest:ToggleNotes(true)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Hide Icons'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                objective.HideIcons = true
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = true
                QuestieQuest:ToggleNotes(false)
            end
        })
    end
end

TrackerMenu.addShowHideQuestsOption = function(menu, quest)
    if quest.HideIcons then
        tinsert(menu, {
            text = l10n('Show Icons'),
            func = function()
                quest.HideIcons = nil
                Questie.db.char.TrackerHiddenQuests[quest.Id] = nil
                QuestieQuest:ToggleNotes(true)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Hide Icons'),
            func = function()
                quest.HideIcons = true
                Questie.db.char.TrackerHiddenQuests[quest.Id] = true
                QuestieQuest:ToggleNotes(false)
            end
        })
    end
end

TrackerMenu.addShowObjectivesOnMapOption = function(menu, quest, objective)
    tinsert(menu, {
        text = l10n('Show on Map'),
        func = function()
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
        end
    })
end

TrackerMenu.addShowFinisherOnMapOption = function(menu, quest)
    if quest:IsComplete() == 1 then
        tinsert(menu, {
            text = l10n('Show on Map'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                TrackerUtils:ShowFinisherOnMap(quest)
            end
        })
    end
end

TrackerMenu.addObjectiveOption = function(menu, subMenu, quest)
    if quest:IsComplete() == 0 then
        tinsert(menu, { text = l10n('Objectives'), hasArrow = true, menuList = subMenu })
    end
end

TrackerMenu.addLinkToChatOption = function(menu, quest)
    tinsert(menu, {
        text = l10n('Link Quest to chat'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            if (not ChatFrame1EditBox:IsVisible()) then
                if Questie.db.global.trackerShowQuestLevel then
                    ChatFrame_OpenChat(QuestieLink:GetQuestLinkString(quest.level, quest.name, quest.Id))
                else
                    ChatFrame_OpenChat("[" .. quest.name .. " (" .. quest.Id .. ")]")
                end
            else
                if Questie.db.global.trackerShowQuestLevel then
                    ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(quest.level, quest.name, quest.Id))
                else
                    ChatEdit_InsertLink("[" .. quest.name .. " (" .. quest.Id .. ")]")
                end
            end
        end
    })
end

TrackerMenu.addShowInQuestLogOption = function(menu, quest)
    tinsert(menu, {
        text = l10n('Show in Quest Log'),
        func = function()
            LibDropDown:CloseDropDownMenus()
            TrackerUtils:ShowQuestLog(quest)
        end
    })
end

TrackerMenu.addAbandonedQuest = function(menu, quest)
    tinsert(menu, {
        text = l10n('Abandon Quest'),
        func = function()
            LibDropDown:CloseDropDownMenus()
            local lastQuest = GetQuestLogSelection()
            SelectQuestLogEntry(GetQuestLogIndexByID(quest.Id))
            SetAbandonQuest()

            local items = GetAbandonQuestItems()
            if items then
                StaticPopup_Hide("ABANDON_QUEST")
                StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items)
            else
                StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
                StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName())
            end

            SelectQuestLogEntry(lastQuest)
            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame

            if questLogFrame:IsShown() then
                QuestLog_Update()
            end
        end
    })
end

TrackerMenu.addUntrackOption = function(menu, quest)
    tinsert(menu, {
        text = l10n('Untrack Quest'),
        func = function()
            LibDropDown:CloseDropDownMenus()
            QuestieTracker:UntrackQuestId(quest.Id)
            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame

            if questLogFrame:IsShown() then
                QuestLog_Update()
            end
        end
    })
end

TrackerMenu.addFocusUnfocusOption = function(menu, quest)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then
        tinsert(menu, {
            text = l10n('Unfocus'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                TrackerUtils:UnFocus()
                QuestieQuest:ToggleNotes(true)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Focus Quest'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                TrackerUtils:FocusQuest(quest.Id)
                QuestieQuest:ToggleNotes(false)
            end
        })
    end
end

TrackerMenu.addLockUnlockOption = function(menu)
    if Questie.db.global.trackerLocked then
        tinsert(menu, {
            text = l10n('Unlock Tracker'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                Questie.db.global.trackerLocked = false
                TrackerBaseFrame:Update()
            end
        })
    else
        tinsert(menu, {
            text = l10n('Lock Tracker'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                Questie.db.global.trackerLocked = true
                TrackerBaseFrame:Update()
            end
        })
    end
end

-- Register the Wowhead Quest popup dialog
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
        local questID = self.text.text_arg1
        local quest_wow = QuestieDB:GetQuest(questID)
        local name = quest_wow.name

        -- self.text:SetText(self.text:GetText() .. "\n\n|cffff7f00" .. name .. "|r")
        self.text:SetFont("GameFontNormal", 12)
        -- self.text:SetText(self.text:GetText() .. "\n\n|c FFFFB9 00" .. name .. "|r")
        self.text:SetText(self.text:GetText() .. Questie:Colorize("\n\n" .. name, "gold"))

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

        self.editBox:SetText(wowheadLink)
        self.editBox:SetFocus()
        self.editBox:HighlightText()
    end,
    whileDead = true,
    hideOnEscape = true
}

-- Create Quest Menu
function TrackerMenu:GetMenuForQuest(quest)
    local menu = {}
    local subMenu = {}

    for _, objective in pairs(quest.Objectives) do
        local objectiveMenu = {}

        TrackerMenu.addFocusOption(objectiveMenu, quest, objective)
        TrackerMenu.addTomTomOption(objectiveMenu, nil, objective)
        TrackerMenu.addShowHideObjectivesOption(objectiveMenu, quest, objective)
        TrackerMenu.addShowObjectivesOnMapOption(objectiveMenu, quest, objective)

        tinsert(subMenu, { text = objective.Description, hasArrow = true, menuList = objectiveMenu })
    end

    if next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local objectiveMenu = {}

            TrackerMenu.addFocusOption(objectiveMenu, quest, objective)
            TrackerMenu.addTomTomOption(objectiveMenu, nil, objective)
            TrackerMenu.addShowHideObjectivesOption(objectiveMenu, quest, objective)
            TrackerMenu.addShowObjectivesOnMapOption(objectiveMenu, quest, objective)

            tinsert(subMenu, { text = objective.Description, hasArrow = true, menuList = objectiveMenu })
        end
    end

    local coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.enableTooltipsQuestLevel, true, true)

    tinsert(menu, { text = coloredQuestName, isTitle = true })

    TrackerMenu.addObjectiveOption(menu, subMenu, quest)
    TrackerMenu.addFocusUnfocusOption(menu, quest)
    TrackerMenu.addTomTomOption(menu, quest, nil)
    TrackerMenu.minMaxQuestOption(menu, quest)
    TrackerMenu.addShowHideQuestsOption(menu, quest)
    TrackerMenu.addShowFinisherOnMapOption(menu, quest)
    TrackerMenu.addShowInQuestLogOption(menu, quest)
    TrackerMenu.addLinkToChatOption(menu, quest)
    TrackerMenu.addUntrackOption(menu, quest)
    TrackerMenu.addAbandonedQuest(menu, quest)

    tinsert(menu, {
        text = "|cFF39c0edWowhead URL|r",
        func = function()
            StaticPopup_Show("QUESTIE_WOWHEAD_URL", quest.Id)
        end
    })

    TrackerMenu.addLockUnlockOption(menu)

    tinsert(menu, {
        text = l10n('Cancel'),
        func = function()
        end
    })

    return menu
end

-- Create local Achievement Menu functions
TrackerMenu.addAchieveLinkToChatOption = function(menu, achieve)
    tinsert(menu, {
        text = l10n('Link Achievement to chat'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            if (not ChatFrame1EditBox:IsVisible()) then
                ChatFrame_OpenChat(GetAchievementLink(achieve.Id))
            else
                ChatEdit_InsertLink(GetAchievementLink(achieve.Id))
            end
        end
    })
end

TrackerMenu.addShowInAchievementsOption = function(menu, achieve)
    tinsert(menu, {
        text = l10n('Show in Achievements Log'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            if (not AchievementFrame) then
                AchievementFrame_LoadUI()
            end

            if (not AchievementFrame:IsShown()) then
                AchievementFrame_ToggleAchievementFrame()
                AchievementFrame_SelectAchievement(achieve.Id)
            else
                if (AchievementFrameAchievements.selection ~= achieve.Id) then
                    AchievementFrame_SelectAchievement(achieve.Id)
                end
            end
        end
    })
end

TrackerMenu.addUntrackAchieveOption = function(menu, achieve)
    tinsert(menu, {
        text = l10n('Untrack Achievement'),
        func = function()
            LibDropDown:CloseDropDownMenus()
            QuestieTracker:UntrackAchieveId(achieve.Id)
            QuestieTracker:UpdateAchieveTrackerCache(achieve.Id)

            if (not AchievementFrame) then
                AchievementFrame_LoadUI()
            end

            AchievementFrameAchievements_ForceUpdate()

            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end
    })
end

-- Register the Wowhead Achievement popup dialog
StaticPopupDialogs["QUESTIE_WOWHEAD_AURL"] = {
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
        local achieveID = self.text.text_arg1
        local name = select(2, GetAchievementInfo(achieveID))

        self.text:SetFont("GameFontNormal", 12)
        self.text:SetText(self.text:GetText() .. Questie:Colorize("\n\n" .. name, "gold"))

        local langShort = string.sub(l10n:GetUILocale(), 1, 2) .. "."
        if langShort == "en." then
            langShort = ""
        end

        local wowheadLink
        if langShort then
            langShort = langShort:gsub("%.", "/") -- The Wotlk wowhead URL differs to the other Classic URLs
        end

        wowheadLink = "https://" .. "wowhead.com/wotlk/" .. langShort .. "achievement=" .. achieveID

        self.editBox:SetText(wowheadLink)
        self.editBox:SetFocus()
        self.editBox:HighlightText()
    end,
    whileDead = true,
    hideOnEscape = true
}

-- Create Achievement Menu
function TrackerMenu:GetMenuForAchievement(achieve)
    local menu = {}
    tinsert(menu, { text = "|cFFFFFF00" .. select(2, GetAchievementInfo(achieve.Id)) .. "|r", isTitle = true })

    TrackerMenu.addAchieveLinkToChatOption(menu, achieve)
    TrackerMenu.addShowInAchievementsOption(menu, achieve)

    for trackedId, _ in pairs(Questie.db.char.trackedAchievementIds) do
        if trackedId == achieve.Id then
            TrackerMenu.addUntrackAchieveOption(menu, achieve)
        end
    end

    tinsert(menu, {
        text = "|cFF39c0edWowhead URL|r",
        func = function()
            StaticPopup_Show("QUESTIE_WOWHEAD_AURL", achieve.Id)
        end
    })

    TrackerMenu.addLockUnlockOption(menu)

    tinsert(menu, {
        text = l10n('Cancel'),
        func = function()
        end
    })

    return menu
end
