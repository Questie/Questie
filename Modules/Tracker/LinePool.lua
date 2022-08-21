---@class LinePool
local LinePool = QuestieLoader:CreateModule("LinePool")

---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")

local LSM30 = LibStub("LibSharedMedia-3.0", true)

local poolSize = 80
local lineIndex = 0
local linePool = {}

local baseFrame

local _OnClick

---@param trackedQuestsFrame Frame
function LinePool.Initialize(trackedQuestsFrame)
    baseFrame = trackedQuestsFrame
    local trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
    local trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective

    local lastFrame
    for i = 1, poolSize do
        local btn = CreateFrame("Button", nil, trackedQuestsFrame)
        btn.label = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        btn.label:SetJustifyH("LEFT")
        btn.label:SetPoint("TOPLEFT", btn)
        btn.label:Hide()

        -- autoadjust parent size for clicks
        btn.label._SetText = btn.label.SetText
        btn.label.frame = btn
        btn.label.SetText = function(self, text)
            self:_SetText(text)
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end

        btn:SetWidth(1)
        btn:SetHeight(1)

        if lastFrame then
            btn:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
        else
            btn:SetPoint("TOPLEFT", trackedQuestsFrame, "TOPLEFT", 0, 0)
        end

        function btn:SetMode(mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == "zone" then
                    self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontZone) or STANDARD_TEXT_FONT, trackerFontSizeZone)
                    self.label:SetHeight(trackerFontSizeZone)
                elseif mode == "quest" then
                    self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontQuest) or STANDARD_TEXT_FONT, trackerFontSizeQuest)
                    self.label:SetHeight(trackerFontSizeQuest)
                    self.button = nil
                elseif mode == "objective" then
                    self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT, trackerFontSizeObjective)
                    self.label:SetHeight(trackerFontSizeObjective)
                end
            end
        end

        function btn:SetZone(ZoneId)
            self.ZoneId = TrackerUtils:GetZoneNameByID(ZoneId)
            self.expandZone.zoneId = ZoneId
        end

        function btn:SetQuest(Quest)
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        end

        function btn:SetObjective(Objective)
            self.Objective = Objective
        end

        function btn:SetVerticalPadding(amount)
            if self.mode == "zone" then
                self:SetHeight(trackerFontSizeZone + amount)
            elseif self.mode == "quest" then
                self:SetHeight(trackerFontSizeQuest + amount)
            else
                self:SetHeight(trackerFontSizeObjective + amount)
            end
        end

        btn:SetMode("quest")
        btn:EnableMouse(true)
        btn:RegisterForDrag("LeftButton")
        btn:RegisterForClicks("RightButtonUp", "LeftButtonUp")

        btn:SetScript("OnClick", _OnClick)
        --btn:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        --btn:SetScript("OnDragStop", _QuestieTracker.OnDragStop)

        btn:SetScript("OnEnter", function(self)
            _OnHighlightEnter(self)
            _OnEnter()
        end)

        btn:SetScript("OnLeave", function(self)
            _OnHighlightLeave(self)
            _OnLeave()
        end)

        if lastFrame then
            btn:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
        else
            btn:SetPoint("TOPLEFT", trackedQuestsFrame, "TOPLEFT", 0, 0)
        end

        -- create expanding zone headers for quests sorted by zones
        local expandZone = CreateFrame("Button", "Questie_ZoneHeader", btn)
        expandZone:SetWidth(1)
        expandZone:SetHeight(1)
        expandZone:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

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
            LinePool.ResetLinesForChange()
            QuestieTracker:Update()
        end)

        expandZone:SetScript("OnEnter", function(self)
            _OnHighlightEnter(self)
            _OnEnter()
        end)

        expandZone:SetScript("OnLeave", function(self)
            _OnHighlightLeave(self)
            _OnLeave()
        end)

        --expandZone:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        --expandZone:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
        expandZone:Hide()

        btn.expandZone = expandZone

        -- create expanding buttons for quests with objectives
        local expandQuest = CreateFrame("Button", "Questie_MinQuestButton", btn)
        expandQuest.texture = expandQuest:CreateTexture(nil, "OVERLAY", nil, 0)
        expandQuest.texture:SetWidth(trackerFontSizeQuest)
        expandQuest.texture:SetHeight(trackerFontSizeQuest)
        expandQuest.texture:SetAllPoints(expandQuest)

        expandQuest:SetWidth(trackerFontSizeQuest)
        expandQuest:SetHeight(trackerFontSizeQuest)
        expandQuest:SetFrameLevel(2)
        expandQuest:SetPoint("RIGHT", btn, "LEFT", 0, 0)

        expandQuest.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == 1 then
                    self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
                else
                    self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
                end
                self:SetWidth(trackerFontSizeQuest+3)
                self:SetHeight(trackerFontSizeQuest+3)
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
            LinePool.ResetLinesForChange()
            QuestieTracker:Update()
        end)

        expandQuest:SetScript("OnEnter", _OnEnter)
        expandQuest:SetScript("OnLeave", _OnLeave)
        expandQuest:Hide()

        if Questie.db.global.trackerFadeMinMaxButtons then
            expandQuest:SetAlpha(0)
        end

        btn.expandQuest = expandQuest

        linePool[i] = btn
        lastFrame = btn
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
end

function LinePool.GetNextLine()
    lineIndex = lineIndex + 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    if linePool[lineIndex].expandQuest then
        linePool[lineIndex].expandQuest:Hide()

    elseif linePool[lineIndex].expandZone then
        linePool[lineIndex].expandZone:Hide()
    end

    return linePool[lineIndex]
end

function LinePool.GetLine(index)
    return linePool[index]
end

function LinePool.GetPreviousLine()
    return linePool[lineIndex - 1]
end

function LinePool.GetLastLine()
    return linePool[poolSize]
end

function LinePool.HideUnusedLines()
    for i = lineIndex + 1, poolSize do
        linePool[i]:Hide()
        linePool[i].mode = nil
        linePool[i].Quest = nil
        linePool[i].Objective = nil
        linePool[i].expandQuest.mode = nil
        linePool[i].expandZone.mode = nil
    end
end

_OnClick = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker:_OnClick]")
    if _QuestieTracker.isMoving == true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker:_OnClick] Tracker is being dragged. Don't show the menu")
        return
    end

    if not self.Quest then
        return
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
                ChatEdit_InsertLink("["..self.Quest.name.." ("..self.Quest.Id..")]")
            end

        else
            QuestieTracker:Untrack(self.Quest)
        end

    elseif TrackerUtils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
        TrackerUtils:ShowQuestLog(self.Quest)

    elseif button == "RightButton" then
        local menu = TrackerMenu:GetMenuForQuest(self.Quest)
        LibDropDown:EasyMenu(menu, TrackerMenu.menuFrame, "cursor", 0 , 0, "MENU")
    end
end
