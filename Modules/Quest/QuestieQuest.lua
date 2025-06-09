---@class QuestieQuest
local QuestieQuest = QuestieLoader:CreateModule("QuestieQuest")
QuestieQuest.private = QuestieQuest.private or {}
---@class QuestieQuestPrivate
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
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type Phasing
local Phasing = QuestieLoader:ImportModule("Phasing")
---@type QuestFinisher
local QuestFinisher = QuestieLoader:ImportModule("QuestFinisher")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

--We should really try and squeeze out all the performance we can, especially in this.
local tostring = tostring;
local tinsert = table.insert;
local pairs = pairs;

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

function QuestieQuest:Initialize()
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest]: Getting all completed quests")
    Questie.db.char.complete = GetQuestsCompleted()

    QuestieProfessions:Update()
    QuestieReputation:Update(true)
end

---@param category AutoBlacklistString
function QuestieQuest.ResetAutoblacklistCategory(category)
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieQuest]: Resetting autoblacklist category", category)
    for questId, questCategory in pairs(QuestieDB.autoBlacklist) do
        if questCategory == category then
            QuestieDB.autoBlacklist[questId] = nil
        end
    end
end

function QuestieQuest.ToggleAvailableQuests(showIcons)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:ToggleAvailableQuests] showIcons:", showIcons)
    if showIcons then
        AvailableQuests.CalculateAndDrawAll()
    end
    QuestieQuest:ToggleNotes(showIcons)
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
    for _, frameList in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(frameList) do                                 -- this may seem a bit expensive, but its actually really fast due to the order things are checked
            local icon = _G[frameName];
            if icon ~= nil and (not icon.hidden) and icon:ShouldBeHidden() then -- check for function to make sure its a frame
                -- Hides Objective Icons
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
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB.GetQuest(questId)

        if not quest then
            return
        end

        for _, s in pairs(quest.Objectives) do
            s.AlreadySpawned = {}
        end

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
            QuestieDB.autoBlacklist = {}

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
            AvailableQuests.CalculateAndDrawAll(function() QuestieQuest._resetNeedsAvailables = false end)
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
    if not Questie.db.profile.hideUntrackedQuestsMapIcons then
        return true
    end

    local autoWatch = Questie.db.profile.autoTrackQuests
    local trackedAuto = autoWatch and (not Questie.db.char.AutoUntrackedQuests or not Questie.db.char.AutoUntrackedQuests[questId])
    local trackedManual = not autoWatch and (Questie.db.char.TrackedQuests and Questie.db.char.TrackedQuests[questId])
    return trackedAuto or trackedManual
end

---@param questId QuestId
function QuestieQuest:HideQuest(questId)
    Questie.db.char.hidden[questId] = true
    QuestieMap:UnloadQuestFrames(questId)
    QuestieTooltips:RemoveQuest(questId)
end

---@param questId QuestId
function QuestieQuest:UnhideQuest(questId)
    Questie.db.char.hidden[questId] = nil

    if QuestiePlayer.currentQuestlog[questId] then
        local quest = QuestieDB.GetQuest(questId)
        QuestieQuest:PopulateObjectiveNotes(quest)
    else
        AvailableQuests.CalculateAndDrawAll()
    end
end

local allianceTournamentMarkerQuests = {[13684] = true, [13685] = true, [13688] = true, [13689] = true, [13690] = true, [13593] = true, [13703] = true, [13704] = true, [13705] = true, [13706] = true}
local hordeTournamentMarkerQuests = {[13691] = true, [13693] = true, [13694] = true, [13695] = true, [13696] = true, [13707] = true, [13708] = true, [13709] = true, [13710] = true, [13711] = true}

---@param questId number
function QuestieQuest:AcceptQuest(questId)
    local quest = QuestieDB.GetQuest(questId)

    if quest then
        local complete = quest:IsComplete()
        -- If any of these flags exist then this quest has already once been accepted and is probably in a failed state
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
                function() AvailableQuests.CalculateAndDrawAll() end,
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

    if Expansions.Current >= Expansions.Wotlk then
        if allianceChampionMarkerQuests[questId] then
            Questie.db.char.complete[13700] = true -- Alliance Champion Marker
            Questie.db.char.complete[13686] = nil -- Alliance Tournament Eligibility Marker
        elseif hordeChampionMarkerQuests[questId] then
            Questie.db.char.complete[13701] = true -- Horde Champion Marker
            Questie.db.char.complete[13687] = nil -- Horde Tournament Eligibility Marker
        end
    end
    if Expansions.Current >= Expansions.MoP then
        if questId == 31450 then -- A New Fate (Pandaren faction quest)
            QuestiePlayer:Initialize() -- Reinitialize to update player race flags
        end
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

    -- TODO: Should this be done first? Because CalculateAndDrawAll looks at QuestieMap.questIdFrames[QuestId] to add available
    AvailableQuests.CalculateAndDrawAll()

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
                end
            end
        end

        AvailableQuests.UnloadUndoable()

        QuestieTracker:RemoveQuest(questId)
        QuestieTooltips:RemoveQuest(questId)
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)

        AvailableQuests.CalculateAndDrawAll()

        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Abandoned Quest:", questId)
    end
end

---@param questId number
function QuestieQuest:UpdateQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest]", questId)

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
            QuestFinisher.AddFinisher(quest)
            quest.WasComplete = true
        elseif isComplete == -1 then
            -- Failed quests should be shown as available again
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest:UpdateQuest] Quest has: Failed!")

            QuestieMap:UnloadQuestFrames(questId)
            QuestieTooltips:RemoveQuest(questId)
            AvailableQuests.DrawAvailableQuest(quest)

            -- Reset any collapsed quest flags
            if Questie.db.char.collapsedQuests then
                Questie.db.char.collapsedQuests[questId] = nil
            end
        elseif isComplete == 0 then
            -- Quest was somehow reset back to incomplete after being completed (quest.WasComplete == true).
            -- The "or" check looks for a sourceItemId then checks to see if it's NOT in the players bag.
            -- Player destroyed quest items? Or some other quest mechanic removed the needed quest item.
            if quest and (quest.WasComplete or (quest.sourceItemId > 0 and QuestieQuest:CheckQuestSourceItem(questId, false) == false)) then
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
                AvailableQuests.CalculateAndDrawAll()
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
                        QuestFinisher.AddFinisher(quest)
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
                if not Questie.IsSoD then Questie:Error(l10n("The quest %s is missing from Questie's database. Please report this on GitHub or Discord!", tostring(questId))) end
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
            -- to simply reuse "QuestieTooltips.GetTooltip".
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

-- This checks and manually adds quest item tooltips for SpellItems
local function _AddSpellItemObjective(quest)
    if quest.SpellItemId then
        local spellobjectives = QuestieDB.QueryQuestSingle(quest.Id, "objectives")[6]

        if spellobjectives then
            local depthIndex = 1 -- TODO: What is better for this?
            local fakeObjective = {
                Id = quest.Id,
                IsSourceItem = true,
                QuestData = quest,
                Index = 1,
                Needed = quest.Objectives[depthIndex].Needed,
                Collected = quest.Objectives[depthIndex].Collected,
                text = nil,
                Description = quest.Objectives[depthIndex].Description,
            }

            QuestieTooltips:RegisterObjectiveTooltip(quest.Id, "i_" .. quest.SpellItemId, fakeObjective);
            return
        end
    end
end

-- This checks and manually adds quest item tooltips for requiredSourceItems
local function _AddRequiredSourceItemObjective(quest)
    if quest.requiredSourceItems then
        for index, requiredSourceItemId in pairs(quest.requiredSourceItems) do
            -- Save the itemObjective table from the quests objectives table
            local objectives = QuestieDB.QueryQuestSingle(quest.Id, "objectives")[3]

            -- TODO: This is not required anymore since we validate the database for this case
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
                -- to simply reuse "QuestieTooltips.GetTooltip".
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
                if not Questie.IsSoD then Questie:Error(l10n("The quest %s is missing from Questie's database. Please report this on GitHub or Discord!", tostring(questId))) end
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
    if quest and quest.sourceItemId > 0 then
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

    if objective.spawnList and next(objective.spawnList) then
        local maxPerType = Questie.db.profile.enableIconLimit and Questie.db.profile.iconLimit or 1500

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

        local objectiveCenter
        if zoneCount == 1 then -- this objective happens in 1 zone, clustering should be relative to that zone
            local x, y = HBD:GetWorldCoordinatesFromZone(0.5, 0.5, ZoneDB:GetUiMapIdByAreaId(objectiveZone))
            objectiveCenter = { x = x, y = y }
        else
            objectiveCenter = DistanceUtils.GetNearestFinisherOrStarter(quest.Starts)
        end

        if (not objectiveCenter) or (not objectiveCenter.x) or (not objectiveCenter.y) then
            -- When an NPC doesn't have any spawns objectiveCenter will be nil.
            -- Also for some areas HBD will return nil for the world coordinates.
            -- This will create a distance of 0 but it doesn't matter.
            objectiveCenter = { x = 0, y = 0 }
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

        if (not objective.AlreadySpawned[id]) and (not objective.Completed) and Questie.db.profile.enableObjectives then
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
                    if spawn[1] and spawn[2] and Phasing.IsSpawnVisible(spawn[3]) then
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
                        local distance = QuestieLib.Euclid(objectiveCenter.x or 0, objectiveCenter.y or 0, x, y);
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

    local range = Questie.db.profile.clusterLevelHotzone

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

                -- Phase is already checked in _DetermineIconsToDraw
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

        -- Phase is already checked in _DetermineIconsToDraw
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
        local iconsAtDistance = icons[distances[distIndex]]

        for iconIndex = 1, #iconsAtDistance do
            local icon = iconsAtDistance[iconIndex]

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
                    -- Phase is already checked in _DetermineIconsToDraw
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
        _AddSpellItemObjective(quest)

        return
    end

    if (not quest.Color) then
        quest.Color = QuestieLib:ColorWheel()
    end

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateObjectiveNotes] Populating objectives for:", quest.Id)

    QuestieQuest:UpdateObjectiveNotes(quest)
    _AddSourceItemObjective(quest)
    _AddRequiredSourceItemObjective(quest)
    _AddSpellItemObjective(quest)
end

---@param quest Quest
function QuestieQuest:PopulateQuestLogInfo(quest)
    if (not quest) then
        return
    end

    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest:PopulateQuestLogInfo] ", quest.Id)

    local questLogEntry = QuestLogCache.GetQuest(quest.Id) -- DO NOT MODIFY THE RETURNED TABLE

    if (not questLogEntry) then return end

    if questLogEntry.isComplete ~= nil and questLogEntry.isComplete == 1 then
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
                        RequiredRepValue = quest.ObjectiveData[objectiveIndex].RequiredRepValue,
                        Icon = quest.ObjectiveData[objectiveIndex].Icon
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

    if #quest.Objectives == 0 and #quest.SpecialObjectives == 0 and ((quest.triggerEnd and #quest.triggerEnd > 0) or (quest.Finisher and (quest.Finisher.NPC or quest.Finisher.GameObject))) then
        -- Some quests when picked up will be flagged isComplete == 0 but the quest.Objective table or quest.SpecialObjectives table is nil. This
        -- check assumes the Quest should have been flagged questLogEngtry.isComplete == 1. We're specifically looking for a quest.triggerEnd or
        -- a quest.Finisher because this might throw an error if there is nothing to populate when we call QuestFinisher.AddFinisher().
        QuestieMap:UnloadQuestFrames(quest.Id)
        QuestFinisher.AddFinisher(quest)
        quest.isComplete = true
    end
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

function QuestieQuest.DrawDailyQuest(questId)
    if QuestieDB.IsDoable(questId) then
        local quest = QuestieDB.GetQuest(questId)
        AvailableQuests.DrawAvailableQuest(quest)
    end
end

return QuestieQuest
