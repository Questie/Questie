---Puts NPCs and objects on the map as Manual Notes, which Shift-click and `/questie tomap reset` remove.
---@class ManualNotes
local ManualNotes = QuestieLoader:CreateModule("ManualNotes")

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---@alias ManualNoteKind "npc"|"object"

---Which groups are on the map, or are being added. See ManualNotes.ShowGroup.
---@type table<string, boolean>
local shownGroups = {}

---What adds or removes the notes of a group
---@type table<string, Ticker>
local groupTimers = {}

---@param kind ManualNoteKind
---@param id number
---@return number spawnId How QuestieMap tells NPCs and objects apart
local function _GetSpawnId(kind, id)
    return kind == "npc" and id or -id
end

---@param kind ManualNoteKind
---@param id number
---@return boolean
function ManualNotes.IsShown(kind, id)
    local notes = QuestieMap.manualFrames["any"]
    return notes ~= nil and notes[_GetSpawnId(kind, id)] ~= nil
end

---@param kind ManualNoteKind
---@param id number
function ManualNotes.Show(kind, id)
    if ManualNotes.IsShown(kind, id) then
        return
    end
    if kind == "npc" then
        QuestieMap:ShowNPC(id)
    else
        QuestieMap:ShowObject(id)
    end
end

---@param kind ManualNoteKind
---@param id number
function ManualNotes.Hide(kind, id)
    QuestieMap:UnloadManualFrames(_GetSpawnId(kind, id))
end

---@param group string
---@param change fun(kind: ManualNoteKind, id: number)
---@param kind ManualNoteKind
---@param ids number[]
local function _ChangeGroup(group, change, kind, ids)
    -- Both cover the whole group, so what the one before didn't get to doesn't matter
    if groupTimers[group] then
        groupTimers[group]:Cancel()
    end
    groupTimers[group] = JourneyThread.Start("ManualNotes", function()
        for _, id in ipairs(ids) do
            change(kind, id)
            JourneyThread.YieldIfNeeded()
        end
    end)
end

---Shows many together, over several frames.
---@param group string Anything that tells it apart from other groups
---@param kind ManualNoteKind
---@param ids number[]
function ManualNotes.ShowGroup(group, kind, ids)
    shownGroups[group] = true
    _ChangeGroup(group, ManualNotes.Show, kind, ids)
end

---@param group string
---@param kind ManualNoteKind
---@param ids number[]
function ManualNotes.HideGroup(group, kind, ids)
    shownGroups[group] = nil
    _ChangeGroup(group, ManualNotes.Hide, kind, ids)
end

---@param group string
---@return boolean
function ManualNotes.IsGroupShown(group)
    return shownGroups[group] == true
end

function ManualNotes.HideAll()
    for _, timer in pairs(groupTimers) do
        timer:Cancel()
    end
    groupTimers, shownGroups = {}, {}
    QuestieMap:ResetManualFrames()
end

---@param zoneId AreaId
---@return UiMapId? uiMapId For an instance, of the zone its entrance is in
function ManualNotes.GetMap(zoneId)
    local entrances = ZoneDB:GetDungeonLocation(zoneId)
    return ZoneDB:GetUiMapIdByAreaId(entrances and entrances[1][1] or zoneId)
end

---Shows something and opens the map at it.
---@param kind ManualNoteKind
---@param id number
---@param uiMapId UiMapId
---@return boolean isOpen
function ManualNotes.OpenMap(kind, id, uiMapId)
    ManualNotes.Show(kind, id)
    if not QuestieCompat.OpenWorldMap(uiMapId) then
        Questie:Print(l10n("Can't open the map while in combat. Open it manually."))
        return false
    end
    return true
end

return ManualNotes
