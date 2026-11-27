---What a search found. The source of the page is what was searched for.
---@class JourneyResultsPage
local JourneyResultsPage = QuestieLoader:CreateModule("JourneyResultsPage")

---@type JourneyPage
local JourneyPage = QuestieLoader:ImportModule("JourneyPage")
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

-- Kinds with more results than this start collapsed
local MAX_EXPANDED_RESULTS = 30
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

---@param page JourneyPage.Instance
function JourneyResultsPage.Load(page)
    local query, expandedPaths = page.source, page.tree.expandedPaths
    local zones, factions = JourneyPlaces.Search(query)
    local nodes = {
        _GetPlacesNode(l10n("Quests by Zone"), "zone", zones),
        _GetPlacesNode(l10n("Quests by Faction"), "faction", factions),
    }
    expandedPaths["result zone"], expandedPaths["result faction"] = true, true

    local count = #zones + #factions
    for _, kind in ipairs(QuestieSearch.KINDS) do
        local ids = QuestieSearch.Search(kind, query)
        count = count + #ids
        local children = {}
        for index, id in ipairs(ids) do
            children[index] = {value = id, kind = kind}
        end
        table.insert(nodes, {value = "result " .. kind, text = l10n(KIND_TITLES[kind]), note = tostring(#ids), children = children})
        if not page.isLoaded then
            expandedPaths["result " .. kind] = #ids <= MAX_EXPANDED_RESULTS or nil
        end
    end
    JourneyPage.SetNodes(page, nodes, l10n("No Match for Search Results: %s", query))
    JourneyPage.SetProgress(page, l10n("Results for %s: %s", Questie:Colorize(query, "yellow"), count))
    JourneyPage.ShowDetails(page, page.isLoaded)
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
        local isKnown, name = pcall(QuestieJourneyUtils.GetZoneName, QuestieJourneyUtils, zoneId)
        return isKnown and name or nil
    end
end

---The zone or faction whose name the user started to type.
---@param query string
---@return JourneySource?
function JourneyResultsPage.GetTypedPlace(query)
    local zones, factions = JourneyPlaces.Search(query)
    if zones[1] and JourneyPlaces.StartsWith(zones[1], query) then
        return "zone:" .. zones[1].id
    elseif factions[1] and JourneyPlaces.StartsWith(factions[1], query) then
        return "faction:" .. factions[1].id
    end
end

return JourneyResultsPage
