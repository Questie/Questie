---@class TrackerHeaderFrame
local TrackerHeaderFrame = QuestieLoader:CreateModule("TrackerHeaderFrame")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
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
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
local LSM30 = LibStub("LibSharedMedia-3.0")

local headerFrame, trackerBaseFrame

function TrackerHeaderFrame.Initialize(baseFrame)
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
    questieIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    questieIcon:SetScript("OnClick", function(_, button)
        if button == "LeftButton" then
            if QuestieJourney:IsShown() then
                QuestieJourney.ToggleJourneyWindow()
            end

            QuestieCombatQueue:Queue(function()
                QuestieOptions:OpenConfigWindow()
            end)

            return
        elseif button == "RightButton" then
            if QuestieConfigFrame:IsShown() then
                QuestieConfigFrame:Hide()
            end

            QuestieCombatQueue:Queue(function()
                QuestieJourney.ToggleJourneyWindow()
            end)

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
        GameTooltip:AddLine("Questie " .. QuestieLib:GetAddonVersionString(), 1, 1, 1)
        GameTooltip:AddLine(Questie:Colorize(l10n("Left Click") .. ": ", "gray") .. l10n("Toggle Options"))
        GameTooltip:AddLine(Questie:Colorize(l10n("Right Click") .. ": ", "gray") .. l10n("Toggle My Journey"))
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(Questie:Colorize(l10n("Left Click + Hold") .. ": ", "gray") .. l10n("Drag while Unlocked"))
        GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Left Click + Hold") .. ": ", "gray") .. l10n("Drag while Locked"))

        local VoiceOver, TomTom = TrackerUtils:IsVoiceOverLoaded(), IsAddOnLoaded("TomTom")

        if VoiceOver or TomTom then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(Questie:Colorize(l10n("Questie Tracker Integrations") .. ": ", "gray"))

            if VoiceOver then
                GameTooltip:AddLine(Questie:Colorize(l10n("VoiceOver") .. ": ", "white") .. l10n("Hold shift to see PlayButtons"))
            end

            if TomTom then
                GameTooltip:AddLine(Questie:Colorize(l10n("TomTom") .. ": ", "white") .. l10n("Ctrl + Left Click or Right Click a Quest Title"))
            end
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
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerHeaderFrame:OnClick] - Tracker Minimized")

            self:SetMode(0)
            Questie.db.char.isTrackerExpanded = false
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerHeaderFrame:OnClick] - Tracker Maximized")

            self:SetMode(1)
            Questie.db.char.isTrackerExpanded = true
        end

        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end)

    trackedQuests:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    trackedQuests:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)
    trackedQuests:SetScript("OnEnter", TrackerFadeTicker.Unfade)
    trackedQuests:SetScript("OnLeave", TrackerFadeTicker.Fade)

    trackedQuests:Hide()

    headerFrame.trackedQuests = trackedQuests

    if Questie.db.global.trackerHeaderEnabled then
        headerFrame:SetSize(1, Questie.db.global.trackerFontSizeHeader) -- Width is updated later on
    else
        headerFrame:SetSize(1, 1)
    end

    headerFrame:SetFrameLevel(0)

    headerFrame:Hide()

    TrackerHeaderFrame.headerFrame = headerFrame

    return headerFrame
end

function TrackerHeaderFrame:Update()
    local trackerFontSizeHeader = Questie.db.global.trackerFontSizeHeader
    local trackerFontSizeZone = Questie.db.global.trackerFontSizeZone

    if Questie.db.global.trackerHeaderEnabled then
        headerFrame:ClearAllPoints()
        headerFrame.questieIcon.texture:SetWidth(trackerFontSizeHeader)
        headerFrame.questieIcon.texture:SetHeight(trackerFontSizeHeader)

        headerFrame.questieIcon:ClearAllPoints()
        headerFrame.questieIcon:SetWidth(trackerFontSizeHeader)
        headerFrame.questieIcon:SetHeight(trackerFontSizeHeader)
        headerFrame.questieIcon:SetAlpha(1)
        headerFrame.questieIcon:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 6, 0)
        headerFrame.questieIcon:Show()

        headerFrame.trackedQuests.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontHeader), trackerFontSizeHeader, Questie.db.global.trackerFontOutline)

        local maxQuestAmount = "/" .. C_QuestLog.GetMaxNumQuestsCanAccept()
        local _, activeQuests = GetNumQuestLogEntries()

        if Questie.db.char.isTrackerExpanded then
            headerFrame.trackedQuests.label:SetText(l10n("Questie Tracker") .. ": " .. tostring(activeQuests) .. maxQuestAmount)
        else
            headerFrame.trackedQuests.label:SetText(l10n("Questie Tracker") .. " +")
        end

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

        local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation

        if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") and Questie.db.global.autoMoveHeader then
            headerFrame.questieIcon:SetPoint("BOTTOMRIGHT", trackerBaseFrame, "BOTTOMRIGHT", -4, 8)
        else
            headerFrame.questieIcon:SetPoint("TOPRIGHT", trackerBaseFrame, "TOPRIGHT", -4, -8)
        end

        headerFrame.questieIcon:Show()

        headerFrame.trackedQuests:Hide()
    end
end

function TrackerHeaderFrame.PositionTrackerHeaderFrame()
    local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation
    if Questie.db.global.autoMoveHeader then
        if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
            -- Auto move tracker header to the bottom
            headerFrame:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 5)
        else
            -- Auto move tracker header to the top
            headerFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -10)
        end
    else
        if Questie.db.char.isTrackerExpanded then
            if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") and Questie.db.global.alwaysShowTracker and (not QuestieTracker:HasQuest()) then
                -- No Automove and Always Show Tracker. Move tracker header to the bottom
                headerFrame:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 5)
            else
                -- No Automove. Tracker header always up top
                headerFrame:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -10)
            end
        else
            -- Tracker minimized. Move header to the bottom
            headerFrame:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 5)
        end
    end
end
