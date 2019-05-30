QuestieDB = {...}

function QuestieDB:Initialize()
  QuestieDBZone:zoneCreateConvertion()
  QuestieDB:deleteFaction()
  QuestieDB:deleteClasses()
  QuestieDB:deleteGatheringNodes()
end

function QuestieDB:ItemLookup(ItemId)
  itemName, itemLink = GetItemInfo(ItemId)
  Item = {}
  Item.Name = itemName
  Item.Link = itemLink
  return Item
end

QuestieDB._QuestCache = {}; -- stores quest objects so they dont need to be regenerated
QuestieDB._ItemCache = {};
QuestieDB._NPCCache = {};
QuestieDB._ObjectCache = {};
function QuestieDB:GetObject(ObjectID)
  if ObjectID == nil then
    return nil
  end
  if QuestieDB._ObjectCache[ObjectID] ~= nil then
    return QuestieDB._ObjectCache[ObjectID];
  end
  local raw = objData[ObjectID];
  if raw ~= nil then
    local obj = {};
    obj.Name = raw[1];
    obj.Spawns = raw[4];
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
  local item = {};
  local raw = CHANGEME_Questie4_ItemDB[ItemID]; -- TODO: use the good item db, I need to talk to Muehe about the format, this is a temporary fix
  if raw ~= nil then
    item.Id = ItemID;
    item.Name = raw[1];
    item.Sources = {};
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
local function _GetColoredQuestName(self)
    return QuestieTooltips:PrintDifficultyColor(self.Level, "[" .. self.Level .. "] " .. self.Name)
end
function QuestieDB:GetQuest(QuestID) -- /dump QuestieDB:GetQuest(867)
  if QuestID == nil then
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
  rawdata = qData[QuestID] -- shouldnt rawdata be local
  if(rawdata)then
    QO = {}
    QO.GetColoredQuestName = _GetColoredQuestName
    QO.Id = QuestID --Key
    QO.Name = rawdata[1] --Name - 1
    QO.Starts = {} --Starts - 2
    QO.Starts["NPC"] = rawdata[2][1] --2.1
    QO.Starts["GameObject"] = rawdata[2][2] --2.2
    QO.Starts["Item"] = rawdata[2][3] --2.3
    QO.Ends = {} --ends 3
    QO.Hidden = rawdata.hidden

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
              obj.Name = npcData[v]
              if obj.Name ~= nil then
                obj.Name = string.lower(obj.Name[1]);
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
              obj.Name = objData[v]
              if obj.Name ~= nil then
                obj.Name = string.lower(obj.Name[1]);
              end

              QO.Finisher = obj; -- there is only 1 finisher
            end
          --end
        --end
      end
    end



    QO.MinLevel = rawdata[4]
    QO.Level = rawdata[5]
    QO.RequiredRaces = rawdata[6]
    QO.RequiredClasses = rawdata[7]
    QO.ObjectiveText = rawdata[8]
    QO.Triggers = rawdata[9] --List of coordinates
    QO.ObjectiveData = {} -- to differentiate from the current quest log info
    --    type
    --String - could be the following things: "item", "object", "monster", "reputation", "log", or "event". (from wow api)

    if QO.Triggers ~= nil then
      for k,v in pairs(QO.Triggers) do
          local obj = {};
          obj.Type = "event"
          obj.Coordinates = v
          table.insert(QO.ObjectiveData, obj);
      end
    end

    if rawdata[10][1] ~= nil then
      for _k,_v in pairs(rawdata[10][1]) do
        if _v ~= nil then
          for k,v in pairs(_v) do
            if v ~= nil then
              local obj = {};
              obj.Type = "monster"
              obj.Id = v

              -- this speeds up lookup
              obj.Name = npcData[v]
              if obj.Name ~= nil then
                obj.Name = string.lower(obj.Name[1]);
              end

              table.insert(QO.ObjectiveData, obj);
            end
          end
        end
      end
    end
    if rawdata[10][2] ~= nil then
      for _k,_v in pairs(rawdata[10][2]) do
        if _v ~= nil then
          for k,v in pairs(_v) do
            if v ~= nil then
              local obj = {};
              obj.Type = "object"
              obj.Id = v

              obj.Name = objData[v]
              if obj.Name ~= nil then
                obj.Name = string.lower(obj.Name[1]);
              end

              table.insert(QO.ObjectiveData, obj);
            end
          end
        end
      end
    end
    if rawdata[10][3] ~= nil then
      for _k,_v in pairs(rawdata[10][3]) do
        if _v ~= nil then
          for k,v in pairs(_v) do
            if v ~= nil then
              local obj = {};
              obj.Type = "item"
              obj.Id = v

              obj.Name = CHANGEME_Questie4_ItemDB[v]
              if obj.Name ~= nil then
                obj.Name = string.lower(obj.Name[1]);
              end

              table.insert(QO.ObjectiveData, obj);
            end
          end
        end
      end
    end
    --QO.Objectives["NPC"] = rawdata[10][1] --{NPCID, Different name of NPC or object}
    --QO.Objectives["GameObject"] = rawdata[10][2] --{GOID, Different name of NPC or object}
    --QO.Objectives["Item"] = rawdata[10][3]
    --QO.SrcItemId = rawdata[11] --A quest item given by a questgiver of some kind.
    if(rawdata[12] ~= nil and rawdata[13] ~= nil) then
      Questie:Debug(DEBUG_CRITICAL, "ERRRRORRRRRRR not mutually exclusive!")
    end
    if(rawdata[12] ~= nil) then
      QO.RequiredQuest = rawdata[12]
    else
      QO.RequiredQuest = rawdata[13]
    end
    if questRequirementFixes[QuestID] ~= nil then
      QO.RequiredQuest = questRequirementFixes[QuestID]
    end
    QO.SubQuests = rawdata[14] --Quests that give questitems that are used in later quests (See STV manual)
    QO.QuestGroup = rawdata[15] --Quests that are part of the same group, example complete this group of quests to open the next one.
    QO.ExclusiveQuestGroup = questExclusiveGroupFixes[QuestID] or rawdata[16]
    QuestieDB._QuestCache[QuestID] = QO
    return QO
  else
    return nil
  end
end

function QuestieDB:GetNPC(NPCID)
  if NPCID == nil then
    return nil
  end
  --[key] = {1 Name,2 minHP,3 maxHP,4 minLevel,5 maxLevel,6 rank,7 spawns,8 waypoint,9 zone, 10 starts, 11 ends},

  if(QuestieDB._NPCCache[NPCID]) then
    return QuestieDB._NPCCache[NPCID]
  end
  rawdata = npcData[NPCID]
  if(rawdata)then
    NPC = {}
    NPC.Type = "NPC" --This can be used to look at which type it is, Gameobject and Items will have the same! (should be monster to match wow api)
    NPC.Id = NPCID
    NPC.Name = rawdata[DB_NAME]
    NPC.MinHealth = rawdata[DB_MIN_LEVEL_HEALTH]
    NPC.MaxHealth = rawdata[DB_MAX_LEVEL_HEALTH]
    NPC.MinLevel = rawdata[DB_MIN_LEVEL]
    NPC.MaxLevel = rawdata[DB_LEVEL]
    NPC.Rank = rawdata[DB_RANK]
    NPC.Spawns = rawdata[DB_NPC_SPAWNS]
    NPC.Waypoints = rawdata[DB_NPC_WAYPOINTS]
    NPC.Starts = rawdata[DB_NPC_STARTS]
    NPC.Ends = rawdata[DB_NPC_ENDS]
    QuestieDB._NPCCache[NPCID] = NPC
    return NPC
  else
    rawdata = Questie_SpecialNPCs[NPCID]
    if rawdata then
        NPC = {}
        NPC.Id = NPCID
        QuestieStreamLib:load(rawdata)
        NPC.Name = QuestieStreamLib:readTinyString()
        NPC.NewFormatSpawns = {}; -- spawns should be stored like this: {{x, y, uimapid}, ...} so im creating a 2nd var to aid with moving to the new format
        NPC.Spawns = {};
        local count = QuestieStreamLib:readByte()
        for i=1,count do
            local x = QuestieStreamLib:readShort() / 655.35
            local y = QuestieStreamLib:readShort() / 655.35
            local m = QuestieStreamLib:readByte() + 1400
            table.insert(NPC.NewFormatSpawns, {x, y, m});
            local om = m;
            m = zoneDataUiMapIDToAreaID[m];
            if m then
                if not NPC.Spawns[m] then
                    NPC.Spawns[m] = {};
                end
                table.insert(NPC.Spawns[m], {x, y});
            end
        end
        return NPC
    end
    return nil
  end
end
-- DB keys
DB_NAME, DB_NPC, NOTE_TITLE = 1, 1, 1;
DB_STARTS, DB_OBJ, NOTE_COMMENT, DB_MIN_LEVEL_HEALTH = 2, 2, 2, 2;
DB_ENDS, DB_ITM, NOTE_ICON, DB_MAX_LEVEL_HEALTH = 3, 3, 3, 3;
DB_MIN_LEVEL, DB_ZONES, DB_VENDOR, DB_OBJ_SPAWNS, DB_TRIGGER_MARKED = 4, 4, 4, 4, 4;
DB_LEVEL, DB_ITM_QUEST_REW = 5, 5;
DB_REQ_RACE, DB_RANK, DB_ITM_NAME = 6, 6, 6;
DB_REQ_CLASS, DB_NPC_SPAWNS = 7, 7;
DB_OBJECTIVES, DB_NPC_WAYPOINTS = 8, 8;
DB_TRIGGER, DB_ZONE = 9, 9;
DB_REQ_NPC_OR_OBJ_OR_ITM, DB_NPC_STARTS = 10, 10;
DB_SRC_ITM, DB_NPC_ENDS = 11, 11;
DB_PRE_QUEST_GROUP = 12;
DB_PRE_QUEST_SINGLE = 13;
DB_SUB_QUESTS = 14;
DB_QUEST_GROUP = 15;
DB_EXCLUSIVE_QUEST_GROUP = 16;


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
function QuestieDB:deleteGatheringNodes()
    local prune = { -- gathering nodes
        1617,1618,1619,1620,1621,1622,1623,1624,1628, -- herbs

        1731,1732,1733,1734,1735,123848,150082,175404,176643,177388,324,150079,176645,2040,123310 -- mining
    };
    for k,v in pairs(prune) do
        objData[v] = nil
    end
end

---------------------------------------------------------------------------------------------------
-- Modifications to questDB

--Deletes opposite factions quests, saves time!
function QuestieDB:deleteFaction()
    englishFaction, _ = UnitFactionGroup("player")
    local fac = ""
    if(englishFaction == "Alliance") then
      fac = "A"
    else
      fac = "H"
    end
    for key, data in pairs(qData) do
        if (data[DB_REQ_RACE] ~= "AH") and (data[DB_REQ_RACE] ~= fac) then
            qData[key] = nil;
        end
    end
    Questie:Debug(DEBUG_DEVELOP, "Opposite factions quests deleted");
end

ClassBitIndexTable = {
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

RaceBitIndexTable = {
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

function unpackBinary(val)
    ret = {};
    for q=0,16 do
        if bit.band(bit.rshift(val,q), 1) == 1 then
            table.insert(ret, true);
        else
            table.insert(ret, false);
        end
    end
    return ret;
end

function checkRace(race, dbRace)
    local valid = true;
    if race and dbRace and not (dbRace == 0) then
        local racemap = unpackBinary(dbRace);
        valid = racemap[RaceBitIndexTable[strlower(race)]];
    end
    return valid;
end

function checkClass(class, dbClass)
    local valid = true;
    if class and dbClass and valid and not (dbRace == 0)then
        local classmap = unpackBinary(dbClass);
        valid = classmap[ClassBitIndexTable[strlower(class)]];
    end
    return valid;
end

function QuestieDB:deleteClasses()
    localizedClass, englishClass, classIndex = UnitClass("player");
    localizedRace, playerRace = UnitRace("player");
    if englishClass and playerRace then
      local playerClass = string.lower(englishClass);
      playerRace = string.lower(playerRace);
      for key, data in pairs(qData) do
        local rpdata = Questie_RepProfData[key]; -- only strip race/class quests here
        if rpdata then
          if rpdata[2] ~= 0 then
              if not checkClass(playerClass, rpdata[2]) then
              qData[key].hidden = true--qData[key] = nil
            end
          end
          if rpdata[1] ~= 0 then
            if not checkRace(playerRace, rpdata[1]) then
              qData[key].hidden = true--qData[key] = nil
            end
          end
        end
      end
    end
    Questie:Debug(DEBUG_DEVELOP, "Other class quests deleted");
end
