---@meta _
C_SecureTransfer = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.AcceptTrade)
function C_SecureTransfer.AcceptTrade() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.Cancel)
function C_SecureTransfer.Cancel() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.CompleteHousingPurchase)
function C_SecureTransfer.CompleteHousingPurchase() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.CompleteHousingVCPurchase)
function C_SecureTransfer.CompleteHousingVCPurchase() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.GetHousingPurchaseCost)
---@return number totalCost
function C_SecureTransfer.GetHousingPurchaseCost() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.GetHousingVCPurchaseProductID)
---@return number productID
function C_SecureTransfer.GetHousingVCPurchaseProductID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.GetMailInfo)
---@return MailInfo mailInfo
function C_SecureTransfer.GetMailInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SecureTransfer.SendMail)
function C_SecureTransfer.SendMail() end

---@class MailInfo
---@field target string
---@field sendMoney number
