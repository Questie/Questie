---@class ActiveQuestsHeader
local ActiveQuestsHeader = QuestieLoader:CreateModule("ActiveQuestsHeader")

---@type FadeTicker
local FadeTicker = QuestieLoader:ImportModule("FadeTicker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LSM30 = LibStub("LibSharedMedia-3.0", true)

local marginLeft = 10
local trackerSpaceBuffer = 10

---@param trackerBaseFrame Frame
function ActiveQuestsHeader.Initialize(trackerBaseFrame, OnClick)
    local frm = CreateFrame("Button", nil, trackerBaseFrame)

    if Questie.db.global.trackerHeaderAutoMove then
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
            frm:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", marginLeft, 10)
        else
            frm:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", marginLeft, -10)
        end
    else
        frm:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", marginLeft, -10)
    end

    frm.Update = function(self)
        local trackerFontSizeHeader = Questie.db.global.trackerFontSizeHeader

        if Questie.db.global.trackerHeaderEnabled then
            self:ClearAllPoints()
            self.questieIcon.texture:SetWidth(trackerFontSizeHeader)
            self.questieIcon.texture:SetHeight(trackerFontSizeHeader)
            self.questieIcon.texture:SetPoint("CENTER", 0, 0)

            self.questieIcon:SetWidth(trackerFontSizeHeader)
            self.questieIcon:SetHeight(trackerFontSizeHeader)
            self.questieIcon:SetPoint("TOPLEFT", self, "TOPLEFT", marginLeft, 0)
            self.questieIcon:Show()

            self.trackedQuests.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerFontSizeHeader)

            local maxQuestAmount = "/" .. C_QuestLog.GetMaxNumQuestsCanAccept()

            local _, activeQuests = GetNumQuestLogEntries()
            self.trackedQuests.label:SetText(l10n("Questie Tracker: ") .. tostring(activeQuests) .. maxQuestAmount)
            self.trackedQuests.label:SetPoint("TOPLEFT", self.questieIcon, "TOPLEFT", marginLeft + 5, 0)

            self.trackedQuests:SetWidth(self.trackedQuests.label:GetUnboundedStringWidth())
            self.trackedQuests:SetHeight(trackerFontSizeHeader)
            self.trackedQuests:SetPoint("TOPLEFT", self, "TOPLEFT", 5, 0)
            self.trackedQuests:Show()

            self:SetWidth(self.trackedQuests.label:GetUnboundedStringWidth() + trackerFontSizeHeader)
            self:SetHeight(trackerFontSizeHeader + 5)
            self:Show()

            if Questie.db.global.trackerHeaderAutoMove then
                if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
                    self:SetPoint("BOTTOMLEFT", trackerBaseFrame, "BOTTOMLEFT", 0, 10)
                else
                    self:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -10)
                end
            else
                self:SetPoint("TOPLEFT", trackerBaseFrame, "TOPLEFT", 0, -10)
            end
            trackerBaseFrame:SetMinResize(trackerSpaceBuffer + self.trackedQuests.label:GetUnboundedStringWidth() + trackerSpaceBuffer, trackerFontSizeHeader)
        else
            self:Hide()
            self.questieIcon:Hide()
            self.trackedQuests:Hide()
            trackerBaseFrame:SetMinResize(trackerSpaceBuffer, trackerFontSizeHeader)
        end
    end

    -- Questie Icon Settings
    local questieIcon = CreateFrame("Button", nil, trackerBaseFrame)
    questieIcon:SetPoint("TOPLEFT", frm, "TOPLEFT", 0, 0)

    -- Questie Icon Texture Settings
    questieIcon.texture = questieIcon:CreateTexture(nil, "BACKGROUND", nil, 0)
    questieIcon.texture:SetTexture(ICON_TYPE_COMPLETE)
    questieIcon.texture:SetPoint("CENTER", 0, 0)

    questieIcon:EnableMouse(true)
    questieIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    questieIcon:SetScript("OnClick", function (_, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                Questie.db.char.enabled = (not Questie.db.char.enabled)
                QuestieQuest:ToggleNotes(Questie.db.char.enabled)

                -- Close config window if it's open to avoid desyncing the Checkbox
                QuestieOptions:HideFrame()

                return

            elseif IsControlKeyDown() then
                QuestieQuest:SmoothReset()

                return
            end

            if InCombatLockdown() then
                QuestieOptions:HideFrame()
            else
                QuestieOptions:OpenConfigWindow()
            end

            if QuestieJourney:IsShown() then
                QuestieJourney.ToggleJourneyWindow()
            end

            return

        elseif button == "RightButton" then
            if not IsModifierKeyDown() then

                -- Close config window if it's open to avoid desyncing the Checkbox
                QuestieOptions:HideFrame()

                QuestieJourney.ToggleJourneyWindow()

                return

            elseif IsControlKeyDown() then
                Questie.db.profile.minimap.hide = true;
                Questie.minimapConfigIcon:Hide("Questie")

                return
            end
        end
    end)

    questieIcon:SetScript("OnEnter", function (self)
        if InCombatLockdown() then
            if GameTooltip:IsShown() then
                GameTooltip:Hide()
                return
            end
        end
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1)
        GameTooltip:AddLine(Questie:Colorize(l10n("Left Click") , "gray") .. ": " .. l10n("Toggle Options"))
        GameTooltip:AddLine(Questie:Colorize(l10n("Right Click") , "gray") .. ": " .. l10n("Toggle My Journey"))
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(Questie:Colorize(l10n("Left Click + Hold") , "gray") .. ": " .. l10n("Drag while Unlocked"))
        GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Left Click + Hold"), "gray") .. ": " .. l10n("Drag while Locked"))
        GameTooltip:Show()

        FadeTicker.OnEnter(self)
    end)

    questieIcon:SetScript("OnLeave", function (self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        FadeTicker.OnLeave(self)
    end)

    questieIcon:Hide()
    frm.questieIcon = questieIcon

    -- Questie Tracked Quests Settings
    local trackedQuests = CreateFrame("Button", nil, trackerBaseFrame)
    trackedQuests:SetPoint("TOPLEFT", questieIcon, "TOPLEFT", marginLeft, 0)

    -- Questie Tracked Quests Label
    trackedQuests.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    trackedQuests.label:SetPoint("TOPLEFT", frm, "TOPLEFT", 0, 0)

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

    trackedQuests:SetScript("OnClick", OnClick)

    trackedQuests:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    trackedQuests:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)
    trackedQuests:SetScript("OnEnter", FadeTicker.OnEnter)
    trackedQuests:SetScript("OnLeave", FadeTicker.OnLeave)
    trackedQuests:Hide()
    frm.trackedQuests = trackedQuests

    if Questie.db.global.trackerHeaderEnabled then
        frm:SetSize(1, Questie.db.global.trackerFontSizeHeader) -- Width is updated later on
    else
        frm:SetSize(1, 1)
    end
    frm:SetFrameLevel(0)

    frm:Hide()

    return frm
end
