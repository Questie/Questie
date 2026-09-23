---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

local WatchFrame_Update = QuestWatch_Update or QuestieCompat.WatchFrame_Update

---@class Hooks
local Hooks = QuestieLoader:CreateModule("Hooks")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

function Hooks:HookQuestLogTitle()
    -- The modern quest log handles links itself and tracks through C_QuestLog, not these title buttons.
    if not QuestLogTitleButton_OnClick then
        return
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[Hooks] Hooking Quest Log Title")
    local baseQLTB_OnClick = QuestLogTitleButton_OnClick

    -- We can not use hooksecurefunc because this needs to be a pre-hook to work properly unfortunately
    QuestLogTitleButton_OnClick = function(self, button)
        if (not self) or self.isHeader or (not IsShiftKeyDown()) then
            baseQLTB_OnClick(self, button)
            return
        end

        local questLogLineIndex
        if Expansions.Current >= Expansions.Wotlk then
            -- With Wotlk the offset is no longer required cause the API already hands the correct index
            questLogLineIndex = self:GetID()
        else
            questLogLineIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
        end

        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            local questId = QuestieCompat.GetQuestIDFromLogIndex(questLogLineIndex)
            ChatEdit_InsertLink("[" .. string.gsub(self:GetText(), " *(.*)", "%1") .. " (" .. questId .. ")]")
        else
            -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
            if Questie.db.profile.trackerEnabled and QuestieCompat.GetNumQuestLeaderBoards(questLogLineIndex) == 0 and (not QuestieCompat.IsQuestWatched(questLogLineIndex)) then
                QuestieTracker:AQW_Insert(questLogLineIndex, QUEST_WATCH_NO_EXPIRE)
                WatchFrame_Update()
                QuestieCompat.QuestLog_SetSelection(questLogLineIndex)
                QuestieCompat.QuestLog_Update()
            else
                baseQLTB_OnClick(self, button)
            end
        end
    end
end
