---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type JourneyQuestList
local JourneyQuestList = QuestieLoader:ImportModule("JourneyQuestList")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local ExpandFactionHeader, GetNumFactions, GetFactionInfo = QuestieCompat.ExpandFactionHeader, QuestieCompat.GetNumFactions, QuestieCompat.GetFactionInfo

local DROPDOWN_WIDTH = 220

-- What is shown. Whenever the tab is opened, it goes to the faction the player watches, until they choose something.
---@type string?
local expansionKey
---@type number?
local factionId
local hasUserChosen = false

---@type JourneyQuestList.Instance
local list
local expansionDropdown, factionDropdown

---@return number?
local function _GetWatchedFactionId()
    ExpandFactionHeader(0)

    for i = 1, GetNumFactions() do
        local _, _, _, _, _, _, _, _, isHeader, _, _, isWatched, _, id = GetFactionInfo(i)
        if isWatched and not isHeader then
            return id
        end
    end
end

---@return table<number, string> factions Names by faction ID
local function _GetFactions()
    return QuestieJourney.factionsByExpansion[expansionKey] or {}
end

---Shows the faction the player watches, or just the first expansion.
local function _FollowWatchedFaction()
    expansionKey, factionId = QuestieJourney.availableFactionExpansionOrder[1], nil

    local watchedFactionId = _GetWatchedFactionId()
    for _, key in ipairs(QuestieJourney.availableFactionExpansionOrder) do
        if watchedFactionId and QuestieJourney.factionsByExpansion[key][watchedFactionId] then
            expansionKey, factionId = key, watchedFactionId
            return
        end
    end
end

---@param newExpansionKey string
---@param newFactionId number? None is chosen yet when nil
local function _Choose(newExpansionKey, newFactionId)
    expansionKey, factionId = newExpansionKey, newFactionId
    hasUserChosen = true
    _QuestieJourney.questsByFaction.Refresh()
end

---@param canvas Frame
function _QuestieJourney.questsByFaction.Build(canvas)
    expansionDropdown = QuestieOptionsControls.Create(canvas, {
        type = "dropdown",
        title = l10n("Select Expansion and Faction"),
        options = function() return QuestieJourney.availableFactionExpansions end,
        sortOrder = function() return QuestieJourney.availableFactionExpansionOrder end,
        get = function() return expansionKey end,
        set = function(key) _Choose(key, nil) end,
    }, DROPDOWN_WIDTH, 1)
    expansionDropdown:SetPoint("TOPLEFT", canvas, "TOPLEFT", 4, -8)

    factionDropdown = QuestieOptionsControls.Create(canvas, {
        type = "dropdown",
        title = "",
        placeholder = l10n("Select Faction"),
        options = _GetFactions,
        sortOrder = function() return QuestieJourneyUtils:GetSortedZoneKeys(_GetFactions()) end,
        get = function() return factionId end,
        set = function(id) _Choose(expansionKey, id) end,
    }, DROPDOWN_WIDTH, 1)
    factionDropdown:SetPoint("TOPLEFT", expansionDropdown, "TOPRIGHT", 0, 0)

    list = JourneyQuestList.Create(canvas, 64)
end

function _QuestieJourney.questsByFaction.OnSelected()
    if not hasUserChosen then
        _FollowWatchedFaction()
    end
end

function _QuestieJourney.questsByFaction.Refresh()
    QuestieOptionsControls.Refresh(expansionDropdown)
    QuestieOptionsControls.Refresh(factionDropdown)

    JourneyQuestList.Load(list, tostring(factionId), function()
        if factionId then
            return _QuestieJourney.questsByFaction:CollectFactionQuests(factionId) or {}
        end
    end)
end

---Shows a quest. It doesn't have to belong to the faction.
---@param questId QuestId
function _QuestieJourney.questsByFaction.OpenQuest(questId)
    JourneyQuestList.Select(list, questId)
end
