---@meta _
C_TradeInfo = {}

---Adds any cursor-held money to the current trade offer.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeInfo.AddTradeMoney)
function C_TradeInfo.AddTradeMoney() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeInfo.PickupTradeMoney)
---@param amount WOWMONEY
function C_TradeInfo.PickupTradeMoney(amount) end

---Sets the amount of money in the current trade offer.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TradeInfo.SetTradeMoney)
---@param amount WOWMONEY
function C_TradeInfo.SetTradeMoney(amount) end
