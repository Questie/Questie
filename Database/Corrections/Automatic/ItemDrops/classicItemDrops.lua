---@class QuestieClassicItemDrops
local QuestieClassicItemDrops = QuestieLoader:CreateModule("QuestieClassicItemDrops")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");


function QuestieClassicItemDrops:LoadAutomaticDropData()

  --! This table is automatically generated from wowhead data based upon objective data from our DB.
  --! See External Scripts/dropdata/
  return {
      --* Item 1307 https://www.wowhead.com/classic/item=1307
      [1307] = {
        [100] = 87,
      },
    }
end
