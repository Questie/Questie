---@meta _

---@class RootMenuDescriptionProxy: SharedMenuDescriptionProxy
local RootMenuDescriptionProxy = {}

---@param callback fun(menu: MenuProxy)
function RootMenuDescriptionProxy:AddMenuAcquiredCallback(callback) end

---@param callback fun()
function RootMenuDescriptionProxy:AddMenuChangedCallback(callback) end

---@param callback fun(menu: MenuProxy, description: SharedMenuDescriptionProxy)
function RootMenuDescriptionProxy:AddMenuResponseCallback(callback) end

---@param callback fun(rootDescription: RootMenuDescriptionProxy)
function RootMenuDescriptionProxy:AddMenuReleasedCallback(callback) end

function RootMenuDescriptionProxy:DisableCompositor() end

function RootMenuDescriptionProxy:DisableReacquireFrames() end

