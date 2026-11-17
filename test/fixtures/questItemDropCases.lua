-- Known Forever Classic quest-item drop cases for map-tooltip rate tests.
-- Rates are copied from Forever QuestieDB support/Forever/DropTables (wowhead +
-- cmangos + Era corrections). Expected suffix text matches FormatDropText in
-- MapIconTooltip.lua / Tooltip.lua (no trailing %).
--
-- Add new rows here when a player report needs a regression fixture; keep IDs
-- and rates tied to a named quest/item so failures read as product cases.
--
-- Schema extras:
--   expectMissingDropData = true  -- Forever DropTables currently have no row;
--                                 -- tip must stay blank until data is added.
--   provisionalCorrection / provisionalExpectedRateText
--                                 -- proves the tooltip path once DropDB is filled.
--   foreverDropTablesStatus = "present"|"absent"
--                                 -- audited against the installed Forever DropTables.

return {
    {
        id = "consumed-by-hatred-tusks",
        issueHint = "Forever map tip missing [N%] / wrong source NPCs for quest item drops",
        questId = 899,
        questName = "Consumed by Hatred",
        itemId = 5085,
        itemName = "Bristleback Quilboar Tusk",
        objectiveDescription = "Bristleback Quilboar Tusk",
        -- Full Dropped-by inventory from Wowhead Forever listview (item XML has no per-NPC rows).
        -- https://www.wowhead.com/forever/item=5085/bristleback-quilboar-tusk
        -- Era corrections: all Bristlebacks 100% (quest item); Raider keeps sampled Wowhead %.
        wowhead = {
            [3260] = 76.2713, -- Bristleback Water Seeker
            [3258] = 74.2372, -- Bristleback Hunter
            [3261] = 70.9279, -- Bristleback Thornweaver
            [3263] = 68.2448, -- Bristleback Geomancer
            [268624] = 8.0711, -- Razormane Raider (Forever-new)
            -- 3259 Bristleback Defender / 3262 Bristleback Mystic: listed, no sample (??)
        },
        cmangos = {
            [3258] = 80.0,
            [3260] = 80.0,
            [3261] = 80.0,
            [3263] = 80.0,
        },
        corrections = {
            [3258] = 100, -- Bristleback Hunter
            [3259] = 100, -- Bristleback Defender
            [3260] = 100, -- Bristleback Water Seeker
            [3261] = 100, -- Bristleback Thornweaver
            [3262] = 100, -- Bristleback Mystic
            [3263] = 100, -- Bristleback Geomancer
            [268624] = 8.0711, -- Razormane Raider; Wowhead Forever 767/9503
        },
        sources = {
            {npcId = 3260, name = "Bristleback Water Seeker", expectedRateText = "100", source = "questie"},
            {npcId = 3258, name = "Bristleback Hunter", expectedRateText = "100", source = "questie"},
            {npcId = 3261, name = "Bristleback Thornweaver", expectedRateText = "100", source = "questie"},
            {npcId = 3263, name = "Bristleback Geomancer", expectedRateText = "100", source = "questie"},
            {npcId = 268624, name = "Razormane Raider", expectedRateText = "8.1", source = "questie"},
            {npcId = 3259, name = "Bristleback Defender", expectedRateText = "100", source = "questie"},
            {npcId = 3262, name = "Bristleback Mystic", expectedRateText = "100", source = "questie"},
        },
        -- Without Era corrections, cmangos (80%) beats wowhead for classic NPCs only.
        cmangosExpected = {
            [3258] = "80",
            [3260] = "80",
            [3261] = "80",
            [3263] = "80",
        },
        wowheadOnlyExpected = {
            [3260] = "76",
            [3258] = "74",
            [3261] = "71",
            [3263] = "68",
            [268624] = "8.1",
        },
        foreverDropTablesStatus = "present",
        unrelatedSources = {
            {npcId = 3242, name = "Zhevra Runner"},
            {npcId = 3457, name = "Razormane Stalker"},
        },
    },
    {
        id = "her-name-is-olgra-adornments",
        issueHint = "Forever-custom quest item; filled from Wowhead Forever item XML when DropTables lacked a row",
        foreverCustom = true,
        foreverDropTablesStatus = "present",
        questId = 95774,
        questName = "Her Name Is Olgra",
        itemId = 277277,
        itemName = "Olgra's Adornments",
        objectiveDescription = "Olgra's Adornments",
        -- npcDrops → 268624. Rate from https://www.wowhead.com/forever/item=277277&xml
        wowhead = {},
        cmangos = {},
        corrections = {
            [268624] = 34.28,
        },
        sources = {
            {npcId = 268624, name = "Razormane Raider", expectedRateText = "34", source = "questie"},
        },
        unrelatedSources = {
            {npcId = 3457, name = "Razormane Stalker"},
        },
    },
    {
        id = "zhevra-hooves-wowhead-sentinel",
        issueHint = "Correction sentinel -1 must resolve through Wowhead into the map tip",
        questId = 845,
        questName = "The Zhevra",
        itemId = 5086,
        itemName = "Zhevra Hooves",
        objectiveDescription = "Zhevra Hooves",
        wowhead = {
            [3242] = 30.7163,
            [3426] = 8.6391,
            [3466] = 0.1453,
            [5831] = 0.4175,
        },
        cmangos = {
            [3242] = 80.0,
            [3426] = 80.0,
            [3466] = 80.0,
            [5831] = 80.0,
        },
        -- DropDB.correctionKeys.WOWHEAD == -1
        corrections = {
            [3242] = -1,
            [3426] = -1,
            [3466] = -1,
            [5831] = -1,
        },
        sources = {
            {npcId = 3242, name = "Zhevra Runner", expectedRateText = "31", source = "wowhead"},
            {npcId = 3426, name = "Zhevra Charger", expectedRateText = "8.6", source = "wowhead"},
            {npcId = 3466, name = "Zhevra Courser", expectedRateText = "0.15", source = "wowhead"},
            {npcId = 5831, name = "Swiftmane", expectedRateText = "0.42", source = "wowhead"},
        },
        foreverDropTablesStatus = "present",
        unrelatedSources = {
            {npcId = 3258, name = "Bristleback Hunter"},
        },
    },
}
