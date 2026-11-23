---@class TaintWatch
local TaintWatch = QuestieLoader:CreateModule("TaintWatch")
---@class TaintWatchPrivate
local _TaintWatch = TaintWatch.private

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

-- Forever blocks Blizzard code that runs with Questie's taint, often long after the Questie call that caused it.
-- TaintWatch records Questie's risky calls and checks Blizzard state for taint, so a report of the first taint
-- and the later blocked action shows what led to it. It only reads Blizzard state and never calls protected code.

local MAX_NOTES = 40
local MAX_CAPTURES = 5
local NOTE_COALESCE_SECONDS = 1
local NOTE_COALESCE_DEPTH = 3
local POLL_INTERVAL = 1
local STACK_LEVELS = 25
local QUESTIE = "Questie"

-- Blizzard events that show what the player was doing around Questie's actions
local BREADCRUMB_EVENTS = {
    PLAYER_REGEN_DISABLED = true,
    PLAYER_REGEN_ENABLED = true,
    PLAYER_ENTERING_WORLD = true,
    WORLD_MAP_OPEN = true,
    SUPER_TRACKING_CHANGED = true,
    QUEST_ACCEPTED = true,
    QUEST_DETAIL = true,
    GOSSIP_SHOW = true,
    EDIT_MODE_LAYOUTS_UPDATED = true,
}

_TaintWatch.notes = {}
_TaintWatch.captures = {}
_TaintWatch.otherCaptures = {}
_TaintWatch.reported = {}
_TaintWatch.lastStatus = {}
_TaintWatch.active = false

---TaintWatch only works while Questie's debug mode is enabled. The hooks stay installed after debug is disabled
---until the next reload, but they do nothing.
---@return boolean
function _TaintWatch.IsEnabled()
    return _TaintWatch.active and Questie.db ~= nil and Questie.db.profile.debugEnabled == true
end

---Records a Questie call that can taint Blizzard state. Calls repeating one of the last few notes within a second
---are counted on that note, so bulk pin updates do not push older actions out.
---@param label string
---@param detail any?
function TaintWatch.Note(label, detail)
    if (not _TaintWatch.IsEnabled()) then
        return
    end
    local notes = _TaintWatch.notes
    local now = GetTime()
    local combat = InCombatLockdown()
    for i = #notes, math.max(1, #notes - NOTE_COALESCE_DEPTH + 1), -1 do
        local note = notes[i]
        if note.label == label and note.detail == detail and note.combat == combat and (now - note.time) < NOTE_COALESCE_SECONDS then
            note.count = note.count + 1
            note.time = now
            return
        end
    end

    table.insert(notes, {
        time = now,
        label = label,
        detail = detail,
        count = 1,
        combat = combat,
    })
    if #notes > MAX_NOTES then
        table.remove(notes, 1)
    end
end

---@param tbl any
---@param key any
---@return string? taintedBy The addon that tainted the value, nil when it is secure or can not be checked
function _TaintWatch.GetTaint(tbl, key)
    if type(tbl) ~= "table" or type(key) ~= "string" then
        return nil
    end
    local secure, taintedBy = issecurevariable(tbl, key)
    if secure then
        return nil
    end
    return taintedBy or "unknown"
end

---Finds where a capture would be stored. Other addons' taint is kept apart, so it can not use up the slots
---for Questie's taint.
---@param label string
---@param taintedBy string
---@return table[]? captures The list the capture belongs to, nil when it would be discarded
function _TaintWatch.GetCaptureList(label, taintedBy)
    local previous = _TaintWatch.lastStatus[label]
    if previous == taintedBy or previous == QUESTIE then
        return nil
    end

    local captures = taintedBy == QUESTIE and _TaintWatch.captures or _TaintWatch.otherCaptures
    if #captures >= MAX_CAPTURES then
        return nil
    end
    return captures
end

---Stores the first time a watched value becomes tainted. Only Questie's first capture of the session is reported.
---@param label string
---@param taintedBy string
---@param stack string?
function _TaintWatch.Capture(label, taintedBy, stack)
    local captures = _TaintWatch.GetCaptureList(label, taintedBy)
    if (not captures) then
        return
    end
    _TaintWatch.lastStatus[label] = taintedBy

    table.insert(captures, {
        time = GetTime(),
        label = label,
        taintedBy = taintedBy,
        combat = InCombatLockdown(),
        stack = stack,
        notes = _TaintWatch.FormatNotes(GetTime()),
    })

    if taintedBy == QUESTIE then
        _TaintWatch.Report("taint", label .. " was tainted by " .. taintedBy)
    end
end

---Checks a value right after Blizzard code wrote it, so the stack still shows the caller.
---The stack is only built for a capture that will be stored.
---@param label string
---@param tbl any
---@param key string
function _TaintWatch.CheckWrite(label, tbl, key)
    if (not _TaintWatch.IsEnabled()) or _TaintWatch.lastStatus[label] == QUESTIE then
        return
    end
    local taintedBy = _TaintWatch.GetTaint(tbl, key)
    if taintedBy and _TaintWatch.GetCaptureList(label, taintedBy) then
        _TaintWatch.Capture(label, taintedBy, debugstack(2, STACK_LEVELS, 0))
    end
end

---@return table? pin Blizzard's quest blob pin on the world map
function _TaintWatch.FindQuestBlobPin()
    if (not WorldMapFrame) or type(WorldMapFrame.dataProviders) ~= "table" then
        return nil
    end
    for provider in pairs(WorldMapFrame.dataProviders) do
        local pin = type(provider) == "table" and provider.pin
        if type(pin) == "table" and pin.pinTemplate == "QuestBlobPinTemplate" then
            return pin
        end
    end
    return nil
end

---@return table<number, {label: string, getTable: fun(): any, key: string}>
function _TaintWatch.GetPolledValues()
    local values = {}
    local function Add(label, getTable, key)
        table.insert(values, {label = label, getTable = getTable, key = key})
    end

    local function WorldMap() return WorldMapFrame end
    for _, key in ipairs({"mapID", "pinPools", "pinSuppressionDirty", "pinNudgingDirty", "pinPostProcessDirty", "pinsToNudge", "pinSuppressors"}) do
        Add("WorldMapFrame." .. key, WorldMap, key)
    end

    local function ScrollContainer() return WorldMapFrame and WorldMapFrame.ScrollContainer end
    for _, key in ipairs({"currentScale", "targetScale", "currentScrollX", "targetScrollX", "currentScrollY", "targetScrollY"}) do
        Add("ScrollContainer." .. key, ScrollContainer, key)
    end

    Add("pinPools.QuestPinTemplate", function() return WorldMapFrame and WorldMapFrame.pinPools end, "QuestPinTemplate")
    local function QuestPinPool() return WorldMapFrame and WorldMapFrame.pinPools and WorldMapFrame.pinPools.QuestPinTemplate end
    Add("QuestPinPool.activeObjects", QuestPinPool, "activeObjects")
    Add("QuestPinPool.inactiveObjects", QuestPinPool, "inactiveObjects")

    for _, key in ipairs({"mapAllowsBlobs", "questID", "focusedQuestID", "highlightedQuestID", "dirty"}) do
        Add("QuestBlobPin." .. key, _TaintWatch.FindQuestBlobPin, key)
    end

    Add("QuestDetailScrollChildFrame.alphaDependentText", function() return QuestDetailScrollChildFrame end, "alphaDependentText")

    local function Tracker() return ObjectiveTrackerFrame end
    for _, key in ipairs({"dirty", "dirtyCallback", "layoutParent"}) do
        Add("ObjectiveTrackerFrame." .. key, Tracker, key)
    end
    local function TrackerLayout() return ObjectiveTrackerFrame and ObjectiveTrackerFrame.layoutParent end
    for _, key in ipairs({"showingFrames", "isDirty", "dirty"}) do
        Add("ObjectiveTrackerFrame.layoutParent." .. key, TrackerLayout, key)
    end
    for _, name in ipairs({"QuestObjectiveTracker", "ScenarioObjectiveTracker", "CampaignQuestObjectiveTracker"}) do
        Add(name .. ".isDirty", function() return _G[name] end, "isDirty")
    end

    -- Blizzard keeps the layout of the tracker, the durability frame and similar frames in these containers
    for _, name in ipairs({"RightManagedFrameContainer", "BottomManagedFrameContainer", "PlayerBottomManagedFrameContainer"}) do
        Add(name .. ".showingFrames", function() return _G[name] end, "showingFrames")
    end

    return values
end

function _TaintWatch.Poll()
    if (not _TaintWatch.IsEnabled()) then
        return
    end
    for _, value in ipairs(_TaintWatch.polledValues) do
        if _TaintWatch.lastStatus[value.label] ~= QUESTIE then
            local taintedBy = _TaintWatch.GetTaint(value.getTable(), value.key)
            if taintedBy then
                _TaintWatch.Capture(value.label, taintedBy, nil)
            end
        end
    end
end

---Hooks run after Blizzard's code and only read what it wrote. hooksecurefunc and HookScript keep the hooked code secure.
function _TaintWatch.InstallHooks()
    local scrollContainer = WorldMapFrame and WorldMapFrame.ScrollContainer
    if scrollContainer and scrollContainer.MarkCanvasDirty then
        hooksecurefunc(scrollContainer, "MarkCanvasDirty", function(self)
            _TaintWatch.CheckWrite("ScrollContainer.currentScale", self, "currentScale")
            _TaintWatch.CheckWrite("ScrollContainer.currentScrollX", self, "currentScrollX")
            _TaintWatch.CheckWrite("ScrollContainer.currentScrollY", self, "currentScrollY")
        end)
    end

    local blobPin = _TaintWatch.FindQuestBlobPin()
    if blobPin and blobPin.OnMapChanged then
        hooksecurefunc(blobPin, "OnMapChanged", function(self)
            _TaintWatch.CheckWrite("QuestBlobPin.mapAllowsBlobs", self, "mapAllowsBlobs")
        end)
    end

    if QuestFrameDetailPanel and QuestDetailScrollChildFrame then
        QuestFrameDetailPanel:HookScript("OnShow", function()
            _TaintWatch.CheckWrite("QuestDetailScrollChildFrame.alphaDependentText", QuestDetailScrollChildFrame, "alphaDependentText")
        end)
    end

    if WorldMapFrame and WorldMapFrame.HookScript then
        WorldMapFrame:HookScript("OnShow", function() TaintWatch.Note("[event] WorldMap shown") end)
        WorldMapFrame:HookScript("OnHide", function() TaintWatch.Note("[event] WorldMap hidden") end)
    end

    if ObjectiveTrackerFrame and ObjectiveTrackerFrame.MarkDirty then
        hooksecurefunc(ObjectiveTrackerFrame, "MarkDirty", function(self)
            _TaintWatch.CheckWrite("ObjectiveTrackerFrame.dirty", self, "dirty")
        end)
    end
end

---@param event string
---@param ... any
function _TaintWatch.OnEvent(_, event, ...)
    if (not _TaintWatch.IsEnabled()) then
        return
    end
    if BREADCRUMB_EVENTS[event] then
        local detail = ...
        TaintWatch.Note("[event] " .. event, type(detail) == "number" and detail or nil)
    elseif event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
        local addonName, func = ...
        if addonName == "Questie" then
            _TaintWatch.Report(event .. ":" .. tostring(func), event .. " " .. tostring(func))
        end
    elseif event == "LUA_WARNING" then
        for i = 1, select("#", ...) do
            local text = select(i, ...)
            if type(text) == "string" and text:find("Questie", 1, true) then
                -- Strip numbers so repeats of the same warning are reported once
                _TaintWatch.Report("warning:" .. text:gsub("%d+", ""), "LUA_WARNING " .. text)
                return
            end
        end
    end
end

---@param now number
---@return string
function _TaintWatch.FormatNotes(now)
    local lines = {}
    local notes = _TaintWatch.notes
    for i = #notes, 1, -1 do
        local note = notes[i]
        table.insert(lines, ("  -%.1fs %s%s%s%s"):format(
            now - note.time,
            note.label,
            note.detail ~= nil and (" " .. tostring(note.detail)) or "",
            note.count > 1 and (" x" .. note.count) or "",
            note.combat and " (combat)" or ""
        ))
    end
    if #lines == 0 then
        return "  none"
    end
    return table.concat(lines, "\n")
end

---@return string
function _TaintWatch.GetOtherAddons()
    local names = {}
    if C_AddOns and C_AddOns.GetNumAddOns then
        for i = 1, C_AddOns.GetNumAddOns() do
            local name = C_AddOns.GetAddOnInfo(i)
            if name and C_AddOns.IsAddOnLoaded(i) and name ~= "Questie" then
                table.insert(names, name)
            end
        end
    end
    return table.concat(names, ", ")
end

---@param title string
---@return string
function _TaintWatch.BuildReport(title)
    local now = GetTime()
    local _, build = GetBuildInfo()
    local lines = {
        "Questie TaintWatch: " .. title,
        ("Questie %s, client build %s, combat=%s, questPOI=%s"):format(
            QuestieLib:GetAddonVersionString(), tostring(build), tostring(InCombatLockdown()), tostring(GetCVar("questPOI"))),
        "Other addons: " .. _TaintWatch.GetOtherAddons(),
        "Taint captures:",
    }
    if #_TaintWatch.captures == 0 then
        table.insert(lines, "  none")
    end
    for _, capture in ipairs(_TaintWatch.captures) do
        table.insert(lines, ("  -%.1fs %s tainted by %s%s"):format(
            now - capture.time, capture.label, capture.taintedBy, capture.combat and " (combat)" or ""))
        table.insert(lines, "  Actions and events before it:")
        table.insert(lines, (capture.notes:gsub("\n", "\n  ")))
        if capture.stack then
            table.insert(lines, "  Stack:")
            table.insert(lines, "    " .. capture.stack:gsub("\n", "\n    "))
        end
    end
    for _, capture in ipairs(_TaintWatch.otherCaptures) do
        table.insert(lines, ("Also tainted: -%.1fs %s by %s%s"):format(
            now - capture.time, capture.label, capture.taintedBy, capture.combat and " (combat)" or ""))
    end
    table.insert(lines, "Last actions and events:")
    table.insert(lines, _TaintWatch.FormatNotes(now))
    return table.concat(lines, "\n")
end

---Hands a report to the error handler, so BugSack keeps it without interrupting anything. Once per key and session.
---BugGrabber only prints messages that mention it to the chat instead of storing them, so its name is altered.
---@param key string
---@param title string
function _TaintWatch.Report(key, title)
    if (not _TaintWatch.IsEnabled()) or _TaintWatch.reported[key] then
        return
    end
    _TaintWatch.reported[key] = true
    geterrorhandler()((_TaintWatch.BuildReport(title):gsub("BugGrabber", "Bug Grabber")))
end

---Starts the watchers. Safe to call again, e.g. when debug mode is enabled later in the session.
function TaintWatch.Initialize()
    if _TaintWatch.active or (not Questie.IsForever) or (not Questie.db.profile.debugEnabled) then
        return
    end
    _TaintWatch.active = true

    _TaintWatch.polledValues = _TaintWatch.GetPolledValues()
    _TaintWatch.InstallHooks()

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_ACTION_BLOCKED")
    eventFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
    eventFrame:RegisterEvent("LUA_WARNING")
    for event in pairs(BREADCRUMB_EVENTS) do
        eventFrame:RegisterEvent(event)
    end
    eventFrame:SetScript("OnEvent", _TaintWatch.OnEvent)

    C_Timer.NewTicker(POLL_INTERVAL, _TaintWatch.Poll)
end

