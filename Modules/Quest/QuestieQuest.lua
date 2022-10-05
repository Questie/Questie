--- COMPATIBILITY ---
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
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type TaskQueue
local TaskQueue = QuestieLoader:ImportModule("TaskQueue")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
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
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

--We should really try and squeeze out all the performance we can, especially in this.
local tostring = tostring;
local tinsert = table.insert;
local pairs = pairs;
local ipairs = ipairs;

QuestieQuest.availableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

--- A list of quests that will never be available, used to quickly skip quests.
---@alias AutoBlacklistString "rep"|"skill"|"race"|"class"
---@type table<number, AutoBlacklistString>
QuestieQuest.autoBlacklist = {}

local NOP_FUNCTION = function() end
local ERR_FUNCTION = function(err)
    print(err)
    print(debugstack())
end

-- forward declaration
local _UnloadAlreadySpawnedIcons
local _RegisterObjectiveTooltips, _RegisterAllObjectiveTooltips, _DetermineIconsToDraw, _GetIconsSortedByDistance
local _DrawObjectiveIcons, _DrawObjectiveWaypoints

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local dungeons = ZoneDB:GetDungeons()

function QuestieQuest:Initialize()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest]: Getting all completed quests")
    Questie.db.char.complete = GetQuestsCompleted()

    QuestieProfessions:Update()
    QuestieReputation:Update(true)
end

---@param category AutoBlacklistString
function QuestieQuest.ResetAutoblacklistCategory(category)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest]: Resetting autoblacklist category", category)
    for questId, questCategory in pairs(QuestieQuest.autoBlacklist) do
        if questCategory == category then
            QuestieQuest.autoBlacklist[questId] = nil
        end
    end
end

function QuestieQuest:ToggleNotes(showIcons)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:ToggleNotes] showIcons:", showIcons)
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
        if (not trackerHiddenQuests) or (not trackerHiddenQuests[questId]) then -- Skip quests which are completly hidden from the Tracker menu
            for _, frameName in pairs(frameList) do -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                ---@type IconFrame
                local icon = _G[frameName];
                if not icon.data then
                    error("Desync! Icon has not been removed correctly, but has already been resetted. Skipping frame \"" .. frameName .. "\" for quest " .. questId)
                else
                    local objectiveString = tostring(questId) .. " " .. tostring(icon.data.ObjectiveIndex)
                    if (not Questie.db.char.TrackerHiddenObjectives) or (not Questie.db.char.TrackerHiddenObjectives[objectiveString]) then
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

        quest.Objectives = {}

        if next(quest.SpecialObjectives) then
            for _,s in pairs(quest.SpecialObjectives) do
                s.AlreadySpawned = {}
            end
        end
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
---@param questId number
local function _UpdateSpecials(questId)
    local quest = QuestieDB:GetQuest(questId)
    if quest and next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, 0, objective, true)
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
        end
    end
end

function QuestieQuest:SmoothReset()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:SmoothReset]")
    if QuestieQuest._isResetting then
        QuestieQuest._resetAgain = true
        return
    end
    QuestieQuest._isResetting = true
    QuestieQuest._resetNeedsAvailables = false

    -- bit of a hack (there has to be a better way to do logic like this
    QuestieDBMIntegration:ClearAll()
    local stepTable = {
        function()
            -- Wait until game cache has quest log okey.
            return QuestLogCache.TestGameCache()
        end,
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

            --- reset the blacklist
            QuestieQuest.autoBlacklist = {}

            -- make sure complete db is correct
            Questie.db.char.complete = GetQuestsCompleted()
            QuestieProfessions:Update()
            QuestieReputation:Update(true)

            -- populate QuestiePlayer.currentQuestlog
            QuestieQuest:GetAllQuestIdsNoObjectives()
            QuestieQuest._nextRestQuest = next(QuestiePlayer.currentQuestlog)
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
            return (not QuestieQuest._resetNeedsAvailables) and #QuestieMap._mapDrawQueue == 0 and #QuestieMap._minimapDrawQueue == 0
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
            if not stepTable[step] then
                ticker:Cancel()
            end
        end
        if QuestieQuest._resetAgain and not QuestieQuest._resetNeedsAvailables then -- we can stop the current reset
            ticker:Cancel()
            QuestieQuest._resetAgain = nil
            QuestieQuest._isResetting = nil
            QuestieQuest:SmoothReset()
        end
    end)
end

---@param questId number
---@return boolean
function QuestieQuest:ShouldShowQuestNotes(questId)
    if not Questie.db.char.hideUntrackedQuestsMapIcons then
        -- Always show quest notes (map icons) unless option is enabled
        return true
    end

    local autoWatch = Questie.db.global.autoTrackQuests
    local trackedAuto = autoWatch and (not Questie.db.char.AutoUntrackedQuests or not Questie.db.char.AutoUntrackedQuests[questId])
    local trackedManual = not autoWatch and (Questie.db.char.TrackedQuests and Questie.db.char.TrackedQuests[questId])
    return trackedAuto or trackedManual
end

function QuestieQuest:HideQuest(id)
    Questie.db.char.hidden[id] = true
    QuestieMap:UnloadQuestFrames(id);
end

function QuestieQuest:UnhideQuest(id)
    Questie.db.char.hidden[id] = nil
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
end

---@param questId number
function QuestieQuest:AcceptQuest(questId)
    if not QuestiePlayer.currentQuestlog[questId] then
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Accepted Quest:", questId)

        local quest = QuestieDB:GetQuest(questId)
        QuestiePlayer.currentQuestlog[questId] = quest

        TaskQueue:Queue(
            --Get all the Frames for the quest and unload them, the available quest icon for example.
            function() QuestieMap:UnloadQuestFrames(questId) end,
            function() QuestieTooltips:RemoveQuest(questId) end,
            function() if Questie.db.char.collapsedQuests then Questie.db.char.collapsedQuests[questId] = nil end end,  -- re-accepted quest can be collapsed. expand it. specially dailies.
            function() QuestieQuest:PopulateQuestLogInfo(quest) end,
            function() QuestieQuest:PopulateObjectiveNotes(quest) end,
            function() QuestieTracker:Update() end,
            QuestieQuest.CalculateAndDrawAvailableQuestsIterative
        )

        --Broadcast an update.
        --Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId); -- :UpdateQuest is called immediately after AcceptQuest now, so this is redundant
    else
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Accepted Quest:", questId, " Warning: Quest already existed, not adding")
    end
end

---@param questId number
function QuestieQuest:CompleteQuest(questId)
    QuestiePlayer.currentQuestlog[questId] = nil;
    -- Only quests that are daily quests or aren't repeatable should be marked complete,
    -- otherwise objectives for repeatable quests won't track correctly - #1433
    Questie.db.char.complete[questId] = QuestieDB.IsDailyQuest(questId) or (not QuestieDB.IsRepeatable(questId));

    QuestieMap:UnloadQuestFrames(questId)
    if (QuestieMap.questIdFrames[questId]) then
        Questie:Error("Just removed all frames but the framelist seems to still be there!", questId)
    end

    QuestieTooltips:RemoveQuest(questId)
    QuestieTracker:RemoveQuest(questId)
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)

    --This should probably be done first, because DrawAllAvailableQuests looks at QuestieMap.questIdFrames[QuestId] to add available
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Completed Quest:", questId)
end

---@param questId number
function QuestieQuest:AbandonedQuest(questId)
    QuestieTooltips:RemoveQuest(questId)
    if(QuestiePlayer.currentQuestlog[questId]) then
        QuestiePlayer.currentQuestlog[questId] = nil

        QuestieMap:UnloadQuestFrames(questId);

        local quest = QuestieDB:GetQuest(questId);
        if quest then
            quest.Objectives = {}

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
            if (not availableQuest) or (not QuestieDB.IsDoable(k)) then
                QuestieMap:UnloadQuestFrames(k);
            end
        end

        QuestieTracker:RemoveQuest(questId)
        QuestieTooltips:RemoveQuest(questId)
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)

        QuestieQuest:CalculateAndDrawAvailableQuestsIterative()

        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Abandoned Quest:", questId)
    end
end

---@param questId number
function QuestieQuest:UpdateQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest]", questId)
    ---@type Quest
    local quest = QuestieDB:GetQuest(questId)
    if quest and (not Questie.db.char.complete[questId]) then
        QuestieQuest:PopulateQuestLogInfo(quest)

        if QuestieQuest:ShouldShowQuestNotes(questId) then
            QuestieQuest:UpdateObjectiveNotes(quest)
        end

        local isComplete = quest:IsComplete()
        if isComplete == 1 then -- Quest is complete
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest is complete")
            QuestieMap:UnloadQuestFrames(questId)
            --QuestieTooltips:RemoveQuest(questId)
            QuestieQuest:AddFinisher(quest)
        elseif isComplete == -1 then -- Failed quests should be shown as available again
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest failed")
            QuestieMap:UnloadQuestFrames(questId)
            QuestieTooltips:RemoveQuest(questId)
            _QuestieQuest:DrawAvailableQuest(quest)
        end
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)

        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId)
    end
end

---@param questId number
function QuestieQuest:SetObjectivesDirty(questId)
    local quest = QuestieDB:GetQuest(questId)
    if quest then
        for _, objective in pairs(quest.Objectives) do
            objective.isUpdated = false
        end
    end
end

--Run this if you want to update the entire table
function QuestieQuest:GetAllQuestIds()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Getting all quests")
    QuestiePlayer.currentQuestlog = {}

    for questId, data in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
        if (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        elseif data.isComplete ~= -1 then -- TODO FIX LATER. Now currentQuestLog may have part of failed quests. Check what is needed? All or none of those?
            --Keep the object in the questlog to save searching
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                QuestiePlayer.currentQuestlog[questId] = quest
                QuestieQuest:PopulateQuestLogInfo(quest)

                quest.LocalizedName = data.title

                if QuestieQuest:ShouldShowQuestNotes(questId) then
                    QuestieQuest:PopulateObjectiveNotes(quest)
                end
            else
                QuestiePlayer.currentQuestlog[questId] = questId -- TODO FIX LATER. codebase is expecting this to be "quest" not "questId"
            end
            Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest] Adding the quest", questId, QuestiePlayer.currentQuestlog[questId])
        end
    end
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

function QuestieQuest:GetAllQuestIdsNoObjectives()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Getting all quests without objectives")
    QuestiePlayer.currentQuestlog = {}

    for questId in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
        if (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        else
            --Keep the object in the questlog to save searching
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                QuestiePlayer.currentQuestlog[questId] = quest
            else
                QuestiePlayer.currentQuestlog[questId] = questId
            end
            Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest] Adding the quest", questId, QuestiePlayer.currentQuestlog[questId])
        end
    end
end

-- iterate all notes, update / remove as needed
---@param quest Quest
function QuestieQuest:UpdateObjectiveNotes(quest)
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest] UpdateObjectiveNotes:", quest.Id)
    for objectiveIndex, objective in pairs(quest.Objectives) do
        local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, objectiveIndex, objective, false)
        if (not result) then
            Questie:Debug(Questie.DEBUG_ELEVATED, "[QuestieQuest] There was an error populating objectives for", quest.name, quest.Id, objectiveIndex, err)
        end
    end
end

local function _GetIconScaleForAvailable()
    return Questie.db.global.availableScale or 1.3
end

---@param quest Quest
function QuestieQuest:AddFinisher(quest)
    --We should never ever add the quest if IsQuestFlaggedComplete true.
    local questId = quest.Id
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Adding finisher for quest", questId)

    if (QuestiePlayer.currentQuestlog[questId] and (IsQuestFlaggedCompleted(questId) == false) and (quest:IsComplete() == 1) and (not Questie.db.char.complete[questId])) then
        local finisher
        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                finisher = QuestieDB:GetNPC(quest.Finisher.Id)
            elseif quest.Finisher.Type == "object" then
                finisher = QuestieDB:GetObject(quest.Finisher.Id)
            else
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] Unhandled finisher type:", quest.Finisher.Type, questId, quest.name)
            end
        else
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] Quest has no finisher:", questId, quest.name)
        end
        if(finisher ~= nil and finisher.spawns ~= nil) then
            QuestieTooltips:RegisterQuestStartTooltip(questId, finisher)

            local finisherIcons = {}
            local finisherLocs = {}
            for finisherZone, spawns in pairs(finisher.spawns) do
                if(finisherZone ~= nil and spawns ~= nil) then
                    for _, coords in ipairs(spawns) do
                        local data = {
                            Id = questId,
                            Icon = ICON_TYPE_COMPLETE,
                            GetIconScale = _GetIconScaleForAvailable,
                            IconScale = _GetIconScaleForAvailable(),
                            Type = "complete",
                            QuestData = quest,
                            Name = finisher.name,
                            IsObjectiveNote = false,
                        }
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
                            local x = coords[1];
                            local y = coords[2];

                            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] Adding world icon as finisher:", finisherZone, x, y)
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
                            local data = {
                                Id = questId,
                                Icon = ICON_TYPE_COMPLETE,
                                GetIconScale = _GetIconScaleForAvailable,
                                IconScale = _GetIconScaleForAvailable(),
                                Type = "complete",
                                QuestData = quest,
                                Name = finisher.name,
                                IsObjectiveNote = false,
                            }
                            finisherIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                            finisherLocs[zone] = {waypoints[1][1][1], waypoints[1][1][2]}
                        end
                        QuestieMap:DrawWaypoints(finisherIcons[zone], waypoints, zone)
                    end
                end
            end
        else
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] finisher or finisher.spawns == nil")
        end
    end
end


---@param quest Quest
---@param objectiveIndex ObjectiveIndex
---@param objective QuestObjective
---@param blockItemTooltips any
function QuestieQuest:PopulateObjective(quest, objectiveIndex, objective, blockItemTooltips) -- must be pcalled
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:PopulateObjective]", objective.Description)

    if (not objective.Update) then
        -- TODO: This is a dirty band aid, to hide Lua errors to the users.
        -- Some reports suggest there might be a race condition for SpecialObjectives so they don't get the fields used in here
        -- before PopulateObjective is called.
        return
    end

    objective:Update()
    local completed = objective.Completed

    local objectiveData = quest.ObjectiveData[objective.Index] or objective -- the reason for "or objective" is to handle "SpecialObjectives" aka non-listed objectives (demonic runestones for closing the portal)

    if (not next(objective.spawnList)) and _QuestieQuest.objectiveSpawnListCallTable[objectiveData.Type] then
        objective.spawnList = _QuestieQuest.objectiveSpawnListCallTable[objectiveData.Type](objective.Id, objective, objectiveData);
    end

    -- Tooltips should always show.
    -- For completed and uncompleted objectives
    _RegisterObjectiveTooltips(objective, quest.Id, blockItemTooltips)

    if completed then
        _UnloadAlreadySpawnedIcons(objective)
        return
    end

    if (not objective.Color) then
        objective.Color = QuestieLib:GetRandomColor(quest.Id + 32768 * objectiveIndex)
    end

    if next(objective.spawnList) then
        local maxPerType = 300
        if Questie.db.global.enableIconLimit then
            maxPerType = Questie.db.global.iconLimit
        end

        local closestStarter = QuestieMap:FindClosestStarter()
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
            local x, y = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, ZoneDB:GetUiMapIdByAreaId(objectiveZone))
            objectiveCenter = { x = x, y = y}
        end

        local iconsToDraw, _  = _DetermineIconsToDraw(quest, objective, objectiveIndex, objectiveCenter)
        local icon, iconPerZone = _DrawObjectiveIcons(quest.Id, iconsToDraw, objective, maxPerType)
        _DrawObjectiveWaypoints(objective, icon, iconPerZone)
    end
end

---@param quest Quest
_RegisterAllObjectiveTooltips = function(quest)
    for _, objective in pairs(quest.Objectives) do
        _RegisterObjectiveTooltips(objective, quest.Id, false)
    end
end

_RegisterObjectiveTooltips = function(objective, questId, blockItemTooltips)
    Questie:Debug(Questie.DEBUG_INFO, "Registering objective tooltips for", objective.Description)

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

    if (not objective.registeredItemTooltips) and objective.Type == "item" and (not blockItemTooltips) and objective.Id then
        local item = QuestieDB.QueryItemSingle(objective.Id, "name")
        if item then
            QuestieTooltips:RegisterObjectiveTooltip(questId, "i_" .. objective.Id, objective);
        end
        objective.registeredItemTooltips = true
    end
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

---@param quest Quest
---@param objective QuestObjective
---@param objectiveIndex ObjectiveIndex
---@param objectiveCenter {x:X, y:Y}
_DetermineIconsToDraw = function(quest, objective, objectiveIndex, objectiveCenter)
    local iconsToDraw = {}
    local spawnItemId

    for id, spawnData in pairs(objective.spawnList) do
        if spawnData.ItemId then
            spawnItemId = spawnData.ItemId
        end

        if (not objective.Icon) and spawnData.Icon then
            objective.Icon = spawnData.Icon
        end
        if (not objective.AlreadySpawned[id]) and (not objective.Completed) and Questie.db.global.enableObjectives then
            local data = {
                Id = quest.Id,
                ObjectiveIndex = objectiveIndex,
                QuestData = quest,
                ObjectiveData = objective,
                Icon = spawnData.Icon,
                IconColor = quest.Color,
                GetIconScale = spawnData.GetIconScale,
                IconScale = spawnData.GetIconScale(),
                Name = spawnData.Name,
                Type = objective.Type,
                ObjectiveTargetId = spawnData.Id
            }

            objective.AlreadySpawned[id] = {
                data = data,
                minimapRefs = {},
                mapRefs = {},
            }

            for zone, spawns in pairs(spawnData.Spawns) do
                local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
                for _, spawn in pairs(spawns) do
                    if(spawn[1] and spawn[2]) then
                        local drawIcon = {
                            AlreadySpawnedId = id,
                            data = data,
                            zone = zone,
                            AreaID = zone,
                            UiMapID = uiMapId,
                            x = spawn[1],
                            y = spawn[2],
                            worldX = 0,
                            worldY = 0,
                            distance = 0,
                            touched = nil, -- TODO change. This is ment to let lua reserve memory for all keys needed for sure.
                        }
                        local x, y, _ = HBD:GetWorldCoordinatesFromZone(drawIcon.x/100, drawIcon.y/100, uiMapId)
                        x = x or 0
                        y = y or 0
                        -- Cache world coordinates for clustering calculations
                        drawIcon.worldX = x
                        drawIcon.worldY = y
                        -- There are instances when X and Y are not in the same map such as in dungeons etc, we default to 0 if it is not set
                        -- This will create a distance of 0 but it doesn't matter.
                        local distance = QuestieLib:Euclid(objectiveCenter.x or 0, objectiveCenter.y or 0, x, y);
                        drawIcon.distance = distance or 0 -- cache for clustering
                        -- there can be multiple icons at same distance at different directions
                        --local distance = floor(distance)
                        local iconList = iconsToDraw[distance]
                        if iconList then
                            iconList[#iconList+1] = drawIcon
                        else
                            iconsToDraw[distance] = { drawIcon }
                        end
                    end
                end
            end
        end
    end

    return iconsToDraw, spawnItemId
end

_DrawObjectiveIcons = function(questId, iconsToDraw, objective, maxPerType)
    local spawnedIconCount = 0
    local icon
    local iconPerZone = {}

    local range = Questie.db.global.clusterLevelHotzone

    local iconCount, orderedList = _GetIconsSortedByDistance(iconsToDraw)

    if orderedList[1] and orderedList[1].Icon == ICON_TYPE_OBJECT then -- new clustering / limit code should prevent problems, always show all object notes
        range = range * 0.2;  -- Only use 20% of the default range.
    end

    local hotzones = QuestieMap.utils:CalcHotzones(orderedList, range, iconCount);

    for i=1, #hotzones do
        local hotzone = hotzones[i]
        if(spawnedIconCount > maxPerType) then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] Too many icons for quest:", questId)
            break;
        end

        --Any icondata will do because they are all the same
        icon = hotzone[1];

        local spawnsMapRefs = objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs
        local spawnsMinimapRefs = objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs

        local centerX, centerY = QuestieMap.utils.CenterPoint(hotzone)

        local dungeonLocation = ZoneDB:GetDungeonLocation(icon.zone)

        if dungeonLocation and centerX == -1 and centerY == -1 then
            if dungeonLocation[2] then -- We have more than 1 instance entrance (e.g. Blackrock dungeons)
                local secondDungeonLocation = dungeonLocation[2]
                icon.zone = secondDungeonLocation[1]
                centerX = secondDungeonLocation[2]
                centerY = secondDungeonLocation[3]

                local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, centerX, centerY) -- clustering code takes care of duplicates as long as mindist is more than 0
                if iconMap and iconMini then
                    iconPerZone[icon.zone] = {iconMap, centerX, centerY}
                    spawnsMapRefs[#spawnsMapRefs+1] = iconMap
                    spawnsMinimapRefs[#spawnsMinimapRefs+1] = iconMini
                end
                spawnedIconCount = spawnedIconCount + 1;
            end
            local firstDungeonLocation = dungeonLocation[1]
            icon.zone = firstDungeonLocation[1]
            centerX = firstDungeonLocation[2]
            centerY = firstDungeonLocation[3]
        end

        local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, centerX, centerY) -- clustering code takes care of duplicates as long as mindist is more than 0
        if iconMap and iconMini then
            iconPerZone[icon.zone] = {iconMap, centerX, centerY}
            spawnsMapRefs[#spawnsMapRefs+1] = iconMap
            spawnsMinimapRefs[#spawnsMinimapRefs+1] = iconMini
        end
        spawnedIconCount = spawnedIconCount + 1;
    end

    return icon, iconPerZone
end

_GetIconsSortedByDistance = function(icons)
    local iconCount = 0;
    local orderedList = {}
    local distances = {}

    local i = 0
    for distance in pairs(icons) do
        i = i + 1
        distances[i] = distance
    end
    table.sort(distances)

    -- use the keys to retrieve the values in the sorted order
    for distIndex = 1, #distances do
        local iconsAtDisntace = icons[distances[distIndex]]
        for iconIndex = 1, #iconsAtDisntace do
            local icon = iconsAtDisntace[iconIndex]
            iconCount = iconCount + 1
            orderedList[iconCount] = icon
        end
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


---@param quest Quest
local function _CallPopulateObjective(quest)
    for objectiveIndex, questObjective in pairs(quest.Objectives) do
        local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, objectiveIndex, questObjective, false);
        if not result then
            local major, minor, patch = QuestieLib:GetAddonVersionInfo();
            local version = "v"..(major or "").."."..(minor or "").."."..(patch or "");--Doing it this way to keep it 100% safe.
            Questie:Error("[QuestieQuest]: " .. version .. " - " .. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", objectiveIndex or "No objective", err or "No error"));
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

---@param quest Quest
function QuestieQuest:PopulateObjectiveNotes(quest) -- this should be renamed to PopulateNotes as it also handles finishers now
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:PopulateObjectiveNotes] Populating objectives for:", quest.Id)
    if (not quest) then
        return
    end

    if quest:IsComplete() == 1 then
        _AddSourceItemObjective(quest)
        --_RegisterAllObjectiveTooltips(quest)
        _CallPopulateObjective(quest)

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
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:PopulateObjectiveNotes] Adding special objectives")
        local index = 0 -- SpecialObjectives is a string table, but we need a number
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, index, objective, true)
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] ".. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
            index = index + 1
        end
    end
end

---@param quest Quest
---@return true?
function QuestieQuest:PopulateQuestLogInfo(quest)
    if (not quest) then
        return nil
    end
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest:PopulateQuestLogInfo] ", quest.Id)

    local questLogEngtry = QuestLogCache.GetQuest(quest.Id) -- DO NOT MODIFY THE RETURNED TABLE
    if (not questLogEngtry) then return end

    quest.isComplete = questLogEngtry.isComplete
    if quest.isComplete ~= nil and quest.isComplete == 1 then
        quest.isComplete = true
    end

--Uses the category order to draw the quests and trusts the database order.

    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(quest.Id) or {}-- DO NOT MODIFY THE RETURNED TABLE

    for objectiveIndex, objective in pairs(questObjectives) do
        if objective.type and string.len(objective.type) > 1 then
            if (not quest.ObjectiveData) or (not quest.ObjectiveData[objectiveIndex]) then
                Questie:Error("Missing objective data for quest " .. quest.Id .. " and objective " .. objective.text)
            else
                if not quest.Objectives[objectiveIndex] then
                    quest.Objectives[objectiveIndex] = {
                        Id = quest.ObjectiveData[objectiveIndex].Id,
                        Index = objectiveIndex,
                        questId = quest.Id,
                        QuestData = quest,
                        _lastUpdate = 0,
                        Description = objective.text,
                        spawnList = {},
                        AlreadySpawned = {},
                        Update = _QuestieQuest.ObjectiveUpdate,
                        Coordinates = quest.ObjectiveData[objectiveIndex].Coordinates, -- Only for type "event"
                        RequiredRepValue = quest.ObjectiveData[objectiveIndex].RequiredRepValue
                    }
                end

                quest.Objectives[objectiveIndex]:Update()
            end
        end

        if (not quest.Objectives[objectiveIndex]) or (not quest.Objectives[objectiveIndex].Id) then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:PopulateQuestLogInfo] Error finding entry ID for objective", objectiveIndex, objective.type, objective.text, "of questId:", quest.Id)
        end
    end

    -- find special unlisted objectives
    if next(quest.SpecialObjectives) then
        for index, specialObjective in pairs(quest.SpecialObjectives) do
            if (not specialObjective.Description) then
                specialObjective.Description = "Special objective"
            end

            specialObjective.questId = quest.Id
            specialObjective.Update = NOP_FUNCTION
            specialObjective.Index = 64 + index -- offset to not conflict with real objectives
            specialObjective.spawnList = specialObjective.spawnList or {}
            specialObjective.AlreadySpawned = {}
        end
    end
    return true
end

---@param self QuestObjective @quest.Objectives[] entry
function _QuestieQuest.ObjectiveUpdate(self)
    if self.isUpdated then
        return
    end

    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(self.questId) -- DO NOT MODIFY THE RETURNED TABLE

    if questObjectives and questObjectives[self.Index] then
        local obj = questObjectives[self.Index] -- DO NOT EDIT THE TABLE
        if (obj.type) then
            -- fixes for api bug
            local numFulfilled = obj.numFulfilled or 0
            local numRequired = obj.numRequired or 0
            local finished = obj.finished or false -- ensure its boolean false and not nil (hack)

            self.Type = obj.type;
            self.Description = obj.text
            self.Collected = tonumber(numFulfilled);
            self.Needed = tonumber(numRequired);
            self.Completed = (self.Needed == self.Collected and self.Needed > 0) or (finished and (self.Needed == 0 or (not self.Needed))) -- some objectives get removed on PLAYER_LOGIN because isComplete is set to true at random????
            -- Mark objective updated
            self.isUpdated = true
        end
    end
end

---@param questId number
---@return table<ObjectiveIndex, QuestLogCacheObjectiveData>|nil @DO NOT EDIT RETURNED TABLE
function QuestieQuest:GetAllLeaderBoardDetails(questId)
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest:GetAllLeaderBoardDetails] for questId", questId)

    local questObjectives = QuestLogCache.GetQuestObjectives(questId) -- DO NOT MODIFY THE RETURNED TABLE
    if (not questObjectives) then return end

    for _, objective in pairs(questObjectives) do -- DO NOT MODIFY THE RETURNED TABLE
        -- TODO Move this to QuestEventHandler module or QuestieQuest:AcceptQuest( ) + QuestieQuest:UpdateQuest( ) (acceptquest one required to register objectives without progress)
        -- TODO After ^^^ moving remove this function and use "QuestLogCache.GetQuest(questId).objectives -- DO NOT MODIFY THE RETURNED TABLE" in place of it.
        QuestieAnnounce:ObjectiveChanged(questId, objective.text, objective.numFulfilled, objective.numRequired)
    end

    return questObjectives
end

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
                            local data = {
                                Id = quest.Id,
                                Icon = _QuestieQuest:GetQuestIcon(quest),
                                GetIconScale = _GetIconScaleForAvailable,
                                IconScale = _GetIconScaleForAvailable(),
                                Type = "available",
                                QuestData = quest,
                                Name = obj.name,
                                IsObjectiveNote = false,
                            }

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

            if (npc ~= nil and npc.spawns ~= nil) then
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, npc)

                --Questie:Debug(Questie.DEBUG_DEVELOP, "Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                local starterIcons = {}
                local starterLocs = {}
                for npcZone, spawns in pairs(npc.spawns) do
                    if(npcZone ~= nil and spawns ~= nil) then

                        for _, coords in ipairs(spawns) do
                            local data = {
                                Id = quest.Id,
                                Icon = _QuestieQuest:GetQuestIcon(quest),
                                GetIconScale = _GetIconScaleForAvailable,
                                IconScale = _GetIconScaleForAvailable(),
                                Type = "available",
                                QuestData = quest,
                                Name = npc.name,
                                IsObjectiveNote = false,
                            }
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
                                local data = {
                                    Id = quest.Id,
                                    Icon = _QuestieQuest:GetQuestIcon(quest),
                                    GetIconScale = _GetIconScaleForAvailable,
                                    IconScale = _GetIconScaleForAvailable(),
                                    Type = "available",
                                    QuestData = quest,
                                    Name = npc.name,
                                    IsObjectiveNote = false,
                                }
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
    local icon
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

---@type Ticker?
local timer
function QuestieQuest:CalculateAndDrawAvailableQuestsIterative(callback)
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:CalculateAndDrawAvailableQuestsIterative] PlayerLevel =", QuestiePlayer.GetPlayerLevel())

    -- Localize the variable for speeeeed
    local debugEnabled = Questie.db.global.debugEnabled

    local data = QuestieDB.QuestPointers or QuestieDB.questData
    local index = next(data)

    local playerLevel = QuestiePlayer.GetPlayerLevel()
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

    local autoBlacklist = QuestieQuest.autoBlacklist

    --? Cancel the previously running timer to not have multiple running at the same time
    if timer then
        timer:Cancel()
    end


    timer = C_Timer.NewTicker(0.01, function()
        for _=0,64 do -- number of available quests to process per tick
            local questId = index
            if questId then
                --? Quick exit through autoBlacklist if IsDoable has blacklisted it.
                if (not autoBlacklist[questId]) then
                    --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
                    if(
                        (not Questie.db.char.complete[questId]) and -- Don't show completed quests
                        ((not QuestiePlayer.currentQuestlog[questId]) or QuestieDB.IsComplete(questId) == -1) and -- Don't show quests if they're already in the quest log
                        (not QuestieCorrections.hiddenQuests[questId]) and -- Don't show blacklisted quests
                        (showRepeatableQuests or (not QuestieDB.IsRepeatable(questId))) and  -- Show repeatable quests if the quest is repeatable and the option is enabled
                        (showDungeonQuests or (not QuestieDB.IsDungeonQuest(questId))) and  -- Show dungeon quests only with the option enabled
                        (showRaidQuests or (not QuestieDB.IsRaidQuest(questId))) and  -- Show Raid quests only with the option enabled
                        (showPvPQuests or (not QuestieDB.IsPvPQuest(questId))) and -- Show PvP quests only with the option enabled
                        (showAQWarEffortQuests or (not QuestieQuestBlacklist.AQWarEffortQuests[questId])) and -- Don't show AQ War Effort quests with the option enabled
                        ((not Questie.IsWotlk) or (not IsleOfQuelDanas.quests[Questie.db.global.isleOfQuelDanasPhase][questId]))
                    ) then

                        if QuestieDB.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel) and QuestieDB.IsDoable(questId, debugEnabled) then
                            QuestieQuest.availableQuests[questId] = true
                            --If the quest is not drawn draw the quest, otherwise skip.
                            if (not QuestieMap.questIdFrames[questId]) then
                                ---@type Quest
                                local quest = QuestieDB:GetQuest(questId)
                                if (not quest.tagInfoWasCached) then
                                    Questie:Debug(Questie.DEBUG_SPAM, "Caching tag info for quest", questId)
                                    QuestieDB.GetQuestTagInfo(questId) -- cache to load in the tooltip
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
                end
            else
                --? We've reached the end of the quest list
                --? Stop and reset timer
                if timer then
                    timer:Cancel()
                    timer = nil
                end
                -- UpdateAddOnCPUUsage(); print("Questie CPU usage:", GetAddOnCPUUsage("Questie")) -- Do not remove even commented out. Useful for performance testing.
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
    if QuestieDB.IsDoable(questId) then
        _QuestieQuest:DrawAvailableQuest(quest)
    end
end
