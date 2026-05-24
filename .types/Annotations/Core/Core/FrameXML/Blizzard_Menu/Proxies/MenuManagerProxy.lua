---@meta _

---@see MenuManagerProxyMixin
---@class MenuManagerProxy
local MenuManagerProxy = {}

---@see MenuManagerProxyMixin.GetOpenMenu
---@return MenuProxy?
function MenuManagerProxy:GetOpenMenu() end

---@see MenuManagerProxyMixin.CloseMenu
---@param menu MenuProxy
function MenuManagerProxy:CloseMenu(menu) end

---@see MenuManagerProxyMixin.CloseMenus
function MenuManagerProxy:CloseMenus() end

---@see MenuManagerProxyMixin.IsAnyMenuOpen
---@return boolean
function MenuManagerProxy:IsAnyMenuOpen() end

---@see MenuManagerProxyMixin.OpenMenu
---@param ownerRegion Region
---@param menuDescriptionProxy RootMenuDescriptionProxy
---@param anchor AnchorMixin
---@return MenuProxy? menu
function MenuManagerProxy:OpenMenu(ownerRegion, menuDescriptionProxy, anchor) end

---@see MenuManagerProxyMixin.OpenContextMenu
---@param ownerRegion Region
---@param menuDescriptionProxy RootMenuDescriptionProxy
---@return MenuProxy? menu
function MenuManagerProxy:OpenContextMenu(ownerRegion, menuDescriptionProxy) end

---@see MenuManagerMixin.HandleESC
function MenuManagerProxy:HandleESC() end

---@see MenuManagerMixin.HandleGlobalMouseEvent
---@param buttonName mouseButton
---@param event FrameEvent
function MenuManagerProxy:HandleGlobalMouseEvent(buttonName, event) end
