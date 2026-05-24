---@meta _
---@class CallbackRegistryMixin
CallbackRegistryMixin = {}

function CallbackRegistryMixin:SetUndefinedEventsAllowed(allowed) end

---@return table
function CallbackRegistryMixin:GetCallbackTables() end

---@return table
function CallbackRegistryMixin:GetCallbackTable(callbackType) end

---@return table
function CallbackRegistryMixin:GetCallbacksByEvent(callbackType, event) end

---@return boolean
function CallbackRegistryMixin:HasRegistrantsForEvent(event) end

function CallbackRegistryMixin:SecureInsertEvent(event) end

---@return any owner
function CallbackRegistryMixin:RegisterCallback(event, func, owner, ...) end

---@return table
function CallbackRegistryMixin:RegisterCallbackWithHandle(event, func, owner, ...) end

function CallbackRegistryMixin:TriggerEvent(event, ...) end

function CallbackRegistryMixin:UnregisterCallback(event, owner) end

function CallbackRegistryMixin:UnregisterEvents(eventTable) end

function CallbackRegistryMixin:GenerateCallbackEvents(events) end

---@return boolean
function CallbackRegistryMixin.DoesFrameHaveEvent(frame, event) end

function CallbackRegistryMixin:OnLoad() end
