---@class QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerHeaderFrame
local TrackerHeaderFrame = QuestieLoader:ImportModule("TrackerHeaderFrame")
---@type TrackerQuestFrame
local TrackerQuestFrame = QuestieLoader:ImportModule("TrackerQuestFrame")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestEventHandler
local QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
local _QuestEventHandler = QuestEventHandler.private
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LSM30 = LibStub("LibSharedMedia-3.0")

-- Local Vars
local trackerLineWidth = 0
local trackerMinLineWidth = 275
local trackerMarginRight = 20
local trackerMarginLeft = 10
local lastAQW = GetTime()
local lastTrackerUpdate = GetTime()
local lastAchieveId = GetTime()
local durabilityInitialPosition = { DurabilityFrame:GetPoint() }
local questsWatched = GetNumQuestWatches()

local trackedAchievements
local trackedAchievementIds

if Questie.IsWotlk then
    trackedAchievements = { GetTrackedAchievements() }
    trackedAchievementIds = {}
end

local isFirstRun = true
local allowFormattingUpdate = false
local trackerBaseFrame, trackerHeaderFrame, trackerQuestFrame
local QuestLogFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame

function QuestieTracker.Initialize()
    if QuestieTracker.started or (not Questie.db.char.trackerEnabled) then
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
    if (not Questie.db.char.minAllQuestsInZone) then
        Questie.db.char.minAllQuestsInZone = {}
    end
    if (not Questie.db.char.collapsedQuests) then
        Questie.db.char.collapsedQuests = {}
    end
    if (not Questie.db.char.trackedAchievementIds) then
        Questie.db.char.trackedAchievementIds = {}
    end
    if (not Questie.db[Questie.db.global.questieTLoc].TrackerWidth) then
        Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
    end
    if (not Questie.db[Questie.db.global.questieTLoc].TrackerHeight) then
        Questie.db[Questie.db.global.questieTLoc].TrackerHeight = 0
    end
    if (not Questie.db[Questie.db.global.questieTLoc].trackerSetpoint) then
        Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "TOPLEFT"
    end

    -- Initialize tracker frames
    trackerBaseFrame = TrackerBaseFrame.Initialize()
    trackerHeaderFrame = TrackerHeaderFrame.Initialize(trackerBaseFrame)
    trackerQuestFrame = TrackerQuestFrame.Initialize(trackerBaseFrame, trackerHeaderFrame)

    -- Initialize tracker functions
    TrackerLinePool.Initialize(trackerQuestFrame)
    TrackerFadeTicker.Initialize(trackerBaseFrame)
    QuestieTracker.started = true

    -- Initialize hooks
    QuestieTracker:HookBaseTracker()

    -- Insures all other data we're getting from other addons and WoW is loaded. There are edge
    -- cases where Questie loads too fast before everything else is available.
    C_Timer.After(1.0, function()
        -- Attach DurabilityFrame to tracker
        if QuestieTracker.alreadyHooked then
            QuestieTracker:CheckDurabilityAlertStatus()
            QuestieTracker:MoveDurabilityFrame()
            DurabilityFrame:Hide()
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

        QuestieCombatQueue:Queue(function()
            -- Hides tracker during a login or reloadUI
            if Questie.db.global.hideTrackerInDungeons and IsInInstance() then
                QuestieTracker:Collapse()
            end

            -- Syncs "Always Show Tracker" upon login
            if Questie.db.global.alwaysShowTracker == true then
                if Questie.db.char.isTrackerExpanded == false then
                    Questie.db.char.isTrackerExpanded = true
                end

                if (not QuestieTracker:HasQuest()) then
                    Questie.db.global.trackerHeaderEnabled = true
                    trackerBaseFrame:SetWidth(trackerHeaderFrame:GetWidth())
                else
                    if Questie.db.global.currentHeaderEnabledSetting == false then
                        Questie.db.global.trackerHeaderEnabled = false
                    end
                end
            else
                Questie.db.global.currentHeaderEnabledSetting = Questie.db.global.trackerHeaderEnabled
            end

            -- Sync and populate the QuestieTracker - this should only run when a player has loaded
            -- Questie for the first time or when Re-enabling the QuestieTracker after it's disabled.

            -- The questsWatched variable is populated by the Unhooked GetNumQuestWatches(). If Questie
            -- is enabled, this is always 0 unless it's run with a true var RE:GetNumQuestWatches(true).
            if questsWatched > 0 then
                -- When a quest is removed from the Watch Frame, the questIndex can change so we need to snag
                -- the entire list and build a temp table with QuestIDs instead to ensure we remove them all.
                local tempQuestIDs = {}
                for i = 1, questsWatched do
                    local questIndex = GetQuestIndexForWatch(i)
                    if questIndex then
                        local questId = select(8, GetQuestLogTitle(questIndex))
                        if questId then
                            tempQuestIDs[i] = questId
                        end
                    end
                end

                -- Remove quest from the Blizzard Quest Watch and populate the tracker.
                for _, questId in pairs(tempQuestIDs) do
                    local questIndex = GetQuestLogIndexByID(questId)
                    if questIndex then
                        QuestieTracker:AQW_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)

                        if QuestLogFrame:IsShown() then QuestLog_Update() end
                    end
                end
            end

            -- The trackedAchievements variable is populated by GetTrackedAchievements(). If Questie
            -- is enabled, this will always return nil so we need to save it before we enable Questie.
            if Questie.IsWotlk then
                if #trackedAchievements > 0 then
                    local tempAchieves = trackedAchievements

                    -- Remove achievement from the Blizzard Quest Watch and populate the tracker.
                    for _, achieveId in pairs(tempAchieves) do
                        if achieveId then
                            RemoveTrackedAchievement(achieveId)
                            Questie.db.char.trackedAchievementIds[achieveId] = true

                            if (not AchievementFrame) then
                                AchievementFrame_LoadUI()
                            end

                            AchievementFrameAchievements_ForceUpdate()
                        end
                    end
                end

                trackedAchievements = { GetTrackedAchievements() }
                WatchFrame_Update()

                -- Sync and populate QuestieTrackers achievement cache
                if Questie.db.char.trackedAchievementIds ~= trackedAchievementIds then
                    for achieveId in pairs(Questie.db.char.trackedAchievementIds) do
                        if Questie.db.char.trackedAchievementIds[achieveId] == true then
                            trackedAchievementIds[achieveId] = true
                        end
                    end
                end
            else
                QuestWatch_Update()
            end

            QuestieTracker:Update()
            trackerBaseFrame:Hide()
        end)
    end)
end

function QuestieTracker:ResetLocation()
    trackerHeaderFrame.trackedQuests:SetMode(1) -- maximized
    Questie.db.char.isTrackerExpanded = true
    Questie.db.char.AutoUntrackedQuests = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
    Questie.db.char.collapsedQuests = {}
    Questie.db.char.collapsedZones = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
    Questie.db[Questie.db.global.questieTLoc].TrackerHeight = 0

    trackerBaseFrame:SetSize(25, 25)
    TrackerBaseFrame:SetSafePoint()

    QuestieTracker:Update()
end

function QuestieTracker:ResetDurabilityFrame()
    DurabilityFrame:ClearAllPoints()
    if durabilityInitialPosition then
        DurabilityFrame:SetPoint(unpack(durabilityInitialPosition))
    end
end

function QuestieTracker:MoveDurabilityFrame()
    local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation

    if Questie.db.char.trackerEnabled and Questie.db.global.stickyDurabilityFrame and DurabilityFrame:IsShown() and QuestieTracker.started and QuestieTrackerLoc ~= nil then
        if QuestieTrackerLoc and QuestieTrackerLoc[1] == "TOPLEFT" or QuestieTrackerLoc[1] == "BOTTOMLEFT" then
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("LEFT", trackerBaseFrame, "TOPRIGHT", 0, -30)
        else
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("RIGHT", trackerBaseFrame, "TOPLEFT", 0, -30)
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
    else
        DurabilityFrame:Hide()
    end
end

-- If the player loots a "Quest Item" then this triggers a Tracker Update so the
-- Quest Item Button can be switched on and appear in the tracker.
---@param text string
function QuestieTracker:QuestItemLooted(text)
    local itemId = tonumber(string.match(text, "item:(%d+)"))
    if select(6, GetItemInfo(itemId)) == "Quest" then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker] Quest Item Detected (itemId): " .. itemId)

        C_Timer.After(0.25, function()
            _QuestEventHandler:UpdateAllQuests()
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieTracker] Callback - QuestEventHandler:UpdateAllQuests()")
        end)

        QuestieCombatQueue:Queue(function()
            C_Timer.After(0.5, function()
                QuestieTracker:Update()
            end)
        end)
    end
end

function QuestieTracker:HasQuest()
    local hasQuest

    if (GetNumQuestWatches(true) == 0) then
        if Questie.IsWotlk then
            if (GetNumTrackedAchievements(true) == 0) then
                hasQuest = false
            else
                hasQuest = true
            end
        else
            hasQuest = false
        end
    else
        hasQuest = true
    end

    return hasQuest
end

function QuestieTracker:Enable()
    -- Update the questsWatched var before we re-enable
    if questsWatched == 0 then
        questsWatched = GetNumQuestWatches()
    end

    Questie.db.char.trackerEnabled = true
    QuestieTracker.started = false
    QuestieTracker.Initialize()
    ReloadUI()
end

function QuestieTracker:Disable()
    Questie.db.char.trackerEnabled = false
    QuestieTracker:ResetDurabilityFrame()
    Questie.db.char.TrackedQuests = {}
    Questie.db.char.AutoUntrackedQuests = {}

    if Questie.IsWotlk then
        Questie.db.char.trackedAchievementIds = {}
        trackedAchievementIds = {}
    end

    QuestieTracker:Unhook()
    QuestieTracker:Update()
    ReloadUI()
end

-- Function for the Slash handler
function QuestieTracker:Toggle()
    if Questie.db.char.trackerEnabled then
        Questie.db.char.trackerEnabled = false
        QuestieTracker:Update()
    else
        Questie.db.char.trackerEnabled = true
        QuestieTracker:Update()
    end
end

-- Minimizes the QuestieTracker
function QuestieTracker:Collapse()
    if trackerHeaderFrame and trackerHeaderFrame.trackedQuests and Questie.db.char.isTrackerExpanded then
        trackerHeaderFrame.trackedQuests:Click()
        QuestieTracker:Update()
    end
end

-- Maximizes the QuestieTracker
function QuestieTracker:Expand()
    if trackerHeaderFrame and trackerHeaderFrame.trackedQuests and (not Questie.db.char.isTrackerExpanded) then
        trackerHeaderFrame.trackedQuests:Click()
        QuestieTracker:Update()
    end
end

function QuestieTracker:Update()
    -- Prevents calling the tracker too often, especially when the QuestieCombatQueue empties after combat ends
    local now = GetTime()
    if (not QuestieTracker.started) or InCombatLockdown() or (now - lastTrackerUpdate) < 0.1 then
        return
    end

    lastTrackerUpdate = now

    -- Tracker has started but not enabled, hide the frames
    if (not Questie.db.char.trackerEnabled or QuestieTracker.disableHooks == true) then
        if trackerBaseFrame and trackerBaseFrame:IsShown() then
            QuestieCombatQueue:Queue(function()
                trackerBaseFrame:Hide()
                DurabilityFrame:Hide()
            end)
        end
        return
    end

    -- Tracker not expanded, no need for an update but it's still a good idea to update the frames
    QuestieCombatQueue:Queue(function()
        TrackerHeaderFrame:Update()
        TrackerQuestFrame:Update()
        TrackerBaseFrame:Update()

        if not Questie.db.char.isTrackerExpanded then
            return
        end
    end)

    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:Update")

    TrackerLinePool.ResetLinesForChange()
    TrackerLinePool.ResetButtonsForChange()

    trackerLineWidth = 0 -- This is needed so the Tracker can also decrease its width

    -- Setup local QuestieTracker:Update vars
    local trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
    local trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
    local questMarginLeft = (trackerMarginLeft + trackerMarginRight + 4) - (18 - trackerFontSizeQuest)
    local objectiveMarginLeft = questMarginLeft + trackerFontSizeQuest
    local questItemButtonSize = 12 + trackerFontSizeQuest

    local line

    local sortedQuestIds, questDetails = TrackerUtils:GetSortedQuestIds()

    local firstQuestInZone = false
    local zoneCheck

    local primaryButton = false
    local secondaryButton = false
    local secondaryButtonAlpha

    -- Begin populating the Tracker with Quests
    for _, questId in pairs(sortedQuestIds) do
        if not questId then break end

        local quest = questDetails[questId].quest
        local complete = quest:IsComplete()
        local zoneName = questDetails[questId].zoneName
        local remainingSeconds = TrackerQuestTimers:GetRemainingTime(quest, nil, true)

        if (complete ~= 1 or Questie.db.global.trackerShowCompleteQuests or quest.trackTimedQuest or quest.timedBlizzardQuest)
            and (Questie.db.global.autoTrackQuests and not Questie.db.char.AutoUntrackedQuests[questId])
            or (not Questie.db.global.autoTrackQuests and Questie.db.char.TrackedQuests[questId]) then
            -- Add Quest Zones
            if zoneCheck ~= zoneName then
                firstQuestInZone = true
            end

            if firstQuestInZone then
                -- Get first line in linePool
                line = TrackerLinePool.GetNextLine()

                -- Safety check - make sure we didn't run over our linePool limit.
                if not line then break end

                -- Set Line Mode, Types, Clickers
                line:SetMode("zone")
                line:SetZone(zoneName)
                line.expandQuest:Hide()
                line.criteriaMark:Hide()

                -- Setup Zone Label
                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

                -- Set Zone Title and default Min/Max states
                if Questie.db.char.collapsedZones[zoneName] then
                    line.expandZone:SetMode(0)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                else
                    line.expandZone:SetMode(1)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
                end

                -- Checks the minAllQuestsInZone[zone] table and if empty, zero out the table.
                if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and not Questie.db.char.minAllQuestsInZone[zoneName].isTrue and not Questie.db.char.collapsedZones[zoneName] then
                    local minQuestIdCount = 0
                    for minQuestId, _ in pairs(Questie.db.char.minAllQuestsInZone[zoneName]) do
                        if type(minQuestId) == "number" then
                            minQuestIdCount = minQuestIdCount + 1
                        end
                    end

                    if minQuestIdCount == 0 then
                        Questie.db.char.minAllQuestsInZone[zoneName] = nil
                    end
                end

                -- Check and measure Zone Label text width and update tracker width
                QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + trackerMarginLeft)

                -- Set Zone Label and Line widths
                line.label:SetWidth(trackerBaseFrame:GetWidth() - trackerMarginLeft)
                line:SetWidth(line.label:GetWidth())

                -- Compare largest text Label in the tracker with current Label, then save widest width
                trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerMarginLeft)

                -- Setup Min/Max Button
                line.expandZone:ClearAllPoints()
                line.expandZone:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
                line.expandZone:SetWidth(line.label:GetWidth())
                line.expandZone:SetHeight(line.label:GetHeight())
                line.expandZone:Show()

                -- Adds 4 pixels between Zone and first Quest Title
                line:SetHeight(line.label:GetHeight() + 4)

                -- Set Zone states
                line:Show()
                line.label:Show()
                line.Quest = nil
                line.Objective = nil
                firstQuestInZone = false
                zoneCheck = zoneName
            end

            -- Add quest
            if (not Questie.db.char.collapsedZones[zoneName]) then
                -- Get next line in linePool
                line = TrackerLinePool.GetNextLine()

                -- Safety check - make sure we didn't run over our linePool limit.
                if not line then break end

                -- Set Line Mode, Types, Clickers
                line:SetMode("quest")
                line:SetOnClick("quest")
                line:SetQuest(quest)
                line:SetObjective(nil)
                line.expandZone:Hide()
                line.criteriaMark:Hide()

                -- Set Min/Max Button and default states
                line.expandQuest:SetPoint("TOPRIGHT", line, "TOPLEFT", questMarginLeft - 8, 1)
                line.expandQuest.zoneId = zoneName

                -- Handles the collapseCompletedQuests option from the Questie Config --> Tracker options.
                if Questie.db.global.collapseCompletedQuests and complete == 1 and #quest.Objectives ~= 0 and not (quest.trackTimedQuest or quest.timedBlizzardQuest) then
                    if not Questie.db.char.collapsedQuests[quest.Id] then
                        Questie.db.char.collapsedQuests[quest.Id] = true
                    end
                else
                    -- The minAllQuestsInZone table is always blank until a player Shift+Clicks the Zone header (MouseDown).
                    -- QuestieTracker:Update is triggered and the table is then filled with all Quest ID's in the same Zone.
                    if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and Questie.db.char.minAllQuestsInZone[zoneName].isTrue then
                        Questie.db.char.minAllQuestsInZone[zoneName][quest.Id] = true
                    end

                    -- Handles all the Min/Max behavior individually for each quest.
                    if Questie.db.char.collapsedQuests[quest.Id] then
                        line.expandQuest:SetMode(0)
                    else
                        line.expandQuest:SetMode(1)
                    end
                end

                -- Setup Quest Label
                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", questMarginLeft, 0)

                -- Set Quest Title
                local coloredQuestName
                if quest.trackTimedQuest or quest.timedBlizzardQuest then
                    coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.trackerShowQuestLevel, false, false)
                else
                    coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.trackerShowQuestLevel, (Questie.db.global.collapseCompletedQuests and complete == 1 and #quest.Objectives ~= 0), false)
                end
                line.label:SetText(coloredQuestName)

                -- Check and measure Quest Label text width and update tracker width
                QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + questMarginLeft + trackerMarginRight)

                -- Set Quest Label and Line widths
                line.label:SetWidth(trackerBaseFrame:GetWidth() - questMarginLeft - trackerMarginRight)
                line:SetWidth(line.label:GetWidth() + questMarginLeft)

                -- Compare largest text Label in the tracker with current Label, then save widest width
                trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + questMarginLeft)

                -- Adds 4 pixels between Quest Title and first Objective
                line:SetHeight(line.label:GetHeight() + 4)

                -- Adds the primary Quest Item button
                -- GetItemSpell(itemId) is a bit of a work around for not having a Blizzard API for checking an items IsUsable state.
                if (complete ~= 1 and GetItemSpell(quest.sourceItemId) ~= nil and (quest.sourceItemId or (quest.requiredSourceItems and #quest.requiredSourceItems == 1))) then
                    -- Get button from buttonPool
                    local button = TrackerLinePool.GetNextItemButton()
                    if not button then break end -- stop populating the tracker

                    -- Check and set itemID
                    if quest.sourceItemId then
                        button.itemID = quest.sourceItemId
                    elseif type(quest.requiredSourceItems) == "table" and #quest.requiredSourceItems == 1 then
                        button.itemID = quest.requiredSourceItems[1]
                    end

                    -- Get and save Quest Title linePool to buttonPool
                    button.line = line

                    -- Setup button and set attributes
                    if button:SetItem(quest, "primary", questItemButtonSize) then
                        local height = 0
                        local frame = button.line
                        while frame and frame ~= trackerQuestFrame do
                            local _, parent, _, _, yOff = frame:GetPoint()
                            height = height - (frame:GetHeight() - yOff)
                            frame = parent
                        end

                        -- If the buttons alpha is zero - hide the expand quest button
                        if Questie.db.char.collapsedQuests[quest.Id] or button:GetAlpha() < 0.06 then
                            button.line.expandQuest:Show()
                        else
                            button.line.expandQuest:Hide()
                        end

                        -- Attach button to Quest Title linePool
                        button:SetPoint("TOPLEFT", button.line, "TOPLEFT", 0, 0)
                        button:SetParent(button.line)
                        button:Show()

                        -- Set flag to allow secondary Quest Item Buttons
                        primaryButton = true

                        -- If the Quest Zone or Quest is minimized then set UIParent and hide buttons since the buttons are normally attached to the Quest frame.
                        -- If buttons are left attached to the Quest frame and if the Tracker frame is hidden in combat, then it would also try and hide the
                        -- buttons which you can't do in combat. This helps avoid violating the Blizzard SecureActionButtonTemplate restrictions relating to combat.
                        if Questie.db.char.collapsedZones[zoneName] or Questie.db.char.collapsedQuests[quest.Id] then
                            button:SetParent(UIParent)
                            button:Hide()
                        end
                    else
                        -- Button failed to get setup for some reason or the quest item is now gone. Hide it and enable the Quest Min/Max button.
                        -- See previous comment for details on why we're setting this button to UIParent.
                        button.line.expandQuest:Show()
                        button:SetParent(UIParent)
                        button:Hide()
                    end

                    -- Save button to linePool
                    line.button = button

                    -- Hide button if quest complete or failed
                elseif (Questie.db.global.collapseCompletedQuests and complete == 1 and #quest.Objectives ~= 0 and not (quest.trackTimedQuest or quest.timedBlizzardQuest)) then
                    line.expandQuest:Hide()
                else
                    line.expandQuest:Show()
                end

                -- Adds the Secondary Quest Item Button (only if Primary is present)
                if (primaryButton and quest.requiredSourceItems and #quest.requiredSourceItems > 1 and next(quest.Objectives)) then
                    if type(quest.requiredSourceItems) == "table" then
                        -- Make sure it's a "secondary" button and if a quest item is "usable".
                        for _, itemId in pairs(quest.requiredSourceItems) do
                            -- GetItemSpell(itemId) is a bit of a work around for not having a Blizzard API for checking an items IsUsable state.
                            if itemId and itemId ~= quest.sourceItemId and QuestieDB.QueryItemSingle(itemId, "class") == 12 and (GetItemSpell(itemId) ~= nil) then
                                -- Get button from buttonPool
                                local altButton = TrackerLinePool.GetNextItemButton()
                                if not altButton then break end -- stop populating the tracker

                                -- Set itemID
                                altButton.itemID = itemId

                                -- Get and save Quest Title linePool to buttonPool
                                altButton.line = line

                                -- Setup button and set attributes
                                if altButton:SetItem(quest, "secondary", questItemButtonSize) then
                                    local height = 0
                                    local frame = altButton.line

                                    while frame and frame ~= trackerQuestFrame do
                                        local _, parent, _, _, yOff = frame:GetPoint()
                                        height = height - (frame:GetHeight() - yOff)
                                        frame = parent
                                    end

                                    if not Questie.db.char.collapsedQuests[quest.Id] and altButton:GetAlpha() > 0 then
                                        -- Set and indent Quest Title linePool
                                        altButton.line.label:ClearAllPoints()
                                        altButton.line.label:SetPoint("TOPLEFT", altButton.line, "TOPLEFT", questMarginLeft + 2 + questItemButtonSize, 0)

                                        -- Recheck and Remeasure Quest Label text width and update tracker width
                                        QuestieTracker:UpdateWidth(altButton.line.label:GetUnboundedStringWidth() + questMarginLeft + trackerMarginRight + questItemButtonSize)

                                        -- Reset Quest Title Label and linePool widths
                                        altButton.line.label:SetWidth(trackerBaseFrame:GetWidth() - questMarginLeft - trackerMarginRight - questItemButtonSize)
                                        altButton.line:SetWidth(altButton.line.label:GetWidth() + questMarginLeft + questItemButtonSize)

                                        -- Re-compare largest text Label in the tracker with Secondary Button/Quest and current Label, then save widest width
                                        trackerLineWidth = math.max(trackerLineWidth, altButton.line.label:GetUnboundedStringWidth() + questMarginLeft + questItemButtonSize)
                                    elseif altButton:GetAlpha() == 0 then
                                        -- Set Quest Title linePool
                                        altButton.line.label:ClearAllPoints()
                                        altButton.line.label:SetPoint("TOPLEFT", altButton.line, "TOPLEFT", questMarginLeft, 0)

                                        -- Recheck and Remeasure Quest Label text width and update tracker width
                                        QuestieTracker:UpdateWidth(altButton.line.label:GetUnboundedStringWidth() + questMarginLeft + trackerMarginRight)

                                        -- Reset Quest Title Label and linePool widths
                                        altButton.line.label:SetWidth(trackerBaseFrame:GetWidth() - questMarginLeft - trackerMarginRight)
                                        altButton.line:SetWidth(altButton.line.label:GetWidth() + questMarginLeft)

                                        -- Re-compare largest text Label in the tracker with current Label, then save widest width
                                        trackerLineWidth = math.max(trackerLineWidth, altButton.line.label:GetUnboundedStringWidth() + questMarginLeft)
                                    end

                                    -- Attach button to Quest Title linePool
                                    altButton:SetPoint("TOPLEFT", altButton.line, "TOPLEFT", 2 + questItemButtonSize, 0)
                                    altButton:SetParent(altButton.line)
                                    altButton:Show()

                                    -- Set flag to shift objective lines
                                    secondaryButton = true
                                    secondaryButtonAlpha = altButton:GetAlpha()

                                    -- If the Quest Zone or Quest is minimized then set UIParent and hide buttons since the buttons are normally attached to the Quest frame.
                                    -- If buttons are left attached to the Quest frame and if the Tracker frame is hidden in combat, then it would also try and hide the
                                    -- buttons which you can't do in combat. This helps avoid violating the Blizzard SecureActionButtonTemplate restrictions relating to combat.
                                    if Questie.db.char.collapsedZones[zoneName] or Questie.db.char.collapsedQuests[quest.Id] then
                                        altButton:SetParent(UIParent)
                                        altButton:Hide()
                                    end

                                    -- Button failed to get setup for some reason or the quest item is now gone. Hide it and enable the Quest Min/Max button.
                                    -- See previous comment for details on why we're setting this button to UIParent.
                                else
                                    altButton:SetParent(UIParent)
                                    altButton:Hide()
                                end

                                -- Save button to linePool
                                line.altButton = altButton
                            end
                        end
                    end
                end

                -- Set Quest Line states
                line:Show()
                line.label:Show()

                -- Add quest Objectives (if applicable)
                if (not Questie.db.char.collapsedQuests[quest.Id]) then
                    -- Add Quest Timers (if applicable)
                    if (quest.trackTimedQuest or quest.timedBlizzardQuest) then
                        -- Get next line in linePool
                        line = TrackerLinePool.GetNextLine()

                        -- Safety check - make sure we didn't run over our linePool limit.
                        if not line then break end

                        -- Set Line Mode, Types, Clickers
                        line:SetMode("objective")
                        line:SetOnClick("quest")
                        line:SetQuest(quest)
                        line.expandZone:Hide()
                        line.expandQuest:Hide()
                        line.criteriaMark:Hide()

                        -- Setup Timer Label
                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                        -- Set Timer font
                        line.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective), Questie.db.global.trackerFontSizeObjective, Questie.db.global.trackerFontOutline)

                        -- Set Timer Title based on states
                        line.label.activeTimer = false
                        if quest.timedBlizzardQuest then
                            line.label:SetText(Questie:Colorize(l10n("Blizzard Timer Active") .. "!", "blue"))
                        else
                            local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTime(quest, line, false)
                            if timeRemaining then
                                if timeRemaining <= 1 then
                                    line.label:SetText(Questie:Colorize("0 Seconds", "blue"))
                                    line.label.activeTimer = false
                                else
                                    line.label:SetText(Questie:Colorize(timeRemainingString, "blue"))
                                    line.label.activeTimer = true
                                end
                            end
                        end

                        -- Check and measure Timer text width and update tracker width
                        QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                        -- Set Timer Label and Line widthsl
                        line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                        line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)

                        -- Compare largest text Label in the tracker with current Label, then save widest width
                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft)

                        -- Set Timer states
                        line:Show()
                        line.label:Show()
                    end

                    -- Set Completion Text
                    local completionText = TrackerUtils:GetCompletionText(quest)

                    -- gsub removes any blank lines
                    if completionText ~= nil then
                        completionText = completionText:gsub("(.\r?\n?)\r?\n?", "%1")
                    end

                    -- Add incomplete Quest Objectives
                    if complete == 0 then
                        for _, objective in pairs(quest.Objectives) do
                            if (not Questie.db.global.hideCompletedQuestObjectives or (Questie.db.global.hideCompletedQuestObjectives and objective.Needed ~= objective.Collected)) then
                                -- Get next line in linePool
                                line = TrackerLinePool.GetNextLine()

                                -- Safety check - make sure we didn't run over our linePool limit.
                                if not line then break end

                                -- Set Line Mode, Types, Clickers
                                line:SetMode("objective")
                                line:SetOnClick("quest")
                                line:SetQuest(quest)
                                line:SetObjective(objective)
                                line.expandZone:Hide()
                                line.expandQuest:Hide()
                                line.criteriaMark:Hide()

                                -- Setup Objective Label based on states. This CANNOT be combined in the secondaryButton
                                -- check below. line.label SetPoint needs to be set BEFORE we SetText.
                                line.label:ClearAllPoints()
                                if secondaryButton and secondaryButtonAlpha ~= 0 then
                                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft + questItemButtonSize, 0)
                                else
                                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)
                                end

                                -- Set Objective based on states
                                local objDesc = objective.Description:gsub("%.", "")

                                if (objective.Completed ~= true or (objective.Completed == true and #quest.Objectives > 1)) then
                                    local lineEnding
                                    lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)

                                    -- Set Objective text
                                    line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding)

                                    if secondaryButton and secondaryButtonAlpha ~= 0 then
                                        -- Check and measure Objective text with Secondary Button widths and update tracker width
                                        QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight + questItemButtonSize)

                                        -- Set Objective with Secondary Quest Item button Label and Line widths
                                        line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight - questItemButtonSize)
                                        line:SetWidth(line.label:GetWidth() + objectiveMarginLeft + questItemButtonSize)

                                        -- Compare current text label with Secondary button width and the largest text label in the Tracker, then save the widest width
                                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft + questItemButtonSize)
                                    else
                                        -- Check and measure Objective text width and update tracker width
                                        QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                                        -- Set Objective Label and Line widths
                                        line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                                        line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)

                                        -- Compare largest text Label in the tracker with current Label, then save widest width
                                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft)
                                    end

                                    -- Edge case where the quest is still flagged incomplete for single objectives and yet the objective itself is flagged complete
                                elseif (objective.Completed == true and completionText ~= nil and #quest.Objectives == 1) then
                                    -- Set Blizzard Completion text for single objectives
                                    line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = 1, Needed = 1 }) .. completionText)

                                    -- Set Blizzard Completion Label and Line widths
                                    line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                                    line:SetWidth(line.label:GetWrappedWidth() + objectiveMarginLeft)

                                    -- Blizzard Completion Text tends to be rather verbose. Allow text wrapping.
                                    line.label:SetHeight(line.label:GetStringHeight() * line.label:GetNumLines())
                                    line:SetHeight(line.label:GetHeight())

                                    -- Compare trackerLineWidth, trackerMinLineWidth and the current label, then save the widest width
                                    trackerLineWidth = math.max(trackerLineWidth, trackerMinLineWidth, line.label:GetWrappedWidth() + objectiveMarginLeft)

                                    -- Show the Quest turn in location on map - This needs to be called manually in certain edge cases. Doesn't hurt to call it twice.
                                    --QuestieQuest:AddFinisher(quest)
                                    --TODO: Find another way to show Quest Finisher
                                end

                                -- Adds 1 pixel between multiple Objectives
                                line:SetHeight(line.label:GetHeight() + 1)

                                -- Set Objective state
                                line:Show()
                                line.label:Show()
                            end
                        end

                        -- Add complete/failed Quest Objectives and tag them as either complete or failed so as to always have at least one objective.
                        -- Some quests have "Blizzard Completion Text" that is displayed to show where to go next or where to turn in the quest.
                    elseif complete == 1 or complete == -1 or quest.Completed == true then
                        -- Get next line in linePool
                        line = TrackerLinePool.GetNextLine()

                        -- Safety check - make sure we didn't run over our linePool limit.
                        if not line then break end

                        -- Set Line Mode, Types, Clickers
                        line:SetMode("objective")
                        line:SetOnClick("quest")
                        line:SetQuest(quest)
                        line.expandZone:Hide()
                        line.expandQuest:Hide()
                        line.criteriaMark:Hide()

                        -- Setup Objective Label
                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                        -- Set Objective label based on states
                        if (complete == 1 and completionText ~= nil and #quest.Objectives == 0) then
                            -- Set Blizzard Completion text for single objectives
                            line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = 1, Needed = 1 }) .. completionText)

                            -- Set Line and Label widths
                            line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                            line:SetWidth(line.label:GetWrappedWidth() + objectiveMarginLeft)

                            -- Allow text wrapping and set Line and Label heights.
                            line.label:SetHeight(line.label:GetStringHeight() * line.label:GetNumLines())
                            line:SetHeight(line.label:GetHeight())

                            -- Compare trackerLineWidth, trackerMinLineWidth and the current label, then save the widest width
                            trackerLineWidth = math.max(trackerLineWidth, trackerMinLineWidth, line.label:GetWrappedWidth() + objectiveMarginLeft)

                            -- Show the Quest turn in location on map - This needs to be called manually in certain edge cases. Doesn't hurt to call it twice.
                            --QuestieQuest:AddFinisher(quest)
                            --TODO: Find another way to show Quest Finisher
                        else
                            if complete == 1 then
                                line.label:SetText(Questie:Colorize(l10n("Quest Complete") .. "!", "green"))

                                -- Show the Quest turn in location on map - This needs to be called manually in certain edge cases. Doesn't hurt to call it twice.
                                --QuestieQuest:AddFinisher(quest)
                                --TODO: Find another way to show Quest Finisher
                            elseif complete == -1 then
                                line.label:SetText(Questie:Colorize(l10n("Quest Failed") .. "!", "red"))
                            end

                            -- Check and measure Objective text width and update tracker width
                            QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                            -- Set Objective Label and Line widths
                            line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                            line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)

                            -- Compare largest text Label in the tracker with current Label, then save widest width
                            trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft)
                        end

                        -- Set Objective state
                        line:Show()
                        line.label:Show()
                    end
                end

                -- Safety check in case we hit the linePool limit
                if not line then
                    line = TrackerLinePool.GetLastLine()
                end

                -- Adds 2 pixels and "Padding Between Quests" setting in Tracker Options
                line:SetHeight(line.label:GetHeight() + (Questie.db.global.trackerQuestPadding + 2))
            end
            primaryButton = false
            secondaryButton = false
        end
    end

    -- Begin populating the tracker with achievements
    if Questie.IsWotlk then
        -- Begin populating the tracker with tracked achievements - Note: We're limited to tracking only 10 Achievements at a time.
        -- For all intents and purposes at a code level we're going to treat each tracked Achievement the same way we treat and add Quests. This loop is
        -- necessary to keep separate from the above tracked Quests loop so we can place all tracked Achievements into it's own "Zone" called Achievements.
        -- This will force Achievements to always appear at the bottom of the tracker. Obviously it'll show at the top if there are no quests being tracked.
        local firstAchieveInZone = false
        local achieveId, achieveName, achieveDescription, achieveComplete, numCriteria, zoneName, achieve

        for trackedId, _ in pairs(trackedAchievementIds) do
            achieveId, achieveName, _, _, _, _, _, achieveDescription, _, _, _, _, achieveComplete, _, _ = GetAchievementInfo(trackedId)
            numCriteria = GetAchievementNumCriteria(trackedId)
            zoneName = "Achievements"

            achieve = {
                Id = achieveId,
                Name = achieveName,
                Description = achieveDescription
            }

            if achieveId and (not achieveComplete) and trackedAchievementIds[achieveId] == true then
                -- Add Achievement Zone
                if zoneCheck ~= zoneName then
                    firstAchieveInZone = true
                end

                if firstAchieveInZone then
                    -- Get first line in linePool
                    line = TrackerLinePool.GetNextLine()

                    -- Safety check - make sure we didn't run over our linePool limit.
                    if not line then break end

                    -- Set Line Mode, Types, Clickers
                    line:SetMode("zone")
                    line:SetZone(zoneName)
                    line.expandQuest:Hide()
                    line.criteriaMark:Hide()

                    -- Setup Zone Label
                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

                    -- Set Zone Title and Min/Max states
                    if Questie.db.char.collapsedZones[zoneName] then
                        line.expandZone:SetMode(0)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                    else
                        line.expandZone:SetMode(1)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. ": " .. GetNumTrackedAchievements(true) .. "/10|r")
                    end

                    -- Checks the minAllQuestsInZone[zone] table and if empty, zero out the table.
                    if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and not Questie.db.char.minAllQuestsInZone[zoneName].isTrue and not Questie.db.char.collapsedZones[zoneName] then
                        local minQuestIdCount = 0
                        for minQuestId, _ in pairs(Questie.db.char.minAllQuestsInZone[zoneName]) do
                            if type(minQuestId) == "number" then
                                minQuestIdCount = minQuestIdCount + 1
                            end
                        end

                        if minQuestIdCount == 0 then
                            Questie.db.char.minAllQuestsInZone[zoneName] = nil
                        end
                    end

                    -- Check and measure Zone Label text width and update tracker width
                    QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + trackerMarginLeft)

                    -- Set Zone Label and Line widths
                    line.label:SetWidth(trackerBaseFrame:GetWidth() - trackerMarginLeft)
                    line:SetWidth(line.label:GetWidth())

                    -- Compare largest text Label in the tracker with current Label, then save widest width
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerMarginLeft)

                    -- Setup Min/Max Button
                    line.expandZone:ClearAllPoints()
                    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)
                    line.expandZone:SetWidth(line.label:GetWidth())
                    line.expandZone:SetHeight(line.label:GetHeight())
                    line.expandZone:Show()

                    -- Adds 4 pixels between Zone and first Achievement Title
                    line:SetHeight(line.label:GetHeight() + 4)

                    -- Set Zone states
                    line:Show()
                    line.label:Show()
                    line.Quest = nil
                    line.Objective = nil
                    firstAchieveInZone = false
                    zoneCheck = zoneName
                end

                -- Add Achievements
                if (not Questie.db.char.collapsedZones[zoneName]) then
                    -- Get next line in linePool
                    line = TrackerLinePool.GetNextLine()

                    -- Safety check - make sure we didn't run over our linePool limit.
                    if not line then break end

                    -- Set Line Mode, Types, Clickers
                    line:SetMode("achieve")
                    line:SetOnClick("achieve")
                    line:SetQuest(achieve)
                    line:SetObjective(nil)
                    line.expandZone:Hide()
                    line.criteriaMark:Hide()

                    -- Set Min/Max Button and default states
                    line.expandQuest:Show()
                    line.expandQuest:SetPoint("TOPRIGHT", line, "TOPLEFT", questMarginLeft - 8, 1)
                    line.expandQuest.zoneId = zoneName

                    -- The minAllQuestsInZone table is always blank until a player Shift+Clicks the Zone header (MouseDown).
                    -- QuestieTracker:Update is triggered and the table is then filled with all Achievement ID's in the same Zone.
                    if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and Questie.db.char.minAllQuestsInZone[zoneName].isTrue then
                        Questie.db.char.minAllQuestsInZone[zoneName][achieve.Id] = true
                    end

                    -- Handles all the Min/Max behavior individually for each Achievement.
                    if Questie.db.char.collapsedQuests[achieve.Id] then
                        line.expandQuest:SetMode(0)
                    else
                        line.expandQuest:SetMode(1)
                    end

                    -- Setup Achievement Label
                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", questMarginLeft, 0)

                    -- Set Achievement Title
                    if Questie.db.global.enableTooltipsQuestID then
                        line.label:SetText("|cFFFFFF00" .. achieve.Name .. " (" .. achieve.Id .. ")|r")
                    else
                        line.label:SetText("|cFFFFFF00" .. achieve.Name .. "|r")
                    end

                    -- Check and measure Achievement Label text width and update tracker width
                    QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + questMarginLeft + trackerMarginRight)

                    -- Set Achievement Label and Line widths
                    line.label:SetWidth(trackerBaseFrame:GetWidth() - questMarginLeft - trackerMarginRight)
                    line:SetWidth(line.label:GetWidth() + questMarginLeft)

                    -- Compare largest text Label in the tracker with current Label, then save widest width
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + questMarginLeft)

                    -- Adds 4 pixels between Achievement Title and first Objective
                    line:SetHeight(line.label:GetHeight() + 4)

                    -- Set Achievement states
                    line:Show()
                    line.label:Show()

                    -- Add achievement Objective (if applicable)
                    if (not Questie.db.char.collapsedQuests[achieve.Id]) then
                        -- Achievements with no number criteria
                        if numCriteria == 0 then
                            -- Get next line in linePool
                            line = TrackerLinePool.GetNextLine()

                            -- Safety check - make sure we didn't run over our linePool limit.
                            if not line then break end

                            -- Set Line Mode, Types, Clickers
                            line:SetMode("objective")
                            line:SetOnClick("achieve")
                            line:SetQuest(achieve)
                            line:SetObjective("objective")
                            line.expandZone:Hide()
                            line.expandQuest:Hide()
                            line.criteriaMark:Hide()

                            -- Setup Objective Label
                            line.label:ClearAllPoints()
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                            -- Set Objective text
                            local objDesc = achieve.Description:gsub("%.", "")
                            line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = 0, Needed = 1 }) .. objDesc)

                            -- Set Label and Line widths
                            line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                            line:SetWidth(line.label:GetWrappedWidth() + objectiveMarginLeft)

                            -- TextWrap Objective and set height
                            line.label:SetHeight(line.label:GetStringHeight() * line.label:GetNumLines())
                            line:SetHeight(line.label:GetHeight())

                            -- Compare trackerLineWidth, trackerMinLineWidth and the current label, then save the widest width
                            trackerLineWidth = math.max(trackerLineWidth, trackerMinLineWidth, line.label:GetWrappedWidth() + objectiveMarginLeft)

                            -- Set Objective state
                            line:Show()
                            line.label:Show()
                        end

                        -- Achievements with number criteria
                        for objCriteria = 1, numCriteria do
                            local criteriaString, _, completed, quantityProgress, quantityNeeded, _, _, refId, quantityString = GetAchievementCriteriaInfo(achieve.Id, objCriteria)
                            if ((Questie.db.global.hideCompletedAchieveObjectives) and (not completed)) or (not Questie.db.global.hideCompletedAchieveObjectives) then
                                -- Get next line in linePool
                                line = TrackerLinePool.GetNextLine()

                                -- Safety check - make sure we didn't run over our linePool limit.
                                if not line then break end

                                -- Set Line Mode, Types, Clickers
                                line:SetMode("objective")
                                line:SetOnClick("achieve")

                                -- Set correct Objective ID. Sometimes stand alone trackable Achievements are part of a group of Achievements under a parent Achievement.
                                local objId

                                if refId and select(2, GetAchievementInfo(refId)) == criteriaString and ((GetAchievementInfo(refId) and refId ~= 0) or (refId > 0 and (not QuestieDB:GetQuest(refId)))) then
                                    objId = refId
                                else
                                    objId = achieve
                                end

                                line:SetQuest(objId)
                                line:SetObjective("objective")
                                line.expandZone:Hide()
                                line.expandQuest:Hide()
                                line.criteriaMark:Hide()

                                -- Setup Objective Label
                                line.label:ClearAllPoints()
                                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                                -- Set Objective label based on state
                                if (criteriaString == "") then
                                    criteriaString = achieve.Description
                                end

                                local objDesc = criteriaString:gsub("%.", "")

                                -- Set Objectives with more than one Objective number criteria
                                if not (completed or quantityNeeded == 1 or quantityProgress == quantityNeeded) then
                                    if string.find(quantityString, "|") then
                                        quantityString = quantityString:gsub("/%s?", "/")
                                    else
                                        quantityString = quantityProgress .. "/" .. quantityNeeded
                                    end

                                    local lineEnding = tostring(quantityString)

                                    -- Set Objective text
                                    line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = quantityProgress, Needed = quantityNeeded }) .. objDesc .. ": " .. lineEnding)

                                    -- Check and measure Objective text width and update tracker width
                                    QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                                    -- Set Label width
                                    line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)

                                    -- Split Objective description and Progress/Needed into seperate lines
                                    if (trackerLineWidth < line.label:GetUnboundedStringWidth() + objectiveMarginLeft) and (line.label:GetWidth() < line.label:GetUnboundedStringWidth() + 5) then
                                        -- Set Objective text
                                        line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = quantityProgress, Needed = quantityNeeded }) .. objDesc .. ": ")

                                        -- Check and measure Objective text width and update tracker width
                                        QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                                        -- Set Label and Line widths
                                        line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                                        line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)

                                        -- Compare largest text Label in the tracker with current Label, then save widest width
                                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft)

                                        -- Adds 1 pixel between split Objectives
                                        line:SetHeight(line.label:GetHeight() + 1)

                                        -- Set Objective state
                                        line:Show()
                                        line.label:Show()

                                        -- Get next line in linePool
                                        line = TrackerLinePool.GetNextLine()

                                        -- Safety check - make sure we didn't run over our linePool limit.
                                        if not line then break end

                                        -- Set Line Mode, Types, Clickers
                                        line:SetMode("objective")
                                        line:SetOnClick("achieve")
                                        line:SetQuest(objId)
                                        line:SetObjective("objective")
                                        line.expandZone:Hide()
                                        line.expandQuest:Hide()
                                        line.criteriaMark:Hide()

                                        -- Set Objective Label
                                        line.label:ClearAllPoints()
                                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                                        -- Set Objective text
                                        line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = quantityProgress, Needed = quantityNeeded }) .. "    > " .. lineEnding)

                                        -- Check and measure Objective text width and update tracker width
                                        QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                                        -- Set Label and Line widths
                                        line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                                        line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)
                                    else
                                        -- Set Line widths
                                        line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)

                                        -- Compare largest text Label in the tracker with current Label, then save widest width
                                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft)
                                    end

                                    -- Set Objectives with a single Objective number criteria
                                else
                                    -- Set Objective text
                                    local trackerColor = Questie.db.global.trackerColorObjectives

                                    if completed then
                                        line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = 1, Needed = 1 }) .. objDesc)
                                    else
                                        line.label:SetText(QuestieLib:GetRGBForObjective({ Collected = 0, Needed = 1 }) .. objDesc)
                                    end

                                    -- Set Objective criteria mark
                                    if not Questie.db.global.hideCompletedAchieveObjectives and (not trackerColor or trackerColor == "white") then
                                        line.criteriaMark:SetCriteria(completed)

                                        if line.criteriaMark.mode == true then
                                            line.criteriaMark:Show()
                                        end
                                    end

                                    -- Check and measure Objective text width and update tracker width
                                    QuestieTracker:UpdateWidth(line.label:GetUnboundedStringWidth() + objectiveMarginLeft + trackerMarginRight)

                                    -- Set Objective Label and Line widths
                                    line.label:SetWidth(trackerBaseFrame:GetWidth() - objectiveMarginLeft - trackerMarginRight)
                                    line:SetWidth(line.label:GetWidth() + objectiveMarginLeft)

                                    -- Compare largest text Label in the tracker with current Label, then save widest width
                                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + objectiveMarginLeft)
                                end

                                -- Adds 1 pixel between multiple Objectives
                                line:SetHeight(line.label:GetHeight() + 1)

                                -- Set Objective state
                                line:Show()
                                line.label:Show()
                            end
                        end
                    end

                    -- Safety check in case we hit the linePool limit
                    if not line then
                        line = TrackerLinePool.GetLastLine()
                    end

                    -- Adds 2 pixels and "Padding Between Quests" setting in Tracker Options
                    line:SetHeight(line.label:GetHeight() + (Questie.db.global.trackerQuestPadding + 2))
                end
            end
        end
    end

    -- Safety check in case we hit the linePool limit
    if not line then
        line = TrackerLinePool.GetLastLine()
    end

    -- Removes any padding from the last line in the tracker
    line:SetHeight(line.label:GetHeight())

    -- Update tracker formatting
    if line then
        QuestieTracker:UpdateFormatting()
    end

    -- First run clean up
    if isFirstRun then
        trackerBaseFrame:Hide()
        for questId in pairs(QuestiePlayer.currentQuestlog) do
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

                    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                        TrackerUtils:FocusObjective(quest.Id, objective.Index)
                    end
                end

                for _, objective in pairs(quest.SpecialObjectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                    end

                    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                        TrackerUtils:FocusObjective(quest.Id, objective.Index)
                    end
                end
            end
        end
        isFirstRun = false
        C_Timer.After(1.0, function()
            QuestieCombatQueue:Queue(function()
                allowFormattingUpdate = true
                QuestieTracker:Update()
            end)
        end)
    end
end

function QuestieTracker:UpdateFormatting()
    if not allowFormattingUpdate then
        return
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UpdateFormatting")

    -- Hide unused lines
    TrackerLinePool.HideUnusedLines()

    -- Hide unused item buttons
    QuestieCombatQueue:Queue(function()
        TrackerLinePool.HideUnusedButtons()
    end)

    if (not QuestieTracker:HasQuest()) then
        if Questie.db.global.alwaysShowTracker then
            Questie.db.global.trackerHeaderEnabled = true
            trackerBaseFrame:Show()
        else
            Questie.db.global.trackerHeaderEnabled = Questie.db.global.currentHeaderEnabledSetting
            trackerBaseFrame:Hide()
        end
    else
        Questie.db.global.trackerHeaderEnabled = Questie.db.global.currentHeaderEnabledSetting
        trackerBaseFrame:Show()
    end

    TrackerHeaderFrame:Update()

    if trackerLineWidth > 1 and TrackerLinePool.GetCurrentLine() then
        local trackerVarsCombined = trackerLineWidth + trackerMarginRight
        local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation

        QuestieTracker:UpdateWidth(trackerVarsCombined)
        TrackerLinePool.UpdateWrappedLineWidths(trackerLineWidth)

        if TrackerLinePool.GetCurrentLine().mode == "zone" then
            trackerQuestFrame.ScrollChildFrame:SetSize(trackerVarsCombined, (TrackerLinePool.GetFirstLine():GetTop() - TrackerLinePool.GetCurrentLine():GetBottom()))
        else
            trackerQuestFrame.ScrollChildFrame:SetSize(trackerVarsCombined, (TrackerLinePool.GetFirstLine():GetTop() - TrackerLinePool.GetCurrentLine():GetBottom() + 2))
        end

        trackerQuestFrame:SetWidth(trackerBaseFrame:GetWidth())
        trackerQuestFrame:SetHeight(trackerQuestFrame.ScrollChildFrame:GetHeight())

        -- Applies static height when the tracker hit's its trackerHeightRatio limit or based on a players preference using the Tracker Sizer
        local trackerHeightByRatio = GetScreenHeight() * Questie.db.global.trackerHeightRatio
        local trackerHeightByManual = Questie.db[Questie.db.global.questieTLoc].TrackerHeight

        -- Set the trackerBaseFrame to full height so we can measure it
        if Questie.db.global.trackerHeaderEnabled then
            trackerBaseFrame:SetHeight(trackerQuestFrame:GetHeight() + trackerHeaderFrame:GetHeight() + 20)
        else
            trackerBaseFrame:SetHeight(trackerQuestFrame:GetHeight() + 20)
        end

        if trackerHeightByManual > 0 then
            -- Manual height set by a player when using the Tracker Sizer limited by the trackers current maximum height
            if trackerBaseFrame:GetHeight() > trackerHeightByManual then
                trackerBaseFrame:SetHeight(trackerHeightByManual)
                trackerQuestFrame.ScrollChildFrame:SetSize(trackerVarsCombined, (TrackerLinePool.GetFirstLine():GetTop() - TrackerLinePool.GetCurrentLine():GetBottom() + 3))

                -- Resize the trackerQuestFrame to match the trackerbaseFrame after the player is done resizing it
                if Questie.db.global.trackerHeaderEnabled then
                    -- With Header Frame
                    trackerQuestFrame:SetHeight(trackerBaseFrame:GetHeight() - trackerHeaderFrame:GetHeight() - 20)
                else
                    -- Without Header Frame
                    trackerQuestFrame:SetHeight(trackerBaseFrame:GetHeight() - 20)
                end
            end
        else
            -- If the trackerBaseFrame is larger than the trackerHeightRatio then resize
            if trackerBaseFrame:GetHeight() > trackerHeightByRatio then
                -- Auto height based on the trackerHeightRatio setting in Questie Config --> Tracker
                trackerBaseFrame:SetHeight(trackerHeightByRatio)
                trackerQuestFrame.ScrollChildFrame:SetSize(trackerVarsCombined, (TrackerLinePool.GetFirstLine():GetTop() - TrackerLinePool.GetCurrentLine():GetBottom() + 3))

                -- Resize the trackerQuestFrame to match the trackerbaseFrame after the trackerHeightRatio is applied
                if Questie.db.global.trackerHeaderEnabled then
                    -- With Header Frame
                    trackerQuestFrame:SetHeight(trackerBaseFrame:GetHeight() - trackerHeaderFrame:GetHeight() - 20)
                else
                    -- Without Header Frame
                    trackerQuestFrame:SetHeight(trackerBaseFrame:GetHeight() - 20)
                end
            end
        end

        TrackerQuestFrame:Update()
    end

    QuestieTracker:CheckDurabilityAlertStatus()
    TrackerBaseFrame:Update()
end

function QuestieTracker:UpdateWidth(trackerVarsCombined)
    local trackerHeaderFrameWidth = trackerHeaderFrame:GetWidth() + Questie.db.global.trackerFontSizeHeader + 10
    local trackerBaseFrameWidth = trackerBaseFrame:GetWidth()
    local trackerWidthByManual = Questie.db[Questie.db.global.questieTLoc].TrackerWidth

    if trackerWidthByManual > 0 then
        -- Manual width set by a player using the Tracker Sizer
        if (not TrackerBaseFrame.isSizing) and (trackerWidthByManual < trackerHeaderFrameWidth) then
            trackerBaseFrame:SetWidth(trackerHeaderFrameWidth)
            Questie.db[Questie.db.global.questieTLoc].TrackerWidth = trackerHeaderFrameWidth
        elseif (not TrackerBaseFrame.isSizing) and (trackerWidthByManual ~= trackerBaseFrameWidth) then
            trackerBaseFrame:SetWidth(trackerWidthByManual)
        end
    else
        -- Auto width based on the maximum size of the largest line in the tracker
        if (trackerVarsCombined < trackerHeaderFrameWidth and Questie.db.global.trackerHeaderEnabled) then
            trackerBaseFrame:SetWidth(trackerHeaderFrameWidth)
        else
            trackerBaseFrame:SetWidth(trackerVarsCombined)
        end
    end
end

function QuestieTracker:Unhook()
    if (not QuestieTracker.alreadyHooked) then
        return
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:Unhook")

    QuestieTracker.disableHooks = true

    TrackerQuestTimers:ShowBlizzardTimer()

    -- ScrollFrame Hooks
    UIPanelScrollBar_OnValueChanged = QuestieTracker.UIPanelScrollBar_OnValueChanged

    -- Quest Hooks
    if QuestieTracker.IsQuestWatched then
        IsQuestWatched = QuestieTracker.IsQuestWatched
        GetNumQuestWatches = QuestieTracker.GetNumQuestWatches
    end

    -- Achievement Hooks
    if Questie.IsWotlk then
        if QuestieTracker.IsTrackedAchievement then
            IsTrackedAchievement = QuestieTracker.IsTrackedAchievement
            GetNumTrackedAchievements = QuestieTracker.GetNumTrackedAchievements
        end
    end

    QuestieTracker.alreadyHooked = nil
end

function QuestieTracker:HookBaseTracker()
    if QuestieTracker.alreadyHooked then
        return
    end

    QuestieTracker.disableHooks = nil

    if not QuestieTracker.alreadyHookedSecure then
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:HookBaseTracker - Secure hooks")

        -- Durability Frame hook
        hooksecurefunc("UIParent_ManageFramePositions", QuestieTracker.MoveDurabilityFrame)

        -- QuestWatch secure hook
        if AutoQuestWatch_Insert then
            hooksecurefunc("AutoQuestWatch_Insert", function(index, watchTimer) QuestieTracker:AQW_Insert(index, watchTimer) end)
        end

        hooksecurefunc("AddQuestWatch", function(index, watchTimer) QuestieTracker:AQW_Insert(index, watchTimer) end)
        hooksecurefunc("RemoveQuestWatch", QuestieTracker.RemoveQuestWatch)

        -- Achievement secure hooks
        if Questie.IsWotlk then
            hooksecurefunc("AddTrackedAchievement", function(achieveId) QuestieTracker:TrackAchieve(achieveId) end)
            hooksecurefunc("RemoveTrackedAchievement", QuestieTracker.RemoveTrackedAchievement)
        end

        QuestieTracker.alreadyHookedSecure = true
    end

    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:HookBaseTracker - Non-secure hooks")

    -- ScrollFrame Hooks
    QuestieTracker.UIPanelScrollBar_OnValueChanged = UIPanelScrollBar_OnValueChanged
    UIPanelScrollBar_OnValueChanged = function(self, value)
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UIPanelScrollBar_OnValueChanged")
        if InCombatLockdown() then
            return
        else
            self:GetParent():SetVerticalScroll(value)
        end
    end

    -- Quest Hooks
    if not QuestieTracker.IsQuestWatched then
        QuestieTracker.IsQuestWatched = IsQuestWatched
        QuestieTracker.GetNumQuestWatches = GetNumQuestWatches
    end

    -- Intercept and return a Questie boolean value
    IsQuestWatched = function(index)
        local questId = select(8, GetQuestLogTitle(index))
        if questId == 0 then
            -- When an objective progresses in TBC "index" is the questId, but when a quest is manually added to the quest watch
            -- (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
            questId = index
        end

        if not Questie.db.global.autoTrackQuests then
            return Questie.db.char.TrackedQuests[questId or -1]
        else
            return questId and QuestiePlayer.currentQuestlog[questId] and (not Questie.db.char.AutoUntrackedQuests[questId])
        end
    end

    -- Intercept and return only what Questie is tracking
    GetNumQuestWatches = function(isQuestie)
        local activeQuests = 0
        if isQuestie and Questie.db.global.autoTrackQuests and Questie.db.char.AutoUntrackedQuests then
            local autoUnTrackedQuests = 0
            for _ in pairs(Questie.db.char.AutoUntrackedQuests) do
                autoUnTrackedQuests = autoUnTrackedQuests + 1
            end
            return select(2, GetNumQuestLogEntries()) - autoUnTrackedQuests
        elseif isQuestie and Questie.db.char.TrackedQuests then
            local autoTrackedQuests = 0
            for _ in pairs(Questie.db.char.TrackedQuests) do
                autoTrackedQuests = autoTrackedQuests + 1
            end
            return autoTrackedQuests
        else
            return 0
        end
    end

    -- Achievement Hooks
    if Questie.IsWotlk then
        if not QuestieTracker.IsTrackedAchievement then
            QuestieTracker.IsTrackedAchievement = IsTrackedAchievement
            QuestieTracker.GetNumTrackedAchievements = GetNumTrackedAchievements
        end

        -- Intercept and return a Questie boolean value
        IsTrackedAchievement = function(achieveId)
            if Questie.db.char.trackedAchievementIds[achieveId] then
                return achieveId and Questie.db.char.trackedAchievementIds[achieveId]
            else
                return false
            end
        end

        -- Intercept and return only what Questie is tracking
        GetNumTrackedAchievements = function(isQuestie)
            if isQuestie and Questie.db.char.trackedAchievementIds then
                local numTrackedAchievements = 0
                for _ in pairs(Questie.db.char.trackedAchievementIds) do
                    numTrackedAchievements = numTrackedAchievements + 1
                end
                return numTrackedAchievements
            else
                return 0
            end
        end
    end

    if Questie.db.global.showBlizzardQuestTimer then
        TrackerQuestTimers:ShowBlizzardTimer()
    else
        TrackerQuestTimers:HideBlizzardTimer()
    end

    QuestieTracker.alreadyHooked = true
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

function QuestieTracker:RemoveQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:RemoveQuest")
    if Questie.db.char.collapsedQuests then
        Questie.db.char.collapsedQuests[questId] = nil
    end

    if Questie.db.char.TrackerFocus then
        if (type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == questId)
            or (type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus:sub(1, #tostring(questId)) == tostring(questId)) then
            TrackerUtils:UnFocus()
            QuestieQuest:ToggleNotes(true)
        end
    end
end

function QuestieTracker.RemoveQuestWatch(index, isQuestie)
    if QuestieTracker.disableHooks then
        return
    end

    if not isQuestie then
        if index then
            local questId = select(8, GetQuestLogTitle(index))
            if questId == 0 then
                -- When an objective progresses in TBC "index" is the questId, but when a quest is manually removed from
                --  the quest watch (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
                questId = index
            end

            if questId then
                QuestieTracker:UntrackQuestId(questId)
                Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker.RemoveQuestWatch (by Blizzard)")
            end
        end
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker.RemoveQuestWatch (by Questie)")
    end
end

function QuestieTracker:UntrackQuestId(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UntrackQuestId")
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
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:AQW_Insert")
    if (not Questie.db.char.trackerEnabled) or (index == 0) or (index == nil) then
        return
    end

    -- This prevents double calling this function
    local now = GetTime()
    if index and index == QuestieTracker.last_aqw and (now - lastAQW) < 0.1 then
        return
    end

    lastAQW = now
    QuestieTracker.last_aqw = index

    -- This removes quests from the Blizzard QuestWatchFrame so when the option "Show Blizzard Timer" is enabled,
    -- that is all the player will see. This also prevents hitting the Blizzard Quest Watch Limit.
    RemoveQuestWatch(index, true)

    local questId = select(8, GetQuestLogTitle(index))
    if questId == 0 then
        -- When an objective progresses in TBC "index" is the questId, but when a quest is manually added to the quest watch
        -- (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
        questId = index
    end

    if questId > 0 then
        -- These checks makes sure the only way to track a quest is through the Blizzard Quest Log
        -- or another Addon hooked into the Blizzard Quest Log that replaces the default Quest Log.
        if not Questie.db.global.autoTrackQuests then
            if Questie.db.char.TrackedQuests[questId] then
                Questie.db.char.TrackedQuests[questId] = nil
            else
                -- Add quest to the tracker
                Questie.db.char.TrackedQuests[questId] = true
            end
        else
            if Questie.db.char.AutoUntrackedQuests[questId] then
                Questie.db.char.AutoUntrackedQuests[questId] = nil

                -- Add quest to the tracker
            elseif IsShiftKeyDown() and QuestLogFrame:IsShown() then
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

        if Questie.db.char.hideUntrackedQuestsMapIcons then
            -- Quest had its Icons removed, paint them again
            QuestieQuest:PopulateObjectiveNotes(quest)
        end
    end
    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

QuestieTracker.RemoveTrackedAchievement = function(achieveId, isQuestie)
    if QuestieTracker.disableHooks then
        return
    end

    if not isQuestie then
        if achieveId then
            QuestieTracker:UntrackAchieveId(achieveId)
            Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker.RemoveTrackedAchievement (by Blizzard)")
        end
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker.RemoveTrackedAchievement (by Questie)")
    end
end

function QuestieTracker:UpdateAchieveTrackerCache(achieveId)
    -- Since we're essentially adding & force removing an achievement from the QuestWatch frame while we add an achievement to the Questie Tracker, the event this
    -- function is called from, TRACKED_ACHIEVEMENT_LIST_CHANGED, fires twice. When we remove an achievement from the Questie Tracker the event still fires twice
    -- because the Blizzard function responsible for this is essentially a "toggle". It quickly re-adds the achievement to the QuestWatch frame and then removes it.
    -- So, again this event again fires twice. We only need to allow this to run once and it often fires before the Questie.db.char.trackedAchievementIds table is
    -- updated so we're going to throttle this 1/10th of a second.
    if Questie.db.char.trackerEnabled then
        if achieveId then
            C_Timer.After(0.1, function()
                Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UpdateAchieveTrackerCache for ID ", achieveId)

                if (not Questie.db.char.trackerEnabled) or (achieveId == 0) then
                    return
                end

                -- Look for changes in the Saved VAR and update the achievement cache
                if Questie.db.char.trackedAchievementIds[achieveId] ~= trackedAchievementIds[achieveId] then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UpdateAchieveTrackerCache - Change Detected!")

                    trackedAchievementIds[achieveId] = Questie.db.char.trackedAchievementIds[achieveId]

                    QuestieCombatQueue:Queue(function()
                        QuestieTracker:Update()
                    end)
                else
                    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UpdateAchieveTrackerCache - No Change Detected!")
                end
            end)
        end
    end
end

function QuestieTracker:UntrackAchieveId(achieveId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:UntrackAchieve")
    if Questie.db.char.trackedAchievementIds[achieveId] then
        Questie.db.char.trackedAchievementIds[achieveId] = nil
    end
end

function QuestieTracker:TrackAchieve(achieveId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker:TrackAchieve")
    if (not Questie.db.char.trackerEnabled) or (achieveId == 0) then
        return
    end

    -- If an achievement is already tracked in the Achievement UI then untrack it (Mimicks a Toggle effect).
    if Questie.db.char.trackedAchievementIds[achieveId] then
        QuestieTracker:UntrackAchieveId(achieveId)
        RemoveTrackedAchievement(achieveId, true)
        return
    end

    -- Prevents tracking more than 10 Achievements
    if (GetNumTrackedAchievements(true) == 10) then
        RemoveTrackedAchievement(achieveId, true)
        UIErrorsFrame:AddMessage(format(l10n("You may only track 10 achievements at a time."), 10), 1.0, 0.1, 0.1, 1.0)
        return
    end

    -- This prevents double calling this function
    local now = GetTime()
    if achieveId and achieveId == QuestieTracker.last_achieveId and (now - lastAchieveId) < 0.1 then
        return
    end

    lastAchieveId = now
    QuestieTracker.last_achieveId = achieveId

    -- This removes achievements from the Blizzard QuestWatchFrame so when the
    -- option "Show Blizzard Timer" is enabled, that is all the player will see.
    RemoveTrackedAchievement(achieveId, true)

    if achieveId > 0 then
        -- This handles the Track check box in the Achievement UI
        local mouseFocus = GetMouseFocus():GetName()
        local frameMatch = strmatch(mouseFocus, "(AchievementFrameAchievementsContainerButton%dTracked.*)")

        -- Upon first login or reloadui, this frame isn't loaded
        if (not AchievementFrame) then
            AchievementFrame_LoadUI()
        end

        -- This check makes sure the only way to track an achieve is through the Blizzard Achievement UI
        if Questie.db.char.trackedAchievementIds[achieveId] then
            Questie.db.char.trackedAchievementIds[achieveId] = nil
        elseif IsShiftKeyDown() and AchievementFrame:IsShown() then
            Questie.db.char.trackedAchievementIds[achieveId] = true
        elseif AchievementFrame:IsShown() and (mouseFocus == frameMatch) then
            Questie.db.char.trackedAchievementIds[achieveId] = true
        end

        -- Forces the achievement out of a minimized state
        if Questie.db.char.collapsedQuests[achieveId] == true then
            Questie.db.char.collapsedQuests[achieveId] = nil
        end

        -- Forces the 'Achievement Zone' out of a minimized state
        if Questie.db.char.collapsedZones["Achievements"] == true then
            Questie.db.char.collapsedZones["Achievements"] = nil
        end
    end
end
