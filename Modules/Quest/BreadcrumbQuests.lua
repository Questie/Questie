---@class BreadcrumbQuests
local BreadcrumbQuests = QuestieLoader:CreateModule("BreadcrumbQuests")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieAnnounce
local QuestieAnnounce = QuestieLoader:ImportModule("QuestieAnnounce")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

--- Abandons the given quest and prints a message referencing the incomplete breadcrumb quest.
---@param questId number
---@param breadcrumbQuestId number
---@return boolean @Whether the quest was abandoned
function BreadcrumbQuests.AbandonQuest(questId, breadcrumbQuestId)
    local questLogIndex = GetQuestLogIndexByID(questId)
    if questLogIndex and questLogIndex > 0 then
        SelectQuestLogEntry(questLogIndex)
        SetAbandonQuest()
        AbandonQuest()
        local questLink = QuestieLink:GetQuestHyperLink(questId)
        local breadcrumbLink = QuestieLink:GetQuestHyperLink(breadcrumbQuestId)
        Questie:Print(l10n("Automatically abandoned quest %s because breadcrumb quest %s is not completed.", questLink, breadcrumbLink))
        return true
    end
    return false
end

--- Checks if a quest has incomplete breadcrumbs and announces/abandons accordingly.
---@param questId number
function BreadcrumbQuests.CheckQuestBreadcrumbs(questId)
    if not (Questie.db.profile.questAnnounceIncompleteBreadcrumb or Questie.db.profile.autoAccept.abandonBreadcrumbFollowup) then
        return
    end

    local breadcrumbs = QuestieDB.QueryQuestSingle(questId, "breadcrumbs")
    if breadcrumbs then
        local lastIncompleteBreadcrumbId = nil
        for _, breadcrumbQuestId in ipairs(breadcrumbs) do
            -- We want to let users know when they picked up a quest without finishing its breadcrumb
            if (not Questie.db.char.complete[breadcrumbQuestId]) and (not QuestiePlayer.currentQuestlog[breadcrumbQuestId]) then
                local requiredRaces = QuestieDB.QueryQuestSingle(breadcrumbQuestId, "requiredRaces")
                local requiredClasses = QuestieDB.QueryQuestSingle(breadcrumbQuestId, "requiredClasses")
                local availableUntilCompleted = QuestieDB.QueryQuestSingle(breadcrumbQuestId, "availableUntilCompleted")

                local exclusiveQuests = QuestieDB.QueryQuestSingle(breadcrumbQuestId, "exclusiveTo")
                local exclusiveQuestCompleted = false
                if exclusiveQuests then
                    for _, exclusiveQuestId in pairs(exclusiveQuests) do
                        if Questie.db.char.complete[exclusiveQuestId] or QuestiePlayer.currentQuestlog[exclusiveQuestId] then
                            exclusiveQuestCompleted = true
                            break
                        end
                    end
                end

                if QuestiePlayer.HasRequiredRace(requiredRaces)
                    and QuestiePlayer.HasRequiredClass(requiredClasses)
                    and (not exclusiveQuestCompleted)
                    and (not availableUntilCompleted or not Questie.db.char.complete[availableUntilCompleted]) then
                    if Questie.db.profile.questAnnounceIncompleteBreadcrumb then
                        QuestieAnnounce.IncompleteBreadcrumbQuest(questId, breadcrumbQuestId)
                    end
                    lastIncompleteBreadcrumbId = breadcrumbQuestId
                end
            end
        end

        if lastIncompleteBreadcrumbId and Questie.db.profile.autoAccept.abandonBreadcrumbFollowup then
            BreadcrumbQuests.AbandonQuest(questId, lastIncompleteBreadcrumbId)
        end
    end
end

--- Checks all existing quests in the quest log for incomplete breadcrumbs.
--- Called during login initialization since QUEST_ACCEPTED does not fire for quests already in the log.
function BreadcrumbQuests.CheckAllQuestBreadcrumbs()
    for questId, _ in pairs(QuestiePlayer.currentQuestlog) do
        BreadcrumbQuests.CheckQuestBreadcrumbs(questId)
    end
end