---@meta _

--------------------------------------------------------------------------------
---- LibDataBroker-1.1
--------------------------------------------------------------------------------

---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/API)
---@class LibDataBroker-1.1
local lib = {}

---@param name string
---@param dataObject? LibDataBroker.DataObject
---@return LibDataBroker.DataObject
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/API#ldbnewdataobjectname-dataobject--dataobject)
function lib:NewDataObject(name, dataObject) end

---@param dataObjectName string
---@return LibDataBroker.DataObject
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/API#ldbgetdataobjectbynamedataobjectname--dataobject)
function lib:GetDataObjectByName(dataObjectName) end

---@param dataObject LibDataBroker.DataObject
---@return string
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/API#ldbgetnamebydataobjectdataobject--name)
function lib:GetNameByDataObject(dataObject) end

---@return table
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/API#ldbdataobjectiterator)
function lib:DataObjectIterator() end

---@param addon table|string
---@param eventName string
---@param method? string|function
---@param arg? any
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/API#ldbregistercallbackmytable-or-myaddonid-eventname-method-arg)
function lib:RegisterCallback(addon, eventName, method, arg) end

--------------------------------------------------------------------------------
-- LibDataBroker.DataDisplay
--------------------------------------------------------------------------------
-- Data display addons provide a LDB “feed” for an always-up addon to display. These addons can be thought of like RSS feeds, where the display addon is similar to an RSS reader.
--
--- ---
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/data-specifications#data-display)
---@class LibDataBroker.DataDisplay: LibDataBroker.DataObjectCommonFields
---@field type "data source" Indicates that this data object is a data source.
---@field text string The text to be shown.
---@field value string? Raw value from the text, for example text "75.0 FPS" would have value "75.0"
---@field suffix string? The “unit” appended to the end of text. For example text "75.0 FPS" would have the suffix "FPS"
---@field label string? A title for your feed, often shown to the left of the text, user might choose to hide this. If missing, the dataobject’s name may be used instead.
---@field icon string? Full path to a texture, often shown to the left of the label or text.
---@field OnClick fun(displayFrame: Frame, buttonName: string)? An OnClick script handler to be directly attached to the display frame.
---@field OnEnter fun(displayFrame: Frame)? An OnEnter script handler to be directly attached to the display frame. Usually used to display a tooltip. This handler should check the position of the frame it is passed and anchor the tooltip to that frame accordingly.
---@field OnLeave fun(displayFrame: Frame)? An OnLeave script handler to be directly attached to the display frame. Usually used to hide the toolip.
---@field tooltip Frame? A frame to be displayed when the display frame is entered. The display addon is responsible for anchoring, showing and hiding this frame as needed. The tooltip frame’s OnShow can be used to refresh the frame. Note that this frame doesn’t have to be a GameTooltip.

--------------------------------------------------------------------------------
-- LibDataBroker.QuickLauncher
--------------------------------------------------------------------------------
-- A quicklauncher is a LDB object that does not provide any data, but instead provides an OnClick handler to allow fast access to config panels, toggle settings, or perform other actions.
--
-- Quicklaunchers should never expect a secure frame to be used, therefore actions like spellcasting are not possible.
--
--- ---
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/data-specifications#data-display)
---@class LibDataBroker.QuickLauncher: LibDataBroker.DataObjectCommonFields
---@field type "launcher" Indicates that this data object is a launcher and does not provide any data to be rendered in an always-up frame.
---@field icon string Full path to a texture for display.
---@field OnClick fun(displayFrame: Frame, buttonName: string) An OnClick script handler to be directly attached to the display frame.
---@field tocname string? The name of the addon providing the launcher, if it’s name does not match the DataObject’s name. Used by displays to get TOC metadata about the addon.
---@field label string? A label to use for the launcher, overriding the DataObject name.

--------------------------------------------------------------------------------
-- LibDataBroker.DataObject
--------------------------------------------------------------------------------
-- Represents either a DataDisplay or a Quicklauncher.
--
---
---[Documentation](https://github.com/tekkub/libdatabroker-1-1/wiki/data-specifications)
---@alias LibDataBroker.DataObject LibDataBroker.DataDisplay|LibDataBroker.QuickLauncher

--------------------------------------------------------------------------------
-- LibDataBroker.DataObjectCommonFields
--------------------------------------------------------------------------------
-- Fields common to both the LibDataBroker.DataDisplay and LibDataBroker.QuickLauncher types.
---@class LibDataBroker.DataObjectCommonFields
---@field iconR number? The red component value to be used when coloring the icon.
---@field iconG number? The green component value to be used when coloring the icon.
---@field iconB number? The blue component value to be used when coloring the icon.
---@field iconCoords table? A table containing the arguments to be supplied to SetTexCoord() on the icon texture. Combined with icon, iconR, iconG and iconB this attribute provides a way for addons to use icons that require TexCoords (such as re-using the icons from the default user interface without the button background). This is currently used by TomTom to display a spinning arrow that points towards your current waypoint.
---@field OnTooltipShow fun(tooltip: GameTooltip)? A function to call when the display wants to show a tooltip. The display will manage positioning, clearing and showing the tooltip, all this handler needs to do is populate the tooltip using :AddLine or similar. The display should pass the tooltip to this callback, in case it isn’t using GameTooltip. The display shouldn’t pass a non-GameTooltip frame unless it mimics the API of GameTooltip.
