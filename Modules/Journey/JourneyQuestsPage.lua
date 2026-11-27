---The quests of a zone or a faction, sorted by what the player can do with them.
---@class JourneyQuestsPage
local JourneyQuestsPage = QuestieLoader:CreateModule("JourneyQuestsPage")

---@type JourneyFactions
local JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
---@type JourneyPage
local JourneyPage = QuestieLoader:ImportModule("JourneyPage")
---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Categories that are open until the player closes them
local EXPANDED_CATEGORIES = {"log", "available", "repeatable"}

---@param nodes JourneyTreeNode[]
---@return JourneyTreeNode?
local function _GetFirstQuest(nodes)
    for _, node in ipairs(nodes) do
        if node.value ~= "completed" and node.children and node.children[1] then
            return node.children[1]
        end
    end
end

---@param page JourneyPage.Instance
---@param factionId number
---@param nodes JourneyTreeNode[]
local function _AddFaction(page, factionId, nodes)
    page.data.overview = JourneyFactions.Arrange(factionId, nodes)
    table.insert(nodes, 1, {value = factionId, kind = "faction", text = OVERVIEW})
    if not page.isLoaded and not page.selection then
        page.selection = {kind = "faction", id = factionId}
    end
end

---@param page JourneyPage.Instance
function JourneyQuestsPage.Load(page)
    local nodes, completed, total = JourneyQuestCategories.Collect(JourneyPlaces.GetQuestIds(page.source))
    local kind, id = JourneyPlaces.Split(page.source)
    if kind == "faction" then
        _AddFaction(page, id, nodes)
    end
    if not page.isLoaded then
        for _, category in ipairs(EXPANDED_CATEGORIES) do
            JourneyTree.Expand(page.tree, category)
        end
        local first = _GetFirstQuest(nodes)
        if first and not page.selection then
            page.selection = {kind = "quest", id = first.value}
        end
    end
    JourneyPage.SetNodes(page, nodes, l10n("No Quests found"))
    JourneyPage.SetProgress(page, total > 0 and l10n("%s of %s completed", completed, total) or "", total > 0 and completed / total or nil)
    JourneyPage.ShowDetails(page, page.isLoaded)
end

---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection
---@return JourneyDetails.Row[]?
function JourneyQuestsPage.GetRows(page, selection)
    if selection.kind == "faction" then
        return page.data.overview and JourneyFactions.GetRows(selection.id, page.data.overview, function(zoneKey)
            JourneyTree.Reveal(page.tree, "available", zoneKey)
        end) or {}
    end
end

return JourneyQuestsPage
