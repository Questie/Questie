---@meta _

MenuUtil = {}

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.TraverseMenu)
---@param elementDescription RootMenuDescriptionProxy|ElementMenuDescriptionProxy
---@param op fun(elementDescription: ElementMenuDescriptionProxy): boolean? # return true to stop traversal
---@param condition nil|fun(elementDescription: ElementMenuDescriptionProxy): boolean # return true to apply `op` to the element description; if nil, all elements are processed
---@return boolean stopped # true if the traversal was stopped by `op` returning true
function MenuUtil.TraverseMenu(elementDescription, op, condition) end

---Return a list of all selected elements, optionally filtered by a condition
---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.GetSelections)
---@param elementDescription RootMenuDescriptionProxy|ElementMenuDescriptionProxy
---@param condition nil|fun(elementDescription: ElementMenuDescriptionProxy): boolean # return true to include the element description
function MenuUtil.GetSelections(elementDescription, condition) end

---Sets up a tooltip anchored to the right of the owner, applying the given function to it, and showing it
---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.ShowTooltip)
---@param owner Region
---@param func fun(tooltip: GameTooltip, ...)
---@param ... any?
function MenuUtil.ShowTooltip(owner, func, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.HideTooltip)
---@param owner Region
function MenuUtil.HideTooltip(owner) end

---Hooks OnEnter and OnLeave for a reagion, configures a tooltip, calls the given function, and shows the tooltip
---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.HookTooltipScripts)
---@param owner Region
---@param func fun(tooltip: GameTooltip) # called both in OnEnter and OnLeave
function MenuUtil.HookTooltipScripts(owner, func) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateRootMenuDescription)
---@generic M: table
---@param menuMixin M
---@return RootMenuDescriptionProxy|M rootMenuDescription
function MenuUtil.CreateRootMenuDescription(menuMixin) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateContextMenu)
---@param ownerRegion Region? # if nil, defaults to UIParent
---@param generator fun(ownerRegion: Region, description: RootMenuDescriptionProxy, ...)
---@param ... any? # passed to the generator
---@return MenuProxy? menu
function MenuUtil.CreateContextMenu(ownerRegion, generator, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.SetElementText)
---@param elementDescription ElementMenuDescriptionProxy
---@param text string
function MenuUtil.SetElementText(elementDescription, text) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.GetElementText)
---@param elementDescription ElementMenuDescriptionProxy
---@return string text
function MenuUtil.GetElementText(elementDescription) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateFrame)
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateFrame() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateTemplate)
---@param template Template
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateTemplate(template) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateTitle)
---@param text string
---@param color colorRGBA? # defaults to NORMAL_FONT_COLOR
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateTitle(text, color) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateButton)
---@param text string
---@param callback MenuResponder
---@param data any? # stored as element's data
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateButton(text, callback, data) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateCheckbox)
---@param text string
---@param isSelected fun(data: any): boolean # data = data param -> element:GetData()
---@param setSelected MenuResponder
---@param data any? # stored as element's data
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateCheckbox(text, isSelected, setSelected, data) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateRadio)
---@param text string
---@param isSelected fun(data: any): boolean # data = data param -> element:GetData()
---@param setSelected MenuResponder
---@param data any? # stored as element's data
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateRadio(text, isSelected, setSelected, data) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateColorSwatch)
---@param text string
---@param callback MenuResponder
---@param colorInfo colorRGBA # stored as element's data
---@return ElementMenuDescriptionProxy
function MenuUtil.CreateColorSwatch(text, callback, colorInfo) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuTemplates.CreateDivider)
---@return ElementMenuDescriptionProxy # some inserters and utility functions are missing
function MenuUtil.CreateDivider() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuTemplates.CreateSpacer)
---@param extend number? # height of the spacer, default = 10
---@return ElementMenuDescriptionProxy # some inserters and utility functions are missing
function MenuUtil.CreateSpacer(extend) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateButtonMenu)
---@param dropdown DropdownButton
---@param ... {[1]:string, [2]: MenuResponder, [3]: any?} # list of {text, callback, data}
function MenuUtil.CreateButtonMenu(dropdown, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateButtonContextMenu)
---@param ownerRegion Region? # if nil, defaults to UIParent
---@param ... {[1]:string, [2]: MenuResponder, [3]: any?} # list of {text, callback, data}
---@return MenuProxy? menu
function MenuUtil.CreateButtonContextMenu(ownerRegion, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateCheckboxMenu)
---@param dropdown DropdownButton
---@param isSelected fun(data: any): boolean # shared between all menu items
---@param setSelected MenuResponder # shared between all menu items
---@param ... {[1]:string, [2]: any?} # list of {text, data}
function MenuUtil.CreateCheckboxMenu(dropdown, isSelected, setSelected, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateCheckboxContextMenu)
---@param ownerRegion Region? # if nil, defaults to UIParent
---@param isSelected fun(data: any): boolean # shared between all menu items
---@param setSelected MenuResponder # shared between all menu items
---@param ... {[1]:string, [2]: any?} # list of {text, data}
---@return MenuProxy? menu
function MenuUtil.CreateCheckboxContextMenu(ownerRegion, isSelected, setSelected, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateRadioMenu)
---@param dropdown DropdownButton
---@param isSelected fun(data: any): boolean # shared between all menu items
---@param setSelected MenuResponder # shared between all menu items
---@param ... {[1]:string, [2]: any?} # list of {text, data}
function MenuUtil.CreateRadioMenu(dropdown, isSelected, setSelected, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateRadioContextMenu)
---@param ownerRegion Region? # if nil, defaults to UIParent
---@param isSelected fun(data: any): boolean # shared between all menu items
---@param setSelected MenuResponder # shared between all menu items
---@param ... {[1]:string, [2]: any?} # list of {text, data}
---@return MenuProxy? menu
function MenuUtil.CreateRadioContextMenu(ownerRegion, isSelected, setSelected, ...) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateEnumRadioMenu)
---@generic V
---@param dropdown DropdownButton
---@param enum table<V> # a list of values; the value is saved as the element's data
---@param enumTranslator fun(enumValue: V): string # translate the enum value into the text to display
---@param isSelected fun(data: any): boolean # data = enum value
---@param setSelected MenuResponder
---@param orderTbl table<V, number>? # optional table to specify the order of the menu buttons, defaults to ordering by enum value
function MenuUtil.CreateEnumRadioMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/MenuUtil.CreateEnumRadioContextMenu)
---@generic V
---@param dropdown Region? # if nil, defaults to UIParent
---@param enum table<V> # a list of values; the value is saved as the element's data
---@param enumTranslator fun(enumValue: V): string # translate the enum value into the text to display
---@param isSelected fun(data: any): boolean # data = enum value
---@param setSelected MenuResponder
---@param orderTbl table<V, number>? # optional table to specify the order of the menu buttons, defaults to ordering by enum value
---@return MenuProxy? menu
function MenuUtil.CreateEnumRadioContextMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl) end
