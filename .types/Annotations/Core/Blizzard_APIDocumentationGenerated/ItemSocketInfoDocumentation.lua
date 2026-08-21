---@meta _
C_ItemSocketInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.AcceptSockets)
function C_ItemSocketInfo.AcceptSockets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.ClickSocketButton)
---@param index number
function C_ItemSocketInfo.ClickSocketButton(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.CloseSocketInfo)
function C_ItemSocketInfo.CloseSocketInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.CompleteSocketing)
function C_ItemSocketInfo.CompleteSocketing() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetCurrUIType)
---@return Enum.ItemSocketInfoUIType uiType
function C_ItemSocketInfo.GetCurrUIType() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetExistingSocketInfo)
---@param index number
---@return string? name
---@return fileID? icon
---@return boolean gemMatchesSocket
function C_ItemSocketInfo.GetExistingSocketInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetExistingSocketLink)
---@param index number
---@return string? existingSocketLink
function C_ItemSocketInfo.GetExistingSocketLink(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetNewSocketInfo)
---@param index number
---@return string? name
---@return fileID? icon
---@return boolean gemMatchesSocket
function C_ItemSocketInfo.GetNewSocketInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetNewSocketLink)
---@param index number
---@return string? newSocketLink
function C_ItemSocketInfo.GetNewSocketLink(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetNumSockets)
---@return number numSockets
function C_ItemSocketInfo.GetNumSockets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetSocketItemBoundTradeable)
---@return boolean socketItemTradeable
function C_ItemSocketInfo.GetSocketItemBoundTradeable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetSocketItemInfo)
---@return string? name
---@return fileID? icon
---@return Enum.ItemQuality quality
function C_ItemSocketInfo.GetSocketItemInfo() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetSocketItemRefundable)
---@return boolean socketItemRefundable
function C_ItemSocketInfo.GetSocketItemRefundable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.GetSocketTypes)
---@param index number
---@return string? socketType
function C_ItemSocketInfo.GetSocketTypes(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.HasBoundGemProposed)
---@return boolean hasBoundGemProposed
function C_ItemSocketInfo.HasBoundGemProposed() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ItemSocketInfo.IsArtifactRelicItem)
---@param info ItemInfo
---@return boolean isArtifactRelicItem
function C_ItemSocketInfo.IsArtifactRelicItem(info) end

---@class SocketInfo
---@field name string?
---@field icon fileID?
---@field gemMatchesSocket boolean

---@class SocketItemInfo
---@field name string?
---@field icon fileID?
---@field quality Enum.ItemQuality
