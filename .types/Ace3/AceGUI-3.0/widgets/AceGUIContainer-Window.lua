---@meta _
---@class AceGUIWindow : AceGUIContainer
---@field protected status? table
---@field protected localstatus table
---@field protected closebutton Button
---@field protected titletext FontString
---@field protected title Button
---@field protected sizer_se Frame
---@field protected line1 Texture
---@field protected line2 Texture
---@field protected sizer_s Frame
---@field protected sizer_e Frame
local AceGUIWindow = {}

function AceGUIWindow:Hide() end

function AceGUIWindow:Show() end

function AceGUIWindow:ApplyStatus() end

---@param title string
function AceGUIWindow:SetTitle(title) end

---@param status table
function AceGUIWindow:SetStatusTable(status) end

---@param text string
function AceGUIWindow:SetStatusText(text) end

---@param state boolean
function AceGUIWindow:EnableResize(state) end
