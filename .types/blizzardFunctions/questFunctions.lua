---@meta
-----------QUEST FUNCTIONS

---@param questLogIndex number
---@return string title             @The title of the quest, or nil if the index is out of range.
---@return number level             @The level of the quest.
---@return number suggestedGroup    @If the quest is designed for more than one player, it is the number of players suggested to complete the quest. Otherwise, it is 0.
---@return boolean isHeader         @true if the entry is a header, false otherwise.
---@return boolean isCollapsed      @true if the entry is a collapsed header, false otherwise.
---@return number isComplete        @1 if the quest is completed, -1 if the quest is failed, nil otherwise.
---@return number frequency         @1 if the quest is a normal quest, LE_QUEST_FREQUENCY_DAILY (2) for daily quests, LE_QUEST_FREQUENCY_WEEKLY (3) for weekly quests.
---@return number questID           @The quest identification number. This is the number found in GetQuestsCompleted() after it has been completed.
---@return boolean startEvent
---@return boolean displayQuestID   @true if the questID is displayed before the title, false otherwise.
---@return boolean isOnMap
---@return boolean hasLocalPOI
---@return boolean isTask
---@return boolean isBounty         @(true for Legion World Quests; is it true for other WQs?)
---@return boolean isStory
---@return boolean isHidden         @true if the quest is not visible inside the player's quest log.
---@return boolean isScaling
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetQuestLogTitle)
function GetQuestLogTitle(questLogIndex) end

---@return number numEntries @Number of entries in the Quest Log, including collapsable zone headers.
---@return number numQuests  @Number of actual quests in the Quest Log, not counting zone headers.
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetNumQuestLogEntries)
function GetNumQuestLogEntries() end

---@param questID QuestId       @Unique identifier for each quest.
---@return number questLogIndex @The index of the queried quest in the quest log. Returns "0" if a quest with this questID does not exist in the quest log.
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetQuestLogIndexByID)
function GetQuestLogIndexByID(questID) end

---@param questID QuestId       @The ID of the quest.
---@return boolean isComplete   @true if the quest is both in the quest log and is complete, false otherwise.
---[Documentation](https://wowpedia.fandom.com/wiki/API_IsQuestComplete)
function IsQuestComplete(questID) end

---@param questID QuestId               @The ID of the quest to retrieve the tag info for.
---@return number? tagID             @the tagID, nil if quest is not tagged
---@return string? tagName           @human readable representation of the tagID, nil if quest is not tagged
---@return number worldQuestType        @type of world quest, or nil if not world quest
---@return number rarity                @the rarity of the quest (used for world quests)
---@return boolean isElite              @is this an elite quest? (used for world quests)
---@return number tradeSkillLineIndex   @tradeSkillID if this is a profession quest (used to determine which profession icon to display for world quests)
---@return number displayTimeLeft       @ ?
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetQuestTagInfo)
function GetQuestTagInfo(questID) end

---@param table? table              @OPTIONAL - If supplied, fills this table with quests. Any other keys will be unchanged.
---@return table<QuestId, boolean>  @The list of completed quests, keyed by quest IDs.
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetQuestsCompleted)
function GetQuestsCompleted(table) end

---@param unit string|"player"
---@return number range @an integer value, currently up to 12 (at level 60)
---[Documentation](https://wowpedia.fandom.com/wiki/API_GetQuestGreenRange)
function GetQuestGreenRange(unit) end

---@param questLogIndex? number      @OPTIONAL: Index of quest in quest log
---@return string questDescription   @The quest description
---@return string questObjectives    @The quest objective
---[Documentation](https://wow.gamepedia.com/API_GetQuestLogQuestText)
function GetQuestLogQuestText(questLogIndex) end

---@param questID integer            @The index of the header you wish to expand. - 0 to expand all quest headers
---[Documentation](https://wowpedia.fandom.com/wiki/API_ExpandQuestHeader)
function ExpandQuestHeader(questID) end
