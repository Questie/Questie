---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_CheckButton)
---@class CheckButton : Button
local CheckButton = {}
---@class checkbutton : CheckButton
---@class CHECKBUTTON : CheckButton

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckButton_GetChecked)
---@return boolean checked
function CheckButton:GetChecked() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckButton_GetCheckedTexture)
---@return SimpleTexture texture
function CheckButton:GetCheckedTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckButton_GetDisabledCheckedTexture)
---@return SimpleTexture texture
function CheckButton:GetDisabledCheckedTexture() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckButton_SetChecked)
---@param checked? boolean Default = false
function CheckButton:SetChecked(checked) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckButton_SetCheckedTexture)
---@param asset TextureAsset
function CheckButton:SetCheckedTexture(asset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CheckButton_SetDisabledCheckedTexture)
---@param asset TextureAsset
function CheckButton:SetDisabledCheckedTexture(asset) end
