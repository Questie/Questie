---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.myJourney = {}
-------------------------
--Import modules.
-------------------------
---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local RECENT_QUEST_TEXTS = {
    Accept = "You Accepted the quest %s",
    Complete = "You Completed the quest %s",
    Abandon = "You Abandoned the quest %s",
}

---The line about an entry in the recent history.
---@param entry JourneyEntry
---@return string
function _QuestieJourney.myJourney.GetRecentText(entry)
    local text
    if entry.Event == "Level" then
        local level = Questie:Colorize(l10n("Level %s", entry.NewLevel), "gray")
        text = l10n("Congratulations! You reached %s !", level)
    elseif entry.Event == "Note" then
        text = l10n("Note Created: %s", Questie:Colorize(entry.Title, "gray"))
    else
        local name = QuestieDB.QueryQuestSingle(entry.Quest, "name") or tostring(entry.Quest)
        text = l10n(RECENT_QUEST_TEXTS[entry.SubType], Questie:Colorize(name, "gray"))
    end
    return Questie:Colorize(QuestieLib.FormatDate(entry.Timestamp) .. " ", "lightBlue") .. Questie:Colorize(text, "yellow")
end

---What the details show about an entry.
---@param entry JourneyEntry
---@return JourneyDetails.Row[]
function _QuestieJourney.myJourney.GetEntryRows(entry)
    local timestamp = Questie:Colorize(QuestieLib.FormatDate(entry.Timestamp), "lightBlue")

    ---@type JourneyDetails.Row[]
    local rows = {
        {type = "heading", text = _QuestieJourney:GetEntryText(entry)},
        {type = "gap", height = 6},
    }
    if entry.Event == "Level" then
        table.insert(rows, {type = "text", text = l10n("Congratulations! You reached %s !", entry.NewLevel)})
        table.insert(rows, {type = "gap", height = 10})
        table.insert(rows, {type = "text", text = timestamp})
    elseif entry.Event == "Note" then
        table.insert(rows, {type = "text", text = Questie:Colorize(entry.Note, "yellow")})
        table.insert(rows, {type = "gap", height = 10})
        table.insert(rows, {type = "text", text = l10n("Note Created: %s", timestamp)})
        table.insert(rows, {type = "gap", height = 10})
        table.insert(rows, {
            type = "button",
            text = l10n("Delete Note"),
            onClick = function() Popup.Show("QUESTIE_DELETE_NOTE_CONFIRM", nil, nil, entry) end,
        })
    else
        local quest = QuestieDB.GetQuest(entry.Quest)
        if quest then
            table.insert(rows, {type = "text", text = QuestieJourneyUtils.CreateObjectiveText(quest.Description)})
            table.insert(rows, {type = "gap", height = 10})
        end
        table.insert(rows, {type = "text", text = l10n("Quest %s: %s", _QuestieJourney.GetQuestState(entry), timestamp)})
        table.insert(rows, {type = "text", text = l10n("Quest ID") .. l10n(": ") .. entry.Quest})
    end
    return rows
end
