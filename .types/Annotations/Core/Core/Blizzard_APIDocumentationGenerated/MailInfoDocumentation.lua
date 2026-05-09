---@meta _
C_Mail = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Mail.CanCheckInbox)
---@return boolean canCheckInbox
---@return number secondsUntilAllowed
function C_Mail.CanCheckInbox() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Mail.GetCraftingOrderMailInfo)
---@param inboxIndex number
---@return CraftingOrderMailInfo? info
function C_Mail.GetCraftingOrderMailInfo(inboxIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Mail.HasInboxMoney)
---@param inboxIndex number
---@return boolean inboxItemHasMoneyAttached
function C_Mail.HasInboxMoney(inboxIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Mail.IsCommandPending)
---@return boolean isCommandPending
function C_Mail.IsCommandPending() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Mail.SetOpeningAll)
---@param openingAll boolean
function C_Mail.SetOpeningAll(openingAll) end
