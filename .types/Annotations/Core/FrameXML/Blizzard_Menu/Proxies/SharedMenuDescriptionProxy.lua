---@meta _

---@class SharedMenuDescriptionProxy
local SharedMenuDescriptionProxy = {}

---@return boolean
function SharedMenuDescriptionProxy:HasElements() end

---@return fun(): number, ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:EnumerateElementDescriptions() end

---@param elementDescription ElementMenuDescriptionProxy
---@param index number? # allows inserting at a specific index, default is last
function SharedMenuDescriptionProxy:Insert(elementDescription, index) end

---@see MenuUtil.CreateTitle
---@param text string
---@param color colorRGBA? # defaults to NORMAL_FONT_COLOR
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateTitle(text, color) end

---@see MenuUtil.CreateDivider
---@return ElementMenuDescriptionProxy # some inserters and utility functions are missing
function SharedMenuDescriptionProxy:CreateDivider() end

---@see MenuUtil.CreateSpacer
---@param extend number? # height of the spacer, default = 10
---@return ElementMenuDescriptionProxy # some inserters and utility functions are missing
function SharedMenuDescriptionProxy:CreateSpacer(extend) end

---@see MenuUtil.CreateButton
---@param text string
---@param callback MenuResponder
---@param data any? # stored as element's data
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateButton(text, callback, data) end

---@see MenuUtil.CreateCheckbox
---@param text string
---@param isSelected fun(data: any): boolean # data = data param -> element:GetData()
---@param setSelected MenuResponder
---@param data any? # stored as element's data
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateCheckbox(text, isSelected, setSelected, data) end

---@see MenuUtil.CreateRadio
---@param text string
---@param isSelected fun(data: any): boolean # data = data param -> element:GetData()
---@param setSelected MenuResponder
---@param data any? # stored as element's data
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateRadio(text, isSelected, setSelected, data) end

---@see MenuUtil.CreateColorSwatch
---@param text string
---@param callback MenuResponder
---@param colorInfo colorRGBA # stored as element's data
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateColorSwatch(text, callback, colorInfo) end

---@see MenuUtil.CreateFrame
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateFrame() end

---@see MenuUtil.CreateTemplate
---@param template Template
---@return ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:CreateTemplate(template) end

---@see RootMenuDescriptionProxyMixin.AddQueuedDescription
---@param queuedDescription ElementMenuDescriptionProxy
function SharedMenuDescriptionProxy:AddQueuedDescription(queuedDescription) end

---@see RootMenuDescriptionProxyMixin.ClearQueueDescriptions
function SharedMenuDescriptionProxy:ClearQueueDescriptions() end

---@see MenuUtilPrivate.Utilities.QueueTitle
---@param text string
---@param color colorRGBA? # defaults to NORMAL_FONT_COLOR
---@param clearQueue boolean? # if true, all previously queued descriptions are cleared
function SharedMenuDescriptionProxy:QueueTitle(text, color, clearQueue) end

---@see MenuUtilPrivate.Utilities.QueueDivider
---@param clearQueue boolean? # if true, all previously queued descriptions are cleared
function SharedMenuDescriptionProxy:QueueDivider(clearQueue) end

---@see MenuUtilPrivate.Utilities.QueueSpacer
---@param extend number? # height of the spacer, default = 10
---@param clearQueue boolean? # if true, all previously queued descriptions are cleared
function SharedMenuDescriptionProxy:QueueSpacer(extend, clearQueue) end

---@see MenuUtilPrivate.Utilities.SetTitleAndTextTooltip
---@param title string
---@param text string
function SharedMenuDescriptionProxy:SetTitleAndTextTooltip(title, text) end

---@see MenuUtilPrivate.Utilities.SetTooltip
---@param initializer fun(tooltip: GameTooltip, elementDescription: ElementMenuDescriptionProxy)
function SharedMenuDescriptionProxy:SetTooltip(initializer) end

---@param initializer MenuDescriptionInitializer
---@param index number? # allows specifying an insert order, to run before / after some other initializer; default is last
function SharedMenuDescriptionProxy:AddInitializer(initializer, index) end

---@param initializer MenuDescriptionInitializer
function SharedMenuDescriptionProxy:SetFinalInitializer(initializer) end

---Registers a callback that will be executed when the MenuDescription's frame is cleaned up on hiding
---Especially useful if you add customizations in the Initializer that aren't reset automatically
---@param resetter fun(frame: Frame)
function SharedMenuDescriptionProxy:AddResetter(resetter) end

---@see RootMenuDescriptionProxyMixin.GetTag
---@return string? tag
---@return any? contextData
function SharedMenuDescriptionProxy:GetTag() end

---@see RootMenuDescriptionProxyMixin.SetTag
---@param tag string
---@param contextData any?
function SharedMenuDescriptionProxy:SetTag(tag, contextData) end

---@return number
function SharedMenuDescriptionProxy:GetMinimumWidth() end

---@param width number
function SharedMenuDescriptionProxy:SetMinimumWidth(width) end

---@param width number
function SharedMenuDescriptionProxy:SetMaximumWidth(width) end

function SharedMenuDescriptionProxy:ClearQueuedDescriptions() end

---@param direction MenuGridDirection
---@param columns number? # if not specified, determines the number of columns based on the number of elements
---@param padding number? # defaults to 0
---@param compactionMargin number? # defaults to disabled
function SharedMenuDescriptionProxy:SetGridMode(direction, columns, padding, compactionMargin) end

---@param maxScrollExtent number? # item height * number of items, defaults to 200
function SharedMenuDescriptionProxy:SetScrollMode(maxScrollExtent) end
