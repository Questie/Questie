--- COMPATIBILITY ---
local GetNumQuestLogEntries = GetNumQuestLogEntries or C_QuestLog.GetNumQuestLogEntries
local GetQuestLogIndexByID = GetQuestLogIndexByID or C_QuestLog.GetLogIndexForQuestID
local IsQuestComplete = IsQuestComplete or C_QuestLog.IsComplete
local GetQuestGreenRange = GetQuestGreenRange or UnitQuestTrivialLevelRange
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

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
---@type TaskQueue
local TaskQueue = QuestieLoader:ImportModule("TaskQueue")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

--We should really try and squeeze out all the performance we can, especially in this.
local tostring = tostring;
local tinsert = table.insert;
local pairs = pairs;
local ipairs = ipairs;
local strim = string.trim;
local smatch = string.match;

QuestieQuest.availableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

-- forward declaration
local _GetObjectiveIdForSpecialQuest, _ObjectiveUpdate, _UnloadAlreadySpawnedIcons
local _RegisterObjectiveTooltips, _DetermineIconsToDraw, _GetIconsSortedByDistance
local _DrawObjectiveIcons, _DrawObjectiveWaypoints

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local dungeons = ZoneDB:GetDungeons()

function QuestieQuest:Initialize()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Getting all completed quests")
    Questie.db.char.complete = GetQuestsCompleted()

    QuestieProfessions:Update()
    QuestieReputation:Update(true)

    QuestieHash:LoadQuestLogHashes()
end

function QuestieQuest:ToggleNotes(showIcons)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:ToggleNotes] showIcons:", showIcons)
    QuestieQuest:GetAllQuestIds() -- add notes that weren't added from previous hidden state

    if showIcons then
        _QuestieQuest:ShowQuestIcons()
        _QuestieQuest:ShowManualIcons()
    else
        _QuestieQuest:HideQuestIcons()
        _QuestieQuest:HideManualIcons()
    end
end

function _QuestieQuest:ShowQuestIcons()
    -- change map button
    if Questie.db.char.enabled then
        Questie_Toggle:SetText(l10n("Hide Questie"));
    end

    local trackerHiddenQuests = Questie.db.char.TrackerHiddenQuests
    for questId, frameList in pairs(QuestieMap.questIdFrames) do
        if (trackerHiddenQuests == nil) or (trackerHiddenQuests[questId] == nil) then -- Skip quests which are completly hidden from the Tracker menu
            for _, frameName in pairs(frameList) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                ---@type IconFrame
                local icon = _G[frameName];
                if icon.data == nil then
                    error("Desync! Icon has not been removed correctly, but has already been resetted. Skipping frame \"" .. frameName .. "\" for quest " .. questId)
                else
                    local objectiveString = tostring(questId) .. " " .. tostring(icon.data.ObjectiveIndex)
                    if (Questie.db.char.TrackerHiddenObjectives == nil) or (Questie.db.char.TrackerHiddenObjectives[objectiveString] == nil) then
                        if icon ~= nil and icon.hidden and (not icon:ShouldBeHidden()) then
                            icon:FakeShow()

                            if icon.data.lineFrames then
                                for _, lineIcon in pairs(icon.data.lineFrames) do
                                    lineIcon:FakeShow()
                                end
                            end
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

function _QuestieQuest:ShowManualIcons()
    for _, frameList in pairs(QuestieMap.manualFrames) do
        for _, frameName in pairs(frameList) do
            local icon = _G[frameName];
            if icon ~= nil and icon.hidden and (not icon:ShouldBeHidden()) then -- check for function to make sure its a frame
                icon:FakeShow()
            end
        end
    end
end

function _QuestieQuest:HideQuestIcons()
    if (not Questie.db.char.enabled) then
        Questie_Toggle:SetText(l10n("Show Questie"));
    end

    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            if icon ~= nil and (not icon.hidden) and icon:ShouldBeHidden() then -- check for function to make sure its a frame
                icon:FakeHide()

                if icon.data.lineFrames then
                    for _, lineIcon in pairs(icon.data.lineFrames) do
                        lineIcon:FakeHide()
                    end
                end
            end
            if (icon.data.QuestData.FadeIcons or (icon.data.ObjectiveData and icon.data.ObjectiveData.FadeIcons)) and icon.data.Type ~= "complete" then
                icon:FadeOut()
            else
                icon:FadeIn()
            end
        end
    end
end

function _QuestieQuest:HideManualIcons()
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

        quest.Objectives = nil

        if next(quest.SpecialObjectives) then
            for _,s in pairs(quest.SpecialObjectives) do
                s.AlreadySpawned = {}
            end
        end
        quest.SpecialObjectives = {}
    end

    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do
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
    if quest and next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, function(err)
                print(err)
                print(debugstack())
            end, QuestieQuest, quest, 0, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
        end
    end
end

function QuestieQuest:AddAllNotes()
    QuestieQuest:GetAllQuestIdsNoObjectives()
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

    for quest in pairs (QuestiePlayer.currentQuestlog) do
        QuestieQuest:UpdateQuest(quest)
        _UpdateSpecials(quest)
    end
end

function QuestieQuest:Reset()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:Reset]")
    QuestieQuest:ClearAllNotes()


    -- reset quest log and tooltips
    QuestiePlayer.currentQuestlog = {}
    QuestieTooltips.lookupByKey = {}
    QuestieTooltips.lookupKeyByQuestId = {}

    Questie.db.char.complete = GetQuestsCompleted()
    QuestieProfessions:Update()
    QuestieReputation:Update(false)


    QuestieMenu:OnLogin()
    QuestieQuest:AddAllNotes()
end

function QuestieQuest:SmoothReset()
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
            QuestieMenu:OnLogin(true) -- remove icons
            return true
        end,
        function() 
            return #QuestieMap._mapDrawQueue == 0 and #QuestieMap._minimapDrawQueue == 0 -- wait until draw queue is finished
        end,
        function()
            -- reset quest log and tooltips
            QuestiePlayer.currentQuestlog = {}
            QuestieTooltips.lookupByKey = {}
            QuestieTooltips.lookupKeyByQuestId = {}

            -- make sure complete db is correct
            Questie.db.char.complete = GetQuestsCompleted()
            QuestieProfessions:Update()
            QuestieReputation:Update(false)

            -- draw available quests
            QuestieQuest:GetAllQuestIdsNoObjectives()
            return true
        end,
        function()
            QuestieMenu:OnLogin()
            return true
        end,
        function()
            QuestieQuest._resetNeedsAvailables = true
            QuestieQuest:CalculateAndDrawAvailableQuestsIterative(function() QuestieQuest._resetNeedsAvailables = false end) 
            return true
        end,
        function()
            for _=1,64 do
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

function QuestieQuest:GetRawLeaderBoardDetails(questLogIndex)
    local quest = {}
    local title, level, _, _, _, isComplete, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(questLogIndex)
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

    return quest;
end

function QuestieQuest:AcceptQuest(questId)
    if(QuestiePlayer.currentQuestlog[questId] == nil) then
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Accepted Quest:", questId);

        local quest = QuestieDB:GetQuest(questId)
        QuestiePlayer.currentQuestlog[questId] = quest

        TaskQueue:Queue(
            --Get all the Frames for the quest and unload them, the available quest icon for example.
            function() QuestieMap:UnloadQuestFrames(questId) end,
            function() QuestieTooltips:RemoveQuest(questId) end,
            function() QuestieHash:AddNewQuestHash(questId) end,
            function() QuestieQuest:PopulateQuestLogInfo(quest) end,
            function() QuestieQuest:PopulateObjectiveNotes(quest) end,
            QuestieQuest.CalculateAndDrawAvailableQuestsIterative
        )

        --Broadcast an update.
        --Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId); -- :UpdateQuest is called immediately after AcceptQuest now, so this is redundant
    else
        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Accepted Quest:", questId, " Warning: Quest already existed, not adding");
    end
end

function QuestieQuest:CompleteQuest(quest)
    local questId = quest.Id
    QuestiePlayer.currentQuestlog[questId] = nil;
    -- Only quests that aren't repeatable and not a daily quest should be marked complete,
    -- otherwise objectives for repeatable quests won't track correctly - #1433
    Questie.db.char.complete[questId] = DailyQuests:IsDailyQuest(questId) or (not quest.IsRepeatable);

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

    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Completed Quest:", questId)
end

function QuestieQuest:AbandonedQuest(questId)
    QuestieTooltips:RemoveQuest(questId)
    if(QuestiePlayer.currentQuestlog[questId]) then
        QuestiePlayer.currentQuestlog[questId] = nil

        QuestieHash:RemoveQuestHash(questId)

        QuestieMap:UnloadQuestFrames(questId);

        local quest = QuestieDB:GetQuest(questId);
        if quest then
            quest.Objectives = nil;

            if quest.ObjectiveData then
                for _, objective in pairs(quest.ObjectiveData) do
                    objective.AlreadySpawned = {}
                end
            end
            if next(quest.SpecialObjectives) then
                for _, objective in pairs(quest.SpecialObjectives) do
                    objective.AlreadySpawned = {}
                end
            end
        end

        for k, _ in pairs(QuestieQuest.availableQuests) do
            ---@type Quest
            local availableQuest = QuestieDB:GetQuest(k)
            if (not availableQuest) or (not availableQuest:IsDoable()) then
                QuestieMap:UnloadQuestFrames(k);
            end
        end

        QuestieTracker:RemoveQuest(questId)
        QuestieTooltips:RemoveQuest(questId)
        QuestieCombatQueue:Queue(function()
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

        Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Abandoned Quest:", questId);
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
            --QuestieTooltips:RemoveQuest(questId)
            QuestieQuest:AddFinisher(quest)
        elseif isComplete == -1 then -- Failed quests should be shown as available again
            Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest failed")
            QuestieMap:UnloadQuestFrames(questId)
            QuestieTooltips:RemoveQuest(questId)
            _QuestieQuest:DrawAvailableQuest(quest)
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
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Getting all quests");
    local numEntries, _ = GetNumQuestLogEntries();
    QuestiePlayer.currentQuestlog = {}
    for index = 1, numEntries do
        local title, _, _, isHeader, _, _, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif (not isHeader) then
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
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Adding the quest", questId, QuestiePlayer.currentQuestlog[questId]);
        end
    end
    QuestieCombatQueue:Queue(function()
        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end)
end

function QuestieQuest:GetAllQuestIdsNoObjectives()
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]: Getting all quests without objectives)");
    local numEntries, _ = GetNumQuestLogEntries();
    QuestiePlayer.currentQuestlog = {}
    for index = 1, numEntries do
        local _, _, _, isHeader, _, _, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif (not isHeader) then
            --Keep the object in the questlog to save searching
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                QuestiePlayer.currentQuestlog[questId] = quest
            else
                QuestiePlayer.currentQuestlog[questId] = questId
            end
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Adding the quest", questId, QuestiePlayer.currentQuestlog[questId]);
        end
    end
end

-- iterate all notes, update / remove as needed
function QuestieQuest:UpdateObjectiveNotes(quest)
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: UpdateObjectiveNotes:", quest.Id)
    if quest.Objectives then
        for objectiveIndex, objective in pairs(quest.Objectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, function(err)
                print(err)
                print(debugstack())
            end, QuestieQuest, quest, objectiveIndex, objective, false);
            if (not result) then
                Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: There was an error populating objectives for", quest.name, quest.Id, objectiveIndex, err);
            end
        end
    end
end

function QuestieQuest:AddFinisher(quest)
    --We should never ever add the quest if IsQuestFlaggedComplete true.
    local questId = quest.Id
    Questie:Debug(DEBUG_INFO, "[QuestieQuest]", "Adding finisher for quest", questId)

    if(QuestiePlayer.currentQuestlog[questId] and (IsQuestFlaggedCompleted(questId) == false) and (IsQuestComplete(questId) or quest:IsComplete() == 1) and (not Questie.db.char.complete[questId])) then
        local finisher
        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                finisher = QuestieDB:GetNPC(quest.Finisher.Id)
            elseif quest.Finisher.Type == "object" then
                finisher = QuestieDB:GetObject(quest.Finisher.Id)
            else
                Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: Unhandled finisher type:", quest.Finisher.Type, questId, quest.name)
            end
        else
            Questie:Debug(DEBUG_CRITICAL, "[QuestieQuest]: Quest has no finisher:", questId, quest.name)
        end
        if(finisher ~= nil and finisher.spawns ~= nil) then
            QuestieTooltips:RegisterQuestStartTooltip(questId, finisher)

            local finisherIcons = {}
            local finisherLocs = {}
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
                            finisherIcons[finisherZone] = QuestieMap:DrawWorldIcon(data, finisherZone, x, y)
                            if not finisherLocs[finisherZone] then
                                finisherLocs[finisherZone] = {x, y}
                            end
                        end
                    end
                end
            end

            if finisher.waypoints then
                for zone, waypoints in pairs(finisher.waypoints) do
                    if (not ZoneDB:IsDungeonZone(zone)) then
                        if not finisherIcons[zone] and waypoints[1] and waypoints[1][1] and waypoints[1][1][1]  then
                            local data = {}
                            data.Id = questId;
                            data.Icon = ICON_TYPE_COMPLETE;
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data:GetIconScale();
                            data.Type = "complete";
                            data.QuestData = quest;
                            data.Name = finisher.name
                            data.IsObjectiveNote = false
                            finisherIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                            finisherLocs[zone] = {waypoints[1][1][1], waypoints[1][1][2]}
                        end
                        QuestieMap:DrawWaypoints(finisherIcons[zone], waypoints, zone)
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
        for _, spawnData in pairs(_QuestieQuest.objectiveSpawnListCallTable[type](id)) do
            spawnData.Type = type
            spawnData.CustomTooltipData = {}
            spawnData.CustomTooltipData.Title = label or "Forced Icon"
            spawnData.CustomTooltipData.Body = {[spawnData.Name]=spawnData.Name}
            if customScale then
                spawnData.GetIconScale = function()
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

function QuestieQuest:PopulateObjective(quest, objectiveIndex, objective, blockItemTooltips) -- must be pcalled
    Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest:PopulateObjective] " .. objective.Description)

    local completed = objective.Completed

    local objectiveData = quest.ObjectiveData[objective.Index] or objective -- the reason for "or objective" is to handle "SpecialObjectives" aka non-listed objectives (demonic runestones for closing the portal)

    if (not completed) and (not next(objective.spawnList)) and _QuestieQuest.objectiveSpawnListCallTable[objectiveData.Type] then
        objective.spawnList = _QuestieQuest.objectiveSpawnListCallTable[objectiveData.Type](objective.Id, objective, objectiveData);
    end

    -- Tooltips should always show.
    -- For completed and uncompleted objectives
    _RegisterObjectiveTooltips(objective, quest.Id)

    local maxPerType = 300
    if Questie.db.global.enableIconLimit then
        maxPerType = Questie.db.global.iconLimit
    end

    local closestStarter = QuestieMap:FindClosestStarter()
    local iconsToDraw = {}
    local spawnItemId

    objective:Update()

    if completed then
        _UnloadAlreadySpawnedIcons(objective)
        return
    end

    if (not objective.Color) then
        objective.Color = QuestieLib:GetRandomColor(quest.Id + 32768 * objectiveIndex)
    end

    if (not objective.registeredItemTooltips) and objective.Type == "item" and (not blockItemTooltips) and objective.Id then
        local item = QuestieDB.QueryItemSingle(objective.Id, "name")
        if item then
            QuestieTooltips:RegisterObjectiveTooltip(quest.Id, "i_" .. objective.Id, objective);
        end
        objective.registeredItemTooltips = true
    end

    if next(objective.spawnList) then
        local objectiveCenter = closestStarter[quest.Id]

        local zoneCount = 0
        local zones = {}
        local objectiveZone

        for _, spawnData in pairs(objective.spawnList) do
            for zone in pairs(spawnData.Spawns) do
                zones[zone] = true
            end
        end

        for zone in pairs(zones) do
            objectiveZone = zone
            zoneCount = zoneCount + 1
        end

        if zoneCount == 1 then -- this objective happens in 1 zone, clustering should be relative to that zone
            objectiveCenter = {}
            local x, y = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, ZoneDB:GetUiMapIdByAreaId(objectiveZone))
            objectiveCenter.x = x
            objectiveCenter.y = y
        end

        iconsToDraw, spawnItemId  = _DetermineIconsToDraw(quest, objective, objectiveIndex, objectiveCenter)
        local icon, iconPerZone = _DrawObjectiveIcons(iconsToDraw, objective, maxPerType)
        _DrawObjectiveWaypoints(objective, icon, iconPerZone)
    end
    
end

_RegisterObjectiveTooltips = function(objective, questId)
    Questie:Debug(DEBUG_INFO, "Registering objective tooltips for " .. objective.Description)
    if objective.spawnList then
        for id, spawnData in pairs(objective.spawnList) do
            if spawnData.TooltipKey and (not objective.AlreadySpawned[id]) and (not objective.hasRegisteredTooltips) then
                QuestieTooltips:RegisterObjectiveTooltip(questId, spawnData.TooltipKey, objective)
            end
        end
    else
        Questie:Error("[QuestieQuest]: [Tooltips] ".. l10n("There was an error populating objectives for %s %s %s %s", objective.Description or "No objective text", questId or "No quest id", 0 or "No objective", "No error"));
    end
    objective.hasRegisteredTooltips = true
end

_UnloadAlreadySpawnedIcons = function(objective)
    if next(objective.spawnList) then
        for id, _ in pairs(objective.spawnList) do
            local spawn = objective.AlreadySpawned[id]
            if spawn then
                for _, mapIcon in pairs(spawn.mapRefs) do
                    mapIcon:Unload()
                end
                for _, minimapIcon in pairs(spawn.minimapRefs) do
                    minimapIcon:Unload()
                end
                spawn.mapRefs = {}
                spawn.minimapRefs = {}
            end
        end
        objective.AlreadySpawned = {}
        objective.spawnList = {} -- Remove the spawns for this objective, since we don't need to show them
    end
end

_DetermineIconsToDraw = function(quest, oObjective, objectiveIndex, objectiveCenter)
    local iconsToDraw = {}
    local spawnItemId

    for id, spawnData in pairs(oObjective.spawnList) do
        if spawnData.ItemId then
            spawnItemId = spawnData.ItemId
        end

        if (not oObjective.Icon) and spawnData.Icon then
            oObjective.Icon = spawnData.Icon
        end
        if (not oObjective.AlreadySpawned[id]) and (not oObjective.Completed) and Questie.db.global.enableObjectives then
            if(not iconsToDraw[quest.Id]) then
                iconsToDraw[quest.Id] = {}
            end
            local data = {
                Id = quest.Id,
                ObjectiveIndex = objectiveIndex,
                QuestData = quest,
                ObjectiveData = oObjective,
                Icon = spawnData.Icon,
                IconColor = quest.Color,
                GetIconScale = function() return spawnData:GetIconScale() or 1 end,
                Name = spawnData.Name,
                Type = oObjective.Type,
                ObjectiveTargetId = spawnData.Id
            }
            data.IconScale = data:GetIconScale()

            oObjective.AlreadySpawned[id] = {};
            oObjective.AlreadySpawned[id].data = data;
            oObjective.AlreadySpawned[id].minimapRefs = {};
            oObjective.AlreadySpawned[id].mapRefs = {};

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
                        local distance = QuestieLib:Euclid(objectiveCenter.x or 0, objectiveCenter.y or 0, x or 0, y or 0);
                        drawIcon.distance = distance or 0;
                        iconsToDraw[quest.Id][floor(distance)] = drawIcon;
                    end
                end
            end
        end
    end

    return iconsToDraw, spawnItemId
end

_DrawObjectiveIcons = function(iconsToDraw, objective, maxPerType)
    local spawnedIconCount = {}
    local icon
    local iconPerZone = {}

    for questId, icons in pairs(iconsToDraw) do
        if(not spawnedIconCount[questId]) then
            spawnedIconCount[questId] = 0;
        end

        local iconCount, orderedList = _GetIconsSortedByDistance(questId, icons, spawnedIconCount, maxPerType)

        local range = Questie.db.global.clusterLevelHotzone
        if orderedList and orderedList[1] and orderedList[1].Icon == ICON_TYPE_OBJECT then -- new clustering / limit code should prevent problems, always show all object notes
            range = range * 0.2;  -- Only use 20% of the default range.
        end

        local hotzones = QuestieMap.utils:CalcHotzones(orderedList, range, iconCount);

        for _, hotzone in pairs(hotzones or {}) do
            if(spawnedIconCount[questId] > maxPerType) then
                Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]", "Too many icons for quest:", questId)
                break;
            end

            --Any icondata will do because they are all the same
            icon = hotzone[1];

            local midPoint = QuestieMap.utils:CenterPoint(hotzone);

            local dungeonLocation = ZoneDB:GetDungeonLocation(icon.zone)

            if dungeonLocation and midPoint.x == -1 and midPoint.y == -1 then
                if dungeonLocation[2] then -- We have more than 1 instance entrance (e.g. Blackrock dungeons)
                    local secondDungeonLocation = dungeonLocation[2]
                    icon.zone = secondDungeonLocation[1]
                    midPoint.x = secondDungeonLocation[2]
                    midPoint.y = secondDungeonLocation[3]

                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, midPoint.x, midPoint.y) -- clustering code takes care of duplicates as long as mindist is more than 0
                    if iconMap and iconMini then
                        iconPerZone[icon.zone] = {iconMap, midPoint.x, midPoint.y}
                        tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                        tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
                    end
                    spawnedIconCount[questId] = spawnedIconCount[questId] + 1;
                end
                local firstDungeonLocation = dungeonLocation[1]
                icon.zone = firstDungeonLocation[1]
                midPoint.x = firstDungeonLocation[2]
                midPoint.y = firstDungeonLocation[3]
            end

            local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, midPoint.x, midPoint.y) -- clustering code takes care of duplicates as long as mindist is more than 0
            if iconMap and iconMini then
                iconPerZone[icon.zone] = {iconMap, midPoint.x, midPoint.y}
                tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
            end
            spawnedIconCount[questId] = spawnedIconCount[questId] + 1;
        end
    end

    return icon, iconPerZone
end

_GetIconsSortedByDistance = function(questId, icons, spawnedIconCount, maxPerType)
    local iconCount = 0;
    local orderedList = {}
    local tableKeys = {}

    for k in pairs(icons) do
        tinsert(tableKeys, k)
    end
    table.sort(tableKeys)

    -- use the keys to retrieve the values in the sorted order
    for _, distance in ipairs(tableKeys) do
        if(spawnedIconCount[questId] > maxPerType) then
            Questie:Debug(DEBUG_DEVELOP, "[QuestieQuest]", "Too many icons for quest:", questId)
            break;
        end
        iconCount = iconCount + 1;
        tinsert(orderedList, icons[distance]);
    end
    return iconCount, orderedList
end

_DrawObjectiveWaypoints = function(objective, icon, iconPerZone)
    for _, spawnData in pairs(objective.spawnList) do -- spawnData.Name, spawnData.Spawns
        if spawnData.Waypoints then
            for zone, waypoints in pairs(spawnData.Waypoints) do
                local firstWaypoint = waypoints[1][1]
                if (not iconPerZone[zone]) and icon and firstWaypoint[1] ~= -1 and firstWaypoint[2] ~= -1 then -- spawn an icon in this zone for the mob
                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, zone, firstWaypoint[1], firstWaypoint[2]) -- clustering code takes care of duplicates as long as mindist is more than 0
                    if iconMap and iconMini then
                        iconPerZone[zone] = {iconMap, firstWaypoint[1], firstWaypoint[2]}
                        tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                        tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
                    end
                end
                local ipz = iconPerZone[zone]
                if ipz then
                    QuestieMap:DrawWaypoints(ipz[1], waypoints, zone, spawnData.Hostile and {1,0.2,0,0.7} or nil)
                end
            end
        end
    end
end

local function _CallPopulateObjective(quest)
    for k, v in pairs(quest.Objectives) do
        local result, err = xpcall(QuestieQuest.PopulateObjective, function(err)
            print(err)
            print(debugstack())
        end, QuestieQuest, quest, k, v, false);
        if not result then
            local major, minor, patch = QuestieLib:GetAddonVersionInfo();
            local version = "v"..(major or "").."."..(minor or "").."."..(patch or "");--Doing it this way to keep it 100% safe.
            Questie:Error("[QuestieQuest]: " .. version .. " - " .. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", k or "No objective", err or "No error"));
        end
    end
end

local function _AddSourceItemObjective(quest)
    if quest.sourceItemId then
        local item = QuestieDB.QueryItemSingle(quest.sourceItemId, "name")--local item = QuestieDB:GetItem(quest.sourceItemId);
        if item then
            -- We fake an objective for the sourceItems because this allows us
            -- to simply reuse "QuestieTooltips:GetTooltip".
            -- This should be all the data required for the tooltip
            local fakeObjective = {
                IsSourceItem = true,
                QuestData = quest,
                Index = 1,
                Needed = 1,
                Collected = 1,
                text = item,
                Description = item
            }

            QuestieTooltips:RegisterObjectiveTooltip(quest.Id, "i_" .. quest.sourceItemId, fakeObjective);
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

    if (not quest.Color) then
        quest.Color = QuestieLib:GetRandomColor(quest.Id)
    end

    -- we've already checked the objectives table by doing IsComplete
    -- if that changes, check it here
    _CallPopulateObjective(quest)
    _AddSourceItemObjective(quest)

    -- check for special (unlisted) DB objectives
    if next(quest.SpecialObjectives) then
        Questie:Debug(DEBUG_DEVELOP, "Adding special objectives")
        local index = 0 -- SpecialObjectives is a string table, but we need a number
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, function(err)
                print(err)
                print(debugstack())
            end, QuestieQuest, quest, index, objective, true);
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
            index = index + 1
        end
    end
end

function QuestieQuest:PopulateQuestLogInfo(quest)
    if quest.Objectives == nil then
        Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: PopulateQuestLogInfo: Creating new objective table")
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

--Uses the category order to draw the quests and trusts the database order.
function QuestieQuest:GetAllQuestObjectives(quest)
    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(quest.Id) or {}

    for objectiveIndex, objective in pairs(questObjectives) do
        if objective.type and string.len(objective.type) > 1 then
            if (not quest.ObjectiveData) or (not quest.ObjectiveData[objectiveIndex]) then
                Questie:Error(Questie.TBC_BETA_BUILD_VERSION_SHORTHAND.."Missing objective data for quest " .. quest.Id .. " and objective " .. objective.text)
            else
                if quest.Objectives[objectiveIndex] == nil then
                    quest.Objectives[objectiveIndex] = {}

                    -- Sometimes we need to retry to get the correct text from the API
                    if (not objective.text) or objective.text:sub(1, 1) == " " then
                        Questie:Debug(DEBUG_INFO, "Retrying to get objectiveText for '", objective.text, "'")
                        local retry = C_QuestLog.GetQuestObjectives(quest.Id)
                        objective.text = retry[objectiveIndex].text
                        Questie:Debug(DEBUG_INFO, "Received text is:", retry[objectiveIndex].text)
                    end
                    quest.Objectives[objectiveIndex] = {
                        Id = quest.ObjectiveData[objectiveIndex].Id,
                        Index = objectiveIndex,
                        questId = quest.Id,
                        QuestData = quest,
                        _lastUpdate = 0,
                        Description = objective.text,
                        spawnList = {},
                        AlreadySpawned = {},
                        Update = _ObjectiveUpdate,
                        Coordinates = quest.ObjectiveData[objectiveIndex].Coordinates, -- Only for type "event"
                        RequiredRepValue = quest.ObjectiveData[objectiveIndex].RequiredRepValue
                    }
                end

                quest.Objectives[objectiveIndex]:Update()
            end
        end

        if (not quest.Objectives[objectiveIndex]) or (not quest.Objectives[objectiveIndex].Id) then
            Questie:Debug(DEBUG_SPAM, "[QuestieQuest]: Error finding entry ID for objective", objective.type, objective.text)
        end
    end

    -- find special unlisted objectives
    if next(quest.SpecialObjectives) then
        for index, specialObjective in pairs(quest.SpecialObjectives) do
            if (not specialObjective.Description) then
                specialObjective.Description = "Special objective"
            end

            specialObjective.questId = quest.Id
            specialObjective.Update = function() end
            specialObjective.Index = 64 + index -- offset to not conflict with real objectives
            specialObjective.spawnList = specialObjective.spawnList or {}
            specialObjective.AlreadySpawned = {}
        end
    end

    return quest.Objectives
end

_ObjectiveUpdate = function(self)
    local now = GetTime();
    if now - self._lastUpdate < 0.5 then
        return {self.Collected, self.Needed, self.Completed} -- updated too recently
    end
    self._lastUpdate = now

    -- Use different variable names from above to avoid confusion.
    local qObjectives = QuestieQuest:GetAllLeaderBoardDetails(self.questId);

    if qObjectives and qObjectives[self.Index] then
        local obj = qObjectives[self.Index];
        if (obj.type) then
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
    return {self.Collected, self.Needed, self.Completed}
end

--- Quests like "The Nightmare's Corruption" have multiple objectives with the same
--- text for each objective. Therefore these need to be handled separatly (see #2308)
---@return number
_GetObjectiveIdForSpecialQuest = function(questId, objectiveIndex)
    if questId == 8735 then
        if objectiveIndex == 1 then
            return 21147
        elseif objectiveIndex == 2 then
            return 21149
        elseif objectiveIndex == 3 then
            return 21148
        elseif objectiveIndex == 4 then
            return 21146
        end
    elseif questId == 4282 then
        if objectiveIndex == 1 then
            return 11464
        else
            return 11465
        end
    end
    return 0
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
local _has_seen_incomplete = {}
local _has_sent_announce = {}
function QuestieQuest:GetAllLeaderBoardDetails(questId)
    Questie:Debug(DEBUG_SPAM, "[QuestieQuest:GetAllLeaderBoardDetails] for questId", questId)
    local questObjectives = QuestieLib:GetQuestObjectives(questId);
    if not questObjectives then
        -- Some quests just don't have a real objective e.g. 2744
        return nil
    end

    --Questie:Print(questId)
    for _, objective in pairs(questObjectives) do
        if(objective.text) then
            local text = objective.text;
            if(objective.type == "monster") then
                local n, _, monsterName = smatch(text, L_QUEST_MONSTERS_KILLED)
                if tonumber(monsterName) then -- SOME objectives are reversed in TBC, why blizzard?
                    monsterName = n
                end

                if((monsterName and objective.text and strlen(monsterName) == strlen(objective.text)) or not monsterName) then
                    --The above doesn't seem to work with the chinese, the row below tries to remove the extra numbers.
                    local cleanerText = smatch(monsterName or text, "(.*)：");
                    text = cleanerText
                else
                    text = monsterName;
                end
            elseif(objective.type == "item") then
                local n, _, itemName = smatch(text, L_QUEST_ITEMS_NEEDED)
                if tonumber(itemName) then -- SOME objectives are reversed in TBC, why blizzard?
                    itemName = n
                end

                text = itemName;
            elseif(objective.type == "object") then
                local n, _, objectName = smatch(text, L_QUEST_OBJECTS_FOUND)
                if tonumber(objectName) then -- SOME objectives are reversed in TBC, why blizzard?
                    objectName = n
                end

                text = objectName;
            end
            -- If the functions above do not give a good answer fall back to older regex to get something.
            if(text == nil) then
                text = smatch(objective.text, "^(.*):%s") or smatch(objective.text, "%s：(.*)$") or smatch(objective.text, "^(.*)：%s") or objective.text;
            end
            --If objective.text is nil, this will be nil, throw error!
            if(text ~= nil) then
                objective.text = strim(text);
                local completed = objective.numRequired == objective.numFulfilled

                if (not completed) then
                    _has_seen_incomplete[objective.text] = true
                elseif _has_seen_incomplete[objective.text] and not _has_sent_announce[objective.text] then
                    _has_seen_incomplete[objective.text] = nil
                    _has_sent_announce[objective.text] = true
                    QuestieAnnounce:AnnounceParty(questId, "objective", spawnItemId, objective.text, tostring(objective.numFulfilled) .. "/" .. tostring(objective.numRequired))
                end
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
        for _, objectId in ipairs(quest.Starts["GameObject"]) do
            local obj = QuestieDB:GetObject(objectId)
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
        for _, npcId in ipairs(quest.Starts["NPC"]) do
            local npc = QuestieDB:GetNPC(npcId)

            QuestieTooltips:RegisterQuestStartTooltip(quest.Id, npc)

            if (npc ~= nil and npc.spawns ~= nil) then
                --Questie:Debug(DEBUG_DEVELOP,"Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                local starterIcons = {}
                local starterLocs = {}
                for npcZone, spawns in pairs(npc.spawns) do
                    if(npcZone ~= nil and spawns ~= nil) then

                        for _, coords in ipairs(spawns) do
                            local data = {}
                            data.Id = quest.Id;
                            data.Icon = _QuestieQuest:GetQuestIcon(quest)
                            data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                            data.IconScale = data.GetIconScale();
                            data.Type = "available";
                            data.QuestData = quest;
                            data.Name = npc.name
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
                                starterIcons[npcZone] = QuestieMap:DrawWorldIcon(data, npcZone, x, y)
                                if not starterLocs[npcZone] then
                                    starterLocs[npcZone] = {x, y}
                                end
                            end
                        end
                    end
                end

                if npc.waypoints then
                    for zone, waypoints in pairs(npc.waypoints) do
                        if not dungeons[zone] and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then
                            if not starterIcons[zone] then
                                local data = {}
                                data.Id = quest.Id;
                                data.Icon = _QuestieQuest:GetQuestIcon(quest)
                                data.GetIconScale = function() return Questie.db.global.availableScale or 1.3 end
                                data.IconScale = data.GetIconScale();
                                data.Type = "available";
                                data.QuestData = quest;
                                data.Name = npc.name
                                data.IsObjectiveNote = false
                                starterIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                                starterLocs[zone] = {waypoints[1][1][1], waypoints[1][1][2]}
                            end
                            QuestieMap:DrawWaypoints(starterIcons[zone], waypoints, zone)
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
    Questie:Debug(DEBUG_INFO, "[QuestieQuest] 0 available quests drawn. PlayerLevel =", QuestiePlayer:GetPlayerLevel());

    local data = QuestieDB.QuestPointers or QuestieDB.questData
    local index = next(data)
    local timer -- if you do local timer = C_Timer then "timer" cant be accessed inside

    local playerLevel = QuestiePlayer:GetPlayerLevel()
    local minLevel = playerLevel - GetQuestGreenRange("player")
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

    timer = C_Timer.NewTicker(0.01, function()
        for _=0,64 do -- number of available quests to process per tick
            local questId = index
            if questId then
                --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
                if(
                    (not Questie.db.char.complete[questId]) and -- Don't show completed quests
                    ((not QuestiePlayer.currentQuestlog[questId]) or QuestieDB:IsComplete(questId) == -1) and -- Don't show quests if they're already in the quest log
                    (not QuestieCorrections.hiddenQuests[questId]) and -- Don't show blacklisted quests
                    (showRepeatableQuests or (not QuestieDB:IsRepeatable(questId))) and  -- Show repeatable quests if the quest is repeatable and the option is enabled
                    (showDungeonQuests or (not QuestieDB:IsDungeonQuest(questId))) and  -- Show dungeon quests only with the option enabled
                    (showRaidQuests or (not QuestieDB:IsRaidQuest(questId))) and  -- Show Raid quests only with the option enabled
                    (showPvPQuests or (not QuestieDB:IsPvPQuest(questId))) and -- Show PvP quests only with the option enabled
                    (showAQWarEffortQuests or (not QuestieQuestBlacklist.AQWarEffortQuests[questId])) -- Don't show AQ War Effort quests with the option enabled
                ) then

                    if QuestieDB:IsLevelRequirementsFulfilled(questId, minLevel, maxLevel) and QuestieDB:IsDoable(questId) then
                        QuestieQuest.availableQuests[questId] = true
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
                        QuestieMap:UnloadQuestFrames(questId)
                        if QuestieQuest.availableQuests[questId] then
                            QuestieTooltips:RemoveQuest(questId)
                        end
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

function QuestieQuest:DrawDailyQuest(questId)
    local quest = QuestieDB:GetQuest(questId)
    if QuestieDB:IsDoable(questId) then
        _QuestieQuest:DrawAvailableQuest(quest)
    end
end
