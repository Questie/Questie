--- **AceGUI-3.0** provides access to numerous widgets which can be used to create GUIs.
-- AceGUI is used by AceConfigDialog to create the option GUIs, but you can use it by itself
-- to create any custom GUI. There are more extensive examples in the test suite in the Ace3 
-- stand-alone distribution.
--
-- **Note**: When using AceGUI-3.0 directly, please do not modify the frames of the widgets directly,
-- as any "unknown" change to the widgets will cause addons that get your widget out of the widget pool
-- to misbehave. If you think some part of a widget should be modifiable, please open a ticket, and we"ll
-- implement a proper API to modify it.
-- @usage
-- local AceGUI = LibStub("AceGUI-3.0")
-- -- Create a container frame
-- local f = AceGUI:Create("Frame")
-- f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
-- f:SetTitle("AceGUI-3.0 Example")
-- f:SetStatusText("Status Bar")
-- f:SetLayout("Flow")
-- -- Create a button
-- local btn = AceGUI:Create("Button")
-- btn:SetWidth(170)
-- btn:SetText("Button !")
-- btn:SetCallback("OnClick", function() print("Click!") end)
-- -- Add the button to the container
-- f:AddChild(btn)
-- @class file
-- @name AceGUI-3.0
-- @release $Id: AceGUI-3.0.lua 1102 2013-10-25 14:15:23Z nevcairiel $
local ACEGUI_MAJOR, ACEGUI_MINOR = "AceGUI-3.0", 34
local AceGUI, oldminor = LibStub:NewLibrary(ACEGUI_MAJOR, ACEGUI_MINOR)

if not AceGUI then return end -- No upgrade needed

-- Lua APIs
local tconcat, tremove, tinsert = table.concat, table.remove, table.insert
local select, pairs, next, type = select, pairs, next, type
local error, assert, loadstring = error, assert, loadstring
local setmetatable, rawget, rawset = setmetatable, rawget, rawset
local math_max = math.max

-- WoW APIs
local UIParent = UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: geterrorhandler, LibStub

--local con = LibStub("AceConsole-3.0",true)

AceGUI.WidgetRegistry = AceGUI.WidgetRegistry or {}
AceGUI.LayoutRegistry = AceGUI.LayoutRegistry or {}
AceGUI.WidgetBase = AceGUI.WidgetBase or {}
AceGUI.WidgetContainerBase = AceGUI.WidgetContainerBase or {}
AceGUI.WidgetVersions = AceGUI.WidgetVersions or {}
 
-- local upvalues
local WidgetRegistry = AceGUI.WidgetRegistry
local LayoutRegistry = AceGUI.LayoutRegistry
local WidgetVersions = AceGUI.WidgetVersions

--[[
	 xpcall safecall implementation
]]
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end
	
		local function dispatch(func, ...)
			method = func
			if not method then return end
			ARGS = ...
			return xpcall(call, eh)
		end
	
		return dispatch
	]]
	
	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", tconcat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})
Dispatchers[0] = function(func)
	return xpcall(func, errorhandler)
end
 
local function safecall(func, ...)
	return Dispatchers[select("#", ...)](func, ...)
end

-- Recycling functions
local newWidget, delWidget
do
	-- Version Upgrade in Minor 29
	-- Internal Storage of the objects changed, from an array table
	-- to a hash table, and additionally we introduced versioning on
	-- the widgets which would discard all widgets from a pre-29 version
	-- anyway, so we just clear the storage now, and don't try to 
	-- convert the storage tables to the new format.
	-- This should generally not cause *many* widgets to end up in trash,
	-- since once dialogs are opened, all addons should be loaded already
	-- and AceGUI should be on the latest version available on the users
	-- setup.
	-- -- nevcairiel - Nov 2nd, 2009
	if oldminor and oldminor < 29 and AceGUI.objPools then
		AceGUI.objPools = nil
	end
	
	AceGUI.objPools = AceGUI.objPools or {}
	local objPools = AceGUI.objPools
	--Returns a new instance, if none are available either returns a new table or calls the given contructor
	function newWidget(type)
		if not WidgetRegistry[type] then
			error("Attempt to instantiate unknown widget type", 2)
		end
		
		if not objPools[type] then
			objPools[type] = {}
		end
		
		local newObj = next(objPools[type])
		if not newObj then
			newObj = WidgetRegistry[type]()
			newObj.AceGUIWidgetVersion = WidgetVersions[type]
		else
			objPools[type][newObj] = nil
			-- if the widget is older then the latest, don't even try to reuse it
			-- just forget about it, and grab a new one.
			if not newObj.AceGUIWidgetVersion or newObj.AceGUIWidgetVersion < WidgetVersions[type] then
				return newWidget(type)
			end
		end
		return newObj
	end
	-- Releases an instance to the Pool
	function delWidget(obj,type)
		if not objPools[type] then
			objPools[type] = {}
		end
		if objPools[type][obj] then
			error("Attempt to Release Widget that is already released", 2)
		end
		objPools[type][obj] = true
	end
end


-------------------
-- API Functions --
-------------------

-- Gets a widget Object

--- Create a new Widget of the given type.
-- This function will instantiate a new widget (or use one from the widget pool), and call the
-- OnAcquire function on it, before returning.
-- @param type The type of the widget.
-- @return The newly created widget.
function AceGUI:Create(type)
	if WidgetRegistry[type] then
		local widget = newWidget(type)

		if rawget(widget, "Acquire") then
			widget.OnAcquire = widget.Acquire
			widget.Acquire = nil
		elseif rawget(widget, "Aquire") then
			widget.OnAcquire = widget.Aquire
			widget.Aquire = nil
		end
		
		if rawget(widget, "Release") then
			widget.OnRelease = rawget(widget, "Release") 
			widget.Release = nil
		end
		
		if widget.OnAcquire then
			widget:OnAcquire()
		else
			error(("Widget type %s doesn't supply an OnAcquire Function"):format(type))
		end
		-- Set the default Layout ("List")
		safecall(widget.SetLayout, widget, "List")
		safecall(widget.ResumeLayout, widget)
		return widget
	end
end

--- Releases a widget Object.
-- This function calls OnRelease on the widget and places it back in the widget pool.
-- Any data on the widget is being erased, and the widget will be hidden.\\
-- If this widget is a Container-Widget, all of its Child-Widgets will be releases as well.
-- @param widget The widget to release
function AceGUI:Release(widget)
	safecall(widget.PauseLayout, widget)
	widget:Fire("OnRelease")
	safecall(widget.ReleaseChildren, widget)

	if widget.OnRelease then
		widget:OnRelease()
--	else
--		error(("Widget type %s doesn't supply an OnRelease Function"):format(widget.type))
	end
	for k in pairs(widget.userdata) do
		widget.userdata[k] = nil
	end
	for k in pairs(widget.events) do
		widget.events[k] = nil
	end
	widget.width = nil
	widget.relWidth = nil
	widget.height = nil
	widget.relHeight = nil
	widget.noAutoHeight = nil
	widget.frame:ClearAllPoints()
	widget.frame:Hide()
	widget.frame:SetParent(UIParent)
	widget.frame.width = nil
	widget.frame.height = nil
	if widget.content then
		widget.content.width = nil
		widget.content.height = nil
	end
	delWidget(widget, widget.type)
end

-----------
-- Focus --
-----------


--- Called when a widget has taken focus.
-- e.g. Dropdowns opening, Editboxes gaining kb focus
-- @param widget The widget that should be focused
function AceGUI:SetFocus(widget)
	if self.FocusedWidget and self.FocusedWidget ~= widget then
		safecall(self.FocusedWidget.ClearFocus, self.FocusedWidget)
	end
	self.FocusedWidget = widget
end


--- Called when something has happened that could cause widgets with focus to drop it
-- e.g. titlebar of a frame being clicked
function AceGUI:ClearFocus()
	if self.FocusedWidget then
		safecall(self.FocusedWidget.ClearFocus, self.FocusedWidget)
		self.FocusedWidget = nil
	end
end

-------------
-- Widgets --
-------------
--[[
	Widgets must provide the following functions
		OnAcquire() - Called when the object is acquired, should set everything to a default hidden state
		
	And the following members
		frame - the frame or derivitive object that will be treated as the widget for size and anchoring purposes
		type - the type of the object, same as the name given to :RegisterWidget()
		
	Widgets contain a table called userdata, this is a safe place to store data associated with the wigdet
	It will be cleared automatically when a widget is released
	Placing values directly into a widget object should be avoided
	
	If the Widget can act as a container for other Widgets the following
		content - frame or derivitive that children will be anchored to
		
	The Widget can supply the following Optional Members
		:OnRelease() - Called when the object is Released, should remove any additional anchors and clear any data
		:OnWidthSet(width) - Called when the width of the widget is changed
		:OnHeightSet(height) - Called when the height of the widget is changed
			Widgets should not use the OnSizeChanged events of thier frame or content members, use these methods instead
			AceGUI already sets a handler to the event
		:LayoutFinished(width, height) - called after a layout has finished, the width and height will be the width and height of the
			area used for controls. These can be nil if the layout used the existing size to layout the controls.

]]

--------------------------
-- Widget Base Template --
--------------------------
do
	local WidgetBase = AceGUI.WidgetBase 
	
	WidgetBase.SetParent = function(self, parent)
		local frame = self.frame
		frame:SetParent(nil)
		frame:SetParent(parent.content)
		self.parent = parent
	end
	
	WidgetBase.SetCallback = function(self, name, func)
		if type(func) == "function" then
			self.events[name] = func
		end
	end
	
	WidgetBase.Fire = function(self, name, ...)
		if self.events[name] then
			local success, ret = safecall(self.events[name], self, name, ...)
			if success then
				return ret
			end
		end
	end
	
	WidgetBase.SetWidth = function(self, width)
		self.frame:SetWidth(width)
		self.frame.width = width
		if self.OnWidthSet then
			self:OnWidthSet(width)
		end
	end
	
	WidgetBase.SetRelativeWidth = function(self, width)
		if width <= 0 or width > 1 then
			error(":SetRelativeWidth(width): Invalid relative width.", 2)
		end
		self.relWidth = width
		self.width = "relative"
	end
	
	WidgetBase.SetHeight = function(self, height)
		self.frame:SetHeight(height)
		self.frame.height = height
		if self.OnHeightSet then
			self:OnHeightSet(height)
		end
	end
	
	--[[ WidgetBase.SetRelativeHeight = function(self, height)
		if height <= 0 or height > 1 then
			error(":SetRelativeHeight(height): Invalid relative height.", 2)
		end
		self.relHeight = height
		self.height = "relative"
	end ]]

	WidgetBase.IsVisible = function(self)
		return self.frame:IsVisible()
	end
	
	WidgetBase.IsShown= function(self)
		return self.frame:IsShown()
	end
		
	WidgetBase.Release = function(self)
		AceGUI:Release(self)
	end
	
	WidgetBase.SetPoint = function(self, ...)
		return self.frame:SetPoint(...)
	end
	
	WidgetBase.ClearAllPoints = function(self)
		return self.frame:ClearAllPoints()
	end
	
	WidgetBase.GetNumPoints = function(self)
		return self.frame:GetNumPoints()
	end
	
	WidgetBase.GetPoint = function(self, ...)
		return self.frame:GetPoint(...)
	end	
	
	WidgetBase.GetUserDataTable = function(self)
		return self.userdata
	end
	
	WidgetBase.SetUserData = function(self, key, value)
		self.userdata[key] = value
	end
	
	WidgetBase.GetUserData = function(self, key)
		return self.userdata[key]
	end
	
	WidgetBase.IsFullHeight = function(self)
		return self.height == "fill"
	end
	
	WidgetBase.SetFullHeight = function(self, isFull)
		if isFull then
			self.height = "fill"
		else
			self.height = nil
		end
	end
	
	WidgetBase.IsFullWidth = function(self)
		return self.width == "fill"
	end
		
	WidgetBase.SetFullWidth = function(self, isFull)
		if isFull then
			self.width = "fill"
		else
			self.width = nil
		end
	end
	
--	local function LayoutOnUpdate(this)
--		this:SetScript("OnUpdate",nil)
--		this.obj:PerformLayout()
--	end
	
	local WidgetContainerBase = AceGUI.WidgetContainerBase
		
	WidgetContainerBase.PauseLayout = function(self)
		self.LayoutPaused = true
	end
	
	WidgetContainerBase.ResumeLayout = function(self)
		self.LayoutPaused = nil
	end
	
	WidgetContainerBase.PerformLayout = function(self)
		if self.LayoutPaused then
			return
		end
		safecall(self.LayoutFunc, self.content, self.children)
	end
	
	--call this function to layout, makes sure layed out objects get a frame to get sizes etc
	WidgetContainerBase.DoLayout = function(self)
		self:PerformLayout()
--		if not self.parent then
--			self.frame:SetScript("OnUpdate", LayoutOnUpdate)
--		end
	end
	
	WidgetContainerBase.AddChild = function(self, child, beforeWidget)
		if beforeWidget then
			local siblingIndex = 1
			for _, widget in pairs(self.children) do
				if widget == beforeWidget then
					break
				end
				siblingIndex = siblingIndex + 1 
			end
			tinsert(self.children, siblingIndex, child)
		else
			tinsert(self.children, child)
		end
		child:SetParent(self)
		child.frame:Show()
		self:DoLayout()
	end
	
	WidgetContainerBase.AddChildren = function(self, ...)
		for i = 1, select("#", ...) do
			local child = select(i, ...)
			tinsert(self.children, child)
			child:SetParent(self)
			child.frame:Show()
		end
		self:DoLayout()
	end
	
	WidgetContainerBase.ReleaseChildren = function(self)
		local children = self.children
		for i = 1,#children do
			AceGUI:Release(children[i])
			children[i] = nil
		end
	end
	
	WidgetContainerBase.SetLayout = function(self, Layout)
		self.LayoutFunc = AceGUI:GetLayout(Layout)
	end

	WidgetContainerBase.SetAutoAdjustHeight = function(self, adjust)
		if adjust then
			self.noAutoHeight = nil
		else
			self.noAutoHeight = true
		end
	end

	local function FrameResize(this)
		local self = this.obj
		if this:GetWidth() and this:GetHeight() then
			if self.OnWidthSet then
				self:OnWidthSet(this:GetWidth())
			end
			if self.OnHeightSet then
				self:OnHeightSet(this:GetHeight())
			end
		end
	end
	
	local function ContentResize(this)
		if this:GetWidth() and this:GetHeight() then
			this.width = this:GetWidth()
			this.height = this:GetHeight()
			this.obj:DoLayout()
		end
	end

	setmetatable(WidgetContainerBase, {__index=WidgetBase})

	--One of these function should be called on each Widget Instance as part of its creation process
	
	--- Register a widget-class as a container for newly created widgets.
	-- @param widget The widget class
	function AceGUI:RegisterAsContainer(widget)
		widget.children = {}
		widget.userdata = {}
		widget.events = {}
		widget.base = WidgetContainerBase
		widget.content.obj = widget
		widget.frame.obj = widget
		widget.content:SetScript("OnSizeChanged", ContentResize)
		widget.frame:SetScript("OnSizeChanged", FrameResize)
		setmetatable(widget, {__index = WidgetContainerBase})
		widget:SetLayout("List")
		return widget
	end
	
	--- Register a widget-class as a widget.
	-- @param widget The widget class
	function AceGUI:RegisterAsWidget(widget)
		widget.userdata = {}
		widget.events = {}
		widget.base = WidgetBase
		widget.frame.obj = widget
		widget.frame:SetScript("OnSizeChanged", FrameResize)
		setmetatable(widget, {__index = WidgetBase})
		return widget
	end
end




------------------
-- Widget API   --
------------------

--- Registers a widget Constructor, this function returns a new instance of the Widget
-- @param Name The name of the widget
-- @param Constructor The widget constructor function
-- @param Version The version of the widget
function AceGUI:RegisterWidgetType(Name, Constructor, Version)
	assert(type(Constructor) == "function")
	assert(type(Version) == "number") 
	
	local oldVersion = WidgetVersions[Name]
	if oldVersion and oldVersion >= Version then return end
	
	WidgetVersions[Name] = Version
	WidgetRegistry[Name] = Constructor
end

--- Registers a Layout Function
-- @param Name The name of the layout
-- @param LayoutFunc Reference to the layout function
function AceGUI:RegisterLayout(Name, LayoutFunc)
	assert(type(LayoutFunc) == "function")
	if type(Name) == "string" then
		Name = Name:upper()
	end
	LayoutRegistry[Name] = LayoutFunc
end

--- Get a Layout Function from the registry
-- @param Name The name of the layout
function AceGUI:GetLayout(Name)
	if type(Name) == "string" then
		Name = Name:upper()
	end
	return LayoutRegistry[Name]
end

AceGUI.counts = AceGUI.counts or {}

--- A type-based counter to count the number of widgets created.
-- This is used by widgets that require a named frame, e.g. when a Blizzard
-- Template requires it.
-- @param type The widget type
function AceGUI:GetNextWidgetNum(type)
	if not self.counts[type] then
		self.counts[type] = 0
	end
	self.counts[type] = self.counts[type] + 1
	return self.counts[type]
end

--- Return the number of created widgets for this type.
-- In contrast to GetNextWidgetNum, the number is not incremented.
-- @param type The widget type
function AceGUI:GetWidgetCount(type)
	return self.counts[type] or 0
end

--- Return the version of the currently registered widget type.
-- @param type The widget type
function AceGUI:GetWidgetVersion(type)
	return WidgetVersions[type]
end

-------------
-- Layouts --
-------------

--[[
	A Layout is a func that takes 2 parameters
		content - the frame that widgets will be placed inside
		children - a table containing the widgets to layout
]]

-- Very simple Layout, Children are stacked on top of each other down the left side
AceGUI:RegisterLayout("List",
	function(content, children)
		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]
			
			local frame = child.frame
			frame:ClearAllPoints()
			frame:Show()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content)
			else
				frame:SetPoint("TOPLEFT", children[i-1].frame, "BOTTOMLEFT")
			end
			
			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)
				
				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)
				
				if child.DoLayout then
					child:DoLayout()
				end
			end
			
			height = height + (frame.height or frame:GetHeight() or 0)
		end
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)

-- A single control fills the whole content area
AceGUI:RegisterLayout("Fill",
	function(content, children)
		if children[1] then
			children[1]:SetWidth(content:GetWidth() or 0)
			children[1]:SetHeight(content:GetHeight() or 0)
			children[1].frame:SetAllPoints(content)
			children[1].frame:Show()
			safecall(content.obj.LayoutFinished, content.obj, nil, children[1].frame:GetHeight())
		end
	end)

local layoutrecursionblock = nil
local function safelayoutcall(object, func, ...)
	layoutrecursionblock = true
	object[func](object, ...)
	layoutrecursionblock = nil
end

AceGUI:RegisterLayout("Flow",
	function(content, children)
		if layoutrecursionblock then return end
		--used height so far
		local height = 0
		--width used in the current row
		local usedwidth = 0
		--height of the current row
		local rowheight = 0
		local rowoffset = 0
		local lastrowoffset
		
		local width = content.width or content:GetWidth() or 0
		
		--control at the start of the row
		local rowstart
		local rowstartoffset
		local lastrowstart
		local isfullheight
		
		local frameoffset
		local lastframeoffset
		local oversize 
		for i = 1, #children do
			local child = children[i]
			oversize = nil
			local frame = child.frame
			local frameheight = frame.height or frame:GetHeight() or 0
			local framewidth = frame.width or frame:GetWidth() or 0
			lastframeoffset = frameoffset
			-- HACK: Why did we set a frameoffset of (frameheight / 2) ? 
			-- That was moving all widgets half the widgets size down, is that intended?
			-- Actually, it seems to be neccessary for many cases, we'll leave it in for now.
			-- If widgets seem to anchor weirdly with this, provide a valid alignoffset for them.
			-- TODO: Investigate moar!
			frameoffset = child.alignoffset or (frameheight / 2)
			
			if child.width == "relative" then
				framewidth = width * child.relWidth
			end
			
			frame:Show()
			frame:ClearAllPoints()
			if i == 1 then
				-- anchor the first control to the top left
				frame:SetPoint("TOPLEFT", content)
				rowheight = frameheight
				rowoffset = frameoffset
				rowstart = frame
				rowstartoffset = frameoffset
				usedwidth = framewidth
				if usedwidth > width then
					oversize = true
				end
			else
				-- if there isn't available width for the control start a new row
				-- if a control is "fill" it will be on a row of its own full width
				if usedwidth == 0 or ((framewidth) + usedwidth > width) or child.width == "fill" then
					if isfullheight then
						-- a previous row has already filled the entire height, there's nothing we can usefully do anymore
						-- (maybe error/warn about this?)
						break
					end
					--anchor the previous row, we will now know its height and offset
					rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
					height = height + rowheight + 3
					--save this as the rowstart so we can anchor it after the row is complete and we have the max height and offset of controls in it
					rowstart = frame
					rowstartoffset = frameoffset
					rowheight = frameheight
					rowoffset = frameoffset
					usedwidth = framewidth
					if usedwidth > width then
						oversize = true
					end
				-- put the control on the current row, adding it to the width and checking if the height needs to be increased
				else
					--handles cases where the new height is higher than either control because of the offsets
					--math.max(rowheight-rowoffset+frameoffset, frameheight-frameoffset+rowoffset)
					
					--offset is always the larger of the two offsets
					rowoffset = math_max(rowoffset, frameoffset)
					rowheight = math_max(rowheight, rowoffset + (frameheight / 2))
					
					frame:SetPoint("TOPLEFT", children[i-1].frame, "TOPRIGHT", 0, frameoffset - lastframeoffset)
					usedwidth = framewidth + usedwidth
				end
			end

			if child.width == "fill" then
				safelayoutcall(child, "SetWidth", width)
				frame:SetPoint("RIGHT", content)
				
				usedwidth = 0
				rowstart = frame
				rowstartoffset = frameoffset
				
				if child.DoLayout then
					child:DoLayout()
				end
				rowheight = frame.height or frame:GetHeight() or 0
				rowoffset = child.alignoffset or (rowheight / 2)
				rowstartoffset = rowoffset
			elseif child.width == "relative" then
				safelayoutcall(child, "SetWidth", width * child.relWidth)
				
				if child.DoLayout then
					child:DoLayout()
				end
			elseif oversize then
				if width > 1 then
					frame:SetPoint("RIGHT", content)
				end
			end
			
			if child.height == "fill" then
				frame:SetPoint("BOTTOM", content)
				isfullheight = true
			end
		end
		
		--anchor the last row, if its full height needs a special case since  its height has just been changed by the anchor
		if isfullheight then
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
		elseif rowstart then
			rowstart:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(height + (rowoffset - rowstartoffset) + 3))
		end
		
		height = height + rowheight + 3
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)
