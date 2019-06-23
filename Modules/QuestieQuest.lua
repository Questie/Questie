QuestieQuest = {...}
local _QuestieQuest = {...}


qAvailableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

qCurrentQuestlog = {} --Gets populated by QuestieQuest:GetAllQuestIds(), this is either an object to the quest in question, or the ID if the object doesn't exist.

function QuestieQuest:Initialize()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST_COMP'))
    GetQuestsCompleted(Questie.db.char.complete)
end

QuestieQuest.NotesHidden = false

function QuestieQuest:ToggleNotes(desiredValue)
    if desiredValue ~= nil and desiredValue == (not QuestieQuest.NotesHidden) then
        return -- we already have the desired state
    end
    if QuestieQuest.NotesHidden then
        Questie_Toggle:SetText(QuestieLocale:GetUIString('QUESTIE_MAP_BUTTON_HIDE'));
        for questId, framelist in pairs(qQuestIdFrames) do
            for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                local icon = _G[frameName];
                if icon ~= nil and icon.hidden then
                    icon.hidden = false
                    icon.Show = icon._show;
                    icon.Hide = icon._hide;
                    icon._show = nil
                    icon._hide = nil
                    if icon.shouldBeShowing then
                        icon:Show();
                    end
                end
            end
        end
    else
        Questie_Toggle:SetText(QuestieLocale:GetUIString('QUESTIE_MAP_BUTTON_SHOW'));
        for questId, framelist in pairs(qQuestIdFrames) do
            for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                local icon = _G[frameName];
                if icon ~= nil and icon.IsShown ~= nil and (not icon.hidden) then -- check for function to make sure its a frame
                    icon.shouldBeShowing = icon:IsShown();
                    icon._show = icon.Show;
                    icon.Show = function()
                        icon.shouldBeShowing = true;
                    end
                    icon:Hide();
                    icon._hide = icon.Hide;
                    icon.Hide = function()
                        icon.shouldBeShowing = false;
                    end
                    icon.hidden = true
                end
            end
        end
    end
    QuestieQuest.NotesHidden = not QuestieQuest.NotesHidden
    Questie.db.char.enabled = not QuestieQuest.NotesHidden
end

function QuestieQuest:GetRawLeaderBoardDetails(QuestLogIndex)
    local quest = {}
    title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(QuestLogIndex)
    quest.title = title;
    quest.level = level;
    quest.isComplete = isComplete;
    local old = GetQuestLogSelection()
    SelectQuestLogEntry(QuestLogIndex);
    local numQuestLogLeaderBoards = GetNumQuestLeaderBoards()

    quest.Objectives = {}
    quest.compareString = ""
    for BoardIndex = 1, numQuestLogLeaderBoards do
        local description, objectiveType, isCompleted = GetQuestLogLeaderBoard(BoardIndex, QuestLogIndex);
        quest.Objectives[BoardIndex] = {}
        quest.Objectives[BoardIndex].description = description;
        quest.Objectives[BoardIndex].objectiveType = objectiveType;
        quest.Objectives[BoardIndex].isCompleted = isCompleted;
        quest.compareString = quest.compareString
        if quest.compareString and description then
            quest.compareString = quest.compareString .. description
        end
        if quest.compareString and objectiveType then
            quest.compareString = quest.compareString .. objectiveType
        end
        if quest.compareString then
            if isCompleted then
                quest.compareString = quest.compareString .."true";
            else
                quest.compareString = quest.compareString .."false";
            end
        end
        --quest.compareString = string.format("%s%s%s%s", quest.compareString, description, objectiveType, isCompleted);
    end
    quest.Id = questId
    if old then SelectQuestLogEntry(old); end
    return quest;
end

-- some plebs dont have beta, i need diz
function LOGONDEBUG_ADDQUEST(QuestId)
    --qCurrentQuestlog[QuestId] = QuestieDB:GetQuest(QuestId);
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ADD_QUEST', QuestId, qCurrentQuestlog[QuestId]));
    QuestieQuest:AcceptQuest(QuestId);
    --QuestieQuest:TrackQuest(QuestId)
end

function LOGONDEBUG_REMOVEQUEST(QuestId)
    QuestieQuest:AbandonedQuest(QuestId);
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_REMOVE_QUEST', QuestId, qCurrentQuestlog[QuestId]));
end

--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
--Use -> QuestieQuest:GetAllQuestObjectives(QuestId)
--170
function QuestieQuest:TrackQuest(QuestId)--Should probably be called from some kind of questlog or similar, will have to wait untill classic to find out how tracking really works...
    Quest = qCurrentQuestlog[QuestId]
    --Quest = QuestieDB:GetQuest(QuestId)

    ObjectiveID = 0
    if type(Quest) == "table" then
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]:", QuestId)
        if(Quest.Objectives["NPC"] ~= nil) then
            for index, ObjectiveData in pairs(Quest.Objectives["NPC"]) do
                for _, NPCID in pairs(ObjectiveData) do
                    NPC = QuestieDB:GetNPC(NPCID)
                    for Zone, Spawns in pairs(NPC.Spawns) do
                        for _, coords in ipairs(Spawns) do
                            Questie:Debug(DEBUG_INFO, "[QuestieQuest]:", Zone, coords[1], coords[2])
                            data = {}
                            data.Id = QuestId;
                            data.Icon = ICON_TYPE_SLAY
                            data.ObjectiveId = ObjectiveID
                            data.NpcData = NPC;
                            data.tooltip = {NPC.Name}
                            --data.QuestData = Quest;
                            QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                        end
                    end
                end
                ObjectiveID = ObjectiveID + 1
            end
        end--
    end
end

function QuestieQuest:AcceptQuest(questId)
    --Get all the Frames for the quest and unload them, the available quest icon for example.
    QuestieMap:UnloadQuestFrames(questId);

    Quest = QuestieDB:GetQuest(questId)
    if(Quest ~= nil) then
        -- we also need to remove exclusivegroup icons (TESTED)
        if Quest.ExclusiveQuestGroup then
            for k, v in pairs(Quest.ExclusiveQuestGroup) do
                QuestieMap:UnloadQuestFrames(v);
            end
        end

        --Reset the clustering for the map
        QuestieMap.MapCache_ClutterFix = {};
        QuestieQuest:PopulateQuestLogInfo(Quest)
        QuestieQuest:PopulateObjectiveNotes(Quest)
        qCurrentQuestlog[questId] = Quest
    else
        qCurrentQuestlog[questId] = questId
    end


    --TODO: Insert call to drawing objective logic here!
    --QuestieQuest:TrackQuest(questId);

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ACCEPT_QUEST', questId));

end

function QuestieQuest:CompleteQuest(QuestId)
    qCurrentQuestlog[QuestId] = nil;
    Questie.db.char.complete[QuestId] = true --can we use some other relevant info here?
    QuestieMap:UnloadQuestFrames(QuestId);
    QuestieTooltips:RemoveQuest(QuestId)
    --Unload all the quest frames from the map.
    --QuestieMap:UnloadQuestFrames(QuestId); --We are currently redrawing everything so we might as well not use this now

    --TODO: This can probably be done better?
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests();

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_COMPLETE_QUEST', QuestId));
end

function QuestieQuest:AbandonedQuest(QuestId)
    QuestieTooltips:RemoveQuest(QuestId)
    if(qCurrentQuestlog[QuestId]) then
        qCurrentQuestlog[QuestId] = nil

        --Unload all the quest frames from the map.
        QuestieMap:UnloadQuestFrames(QuestId);

        local quest = QuestieDB:GetQuest(QuestId);
        quest.Objectives = nil;
        quest.AlreadySpawned = nil; -- temporary fix for "special objectives" remove later
        --The old data for notes are still there, we don't need to recalulate data.
        _QuestieQuest:DrawAvailableQuest(quest)

        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ABANDON_QUEST', QuestId));
    end
end

function QuestieQuest:UpdateQuest(QuestId)
    local quest = QuestieDB:GetQuest(QuestId);
    if quest ~= nil then
        QuestieQuest:PopulateQuestLogInfo(quest)
        QuestieQuest:GetAllQuestObjectives(quest) -- update quest log values in quest object
        QuestieQuest:UpdateObjectiveNotes(quest)
        if QuestieQuest:IsComplete(quest) then
            --DEFAULT_CHAT_FRAME:AddMessage("Finished " .. QuestId);
            QuestieMap:UnloadQuestFrames(QuestId);
            QuestieQuest:AddFinisher(quest)
            return
        else
            --DEFAULT_CHAT_FRAME:AddMessage("Still not finished " .. QuestId);
        end
    end
end
--Run this if you want to update the entire table
function QuestieQuest:GetAllQuestIds()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST'));
    numEntries, numQuests = GetNumQuestLogEntries();
    qCurrentQuestlog = {}
    for index = 1, numEntries do
        title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if(not isHeader) then
            --Keep the object in the questlog to save searching
            Quest = QuestieDB:GetQuest(questId)
            if(Quest ~= nil) then
                QuestieQuest:PopulateQuestLogInfo(Quest)
                QuestieQuest:PopulateObjectiveNotes(Quest)
                qCurrentQuestlog[questId] = Quest
                if title and strlen(title) > 1 then
                    Quest.LocalizedName = title
                end
            else
                qCurrentQuestlog[questId] = questId
            end
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ADD_QUEST', questId, qCurrentQuestlog[questId]));
        end
    end
end

function QuestieQuest:GetAllQuestIdsNoObjectives()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST'));
    numEntries, numQuests = GetNumQuestLogEntries();
    qCurrentQuestlog = {}
    for index = 1, numEntries do
        title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if(not isHeader) then
            --Keep the object in the questlog to save searching
            Quest = QuestieDB:GetQuest(questId)
            if(Quest ~= nil) then
                qCurrentQuestlog[questId] = Quest
            else
                qCurrentQuestlog[questId] = questId
            end
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ADD_QUEST', questId, qCurrentQuestlog[questId]));
        end
    end
end

function QuestieQuest:ShouldQuestShowObjectives(QuestId)
    return true -- todo: implement tracker logic here, to hide non-tracked quest optionally (1.12 questie does this optionally)
end


local function counthack(tab) -- according to stack overflow, # and table.getn arent reliable (I've experienced this? not sure whats up)
    local count = 0
    for k, v in pairs(tab) do count = count + 1; end
    return count
end

function QuestieQuest:_IsCompleteHack(Quest) -- adding this because I hit my threshold of 3 hours trying to debug why .isComplete isnt working properly-- we can fix this later
    local logID = GetQuestLogIndexByID(Quest.Id);
    if logID ~= 0 then
        _, _, _, _, _, Quest.isComplete, _, _, _, _, _, _, _, _, _, Quest.isHidden = GetQuestLogTitle(logID)
        if Quest.isComplete and Quest.isComplete == 1 then
            return true;
        end
    end
end

function QuestieQuest:IsComplete(Quest)
    return Quest.Objectives == nil or counthack(Quest.Objectives) == 0 or Quest.isComplete or QuestieQuest:_IsCompleteHack(Quest);
end
-- iterate all notes, update / remove as needed
function QuestieQuest:UpdateObjectiveNotes(Quest)
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes:", Quest.Id)
    if Quest.Objectives then
        for k, v in pairs(Quest.Objectives) do
            result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, k, v);
            if not result then
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_POP_ERROR', Quest.Name, Quest.Id, k, err));
            end
        end
    end
end
function QuestieQuest:AddFinisher(Quest)
    NPC = nil
    if Quest.Finisher ~= nil then
        if Quest.Finisher.Type == "monster" then
            NPC = QuestieDB:GetNPC(Quest.Finisher.Id)
        elseif Quest.Finisher.Type == "object" then
            NPC = QuestieDB:GetObject(Quest.Finisher.Id)
        else
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_UNHANDLE_FINISH', Quest.Finisher.Type, Quest.Id, Quest.Name))
        end
    else
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_NO_FINISH', Quest.Id, Quest.Name))
    end
    --NPC = QuestieDB:GetNPC(Quest.Finisher)
    if(NPC ~= nil and NPC.Spawns ~= nil) then
        --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
        for Zone, Spawns in pairs(NPC.Spawns) do
            if(Zone ~= nil and Spawns ~= nil) then
                --Questie:Debug("Zone", Zone)
                --Questie:Debug("Qid:", questid)
                for _, coords in ipairs(Spawns) do
                    --Questie:Debug("Coords", coords[1], coords[2])
                    local data = {}
                    data.Id = Quest.Id;
                    data.Icon = ICON_TYPE_COMPLETE;
                    data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                    data.IconScale = data:GetIconScale();
                    data.Type = "complete";
                    data.QuestData = Quest;
                    data.Name = NPC.Name
                    data.IsObjectiveNote = false
                    --data.updateTooltip = function(data)
                    --return {QuestieTooltips:PrintDifficultyColor(data.QuestData.Level, "[" .. data.QuestData.Level .. "] " .. data.QuestData.Name), "|cFFFFFFFFQuest complete!", "Finished by: |cFF00FF00" .. data.QuestData.NPCName}
                    --end
                    --data.tooltip = data.updateTooltip(data)

                    --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn1", v.Id, NPC.Name )
                    if(coords[1] == -1 or coords[2] == -1) then
                        if(instanceData[Zone] ~= nil) then
                            for index, value in ipairs(instanceData[Zone]) do
                                --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                                --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn3", value[1], value[2], value[3])
                                QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                            end
                        end
                    else
                        --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
                        --HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
                        --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: AddSpawn2", Zone, coords[1], coords[2])
                        QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                    end
                end
            end
        end
    end
end


ObjectiveSpawnListCallTable = {
    ["monster"] = function(id, Objective)
        local npcData = QuestieDB:GetNPC(id)
        if not npcData then
            -- todo: log this
            return nil
        end
        local ret = {}
        local mon = {};

        mon.Name = npcData.Name
        mon.Spawns = npcData.Spawns
        mon.Icon = ICON_TYPE_SLAY
        mon.Id = id
        mon.GetIconScale = function() return Questie.db.global.monsterScale or 1 end
        mon.IconScale = mon:GetIconScale();
        mon.TooltipKey = "u_" .. npcData.Name -- todo: use ID based keys

        ret[id] = mon;
        return ret
    end,
    ["object"] = function(id, Objective)
        local objData = QuestieDB:GetObject(id)
        if not objData then
            -- todo: log this
            return nil
        end
        local ret = {}
        local obj = {}

        obj.Name = objData.Name
        obj.Spawns = objData.Spawns
        obj.Icon = ICON_TYPE_LOOT
        obj.GetIconScale = function() return Questie.db.global.objectScale or 1 end
        obj.IconScale = obj:GetIconScale()
        obj.TooltipKey = "o_" .. objData.Name
        obj.Id = id

        ret[id] = obj
        return ret
    end,
    ["event"] = function(id, Objective)
        local ret = {}
        ret[1] = {};
        ret[1].Name = Objective.Description or "Event Trigger";
        ret[1].Icon = ICON_TYPE_EVENT
        ret[1].GetIconScale = function() return Questie.db.global.eventScale or 1.35 end
        ret[1].IconScale = ret[1]:GetIconScale();
        ret[1].Id = id or 0
        if Objective.Coordinates then
            ret[1].Spawns = Objective.Coordinates
        elseif Objective.Description then-- we need to fall back to old questie data, some events are missing in the new DB
            ret[1].Spawns = {}
            local questie2data = TEMP_Questie2Events[Objective.Description];
            if questie2data and questie2data["locations"] then
                for i, spawn in pairs(questie2data["locations"]) do
                    local zid = Questie2ZoneTableInverse[spawn[1]];
                    if zid then
                        zid = zoneDataUiMapIDToAreaID[zid]
                        if zid then
                            if not ret[1].Spawns[zid] then
                                ret[1].Spawns[zid] = {};
                            end
                            local x = spawn[2] * 100;
                            local y = spawn[3] * 100;
                            table.insert(ret[1].Spawns[zid], {x, y});
                        end
                    end
                end
            end
        end
        return ret
    end,
    ["item"] = function(id, Objective)
        local ret = {};
        local item = QuestieDB:GetItem(id);
        if item ~= nil and item.Sources ~= nil then
            for _, source in pairs(item.Sources) do
                if ObjectiveSpawnListCallTable[source.Type] and source.Type ~= "item" then -- anti-recursive-loop check, should never be possible but would be bad if it was
                    local sourceList = ObjectiveSpawnListCallTable[source.Type](source.Id, Objective);
                    if sourceList == nil then
                        -- log this
                    else
                        for id, sourceData in pairs(sourceList) do
                            if not ret[id] then
                                ret[id] = {};
                                ret[id].Name = sourceData.Name;
                                ret[id].Spawns = {};
                                if source.Type == "object" then
                                    ret[id].Icon = ICON_TYPE_OBJECT
                                    ret[id].GetIconScale = function() return Questie.db.global.objectScale or 1 end
                                    ret[id].IconScale = ret[id]:GetIconScale()
                                else
                                    ret[id].Icon = ICON_TYPE_LOOT
                                    ret[id].GetIconScale = function() return Questie.db.global.lootScale or 1 end
                                    ret[id].IconScale = ret[id]:GetIconScale()
                                end
                                ret[id].TooltipKey = sourceData.TooltipKey
                                ret[id].Id = id
                            end
                            if sourceData.Spawns then
                                for zone, spawns in pairs(sourceData.Spawns) do
                                    if not ret[id].Spawns[zone] then
                                        ret[id].Spawns[zone] = {};
                                    end
                                    for _, spawn in pairs(spawns) do
                                        table.insert(ret[id].Spawns[zone], spawn);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return ret
    end
}

function QuestieQuest:PopulateObjective(Quest, ObjectiveIndex, Objective, BlockItemTooltips) -- must be pcalled

    if not Objective.AlreadySpawned then
        Objective.AlreadySpawned = {};
    end

    -- temporary fix for "special objectives" to not double-spawn (we need to fix the objective detection logic)
    if not Quest.AlreadySpawned then
        Quest.AlreadySpawned = {};
    end

    if ObjectiveSpawnListCallTable[Objective.Type] and (not Objective.spawnList) then
        Objective.spawnList = ObjectiveSpawnListCallTable[Objective.Type](Objective.Id, Objective);
    end
    local maxPerType = 100
    local maxPerObjectiveOutsideZone = 100

    Objective:Update() -- update qlog data
    local completed = Objective.Completed
	
    if not Objective.Color then -- todo: move to a better place
        QuestieQuest:math_randomseed(Quest.Id + 32768 * ObjectiveIndex)
        Objective.Color = {0.45 + QuestieQuest:math_random() / 2, 0.45 + QuestieQuest:math_random() / 2, 0.45 + QuestieQuest:math_random() / 2}
    end

    if (not Objective.registeredItemTooltips) and Objective.Type == "item" and (not BlockItemTooltips) and Objective.Id then -- register item tooltip (special case)
        local itm = QuestieDB:GetItem(Objective.Id);
        if itm and itm.Name then
            if completed then
                QuestieTooltips:RemoveTooltip("i_" .. itm.Name)
            else
                QuestieTooltips:RegisterTooltip(Quest.Id, "i_" .. itm.Name, Objective);
            end
        end
        Objective.registeredItemTooltips = true
    end
    if Objective.spawnList then
        local hasSpawnHack = false -- used to check if we have bad data due to API delay. Remove this check once the API bug is dealt with properly
        local hasTooltipHack = false
        local tooltipRegisterHack = {} -- improve this
        for id, spawnData in pairs(Objective.spawnList) do -- spawnData.Name, spawnData.Spawns
            hasSpawnHack = true -- #table and table.getn are unreliable
            if not Objective.Icon and spawnData.Icon then -- move this to a better place
                Objective.Icon = spawnData.Icon
            end
            if not Quest.AlreadySpawned[Objective.Type] then
                Quest.AlreadySpawned[Objective.Type] = {};
            end

            if (not Objective.AlreadySpawned[id]) and (not completed) and (not Quest.AlreadySpawned[Objective.Type][spawnData.Id]) then

                -- temporary fix for "special objectives" to not double-spawn (we need to fix the objective detection logic)
                Quest.AlreadySpawned[Objective.Type][spawnData.Id] = true

                if not Objective.registeredTooltips and spawnData.TooltipKey and (not tooltipRegisterHack[spawnData.TooltipKey]) then -- register mob / item / object tooltips
                    QuestieTooltips:RegisterTooltip(Quest.Id, spawnData.TooltipKey, Objective);
                    tooltipRegisterHack[spawnData.TooltipKey] = true
                    hasTooltipHack = true
                end
                local maxCount = 0
                local data = {}
                data.Id = Quest.Id
                data.ObjectiveIndex = ObjectiveIndex
                data.QuestData = Quest
                data.ObjectiveData = Objective
                data.Icon = spawnData.Icon
                data.GetIconScale = function() return spawnData:GetIconScale() or 1 end
                data.IconScale = data:GetIconScale()
                data.Name = spawnData.Name
                data.Type = Objective.Type
                data.ObjectiveTargetId = spawnData.Id

                if spawnData.Icon ~= ICON_TYPE_OBJECT then -- new clustering / limit code should prevent problems, always show all object notes
                    data.ClusterId = tostring(spawnData.Id) .. tostring(Quest.Id) .. ObjectiveIndex
                end

                Objective.AlreadySpawned[id] = {};
                Objective.AlreadySpawned[id].data = data;
                Objective.AlreadySpawned[id].minimapRefs = {};
                Objective.AlreadySpawned[id].mapRefs = {};

                for zone, spawns in pairs(spawnData.Spawns) do
                    for _, spawn in pairs(spawns) do
                        if maxPerObjectiveOutsideZone > 0 or ((not Quest.Zone) or Quest.Zone == zone) then -- still add the note if its in the current zone
                            iconMap, iconMini = QuestieMap:DrawWorldIcon(data, zone, spawn[1], spawn[2]) -- clustering code takes care of duplicates as long as mindist is more than 0
                            if iconMap and iconMini then
                                table.insert(Objective.AlreadySpawned[id].mapRefs, iconMap);
                                table.insert(Objective.AlreadySpawned[id].minimapRefs, iconMini);
                            end
                        end
                        maxCount = maxCount + 1
                        if Quest.Zone then
                            if zone ~= Quest.Zone then
                                maxPerObjectiveOutsideZone = maxPerObjectiveOutsideZone - 1
                            end
                        end
                        if maxCount > maxPerType then break; end
                    end
                    if maxCount > maxPerType then break; end
                end
            elseif completed and Objective.AlreadySpawned then -- unregister notes
                for id, spawn in pairs(Objective.AlreadySpawned) do
                    for _, note in pairs(spawn.mapRefs) do
                        note:Unload();
                    end
                    for _, note in pairs(spawn.minimapRefs) do
                        note:Unload();
                    end
                end
            end
        end
        if not hasSpawnHack then-- used to check if we have bad data due to API delay. Remove this check once the API bug is dealt with properly
            Objective.spawnList = nil -- reset the list so it can be regenerated with hopefully better quest log data
        end
        if hasTooltipHack then
            Objective.registeredTooltips = true
        end
    end
end

local _randomSeed = 0;
function QuestieQuest:math_randomseed(seed)
    _randomSeed = seed
end
function QuestieQuest:math_random()
    local high = 0xffffff;
    _randomSeed = (_randomSeed * 214013 + 2531011) % 2^32;
    local rand = math.floor(_randomSeed / 2^16) % 2^15;
    return (1 + math.floor(rand / 0x7fff * high)) / high
end

function QuestieQuest:PopulateObjectiveNotes(Quest) -- this should be renamed to PopulateNotes as it also handles finishers now
    if not Quest then return; end
    if QuestieQuest:IsComplete(Quest) then
        QuestieQuest:AddFinisher(Quest)
        return
    end


    if not Quest.Color then -- todo: move to a better place
        QuestieQuest:math_randomseed(Quest.Id)
        Quest.Color = {0.45 + QuestieQuest:math_random() / 2, 0.45 + QuestieQuest:math_random() / 2, 0.45 + QuestieQuest:math_random() / 2}
    end

    -- we've already checked the objectives table by doing IsComplete
    -- if that changes, check it here
    local old = GetQuestLogSelection()
    for k, v in pairs(Quest.Objectives) do
        SelectQuestLogEntry(v.Index)
        result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, k, v, false);
        if not result then
            Questie:Error("[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', Quest.Name, Quest.Id, k, err));
        end
    end

    -- check for special (unlisted) DB objectives
    if Quest.SpecialObjectives then
        for _, objective in pairs(Quest.SpecialObjectives) do
            result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, 0, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', Quest.Name, Quest.Id, k, err));
            end
        end
    end
    if old then
        SelectQuestLogEntry(old)
    end

end
function QuestieQuest:PopulateQuestLogInfo(Quest)
    --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta1:", Quest.Id, Quest.Name)
    if Quest.Objectives == nil then
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateQuestLogInfo: ".. QuestieLocale:GetUIString('DEBUG_POPTABLE'))
        Quest.Objectives = {};
    end
    local logID = GetQuestLogIndexByID(Quest.Id);
    if logID ~= 0 then
        _, _, _, _, _, Quest.isComplete, _, _, _, _, _, _, _, _, _, Quest.isHidden = GetQuestLogTitle(logID)
        if Quest.isComplete ~= nil and Quest.isComplete == 1 then
            Quest.isComplete = true
        end
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta:", Quest.isComplete, Quest.Name)
    else
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Error: No logid:", Quest.Name, Quest.Id )
    end
    QuestieQuest:GetAllQuestObjectives(Quest)
end

--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
function QuestieQuest:GetAllQuestObjectives(Quest)
    local logId = GetQuestLogIndexByID(Quest.Id)
    local old = GetQuestLogSelection()
    SelectQuestLogEntry(logId)
    local count = GetNumQuestLeaderBoards()
    if Quest.Objectives == nil then
        Quest.Objectives = {}; -- TODO: remove after api bug is fixed!!!
        Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_OBJ_TABLE'));
    end

    for i = 1, count do
        objectiveType, objectiveDesc, numItems, numNeeded, isCompleted = _QuestieQuest:GetLeaderBoardDetails(i, Quest.Id)
        if objectiveType then
            if Quest.Objectives[i] == nil then
                Quest.Objectives[i] = {}
            end
            Quest.Objectives[i].Index = i
            Quest.Objectives[i].QuestId = Quest.Id
            Quest.Objectives[i].QuestLogId = logId
            Quest.Objectives[i].QuestData = Quest
            Quest.Objectives[i]._lastUpdate = 0;
            Quest.Objectives[i].Description = nil
            Quest.Objectives[i].Update = function(self)
                local old = GetQuestLogSelection()
                SelectQuestLogEntry(self.QuestLogId)
                local now = GetTime();
                if now - self._lastUpdate < 0.5 then
                    if old then SelectQuestLogEntry(old); end
                    return {self.Collected, self.Needed, self.Completed} -- updated too recently
                end
                self._lastUpdate = now

                -- check if this is still a valid objective (fix)
                --_,_,_,_,_,_,_,questID = GetQuestLogTitle(self.Index)
                --DEFAULT_CHAT_FRAME:AddMessage("qid: " .. questID .. " " .. self.QuestId)

                objectiveType, objectiveDesc, numItems, numNeeded, isComplete = _QuestieQuest:GetLeaderBoardDetails(self.Index, self.QuestId)

                --if self.Description and strlen(self.Description) > 1 and self.Description ~= objectiveDesc then -- fix bug (mentioned above with GetQuestLogTitle)
                --    self.Collected = self.Needed
                --    self.Completed = true
                --    return {self.Collected, self.Needed, self.Completed}
                --end

                if objectiveType then
                    -- fixes for api bug
                    if not numItems then numItems = 0; end
                    if not numNeeded then numNeeded = 0; end
                    if not isComplete then isComplete = false; end -- ensure its boolean false and not nil (hack)

                    self.Type = objectiveType
                    self.Description = objectiveDesc
                    self.Collected = tonumber(numItems)
                    self.Needed = tonumber(numNeeded)
                    self.Completed = (self.Needed == self.Collected and self.Needed > 0) or (isComplete and (self.Needed == 0 or (not self.Needed))) -- some objectives get removed on PLAYER_LOGIN because isComplete is set to true at random????
                end
                if old then SelectQuestLogEntry(old); end
                return {self.Collected, self.Needed, self.Completed}
            end
            Quest.Objectives[i]:Update()

            if count == 1 and counthack(Quest.ObjectiveData) == 1 then
                Quest.Objectives[i].Id = Quest.ObjectiveData[1].Id
            elseif Quest.ObjectiveData ~= nil then
                -- try to find npc/item/event ID
                for k, v in pairs(Quest.ObjectiveData) do
                    if objectiveType == v.Type then
                        -- TODO: use string distance to find closest, dont rely on exact match
                        if ((v.Name == nil or objectiveDesc == nil) and v.Type ~= "item" and v.Type ~= "monster") or (v.Name and ((string.lower(objectiveDesc) == string.lower(v.Name))) or (v.Text and (string.lower(objectiveDesc) == string.lower(v.Text)))) then
                            Quest.Objectives[i].Id = v.Id
                            Quest.Objectives[i].Coordinates = v.Coordinates
                            v.ObjectiveRef = Quest.Objectives[i]
                        end
                    end
                end
            end
        end

        if (not Quest.Objectives[i]) or (not Quest.Objectives[i].Id) then
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ENTRY_ID', objectiveType, objectiveDesc))
        end

    end
    if old then SelectQuestLogEntry(old); end

    -- find special unlisted objectives
    -- hack to remove misdetected unlisted (when qlog returns bad data for objective text on first try)
    local checkTime = GetTime();
    if Quest.HiddenObjectiveData then
        for _, objective in pairs(Quest.HiddenObjectiveData) do
            if not objective.ObjectiveRef then -- there was no qlog objective detected for this DB objective
                -- hack
                if not Quest.SpecialObjectives then
                    Quest.SpecialObjectives = {};
                end
                if objective.Type then
                    if objective.Type == "monster" then
                        local npc = QuestieDB:GetNPC(objective.Id);
                        if npc and npc.Name then
                            objective.Description = npc.Name
                        end
                    elseif objective.Type == "item" then
                        local itm = QuestieDB:GetItem(objective.Id);
                        if itm and itm.Name then
                            objective.Description = itm.Name
                        end
                    elseif objective.Type == "event" then
                        objective.Description = "Event Trigger"
                    end
                end
                if not objective.Description then objective.Description = "Hidden objective"; end

                if not Quest.SpecialObjectives[objective.Description] then
                    objective.QuestData = Quest
                    objective.QuestId = Quest.Id
                    objective.Update = function() end
                    objective.checkTime = checkTime
                    Quest.SpecialObjectives[objective.Description] = objective
                end
                --table.insert(Quest.SpecialObjectives, objective);
            end
        end
    end

    return Quest.Objectives
end


--TODO Check that this resolves correctly in classic!
--/dump QuestieQuest:GetLeaderBoardDetails (1,1)
function _QuestieQuest:GetLeaderBoardDetails(BoardIndex, QuestId)
    Index = GetQuestLogIndexByID(QuestId)
    if(Index == 0) then
        Index = QuestId;
    end
    local description, objectiveType, isCompleted = GetQuestLogLeaderBoard (BoardIndex, Index);
    if not description then return nil; end -- invalid board index (this has happened extremely rarely see issue 565)

    --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Quest Details1:", description, objectiveType, isCompleted)
    --Classic
    local itemName, numItems, numNeeded = string.match(description, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
    --Retail
    if(itemName == nil or string.len(itemName) < 1) then --Just a figure... check if its not 0
        numItems, numNeeded, itemName = string.match(description, "(%d+)\/(%d+)(.*)")
    end
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Quest Details2:", QuestId, itemName, numItems, numNeeded)
    if (itemName) then
        itemName = string.gsub(itemName, "slain", "")
    else
        itemName = description;
    end
    numItems, numNeeded = string.match(description, "(%d+)\/(%d+)")
    return objectiveType, strtrim(itemName), numItems, numNeeded, isCompleted;
end

--Draw a single available quest, it is used by the DrawAllAvailableQuests function.
function _QuestieQuest:DrawAvailableQuest(questObject) -- prevent recursion
    return _QuestieQuest:DrawAvailableQuest(questObject, false)
end
function _QuestieQuest:DrawAvailableQuest(questObject, noChildren)

    --If the object is nil we just return
    if(questObject == nil) then
        return false;
    end

    -- where applicable, make the exclusivegroup quests available again (TESTED)
    if questObject.ExclusiveQuestGroup and (not noChildren) then
        for k, v in pairs(questObject.ExclusiveQuestGroup) do
            local quest = QuestieDB:GetQuest(v)
            if _QuestieQuest:IsDoable(quest) then
                _QuestieQuest:DrawAvailableQuest(quest, true);
            end
        end
    end


    --TODO More logic here, currently only shows NPC quest givers.
    if questObject.Starts["GameObject"] ~= nil then
        for index, ObjectID in ipairs(questObject.Starts["GameObject"]) do
            obj = QuestieDB:GetObject(ObjectID)
            if(obj ~= nil and obj.Spawns ~= nil) then
                --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                for Zone, Spawns in pairs(obj.Spawns) do
                    if(Zone ~= nil and Spawns ~= nil) then
                        --Questie:Debug("Zone", Zone)
                        --Questie:Debug("Qid:", questid)
                        for _, coords in ipairs(Spawns) do
                            --Questie:Debug("Coords", coords[1], coords[2])
                            local data = {}
                            data.Id = questObject.Id;
                            data.Icon = ICON_TYPE_AVAILABLE;
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data:GetIconScale()
                            data.Type = "available";
                            data.QuestData = questObject;
                            data.Name = obj.Name

                            data.IsObjectiveNote = false
                            --data.updateTooltip = function(data)
                            --    return {QuestieTooltips:PrintDifficultyColor(data.QuestData.Level, "[" .. data.QuestData.Level .. "] " .. data.QuestData.Name), "|cFFFFFFFFStarted by: |r|cFF22FF22" .. data.QuestData.NPCName, "QuestId:"..data.QuestData.Id}
                            --end
                            if(coords[1] == -1 or coords[2] == -1) then
                                if(instanceData[Zone] ~= nil) then
                                    for index, value in ipairs(instanceData[Zone]) do
                                        --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                                        QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    end
                                end
                            else
                                --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
                                --HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
                                QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                            end
                        end
                    end
                end
            end
        end
    elseif(questObject.Starts["NPC"] ~= nil)then
        for index, NPCID in ipairs(questObject.Starts["NPC"]) do
            NPC = QuestieDB:GetNPC(NPCID)
            if(NPC ~= nil and NPC.Spawns ~= nil) then
                --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                for Zone, Spawns in pairs(NPC.Spawns) do
                    if(Zone ~= nil and Spawns ~= nil) then
                        --Questie:Debug("Zone", Zone)
                        --Questie:Debug("Qid:", questid)
                        for _, coords in ipairs(Spawns) do
                            --Questie:Debug("Coords", coords[1], coords[2])
                            local data = {}
                            data.Id = questObject.Id;
                            data.Icon = ICON_TYPE_AVAILABLE;
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data.GetIconScale();
                            data.Type = "available";
                            data.QuestData = questObject;
                            data.Name = NPC.Name
                            data.IsObjectiveNote = false
                            --data.updateTooltip = function(data)
                            --    return {QuestieTooltips:PrintDifficultyColor(data.QuestData.Level, "[" .. data.QuestData.Level .. "] " .. data.QuestData.Name), "|cFFFFFFFFStarted by: |r|cFF22FF22" .. data.QuestData.NPCName, "QuestId:"..data.QuestData.Id}
                            --end
                            if(coords[1] == -1 or coords[2] == -1) then
                                if(instanceData[Zone] ~= nil) then
                                    for index, value in ipairs(instanceData[Zone]) do
                                        --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                                        QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    end
                                end
                            else
                                --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[Zone])
                                --HBDPins:AddWorldMapIconMap(Questie, Note, zoneDataAreaIDToUiMapID[Zone], coords[1]/100, coords[2]/100, HBD_PINS_WORLDMAP_SHOW_WORLD)
                                QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                            end
                        end
                    end
                end
            end
        end
    end
end

function QuestieQuest:DrawAllAvailableQuests()--All quests between
    --This should probably be called somewhere else!
    --QuestieFramePool:UnloadAll()

    local count = 0
    for questid, qid in pairs(qAvailableQuests) do
        --If the quest is not drawn draw the quest, otherwise skip.
        if(not qQuestIdFrames[questid]) then
            Quest = QuestieDB:GetQuest(questid)
            --Draw a specific quest through the function
            _QuestieQuest:DrawAvailableQuest(Quest)
        end
        count = count + 1
    end
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", QuestieLocale:GetUIString('DEBUG_DRAW', count, qPlayerLevel));
end




function _QuestieQuest:IsDoable(questObject) -- we need to add profession/reputation checks here
    if not questObject then
        return false;
    end
    if questObject.Hidden then
        return false;
    end
    if questObject.NextQuestInChain then
        if Questie.db.char.complete[questObject.NextQuestInChain] or qCurrentQuestlog[questObject.NextQuestInChain] then
            return false
        end
    end
    local allFinished = true
    --Run though the requiredQuests
    if questObject.ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for k, v in pairs(questObject.ExclusiveQuestGroup) do
            if Questie.db.char.complete[v] or qCurrentQuestlog[v] then
                return false
            end
        end
    end
    if questObject.RequiredQuest == nil or questObject.RequiredQuest == 0 then
        return true
    end
    for index, preQuestId in pairs(questObject.RequiredQuest) do

        local preQuest = QuestieDB:GetQuest(preQuestId);

        --If a quest is not complete not all are finished, we need to check group
        if not Questie.db.char.complete[preQuestId] then
            allFinished = false
            --If one of the quests in the group is done we return true
        elseif preQuest and preQuest.ExclusiveQuestGroup then
            return true
        end

        --If one of the quests are in the log, return false
        if preQuest and qCurrentQuestlog[preQuest.Id] then
            return false
        end
    end
    return allFinished
end

function _QuestieQuest:CheckExclusivity(questObject)

end

--TODO Check that this function does what it is supposed to...
function QuestieQuest:CalculateAvailableQuests()
    local PlayerLevel = qPlayerLevel;

    local MinLevel = PlayerLevel - Questie.db.global.minLevelFilter
    local MaxLevel = PlayerLevel + Questie.db.global.maxLevelFilter

    --DEFAULT_CHAT_FRAME:AddMessage(" minlevel/maxlevel: " .. MinLevel .. "/" .. MaxLevel);

    qAvailableQuests = {}

    for i, v in pairs(qData) do
        local QuestID = i;
        --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.

        if(not Questie.db.char.complete[QuestID] and not qHide[QuestID] and not qCurrentQuestlog[QuestID]) then --Should be not qCurrentQuestlog[QuestID]
            local Quest = QuestieDB:GetQuest(QuestID);
            if (Quest.Level > MinLevel or Questie.db.char.lowlevel) and Quest.Level < MaxLevel and Quest.MinLevel <= PlayerLevel then
                if _QuestieQuest:IsDoable(Quest) then
                    qAvailableQuests[QuestID] = QuestID
                end
            else
                --If the quests are not within level range we want to unload them
                --(This is for when people level up or change settings etc)
                QuestieMap:UnloadQuestFrames(QuestID);
            end
        end
    end
end
