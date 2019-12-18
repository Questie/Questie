---@class QuestieDB
local QuestieDB = QuestieLoader:CreateModule("QuestieDB");
-------------------------
--Import modules.
-------------------------
---@type QuestieStreamLib
local QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDBZone
local QuestieDBZone = QuestieLoader:ImportModule("QuestieDBZone")

local tinsert = table.insert

-- DB keys
local DB_NAME, DB_NPC, NOTE_TITLE = 1, 1, 1;
local DB_STARTS, DB_OBJ, NOTE_COMMENT, DB_MIN_LEVEL_HEALTH = 2, 2, 2, 2;
local DB_ENDS, DB_ITM, NOTE_ICON, DB_MAX_LEVEL_HEALTH = 3, 3, 3, 3;
local DB_MIN_LEVEL, DB_ZONES, DB_VENDOR, DB_OBJ_SPAWNS, DB_TRIGGER_MARKED = 4, 4, 4, 4, 4;
local DB_LEVEL, DB_ITM_QUEST_REW = 5, 5;
local DB_REQ_RACE, DB_RANK, DB_ITM_NAME = 6, 6, 6;
local DB_REQ_CLASS, DB_NPC_SPAWNS = 7, 7;
local DB_OBJECTIVES, DB_NPC_WAYPOINTS = 8, 8;
local DB_TRIGGER, DB_ZONE = 9, 9;
local DB_REQ_NPC_OR_OBJ_OR_ITM, DB_NPC_STARTS = 10, 10;
local DB_SRC_ITM, DB_NPC_ENDS = 11, 11;
local DB_PRE_QUEST_GROUP = 12;
local DB_PRE_QUEST_SINGLE, DB_NPC_FRIENDLY = 13, 13;
local DB_SUB_QUESTS = 14;
local DB_QUEST_GROUP = 15;
local DB_EXCLUSIVE_QUEST_GROUP = 16;
local DB_SPECIAL_FLAGS = 24

local ClassBitIndexTable = {
    ['warrior'] = 1,
    ['paladin'] = 2,
    ['hunter'] = 3,
    ['rogue'] = 4,
    ['priest'] = 5,
    ['shaman'] = 7,
    ['mage'] = 8,
    ['warlock'] = 9,
    ['druid'] = 11
};

local RaceBitIndexTable = {
    ['human'] = 1,
    ['orc'] = 2,
    ['dwarf'] = 3,
    ['nightelf'] = 4,
    ['night elf'] = 4,
    ['scourge'] = 5,
    ['undead'] = 5,
    ['tauren'] = 6,
    ['gnome'] = 7,
    ['troll'] = 8,
    ['goblin'] = 9
};

QuestieDB._QuestCache = {}; -- stores quest objects so they dont need to be regenerated
QuestieDB._ItemCache = {};
QuestieDB._NPCCache = {};
QuestieDB._ObjectCache = {};
QuestieDB._ZoneCache = {};

function QuestieDB:Initialize()
    QuestieDBZone:ZoneCreateConversion()
    QuestieDB:HideClassAndRaceQuests()
    QuestieDB:DeleteGatheringNodes()

    -- data has been corrected, ensure cache is empty (something might have accessed the api before questie initialized)
    QuestieDB._QuestCache = {};
    QuestieDB._ItemCache = {};
    QuestieDB._NPCCache = {};
    QuestieDB._ObjectCache = {};
    QuestieDB._ZoneCache = {};
end

function QuestieDB:ItemLookup(itemId)
    local itemName, itemLink = GetItemInfo(itemId)
    local item = {}
    item.name = itemName
    item.link = itemLink
    return item
end


function QuestieDB:GetObject(objectID)
    if objectID == nil then
        return nil
    end
    if QuestieDB._ObjectCache[objectID] ~= nil then
        return QuestieDB._ObjectCache[objectID];
    end

    local rawdata = QuestieDB.objectData[objectID];
    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetObject] rawdata is nil for objectID:", objectID)
        return nil
    end

    local obj = {};

    obj.id = objectID
    obj.type = "object"
    for stringKey, intKey in pairs(QuestieDB.objectKeys) do
        obj[stringKey] = rawdata[intKey]
    end
    QuestieDB._ObjectCache[objectID] = obj;
    return obj;
end

function QuestieDB:GetItem(itemID)
    if itemID == nil then
        return nil
    end
    if QuestieDB._ItemCache[itemID] ~= nil then
        return QuestieDB._ItemCache[itemID];
    end

    local rawdata = QuestieDB.itemData[itemID]; -- TODO: use the good item db, I need to talk to Muehe about the format, this is a temporary fix
    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetItem] rawdata is nil for itemID:", itemID)
        return nil
    end

    local item = {};

    for stringKey, intKey in pairs(QuestieDB.itemKeys) do
        item[stringKey] = rawdata[intKey]
    end

    item.Id = itemID;
    item.Sources = {};
    item.Hidden = QuestieCorrections.questItemBlacklist[itemID]
    for k,v in pairs(rawdata[3]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
        local source = {};
        source.Type = "monster";
        source.Id = v;
        tinsert(item.Sources, source);
    end
    for k,v in pairs(rawdata[4]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
        local source = {};
        source.Type = "object";
        source.Id = v;
        tinsert(item.Sources, source);
    end

    QuestieDB._ItemCache[itemID] = item;
    return item
end

local function _GetColoredQuestName(self, blizzLike)
    local questName = (self.LocalizedName or self.name)
    return QuestieLib:GetColoredQuestName(self.Id, questName, self.level, Questie.db.global.enableTooltipsQuestLevel, false, blizzLike)
end

---@param questID QuestId @The quest ID
---@return Quest|nil @The quest object or nil if the quest is missing
function QuestieDB:GetQuest(questID) -- /dump QuestieDB:GetQuest(867)
    if questID == nil then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetQuest] Expected questID but received nil!")
        return nil
    end
    if QuestieDB._QuestCache[questID] ~= nil then
        return QuestieDB._QuestCache[questID];
    end

    local rawdata = QuestieDB.questData[questID];
    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetQuest] rawdata is nil for questID:", questID)
        return nil
    end

    ---@class ObjectiveIndex
    ---@class QuestId

    ---@class Quest
    ---@field public childQuests any
    ---@field public exclusiveTo any
    ---@field public finishedBy any
    ---@field public inGroupWith any
    ---@field public name string
    ---@field public nextQuestInChain any
    ---@field public objectives any
    ---@field public objectivesText any
    ---@field public parentQuest any
    ---@field public preQuestGroup any
    ---@field public preQuestSingle any
    ---@field public questLevel any
    ---@field public requiredClasses any
    ---@field public requiredLevel any
    ---@field public requiredMinRep any
    ---@field public requiredRaces any
    ---@field public requiredSkill any
    ---@field public requiredSourceItems any
    ---@field public sourceItemId any
    ---@field public specialFlags any
    ---@field public startedBy any
    ---@field public triggerEnd any
    ---@field public zoneOrSort any

    local QO = {}
    QO.GetColoredQuestName = _GetColoredQuestName
    QO.Id = questID --Key
    for stringKey, intKey in pairs(QuestieDB.questKeys) do
        QO[stringKey] = rawdata[intKey]
    end
    QO.Starts = {} --Starts - 2
    QO.Starts["NPC"] = rawdata[2][1] --2.1
    QO.Starts["GameObject"] = rawdata[2][2] --2.2
    QO.Starts["Item"] = rawdata[2][3] --2.3
    QO.Ends = {} --ends 3
    QO.isHidden = rawdata.hidden or QuestieCorrections.hiddenQuests[questID]
    QO.Description = rawdata[8] --
    if QO.specialFlags then
        QO.Repeatable = mod(QO.specialFlags, 2) == 1
    end

    -- reorganize to match wow api
    if rawdata[3][1] ~= nil then
        for k,v in pairs(rawdata[3][1]) do
            --if _v ~= nil then
            --for k,v in pairs(_v) do
            if v ~= nil then
                local obj = {};
                obj.Type = "monster"
                obj.Id = v

                -- this speeds up lookup
                obj.Name = QuestieDB.npcData[v]
                if obj.Name ~= nil then
                    local name = obj.Name[QuestieDB.npcKeys.name]
                    obj.Name = string.lower(name);
                end

                QO.Finisher = obj; -- there is only 1 finisher --tinsert(QO.Finisher, obj);
            end
            --end
            --end
        end
    end
    if rawdata[3][2] ~= nil then
        for k,v in pairs(rawdata[3][2]) do
            --if _v ~= nil then
            --for k,v in pairs(_v) do
            if v ~= nil then
                local obj = {};
                obj.Type = "object"
                obj.Id = v

                -- this speeds up lookup
                obj.Name = QuestieDB.objectData[v]
                if obj.Name ~= nil then
                    obj.Name = string.lower(obj.Name[1]);
                end

                QO.Finisher = obj; -- there is only 1 finisher
            end
            --end
            --end
        end
    end

    QO.level = rawdata[5]
    QO.Triggers = rawdata[9] --List of coordinates
    QO.ObjectiveData = {} -- to differentiate from the current quest log info
    --    type
    --String - could be the following things: "item", "object", "monster", "reputation", "log", or "event". (from wow api)

    if QO.Triggers ~= nil then
        for k, v in pairs(QO.Triggers) do
            local obj = {};
            obj.Type = "event"
            obj.Coordinates = v
            tinsert(QO.ObjectiveData, obj);
        end
    end
    if rawdata[10] ~= nil then
        if rawdata[10][1] ~= nil then
            for _k,_v in pairs(rawdata[10][1]) do
                if _v ~= nil then

                    local obj = {};
                    obj.Type = "monster"
                    obj.Id = _v[1]
                    obj.Text = _v[2];

                    tinsert(QO.ObjectiveData, obj);

                end
            end
        end
        if rawdata[10][2] ~= nil then
            for _k,_v in pairs(rawdata[10][2]) do
                if _v ~= nil then

                    local obj = {};
                    obj.Type = "object"
                    obj.Id = _v[1]
                    obj.Text = _v[2]

                    tinsert(QO.ObjectiveData, obj);

                end
            end
        end
        if rawdata[10][3] ~= nil then
            for _k,_v in pairs(rawdata[10][3]) do
                if _v ~= nil then
                    local obj = {};
                    obj.Type = "item"
                    obj.Id = _v[1]
                    obj.Text = _v[2]

                    tinsert(QO.ObjectiveData, obj);
                end
            end
        end
    end

    if(rawdata[12] ~= nil and next(rawdata[12]) ~= nil and rawdata[13] ~= nil and next(rawdata[13]) ~= nil) then
        Questie:Debug(DEBUG_CRITICAL, "ERRRRORRRRRRR not mutually exclusive for questID:", questID)
    end
    QO.QuestGroup = rawdata[15] --Quests that are part of the same group, example complete this group of quests to open the next one.
    QO.ExclusiveQuestGroup = rawdata[16]

    QO.HiddenObjectiveData = {}

    local hidden = rawdata[21]

    if hidden ~= nil then --required source items
        for _,Id in pairs(hidden) do
            if Id ~= nil then

                local obj = {};
                obj.Type = "item"
                obj.Id = Id

                obj.Name = QuestieDB.itemData[obj.Id]
                if obj.Name ~= nil then
                    local name = obj.Name[QuestieDB.itemKeys.name]
                    obj.Name = string.lower(name);
                end

                tinsert(QO.HiddenObjectiveData, obj);
            end
        end
    end

    local zos = rawdata[17]
    if zos and zos ~= 0 then
        if zos > 0 then
            QO.Zone = zos
        else
            QO.Sort = -zos
        end
    end

    --- function
    ---@return boolean @Returns true if the quest should be grey, false otherwise
    function QO:IsTrivial()
        local levelDiff = self.level - QuestiePlayer:GetPlayerLevel();
        if (levelDiff >= 5) then
            return false -- Red
        elseif (levelDiff >= 3) then
            return false -- Orange
        elseif (levelDiff >= -2) then
            return false -- Yellow
        elseif (-levelDiff <= GetQuestGreenRange()) then
            return false -- Green
        else
            return true -- Grey
        end
    end

    ---@return boolean @Returns true if any pre quest has been completed or none is listed, false otherwise
    function QO:IsPreQuestSingleFulfilled()
        local preQuestSingle = self.preQuestSingle
        if not preQuestSingle or not next(preQuestSingle) then
            return true
        end
        for _, preQuestId in pairs(preQuestSingle) do
            local preQuest = QuestieDB:GetQuest(preQuestId);

            -- If a quest is complete the requirement is fulfilled
            if Questie.db.char.complete[preQuestId] then
                return true
            -- If one of the quests in the exclusive group is complete the requirement is fulfilled
            elseif preQuest and preQuest.ExclusiveQuestGroup then
                for _, v in pairs(preQuest.ExclusiveQuestGroup) do
                    if Questie.db.char.complete[v] then
                        return true
                    end
                end
            end
        end
        -- No preQuest is complete
        return false
    end

    ---@return boolean @Returns true if all listed pre quests are complete or none is listed, false otherwise
    function QO:IsPreQuestGroupFulfilled()
        local preQuestGroup = self.preQuestGroup
        if not preQuestGroup  or not next(preQuestGroup) then
            return true
        end
        for _, preQuestId in pairs(preQuestGroup) do
            -- If a quest is not complete and no exlusive quest is complete, the requirement is not fulfilled
            if not Questie.db.char.complete[preQuestId] then
                local preQuest = QuestieDB:GetQuest(preQuestId);
                if preQuest == nil or preQuest.ExclusiveQuestGroup == nil then
                    return false
                end

                local anyExlusiveFinished = false
                for _, v in pairs(preQuest.ExclusiveQuestGroup) do
                    if Questie.db.char.complete[v] then
                        anyExlusiveFinished = true
                    end
                end
                if not anyExlusiveFinished then
                    return false
                end
            end
        end
        -- All preQuests are complete
        return true
    end

    QuestieDB._QuestCache[questID] = QO
    return QO
end

---@param quest Quest
---@return table<string, table<integer, integer>> @List of creature names with their min-max level
function QuestieDB:GetCreatureLevels(quest)
    local creatureLevels = {}

    local function _CollectCreateLevels(npcList)
        for _, npcId in pairs(npcList) do
            local npc = QuestieDB:GetNPC(npcId)
            if npc and not creatureLevels[npc.name] then
                creatureLevels[npc.name] = {npc.minLevel, npc.maxLevel}
            end
        end
    end

    if quest.objectives then
        if quest.objectives[1] then -- Killing creatures
            for _, mobObjective in pairs(quest.objectives[1]) do
                _CollectCreateLevels(mobObjective)
            end
        end
        if quest.objectives[3] then -- Looting items from creatures
            for _, itemObjective in pairs(quest.objectives[3]) do
                local item = QuestieDB:GetItem(itemObjective[1])
                if item and item.npcDrops then
                    _CollectCreateLevels(item.npcDrops)
                end
            end
        end
    end
    return creatureLevels
end

QuestieDB.FactionGroup = UnitFactionGroup("player")

function QuestieDB:_GetSpecialNPC(NPCID)
    if NPCID == nil then
        return nil
    end
    local rawdata = Questie_SpecialNPCs[NPCID]
    if rawdata then
        local NPC = {}
        NPC.id = NPCID
        if not QuestieDB._stream then -- bad code
            QuestieDB._stream = QuestieStreamLib:GetStream("b89")
        end
        QuestieDB._stream:Load(rawdata)
        NPC.name = QuestieDB._stream:ReadTinyString()
        NPC.type = "monster"
        NPC.newFormatSpawns = {}; -- spawns should be stored like this: {{x, y, uimapid}, ...} so im creating a 2nd var to aid with moving to the new format
        NPC.spawns = {};
        local count = QuestieDB._stream:ReadByte()
        for i=1, count do
            local x = QuestieDB._stream:ReadShort() / 655.35
            local y = QuestieDB._stream:ReadShort() / 655.35
            local m = QuestieDB._stream:ReadByte() + 1400
            tinsert(NPC.newFormatSpawns, {x, y, m});
            local om = m;
            m = QuestieDBZone:GetAreaIdByUIMapID(m)
            if m then
                if not NPC.spawns[m] then
                    NPC.spawns[m] = {};
                end
                tinsert(NPC.spawns[m], {x, y});
            end
        end
        return NPC
    end
    return nil
end

function QuestieDB:GetNPC(npcID)
    if npcID == nil then
        return nil
    end
    if(QuestieDB._NPCCache[npcID]) then
        return QuestieDB._NPCCache[npcID]
    end

    local rawdata = QuestieDB.npcData[npcID]    
    if not rawdata then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetNPC] rawdata is nil for npcID:", npcID)
        return QuestieDB:_GetSpecialNPC(npcID)
    end

    local npc = {}
    npc.type = "monster"
    npc.id = npcID
    for stringKey, intKey in pairs(QuestieDB.npcKeys) do
        npc[stringKey] = rawdata[intKey]
    end
    if npc.spawns == nil and Questie_SpecialNPCs[npcID] then -- get spawns from script spawns list
        npc.spawns = QuestieDB:_GetSpecialNPC(npcID).spawns
    end

    ---@class Point
    ---@class Zone
    if npc.waypoints == nil and rawdata[QuestieDB.npcKeys.waypoints] then
        Questie:Debug(DEBUG_DEVELOP, "Got waypoints! NPC", npc.name, npc.id)
        ---@type table<Zone, table<Point, Point>>
        npc.waypoints = rawdata[QuestieDB.npcKeys.waypoints];
    end

    if rawdata[DB_NPC_FRIENDLY] then
        if rawdata[DB_NPC_FRIENDLY] == "AH" then
            npc.friendly = true
        else
            if QuestieDB.FactionGroup == "Horde" and rawdata[DB_NPC_FRIENDLY] == "H" then
                npc.friendly = true
            elseif QuestieDB.FactionGroup == "Alliance" and rawdata[DB_NPC_FRIENDLY] == "A" then
                npc.friendly = true
            end
        end
    else
        npc.friendly = true
    end

    QuestieDB._NPCCache[npcID] = npc
    return npc
end

function QuestieDB:GetQuestsByName(questName)
    if not questName then
        return nil;
    end

    local returnTable = {};

    for index, quest in pairs(QuestieDB.questData) do
        local needle = string.lower(questName);
        local haystack = quest[1]
        local lowerHaystack = string.lower(haystack);
        if string.find(lowerHaystack, needle) then
            tinsert(returnTable, index);
        end
    end

    return returnTable;
end

function QuestieDB:GetNPCsByName(npcName)
    if not npcName then
        return nil;
    end

    local returnTable = {};

    for index, npc in pairs(QuestieDB.npcData) do
        local needle = string.lower(npcName);
        local haystack = npc[QuestieDB.questKeys.name]
        local lowerHaystack = string.lower(haystack);

        if string.find(lowerHaystack, needle) then
            tinsert(returnTable, index);
        end
    end

    return returnTable;
end

--[[
    https://github.com/cmangos/issues/wiki/AreaTable.dbc
    Example to differentiate between Dungeon and Zone infront of a Dungeon:
    1337 Uldaman = The Dungeon (MapID ~= 0, AreaID = 0)
    1517 Uldaman = Cave infront of the Dungeon (MapID = 0, AreaID = 3 (Badlands))

    Check `LangZoneLookup` for the available IDs
]]
function QuestieDB:GetQuestsByZoneId(zoneId)

    if not zoneId then
        return nil;
    end

    -- in in cache return that
    if QuestieDB._ZoneCache[zoneId] then
        return QuestieDB._ZoneCache[zoneId]
    end

    local zoneQuests = {};
    local alternativeZoneID = QuestieDBZone:GetDungeonAlternative(zoneId)
    -- loop over all quests to populate a zone
    for qid, _ in pairs(QuestieDB.questData) do
        local quest = QuestieDB:GetQuest(qid);

        if quest then
            if quest.zoneOrSort > 0 and (quest.zoneOrSort == zoneId or (alternativeZoneID and quest.zoneOrSort == alternativeZoneID)) then
                zoneQuests[qid] = quest;
            end

            if quest.Starts.NPC and zoneQuests[qid] == nil then
                local npc = QuestieDB:GetNPC(quest.Starts.NPC[1]);

                if npc and npc.friendly and npc.spawns then
                    for zone, _ in pairs(npc.spawns) do
                        if zone == zoneId  or (alternativeZoneID and zone == alternativeZoneID) then
                            zoneQuests[qid] = quest;
                        end
                    end
                end
            end

            if quest.Starts.GameObject and zoneQuests[qid] == nil then
                local obj = QuestieDB:GetObject(quest.Starts.GameObject[1]);

                if obj and obj.spawns then
                    for zone, _ in pairs(obj.spawns) do
                        if zone == zoneId  or (alternativeZoneID and zone == alternativeZoneID) then
                            zoneQuests[qid] = quest;
                        end
                    end
                end
            end
        end
    end

    QuestieDB._ZoneCache[zoneId] = zoneQuests;
    return zoneQuests;
end

---------------------------------------------------------------------------------------------------
-- Modifications to objectDB
function QuestieDB:DeleteGatheringNodes()
    local prune = { -- gathering nodes
        1617,1618,1619,1620,1621,1622,1623,1624,1628, -- herbs

        1731,1732,1733,1734,1735,123848,150082,175404,176643,177388,324,150079,176645,2040,123310 -- mining
    };
    for k,v in pairs(prune) do
        QuestieDB.objectData[v][DB_OBJ_SPAWNS] = nil
    end
end

---------------------------------------------------------------------------------------------------
-- Modifications to questDB

function UnpackBinary(val)
    local ret = {};
    for q=0,16 do
        if bit.band(bit.rshift(val,q), 1) == 1 then
            tinsert(ret, true);
        else
            tinsert(ret, false);
        end
    end
    return ret;
end

function QuestieDB:HideClassAndRaceQuests()
    local _, _, classIndex = UnitClass("player");
    local _, _, raceIndex = UnitRace("player");
    if classIndex and raceIndex then
        classIndex = math.pow(2, classIndex-1)
        raceIndex = math.pow(2, raceIndex-1)
        local questKeys = QuestieDB.questKeys
        for key, entry in pairs(QuestieDB.questData) do
            -- check requirements, set hidden flag if not met
            local requiredClasses = entry[questKeys.requiredClasses]
            if (requiredClasses) and (requiredClasses ~= 0) then
                if (bit.band(requiredClasses, classIndex) == 0) then
                    entry.hidden = true
                end
            end
            local requiredRaces = entry[questKeys.requiredRaces]
            if (requiredRaces) and (requiredRaces ~= 0) and (requiredRaces ~= 255) then
                if (bit.band(requiredRaces, raceIndex) == 0) then
                    entry.hidden = true
                end
            end
        end
    end
    Questie:Debug(DEBUG_DEVELOP, "Other class and race quests hidden");
end
