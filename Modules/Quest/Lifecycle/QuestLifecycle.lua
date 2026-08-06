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

---@param questId number
function QuestLifecycle:AcceptQuest(questId)
    local quest = QuestieDB.GetQuest(questId)

    if quest then
        local complete = quest:IsComplete()
        -- If any of these flags exist then this quest has already once been accepted and is probably in a failed state
        if (quest.WasComplete or quest.isComplete or complete == 0 or complete == -1) and (QuestiePlayer.currentQuestlog[questId]) then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AcceptQuest] Quest", questId, " was accepted before and needs to be reset.")

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

        if (not QuestiePlayer.currentQuestlog[questId]) then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AcceptQuest] Quest", questId, "will be added to the quest log.")

            QuestiePlayer.currentQuestlog[questId] = quest

            if allianceTournamentMarkerQuests[questId] then
                Questie.db.char.complete[13686] = true -- Alliance Tournament Eligibility Marker
            elseif hordeTournamentMarkerQuests[questId] then
                Questie.db.char.complete[13687] = true -- Horde Tournament Eligibility Marker
            elseif xiaoFollowUpQuests[questId] then
                Questie.db.char.complete[30087] = true -- Xiao's Breadcrumbs Hidden Prequest
            end

            -- Re-accepted quest can be collapsed. Expand it. Especially dailies.
            if Questie.db.char.collapsedQuests then
                Questie.db.char.collapsedQuests[questId] = nil
            end
            -- Re-accepted quest can be untracked. Clear it. Especially timed quests.
            if Questie.db.char.AutoUntrackedQuests[questId] then
                Questie.db.char.AutoUntrackedQuests[questId] = nil
            end

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
        else
            Questie:Debug(Questie.DEBUG_INFO, "[QuestLifecycle:AcceptQuest] Quest", questId, "is already in the quest log. Nothing to do.")
        end
    end
end
