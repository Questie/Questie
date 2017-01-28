---------------------------------------------------------------------------------------------------
-- Name: QuestieQuest
-- Description: Handles all the quest related functions
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
-- Global Vars
---------------------------------------------------------------------------------------------------
local QuestieQuestHashCache = {}
LastQuestLogHashes = nil;
LastQuestLogCount = 0;
LastCount = 0;
---------------------------------------------------------------------------------------------------
-- WoW Functions --PERFORMANCE CHANGE--
---------------------------------------------------------------------------------------------------
local QGet_QuestLogTitle = GetQuestLogTitle;
local QGet_NumQuestLeaderBoards = GetNumQuestLeaderBoards;
local QSelect_QuestLogEntry = SelectQuestLogEntry;
local QGet_QuestLogLeaderBoard = GetQuestLogLeaderBoard;
local QGet_QuestLogQuestText = GetQuestLogQuestText;
local QExpand_QuestHeader = ExpandQuestHeader;
---------------------------------------------------------------------------------------------------
-- Finishes a quest and performs a recrusive check to make sure all the required quests that come
-- before it are also finsihed and recorded in the players QuestieSeenQuests. It will also clear
-- any redundant quest tracking data and make sure a quest that is in a players log isn't
-- accidently marked finished. When ever this function is run it will also remove invalid tracker
-- data when it doesn't find a matching hash in the QuestieSeenQuests table. This sometimes
-- happens when a player starts a quest chain.
---------------------------------------------------------------------------------------------------
function Questie:finishAndRecurse(questhash)
    if (QuestieSeenQuests[questhash] == 1) then
        if (QuestieTrackedQuests[questhash]) then
            QuestieTrackedQuests[questhash] = nil;
        end
        return
    end
    if (QuestieSeenQuests[questhash] == 0) and (QuestieTrackedQuests[questhash]) then
        if ((QuestieTrackedQuests[questhash]["leaderboards"] == 0) or (QuestieTrackedQuests[questhash]["isComplete"] == 1)) then
            QuestieSeenQuests[questhash] = 1;
            QuestieTrackedQuests[questhash] = nil;
            if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
                TomTomCrazyArrow:Hide()
            end
        end
    elseif ((QuestieSeenQuests[questhash] == nil) or (QuestieTrackedQuests[questhash] == nil)) then
        QuestieSeenQuests[questhash] = 1;
        local req = nil;
        if QuestieHashMap[questhash] then
            req = QuestieHashMap[questhash]['rq'];
        end
        if req then
            Questie:finishAndRecurse(req);
        end
    end
    local index = 0
    for i,v in pairs(QuestieTrackedQuests) do
        if QuestieSeenQuests[i] ~= QuestieTrackedQuests[i] then
            QuestieTrackedQuests[i] = nil
        end
        index = index + 1
    end
end
---------------------------------------------------------------------------------------------------
-- Checks the players quest log to make sure the QuestieSeenQuests is accurate and adds or removes
-- any quests from the appropiate caches. This also updates quest tracking data.
---------------------------------------------------------------------------------------------------
function Questie:CheckQuestLog()
    local numEntries, numQuests = GetNumQuestLogEntries();
    if(LastCount == numEntries) then
    end
    LastCount = numEntries;
    local t = GetTime();
    if(not LastQuestLogHashes) then
        LastQuestLogHashes = Questie:AstroGetAllCurrentQuestHashesAsMeta();
        for k, v in pairs(LastQuestLogHashes) do
            Questie:AddQuestToMap(v["hash"]);
            if (not QuestieHashMap[v["hash"]]) then return end
            if(not QuestieSeenQuests[v["hash"]]) then
                local req = QuestieHashMap[v["hash"]]['rq'];
                if req then
                    Questie:finishAndRecurse(req)
                end
                QuestieSeenQuests[v["hash"]] = 0
                QuestieTracker:addQuestToTracker(v["hash"])
            end
        end
        QUESTIE_LAST_UPDATE_FINISHED = GetTime();
        return;
    end
    local Quests, QuestsCount = Questie:AstroGetAllCurrentQuestHashesAsMeta();
    MapChanged = false;
    delta = {};
    if (QuestsCount > LastQuestLogCount) then
        for k, v in pairs(Quests) do
            if(Quests[k] and LastQuestLogHashes[k]) then
            else
                if(Quests[k]) then
                    v["deltaType"] = 1;
                    table.insert(delta, v);
                else
                    v["deltaType"] = 0;
                    table.insert(delta, v);
                end
            end
        end
    else
        for k, v in pairs(LastQuestLogHashes) do
            if(Quests[k] and LastQuestLogHashes[k]) then
            else
                if(Quests[k]) then
                    v["deltaType"] = 1;
                    table.insert(delta, v);
                else
                    v["deltaType"] = 0;
                    table.insert(delta, v);
                end
            end
        end
    end
    for k, v in pairs(delta) do
        if(v["deltaType"] == 1) then
            Questie:AddQuestToMap(v["hash"]);
            if (not QuestieHashMap[v["hash"]]) then return end
            if(not QuestieSeenQuests[v["hash"]]) then
                local req = QuestieHashMap[v["hash"]]['rq'];
                if req then
                    Questie:finishAndRecurse(req)
                end
                QuestieSeenQuests[v["hash"]] = 0
                QuestieTracker:addQuestToTracker(v["hash"])
            end
            MapChanged = true;
        elseif not Questie.collapsedThisRun then
            Questie:RemoveQuestFromMap(v["hash"]);
            QuestieTracker:removeQuestFromTracker(v["hash"]);
            if(not QuestieCompletedQuestMessages[v["name"]]) then
                QuestieCompletedQuestMessages[v["name"]] = 0;
            end
            if (not QuestieHashMap[v["hash"]]) then return end
            if(not QuestieSeenQuests[v["hash"]]) then
                local req = QuestieHashMap[v["hash"]]['rq'];
                if req then
                    Questie:finishAndRecurse(req)
                end
                QuestieSeenQuests[v["hash"]] = 0
                QuestieTracker:addQuestToTracker(v["hash"])
            end
            -- This wipes an abandonded quest from both databases
            if(QuestieSeenQuests[v["hash"]] == -1) then
                QuestieTrackedQuests[v["hash"]] = nil
                QuestieSeenQuests[v["hash"]] = nil
            end
            if lastObjectives and lastObjectives[v["hash"]] then
                lastObjectives = nil;
            end
            MapChanged = true;
        end
    end
    newcheckArray = nil;
    checkArray = nil;
    BiggestTable = nil;
    delta = nil;
--[[
    if(MapChanged == true) then
        Questie:SetAvailableQuests();
        Questie:RedrawNotes();
    end
]]
    LastQuestLogHashes = Quests;
    LastQuestLogCount = QuestsCount;
    if(MapChanged == true) then
        LastQuestLogHashes = nil;
        LastCount = 0;
        Questie:CheckQuestLog();
        Questie:SetAvailableQuests()
        Questie:RedrawNotes();
        QUESTIE_LAST_UPDATE_FINISHED = GetTime();
        return true;
    else
        QUESTIE_LAST_UPDATE_FINISHED = GetTime();
        return nil;
    end
end
---------------------------------------------------------------------------------------------------
-- Forces an update on a quest
---------------------------------------------------------------------------------------------------
lastObjectives = nil;
function Questie:UpdateQuests(force)
    if(lastObjectives == nil) then
        lastObjectives = {};
        Questie:UpdateQuestsInit();
        return;
    end
    local ZonesChecked = 0;
    local t = GetTime();
    local CurrentZone = GetZoneText();
    local numEntries, numQuests = GetNumQuestLogEntries();
    local foundChange = false;
    local ZonesWithQuests = {};
    local change = Questie:UpdateQuestInZone(CurrentZone);
    local i=1;
    local qc=0;
    ZonesChecked = ZonesChecked+1;
    if(not change) then
        change = Questie:UpdateQuestInZone(GetMinimapZoneText());
        ZonesChecked = ZonesChecked+1;
    end
    if(not change or force) then
        while qc<numQuests do
            local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
            if(isHeader and q ~= CurrentZone) then
                local c = Questie:UpdateQuestInZone(q, force);
                ZonesChecked = ZonesChecked +1;
                change = c;
                if(c and not force)then
                    break;
                end
            end
            if not isHeader then
                qc=qc+1
            end
            i=i+1
        end
    else
    end
    return change;
end
---------------------------------------------------------------------------------------------------
-- Forces an update on a quest in a specific zone
---------------------------------------------------------------------------------------------------
function Questie:UpdateQuestInZone(Zone, force)
    local numEntries, numQuests = GetNumQuestLogEntries();
    local foundChange = nil;
    local ZoneFound = nil;
    local QuestsChecked = 0;
    local i=1;
    local qc=0;
    while qc<numQuests do
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if(ZoneFound and isHeader) then
            break;
        end
        if(isHeader and q == Zone) then
            ZoneFound = true;
        end
        if not isHeader and ZoneFound then
            QuestsChecked = QuestsChecked+1;
            QSelect_QuestLogEntry(i);
            local count =  QGet_NumQuestLeaderBoards();
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(q, level, objectiveText);
            if QuestieHashCache[q] == nil then QuestieHashCache[q] = {}; end
            QuestieHashCache[q][hash] = GetTime();
            if not lastObjectives[hash] then
                lastObjectives[hash] = {};
            end
            local Refresh = nil;
            for obj = 1, count do
                if (not lastObjectives[hash][obj]) then
                    lastObjectives[hash][obj] = {};
                end
                local desc, typ, done = QGet_QuestLogLeaderBoard(obj);
                if(lastObjectives[hash][obj].desc == desc and lastObjectives[hash][obj].typ == typ and lastObjectives[hash][obj].done == done) then
                elseif(lastObjectives[hash][obj].done ~= done) then
                    Refresh = true;
                    foundChange = true;
                else
                    foundChange = true;
                end
                lastObjectives[hash][obj].desc = desc;
                lastObjectives[hash][obj].typ = typ;
                lastObjectives[hash][obj].done = done;
            end
            if(Refresh) then
                Questie:AddQuestToMap(hash, true);
                if (QuestieTrackedQuests[hash]) then
                    QuestieTracker:updateFrameOnTracker(hash, i, level)
                end
                QuestieTracker:fillTrackingFrame()
                --DEFAULT_CHAT_FRAME:AddMessage("1: UpdateQuestInZone --> fillTrackingFrame")
            elseif foundChange and QuestieConfig.trackerEnabled == true then
                if (QuestieTrackedQuests[hash]) then
                    QuestieTracker:updateFrameOnTracker(hash, i, level)
                end
                QuestieTracker:fillTrackingFrame()
                --DEFAULT_CHAT_FRAME:AddMessage("2: UpdateQuestInZone --> fillTrackingFrame")
            end
        end
        if(foundChange and not force) then
            break;
        end
        if not isHeader then
            qc=qc+1
        end
        i=i+1
    end
    return foundChange;
end
---------------------------------------------------------------------------------------------------
-- Updates all quest objectives upon login or UI reload
---------------------------------------------------------------------------------------------------
function Questie:UpdateQuestsInit()
    local numEntries, numQuests = GetNumQuestLogEntries();
    local i=1;
    local qc=0;
    while qc<numQuests do
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if not isHeader then
            QSelect_QuestLogEntry(i);
            local count =  QGet_NumQuestLeaderBoards();
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(q, level, objectiveText);
            if not lastObjectives[hash] then
                lastObjectives[hash] = {};
            end
            for obj = 1, count do
                if (not lastObjectives[hash][obj]) then
                    lastObjectives[hash][obj] = {};
                end
                lastObjectives[hash][obj].desc = desc;
                lastObjectives[hash][obj].typ = typ;
                lastObjectives[hash][obj].done = done;
            end
            qc=qc+1
        end
        i=i+1
    end
end
---------------------------------------------------------------------------------------------------
-- Astrolabe functions
---------------------------------------------------------------------------------------------------
function Questie:AstroGetAllCurrentQuestHashes(print)
    local hashes = {};
    local numEntries, numQuests = GetNumQuestLogEntries();
    local i=1;
    local qc=0;
        if(print) then
            Questie:debug_Print("--Listing all current quests--");
        end
    while qc<numQuests do
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if not isHeader then
            QSelect_QuestLogEntry(i);
            local count =  QGet_NumQuestLeaderBoards();
            local questText, objectiveText = QGet_QuestLogQuestText();
            local quest = {};
            quest["name"] = q;
            quest["level"] = level;
            local hash = Questie:getQuestHash(q, level, objectiveText)
            quest["hash"] = hash;
            if(IsAddOnLoaded("URLCopy") and print)then
                Questie:debug_Print("        "..q,URLCopy_Link(quest["hash"]));
            elseif(print) then
                Questie:debug_Print("        "..q,quest["hash"]);
            end
            table.insert(hashes, quest);
            qc=qc+1
        else
            if(print) then
                Questie:debug_Print("    Zone:", q);
            end
        end
        i=i+1
    end
    if(print) then
        Questie:debug_Print("--End of all current quests--");
    end
    return hashes;
end
---------------------------------------------------------------------------------------------------
Questie.lastCollapsedCount = 0;
Questie.collapsedThisRun = false;
function Questie:AstroGetAllCurrentQuestHashesAsMeta(print)
    local startTime = GetTime();
    local hashes = {};
    local Count = 0;
    local numEntries, numQuests = GetNumQuestLogEntries();
    local collapsedCount = 0;
    local i=1;
    local qc=0;
    Questie.collapsedThisRun = false;
    while qc<numQuests do
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if isCollapsed then collapsedCount = collapsedCount + 1; end
        if not isHeader then
            QSelect_QuestLogEntry(i);
            local count =  QGet_NumQuestLeaderBoards();
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(q, level, objectiveText)
            hashes[hash] = {};
            hashes[hash]["hash"] = hash;
            hashes[hash]["name"] = q;
            hashes[hash]["level"] = level;
            if(IsAddOnLoaded("URLCopy") and print)then
                Questie:debug_Print("        "..q,URLCopy_Link(quest["hash"]));
            elseif(print) then
                Questie:debug_Print("        "..q,quest["hash"]);
            end
            qc=qc+1
        else
            if(print) then
                Questie:debug_Print("    Zone:", q);
            end
        end
        i=i+1
    end
    if(print) then
        Questie:debug_Print("--End of all current quests--");
    end
    if not (collapsedCount == Questie.lastCollapsedCount) then
        Questie.lastCollapsedCount = collapsedCount;
        Questie.collapsedThisRun = true;
    end
    Questie:debug_Print("[AllCurrentHashes] Getting all hashes took: ",(GetTime()-startTime)*1000, "ms");
    return hashes, numQuests;
end
---------------------------------------------------------------------------------------------------
function Questie:AstroGetFinishedQuests()
    numEntries, numQuests = GetNumQuestLogEntries();
    local FinishedQuests = {};
    local i=1;
    local qc=0;
    while qc<numQuests do
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if not isHeader then
            QSelect_QuestLogEntry(i);
            local count =  QGet_NumQuestLeaderBoards();
            local questText, objectiveText = QGet_QuestLogQuestText();
            Done = true;
            for obj = 1, count do
                local desc, typ, done = QGet_QuestLogLeaderBoard(obj);
                if not done then
                    Done = nil;
                end
            end
            if(Done) then
                local hash = Questie:getQuestHash(q, level, objectiveText);
                Questie:debug_Print("[AstroGetFinishedQuests] Finished returned:", hash, q ,level);
                table.insert(FinishedQuests, hash);
            end
            qc=qc+1
        end
        i=i+1
    end
    return FinishedQuests;
end
---------------------------------------------------------------------------------------------------
function Questie:AstroGetQuestObjectives(questHash)
    QuestLogID = Questie:GetQuestIdFromHash(questHash);
    local mapid = GetCurrentMapID();
    local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(QuestLogID);
    QSelect_QuestLogEntry(QuestLogID);
    local count =  QGet_NumQuestLeaderBoards();
    local questText, objectiveText = QGet_QuestLogQuestText();
    local AllObjectives = {};
    AllObjectives["QuestName"] = q;
    AllObjectives["objectives"] = {};
    for i = 1, count do
        local desc, typ, done = QGet_QuestLogLeaderBoard(i);
        local typeFunction = AstroobjectiveProcessors[typ];
        if typ == "item" or typ == "monster" or not (typeFunction == nil) then
            local indx = findLast(desc, ":");
            local countless = indx == nil;
            local countstr = "";
            local namestr = desc;
            if not countless then
                countstr = string.sub(desc, indx+2);
                namestr = string.sub(desc, 1, indx-1);
            end
            local objectives = typeFunction(q, namestr, countstr, selected, mapid);
            Objective = {};
            local hash = Questie:getQuestHash(q, level, objectiveText);
            for k, v in pairs(objectives) do
                if (AllObjectives["objectives"][v["name"]] == nil) then
                    AllObjectives["objectives"][v["name"]] = {};
                end
                if(not QuestieCachedMonstersAndObjects[hash]) then
                    QuestieCachedMonstersAndObjects[hash] = {};
                end
                if(not QuestieCachedMonstersAndObjects[hash][v["name"]]) then
                    QuestieCachedMonstersAndObjects[hash][v["name"]] = {};
                end
                QuestieCachedMonstersAndObjects[hash][v["name"]].name = v["name"];
                for monster, info in pairs(v['locations']) do
                    local obj = {};
                    obj["mapid"] = info[1];
                    obj["x"] = info[2];
                    obj["y"] = info[3];
                    obj["lootname"] = v["lootname"];
                    obj["type"] = v["type"];
                    obj["done"] = done;
                    obj['objectiveid'] = i;
                    table.insert(AllObjectives["objectives"][v["name"]], obj);
                end
            end
        else
        end
    end
    return AllObjectives;
end
---------------------------------------------------------------------------------------------------
AstroobjectiveProcessors = {
    ['item'] = function(quest, name, amount, selected, mapid)
        local list = {};
        local itemdata = QuestieItems[name];
        Questie:debug_Print(name);
        if itemdata == nil then
            Questie:debug_Print("[AstroobjectiveProcessors] ERROR1 PROCESSING '" .. quest .. "''  objective:'" .. name .. "'' no itemdata".. " ID:0");
            itemdata = QuestieItems[name];
        end
        if itemdata then
            for k,v in pairs(itemdata) do
                if k == "locationCount" then
                    local monster = {};
                    monster["name"] = name;
                    monster["locations"] = {};
                    monster["type"] = "loot";
                    for b=1,itemdata['locationCount'] do
                        local loc = itemdata['locations'][b];
                        table.insert(monster["locations"], loc);
                    end
                    table.insert(list, monster);
                elseif k == "drop" then
                    for e,r in pairs(v) do
                        local monster = {};
                        monster["name"] = name;
                        monster["lootname"] = e;
                        monster["locations"] = {};
                        monster["type"] = "loot";
                        for k, pos in pairs(QuestieMonsters[e]['locations']) do
                            table.insert(monster["locations"], pos);
                        end
                        table.insert(list, monster)
                    end
                elseif k =="locations" then
                else
                    Questie:debug_Print("[AstroobjectiveProcessors] ERROR2 " .. quest .. "  objective:" .. name.. " ID:1");
                    for s, r in pairs(itemdata) do
                        Questie:debug_Print(s,tostring(r));
                    end
                end
            end
        end
        return list;
    end,
    ['event'] = function(quest, name, amount, selected, mapid)
        local evtdata = QuestieEvents[name]
        local list = {};
        if evtdata == nil then
            Questie:debug_Print("[AstroobjectiveProcessors] ERROR3 UNKNOWN EVENT " .. quest .. "  objective:" .. name.. " ID:2");
        else
            for b=1,evtdata['locationCount'] do
                local monster = {};
                monster["name"] = name;
                monster["locations"] = {};
                monster["type"] = "event";
                for b=1,evtdata['locationCount'] do
                    local loc = evtdata['locations'][b];
                    table.insert(monster["locations"], loc);
                end
                table.insert(list, monster);
            end
        end
        return list;
    end,
    ['monster'] = function(quest, name, amount, selected, mapid)
        local list = {};
        local monster = {};
        if(string.find(name, " slain")) then
            monster["name"] = name;
        else
            monster["name"] = string.sub(name, string.len(name)-6);
        end
        monster["type"] = "slay";
        monster["locations"] = {};
        if(QuestieMonsters[name] and QuestieMonsters[name]['locations']) then
            for k, pos in pairs(QuestieMonsters[name]['locations']) do
                table.insert(monster["locations"], pos);
            end
        end
        table.insert(list, monster);
        return list;
    end,
    ['object'] = function(quest, name, amount, selected, mapid)
        local list = {};
        local objdata = QuestieObjects[name];
        if objdata == nil then
            Questie:debug_Print("[AstroobjectiveProcessors] ERROR4 UNKNOWN OBJECT " .. quest .. "  objective:" .. name);
        else
            for b=1,objdata['locationCount'] do
                local monster = {};
                monster["name"] = name;
                monster["locations"] = {};
                monster["type"] = "object";
                for b=1,objdata['locationCount'] do
                    local loc = objdata['locations'][b];
                    table.insert(monster["locations"], loc);
                end
                table.insert(list, monster);
            end
        end
        return list;
    end
}
---------------------------------------------------------------------------------------------------
-- End of Astrolabe functions
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Get quest ID from quest hash
---------------------------------------------------------------------------------------------------
LastNrOfEntries = 0;
CachedIds = {};
function Questie:GetQuestIdFromHash(questHash)
    local numEntries, numQuests = GetNumQuestLogEntries();
    if(QUESTIE_UPDATE_EVENT or numEntries ~= LastNrOfEntries or not CachedIds[questHash]) then
        CachedIds[questHash] = {};
        QUESTIE_UPDATE_EVENT=0;
        LastNrOfEntries = numEntries;
        Questie:UpdateQuestIds();
        if CachedIds[questHash] then
            return CachedIds[questHash];
        end
    else
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(CachedIds[questHash]);
        QSelect_QuestLogEntry(CachedIds[questHash]);
        local questText, objectiveText = QGet_QuestLogQuestText();
        if(q and level and objectiveText) then
            if(Questie:getQuestHash(q, level, objectiveText) == questHash) then
                return CachedIds[questHash];
            else
                Questie:debug_Print("[GetQuestIdFromHash] Something went wrong Error1");
            end
        else
            Questie:debug_Print("[GetQuestIdFromHash] Something went wrong, Error2", tostring(CachedIds[questHash]), tostring(q), tostring(level));
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Update quest ID's
---------------------------------------------------------------------------------------------------
function Questie:UpdateQuestIds()
    local startTime = GetTime()
    local numEntries, numQuests = GetNumQuestLogEntries();
    local i=1;
    local qc=0;
    while qc<numQuests do
        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if not isHeader then
            QSelect_QuestLogEntry(i);
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(q, level, objectiveText);
            if(not q or not level or not objective) then
                Questie:debug_Print("[UpdateQuestID] ERROR!!!!  Error1",tostring(name), tostring(level), tostring(i), tostring(hash))
            end
            CachedIds[hash] = i;
            qc=qc+1
        end
        i=i+1
    end
    Questie:debug_Print("[UpdateQuestID] Had to update UpdateQuestIds",(GetTime() - startTime)*1000,"ms")
end
QuestieHashCache = {};
---------------------------------------------------------------------------------------------------
-- Get quest hash from quest name
---------------------------------------------------------------------------------------------------
function Questie:GetHashFromName(name)
    if QuestieHashCache[name] then
        local hashtable = QuestieHashCache[name];
        local bestValue = 0;
        local bestHash = -1;
        for k,v in pairs(hashtable) do
            if v > bestValue then
                bestValue = v;
                bestHash = k;
            end
        end
        if not (bestHash == -1) then return bestHash; end
    end
    return Questie:getQuestHash(name, nil, nil);
end
---------------------------------------------------------------------------------------------------
-- Lookup quest hash from name, level or objective text
---------------------------------------------------------------------------------------------------
function Questie:getQuestHash(name, level, objectiveText)
    local hashLevel = level or "hashLevel"
    local hashText = objectiveText or "hashText"
    if QuestieQuestHashCache[name..hashLevel..hashText] then
        return QuestieQuestHashCache[name..hashLevel..hashText]
    end
    local questLookup = QuestieLevLookup[name];
    local hasOthers = false;
    if questLookup then
        local count = 0;
        local retval = 0;
        local bestDistance = 4294967295; -- some high number (0xFFFFFFFF)
        local race = UnitRace("Player");
        for k,v in pairs(questLookup) do
            local rr = v[1];
            if checkRequirements(null, race, null, rr) or true then
                if count == 1 then
                    hasOthers = true;
                end
                if k == objectiveText then
                    QuestieQuestHashCache[name..hashLevel..hashText] = v[2];
                    return v[2],hasOthers; -- exact match
                end
                local dist = 4294967294;
                if not (objectiveText == nil) then
                    dist = Questie:Levenshtein(objectiveText, k);
                end
                if dist < bestDistance then
                    bestDistance = dist;
                    retval = v[2];
                end
            else
            end
            count = count + 1;
        end
        if not (retval == 0) then
            QuestieQuestHashCache[name..hashLevel..hashText] = retval;
            return retval, hasOthers; -- nearest match
        end
    end
    if name == nil then
        return -1;
    end
    local hash = Questie:MixString(0, name);
    if not (level == nil) then
        hash = Questie:MixInt(hash, level);
        QuestieQuestHashCache[name..hashLevel..hashText] = hash;
    end
    if not (objectiveText == nil) then
        hash = Questie:MixString(hash, objectiveText);
        QuestieQuestHashCache[name..hashLevel..hashText] = hash;
    end
    QuestieQuestHashCache[name..hashLevel..hashText] = hash;
    return hash, false;
end
---------------------------------------------------------------------------------------------------
-- Checks to see if a quest is finished by quest hash
---------------------------------------------------------------------------------------------------
function Questie:IsQuestFinished(questHash)
    local i = Questie:GetQuestIdFromHash(questHash);
    if (not i) then
        return false;
    end
    local FinishedQuests = {};
    local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
    QSelect_QuestLogEntry(i);
    local count =  QGet_NumQuestLeaderBoards();
    local questText, objectiveText = QGet_QuestLogQuestText();
    Done = true;
    for obj = 1, count do
        local desc, typ, done = QGet_QuestLogLeaderBoard(obj);
        if not done then
            Done = nil;
        end
    end
    if(Done and Questie:getQuestHash(q, level, objectiveText) == questHash) then
        local ret = {};
        ret["questHash"] = questHash;
        ret["name"] = q;
        ret["level"] = level;
        return ret;
    end
    return nil;
end
---------------------------------------------------------------------------------------------------
-- Race, Class and Profession filter functions
---------------------------------------------------------------------------------------------------
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
}
---------------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------------
function checkRequirements(class, race, dbClass, dbRace)
    local valid = true;
    if race and dbRace and not (dbRace == 0) then
        local racemap = unpackBinary(dbRace);
        valid = racemap[RaceBitIndexTable[strlower(race)]];
    end
    if class and dbClass and valid and not (dbRace == 0)then
        local classmap = unpackBinary(dbClass);
        valid = classmap[ClassBitIndexTable[strlower(class)]];
    end
    return valid;
end
---------------------------------------------------------------------------------------------------
function Questie:GetAvailableQuestHashes(mapFileName, levelFrom, levelTo)
    local mapid =  -1
    if(QuestieZones[mapFileName]) then
        mapid = QuestieZones[mapFileName][1];
    end
    local class = UnitClass("Player");
    local race = UnitRace("Player");
    local hashes = {};
    for l=levelFrom,levelTo do
        if QuestieZoneLevelMap[mapid] then
            local content = QuestieZoneLevelMap[mapid][l];
            if content then
                for k,v in pairs(content) do
                    local qdata = QuestieHashMap[v];
                    if(qdata) then
                        local requiredQuest = qdata['rq'];
                        local requiredRaces = qdata['rr'];
                        local requiredClasses = qdata['rc'];
                        local requiredSkill = qdata['rs'];
                        local valid = not QuestieSeenQuests[requiredQuest];
                        if(requiredQuest) then valid = QuestieSeenQuests[requiredQuest]; end
                        valid = valid and (requiredSkill == nil or QuestieConfig.showProfessionQuests);
                        if valid then valid = valid and checkRequirements(class, race, requiredClasses,requiredRaces); end
                        if valid and not QuestieHandledQuests[requiredQuest] and not QuestieSeenQuests[v] then
                            table.insert(hashes, v);
                        end
                    end
                end
            end
        end
    end
    return hashes;
end
---------------------------------------------------------------------------------------------------
-- End of filter functions
---------------------------------------------------------------------------------------------------
