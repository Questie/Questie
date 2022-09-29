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

local LSM30 = LibStub("LibSharedMedia-3.0", true)
local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local poolSize = 80
local lineIndex = 0
local linePool = {}

local achievementPoolSize = 40
local achievementLineIndex = 0
local achievementLinePool = {}

local baseFrame
local lineMarginLeft = 10

local _OnClick, _OnHighlightEnter, _OnHighlightLeave, _SetMode
local _UntrackQuest, _TrackerUpdate

---@param trackedQuestsFrame Frame
function LinePool.Initialize(trackedQuestsFrame, UntrackQuest, TrackerUpdate)
    baseFrame = trackedQuestsFrame
    _UntrackQuest = UntrackQuest
    _TrackerUpdate = TrackerUpdate

    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest

    local lastFrame
    for i = 1, poolSize do
        local line = CreateFrame("Button", nil, trackedQuestsFrame)
        line.label = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        line.label:SetJustifyH("LEFT")
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
            self.ZoneId = TrackerUtils:GetZoneNameByID(ZoneId)
            self.expandZone.zoneId = ZoneId
        end

        function line:SetQuest(Quest)
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        end

        function line:SetObjective(Objective)
            self.Objective = Objective
        end

        function line:SetVerticalPadding(amount)
            if self.mode == "zone" then
                self:SetHeight(Questie.db.global.trackerFontSizeZone + amount)
            elseif self.mode == "quest" then
                self:SetHeight(Questie.db.global.trackerFontSizeQuest + amount)
            else
                self:SetHeight(Questie.db.global.trackerFontSizeObjective + amount)
            end
        end

        line:SetMode("quest")
        line:EnableMouse(true)
        line:RegisterForDrag("LeftButton")
        line:RegisterForClicks("RightButtonUp", "LeftButtonUp")

        line:SetScript("OnClick", _OnClick)
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
end

---@param trackedAchievementsFrame Frame
function LinePool.InitializeAchievementLines(trackedAchievementsFrame, OnAchievementClick, AchievementUpdate)
    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest

    local lastFrame
    for i = 1, achievementPoolSize do
        local line = CreateFrame("Button", nil, trackedAchievementsFrame)
        line:SetSize(1, 1)

        line.label = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        line.label:SetJustifyH("LEFT")
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

        if lastFrame then
            line:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
        else
            line:SetPoint("TOPLEFT", trackedAchievementsFrame, "TOPLEFT", lineMarginLeft, -30)
        end

        line.SetMode = _SetMode

        function line:SetAchievement(achievementId)
            self.expand.achievementId = achievementId
        end

        function line:SetVerticalPadding(amount)
            if self.mode == "achievement" then
                self:SetHeight(Questie.db.global.trackerFontSizeQuest + amount)
            else
                self:SetHeight(Questie.db.global.trackerFontSizeObjective + amount)
            end
        end

        line:SetMode("achievement")
        line:EnableMouse(true)
        line:RegisterForDrag("LeftButton")
        line:RegisterForClicks("RightButtonUp", "LeftButtonUp")

        line:SetScript("OnClick", OnAchievementClick)
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

        -- create expanding buttons
        local expand = CreateFrame("Button", nil, line)
        expand.texture = expand:CreateTexture(nil, "OVERLAY", nil, 0)
        expand.texture:SetWidth(trackerFontSizeQuest)
        expand.texture:SetHeight(trackerFontSizeQuest)
        expand.texture:SetAllPoints(expand)

        expand:SetWidth(trackerFontSizeQuest)
        expand:SetHeight(trackerFontSizeQuest)
        expand:SetPoint("RIGHT", line, "LEFT", 0, 0)

        expand.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == 1 then
                    self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
                else
                    self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
                end
                self:SetWidth(Questie.db.global.trackerFontSizeQuest+3)
                self:SetHeight(Questie.db.global.trackerFontSizeQuest+3)
            end
        end

        expand:SetMode(1) -- maximized
        expand:EnableMouse(true)
        expand:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expand:SetScript("OnClick", function(self)
            if InCombatLockdown() then
                return
            end
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedAchievements[self.achievementId] then
                Questie.db.char.collapsedAchievements[self.achievementId] = nil
            else
                Questie.db.char.collapsedAchievements[self.achievementId] = true
            end
            AchievementUpdate()
        end)

        expand:SetScript("OnEnter", FadeTicker.OnEnter)
        expand:SetScript("OnLeave", FadeTicker.OnLeave)
        expand:Hide()

        if Questie.db.global.trackerFadeMinMaxButtons then
            expand:SetAlpha(0)
        end

        line.expand = expand

        achievementLinePool[i] = line
        lastFrame = line
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

function LinePool.ResetAchievementLinesForChange()
    Questie:Debug(Questie.DEBUG_DEVELOP, "LinePool: ResetAchievementLinesForChange")
    if InCombatLockdown() or not Questie.db.global.trackerEnabled then
        return
    end

    for _, line in pairs(achievementLinePool) do
        line.mode = nil
        if line.expand then
            line.expand.mode = nil
        end
    end

    achievementLineIndex = 0
end

function LinePool.GetNextLine()
    lineIndex = lineIndex + 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    return linePool[lineIndex]
end

function LinePool.GetNextAchievementLine()
    achievementLineIndex = achievementLineIndex + 1
    if not achievementLinePool[achievementLineIndex] then
        return nil -- past the line limit
    end

    return achievementLinePool[achievementLineIndex]
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

function LinePool.HideUnusedAchievementLines()
    for i = achievementLineIndex + 1, achievementPoolSize do
        if achievementLinePool[i] then -- Safe Guard to really concurrent triggeres
            achievementLinePool[i]:Hide()
            achievementLinePool[i].mode = nil
            achievementLinePool[i].expand.achievementId = nil
            achievementLinePool[i].expand.mode = nil
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

function LinePool.SetAllExpandAchievementsAlpha(alpha)
    local highestIndex = achievementLineIndex > achievementPoolSize and achievementPoolSize or achievementLineIndex

    for i = 1, highestIndex do
        achievementLinePool[i].expand:SetAlpha(alpha)
    end
end

_OnClick = function(self, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[LinePool:_OnClick]")
    if (not self.Quest) then
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

_OnHighlightEnter = function(self)
    if self.mode == "quest" or self.mode == "objective" or self.mode == "zone" or self:GetParent().mode == "zone" then
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
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontZone) or STANDARD_TEXT_FONT,
                trackerFontSizeZone, _GetOutline())
            self.label:SetHeight(trackerFontSizeZone)
        elseif mode == "quest" or mode == "achievement" then
            local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontQuest) or STANDARD_TEXT_FONT,
                trackerFontSizeQuest, _GetOutline())
            self.label:SetHeight(trackerFontSizeQuest)
            self.button = nil
        elseif mode == "objective" then
            local trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT,
                trackerFontSizeObjective, _GetOutline())
            self.label:SetHeight(trackerFontSizeObjective)
        end
    end
end
