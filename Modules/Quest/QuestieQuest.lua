--- COMPATIBILITY ---
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

---@class QuestieQuest
local QuestieQuest = QuestieLoader:CreateModule("QuestieQuest")
---@type QuestieQuestPrivate
QuestieQuest.private = QuestieQuest.private or {}
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
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type WorldMapButton
local WorldMapButton = QuestieLoader:ImportModule("WorldMapButton")

--We should really try and squeeze out all the performance we can, especially in this.
local tostring = tostring;
local tinsert = table.insert;
local pairs = pairs;
local ipairs = ipairs;
local yield = coroutine.yield
local NewThread = ThreadLib.ThreadSimple

QuestieQuest.availableQuests = {} --Gets populated at PLAYER_ENTERED_WORLD

--- A list of quests that will never be available, used to quickly skip quests.
---@alias AutoBlacklistString "rep"|"skill"|"race"|"class"
---@type table<number, AutoBlacklistString>
QuestieQuest.autoBlacklist = {}

local NOP_FUNCTION = function()
end
local ERR_FUNCTION = function(err)
    print(err)
    print(debugstack())
end

-- forward declaration
local _UnloadAlreadySpawnedIcons
local _RegisterObjectiveTooltips, _DetermineIconsToDraw, _GetIconsSortedByDistance
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
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest]: Resetting autoblacklist category", category)
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
    WorldMapButton.UpdateText()

    local trackerHiddenQuests = Questie.db.char.TrackerHiddenQuests
    for questId, frameList in pairs(QuestieMap.questIdFrames) do
        if (not trackerHiddenQuests) or (not trackerHiddenQuests[questId]) then -- Skip quests which are completely hidden from the Tracker menu
            for _, frameName in pairs(frameList) do                             -- this may seem a bit expensive, but its actually really fast due to the order things are checked
                ---@type IconFrame
                local icon = _G[frameName];
                if not icon.data then
                    error("Desync! Icon has not been removed correctly, but has already been reset. Skipping frame \"" .. frameName .. "\" for quest " .. questId)
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
    WorldMapButton.UpdateText()

    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do                                 -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            if icon ~= nil and (not icon.hidden) and icon:ShouldBeHidden() then -- check for function to make sure its a frame
                -- Hides Objective Icons
                icon:FakeHide()

                -- Hides Objective Tooltips
                QuestieTooltips:RemoveQuest(icon.data.Id)

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
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB.GetQuest(questId)

        if not quest then
            return
        end

        quest.Objectives = {}

        if next(quest.SpecialObjectives) then
            for _, s in pairs(quest.SpecialObjectives) do
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

function QuestieQuest:ClearAllToolTips()
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB.GetQuest(questId)

        if not quest then
            return
        end

        if quest.Objectives then
            for _, objective in pairs(quest.Objectives) do
                if objective.hasRegisteredTooltips then
                    objective.hasRegisteredTooltips = false
                end

                if objective.registeredItemTooltips then
                    objective.registeredItemTooltips = false
                end
            end
        end

        if quest.ObjectiveData then
            for _, objective in pairs(quest.ObjectiveData) do
                if objective.hasRegisteredTooltips then
                    objective.hasRegisteredTooltips = false
                end

                if objective.registeredItemTooltips then
                    objective.registeredItemTooltips = false
                end
            end
        end

        if next(quest.SpecialObjectives) then
            for _, objective in pairs(quest.SpecialObjectives) do
                if objective.hasRegisteredTooltips then
                    objective.hasRegisteredTooltips = false
                end

                if objective.registeredItemTooltips then
                    objective.registeredItemTooltips = false
                end
            end
        end
    end

    QuestieTooltips.lookupByKey = {}
    QuestieTooltips.lookupKeyByQuestId = {}
end

-- This is only needed for SmoothReset(), normally special objectives don't need to update
---@param questId number
local function _UpdateSpecials(questId)
    local quest = QuestieDB.GetQuest(questId)
    if quest and next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, 0, objective, true)
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] " .. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
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
            -- Wait until game cache has quest log okay.
            return QuestLogCache.TestGameCache()
        end,
        function()
            return #QuestieMap._mapDrawQueue == 0 and #QuestieMap._minimapDrawQueue == 0 -- wait until draw queue is finished
        end,
        function()
            QuestieQuest:ClearAllNotes()
            QuestieQuest:ClearAllToolTips()
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
            -- reset quest log
            QuestiePlayer.currentQuestlog = {}

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
            QuestieQuest.CalculateAndDrawAvailableQuestsIterative(function() QuestieQuest._resetNeedsAvailables = false end)
            return true
        end,
        function()
            for _ = 1, 64 do
                if QuestieQuest._nextRestQuest then
                    QuestieQuest:UpdateQuest(QuestieQuest._nextRestQuest)
                    _UpdateSpecials(QuestieQuest._nextRestQuest)
                    QuestieQuest._nextRestQuest = next(QuestiePlayer.currentQuestlog, QuestieQuest._nextRestQuest)
                else
                    QuestieCombatQueue:Queue(function()
                        C_Timer.After(2.0, function()
                            QuestieTracker:Update()
                        end)
                    end)
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
        return true
    end

    local autoWatch = Questie.db.global.autoTrackQuests
    local trackedAuto = autoWatch and (not Questie.db.char.AutoUntrackedQuests or not Questie.db.char.AutoUntrackedQuests[questId])
    local trackedManual = not autoWatch and (Questie.db.char.TrackedQuests and Questie.db.char.TrackedQuests[questId])
    return trackedAuto or trackedManual
end

function QuestieQuest:HideQuest(id)
    Questie.db.char.hidden[id] = true
    QuestieMap:UnloadQuestFrames(id)
    QuestieTooltips:RemoveQuest(id)
end

function QuestieQuest:UnhideQuest(id)
    Questie.db.char.hidden[id] = nil
    QuestieQuest.CalculateAndDrawAvailableQuestsIterative()
end

local allianceTournamentMarkerQuests = {[13684] = true, [13685] = true, [13688] = true, [13689] = true, [13690] = true, [13593] = true, [13703] = true, [13704] = true, [13705] = true, [13706] = true}
local hordeTournamentMarkerQuests = {[13691] = true, [13693] = true, [13694] = true, [13695] = true, [13696] = true, [13707] = true, [13708] = true, [13709] = true, [13710] = true, [13711] = true}

---@param questId number
function QuestieQuest:AcceptQuest(questId)
    local quest = QuestieDB.GetQuest(questId)
    local complete = quest:IsComplete()

    if quest then
        -- If any of these flags exsist then this quest has already once been accepted and is probobly in a failed state
        if (quest.WasComplete or quest.isComplete or complete == 0 or complete == -1) and (QuestiePlayer.currentQuestlog[questId]) then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Accepted Quest:", questId, " Warning: This quest was once accepted and needs to be reset.")

            -- Reset quest log
            QuestiePlayer.currentQuestlog[questId] = nil

            -- Reset quest objectives
            quest.Objectives = {}

            -- Reset quest flags
            quest.WasComplete = nil
            quest.isComplete = nil

            -- Reset tooltips
            QuestieTooltips:RemoveQuest(questId)
        end

        if not QuestiePlayer.currentQuestlog[questId] then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Accepted Quest:", questId)

            QuestiePlayer.currentQuestlog[questId] = quest

            if allianceTournamentMarkerQuests[questId] then
                Questie.db.char.complete[13686] = true -- Alliance Tournament Eligibility Marker
            elseif hordeTournamentMarkerQuests[questId] then
                Questie.db.char.complete[13687] = true -- Horde Tournament Eligibility Marker
            end

            TaskQueue:Queue(
            -- Get all the Frames for the quest and unload them, the available quest icon for example.
                function() QuestieMap:UnloadQuestFrames(questId) end,
                -- Make sure there isn't any lingering tooltip data hanging around in the quest table.
                function() QuestieTooltips:RemoveQuest(questId) end,
                function()
                    -- Re-accepted quest can be collapsed. Expand it. Especially dailies.
                    if Questie.db.char.collapsedQuests then
                        Questie.db.char.collapsedQuests[questId] = nil
                    end
                    -- Re-accepted quest can be untracked. Clear it. Especially timed quests.
                    if Questie.db.char.AutoUntrackedQuests[questId] then
                        Questie.db.char.AutoUntrackedQuests[questId] = nil
                    end
                end,
                function() QuestieQuest:PopulateQuestLogInfo(quest) end,
                function()
                    -- This needs to happen after QuestieQuest:PopulateQuestLogInfo because that is the place where quest.Objectives is generated
                    Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId)
                end,
                function() QuestieQuest:PopulateObjectiveNotes(quest) end,
                function() QuestieQuest.CalculateAndDrawAvailableQuestsIterative() end,
                function()
                    QuestieCombatQueue:Queue(function()
                        QuestieTracker:Update()
                    end)
                end
            )
        else
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Accepted Quest:", questId, " Warning: Quest already exists, not adding")
        end
    end
end

local allianceChampionMarkerQuests = {[13699] = true, [13713] = true, [13723] = true, [13724] = true, [13725] = true}
local hordeChampionMarkerQuests = {[13726] = true, [13727] = true, [13728] = true, [13729] = true, [13731] = true}

---@param questId number
function QuestieQuest:CompleteQuest(questId)
    -- Skip quests which are turn in only and are not added to the quest log in the first place
    if QuestiePlayer.currentQuestlog[questId] then
        -- Reset quest flags of
        QuestiePlayer.currentQuestlog[questId].WasComplete = nil
        QuestiePlayer.currentQuestlog[questId].isComplete = nil
        QuestiePlayer.currentQuestlog[questId] = nil;
    end

    -- Only quests that are daily quests or aren't repeatable should be marked complete,
    -- otherwise objectives for repeatable quests won't track correctly - #1433
    Questie.db.char.complete[questId] = (not QuestieDB.IsRepeatable(questId)) or QuestieDB.IsDailyQuest(questId) or QuestieDB.IsWeeklyQuest(questId);

    if allianceChampionMarkerQuests[questId] then
        Questie.db.char.complete[13700] = true -- Alliance Champion Marker
        Questie.db.char.complete[13686] = nil -- Alliance Tournament Eligibility Marker
    elseif hordeChampionMarkerQuests[questId] then
        Questie.db.char.complete[13701] = true -- Horde Champion Marker
        Questie.db.char.complete[13687] = nil -- Horde Tournament Eligibility Marker
    end
    QuestieMap:UnloadQuestFrames(questId)

    if (QuestieMap.questIdFrames[questId]) then
        Questie:Error("Just removed all frames but the framelist seems to still be there!", questId)
    end

    QuestieTooltips:RemoveQuest(questId)
    QuestieTracker:RemoveQuest(questId)
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)

    -- TODO: Should this be done first? Because DrawAllAvailableQuests looks at QuestieMap.questIdFrames[QuestId] to add available
    QuestieQuest.CalculateAndDrawAvailableQuestsIterative()

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Completed Quest:", questId)
end

---@param questId number
function QuestieQuest:AbandonedQuest(questId)
    if (QuestiePlayer.currentQuestlog[questId]) then
        QuestiePlayer.currentQuestlog[questId] = nil
        QuestieMap:UnloadQuestFrames(questId)
        local quest = QuestieDB.GetQuest(questId)

        if quest then
            -- Reset quest objectives
            quest.Objectives = {}

            -- Reset quest flags
            quest.WasComplete = nil
            quest.isComplete = nil

            if allianceTournamentMarkerQuests[questId] then
                Questie.db.char.complete[13686] = nil -- Alliance Tournament Eligibility Marker
            elseif hordeTournamentMarkerQuests[questId] then
                Questie.db.char.complete[13687] = nil -- Horde Tournament Eligibility Marker
            end

            local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
            if childQuests then
                for _, childQuestId in pairs(childQuests) do
                    Questie.db.char.complete[childQuestId] = nil
                    QuestLogCache.RemoveQuest(childQuestId)
                end
            end
        end

        for questIdAvailable, _ in pairs(QuestieQuest.availableQuests) do
            if (not QuestieDB.IsDoable(questIdAvailable)) then
                QuestieMap:UnloadQuestFrames(questIdAvailable)
            end
        end

        QuestieTracker:RemoveQuest(questId)
        QuestieTooltips:RemoveQuest(questId)
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)

        QuestieQuest.CalculateAndDrawAvailableQuestsIterative()

        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Abandoned Quest:", questId)
    end
end

---@param questId number
function QuestieQuest:UpdateQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest]", questId)

    ---@type Quest
    local quest = QuestieDB.GetQuest(questId)

    if quest and (not Questie.db.char.complete[questId]) then
        QuestieQuest:PopulateQuestLogInfo(quest)

        if QuestieQuest:ShouldShowQuestNotes(questId) then
            QuestieQuest:UpdateObjectiveNotes(quest)
        else
            QuestieTooltips:RemoveQuest(questId)
        end

        local isComplete = quest:IsComplete()

        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] QuestDB:IsComplete() flag is: " .. isComplete)

        if isComplete == 1 then
            -- Quest is complete
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest is: Complete!")

            QuestieMap:UnloadQuestFrames(questId)
            QuestieQuest:AddFinisher(quest)
            quest.WasComplete = true
        elseif isComplete == -1 then
            -- Failed quests should be shown as available again
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest has: Failed!")

            QuestieMap:UnloadQuestFrames(questId)
            QuestieTooltips:RemoveQuest(questId)
            _QuestieQuest:DrawAvailableQuest(quest)

            -- Reset any collapsed quest flags
            if Questie.db.char.collapsedQuests then
                Questie.db.char.collapsedQuests[questId] = nil
            end
        elseif isComplete == 0 then
            -- Quest was somehow reset back to incomplete after being completed (quest.WasComplete == true).
            -- The "or" check looks for a sourceItemId then checks to see if it's NOT in the players bag.
            -- Player destroyed quest items? Or some other quest mechanic removed the needed quest item.
            if quest and (quest.WasComplete or (quest.sourceItemId > 0 and QuestieQuest:CheckQuestSourceItem(questId) == false)) then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest was once complete or Quest Item(s) were removed. Resetting quest.")

                -- Reset quest objectives
                quest.Objectives = {}

                -- Reset quest flags
                quest.WasComplete = nil
                quest.isComplete = nil

                -- Reset tooltips
                QuestieTooltips:RemoveQuest(questId)

                QuestieQuest:CheckQuestSourceItem(questId, true)
                QuestieMap:UnloadQuestFrames(questId)

                -- Reset any collapsed quest flags
                if Questie.db.char.collapsedQuests then
                    Questie.db.char.collapsedQuests[questId] = nil
                end

                QuestieQuest:PopulateQuestLogInfo(quest)
                QuestieQuest:PopulateObjectiveNotes(quest)
                QuestieQuest.CalculateAndDrawAvailableQuestsIterative()
            else
                -- Sometimes objective(s) are all complete but the quest doesn't get flagged as "1". So far the only
                -- quests I've found that does this are quests involving an item(s). Checks all objective(s) and if they
                -- are all complete, simulate a "Complete Quest" so the quest finisher appears on the map.
                if quest.Objectives and #quest.Objectives > 0 then
                    local numCompleteObjectives = 0

                    for i = 1, #quest.Objectives do
                        if quest.Objectives[i] and quest.Objectives[i].Completed and quest.Objectives[i].Completed == true then
                            numCompleteObjectives = numCompleteObjectives + 1
                        end
                    end

                    if numCompleteObjectives == #quest.Objectives then
                        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] All Quest Objective(s) are Complete! Manually setting quest to Complete!")
                        QuestieMap:UnloadQuestFrames(questId)
                        QuestieQuest:AddFinisher(quest)
                        quest.WasComplete = true
                        quest.isComplete = true
                    else
                        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest Objective Status is: " .. numCompleteObjectives .. ", out of: " .. #quest.Objectives .. ". No updates required.")
                    end
                end
            end
        end

        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId)
    end
end

---@param questId number
function QuestieQuest:SetObjectivesDirty(questId)
    local quest = QuestieDB.GetQuest(questId)

    if quest then
        for _, objective in pairs(quest.Objectives) do
            objective.isUpdated = false
        end
    end
end

--Run this if you want to update the entire table
function QuestieQuest:GetAllQuestIds()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] Getting all quests")

    QuestiePlayer.currentQuestlog = {}

    for questId, data in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
        if (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database. Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        else
            --Keep the object in the questlog to save searching
            local quest = QuestieDB.GetQuest(questId)

            if quest then
                local complete = quest:IsComplete()

                QuestiePlayer.currentQuestlog[questId] = quest
                quest.LocalizedName = data.title

                if complete == -1 then
                    QuestieQuest:UpdateQuest(questId)
                else
                    QuestieQuest:CheckQuestSourceItem(questId, true)
                    QuestieQuest:PopulateQuestLogInfo(quest)

                    if QuestieQuest:ShouldShowQuestNotes(questId) then
                        QuestieQuest:PopulateObjectiveNotes(quest)
                    else
                        QuestieTooltips:RemoveQuest(questId)
                    end
                end
            else
                QuestiePlayer.currentQuestlog[questId] = questId -- TODO FIX LATER. codebase is expecting this to be "quest" not "questId"
            end

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Adding the quest", questId, QuestiePlayer.currentQuestlog[questId])
        end
    end

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

-- This checks and manually adds quest item tooltips for sourceItems
local function _AddSourceItemObjective(quest)
    if quest.sourceItemId then
        -- Save the itemObjective table from the quests objectives table
        local objectives = QuestieDB.QueryQuestSingle(quest.Id, "objectives")[3]

        -- Look for an itemObjective Id that matches sourceItemId - if found exit
        if objectives then
            for _, itemObjectiveIndex in pairs(objectives) do
                for _, itemObjectiveId in pairs(itemObjectiveIndex) do
                    if itemObjectiveId == quest.sourceItemId then
                        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_AddSourceItemObjective] This item is already part of a quest objective.")
                        return
                    end
                end
            end
        end

        local item = QuestieDB.QueryItemSingle(quest.sourceItemId, "name") --local item = QuestieDB:GetItem(quest.sourceItemId);

        if item then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_AddSourceItemObjective] Adding Source Item Id for:", quest.sourceItemId)

            -- We fake an objective for the sourceItems because this allows us
            -- to simply reuse "QuestieTooltips:GetTooltip".
            -- This should be all the data required for the tooltip
            local fakeObjective = {
                Id = quest.Id,
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

-- This checks and manually adds quest item tooltips for requiredSourceItems
local function _AddRequiredSourceItemObjective(quest)
    if quest.requiredSourceItems then
        for index, requiredSourceItemId in pairs(quest.requiredSourceItems) do
            -- Save the itemObjective table from the quests objectives table
            local objectives = QuestieDB.QueryQuestSingle(quest.Id, "objectives")[3]

            -- Look for an itemObjective Id that matches a requiredSourceItem Id - if found exit
            if objectives then
                for _, itemObjectiveIndex in pairs(objectives) do
                    for _, itemObjectiveId in pairs(itemObjectiveIndex) do
                        if itemObjectiveId == requiredSourceItemId or quest.sourceItemId == requiredSourceItemId then
                            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_AddRequiredSourceItemObjective] This item is already part of a quest objective.")
                            return
                        end
                    end
                end
            end

            local item = QuestieDB.QueryItemSingle(requiredSourceItemId, "name")

            if item then
                Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_AddRequiredSourceItemObjective] Adding Source Item Id for:", requiredSourceItemId)

                -- We fake an objective for the requiredSourceItem because this allows us
                -- to simply reuse "QuestieTooltips:GetTooltip".
                -- This should be all the data required for the tooltip
                local fakeObjective = {
                    Id = quest.Id,
                    IsRequiredSourceItem = true,
                    QuestData = quest,
                    Index = index,
                    text = item,
                    Description = item
                }

                QuestieTooltips:RegisterObjectiveTooltip(quest.Id, "i_" .. requiredSourceItemId, fakeObjective);
            end
        end
    end
end

function QuestieQuest:GetAllQuestIdsNoObjectives()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] Getting all quests without objectives")
    QuestiePlayer.currentQuestlog = {}

    for questId, data in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
        if (not QuestieDB.QuestPointers[questId]) then
            if not Questie._sessionWarnings[questId] then
                Questie:Error(l10n("The quest %s is missing from Questie's database. Please report this on GitHub or Discord!", tostring(questId)))
                Questie._sessionWarnings[questId] = true
            end
        else
            --Keep the object in the questlog to save searching
            local quest = QuestieDB.GetQuest(questId)
            if quest then
                QuestiePlayer.currentQuestlog[questId] = quest
                quest.LocalizedName = data.title
                _AddSourceItemObjective(quest)
                _AddRequiredSourceItemObjective(quest)
            else
                QuestiePlayer.currentQuestlog[questId] = questId
            end

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Adding the quest", questId, QuestiePlayer.currentQuestlog[questId])
        end
    end
end

-- iterate all notes, update / remove as needed
---@param quest Quest
function QuestieQuest:UpdateObjectiveNotes(quest)
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] UpdateObjectiveNotes:", quest.Id)
    for objectiveIndex, objective in pairs(quest.Objectives) do
        local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, objectiveIndex, objective, false)
        if (not result) then
            Questie:Debug(Questie.DEBUG_ELEVATED, "[QuestieQuest] There was an error populating objectives for", quest.name, quest.Id, objectiveIndex, err)
        end
    end

    if next(quest.SpecialObjectives) then
        for _, objective in pairs(quest.SpecialObjectives) do
            local result, err = xpcall(QuestieQuest.PopulateObjective, ERR_FUNCTION, QuestieQuest, quest, 0, objective, true)
            if not result then
                Questie:Error("[QuestieQuest]: [SpecialObjectives] " .. l10n("There was an error populating objectives for %s %s %s %s", quest.name or "No quest name", quest.Id or "No quest id", 0 or "No objective", err or "No error"));
            end
        end
    end
end

-- This function is used to check the players bags for an item that matches quest.sourceItemId.
-- A good example for this edge case is [18] The Price of Shoes (118) where upon acceptance, Verner's Note (1283) is given
-- to the player and the Quest is immediately flagged as Complete. If the note is destroyed then a slightly modified version
-- of QuestieDB.IsComplete() that uses this function, returns zero allowing the quest updates to properly set the quests state.
---@param questId number @QuestID
---@param makeObjective boolean @If set to true, then this will create an incomplete objective for the missing quest item
---@return boolean @Returns true if quest.sourceItemId matches an item in a players bag
function QuestieQuest:CheckQuestSourceItem(questId, makeObjective)
    local quest = QuestieDB.GetQuest(questId)
    local sourceItem = true
    if quest.sourceItemId > 0 then
        for bag = -2, 4 do
            for slot = 1, QuestieCompat.GetContainerNumSlots(bag) do
                local itemId = select(10, QuestieCompat.GetContainerItemInfo(bag, slot))
                if itemId == quest.sourceItemId then
                    return true
                end
            end

            sourceItem = false
        end

        -- If we are missing the sourceItem for zero objective quests then make an objective for it so the
        -- player has a visual indication as to what item is missing and so the quest has a "tag" of some kind.
        -- Also double check the quests leaderboard and make sure an objective doesn't already exist.
        if (not sourceItem) and makeObjective and (not QuestieQuest:GetAllLeaderBoardDetails(quest.Id)[1]) then
            local itemName = QuestieDB.QueryItemSingle(quest.sourceItemId, "name")
            quest.Objectives = {
                [1] = {
                    Description = itemName,
                    Type = "item",
                    Needed = 1,
                    Collected = 0,
                    Completed = false,
                    Id = quest.sourceItemId,
                    questId = quest.Id
                }
            }
        end
    else
        return true
    end

    return false
end

local function _GetIconScaleForAvailable()
    return Questie.db.global.availableScale or 1.3
end

---@param quest Quest
function QuestieQuest:AddFinisher(quest)
    --We should never ever add the quest if IsQuestFlaggedComplete true.
    local questId = quest.Id
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Adding finisher for quest", questId)

    if (QuestiePlayer.currentQuestlog[questId] and (IsQuestFlaggedCompleted(questId) == false) and (quest:IsComplete() == 1 or quest:IsComplete() == 0) and (not Questie.db.char.complete[questId])) then
        local finisher, key

        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                finisher = QuestieDB:GetNPC(quest.Finisher.Id)
                key = "m_" .. quest.Finisher.Id
            elseif quest.Finisher.Type == "object" then
                finisher = QuestieDB:GetObject(quest.Finisher.Id)
                key = "o_" .. quest.Finisher.Id
            else
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] Unhandled finisher type:", quest.Finisher.Type, questId, quest.name)
            end
        else
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] Quest has no finisher:", questId, quest.name)
        end

        if (finisher ~= nil and finisher.spawns ~= nil) then
            -- Certain race conditions can occur when the NPC/Objects are both the Quest Starter and Quest Finisher
            -- which can result in duplicate Quest Title tooltips appearing. DrawAvailableQuest() would have already
            -- registered this NPC/Object so, the appropiate tooltip lines are already present. This checks and clears
            -- any duplicate keys before registering the Quest Finisher.

            -- Clear duplicate keys if they exsist
            if QuestieTooltips.lookupByKey[key] then
                if QuestieTooltips:GetTooltip(key) ~= nil and #QuestieTooltips:GetTooltip(key) > 1 then
                    for ttline = 1, #QuestieTooltips:GetTooltip(key) do
                        for index, line in pairs(QuestieTooltips:GetTooltip(key)) do
                            if (ttline == index) then
                                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] AddFinisher - Removing duplicate Quest Title!")

                                -- Remove duplicate Quest Title
                                QuestieTooltips.lookupByKey[key][tostring(questId) .. " " .. finisher.name] = nil

                                -- Now check to see if the dup has a Special Objective
                                local objText = string.match(line, ".*|cFFcbcbcb.*")

                                if objText then
                                    local objIndex

                                    -- Grab the Special Objective index
                                    if quest.SpecialObjectives[1] then
                                        objIndex = quest.SpecialObjectives[1].Index
                                    end

                                    if objIndex then
                                        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] AddFinisher - Removing Special Objective!")

                                        -- Remove Special Objective Text
                                        QuestieTooltips.lookupByKey[key][tostring(questId) .. " " .. objIndex] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end

            QuestieTooltips:RegisterQuestStartTooltip(questId, finisher, key)

            local finisherIcons = {}
            local finisherLocs = {}

            for finisherZone, spawns in pairs(finisher.spawns) do
                if (finisherZone ~= nil and spawns ~= nil) then
                    for _, coords in ipairs(spawns) do
                        local data = {
                            Id = questId,
                            Icon = Questie.ICON_TYPE_COMPLETE,
                            GetIconScale = _GetIconScaleForAvailable,
                            IconScale = _GetIconScaleForAvailable(),
                            Type = "complete",
                            QuestData = quest,
                            Name = finisher.name,
                            IsObjectiveNote = false,
                        }

                        if QuestieDB.IsActiveEventQuest(quest.Id) then
                            data.Icon = Questie.ICON_TYPE_EVENTQUEST_COMPLETE
                        elseif QuestieDB.IsPvPQuest(quest.Id) then
                            data.Icon = Questie.ICON_TYPE_PVPQUEST_COMPLETE
                        elseif quest.IsRepeatable then
                            data.Icon = Questie.ICON_TYPE_REPEATABLE_COMPLETE
                        end

                        if (coords[1] == -1 or coords[2] == -1) then
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
                                finisherLocs[finisherZone] = { x, y }
                            end
                        end
                    end
                end
            end

            if finisher.waypoints then
                for zone, waypoints in pairs(finisher.waypoints) do
                    if (not ZoneDB.IsDungeonZone(zone)) then
                        if not finisherIcons[zone] and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then
                            local data = {
                                Id = questId,
                                Icon = Questie.ICON_TYPE_COMPLETE,
                                GetIconScale = _GetIconScaleForAvailable,
                                IconScale = _GetIconScaleForAvailable(),
                                Type = "complete",
                                QuestData = quest,
                                Name = finisher.name,
                                IsObjectiveNote = false,
                            }

                            if QuestieDB.IsActiveEventQuest(quest.Id) then
                                data.Icon = Questie.ICON_TYPE_EVENTQUEST_COMPLETE
                            elseif QuestieDB.IsPvPQuest(quest.Id) then
                                data.Icon = Questie.ICON_TYPE_PVPQUEST_COMPLETE
                            elseif quest.IsRepeatable then
                                data.Icon = Questie.ICON_TYPE_REPEATABLE_COMPLETE
                            end

                            finisherIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                            finisherLocs[zone] = { waypoints[1][1][1], waypoints[1][1][2] }
                        end

                        QuestieMap:DrawWaypoints(finisherIcons[zone], waypoints, zone)
                    end
                end
            end
        else
            Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] finisher or finisher.spawns == nil for questId", questId)
        end
    end
end

---@param quest Quest
---@param objectiveIndex ObjectiveIndex
---@param objective QuestObjective
---@param blockItemTooltips any
function QuestieQuest:PopulateObjective(quest, objectiveIndex, objective, blockItemTooltips) -- must be p-called
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateObjective]", objective.Description)

    if (not objective.Update) then
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateObjective] - Quest is already updated. --> Exiting!")
        return
    end

    objective:Update()
    local completed = objective.Completed
    local objectiveData = quest.ObjectiveData[objective.Index] or objective -- the reason for "or objective" is to handle "SpecialObjectives" aka non-listed objectives (demonic runestones for closing the portal)

    if (not objective.spawnList or (not next(objective.spawnList))) and _QuestieQuest.objectiveSpawnListCallTable[objectiveData.Type] then
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
        objective.Color = QuestieLib:ColorWheel()
    end

    if next(objective.spawnList) then
        local maxPerType = 300

        if Questie.db.global.enableIconLimit and Questie.db.global.iconLimit < maxPerType then
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
            objectiveCenter = { x = x, y = y }
        end

        local iconsToDraw, _ = _DetermineIconsToDraw(quest, objective, objectiveIndex, objectiveCenter)
        local icon, iconPerZone = _DrawObjectiveIcons(quest.Id, iconsToDraw, objective, maxPerType)
        _DrawObjectiveWaypoints(objective, icon, iconPerZone)
    end
end

_RegisterObjectiveTooltips = function(objective, questId, blockItemTooltips)
    Questie:Debug(Questie.DEBUG_INFO, "Registering objective tooltips for", objective.Description)

    if objective.spawnList then
        if (not objective.hasRegisteredTooltips) then
            for id, spawnData in pairs(objective.spawnList) do
                if spawnData.TooltipKey and (not objective.AlreadySpawned[id]) then
                    QuestieTooltips:RegisterObjectiveTooltip(questId, spawnData.TooltipKey, objective)
                end
            end

            objective.hasRegisteredTooltips = true
        end
    else
        Questie:Error("[QuestieQuest]: [Tooltips] " .. l10n("There was an error populating objectives for %s %s %s %s", objective.Description or "No objective text", questId or "No quest id", 0 or "No objective", "No error"));
    end

    if (not objective.registeredItemTooltips) and objective.Type == "item" and (not blockItemTooltips) and objective.Id then
        local itemName = QuestieDB.QueryItemSingle(objective.Id, "name")

        if itemName then
            QuestieTooltips:RegisterObjectiveTooltip(questId, "i_" .. objective.Id, objective)
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
    end
end

---@param quest Quest
---@param objective QuestObjective
---@param objectiveIndex ObjectiveIndex
---@param objectiveCenter {x:X, y:Y}
_DetermineIconsToDraw = function(quest, objective, objectiveIndex, objectiveCenter)
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_DetermineIconsToDraw]")

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
                    if (spawn[1] and spawn[2]) then
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
                            touched = nil, -- TODO change. This is meant to let lua reserve memory for all keys needed for sure.
                        }
                        local x, y, _ = HBD:GetWorldCoordinatesFromZone(drawIcon.x / 100, drawIcon.y / 100, uiMapId)
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
                            iconList[#iconList + 1] = drawIcon
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
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_DrawObjectiveIcons] Adding Icons for quest:", questId)

    local spawnedIconCount = 0
    local icon
    local iconPerZone = {}

    local range = Questie.db.global.clusterLevelHotzone

    local iconCount, orderedList = _GetIconsSortedByDistance(iconsToDraw)

    if orderedList[1] and orderedList[1].Icon == Questie.ICON_TYPE_OBJECT then -- new clustering / limit code should prevent problems, always show all object notes
        range = range * 0.2;                                                   -- Only use 20% of the default range.
    end

    local hotzones = QuestieMap.utils:CalcHotzones(orderedList, range, iconCount);

    for i = 1, #hotzones do
        local hotzone = hotzones[i]
        if (spawnedIconCount > maxPerType) then
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

                local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, centerX, centerY) -- clustering code takes care of duplicates as long as min-dist is more than 0

                if iconMap and iconMini then
                    iconPerZone[icon.zone] = { iconMap, centerX, centerY }
                    spawnsMapRefs[#spawnsMapRefs + 1] = iconMap
                    spawnsMinimapRefs[#spawnsMinimapRefs + 1] = iconMini
                end

                spawnedIconCount = spawnedIconCount + 1;
            end

            local firstDungeonLocation = dungeonLocation[1]
            icon.zone = firstDungeonLocation[1]
            centerX = firstDungeonLocation[2]
            centerY = firstDungeonLocation[3]
        end

        local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, icon.zone, centerX, centerY) -- clustering code takes care of duplicates as long as min-dist is more than 0

        if iconMap and iconMini then
            iconPerZone[icon.zone] = { iconMap, centerX, centerY }
            spawnsMapRefs[#spawnsMapRefs + 1] = iconMap
            spawnsMinimapRefs[#spawnsMinimapRefs + 1] = iconMini
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

                if (not iconPerZone[zone]) and icon and firstWaypoint[1] ~= -1 and firstWaypoint[2] ~= -1 then              -- spawn an icon in this zone for the mob
                    local iconMap, iconMini = QuestieMap:DrawWorldIcon(icon.data, zone, firstWaypoint[1], firstWaypoint[2]) -- clustering code takes care of duplicates as long as min-dist is more than 0

                    if iconMap and iconMini then
                        iconPerZone[zone] = { iconMap, firstWaypoint[1], firstWaypoint[2] }
                        tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].mapRefs, iconMap);
                        tinsert(objective.AlreadySpawned[icon.AlreadySpawnedId].minimapRefs, iconMini);
                    end
                end

                local ipz = iconPerZone[zone]

                if ipz then
                    QuestieMap:DrawWaypoints(ipz[1], waypoints, zone, spawnData.Hostile and { 1, 0.2, 0, 0.7 } or nil)
                end
            end

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:_DrawObjectiveWaypoints]")
        end
    end
end

---@param quest Quest
function QuestieQuest:PopulateObjectiveNotes(quest) -- this should be renamed to PopulateNotes as it also handles finishers now
    if (not quest) then
        return
    end

    if quest:IsComplete() == 1 then
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateObjectiveNotes] Quest Complete! Adding Finisher for:", quest.Id)

        QuestieQuest:UpdateQuest(quest.Id)
        _AddSourceItemObjective(quest)
        _AddRequiredSourceItemObjective(quest)

        return
    end

    if (not quest.Color) then
        quest.Color = QuestieLib:ColorWheel()
    end

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateObjectiveNotes] Populating objectives for:", quest.Id)

    QuestieQuest:UpdateObjectiveNotes(quest)
    _AddSourceItemObjective(quest)
    _AddRequiredSourceItemObjective(quest)
end

---@param quest Quest
---@return true?
function QuestieQuest:PopulateQuestLogInfo(quest)
    if (not quest) then
        return nil
    end

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateQuestLogInfo] ", quest.Id)

    local questLogEngtry = QuestLogCache.GetQuest(quest.Id) -- DO NOT MODIFY THE RETURNED TABLE

    if (not questLogEngtry) then return end

    if questLogEngtry.isComplete ~= nil and questLogEngtry.isComplete == 1 then
        quest.isComplete = true
    end

    --Uses the category order to draw the quests and trusts the database order.

    local questObjectives = QuestieQuest:GetAllLeaderBoardDetails(quest.Id) or {} -- DO NOT MODIFY THE RETURNED TABLE

    for objectiveIndex, objective in pairs(questObjectives) do
        if objective.type and string.len(objective.type) > 1 then
            if (not quest.ObjectiveData) or (not quest.ObjectiveData[objectiveIndex]) then
                Questie:Error(l10n("Missing objective data for quest "), quest.Id, " ", objective.text)
            else
                if not quest.Objectives[objectiveIndex] then
                    quest.Objectives[objectiveIndex] = {
                        Id = quest.ObjectiveData[objectiveIndex].Id,
                        Index = objectiveIndex,
                        questId = quest.Id,
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

            if specialObjective.RealObjectiveIndex and quest.Objectives[specialObjective.RealObjectiveIndex] then
                -- This specialObjective is an extraObjective and has a RealObjectiveIndex set
                specialObjective.Completed = quest.Objectives[specialObjective.RealObjectiveIndex].Completed
                specialObjective.Update = function(self)
                    self.Completed = quest.Objectives[self.RealObjectiveIndex].Completed
                end
            else
                specialObjective.Update = NOP_FUNCTION
            end

            specialObjective.Index = 64 + index -- offset to not conflict with real objectives
            specialObjective.AlreadySpawned = specialObjective.AlreadySpawned or {}
        end
    end

    if #quest.Objectives == 0 and #quest.SpecialObjectives == 0 and ((quest.triggerEnd and #quest.triggerEnd > 0) or (quest.Finisher and quest.Finisher.Id ~= nil)) then
        -- Some quests when picked up will be flagged isComplete == 0 but the quest.Objective table or quest.SpecialObjectives table is nil. This
        -- check assumes the Quest should have been flagged questLogEngtry.isComplete == 1. We're specifically looking for a quest.triggerEnd or
        -- a quest.Finisher.Id because this might throw an error if there is nothing to populate when we call QuestieQuest:AddFinisher().
        QuestieMap:UnloadQuestFrames(quest.Id)
        QuestieQuest:AddFinisher(quest)
        quest.isComplete = true
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
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:GetAllLeaderBoardDetails] for questId", questId)

    local questObjectives = QuestLogCache.GetQuestObjectives(questId) -- DO NOT MODIFY THE RETURNED TABLE
    if (not questObjectives) then return end

    for _, objective in pairs(questObjectives) do -- DO NOT MODIFY THE RETURNED TABLE
        -- TODO Move this to QuestEventHandler module or QuestieQuest:AcceptQuest( ) + QuestieQuest:UpdateQuest( ) (accept quest one required to register objectives without progress)
        -- TODO After ^^^ moving remove this function and use "QuestLogCache.GetQuest(questId).objectives -- DO NOT MODIFY THE RETURNED TABLE" in place of it.
        QuestieAnnounce:ObjectiveChanged(questId, objective.text, objective.numFulfilled, objective.numRequired)
    end

    return questObjectives
end

--Draw a single available quest, it is used by the DrawAllAvailableQuests function.
---@param quest Quest
function _QuestieQuest:DrawAvailableQuest(quest) -- prevent recursion
    --? Some quests can be started by both an NPC and a GameObject

    if quest.Starts["GameObject"] ~= nil then
        local gameObjects = quest.Starts["GameObject"]
        for i = 1, #gameObjects do
            local obj = QuestieDB:GetObject(gameObjects[i])
            if (obj ~= nil and obj.spawns ~= nil) then
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, obj, "o_" .. obj.id)

                for zone, spawns in pairs(obj.spawns) do
                    if (zone ~= nil and spawns ~= nil) then
                        local coords
                        for spawnIndex = 1, #spawns do
                            coords = spawns[spawnIndex]
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

                            if (coords[1] == -1 or coords[2] == -1) then
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
    end
    if (quest.Starts["NPC"] ~= nil) then
        local npcs = quest.Starts["NPC"]
        for i = 1, #npcs do
            local npc = QuestieDB:GetNPC(npcs[i])

            if (npc ~= nil and npc.spawns ~= nil) then
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, npc, "m_" .. npc.id)

                --Questie:Debug(Questie.DEBUG_DEVELOP, "Adding Quest:", questObject.Id, "StarterNPC:", NPC.Id)
                local starterIcons = {}
                local starterLocs = {}
                for npcZone, spawns in pairs(npc.spawns) do
                    if (npcZone ~= nil and spawns ~= nil) then
                        local coords
                        for spawnIndex = 1, #spawns do
                            coords = spawns[spawnIndex]
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
                            if (coords[1] == -1 or coords[2] == -1) then
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
                                    starterLocs[npcZone] = { x, y }
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
                                starterLocs[zone] = { waypoints[1][1][1], waypoints[1][1][2] }
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
    if QuestieDB.IsActiveEventQuest(quest.Id) then
        icon = Questie.ICON_TYPE_EVENTQUEST
    elseif QuestieDB.IsPvPQuest(quest.Id) then
        icon = Questie.ICON_TYPE_PVPQUEST
    elseif quest.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        icon = Questie.ICON_TYPE_AVAILABLE_GRAY
    elseif quest.IsRepeatable then
        icon = Questie.ICON_TYPE_REPEATABLE
    elseif (QuestieDB.IsTrivial(quest.level)) then
        icon = Questie.ICON_TYPE_AVAILABLE_GRAY
    else
        icon = Questie.ICON_TYPE_AVAILABLE
    end
    return icon
end

--? Creates a localized space where the local variables and functions are stored
do
    --- Used to keep track of the active timer for CalculateAvailableQuests
    --- Is used by the QuestieQuest.CalculateAndDrawAvailableQuestsIterative func
    ---@type Ticker|nil
    local timer

    local function CalculateAvailableQuests()
        local questsPerYield = 24

        -- Localize the variable for speeeeed
        local debugEnabled = Questie.db.global.debugEnabled

        local data = QuestieDB.QuestPointers or QuestieDB.questData

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

        --- Fast Localizations
        local autoBlacklist = QuestieQuest.autoBlacklist
        local hiddenQuests = QuestieCorrections.hiddenQuests
        local hidden = Questie.db.char.hidden

        QuestieDB.activeChildQuests = {} -- Reset here so we don't need to keep track in the quest event system

        local questCount = 0
        for questId in pairs(data) do
            --? Quick exit through autoBlacklist if IsDoable has blacklisted it.
            if (not autoBlacklist[questId]) then

                if QuestiePlayer.currentQuestlog[questId] then
                    -- Mark all child quests as active when the parent quest is in the quest log
                    local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
                    if childQuests then
                        for _, childQuestId in pairs(childQuests) do
                            if (not Questie.db.char.complete[childQuestId]) and (not QuestiePlayer.currentQuestlog[childQuestId]) then
                                QuestieDB.activeChildQuests[childQuestId] = true
                                -- Draw them right away and skip all other irrelevant checks
                                NewThread(function()
                                    local quest = QuestieDB.GetQuest(childQuestId)
                                    if (not quest.tagInfoWasCached) then
                                        QuestieDB.GetQuestTagInfo(childQuestId) -- cache to load in the tooltip

                                        quest.tagInfoWasCached = true
                                    end

                                    _QuestieQuest:DrawAvailableQuest(quest)
                                end, 0)
                            end
                        end
                    end
                --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
                elseif (
                        (not Questie.db.char.complete[questId]) and                                               -- Don't show completed quests
                        (not QuestieDB.activeChildQuests[questId]) and                                            -- Don't show child quests again. We already did that above
                        ((not QuestiePlayer.currentQuestlog[questId]) or QuestieDB.IsComplete(questId) == -1) and -- Don't show quests if they're already in the quest log
                        (not hiddenQuests[questId] and not hidden[questId]) and                                   -- Don't show blacklisted or player hidden quests
                        (showRepeatableQuests or (not QuestieDB.IsRepeatable(questId))) and                       -- Show repeatable quests if the quest is repeatable and the option is enabled
                        (showDungeonQuests or (not QuestieDB.IsDungeonQuest(questId))) and                        -- Show dungeon quests only with the option enabled
                        (showRaidQuests or (not QuestieDB.IsRaidQuest(questId))) and                              -- Show Raid quests only with the option enabled
                        (showPvPQuests or (not QuestieDB.IsPvPQuest(questId))) and                                -- Show PvP quests only with the option enabled
                        (showAQWarEffortQuests or (not QuestieQuestBlacklist.AQWarEffortQuests[questId])) and     -- Don't show AQ War Effort quests with the option enabled
                        ((not Questie.IsWotlk) or (not IsleOfQuelDanas.quests[Questie.db.global.isleOfQuelDanasPhase][questId]))
                    ) then
                    if QuestieDB.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel) and QuestieDB.IsDoable(questId, debugEnabled) then
                        QuestieQuest.availableQuests[questId] = true
                        --If the quest is not drawn draw the quest, otherwise skip.
                        if (not QuestieMap.questIdFrames[questId]) then
                            --? This looks expensive, and it kind of is but it offloads the work to a thread, which happens "next frame"
                            NewThread(function()
                                ---@type Quest
                                local quest = QuestieDB.GetQuest(questId)
                                if (not quest.tagInfoWasCached) then
                                    --Questie:Debug(Questie.DEBUG_INFO, "Caching tag info for quest", questId)
                                    QuestieDB.GetQuestTagInfo(questId) -- cache to load in the tooltip

                                    quest.tagInfoWasCached = true
                                end

                                --Draw a specific quest through the function
                                _QuestieQuest:DrawAvailableQuest(quest)
                            end, 0)
                        else
                            --* TODO: How the frames are handled needs to be reworked, why are we getting them from _G
                            --We might have to update the icon in this situation (config changed/level up)
                            for _, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                                if frame and frame.data and frame.data.QuestData then
                                    local newIcon = _QuestieQuest:GetQuestIcon(frame.data.QuestData)

                                    if newIcon ~= frame.data.Icon then
                                        frame:UpdateTexture(Questie.usedIcons[newIcon])
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

            -- Reset the questCount
            questCount = questCount + 1
            if questCount > questsPerYield then
                questCount = 0
                yield()
            end
        end
    end

    -- Starts a thread to calculate available quests to avoid lag spikes
    ---@param callback fun()?
    function QuestieQuest.CalculateAndDrawAvailableQuestsIterative(callback)
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest.CalculateAndDrawAvailableQuestsIterative] PlayerLevel =", QuestiePlayer.GetPlayerLevel())

        --? Cancel the previously running timer to not have multiple running at the same time
        if timer then
            timer:Cancel()
        end
        timer = ThreadLib.Thread(CalculateAvailableQuests, 0, "Error in CalculateAvailableQuests", callback)
    end
end

function QuestieQuest.DrawDailyQuest(questId)
    if QuestieDB.IsDoable(questId) then
        local quest = QuestieDB.GetQuest(questId)
        _QuestieQuest:DrawAvailableQuest(quest)
    end
end
