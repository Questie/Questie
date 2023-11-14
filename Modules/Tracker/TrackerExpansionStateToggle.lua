-- Create a secure button to execute TrackerExpansionStateToggle
local btn = CreateFrame("Button", "MySecureButton", UIParent, "SecureActionButtonTemplate")
btn:SetAttribute("type", "macro")
btn:SetAttribute("macrotext", "/run TrackerExpansionStateToggle()")

-- Toggle the Questie tracker expansion state (called by the keybind)
function TrackerExpansionStateToggle()
    local qt = QuestieLoader:ImportModule("QuestieTracker")
    if Questie.db.char.isTrackerExpanded then
        qt:Collapse()
        ClearOverrideBindings(btn)  -- Remove the override when collapsed
    else
        qt:Expand()
        SetOverrideBinding(btn, false, "ESCAPE", "CLICK MySecureButton:LeftButton")  -- Set the override when expanded
    end
end

-- Initialize the override binding based on the current state
local frame = _G["TrackerBaseFrame"]  -- Get the Questie tracker frame
if frame then  -- Check if the frame exists
    if Questie and Questie.db.char.isTrackerExpanded then
        SetOverrideBinding(btn, false, "ESCAPE", "CLICK MySecureButton:LeftButton")  -- Set the override if initially expanded
    end
end
