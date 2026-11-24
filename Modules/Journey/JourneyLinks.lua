---The links between quests, NPCs, objects and items in the details of My Journey.
---@class JourneyLinks
local JourneyLinks = QuestieLoader:CreateModule("JourneyLinks")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
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

---@param questId QuestId
local function _FillQuestTooltip(questId)
    local quest = QuestieDB.GetQuest(questId)
    GameTooltip:AddLine("[" .. quest.level .. "] " .. quest.name .. " (" .. questId .. ")")
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
    elseif kind == "npc" then
        local npc = QuestieDB:GetNPC(id)
        GameTooltip:AddLine("[" .. npc.minLevel .. "] " .. npc.name .. " (" .. id .. ")")
        if npc.subName then
            GameTooltip:AddLine("    " .. npc.subName, 1, 1, 1)
        end
    else
        GameTooltip:AddLine(QuestieSearch.GetName(kind, id) .. " (" .. id .. ")")
    end
    GameTooltip:AddLine("\n" .. l10n("Click to show"))
end

---@param kind JourneyKind
---@param id number
---@return string? text Nil when it isn't in the database
local function _GetText(kind, id)
    if kind == "quest" then
        return QuestieDB.QuestPointers[id] and QuestieLib:GetColoredQuestName(id, true, true)
    end
    local name = QuestieSearch.GetName(kind, id)
    local text = name and name .. " (" .. id .. ")"
    if text and kind == "npc" then
        text = "[" .. (QuestieDB.QueryNPCSingle(id, "maxLevel") or 0) .. "] " .. text
    end
    return text
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

---@param kind JourneyKind
---@param ids number[] Those that aren't in the database are left out. Some prerequisites are negative.
---@param excludedId number?
---@return JourneyDetails.Row[] rows
function JourneyLinks.GetRows(kind, ids, excludedId)
    local rows = {}
    for _, id in pairs(ids) do
        id = math.abs(id)
        local text = id ~= excludedId and _GetText(kind, id)
        if text then
            table.insert(rows, JourneyLinks.Link({type = "link", text = text}, kind, id))
        end
    end
    return rows
end

---Puts a link to a quest into the chat if the user is typing there and clicked with the keys for links.
---@param questId QuestId
function JourneyLinks.TryInsertIntoChat(questId)
    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
        ChatEdit_InsertLink(QuestieLink.GetQuestLinkStringById(questId))
    end
end

return JourneyLinks
