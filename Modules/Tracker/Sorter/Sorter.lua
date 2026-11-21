---@type QuestieLoader
local QuestieLoader = select(2, ...).QuestieLoader

---@class Sorter
local Sorter = QuestieLoader:CreateModule("Sorter")

---@class QuestSortDetails
---@field questCompletePercent number
---@field quest Quest
---@field zoneName string
