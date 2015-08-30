QuestieCompat_GetQuestLogTitle = GetQuestLogTitle;
function GetQuestLogTitle(index) -- addons will override this function and not affect QuestieCompat_GetQuestLogTitle
	return QuestieCompat_GetQuestLogTitle(index);
end
