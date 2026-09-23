---@diagnostic disable: undefined-global, return-type-mismatch, undefined-field
---@class QuestieCompat
local QuestieCompat = QuestieLoader:CreateModule("QuestieCompat")

-- Source baselines: Era 1.15.9 (69722), Anniversary 2.5.6 (69795), Mists 5.5.4 (69585),
-- Titan 3.80.2 (69874), Forever 1.60.1 (69913). See FOREVER_WORK_LEFT_TO_DO.md for pinned sources and caveats.
-- These are inspected builds, not minimum supported versions. API selection is generally capability-based;
-- explicit Forever and Titan branches preserve client-specific behavior. Namespaces also exist on Classic,
-- and older fallback cutoffs are not established.
-- Item/container/gossip/date APIs have modern paths on these baselines; quest-log/reputation contracts still differ.
-- Keep calls dynamic where legacy globals may be replaced by tracker hooks after this module loads.

local errorMsg = "Questie tried to call a blizzard API function that does not exist..."
local INDIZES_AVAILABLE = 7
local INDIZES_ACTIVE = 6

local tinsert = table.insert

-- Compatibility loads before VersionCheck and embedded libraries, so Questie.IsForever is not available yet.
-- Forever shares Retail's project ID; use the same interface range as VersionCheck instead.
local _, _, _, interfaceVersion = GetBuildInfo()
local isForever = interfaceVersion >= 16000 and interfaceVersion < 17000

-- QuestieDB loads later; the loader returns the module table that its owning file will populate.
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local WatchFrame = QuestWatchFrame or WatchFrame

------------------------------------------
-- Missing startup globals
------------------------------------------

-- VersionCheck needs a nonseasonal answer when this namespace is absent, including older Era builds.
-- Native Forever season support is not established; a post-load presence check may only see this shim.
if not C_Seasons then
    C_Seasons = {
        ---[C_Seasons.HasActiveSeason Documentation](https://warcraft.wiki.gg/wiki/API_C_Seasons.HasActiveSeason)
        ---Reports no active season when the client has no season API.
        ---@return boolean hasActiveSeason Always false.
        HasActiveSeason = function()
            return false
        end,
        ---[C_Seasons.GetActiveSeason Documentation](https://warcraft.wiki.gg/wiki/API_C_Seasons.GetActiveSeason)
        ---Returns "no season" when the client has no season API.
        ---@return number seasonID Always 0 (NoSeason).
        GetActiveSeason = function()
            return 0
        end
    }
end

-- Embedded dropdowns need a backdrop mixin before they load. Inspected builds supply the tooltip subclass;
-- older builds fall back to the base backdrop, without claiming identical tooltip styling.
if not TooltipBackdropTemplateMixin then
    TooltipBackdropTemplateMixin = BackdropTemplateMixin
end

-------------------------------------------
-- Capability-selected API contracts
-------------------------------------------

---[SetMinResize Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetMinResize)
---[SetMaxResize Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetMaxResize)
---[SetResizeBounds Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetResizeBounds)
---Sets the minimum and optional maximum size a frame can be resized to.
---@param frame frame
---@param minWidth number The minimum width the object can be resized to.
---@param minHeight number The minimum height the object can be resized to.
---@param maxWidth number? The maximum width the object can be resized to.
---@param maxHeight number? The maximum height the object can be resized to.
function QuestieCompat.SetResizeBounds(frame, minWidth, minHeight, maxWidth, maxHeight)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
        return
    else
        -- Older setters leave the corresponding bounds unchanged when width is nil or zero.
        if frame.SetMinResize and frame.SetMaxResize then
            if minWidth and minWidth ~= 0 then
                frame:SetMinResize(minWidth, minHeight)
            end
            if maxWidth and maxWidth ~= 0 then
                frame:SetMaxResize(maxWidth, maxHeight)
            end
            return
        end
    end
    error(errorMsg, 2)
end

---Returns quests available to accept from the gossip window.
---@return GossipQuestUIInfo[]
function QuestieCompat.GetAvailableQuests()
    if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        return C_GossipInfo.GetAvailableQuests()
    elseif GetGossipAvailableQuests then
        -- Convert the flat list to records; unavailable quest IDs use 0.
        local info = {GetGossipAvailableQuests()}
        local availableQuests = {}
        for i = 1, #info, INDIZES_AVAILABLE do
            local quest = {
                title = info[i],
                questLevel = info[i + 1],
                isTrivial = info[i + 2],
                frequency = info[i + 3],
                repeatable = info[i + 4],
                isLegendary = info[i + 5],
                isIgnored = info[i + 6],
                isImportant = false, -- Not available from GetGossipAvailableQuests
                isMeta = false, -- Not available from GetGossipAvailableQuests
                questID = 0, -- Not available from GetGossipAvailableQuests
            }
            tinsert(availableQuests, quest)
        end
        return availableQuests
    end
    error(errorMsg, 2)
end

---Returns accepted quests listed by the current gossip NPC, including incomplete quests.
---@return GossipQuestUIInfo[]
function QuestieCompat.GetActiveQuests()
    if C_GossipInfo and C_GossipInfo.GetActiveQuests then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        -- Also mark quests complete when Questie's quest state reports completion.
        for _, quest in pairs(activeQuests) do
            quest.isComplete = quest.isComplete or QuestieDB.IsComplete(quest.questID) == 1
        end
        return activeQuests
    elseif GetGossipActiveQuests then
        -- The legacy list has no quest IDs; use 0 for the unavailable ID.
        local info = {GetGossipActiveQuests()}
        local activeQuests = {}

        for i = 1, #info, INDIZES_ACTIVE do
            local quest = {
                title = info[i],
                questLevel = info[i + 1],
                isTrivial = info[i + 2],
                isComplete = info[i + 3],
                isLegendary = info[i + 4],
                isIgnored = info[i + 5],
                frequency = nil, -- Not available from GetGossipActiveQuests
                repeatable = false, -- Not available from GetGossipActiveQuests
                isImportant = false, -- Not available from GetGossipActiveQuests
                isMeta = false, -- Not available from GetGossipActiveQuests
                questID = 0, -- Not available from GetGossipActiveQuests
            }
            tinsert(activeQuests, quest)
        end
        return activeQuests
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectAvailableQuest)
---Selects an available quest from the gossip window.
---@param index number Valid position in the current available quest list, not a quest ID.
function QuestieCompat.SelectAvailableQuest(index)
    if C_GossipInfo and C_GossipInfo.SelectAvailableQuest then
        -- The modern API takes a quest ID; the legacy selector takes the list position.
        local questId = C_GossipInfo.GetAvailableQuests()[index].questID
        return C_GossipInfo.SelectAvailableQuest(questId)
    elseif SelectGossipAvailableQuest then
        return SelectGossipAvailableQuest(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectActiveQuest)
---Opens an accepted quest from the gossip window.
---@param index number Valid position in the current active quest list, not a quest ID.
function QuestieCompat.SelectActiveQuest(index)
    if C_GossipInfo and C_GossipInfo.SelectActiveQuest then
        -- The modern API takes a quest ID; the legacy selector takes the list position.
        local questId = C_GossipInfo.GetActiveQuests()[index].questID
        return C_GossipInfo.SelectActiveQuest(questId)
    elseif SelectGossipActiveQuest then
        return SelectGossipActiveQuest(index)
    end
    error(errorMsg, 2)
end

---Returns a quest ID from the current quest-greeting list, or 0 if it cannot be resolved.
---@param index number Position within the active or available list, not a quest-log index.
---@param isActive boolean True for an accepted quest, false for an available quest.
---@param npcGuid string? GUID of the NPC whose greeting is open.
---@return QuestId questID
function QuestieCompat.GetQuestGreetingQuestID(index, isActive, npcGuid)
    local questID
    if isActive and _G.GetActiveQuestID then
        questID = _G.GetActiveQuestID(index)
    elseif not isActive and _G.GetAvailableQuestInfo then
        -- Forever includes the quest ID in position 5; older Classic tuples end before it.
        questID = select(5, _G.GetAvailableQuestInfo(index))
    end
    if questID and questID > 0 then
        return questID
    end

    -- Classic greeting APIs expose titles rather than IDs. Keep the NPC and starter/finisher context.
    local title
    if isActive then
        title = GetActiveTitle(index)
    else
        title = GetAvailableTitle(index)
    end
    if not title or title == "" then
        return 0
    end
    return QuestieDB.GetQuestIDFromName(title, npcGuid, not isActive) or 0
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetContainerNumSlots)
---Returns the total number of slots in a bag, including empty slots.
---@param bagID number Bag identifier; 0 is the backpack.
---@return number numberOfSlots
function QuestieCompat.GetContainerNumSlots(bagID)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bagID)
    elseif GetContainerNumSlots then
        return GetContainerNumSlots(bagID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetContainerItemInfo)
---Returns information about the item in a bag slot, or nil if the slot is empty.
---@param bagID number BagID of the bag the item is in, e.g. 0 for your backpack.
---@param slot number index of the slot inside the bag to look up.
---@return number? texture The icon texture (FileID) for the item in the specified bag slot.
---@return number? itemCount The number of items in the specified bag slot.
---@return boolean? locked True if the item is locked by the server, false otherwise.
---@return number? quality The Quality of the item.
---@return boolean? readable True if the item can be "read" (as in a book), false otherwise.
---@return boolean? lootable True if the item is a temporary container containing items that can be looted, false otherwise.
---@return string? itemLink The itemLink of the item in the specified bag slot.
---@return boolean? isFiltered True if the item is grayed-out during the current inventory search, false otherwise.
---@return boolean? noValue True if the item has no gold value, false otherwise.
---@return number? itemID The unique ID for the item in the specified bag slot.
---@return boolean? isBound True if the item is bound to the current character, false otherwise.
function QuestieCompat.GetContainerItemInfo(bagID, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        -- Convert the record to positional returns; callers expect item ID in position 10.
        local containerInfo = C_Container.GetContainerItemInfo(bagID, slot)
        if containerInfo then
            return containerInfo.iconFileID,
                containerInfo.stackCount,
                containerInfo.isLocked,
                containerInfo.quality,
                containerInfo.isReadable,
                containerInfo.hasLoot,
                containerInfo.hyperlink,
                containerInfo.isFiltered,
                containerInfo.hasNoValue,
                containerInfo.itemID,
                containerInfo.isBound
        else
            return nil
        end
    elseif GetContainerItemInfo then
        return GetContainerItemInfo(bagID, slot)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetItemCooldown)
---Returns an item's cooldown start time, duration, and enabled flag.
---@param itemID number The item ID.
---@return number? startTime Cooldown start (GetTime units), or zero when no cooldown.
---@return number? duration Cooldown seconds, or zero when no cooldown.
---@return number|boolean|nil enable Numeric 1/0 on the container/legacy paths; boolean on the C_Item fallback.
function QuestieCompat.GetItemCooldown(itemID)
    if C_Container and C_Container.GetItemCooldown then
        return C_Container.GetItemCooldown(itemID)
    elseif C_Item and C_Item.GetItemCooldown then
        -- Forever's C_Item API returns a boolean flag, unlike C_Container's number.
        -- Forwarded unchanged here; TrackerItemButton currently expects numeric 1.
        return C_Item.GetItemCooldown(itemID)
    else
        return GetItemCooldown(itemID)
    end
end

---Returns the first UI region receiving mouse input, or nil if none.
---@return ScriptRegion? focus
function QuestieCompat.GetMouseFocus()
    if GetMouseFoci then
        -- The newer API returns a list; preserve the legacy single-result interface.
        return GetMouseFoci()[1]
    else
        return GetMouseFocus()
    end
end

---@class CalendarTime
---@field monthDay number
---@field month number
---@field year number
---@field weekday number
---@field hour number
---@field minute number

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetCurrentCalendarTime)
---Returns the current calendar date and time.
---@return CalendarTime
function QuestieCompat.GetCurrentCalendarTime()
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        return C_DateAndTime.GetCurrentCalendarTime()
    elseif C_DateAndTime and C_DateAndTime.GetTodaysDate then
        -- Match the modern field names. This older API has no time of day,
        -- so hour and minute default to midnight.
        local today = C_DateAndTime.GetTodaysDate()
        return {
            monthDay = today.day,
            month = today.month,
            year = today.year,
            weekday = today.weekDay,
            hour = 0,
            minute = 0,
        }
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellBook.IsSpellKnown)
---Returns whether the player knows a spell.
---@param spellID number The spell ID.
---@return boolean isKnown True if the player knows the spell/profession spell, false otherwise
function QuestieCompat.IsSpellKnown(spellID)
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(spellID)
    else
        -- IsPlayerSpell matches the modern knowledge check.
        -- Legacy IsSpellKnown checks spellbook membership instead.
        return IsPlayerSpell(spellID)
    end
end

-- Forever's objective tracker can show itself during content updates. Own suppression only while requested,
-- and defer protected visibility changes until combat ends. Classic keeps its existing WatchFrame policy.
local hideObjectiveTracker = false
local objectiveTrackerHooked = false
local visibilityFrame

---Hides Blizzard's tracker when requested, or lets Blizzard restore its normal visibility.
local function ApplyObjectiveTrackerVisibility()
    if InCombatLockdown() then
        -- Retry after combat using the latest request, not the state when combat began.
        visibilityFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    visibilityFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if ObjectiveTrackerFrame then
        if hideObjectiveTracker then
            ObjectiveTrackerFrame:Hide()
        else
            -- Forever: let Blizzard decide whether content/edit mode requires a visible tracker.
            ObjectiveTrackerFrame:Update()
        end
    end
end

if isForever then
    visibilityFrame = CreateFrame("Frame")
    visibilityFrame:SetScript("OnEvent", ApplyObjectiveTrackerVisibility)
end

---Hides Blizzard's quest tracker, waiting until combat ends on Forever.
function QuestieCompat.HideWatchFrame()
    if isForever then
        -- Forever: keep later native OnShow calls suppressed, without reparenting protected frames.
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
    elseif Questie.IsTitanReforged then
        -- On titan reforged realms, the WatchFrame somehow behaves differently when hidden.
        -- details: https://github.com/Questie/Questie/issues/7497
        WatchFrame:SetAlpha(0)
    else
        -- Classic: the legacy tracker can be hidden directly.
        WatchFrame:Hide()
    end
end

---Restores Blizzard's control of quest-tracker visibility.
function QuestieCompat.ShowWatchFrame()
    if isForever then
        -- Forever: release only suppression we own; a release requested in combat is deferred too.
        if hideObjectiveTracker then
            hideObjectiveTracker = false
            ApplyObjectiveTrackerVisibility()
        end
    elseif Questie.IsTitanReforged then
        -- On titan reforged realms, the WatchFrame somehow behaves differently when hidden.
        -- details: https://github.com/Questie/Questie/issues/7497
        WatchFrame:SetAlpha(1)
    else
        -- Classic: restore the legacy tracker directly.
        WatchFrame:Show()
    end
end

---Returns Blizzard's quest tracker anchor for positioning Questie's tracker.
---@return any ... Point, relative region, relative point, x/y offsets; may return nothing.
function QuestieCompat.GetWatchFramePoint()
    if isForever then
        -- Forever: anchor to the modern objective tracker.
        return ObjectiveTrackerFrame:GetPoint()
    end
    -- Classic: anchor to the legacy watch frame captured at load time.
    return WatchFrame:GetPoint()
end

-- Quest-log adapters keep the identities and return positions used by existing consumers.
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumQuestLogEntries)
---Returns the number of shown quest-log entries and the total quest count.
---@return number numEntries Shown entries, including headers.
---@return number numQuests Quests, excluding headers.
function QuestieCompat.GetNumQuestLogEntries()
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        return C_QuestLog.GetNumQuestLogEntries()
    elseif GetNumQuestLogEntries then
        return GetNumQuestLogEntries()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLogTitle)
---Returns information about an entry in the player's quest log.
---@param questLogIndex number
---@return any ... Positional quest information, or nil when the entry is absent.
function QuestieCompat.GetQuestLogTitle(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return nil end
    if C_QuestLog and C_QuestLog.GetInfo then
        -- Convert the record to the return positions consumed by QuestLogCache.
        -- Position 3 is the quest tag; completion is nil, 1 (complete), or -1 (failed).
        local info = C_QuestLog.GetInfo(questLogIndex)
        if not info then return nil end

        local questTag
        if not info.isHeader and C_QuestLog.GetQuestTagInfo then
            local tagInfo = C_QuestLog.GetQuestTagInfo(info.questID)
            questTag = tagInfo and tagInfo.tagName
        end

        local isComplete
        if not info.isHeader then
            if C_QuestLog.IsFailed and C_QuestLog.IsFailed(info.questID) then
                isComplete = -1
            elseif C_QuestLog.IsComplete and C_QuestLog.IsComplete(info.questID) then
                isComplete = 1
            end
        end

        -- Position 10 controls whether the UI displays the quest ID; it is not another quest ID.
        return info.title, info.level, questTag, info.isHeader, info.isCollapsed,
            isComplete, info.frequency, info.questID, info.startEvent,
            GetCVarBool("displayQuestID"), info.isOnMap, info.hasLocalPOI, info.isTask,
            info.isBounty, info.isStory, info.isHidden, info.isScaling
    elseif GetQuestLogTitle then
        return GetQuestLogTitle(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SelectQuestLogEntry)
---Sets the selected entry in the quest log.
---@param questLogIndex number Position in the quest log, not a quest ID.
function QuestieCompat.SelectQuestLogEntry(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetInfo then
        -- The modern API selects by quest ID. Ignore missing entries and headers.
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info and not info.isHeader then
            C_QuestLog.SetSelectedQuest(info.questID)
        end
        return
    elseif SelectQuestLogEntry then
        return SelectQuestLogEntry(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLogSelection)
---Returns the index of the currently selected quest log entry.
---@return number questLogIndex Zero when no quest-log entry is selected.
function QuestieCompat.GetQuestLogSelection()
    if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetLogIndexForQuestID then
        -- Convert the selected quest ID to a log index; use 0 when no matching entry exists.
        local questID = C_QuestLog.GetSelectedQuest()
        return (questID and C_QuestLog.GetLogIndexForQuestID(questID)) or 0
    elseif GetQuestLogSelection then
        return GetQuestLogSelection()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitAura)
---Returns information about a unit's buff or debuff by index, or nil if none.
---@param unit string
---@param index number
---@param filter string?
---@return any ... Legacy aura tuple, or nil when the index has no aura.
function QuestieCompat.UnitAura(unit, index, filter)
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        -- This conversion does not remove aura-access or secret-data restrictions.
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
        if not aura then return nil end
        if isForever then
            -- Forever: the existing UnitAura global can fail internally. Preserve the full legacy tuple,
            -- including spell ID in slot 10 and the trailing flags/points supplied by AuraUtil.
            return AuraUtil.UnpackAuraData(aura)
        end
        -- Callers read spell ID from return position 10.
        return aura.name, aura.icon, aura.applications, aura.dispelName,
            aura.duration, aura.expirationTime, aura.sourceUnit,
            aura.isStealable, aura.nameplateShowPersonal, aura.spellId
    elseif UnitAura then
        return UnitAura(unit, index, filter)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetItemInfo)
---Returns information about an item, or nil if its data is unavailable.
---Does not wait for uncached data; callers handle loading and retries.
---@param item ItemId|string
---@return string? name
---@return string? itemLink
---@return number? quality
---@return number? level
---@return number? minLevel
---@return string? type
---@return string? subType
---@return number? stackCount
---@return string? equipLoc
---@return number? texture
---@return number? vendorPrice
---@return number? classID
---@return number? subClassID
---@return number? bindType
---@return number? expacID
---@return number? setID
---@return boolean? isCraftingReagent
---@return string? itemDescription
function QuestieCompat.GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        return C_Item.GetItemInfo(item)
    elseif GetItemInfo then
        return GetItemInfo(item)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsQuestFlaggedCompleted)
---Returns whether the game currently flags this quest as completed for the character.
---@param questID QuestId
---@return boolean isComplete
function QuestieCompat.IsQuestFlaggedCompleted(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    elseif IsQuestFlaggedCompleted then
        return IsQuestFlaggedCompleted(questID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumQuestLeaderBoards)
---Returns the number of objectives for a quest-log entry.
---@param questLogIndex number? Log position; nil uses the selected quest.
---@return number numObjectives
function QuestieCompat.GetNumQuestLeaderBoards(questLogIndex)
    if C_QuestLog and C_QuestLog.GetNumQuestObjectives then
        -- Convert the log position to a quest ID; missing entries and headers return zero.
        local index = questLogIndex or C_QuestLog.GetLogIndexForQuestID(C_QuestLog.GetSelectedQuest())
        if not index or index <= 0 then return 0 end
        local info = C_QuestLog.GetInfo(index)
        return info and not info.isHeader and C_QuestLog.GetNumQuestObjectives(info.questID) or 0
    elseif GetNumQuestLeaderBoards then
        return GetNumQuestLeaderBoards(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumQuestWatches)
---Returns the watched-quest count from the available API.
---@param arg any? Legacy-only argument, ignored by the modern C_QuestLog API.
---@return number numQuestWatches
function QuestieCompat.GetNumQuestWatches(arg)
    if C_QuestLog and C_QuestLog.GetNumQuestWatches then
        -- Native count, not Questie's own tracked-quest count.
        return C_QuestLog.GetNumQuestWatches()
    elseif GetNumQuestWatches then
        -- While the tracker intercepts this global, true requests Questie's count; other arguments return zero.
        return GetNumQuestWatches(arg)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestIndexForWatch)
---Returns the quest log index of a watched quest.
---@param watchIndex number Position in the watch list, not a quest ID or quest-log index.
---@return number? questLogIndex
function QuestieCompat.GetQuestIndexForWatch(watchIndex)
    if C_QuestLog and C_QuestLog.GetQuestIDForQuestWatchIndex and C_QuestLog.GetLogIndexForQuestID then
        -- Convert watch position to quest ID, then to quest-log position.
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(watchIndex)
        return questID and C_QuestLog.GetLogIndexForQuestID(questID)
    elseif GetQuestIndexForWatch then
        return GetQuestIndexForWatch(watchIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RemoveQuestWatch)
---Removes a quest from Blizzard's watched quests.
---@param questLogIndex number Position in the quest log, not a quest ID.
---@param isQuestie boolean? Bypasses Questie's legacy removal hook; ignored by the modern path.
function QuestieCompat.RemoveQuestWatch(questLogIndex, isQuestie)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.RemoveQuestWatch and C_QuestLog.GetInfo then
        -- Convert the log position to a quest ID; skip missing entries and headers.
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info and not info.isHeader then
            return C_QuestLog.RemoveQuestWatch(info.questID)
        end
        return
    elseif RemoveQuestWatch then
        -- Forward the hook-control flag so Questie-owned removals are not treated as user actions.
        return RemoveQuestWatch(questLogIndex, isQuestie)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitQuestTrivialLevelRange)
---Returns how many levels below the player a quest can be before becoming gray.
---@return number range
function QuestieCompat.GetQuestGreenRange()
    if isForever then
        -- The unit-based API requires "player"; the legacy helper is already player-specific.
        return UnitQuestTrivialLevelRange("player")
    end
    -- Classic: preserve the legacy helper when available.
    if GetQuestGreenRange then
        return GetQuestGreenRange("player")
    end
    return UnitQuestTrivialLevelRange("player")
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetItemCount)
---Returns the number of a given item in the player's inventory (and optionally bank).
---@param item ItemId|string
---@param includeBank boolean?
---@param includeCharges boolean? Count uses/charges where applicable.
---@param includeReagentBank boolean?
---@return number itemCount
function QuestieCompat.GetItemCount(item, includeBank, includeCharges, includeReagentBank)
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(item, includeBank, includeCharges, includeReagentBank)
    elseif GetItemCount then
        return GetItemCount(item, includeBank, includeCharges, includeReagentBank)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetItemIcon)
---Returns the icon texture for an item.
---@param item ItemId|string
---@return number|string|nil texture Nil when the native lookup has no icon.
function QuestieCompat.GetItemIcon(item)
    if C_Item and C_Item.GetItemIconByID then
        -- Accepts the same item identifiers as the legacy GetItemIcon; no argument conversion is needed.
        return C_Item.GetItemIconByID(item)
    elseif GetItemIcon then
        return GetItemIcon(item)
    end
    error(errorMsg, 2)
end

---Returns an item's spell name and ID, or no values when unavailable.
---@param item ItemId|string Item ID, name, item string, or hyperlink.
---@return string? spellName
---@return number? spellID
function QuestieCompat.GetItemSpell(item)
    if C_Item and C_Item.GetItemSpell then
        return C_Item.GetItemSpell(item)
    end
    return GetItemSpell(item)
end

---Returns whether an item is equippable, not whether it is currently equipped.
---@param item ItemId|string Item ID, name, or link.
---@return boolean isEquippable
function QuestieCompat.IsEquippableItem(item)
    if C_Item and C_Item.IsEquippableItem then
        return C_Item.IsEquippableItem(item)
    end
    return IsEquippableItem(item)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumFactions)
---Returns the number of entries (including headers) in the player's reputation list.
---@return number numFactions
function QuestieCompat.GetNumFactions()
    if C_Reputation and C_Reputation.GetNumFactions then
        return C_Reputation.GetNumFactions()
    elseif GetNumFactions then
        return GetNumFactions()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFactionInfo)
---Returns information about a reputation list entry.
---@param index number Position in the reputation list, not a faction ID.
---@return any ... Positional faction information, or nil when absent.
function QuestieCompat.GetFactionInfo(index)
    if C_Reputation and C_Reputation.GetFactionDataByIndex then
        -- Convert the record to positional returns; consumers use the bonus flag in position 15.
        local d = C_Reputation.GetFactionDataByIndex(index)
        if not d then return nil end
        return d.name, d.description, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.atWarWith,
            d.canToggleAtWar, d.isHeader, d.isCollapsed, d.isHeaderWithRep,
            d.isWatched, d.isChild, d.factionID, d.hasBonusRepGain,
            d.canSetInactive
    elseif GetFactionInfo then
        return GetFactionInfo(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ExpandFactionHeader)
---Expands a reputation list header.
---@param index number
function QuestieCompat.ExpandFactionHeader(index)
    if C_Reputation and C_Reputation.ExpandFactionHeader then
        -- Callers use the legacy index 0 to expand all headers. That behavior is unverified here;
        -- the modern API separately provides ExpandAllFactionHeaders.
        return C_Reputation.ExpandFactionHeader(index)
    elseif ExpandFactionHeader then
        return ExpandFactionHeader(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFactionInfoByID)
---Returns information about a reputation entry by faction ID.
---@param factionID number
---@return any ... Positional faction information, or nil when absent.
function QuestieCompat.GetFactionInfoByID(factionID)
    if C_Reputation and C_Reputation.GetFactionDataByID then
        -- Keep the same return positions as the index-based query above, including the bonus flag at 15.
        local d = C_Reputation.GetFactionDataByID(factionID)
        if not d then return nil end
        return d.name, d.description, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.atWarWith,
            d.canToggleAtWar, d.isHeader, d.isCollapsed, d.isHeaderWithRep,
            d.isWatched, d.isChild, d.factionID, d.hasBonusRepGain,
            d.canSetInactive
    elseif GetFactionInfoByID then
        return GetFactionInfoByID(factionID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLogIndexByID)
---Returns the quest log index for a given quest ID.
---@param questID QuestId
---@return number questLogIndex Zero when the quest is not in the log.
function QuestieCompat.GetQuestLogIndexByID(questID)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        -- Convert the modern API's nil result to the legacy zero result.
        return C_QuestLog.GetLogIndexForQuestID(questID) or 0
    elseif GetQuestLogIndexByID then
        return GetQuestLogIndexByID(questID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLink)
---Returns Blizzard's hyperlink for a quest, or nil when the native lookup has no link.
---@param arg QuestId|string
---@return string? questLink
function QuestieCompat.GetQuestLink(arg)
    if C_QuestLog and C_QuestLog.GetQuestLink then
        -- This spelling is a capability probe; its availability is not established by the inspected sources.
        return C_QuestLog.GetQuestLink(arg)
    elseif GetQuestLink then
        return GetQuestLink(arg)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestResetTime)
---Returns the number of seconds until the next daily quest reset.
---@return number secondsUntilReset
function QuestieCompat.GetQuestResetTime()
    if C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset then
        return C_DateAndTime.GetSecondsUntilDailyReset()
    elseif GetQuestResetTime then
        return GetQuestResetTime()
    end
    error(errorMsg, 2)
end

---Returns a lookup table of completed quests, keyed by quest ID.
---@param target table?
---@return table<QuestId, boolean>
function QuestieCompat.GetQuestsCompleted(target)
    if C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs then
        -- Convert the ID list to [questID] = true without clearing entries in the supplied table.
        local completed = target or {}
        for _, questID in ipairs(C_QuestLog.GetAllCompletedQuestIDs()) do
            completed[questID] = true
        end
        return completed
    elseif GetQuestsCompleted then
        return GetQuestsCompleted(target)
    end
    error(errorMsg, 2)
end

---Returns a quest's tag ID and name, plus optional world-quest details.
---@param questID QuestId
---@return any ... Tag ID/name and world-quest details, or nil when tag information is unavailable.
function QuestieCompat.GetQuestTagInfo(questID)
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local info = C_QuestLog.GetQuestTagInfo(questID)
        if not info then return nil end
        -- Convert the record to positional returns, including the optional world-quest fields.
        return info.tagID, info.tagName, info.worldQuestType, info.quality, info.isElite,
            info.tradeskillLineID, info.displayExpiration
    elseif GetQuestTagInfo then
        return GetQuestTagInfo(questID)
    end
    error(errorMsg, 2)
end

-- Only the numbered greeting layout uses this limit; pooled buttons are enumerated directly.
QuestieCompat.MAX_NUM_QUESTS = (Constants and Constants.QuestLogConsts and Constants.QuestLogConsts.MAXIMUM_NUM_QUESTS_LOG_CAN_ACCEPT) or MAX_NUM_QUESTS

---Visits shown quest-greeting buttons and their icons, without creating or acquiring frames.
---@param callback fun(button: Button, icon: Texture)
function QuestieCompat.ForEachQuestGreetingButton(callback)
    local pool = QuestFrameGreetingPanel and QuestFrameGreetingPanel.titleButtonPool
    if pool then
        -- Native Forever buttons are unnamed and reused whenever Blizzard rebuilds the greeting.
        for button in pool:EnumerateActive() do
            if button:IsShown() and button.Icon then
                callback(button, button.Icon)
            end
        end
        return
    end

    for i = 1, QuestieCompat.MAX_NUM_QUESTS or 0 do
        local button = _G["QuestTitleButton" .. i]
        if not button then
            break
        end
        if button:IsShown() then
            local icon = _G["QuestTitleButton" .. i .. "QuestIcon"]
            if icon then
                callback(button, icon)
            end
        end
    end
end

-- Requests native legacy UI refresh, preserving Blizzard's helper side effects (including quest selection).
-- Classic retains these frames; absent helpers make the wrappers no-ops.
---Refreshes Blizzard's quest watch display, if its legacy update helper exists.
function QuestieCompat.WatchFrame_Update()
    -- Prefer WatchFrame_Update when both legacy helpers are available.
    if WatchFrame_Update then
        return WatchFrame_Update()
    elseif QuestWatch_Update then
        return QuestWatch_Update()
    end
end

---Refreshes the legacy quest-log window when available.
function QuestieCompat.QuestLog_Update()
    if QuestLog_Update then
        -- Native refresh may select the first valid quest when nothing is selected.
        return QuestLog_Update()
    end
end

---Returns the remaining seconds for active quest timers.
---@param questID QuestId? Forwarded only to the legacy API; Forever returns all timers, ignoring this argument.
---@return number? ... Legacy timer seconds.
function QuestieCompat.GetQuestTimers(questID)
    if isForever then
        -- Convert records to separate numeric results; an empty list returns no values.
        -- Quest-specific lookup belongs to TrackerQuestTimers and does not change selection.
        local timers = {}
        for _, info in ipairs(C_QuestLog.GetQuestTimers()) do
            timers[#timers + 1] = info.questTimer
        end
        return unpack(timers)
    elseif GetQuestTimers then
        return GetQuestTimers(questID)
    end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_MouseIsOver)
---Returns whether the mouse is over the frame, with optional offsets to its bounds.
---@param frame frame
---@param top number?
---@param bottom number?
---@param left number?
---@param right number?
---@return boolean
function QuestieCompat.MouseIsOver(frame, top, bottom, left, right)
    if isForever then
        -- Forever: the legacy global can exist but call removed internals. Use the frame method even then.
        return frame:IsMouseOver(top, bottom, left, right)
    end
    -- The legacy helper forwards the same top/bottom/left/right offsets.
    if MouseIsOver then
        return MouseIsOver(frame, top, bottom, left, right)
    end
    if not frame or not frame.IsMouseOver then return false end
    return frame:IsMouseOver(top, bottom, left, right)
end

---Returns the number of accepted quests listed in the current gossip window.
---@return number numActiveQuests
function QuestieCompat.GetNumGossipActiveQuests()
    if C_GossipInfo and C_GossipInfo.GetNumActiveQuests then
        return C_GossipInfo.GetNumActiveQuests()
    elseif GetNumGossipActiveQuests then
        return GetNumGossipActiveQuests()
    end
    error(errorMsg, 2)
end

---Returns the number of quests available to accept in the current gossip window.
---@return number numAvailableQuests
function QuestieCompat.GetNumGossipAvailableQuests()
    if C_GossipInfo and C_GossipInfo.GetNumAvailableQuests then
        return C_GossipInfo.GetNumAvailableQuests()
    elseif GetNumGossipAvailableQuests then
        return GetNumGossipAvailableQuests()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetAbandonQuest)
---Marks the selected quest for abandonment; does not abandon it yet.
function QuestieCompat.SetAbandonQuest()
    -- Preserve the abandonment target when callers later restore quest-log selection.
    if SetAbandonQuest then
        return SetAbandonQuest()
    end
    if C_QuestLog and C_QuestLog.SetAbandonQuest then
        return C_QuestLog.SetAbandonQuest()
    end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAbandonQuestName)
---Returns the quest name used in the abandonment confirmation.
---@return string? name Empty string if no helper exists; a native title lookup may return nil.
function QuestieCompat.GetAbandonQuestName()
    if GetAbandonQuestName then
        return GetAbandonQuestName()
    end
    if C_QuestLog and C_QuestLog.GetAbandonQuestName then
        -- This namespaced spelling is not established by the inspected sources.
        return C_QuestLog.GetAbandonQuestName()
    end
    -- This reads the selected quest, not the stored abandonment target.
    -- The tracker menu queries it before restoring the previous selection.
    if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetTitleForQuestID then
        return C_QuestLog.GetTitleForQuestID(C_QuestLog.GetSelectedQuest())
    end
    return ""
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAbandonQuestItems)
---Returns item names for the quest-abandonment warning, or nil if none are available.
---@return string? items
function QuestieCompat.GetAbandonQuestItems()
    if GetAbandonQuestItems then
        return GetAbandonQuestItems()
    end
    if C_QuestLog and C_QuestLog.GetAbandonQuestItems then
        -- Convert item IDs to comma-separated names for the popup, omitting uncached names.
        local names = {}
        for _, itemID in ipairs(C_QuestLog.GetAbandonQuestItems() or {}) do
            local name = QuestieCompat.GetItemInfo(itemID)
            if name then
                tinsert(names, name)
            end
        end
        if #names > 0 then
            return table.concat(names, ", ")
        end
    end
    return nil
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AbandonQuest)
---Abandons the quest previously chosen with SetAbandonQuest.
function QuestieCompat.AbandonQuest()
    if AbandonQuest then
        return AbandonQuest()
    end
    if C_QuestLog and C_QuestLog.AbandonQuest then
        return C_QuestLog.AbandonQuest()
    end
end

---Returns the quest ID for an entry in the quest log.
---@param questLogIndex number Position in the quest log.
---@return QuestId? questID
function QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.GetInfo then
        -- Missing entries and zone headers have no selectable quest ID.
        local info = C_QuestLog.GetInfo(questLogIndex)
        return info and not info.isHeader and info.questID or nil
    elseif GetQuestIDFromLogIndex then
        return GetQuestIDFromLogIndex(questLogIndex)
    end
    error(errorMsg, 2)
end

---Selects a quest-log entry and updates the legacy selection highlight when available.
---@param questLogIndex number Position in the quest log, not a quest ID.
function QuestieCompat.QuestLog_SetSelection(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetInfo then
        -- Modern selection takes a quest ID; missing entries and headers are ignored.
        local questID = QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
        if questID then
            return C_QuestLog.SetSelectedQuest(questID)
        end
        return
    elseif QuestLog_SetSelection then
        -- Unlike plain SelectQuestLogEntry, this helper also updates highlighting and toggles headers.
        return QuestLog_SetSelection(questLogIndex)
    end
end

---Refreshes the selected quest's details in the legacy quest-log window, if available.
function QuestieCompat.QuestLog_UpdateQuestDetails()
    if QuestLog_UpdateQuestDetails then
        return QuestLog_UpdateQuestDetails()
    end
end

---Resizes a popup dialog when the legacy resize helper is available.
---@param ... any Legacy resize arguments, forwarded unchanged.
function QuestieCompat.StaticPopup_Resize(...)
    if StaticPopup_Resize then
        return StaticPopup_Resize(...)
    end
end

---Shows a short status message.
---@param message string
---@param ignoreNewbieTooltipSetting boolean? Show native feedback even when newbie tips are disabled.
function QuestieCompat.ActionStatus_DisplayMessage(message, ignoreNewbieTooltipSetting)
    if ActionStatus_DisplayMessage then
        return ActionStatus_DisplayMessage(message, ignoreNewbieTooltipSetting)
    end
    if UIErrorsFrame and message then
        -- Use plain white error-frame text when the native status helper is absent.
        UIErrorsFrame:AddMessage(message, 1, 1, 1)
    end
end

-- Achievement UI can be absent or load-on-demand; Classic still uses these global UI helpers.
-- Forever maps to Era content, so ordinary achievement tracker branches do not run there.
---Toggles the achievement window when its UI helper is available.
function QuestieCompat.AchievementFrame_ToggleAchievementFrame()
    if AchievementFrame_ToggleAchievementFrame then
        return AchievementFrame_ToggleAchievementFrame()
    end
end

---Selects an achievement in the open achievement window, if its UI helper is available.
---@param achievementId number
function QuestieCompat.AchievementFrame_SelectAchievement(achievementId)
    if AchievementFrame_SelectAchievement then
        return AchievementFrame_SelectAchievement(achievementId)
    end
end

---Refreshes the achievement list when its UI helper is loaded.
function QuestieCompat.AchievementFrameAchievements_ForceUpdate()
    if AchievementFrameAchievements_ForceUpdate then
        return AchievementFrameAchievements_ForceUpdate()
    end
end

---Returns the achievement IDs tracked by Blizzard as separate return values.
---@return number ... Achievement IDs.
function QuestieCompat.GetTrackedAchievements()
    -- No API means no returned values, so callers collect an empty table.
    if GetTrackedAchievements then
        return GetTrackedAchievements()
    end
end

---Removes an achievement from Blizzard's tracked achievements, if supported.
---@param achieveId number
---@param isQuestie boolean? True prevents Questie's removal hook from also untracking it in Questie.
function QuestieCompat.RemoveTrackedAchievement(achieveId, isQuestie)
    if RemoveTrackedAchievement then
        return RemoveTrackedAchievement(achieveId, isQuestie)
    end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetStablePetFoodTypes)
---Returns the food types a stable pet can eat as separate return values.
---@param index number Stable slot passed unchanged; callers use the legacy active-pet slot 0.
---@return string ... Food types.
function QuestieCompat.GetStablePetFoodTypes(index)
    if C_StableInfo and C_StableInfo.GetStablePetFoodTypes then
        -- Unpack the array because the townsfolk menu collects these values into its own table.
        return unpack(C_StableInfo.GetStablePetFoodTypes(index) or {})
    elseif GetStablePetFoodTypes then
        return GetStablePetFoodTypes(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsQuestWatched)
---Returns whether a quest-log entry is watched.
---@param questLogIndex number Position in the quest log.
---@return boolean? isWatched
function QuestieCompat.IsQuestWatched(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return false end
    if isForever then
        -- Forever: query native state by quest ID, not Questie's synthetic legacy global. Watch type 0 is valid.
        local questID = QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
        return questID ~= nil and C_QuestLog.GetQuestWatchType(questID) ~= nil
    end
    -- The legacy global may report Questie's tracking state, including nil for an unwatched quest.
    if IsQuestWatched then
        return IsQuestWatched(questLogIndex)
    end
    if C_QuestLog and C_QuestLog.GetQuestWatchType and C_QuestLog.GetQuestIDForLogIndex then
        local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
        return questID ~= nil and C_QuestLog.GetQuestWatchType(questID) ~= nil
    end
    return false
end


------------------------------------------
-- Early library bridge
------------------------------------------

---Makes a texture grayscale, or restores its original colors.
---@param texture Texture
---@param desaturated boolean
function QuestieCompat.SetDesaturation(texture, desaturated)
    texture:SetDesaturated(desaturated)
end

if isForever then
    -- AceGUI checkboxes still call this global. Install before embedded libraries without replacing a native helper.
    SetDesaturation = SetDesaturation or QuestieCompat.SetDesaturation
end

---Returns whether an addon is loaded or loading, and whether loading has finished.
---@param addon string|number Addon folder name or 1-based addon-list index; use names for Blizzard addons.
---@return boolean loadedOrLoading
---@return boolean? loaded Whether ADDON_LOADED has fired, when supplied by the client.
function QuestieCompat.IsAddOnLoaded(addon)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(addon)
    end
    return IsAddOnLoaded(addon)
end

---Returns an addon's metadata field, such as its version.
---@param addon string|number Addon name or index.
---@param field string
---@return string?
function QuestieCompat.GetAddOnMetadata(addon, field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addon, field)
    end
    return GetAddOnMetadata(addon, field)
end

---Registers a callback that can hide or rewrite chat messages before display.
---The callback receives (chatFrame, event, ...). Return true to hide a message,
---false plus replacement arguments to rewrite it, or nil to leave it unchanged.
---@param event string Chat event name, such as "CHAT_MSG_PARTY".
---@param filter function
function QuestieCompat.AddMessageEventFilter(event, filter)
    if ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
        return ChatFrameUtil.AddMessageEventFilter(event, filter)
    end
    return ChatFrame_AddMessageEventFilter(event, filter)
end

---Stops applying a filter to messages from the specified chat event.
---@param event string The event used when registering the filter.
---@param filter function The original callback function passed during registration.
function QuestieCompat.RemoveMessageEventFilter(event, filter)
    if ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter then
        return ChatFrameUtil.RemoveMessageEventFilter(event, filter)
    end
    return ChatFrame_RemoveMessageEventFilter(event, filter)
end
