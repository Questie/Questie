---@class TrackerLine
local TrackerLine = QuestieLoader:CreateModule("TrackerLine")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker") -- TODO: Remove this explicit depenency
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LSM30 = LibStub("LibSharedMedia-3.0")
local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local _SetMode, _OnClickQuest, _OnClickAchieve

local lineMarginLeft = 10

---@param index number
---@param parent ScrollFrame
---@param previousLine|nil LineFrame
---@param OnEnter function @Callback function for OnEnter
---@param OnLeave function @Callback function for OnLeave
---@param OnQuestAdded function @Callback function for SetQuest
function TrackerLine.Create(index, parent, previousLine, OnEnter, OnLeave, OnQuestAdded)
    local timeElapsed = 0
    local line = CreateFrame("Button", "linePool" .. index, parent)
    line:SetWidth(1)
    line:SetHeight(1)
    line.label = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line.label:SetJustifyH("LEFT")
    line.label:SetJustifyV("TOP")
    line.label:SetPoint("TOPLEFT", line)
    line.label:Hide()

    -- autoadjust parent size for clicks
    line.label._SetText = line.label.SetText
    line.label.frame = line
    line.label.SetText = function(self, text)
        self:_SetText(text)
        if (not InCombatLockdown()) then
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end
    end

    if previousLine then
        line:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, 0)
    else
        line:SetPoint("TOPLEFT", parent, "TOPLEFT", lineMarginLeft, 0)
    end

    line.SetMode = _SetMode

    function line:SetZone(ZoneId)
        if type(ZoneId) == "string" then
            self.expandZone.zoneId = ZoneId
        elseif type(ZoneId) == "number" then
            self.ZoneId = TrackerUtils:GetZoneNameByID(ZoneId)
            self.expandZone.zoneId = ZoneId
        end
    end

    function line:SetQuest(Quest)
        if type(Quest) == "number" then
            Quest = {
                Id = Quest
            }
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        else
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        end

        OnQuestAdded(Quest.Id, self)

        -- Set Timed Quest Flag
        if Quest.trackTimedQuest then
            self.trackTimedQuest = Quest.trackTimedQuest
        end
    end

    function line:SetObjective(Objective)
        self.Objective = Objective
    end

    function line:OnUpdate(elapsed)
        if Questie.IsWotlk or Questie.IsCata then
            timeElapsed = timeElapsed + elapsed

            if timeElapsed > 1 and self.trackTimedQuest and self.label.activeTimer then
                local _, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(self.Quest.Id)

                if timeRemaining ~= nil then
                    if timeRemaining > 1 then
                        TrackerQuestTimers:UpdateTimerFrame()
                    end

                    if timeRemaining == 1 then
                        TrackerQuestTimers:UpdateTimerFrame()
                    end

                    timeElapsed = 0
                else
                    timeElapsed = 0
                    return
                end
            end
        else
            return
        end
    end

    function line:SetVerticalPadding(amount)
        if self.mode == "zone" then
            self:SetHeight(Questie.db.profile.trackerFontSizeZone + amount)
        elseif self.mode == "quest" or "achieve" then
            self:SetHeight(Questie.db.profile.trackerFontSizeQuest + amount)
        else
            self:SetHeight(Questie.db.profile.trackerFontSizeObjective + amount)
        end
    end

    line:EnableMouse(true)
    line:RegisterForDrag("LeftButton")
    line:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    function line:SetOnClick(onClickmode)
        if onClickmode == "quest" then
            self:SetScript("OnClick", _OnClickQuest)
        elseif onClickmode == "achieve" then
            self:SetScript("OnClick", _OnClickAchieve)
        end
    end

    line:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    line:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)

    line:SetScript("OnEnter", function(self)
        OnEnter(self)
        TrackerFadeTicker.Unfade()
    end)

    line:SetScript("OnLeave", function(self)
        OnLeave(self)
        TrackerFadeTicker.Fade()
    end)

    -- create objective complete criteria marks
    local criteriaMark = CreateFrame("Button", "linePool.criteriaMark" .. index, line)
    criteriaMark.texture = criteriaMark:CreateTexture(nil, "OVERLAY", nil, 0)
    criteriaMark.texture:SetWidth(Questie.db.profile.trackerFontSizeObjective)
    criteriaMark.texture:SetHeight(Questie.db.profile.trackerFontSizeObjective)
    criteriaMark.texture:SetAllPoints(criteriaMark)

    criteriaMark:SetWidth(1)
    criteriaMark:SetHeight(1)
    criteriaMark:SetPoint("RIGHT", line.label, "LEFT", -4, 0)
    criteriaMark:SetFrameLevel(100)

    function criteriaMark:SetCriteria(criteria)
        if criteria ~= self.mode then
            self.mode = criteria

            if criteria == true then
                self.texture:SetTexture("Interface\\Addons\\Questie\\Icons\\Checkmark")
                ---------------------------------------------------------------------
                -- Just in case we decide to show the minus sign for incompletes
                ---------------------------------------------------------------------
                --self.texture:SetAlpha(1)
                --else
                --self.texture:SetTexture("Interface\\Addons\\Questie\\Icons\\Minus")
                --self.texture:SetAlpha(0.5)
                ---------------------------------------------------------------------
            end

            self:SetWidth(Questie.db.profile.trackerFontSizeObjective)
            self:SetHeight(Questie.db.profile.trackerFontSizeObjective)
        end
    end

    criteriaMark:SetCriteria(false)
    criteriaMark:Hide()

    line.criteriaMark = criteriaMark

    -- create expanding zone headers for quests sorted by zones
    local expandZone = CreateFrame("Button", "linePool.expandZone" .. index, line)
    expandZone:SetWidth(1)
    expandZone:SetHeight(1)
    expandZone:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

    function expandZone:SetMode(mode)
        if mode ~= self.mode then
            self.mode = mode
        end
    end

    expandZone:SetMode(1) -- maximized
    expandZone:EnableMouse(true)
    expandZone:RegisterForDrag("LeftButton")
    expandZone:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown")

    expandZone:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                -- This sets up the minAllQuestsInZone table upon first click
                if not Questie.db.char.collapsedZones[self.zoneId] then
                    if not Questie.db.char.minAllQuestsInZone[self.zoneId] then
                        Questie.db.char.minAllQuestsInZone[self.zoneId] = {}
                        -- This flag prevents repopulating QuestID's where we don't want them.
                        Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue = true

                        QuestieCombatQueue:Queue(function()
                            QuestieTracker:Update()
                        end)
                    end
                end
            end
        end
    end)

    expandZone:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                if not Questie.db.char.collapsedZones[self.zoneId] then
                    C_Timer.After(0.1, function()
                        if Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue then
                            -- Places all QuestID's into the collapsedQuests table and keeps the Min/Max buttons in sync.
                            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:minAllQuestsInZone] - Minimize")
                            for questId, _ in pairs(Questie.db.char.minAllQuestsInZone[self.zoneId]) do
                                if type(questId) == "number" then
                                    Questie.db.char.collapsedQuests[questId] = true
                                end
                            end

                            Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue = nil
                        else
                            -- Removes all QuestID's from the collapsedQuests table.
                            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:minAllQuestsInZone] - Maximize")
                            for questId, _ in pairs(Questie.db.char.minAllQuestsInZone[self.zoneId]) do
                                if type(questId) == "number" then
                                    Questie.db.char.collapsedQuests[questId] = nil
                                end
                            end

                            Questie.db.char.minAllQuestsInZone[self.zoneId] = nil
                        end

                        QuestieCombatQueue:Queue(function()
                            QuestieTracker:Update()
                        end)
                    end)
                end
            else
                if self.mode == 1 then
                    self:SetMode(0)
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandZone] - Minimize")
                else
                    self:SetMode(1)
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandZone] - Maximize")
                end

                if Questie.db.char.collapsedZones[self.zoneId] == true then
                    Questie.db.char.collapsedZones[self.zoneId] = nil
                else
                    Questie.db.char.collapsedZones[self.zoneId] = true
                end

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
            end
        end
    end)

    expandZone:SetScript("OnEnter", function(self)
        OnEnter(self)
        TrackerFadeTicker.Unfade()
    end)

    expandZone:SetScript("OnLeave", function(self)
        OnLeave(self)
        TrackerFadeTicker.Fade()
    end)

    expandZone:Hide()

    line.expandZone = expandZone

    -- create play buttons for AI_VoiceOver
    local playButton = CreateFrame("Button", "linePool.playButton" .. index, line)
    playButton:SetWidth(20)
    playButton:SetHeight(20)
    playButton:SetHitRectInsets(2, 2, 2, 2)
    playButton:SetPoint("RIGHT", line.label, "LEFT", -4, 0)
    playButton:SetFrameLevel(0)
    playButton:SetNormalTexture("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton")
    playButton:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight")

    function playButton:SetPlayButton(questId)
        if questId ~= self.mode then
            self.mode = questId

            if questId and TrackerUtils:IsVoiceOverLoaded() then
                self:Show()
            else
                self.mode = nil
                self:SetAlpha(0)
                self:Hide()
            end
        end
    end

    playButton:EnableMouse(true)
    playButton:RegisterForClicks("LeftButtonUp")

    playButton:SetScript("OnClick", function(self)
        if self.mode ~= nil then
            if TrackerUtils:IsVoiceOverLoaded() then
                local button = VoiceOver.QuestOverlayUI.questPlayButtons[self.mode]
                if button then
                    if not VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData then
                        local type, id = VoiceOver.DataModules:GetQuestLogQuestGiverTypeAndID(self.mode)
                        local title = GetQuestLogTitle(GetQuestLogIndexByID(self.mode))
                        VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData = {
                            event = VoiceOver.Enums.SoundEvent.QuestAccept,
                            questID = self.mode,
                            name = id and VoiceOver.DataModules:GetObjectName(type, id) or "Unknown Name",
                            title = title,
                            unitGUID = id and VoiceOver.Enums.GUID:CanHaveID(type) and VoiceOver.Utils:MakeGUID(type, id) or nil
                        }
                    end

                    local soundData = VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData
                    local isPlaying = VoiceOver.SoundQueue:Contains(soundData)

                    if not isPlaying then
                        VoiceOver.SoundQueue:AddSoundToQueue(soundData)
                        VoiceOver.QuestOverlayUI:UpdatePlayButtonTexture(self.mode)

                        soundData.stopCallback = function()
                            VoiceOver.QuestOverlayUI:UpdatePlayButtonTexture(self.mode)
                            VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData = nil
                        end
                    else
                        VoiceOver.SoundQueue:RemoveSoundFromQueue(soundData)
                    end

                    isPlaying = button.soundData and VoiceOver.SoundQueue:Contains(button.soundData)
                    local texturePath = isPlaying and "Interface\\Addons\\Questie\\Icons\\QuestLogStopButton" or "Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton"
                    self:SetNormalTexture(texturePath)

                    -- Move the VoiceOverFrame below the DurabilityFrame if it's present and not already moved
                    if (Questie.db.profile.stickyDurabilityFrame and DurabilityFrame:IsVisible()) and select(5, VoiceOverFrame:GetPoint()) < -125 then
                        QuestieTracker:UpdateVoiceOverFrame()
                    end
                end
            end
        end
    end)

    playButton:SetAlpha(0)
    playButton:Hide()

    line.playButton = playButton
    local trackerFontSizeQuest = Questie.db.profile.trackerFontSizeQuest

    -- create expanding buttons for quests with objectives
    local expandQuest = CreateFrame("Button", "linePool.expandQuest" .. index, line)
    expandQuest.texture = expandQuest:CreateTexture(nil, "OVERLAY", nil, 0)
    expandQuest.texture:SetWidth(trackerFontSizeQuest)
    expandQuest.texture:SetHeight(trackerFontSizeQuest)
    expandQuest.texture:SetAllPoints(expandQuest)

    expandQuest:SetWidth(trackerFontSizeQuest)
    expandQuest:SetHeight(trackerFontSizeQuest)
    expandQuest:SetPoint("RIGHT", line, "LEFT", 0, 0)
    expandQuest:SetFrameLevel(100)

    function expandQuest:SetMode(mode)
        if mode ~= self.mode then
            self.mode = mode
            if mode == 1 then
                self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
            else
                self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
            end
            self:SetWidth(Questie.db.profile.trackerFontSizeQuest + 3)
            self:SetHeight(Questie.db.profile.trackerFontSizeQuest + 3)
        end
    end

    expandQuest:SetMode(1) -- maximized
    expandQuest:EnableMouse(true)
    expandQuest:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    expandQuest:SetScript("OnClick", function(self)
        if self.mode == 1 then
            self:SetMode(0)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandQuest] - Minimize")
        else
            self:SetMode(1)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:expandQuest] - Maximize")
        end
        if Questie.db.char.collapsedQuests[self.questId] then
            Questie.db.char.collapsedQuests[self.questId] = nil

            -- This keeps both tables in sync so we can use them to maintain Min/Max states.
            if Questie.db.char.minAllQuestsInZone[self.zoneId] and Questie.db.char.minAllQuestsInZone[self.zoneId][self.questId] then
                Questie.db.char.minAllQuestsInZone[self.zoneId][self.questId] = nil
            end
        else
            Questie.db.char.collapsedQuests[self.questId] = true

            -- This keeps both tables in sync so we can use them to maintain Min/Max states.
            if Questie.db.char.minAllQuestsInZone[self.zoneId] then
                Questie.db.char.minAllQuestsInZone[self.zoneId][self.questId] = true
            end
        end
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end)

    if Questie.IsWotlk or Questie.IsCata then
        line:HookScript("OnUpdate", line.OnUpdate)
    end

    if Questie.db.profile.trackerFadeMinMaxButtons then
        expandQuest:SetAlpha(0)
    end

    expandQuest:SetScript("OnEnter", function()
        TrackerFadeTicker.Unfade()
    end)

    expandQuest:SetScript("OnLeave", function()
        TrackerFadeTicker.Fade()
    end)

    expandQuest:Hide()

    line.expandQuest = expandQuest

    return line
end


---@param mode string
_SetMode = function(self, mode)
    if mode ~= self.mode then
        self.mode = mode
        if mode == "zone" then
            local trackerFontSizeZone = Questie.db.profile.trackerFontSizeZone
            self.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontZone), trackerFontSizeZone, Questie.db.profile.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeZone)
        elseif mode == "quest" or mode == "achieve" then
            local trackerFontSizeQuest = Questie.db.profile.trackerFontSizeQuest
            self.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontQuest), trackerFontSizeQuest, Questie.db.profile.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeQuest)
        elseif mode == "objective" then
            local trackerFontSizeObjective = Questie.db.profile.trackerFontSizeObjective
            self.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontObjective), trackerFontSizeObjective, Questie.db.profile.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeObjective)
        end
    end
end


---@param button string
_OnClickQuest = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:_OnClickQuest]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindSetTomTom, button) then
        local spawn, zone, name = DistanceUtils.GetNearestSpawnForQuest(self.Quest)
        if spawn then
            TrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            if Questie.db.profile.trackerShowQuestLevel then
                ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(self.Quest.level, self.Quest.name, self.Quest.Id))
            else
                ChatEdit_InsertLink("[" .. self.Quest.name .. " (" .. self.Quest.Id .. ")]")
            end
        else
            QuestieTracker:UntrackQuestId(self.Quest.Id)
            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
            if questLogFrame:IsShown() then
                QuestLog_Update()
            end
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindOpenQuestLog, button) then
        TrackerUtils:ShowQuestLog(self.Quest)
    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForQuest(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0, 0, "MENU")
    end
end

---@param button string
_OnClickAchieve = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLine:_OnClickAchieve]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            ChatEdit_InsertLink(GetAchievementLink(self.Quest.Id))
        else
            if Questie.db.char.trackedAchievementIds[self.Quest.Id] then
                QuestieTracker:UntrackAchieveId(self.Quest.Id)
                QuestieTracker:UpdateAchieveTrackerCache(self.Quest.Id)

                if (not AchievementFrame) then
                    AchievementFrame_LoadUI()
                end

                AchievementFrameAchievements_ForceUpdate()

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
            else
                -- Assume this is an Objective of an Achievement
                UIErrorsFrame:AddMessage(format(l10n("You can't untrack an objective of an achievement.")), 1.0, 0.1, 0.1, 1.0)
            end
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.profile.trackerbindOpenQuestLog, button) then
        if (not AchievementFrame) then
            AchievementFrame_LoadUI()
        end

        if (not AchievementFrame:IsShown()) then
            AchievementFrame_ToggleAchievementFrame()
            AchievementFrame_SelectAchievement(self.Quest.Id)
        else
            if (AchievementFrameAchievements.selection ~= self.Quest.Id) then
                AchievementFrame_SelectAchievement(self.Quest.Id)
            end
        end
    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForAchievement(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0, 0, "MENU")
    end
end

return TrackerLine
