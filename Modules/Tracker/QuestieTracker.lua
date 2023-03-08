local WatchFrame = QuestWatchFrame or WatchFrame

---@class QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
---@type QuestieTrackerPrivate
QuestieTracker.private = QuestieTracker.private or {}
---@class QuestieTrackerPrivate
local _QuestieTracker = QuestieTracker.private
-------------------------
--Import modules.
-------------------------
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type ActiveQuestsHeader
local ActiveQuestsHeader = QuestieLoader:ImportModule("ActiveQuestsHeader")
---@type LinePool
local LinePool = QuestieLoader:ImportModule("LinePool")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type FadeTicker
local FadeTicker = QuestieLoader:ImportModule("FadeTicker")
---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
local _QuestEventHandler = QuestEventHandler.private

-- Local Vars
local trackerLineWidth = 1
local trackerLineIndent = 1
local trackerSpaceBuffer = 1
local trackerFontSizeHeader = 1
local trackerFontSizeZone = 1
local trackerFontSizeQuest = 1
local trackerFontSizeObjective = 1

local activeQuestHeaderMarginLeft = 10
local questHeaderMarginLeft = activeQuestHeaderMarginLeft + 17
local objectiveMarginLeft = activeQuestHeaderMarginLeft + questHeaderMarginLeft + 5

local lastAQW = GetTime()
local durabilityInitialPosition

local trackedAchievementIds = {}
local isFirstRun = true

-- Forward declaration
local _OnTrackedQuestClick
local _RemoveQuestWatch
local _PlayerPosition, _QuestProximityTimer
local _GetDistanceToClosestObjective, _GetContinent

local function _UpdateLayout()
    trackerLineIndent = math.max(Questie.db.global.trackerFontSizeQuest, Questie.db.global.trackerFontSizeObjective)*2.75
    trackerSpaceBuffer = trackerFontSizeQuest+2+trackerFontSizeObjective

    trackerFontSizeHeader = Questie.db.global.trackerFontSizeHeader
    trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
    trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
    trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective
end

function QuestieTracker.Initialize()
    if QuestieTracker.started or (not Questie.db.global.trackerEnabled) then
        return
    end
    if (not Questie.db.char.TrackerHiddenQuests) then
        Questie.db.char.TrackerHiddenQuests = {}
    end
    if (not Questie.db.char.TrackerHiddenObjectives) then
        Questie.db.char.TrackerHiddenObjectives = {}
    end
    if (not Questie.db.char.TrackedQuests) then
        Questie.db.char.TrackedQuests = {}
    end
    if (not Questie.db.char.AutoUntrackedQuests) then
        Questie.db.char.AutoUntrackedQuests = {}
    end
    if (not Questie.db.char.collapsedZones) then
        Questie.db.char.collapsedZones = {}
    end
    if (not Questie.db.char.collapsedQuests) then
        Questie.db.char.collapsedQuests = {}
    end
    if (not Questie.db[Questie.db.global.questieTLoc].TrackerWidth) then
        Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
    end
    if (not Questie.db[Questie.db.global.questieTLoc].trackerSetpoint) then
        Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "TOPLEFT"
    end

    _UpdateLayout()

    -- Create tracker frames and assign them to a var
    _QuestieTracker.baseFrame = TrackerBaseFrame.Initialize(QuestieTracker.Update, QuestieTracker.MoveDurabilityFrame)
    TrackerMenu.Initialize(TrackerBaseFrame.Update, QuestieTracker.Untrack)

    _QuestieTracker.activeQuestsHeader = ActiveQuestsHeader.Initialize(_QuestieTracker.baseFrame, _OnTrackedQuestClick)

    _QuestieTracker.trackedQuestsFrame = _QuestieTracker:CreateTrackedQuestsFrame(_QuestieTracker.activeQuestsHeader)
    LinePool.Initialize(_QuestieTracker.trackedQuestsFrame, QuestieTracker.Untrack, QuestieTracker.Update)

    QuestieTracker.started = true
    FadeTicker.Initialize(_QuestieTracker.baseFrame)

    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    -- Attach durability frame to the tracker if shown and Sticky Durability Frame is enabled
    if not durabilityInitialPosition then
        durabilityInitialPosition = {DurabilityFrame:GetPoint()}
    end

    -- TODO: Do we really need to wait here? Especially 2 (!) seconds on the second timer seems quite late

    -- TODO: Yes. This ensures all other data we're getting from other addons and WoW is loaded. There are edge
    -- cases where Questie loads too fast before everything else is available.

    C_Timer.After(2.0, function()
        if Questie.db.global.stickyDurabilityFrame then
            -- This is the best way to not check 19238192398 events which might reset the position of the DurabilityFrame
            hooksecurefunc("UIParent_ManageFramePositions", QuestieTracker.MoveDurabilityFrame)

            -- Attach DurabilityFrame to tracker
            QuestieTracker:CheckDurabilityAlertStatus()
            QuestieTracker:MoveDurabilityFrame()
        end

        -- Prevent Dugi Guides from automatically un-tracking quests from the tracker
        if Questie.db.global.autoTrackQuests then
            if IsAddOnLoaded("DugisGuideViewerZ") then
                DugisGuideViewer:SetDB(false, 39)
            end
        end

        -- Quest Focus Feature
        if Questie.db.char.TrackerFocus then
            local focusType = type(Questie.db.char.TrackerFocus)
            if focusType == "number" then
                TrackerUtils:FocusQuest(Questie.db.char.TrackerFocus)
                QuestieQuest:ToggleNotes(false)
            elseif focusType == "string" then
                local questId, objectiveIndex = string.match(Questie.db.char.TrackerFocus, "(%d+) (%d+)")
                TrackerUtils:FocusObjective(questId, objectiveIndex)
                QuestieQuest:ToggleNotes(false)
            end
        end

        -- Hides tracker during a login or reloadUI
        if Questie.db.global.hideTrackerInDungeons and IsInInstance() then
            QuestieTracker:Collapse()
        end

        -- Assigns a local var with the players preferred setting so we can switch back to it
        if Questie.db.global.trackerHeaderEnabled ~= nil then
            QuestieTracker.currentHeaderEnabledSetting = Questie.db.global.trackerHeaderEnabled
        end

        -- If the player loots a "Quest Item" then this triggers a Tracker Update so the
        -- Quest Item Button can be switched on and appear in the tracker.
        Questie:RegisterEvent("CHAT_MSG_LOOT", function(_, text)
            local itemId = tonumber(string.match(text, "item:(%d+)"))
            if select(6, GetItemInfo(itemId)) == "Quest" then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker] Quest Item Detected (itemId): "..itemId)

                C_Timer.After(0.25, function()
                    _QuestEventHandler:UpdateAllQuests()
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker] QuestEventHandler:UpdateAllQuests()")
                end)

                QuestieCombatQueue:Queue(function()
                    C_Timer.After(0.5, function()
                        QuestieTracker:Update()
                        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker] Update()")
                    end)
                end)
            end
        end)

        -- Font's and cooldowns can occasionally not apply upon login.
        -- Tracked Achievements aren't always available upon login.
        trackedAchievementIds = {GetTrackedAchievements()}
        QuestieTracker:Update()
    end)
end

---@param frm ActiveQuestsHeader
local function _PositionTrackedQuestsFrame(frm, ActiveQuestsHeader)
    if Questie.db.global.trackerHeaderEnabled then
        if Questie.db.global.autoMoveHeader then
            if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
                -- Auto move tracker header to the bottom
                frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", 0, -(trackerFontSizeHeader))
            else
                -- Auto move tracker header to the top
                frm:SetPoint("TOPLEFT", ActiveQuestsHeader, "BOTTOMLEFT", 0, 0)
            end
        else
            -- No Automove. Tracker header always up top
            frm:SetPoint("TOPLEFT", ActiveQuestsHeader, "BOTTOMLEFT", 0, 0)
        end
    else
        -- No header. TrackedQuestsFrame always up top
        frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", 0, -(trackerFontSizeHeader))
    end
end

function _QuestieTracker:CreateTrackedQuestsFrame(ActiveQuestsHeader)
    local frm = CreateFrame("Frame", "Questie_TrackedQuests", _QuestieTracker.baseFrame)
    frm:SetWidth(165)
    frm:SetHeight(32)

    _PositionTrackedQuestsFrame(frm, ActiveQuestsHeader)

    frm.Update = function(self)
        self:ClearAllPoints()
        _PositionTrackedQuestsFrame(self, ActiveQuestsHeader)
    end

    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")

    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", FadeTicker.OnEnter)
    frm:SetScript("OnLeave", FadeTicker.OnLeave)

    frm:Hide()

    return frm
end

function QuestieTracker:ResetLocation()
    _QuestieTracker.activeQuestsHeader.trackedQuests:SetMode(1) -- maximized
    Questie.db.char.isTrackerExpanded = true
    Questie.db.char.AutoUntrackedQuests = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
    Questie.db.char.collapsedQuests = {}
    Questie.db.char.collapsedZones = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0

    _QuestieTracker.baseFrame:SetSize(280, 32)
    TrackerBaseFrame.SetSafePoint()

    QuestieTracker:Update()
end

function QuestieTracker:ResetDurabilityFrame()
    DurabilityFrame:ClearAllPoints()
    if durabilityInitialPosition then
        DurabilityFrame:SetPoint(unpack(durabilityInitialPosition))
    end
end

function QuestieTracker:MoveDurabilityFrame()
    if Questie.db.global.trackerEnabled and Questie.db.global.stickyDurabilityFrame and DurabilityFrame:IsShown() and QuestieTracker.started and Questie.db[Questie.db.global.questieTLoc].TrackerLocation ~= nil then
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "TOPLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" then
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("LEFT", _QuestieTracker.baseFrame, "TOPRIGHT", 0, -30)
        else
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("RIGHT", _QuestieTracker.baseFrame, "TOPLEFT", 0, -30)
        end
    else
        QuestieTracker:ResetDurabilityFrame()
    end
end

function QuestieTracker:CheckDurabilityAlertStatus()
    local numAlerts = 0
    for i = 1, #INVENTORY_ALERT_STATUS_SLOTS do
        if GetInventoryAlertStatus(i) > 0 then
            numAlerts = numAlerts + 1
        end
    end
    if numAlerts > 0 then
        DurabilityFrame:Show()
    end
end

function QuestieTracker:Enable()
    Questie.db.global.trackerEnabled = true

    -- may not have been initialized yet
    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    QuestieQuestTimers:HideBlizzardTimer()
    QuestieTracker.Initialize()
    QuestieTracker:MoveDurabilityFrame()
    QuestieTracker:Update()
end

function QuestieTracker:Disable()
    Questie.db.global.trackerEnabled = false

    if Questie.db.global.hookTracking then
        QuestieTracker:Unhook()
    end

    QuestieQuestTimers:ShowBlizzardTimer()
    QuestieTracker:ResetDurabilityFrame()
    QuestieTracker:Update()
end

function QuestieTracker:Toggle()
    if Questie.db.global.trackerEnabled then
        QuestieTracker:Disable()
    else
        QuestieTracker:Enable()
    end
end

function QuestieTracker:Collapse()
    if _QuestieTracker.activeQuestsHeader and _QuestieTracker.activeQuestsHeader.trackedQuests and Questie.db.char.isTrackerExpanded then
        _QuestieTracker.activeQuestsHeader.trackedQuests:Click()
        QuestieTracker:Update()
    end
end

function QuestieTracker:Expand()
    if _QuestieTracker.activeQuestsHeader and _QuestieTracker.activeQuestsHeader.trackedQuests and (not Questie.db.char.isTrackerExpanded) then
        _QuestieTracker.activeQuestsHeader.trackedQuests:Click()
        QuestieTracker:Update()
    end
end

local function _ReportErrorMessage(zoneOrtSort)
    Questie:Error("SortID: |cffffbf00"..zoneOrtSort.."|r was not found in the Database. Please file a bugreport at:")
    Questie:Error("|cff00bfffhttps://github.com/Questie/Questie/issues|r")
end

local questCompletePercent = {}

local function _GetSortedQuestIds()
    local sortedQuestIds = {}

    -- Update quest objectives
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if quest:IsComplete() == 1 or (not next(quest.Objectives)) then
                questCompletePercent[quest.Id] = 1
            else
                local percent = 0
                local count = 0
                for _, Objective in pairs(quest.Objectives) do
                    percent = percent + (Objective.Collected / Objective.Needed)
                    count = count + 1
                end
                percent = percent / count
                questCompletePercent[quest.Id] = percent
            end
            table.insert(sortedQuestIds, questId)
        end
    end

    -- Quests and objectives sort
    if Questie.db.global.trackerSortObjectives == "byComplete" then
        table.sort(sortedQuestIds, function(a, b)
            local vA, vB = questCompletePercent[a], questCompletePercent[b]
            if vA == vB then
                local qA = QuestieDB:GetQuest(a)
                local qB = QuestieDB:GetQuest(b)
                return qA and qB and qA.level < qB.level
            end
            return vB < vA
        end)

    elseif Questie.db.global.trackerSortObjectives == "byLevel" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level < qB.level
        end)

    elseif Questie.db.global.trackerSortObjectives == "byLevelReversed" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level > qB.level
        end)

    elseif Questie.db.global.trackerSortObjectives == "byZone" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            local qAZone, qBZone
            if qA.zoneOrSort > 0 then
                qAZone = TrackerUtils:GetZoneNameByID(qA.zoneOrSort)
            elseif qA.zoneOrSort < 0 then
                qAZone = TrackerUtils:GetCategoryNameByID(qA.zoneOrSort)
            else
                qAZone = tostring(qA.zoneOrSort)
                _ReportErrorMessage(qAZone)
            end

            if qB.zoneOrSort > 0 then
                qBZone = TrackerUtils:GetZoneNameByID(qB.zoneOrSort)
            elseif qB.zoneOrSort < 0 then
                qBZone = TrackerUtils:GetCategoryNameByID(qB.zoneOrSort)
            else
                qBZone = tostring(qB.zoneOrSort)
                _ReportErrorMessage(qBZone)
            end

            -- Sort by Zone then by Level to mimic QuestLog sorting
            if qAZone == qBZone then
                return qA.level < qB.level
            else
                if qAZone ~= nil and qBZone ~= nil then
                    return qAZone < qBZone
                else
                    return qAZone and qBZone
                end
            end
        end)

    elseif Questie.db.global.trackerSortObjectives == "byProximity" then
        local toSort = {}
        local continent = _GetContinent(C_Map.GetBestMapForUnit("player"))
        for _, questId in pairs(sortedQuestIds) do
            local sortData = {}
            sortData.questId = questId
            sortData.distance = _GetDistanceToClosestObjective(questId)
            sortData.q = QuestieDB:GetQuest(questId)
            local _, zone, _ = QuestieMap:GetNearestQuestSpawn(sortData.q)
            sortData.zone = zone
            sortData.continent = _GetContinent(ZoneDB:GetUiMapIdByAreaId(zone))
            toSort[questId] = sortData
        end
        local sorter = function(a, b)
            a = toSort[a]
            b = toSort[b]
            if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                if a.distance == b.distance then
                    return a.q and b.q and a.q.level < b.q.level;
                end
                if not a.distance and b.distance then
                    return false;
                elseif a.distance and not b.distance then
                    return true;
                end
                return a.distance < b.distance;
            elseif (continent == a.continent) and (continent ~= b.continent) then
                return true
            elseif (continent ~= a.continent) and (continent == b.continent) then
                return false
            end
        end
        table.sort(sortedQuestIds, sorter)

        if not _QuestProximityTimer then
            QuestieTracker.UpdateQuestProximityTimer(sortedQuestIds, sorter)
        end
    end

    return sortedQuestIds
end

function QuestieTracker:Update()
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: Update")
    if (not QuestieTracker.started) then
        return
    end

    -- Tracker has started but not enabled
    if (not Questie.db.global.trackerEnabled) then
        if _QuestieTracker.baseFrame and _QuestieTracker.baseFrame:IsShown() then
            QuestieCombatQueue:Queue(function()
                _QuestieTracker.baseFrame:Hide()
            end)
        end
        return
    end

    LinePool.ResetLinesForChange()

    -- Update primary frames and layout
    QuestieCombatQueue:Queue(function()
        TrackerBaseFrame.Update()
        _QuestieTracker.activeQuestsHeader:Update()
        _QuestieTracker.trackedQuestsFrame:Update()
    end)

    _UpdateLayout()
    LinePool.ResetButtonsForChange()

    -- The Tracker is not expanded. No use to calculate anything - just hide everything
    if (not Questie.db.char.isTrackerExpanded) then
        _QuestieTracker.trackedQuestsFrame:Hide()
        _QuestieTracker.baseFrame.sizer:SetAlpha(0)
        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
        _QuestieTracker.baseFrame:SetBackdropBorderColor(0, 0, 0, 0)
        TrackerBaseFrame.ShrinkToMinSize(1)
        LinePool.HideUnusedLines()

        QuestieCombatQueue:Queue(function()
            LinePool.HideUnusedButtons()
        end)

        _QuestieTracker.baseFrame:Show()

        local _, activeQuests = GetNumQuestLogEntries()
        local autoUnTrackedQuests = 0

        for _ in pairs (Questie.db.char.AutoUntrackedQuests) do
            autoUnTrackedQuests = autoUnTrackedQuests + 1
        end

        if Questie.db.global.autoTrackQuests and autoUnTrackedQuests == activeQuests then
            Questie.db.char.isTrackerExpanded = true
            QuestieTracker:Update()
        else
            return
        end
    end

    local order = _GetSortedQuestIds()

    if (Questie.db.global.trackerSortObjectives ~= "byProximity") and _QuestProximityTimer and (_QuestProximityTimer:IsCancelled() ~= "true") then
        _QuestProximityTimer:Cancel()
        _QuestProximityTimer = nil
    end

    local hasQuest = false
    local firstQuestInZone = false
    local zoneCheck
    local primaryButton = false
    local secondaryButton = false

    local line
    trackerLineWidth = 0 -- This is needed so the Tracker can also decrease its width

    -- Begin populating the tracker with quests
    for _, questId in pairs(order) do
        local quest = QuestieDB:GetQuest(questId)
        if not quest then break end
        local complete = quest:IsComplete()
        local zoneName

        -- Valid ZoneID
        if (quest.zoneOrSort) > 0 then
            zoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)

        -- Valid CategoryID
        elseif (quest.zoneOrSort) < 0 then
            zoneName = TrackerUtils:GetCategoryNameByID(quest.zoneOrSort)

        -- Probobly not in the Database. Assign zoneOrSort ID so Questie doesn't error
        else
            zoneName = tostring(quest.zoneOrSort)
            _ReportErrorMessage(zoneName)
        end

        -- Check for valid timed quests
        quest.timedBlizzardQuest = nil
        quest.trackTimedQuest = false
        local remainingSeconds = QuestieQuestTimers:GetRemainingTime(questId, nil, true)

        if remainingSeconds then
            if Questie.db.global.showBlizzardQuestTimer then
                QuestieQuestTimers:ShowBlizzardTimer()
                quest.timedBlizzardQuest = true
                quest.trackTimedQuest = false
            else
                QuestieQuestTimers:HideBlizzardTimer()
                quest.timedBlizzardQuest = false
                quest.trackTimedQuest = true
            end
        end

        if (complete ~= 1 or Questie.db.global.trackerShowCompleteQuests or quest.trackTimedQuest or quest.timedBlizzardQuest) and (Questie.db.global.autoTrackQuests and not Questie.db.char.AutoUntrackedQuests[questId]) or ((not Questie.db.global.autoTrackQuests) and Questie.db.char.TrackedQuests[questId]) then
            hasQuest = true

            -- Add zones
            if Questie.db.global.trackerSortObjectives == "byZone" then
                if zoneCheck ~= zoneName then
                    firstQuestInZone = true
                end

                if firstQuestInZone then
                    line = LinePool.GetNextLine()
                    if not line then break end -- stop populating the tracker

                    line:SetMode("zone")
                    line:SetZone(quest.zoneOrSort)
                    line.expandQuest:Hide()
                    line.expandZone:Show()

                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

                    if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                        line.expandZone:SetMode(0)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                    else
                        line.expandZone:SetMode(1)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
                    end

                    local zoneLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() + trackerFontSizeZone
                    line.label:SetWidth(zoneLineWidth)
                    line:SetWidth(zoneLineWidth)

                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth())

                    line.expandZone:ClearAllPoints()
                    line.expandZone:SetWidth(line.label:GetWidth())
                    line.expandZone:SetHeight(trackerFontSizeZone)
                    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)

                    line:SetVerticalPadding(4)
                    line:Show()
                    line.label:Show()

                    line.Quest = nil
                    line.Objective = nil

                    firstQuestInZone = false
                    zoneCheck = zoneName
                end
            end

            if (not Questie.db.char.collapsedZones[quest.zoneOrSort]) then
                local buttonSize = trackerFontSizeQuest+2+trackerFontSizeObjective

                -- Add quests
                line = LinePool.GetNextLine()
                if not line then break end -- stop populating the tracker

                line:SetMode("quest")
                line:SetOnClick("quest")
                line:SetQuest(quest)
                line:SetObjective(nil)
                line.expandZone:Hide()

                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", questHeaderMarginLeft, 0)
                line.expandQuest:SetPoint("RIGHT", line, "LEFT", questHeaderMarginLeft - 8, 0)

                local coloredQuestName
                if quest.trackTimedQuest or quest.timedBlizzardQuest then
                    coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.trackerShowQuestLevel, false, false)
                else
                    coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.trackerShowQuestLevel, Questie.db.global.collapseCompletedQuests, false)
                end

                line.label:SetText(coloredQuestName)

                local questLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - questHeaderMarginLeft + trackerFontSizeQuest
                line.label:SetWidth(questLineWidth)
                line:SetWidth(questLineWidth)

                if Questie.db.global.collapseCompletedQuests and (complete == 1 or complete == -1) and not ((quest.trackTimedQuest) or (quest.timedBlizzardQuest)) then
                    if not Questie.db.char.collapsedQuests[quest.Id] then
                        Questie.db.char.collapsedQuests[quest.Id] = true
                        line.expandQuest:SetMode(1)
                    end
                else
                    if Questie.db.char.collapsedQuests[quest.Id] then
                        line.expandQuest:SetMode(0)
                    else
                        line.expandQuest:SetMode(1)
                    end
                end

                if Questie.db.global.enableTooltipsQuestID then
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerFontSizeQuest/2)
                else
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth())
                end

                line:SetVerticalPadding(2)

                -- Adds the primary Quest Item button
                if (quest.sourceItemId or (quest.requiredSourceItems and #quest.requiredSourceItems == 1)) and questCompletePercent[quest.Id] ~= 1 then
                    local fontSizeCompare = trackerFontSizeQuest + trackerFontSizeObjective + Questie.db.global.trackerQuestPadding -- hack to allow refreshing when changing font size

                    local button = LinePool.GetNextItemButton()

                    if quest.sourceItemId then
                        button.itemID = quest.sourceItemId

                    elseif type(quest.requiredSourceItems) == "table" and #quest.requiredSourceItems == 1 then
                        button.itemID = quest.requiredSourceItems[1]
                    end

                    button.fontSize = fontSizeCompare
                    button.line = line

                    if button:SetItem(quest, "primary", buttonSize) then
                        local height = 0
                        local frame = button.line

                        while frame and frame ~= _QuestieTracker.trackedQuestsFrame do
                            local _, parent, _, _, yOff = frame:GetPoint()
                            height = height - (frame:GetHeight() - yOff)
                            frame = parent
                        end

                        button.line.expandQuest:Hide()

                        button:SetPoint("TOPLEFT", button.line, "TOPLEFT", 0, 0)
                        button:SetParent(button.line)
                        button:Show()
                        primaryButton = true

                        if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
                            button:SetParent(UIParent)
                            button:Hide()
                        end
                    else
                        button.line.expandQuest:Show()
                        button:SetParent(UIParent)
                        button:Hide()
                    end

                    line.button = button

                elseif Questie.db.global.collapseCompletedQuests and (complete == 1 or complete == -1) then
                    line.expandQuest:Hide()
                else
                    line.expandQuest:Show()
                end

                -- Adds the secondary Quest Item button (if present)
                if (primaryButton and quest.requiredSourceItems and #quest.requiredSourceItems > 1) and questCompletePercent[quest.Id] ~= 1 then
                    local fontSizeCompare = trackerFontSizeQuest + trackerFontSizeObjective + Questie.db.global.trackerQuestPadding -- hack to allow refreshing when changing font size

                    if type(quest.requiredSourceItems) == "table" then
                        for _, itemId in pairs(quest.requiredSourceItems) do
                            if itemId and itemId ~= quest.sourceItemId and QuestieDB:GetItem(itemId).class == 12 then
                                local altButton = LinePool.GetNextItemButton()
                                altButton.itemID = itemId
                                altButton.fontSize = fontSizeCompare
                                altButton.line = line

                                if altButton:SetItem(quest, "secondary", buttonSize) then
                                    local height = 0
                                    local frame = altButton.line

                                    while frame and frame ~= _QuestieTracker.trackedQuestsFrame do
                                        local _, parent, _, _, yOff = frame:GetPoint()
                                        height = height - (frame:GetHeight() - yOff)
                                        frame = parent
                                    end

                                    altButton.line.label:ClearAllPoints()
                                    altButton.line.label:SetPoint("TOPLEFT", altButton.line, "TOPLEFT", questHeaderMarginLeft * 2 + 2, 0)
                                    altButton:SetPoint("TOPLEFT", altButton.line, "TOPLEFT", buttonSize + 2, 0)
                                    altButton:SetParent(altButton.line)
                                    altButton:Show()
                                    secondaryButton = true

                                    if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
                                        altButton:SetParent(UIParent)
                                        altButton:Hide()
                                    end
                                else
                                    altButton:SetParent(UIParent)
                                    altButton:Hide()
                                end

                                line.altButton = altButton
                            end
                        end
                    end
                end

                line:Show()
                line.label:Show()

                -- Add quest objectives (if applicable)
                if (not Questie.db.char.collapsedQuests[quest.Id]) then

                    -- Add quest timers (if applicable)
                    if quest.trackTimedQuest and (not quest.timedBlizzardQuest) then
                        line = LinePool.GetNextLine()
                        if not line then break end -- stop populating the tracker

                        line:SetMode("objective")
                        line:SetOnClick("quest")
                        line:SetQuest(quest)
                        line.expandZone:Hide()
                        line.expandQuest:Hide()

                        line.label:ClearAllPoints()
                        if secondaryButton then
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft + buttonSize, 0)
                        else
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
                        end

                        local timeRemaining = QuestieQuestTimers:GetRemainingTime(questId, line, false)
                        if timeRemaining then
                            line.label:SetText(Questie:Colorize(timeRemaining, "blue"))
                        else
                            line.label:SetText(Questie:Colorize("0 Seconds", "blue"))
                        end

                        line.label:SetHeight(trackerFontSizeObjective * 1.3)

                        local timerLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft + trackerFontSizeObjective
                        line.label:SetWidth(timerLineWidth)
                        line:SetWidth(timerLineWidth)

                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12)

                        line:SetVerticalPadding(2)
                        line:Show()
                        line.label:Show()
                    end

                    if complete == 0 then
                        for _, objective in pairs(quest.Objectives) do
                            if (not Questie.db.global.hideCompletedQuestObjectives or #quest.Objectives == 1) or (objective.Needed ~= objective.Collected) then
                                line = LinePool.GetNextLine()
                                if not line then break end -- stop populating the tracker

                                line:SetMode("objective")
                                line:SetOnClick("quest")
                                line:SetQuest(quest)
                                line:SetObjective(objective)
                                line.expandZone:Hide()
                                line.expandQuest:Hide()

                                line.label:ClearAllPoints()
                                if secondaryButton then
                                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft + buttonSize, 0)
                                else
                                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
                                end

                                local objDesc = objective.Description:gsub("%.", "")
                                if objective.Completed ~= true then
                                    local lineEnding = ""
                                    lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)

                                    line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding)

                                    if line.label:GetUnboundedStringWidth() > 170 then
                                        local objSpltText, objSpltFind, objTextLength
                                        objTextLength = strlenutf8(objDesc)
                                        objSpltFind = strfind(objDesc, "%s", objTextLength/2)
                                        objSpltText = ""..strsub(objDesc, 1, objSpltFind).."\n"..strsub(objDesc, objSpltFind+1, objTextLength)..""
                                        line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objSpltText .. ": " .. lineEnding)
                                        line.label:SetHeight(trackerFontSizeObjective * 3)
                                    end

                                else
                                    local questIndex = GetQuestLogIndexByID(quest.Id)
                                    local completeText = GetQuestLogCompletionText(questIndex)

                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected=1, Needed=1}) .. completeText)

                                    if line.label:GetUnboundedStringWidth() > 170 then
                                        local objSpltText, objSpltFind, objTextLength
                                        objTextLength = strlenutf8(completeText)
                                        objSpltFind = strfind(completeText, "%s", objTextLength/2)
                                        objSpltText = ""..strsub(completeText, 1, objSpltFind).."\n"..strsub(completeText, objSpltFind+1, objTextLength)..""
                                        line.label:SetText(QuestieLib:GetRGBForObjective({Collected=1, Needed=1}) .. objSpltText)
                                        line.label:SetHeight(trackerFontSizeObjective * 3)
                                    end

                                    QuestieQuest:AddFinisher(quest)
                                end

                                local notDoneObjLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft + trackerFontSizeObjective
                                line.label:SetWidth(notDoneObjLineWidth)
                                line:SetWidth(notDoneObjLineWidth)

                                if secondaryButton then
                                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12 + buttonSize)
                                else
                                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12)
                                end

                                line:SetVerticalPadding(1)
                                line:Show()
                                line.label:Show()
                            end
                        end

                    -- Tags quest as either complete or failed so as to always have at least one objective.

                    -- TODO: change tags to reflect NPC to turn a quest into or in the case of a failure
                    -- which NPC to obtain the quest from again...

                    -- TODO: Why? The Quest Tracker only tracks a quests progress, nothing more. Besides,
                    -- Questie already informs the user where to turn in the quest. In the case of a failure,
                    -- the quest is marked on the map as available again.
                    elseif (complete == 1 and (not quest.trackTimedQuest)) or complete == -1 or quest.Completed == true then
                        line = LinePool.GetNextLine()
                        if not line then break end -- stop populating the tracker

                        line:SetMode("objective")
                        line:SetOnClick("quest")
                        line:SetQuest(quest)
                        line.expandZone:Hide()
                        line.expandQuest:Hide()

                        line.label:ClearAllPoints()
                        if secondaryButton then
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft + buttonSize, 0)
                        else
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
                        end

                        if (complete == 1 and (not quest.timedBlizzardQuest)) then
                            line.label:SetText(Questie:Colorize(l10n("Quest Complete!"), "green"))
                        elseif (complete == 1 and quest.timedBlizzardQuest) then
                            line.label:SetText(Questie:Colorize(l10n("Blizzard Timer Active!"), "blue"))
                        elseif (complete == -1) then
                            line.label:SetText(Questie:Colorize(l10n("Quest Failed!"), "red"))
                        end

                        local doneObjLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft + trackerFontSizeObjective
                        line.label:SetWidth(doneObjLineWidth)
                        line:SetWidth(doneObjLineWidth)

                        if secondaryButton then
                            trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12 + buttonSize)
                        else
                            trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12)
                        end

                        line:SetVerticalPadding(1)
                        line:Show()
                        line.label:Show()
                    end
                else
                    QuestieQuestTimers:GetRemainingTime(questId, nil, true)
                end

                if not line then
                    line = LinePool.GetLastLine()
                end

                if line.label:GetHeight() > trackerFontSizeObjective + .015 then
                    line:SetVerticalPadding(trackerFontSizeObjective + Questie.db.global.trackerQuestPadding)
                else
                    line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
                end
            end
            primaryButton = false
            secondaryButton = false
        end
    end

    -- Begin populating the tracker with tracked achievements - Note: We're limited to tracking only 10 Achievements at a time.
    -- For all intents and purposes at a code level we're going to treat each tracked Achievement the same way we treat and add Quests. This loop is
    -- necessary to keep separate from the above tracked Quests loop so we can place all tracked Achievements into it's own "Zone" called Achievements.
    -- This will force Achievements to always appear at the bottom of the tracker. Obviously it'll show at the top if there are no quests being tracked.
    trackedAchievementIds = {}
    trackedAchievementIds = {GetTrackedAchievements()}
    local firstAchieveInZone = false

    for trackedId = 1, #trackedAchievementIds do
        local achieveId, achieveName, _, _, _, _, _, achieveDescription, _, _, _, _, achieveComplete, _, _ = GetAchievementInfo(trackedAchievementIds[trackedId])
        local numCriteria = GetAchievementNumCriteria(trackedAchievementIds[trackedId])
        local zoneName = "Achievements"

        local achieve = {
            Id = achieveId,
            Name = achieveName,
            Description = achieveDescription
        }

        if achieveId and (not achieveComplete) then
            hasQuest = true

            -- Add achievement zone
            if zoneCheck ~= zoneName then
                firstAchieveInZone = true
            end

            if firstAchieveInZone then
                line = LinePool.GetNextLine()
                if not line then break end -- stop populating the tracker

                line:SetMode("zone")
                line:SetZone(zoneName)
                line.expandQuest:Hide()
                line.expandZone:Show()

                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

                if Questie.db.char.collapsedZones[zoneName] then
                    line.expandZone:SetMode(0)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                else
                    line.expandZone:SetMode(1)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
                end

                local achieveZoneLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() + trackerFontSizeZone
                line.label:SetWidth(achieveZoneLineWidth)
                line:SetWidth(achieveZoneLineWidth)

                trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth())

                line.expandZone:ClearAllPoints()
                line.expandZone:SetWidth(line.label:GetWidth())
                line.expandZone:SetHeight(trackerFontSizeZone)
                line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)

                line:SetVerticalPadding(4)
                line:Show()
                line.label:Show()

                line.Quest = nil
                line.Objective = nil

                firstAchieveInZone = false
                zoneCheck = zoneName
            end

            if (not Questie.db.char.collapsedZones[zoneName]) then

                -- Add achievements
                line = LinePool.GetNextLine()
                if not line then break end -- stop populating the tracker

                line:SetMode("achieve")
                line:SetOnClick("achieve")
                line:SetQuest(achieve)
                line:SetObjective(nil)
                line.expandZone:Hide()
                line.expandQuest:Show()

                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", questHeaderMarginLeft, 0)
                line.expandQuest:SetPoint("RIGHT", line, "LEFT", questHeaderMarginLeft - 8, 0)

                line.label:SetText("|cFFFFFF00" .. achieve.Name .. "|r")

                local achieveLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - questHeaderMarginLeft + trackerFontSizeQuest
                line.label:SetWidth(achieveLineWidth)
                line:SetWidth(achieveLineWidth)

                if Questie.db.char.collapsedQuests[achieve.Id] then
                    line.expandQuest:SetMode(0)
                else
                    line.expandQuest:SetMode(1)
                end

                trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth())

                line:SetVerticalPadding(3)
                line:Show()
                line.label:Show()

                -- Add achievement objectives (if applicable)
                if (not Questie.db.char.collapsedQuests[achieve.Id]) then

                    -- Achievements with one objective
                    if numCriteria == 0 then
                        line = LinePool.GetNextLine()
                        if not line then break end -- stop populating the tracker
                        line:SetMode("objective")
                        line:SetOnClick("achieve")
                        line:SetQuest(achieve)
                        line:SetObjective("objective")
                        line.expandZone:Hide()
                        line.expandQuest:Hide()

                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                        local objDesc = achieve.Description:gsub("%.", "")
                        line.label:SetText(QuestieLib:GetRGBForObjective({Collected=0, Needed=1}) .. objDesc)

                        if line.label:GetUnboundedStringWidth() > 170 then
                            local objSpltDesc, objSpltFind, objDescLength
                            objDescLength = strlenutf8(objDesc)
                            objSpltFind = strfind(objDesc, "%s", objDescLength/2)
                            objSpltDesc = ""..strsub(objDesc, 1, objSpltFind).."\n"..strsub(objDesc, objSpltFind+1, objDescLength)..""
                            line.label:SetText(QuestieLib:GetRGBForObjective({Collected=0, Needed=1}) .. objSpltDesc)
                            line.label:SetHeight(trackerFontSizeObjective * 3)
                        end

                        local achieveOneObjLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft + trackerFontSizeObjective
                        line.label:SetWidth(achieveOneObjLineWidth)
                        line:SetWidth(achieveOneObjLineWidth)

                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12)

                        line:SetVerticalPadding(1)
                        line:Show()
                        line.label:Show()
                    end

                    -- Achievements with more than one objective
                    for objCriteria = 1, numCriteria do
                        local criteriaString, _, completed, quantityProgress, quantityNeeded, _, _, refId, quantityString = GetAchievementCriteriaInfo(achieve.Id, objCriteria)
                        if ((Questie.db.global.hideCompletedAchieveObjectives) and (not completed)) or (not Questie.db.global.hideCompletedAchieveObjectives) then
                            line = LinePool.GetNextLine()
                            if not line then break end -- stop populating the tracker
                            line:SetMode("objective")
                            line:SetOnClick("achieve")

                            local objId
                            if refId and select(2,GetAchievementInfo(refId)) == criteriaString and ((GetAchievementInfo(refId) and refId ~= 0) or (refId > 0 and (not QuestieDB:GetQuest(refId)))) then
                                objId = refId
                            else
                                objId = achieve
                            end

                            line:SetQuest(objId)
                            line:SetObjective("objective")
                            line.expandZone:Hide()
                            line.expandQuest:Hide()

                            line.label:ClearAllPoints()
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                            if (criteriaString == "") then
                                criteriaString = achieve.Description
                            end

                            local objDesc = criteriaString:gsub("%.", "")
                            local graphicalQuantity = false
                            if (not completed) then
                                if string.find(quantityString, "|") then
                                    quantityString = quantityString
                                    graphicalQuantity = true
                                else
                                    quantityString = quantityProgress .. "/" .. quantityNeeded
                                end

                                local lineEnding = tostring(quantityString)
                                if lineEnding == "0" then
                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. objDesc)
                                else
                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. objDesc .. ": " .. lineEnding)
                                end

                                if line.label:GetUnboundedStringWidth() > 170 and graphicalQuantity then
                                    if lineEnding == "0" then
                                        line.label:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. objDesc)
                                    else
                                        line.label:SetText(QuestieLib:GetRGBForObjective({Collected=quantityProgress, Needed=quantityNeeded}) .. objDesc .. ":\n       " .. lineEnding)
                                    end
                                    line.label:SetHeight(trackerFontSizeObjective * 3)
                                end
                            else
                                line.label:SetText(QuestieLib:GetRGBForObjective({Collected=1, Needed=1}) .. objDesc)
                            end

                            local achieveLotsObjLineWidth = trackerSpaceBuffer + _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft + trackerFontSizeObjective
                            line.label:SetWidth(achieveLotsObjLineWidth)
                            line:SetWidth(achieveLotsObjLineWidth)

                            trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + 12)

                            if line.label:GetHeight() > trackerFontSizeObjective + .015 then
                                line:SetVerticalPadding(trackerFontSizeObjective + Questie.db.global.trackerQuestPadding)
                            else
                                line:SetVerticalPadding(1)
                            end

                            line:Show()
                            line.label:Show()
                        end
                    end
                end

                if not line then
                    line = LinePool.GetLastLine()
                end

                if line.label:GetHeight() > trackerFontSizeObjective + .015 then
                    line:SetVerticalPadding(trackerFontSizeObjective + Questie.db.global.trackerQuestPadding)
                else
                    line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
                end
            end
        end
    end

    -- TODO: Is this needed?

    -- TODO: Yes. This is a safety check to make sure we have the last line selected so the tracker can be properly trimmed.
    if not line then
        line = LinePool.GetLastLine()
    end

    -- Hide unused lines
    LinePool.HideUnusedLines()

    -- Hide unused item buttons
    QuestieCombatQueue:Queue(function()
        LinePool.HideUnusedButtons()
    end)

    if line then
        local activeQuestsHeaderWidth = trackerSpaceBuffer + _QuestieTracker.activeQuestsHeader:GetWidth() + trackerFontSizeHeader
        local trackerVarsCombined = trackerLineWidth + trackerSpaceBuffer + trackerLineIndent
        TrackerBaseFrame.UpdateWidth(activeQuestsHeaderWidth, trackerVarsCombined)

        -- Trims the bottom of the tracker (overall height) based on min/max'd zones and/or quests
        local trackerBottomPadding
        if Questie.db.global.trackerHeaderEnabled and Questie.db.global.autoMoveHeader and Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
            trackerBottomPadding = trackerFontSizeHeader+8
        else
            trackerBottomPadding = 0
        end

        if line:IsVisible() or LinePool.IsFirstLine() then
            if LinePool.IsFirstLine() then
                _QuestieTracker.baseFrame:SetHeight( (_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + 14) - (Questie.db.global.trackerQuestPadding + 2) + trackerBottomPadding )
            end
        else
            _QuestieTracker.baseFrame:SetHeight( (_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + trackerFontSizeObjective - 2) + trackerBottomPadding )
        end

        QuestieCompat.SetResizeBounds(_QuestieTracker.baseFrame, activeQuestsHeaderWidth, _QuestieTracker.baseFrame:GetHeight(), GetScreenWidth()/2, GetScreenHeight())
        _QuestieTracker.trackedQuestsFrame:Show()
    end

    -- First run clean up
    if isFirstRun then
        _QuestieTracker.baseFrame:Hide()
        for questId in pairs (QuestiePlayer.currentQuestlog) do
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                if Questie.db.char.TrackerHiddenQuests[questId] then
                    quest.HideIcons = true
                end
                if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then -- quest focus
                    TrackerUtils:FocusQuest(quest.Id)
                end
                for _, objective in pairs(quest.Objectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                    end
                    if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                        TrackerUtils:FocusObjective(quest.Id, objective.Index)
                    end
                end

                for _, objective in pairs(quest.SpecialObjectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                    end
                    if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                        TrackerUtils:FocusObjective(quest.Id, objective.Index)
                    end
                end
            end
        end
        isFirstRun = nil
        C_Timer.After(2.0, function()
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)
    else
        _QuestieTracker.baseFrame:Show()
    end

    if (not hasQuest) then
        if Questie.db.global.alwaysShowTracker then
            _QuestieTracker.trackedQuestsFrame:Hide()
            _QuestieTracker.baseFrame.sizer:SetAlpha(0)
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
            _QuestieTracker.baseFrame:SetBackdropBorderColor(0, 0, 0, 0)
            TrackerBaseFrame.ShrinkToMinSize(1)
            LinePool.HideUnusedLines()

            QuestieCombatQueue:Queue(function()
                LinePool.HideUnusedButtons()
            end)

            if (not QuestieTracker.currentHeaderEnabledSetting) then
                Questie.db.global.trackerHeaderEnabled = true
            end
            _QuestieTracker.baseFrame:Show()
        else
            _QuestieTracker.baseFrame:Hide()
        end
    else
        if Questie.db.global.trackerBackdropEnabled then
            if Questie.db.global.trackerBorderEnabled then
                if not Questie.db.global.trackerBackdropFader then
                    if Questie.db.global.alwaysShowTracker then
                        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
                        Questie.db.global.trackerHeaderEnabled = QuestieTracker.currentHeaderEnabledSetting
                    end
                end
            end
        end
        _QuestieTracker.baseFrame:Show()
    end
end

function QuestieTracker.Untrack(quest)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: Untrack")
    QuestieTracker:UntrackQuestId(quest.Id)
end

function QuestieTracker:Unhook()
    if (not QuestieTracker._alreadyHooked) then
        return
    end

    QuestieTracker._disableHooks = true
    if QuestieTracker._IsQuestWatched then
        IsQuestWatched = QuestieTracker._IsQuestWatched
        GetNumQuestWatches = QuestieTracker._GetNumQuestWatches
    end
    _QuestieTracker._alreadyHooked = nil
    WatchFrame:Show()
end

function QuestieTracker:HookBaseTracker()
    if _QuestieTracker._alreadyHooked then
        return
    end
    QuestieTracker._disableHooks = nil

    if not QuestieTracker._alreadyHookedSecure then
        if AutoQuestWatch_Insert then
            hooksecurefunc("AutoQuestWatch_Insert", function(index, watchTimer)
                QuestieTracker:AQW_Insert(index, watchTimer)
            end)
        end
        hooksecurefunc("AddQuestWatch", function(index, watchTimer)
            QuestieTracker:AQW_Insert(index, watchTimer)
        end)
        hooksecurefunc("RemoveQuestWatch", _RemoveQuestWatch)

        -- totally prevent the blizzard tracker frame from showing (BAD CODE, shouldn't be needed but some have had trouble)
        WatchFrame:HookScript("OnShow", function(self)
            if QuestieTracker._disableHooks then
                return
            end
            if Questie.db.global.showBlizzardQuestTimer then
                self:Show()
            else
                self:Hide()
            end
        end)
        QuestieTracker._alreadyHookedSecure = true
    end

    if not QuestieTracker._IsQuestWatched then
        QuestieTracker._IsQuestWatched = IsQuestWatched
        QuestieTracker._GetNumQuestWatches = GetNumQuestWatches
    end

    -- this is probably bad
    IsQuestWatched = function(index)
        local questId = select(8, GetQuestLogTitle(index));
        if questId == 0 then
            -- When an objective progresses in TBC "index" is the questId, but when a quest is manually added to the quest watch
            -- (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
            questId = index;
        end
        if not Questie.db.global.autoTrackQuests then
            return Questie.db.char.TrackedQuests[questId or -1]
        else
            return questId and QuestiePlayer.currentQuestlog[questId] and (not Questie.db.char.AutoUntrackedQuests[questId])
        end
    end

    GetNumQuestWatches = function()
        return 0
    end

    if Questie.db.global.showBlizzardQuestTimer then
        WatchFrame:Show()
    else
        WatchFrame:Hide()
    end

    QuestieTracker._alreadyHooked = true
end

_OnTrackedQuestClick = function(self)
    if InCombatLockdown() then
        return
    end
    if self.mode == 1 then
        self:SetMode(0)
        Questie.db.char.isTrackerExpanded = false
    else
        self:SetMode(1)
        Questie.db.char.isTrackerExpanded = true

        if not Questie.db.global.sizerHidden then
            _QuestieTracker.baseFrame.sizer:SetAlpha(1)
        end

        if Questie.db.global.trackerBackdropEnabled then
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)

            if Questie.db.global.trackerBorderEnabled then
                _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
            else
                _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
            end
        else
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end
    end
    if Questie.db.global.stickyDurabilityFrame then
        QuestieTracker:CheckDurabilityAlertStatus()
        QuestieTracker:MoveDurabilityFrame()
    end
    QuestieTracker:Update()
end

function QuestieTracker:RemoveQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: RemoveQuest")
    if Questie.db.char.collapsedQuests then -- if because this function is called even Tracker isn't initialized
        Questie.db.char.collapsedQuests[questId] = nil  -- forget the collapsed/expanded state
    end
    if Questie.db.char.TrackerFocus then
        if (type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == questId)
        or (type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus:sub(1, #tostring(questId)) == tostring(questId)) then
            TrackerUtils:UnFocus()
            QuestieQuest:ToggleNotes(true)
        end
    end
end

local hexTable = {
    "00","11","22","33","44","55","66","77","88","99","AA","BB","CC","DD","EE","FF"
}

function _QuestieTracker:PrintProgressColor(percent, text)
    local hexGreen = hexTable[5 + math.floor(percent * 10)]
    local hexRed = hexTable[8 + math.floor((1 - percent) * 6)]
    local hexBlue = hexTable[4 + math.floor(percent * 6)]

    return "|cFF"..hexRed..hexGreen..hexBlue..text.."|r"
end

_RemoveQuestWatch = function(index, isQuestie)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: RemoveQuestWatch")

    if QuestieTracker._disableHooks then
        return
    end

    if not isQuestie then
        local questId = select(8, GetQuestLogTitle(index))

        if questId == 0 then
            -- When an objective progresses in TBC "index" is the questId, but when a quest is manually removed from
            --  the quest watch (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
            questId = index;
        end

        if questId then
            QuestieTracker:UntrackQuestId(questId)
        end
    end
end

function QuestieTracker:UntrackQuestId(questId)
    if not Questie.db.global.autoTrackQuests then
        Questie.db.char.TrackedQuests[questId] = nil
    else
        Questie.db.char.AutoUntrackedQuests[questId] = true
    end

    if Questie.db.char.hideUntrackedQuestsMapIcons then
        -- Remove quest Icons from map when un-tracking quest.
        -- Also reset caches of spawned Icons so re-tracking works.
        QuestieMap:UnloadQuestFrames(questId)
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            for _, objective in pairs(quest.Objectives) do
                objective.AlreadySpawned = {}
            end
            for _, objective in pairs(quest.SpecialObjectives) do
                objective.AlreadySpawned = {}
            end
        end
    end

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

function QuestieTracker:AQW_Insert(index, expire)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: AQW_Insert")
    if (not Questie.db.global.trackerEnabled) then
        return
    end

    if index == 0 then
        return;
    end

    local now = GetTime()
    if index and index == QuestieTracker._last_aqw and (now - lastAQW) < 0.1 then
        -- this fixes double calling due to AQW+AQW_Insert (QuestGuru fix)
        return
    end

    lastAQW = now
    QuestieTracker._last_aqw = index
    RemoveQuestWatch(index, true) -- prevent hitting 5 quest watch limit

    local questId = select(8, GetQuestLogTitle(index))
    if questId == 0 then
        -- When an objective progresses in TBC "index" is the questId, but when a quest is manually added to the quest watch
        -- (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
        questId = index;
    end

    if questId > 0 then
        if not Questie.db.global.autoTrackQuests then
            if Questie.db.char.TrackedQuests[questId] then
                Questie.db.char.TrackedQuests[questId] = nil
            else
                Questie.db.char.TrackedQuests[questId] = true
            end
        else
            if Questie.db.char.AutoUntrackedQuests[questId] then
                Questie.db.char.AutoUntrackedQuests[questId] = nil
            elseif IsShiftKeyDown() and (QuestLogFrame:IsShown() or (QuestLogExFrame and QuestLogExFrame:IsShown())) then--hack
                Questie.db.char.AutoUntrackedQuests[questId] = true
            end
        end

        -- Make sure quests or zones (re)added to the tracker isn't in a minimized state
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            local zoneId = quest.zoneOrSort

            if Questie.db.char.collapsedQuests[questId] == true then
                Questie.db.char.collapsedQuests[questId] = nil
            end

            if Questie.db.char.collapsedZones[zoneId] == true then
                Questie.db.char.collapsedZones[zoneId] = nil
            end
        else
            Questie:Error("Missing quest " .. tostring(questId) .. "," .. tostring(expire) .. " during tracker update")
        end
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
            if Questie.db.char.hideUntrackedQuestsMapIcons then
                -- Quest had its Icons removed, paint them again
                QuestieQuest:PopulateObjectiveNotes(quest)
            end
        end)
    end
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

local function _GetWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapId = C_Map.GetBestMapForUnit("player");

    if (not uiMapId) then
        return nil;
    end

    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player");
    if (not mapPosition) or (not mapPosition.x) then
        return nil
    end
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, mapPosition);

    return worldPosition;
end

local function _GetDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

_GetDistanceToClosestObjective = function(questId)
    -- main function for proximity sorting
    local player = _GetWorldPlayerPosition();

    if (not player) then
        return nil
    end

    local coordinates = {};
    local quest = QuestieDB:GetQuest(questId);

    if (not quest) then
        return nil
    end

    local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)

    if (not spawn) or (not zone) or (not name) then
        return nil
    end

    local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
    if not uiMapId then
        return nil
    end
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, {
        x = spawn[1] / 100,
        y = spawn[2] / 100
    });

    tinsert(coordinates, {
        x = worldPosition.x,
        y = worldPosition.y
    });

    if (not coordinates) then
        return nil
    end

    local closestDistance;
    for _, _ in pairs(coordinates) do
        local distance = _GetDistance(player.x, player.y, worldPosition.x, worldPosition.y);
        if (not closestDistance) or (distance < closestDistance) then
            closestDistance = distance;
        end
    end

    return closestDistance;
end

_GetContinent = function(uiMapId)
    if (not uiMapId) then
        return
    end

    local useUiMapId = uiMapId
    local mapInfo = C_Map.GetMapInfo(useUiMapId)
    while mapInfo and mapInfo.mapType ~= 2 and mapInfo.parentMapID ~= useUiMapId do
        useUiMapId = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(useUiMapId)
    end
    if mapInfo ~= nil then
        return mapInfo.name
    else
        return "UNKNOWN"
    end
end

function QuestieTracker.UpdateQuestProximityTimer(sortedQuestIds, sorter)
    -- Check location often and update if you've moved
    C_Timer.After(3.0, function()
        _QuestProximityTimer = C_Timer.NewTicker(5.0, function()
            local position = _GetWorldPlayerPosition();
            if position then
                local distance = _PlayerPosition and _GetDistance(position.x, position.y, _PlayerPosition.x, _PlayerPosition.y);
                if not distance or distance > 0.01 then
                    _PlayerPosition = position;
                    --QuestieTracker:Update()
                    local orderCopy = {}
                    for index, val in pairs(sortedQuestIds) do
                        orderCopy[index] = val
                    end
                    table.sort(orderCopy, sorter)
                    for index, val in pairs(sortedQuestIds) do
                        if orderCopy[index] ~= val then
                            -- the order has changed
                            QuestieTracker:Update()
                            break;
                        end
                    end
                end
            end
        end)
    end)
end
