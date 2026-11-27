---What the Journey shows about a faction: the player's standing, and how far quests would bring it.
---@class JourneyFactions
local JourneyFactions = QuestieLoader:CreateModule("JourneyFactions")

---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- The lowest reputation of each standing, from Hated to Exalted. Checked against the standings the client names.
local STANDING_STARTS = {-42000, -6000, -3000, 0, 3000, 9000, 21000, 42000}
local HIGHEST_REPUTATION = 43000
local FIRST_POSITIVE_STANDING = 4
-- Categories whose quests are grouped by zone, because there can be hundreds
local GROUPED_CATEGORIES = {available = true, later = true}
local MAX_ZONES_ON_PAGE = 8

---@class JourneyFactions.Standing
---@field id number 1 is Hated, 8 is Exalted
---@field name string
---@field color ColorMixin
---@field reputation number
---@field value number How far the player is in this standing
---@field size number How much reputation this standing takes

---@class JourneyFactions.Part Some of a faction's quests
---@field count number
---@field reputation number

---@class JourneyFactions.Overview
---@field parts table<JourneyQuestCategory, JourneyFactions.Part>
---@field zones {key: number, name: string, count: number, reputation: number}[] Of the available quests

-------------------------
-- Standing
-------------------------

---@param reputation number
---@return JourneyFactions.Standing
function JourneyFactions.GetStandingAt(reputation)
    reputation = math.min(reputation, HIGHEST_REPUTATION - 1)
    local id = 1
    for index, start in ipairs(STANDING_STARTS) do
        if reputation >= start then
            id = index
        end
    end
    local color = FACTION_BAR_COLORS[id]
    return {
        id = id,
        name = GetText("FACTION_STANDING_LABEL" .. id, UnitSex("player")),
        color = CreateColor(color.r, color.g, color.b),
        reputation = reputation,
        value = reputation - STANDING_STARTS[id],
        size = (STANDING_STARTS[id + 1] or HIGHEST_REPUTATION) - STANDING_STARTS[id],
    }
end

---@param factionId FactionId
---@return JourneyFactions.Standing?
function JourneyFactions.GetStanding(factionId)
    local name, _, _, _, _, reputation = QuestieCompat.GetFactionInfoByID(factionId)
    return name and reputation and JourneyFactions.GetStandingAt(reputation) or nil
end

---@param factionId FactionId
---@return boolean isMet Whether it is in the player's list of factions
function JourneyFactions.IsMet(factionId)
    return QuestieReputation:GetPlayerReputations()[factionId] ~= nil
end

---@param standing JourneyFactions.Standing
---@return string
function JourneyFactions.GetStandingText(standing)
    return standing.color:WrapTextInColorCode(standing.name)
end

-------------------------
-- Rewards
-------------------------

---@param questId QuestId
---@param factionId FactionId
---@return number reputation
function JourneyFactions.GetReward(questId, factionId)
    local reputation = 0
    for _, reward in pairs(QuestieReputation.GetReputationReward(questId)) do
        if reward[1] == factionId then
            reputation = reputation + reward[2]
        end
    end
    return math.floor(reputation + 0.5)
end

---@param reputation number
---@return string
function JourneyFactions.GetRewardText(reputation)
    local sign = reputation < 0 and "-" or "+"
    return Questie:Colorize(sign .. BreakUpLargeNumbers(math.abs(reputation)), "reputationBlue")
end

-------------------------
-- List
-------------------------

---@param questId QuestId
---@return number key
---@return string name
local function _GetZone(questId)
    local zoneOrSort = QuestieDB.QueryQuestSingle(questId, "zoneOrSort") or 0
    local key = zoneOrSort > 0 and ZoneDB:GetParentZoneId(zoneOrSort) or zoneOrSort
    local name = JourneyPlaces.GetZoneName(key)
    return name ~= "" and key or 0, name ~= "" and name or OTHER
end

---@param quests JourneyTreeNode[]
---@return JourneyTreeNode[] zones With the quests below them. Those with the most reputation come first.
local function _GroupByZone(quests)
    local zones, zonesByKey = {}, {}
    for _, quest in ipairs(quests) do
        local key, name = _GetZone(quest.value)
        local zone = zonesByKey[key]
        if not zone then
            zone = {value = key, text = name, children = {}, reputation = 0}
            zonesByKey[key] = zone
            table.insert(zones, zone)
        end
        table.insert(zone.children, quest)
        zone.reputation = zone.reputation + quest.reputation
    end
    table.sort(zones, function(a, b)
        return a.reputation > b.reputation or a.reputation == b.reputation and a.text < b.text
    end)
    for _, zone in ipairs(zones) do
        zone.note = zone.reputation ~= 0 and JourneyFactions.GetRewardText(zone.reputation) or nil
    end
    return zones
end

---Shows the reputation of each quest, and groups the quests by zone. Yields, so it runs in a thread.
---@async
---@param factionId FactionId
---@param categories JourneyTreeNode[] Are changed
---@return JourneyFactions.Overview
function JourneyFactions.Arrange(factionId, categories)
    local overview = {parts = {}, zones = {}}
    for _, category in ipairs(categories) do
        local part = {count = #category.children, reputation = 0}
        overview.parts[category.value] = part
        for _, quest in ipairs(category.children) do
            JourneyThread.YieldIfNeeded()
            quest.reputation = JourneyFactions.GetReward(quest.value, factionId)
            quest.note = quest.reputation ~= 0 and JourneyFactions.GetRewardText(quest.reputation) or nil
            part.reputation = part.reputation + quest.reputation
        end
        if GROUPED_CATEGORIES[category.value] then
            category.children = _GroupByZone(category.children)
        end
        if category.value == "available" then
            for index, zone in ipairs(category.children) do
                overview.zones[index] = {key = zone.value, name = zone.text, count = #zone.children, reputation = zone.reputation}
            end
        end
    end
    return overview
end

-------------------------
-- Page of a faction
-------------------------

---@param overview JourneyFactions.Overview
---@param key JourneyQuestCategory
---@return JourneyFactions.Part
local function _GetPart(overview, key)
    return overview.parts[key] or {count = 0, reputation = 0}
end

---@param count number
---@param reputation number
---@return string
local function _GetPartText(count, reputation)
    local text = Questie:Colorize(tostring(count), "gray")
    return reputation ~= 0 and text .. "     " .. JourneyFactions.GetRewardText(reputation) or text
end

---@param factionId FactionId
---@param overview JourneyFactions.Overview
---@param onZone fun(key: number)
---@return JourneyDetails.Row[]
function JourneyFactions.GetRows(factionId, overview, onZone)
    local rows = {{type = "page", text = JourneyPlaces.GetFactionName(factionId)}}
    local standing = JourneyFactions.GetStanding(factionId)
    local gain = _GetPart(overview, "log").reputation + _GetPart(overview, "available").reputation
    if standing then
        local reached = JourneyFactions.GetStandingAt(standing.reputation + math.max(0, gain))
        table.insert(rows, {type = "gap", height = 8})
        table.insert(rows, {type = "standing", standing = standing, gain = gain, state = standing.reputation .. " " .. gain})
        if gain > 0 then
            table.insert(rows, {type = "gap", height = 4})
            table.insert(rows, {
                type = "text",
                text = l10n("With all quests you can do now: %s", JourneyFactions.GetStandingText(reached) .. "  "
                    .. BreakUpLargeNumbers(reached.value) .. " / " .. BreakUpLargeNumbers(reached.size)),
            })
        end
    end

    table.insert(rows, {type = "caption", text = REPUTATION})
    for _, line in ipairs({
        {"log", QUEST_LOG, Questie.icons["incomplete"]},
        {"available", l10n("Available Quests"), Questie.icons["available"]},
        {"repeatable", l10n("Repeatable Quests"), Questie.icons["repeatable"]},
        {"later", l10n("Missing Requirement")},
        {"completed", l10n("Completed Quests"), Questie.icons["checkmark"]},
    }) do
        local part = _GetPart(overview, line[1])
        if part.count > 0 then
            table.insert(rows, {type = "step", text = line[2], trailingIcon = line[3], tag = _GetPartText(part.count, part.reputation)})
        end
    end

    if #overview.zones > 0 then
        table.insert(rows, {type = "caption", text = l10n("Where")})
        for index = 1, math.min(#overview.zones, MAX_ZONES_ON_PAGE) do
            local zone = overview.zones[index]
            table.insert(rows, {
                type = "step",
                text = zone.name,
                tag = _GetPartText(zone.count, zone.reputation),
                onClick = function() onZone(zone.key) end,
            })
        end
    end
    return rows
end

-------------------------
-- All factions
-------------------------

---@class JourneyFactions.Met
---@field faction JourneyPlace
---@field standing JourneyFactions.Standing

---@return JourneyFactions.Met[] met In the player's list of factions, with the highest reputation first
---@return JourneyPlace[] others Sorted by name
function JourneyFactions.GetMet()
    local met, others = {}, {}
    for _, faction in ipairs(JourneyPlaces.GetFactions()) do
        local standing = JourneyFactions.IsMet(faction.id) and JourneyFactions.GetStanding(faction.id)
        if standing then
            table.insert(met, {faction = faction, standing = standing})
        else
            table.insert(others, faction)
        end
    end
    table.sort(met, function(a, b)
        return a.standing.reputation > b.standing.reputation
            or a.standing.reputation == b.standing.reputation and a.faction.name < b.faction.name
    end)
    return met, others
end

---@param maxCount number
---@return JourneyFactions.Met[] closest Those that take the least to reach the next standing
function JourneyFactions.GetClosest(maxCount)
    local closest = {}
    for _, entry in ipairs((JourneyFactions.GetMet())) do
        if entry.standing.id >= FIRST_POSITIVE_STANDING and entry.standing.id < #STANDING_STARTS then
            table.insert(closest, entry)
        end
    end
    table.sort(closest, function(a, b)
        local missingA, missingB = a.standing.size - a.standing.value, b.standing.size - b.standing.value
        return missingA < missingB or missingA == missingB and a.faction.name < b.faction.name
    end)
    for index = #closest, maxCount + 1, -1 do
        closest[index] = nil
    end
    return closest
end

return JourneyFactions
