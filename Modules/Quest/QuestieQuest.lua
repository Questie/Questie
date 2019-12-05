---@class QuestieQuest
local QuestieQuest = QuestieLoader:CreateModule("QuestieQuest");
-------------------------
--Import modules.
-------------------------
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions");
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation");
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration");
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestieHash
local QuestieHash = QuestieLoader:ImportModule("QuestieHash");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local _QuestieQuest = QuestieQuest.private
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

QuestieQuest.availableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD


local HBD = LibStub("HereBeDragonsQuestie-2.0")

function QuestieQuest:Initialize()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_GET_QUEST_COMP'))
    --GetQuestsCompleted(Questie.db.char.complete)
    Questie.db.char.complete = GetQuestsCompleted()
    QuestieProfessions:Update()
    QuestieReputation:Update()

    QuestieHash:LoadQuestLogHashes()
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
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if not quest then
            return
        end

        -- Clear user-specifc data from quest object (maybe we should refactor into Quest.session.* so we can do Quest.session = nil to reset easier
        quest.AlreadySpawned = nil
        quest.Objectives = nil

        -- reference is still held elswhere
        if quest.SpecialObjectives then for _,s in pairs(quest.SpecialObjectives) do s.AlreadySpawned = nil end end
        quest.SpecialObjectives = nil
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
end

-- this is only needed for reset, normally special objectives don't need to update
local function _UpdateSpecials(questId)
    local quest = QuestieDB:GetQuest(questId)
    if quest and quest.SpecialObjectives then
        if quest.SpecialObjectives then
            for _, objective in pairs(quest.SpecialObjectives) do
                local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, 0, objective, true);
                if not result then
                    Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
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
            --After a smooth reset we should scale stuff.
            --QuestieMap:UpdateZoomScale()
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
    local questieGlobalDB = Questie.db.global
    if questieGlobalDB.enableAvailable then
        QuestieQuest:DrawAllAvailableQuests();
    end

    -- Update hidden status of quest notes
    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        for index, frameName in ipairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            if icon ~= nil and icon.data then
                if (QuestieQuest.NotesHidden or (((not questieGlobalDB.enableObjectives) and (icon.data.Type == "monster" or icon.data.Type == "object" or icon.data.Type == "event" or icon.data.Type == "item"))
                 or ((not questieGlobalDB.enableTurnins) and icon.data.Type == "complete")
                 or ((not questieGlobalDB.enableAvailable) and icon.data.Type == "available"))
                 or ((not questieGlobalDB.enableMapIcons) and (not icon.miniMapIcon))
                 or ((not questieGlobalDB.enableMiniMapIcons) and (icon.miniMapIcon))) or (icon.data.ObjectiveData and icon.data.ObjectiveData.HideIcons) or (icon.data.QuestData and icon.data.QuestData.HideIcons and icon.data.Type ~= "complete") then
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
                    ((not questieGlobalDB.enableMapIcons) and (not icon.miniMapIcon)) or
                    ((not questieGlobalDB.enableMiniMapIcons) and (icon.miniMapIcon))
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
        QuestieHash:AddNewQuestHash(questId)

        local quest = QuestieDB:GetQuest(questId)
        if quest then
            -- we also need to remove exclusivegroup icons (TESTED)
            if quest.ExclusiveQuestGroup then
                for k, qId in pairs(quest.ExclusiveQuestGroup) do
                    QuestieMap:UnloadQuestFrames(qId);
                end
            end

            QuestiePlayer.currentQuestlog[questId] = quest
            QuestieQuest:PopulateQuestLogInfo(quest)
            QuestieQuest:PopulateObjectiveNotes(quest)
        else
            QuestiePlayer.currentQuestlog[questId] = questId
        end

        --TODO: Insert call to drawing objective logic here!
        --QuestieQuest:TrackQuest(questId);
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()

        for availableQuestId, alsoQuestId in pairs(QuestieQuest.availableQuests) do
            if not _QuestieQuest:IsDoable(QuestieDB:GetQuest(availableQuestId)) then
                QuestieMap:UnloadQuestFrames(availableQuestId, ICON_TYPE_AVAILABLE);
            end
        end

        --For safety, remove all these icons.
        QuestieMap:UnloadQuestFrames(questId, ICON_TYPE_AVAILABLE);
        --Broadcast an update.
        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId);
    else
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ACCEPT_QUEST', questId), " Warning: Quest already existed, not adding");
    end

end

function QuestieQuest:CompleteQuest(quest)
    local questId = quest.Id
    QuestiePlayer.currentQuestlog[questId] = nil;
    -- Only quests that aren't repeatable should be marked complete, otherwise objectives for repeatable quests won't track correctly - #1433
    Questie.db.char.complete[questId] = not quest.Repeatable

    QuestieHash:RemoveQuestHash(questId)

    --This should probably be done first, because DrawAllAvailableQuests looks at QuestieMap.questIdFrames[QuestId] to add available
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests();

    QuestieMap:UnloadQuestFrames(questId);
    if(QuestieMap.questIdFrames[questId]) then
        Questie:Print("ERROR: Just removed all frames but the framelist seems to still be there!", questId);
    end
    QuestieTooltips:RemoveQuest(questId)
    --Unload all the quest frames from the map.
    --QuestieMap:UnloadQuestFrames(QuestId); --We are currently redrawing everything so we might as well not use this now


    QuestieTracker:RemoveQuest(questId)
    QuestieTracker:Update()

    --For safety, remove all these icons.
    QuestieMap:UnloadQuestFrames(questId, ICON_TYPE_COMPLETE);

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_COMPLETE_QUEST', questId));
end

function QuestieQuest:AbandonedQuest(questId)
    QuestieTooltips:RemoveQuest(questId)
    if(QuestiePlayer.currentQuestlog[questId]) then
        QuestiePlayer.currentQuestlog[questId] = nil

        QuestieHash:RemoveQuestHash(questId)

        --Unload all the quest frames from the map.
        QuestieMap:UnloadQuestFrames(questId);

        local quest = QuestieDB:GetQuest(questId);
        if quest then
            quest.Objectives = nil;
            quest.AlreadySpawned = nil; -- temporary fix for "special objectives" remove later
        end
        --The old data for notes are still there, we don't need to recalulate data.
        --_QuestieQuest:DrawAvailableQuest(quest)

        -- yes we do, since abandoning can unlock more than 1 quest, or remove unlocked quests
        for k, v in pairs(QuestieQuest.availableQuests) do
            if not _QuestieQuest:IsDoable(QuestieDB:GetQuest(k)) then
                QuestieMap:UnloadQuestFrames(k);
            end
        end
        QuestieQuest:CalculateAvailableQuests()
        QuestieQuest:DrawAllAvailableQuests()

        QuestieTracker:RemoveQuest(questId)
        QuestieTracker:Update()

        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ABANDON_QUEST', questId));
    end
end

function QuestieQuest:UpdateQuest(questId)
    local quest = QuestieDB:GetQuest(questId)
    if quest and not Questie.db.char.complete[questId] then
        QuestieQuest:PopulateQuestLogInfo(quest)
        QuestieQuest:GetAllQuestObjectives(quest) -- update quest log values in quest object
        QuestieQuest:UpdateObjectiveNotes(quest)
        local isComplete = QuestieQuest:IsComplete(quest)
        if isComplete == 1 then -- Quest is complete
            QuestieMap:UnloadQuestFrames(questId)
            QuestieQuest:AddFinisher(quest)
        elseif isComplete == -1 then -- Failed quests should be shown as available again
            QuestieMap:UnloadQuestFrames(questId)
            _QuestieQuest:DrawAvailableQuest(quest)
        else
            --DEFAULT_CHAT_FRAME:AddMessage("Still not finished " .. QuestId);
        end
        QuestieTracker:Update()

        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId)
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
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                QuestiePlayer.currentQuestlog[questId] = quest
                QuestieQuest:PopulateQuestLogInfo(quest)
                QuestieQuest:PopulateObjectiveNotes(quest)
                if title and strlen(title) > 1 then
                    quest.LocalizedName = title
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
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                QuestiePlayer.currentQuestlog[questId] = quest
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

--@param quest QuestieQuest @The quest to check for completion
--@return integer @Complete = 1, Failed = -1, Incomplete = 0
function QuestieQuest:IsComplete(quest)
    local questId = quest.Id
    local questLogIndex = GetQuestLogIndexByID(questId)
    local _, _, _, _, _, isComplete, _, _, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(questLogIndex)

    if isComplete ~= nil then
        return isComplete -- 1 if the quest is completed, -1 if the quest is failed
    end

    isComplete = IsQuestComplete(questId) -- true if the quest is both in the quest log and complete, false otherwise
    if isComplete then
        return 1
    end

    return 0
end

-- iterate all notes, update / remove as needed
function QuestieQuest:UpdateObjectiveNotes(quest)
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes:", quest.Id)
    if quest.Objectives then
        for k, v in pairs(quest.Objectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, k, v);
            if not result then
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_POP_ERROR', quest.name, quest.Id, k, err));
            end
        end
    end
end

function QuestieQuest:AddFinisher(quest)
    --We should never ever add the quest if IsQuestFlaggedComplete true.
    local questId = quest.Id
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", "Adding finisher for quest ", questId)

    if(QuestiePlayer.currentQuestlog[questId] and IsQuestFlaggedCompleted(questId) == false and IsQuestComplete(questId) and not Questie.db.char.complete[questId]) then
        local finisher = nil
        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                finisher = QuestieDB:GetNPC(quest.Finisher.Id)
            elseif quest.Finisher.Type == "object" then
                finisher = QuestieDB:GetObject(quest.Finisher.Id)
            else
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_UNHANDLE_FINISH', quest.Finisher.Type, questId, quest.name))
            end
        else
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_NO_FINISH', questId, quest.name))
        end
        if(finisher ~= nil and finisher.spawns ~= nil) then
            for finisherZone, spawns in pairs(finisher.spawns) do
                if(finisherZone ~= nil and spawns ~= nil) then
                    for _, coords in ipairs(spawns) do
                        local data = {}
                        data.Id = questId;
                        data.Icon = ICON_TYPE_COMPLETE;
                        data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                        data.IconScale = data:GetIconScale();
                        data.Type = "complete";
                        data.QuestData = quest;
                        data.Name = finisher.name
                        data.IsObjectiveNote = false
                        if(coords[1] == -1 or coords[2] == -1) then
                            if(InstanceLocations[finisherZone] ~= nil) then
                                for _, value in ipairs(InstanceLocations[finisherZone]) do
                                    --QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", ZoneDataAreaIDToUiMapID[value[1]])
                                    --local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    local zone = value[1];
                                    local x = value[2];
                                    local y = value[3];

                                    -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                                    -- as we need the icon handle for the lines.
                                    if(finisher.waypoints and finisher.waypoints[zone]) then
                                        local midX, midY = QuestieLib:CalculateWaypointMidPoint(finisher.waypoints[zone]);
                                        x = midX or x;
                                        y = midY or y;
                                        -- The above code should do the same... remove this after testing it.
                                        --if(midX and midY) then
                                        --    x = midX;
                                        --    y = midY;
                                        --end
                                    end

                                    local icon, _ = QuestieMap:DrawWorldIcon(data, zone, x, y)

                                    if(finisher.waypoints and finisher.waypoints[zone]) then
                                        QuestieMap:DrawWaypoints(icon, finisher.waypoints[zone], zone, x, y)
                                    end
                                end
                            end
                        else
                            --QuestieMap:DrawWorldIcon(data, Zone, coords[1], coords[2])
                            local x = coords[1];
                            local y = coords[2];

                            -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                            -- as we need the icon handle for the lines.
                            if(finisher.waypoints and finisher.waypoints[finisherZone]) then
                                local midX, midY = QuestieLib:CalculateWaypointMidPoint(finisher.waypoints[finisherZone]);
                                x = midX or x;
                                y = midY or y;
                                -- The above code should do the same... remove this after testing it.
                                --if(midX and midY) then
                                --    x = midX;
                                --    y = midY;
                                --end
                            end

                            local icon, _ = QuestieMap:DrawWorldIcon(data, finisherZone, x, y)

                            if(finisher.waypoints and finisher.waypoints[finisherZone]) then
                                QuestieMap:DrawWaypoints(icon, finisher.waypoints[finisherZone], finisherZone, x, y)
                            end
                        end
                    end
                end
            end
        end
    end
end


-- this is for forcing specific things on to the map (That aren't quest related)
-- label and customScale can be nil
function QuestieQuest:ForceToMap(type, id, label, customScale)
    if _QuestieQuest.objectiveSpawnListCallTable[type] and type ~= "event" then
        local mapRefs = {}
        local miniRefs = {}
        --local spawnData = _QuestieQuest.objectiveSpawnListCallTable[type](id)[id]
        for id, spawnData in pairs(_QuestieQuest.objectiveSpawnListCallTable[type](id)) do
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

    if _QuestieQuest.objectiveSpawnListCallTable[Objective.Type] and (not Objective.spawnList) then
        Objective.spawnList = _QuestieQuest.objectiveSpawnListCallTable[Objective.Type](Objective.Id, Objective);
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
        QuestieLib:MathRandomSeed(Quest.Id + 32768 * ObjectiveIndex)
        Objective.Color = {0.45 + QuestieLib:MathRandom() / 2, 0.45 + QuestieLib:MathRandom() / 2, 0.45 + QuestieLib:MathRandom() / 2}
    end

    if (not Objective.registeredItemTooltips) and Objective.Type == "item" and (not BlockItemTooltips) and Objective.Id then -- register item tooltip (special case)
        local item = QuestieDB:GetItem(Objective.Id);
        if item and item.name then
            QuestieTooltips:RegisterTooltip(Quest.Id, "i_" .. item.Id, Objective);
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
                                drawIcon.UIMapId = ZoneDataAreaIDToUiMapID[zone];
                                drawIcon.x = spawn[1];
                                drawIcon.y = spawn[2];
                                local x, y, instance = HBD:GetWorldCoordinatesFromZone(drawIcon.x/100, drawIcon.y/100, ZoneDataAreaIDToUiMapID[zone])
                                -- There are instances when X and Y are not in the same map such as in dungeons etc, we default to 0 if it is not set
                                -- This will create a distance of 0 but it doesn't matter.
                                local distance = QuestieLib:Euclid(closestStarter[Quest.Id].x or 0, closestStarter[Quest.Id].y or 0, x or 0, y or 0);
                                drawIcon.distance = distance or 0;
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

            --This can be used to make distance ordered list..
            local iconCount = 0;
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
                iconCount = iconCount + 1;
                tinsert(orderedList, icons[distance]);
            end
            local range = QUESTIE_CLUSTER_DISTANCE
            if orderedList and orderedList[1] and orderedList[1].Icon == ICON_TYPE_OBJECT then -- new clustering / limit code should prevent problems, always show all object notes
                range = range * 0.2;  -- Only use 20% of the default range.
            end

            local hotzones = QuestieMap.utils:CalcHotzones(orderedList, range, iconCount);

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
        end
        if not hasSpawnHack then-- used to check if we have bad data due to API delay. Remove this check once the API bug is dealt with properly
            Objective.spawnList = nil -- reset the list so it can be regenerated with hopefully better quest log data
        end
        if hasTooltipHack then
            Objective.registeredTooltips = true
        end
    end
end

function QuestieQuest:PopulateObjectiveNotes(quest) -- this should be renamed to PopulateNotes as it also handles finishers now
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:PopulateObjectiveNotes]", "Populating objectives for:", quest.Id)
    if not quest then return; end
    if QuestieQuest:IsComplete(quest) == 1 then
        QuestieQuest:AddFinisher(quest)
        return
    end

    if not quest.Color then -- todo: move to a better place
        QuestieLib:MathRandomSeed(quest.Id)
        quest.Color = {0.45 + QuestieLib:MathRandom() / 2, 0.45 + QuestieLib:MathRandom() / 2, 0.45 + QuestieLib:MathRandom() / 2}
    end

    -- we've already checked the objectives table by doing IsComplete
    -- if that changes, check it here
    local old = GetQuestLogSelection()
    for k, v in pairs(quest.Objectives) do
        SelectQuestLogEntry(v.Index)
        local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, k, v, false);
        if not result then
            local major, minor, patch = QuestieLib:GetAddonVersionInfo();
            local version = "v"..(major or "").."."..(minor or "").."."..(patch or "");--Doing it this way to keep it 100% safe.
            Questie:Error("[QuestieQuest]: " .. version .. " - " .. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', quest.name or "No quest name", quest.Id or "No quest id", k or "No objective", err or "No error"));
        end
    end

    -- check for special (unlisted) DB objectives
    if quest.SpecialObjectives then
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, 0, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. QuestieLocale:GetUIString('DEBUG_POPULATE_ERR', quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
        end
    end
    if old then
        SelectQuestLogEntry(old)
    end

end
function QuestieQuest:PopulateQuestLogInfo(quest)
    --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta1:", Quest.Id, Quest.Name)
    if quest.Objectives == nil then
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateQuestLogInfo: ".. QuestieLocale:GetUIString('DEBUG_POPTABLE'))
        quest.Objectives = {};
    end
    local logID = GetQuestLogIndexByID(quest.Id);
    if logID ~= 0 then
        _, _, _, _, _, quest.isComplete, _, _, _, _, _, _, _, _, _, quest.isHidden = GetQuestLogTitle(logID)
        if quest.isComplete ~= nil and quest.isComplete == 1 then
            quest.isComplete = true
        end
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta:", quest.isComplete, quest.name)
    else
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Error: No logid:", quest.name, quest.Id )
    end
    QuestieQuest:GetAllQuestObjectives(quest)
end

--Use the category order to draw the quests and trust the database order.
--/dump QuestieQuest:GetAllQuestObjectives(24475)
function QuestieQuest:GetAllQuestObjectives(quest)
    -- Old Select Code, maybe remove?
    local logId = GetQuestLogIndexByID(quest.Id)
    local old = GetQuestLogSelection()
    SelectQuestLogEntry(logId)

    if quest.Objectives == nil then
        quest.Objectives = {}; -- TODO: remove after api bug is fixed!!!
        Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_OBJ_TABLE'));
    end

    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(quest.Id);
    local logCount = Counthack(questObjectives);
    local dbCount = Counthack(quest.ObjectiveData);

    for objectiveIndex, objective in pairs(questObjectives) do
        if(objective.type) then
            if quest.Objectives[objectiveIndex] == nil then
                quest.Objectives[objectiveIndex] = {}
            end
            quest.Objectives[objectiveIndex].Index = objectiveIndex
            quest.Objectives[objectiveIndex].QuestId = quest.Id
            quest.Objectives[objectiveIndex].QuestLogId = logId
            quest.Objectives[objectiveIndex].QuestData = quest
            quest.Objectives[objectiveIndex]._lastUpdate = 0;
            quest.Objectives[objectiveIndex].Description = objective.text;

            quest.Objectives[objectiveIndex].Update = function(self)
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
            quest.Objectives[objectiveIndex]:Update();

            -- If both the log and the db only have one objective, we can safely assume they are the same.
            if logCount == 1 and dbCount == 1 then
                quest.Objectives[objectiveIndex].Id = quest.ObjectiveData[1].Id
            elseif quest.ObjectiveData ~= nil then

                local bestIndex = -1;
                local bestDistance = 99999;

                --Debug var
                local tempName = "";
                --
                -- try to find npc/item/object/event ID
                for objectiveIndexDB, objectiveDB in pairs(quest.ObjectiveData) do
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
                            if(item and item.name) then
                                oName = slower(item.name);-- this is capital letters for some reason...
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
                        -- This is used for quests where the objective text and object/NPC/whatever does not correspond with eachother
                        -- examples https://classic.wowhead.com/quest=3463/set-them-ablaze - https://classic.wowhead.com/quest=2988/witherbark-cages
                        local oText = slower(objectiveDB.Text or "");

                        if((oName or (oText and oText ~= "")) and oDesc) then
                            local nameDistance = QuestieLib:Levenshtein(oDesc, oName or "");
                            local textDistance = QuestieLib:Levenshtein(oDesc, oText);
                            if(math.min(nameDistance, textDistance) < bestDistance) then
                                bestDistance = math.min(nameDistance, textDistance);
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
                        if(quest.Objectives[objectiveIndex].Id == nil and GetLocale() ~= "enUS" and GetLocale() ~= "enGB") then
                            quest.Objectives[objectiveIndex].Id = objectiveDB.Id;
                        end
                        -- ~OldQ
                    end
                end

                local objectiveDB = quest.ObjectiveData[bestIndex]
                --Debug var
                local oDesc = slower(objective.text) or nil
                --
                if(bestIndex ~= -1 and objectiveDB) then
                    Questie:Debug(DEBUG_SPAM, "----> Objective", objective.text, "Dist:", bestDistance)
                    Questie:Debug(DEBUG_SPAM, "-->ID:", objectiveDB.Id)
                    Questie:Debug(DEBUG_SPAM, "-->Description:", oDesc)
                    Questie:Debug(DEBUG_SPAM, "-->Found:", tempName)
                    quest.Objectives[objectiveIndex].Id = objectiveDB.Id;
                    quest.Objectives[objectiveIndex].Coordinates = objectiveDB.Coordinates;
                    objectiveDB.ObjectiveRef = quest.Objectives[objectiveIndex];
                end
            end
        end

        if (not quest.Objectives[objectiveIndex]) or (not quest.Objectives[objectiveIndex].Id) then
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString('DEBUG_ENTRY_ID', objective.type, objective.text))
        end
    end
    -- Old Select code do we need it?
    if old then SelectQuestLogEntry(old); end
    --

    -- find special unlisted objectives
    -- hack to remove misdetected unlisted (when qlog returns bad data for objective text on first try)
    local checkTime = GetTime();
    if quest.HiddenObjectiveData then
        for index, objective in pairs(quest.HiddenObjectiveData) do
            if not objective.ObjectiveRef then -- there was no qlog objective detected for this DB objective
                -- hack
                if not quest.SpecialObjectives then
                    quest.SpecialObjectives = {};
                end
                if objective.Type then
                    if objective.Type == "monster" then
                        local npc = QuestieDB:GetNPC(objective.Id);
                        if npc and npc.name then
                            objective.Description = npc.name
                        end
                    elseif objective.Type == "item" then
                        local item = QuestieDB:GetItem(objective.Id);
                        if item and item.name then
                            objective.Description = item.name
                        end
                    elseif objective.Type == "event" then
                        objective.Description = "Event Trigger"
                    end
                end
                if not objective.Description then objective.Description = "Hidden objective"; end

                if not quest.SpecialObjectives[objective.Description] then
                    objective.QuestData = quest
                    objective.QuestId = quest.Id
                    objective.Update = function() end
                    objective.checkTime = checkTime
                    objective.Index = 64 + index -- offset to not conflict with real objectives
                    quest.SpecialObjectives[objective.Description] = objective
                end
                --tinsert(Quest.SpecialObjectives, objective);
            end
        end
    end

    return quest.Objectives;
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

                if((monsterName and objective.text and strlen(monsterName) == strlen(objective.text)) or not monsterName) then
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
                            data.Icon = _QuestieQuest:GetQuestIcon(questObject)
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data:GetIconScale()
                            data.Type = "available";
                            data.QuestData = questObject;
                            data.Name = obj.name

                            data.IsObjectiveNote = false
                            if(coords[1] == -1 or coords[2] == -1) then
                                if(InstanceLocations[Zone] ~= nil) then
                                    for index, value in ipairs(InstanceLocations[Zone]) do
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
                for npcZone, Spawns in pairs(NPC.spawns) do
                    if(npcZone ~= nil and Spawns ~= nil) then
                        --Questie:Debug("Zone", Zone)
                        --Questie:Debug("Qid:", questid)
                        for _, coords in ipairs(Spawns) do
                            --Questie:Debug("Coords", coords[1], coords[2])
                            local data = {}
                            data.Id = questObject.Id;
                            data.Icon = _QuestieQuest:GetQuestIcon(questObject)
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
                                if(InstanceLocations[npcZone] ~= nil) then
                                    for _, value in ipairs(InstanceLocations[npcZone]) do
                                        --Questie:Debug(DEBUG_SPAM, "Conv:", Zone, "To:", ZoneDataAreaIDToUiMapID[value[1]])
                                        --local icon, minimapIcon = QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                        local zone = value[1];
                                        local x = value[2];
                                        local y = value[3];

                                        -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                                        -- as we need the icon handle for the lines.
                                        if(NPC.waypoints and NPC.waypoints[zone]) then
                                            local midX, midY = QuestieLib:CalculateWaypointMidPoint(NPC.waypoints[zone]);
                                            x = midX or x;
                                            y = midY or y;
                                            -- The above code should do the same... remove this after testing it.
                                            --if(midX and midY) then
                                            --    x = midX;
                                            --    y = midY;
                                            --end
                                        end

                                        local icon, _ = QuestieMap:DrawWorldIcon(data, zone, x, y)

                                        if(NPC.waypoints and NPC.waypoints[zone]) then
                                            QuestieMap:DrawWaypoints(icon, NPC.waypoints[zone], zone, x, y)
                                        end
                                    end
                                end
                            else
                                local x = coords[1];
                                local y = coords[2];

                                -- Calculate mid point if waypoints exist, we need to do this before drawing the lines
                                -- as we need the icon handle for the lines.
                                if(NPC.waypoints and NPC.waypoints[npcZone]) then
                                    local midX, midY = QuestieLib:CalculateWaypointMidPoint(NPC.waypoints[npcZone]);
                                    x = midX or x;
                                    y = midY or y;
                                    -- The above code should do the same... remove this after testing it.
                                    --if(midX and midY) then
                                    --    x = midX;
                                    --    y = midY;
                                    --end
                                end

                                local icon, _ = QuestieMap:DrawWorldIcon(data, npcZone, x, y)

                                if(NPC.waypoints and NPC.waypoints[npcZone]) then
                                    QuestieMap:DrawWaypoints(icon, NPC.waypoints[npcZone], npcZone, x, y)
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
    for questId, _ in pairs(QuestieQuest.availableQuests) do

        --If the quest is not drawn draw the quest, otherwise skip.
        if(not QuestieMap.questIdFrames[questId]) then
            local quest = QuestieDB:GetQuest(questId)
            --Draw a specific quest through the function
            _QuestieQuest:DrawAvailableQuest(quest)
        else
            --We might have to update the icon in this situation (config changed/level up)
            for _, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                if frame and frame.data then
                    local newIcon = _QuestieQuest:GetQuestIcon(frame.data.QuestData)
                    if newIcon ~= frame.data.Icon then
                        frame:UpdateTexture(newIcon)
                    end
                end
            end
        end
        count = count + 1
    end
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", QuestieLocale:GetUIString('DEBUG_DRAW', count, QuestiePlayer:GetPlayerLevel()));
end

function _QuestieQuest:GetQuestIcon(questObject)
    local icon = {}
    if questObject.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        icon = ICON_TYPE_AVAILABLE_GRAY
    elseif questObject.Repeatable then
        icon = ICON_TYPE_REPEATABLE
    elseif(questObject:IsTrivial()) then
        icon = ICON_TYPE_AVAILABLE_GRAY
    else
        icon = ICON_TYPE_AVAILABLE
    end
    return icon
end

function _QuestieQuest:IsDoable(quest)
    if not quest then
        return false;
    end
    if quest.isHidden then
        return false;
    end
    if Questie.db.char.hidden[quest.Id] then
        return false;
    end
    if quest.nextQuestInChain then
        if Questie.db.char.complete[quest.nextQuestInChain] or QuestiePlayer.currentQuestlog[quest.nextQuestInChain] then
            return false
        end
    end
    -- Check if a quest which is exclusive to the current has already been completed or accepted
    -- If yes the current quest can't be accepted
    if quest.ExclusiveQuestGroup then -- fix (DO NOT REVERT, tested thoroughly)
        for k, v in pairs(quest.ExclusiveQuestGroup) do
            if Questie.db.char.complete[v] or QuestiePlayer.currentQuestlog[v] then
                return false
            end
        end
    end
    if quest.parentQuest then
        -- If the quest has a parent quest then only show it if the
        -- parent quest is in the quest log
        return _QuestieQuest:IsParentQuestActive(quest.parentQuest)
    end

    -- check if npc is friendly
    if quest.Starts["NPC"] ~= nil then
        local hasValidNPC = false
        for _, id in ipairs(quest.Starts["NPC"]) do
            if QuestieDB:GetNPC(id).friendly then
                hasValidNPC = true
                break
            end
        end
        if not hasValidNPC then
            return false
        end
    end

    if not QuestieProfessions:HasProfessionAndSkill(quest.requiredSkill) then
        return false
    end

    if not QuestieReputation:HasReputation(quest.requiredMinRep, quest.requiredMaxRep) then
        return false
    end

    -- Check the preQuestGroup field where every required quest has to be complete for a quest to show up
    if quest.preQuestGroup ~= nil and next(quest.preQuestGroup) ~= nil then
        return _QuestieQuest:IsPreQuestGroupFulfilled(quest.preQuestGroup)
    end

    -- Check the preQuestSingle field where just one of the required quests has to be complete for a quest to show up
    if quest.preQuestSingle ~= nil and next(quest.preQuestSingle) ~= nil then
        return _QuestieQuest:IsPreQuestSingleFulfilled(quest.preQuestSingle)
    end

    return true
end

function _QuestieQuest:IsPreQuestGroupFulfilled(preQuestGroup)
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
    local showRepeatableQuests = Questie.db.global.showRepeatableQuests

    if(not Questie.db.char.manualMinLevelOffset) then
        minLevel = playerLevel - GetQuestGreenRange();
    end

    QuestieQuest.availableQuests = {}

    for questID, v in pairs(QuestieDB.questData) do
        local quest = QuestieDB:GetQuest(questID)

        --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
        if(
            (not Questie.db.char.complete[questID]) and -- Don't show completed quests
            ((not QuestiePlayer.currentQuestlog[questID]) or QuestieQuest:IsComplete(quest) == -1) and -- Don't show quests if they're already in the quest log
            (not QuestieCorrections.hiddenQuests[questID]) and -- Don't show blacklisted quests
            ((not quest.Repeatable) or (quest.Repeatable and showRepeatableQuests))) then -- Show repeatable quests if the quest is repeatable and the option is enabled

            if quest and _QuestieQuest:LevelRequirementsFulfilled(quest, playerLevel, minLevel, maxLevel) then
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
