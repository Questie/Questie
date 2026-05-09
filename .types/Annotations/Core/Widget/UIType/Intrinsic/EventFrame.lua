---@meta _
---[FrameXML](https://www.townlong-yak.com/framexml/live/Frame/EventFrame.lua)
---@class EventFrameMixin : CallbackRegistryMixin
EventFrameMixin = {}

function EventFrameMixin:OnLoad_Intrinsic() end
function EventFrameMixin:OnHide_Intrinsic() end
function EventFrameMixin:OnShow_Intrinsic() end

---@param width number
---@param height number
function EventFrameMixin:OnSizeChanged_Intrinsic(width, height) end

---@class EventFrame : EventFrameMixin, Frame
