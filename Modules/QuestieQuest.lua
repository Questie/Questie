QuestieQuest = {...}
local _QuestieQuest = {...}
local libS = LibStub:GetLibrary("AceSerializer-3.0")
local libC = LibStub:GetLibrary("LibCompress")


--We should really try and squeeze out all the performance we can, especially in this.
local tostring = tostring;
local tinsert = table.insert;
local pairs = pairs;
local ipairs = ipairs;
local strim = string.trim;
local smatch = string.match;
local strfind = string.find;
local slower = string.lower;

--Change cluter method, "hotzone" or "cell"
clusterMethod = "hotzone";

QuestieQuest.availableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD


local HBD = LibStub("HereBeDragonsQuestie-2.0")

function QuestieQuest:Initialize()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST_COMP'))
    --GetQuestsCompleted(Questie.db.char.complete)
    Questie.db.char.complete = GetQuestsCompleted()
    QuestieProfessions:Update()
    QuestieReputation:Update()

    -- this inserts the Questie Icons to the MinimapButtonBag ignore list
    if MBB_Ignore then
        tinsert(MBB_Ignore, "QuestieFrameGroup")
    end

    _QuestieQuest.questLogHashes = QuestieQuest:GetQuestLogHashes()

    --local db = {}
    --GetQuestsCompleted(db)

    -- maintain additional data added to db.char.complete, but remove quests that are no longer complete
    --for k,v in pairs(db) do
    --    if not Questie.db.char.complete[k] then Questie.db.char.complete[k] = true; end
    --end
    --for k,v in pairs(Questie.db.char.complete) do
    --    if not db[k] then
    --        Questie.db.char.complete[k] = nil
    --    end
    --end
end

QuestieQuest.NotesHidden = false

function QuestieQuest:ToggleNotes(desiredValue)
    if desiredValue ~= nil and desiredValue == (not QuestieQuest.NotesHidden) then
        return -- we already have the desired state
    end
    if QuestieQuest.NotesHidden then
        -- change map button
        Questie_Toggle:SetText(QuestieLocale:GetUIString('QUESTIE_MAP_BUTTON_HIDE'));
        -- show quest notes
        for questId, framelist in pairs(QuestieMap.questIdFrames) do
            for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                local icon = _G[frameName];
                if icon ~= nil and icon.hidden and not ((((not Questie.db.global.enableObjectives) and (icon.data.Type == "monster" or icon.data.Type == "object" or icon.data.Type == "event" or icon.data.Type == "item"))
                 or ((not Questie.db.global.enableTurnins) and icon.data.Type == "complete")
                 or ((not Questie.db.global.enableAvailable) and icon.data.Type == "available"))
                 or ((not Questie.db.global.enableMapIcons) and (not icon.miniMapIcon))
                 or ((not Questie.db.global.enableMiniMapIcons) and (icon.miniMapIcon))) or (icon.data.ObjectiveData and icon.data.ObjectiveData.HideIcons) or (icon.data.QuestData and icon.data.QuestData.HideIcons and icon.data.Type ~= "complete") then
                    icon:FakeUnhide()
                end
            end
        end
        -- show manual notes
        -- TODO probably this whole function should be moved to QuestieMap, now that it handles manualFrames
        for _, frameList in pairs(QuestieMap.manualFrames) do
            for _, frameName in pairs(frameList) do
                local icon = _G[frameName];
                if icon ~= nil and icon.IsShown ~= nil and (not icon.hidden) then -- check for function to make sure its a frame
                    icon:FakeUnide()
                end
            end
        end
    else
        -- change map button
        Questie_Toggle:SetText(QuestieLocale:GetUIString('QUESTIE_MAP_BUTTON_SHOW'));
        -- hide quest notes
        for questId, framelist in pairs(QuestieMap.questIdFrames) do
            for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                local icon = _G[frameName];
                if icon ~= nil and icon.IsShown ~= nil and (not icon.hidden) then -- check for function to make sure its a frame
                    icon:FakeHide()
                end
            end
        end
        -- hide manual notes
        for _, frameList in pairs(QuestieMap.manualFrames) do
            for _, frameName in pairs(frameList) do
                local icon = _G[frameName];
                if icon ~= nil and icon.IsShown ~= nil and (not icon.hidden) then -- check for function to make sure its a frame
                    icon:FakeHide()
                end
            end
        end
    end
    -- update config
    QuestieQuest.NotesHidden = not QuestieQuest.NotesHidden
    Questie.db.char.enabled = not QuestieQuest.NotesHidden
end


function QuestieQuest:ClearAllNotes()
    for quest in pairs (QuestiePlayer.currentQuestlog) do
        local Quest = QuestieDB:GetQuest(quest)

        -- Clear user-specifc data from quest object (maybe we should refactor into Quest.session.* so we can do Quest.session = nil to reset easier
        Quest.AlreadySpawned = nil
        Quest.Objectives = nil

        -- reference is still held elswhere
        if Quest.SpecialObjectives then for _,s in pairs(Quest.SpecialObjectives) do s.AlreadySpawned = nil end end
        Quest.SpecialObjectives = nil
    end

    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        for index, frameName in ipairs(framelist) do
            local icon = _G[frameName]
            if icon and icon.Unload then
                icon:Unload()
            end
        end
    end
    QuestieMap.questIdFrames = {}
    QuestieMap.MapCache_ClutterFix = {}
end

-- this is only needed for reset, normally special objectives don't need to update
local function _UpdateSpecials(quest)
    local Quest = QuestieDB:GetQuest(quest)
    if Quest and Quest.SpecialObjectives then
        if Quest.SpecialObjectives then
            for _, objective in pairs(Quest.SpecialObjectives) do
                local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, 0, objective, true);
                if not result then
                    Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', Quest.Name or "No quest name", Quest.Id or "No quest id", 0 or "No objective", err or "No error"));
                end
            end
        end
    end
end

function QuestieQuest:AddAllNotes()
    QuestieQuest.availableQuests = {} -- reset available quest db

    -- draw available quests
    QuestieQuest:GetAllQuestIdsNoObjectives()
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()

    -- draw quests
    for quest in pairs (QuestiePlayer.currentQuestlog) do
        QuestieQuest:UpdateQuest(quest)
        _UpdateSpecials(quest)
    end
end

function QuestieQuest:Reset()
    -- clear all notes
    QuestieQuest:ClearAllNotes()

    -- reset quest log and tooltips
    QuestiePlayer.currentQuestlog = {}
    QuestieTooltips.tooltipLookup = {}

    -- make sure complete db is correct
    Questie.db.char.complete = GetQuestsCompleted()
    QuestieProfessions:Update()
    QuestieReputation:Update()

    QuestieQuest:AddAllNotes()
end

function QuestieQuest:SmoothReset() -- use timers to reset progressively instead of all at once
    -- bit of a hack (there has to be a better way to do logic like this
    QuestieDBMIntegration:ClearAll()
    local stepTable = {
        QuestieQuest.ClearAllNotes,
        function()
            -- reset quest log and tooltips
            QuestiePlayer.currentQuestlog = {}
            QuestieTooltips.tooltipLookup = {}

            -- make sure complete db is correct
            Questie.db.char.complete = GetQuestsCompleted()
            QuestieProfessions:Update()
            QuestieReputation:Update()
            QuestieQuest.availableQuests = {} -- reset available quest db

            -- draw available quests
            QuestieQuest:GetAllQuestIdsNoObjectives()
        end,
        QuestieQuest.CalculateAvailableQuests,
        QuestieQuest.DrawAllAvailableQuests,
        function()
            -- bit of a hack here too
            local mod = 0
            for quest in pairs (QuestiePlayer.currentQuestlog) do
                C_Timer.After(mod, function() QuestieQuest:UpdateQuest(quest) _UpdateSpecials(quest) end)
                mod = mod + 0.2
            end
        end
    }
    local step = 1
    C_Timer.NewTicker(0.1, function()
        stepTable[step]()
        step = step + 1
    end, 5)
end


function QuestieQuest:UpdateHiddenNotes()
    QuestieQuest:GetAllQuestIds() -- add notes that weren't added from previous hidden state
    if Questie.db.global.enableAvailable then
        QuestieQuest:DrawAllAvailableQuests();
    end

    -- Update hidden status of quest notes
    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            if icon ~= nil and icon.data then
                if (QuestieQuest.NotesHidden or (((not Questie.db.global.enableObjectives) and (icon.data.Type == "monster" or icon.data.Type == "object" or icon.data.Type == "event" or icon.data.Type == "item"))
                 or ((not Questie.db.global.enableTurnins) and icon.data.Type == "complete")
                 or ((not Questie.db.global.enableAvailable) and icon.data.Type == "available"))
                 or ((not Questie.db.global.enableMapIcons) and (not icon.miniMapIcon))
                 or ((not Questie.db.global.enableMiniMapIcons) and (icon.miniMapIcon))) or (icon.data.ObjectiveData and icon.data.ObjectiveData.HideIcons) or (icon.data.QuestData and icon.data.QuestData.HideIcons and icon.data.Type ~= "complete") then
                    icon:FakeHide()
                else
                    icon:FakeUnhide()
                end
                if (icon.data.QuestData.FadeIcons or (icon.data.ObjectiveData and icon.data.ObjectiveData.FadeIcons)) and icon.data.Type ~= "complete" then
                    icon:FadeOut()
                else
                    icon:FadeIn()
                end
            end
        end
    end
    -- Update hidden status of manual notes
    -- TODO maybe move the function to QuestieMap?
    for id, frameList in pairs(QuestieMap.manualFrames) do
        for _, frameName in ipairs(frameList) do
            local icon = _G[frameName]
            if icon ~= nil and icon.data then
                if  QuestieQuest.NotesHidden or
                    ((not Questie.db.global.enableMapIcons) and (not icon.miniMapIcon)) or
                    ((not Questie.db.global.enableMiniMapIcons) and (icon.miniMapIcon))
                then
                    icon:FakeHide()
                else
                    icon:FakeUnhide()
                end 
            end
        end
    end
end

function QuestieQuest:HideQuest(id)
    Questie.db.char.hidden[id] = true
    QuestieMap:UnloadQuestFrames(id);
end

function QuestieQuest:UnhideQuest(id)
    Questie.db.char.hidden[id] = nil
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()
end

function QuestieQuest:GetRawLeaderBoardDetails(QuestLogIndex)
    -- Old Select code, is this still needed?
    local old = GetQuestLogSelection()
    SelectQuestLogEntry(QuestLogIndex);
    --
    local quest = {}
    local title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(QuestLogIndex)
    quest.title = title;
    quest.level = level;
    quest.Id = questId
    quest.isComplete = isComplete;

    quest.Objectives = {}
    local objectiveList  = C_QuestLog.GetQuestObjectives(questId) or {};
    for objectiveIndex, objective in pairs(objectiveList) do
        quest.Objectives[objectiveIndex] = {}
        quest.Objectives[objectiveIndex].description = objective.text;
        quest.Objectives[objectiveIndex].objectiveType = objective.type;
        quest.Objectives[objectiveIndex].isCompleted = objective.finished;
        quest.Objectives[objectiveIndex].numFulfilled = objective.numFulfilled;
        quest.Objectives[objectiveIndex].numRequired = objective.numRequired;
    end
    -- Old select code, is this still needed?
    if old then SelectQuestLogEntry(old); end
    --
    return quest;
end

function QuestieQuest:AcceptQuest(questId)
    if(QuestiePlayer.currentQuestlog[questId] == nil) then
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ACCEPT_QUEST', questId));


        --Get all the Frames for the quest and unload them, the available quest icon for example.
        QuestieMap:UnloadQuestFrames(questId);
        QuestieQuest:AddNewQuestHash(questId)

        Quest = QuestieDB:GetQuest(questId)
        if(Quest ~= nil) then
            -- we also need to remove exclusivegroup icons (TESTED)
            if Quest.ExclusiveQuestGroup then
                for k, questId in pairs(Quest.ExclusiveQuestGroup) do
                    QuestieMap:UnloadQuestFrames(questId);
                end
            end

            --Reset the clustering for the map
            QuestieMap.MapCache_ClutterFix = {};
            QuestiePlayer.currentQuestlog[questId] = Quest
            QuestieQuest:PopulateQuestLogInfo(Quest)
            QuestieQuest:PopulateObjectiveNotes(Quest)
        else
            QuestiePlayer.currentQuestlog[questId] = questId
        end


        for availableQuestId, alsoQuestId in pairs(QuestieQuest.availableQuests) do
            if not _QuestieQuest:IsDoable(QuestieDB:GetQuest(availableQuestId)) then
                QuestieMap:UnloadQuestFrames(availableQuestId, ICON_TYPE_AVAILABLE);
            end
        end

        --TODO: Insert call to drawing objective logic here!
        --QuestieQuest:TrackQuest(questId);
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()
        
        --For safety, remove all these icons.
        QuestieMap:UnloadQuestFrames(questId, ICON_TYPE_AVAILABLE);
        --Broadcast an update.
        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId);
    else
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ACCEPT_QUEST', questId), " Warning: Quest already existed, not adding");
    end

end

function QuestieQuest:CompleteQuest(QuestId)
    QuestiePlayer.currentQuestlog[QuestId] = nil;
    Questie.db.char.complete[QuestId] = true --can we use some other relevant info here?
    QuestieQuest:RemoveQuestHash(QuestId)

    --This should probably be done first, because DrawAllAvailableQuests looks at QuestieMap.questIdFrames[QuestId] to add available
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests();

    QuestieMap:UnloadQuestFrames(QuestId);
    if(QuestieMap.questIdFrames[QuestId]) then
        Questie:Print("ERROR: Just removed all frames but the framelist seems to still be there!", QuestId);
    end
    QuestieTooltips:RemoveQuest(QuestId)
    --Unload all the quest frames from the map.
    --QuestieMap:UnloadQuestFrames(QuestId); --We are currently redrawing everything so we might as well not use this now


    QuestieTracker:QuestRemoved(QuestId)
    QuestieTracker:Update()

    --For safety, remove all these icons.
    QuestieMap:UnloadQuestFrames(QuestId, ICON_TYPE_COMPLETE);

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_COMPLETE_QUEST', QuestId));
end

function QuestieQuest:AbandonedQuest(QuestId)
    QuestieTooltips:RemoveQuest(QuestId)
    if(QuestiePlayer.currentQuestlog[QuestId]) then
        QuestiePlayer.currentQuestlog[QuestId] = nil
        QuestieQuest:RemoveQuestHash(QuestId)

        --Unload all the quest frames from the map.
        QuestieMap:UnloadQuestFrames(QuestId);

        local quest = QuestieDB:GetQuest(QuestId);
        quest.Objectives = nil;
        quest.AlreadySpawned = nil; -- temporary fix for "special objectives" remove later
        --The old data for notes are still there, we don't need to recalulate data.
        --_QuestieQuest:DrawAvailableQuest(quest)

        -- yes we do, since abandoning can unlock more than 1 quest, or remove unlocked quests
        for k,v in pairs(QuestieQuest.availableQuests) do
            if not _QuestieQuest:IsDoable(QuestieDB:GetQuest(k)) then
                QuestieMap:UnloadQuestFrames(k);
            end
        end
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()

        QuestieTracker:QuestRemoved(QuestId)
        QuestieTracker:Update()

        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ABANDON_QUEST', QuestId));
    end
end

function QuestieQuest:UpdateQuest(QuestId)
    local quest = QuestieDB:GetQuest(QuestId);
    if quest ~= nil and not Questie.db.char.complete[QuestId] then
        QuestieQuest:PopulateQuestLogInfo(quest)
        QuestieQuest:GetAllQuestObjectives(quest) -- update quest log values in quest object
        QuestieQuest:UpdateObjectiveNotes(quest)
        if QuestieQuest:IsComplete(quest) or QuestieQuest:isCompleteByQuestId(QuestId) or IsQuestComplete(QuestId) then
            --DEFAULT_CHAT_FRAME:AddMessage("Finished " .. QuestId);
            QuestieMap:UnloadQuestFrames(QuestId);
            QuestieQuest:AddFinisher(quest)

        else
            --DEFAULT_CHAT_FRAME:AddMessage("Still not finished " .. QuestId);
        end
        QuestieTracker:Update()

        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", QuestId);
    end
end
--Run this if you want to update the entire table
function QuestieQuest:GetAllQuestIds()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST'));
    local numEntries, numQuests = GetNumQuestLogEntries();
    QuestiePlayer.currentQuestlog = {}
    for index = 1, numEntries do
        local title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if(not isHeader) then
            --Keep the object in the questlog to save searching
            local Quest = QuestieDB:GetQuest(questId)
            if(Quest ~= nil) then
                QuestiePlayer.currentQuestlog[questId] = Quest
                QuestieQuest:PopulateQuestLogInfo(Quest)
                QuestieQuest:PopulateObjectiveNotes(Quest)
                if title and strlen(title) > 1 then
                    Quest.LocalizedName = title
                end
            else
                QuestiePlayer.currentQuestlog[questId] = questId
            end
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ADD_QUEST', questId, QuestiePlayer.currentQuestlog[questId]));
        end
    end
    QuestieTracker:Update()
end

function QuestieQuest:GetAllQuestIdsNoObjectives()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST'));
    local numEntries, numQuests = GetNumQuestLogEntries();
    QuestiePlayer.currentQuestlog = {}
    for index = 1, numEntries do
        local title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if(not isHeader) then
            --Keep the object in the questlog to save searching
            local Quest = QuestieDB:GetQuest(questId)
            if(Quest ~= nil) then
                QuestiePlayer.currentQuestlog[questId] = Quest
            else
                QuestiePlayer.currentQuestlog[questId] = questId
            end
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ADD_QUEST', questId, QuestiePlayer.currentQuestlog[questId]));
        end
    end
end

function QuestieQuest:ShouldQuestShowObjectives(QuestId)
    return true -- todo: implement tracker logic here, to hide non-tracked quest optionally (1.12 questie does this optionally)
end


local function Counthack(tab) -- according to stack overflow, # and table.getn arent reliable (I've experienced this? not sure whats up)
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

function QuestieQuest:isCompleteByQuestId(questId)
    local logID = GetQuestLogIndexByID(questId);
    local _, _, _, _, _, isComplete, _, questID, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(logID)

    local allComplete = true;
    local numQuestLogLeaderBoards = GetNumQuestLeaderBoards(questId)
    for index=1, numQuestLogLeaderBoards do
        local desc, type, done = GetQuestLogLeaderBoard(index, questId)
        if(done == false) then
            allComplete = false;
        end
    end
    if(isComplete == 1 and allComplete == true) then
        return true;
    else
        return nil;
    end
end

function QuestieQuest:IsComplete(Quest)
    return Quest.Objectives == nil or Counthack(Quest.Objectives) == 0 or Quest.isComplete or QuestieQuest:_IsCompleteHack(Quest);
end
-- iterate all notes, update / remove as needed
function QuestieQuest:UpdateObjectiveNotes(Quest)
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes:", Quest.Id)
    if Quest.Objectives then
        for k, v in pairs(Quest.Objectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, k, v);
            if not result then
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_POP_ERROR', Quest.Name, Quest.Id, k, err));
            end
        end
    end
end

function QuestieQuest:AddFinisher(Quest)
    --We should never ever add the quest if IsQuestFlaggedComplete true.
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", "Adding finisher for quest ", Quest.Id)
    if(QuestiePlayer.currentQuestlog[Quest.Id] and IsQuestFlaggedCompleted(Quest.Id) == false and IsQuestComplete(Quest.Id) and not Questie.db.char.complete[Quest.Id]) then
        local finisher = nil
        if Quest.Finisher ~= nil then
            if Quest.Finisher.Type == "monster" then
                finisher = QuestieDB:GetNPC(Quest.Finisher.Id)
            elseif Quest.Finisher.Type == "object" then
                finisher = QuestieDB:GetObject(Quest.Finisher.Id)
            else
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_UNHANDLE_FINISH', Quest.Finisher.Type, Quest.Id, Quest.Name))
            end
        else
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_NO_FINISH', Quest.Id, Quest.Name))
        end
        if(finisher ~= nil and finisher.spawns ~= nil) then
            for Zone, Spawns in pairs(finisher.spawns) do
                if(Zone ~= nil and Spawns ~= nil) then
                    for _, coords in ipairs(Spawns) do
                        local data = {}
                        data.Id = Quest.Id;
                        data.Icon = ICON_TYPE_COMPLETE;
                        data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                        data.IconScale = data:GetIconScale();
                        data.Type = "complete";
                        data.QuestData = Quest;
                        data.Name = finisher.name
                        data.IsObjectiveNote = false
                        if(coords[1] == -1 or coords[2] == -1) then
                            if(instanceData[Zone] ~= nil) then
                                for index, value in ipairs(instanceData[Zone]) do
                                    --QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                                    --local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    local z = value[1];
                                    local x = value[2];
                                    local y = value[3];

                                    -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                                    -- as we need the icon handle for the lines.
                                    if(finisher.waypoints and finisher.waypoints[z]) then
                                        local midX, midY = QuestieLib:CalculateWaypointMidPoint(finisher.waypoints[z]);
                                        x = midX or x;
                                        y = midY or y;
                                        -- The above code should do the same... remove this after testing it.
                                        --if(midX and midY) then
                                        --    x = midX;
                                        --    y = midY;
                                        --end
                                    end

                                    local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, z, x, y)

                                    if(finisher.waypoints and finisher.waypoints[z]) then
                                        local lineFrames = QuestieFramePool:CreateWaypoints(icon, finisher.waypoints[z]);
                                        for index, lineFrame in ipairs(lineFrames) do
                                            QuestieMap:DrawLineIcon(lineFrame, z, x, y);
                                            --HBDPins:AddWorldMapIconMap(Questie, lineFrame, zoneDataAreaIDToUiMapID[z], x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                                        end
                                    end
                                end
                            end
                        else
                            --QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                            local x = coords[1];
                            local y = coords[2];

                            -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                            -- as we need the icon handle for the lines.
                            if(finisher.waypoints and finisher.waypoints[Zone]) then
                                local midX, midY = QuestieLib:CalculateWaypointMidPoint(finisher.waypoints[Zone]);
                                x = midX or x;
                                y = midY or y;
                                -- The above code should do the same... remove this after testing it.
                                --if(midX and midY) then
                                --    x = midX;
                                --    y = midY;
                                --end
                            end

                            local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, Zone, x, y)

                            if(finisher.waypoints and finisher.waypoints[Zone]) then
                                local lineFrames = QuestieFramePool:CreateWaypoints(icon, finisher.waypoints[Zone]);
                                for index, lineFrame in ipairs(lineFrames) do
                                    QuestieMap:DrawLineIcon(lineFrame, Zone, x, y);
                                    --HBDPins:AddWorldMapIconMap(Questie, lineFrame, zoneDataAreaIDToUiMapID[Zone], x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

ObjectiveSpawnListCallTable = {
    ["monster"] = function(id, Objective)
        local npc = QuestieDB:GetNPC(id)
        if not npc then
            -- todo: log this
            return nil
        end
        local ret = {}
        local mon = {};

        mon.Name = npc.name
        mon.Spawns = npc.spawns
        mon.Icon = ICON_TYPE_SLAY
        mon.Id = id
        mon.GetIconScale = function() return Questie.db.global.monsterScale or 1 end
        mon.IconScale = mon:GetIconScale();
        mon.TooltipKey = "m_" .. id -- todo: use ID based keys

        ret[id] = mon;
        return ret
    end,
    ["object"] = function(id, Objective)
        local object = QuestieDB:GetObject(id)
        if not object then
            -- todo: log this
            return nil
        end
        local ret = {}
        local obj = {}

        obj.Name = object.name
        obj.Spawns = object.spawns
        obj.Icon = ICON_TYPE_LOOT
        obj.GetIconScale = function() return Questie.db.global.objectScale or 1 end
        obj.IconScale = obj:GetIconScale()
        obj.TooltipKey = "o_" .. id
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
                            tinsert(ret[1].Spawns[zid], {x, y});
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
                            if sourceData.Spawns and not item.Hidden then
                                for zone, spawns in pairs(sourceData.Spawns) do
                                    if not ret[id].Spawns[zone] then
                                        ret[id].Spawns[zone] = {};
                                    end
                                    for _, spawn in pairs(spawns) do
                                        tinsert(ret[id].Spawns[zone], spawn);
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

-- this is for forcing specific things on to the map (That aren't quest related)
-- label and customScale can be nil
function QuestieQuest:ForceToMap(type, id, label, customScale)
    if ObjectiveSpawnListCallTable[type] and type ~= "event" then
        local mapRefs = {}
        local miniRefs = {}
        --local spawnData = ObjectiveSpawnListCallTable[type](id)[id]
        for id, spawnData in pairs(ObjectiveSpawnListCallTable[type](id)) do
            spawnData.Type = type
            spawnData.CustomTooltipData = {}
            spawnData.CustomTooltipData.Title = label or "Forced Icon"
            spawnData.CustomTooltipData.Body = {[spawnData.Name]=spawnData.Name}
            if customScale then
                spawnData.GetIconScale = function(self)
                    return customScale
                end
                spawnData.IconScale = customScale
            end
            for zone, spawns in pairs(spawnData.Spawns) do
                for _, spawn in pairs(spawns) do
                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(spawnData, zone, spawn[1], spawn[2])
                    if iconMap and iconMini then
                        tinsert(mapRefs, iconMap);
                        tinsert(miniRefs, iconMini);
                    end
                end
            end
        end
        return mapRefs, miniRefs
    end
end

function QuestieQuest:PopulateObjective(Quest, ObjectiveIndex, Objective, BlockItemTooltips) -- must be pcalled
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest:PopulateObjective]")
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

    local maxPerType = 300
    if Questie.db.global.enableIconLimit then
        maxPerType = Questie.db.global.iconLimit
    end

    local closestStarter = QuestieMap:FindClosestStarter()

    local iconsToDraw = {}

    Objective:Update() -- update qlog data
    local completed = Objective.Completed

    if not Objective.Color then -- todo: move to a better place
        QuestieQuest:Math_randomseed(Quest.Id + 32768 * ObjectiveIndex)
        Objective.Color = {0.45 + QuestieQuest:Math_random() / 2, 0.45 + QuestieQuest:Math_random() / 2, 0.45 + QuestieQuest:Math_random() / 2}
    end

    if (not Objective.registeredItemTooltips) and Objective.Type == "item" and (not BlockItemTooltips) and Objective.Id then -- register item tooltip (special case)
        local itm = QuestieDB:GetItem(Objective.Id);
        if itm and itm.Name then
            QuestieTooltips:RegisterTooltip(Quest.Id, "i_" .. itm.Id, Objective);
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
            if not Quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)] then
                Quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)] = {};
            end
            if (not Objective.AlreadySpawned[id]) and (not Quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)][spawnData.Id]) then
                if not Objective.registeredTooltips and spawnData.TooltipKey and (not tooltipRegisterHack[spawnData.TooltipKey]) then -- register mob / item / object tooltips
                    QuestieTooltips:RegisterTooltip(Quest.Id, spawnData.TooltipKey, Objective);
                    tooltipRegisterHack[spawnData.TooltipKey] = true
                    hasTooltipHack = true
                end
            end
            if (not Objective.AlreadySpawned[id]) and (not completed) and (not Quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)][spawnData.Id]) then
                if Questie.db.global.enableObjectives then
                    -- temporary fix for "special objectives" to not double-spawn (we need to fix the objective detection logic)
                    Quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)][spawnData.Id] = true
                    local maxCount = 0
                    if(not iconsToDraw[Quest.Id]) then
                        iconsToDraw[Quest.Id] = {}
                    end
                    local data = {}
                    data.Id = Quest.Id
                    data.ObjectiveIndex = ObjectiveIndex
                    data.QuestData = Quest
                    data.ObjectiveData = Objective
                    data.Icon = spawnData.Icon
                    data.IconColor = Quest.Color
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
                            if(spawn[1] and spawn[2]) then
                                local drawIcon = {};
                                drawIcon.AlreadySpawnedId = id;
                                drawIcon.data = data;
                                drawIcon.zone = zone;
                                drawIcon.areaId = zone;
                                drawIcon.UIMapId = zoneDataAreaIDToUiMapID[zone];
                                drawIcon.x = spawn[1];
                                drawIcon.y = spawn[2];
                                local x, y, instance = HBD:GetWorldCoordinatesFromZone(drawIcon.x/100, drawIcon.y/100, zoneDataAreaIDToUiMapID[zone])
                                -- There are instances when X and Y are not in the same map such as in dungeons etc, we default to 0 if it is not set
                                -- This will create a distance of 0 but it doesn't matter.
                                local distance = QuestieLib:Euclid(closestStarter[Quest.Id].x or 0, closestStarter[Quest.Id].y or 0, x or 0, y or 0);
                                iconsToDraw[Quest.Id][floor(distance)] = drawIcon;
                            end
                            --maxCount = maxCount + 1
                            --if maxPerType > 0 and maxCount > maxPerType then break; end
                        end
                        --if maxPerType > 0 and maxCount > maxPerType then break; end
                    end
                end
            elseif completed and Objective.AlreadySpawned then -- unregister notes
                for id, spawn in pairs(Objective.AlreadySpawned) do
                    for _, note in pairs(spawn.mapRefs) do
                        note:Unload();
                    end
                    for _, note in pairs(spawn.minimapRefs) do
                        note:Unload();
                    end
                    spawn.mapRefs = {}
                    spawn.minimapRefs = {}
                end
            end
        end
        local spawnedIcons = {}
        for questId, icons in pairs(iconsToDraw) do
            if(not spawnedIcons[questId]) then
                spawnedIcons[questId] = 0;
            end
            
            if(clusterMethod == "hotzone") then
                --This can be used to make distance ordered list..
                local orderedList = {}
                local tkeys = {}
                -- populate the table that holds the keys
                for k in pairs(icons) do tinsert(tkeys, k) end
                -- sort the keys
                table.sort(tkeys)
                -- use the keys to retrieve the values in the sorted order
                for _, distance in ipairs(tkeys) do
                    if(spawnedIcons[questId] > maxPerType) then
                        Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]", "Too many icons for quest:", questId)
                        break;
                    end
                    tinsert(orderedList, icons[distance]);
                end
                local range = QUESTIE_NOTES_CLUSTERMUL_HACK
                if orderedList and orderedList[1] and orderedList[1].Icon == ICON_TYPE_OBJECT then -- new clustering / limit code should prevent problems, always show all object notes
                    range = range * 0.2;  -- Only use 20% of the default range.
                end
                
                local hotzones = QuestieMap.utils:CalcHotzones(orderedList, range);

                for index, hotzone in pairs(hotzones or {}) do
                    if(spawnedIcons[questId] > maxPerType) then
                        Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]", "Too many icons for quest:", questId)
                        break;
                    end

                    --Any icondata will do because they are all the same
                    local icon = hotzone[1];


                    local midPoint = QuestieMap.utils:CenterPoint(hotzone);
                    --Disable old clustering.
                    icon.data.ClusterId = nil;
                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, midPoint.x, midPoint.y) -- clustering code takes care of duplicates as long as mindist is more than 0
                    if iconMap and iconMini then
                        tinsert(Objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                        tinsert(Objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
                    end
                    spawnedIcons[questId] = spawnedIcons[questId] + 1;
                end

                --Unused.
            else
                local tkeys = {}
                -- populate the table that holds the keys
                for k in pairs(icons) do tinsert(tkeys, k) end
                -- sort the keys
                table.sort(tkeys)
                -- use the keys to retrieve the values in the sorted order
                for _, distance in ipairs(tkeys) do
                    if(spawnedIcons[questId] > maxPerType) then
                        Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]", "Too many icons for quest:", questId)
                        break;
                    end
                    local icon = icons[distance];
                    local xcell = math.floor((icon.x * (QUESTIE_NOTES_CLUSTERMUL_HACK)));
                    local ycell = math.floor((icon.y * (QUESTIE_NOTES_CLUSTERMUL_HACK)));
                    if QuestieMap.MapCache_ClutterFix[icon.areaId] == nil then QuestieMap.MapCache_ClutterFix[icon.areaId] = {}; end
                    if QuestieMap.MapCache_ClutterFix[icon.areaId][xcell] == nil then QuestieMap.MapCache_ClutterFix[icon.areaId][xcell] = {}; end
                    if QuestieMap.MapCache_ClutterFix[icon.areaId][xcell][ycell] == nil then QuestieMap.MapCache_ClutterFix[icon.areaId][xcell][ycell] = {}; end
                    if((not icon.data.ClusterId) or (not QuestieMap.MapCache_ClutterFix[icon.areaId][xcell][ycell][icon.data.ClusterId])) then
                        --Questie:Print(questId, distance);
                        local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, icon.x, icon.y) -- clustering code takes care of duplicates as long as mindist is more than 0
                        if iconMap and iconMini then
                            tinsert(Objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                            tinsert(Objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
                        end
                        spawnedIcons[questId] = spawnedIcons[questId] + 1;
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
function QuestieQuest:Math_randomseed(seed)
    _randomSeed = seed
end
function QuestieQuest:Math_random(low_or_high_arg, high_arg)
    local low = nil
    local high = nil
    if low_or_high_arg ~= nil then
        if high_arg ~= nil then
            low = low_or_high_arg
            high = high_arg
        else
            low = 1
            high = low_or_high_arg
        end
    end

    _randomSeed = (_randomSeed * 214013 + 2531011) % 2^32;
    local rand = (math.floor(_randomSeed / 2^16) % 2^15) / 0x7fff;
    if high == nil then
        return rand
    end
    return low + math.floor(rand * high)
end

function QuestieQuest:PopulateObjectiveNotes(Quest) -- this should be renamed to PopulateNotes as it also handles finishers now
    if not Quest then return; end
    if QuestieQuest:IsComplete(Quest) then
        QuestieQuest:AddFinisher(Quest)
    end

    if not Quest.Color then -- todo: move to a better place
        QuestieQuest:Math_randomseed(Quest.Id)
        Quest.Color = {0.45 + QuestieQuest:Math_random() / 2, 0.45 + QuestieQuest:Math_random() / 2, 0.45 + QuestieQuest:Math_random() / 2}
    end

    -- we've already checked the objectives table by doing IsComplete
    -- if that changes, check it here
    local old = GetQuestLogSelection()
    for k, v in pairs(Quest.Objectives) do
        SelectQuestLogEntry(v.Index)
        local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, k, v, false);
        if not result then
            Questie:Error("[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', Quest.Name or "No quest name", Quest.Id or "No quest id", k or "No objective", err or "No error"));
        end
    end

    -- check for special (unlisted) DB objectives
    if Quest.SpecialObjectives then
        for _, objective in pairs(Quest.SpecialObjectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, Quest, 0, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', Quest.Name or "No quest name", Quest.Id or "No quest id", 0 or "No objective", err or "No error"));
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
    -- Old Select Code, maybe remove?
    local logId = GetQuestLogIndexByID(Quest.Id)
    local old = GetQuestLogSelection()
    SelectQuestLogEntry(logId)

    if Quest.Objectives == nil then
        Quest.Objectives = {}; -- TODO: remove after api bug is fixed!!!
        Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_OBJ_TABLE'));
    end

    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(Quest.Id);
    local logCount = Counthack(questObjectives);
    local dbCount = Counthack(Quest.ObjectiveData);

    for objectiveIndex, objective in pairs(questObjectives) do
        if(objective.type) then
            if Quest.Objectives[objectiveIndex] == nil then
                Quest.Objectives[objectiveIndex] = {}
            end
            Quest.Objectives[objectiveIndex].Index = objectiveIndex
            Quest.Objectives[objectiveIndex].QuestId = Quest.Id
            Quest.Objectives[objectiveIndex].QuestLogId = logId
            Quest.Objectives[objectiveIndex].QuestData = Quest
            Quest.Objectives[objectiveIndex]._lastUpdate = 0;
            Quest.Objectives[objectiveIndex].Description = objective.text;

            Quest.Objectives[objectiveIndex].Update = function(self)
                -- Old select code, do we need it?
                local old = GetQuestLogSelection()
                SelectQuestLogEntry(self.QuestLogId)
                --

                local now = GetTime();
                if now - self._lastUpdate < 0.5 then
                    if old then SelectQuestLogEntry(old); end
                    return {self.Collected, self.Needed, self.Completed} -- updated too recently
                end
                self._lastUpdate = now

                -- Use different variable names from above to avoid confusion.
                local qObjectives = QuestieQuest:GetAllLeaderBoardDetails(self.QuestId);

                if qObjectives and qObjectives[self.Index] then
                    local obj = qObjectives[self.Index];
                    if(obj.type) then
                        -- fixes for api bug
                        if not obj.numFulfilled then obj.numFulfilled = 0; end
                        if not obj.numRequired then obj.numRequired = 0; end
                        if not obj.finished then obj.finished = false; end -- ensure its boolean false and not nil (hack)

                        self.Type = obj.type;
                        self.Description = obj.text;
                        self.Collected = tonumber(obj.numFulfilled);
                        self.Needed = tonumber(obj.numRequired);
                        self.Completed = (self.Needed == self.Collected and self.Needed > 0) or (obj.finished and (self.Needed == 0 or (not self.Needed))) -- some objectives get removed on PLAYER_LOGIN because isComplete is set to true at random????
                    end
                end
                -- Old select code, do we need it?
                if old then SelectQuestLogEntry(old); end
                --
                return {self.Collected, self.Needed, self.Completed}
            end
            Quest.Objectives[objectiveIndex]:Update();

            -- If both the log and the db only have one objective, we can safely assume they are the same.
            if logCount == 1 and dbCount == 1 then
                Quest.Objectives[objectiveIndex].Id = Quest.ObjectiveData[1].Id
            elseif Quest.ObjectiveData ~= nil then

                local bestIndex = -1;
                local bestDistance = 99999;

                --Debug var
                local tempName = "";
                --
                -- try to find npc/item/object/event ID
                for objectiveIndexDB, objectiveDB in pairs(Quest.ObjectiveData) do
                    if objective.type == objectiveDB.Type then
                        -- TODO: use string distance to find closest, dont rely on exact match
                        
                        -- Fetch the name of the objective
                        local oName = nil;
                        if(objectiveDB.Type == "monster" and objectiveDB.Id) then
                            oName = slower(QuestieDB:GetNPC(objectiveDB.Id).name);
                        elseif(objectiveDB.Type == "object" and objectiveDB.Id) then
                            oName = slower(QuestieDB:GetObject(objectiveDB.Id).name);
                        elseif(objectiveDB.Type == "item" and objectiveDB.Id) then
                            --testVar = CHANGEME_Questie4_ItemDB[objectiveDB.Id]
                            --DEFAULT_CHAT_FRAME:AddMessage(CHANGEME_Questie4_ItemDB[objectiveDB.Id][1][])
                            local item = QuestieDB:GetItem(objectiveDB.Id);
                            if(item and item.Name) then
                                oName = slower(item.Name);-- this is capital letters for some reason...
                            else
                                local itemName = GetItemInfo(objectiveDB.Id)
                                if(itemName) then
                                    oName = itemName;
                                else
                                    oName = nil;
                                    --[[
                                    This is a good idea, but would require us to break out the objective identification code to a function
                                    that runs a specific quest. I instead try to pre-cache the items in CacheAllItemNames
                                    local item = Item:CreateFromItemID(objective.id)
                                    item:ContinueOnItemLoad(function()
                                        local itemName = GetItemInfo(objectiveDB.Id)
                                        oName = itemName;
                                    end)]]--
                                end
                            end
                        end
                        -- To lower the questlog objective text
                        local oDesc = slower(objective.text) or nil;
                        -- This is whaaaat?
                        -- local oText = slower(objectiveDB.Text or "");

                        if(oName and oDesc) then
                            local distance = QuestieDB:Levenshtein(oDesc, oName);
                            if(distance < bestDistance) then
                                bestDistance = distance;
                                bestIndex = objectiveIndexDB;
                                tempName = oName; --For debugging
                            end
                        elseif((oName == nil or oDesc == nil) and objectiveDB.Type ~= "item" and objectiveDB.Type ~= "monster") then
                            bestIndex = objectiveIndexDB;
                            tempName = oName; --For debugging
                            --We set the distance to 0 because otherwise other objectives might be closer...
                            bestDistance = 0;
                        end

                        -- Old
                        if(Quest.Objectives[objectiveIndex].Id == nil and GetLocale() ~= "enUS" and GetLocale() ~= "enGB") then
                            Quest.Objectives[objectiveIndex].Id = objectiveDB.Id;
                        end
                        -- ~OldQ
                    end
                end

                local objectiveDB = Quest.ObjectiveData[bestIndex]
                --Debug var
                local oDesc = slower(objective.text) or nil
                --
                if(bestIndex ~= -1 and objectiveDB) then
                    Questie:Debug(DEBUG_SPAM, "----> Objective", objective.text, "Dist:", bestDistance)
                    Questie:Debug(DEBUG_SPAM, "-->ID:", objectiveDB.Id)
                    Questie:Debug(DEBUG_SPAM, "-->Description:", oDesc)
                    Questie:Debug(DEBUG_SPAM, "-->Found:", tempName)
                    Quest.Objectives[objectiveIndex].Id = objectiveDB.Id;
                    Quest.Objectives[objectiveIndex].Coordinates = objectiveDB.Coordinates;
                    objectiveDB.ObjectiveRef = Quest.Objectives[objectiveIndex];
                end
            end
        end

        if (not Quest.Objectives[objectiveIndex]) or (not Quest.Objectives[objectiveIndex].Id) then
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ENTRY_ID', objective.type, objective.text))
        end
    end
    -- Old Select code do we need it?
    if old then SelectQuestLogEntry(old); end
    --

    -- find special unlisted objectives
    -- hack to remove misdetected unlisted (when qlog returns bad data for objective text on first try)
    local checkTime = GetTime();
    if Quest.HiddenObjectiveData then
        for index, objective in pairs(Quest.HiddenObjectiveData) do
            if not objective.ObjectiveRef then -- there was no qlog objective detected for this DB objective
                -- hack
                if not Quest.SpecialObjectives then
                    Quest.SpecialObjectives = {};
                end
                if objective.Type then
                    if objective.Type == "monster" then
                        local npc = QuestieDB:GetNPC(objective.Id);
                        if npc and npc.name then
                            objective.Description = npc.name
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
                    objective.Index = 64 + index -- offset to not conflict with real objectives
                    Quest.SpecialObjectives[objective.Description] = objective
                end
                --tinsert(Quest.SpecialObjectives, objective);
            end
        end
    end

    return Quest.Objectives;
end

function QuestieQuest:GetQuestHash(questId, isComplete)
    local hash = libC:fcs32init()
    local data = {}
    data.questId = questId
    data.isComplete = isComplete
    data.questObjectives = QuestieLib:GetQuestObjectives(questId);

    hash = libC:fcs32update(hash, libS:Serialize(data))
    hash = libC:fcs32final(hash)
    return hash
end

function QuestieQuest:GetQuestLogHashes()
    local questLogHashes = {}
    ExpandQuestHeader(0) -- Expand all headers

    local numEntries, _ = GetNumQuestLogEntries()
    for questLogIndex=1, numEntries do
        local _, _, _, isHeader, isCollapsed, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if isHeader then
            if isCollapsed then
                -- TODO
            end
        else
            local hash = QuestieQuest:GetQuestHash(questId, isComplete)
            tinsert(questLogHashes, questId, hash)
        end
    end
    return questLogHashes
end

function QuestieQuest:AddNewQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "AddNewQuestHash:", questId)
    local hash = QuestieQuest:GetQuestHash(questId, false)

    _QuestieQuest.questLogHashes[questId] = hash
end

function QuestieQuest:GetCurrentHashes()
    return _QuestieQuest.questLogHashes
end

function QuestieQuest:RemoveQuestHash(questId)
    Questie:Debug(DEBUG_DEVELOP, "RemoveQuestHash:", questId)
    _QuestieQuest.questLogHashes[questId] = nil
end

function QuestieQuest:CompareQuestHashes()
    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes")
    if _QuestieQuest.questLogHashes == nil then
        return
    end
    ExpandQuestHeader(0) -- Expand all headers

    local numEntries, _ = GetNumQuestLogEntries()
    for questLogIndex=1, numEntries do
        local _, _, _, isHeader, isCollapsed, isComplete, _, questId = GetQuestLogTitle(questLogIndex)
        if isHeader then
            if isCollapsed then
                -- TODO
            end
        else
            local oldhash = _QuestieQuest.questLogHashes[questId]
            if oldhash ~= nil then
                local newHash = QuestieQuest:GetQuestHash(questId, isComplete)

                if oldhash ~= newHash then
                    Questie:Debug(DEBUG_DEVELOP, "CompareQuestHashes: Hash changed for questId:", questId)
                    --[[local timer = nil;
                    timer = C_Timer.NewTicker(0.5, function()
                        if(QuestieLib:IsResponseCorrect(questId)) then
                            QuestieQuest:UpdateQuest(questId)
                            _QuestieQuest.questLogHashes[questId] = newHash
                            timer:Cancel();
                            Questie:Debug(DEBUG_DEVELOP, "Accept seems correct, cancel timer");
                        else   
                            Questie:Debug(DEBUG_CRITICAL, "Response is wrong for quest, waiting with timer");
                        end
                    end)]]--
                    QuestieQuest:SafeUpdateQuest(questId, newHash);
                end
            end
        end
    end
end

function QuestieQuest:SafeUpdateQuest(questId, hash, count)
    if(not count) then
        count = 0;
    end
    if(QuestieLib:IsResponseCorrect(questId)) then
        QuestieQuest:UpdateQuest(questId)
        _QuestieQuest.questLogHashes[questId] = hash
        Questie:Debug(DEBUG_DEVELOP, "Accept seems correct, cancel timer");
    else
        if(count < 50) then
            Questie:Debug(DEBUG_CRITICAL, "Response is wrong for quest, waiting with timer");
            C_Timer.After(0.1, function()
                QuestieQuest:SafeUpdateQuest(questId, hash, count + 1);
            end)
        else
            Questie:Debug(DEBUG_CRITICAL, "Didn't get a correct response after 50 tries, stopping");
        end
    end
end

--https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentation#C_QuestLog.GetQuestObjectives
--[[function _QuestieQuest:GetLeaderBoardDetails(objectiveIndex, questId)
    local questObjectives = C_QuestLog.GetQuestObjectives(questId)-- or {};
    if(questObjectives[objectiveIndex]) then
        local objective = questObjectives[objectiveIndex];
        local text = smatch(objective.text, "(.*)[：,:]");
        -- If nothing is matched, we should just add the text as is.
        if(text ~= nil) then
            objective.text = text;
        end
        return objective.type, objective.text, objective.numFulfilled, objective.numRequired, objective.finished;
    end
    return nil;
end]]--

-- Link contains test bench for regex in lua.
-- https://hastebin.com/anodilisuw.bash
local L_QUEST_MONSTERS_KILLED = QuestieLib:SanitizePattern(QUEST_MONSTERS_KILLED)
local L_QUEST_ITEMS_NEEDED = QuestieLib:SanitizePattern(QUEST_ITEMS_NEEDED)
local L_QUEST_OBJECTS_FOUND = QuestieLib:SanitizePattern(QUEST_OBJECTS_FOUND)
function QuestieQuest:GetAllLeaderBoardDetails(questId)
    local questObjectives = QuestieLib:GetQuestObjectives(questId);

    --Questie:Print(questId)
    for objectiveIndex, objective in pairs(questObjectives) do
        if(objective.text) then
            local text = objective.text;
            if(objective.type == "monster") then
                local i, j, monsterName = strfind(text, L_QUEST_MONSTERS_KILLED)

                if(monsterName and objective.text and strlen(monsterName) == strlen(objective.text)) then
                    --The above doesn't seem to work with the chinese, the row below tries to remove the extra numbers.
                    local cleanerText = smatch(monsterName or text, "(.*)：");
                    text = cleanerText
                else
                    text = monsterName;
                end
            elseif(objective.type == "item") then
                local i, j, itemName = strfind(text, L_QUEST_ITEMS_NEEDED)
                text = itemName;
            elseif(objective.type == "object") then
                local i, j, objectName = strfind(text, L_QUEST_OBJECTS_FOUND)
                text = objectName;
            end
            -- If the functions above do not give a good answer fall back to older regex to get something.
            if(text == nil) then
                text = smatch(objective.text, "^(.*):%s") or smatch(objective.text, "%s：(.*)$") or smatch(objective.text, "^(.*)：%s") or objective.text;
            end

            --If objective.text is nil, this will be nil, throw error!
            if(text ~= nil) then
                objective.text = strim(text);
            else
                Questie:Print("WARNING! [QuestieQuest]", "Could not split out the objective out of the objective text! Please report the error!", questId, objective.text)
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("ERROR! Something went wrong in GetAllLeaderBoardDetails"..tostring(questId).." - "..tostring(objective.text));
        end
    end
    return questObjectives;
end
--[[  KEEP THIS FOR NOW

            -- Look if it contains "slain"
            if(smatch(text, slain)) then
                --English first, chinese after
                text = smatch(objective.text, "(.*)"..slain.."%W*%d+/%d+") or smatch(objective.text, "%d+/%d+%W*"..slain.."(.*)")
                --Capital %W is required due to chinese not being alphanumerical
                --text = smatch(objective.text, '^(.*)%s+%w+:%s') or smatch(objective.text, '%s：%W+%s(.+)$');
            else
                --English first, chinese after
                text = smatch(objective.text, "^(.*):%s") or smatch(objective.text, "%s：(.*)$");
            end
]]--

--Draw a single available quest, it is used by the DrawAllAvailableQuests function.
function _QuestieQuest:DrawAvailableQuest(questObject) -- prevent recursion
    return _QuestieQuest:DrawAvailableQuest(questObject, false)
end

function _QuestieQuest:DrawAvailableQuest(questObject, noChildren)

    --If the object is nil we just return
    if (questObject == nil) then
        return false;
    end

    -- recheck IsDoable (shouldn't be needed)
    if not _QuestieQuest:IsDoable(questObject) then return false; end

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
            local obj = QuestieDB:GetObject(ObjectID)
            if(obj ~= nil and obj.spawns ~= nil) then
                for Zone, Spawns in pairs(obj.spawns) do
                    if(Zone ~= nil and Spawns ~= nil) then
                        for _, coords in ipairs(Spawns) do
                            local data = {}
                            data.Id = questObject.Id;
                            if questObject.Repeatable then
                                data.Icon = ICON_TYPE_REPEATABLE
                            else
                                data.Icon = ICON_TYPE_AVAILABLE
                            end
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data:GetIconScale()
                            data.Type = "available";
                            data.QuestData = questObject;
                            data.Name = obj.name

                            data.IsObjectiveNote = false
                            if(coords[1] == -1 or coords[2] == -1) then
                                if(instanceData[Zone] ~= nil) then
                                    for index, value in ipairs(instanceData[Zone]) do
                                        QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    end
                                end
                            else
                                QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                            end
                        end
                    end
                end
            end
        end
    elseif(questObject.Starts["NPC"] ~= nil)then
        for index, NPCID in ipairs(questObject.Starts["NPC"]) do
            local NPC = QuestieDB:GetNPC(NPCID)
            if (NPC ~= nil and NPC.spawns ~= nil and NPC.friendly) then
                --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                for Zone, Spawns in pairs(NPC.spawns) do
                    if(Zone ~= nil and Spawns ~= nil) then
                        --Questie:Debug("Zone", Zone)
                        --Questie:Debug("Qid:", questid)
                        for _, coords in ipairs(Spawns) do
                            --Questie:Debug("Coords", coords[1], coords[2])
                            local data = {}
                            data.Id = questObject.Id;
                            if questObject.Repeatable then
                                data.Icon = ICON_TYPE_REPEATABLE
                            else
                                data.Icon = ICON_TYPE_AVAILABLE
                            end
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data.GetIconScale();
                            data.Type = "available";
                            data.QuestData = questObject;
                            data.Name = NPC.name
                            data.IsObjectiveNote = false
                            --data.updateTooltip = function(data)
                            --    return {QuestieLib:PrintDifficultyColor(data.QuestData.Level, "[" .. data.QuestData.Level .. "] " .. data.QuestData.Name), "|cFFFFFFFFStarted by: |r|cFF22FF22" .. data.QuestData.NPCName, "QuestId:"..data.QuestData.Id}
                            --end
                            if(coords[1] == -1 or coords[2] == -1) then
                                if(instanceData[Zone] ~= nil) then
                                    for index, value in ipairs(instanceData[Zone]) do
                                        --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", zoneDataAreaIDToUiMapID[value[1]])
                                        --local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                        local z = value[1];
                                        local x = value[2];
                                        local y = value[3];

                                        -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                                        -- as we need the icon handle for the lines.
                                        if(NPC.waypoints and NPC.waypoints[z]) then
                                            local midX, midY = QuestieLib:CalculateWaypointMidPoint(NPC.waypoints[z]);
                                            x = midX or x;
                                            y = midY or y;
                                            -- The above code should do the same... remove this after testing it.
                                            --if(midX and midY) then
                                            --    x = midX;
                                            --    y = midY;
                                            --end
                                        end

                                        local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, z, x, y)

                                        if(NPC.waypoints and NPC.waypoints[z]) then
                                            local lineFrames = QuestieFramePool:CreateWaypoints(icon, NPC.waypoints[z]);
                                            for index, lineFrame in ipairs(lineFrames) do
                                                QuestieMap:DrawLineIcon(lineFrame, z, x, y);
                                                --HBDPins:AddWorldMapIconMap(Questie, lineFrame, zoneDataAreaIDToUiMapID[z], x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                                            end
                                        end

                                    end
                                end
                            else
                                local x = coords[1];
                                local y = coords[2];

                                -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                                -- as we need the icon handle for the lines.
                                if(NPC.waypoints and NPC.waypoints[Zone]) then
                                    local midX, midY = QuestieLib:CalculateWaypointMidPoint(NPC.waypoints[Zone]);
                                    x = midX or x;
                                    y = midY or y;
                                    -- The above code should do the same... remove this after testing it.
                                    --if(midX and midY) then
                                    --    x = midX;
                                    --    y = midY;
                                    --end
                                end

                                local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, Zone, x, y)

                                if(NPC.waypoints and NPC.waypoints[Zone]) then
                                  local lineFrames = QuestieFramePool:CreateWaypoints(icon, NPC.waypoints[Zone]);
                                  for index, lineFrame in ipairs(lineFrames) do
                                    QuestieMap:DrawLineIcon(lineFrame, Zone, x, y);
                                    --HBDPins:AddWorldMapIconMap(Questie, lineFrame, zoneDataAreaIDToUiMapID[Zone], x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                                  end
                                end
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
    for questid, qid in pairs(QuestieQuest.availableQuests) do
        --If the quest is not drawn draw the quest, otherwise skip.
        if(not QuestieMap.questIdFrames[questid]) then
            local Quest = QuestieDB:GetQuest(questid)
            --Draw a specific quest through the function
            _QuestieQuest:DrawAvailableQuest(Quest)
        end
        count = count + 1
    end
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", QuestieLocale:GetUIString('DEBUG_DRAW', count, QuestiePlayer:GetPlayerLevel()));
end

function _QuestieQuest:IsDoable(questObject)
    if not questObject then
        return false;
    end
    if questObject.Hidden then
        return false;
    end
    if Questie.db.char.hidden[questObject.Id] then
        return false;
    end
    if questObject.NextQuestInChain then
        if Questie.db.char.complete[questObject.NextQuestInChain] or QuestiePlayer.currentQuestlog[questObject.NextQuestInChain] then
            return false
        end
    end
    --Run though the requiredQuests
    if questObject.ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for k, v in pairs(questObject.ExclusiveQuestGroup) do
            if Questie.db.char.complete[v] or QuestiePlayer.currentQuestlog[v] then
                return false
            end
        end
    end
    if questObject.parentQuest and not _QuestieQuest:IsParentQuestActive(questObject.parentQuest) then
        return false
    end

    -- check if npc is friendly
    if questObject.Starts["NPC"] ~= nil then
        local hasValidNPC = false
        for _, id in ipairs(questObject.Starts["NPC"]) do
            if QuestieDB:GetNPC(id).friendly then
                hasValidNPC = true
                break
            end
        end
        if not hasValidNPC then
            return false
        end
    end

    if QuestieProfessions:HasProfessionAndSkill(questObject.requiredSkill) == false then
        return false
    end

    if QuestieProfessions:HasReputation(questObject.requiredMinRep) == false then
        return false
    end

    -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
    if questObject.preQuestGroup ~= nil and next(questObject.preQuestGroup) ~= nil then
        return _QuestieQuest:IsPreQuestGroupFulfilled(questObject.preQuestGroup)
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    if questObject.preQuestSingle ~= nil and next(questObject.preQuestSingle) ~= nil then
        return _QuestieQuest:IsPreQuestSingleFulfilled(questObject.preQuestSingle)
    end

    return true
end

function _QuestieQuest:IsPreQuestGroupFulfilled(preQuestGroup)
    for _, preQuestId in pairs(preQuestGroup) do
        -- If a quest is not complete and no exlusive quest is complete, the requirement is not fulfilled
        if not Questie.db.char.complete[preQuestId] then
            local preQuest = QuestieDB:GetQuest(preQuestId);
            if preQuest.ExclusiveQuestGroup == nil then
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

function _QuestieQuest:IsPreQuestSingleFulfilled(preQuestSingle)
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

--TODO Check that this function does what it is supposed to...
function QuestieQuest:CalculateAvailableQuests()
    local playerLevel = QuestiePlayer:GetPlayerLevel()
    
    local minLevel = playerLevel - Questie.db.global.minLevelFilter
    local maxLevel = playerLevel + Questie.db.global.maxLevelFilter

    
    if(not Questie.db.char.manualMinLevelOffset) then
        minLevel = playerLevel - GetQuestGreenRange();
    end

    QuestieQuest.availableQuests = {}

    for questID, v in pairs(QuestieDB.questData) do
        --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.

        if((not Questie.db.char.complete[questID]) and (not QuestieCorrections.hiddenQuests[questID]) and (not QuestiePlayer.currentQuestlog[questID])) then
            local quest = QuestieDB:GetQuest(questID)

            if _QuestieQuest:LevelRequirementsFulfilled(quest, playerLevel, minLevel, maxLevel) or _QuestieQuest:IsParentQuestActive(quest.parentQuest) then
                if _QuestieQuest:IsDoable(quest) then
                    QuestieQuest.availableQuests[questID] = questID
                end
            else
                --If the quests are not within level range we want to unload them
                --(This is for when people level up or change settings etc)
                QuestieMap:UnloadQuestFrames(questID);
            end
        end
    end
end

function _QuestieQuest:LevelRequirementsFulfilled(quest, playerLevel, minLevel, maxLevel)
    return (quest.Level >= minLevel or Questie.db.char.lowlevel) and quest.Level <= maxLevel and quest.requiredLevel <= playerLevel
end

-- We always want to show a quest if it is a childQuest and its parent is in the quest log
function _QuestieQuest:IsParentQuestActive(parentID)
    if parentID == nil or parentID == 0 then
        return false
    end
    if QuestiePlayer.currentQuestlog[parentID] then
        return true
    end
    return false
end
