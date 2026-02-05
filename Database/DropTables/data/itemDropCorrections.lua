---@class QuestieItemDropCorrections
local QuestieItemDropCorrections = QuestieLoader:CreateModule("QuestieItemDropCorrections")
-------------------------
--Import modules.
-------------------------

  -- These table contain manual drop corrections.
  --
  -- Use the following format:
  -- [itemID] = { -- Item Name
  --    [npcID] = 80.0,
  -- }
  --
  -- This example would be an 80% drop rate.
  --
  -- Corrections propagate up to the current expansion. For instance, if you make a correction in Era, that
  -- correction will be loaded in MoP unless an expansion after Era made a different correction for the same ID.
  --
  -- This is the same way our normal database corrections system behaves as well.

QuestieItemDropCorrections.Era = {

}

QuestieItemDropCorrections.Tbc = {
    [23614] = { -- Red Snapper
        [17102] = 100,
    },
}

QuestieItemDropCorrections.Wotlk = {

}

QuestieItemDropCorrections.Cata = {

}

QuestieItemDropCorrections.MoP = {

}