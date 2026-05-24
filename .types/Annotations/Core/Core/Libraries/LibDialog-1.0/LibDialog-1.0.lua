-- ----------------------------------------------------------------------------
-- LibDialog-1.0
-- ----------------------------------------------------------------------------
---@meta _
---@class LibDialog-1.0
local lib = {}

--- Determines whether or not a specific dialog is currently active.
---@param reference string|LibDialog.Delegate The delegate criteria for the dialog being targeted. Can be either a string, in which case the delegate must be registered, or a delegate definition table.
---@param data? unknown Additional data to be used as further criteria to determine if the target dialog is active - this would be the same data used to spawn the dialog.
---@return LibDialog.Dialog|nil
function lib:ActiveDialog(reference, data)
end

--- Dismisses a specific dialog.
---@param reference string|LibDialog.Delegate The delegate criteria for the dialog being targeted. Can be either a string, in which case the delegate must be registered, or a delegate definition table.
function lib:Dismiss(reference, data)
end

--- Registers a new dialog delegate.
---@param delegateName string The name the delegate table will be registered under.
---@param delegate LibDialog.Delegate The delegate properties definition.
function lib:Register(delegateName, delegate)
end

--- Spawns a dialog from a delegate reference.
---@param reference string|LibDialog.Delegate The delegate to be used for the spawned dialog. Can be either a string, in which case the delegate must be registered, or a delegate definition table.
---@param data? unknown Additional data to be passed on to the resultant dialog.
---@return LibDialog.Dialog|nil
function lib:Spawn(reference, data)
end

-- ----------------------------------------------------------------------------
-- LibDialog.Dialog
-- ----------------------------------------------------------------------------
---@meta _
---@class LibDialog.Dialog
local dialog = {}

--- Resets the dialog to default settings.
function dialog:Reset()
end

--- Resizes the dialog according to its buttons and other widgets.
function dialog:Resize()
end

-- ----------------------------------------------------------------------------
-- LibDialog.Delegate
-- ----------------------------------------------------------------------------
---@meta _
---@class LibDialog.Delegate
---@field buttons LibDialog.Delegate.Button[] List of Buttons to define in the Dialog.
---@field cancels_on_spawn string[] When the Dialog is spawned, it will cancel all other Dialogs named in the list.
---@field checkboxes LibDialog.Delegate.CheckBox[] List of CheckBoxes to define in the Dialog.
---@field duration number Number of seconds the Dialog will exist before automatically being dismissed.
---@field editboxes LibDialog.Delegate.EditBox[] List of EditBoxes to define in the Dialog.
---@field height number Height for the Dialog (in pixels); if omitted or 0, causes the Dialog's height to be determined automatically based on its contents.
---@field hide_on_escape boolean Causes the Dialog to be dismissed when the Escape key is pressed.
---@field icon string Assigns an icon to the Dialog found at the given file path.
---@field icon_size number Sets the width and height of the Dialog's icon (in pixels). Defaults to 36.
---@field is_exclusive boolean If set to true, the Dialog will dismiss other exclusive Dialogs when spawned.
---@field no_cancel_on_escape boolean When set to true, do not cancel this Dialog when the Escape key is pressed.
---@field no_cancel_on_reuse boolean When set to true, do not cancel pre-existing Dialogs of this designation when a new instance is created.
---@field show_during_cinematic boolean When set to true, do not cancel this Dialog when a Cinematic cut-scene begins.
---@field show_while_dead boolean When set to true, allow the Dialog to be shown while the character is dead.
---@field sound string Plays an audio file at the given path when the Dialog is shown.
---@field static_size number Sets the Dialog's width to the specified size. Ignores contained widgets for resizing purposes.
---@field text string The text displayed on the Dialog, before its widgets.
---@field text_justify_h JustifyHorizontal Sets the Dialog's horizontal text alignment style.
---@field text_justify_v JustifyVertical Sets the Dialog's vertical text alignment style.
---@field width number Width for the Dialog (in pixels); if omitted or 0, causes the Dialog's height to be determined automatically based on its contents.
local delegate = {}

--- Called when the Dialog is canceled.
---@param self Frame Reference to the Dialog for which the script was run.
---@param data unknown|nil The data passed to the Delegate when the Dialog was instantiated via lib:Spawn()
---@param reason? string Reason for cancelation. Not always present. The library will use the following according to circumstance: timeout - Passed when a Dialog's duration has run out. override - Passed when a Dialog is dismissed by either being in the cancelsonspawn list of another Dialog, having its is_exclusive value set to true when another Dialog with its is_exclusive value set is spawned, or when the same Dialog is spawned again and its no_cancel_on_reuse value is empty or false.
function delegate:on_cancel(data, reason)
end

--- Run when the Dialog becomes invisible.
---@param self Frame Reference to the Dialog for which the script was run.
function delegate:on_hide()
end

--- Run when the Dialog becomes visible.
---@param self Frame Reference to the Dialog for which the script was run.
function delegate:on_show()
end

--- Run each time the screen is drawn by the game engine. This handler runs for each frame draw.
---@param self Frame Reference to the Dialog for which the script was run.
---@param elapsed number Number of seconds since the OnUpdate handlers were last run (likely a fraction of a second).
function delegate:on_update(elapsed)
end

-- ----------------------------------------------------------------------------
-- LibDialog.Delegate.Button
-- ----------------------------------------------------------------------------
---@meta _
---@class LibDialog.Delegate.Button: Button
---@field text string The text displayed on the Button. Required.
local button = {}

--- Run when the Button is clicked.
---@param mouseButton string Name of the mouse button responsible for the click action.
---@param down boolean True for a mouse button down action; false for button up or other actions.
function button:on_click(mouseButton, down)
end

-- ----------------------------------------------------------------------------
-- LibDialog.Delegate.CheckBox
-- ----------------------------------------------------------------------------
---@meta _
---@class LibDialog.Delegate.CheckBox: CheckButton
---@field label string The CheckBox label. Required.
local checkBox = {}

--- Run when the CheckBox is clicked.
---@param mouseButton string Name of the mouse button responsible for the click action.
---@param down boolean True for a mouse button down action; false for button up or other actions.
function checkBox:on_click(mouseButton, down)
end

-- ----------------------------------------------------------------------------
-- LibDialog.Delegate.EditBox
-- ----------------------------------------------------------------------------
---@meta _
---@class LibDialog.Delegate.EditBox: EditBox
---@field auto_focus boolean Sets whether the EditBox automatically acquires keyboard input focus.
---@field label string The EditBox label.
---@field max_bytes number Sets the maximum number of bytes of text allowed in the EditBox. Attempts to type more than this number into the EditBox will produce no results; programmatically inserting text or setting the EditBox's text will truncate input to the maximum length. Omitting this value, or setting it to 0, results in no limit. Note: Unicode characters may consist of more than one byte each, so the behavior of a byte limit may differ from that of a character limit in practical use.
---@field max_letters number Sets the maximum number of text characters allowed in the EditBox. Attempts to type more than this number into the EditBox will produce no results; programmatically inserting text or setting the EditBox's text will truncate input to the maximum length. Omitting this value, or setting it to 0, results in no limit.
---@field text string Initial text of the EditBox.
---@field width number Width for the EditBox (in pixels); if 0, causes the EditBox's width to be determined automatically according to its anchor points.
local editBox = {}

--- Run when the Enter (or Return) key is pressed while the EditBox has keyboard focus.
function editBox:on_enter_pressed()
end

--- Run when the Escape key is pressed while the EditBox has keyboard focus.
function editBox:on_escape_pressed()
end

--- Run when the EditBox becomes visible.
function editBox:on_show()
end

--- Run when the EditBox's text is changed. This script is run both when text is typed in the EditBox (for each character entered) and when the EditBox's contents are changed via :SetText() (but only if the text is actually changed).
---@param userInput boolean True if the text changed due to user input; false if the text was changed via :SetText()
function editBox:on_text_changed(userInput)
end
