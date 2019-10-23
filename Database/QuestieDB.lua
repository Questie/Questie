QuestieDB = {...}

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

function QuestieDB:ItemLookup(ItemId)
    local itemName, itemLink = GetItemInfo(ItemId)
    local item = {}
    item.name = itemName
    item.link = itemLink
    return item
end


function QuestieDB:GetObject(ObjectID)
    if ObjectID == nil then
        return nil
    end
    if QuestieDB._ObjectCache[ObjectID] ~= nil then
        return QuestieDB._ObjectCache[ObjectID];
    end
    if QuestieCorrections.objectFixes[ObjectID] then
        for k,v in pairs(QuestieCorrections.objectFixes[ObjectID]) do
            QuestieDB.objectData[ObjectID][k] = v
        end
    end
    local raw = QuestieDB.objectData[ObjectID];
    if raw ~= nil then
        local obj = {};
        obj.id = ObjectID
        obj.type = "object"
        for stringKey, intKey in pairs(QuestieDB.objectKeys) do
            obj[stringKey] = raw[intKey]
        end
        -- Do localization
        local localizedName = LangObjectLookup[ObjectID]
        if localizedName ~= nil then
            obj.name = localizedName or obj.name
        end
        QuestieDB._ObjectCache[ObjectID] = obj;
        return obj;
    else
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Missing container ", ObjectID)
    end
end

function QuestieDB:GetItem(ItemID)
    if ItemID == nil then
        return nil
    end
    if QuestieDB._ItemCache[ItemID] ~= nil then
        return QuestieDB._ItemCache[ItemID];
    end
    -- TODO make itemFixes be accessable by field as well
    -- if QuestieCorrections.itemFixes[ItemID] then
    --     for k,v in pairs(QuestieCorrections.itemFixes[ItemID]) do
    --         CHANGEME_Questie4_ItemDB[ItemID][k] = v
    --     end
    -- end
    local raw = CHANGEME_Questie4_ItemDB[ItemID]; -- TODO: use the good item db, I need to talk to Muehe about the format, this is a temporary fix
    local item = {};
    if raw ~= nil then
        item.Id = ItemID;
        item.Name = LangItemLookup[ItemID] or raw[1];
        item.Sources = {};
        item.Hidden = QuestieCorrections.questItemBlacklist[ItemID]
        for k,v in pairs(raw[3]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
            local source = {};
            source.Type = "monster";
            source.Id = v;
            table.insert(item.Sources, source);
        end
        for k,v in pairs(raw[4]) do -- droppedBy = 3, relatedQuests=2, containedIn=4
            local source = {};
            source.Type = "object";
            source.Id = v;
            table.insert(item.Sources, source);
        end
    end
    QuestieDB._ItemCache[ItemID] = item;
    return item
end

local function _GetColoredQuestName(self, blizzLike)
    local questName = (self.LocalizedName or self.Name)
    return QuestieLib:GetColoredQuestName(self.Id, questName, self.Level, Questie.db.global.enableTooltipsQuestLevel, false, blizzLike)
end

function QuestieDB:GetQuest(QuestID) -- /dump QuestieDB:GetQuest(867)
    if QuestID == nil then
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetQuest] Expected questID but received nil!")
        return nil
    end
    if QuestieDB._QuestCache[QuestID] ~= nil then
        return QuestieDB._QuestCache[QuestID];
    end
    --[[     [916] = {"Webwood Venom",{{2082,},nil,nil,},{{2082,},nil,},3,4,"A",nil,nil,nil,{nil,nil,{{5166,nil},},},nil,nil,nil,nil,nil,nil,},
    --key
    --name = 1
    --starts = 2
    --npc = starts1
    --obj = starts2
    --itm = starts3
    --ends = 3
    --npc = ends1
    --obj = ends2
    --minLevel = 4
    --level = 5
    --RequiredRaces = 6
    --RequiredClasses = 7
    --objectives = 8
    --trigger = 9
    --ReqCreatureOrGOOrItm = 10
    --npc = ReqCreatureOrGOOrItm1
    --obj = ReqCreatureOrGOOrItm2
    --itm = ReqCreatureOrGOOrItm3
    --SrcItemId = 11
    -- 12 DB_PRE_QUEST_GROUP
    -- 13 DB_PRE_QUEST_SINGLE
    -- 14 DB_SUB_QUESTS
    -- 15 DB_QUEST_GROUP
    -- 16 DB_EXCLUSIVE_QUEST_GROUP]]--
    if QuestieCorrections.questFixes[QuestID] then
        for k, v in pairs(QuestieCorrections.questFixes[QuestID]) do
            QuestieDB.questData[QuestID][k] = v
        end
    end
    local rawdata = QuestieDB.questData[QuestID];
    if(rawdata)then
        local QO = {}
        QO.GetColoredQuestName = _GetColoredQuestName
        QO.Id = QuestID --Key
        for stringKey, intKey in pairs(QuestieDB.questKeys) do
            QO[stringKey] = rawdata[intKey]
        end
        QO.Name = rawdata[1] --Name - 1
        QO.Starts = {} --Starts - 2
        QO.Starts["NPC"] = rawdata[2][1] --2.1
        QO.Starts["GameObject"] = rawdata[2][2] --2.2
        QO.Starts["Item"] = rawdata[2][3] --2.3
        QO.Ends = {} --ends 3
        QO.Hidden = rawdata.hidden or QuestieCorrections.hiddenQuests[QuestID]
        QO.Description = rawdata[8] --
        QO.SpecialFlags = rawdata[DB_SPECIAL_FLAGS]
        if QO.SpecialFlags then
            QO.Repeatable = mod(QO.SpecialFlags, 2) == 1
        end

        -- Do localization
        local localizedQuest = LangQuestLookup[QuestID]
        if localizedQuest ~=nil then
            QO.Name = localizedQuest[1] or QO.Name
            QO.Description = localizedQuest[3] or QO.Description
        end

        --QO.Ends["NPC"] = rawdata[3][1]
        --QO.Ends["GameObject"] = rawdata[3][2]

        --[4495] = {"A Good Friend",{{8583,},nil,nil,},{{8584,},nil,}
        --QO.Finisher = {};
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
                        local name = LangNameLookup[v] or obj.Name[1]
                        obj.Name = string.lower(name);
                    end

                    QO.Finisher = obj; -- there is only 1 finisher --table.insert(QO.Finisher, obj);
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

        QO.Level = rawdata[5]
        QO.Triggers = rawdata[9] --List of coordinates
        QO.ObjectiveData = {} -- to differentiate from the current quest log info
        --    type
        --String - could be the following things: "item", "object", "monster", "reputation", "log", or "event". (from wow api)

        if QO.Triggers ~= nil then
            for k, v in pairs(QO.Triggers) do
                local obj = {};
                obj.Type = "event"
                obj.Coordinates = v
                table.insert(QO.ObjectiveData, obj);
            end
        end

        if rawdata[10][1] ~= nil then
            for _k,_v in pairs(rawdata[10][1]) do
                if _v ~= nil then

                    local obj = {};
                    obj.Type = "monster"
                    obj.Id = _v[1]
                    obj.Text = _v[2];

                    table.insert(QO.ObjectiveData, obj);

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

                    table.insert(QO.ObjectiveData, obj);

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

                    table.insert(QO.ObjectiveData, obj);
                end
            end
        end
        --QO.Objectives["NPC"] = rawdata[10][1] --{NPCID, Different name of NPC or object}
        --QO.Objectives["GameObject"] = rawdata[10][2] --{GOID, Different name of NPC or object}
        --QO.Objectives["Item"] = rawdata[10][3]
        --QO.SrcItemId = rawdata[11] --A quest item given by a questgiver of some kind.

        if(rawdata[12] ~= nil and next(rawdata[12]) ~= nil and rawdata[13] ~= nil and next(rawdata[13]) ~= nil) then
            Questie:Debug(DEBUG_CRITICAL, "ERRRRORRRRRRR not mutually exclusive for questID:", QuestID)
        end
        if(rawdata[12] ~= nil) then
            QO.RequiredQuestGroup = rawdata[12]
        else
            QO.RequiredQuestSingle = rawdata[13]
        end
        QO.QuestGroup = rawdata[15] --Quests that are part of the same group, example complete this group of quests to open the next one.
        QO.ExclusiveQuestGroup = rawdata[16]
        QO.NextQuestInChain = rawdata[22]

        QO.HiddenObjectiveData = {}

        local hidden = rawdata[21]

        if hidden ~= nil then --required source items
            for _,Id in pairs(hidden) do
                if Id ~= nil then

                    local obj = {};
                    obj.Type = "item"
                    obj.Id = Id

                    obj.Name = CHANGEME_Questie4_ItemDB[obj.Id]
                    if obj.Name ~= nil then
                        local name = LangItemLookup[obj.Id] or obj.Name[1]
                        obj.Name = string.lower(name);
                    end

                    table.insert(QO.HiddenObjectiveData, obj);
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

        QuestieDB._QuestCache[QuestID] = QO
        return QO
    else
        Questie:Debug(DEBUG_CRITICAL, "[QuestieDB:GetQuest] rawdata is nil for questID:", QuestID)
        return nil
    end
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
        for i=1,count do
            local x = QuestieDB._stream:ReadShort() / 655.35
            local y = QuestieDB._stream:ReadShort() / 655.35
            local m = QuestieDB._stream:ReadByte() + 1400
            table.insert(NPC.newFormatSpawns, {x, y, m});
            local om = m;
            m = zoneDataUiMapIDToAreaID[m];
            if m then
                if not NPC.spawns[m] then
                    NPC.spawns[m] = {};
                end
                table.insert(NPC.spawns[m], {x, y});
            end
        end
        return NPC
    end
    return nil
end

function QuestieDB:GetNPC(NPCID)
    if NPCID == nil then
        return nil
    end
    if(QuestieDB._NPCCache[NPCID]) then
        return QuestieDB._NPCCache[NPCID]
    end
    if QuestieCorrections.npcFixes[NPCID] then
        for k,v in pairs(QuestieCorrections.npcFixes[NPCID]) do
            QuestieDB.npcData[NPCID][k] = v
        end
    end
    local rawdata = QuestieDB.npcData[NPCID]
    if(rawdata)then
        local NPC = {}
        NPC.type = "monster"
        NPC.id = NPCID
        for stringKey, intKey in pairs(QuestieDB.npcKeys) do
            NPC[stringKey] = rawdata[intKey]
        end
        -- Do localization
        local localizedName = LangNameLookup[NPCID]
        if localizedName ~=nil then
            NPC.name = localizedName or NPC.name
        end
        if NPC.spawns == nil and Questie_SpecialNPCs[NPCID] then -- get spawns from script spawns list
            NPC.spawns = QuestieDB:_GetSpecialNPC(NPCID).spawns
        end

        ---@class Point
        ---@class Zone
        if NPC.waypoints == nil and rawdata[QuestieDB.npcKeys.waypoints] then
            Questie:Debug(DEBUG_DEVELOP, "Got waypoints! NPC", NPC.name, NPC.id)
            ---@type table<Zone, table<Point, Point>>
            NPC.waypoints = rawdata[QuestieDB.npcKeys.waypoints];
        end

        if rawdata[DB_NPC_FRIENDLY] then
            if rawdata[DB_NPC_FRIENDLY] == "AH" then
                NPC.friendly = true
            else
                if QuestieDB.FactionGroup == "Horde" and rawdata[DB_NPC_FRIENDLY] == "H" then
                    NPC.friendly = true
                elseif QuestieDB.FactionGroup == "Alliance" and rawdata[DB_NPC_FRIENDLY] == "A" then
                    NPC.friendly = true
                end
            end
        else
            NPC.friendly = true
        end
        QuestieDB._NPCCache[NPCID] = NPC
        return NPC
    else
        return QuestieDB:_GetSpecialNPC(NPCID)
    end
end

function QuestieDB:GetQuestsByName(questName)
    if not questName then
        return nil;
    end

    local returnTable = {};

    for index, quest in pairs(QuestieDB.questData) do
        local needle = string.lower(questName);
        local haystack = quest[1]
        local localizedQuest = LangQuestLookup[index]
        if localizedQuest ~=nil then
            haystack = localizedQuest[1] or quest[1]
        end
        local lowerHaystack = string.lower(haystack);
        if string.find(lowerHaystack, needle) then
            table.insert(returnTable, index);
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
        local haystack =  LangNameLookup[index] or npc[1]
        local lowerHaystack = string.lower(haystack);

        if string.find(lowerHaystack, needle) then
            table.insert(returnTable, index);
        end
    end

    return returnTable;
end

function QuestieDB:GetQuestsByZoneId(zoneid)

    if not zoneid then
        return nil;
    end

    -- in in cache return that
    if QuestieDB._ZoneCache[zoneid] then
        return QuestieDB._ZoneCache[zoneid]
    end

    local zoneTable = {};
    -- loop over all quests to populate a zone
    for qid, _ in pairs(QuestieDB.questData) do
        local quest = QuestieDB:GetQuest(qid);

        if quest and quest.Starts then
            if quest.Starts.NPC then
                local npc = QuestieDB:GetNPC(quest.Starts.NPC[1]);

                if npc and npc.spawns then
                    for zone, _ in pairs(npc.spawns) do
                        if zone == zoneid then
                            zoneTable[qid] = quest;
                        end
                    end
                end
            end

            if quest.Starts.GameObject then
                local obj = QuestieDB:GetObject(quest.Starts.GameObject[1]);

                if obj and obj.spawns then
                    for zone, _ in pairs(obj.spawns) do
                        if zone == zoneid then
                            zoneTable[qid] = quest;
                        end
                    end
                end
            end

        end
    end

    QuestieDB._ZoneCache[zoneid] = zoneTable;

    return zoneTable;

end

---------------------------------------------------------------------------------------------------
-- Returns the Levenshtein distance between the two given strings
-- credit to https://gist.github.com/Badgerati/3261142
function QuestieDB:Levenshtein(str1, str2)
    local len1 = string.len(str1)
    local len2 = string.len(str2)
    local matrix = {}
    local cost = 0
    -- quick cut-offs to save time
    if (len1 == 0) then
        return len2
    elseif (len2 == 0) then
        return len1
    elseif (str1 == str2) then
        return 0
    end
    -- initialise the base matrix values
    for i = 0, len1, 1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, len2, 1 do
        matrix[0][j] = j
    end
    -- actual Levenshtein algorithm
    for i = 1, len1, 1 do
        for j = 1, len2, 1 do
            if (string.byte(str1,i) == string.byte(str2,j)) then
                cost = 0
            else
                cost = 1
            end
            matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
        end
    end
    -- return the last value - this is the Levenshtein distance
    return matrix[len1][len2]
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
            table.insert(ret, true);
        else
            table.insert(ret, false);
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
            -- load corrections into QuestieDB.questData
            local correction = QuestieCorrections.questFixes[key]
            if correction and correction[questKeys.requiredClasses] then
                entry[questKeys.requiredClasses] = correction[questKeys.requiredClasses]
            end
            if correction and correction[questKeys.requiredRaces] then
                entry[questKeys.requiredRaces] = correction[questKeys.requiredRaces]
            end
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
