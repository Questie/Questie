---@meta _
C_StorePublic = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StorePublic.DoesGroupHavePurchaseableProducts)
---@param groupID number
---@return boolean hasPurchaseableProducts
function C_StorePublic.DoesGroupHavePurchaseableProducts(groupID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StorePublic.EventStoreUISetShown)
---@param newShown boolean
---@param contextKey? string
function C_StorePublic.EventStoreUISetShown(newShown, contextKey) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StorePublic.IsDisabledByParentalControls)
---@return boolean disabled
function C_StorePublic.IsDisabledByParentalControls() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StorePublic.IsEnabled)
---@return boolean enabled
function C_StorePublic.IsEnabled() end
