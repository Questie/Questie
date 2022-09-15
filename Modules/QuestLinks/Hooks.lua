local WatchFrame_Update = QuestWatch_Update or WatchFrame_Update

---@class Hooks
local Hooks = QuestieLoader:CreateModule("Hooks")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")


function Hooks:HookQuestLogTitle()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[Hooks] Hooking Quest Log Title")
    local baseQLTB_OnClick = QuestLogTitleButton_OnClick

    -- We can not use hooksecurefunc because this needs to be a pre-hook to work properly unfortunately
    QuestLogTitleButton_OnClick = function(self, button)
        if (not self) or self.isHeader or (not IsShiftKeyDown()) then
            baseQLTB_OnClick(self, button)
            return
        end

        local questLogLineIndex
        if Questie.IsWotlk then
            -- With Wotlk the offset is no longer required cause the API already hands the correct index
            questLogLineIndex = self:GetID()
        else
            questLogLineIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
        end

        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
            local questId = GetQuestIDFromLogIndex(questLogLineIndex)
            ChatEdit_InsertLink("["..string.gsub(self:GetText(), " *(.*)", "%1").." ("..questId..")]")
        else
            -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
            if Questie.db.global.trackerEnabled and GetNumQuestLeaderBoards(questLogLineIndex) == 0 and (not IsQuestWatched(questLogLineIndex)) then
                QuestieTracker:AQW_Insert(questLogLineIndex, QUEST_WATCH_NO_EXPIRE)
                WatchFrame_Update()
                QuestLog_SetSelection(questLogLineIndex)
                QuestLog_Update()
            else
                baseQLTB_OnClick(self, button)
            end
        end
    end
end