---@meta _
C_LootJournal = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootJournal.GetItemSetItems)
---@param setID number
---@return LootJournalItemInfo[] items
function C_LootJournal.GetItemSetItems(setID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_LootJournal.GetItemSets)
---@param classID? number
---@param specID? number
---@return LootJournalItemSetInfo[] itemSets
function C_LootJournal.GetItemSets(classID, specID) end

---@class LootJournalItemInfo
---@field itemID number
---@field icon fileID
---@field invType number

---@class LootJournalItemSetInfo
---@field setID number
---@field itemLevel number
---@field name string
