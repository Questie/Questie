---@class LinePool
local LinePool = QuestieLoader:CreateModule("LinePool")

---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
---@type FadeTicker
local FadeTicker = QuestieLoader:ImportModule("FadeTicker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local poolSize = 80
local lineIndex = 0
local buttonIndex = 0
local linePool = {}
local buttonPool = {}

local baseFrame
local lineMarginLeft = 10

local _OnClickQuest, _OnClickAchieve, _OnHighlightEnter, _OnHighlightLeave, _SetMode
local _UntrackQuest, _TrackerUpdate

---@param trackedQuestsFrame Frame
function LinePool.Initialize(trackedQuestsFrame, UntrackQuest, TrackerUpdate)
    baseFrame = trackedQuestsFrame
    _UntrackQuest = UntrackQuest
    _TrackerUpdate = TrackerUpdate

    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest

    -- create linePool for quests/achievements
    local lastFrame
    for i = 1, poolSize do
        local line = CreateFrame("Button", nil, trackedQuestsFrame)
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
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end

        line:SetWidth(1)
        line:SetHeight(1)

        if lastFrame then
            line:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
        else
            line:SetPoint("TOPLEFT", trackedQuestsFrame, "TOPLEFT", lineMarginLeft, 0)
        end

        line.SetMode = _SetMode

        function line:SetZone(ZoneId)
            if ZoneId == "Achievements" then
                self.expandZone.zoneId = ZoneId
            else
                self.ZoneId = TrackerUtils:GetZoneNameByID(ZoneId)
                self.expandZone.zoneId = ZoneId
            end
        end

        function line:SetQuest(Quest)
            if type(Quest) ~= "table" then
                local questID = Quest
                Quest = {
                    Id = questID
                }
            end
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        end

        function line:SetObjective(Objective)
            self.Objective = Objective
        end

        function line:SetVerticalPadding(amount)
            if self.mode == "zone" then
                self:SetHeight(Questie.db.global.trackerFontSizeZone + amount)
            elseif self.mode == "quest" or "achieve" then
                self:SetHeight(Questie.db.global.trackerFontSizeQuest + amount)
            else
                self:SetHeight(Questie.db.global.trackerFontSizeObjective + amount)
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
            _OnHighlightEnter(self)
            FadeTicker.OnEnter()
        end)

        line:SetScript("OnLeave", function(self)
            _OnHighlightLeave(self)
            FadeTicker.OnLeave()
        end)

        -- create expanding zone headers for quests sorted by zones
        local expandZone = CreateFrame("Button", nil, line)
        expandZone:SetWidth(1)
        expandZone:SetHeight(1)
        expandZone:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

        expandZone.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
            end
        end

        expandZone:SetMode(1) -- maximized
        expandZone:EnableMouse(true)
        expandZone:RegisterForDrag("LeftButton")
        expandZone:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expandZone:SetScript("OnClick", function(self)
            if InCombatLockdown() then
                return
            end
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedZones[self.zoneId] == true then
                Questie.db.char.collapsedZones[self.zoneId] = nil
            else
                Questie.db.char.collapsedZones[self.zoneId] = true
            end
            _TrackerUpdate()
            C_Timer.After(0.01, function()
                _TrackerUpdate()
            end)
        end)

        expandZone:SetScript("OnEnter", function(self)
            _OnHighlightEnter(self)
            FadeTicker.OnEnter()
        end)

        expandZone:SetScript("OnLeave", function(self)
            _OnHighlightLeave(self)
            FadeTicker.OnLeave()
        end)

        expandZone:Hide()

        line.expandZone = expandZone

        -- create expanding buttons for quests with objectives
        local expandQuest = CreateFrame("Button", nil, line)
        expandQuest.texture = expandQuest:CreateTexture(nil, "OVERLAY", nil, 0)
        expandQuest.texture:SetWidth(trackerFontSizeQuest)
        expandQuest.texture:SetHeight(trackerFontSizeQuest)
        expandQuest.texture:SetAllPoints(expandQuest)

        expandQuest:SetWidth(trackerFontSizeQuest)
        expandQuest:SetHeight(trackerFontSizeQuest)
        expandQuest:SetPoint("RIGHT", line, "LEFT", 0, 0)

        expandQuest.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == 1 then
                    self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
                else
                    self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
                end
                self:SetWidth(Questie.db.global.trackerFontSizeQuest + 3)
                self:SetHeight(Questie.db.global.trackerFontSizeQuest + 3)
            end
        end

        expandQuest:SetMode(1) -- maximized
        expandQuest:EnableMouse(true)
        expandQuest:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expandQuest:SetScript("OnClick", function(self)
            if InCombatLockdown() then
                return
            end
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedQuests[self.questId] then
                Questie.db.char.collapsedQuests[self.questId] = nil
            else
                Questie.db.char.collapsedQuests[self.questId] = true
            end
            _TrackerUpdate()
            C_Timer.After(0.01, function()
                _TrackerUpdate()
            end)
        end)

        expandQuest:SetScript("OnEnter", FadeTicker.OnEnter)
        expandQuest:SetScript("OnLeave", FadeTicker.OnLeave)
        expandQuest:Hide()

        if Questie.db.global.trackerFadeMinMaxButtons then
            expandQuest:SetAlpha(0)
        end

        line.expandQuest = expandQuest

        linePool[i] = line
        lastFrame = line
    end

    -- create buttonPool for quest items
    for i = 1, C_QuestLog.GetMaxNumQuestsCanAccept() do
        local buttonName = "Questie_ItemButton"..i
        local btn = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
        local cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
        btn.range = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
        btn.count = btn:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
        btn:SetAttribute("type1", "item")
        btn:SetAttribute("type2", "stop")
        btn:Hide()

        if Questie.db.global.trackerFadeQuestItemButtons then
            btn:SetAlpha(0)
        end

        btn.SetItem = function(self, quest, itemType, size)
            local validTexture

            for bag = 0 , 4 do
                for slot = 1, QuestieCompat.GetContainerNumSlots(bag) do
                    local texture, _, _, _, _, _, _, _, _, itemID = QuestieCompat.GetContainerItemInfo(bag, slot)
                    if quest.sourceItemId == itemID and QuestieDB:GetItem(itemID).flags == 64 and itemType == "primary" then
                        validTexture = texture
                        self.itemID = quest.sourceItemId
                        break
                    end

                    if type(quest.requiredSourceItems) == "table" then
                        for _, questItemId in pairs(quest.requiredSourceItems) do
                            if questItemId and questItemId ~= quest.sourceItemId and QuestieDB:GetItem(questItemId).flags == 64 and questItemId == itemID and (itemType == "primary" or itemType == "secondary") then
                                validTexture = texture
                                self.itemID = questItemId
                                break
                            end
                        end
                    end
                end
            end

            -- Edge case to find "equipped" quest items since they will no longer be in the players bag
            if (not validTexture) then
                for inventorySlot = 1, 19 do
                    local itemID = GetInventoryItemID("player", inventorySlot)
                    if quest.sourceItemId == itemID and QuestieDB:GetItem(itemID).flags == 64 and itemType == "primary" then
                        validTexture = GetInventoryItemTexture("player", inventorySlot)
                        self.itemID = quest.sourceItemId
                        break
                    end

                    if type(quest.requiredSourceItems) == "table" then
                        for _, questItemId in pairs(quest.requiredSourceItems) do
                            if questItemId and questItemId ~= quest.sourceItemId and QuestieDB:GetItem(questItemId).flags == 64 and questItemId == itemID and (itemType == "primary" or itemType == "secondary") then
                                validTexture = GetInventoryItemTexture("player", inventorySlot)
                                self.itemID = questItemId
                                break
                            end
                        end
                    end
                end
            end

            if validTexture and self.itemID then
                self.questID = quest.Id
                self.charges = GetItemCount(self.itemID, nil, true)
                self.rangeTimer = -1

                self:SetAttribute("item", "item:" .. tostring(self.itemID))
                self:SetNormalTexture(validTexture)
                self:SetPushedTexture(validTexture)
                self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                self:SetSize(size, size)

                self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

                self:SetScript("OnEvent", self.OnEvent)
                self:SetScript("OnShow", self.OnShow)
                self:SetScript("OnHide", self.OnHide)
                self:SetScript("OnEnter", self.OnEnter)
                self:SetScript("OnLeave", self.OnLeave)

                -- Cooldown Updates
                cooldown:SetSize(size-4, size-4)
                cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
                cooldown:Hide()

                -- Range Updates
                self.range:SetText("●")
                self.range:SetPoint("TOPRIGHT", self, "TOPRIGHT", 3, 0)
                self.range:Hide()

                -- Charges Updates
                self.count:Hide()
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                self.count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 3)

                return true
            end

            return false
        end

        btn.OnEvent = function(self, event, ...)
            if (event == "PLAYER_TARGET_CHANGED") then
                self.rangeTimer = -1
                self.range:Hide()
            end
        end

        btn.OnUpdate = function(self, elapsed)
            if not self.itemID or not self:IsVisible() then
                return
            end

            local valid
            local rangeTimer = self.rangeTimer
            local charges = GetItemCount(self.itemID, nil, true)

            local start, duration, enabled = QuestieCompat.GetItemCooldown(self.itemID)

            if enabled == 1 and duration > 0 then
                cooldown:SetCooldown(start, duration, enabled)
                cooldown:Show()
            else
                cooldown:Hide()
            end

            if (not charges or charges ~= self.charges) then
                self.count:Hide()
                self.charges = GetItemCount(self.itemID, nil, true)
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                if self.charges == 0 then
                    QuestieCombatQueue:Queue(function()
                        C_Timer.After(0.5, function()
                            QuestieTracker:Update()
                        end)
                    end)
                end
            end

            if UnitExists("target") then

                if not self.itemName then
                    self.itemName = GetItemInfo(self.itemID)
                end

                if (rangeTimer) then
                    rangeTimer = rangeTimer - elapsed

                    if (rangeTimer <= 0) then

                        valid = IsItemInRange(self.itemName, "target")

                        if valid == false then
                            self.range:SetVertexColor(1.0, 0.1, 0.1)
                            self.range:Show()

                        elseif valid == true then
                            self.range:SetVertexColor(0.6, 0.6, 0.6)
                            self.range:Show()
                        end

                        rangeTimer = 0.3
                    end

                    self.rangeTimer = rangeTimer
                end
            end
        end

        btn.OnShow = function(self)
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
        end

        btn.OnHide = function(self)
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
        end

        btn.OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink("item:"..tostring(self.itemID)..":0:0:0:0:0:0:0")
            GameTooltip:Show()

            FadeTicker.OnEnter(self)
        end

        btn.OnLeave = function(self)
            GameTooltip:Hide()

            FadeTicker.OnLeave(self)
        end

        btn.FakeHide = function(self)
            self:RegisterForClicks()
            self:SetScript("OnEnter", nil)
            self:SetScript("OnLeave", nil)
        end

        btn:HookScript("OnUpdate", btn.OnUpdate)

        btn:FakeHide()

        buttonPool[i] = btn
        buttonPool[i]:Hide()
    end
end

function LinePool.ResetLinesForChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "LinePool: ResetLinesForChange")
    if InCombatLockdown() or not Questie.db.global.trackerEnabled then
        return
    end

    for _, line in pairs(linePool) do
        line.mode = nil
        if line.expandQuest then
            line.expandQuest.mode = nil
        end
        if line.expandZone then
            line.expandZone.mode = nil
        end
    end

    baseFrame:Hide()
    lineIndex = 0
end

function LinePool.ResetButtonsForChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "LinePool: ResetButtonsForChange")
    if InCombatLockdown() or not Questie.db.global.trackerEnabled then
        return
    end

    buttonIndex = 0
end

function LinePool.GetNextLine()
    lineIndex = lineIndex + 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    return linePool[lineIndex]
end

function LinePool.GetNextItemButton()
    buttonIndex = buttonIndex + 1
    if not buttonPool[buttonIndex] then
        return nil -- past the line limit
    end

    return buttonPool[buttonIndex]
end

function LinePool.IsFirstLine()
    return lineIndex == 1
end

function LinePool.GetLine(index)
    return linePool[index]
end

function LinePool.GetCurrentLine()
    return linePool[lineIndex]
end

function LinePool.GetPreviousLine()
    return linePool[lineIndex - 1]
end

function LinePool.GetLastLine()
    return linePool[poolSize]
end

function LinePool.HideUnusedLines()
    for i = lineIndex + 1, poolSize do
        if linePool[i] then -- Safe Guard to really concurrent triggeres
            linePool[i]:Hide()
            linePool[i].mode = nil
            linePool[i].Quest = nil
            linePool[i].Objective = nil
            linePool[i].expandQuest.mode = nil
            linePool[i].expandZone.mode = nil
        end
    end
end

function LinePool.HideUnusedButtons()
    local startUnusedButtons = 1

    if Questie.db.char.isTrackerExpanded then
        startUnusedButtons = buttonIndex + 1
    end

    for i = startUnusedButtons, C_QuestLog.GetMaxNumQuestsCanAccept() do
        local button = buttonPool[i]
        if button.itemID then
            button:FakeHide()
            button.itemID = nil
            button.itemName = nil
            button.lineID = nil
            button.fontSize = nil
            button:ClearAllPoints()
            button:SetParent(UIParent)
            button:Hide()
        end
    end
end

local function _GetHighestIndex()
    return lineIndex > poolSize and poolSize or lineIndex
end

function LinePool.SetAllExpandQuestAlpha(alpha)
    local highestIndex = _GetHighestIndex()

    for i = 1, highestIndex do
        linePool[i].expandQuest:SetAlpha(alpha)
    end
end

function LinePool.SetAllItemButtonAlpha(alpha)
    local highestIndex = _GetHighestIndex()

    for i = 1, highestIndex do
        local line = linePool[i]
        if line.button then
            line.button:SetAlpha(alpha)
        end
    end
end

_OnClickQuest = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[LinePool:_OnClickQuest]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.global.trackerbindSetTomTom, button) then
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(self.Quest)
        if spawn then
            TrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end

    elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then

            if Questie.db.global.trackerShowQuestLevel then
                ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(self.Quest.level, self.Quest.name, self.Quest.Id))
            else
                ChatEdit_InsertLink("[" .. self.Quest.name .. " (" .. self.Quest.Id .. ")]")
            end

        else
            _UntrackQuest(self.Quest)
        end

    elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
        TrackerUtils:ShowQuestLog(self.Quest)

    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForQuest(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0, 0, "MENU")
    end
end

_OnClickAchieve = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[LinePool:_OnClickAchieve]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
        if GetTrackedAchievements(self.Quest.Id) then
            if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
                ChatEdit_InsertLink(GetAchievementLink(self.Quest.Id))

            else
                RemoveTrackedAchievement(self.Quest.Id)
                AchievementFrame_ForceUpdate()
            end
        end

    elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
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

_OnHighlightEnter = function(self)
    if self.mode == "quest" or self.mode == "achieve" or self.mode == "objective" or self.mode == "zone" or self:GetParent().mode == "zone" then
        local highestIndex = _GetHighestIndex()
        for i = 1, highestIndex do
            local line = linePool[i]
            line:SetAlpha(0.5)
            if (line.Quest == self.Quest) or line.mode == "zone" then
                line:SetAlpha(1)
            end
        end
    end
end

_OnHighlightLeave = function()
    local highestIndex = _GetHighestIndex()
    for i = 1, highestIndex do
        linePool[i]:SetAlpha(1)
    end
end

local _GetOutline = function()
    local outlineValue = Questie.db.global.trackerFontOutline
    if outlineValue == "NONE" then
        return nil
    end
    return outlineValue
end

_SetMode = function(self, mode)
    if mode ~= self.mode then
        self.mode = mode
        if mode == "zone" then
            local trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
            self.label:SetFont(STANDARD_TEXT_FONT, trackerFontSizeZone, _GetOutline())
            self.label:SetHeight(trackerFontSizeZone)
        elseif mode == "quest" or mode == "achieve" then
            local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
            self.label:SetFont(STANDARD_TEXT_FONT, trackerFontSizeQuest, _GetOutline())
            self.label:SetHeight(trackerFontSizeQuest)
            self.button = nil
        elseif mode == "objective" then
            local trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective
            self.label:SetFont(STANDARD_TEXT_FONT, trackerFontSizeObjective, _GetOutline())
            self.label:SetHeight(trackerFontSizeObjective)
        end
    end
end
