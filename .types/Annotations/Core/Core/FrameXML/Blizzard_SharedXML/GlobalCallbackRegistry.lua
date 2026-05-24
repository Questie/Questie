---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/EventRegistry)
EventRegistry = CreateFromMixins(CallbackRegistryMixin)

-- function EventRegistry:OnLoad() end

---@param frameEvent FrameEvent
---@param value number
function EventRegistry:OnAttributeChanged(frameEvent, value) end

---@param frameEvent FrameEvent
function EventRegistry:RegisterFrameEvent(frameEvent) end

---@param frameEvent FrameEvent
function EventRegistry:UnregisterFrameEvent(frameEvent) end

---@param frameEvent FrameEvent
---@return any owner
function EventRegistry:RegisterFrameEventAndCallback(frameEvent, ...) end

---@param frameEvent FrameEvent
---@return table
function EventRegistry:RegisterFrameEventAndCallbackWithHandle(frameEvent, ...) end

---@param frameEvent FrameEvent
function EventRegistry:UnregisterFrameEventAndCallback(frameEvent, ...) end

---@return string
function EventRegistry:GetEventCounts(...) end
