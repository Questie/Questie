---@meta _

---@class ElementMenuDescriptionProxy: SharedMenuDescriptionProxy
local ElementMenuDescriptionProxy = {}

function ElementMenuDescriptionProxy:SetSelectionIgnored() end

---@return boolean
function ElementMenuDescriptionProxy:IsSelectionIgnored() end

---@param data any
function ElementMenuDescriptionProxy:SetData(data) end

---@return any data # from SetData or element creation
function ElementMenuDescriptionProxy:GetData() end

---simulates selecting/clicking a dropdown option
---@param menuInputContext MenuInputContext
---@param menuInputButtonName mouseButton?
function ElementMenuDescriptionProxy:Pick(menuInputContext, menuInputButtonName) end

---@param isEnabled boolean|fun(elementDescription: ElementMenuDescriptionProxy): boolean
function ElementMenuDescriptionProxy:SetEnabled(isEnabled) end

---@return boolean
function ElementMenuDescriptionProxy:IsEnabled() end

---@return boolean # true if a function was passed to SetEnabled()
function ElementMenuDescriptionProxy:ShouldPollEnabled() end

---@param onLeave fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy)
function ElementMenuDescriptionProxy:SetOnLeave(onLeave) end

---hooks OnLeave if it exists, else calls SetOnLeave
---@param onLeave fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy)
function ElementMenuDescriptionProxy:HookOnLeave(onLeave) end

---@return nil|fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy) onLeave
function ElementMenuDescriptionProxy:GetOnLeave() end

---@param frame Frame # frame:OnLeave(elementDescription) is called if it exists, otherwise the onLeave callback is called
function ElementMenuDescriptionProxy:HandleOnLeave(frame) end

---@param onEnter fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy)
function ElementMenuDescriptionProxy:SetOnEnter(onEnter) end

---hooks OnEnter if it exists, else calls SetOnEnter
---@param onEnter fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy)
function ElementMenuDescriptionProxy:HookOnEnter(onEnter) end

---@return nil|fun(frame: Frame, elementDescription: ElementMenuDescriptionProxy) onEnter
function ElementMenuDescriptionProxy:GetOnEnter() end

---@param frame Frame # frame:OnEnter(elementDescription) is called if it exists, otherwise the onEnter callback is called
function ElementMenuDescriptionProxy:HandleOnEnter(frame) end

---@param canSelect boolean
function ElementMenuDescriptionProxy:SetCanSelect(canSelect) end

---@return boolean
function ElementMenuDescriptionProxy:CanSelect() end

---@param isSelected fun(data: any): boolean # data = element:GetData()
function ElementMenuDescriptionProxy:SetIsSelected(isSelected) end

---@return boolean isSelected # calls the isSelected callback with the element's data; if no callback is set, returns false
function ElementMenuDescriptionProxy:IsSelected() end

---@param isRadio boolean
function ElementMenuDescriptionProxy:SetRadio(isRadio) end

---@return boolean
function ElementMenuDescriptionProxy:IsRadio() end

---@param defaultResponse MenuResponse|fun(menuInputContext: MenuInputContext, menuInputButtonName: mouseButton): MenuResponse
function ElementMenuDescriptionProxy:SetResponse(defaultResponse) end

---@param menuInputContext MenuInputContext
---@param menuInputButtonName mouseButton
---@return MenuResponse
function ElementMenuDescriptionProxy:GetDefaultResponse(menuInputContext, menuInputButtonName) end

---@param responder MenuResponder
function ElementMenuDescriptionProxy:SetResponder(responder) end

---hooks responder if it exists, else calls SetResponder
---@param responder MenuResponder
function ElementMenuDescriptionProxy:HookResponder(responder) end

function ElementMenuDescriptionProxy:SetElementFactory(callback) end

---@param soundKit number|fun(elementDescription: ElementMenuDescriptionProxy): number
function ElementMenuDescriptionProxy:SetSoundKit(soundKit) end

---@return number soundKit
function ElementMenuDescriptionProxy:GetSoundKit() end

---@param canPlay boolean
function ElementMenuDescriptionProxy:SetShouldPlaySoundOnSubmenuClick(canPlay) end

---@return boolean
function ElementMenuDescriptionProxy:ShouldPlaySoundOnSubmenuClick() end

function ElementMenuDescriptionProxy:DeactivateSubmenu() end

---@param canRespond boolean
function ElementMenuDescriptionProxy:SetShouldRespondIfSubmenu(canRespond) end

---@return boolean
function ElementMenuDescriptionProxy:ShouldRespondIfSubmenu() end

---@return boolean canOpenSubmenu # true if there are subItems and opening submenus isn't blocked
function ElementMenuDescriptionProxy:CanOpenSubmenu() end

function ElementMenuDescriptionProxy:ForceOpenSubmenu() end

---@param callback fun(frame: Frame, descriptionProxy: ElementMenuDescriptionProxy, menuFrame: Frame, finalColumns: number, finalRows: number)
function ElementMenuDescriptionProxy:SetFinalizeGridLayout(callback) end
