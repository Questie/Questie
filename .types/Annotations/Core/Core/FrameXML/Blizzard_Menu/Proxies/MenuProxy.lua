---@meta _

---@see MenuProxyMixin
---@class MenuProxy: Frame, MenuTemplateBase
local MenuProxy = {}

---@see MenuProxyMixin.Close
function MenuProxy:Close() end

---@see MenuMixin.ReinitializeAll # proxied
function MenuProxy:ReinitializeAll() end

---@see MenuProxyMixin.GetOwnerRegion
---@return Frame
function MenuProxy:GetOwnerRegion() end

---@see MenuProxyMixin.SendResponse
function MenuProxy:SendResponse(descriptionProxy, response) end

---@see MenuProxyMixin.SetMenuDescription
function MenuProxy:SetMenuDescription(descriptionProxy) end

---@see MenuMixin.SetClosedCallback # proxied
---@param onCloseCallback fun(menu: MenuProxy)
function MenuProxy:SetClosedCallback(onCloseCallback) end

---usually you want to use SharedMenuDescriptionProxy:SetScrollMode instead
---@see MenuProxyMixin.InitScrollLayout
---@param childWidth number
---@param maxScrollExtent number # item height * number of items
function MenuProxy:InitScrollLayout(childWidth, maxScrollExtent) end

---@see MenuProxyMixin.ClearScrollLayout
function MenuProxy:ClearScrollLayout() end

---usually there's no need to call it manually
---@see MenuProxyMixin.OnLoad
function MenuProxy:OnLoad() end
