---A dropdown with submenus.
---@class JourneyPicker
local JourneyPicker = QuestieLoader:CreateModule("JourneyPicker")

local MENU_HEIGHT = 480

---@class JourneyPicker.Choice
---@field text string?
---@field value string? Nil for a choice that only has others
---@field choices JourneyPicker.Choice[]?
---@field isDivider boolean?

---@param description table
---@param choices JourneyPicker.Choice[]
---@param onPick fun(value: string)
local function _AddChoices(description, choices, onPick)
    for _, choice in ipairs(choices) do
        if choice.isDivider then
            description:CreateDivider()
        else
            local entry = description:CreateButton(choice.text, choice.value and function() onPick(choice.value) end or nil)
            if choice.choices then
                entry:SetScrollMode(MENU_HEIGHT)
                _AddChoices(entry, choice.choices, onPick)
            end
        end
    end
end

---@param parent Frame
---@param width number
---@param getChoices fun(): JourneyPicker.Choice[]
---@param onPick fun(value: string)
---@return Frame picker
function JourneyPicker.Create(parent, width, getChoices, onPick)
    local picker = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    picker:SetWidth(width)
    local isOpening = false
    local openMenu = picker.OpenMenu
    picker.OpenMenu = function(self)
        isOpening = true
        openMenu(self)
        isOpening = false
    end
    picker:SetupMenu(function(_, rootDescription)
        if isOpening or picker:IsMenuOpen() then
            rootDescription:SetScrollMode(MENU_HEIGHT)
            _AddChoices(rootDescription, getChoices(), onPick)
        end
    end)
    return picker
end

---@param picker Frame
---@param text string
function JourneyPicker.SetText(picker, text)
    picker:OverrideText(text)
end

return JourneyPicker
