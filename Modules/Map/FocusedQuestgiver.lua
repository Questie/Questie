---@class FocusedQuestgiver
local FocusedQuestgiver = QuestieLoader:CreateModule("FocusedQuestgiver")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

--- Manual-frame type key. Using a dedicated key keeps these icons separate from the quest's
--- objective and finisher frames, so they can be unloaded independently and never trip the
--- "available quest" visibility filters (which apply to Type == "available" icons).
local MANUAL_TYPE = "questgiver"

--- Starters currently drawn, so they can be removed on the next focus change.
--- Each entry is the NPC or object ID passed to QuestieMap:ShowNPC / ShowObject.
---@type NpcId[]|ObjectId[]
local shownStarterIds = {}

--- Removes all quest giver icons drawn by a previous Show call.
function FocusedQuestgiver.Hide()
    for i = 1, #shownStarterIds do
        QuestieMap:UnloadManualFrames(shownStarterIds[i], MANUAL_TYPE)
    end
    shownStarterIds = {}
end

--- Draws the quest giver (the starting NPC or object) of an active quest as a manual map icon.
--- This lets the player see where a quest they already have was picked up, e.g. while it is focused.
--- Items that start a quest are intentionally skipped: their source is not "the quest giver".
---@param questId QuestId
function FocusedQuestgiver.Show(questId)
    -- Always clear the previous giver first so focusing a different quest never stacks icons.
    FocusedQuestgiver.Hide()

    if (not Questie.db.profile.trackerShowQuestGiverOnFocus) then
        return
    end

    local quest = QuestieDB.GetQuest(questId)
    if (not quest) or (not quest.Starts) then
        return
    end

    local icon = Questie.icons["available"]
    local scale = Questie.db.profile.availableScale
    local questName = quest.name or tostring(questId)
    local title = Questie:Colorize(questName, "white") .. "\n" .. l10n("Quest Giver")

    local npcs = quest.Starts.NPC
    if npcs then
        for i = 1, #npcs do
            QuestieMap:ShowNPC(npcs[i], icon, scale, title, nil, true, MANUAL_TYPE)
            shownStarterIds[#shownStarterIds + 1] = npcs[i]
        end
    end

    local objects = quest.Starts.GameObject
    if objects then
        for i = 1, #objects do
            QuestieMap:ShowObject(objects[i], icon, scale, title, nil, true, MANUAL_TYPE)
            shownStarterIds[#shownStarterIds + 1] = objects[i]
        end
    end
end
