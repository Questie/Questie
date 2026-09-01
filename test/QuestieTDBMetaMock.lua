-- Focused Contract Version 1 metadata fixture for QuestieDB semantic tests.
-- It intentionally omits compiler metadata, raw entity tables, and storage behavior.
---@return nil
local function LoadQuestieTDBMetaMock()
    ---@type QuestieDB
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

    QuestieDB.questKeys = {
        ["name"] = 1, -- string
        ["startedBy"] = 2, -- table
            --["creatureStart"] = 1, -- table {creature(int),...}
            --["objectStart"] = 2, -- table {object(int),...}
            --["itemStart"] = 3, -- table {item(int),...}
        ["finishedBy"] = 3, -- table
            --["creatureEnd"] = 1, -- table {creature(int),...}
            --["objectEnd"] = 2, -- table {object(int),...}
        ["requiredLevel"] = 4, -- int
        ["questLevel"] = 5, -- int
        ["requiredRaces"] = 6, -- bitmask
        ["requiredClasses"] = 7, -- bitmask
        ["objectivesText"] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
        ["triggerEnd"] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
        ["objectives"] = 10, -- table
            --["creatureObjective"] = 1, -- table {{creature(int), text(string), iconFile},...}, If text is nil the default "<Name> slain x/y" is used
            --["objectObjective"] = 2, -- table {{object(int), text(string), iconFile},...}
            --["itemObjective"] = 3, -- table {{item(int), text(string), iconFile},...}
            --["reputationObjective"] = 4, -- table: {faction(int), value(int)}
            --["killCreditObjective"] = 5, -- table: {{{creature(int), ...}, baseCreatureID, baseCreatureText, iconFile}, ...}
            --["spellObjective"] = 6, -- table: {{spell(int), text(string), item(int)},...}
        ["sourceItemId"] = 11, -- int, item provided by quest starter
        ["preQuestGroup"] = 12, -- table: {quest(int)}
        ["preQuestSingle"] = 13, -- table: {quest(int)}
        ["childQuests"] = 14, -- table: {quest(int)}
        ["inGroupWith"] = 15, -- table: {quest(int)}
        ["exclusiveTo"] = 16, -- table: {quest(int)}
        ["zoneOrSort"] = 17, -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
        ["requiredSkill"] = 18, -- table: {skill(int), value(int)}
        ["requiredMinRep"] = 19, -- table: {faction(int), value(int)}
        ["requiredMaxRep"] = 20, -- table: {faction(int), value(int)}
        ["requiredSourceItems"] = 21, -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
        ["nextQuestInChain"] = 22, -- int: if this quest is active/finished, the current quest is not available anymore
        ["questFlags"] = 23, -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
        ["specialFlags"] = 24, -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
        ["parentQuest"] = 25, -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
        ["reputationReward"] = 26, -- table: {{faction(int), value(int)},...}, a list of reputation rewarded upon quest completion
        ["breadcrumbForQuestId"] = 27, -- int: quest ID for the quest this optional breadcrumb quest leads to
        ["breadcrumbs"] = 28, -- table: {questID(int), ...} quest IDs of the breadcrumbs that lead to this quest
        ["extraObjectives"] = 29, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
        ["requiredSpell"] = 30, -- int: quest is only available if character has this spellID
        ["requiredSpecialization"] = 31, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
        ["requiredMaxLevel"] = 32, -- int: the maximum level at which the quest is still available
        ["availableUntilCompleted"] = 33, -- int: the current quest is available until this quest is turned in
        ["availableStartingWith"] = 34, -- int: the ID of the quest that needs to be in quest log OR turned in for the current one to be available.
        ["requiredRanks"] = 35, -- table: {{skill(int), value(int)}}. Table of professions and ranks to be checked with OR logic
        ["disabledByQuest"] = 36, -- int: quest that, if in player's quest log, makes current quest unavailable for the duration
    }

    QuestieDB.npcKeys = {
        ["name"] = 1, -- string
        ["minLevelHealth"] = 2, -- int
        ["maxLevelHealth"] = 3, -- int
        ["minLevel"] = 4, -- int
        ["maxLevel"] = 5, -- int
        ["rank"] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
        ["spawns"] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ["waypoints"] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ["zoneID"] = 9, -- guess as to where this NPC is most common
        ["questStarts"] = 10, -- table {questID(int),...}
        ["questEnds"] = 11, -- table {questID(int),...}
        ["factionID"] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
        ["friendlyToFaction"] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
        ["subName"] = 14, -- string, The title or function of the NPC, e.g. "Weapon Vendor"
        ["npcFlags"] = 15, -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
                           -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
    }

    QuestieDB.itemKeys = {
        ["name"] = 1, -- string
        ["npcDrops"] = 2, -- table or nil, NPC IDs
        ["objectDrops"] = 3, -- table or nil, object IDs
        ["itemDrops"] = 4, -- table or nil, item IDs
        ["startQuest"] = 5, -- int or nil, ID of the quest started by this item
        ["questRewards"] = 6, -- table or nil, quest IDs
        ["flags"] = 7, -- int or nil, see: https://github.com/cmangos/issues/wiki/Item_template#flags
        ["foodType"] = 8, -- int or nil, see https://github.com/cmangos/issues/wiki/Item_template#foodtype
        ["itemLevel"] = 9, -- int, the level of this item
        ["requiredLevel"] = 10, -- int, the level required to equip/use this item
        ["ammoType"] = 11, -- int,
        ["class"] = 12, -- int,
        ["subClass"] = 13, -- int,
        ["vendors"] = 14, -- table or nil, NPC IDs
        ["relatedQuests"] = 15, -- table or nil, IDs of quests that are related to this item
        ["teachesSpell"] = 16, -- int, spellID taught by this item upon use
    }

    QuestieDB.objectKeys = {
        ["name"] = 1, -- string
        ["questStarts"] = 2, -- table {questID(int),...}
        ["questEnds"] = 3, -- table {questID(int),...}
        ["spawns"] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ["zoneID"] = 5, -- guess as to where this object is most common
        ["factionID"] = 6, -- faction restriction mask (same as spawndb factionid)
        ["waypoints"] = 7, -- waypoints for objects on ships/zeppelins/etc
    }
end

return LoadQuestieTDBMetaMock
