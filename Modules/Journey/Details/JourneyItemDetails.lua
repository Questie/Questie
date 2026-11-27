---What the Journey shows about an item: its tooltip, the quests it has to do with, and where to get it.
---@class JourneyItemDetails
local JourneyItemDetails = QuestieLoader:CreateModule("JourneyItemDetails")

---@type JourneyEntityDetails
local JourneyEntityDetails = QuestieLoader:ImportModule("JourneyEntityDetails")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyNameColors
local JourneyNameColors = QuestieLoader:ImportModule("JourneyNameColors")
---@type JourneyRawData
local JourneyRawData = QuestieLoader:ImportModule("JourneyRawData")
---@type ManualNotes
local ManualNotes = QuestieLoader:ImportModule("ManualNotes")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---Where an item can be gotten from, in the order the details list them.
---@class JourneyItemSource
---@field field "npcDrops"|"objectDrops"|"vendors"
---@field kind ManualNoteKind
---@field caption string

---@type JourneyItemSource[]
local SOURCES = {
    {field = "npcDrops", kind = "npc", caption = "NPCs"},
    {field = "objectDrops", kind = "object", caption = "Objects"},
    {field = "vendors", kind = "npc", caption = "Vendors"},
}

---@param rows JourneyDetails.Row[]
---@param caption string Is translated
---@param section JourneyDetails.Row[] Nothing is added without any
local function _AddSection(rows, caption, section)
    if #section > 0 then
        table.insert(rows, {type = "caption", text = caption})
        for _, row in ipairs(section) do table.insert(rows, row) end
    end
end

---@param itemId ItemId
local function _OnIconClick(itemId)
    local _, link = QuestieCompat.GetItemInfo(itemId)
    if not link then
        return -- The client doesn't know the item yet
    end
    if IsShiftKeyDown() then
        if ChatEdit_GetActiveWindow() then
            ChatEdit_InsertLink(link)
        else
            ChatFrame_OpenChat(link)
        end
    elseif IsControlKeyDown() then
        DressUpItemLink(link)
    end
end

---@param source JourneyItemSource
---@param id number
---@return boolean isReachable Whether the player can get the item there
local function _IsReachable(source, id)
    local spawns
    if source.kind == "npc" then
        spawns = QuestieDB.QueryNPCSingle(id, "spawns")
    else
        spawns = QuestieDB.QueryObjectSingle(id, "spawns")
    end
    local isHostileVendor = source.field == "vendors"
        and not QuestieDB.IsFriendlyToPlayer(QuestieDB.QueryNPCSingle(id, "friendlyToFaction"))
    return spawns ~= nil and not isHostileVendor
end

---@class JourneyItemSourceEntry
---@field id number
---@field name string
---@field dropRate number? In percent

---Those the player can get the item from, the most likely drop first.
---@param itemId ItemId
---@param source JourneyItemSource
---@param ids number[]?
---@return JourneyItemSourceEntry[]
local function _GetEntries(itemId, source, ids)
    local entries = {}
    for _, id in ipairs(ids or {}) do
        local name
        if source.kind == "npc" then
            name = QuestieDB.QueryNPCSingle(id, "name")
        else
            name = QuestieDB.QueryObjectSingle(id, "name")
        end
        if name and _IsReachable(source, id) then
            -- Only NPCs have drop rates
            local dropRate = source.field == "npcDrops" and QuestieDB.GetItemDroprate(itemId, id)
            table.insert(entries, {id = id, name = name, dropRate = dropRate and dropRate[1] or nil})
        end
    end
    table.sort(entries, function(a, b)
        if (a.dropRate or -1) ~= (b.dropRate or -1) then
            return (a.dropRate or -1) > (b.dropRate or -1)
        end
        return a.name < b.name or a.name == b.name and a.id < b.id
    end)
    return entries
end

---@param source JourneyItemSource
---@param entry JourneyItemSourceEntry
---@return string? tag Where it is, and how likely it drops the item
local function _GetSourceTag(source, entry)
    local zoneId
    if source.kind == "npc" then
        zoneId = QuestieDB.QueryNPCSingle(entry.id, "zoneID")
    else
        zoneId = QuestieDB.QueryObjectSingle(entry.id, "zoneID")
    end
    local parts = {}
    if zoneId and zoneId > 0 then
        table.insert(parts, QuestieJourneyUtils:GetZoneName(zoneId))
    end
    if entry.dropRate then
        table.insert(parts, QuestieLib.FormatDropRate(entry.dropRate) .. "%")
    end
    return #parts > 0 and table.concat(parts, "   ") or nil
end

---@param source JourneyItemSource
---@param entry JourneyItemSourceEntry
---@param onChanged fun()
---@return JourneyDetails.Row
local function _GetSourceRow(source, entry, onChanged)
    local row = {
        type = "step",
        text = source.kind == "npc" and JourneyNameColors.Npc(entry.id, entry.name) or JourneyNameColors.Object(entry.name),
        tag = _GetSourceTag(source, entry),
    }
    row.action, row.state = JourneyEntityDetails.GetMapAction(source.kind, entry.id, onChanged)
    return JourneyLinks.Link(row, source.kind, entry.id)
end

---@param ids ItemId[]?
---@return JourneyDetails.Row[]
local function _GetItemSteps(ids)
    local steps = {}
    for _, id in ipairs(ids or {}) do
        local name = QuestieDB.QueryItemSingle(id, "name")
        if name then
            table.insert(steps, JourneyLinks.Link({
                type = "step",
                text = JourneyNameColors.Item(id, name),
                trailingIcon = QuestieCompat.GetItemIcon(id),
            }, "item", id))
        end
    end
    return steps
end

---Puts all the places on the map that the details list, or removes them again.
---@param itemId ItemId
---@param idsByKind table<ManualNoteKind, number[]>
---@param onChanged fun()
---@return JourneyDetails.Row? footer Nil when nothing is listed
local function _GetFooter(itemId, idsByKind, onChanged)
    local groups = {}
    for kind, ids in pairs(idsByKind) do
        if #ids > 0 then
            table.insert(groups, {name = "item " .. itemId .. " " .. kind, kind = kind, ids = ids})
        end
    end
    if #groups == 0 then
        return nil
    end
    local isShown = false
    for _, group in ipairs(groups) do
        isShown = isShown or ManualNotes.IsGroupShown(group.name)
    end
    return {
        type = "footer",
        state = tostring(isShown),
        buttons = {{
            text = isShown and l10n("Remove from Map") or l10n("Show on Map"),
            icon = JourneyIcon.MAP,
            onClick = function()
                for _, group in ipairs(groups) do
                    -- Once all of them are there, so the small maps of the rows are right
                    if isShown then
                        ManualNotes.HideGroup(group.name, group.kind, group.ids, onChanged)
                    else
                        ManualNotes.ShowGroup(group.name, group.kind, group.ids, onChanged)
                    end
                end
                onChanged()
            end,
        }},
    }
end

---@param itemId ItemId
---@param onChanged fun() Called after the user changed something the rows show
---@return JourneyDetails.Row[] rows Empty when it isn't in the database
function JourneyItemDetails.GetRows(itemId, onChanged)
    local name = QuestieDB.QueryItemSingle(itemId, "name")
    if not name then
        return {}
    end

    ---@type JourneyDetails.Row[]
    local rows = {
        {type = "page", text = JourneyNameColors.Item(itemId, name), tag = l10n("Item ID") .. l10n(": ") .. itemId},
        {type = "gap", height = 6},
        {type = "itemTooltip", itemId = itemId, icon = QuestieCompat.GetItemIcon(itemId), onClick = function() _OnIconClick(itemId) end},
    }
    _AddSection(rows, l10n("Starts this quest"), JourneyLinks.GetQuestSteps({QuestieDB.QueryItemSingle(itemId, "startQuest")}))

    local footer
    if QuestieCorrections.questItemBlacklist[itemId] then
        table.insert(rows, {type = "text", text = l10n("This item is blacklisted because it has too many sources")})
    else
        local idsByKind = {npc = {}, object = {}}
        local isListed = {npc = {}, object = {}}
        for _, source in ipairs(SOURCES) do
            local entries = _GetEntries(itemId, source, QuestieDB.QueryItemSingle(itemId, source.field))
            local sourceRows = {}
            for _, entry in ipairs(entries) do
                table.insert(sourceRows, _GetSourceRow(source, entry, onChanged))
                if not isListed[source.kind][entry.id] then
                    isListed[source.kind][entry.id] = true
                    table.insert(idsByKind[source.kind], entry.id)
                end
            end
            _AddSection(rows, l10n(source.caption) .. Questie:Colorize("   " .. #entries, "gray"), sourceRows)
        end
        footer = _GetFooter(itemId, idsByKind, onChanged)
    end

    _AddSection(rows, l10n("Contained in"), _GetItemSteps(QuestieDB.QueryItemSingle(itemId, "itemDrops")))
    _AddSection(rows, l10n("Reward from"), JourneyLinks.GetQuestSteps(QuestieDB.QueryItemSingle(itemId, "questRewards")))
    JourneyRawData.AddRows(rows, QuestieDB:GetItem(itemId), QuestieDB.itemKeys)
    table.insert(rows, footer)
    return rows
end

return JourneyItemDetails
