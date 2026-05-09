---@meta _

-- ----------------------------------------------------------------------------
-- LibQTip-1.0
-- ----------------------------------------------------------------------------
---@class LibQTip-1.0
---@field LabelProvider LibQTip.CellProvider The default CellProvider used to create tooltip cells.
local lib = {}

--- Create or retrieve the tooltip with the given key.
---
-- If additional arguments are passed, they are passed to :SetColumnLayout for the acquired tooltip.
---@param key string|table - The tooltip key. Any value that can be used as a table key is accepted though you should try to provide unique keys to avoid conflicts.
---Numbers and booleans should be avoided and strings should be carefully chosen to avoid namespace clashes - no "MyTooltip" - you have been warned!
---@param numColumns? number Minimum number of columns
---@param ... JustifyHorizontal Column horizontal justifications ("CENTER", "LEFT" or "RIGHT"). Defaults to "LEFT".
--- Example tooltip with 5 columns justified as left, center, left, left, left:
---
--- local tip = LibStub('LibQTip-1.0'):Acquire('MyFooBarTooltip', 5, "LEFT", "CENTER")
---@return LibQTip.Tooltip
function lib:Acquire(key, numColumns, ...) end

--- Convenience method to create a new cell provider.
---
--- Although one can use anything that matches the CellProvider and Cell interfaces, this method provides an easy way to create new providers.
---@param baseProvider? LibQTip.CellProvider An existing provider to base the new provider on.
---@return LibQTip.CellProvider provider The new CellProvider.
---@return table cellPrototype The prototype of the new cell. It must be extended with the mandatory :InitializeCell() and :SetupCell() methods.
---@return table baseCellPrototype The prototype of baseProvider cells. It may be used to call base cell methods.
function lib:CreateCellProvider(baseProvider) end

--- Check if a given tooltip has been acquired and not released.
---@param key string|table - The tooltip key.
---@return boolean
function lib:IsAcquired(key) end

--- Return an iterator on the acquired tooltips.
---@generic T: LibQTip.Tooltip, K, V
---@return fun(tooltip: LibQTip.Tooltip<K, V>, index?: K):K, V
---@return T
function lib:IterateTooltips() end

--- Return an acquired tooltip to the heap. The tooltip is cleared and hidden.
---@param tooltip LibQTip.Tooltip The tooltip to release. Any invalid values are silently ignored.
function lib:Release(tooltip) end

-- ----------------------------------------------------------------------------
-- LibQTip.ScriptType
-- ----------------------------------------------------------------------------
---@alias LibQTip.ScriptType
---|"OnEnter"
---|"OnLeave"
---|"OnMouseDown"
---|"OnMouseUp"|
---|"OnReceiveDrag"

-- ----------------------------------------------------------------------------
-- LibQTip.Tooltip
-- ----------------------------------------------------------------------------
---@class LibQTip.Tooltip: BackdropTemplate, Frame
local tooltip = {}

--- Add a new column to the right of the tooltip.
---@param justification? JustifyHorizontal The horizontal justification of cells in this column ("CENTER", "LEFT" or "RIGHT"). Defaults to "LEFT".
function tooltip:AddColumn(justification) end

--- Add a new header line at the bottom of the tooltip.
--- Provided values are displayed on the line with the header font. Nil values are ignored. If the number of values is greater than the number of columns, an error is raised.
---@param ... unknown Value to be displayed in each column of the line.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function tooltip:AddHeader(...) end

--- Add a new line at the bottom of the tooltip.
--- Provided values are displayed on the line with the regular font. Nil values are ignored. If the number of values is greater than the number of columns, an error is raised.
---@param ... unknown Value to be displayed in each column of the line.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function tooltip:AddLine(...) end

--- Adds a graphical separator line at the bottom of the tooltip.
---@param height? number Height, in pixels, of the separator. Defaults to 1.
---@param r? number Red color value of the separator. Defaults to NORMAL_FONT_COLOR.r
---@param g? number Green color value of the separator. Defaults to NORMAL_FONT_COLOR.g
---@param b? number Blue color value of the separator. Defaults to NORMAL_FONT_COLOR.b
---@param a? number Alpha level of the separator. Defaults to 1.
---@return number lineIndex The index of the newly added line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function tooltip:AddSeparator(height, r, g, b, a) end

--- Reset the contents of the tootip. The column layout is preserved but all lines are wiped.
function tooltip:Clear() end

--- Returns the total number of columns of the tooltip.
---@return number columnCount The number of columns added using :SetColumnLayout or :AddColumn.
function tooltip:GetColumnCount() end

--- Return the CellProvider used for cell functionality.
---@return LibQTip.CellProvider
function tooltip:GetDefaultProvider() end

--- Return the font used for regular lines.
---@return Font
function tooltip:GetFont() end

--- Return the font used for header lines.
---@return Font
function tooltip:GetHeaderFont() end

--- Returns the total number of lines of the tooltip.
---@return number lineCount The number of lines added using :AddLine or :AddHeader.
function tooltip:GetLineCount() end

--- Sets the length of time in which the mouse pointer can be outside of the tooltip, or an alternate frame, before the tooltip is automatically hidden and then released.
---@param delay number Whole or fractional seconds.
---@param alternateFrame? Frame If specified, the tooltip will not be automatically hidden while the mouse pointer is over it.
---@param releaseHandler? fun(frame: Frame, delay: number) Called when the tooltip is released. Generally used to clean up a reference an AddOn has to the tooltip frame, since another AddOn can subsequently acquire it.
function tooltip:SetAutoHideDelay(delay, alternateFrame, releaseHandler) end

-- stylua: ignore start

--- Add or replace a cell at the given line and column indices. The additional arguments override the tooltip defaults.
---@param lineNum number The line index of the cell. Indexes greater than tooltip:GetLineCount() raise an error.
---@param colNum number The column index of the cell. Indexes greater than tooltip:GetColumnCount() raise an error.
---@param value unknown The value to display in the cell.
---@param font? FontObject|Font The rendering font. Defaults to regular font.
---@param justification? JustifyHorizontal Cell-specific justification to use ("CENTER", "LEFT" or "RIGHT"). Defaults to column justification.
---@param colSpan? number The number of columns the cell will span. Defaults to 1.
---@param provider? LibQTip.CellProvider CellProvider to use instead of the default one. Defaults to LibQTip.LabelProvider.
---@param leftPadding? number Pixel padding on the left side of the cell's value. Defaults to 0.
---@param rightPadding? number Pixel padding on the right side of the cell's value. Defaults to 0.
---@param maxWidth? number The maximum width (in pixels) of the cell. If the cell's value is textual and exceeds this width, it will wrap to a new line. Must not be less than the value of minWidth.
---@param minWidth? number The minimum width (in pixels) of the cell. Must not exceed the value of maxWidth.
---@param ...? unknown Additional arguments to pass to the cell:SetupCell method.
---@return number lineIndex The index of the cell's line.
---@return number columnIndex The index of the next empty cell in the line or nil if it is full.
function tooltip:SetCell(lineNum, colNum, value, font, justification, colSpan, provider, leftPadding, rightPadding, maxWidth, minWidth, ...) end

-- stylua: ignore end

--- Sets the horizontal margin size of all cells within the tooltip. This function can only be used before the tooltip has had lines set.
---@param size number The desired margin size. Must be a positive number or zero.
function tooltip:SetCellMarginH(size) end

--- Sets the vertical margin size of all cells within the tooltip. This function can only be used before the tooltip has had lines set.
---@param size number The desired margin size. Must be a positive number or zero.
function tooltip:SetCellMarginV(size) end

--- Assign a script to a cell at the given line and column indices.
---@param lineNum number Line index of the cell.
---@param colNum number Column index of the cell.
---@param scriptType LibQTip.ScriptType The cell ScriptType.
---@param func fun(frame: Frame, ...) The function called when the script is run. Parameters conform to the given ScriptType.
---@param arg? unknown Data to be passed to the script function.
function tooltip:SetCellScript(lineNum, colNum, scriptType, func, arg) end

--- Sets the color of the specified column of the tooltip.
---@param colNum number Column number to set.
---@param r? number Red color value of the column. Defaults to the tooltip's current red value.
---@param g? number Green color value of the column. Defaults to the tooltip's current green value.
---@param b? number Blue color value of the column. Defaults to the tooltip's current blue value.
---@param a? number Alpha level of the column. Defaults to 1.
function tooltip:SetColumnColor(colNum, r, g, b, a) end

--- Ensure the tooltip has at least the passed number of columns, adding new columns if need be.
---
--- The justification of existing columns is reset to the passed values.
---@param numColumns number Minimum number of columns
---@param ... JustifyHorizontal? Column horizontal justifications ("CENTER", "LEFT" or "RIGHT"). Defaults to "LEFT".
--- Example tooltip with 5 columns justified as left, center, left, left, left:
---
--- tooltip:SetColumnLayout(5, "LEFT", "CENTER")
function tooltip:SetColumnLayout(numColumns, ...) end

--- Assign a script to a column at the given index.
---@param colNum number Index of the column.
---@param scriptType LibQTip.ScriptType The column ScriptType.
---@param func fun(frame: Frame, ...) The function called when the script is run. Parameters conform to the given ScriptType.
---@param arg? unknown Data to be passed to the script function.
function tooltip:SetColumnScript(colNum, scriptType, func, arg) end

--- Sets the color of the text for the specified column of the tooltip.
---@param colNum number Column number to set.
---@param r? number Red color value of the column text. Defaults to the red value of the tooltip's current font.
---@param g? number Green color value of the column text. Defaults to the green value of the tooltip's current font.
---@param b? number Blue color value of the column text. Defaults to the blue value of the tooltip's current font.
---@param a? number Alpha level of the column's text. Defaults to 1.
function tooltip:SetColumnTextColor(colNum, r, g, b, a) end

--- Define the cellprovider to be used for all cell functionality.
---@param provider LibQTip.CellProvider The new default cellprovider.
function tooltip:SetDefaultProvider(provider) end

--- Define the font used when adding new lines.
---@param font FontObject|Font The new default font.
function tooltip:SetFont(font) end

--- Define the font used when adding new header lines.
---@param font FontObject|Font The new default font.
function tooltip:SetHeaderFont(font) end

--- Works identically to the default UI's texture:SetTexCoord() API, for the tooltip's highlight texture.
---@param ULx number
---@param ULy number
---@param LLx number
---@param LLy number
---@param URx number
---@param URy number
---@param LRx number
---@param LRy number
---@overload fun(minX: number, maxX: number, minY: number, maxY: number)
function tooltip:SetHighlightTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy) end

--- Sets the texture of the highlight when mousing over a line or cell that has a script assigned to it.
---
--- Works identically to the default UI's texture:SetTexture() API.
---@param file string|number
---@param horizWrap? WrapMode
---@param vertWrap? WrapMode
---@param filterMode? FilterMode
function tooltip:SetHighlightTexture(file, horizWrap, vertWrap, filterMode) end

--- Sets the color of the specified line of the tooltip.
---@param lineNum number Line number to set.
---@param r? number Red color value of the line. Defaults to the tooltip's current red value.
---@param g? number Green color value of the line. Defaults to the tooltip's current green value.
---@param b? number Blue color value of the line. Defaults to the tooltip's current blue value.
---@param a? number Alpha level of the line. Defaults to 1.
function tooltip:SetLineColor(lineNum, r, g, b, a) end

--- Assign a script to a line at the given index.
---@param lineNum number Index of the line.
---@param scriptType LibQTip.ScriptType The column ScriptType.
---@param func fun(frame: Frame, ...) The function called when the script is run. Parameters conform to the given ScriptType.
---@param arg? unknown Data to be passed to the script function.
function tooltip:SetLineScript(lineNum, scriptType, func, arg) end

--- Sets the color of the text for the specified line of the tooltip.
---@param lineNum number Line number to set.
---@param r? number Red color value of the line text. Defaults to the red value of the tooltip's current font.
---@param g? number Green color value of the line text. Defaults to the green value of the tooltip's current font.
---@param b? number Blue color value of the line text. Defaults to the blue value of the tooltip's current font.
---@param a? number Alpha level of the line's text. Defaults to 1.
function tooltip:SetLineTextColor(lineNum, r, g, b, a) end

--- Set the step size for the scroll bar
---@param step number The new step size.
function tooltip:SetScrollStep(step) end

--- Smartly anchor the tooltip to the given frame and ensure that it is always on screen.
---@param frame Frame The frame that will serve as the tooltip anchor.
function tooltip:SmartAnchorTo(frame) end

--- Resizes the tooltip to fit the screen and show a scrollbar if needed.
---@param maxheight? number Maximum tooltip height in pixels.
function tooltip:UpdateScrolling(maxheight) end

-- ----------------------------------------------------------------------------
-- LibQTip.Cell
-- ----------------------------------------------------------------------------
---@class LibQTip.Cell: Frame
local cell = {}

--- Returns the cell's position within the containing tooltip.
---@return number lineIndex The line index of cell.
---@return number columnIndex The column index of cell.
function cell:GetPosition() end

--- This method is called on newly created Cells, typically to perform one-time initialization.
function cell:InitializeCell() end

--- Setup the cell with the given arguments.
---@param tooltip LibQTip.Tooltip The tooltip the cell belongs to.
---@param value unknown The value to display in the cell.
---@param justification JustifyHorizontal Cell-specific justification to use ("CENTER", "LEFT" or "RIGHT").
---@param font? FontObject|Font The rendering font. Defaults to regular or header font, depending on the cell's designation.
---@param leftPadding? number Pixel padding on the left side of the cell's value. Defaults to 0.
---@param rightPadding? number Pixel padding on the right side of the cell's value. Defaults to 0.
---@param maxWidth? number The maximum width (in pixels) of the cell. If the cell's value is textual and exceeds this width, it will wrap to a new line. Must not be less than the value of minWidth.
---@param minWidth? number The minimum width (in pixels) of the cell. Must not exceed the value of maxWidth.
function cell:SetupCell(tooltip, value, justification, font, leftPadding, rightPadding, maxWidth, minWidth) end

-- ----------------------------------------------------------------------------
-- LibQTip.CellProvider
-- ----------------------------------------------------------------------------
---@class LibQTip.CellProvider
local cellProvider = {}

--- Acquire a new cell to be displayed in the tooltip. LibQTip manages parent, framelevel, anchors, visibility and size of the cell.
---@param tooltip LibQTip.Tooltip The tooltip the cell is being acquired for.
---@return LibQTip.Cell cell The acquired cell.
function cellProvider:AcquireCell(tooltip) end

--- Return the prototype and metatable used to create new cells.
---@return table cellPrototype The prototype on which cell are based.
---@return table cellMetatable The metatable used to create new cell.
function cellProvider:GetCellPrototype() end

--- Return an iterator on currently acquired cells.
---@generic T: LibQTip.Cell, K, V
---@return fun(tooltip: LibQTip.Cell<K, V>, index?: K):K, V
---@return T
function cellProvider:IterateCells() end

--- Release a cell that LibQTip is no longer using. The cell has already been hidden, unanchored and orphaned by LibQTip.
---@param cell LibQTip.Cell The cell to release.
function cellProvider:ReleaseCell(cell) end
