---@meta _
---@meta _
---@class NamePlateFrame : Frame, NamePlateBaseMixin
local NamePlateFrame = {}

---@class NamePlateBaseMixin
---@field UnitFrame Button
---@field driverFrame NamePlateDriverFrame
---@field namePlateUnitToken UnitToken
---@field template string
local NamePlateBaseMixin = {}

---@param namePlateUnitToken UnitToken
---@param driverFrame NamePlateDriverFrame
function NamePlateBaseMixin:OnAdded(namePlateUnitToken, driverFrame) end

function NamePlateBaseMixin:OnRemoved() end

function NamePlateBaseMixin:OnOptionsUpdated() end

function NamePlateBaseMixin:ApplyOffsets() end

---@param insetWidth number
---@param insetHeight number
---@return number widthPadding
---@return number heightPadding
function NamePlateBaseMixin:GetAdditionalInsetPadding(insetWidth, insetHeight) end

---@return number left
---@return number right
---@return number top
---@return number bottom
function NamePlateBaseMixin:GetPreferredInsets() end

function NamePlateBaseMixin:OnSizeChanged() end

--- not yet annotated, inherits NamePlateDriverMixin
---@class NamePlateDriverFrame
