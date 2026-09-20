-- Loaded only by Camelot, before consumers cache compatibility methods and embedded libraries load.
-- First-party translations stay on QuestieCompat; only AceGUI spell/texture calls need global bridges.
---@class QuestieForever
local QuestieForever = QuestieLoader:CreateModule("QuestieForever")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@param index number Quest-log index, not quest ID.
---@return any ... Legacy GetQuestLogTitle tuple; incomplete quests return nil, not zero, for completion.
function QuestieForever.GetQuestLogTitle(index)
    if not index or index <= 0 then return nil end
    local info = C_QuestLog.GetInfo(index)
    if not info then
        return nil
    end
    local complete
    local questTag
    if not info.isHeader then
        local tag = C_QuestLog.GetQuestTagInfo and C_QuestLog.GetQuestTagInfo(info.questID)
        questTag = tag and tag.tagName
        if C_QuestLog.IsFailed(info.questID) then
            complete = -1
        elseif C_QuestLog.IsComplete(info.questID) then
            complete = 1
        end
    end
    return info.title, info.level, questTag, info.isHeader, info.isCollapsed, complete,
        info.frequency, info.questID, info.startEvent, info.questID, info.isOnMap, info.hasLocalPOI,
        info.isTask, info.isBounty, info.isStory, info.isHidden, info.isScaling
end

---@param completed table<number, boolean>? Existing result table to populate.
---@return table<number, boolean>
function QuestieForever.GetQuestsCompleted(completed)
    completed = completed or {}
    for _, questID in ipairs(C_QuestLog.GetAllCompletedQuestIDs()) do
        completed[questID] = true
    end
    return completed
end

---@return number ... Timers in seconds, or no values when there are no timed quests.
function QuestieForever.GetQuestTimers()
    local timers = {}
    for _, info in ipairs(C_QuestLog.GetQuestTimers()) do
        timers[#timers + 1] = info.questTimer
    end
    return unpack(timers)
end

---@param questID number
---@return number Log index, or zero when absent, as on Classic.
function QuestieForever.GetQuestLogIndexByID(questID)
    return C_QuestLog.GetLogIndexForQuestID(questID) or 0
end

---@param index number
---@return number? questID
local function QuestIDFromIndex(index)
    if not index or index <= 0 then return nil end
    local info = C_QuestLog.GetInfo(index)
    return info and not info.isHeader and info.questID or nil
end

---@param index number
---@return nil
function QuestieForever.SelectQuestLogEntry(index)
    local questID = QuestIDFromIndex(index)
    if questID then
        C_QuestLog.SetSelectedQuest(questID)
    end
end

---@return number
function QuestieForever.GetQuestLogSelection()
    local questID = C_QuestLog.GetSelectedQuest()
    return (questID and C_QuestLog.GetLogIndexForQuestID(questID)) or 0
end

---@param watchIndex number
---@return number? Log index, not quest ID.
function QuestieForever.GetQuestIndexForWatch(watchIndex)
    local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(watchIndex)
    return questID and C_QuestLog.GetLogIndexForQuestID(questID) or nil
end

---@param index number
---@return boolean
function QuestieForever.IsQuestWatched(index)
    local questID = QuestIDFromIndex(index)
    return questID ~= nil and C_QuestLog.GetQuestWatchType(questID) ~= nil
end

---@param index number
---@return boolean? added
function QuestieForever.AddQuestWatch(index)
    local questID = QuestIDFromIndex(index)
    if questID then
        return C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Manual)
    end
end

---@param index number
---@return boolean? removed
function QuestieForever.RemoveQuestWatch(index)
    local questID = QuestIDFromIndex(index)
    if questID then
        return C_QuestLog.RemoveQuestWatch(questID)
    end
end

---@param questID number
---@return any ... Legacy quest tag tuple.
function QuestieForever.GetQuestTagInfo(questID)
    local info = C_QuestLog.GetQuestTagInfo(questID)
    if info then
        return info.tagID, info.tagName, info.worldQuestType, info.quality, info.isElite,
            info.tradeskillLineID, info.displayExpiration
    end
end

---@param info table?
---@return any ... Legacy faction tuple.
local function FactionTuple(info)
    if info then
        return info.name, info.description, info.reaction, info.currentReactionThreshold, info.nextReactionThreshold,
            info.currentStanding, info.atWarWith, info.canToggleAtWar, info.isHeader, info.isCollapsed,
            info.isHeaderWithRep, info.isWatched, info.isChild, info.factionID, info.hasBonusRepGain, info.canSetInactive
    end
end

---@param index number
---@return any ...
function QuestieForever.GetFactionInfo(index)
    return FactionTuple(C_Reputation.GetFactionDataByIndex(index))
end

---@param factionID number
---@return any ...
function QuestieForever.GetFactionInfoByID(factionID)
    return FactionTuple(C_Reputation.GetFactionDataByID(factionID))
end

---@param spell number|string
---@return any ... Legacy spell-info tuple.
function QuestieForever.GetSpellInfo(spell)
    local info = C_Spell.GetSpellInfo(spell)
    if info then
        return info.name, nil, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID
    end
end

---@param unit string
---@param index number
---@param filter string?
---@return any ... Legacy aura tuple, including spell ID at position ten.
function QuestieForever.UnitAura(unit, index, filter)
    return AuraUtil.UnpackAuraData(C_UnitAuras.GetAuraDataByIndex(unit, index, filter))
end

---@param frame Region
---@param ... number Optional top, bottom, left, and right offsets.
---@return boolean
function QuestieForever.MouseIsOver(frame, ...)
    return frame:IsMouseOver(...)
end

---@param texture Texture
---@param desaturated boolean
---@return nil
function QuestieForever.SetDesaturation(texture, desaturated)
    texture:SetDesaturated(desaturated)
end

-- First-party consumers import these wrappers; Blizzard globals remain untouched.
QuestieCompat.GetQuestTimers = QuestieForever.GetQuestTimers
QuestieCompat.GetQuestGreenRange = UnitQuestTrivialLevelRange
QuestieCompat.GetQuestsCompleted = QuestieForever.GetQuestsCompleted
QuestieCompat.GetQuestLogTitle = QuestieForever.GetQuestLogTitle
QuestieCompat.GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
QuestieCompat.GetQuestLogIndexByID = QuestieForever.GetQuestLogIndexByID
QuestieCompat.GetQuestIDFromLogIndex = QuestIDFromIndex
QuestieCompat.SelectQuestLogEntry = QuestieForever.SelectQuestLogEntry
QuestieCompat.GetQuestLogSelection = QuestieForever.GetQuestLogSelection
QuestieCompat.GetQuestIndexForWatch = QuestieForever.GetQuestIndexForWatch
QuestieCompat.IsQuestWatched = QuestieForever.IsQuestWatched
QuestieCompat.AddQuestWatch = QuestieForever.AddQuestWatch
QuestieCompat.RemoveQuestWatch = QuestieForever.RemoveQuestWatch
QuestieCompat.GetQuestTagInfo = QuestieForever.GetQuestTagInfo
QuestieCompat.GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
QuestieCompat.UnitAura = QuestieForever.UnitAura
QuestieCompat.MouseIsOver = QuestieForever.MouseIsOver
QuestieCompat.GetFactionInfo = QuestieForever.GetFactionInfo
QuestieCompat.GetFactionInfoByID = QuestieForever.GetFactionInfoByID
QuestieCompat.GetNumFactions = C_Reputation.GetNumFactions
QuestieCompat.ExpandFactionHeader = C_Reputation.ExpandFactionHeader

-- Embedded AceGUI widgets still call the legacy spell and texture globals.
GetSpellInfo = GetSpellInfo or QuestieForever.GetSpellInfo
SetDesaturation = SetDesaturation or QuestieForever.SetDesaturation

-- The modern tracker can show itself on every content update. Keep suppression owned and reversible,
-- and defer visibility changes during combat rather than interfering with protected objective buttons.
local hideObjectiveTracker = false
local objectiveTrackerHooked = false
local visibilityFrame = CreateFrame("Frame")

---@return nil
local function ApplyObjectiveTrackerVisibility()
    if InCombatLockdown() then
        visibilityFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    visibilityFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if ObjectiveTrackerFrame then
        if hideObjectiveTracker then
            ObjectiveTrackerFrame:Hide()
        else
            -- Release to Blizzard's content/edit-mode policy instead of forcing an empty tracker to show.
            ObjectiveTrackerFrame:Update()
        end
    end
end
visibilityFrame:SetScript("OnEvent", ApplyObjectiveTrackerVisibility)

---@return nil
function QuestieCompat.HideWatchFrame()
    hideObjectiveTracker = true
    if ObjectiveTrackerFrame and not objectiveTrackerHooked then
        ObjectiveTrackerFrame:HookScript("OnShow", function()
            if hideObjectiveTracker then
                ApplyObjectiveTrackerVisibility()
            end
        end)
        objectiveTrackerHooked = true
    end
    ApplyObjectiveTrackerVisibility()
end

---@return nil
function QuestieCompat.ShowWatchFrame()
    if hideObjectiveTracker then
        hideObjectiveTracker = false
        ApplyObjectiveTrackerVisibility()
    end
end

---@return any ... Frame anchor tuple.
function QuestieCompat.GetWatchFramePoint()
    return ObjectiveTrackerFrame:GetPoint()
end
