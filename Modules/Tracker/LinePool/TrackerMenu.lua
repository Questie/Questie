---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

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
---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type TrackerMapEligibility
local TrackerMapEligibility = QuestieLoader:ImportModule("TrackerMapEligibility")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

TrackerMenu.menuFrame = LibDropDown:Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

local tinsert = table.insert

-- Commands recheck the snapshot and original-object identity before any map mutation. A menu can
-- stay open across quest removal, objective replacement or a change in verified enrichment.
local function _GetCurrentMapCapabilities(expectedQuest, expectedObjective)
    if not expectedQuest then
        return
    end
    local current = TrackerData.RefreshQuest(expectedQuest.Id)
    local capabilities = TrackerMapEligibility.GetCapabilities(current)
    if capabilities.quest ~= expectedQuest or (expectedObjective and not capabilities.objectives[expectedObjective]) then
        return
    end
    return current, capabilities
end

-- Recovery actions: Unfocus and quest Show Icons. They only clear state the quest already has, so they skip
-- the map checks above. Otherwise a quest that loses eligibility while focused or hidden, e.g. by completing
-- with no finisher in the database, would stay that way.

---True when the saved focus is this quest or one of its objectives.
---Saved focus is a quest ID, or a "questId objectiveIndex" string for objective focus.
---@param questId QuestId
---@return boolean
local function _IsFocusedOnQuest(questId)
    local focus = Questie.db.char.TrackerFocus
    if type(focus) == "number" then
        return focus == questId
    elseif type(focus) == "string" then
        return tonumber(focus:match("^(%d+) ")) == questId
    end
    return false
end

---@param menu table
---@param isStillFocused fun(): boolean Rechecked on click; an open menu can outlive the focus it showed.
local function _AddUnfocusEntry(menu, isStillFocused)
    tinsert(menu, {
        text = l10n('Unfocus'),
        func = function()
            LibDropDown:CloseDropDownMenus()
            if not isStillFocused() then
                return
            end
            TrackerUtils:UnFocus()
            QuestieQuest:ToggleNotes(true)
        end
    })
end

-- Create local Quest Menu functions
---@param menu table
---@param quest Quest
---@param objective QuestObjective
TrackerMenu.addFocusOption = function(menu, quest, objective)
    local focusKey = tostring(quest.Id) .. " " .. tostring(objective.Index)
    if Questie.db.char.TrackerFocus == focusKey then
        _AddUnfocusEntry(menu, function() return Questie.db.char.TrackerFocus == focusKey end)
    else
        tinsert(menu, {
            text = l10n('Focus Objective'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                if TrackerUtils:FocusObjective(quest.Id, objective.Index, objective, quest) then
                    QuestieQuest:ToggleNotes(false)
                end
            end
        })
    end
end

---@param menu table
---@param quest Quest
TrackerMenu.addTomTomOptionForQuest = function(menu, quest)
    local expectedQuest = quest.enrichment
    tinsert(menu, {
        text = l10n('Set |cFF54e33bTomTom|r Target'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            TrackerUtils.SetQuestTomTomTarget(quest.Id, expectedQuest)
        end
    })
end

---@param menu table
---@param quest Quest Original enriched quest.
---@param objective QuestObjective
TrackerMenu.addTomTomOptionForObjective = function(menu, quest, objective)
    tinsert(menu, {
        text = l10n('Set |cFF54e33bTomTom|r Target'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            if not _GetCurrentMapCapabilities(quest, objective) then
                return
            end
            local spawn, zone, name = DistanceUtils.GetNearestObjective(objective.spawnList)
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
                -- Unlike quest Show Icons, keep the identity check. The saved key is the original index, which
                -- a replacement objective can reuse; a stale menu must not clear the replacement's state.
                local _, capabilities = _GetCurrentMapCapabilities(quest, objective)
                if not capabilities or capabilities.focusObjectives[objective.Index] ~= objective then
                    return
                end
                objective.HideIcons = nil
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = nil
                QuestieQuest.ToggleQuestNotes(true)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Hide Icons'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                local _, capabilities = _GetCurrentMapCapabilities(quest, objective)
                if not capabilities or capabilities.focusObjectives[objective.Index] ~= objective then
                    return
                end
                objective.HideIcons = true
                Questie.db.char.TrackerHiddenObjectives[tostring(quest.Id) .. " " .. tostring(objective.Index)] = true
                QuestieQuest.ToggleQuestNotes(false)
            end
        })
    end
end

TrackerMenu.addShowHideQuestsOption = function(menu, quest)
    if quest.HideIcons then
        tinsert(menu, {
            text = l10n('Show Icons'),
            func = function()
                -- Recovery action: clearing hidden state needs no eligibility check.
                quest.HideIcons = nil
                Questie.db.char.TrackerHiddenQuests[quest.Id] = nil
                QuestieQuest.ToggleQuestNotes(true)
            end
        })
    else
        tinsert(menu, {
            text = l10n('Hide Icons'),
            func = function()
                local _, capabilities = _GetCurrentMapCapabilities(quest)
                if not capabilities or not capabilities.canFocusQuest then
                    return
                end
                quest.HideIcons = true
                Questie.db.char.TrackerHiddenQuests[quest.Id] = true
                QuestieQuest.ToggleQuestNotes(false)
            end
        })
    end
end

TrackerMenu.addShowObjectivesOnMapOption = function(menu, quest, objective)
    tinsert(menu, {
        text = l10n('Show on Map'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            if not _GetCurrentMapCapabilities(quest, objective) then
                return
            end
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
                QuestieQuest.ToggleQuestNotes(true)
            end

            TrackerUtils:ShowObjectiveOnMap(objective)
        end
    })
end

TrackerMenu.addShowFinisherOnMapOption = function(menu, quest)
    tinsert(menu, {
        text = l10n('Show on Map'),
        func = function()
            LibDropDown:CloseDropDownMenus()
            local _, capabilities = _GetCurrentMapCapabilities(quest)
            if capabilities and capabilities.canShowFinisher then
                TrackerUtils:ShowFinisherOnMap(quest)
            end
        end
    })
end

TrackerMenu.addObjectiveOption = function(menu, subMenu, quest)
    if quest:IsComplete() == 0 and not quest.isComplete and #subMenu > 0 then
        tinsert(menu, { text = l10n('Objectives'), hasArrow = true, menuList = subMenu })
    end
end

TrackerMenu.addLinkToChatOption = function(menu, quest)
    tinsert(menu, {
        text = l10n('Link Quest to chat'),
        func = function()
            LibDropDown:CloseDropDownMenus()

            if (not ChatFrame1EditBox:IsVisible()) then
                ChatFrame_OpenChat(TrackerData.GetQuestLink(quest))
            else
                ChatEdit_InsertLink(TrackerData.GetQuestLink(quest))
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
            local lastQuest = QuestieCompat.GetQuestLogSelection()
            QuestieCompat.SelectQuestLogEntry(QuestieCompat.GetQuestLogIndexByID(quest.Id))
            QuestieCompat.SetAbandonQuest()

            local items = QuestieCompat.GetAbandonQuestItems()
            if items then
                StaticPopup_Hide("ABANDON_QUEST")
                StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", QuestieCompat.GetAbandonQuestName(), items)
            else
                StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
                StaticPopup_Show("ABANDON_QUEST", QuestieCompat.GetAbandonQuestName())
            end

            QuestieCompat.SelectQuestLogEntry(lastQuest)
            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame

            if questLogFrame and questLogFrame:IsShown() then
                QuestieCompat.QuestLog_Update()
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

            if questLogFrame and questLogFrame:IsShown() then
                QuestieCompat.QuestLog_Update()
            end
        end
    })
end

TrackerMenu.addFocusUnfocusOption = function(menu, quest)
    if Questie.db.char.TrackerFocus == quest.Id then
        _AddUnfocusEntry(menu, function() return Questie.db.char.TrackerFocus == quest.Id end)
    else
        tinsert(menu, {
            text = l10n('Focus Quest'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                if TrackerUtils:FocusQuest(quest.Id, quest) then
                    QuestieQuest:ToggleNotes(false)
                end
            end
        })
    end
end

TrackerMenu.addLockUnlockOption = function(menu)
    if Questie.db.profile.trackerLocked then
        tinsert(menu, {
            text = l10n('Unlock Tracker'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                Questie.db.profile.trackerLocked = false
                TrackerBaseFrame:Update()
            end
        })
    else
        tinsert(menu, {
            text = l10n('Lock Tracker'),
            func = function()
                LibDropDown:CloseDropDownMenus()
                Questie.db.profile.trackerLocked = true
                TrackerBaseFrame:Update()
            end
        })
    end
end

local function _GetWowheadLinkForLanguage()
    local langShort = string.sub(GetLocale(), 1, 2) .. "/"
    if langShort == "en/" then
        langShort = ""
    elseif langShort == "zh/" then
        langShort = "cn/"
    end

    local xpac
    if Questie.IsForever then
        xpac = "forever/"
    elseif Questie.IsMoP then
        xpac = "mop-classic/"
    elseif Questie.IsCata then
        xpac = "cata/"
    elseif Questie.IsWotlk then
        xpac = "wotlk/"
    elseif Questie.IsTBC then
        xpac = "tbc/"
    else
        xpac = "classic/" -- era/sod/hardcore are all on this URL
    end

    return "https://www.wowhead.com/".. xpac .. langShort
end

-- The generation check stops an old Ctrl+C timer from closing a reopened dialog (#7867)
---@param dialog DialogFrame
---@param name string?
---@param link string
local function _ShowWowheadLink(dialog, name, link)
    if name then
        dialog.Text:SetText(dialog.Text:GetText() .. Questie:Colorize("\n\n" .. name, "gold"))
    end

    local editBox = dialog:GetEditBox()
    editBox:SetText(link)
    -- Focusing from addon code while SmartNavigation is shown taints Blizzard's controller bindings
    if Questie.IsForever and SmartNavigation and SmartNavigation:IsShown() then
        editBox:SetScript("OnEditFocusGained", editBox.HighlightText)
    else
        editBox:SetScript("OnEditFocusGained", nil)
        editBox:SetFocus()
        editBox:HighlightText()
    end

    editBox:SetScript("OnKeyDown", function(_, key)
        if key == "C" and IsControlKeyDown() then
            local generation = dialog.generation
            C_Timer.After(0.1, function()
                if dialog.generation == generation and dialog.active and dialog:IsShown() then
                    dialog:Hide()
                    QuestieCompat.ActionStatus_DisplayMessage(l10n("Copied URL to clipboard"), true)
                end
            end)
        end
    end)
end

-- Showing the dialog in combat is blocked (SetPropagateKeyboardInput), so it opens after combat
---@param key string
---@param id number
local function _ShowWowheadDialog(key, id)
    if InCombatLockdown() then
        QuestieCombatQueue:Queue(Popup.Show, key, id)
    else
        Popup.Show(key, id)
    end
end

-- Register the WoWHead Quest popup dialog
Popup.Dialogs["QUESTIE_WOWHEAD_URL"] = {
    text = "WoWHead URL",
    button2 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 280,
    EditBoxOnEnterPressed = function(editBox)
        editBox:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(editBox)
        editBox:GetParent():Hide()
    end,
    OnShow = function(dialog)
        local questId = dialog.Text.text_arg1
        local quest = TrackerData.GetQuest(tonumber(questId))
        -- all expansions follow this system as of 2024 start of Cata
        _ShowWowheadLink(dialog, quest and quest.name, _GetWowheadLinkForLanguage() .. "quest=" .. questId)
    end,
    whileDead = true,
    hideOnEscape = true
}

-- Create Quest Menu
function TrackerMenu:GetMenuForQuest(quest)
    local menu = {}
    local subMenu = {}

    local capabilities = TrackerMapEligibility.GetCapabilities(quest)
    local enrichedQuest = capabilities.quest
    for _, objective in pairs(quest.Objectives) do
        local enrichedObjective = objective.enrichment
        if capabilities.objectives[enrichedObjective] then
            local objectiveMenu = {}

            -- Map actions mutate the original objective, never the display snapshot.
            if capabilities.focusObjectives[enrichedObjective.Index] == enrichedObjective then
                TrackerMenu.addFocusOption(objectiveMenu, enrichedQuest, enrichedObjective)
            end
            TrackerMenu.addTomTomOptionForObjective(objectiveMenu, enrichedQuest, enrichedObjective)
            if capabilities.focusObjectives[enrichedObjective.Index] == enrichedObjective then
                TrackerMenu.addShowHideObjectivesOption(objectiveMenu, enrichedQuest, enrichedObjective)
            end
            TrackerMenu.addShowObjectivesOnMapOption(objectiveMenu, enrichedQuest, enrichedObjective)

            tinsert(subMenu, { text = objective.Description, hasArrow = true, menuList = objectiveMenu })
        end
    end

    -- TrackerData exposes special objectives only when the live objectives matched.
    if enrichedQuest then
        for _, objective in pairs(quest.SpecialObjectives) do
            if capabilities.objectives[objective] then
                local objectiveMenu = {}

                if capabilities.focusObjectives[objective.Index] == objective then
                    TrackerMenu.addFocusOption(objectiveMenu, enrichedQuest, objective)
                end
                TrackerMenu.addTomTomOptionForObjective(objectiveMenu, enrichedQuest, objective)
                if capabilities.focusObjectives[objective.Index] == objective then
                    TrackerMenu.addShowHideObjectivesOption(objectiveMenu, enrichedQuest, objective)
                end
                TrackerMenu.addShowObjectivesOnMapOption(objectiveMenu, enrichedQuest, objective)

                tinsert(subMenu, { text = objective.Description, hasArrow = true, menuList = objectiveMenu })
            end
        end
    end

    local coloredQuestName = TrackerData.GetColoredQuestName(quest, Questie.db.profile.enableTooltipsQuestLevel, true)

    tinsert(menu, { text = coloredQuestName, isTitle = true })

    TrackerMenu.addObjectiveOption(menu, subMenu, quest)
    if capabilities.canFocusQuest then
        TrackerMenu.addFocusUnfocusOption(menu, enrichedQuest)
    elseif _IsFocusedOnQuest(quest.Id) then
        -- Lost eligibility while focused. A completed quest has no objective menus, so objective focus is cleared here too.
        _AddUnfocusEntry(menu, function() return _IsFocusedOnQuest(quest.Id) end)
    end
    if capabilities.canNavigateQuest then
        TrackerMenu.addTomTomOptionForQuest(menu, quest)
    end
    TrackerMenu.minMaxQuestOption(menu, quest)
    -- An ineligible hidden quest still gets Show Icons; it never gets Hide Icons.
    if capabilities.canFocusQuest or (enrichedQuest and enrichedQuest.HideIcons) then
        TrackerMenu.addShowHideQuestsOption(menu, enrichedQuest)
    end
    if capabilities.canShowFinisher then
        TrackerMenu.addShowFinisherOnMapOption(menu, enrichedQuest)
    end
    TrackerMenu.addShowInQuestLogOption(menu, quest)
    TrackerMenu.addLinkToChatOption(menu, quest)
    TrackerMenu.addUntrackOption(menu, quest)
    TrackerMenu.addAbandonedQuest(menu, quest)

    tinsert(menu, {
        text = "|cFF39c0edWoWHead URL|r",
        func = function()
            _ShowWowheadDialog("QUESTIE_WOWHEAD_URL", quest.Id)
        end
    })

    TrackerMenu.addLockUnlockOption(menu)

    tinsert(menu, {
        text = CANCEL,
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
                QuestieCompat.AchievementFrame_ToggleAchievementFrame()
                QuestieCompat.AchievementFrame_SelectAchievement(achieve.Id)
            else
                if (AchievementFrameAchievements.selection ~= achieve.Id) then
                    QuestieCompat.AchievementFrame_SelectAchievement(achieve.Id)
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

            QuestieCompat.AchievementFrameAchievements_ForceUpdate()

            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end
    })
end

-- Register the WoWHead Achievement popup dialog
Popup.Dialogs["QUESTIE_WOWHEAD_AURL"] = {
    text = "WoWHead URL",
    button2 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 280,
    EditBoxOnEnterPressed = function(editBox)
        editBox:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(editBox)
        editBox:GetParent():Hide()
    end,
    OnShow = function(dialog)
        local achieveId = dialog.Text.text_arg1
        local name = select(2, GetAchievementInfo(achieveId))
        _ShowWowheadLink(dialog, name, _GetWowheadLinkForLanguage() .. "achievement=" .. achieveId)
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
        text = "|cFF39c0edWoWHead URL|r",
        func = function()
            _ShowWowheadDialog("QUESTIE_WOWHEAD_AURL", achieve.Id)
        end
    })

    TrackerMenu.addLockUnlockOption(menu)

    tinsert(menu, {
        text = CANCEL,
        func = function()
        end
    })

    return menu
end
