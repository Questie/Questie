---@meta _

---@deprecated
---Deprecated by [C_CurrencyInfo.GetCoinIcon](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCoinIcon)
---@param amount WOWMONEY
---@return fileID result
function GetCoinIcon(amount) end

---@deprecated
---Deprecated by [C_CurrencyInfo.GetCoinText](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCoinText)
---@param amount WOWMONEY
---@param separator? string Default = , 
---@return string result
function GetCoinText(amount, separator) end

---@deprecated
---Deprecated by [C_CurrencyInfo.GetCoinTextureString](https://warcraft.wiki.gg/wiki/API_C_CurrencyInfo.GetCoinTextureString)
---@param amount WOWMONEY
---@param fontHeight? number Default = 14
---@return string result
function GetCoinTextureString(amount, fontHeight) end
