---The links between quests, NPCs, objects and items in the details of My Journey.
---@class JourneyLinks
local JourneyLinks = QuestieLoader:CreateModule("JourneyLinks")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type WrappedText
local WrappedText = QuestieLoader:ImportModule("WrappedText")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- The settings that show IDs in tooltips. Quest names come with theirs, from QuestieLib:GetColoredQuestName.
local ID_SETTINGS = {npc = "enableTooltipsNPCID", object = "enableTooltipsObjectID", item = "enableTooltipsItemID"}

---@param kind "npc"|"object"|"item"
---@param id number
---@return string text Like " (299)" while the settings show the IDs of its kind, otherwise empty
function JourneyLinks.GetIdText(kind, id)
    return Questie.db.profile[ID_SETTINGS[kind]] and " " .. l10n("(") .. id .. l10n(")") or ""
end

---@param questId QuestId
local function _FillQuestTooltip(questId)
    local quest = QuestieDB.GetQuest(questId)
    GameTooltip:AddLine(QuestieLib:GetColoredQuestName(questId, true, false))
    for _, line in pairs(quest.Description or {}) do
        for _, text in pairs(WrappedText:TextWrap(line, "    ", false, 360)) do
            GameTooltip:AddLine(text, 1, 1, 1)
        end
    end
end

---@param kind JourneyKind
---@param id number
local function _FillTooltip(kind, id)
    if kind == "quest" then
        _FillQuestTooltip(id)
    elseif kind == "item" then
        -- The game's own, which also gets Questie's lines, and the ID while the settings show it
        GameTooltip:SetItemByID(id)
    elseif kind == "npc" then
        local npc = QuestieDB:GetNPC(id)
        GameTooltip:AddLine("[" .. (npc.minLevel or 0) .. "] " .. npc.name .. JourneyLinks.GetIdText(kind, id))
        if npc.subName then
            GameTooltip:AddLine("    " .. npc.subName, 1, 1, 1)
        end
    else
        GameTooltip:AddLine(QuestieSearch.GetName(kind, id) .. JourneyLinks.GetIdText(kind, id))
    end
    GameTooltip:AddLine("\n" .. l10n("Click to show"))
end

---Makes a row lead to something.
---@param row JourneyDetails.Row
---@param kind JourneyKind
---@param id number
---@return JourneyDetails.Row row
function JourneyLinks.Link(row, kind, id)
    row.onClick = function() JourneyWindow.OpenLink(kind, id) end
    row.showTooltip = function() _FillTooltip(kind, id) end
    return row
end

---Rows that lead to a few quests, like those of an NPC. They are like the entries of the list of quests, and in its order.
---@param questIds QuestId[]? Those the list leaves out are left out
---@return JourneyDetails.Row[] steps
---@return JourneyQuestCategories.Entry[] entries What the player can do with the quests of the steps, in the same order
function JourneyLinks.GetQuestSteps(questIds)
    local entries = JourneyQuestCategories.Arrange(questIds or {})
    local steps = {}
    for index, entry in ipairs(entries) do
        steps[index] = JourneyLinks.Link({
            type = "step",
            text = QuestieLib:GetColoredQuestName(entry.questId, true, false),
            trailingIcon = JourneyQuestCategories.GetIcon(entry.questId, entry.category),
            tag = entry.note,
        }, "quest", entry.questId)
    end
    return steps, entries
end

---Puts a link to a quest into the chat if the user is typing there and clicked with the keys for links.
---@param questId QuestId
function JourneyLinks.TryInsertIntoChat(questId)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
        ChatEdit_InsertLink(QuestieLink.GetQuestLinkStringById(questId))
    end
end

return JourneyLinks
