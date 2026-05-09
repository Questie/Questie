---@meta _
---@alias AceGUILayoutType
---|"Flow"
---|"List"
---|"Fill"
---|"Table"

---@alias AceGUIWidgetType
---|"BlizOptionsGroup"
---|"Button"
---|"CheckBox"
---|"ColorPicker"
---|"Dropdown"
---|"EditBox"
---|"Heading"
---|"Icon"
---|"InteractiveLabel"
---|"Keybinding"
---|"Label"
---|"MultiLineEditBox"
---|"Slider"

---@alias AceGUIContainerType
---|"DropdownGroup"
---|"Frame"
---|"InlineGroup"
---|"ScrollFrame"
---|"SimpleGroup"
---|"TabGroup"
---|"TreeGroup"
---|"Window"

---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0)
---@class AceGUI-3.0
---@field tooltip GameTooltip
local AceGUI = {}

---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-2)
function AceGUI:ClearFocus() end

---@param type AceGUIWidgetType|AceGUIContainerType
---@return AceGUIWidget
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-3)
function AceGUI:Create(type) end

---@param Name AceGUILayoutType
---@return function
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-4)
function AceGUI:GetLayout(Name) end

---@param type string
---@return number
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-5)
function AceGUI:GetNextWidgetNum(type) end

---@param type string
---@return number
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-6)
function AceGUI:GetWidgetCount(type) end

---@param type string
---@return number
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-7)
function AceGUI:GetWidgetVersion(type) end

---@param widget AceGUIWidget
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-8)
function AceGUI:RegisterAsContainer(widget) end

---@param widget AceGUIWidget
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-9)
function AceGUI:RegisterAsWidget(widget) end

---@param Name string
---@param LayoutFunc function
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-10)
function AceGUI:RegisterLayout(Name, LayoutFunc) end

---@param Name string
---@param Constructor function
---@param Version number
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-11)
function AceGUI:RegisterWidgetType(Name, Constructor, Version) end

---@param widget AceGUIWidget
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-12)
function AceGUI:Release(widget) end

---@param widget AceGUIWidget
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-gui-3-0#title-13)
function AceGUI:SetFocus(widget) end

---@meta _
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets)
---@class AceGUIWidget
---@field public type string
---@field protected frame Frame
---@field protected userdata table
---@field protected events table<string,function>
---@field protected width? string|number
---@field protected height? string|number
local AceGUIWidget = {}

---@param name string
---@param func function
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-1)
function AceGUIWidget:SetCallback(name, func) end

---@param width number
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-2)
function AceGUIWidget:SetWidth(width) end

---@param width number
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-3)
function AceGUIWidget:SetRelativeWidth(width) end

---@param height number
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-4)
function AceGUIWidget:SetHeight(height) end

---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-5)
function AceGUIWidget:IsVisible() end

---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-6)
function AceGUIWidget:IsShown() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-7)
function AceGUIWidget:Release() end

---@param point FramePoint
---@param relativeTo Region|string
---@param relativePoint string
---@param ofsx? number
---@param ofsy? number
---@overload fun(self, point: FramePoint, relativeTo: Region|string, ofsx?: number, ofsy?: number)
---@overload fun(self, point: FramePoint, ofsx?: number, ofsy?: number)
---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_SetPoint)
function AceGUIWidget:SetPoint(point, relativeTo, relativePoint, ofsx, ofsy) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-9)
function AceGUIWidget:ClearAllPoints() end

---@return number
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-10)
function AceGUIWidget:GetNumPoints() end

---@param index number
---@return string point
---@return Region relativeTo
---@return string relativePoint
---@return number xOfs
---@return number yOfs
---[Documentation](https://warcraft.wiki.gg/wiki/API_Region_GetPoint)
function AceGUIWidget:GetPoint(index) end

---@return table
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-12)
function AceGUIWidget:GetUserDataTable() end

---@param key any
---@param value any
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-13)
function AceGUIWidget:SetUserData(key, value) end

---@param key any
---@return any
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-14)
function AceGUIWidget:GetUserData(key) end

---@param isFull boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-15)
function AceGUIWidget:SetFullHeight(isFull) end

---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-16)
function AceGUIWidget:IsFullHeight() end

---@param isFull boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-17)
function AceGUIWidget:SetFullWidth(isFull) end

---@return boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-1-18)
function AceGUIWidget:IsFullWidth() end

---@param parent Region|string|nil
function AceGUIWidget:SetParent(parent) end

---@param name string
function AceGUIWidget:Fire(name, ...) end

---@return boolean
function AceGUIWidget:IsReleasing() end

---@meta _
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets)
---@class AceGUIContainer : AceGUIWidget
---@field protected children AceGUIWidget[]
---@field protected content Frame
local AceGUIContainer = {}

---@param widget AceGUIWidget
---@param beforeWidget? AceGUIWidget
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-1)
function AceGUIContainer:AddChild(widget, beforeWidget) end

---@param layout AceGUILayoutType
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-2)
function AceGUIContainer:SetLayout(layout) end

---@param flag boolean
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-3)
function AceGUIContainer:SetAutoAdjustHeight(flag) end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-4)
function AceGUIContainer:ReleaseChildren() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-5)
function AceGUIContainer:DoLayout() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-6)
function AceGUIContainer:PauseLayout() end

---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-gui-3-0-widgets#title-3-7)
function AceGUIContainer:ResumeLayout() end

function AceGUIContainer:PerformLayout() end
