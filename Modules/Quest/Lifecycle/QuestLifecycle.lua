---@class QuestLifecycle
local QuestLifecycle = QuestieLoader:CreateModule("QuestLifecycle")

---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type CommsVisibility
local CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")

local pairs = pairs

local allianceTournamentMarkerQuests = {
    [13684] = true,
    [13685] = true,
    [13688] = true,
    [13689] = true,
    [13690] = true,
    [13593] = true,
    [13703] = true,
    [13704] = true,
    [13705] = true,
    [13706] = true
}
local hordeTournamentMarkerQuests = {
    [13691] = true,
    [13693] = true,
    [13694] = true,
    [13695] = true,
    [13696] = true,
    [13707] = true,
    [13708] = true,
    [13709] = true,
    [13710] = true,
    [13711] = true
}
local xiaoFollowUpQuests = {[29577] = true, [29981] = true, [30079] = true}

local allianceChampionMarkerQuests = {[13699] = true, [13713] = true, [13723] = true, [13724] = true, [13725] = true}
local hordeChampionMarkerQuests = {[13726] = true, [13727] = true, [13728] = true, [13729] = true, [13731] = true}

---@param questId number
function QuestLifecycle:AcceptQuest(questId)
    local quest = QuestieDB.GetQuest(questId)

    if (not quest) then
        return
    end

    local complete = quest:IsComplete()
    -- If any of these flags exist then this quest has already once been accepted and is probably in a failed state
    if (quest.WasComplete or quest.isComplete or complete == 0 or complete == -1) and (QuestiePlayer.currentQuestlog[questId]) then
        Questie.Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AcceptQuest] Quest", questId, " was accepted before and needs to be reset.")

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

    local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
    if childQuests then
        for _, childQuestId in pairs(childQuests) do
            -- Daily quest status is reset after parent accept
            if QuestieDB.IsDailyQuest(childQuestId) then
                Questie.db.char.complete[childQuestId] = nil
            end
        end
    end

    if QuestiePlayer.currentQuestlog[questId] then
        Questie.Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AcceptQuest] Quest", questId, "is already in the quest log. Nothing to do.")
        return
    end

    Questie.Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AcceptQuest] Quest", questId, "will be added to the quest log.")

    QuestiePlayer.currentQuestlog[questId] = quest

    if allianceTournamentMarkerQuests[questId] then
        Questie.db.char.complete[13686] = true -- Alliance Tournament Eligibility Marker
    elseif hordeTournamentMarkerQuests[questId] then
        Questie.db.char.complete[13687] = true -- Horde Tournament Eligibility Marker
    elseif xiaoFollowUpQuests[questId] then
        Questie.db.char.complete[30087] = true -- Xiao's Breadcrumbs Hidden Prequest
    end

    -- Re-accepted quest can be collapsed. Expand it. Especially dailies.
    Questie.db.char.collapsedQuests[questId] = nil
    -- Re-accepted quest can be untracked. Clear it. Especially timed quests.
    Questie.db.char.AutoUntrackedQuests[questId] = nil

    -- QuestieV1 snapshots are full-state maps. Re-accepting can clear a stale remote
    -- false entry, so notify peers after the local quest-log/tracking state is updated.
    CommsVisibility:ScheduleSnapshot("ACCEPT_QUEST")

    -- Remove the starter/finisher frames first, then draw objective notes once the
    -- unload coroutine has finished. This prevents the draw coroutines from racing
    -- with the unload coroutine and leaving stale entries in questIdFrames.
    AvailableQuests.RemoveQuest(questId, function()
        QuestieQuest:PopulateQuestLogInfo(quest)
        -- This needs to happen after QuestieQuest:PopulateQuestLogInfo because that is the place where quest.Objectives is generated
        Questie:SendMessage("QC_ID_BROADCAST_QUEST_UPDATE", questId)
        QuestieQuest:PopulateObjectiveNotes(quest)

        AvailableQuests.CalculateAndDrawAll()
    end)
end

---@param questId number
function QuestLifecycle:CompleteQuest(questId)
    -- Skip quests which are turn in only and are not added to the quest log in the first place
    if QuestiePlayer.currentQuestlog[questId] then
        -- Reset quest flags of
        QuestiePlayer.currentQuestlog[questId].WasComplete = nil
        QuestiePlayer.currentQuestlog[questId].isComplete = nil
        QuestiePlayer.currentQuestlog[questId] = nil;
    end

    -- Only quests that are daily quests or aren't repeatable should be marked complete,
    -- otherwise objectives for repeatable quests won't track correctly - #1433
    Questie.db.char.complete[questId] = (not QuestieDB.IsRepeatable(questId)) or QuestieDB.IsDailyQuest(questId) or QuestieDB.IsWeeklyQuest(questId) or
        QuestieDB.IsMonthlyQuest(questId);

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

    local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
    if childQuests then
        for _, childQuestId in pairs(childQuests) do
            if (not QuestiePlayer.currentQuestlog[childQuestId]) then
                -- Make sure all other childQuests are unloaded: all exclusives, chains etc
                AvailableQuests.RemoveQuest(childQuestId)
            end
        end
    end

    QuestieTracker:RemoveQuest(questId)
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)

    -- Removing the quest from our snapshot clears any previous false visibility entry on peers.
    CommsVisibility:ScheduleSnapshot("COMPLETE_QUEST")

    AvailableQuests.RemoveQuest(questId, function()
        AvailableQuests.CalculateAndDrawAll()
    end)

    Questie.Debug(Questie.DEBUG_INFO, "[QuestLifecycle:CompleteQuest]", questId)
end

---@param questId number
function QuestLifecycle:AbandonQuest(questId)
    if (not QuestiePlayer.currentQuestlog[questId]) then
        return
    end

    QuestiePlayer.currentQuestlog[questId] = nil

    local quest = QuestieDB.GetQuest(questId)

    if (not quest) then
        return
    end

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
            if (not QuestiePlayer.currentQuestlog[childQuestId]) then
                -- Make sure all other childQuests are unloaded: all exclusives, chains etc
                AvailableQuests.RemoveQuest(childQuestId)
            end
        end
    end

    QuestieTracker:RemoveQuest(questId)
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)

    -- Removing the quest from our snapshot clears any previous false visibility entry on peers.
    CommsVisibility:ScheduleSnapshot("ABANDON_QUEST")

    AvailableQuests.RemoveQuest(questId, function()
        AvailableQuests.CalculateAndDrawAll()
    end)

    Questie.Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AbandonQuest]", questId)
end
