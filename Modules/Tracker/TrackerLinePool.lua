---@class TrackerLinePool
local TrackerLinePool = QuestieLoader:CreateModule("TrackerLinePool")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerQuestFrame
local TrackerQuestFrame = QuestieLoader:ImportModule("TrackerQuestFrame")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
local _QuestEventHandler = QuestEventHandler.private

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")
local LSM30 = LibStub("LibSharedMedia-3.0")

local linePoolSize = 250
local lineIndex = 0
local buttonPoolSize = 25
local buttonIndex = 0
local linePool = {}
local buttonPool = {}
local lineMarginLeft = 10

---@param questFrame Frame
function TrackerLinePool.Initialize(questFrame)
    local trackerQuestFrame = questFrame
    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest

    -- create linePool for quests/achievements
    local nextFrame
    for i = 1, linePoolSize do
        local timeElapsed = 0
        local line = CreateFrame("Button", nil, trackerQuestFrame.ScrollChildFrame)
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
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end

        if nextFrame then
            -- Second lineIndex hearafter
            line:SetPoint("TOPLEFT", nextFrame, "BOTTOMLEFT", 0, 0)
        else
            -- First lineIndex
            line:SetPoint("TOPLEFT", trackerQuestFrame.ScrollChildFrame, "TOPLEFT", lineMarginLeft, 0)
        end

        line.SetMode = TrackerLinePool.SetMode

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

            -- Set Timed Quest Flag
            if Quest.trackTimedQuest then
                self.trackTimedQuest = Quest.trackTimedQuest
            end
        end

        function line:SetObjective(Objective)
            self.Objective = Objective
        end

        line.OnUpdate = function(self, elapsed)
            if Questie.IsWotlk then
                timeElapsed = timeElapsed + elapsed

                if timeElapsed > 1 and self.trackTimedQuest and self.label.activeTimer then
                    local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(self.Quest.Id)

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
                self:SetScript("OnClick", TrackerLinePool.OnClickQuest)
            elseif onClickmode == "achieve" then
                self:SetScript("OnClick", TrackerLinePool.OnClickAchieve)
            end
        end

        line:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
        line:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)

        line:SetScript("OnEnter", function(self)
            TrackerLinePool.OnHighlightEnter(self)
            TrackerFadeTicker.OnEnter()
        end)

        line:SetScript("OnLeave", function(self)
            TrackerLinePool.OnHighlightLeave(self)
            TrackerFadeTicker.OnLeave()
        end)

        -- create objective complete criteria marks
        local criteriaMark = CreateFrame("Button", nil, line)
        criteriaMark.texture = criteriaMark:CreateTexture(nil, "OVERLAY", nil, 0)
        criteriaMark.texture:SetWidth(Questie.db.global.trackerFontSizeObjective)
        criteriaMark.texture:SetHeight(Questie.db.global.trackerFontSizeObjective)
        criteriaMark.texture:SetAllPoints(criteriaMark)

        criteriaMark:SetWidth(1)
        criteriaMark:SetHeight(1)
        criteriaMark:SetPoint("RIGHT", line.label, "LEFT", -4, 0)
        criteriaMark:SetFrameLevel(100)

        criteriaMark.SetCriteria = function(self, criteria)
            if criteria ~= self.mode then
                self.mode = criteria

                if criteria == true then
                    self.texture:SetTexture("Interface\\Addons\\Questie\\Icons\\Checkmark")
                    --self.texture:SetAlpha(1)
                    --else
                    --self.texture:SetTexture("Interface\\Addons\\Questie\\Icons\\Minus")
                    --self.texture:SetAlpha(0.5)
                end

                self:SetWidth(Questie.db.global.trackerFontSizeObjective)
                self:SetHeight(Questie.db.global.trackerFontSizeObjective)
            end
        end

        criteriaMark:SetCriteria(false)
        criteriaMark:Hide()

        line.criteriaMark = criteriaMark

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
                                for questId, _ in pairs(Questie.db.char.minAllQuestsInZone[self.zoneId]) do
                                    if type(questId) == "number" then
                                        Questie.db.char.collapsedQuests[questId] = true
                                    end
                                end

                                Questie.db.char.minAllQuestsInZone[self.zoneId].isTrue = nil
                            else
                                -- Removes all QuestID's from the collapsedQuests table.
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
                    else
                        self:SetMode(1)
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
            TrackerLinePool.OnHighlightEnter(self)
            TrackerFadeTicker.OnEnter()
        end)

        expandZone:SetScript("OnLeave", function(self)
            TrackerLinePool.OnHighlightLeave(self)
            TrackerFadeTicker.OnLeave()
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
        expandQuest:SetFrameLevel(100)

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
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
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

        if Questie.IsWotlk then
            line:HookScript("OnUpdate", line.OnUpdate)
        end

        if Questie.db.global.trackerFadeMinMaxButtons then
            expandQuest:SetAlpha(0)
        end

        expandQuest:SetScript("OnEnter", function(self)
            TrackerLinePool.OnHighlightEnter(self)
            TrackerFadeTicker.OnEnter()
        end)

        expandQuest:SetScript("OnLeave", function(self)
            TrackerLinePool.OnHighlightLeave(self)
            TrackerFadeTicker.OnLeave()
        end)

        expandQuest:Hide()

        line.expandQuest = expandQuest

        linePool[i] = line
        nextFrame = line
    end

    -- create buttonPool for quest items
    for i = 1, C_QuestLog.GetMaxNumQuestsCanAccept() do
        local buttonName = "Questie_ItemButton" .. i
        local btn = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
        local cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
        btn.range = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
        btn.count = btn:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
        btn:Hide()

        if Questie.db.global.trackerFadeQuestItemButtons then
            btn:SetAlpha(0)
        end

        btn.SetItem = function(self, quest, buttonType, size)
            local validTexture

            for bag = -2, 4 do
                for slot = 1, QuestieCompat.GetContainerNumSlots(bag) do
                    local texture, _, _, _, _, _, _, _, _, itemId = QuestieCompat.GetContainerItemInfo(bag, slot)
                    -- These type of quest items can never be secondary buttons
                    if quest.sourceItemId == itemId and QuestieDB.QueryItemSingle(itemId, "class") == 12 and buttonType == "primary" then
                        validTexture = texture
                        self.itemId = quest.sourceItemId
                        break
                    end
                    -- These type of quest items are technically secondary buttons but are assigned primary button slots
                    if type(quest.requiredSourceItems) == "table" and #quest.requiredSourceItems == 1 then
                        local questItemId = quest.requiredSourceItems[1]
                        if questItemId and questItemId ~= quest.sourceItemId and QuestieDB.QueryItemSingle(questItemId, "class") == 12 and questItemId == itemId then
                            validTexture = texture
                            self.itemId = questItemId
                            break
                        end
                        -- These type of quest items can never be primary buttons
                    elseif type(quest.requiredSourceItems) == "table" and #quest.requiredSourceItems > 1 then
                        for _, questItemId in pairs(quest.requiredSourceItems) do
                            if questItemId and questItemId ~= quest.sourceItemId and QuestieDB.QueryItemSingle(questItemId, "class") == 12 and questItemId == itemId and buttonType == "secondary" then
                                validTexture = texture
                                self.itemId = questItemId
                                break
                            end
                        end
                    end
                end
            end

            -- Edge case to find "equipped" quest items since they will no longer be in the players bag
            if (not validTexture) then
                for inventorySlot = 1, 19 do
                    local itemId = GetInventoryItemID("player", inventorySlot)
                    -- These type of quest items can never be secondary buttons
                    if quest.sourceItemId == itemId and QuestieDB.QueryItemSingle(itemId, "class") == 12 and buttonType == "primary" then
                        validTexture = GetInventoryItemTexture("player", inventorySlot)
                        self.itemId = quest.sourceItemId
                        break
                    end
                    -- These type of quest items are technically secondary buttons but are assigned primary button slots
                    if type(quest.requiredSourceItems) == "table" and #quest.requiredSourceItems == 1 then
                        local questItemId = quest.requiredSourceItems[1]
                        if questItemId and questItemId ~= quest.sourceItemId and QuestieDB.QueryItemSingle(questItemId, "class") == 12 and questItemId == itemId then
                            validTexture = GetInventoryItemTexture("player", inventorySlot)
                            self.itemId = questItemId
                            break
                        end
                        -- These type of quest items can never be primary buttons
                    elseif type(quest.requiredSourceItems) == "table" and #quest.requiredSourceItems > 1 then
                        for _, questItemId in pairs(quest.requiredSourceItems) do
                            if questItemId and questItemId ~= quest.sourceItemId and QuestieDB.QueryItemSingle(questItemId, "class") == 12 and questItemId == itemId and buttonType == "secondary" then
                                validTexture = GetInventoryItemTexture("player", inventorySlot)
                                self.itemId = questItemId
                                break
                            end
                        end
                    end
                end
            end

            if validTexture and self.itemId then
                self.questID = quest.Id
                self.charges = GetItemCount(self.itemId, nil, true)
                self.rangeTimer = -1

                self:SetNormalTexture(validTexture)
                self:SetPushedTexture(validTexture)
                self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                self:SetSize(size, size)

                self:RegisterForClicks("anyUp")

                self:SetScript("OnEvent", self.OnEvent)
                self:SetScript("OnShow", self.OnShow)
                self:SetScript("OnHide", self.OnHide)
                self:SetScript("OnEnter", self.OnEnter)
                self:SetScript("OnLeave", self.OnLeave)

                self:SetAttribute("type1", "item")
                self:SetAttribute("item1", "item:" .. self.itemId)
                self:Show()

                -- Cooldown Updates
                cooldown:SetSize(size - 4, size - 4)
                cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
                cooldown:Hide()

                -- Range Updates
                self.range:SetText("●")
                self.range:SetPoint("TOPRIGHT", self, "TOPRIGHT", 3, 0)
                self.range:Hide()

                -- Charges Updates
                self.count:Hide()
                self.count:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontQuest), Questie.db.global.trackerFontSizeQuest, "OUTLINE")
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                self.count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 3)

                return true
            else
                self:SetAttribute("item1", nil)
                self:Hide()
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
            if not self.itemId or not self:IsVisible() then
                return
            end

            local valid
            local rangeTimer = self.rangeTimer
            local charges = GetItemCount(self.itemId, nil, true)

            local start, duration, enabled = QuestieCompat.GetItemCooldown(self.itemId)

            if enabled == 1 and duration > 0 then
                cooldown:SetCooldown(start, duration, enabled)
                cooldown:Show()
            else
                cooldown:Hide()
            end

            if (not charges or charges ~= self.charges) then
                self.count:Hide()
                self.charges = GetItemCount(self.itemId, nil, true)
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                if self.charges == 0 then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "TrackerLinePool: Button.OnUpdate")
                    QuestieCombatQueue:Queue(function()
                        C_Timer.After(0.2, function()
                            QuestieTracker:Update()
                        end)
                    end)
                end
            end

            if UnitExists("target") then
                if not self.itemName then
                    self.itemName = GetItemInfo(self.itemId)
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
            GameTooltip:SetHyperlink("item:" .. tostring(self.itemId) .. ":0:0:0:0:0:0:0")
            GameTooltip:Show()

            TrackerFadeTicker.OnEnter(self)
        end

        btn.OnLeave = function(self)
            GameTooltip:Hide()

            TrackerFadeTicker.OnLeave(self)
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

function TrackerLinePool.ResetLinesForChange()
    Questie:Debug(Questie.DEBUG_INFO, "TrackerLinePool: ResetLinesForChange")
    if InCombatLockdown() or not Questie.db.char.trackerEnabled then
        return
    end

    for _, line in pairs(linePool) do
        line.mode = nil
        line.trackTimedQuest = nil
        if line.expandQuest then
            line.expandQuest.mode = nil
        end
        if line.expandZone then
            line.expandZone.mode = nil
        end
        if line.criteriaMark then
            line.criteriaMark.mode = nil
        end
    end

    lineIndex = 0
end

function TrackerLinePool.ResetButtonsForChange()
    Questie:Debug(Questie.DEBUG_INFO, "TrackerLinePool: ResetButtonsForChange")

    if InCombatLockdown() or not Questie.db.char.trackerEnabled then
        return
    end

    buttonIndex = 0
end

---@param trackerLineWidth number
function TrackerLinePool.UpdateWrappedLineWidths(trackerLineWidth)
    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
    local trackerMarginLeft = 10
    local trackerMarginRight = 20
    local questMarginLeft = (trackerMarginLeft + trackerMarginRight + 4) - (18 - trackerFontSizeQuest)
    local objectiveMarginLeft = questMarginLeft + trackerFontSizeQuest
    local questItemButtonSize = 12 + trackerFontSizeQuest
    local trackerMinLineWidth = 280

    ---Updates all the line.label widths in the linePool for wrapped text only
    for _, line in pairs(linePool) do
        if Questie.db[Questie.db.global.questieTLoc].TrackerWidth == 0 then
            if line.mode == "objective" then
                if line.label:GetNumLines() > 1 and line:GetHeight() > Questie.db.global.trackerFontSizeObjective then
                    line.label:SetText(line.label:GetText())

                    if line.altButton then
                        line.label:SetWidth(TrackerBaseFrame.baseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight - questItemButtonSize)
                        line:SetWidth(line.label:GetWrappedWidth() + objectiveMarginLeft + questItemButtonSize)
                    else
                        line.label:SetWidth(TrackerBaseFrame.baseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                        line:SetWidth(line.label:GetWrappedWidth() + objectiveMarginLeft)
                    end

                    line:SetHeight(line.label:GetStringHeight() + 2 + Questie.db.global.trackerQuestPadding)
                    line.label:SetHeight(line:GetHeight())

                    trackerLineWidth = math.max(trackerLineWidth, trackerMinLineWidth, line.label:GetWrappedWidth() + objectiveMarginLeft)
                end
            end
        end
    end
end

---@return table|nil lineIndex linePool[lineIndex + 1]
function TrackerLinePool.GetNextLine()
    lineIndex = lineIndex + 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    return linePool[lineIndex]
end

---@return table|nil buttonIndex buttonPool[buttonIndex]
function TrackerLinePool.GetNextItemButton()
    buttonIndex = buttonIndex + 1
    if not buttonPool[buttonIndex] then
        return nil -- past the line limit
    end

    return buttonPool[buttonIndex]
end

---@return number lineIndex lineIndex == 1
function TrackerLinePool.IsFirstLine()
    return linePool[1]
end

---@param index number
---@return table index linePool[index]
function TrackerLinePool.GetLine(index)
    return linePool[index]
end

---@return table lineIndex linePool[lineIndex]
function TrackerLinePool.GetCurrentLine()
    return linePool[lineIndex]
end

---@return table buttonIndex buttonPool[buttonIndex]
function TrackerLinePool.GetCurrentButton()
    return buttonPool[buttonIndex]
end

---@return table|nil lineIndex linePool[lineIndex - 1]
function TrackerLinePool.GetPreviousLine()
    lineIndex = lineIndex - 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    return linePool[lineIndex]
end

---@return table linePool linePool[1]
function TrackerLinePool.GetFirstLine()
    return linePool[1]
end

---@return table linePool linePool[linePoolSize]
function TrackerLinePool.GetLastLine()
    return linePool[linePoolSize]
end

function TrackerLinePool.HideUnusedLines()
    Questie:Debug(Questie.DEBUG_INFO, "TrackerLinePool: HideUnusedLines")
    local startUnusedLines = 0

    if Questie.db.char.isTrackerExpanded then
        startUnusedLines = lineIndex + 1
    end

    for i = startUnusedLines, linePoolSize do
        local line = linePool[i]
        if line then -- Safe Guard to really concurrent triggers
            line:Hide()
            line.mode = nil
            line.ZoneId = nil
            line.Quest = nil
            line.Objective = nil
            line.Button = nil
            line.altButton = nil
            line.trackTimedQuest = nil
            line.expandQuest.mode = nil
            line.expandZone.mode = nil
            line.criteriaMark.mode = nil
        end
    end
end

function TrackerLinePool.HideUnusedButtons()
    Questie:Debug(Questie.DEBUG_INFO, "TrackerLinePool: HideUnusedButtons")
    local startUnusedButtons = 0

    if Questie.db.char.isTrackerExpanded then
        startUnusedButtons = buttonIndex + 1
    end

    for i = startUnusedButtons, buttonPoolSize do
        local button = buttonPool[i]
        if button then
            button:FakeHide()
            button.itemId = nil
            button.itemName = nil
            button.lineID = nil
            button.fontSize = nil
            button:ClearAllPoints()
            button:SetParent(UIParent)
            button:Hide()
        end
    end
end

---@return number lineIndex
function TrackerLinePool.GetHighestIndex()
    return lineIndex > linePoolSize and linePoolSize or lineIndex
end

---@param alpha number
function TrackerLinePool.SetAllExpandQuestAlpha(alpha)
    local highestIndex = TrackerLinePool.GetHighestIndex()

    for i = 1, highestIndex do
        linePool[i].expandQuest:SetAlpha(alpha)
    end
end

---@param alpha number
function TrackerLinePool.SetAllItemButtonAlpha(alpha)
    local highestIndex = TrackerLinePool.GetHighestIndex()
    local hasButton = false

    for i = 1, highestIndex do
        local line = linePool[i]

        if line.button then
            line.button:SetAlpha(alpha)
            if line.button:GetAlpha() < 0.07 then
                hasButton = true
            end
        end

        if line.altButton then
            line.altButton:SetAlpha(alpha)
            if line.altButton:GetAlpha() < 0.07 then
                hasButton = true
            end
        end
    end

    if hasButton then
        QuestieTracker:Update()
    end
end

---@param button string
TrackerLinePool.OnClickQuest = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLinePool:_OnClickQuest]")
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
            QuestieTracker:UntrackQuestId(self.Quest.Id)
            local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
            if questLogFrame:IsShown() then
                QuestLog_Update()
            end
        end
    elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
        TrackerUtils:ShowQuestLog(self.Quest)
    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForQuest(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0, 0, "MENU")
    end
end

---@param button string
TrackerLinePool.OnClickAchieve = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerLinePool:_OnClickAchieve]")
    if (not self.Quest) then
        return
    end

    if TrackerMenu.menuFrame:IsShown() then
        LibDropDown:CloseDropDownMenus()
    end

    if TrackerUtils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
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

TrackerLinePool.OnHighlightEnter = function(self)
    if (self.mode == "quest" or self:GetParent().mode == "quest") or self.mode == "achieve" or self.mode == "objective" or self.mode == "zone" or self:GetParent().mode == "zone" then
        local highestIndex = TrackerLinePool.GetHighestIndex()
        for i = 1, highestIndex do
            local line = linePool[i]
            line:SetAlpha(0.5)
            if line.Quest == self.Quest or (self:GetParent().mode == "quest" and line.Quest == self:GetParent().Quest) or line.mode == "zone" then
                line:SetAlpha(1)
            end
        end
    end
end

TrackerLinePool.OnHighlightLeave = function()
    local highestIndex = TrackerLinePool.GetHighestIndex()
    for i = 1, highestIndex do
        linePool[i]:SetAlpha(1)
    end
end

---@param mode string
TrackerLinePool.SetMode = function(self, mode)
    if mode ~= self.mode then
        self.mode = mode
        if mode == "zone" then
            local trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontZone), trackerFontSizeZone, Questie.db.global.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeZone)
        elseif mode == "quest" or mode == "achieve" then
            local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontQuest), trackerFontSizeQuest, Questie.db.global.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeQuest)
            self.button = nil
        elseif mode == "objective" then
            local trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective), trackerFontSizeObjective, Questie.db.global.trackerFontOutline)
            self.label:SetHeight(trackerFontSizeObjective)
        end
    end
end
