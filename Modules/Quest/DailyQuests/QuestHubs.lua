---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")

---@alias HubId string

---@class Hub
---@field quests QuestId[]
---@field limit number

---@type table<HubId, Hub>
DailyQuests.hubs = {
    TOL_BARAD_ALLIANCE = {
        quests = {27944,27948,27949,27966,27967,27970,27971,27972,27973,27975,27978,27987,27991,27992,28046,28050,28059,28063,28130,28137,28275},
        limit = 6,
    },
    TOL_BARAD_HORDE = {
        quests = {28678,28679,28680,28681,28682,28683,28684,28685,28686,28687,28689,28690,28691,28692,28693,28694,28695,28696,28697,28698,28700},
        limit = 6,
    },
}
