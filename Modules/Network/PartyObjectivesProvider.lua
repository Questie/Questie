---@class PartyObjectivesProvider : QuestieModule
local PartyObjectivesProvider = QuestieLoader:CreateModule("PartyObjectivesProvider")
-------------------------
--Import modules.
-------------------------
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

-- Beyond a 5-man group (party or 5-man dungeon) we stop drawing party objectives, to avoid
-- flooding the map with every raid member's quests.
local MAX_GROUP_SIZE = 5

-- The single-character objective types used in the QuestieComms packets, mapped to the
-- full type names used by the drawing pipeline and the database ObjectiveData.
local typeCharToFull = {
    ["m"] = "monster",
    ["o"] = "object",
    ["i"] = "item",
}

-- The tooltips prefer FullDescription (the objective text including "slain", see
-- QuestieLib:GetObjectiveDescription), which QuestieQuest extracts from the local quest log
-- when trimObjectiveText is inactive. The local player does not have a party member's quest,
-- so rebuild the text from the client's own quest log format string for the objective type.
local objectiveTypePatterns = {
    monster = QUEST_MONSTERS_KILLED, -- "%s slain: %d/%d"
    item = QUEST_ITEMS_NEEDED,
    object = QUEST_OBJECTS_FOUND,
}

---@param questId number
---@return boolean @true if the local player currently has this quest in their log
local function _PlayerHasQuest(questId)
    return QuestLogCache.questLog_DO_NOT_MODIFY[questId] ~= nil
end

---@param name string
---@return boolean @true if the named party member is online
local function _IsPlayerOnline(name)
    -- UnitIsConnected accepts a group member's name (same pattern as QuestieComms:CheckInGroup,
    -- which calls UnitInParty/UnitInRaid by name). Returns falsy for offline or non-group names.
    return UnitIsConnected(name)
end

-- The objective needs a non-nil Description or the map icon tooltip skips it entirely
-- (see MapIconTooltip "iconData.ObjectiveData.Description" check). The compiled database
-- objective text is often empty, so fall back to the target's name.
---@param objType string
---@param objId number
---@return string?
local function _GetObjectiveName(objType, objId)
    if objType == "monster" then
        local npc = QuestieDB:GetNPC(objId)
        return npc and npc.name
    elseif objType == "object" then
        local object = QuestieDB:GetObject(objId)
        return object and object.name
    elseif objType == "item" then
        local item = QuestieDB:GetItem(objId)
        return item and item.name
    end
end

---@param objType string
---@param description string
---@return string?
local function _GetFullDescription(objType, description)
    if Questie.db.profile.trimObjectiveText or description == "" then
        return nil
    end
    local pattern = objectiveTypePatterns[objType]
    if not pattern then
        return nil
    end
    local rawText = string.format(pattern, description, 0, 0)

    return QuestieLib.GetFullObjectiveText(rawText)
end

-- Resolve the real Blizzard objective text for a quest the local player doesn't have (a flagged
-- objective's DB name is meaningless). The data arrives asynchronously and QUEST_DATA_LOAD_RESULT
-- isn't available on Classic clients, so when it isn't cached yet we prime the client cache and
-- report dataReady=false; the orchestrator then polls with a bounded number of delayed redraws
-- until it lands (same pattern as Link.lua _AddQuestRequirements).
---@param questId number
---@param objectiveIndex number
---@return string? text, boolean dataReady
local function _ResolveApiObjectiveText(questId, objectiveIndex)
    if not HaveQuestData(questId) then
        C_QuestLog.GetQuestObjectives(questId) -- prime the client cache
        return nil, false
    end
    local objectives = C_QuestLog.GetQuestObjectives(questId)
    local objective = objectives and objectives[objectiveIndex]
    local text = objective and objective.text
    if (not text) or text == "" then
        return nil, true
    end
    -- Strip the counter from the objective text; the tooltip prepends fulfilled/required separately
    local fullText = QuestieLib.GetFullObjectiveText(text) or text
    if fullText == "" then
        -- A name-less counter (": 0/8") strips to "": the client has the quest data but hasn't
        -- populated the objective name yet, so report not-ready and let the orchestrator retry
        -- rather than baking in an empty description.
        return nil, false
    end
    return fullText, true
end

---@return boolean
function PartyObjectivesProvider.ShouldDraw()
    return Questie.db.profile.showPartyQuestObjectives
        and QuestiePlayer:GetGroupType() ~= nil
        and GetNumGroupMembers() <= MAX_GROUP_SIZE
end

-- All questIds party members currently have, for a full refresh.
---@return number[]
function PartyObjectivesProvider.GetAllRemoteQuestIds()
    local questIds = {}
    for questId in pairs(QuestieComms.remoteQuestLogs) do
        questIds[#questIds + 1] = questId
    end
    return questIds
end

---@class PartyObjectiveDescriptor
---@field Id number
---@field Type string
---@field Index number
---@field questId number
---@field Description string @the fully resolved objective text (Blizzard API text, DB text or name fallback)
---@field FullDescription string?
---@field Icon any
---@field Coordinates any?

---@class PartyObjectiveQuestPlan
---@field questId number
---@field quest table @the QuestieDB quest object the drawer feeds to PopulateObjective
---@field objectives PartyObjectiveDescriptor[] @standard objectives, drawn first
---@field specialObjectives PartyObjectiveDescriptor[] @DB-defined extras, drawn after the standard ones
---@field needsApiRetry boolean @true when an objective is still awaiting Blizzard quest data; the orchestrator retries

-- Decide what should be drawn for a single party quest and describe it as plain data. This owns
-- all data gathering: it reads comms data, the database, group/online state, settings and the
-- Blizzard quest cache (priming it for objective text), but makes no map calls and does no
-- scheduling, so the drawing layer just consumes the resolved descriptors and tests can assert
-- against them directly. Returns nil when nothing should be drawn.
---@param questId number
---@return PartyObjectiveQuestPlan?
function PartyObjectivesProvider.BuildQuestPlan(questId)
    -- Quests the local player has are drawn by the normal pipeline; don't double up.
    if _PlayerHasQuest(questId) then
        return nil
    end

    local players = QuestieComms.remoteQuestLogs[questId]
    if not players then
        return nil
    end

    -- An objective index is drawn if at least one online party member still needs it. Offline
    -- members are ignored so their icons disappear until they reconnect.
    local neededIndices = {}
    for playerName, objectives in pairs(players) do
        if _IsPlayerOnline(playerName) then
            for objectiveIndex, objective in pairs(objectives) do
                if not objective.finished then
                    neededIndices[objectiveIndex] = objective
                end
            end
        end
    end
    if not next(neededIndices) then
        return nil
    end

    local quest = QuestieDB.GetQuest(questId)
    if not (quest and quest.ObjectiveData) then
        return nil
    end
    if not quest.Color then
        quest.Color = QuestieLib:ColorWheel()
    end

    local objectives = {}
    local needsApiRetry = false

    for objectiveIndex, remoteObjective in pairs(neededIndices) do
        -- Prefer the database ObjectiveData (canonical Type/Id). It only misses an entry at this
        -- index when the party members' databases disagree (e.g. different Questie versions);
        -- in that case fall back to the comms data as a whole, to not mix the two sources.
        local objData = quest.ObjectiveData[objectiveIndex]
        local objType, objId
        if objData then
            objType = objData.Type
            objId = objData.Id
        else
            objType = typeCharToFull[remoteObjective.type]
            objId = remoteObjective.id
        end

        if objType and objId then
            -- When the objective's live API type (first char, from comms) differs from the
            -- database's compiled type (kill-credit, events, invisible "bunny" NPCs), the id/type
            -- no longer map to a meaningful name, so the drawer must use the Blizzard objective
            -- text and skip the name-based fallback. Derived here rather than transmitted so it
            -- works for every comms path, including the full quest list received on login/join.
            local useApiObjectiveText = objData ~= nil and remoteObjective.type ~= nil
                and string.sub(objData.Type, 1, 1) ~= remoteObjective.type
            -- The fallback description, used directly when API text isn't needed and while the
            -- Blizzard quest data hasn't been cached yet.
            local description = (objData and objData.Text)
                or (not useApiObjectiveText and _GetObjectiveName(objType, objId)) or ""
            local fullDescription = (not useApiObjectiveText) and _GetFullDescription(objType, description) or nil

            -- Resolve the Blizzard objective text now; the generator owns all data fetching. On a
            -- cache miss the fallback stands and the plan asks the orchestrator to retry, so the
            -- drawer never has to fetch anything - it just draws the description it is handed.
            if useApiObjectiveText then
                local apiText, dataReady = _ResolveApiObjectiveText(questId, objectiveIndex)
                if apiText then
                    description = apiText
                elseif not dataReady then
                    needsApiRetry = true
                end
            end

            objectives[#objectives + 1] = {
                Id = objId,
                Type = objType,
                Index = objectiveIndex,
                questId = questId,
                Description = description,
                FullDescription = fullDescription,
                Icon = objData and objData.Icon,
            }
        end
    end

    -- The quest's extra/special objectives (DB-defined, e.g. "use item" custom spawns and required
    -- source items). They come from QuestieDB.GetQuest independent of comms data, and the drawer
    -- draws them after the standard objectives, so they are kept in a separate list.
    local specialObjectives = {}
    local specialCounter = 0
    for _, special in pairs(quest.SpecialObjectives or {}) do
        -- Always draw extras. RealObjectiveIndex is used loosely in the DB (it can be 0 or point
        -- past the real objectives), so we can't reliably tie an extra to a standard objective's
        -- completion for party members; matching Questie's own pipeline, we just draw them.
        specialCounter = specialCounter + 1
        specialObjectives[#specialObjectives + 1] = {
            Id = special.Id,
            Type = special.Type,
            -- Offset past standard objective indices, matching PopulateQuestLogInfo.
            Index = 64 + specialCounter,
            questId = questId,
            Description = special.Description or "Special objective",
            Icon = special.Icon,
            Coordinates = special.Coordinates,
            -- Reuse the DB-built spawn list read-only; PopulateObjective builds it from
            -- Type/Id when absent (the required-source-item case).
            spawnList = special.spawnList,
        }
    end

    if #objectives == 0 and #specialObjectives == 0 then
        return nil
    end

    return {
        questId = questId,
        quest = quest,
        objectives = objectives,
        specialObjectives = specialObjectives,
        needsApiRetry = needsApiRetry,
    }
end

return PartyObjectivesProvider
