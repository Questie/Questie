---@class QuestieConditionText
local QuestieConditionText = QuestieLoader:CreateModule("QuestieConditionText")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Renders the trees LibQuestieDB.Conditions.Explain returns. QuestieDB owns the expression and
-- its evaluation; the wording and localization are Questie's.

local function questName(questId)
    return (QuestieDB.QueryQuestSingle(questId, "name") or "?") .. " (" .. questId .. ")"
end

local function itemName(itemId)
    return (QuestieDB.QueryItemSingle(itemId, "name") or "?") .. " (" .. itemId .. ")"
end

local function spellName(spellId)
    return (C_Spell.GetSpellName(spellId) or "?") .. " (" .. spellId .. ")"
end

---Condition ranks run from 0 (Hated) to 7 (Exalted); the client labels start at 1.
local function standing(rank)
    return _G["FACTION_STANDING_LABEL" .. (rank + 1)] or tostring(rank)
end

local function withCount(text, count)
    return (count and count > 1) and (text .. " x" .. count) or text
end

-- One template per condition function. Unlisted functions show their raw call.
local describe = {
    QuestRewarded = function(id) return l10n("Turned in: %s", questName(id)) end,
    QuestInLog = function(id) return l10n("In quest log: %s", questName(id)) end,
    QuestComplete = function(id) return l10n("Objectives complete: %s", questName(id)) end,
    QuestNone = function(id) return l10n("Not taken or turned in: %s", questName(id)) end,
    QuestAvailable = function(id) return l10n("Can be accepted: %s", questName(id)) end,
    HasAura = function(id) return l10n("Has aura: %s", spellName(id)) end,
    HasItem = function(id, count) return withCount(l10n("Has item: %s", itemName(id)), count) end,
    HasItemOrBank = function(id, count) return withCount(l10n("Has item, bank included: %s", itemName(id)), count) end,
    HasItemEquipped = function(id) return l10n("Has item equipped: %s", itemName(id)) end,
    HasSkill = function(id, level)
        return l10n("Profession: %s", (QuestieProfessions:GetProfessionName(id) or tostring(id)) .. " (" .. (level or 1) .. ")")
    end,
    KnowsSpell = function(id) return l10n("Knows spell: %s", spellName(id)) end,
    HasRep = function(id, rank)
        return l10n("Reputation at least %s: %s", standing(rank), QuestieReputation.GetFactionName(id) or tostring(id))
    end,
    RepBelow = function(id, rank)
        return l10n("Reputation at most %s: %s", standing(rank), QuestieReputation.GetFactionName(id) or tostring(id))
    end,
    IsTeam = function(tag) return l10n("Faction: %s", l10n(tag)) end,
    IsRace = function(mask) return l10n("Race: %s", QuestieLib:GetRaceString(mask)) end,
    IsClass = function(mask) return l10n("Class: %s", QuestieLib:GetClassString(mask)) end,
    IsLevel = function(level) return l10n("Level at least %s", level) end,
    IsLevelExact = function(level) return l10n("Level exactly %s", level) end,
    IsLevelBelow = function(level) return l10n("Level at most %s", level) end,
}

---@param node QuestieDBConditionNode A leaf.
---@return string
local function describeLeaf(node)
    local template = describe[node.call]
    if template then
        local ok, text = pcall(template, unpack(node.args))
        if ok then return text end
    end
    local args = {}
    for index, value in ipairs(node.args) do args[index] = tostring(value) end
    return node.call .. "(" .. table.concat(args, ", ") .. ")"
end

local function colorFor(result)
    if result == nil then return "yellow" end
    return result and "green" or "red"
end

---Render a whole explained condition as indented, colored lines.
---Green parts hold, red parts do not, and yellow parts cannot be read right now.
---@param tree QuestieDBConditionNode
---@return string
function QuestieConditionText.RenderTree(tree)
    local lines = {}
    local function add(node, depth)
        local indent = string.rep("    ", depth)
        if node.call then
            lines[#lines + 1] = indent .. Questie:Colorize(describeLeaf(node), colorFor(node.result))
        elseif node.op == "not" and node.children[1].call then
            local child = node.children[1]
            lines[#lines + 1] = indent .. Questie:Colorize(l10n("Not") .. l10n(": ") .. describeLeaf(child), colorFor(node.result))
        else
            local label = (node.op == "and" and l10n("All of")) or (node.op == "or" and l10n("Any of")) or l10n("Not")
            lines[#lines + 1] = indent .. Questie:Colorize(label .. l10n(": "), colorFor(node.result))
            for _, child in ipairs(node.children) do add(child, depth + 1) end
        end
    end
    add(tree, 0)
    return table.concat(lines, "\n")
end

---Render a quest's condition, or nil when it has none.
---@param questId QuestId
---@return string?
function QuestieConditionText.RenderQuest(questId)
    local tree = LibQuestieDB.Conditions.ExplainQuest(questId)
    return tree and QuestieConditionText.RenderTree(tree)
end

---Describe the parts that make a condition false, for a one-line explanation.
---A false `and` is blocked by its false operands; a false `or` by all of them; a false `not x`
---by `x` holding.
---@param tree QuestieDBConditionNode
---@return string[] parts Empty unless the condition is false.
function QuestieConditionText.BlockingParts(tree)
    local parts = {}
    local function collect(node, negated)
        if node.result ~= (negated and true or false) then return end
        if node.call then
            local text = describeLeaf(node)
            parts[#parts + 1] = negated and (l10n("Not") .. l10n(": ") .. text) or text
        elseif node.op == "not" then
            collect(node.children[1], not negated)
        else
            for _, child in ipairs(node.children) do collect(child, negated) end
        end
    end
    collect(tree, false)
    return parts
end

return QuestieConditionText
