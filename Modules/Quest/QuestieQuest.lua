---@class QuestieQuest
local QuestieQuest = QuestieLoader:CreateModule("QuestieQuest")
local _QuestieQuest = QuestieQuest.private
-------------------------
--Import modules.
-------------------------
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:ImportModule("QuestieDBMIntegration")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieHash
local QuestieHash = QuestieLoader:ImportModule("QuestieHash")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

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

-- forward declaration
local _UnhideQuestIcons, _HideQuestIcons, _UnhideManualIcons, _HideManualIcons

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

function QuestieQuest:Initialize()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_GET_QUEST_COMP"))
    Questie.db.char.complete = GetQuestsCompleted()

    QuestieProfessions:Update()
    QuestieReputation:Update(true)

    QuestieHash:LoadQuestLogHashes()
end

function QuestieQuest:ToggleNotes(showIcons)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:ToggleNotes] showIcons:", showIcons)
    QuestieQuest:GetAllQuestIds() -- add notes that weren't added from previous hidden state

    if showIcons then
        _UnhideQuestIcons()
        _UnhideManualIcons()
    else
        _HideQuestIcons()
        _HideManualIcons()
    end
end

_UnhideQuestIcons = function()
    -- change map button
    if Questie.db.char.enabled then
        Questie_Toggle:SetText(QuestieLocale:GetUIString("QUESTIE_MAP_BUTTON_HIDE"));
    end

    local trackerHiddenQuests = Questie.db.char.TrackerHiddenQuests
    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        if (trackerHiddenQuests == nil) or (trackerHiddenQuests[questId] == nil) then -- Skip quests which are completly hidden from the Tracker menu
            for _, frameName in pairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                ---@type IconFrame
                local icon = _G[frameName];
                if icon.data == nil then
                    error("Desync! Icon has not been removed correctly, but has already been resetted. Skipping frame \"" .. frameName .. "\" for quest " .. questId)
                else
                    local objectiveString = tostring(questId) .. " " .. tostring(icon.data.ObjectiveIndex)
                    if (Questie.db.char.TrackerHiddenObjectives == nil) or (Questie.db.char.TrackerHiddenObjectives[objectiveString] == nil) then
                        if icon ~= nil and icon.hidden and (not icon:ShouldBeHidden()) then
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
        end
    end
end

_UnhideManualIcons = function()
    for _, frameList in pairs(QuestieMap.manualFrames) do
        for _, frameName in pairs(frameList) do
            local icon = _G[frameName];
            if icon ~= nil and icon.hidden and (not icon:ShouldBeHidden()) then -- check for function to make sure its a frame
                icon:FakeUnide()
            end
        end
    end
end

_HideQuestIcons = function()
    if (not Questie.db.char.enabled) then
        Questie_Toggle:SetText(QuestieLocale:GetUIString("QUESTIE_MAP_BUTTON_SHOW"));
    end

    for _, framelist in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(framelist) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            if icon ~= nil and (not icon.hidden) and icon:ShouldBeHidden() then -- check for function to make sure its a frame
                icon:FakeHide()
            end
            if (icon.data.QuestData.FadeIcons or (icon.data.ObjectiveData and icon.data.ObjectiveData.FadeIcons)) and icon.data.Type ~= "complete" then
                icon:FadeOut()
            else
                icon:FadeIn()
            end
        end
    end
end

_HideManualIcons = function()
    for _, frameList in pairs(QuestieMap.manualFrames) do
        for _, frameName in pairs(frameList) do
            local icon = _G[frameName];
            if icon ~= nil and (not icon.hidden) and icon:ShouldBeHidden() then -- check for function to make sure its a frame
                icon:FakeHide()
            end
        end
    end
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
        for index, frameName in pairs(framelist) do
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
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, 0, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. QuestieLocale:GetUIString("DEBUG_POPULATE_ERR", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
        end
    end
end

function QuestieQuest:AddAllNotes()
    QuestieQuest.availableQuests = {} -- reset available quest db

    -- draw available quests
    QuestieQuest:GetAllQuestIdsNoObjectives()
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

    -- draw quests
    for quest in pairs (QuestiePlayer.currentQuestlog) do
        QuestieQuest:UpdateQuest(quest)
        _UpdateSpecials(quest)
    end
end

function QuestieQuest:Reset()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:Reset]")
    -- clear all notes
    QuestieQuest:ClearAllNotes()


    -- reset quest log and tooltips
    QuestiePlayer.currentQuestlog = {}
    QuestieTooltips.tooltipLookup = {}

    -- make sure complete db is correct
    Questie.db.char.complete = GetQuestsCompleted()
    QuestieProfessions:Update()
    QuestieReputation:Update(false)

    QuestieQuest:AddAllNotes()
end

function QuestieQuest:SmoothReset() -- use timers to reset progressively instead of all at once
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:SmoothReset]")
    if QuestieQuest._isResetting then
        QuestieQuest._resetAgain = true
        return
    end
    QuestieQuest._isResetting = true
    QuestieQuest._resetNeedsAvailables = false
    QuestieQuest._nextRestQuest = next(QuestiePlayer.currentQuestlog)
    
    -- bit of a hack (there has to be a better way to do logic like this
    QuestieDBMIntegration:ClearAll()
    local stepTable = {
        function()
            return #QuestieMap._mapDrawQueue == 0 and #QuestieMap._minimapDrawQueue == 0 -- wait until draw queue is finished
        end,
        function() 
            QuestieQuest:ClearAllNotes() 
            return true 
        end,
        function() 
            return #QuestieMap._mapDrawQueue == 0 and #QuestieMap._minimapDrawQueue == 0 -- wait until draw queue is finished
        end,
        function()
            -- reset quest log and tooltips
            QuestiePlayer.currentQuestlog = {}
            QuestieTooltips.tooltipLookup = {}

            -- make sure complete db is correct
            Questie.db.char.complete = GetQuestsCompleted()
            QuestieProfessions:Update()
            QuestieReputation:Update(false)
            QuestieQuest.availableQuests = {} -- reset available quest db

            -- draw available quests
            QuestieQuest:GetAllQuestIdsNoObjectives()
            return true
        end,
        function()
            QuestieQuest._resetNeedsAvailables = true
            QuestieQuest:CalculateAndDrawAvailableQuestsIterative(function() QuestieQuest._resetNeedsAvailables = false end) 
            return true
        end,
        function()
            for i=1,64 do
                if QuestieQuest._nextRestQuest then
                    QuestieQuest:UpdateQuest(QuestieQuest._nextRestQuest) 
                    _UpdateSpecials(QuestieQuest._nextRestQuest)
                    QuestieQuest._nextRestQuest = next(QuestiePlayer.currentQuestlog, QuestieQuest._nextRestQuest)
                else
                    break
                end
            end
            return not QuestieQuest._nextRestQuest
        end,
        function()
            return #QuestieMap._mapDrawQueue == 0 and #QuestieMap._minimapDrawQueue == 0 and (not QuestieQuest._resetNeedsAvailables)
        end,
        function()
            QuestieQuest._isResetting = nil
            if QuestieQuest._resetAgain then
                QuestieQuest._resetAgain = nil
                QuestieQuest:SmoothReset()
            end
            return true
        end
    }
    local step = 1
    local ticker
    ticker = C_Timer.NewTicker(0.01, function()
        if stepTable[step]() then
            step = step + 1
        end
        if not stepTable[step] then
            ticker:Cancel()
        end
        if QuestieQuest._resetAgain and not QuestieQuest._resetNeedsAvailables then -- we can stop the current reset
            ticker:Cancel()
            QuestieQuest._resetAgain = nil
            QuestieQuest._isResetting = nil
            QuestieQuest:SmoothReset()
        end
    end)
end

function QuestieQuest:HideQuest(id)
    Questie.db.char.hidden[id] = true
    QuestieMap:UnloadQuestFrames(id);
end

function QuestieQuest:UnhideQuest(id)
    Questie.db.char.hidden[id] = nil
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
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
    local objectiveList  = C_QuestLog.GetQuestObjectives(questId) or {}
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


-- todo: move this
local QuestieTaskQueue = {}
QuestieTaskQueue._queue = {}
function QuestieTaskQueue:OnUpdate()
    local val = tremove(QuestieTaskQueue._queue, 1)
    if val then val() end
end
function QuestieTaskQueue:Queue(...)
    for _,val in pairs({...}) do
        tinsert(QuestieTaskQueue._queue, val)
    end
end
local frm = CreateFrame("Frame", UIParent)
frm:SetScript("OnUpdate", QuestieTaskQueue.OnUpdate)
frm:Show()



function QuestieQuest:AcceptQuest(questId)
    if(QuestiePlayer.currentQuestlog[questId] == nil) then
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_ACCEPT_QUEST", questId));

        local quest = QuestieDB:GetQuest(questId)
        QuestiePlayer.currentQuestlog[questId] = quest

        QuestieTaskQueue:Queue(
            --Get all the Frames for the quest and unload them, the available quest icon for example.
            function() QuestieMap:UnloadQuestFrames(questId) end,
            function() QuestieHash:AddNewQuestHash(questId) end,
            function() QuestieQuest:PopulateQuestLogInfo(quest) end,
            function() QuestieQuest:PopulateObjectiveNotes(quest) end,
            QuestieQuest.CalculateAndDrawAvailableQuestsIterative
        )

        --Broadcast an update.
        --Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId); -- :UpdateQuest is called immediately after AcceptQuest now, so this is redundant
    else
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_ACCEPT_QUEST", questId), " Warning: Quest already existed, not adding");
    end
end

function QuestieQuest:CompleteQuest(quest)
    local questId = quest.Id
    QuestiePlayer.currentQuestlog[questId] = nil;
    -- Only quests that aren't repeatable should be marked complete, otherwise objectives for repeatable quests won't track correctly - #1433
    Questie.db.char.complete[questId] = not quest.IsRepeatable

    QuestieHash:RemoveQuestHash(questId)

    QuestieMap:UnloadQuestFrames(questId)
    if (QuestieMap.questIdFrames[questId]) then
        Questie:Error("Just removed all frames but the framelist seems to still be there!", questId)
    end

    QuestieTooltips:RemoveQuest(questId)
    QuestieTracker:RemoveQuest(questId)
    QuestieCombatQueue:Queue(function()
        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end)

    --This should probably be done first, because DrawAllAvailableQuests looks at QuestieMap.questIdFrames[QuestId] to add available
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_COMPLETE_QUEST", questId))
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

            if quest.ObjectiveData then
                -- We also have to reset these stupid "AlreadySpawned" fields
                for _, objective in pairs(quest.ObjectiveData) do
                    objective.AlreadySpawned = nil
                end
            end
            if quest.SpecialObjectives then
                for _, objective in pairs(quest.SpecialObjectives) do
                    objective.AlreadySpawned = nil
                end
            end
        end

        -- yes we do, since abandoning can unlock more than 1 quest, or remove unlocked quests
        for k, v in pairs(QuestieQuest.availableQuests) do
            ---@type Quest
            local availableQuest = QuestieDB:GetQuest(k)
            if (not availableQuest) or (not availableQuest:IsDoable()) then
                QuestieMap:UnloadQuestFrames(k);
            end
        end

        QuestieTracker:RemoveQuest(questId)
        QuestieCombatQueue:Queue(function()
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_ABANDON_QUEST", questId));
    end
end

---@param questId QuestId
function QuestieQuest:UpdateQuest(questId)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest]", questId)
    ---@type Quest
    local quest = QuestieDB:GetQuest(questId)
    if quest and (not Questie.db.char.complete[questId]) then
        QuestieQuest:PopulateQuestLogInfo(quest)
        QuestieQuest:UpdateObjectiveNotes(quest)
        local isComplete = quest:IsComplete()
        if isComplete == 1 then -- Quest is complete
            Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest is complete")
            QuestieMap:UnloadQuestFrames(questId)
            QuestieQuest:AddFinisher(quest)
        elseif isComplete == -1 then -- Failed quests should be shown as available again
            Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest failed")
            QuestieMap:UnloadQuestFrames(questId)
            _QuestieQuest:DrawAvailableQuest(quest)
        else
            --DEFAULT_CHAT_FRAME:AddMessage("Still not finished " .. QuestId);
        end
        QuestieCombatQueue:Queue(function()
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId)
    end
end

--Run this if you want to update the entire table
function QuestieQuest:GetAllQuestIds()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_GET_QUEST"));
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
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_ADD_QUEST", questId, QuestiePlayer.currentQuestlog[questId]));
        end
    end
    QuestieCombatQueue:Queue(function()
        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end)
end

function QuestieQuest:GetAllQuestIdsNoObjectives()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_GET_QUEST"), "(without objectives)");
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
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_ADD_QUEST", questId, QuestiePlayer.currentQuestlog[questId]));
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

-- iterate all notes, update / remove as needed
function QuestieQuest:UpdateObjectiveNotes(quest)
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes:", quest.Id)
    if quest.Objectives then
        for k, v in pairs(quest.Objectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, k, v);
            if not result then
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_POP_ERROR", quest.name, quest.Id, k, err));
            end
        end
    end
end

function QuestieQuest:AddFinisher(quest)
    --We should never ever add the quest if IsQuestFlaggedComplete true.
    local questId = quest.Id
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", "Adding finisher for quest", questId)

    if(QuestiePlayer.currentQuestlog[questId] and (IsQuestFlaggedCompleted(questId) == false) and IsQuestComplete(questId) and (not Questie.db.char.complete[questId])) then
        local finisher = nil
        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                finisher = QuestieDB:GetNPC(quest.Finisher.Id)
            elseif quest.Finisher.Type == "object" then
                finisher = QuestieDB:GetObject(quest.Finisher.Id)
            else
                Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_UNHANDLE_FINISH", quest.Finisher.Type, questId, quest.name))
            end
        else
            Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_NO_FINISH", questId, quest.name))
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
                            local dungeonLocation = ZoneDB:GetDungeonLocation(finisherZone)
                            if dungeonLocation ~= nil then
                                for _, value in ipairs(dungeonLocation) do
                                    local zone = value[1];
                                    local x = value[2];
                                    local y = value[3];

                                    QuestieMap:DrawWorldIcon(data, zone, x, y)
                                end
                            end
                        else
                            Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]: Adding world icon as finisher")
                            local x = coords[1];
                            local y = coords[2];

                            Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]:", finisherZone, x, y)
                            local icon, _ = QuestieMap:DrawWorldIcon(data, finisherZone, x, y)

                            if(finisher.waypoints and finisher.zoneID and finisher.zoneID == finisherZone and finisher.waypoints[finisherZone]) then
                                QuestieMap:DrawWaypoints(icon, finisher.waypoints[finisherZone], finisherZone, x, y)
                            end
                        end
                    end
                end
            end
        else
            Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: finisher or finisher.spawns == nil")
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

function QuestieQuest:PopulateObjective(quest, ObjectiveIndex, Objective, BlockItemTooltips) -- must be pcalled
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:PopulateObjective]")
    if not Objective.AlreadySpawned then
        Objective.AlreadySpawned = {};
    end


    -- temporary fix for "special objectives" to not double-spawn (we need to fix the objective detection logic)
    if not quest.AlreadySpawned then
        quest.AlreadySpawned = {};
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
        QuestieLib:MathRandomSeed(quest.Id + 32768 * ObjectiveIndex)
        Objective.Color = {0.45 + QuestieLib:MathRandom() / 2, 0.45 + QuestieLib:MathRandom() / 2, 0.45 + QuestieLib:MathRandom() / 2}
    end

    if (not Objective.registeredItemTooltips) and Objective.Type == "item" and (not BlockItemTooltips) and Objective.Id then -- register item tooltip (special case)
        local item = QuestieDB:GetItem(Objective.Id);
        if item and item.name then
            QuestieTooltips:RegisterTooltip(quest.Id, "i_" .. item.Id, Objective);
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
            if not quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)] then
                quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)] = {};
            end
            if (not Objective.AlreadySpawned[id]) and (not quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)][spawnData.Id]) then
                if not Objective.registeredTooltips and spawnData.TooltipKey and (not tooltipRegisterHack[spawnData.TooltipKey]) then -- register mob / item / object tooltips
                    QuestieTooltips:RegisterTooltip(quest.Id, spawnData.TooltipKey, Objective);
                    tooltipRegisterHack[spawnData.TooltipKey] = true
                    hasTooltipHack = true
                end
            end
            if (not Objective.AlreadySpawned[id]) and (not completed) and (not quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)][spawnData.Id]) then
                if Questie.db.global.enableObjectives then
                    -- temporary fix for "special objectives" to not double-spawn (we need to fix the objective detection logic)
                    quest.AlreadySpawned[Objective.Type .. tostring(ObjectiveIndex)][spawnData.Id] = true
                    local maxCount = 0
                    if(not iconsToDraw[quest.Id]) then
                        iconsToDraw[quest.Id] = {}
                    end
                    local data = {}
                    data.Id = quest.Id
                    data.ObjectiveIndex = ObjectiveIndex
                    data.QuestData = quest
                    data.ObjectiveData = Objective
                    data.Icon = spawnData.Icon
                    data.IconColor = quest.Color
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
                        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
                        for _, spawn in pairs(spawns) do
                            if(spawn[1] and spawn[2]) then
                                local drawIcon = {};
                                drawIcon.AlreadySpawnedId = id;
                                drawIcon.data = data;
                                drawIcon.zone = zone;
                                drawIcon.AreaID = zone;
                                drawIcon.UiMapID = uiMapId
                                drawIcon.x = spawn[1];
                                drawIcon.y = spawn[2];
                                local x, y, _ = HBD:GetWorldCoordinatesFromZone(drawIcon.x/100, drawIcon.y/100, uiMapId)
                                -- There are instances when X and Y are not in the same map such as in dungeons etc, we default to 0 if it is not set
                                -- This will create a distance of 0 but it doesn't matter.
                                local distance = QuestieLib:Euclid(closestStarter[quest.Id].x or 0, closestStarter[quest.Id].y or 0, x or 0, y or 0);
                                drawIcon.distance = distance or 0;
                                iconsToDraw[quest.Id][floor(distance)] = drawIcon;
                            end
                            --maxCount = maxCount + 1
                            --if maxPerType > 0 and maxCount > maxPerType then break; end
                        end
                        --if maxPerType > 0 and maxCount > maxPerType then break; end
                    end
                end
            elseif completed and Objective.AlreadySpawned then -- unregister notes
                for _, spawn in pairs(Objective.AlreadySpawned) do
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
            local range = Questie.db.global.clusterLevelHotzone
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

                local dungeonLocation = ZoneDB:GetDungeonLocation(icon.zone)

                if dungeonLocation and midPoint.x == -1 and midPoint.y == -1 then
                    if dungeonLocation[2] then -- We have more than 1 instance entrance (e.g. Blackrock dungeons)
                        local secondDungeonLocation = dungeonLocation[2]
                        icon.zone = secondDungeonLocation[1]
                        midPoint.x = secondDungeonLocation[2]
                        midPoint.y = secondDungeonLocation[3]

                        local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, midPoint.x, midPoint.y) -- clustering code takes care of duplicates as long as mindist is more than 0
                        if iconMap and iconMini then
                            tinsert(Objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                            tinsert(Objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
                        end
                        spawnedIcons[questId] = spawnedIcons[questId] + 1;
                    end
                    local firstDungeonLocation = dungeonLocation[1]
                    icon.zone = firstDungeonLocation[1]
                    midPoint.x = firstDungeonLocation[2]
                    midPoint.y = firstDungeonLocation[3]
                end

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

local function _CallPopulateObjective(quest)
    for k, v in pairs(quest.Objectives) do
        SelectQuestLogEntry(v.Index)
        local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, k, v, false);
        if not result then
            local major, minor, patch = QuestieLib:GetAddonVersionInfo();
            local version = "v"..(major or "").."."..(minor or "").."."..(patch or "");--Doing it this way to keep it 100% safe.
            Questie:Error("[QuestieQuest]: " .. version .. " - " .. QuestieLocale:GetUIString("DEBUG_POPULATE_ERR", quest.name or "No quest name", quest.Id or "No quest id", k or "No objective", err or "No error"));
        end
    end
end

local function _AddSourceItemObjective(quest)
    if quest.sourceItemId then
        local item = QuestieDB:GetItem(quest.sourceItemId);
        if item and item.name then
            -- We fake an objective for the sourceItems because this allows us
            -- to simply reuse "QuestieTooltips:GetTooltip".
            -- This should be all the data required for the tooltip
            local fakeObjective = {
                IsSourceItem = true,
                QuestData = quest,
                Index = 1,
                Needed = 1,
                Collected = 1,
                text = item.name,
                Description = item.name
            }

            QuestieTooltips:RegisterTooltip(quest.Id, "i_" .. item.Id, fakeObjective);
        end
    end
end

function QuestieQuest:PopulateObjectiveNotes(quest) -- this should be renamed to PopulateNotes as it also handles finishers now
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:PopulateObjectiveNotes]", "Populating objectives for:", quest.Id)
    if (not quest) then
        return
    end

    if quest:IsComplete() == 1 then
        _AddSourceItemObjective(quest)

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
    _CallPopulateObjective(quest)
    _AddSourceItemObjective(quest)

    -- check for special (unlisted) DB objectives
    if quest.SpecialObjectives then
        Questie:Debug(DEBUG_DEVELOP, "Adding special objectives")
        local index = 0 -- SpecialObjectives is a string table, but we need a number
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, index, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. QuestieLocale:GetUIString("DEBUG_POPULATE_ERR", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
            index = index + 1
        end
    end
    if old then
        SelectQuestLogEntry(old)
    end

end
function QuestieQuest:PopulateQuestLogInfo(quest)
    --Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateMeta1:", Quest.Id, Quest.Name)
    if quest.Objectives == nil then
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateQuestLogInfo: ".. QuestieLocale:GetUIString("DEBUG_POPTABLE"))
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
        Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_OBJ_TABLE"));
    end

    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(quest.Id);
    if not questObjectives then
        questObjectives = {}
    end
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
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: ".. QuestieLocale:GetUIString("DEBUG_ENTRY_ID", objective.type, objective.text))
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
                    -- tinsert(quest.SpecialObjectives, objective)
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
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest:GetAllLeaderBoardDetails] for questId", questId)
    local questObjectives = QuestieLib:GetQuestObjectives(questId);
    if not questObjectives then
        -- Some quests just don't have a real objective e.g. 2744
        return nil
    end

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
---@param quest Quest
function _QuestieQuest:DrawAvailableQuest(quest) -- prevent recursion

    --TODO More logic here, currently only shows NPC quest givers.
    if quest.Starts["GameObject"] ~= nil then
        for _, ObjectID in ipairs(quest.Starts["GameObject"]) do
            local obj = QuestieDB:GetObject(ObjectID)
            if(obj ~= nil and obj.spawns ~= nil) then
                for zone, spawns in pairs(obj.spawns) do
                    if(zone ~= nil and spawns ~= nil) then
                        for _, coords in ipairs(spawns) do
                            local data = {}
                            data.Id = quest.Id;
                            data.Icon = _QuestieQuest:GetQuestIcon(quest)
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data:GetIconScale()
                            data.Type = "available";
                            data.QuestData = quest;
                            data.Name = obj.name

                            data.IsObjectiveNote = false
                            if(coords[1] == -1 or coords[2] == -1) then
                                local dungeonLocation = ZoneDB:GetDungeonLocation(zone)
                                if dungeonLocation ~= nil then
                                    for _, value in ipairs(dungeonLocation) do
                                        QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                    end
                                end
                            else
                                QuestieMap:DrawWorldIcon(data, zone, coords[1], coords[2])
                            end
                        end
                    end
                end
            end
        end
    elseif(quest.Starts["NPC"] ~= nil)then
        for _, NPCID in ipairs(quest.Starts["NPC"]) do
            local NPC = QuestieDB:GetNPC(NPCID)
            if (NPC ~= nil and NPC.spawns ~= nil) then
                --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                for npcZone, Spawns in pairs(NPC.spawns) do
                    if(npcZone ~= nil and Spawns ~= nil) then

                        for _, coords in ipairs(Spawns) do
                            local data = {}
                            data.Id = quest.Id;
                            data.Icon = _QuestieQuest:GetQuestIcon(quest)
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data.GetIconScale();
                            data.Type = "available";
                            data.QuestData = quest;
                            data.Name = NPC.name
                            data.IsObjectiveNote = false
                            if(coords[1] == -1 or coords[2] == -1) then
                                local dungeonLocation = ZoneDB:GetDungeonLocation(npcZone)
                                if dungeonLocation ~= nil then
                                    for _, value in ipairs(dungeonLocation) do
                                        local zone = value[1];
                                        local x = value[2];
                                        local y = value[3];

                                        QuestieMap:DrawWorldIcon(data, zone, x, y)
                                    end
                                end
                            else
                                local x = coords[1];
                                local y = coords[2];

                                local icon, _ = QuestieMap:DrawWorldIcon(data, npcZone, x, y)

                                if(NPC.waypoints and NPC.zoneID and NPC.zoneID == npcZone and NPC.waypoints[npcZone]) then
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

---@param quest Quest
function _QuestieQuest:GetQuestIcon(quest)
    local icon = {}
    if quest.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        icon = ICON_TYPE_AVAILABLE_GRAY
    elseif quest.IsRepeatable then
        icon = ICON_TYPE_REPEATABLE
    elseif(quest:IsTrivial()) then
        icon = ICON_TYPE_AVAILABLE_GRAY
    else
        icon = ICON_TYPE_AVAILABLE
    end
    return icon
end

function QuestieQuest:CalculateAndDrawAvailableQuestsIterative(callback)
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", QuestieLocale:GetUIString("DEBUG_DRAW", 0, QuestiePlayer:GetPlayerLevel()));

    local data = QuestieDB.QuestPointers or QuestieDB.questData
    local index = next(data)
    local timer -- if you do local timer = C_Timer then "timer" cant be accessed inside

    local playerLevel = QuestiePlayer:GetPlayerLevel()
    local minLevel = playerLevel - GetQuestGreenRange()
    local maxLevel = playerLevel

    if Questie.db.char.absoluteLevelOffset then
        minLevel = Questie.db.char.minLevelFilter
        maxLevel = Questie.db.char.maxLevelFilter
    elseif Questie.db.char.manualMinLevelOffset then
        minLevel = playerLevel - Questie.db.char.minLevelFilter
    end

    local showRepeatableQuests = Questie.db.char.showRepeatableQuests
    local showDungeonQuests = Questie.db.char.showDungeonQuests
    local showRaidQuests = Questie.db.char.showRaidQuests
    local showPvPQuests = Questie.db.char.showPvPQuests
    local showAQWarEffortQuests = Questie.db.char.showAQWarEffortQuests

    QuestieQuest.availableQuests = {}

    timer = C_Timer.NewTicker(0.01, function()
        for i=0,64 do -- number of available quests to process per tick
            local questId = index
            if questId then
                -- ---@type Quest
                -- local quest = QuestieDB:GetQuest(questId)

                --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
                if(
                    (not Questie.db.char.complete[questId]) and -- Don't show completed quests
                    ((not QuestiePlayer.currentQuestlog[questId]) or QuestieDB:IsComplete(questId) == -1) and -- Don't show quests if they're already in the quest log
                    (not QuestieCorrections.hiddenQuests[questId]) and -- Don't show blacklisted quests
                    (showRepeatableQuests or (not QuestieDB:IsRepeatable(questId))) and  -- Show repeatable quests if the quest is repeatable and the option is enabled
                    (showDungeonQuests or (not QuestieDB:IsDungeonQuest(questId))) and  -- Show dungeon quests only with the option enabled
                    (showRaidQuests or (not QuestieDB:IsRaidQuest(questId))) and  -- Show Raid quests only with the option enabled
                    (showPvPQuests or (not QuestieDB:IsPvPQuest(questId))) and -- Show PvP quests only with the option enabled
                    (showAQWarEffortQuests or (not QuestieDB:IsAQWarEffortQuest(questId))) -- Don't show AQ War Effort quests with the option enabled
                ) then

                    if QuestieDB:IsLevelRequirementsFulfilled(questId, minLevel, maxLevel) and QuestieDB:IsDoable(questId) then
                        QuestieQuest.availableQuests[questId] = questId
                        --If the quest is not drawn draw the quest, otherwise skip.
                        if (not QuestieMap.questIdFrames[questId]) then
                            ---@type Quest
                            local quest = QuestieDB:GetQuest(questId)
                            if (not quest.tagInfoWasCached) then
                                Questie:Debug(DEBUG_INFO, "Caching for quest", quest.Id)
                                quest:GetQuestTagInfo() -- cache to load in the tooltip
                                quest.tagInfoWasCached = true
                            end
                            --Draw a specific quest through the function
                            _QuestieQuest:DrawAvailableQuest(quest)
                        else
                            --We might have to update the icon in this situation (config changed/level up)
                            for _, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                                if frame and frame.data and frame.data.QuestData then
                                    local newIcon = _QuestieQuest:GetQuestIcon(frame.data.QuestData)
                                    if newIcon ~= frame.data.Icon then
                                        frame:UpdateTexture(newIcon)
                                    end
                                end
                            end
                        end
                    else
                        --If the quests are not within level range we want to unload them
                        --(This is for when people level up or change settings etc)
                        QuestieMap:UnloadQuestFrames(questId);
                    end
                end
            else
                timer:Cancel()
                if callback ~= nil then
                    callback()
                end
                return
            end
            index = next(data, index)
        end
    end)
end

---------------------------------------------------------------------------------------------------
-- These must be loaded in order together and loaded before the hook for custom quest links
-- The Hyperlink hook is located in QuestieTooltips.lua
---------------------------------------------------------------------------------------------------
-- Message Event Filter which intercepts incoming linked quests and replaces them with Hyperlinks
local function QuestsFilter(chatFrame, event, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, senderGUID, bnSenderID, ...)
    if string.find(msg, "%[(..-) %((%d+)%)%]") then
        if chatFrame and chatFrame.historyBuffer and #(chatFrame.historyBuffer.elements) > 0 and chatFrame ~= _G.ChatFrame2 then
            for k in string.gmatch(msg, "%[%[?%d?..?%]?..-%]") do
                local complete, sqid, questId, questLevel, questName, realQuestName, realQuestLevel
                _, _, questName, sqid = string.find(k, "%[(..-) %((%d+)%)%]")

                if questName and sqid then
                    questId = tonumber(sqid)

                    if string.find(questName, "(%[%d+.-%]) ") ~= nil then
                        _, _, questLevel, questName = string.find(questName, "%[(..-)%] (.+)")
                    end

                    if QuestieDB.QueryQuest then
                        realQuestName, realQuestLevel = unpack(QuestieDB.QueryQuest(questId, "name", "questLevel"))

                        if questName and questId then
                            complete = QuestieDB:IsComplete(questId)
                        end
                    end
                end

                if realQuestName and realQuestName == questName and questId then
                    local coloredQuestName = QuestieLib:GetColoredQuestName(questId, questName, realQuestLevel, Questie.db.global.trackerShowQuestLevel, complete, false)

                    if senderGUID == nil then
                        playerName = BNGetFriendInfoByID(bnSenderID)
                        senderGUID = bnSenderID
                    end

                    local questLink = "|Hquestie:"..sqid..":"..senderGUID.."|h"..QuestieLib:PrintDifficultyColor(realQuestLevel, "[")..coloredQuestName..QuestieLib:PrintDifficultyColor(realQuestLevel, "]").."|h"

                    -- Escape the magic characters
                    local function escapeMagic(toEsc)
                        return (toEsc
                            :gsub("%%", "%%%%")
                            :gsub("^%^", "%%^")
                            :gsub("%$$", "%%$")
                            :gsub("%(", "%%(")
                            :gsub("%)", "%%)")
                            :gsub("%.", "%%.")
                            :gsub("%[", "%%[")
                            :gsub("%]", "%%]")
                            :gsub("%*", "%%*")
                            :gsub("%+", "%%+")
                            :gsub("%-", "%%-")
                            :gsub("%?", "%%?")
                            :gsub("%|", "%%|")
                        )
                    end

                    if questName then
                        questName = escapeMagic(questName)
                    end

                    if questLevel then
                        questLevel = escapeMagic(questLevel)
                    end

                    if questLevel then
                        msg = string.gsub(msg, "%[%["..questLevel.."%] "..questName.." %("..sqid.."%)%]", questLink)
                    else
                        msg = string.gsub(msg, "%["..questName.." %("..sqid.."%)%]", questLink)
                    end
                end
            end
            return false, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, senderGUID, bnSenderID, ...
        end
    end
end

-- The message filter that triggers the above local function

-- Party
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestsFilter)

-- Raid
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", QuestsFilter)

-- Guild
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", QuestsFilter)

-- Battleground
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestsFilter)

-- Whisper
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", QuestsFilter)

-- Battle Net
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", QuestsFilter)

-- Open world
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", QuestsFilter)
