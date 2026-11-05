---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class TrackerHeaderFrame
local TrackerHeaderFrame = QuestieLoader:CreateModule("TrackerHeaderFrame")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")

local LSM30 = LibStub("LibSharedMedia-3.0")
local IsAddOnLoaded = QuestieCompat.IsAddOnLoaded

local headerFrame, trackerBaseFrame

function TrackerHeaderFrame.Initialize(baseFrame, OnTrackedQuestClick)
    trackerBaseFrame = baseFrame
    headerFrame = CreateFrame("Button", "Questie_HeaderFrame", trackerBaseFrame)

    TrackerHeaderFrame.PositionTrackerHeaderFrame()

    -- Questie Icon Settings
    local questieIcon = CreateFrame("Button", nil, trackerBaseFrame)
    questieIcon:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, 0)
    questieIcon:SetAlpha(1)

    -- Questie Icon Texture Settings
    questieIcon.texture = questieIcon:CreateTexture(nil, "BACKGROUND", nil, 0)
    questieIcon.texture:SetTexture(Questie.icons["complete"])
    questieIcon.texture:SetPoint("CENTER", 0, 0)

    questieIcon:EnableMouse(true)
    questieIcon:RegisterForDrag("LeftButton")
    questieIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    questieIcon:SetScript("OnClick", function(_, button)
        if button == "LeftButton" then
            if QuestieJourney:IsShown() then
                QuestieJourney:ToggleJourneyWindow()
            end
            QuestieOptionsEngine:ToggleConfigWindow()

            return
        elseif button == "RightButton" then
            if QuestieConfigFrame:IsShown() then
                QuestieConfigFrame:Hide()
            end

            if QuestieOptionsEngine:IsShown() then
                QuestieOptionsEngine:ToggleConfigWindow()
            end
            QuestieJourney:ToggleJourneyWindow()

            return
        end
    end)

    questieIcon:SetScript("OnEnter", function(self)
        if InCombatLockdown() then
            if GameTooltip:IsShown() then
                GameTooltip:Hide()
                return
            end
        end
        GameTooltip._owner = self
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddDoubleLine(Questie:Colorize("Questie", "gold"), Questie:Colorize(QuestieLib:GetAddonVersionString(), "gray"))
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(Questie:Colorize(l10n("Left Click"), "lightBlue"), Questie:Colorize(l10n("Toggle Options"), "white"))
        GameTooltip:AddDoubleLine(Questie:Colorize(l10n("Right Click"), "lightBlue"), Questie:Colorize(l10n("Toggle My Journey"), "white"))
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(
            Questie:Colorize(l10n("Left Click + Hold"), "lightBlue"),
            Questie:Colorize(l10n("Drag while Unlocked"), "white")
        )
        GameTooltip:AddDoubleLine(
            Questie:Colorize(l10n("Ctrl + Left Click + Hold"), "lightBlue"),
            Questie:Colorize(l10n("Drag while Locked"), "white")
        )

        if IsAddOnLoaded("TomTom") then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(Questie:Colorize(l10n("Questie Tracker Integrations"), "gold"))
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(
                Questie:Colorize(l10n("TomTom"), "lightBlue"),
                Questie:Colorize(l10n("Ctrl + Left Click or Right Click a Quest Title"), "white")
            )
        end

        GameTooltip:Show()

        TrackerFadeTicker.Unfade(self)
    end)

    questieIcon:SetScript("OnLeave", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        TrackerFadeTicker.Fade(self)
    end)

    questieIcon:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    questieIcon:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)

    questieIcon:Hide()
    headerFrame.questieIcon = questieIcon

    -- Questie Tracked Quests Settings
    local trackedQuests = CreateFrame("Button", nil, trackerBaseFrame)
    trackedQuests:SetPoint("TOPLEFT", questieIcon, "TOPLEFT", 10, 0)

    -- Questie Tracked Quests Label
    trackedQuests.label = headerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    trackedQuests.label:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, 0)

    trackedQuests.SetMode = function(self, mode)
        if mode ~= self.mode then
            self.mode = mode
        end
    end

    if Questie.db.char.isTrackerExpanded then
        trackedQuests:SetMode(1)
    else
        trackedQuests:SetMode(0)
    end

    trackedQuests:EnableMouse(true)
    trackedQuests:RegisterForDrag("LeftButton")
    trackedQuests:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    trackedQuests:SetScript("OnClick", function(self)
        if InCombatLockdown() then
            return
        end

        if self.mode == 1 then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerHeaderFrame:OnClick] - Tracker Minimized")

            self:SetMode(0)
            Questie.db.char.isTrackerExpanded = false
        else
            Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerHeaderFrame:OnClick] - Tracker Maximized")

            self:SetMode(1)
            Questie.db.char.isTrackerExpanded = true
        end

        QuestieCombatQueue:Queue(function()
            OnTrackedQuestClick()
        end)
    end)

    trackedQuests:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    trackedQuests:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)
    trackedQuests:SetScript("OnEnter", TrackerFadeTicker.Unfade)
    trackedQuests:SetScript("OnLeave", TrackerFadeTicker.Fade)

    trackedQuests:Hide()

    headerFrame.trackedQuests = trackedQuests

    if Questie.db.profile.trackerHeaderEnabled or (not TrackerUtils.HasQuest()) then
        headerFrame:SetSize(1, Questie.db.profile.trackerFontSizeHeader) -- Width is updated later on
    else
        headerFrame:SetSize(1, 1)
    end

    headerFrame:SetFrameLevel(0)

    headerFrame:Hide()

    TrackerHeaderFrame.headerFrame = headerFrame

    return headerFrame
end

---@return string
local function _GetTrackedQuestsText()
    if Questie.db.char.isTrackerExpanded then
        local maxQuestAmount = "/" .. C_QuestLog.GetMaxNumQuestsCanAccept()
        return l10n("Questie Tracker") .. l10n(": ") .. tostring(QuestLogCache.GetQuestCount()) .. maxQuestAmount
    end

    return l10n("Questie Tracker") .. " +"
end

local function _IsHeaderShown()
    return Questie.db.profile.trackerHeaderEnabled or (not TrackerUtils.HasQuest())
end

-- Only changes the text, so it is safe to call in combat
function TrackerHeaderFrame.UpdateQuestCount()
    if (not headerFrame) or (not _IsHeaderShown()) then
        return
    end

    headerFrame.trackedQuests.label:SetText(_GetTrackedQuestsText())
end

-- The label is sized for the longest quest count, so a count set in combat, e.g. "10/25" after "9/25", is not cut off
function TrackerHeaderFrame.ExpandLabelWidth()
    if (not _IsHeaderShown()) then
        return
    end

    local label = headerFrame.trackedQuests.label
    local text = label:GetText()
    if Questie.db.char.isTrackerExpanded then
        local maxQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
        label:SetText(l10n("Questie Tracker") .. l10n(": ") .. maxQuests .. "/" .. maxQuests)
    end
    local neededWidth = label:GetUnboundedStringWidth()
    label:SetText(text)

    -- The label starts behind the icon, which is 6 pixels from the left, and has a gap of 2 pixels to it
    local availableWidth = trackerBaseFrame:GetWidth() - (6 + Questie.db.profile.trackerFontSizeHeader + 2)
    label:SetWidth(math.max(neededWidth, availableWidth))
end

function TrackerHeaderFrame:Update()
    local trackerFontSizeHeader = Questie.db.profile.trackerFontSizeHeader
    local trackerFontSizeZone = Questie.db.profile.trackerFontSizeZone

    if _IsHeaderShown() then
        headerFrame:ClearAllPoints()
        headerFrame.questieIcon.texture:SetWidth(trackerFontSizeHeader)
        headerFrame.questieIcon.texture:SetHeight(trackerFontSizeHeader)

        headerFrame.questieIcon:ClearAllPoints()
        headerFrame.questieIcon:SetWidth(trackerFontSizeHeader)
        headerFrame.questieIcon:SetHeight(trackerFontSizeHeader)
        headerFrame.questieIcon:SetAlpha(1)
        headerFrame.questieIcon:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 6, 0)
        headerFrame.questieIcon:Show()

        headerFrame.trackedQuests.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontHeader), trackerFontSizeHeader, Questie.db.profile.trackerFontOutline)

        headerFrame.trackedQuests.label:SetText(_GetTrackedQuestsText())

        headerFrame.trackedQuests.label:SetPoint("TOPLEFT", headerFrame.questieIcon, "TOPRIGHT", 2, 0)
        headerFrame.trackedQuests:SetWidth(headerFrame.trackedQuests.label:GetUnboundedStringWidth())
        headerFrame.trackedQuests:SetHeight(trackerFontSizeHeader)
        headerFrame.trackedQuests:SetPoint("TOPLEFT", headerFrame.questieIcon, "TOPRIGHT", 2, 0)
        headerFrame.trackedQuests:Show()

        headerFrame:SetWidth(headerFrame.trackedQuests.label:GetUnboundedStringWidth() + trackerFontSizeHeader)
        headerFrame:SetHeight(trackerFontSizeHeader + 5)
        headerFrame:Show()

        TrackerHeaderFrame.PositionTrackerHeaderFrame(headerFrame, trackerBaseFrame)

        QuestieCompat.SetResizeBounds(trackerBaseFrame, headerFrame.trackedQuests.label:GetUnboundedStringWidth(), trackerFontSizeHeader)
    else
        headerFrame:Hide()

        headerFrame.questieIcon.texture:SetWidth(trackerFontSizeZone)
        headerFrame.questieIcon.texture:SetHeight(trackerFontSizeZone)

        headerFrame.questieIcon:ClearAllPoints()
        headerFrame.questieIcon:SetWidth(trackerFontSizeZone)
        headerFrame.questieIcon:SetHeight(trackerFontSizeZone)
        headerFrame.questieIcon:SetAlpha(0)

        if Questie.db.profile.moveHeaderToBottom then
            headerFrame.questieIcon:SetPoint("BOTTOMRIGHT", trackerBaseFrame, "BOTTOMRIGHT", -4, 8)
        else
            headerFrame.questieIcon:SetPoint("TOPRIGHT", trackerBaseFrame, "TOPRIGHT", -4, -8)
        end

        headerFrame.questieIcon:Show()

        headerFrame.trackedQuests:Hide()
    end
end

function TrackerHeaderFrame.PositionTrackerHeaderFrame()
    if Questie.db.profile.moveHeaderToBottom then
        -- Move tracker header to the bottom
        headerFrame:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 5)
    else
        if Questie.db.char.isTrackerExpanded then
            -- Move tracker header to the top
            headerFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -10)
        else
            -- Tracker minimized. Move tracker header to the bottom
            headerFrame:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 5)
        end
    end
end
