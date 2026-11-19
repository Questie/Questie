---@class QuestieMenuBuilder
local QuestieMenuBuilder = QuestieLoader:CreateModule("QuestieMenuBuilder")

---@class MenuBuilderEntry
---@field text string?
---@field isTitle boolean?
---@field isDivider boolean?
---@field func fun(mouseButton: string?): MenuResponse?  Runs synchronously inside the click, so restricted APIs keep their hardware event. A returned MenuResponse overrides the default response.
---@field checked (boolean|fun(): boolean)?  Turns the entry into a checkbox. Evaluated on every redraw.
---@field disabled (boolean|fun(): boolean)?
---@field icon (string|number)?
---@field keepShownOnClick boolean? Redraws the menu instead of closing it after a click.
---@field registerForRightClick boolean?
---@field initializer fun(button: Button)? Runs every time the entry's button is (re)drawn.
---@field menuList MenuBuilderEntry[]? Makes the entry a submenu.

local function _Resolve(value)
    if type(value) == "function" then
        return value()
    end
    return value
end

---@param entry MenuBuilderEntry
---@return string
local function _GetLabel(entry)
    if entry.icon then
        return "|T" .. entry.icon .. ":16|t " .. entry.text
    end
    return entry.text
end

---@param entry MenuBuilderEntry
local function _GetResponder(entry)
    return function(_, menuInputData)
        local response
        if entry.func then
            response = entry.func(menuInputData and menuInputData.buttonName)
        end
        if type(response) == "number" then
            return response
        end
        if entry.keepShownOnClick then
            return MenuResponse.Refresh
        end
        return MenuResponse.CloseAll
    end
end

local function _AddEntries(parent, entries)
    for _, entry in ipairs(entries) do
        if entry.isDivider then
            parent:CreateDivider()
        elseif entry.isTitle then
            parent:CreateTitle(entry.text)
        else
            local label = _GetLabel(entry)
            local description
            if entry.menuList then
                description = parent:CreateButton(label)
                _AddEntries(description, entry.menuList)
            elseif entry.checked ~= nil then
                description = parent:CreateCheckbox(label, function()
                    return _Resolve(entry.checked) and true or false
                end, _GetResponder(entry))
            else
                description = parent:CreateButton(label, _GetResponder(entry))
            end

            if entry.disabled ~= nil then
                description:SetEnabled(function()
                    return (not _Resolve(entry.disabled))
                end)
            end
            if entry.registerForRightClick then
                description:AddInitializer(function(button)
                    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                end)
            end
            if entry.initializer then
                description:AddInitializer(entry.initializer)
            end
        end
    end
end

---Opens the entries as a context menu at the cursor, or next to the anchor frame when one is given.
---@param entries MenuBuilderEntry[]
---@param anchorFrame Frame?
---@param point FramePoint? Point of the menu to attach, defaults to "TOPLEFT"
---@param relativePoint FramePoint? Point of the anchor frame to attach to, defaults to "TOPRIGHT" (opens to the right)
function QuestieMenuBuilder.Show(entries, anchorFrame, point, relativePoint)
    local function generator(_, rootDescription)
        _AddEntries(rootDescription, entries)
    end

    if (not anchorFrame) then
        MenuUtil.CreateContextMenu(UIParent, generator)
        return
    end

    -- Same steps as MenuUtil.CreateContextMenu, but opened with an anchor instead of at the cursor
    local rootDescription = MenuUtil.CreateRootMenuDescription(MenuVariants.GetDefaultContextMenuMixin())
    Menu.PopulateDescription(generator, anchorFrame, rootDescription)
    Menu.GetManager():OpenMenu(anchorFrame, rootDescription, CreateAnchor(point or "TOPLEFT", anchorFrame, relativePoint or "TOPRIGHT"))
end

function QuestieMenuBuilder.Close()
    Menu.GetManager():CloseMenus()
end

---@return boolean
function QuestieMenuBuilder.IsOpen()
    return Menu.GetManager():IsAnyMenuOpen()
end
