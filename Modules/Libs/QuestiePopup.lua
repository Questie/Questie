-- luacheck: globals AddonDialog

-- Keep the shared library behind QuestieLoader. Use a different module name:
-- PopulateGlobals exports modules during debugging and must not replace AddonDialog.
---@class QuestiePopup
---@field Dialogs table<string, DialogDefinition>
---@field Show fun(key: string, textArg1: string|number?, textArg2: string|number?, data: any): DialogFrame?
---@field FindVisible fun(key: string): DialogFrame?
---@field Hide fun(key: string)
local Popup = QuestieLoader:CreateModule("QuestiePopup")

Popup.Dialogs = AddonDialog.Dialogs
Popup.Show = AddonDialog.Show
Popup.FindVisible = AddonDialog.FindVisible
Popup.Hide = AddonDialog.Hide
