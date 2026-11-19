---@class TrackerShortcuts
local TrackerShortcuts = QuestieLoader:CreateModule("TrackerShortcuts")

-- A shortcut is a click on a tracker line with at most one modifier key held. It is stored as the
-- modifier followed by the button, e.g. "left", "shiftleft" or "ctrlright". Every click is exactly one
-- shortcut, so a Left Click never runs a Ctrl + Left Click shortcut, and Ctrl + Left Click never runs
-- a Left Click shortcut. Together with Set, which keeps a click bound to one action, a click runs at most one action.
-- The one exception is linking to chat, which no shortcut does: Shift + Left Click links while the chat input is open.

---@alias TrackerShortcutSetting "trackerbindOpenQuestLog"|"trackerbindUntrack"|"trackerbindShareQuest"|"trackerbindSetTomTom"

---Every profile setting that binds a shortcut to a tracker action.
---@type TrackerShortcutSetting[]
local SHORTCUT_SETTINGS = {"trackerbindOpenQuestLog", "trackerbindUntrack", "trackerbindShareQuest", "trackerbindSetTomTom"}

---The shortcut name of each mouse button a shortcut can use.
local SHORTCUT_BUTTONS = {LeftButton = "left", RightButton = "right"}

---@param button string The mouse button of the click, e.g. "LeftButton"
---@return string? shortcut e.g. "left" or "ctrlleft"; nil for another button, or for several modifier keys held at once
local function _GetClickShortcut(button)
    local buttonName = SHORTCUT_BUTTONS[button]
    if not buttonName then
        return nil
    end

    local heldModifiers = {}
    if IsShiftKeyDown() then heldModifiers[#heldModifiers + 1] = "shift" end
    if IsControlKeyDown() then heldModifiers[#heldModifiers + 1] = "ctrl" end
    if IsAltKeyDown() then heldModifiers[#heldModifiers + 1] = "alt" end
    if #heldModifiers > 1 then
        return nil
    end
    return (heldModifiers[1] or "") .. buttonName
end

---Checks whether the current click links a tracker line to chat: Shift + Left Click while the chat input is open.
---This is fixed, like Shift-clicking a link anywhere else, and goes before the shortcut bound to Shift + Left Click.
---@param button string The mouse button of the click, e.g. "LeftButton"
---@return boolean
function TrackerShortcuts.IsLinkClick(button)
    return _GetClickShortcut(button) == "shiftleft" and ChatEdit_GetActiveWindow() ~= nil
end

---Checks whether the current click is the shortcut bound to an action. A disabled action matches no click.
---@param setting TrackerShortcutSetting
---@param button string The mouse button of the click, e.g. "LeftButton"
---@return boolean
function TrackerShortcuts.Matches(setting, button)
    local shortcut = _GetClickShortcut(button)
    return shortcut ~= nil and Questie.db.profile[setting] == shortcut
end

---Binds a shortcut to one tracker action. Any other action bound to the same shortcut is disabled, so a click never has two actions.
---@param setting TrackerShortcutSetting
---@param shortcut string A key of the options' shortcut list, e.g. "ctrlleft" or "disabled"
function TrackerShortcuts.Set(setting, shortcut)
    local profile = Questie.db.profile
    for _, otherSetting in ipairs(SHORTCUT_SETTINGS) do
        if profile[otherSetting] == shortcut then
            profile[otherSetting] = "disabled"
        end
    end
    profile[setting] = shortcut
end
