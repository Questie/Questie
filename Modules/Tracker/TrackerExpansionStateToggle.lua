---@class TrackerExpansionStateToggle
local TrackerExpansionStateToggle = QuestieLoader:CreateModule("TrackerExpansionStateToggle")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")

local TrackerCollapseBtn

function TrackerExpansionStateToggle.Initialize()
    -- Create a secure button to execute TrackerExpansionStateToggle with ESC
    TrackerCollapseBtn = CreateFrame("Button", "TESTButton", UIParent, "SecureActionButtonTemplate")
    TrackerCollapseBtn:SetAttribute("type", "macro")
    TrackerCollapseBtn:SetAttribute("macrotext", "/run G_TrackerExpansionStateToggle()")
end

-- Toggles the Questie tracker expansion state (called by the keybind)
function TrackerExpansionStateToggle.Toggle()
    if UnitAffectingCombat("player") then
        return
    end
    if Questie.db.char.isTrackerExpanded then
        QuestieTracker:Collapse()
        ClearOverrideBindings(TrackerCollapseBtn)  -- Remove the override when collapsed
    else
        QuestieTracker:Expand()
        if QuestieTracker and Questie.db.global.useEscapeKeyForTracker and Questie.db.char.isTrackerExpanded then
            SetOverrideBinding(TrackerCollapseBtn, false, "ESCAPE", "CLICK TESTButton:LeftButton")
        end
    end
end

function G_TrackerCreateButton()
    if QuestieTracker and Questie.db.char.isTrackerExpanded then
        SetOverrideBinding(TrackerCollapseBtn, false, "ESCAPE", "CLICK TESTButton:LeftButton")
    end
end

-- Global function to toggle the tracker
function G_TrackerExpansionStateToggle()
    TrackerExpansionStateToggle:Toggle()
end

-- Event frame for detecting combat state changes
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering combat
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Leaving combat

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- Player entered combat
        if QuestieTracker and Questie.db.char.isTrackerExpanded then
            ClearOverrideBindings(TrackerCollapseBtn)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Player left combat
        if Questie.db.global.useEscapeKeyForTracker and QuestieTracker and Questie.db.char.isTrackerExpanded then
            SetOverrideBinding(TrackerCollapseBtn, false, "ESCAPE", "CLICK TESTButton:LeftButton")
        end
    end
end)
