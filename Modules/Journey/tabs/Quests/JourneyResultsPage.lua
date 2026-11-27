---What the search of the overview finds, and how it is described.
---@class JourneyResultsPage
local JourneyResultsPage = QuestieLoader:CreateModule("JourneyResultsPage")

---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local KIND_TITLES = {quest = "Quests", npc = "NPCs", object = "Objects", item = "Items"}
local PLACE_ICONS = {zone = "Interface\\AddOns\\Questie\\Icons\\map_scroll.png", faction = "Interface\\Icons\\INV_Shirt_GuildTabard_01"}

---@param title string
---@param kind string Of source
---@param places JourneyPlace[]
---@return JourneyTreeNode
local function _GetPlacesNode(title, kind, places)
    local children = {}
    for index, place in ipairs(places) do
        local source = kind .. ":" .. place.id
        children[index] = {value = source, kind = kind, source = source, text = place.name, note = place.group, icon = PLACE_ICONS[kind]}
    end
    return {value = "result " .. kind, text = title, note = tostring(#places), children = children}
end

---What a search finds, by what it is. Zones and factions come first.
---Goes through whole databases, so it has to run in a thread.
---@param query string
---@return JourneyTreeNode[] groups What was found are their children. A child that has a source leads to its own tab.
function JourneyResultsPage.Find(query)
    local zones, factions = JourneyPlaces.Search(query)
    local groups = {
        _GetPlacesNode(l10n("Quests by Zone"), "zone", zones),
        _GetPlacesNode(l10n("Quests by Faction"), "faction", factions),
    }
    for _, kind in ipairs(QuestieSearch.KINDS) do
        local ids = QuestieSearch.Search(kind, query)
        local children = {}
        for index, id in ipairs(ids) do
            children[index] = {value = id, kind = kind}
        end
        table.insert(groups, {value = "result " .. kind, text = l10n(KIND_TITLES[kind]), note = tostring(#ids), children = children})
    end
    return groups
end

---@param node JourneyTreeNode
---@return string
function JourneyResultsPage.GetText(node)
    if node.kind == "quest" then
        return QuestieLib:GetColoredQuestName(node.value, true, false)
    end
    local text = QuestieSearch.GetName(node.kind, node.value) or ""
    if Questie.db.profile.enableTooltipsQuestID then
        text = text .. " (" .. node.value .. ")"
    end
    return text
end

---@param node JourneyTreeNode
---@return JourneyIcon.Icon?
function JourneyResultsPage.GetIcon(node)
    if node.kind == "quest" then
        return JourneyQuestCategories.GetIcon(node.value, (JourneyQuestCategories.Get(node.value)))
    end
end

---@param node JourneyTreeNode
---@return string? note Where it is
function JourneyResultsPage.GetNote(node)
    local zoneId
    if node.kind == "quest" then
        zoneId = QuestieDB.QueryQuestSingle(node.value, "zoneOrSort")
    elseif node.kind == "npc" then
        zoneId = QuestieDB.QueryNPCSingle(node.value, "zoneID")
    elseif node.kind == "object" then
        zoneId = QuestieDB.QueryObjectSingle(node.value, "zoneID")
    end
    if zoneId and zoneId > 0 then
        return QuestieJourneyUtils:GetZoneName(zoneId)
    end
end

return JourneyResultsPage
