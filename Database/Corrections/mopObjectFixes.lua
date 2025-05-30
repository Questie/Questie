---@class MopObjectFixes
local MopObjectFixes = QuestieLoader:CreateModule("MopObjectFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

function MopObjectFixes.Load()
    local objectKeys = QuestieDB.objectKeys
    local zoneIDs = ZoneDB.zoneIDs

    return {
        [209656] = { -- Defaced Scroll of Wisdom
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{29.07,51.28},{29.2,51.22},{29.07,51.28},{29.2,51.22},{29.2,51.22},{29.07,51.28},{31.26,49.96},{31.47,49.92},{32.7,53.5},{32.5,53.58},{32.5,53.58},{31.47,49.92},{31.26,49.96},{32.7,53.5},{32.53,46.81},{32.48,46.66},{33.17,46.15},{33.45,50.86},{32.48,46.66},{33.13,46.3},{33.17,46.15},{33.13,46.3},{32.53,46.81},{33.45,50.86},{33.17,46.15},{33.13,46.3},{32.48,46.66},{32.53,46.81},{32.53,46.81},{32.48,46.66},{33.17,46.15},{33.13,46.3},{28.26,49.88},{28.26,49.58},{28.19,49.95},{28.19,49.95},{28.26,49.58},{28.26,49.88},{28.19,49.95},{28.26,49.58}}},
        },
        [210005] = { -- Weapon Rack
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{59.19,17.25},{58.67,16.32},{56.86,19.64},{57.59,17.59},{58.03,19.95},{57.85,20.06},{58.86,16.72},{57.24,16.73},{57.23,19.23},{56.98,20.49}}},
        },
        [210964] = { -- Pei-Wu Forest Gate
            [objectKeys.name] = 'Pei-Wu Forest Gate',
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{52.26,68.52}}},
            [objectKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [210965] = { -- Mandori Village Gate
            [objectKeys.name] = 'Mandori Village Gate',
            [objectKeys.spawns] = {[zoneIDs.THE_WANDERING_ISLE] = {{51.59,61.29}}},
            [objectKeys.zoneID] = zoneIDs.THE_WANDERING_ISLE,
        },
        [211720] = { -- Meeting Stone (Terrace of Endless Spring)
            [objectKeys.zoneID] = zoneIDs.THE_VEILED_STAIRS,
            [objectKeys.spawns] = {[zoneIDs.THE_VEILED_STAIRS] = {{51.7,69.4}}},
        },
        [212526] = { -- An empty bookshelf
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{82.4,29.4},{82.4,29.5},{82.5,29.4},{82.5,29.5}}},
        },
        [213254] = { -- Meeting Stone (Mogu Shan Palace)
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{82.9,40.8}}},
        },
        [213255] = { -- Meeting Stone (Mogu Shan Palace)
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{74.8,30.3}}},
        },
        [214169] = { -- Meeting Stone (Gate of the Setting Sun)
            [objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            [objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{15.5,76.7}}},
        },
        [214979] = { -- Meeting Stone (Stormstout Brewery)
            [objectKeys.zoneID] = zoneIDs.VALLEY_OF_THE_FOUR_WINDS,
            [objectKeys.spawns] = {[zoneIDs.VALLEY_OF_THE_FOUR_WINDS] = {{35.6,65.6}}},
        },
        [221268] = { -- Meeting Stone (Siege of Orgrimmar) TODO: Enable correct spawns, once SoO is available
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = {},
            --[objectKeys.zoneID] = zoneIDs.VALE_OF_ETERNAL_BLOSSOMS,
            --[objectKeys.spawns] = {[zoneIDs.VALE_OF_ETERNAL_BLOSSOMS] = {{69.8,45.5}}},
        },
        [223816] = { -- Meeting Stone (Heart of Fear)
            [objectKeys.name] = 'Meeting Stone', -- DB says "unk name" and wowhead does not know this object, so we reuse it.
            [objectKeys.zoneID] = zoneIDs.DREAD_WASTED,
            [objectKeys.spawns] = {[zoneIDs.DREAD_WASTED] = {{40.6,33.6}}},
        },
        [223817] = { -- Meeting Stone (Throne of Thunder) TODO: Add correct spawns, once The Isle of Thunder is available
            [objectKeys.name] = 'Meeting Stone', -- DB says "unk name" and wowhead does not know this object, so we reuse it.
            [objectKeys.zoneID] = 0,
            [objectKeys.spawns] = {},
        },
    }
end
