---@diagnostic disable: undefined-global, return-type-mismatch, undefined-field
---@class QuestieCompat
local QuestieCompat = QuestieLoader:CreateModule("QuestieCompat")

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
-- Older client compatibility (pre 1.14.1)
------------------------------------------

-- Add missing Seasons object, if not available (e.g. 1.14.0 and below is missing it)
if not C_Seasons then
    C_Seasons = {
        ---[C_Seasons.HasActiveSeason Documentation](https://warcraft.wiki.gg/wiki/API_C_Seasons.HasActiveSeason)
        ---Returns true if the player is on a seasonal realm.
        HasActiveSeason = function()
            return false
        end,
        ---[C_Seasons.GetActiveSeason Documentation](https://warcraft.wiki.gg/wiki/API_C_Seasons.GetActiveSeason)
        ---Returns the ID of the season that is active on the current realm.
        GetActiveSeason = function()
            return 0
        end
    }
end

-- Specific subclass of this mixin was added in a minor version and is missing in earlier patches, functionality this makes next to no visual difference
if not TooltipBackdropTemplateMixin then
    TooltipBackdropTemplateMixin = BackdropTemplateMixin
end

-------------------------------------------
-- API difference compatibility (Era/Wotlk)
-------------------------------------------

---[SetMinResize Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetMinResize)
---[SetMaxResize Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetMaxResize)
---[SetResizeBounds Documentation](https://warcraft.wiki.gg/wiki/API_Frame_SetMinResize)
---Specifies the minimum [and maximum] width and height that the object can be resized to.
---@param frame frame
---@param minWidth number The minimum width the object can be resized to.
---@param minHeight number The minimum height the object can be resized to.
---@param maxWidth number The maximum width the object can be resized to.
---@param maxHeight number The maximum height the object can be resized to.
function QuestieCompat.SetResizeBounds(frame, minWidth, minHeight, maxWidth, maxHeight)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
        return
    else
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

---Returns the available quests at a quest giver.
---@return GossipQuestUIInfo[]
function QuestieCompat.GetAvailableQuests()
    if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        return C_GossipInfo.GetAvailableQuests()
    elseif GetGossipAvailableQuests then
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

---Returns the quests which can be turned in at a quest giver.
---@return GossipQuestUIInfo[]
function QuestieCompat.GetActiveQuests()
    if C_GossipInfo and C_GossipInfo.GetActiveQuests then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        for _, quest in pairs(activeQuests) do
            quest.isComplete = quest.isComplete or QuestieDB.IsComplete(quest.questID) == 1
        end
        return activeQuests
    elseif GetGossipActiveQuests then
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
                isImportant = false, -- Not available from GetGossipAvailableQuests
                isMeta = false, -- Not available from GetGossipAvailableQuests
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
---@param index number Index of the quest to select (I think questId might work here too...)
function QuestieCompat.SelectAvailableQuest(index)
    if C_GossipInfo and C_GossipInfo.SelectAvailableQuest then
        local questId = C_GossipInfo.GetAvailableQuests()[index].questID
        return C_GossipInfo.SelectAvailableQuest(questId)
    elseif SelectGossipAvailableQuest then
        return SelectGossipAvailableQuest(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.SelectActiveQuest)
---Selects an active quest from the gossip window.
---@param index number|QuestId Index of the active quest to select, from 1 to GetNumGossipActiveQuests(); order corresponds to the order of return values from GetGossipActiveQuests().
function QuestieCompat.SelectActiveQuest(index)
    if C_GossipInfo and C_GossipInfo.SelectActiveQuest then
        local questId = C_GossipInfo.GetActiveQuests()[index].questID
        return C_GossipInfo.SelectActiveQuest(questId)
    elseif SelectGossipActiveQuest then
        return SelectGossipActiveQuest(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetContainerNumSlots)
---Returns the total number of slots in the bag specified by the index.
---@param bagID number the slot containing the bag, e.g. 0 for backpack, etc.
---@return number numberOfSlots the number of slots in the specified bag, or 0 if there is no bag in the given slot.
function QuestieCompat.GetContainerNumSlots(bagID)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bagID)
    elseif GetContainerNumSlots then
        return GetContainerNumSlots(bagID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetContainerItemInfo)
---Returns info for an item in a container slot.
---@param bagID number BagID of the bag the item is in, e.g. 0 for your backpack.
---@param slot number index of the slot inside the bag to look up.
---@return number texture The icon texture (FileID) for the item in the specified bag slot.
---@return number itemCount The number of items in the specified bag slot.
---@return boolean locked True if the item is locked by the server, false otherwise.
---@return number quality The Quality of the item.
---@return boolean readable True if the item can be "read" (as in a book), false otherwise.
---@return boolean lootable True if the item is a temporary container containing items that can be looted, false otherwise.
---@return string itemLink The itemLink of the item in the specified bag slot.
---@return boolean isFiltered True if the item is grayed-out during the current inventory search, false otherwise.
---@return boolean noValue True if the item has no gold value, false otherwise.
---@return number itemID The unique ID for the item in the specified bag slot.
---@return boolean isBound True if the item is bound to the current character, false otherwise.
function QuestieCompat.GetContainerItemInfo(bagID, slot)
    if C_Container and C_Container.GetContainerItemInfo then
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
---Returns info about the cooldown state and time of an item.
---@param itemID number The item ID.
---@return number startTime The time when the cooldown started (as returned by GetTime()) or zero if no cooldown.
---@return number duration The number of seconds the cooldown will last, or zero if no cooldown.
---@return number enable 1 if the item is ready or on cooldown, 0 if the item is used, but the cooldown didn't start yet (e.g. potion in combat).
function QuestieCompat.GetItemCooldown(itemID)
    if C_Container and C_Container.GetItemCooldown then
        return C_Container.GetItemCooldown(itemID)
    elseif C_Item and C_Item.GetItemCooldown then
        return C_Item.GetItemCooldown(itemID)
    else
        return GetItemCooldown(itemID)
    end
end

--- Returns the frame that is currently under the mouse cursor.
function QuestieCompat.GetMouseFocus()
    if GetMouseFoci then
        return GetMouseFoci()[1]
    else
        --- Old version (still used in WotLK client)
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
---Returns the current date and time information.
---@return CalendarTime
function QuestieCompat.GetCurrentCalendarTime()
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        return C_DateAndTime.GetCurrentCalendarTime()
    elseif C_DateAndTime and C_DateAndTime.GetTodaysDate then
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

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsSpellKnown)
---Returns whether the player (or pet) knows the given spell.
---@param spellID number The spell ID.
---@return boolean isKnown True if the player knows the spell/profession spell, false otherwise
function QuestieCompat.IsSpellKnown(spellID)
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(spellID)
    else
        -- If there is no C_SpellBook we need to call this function instead because passive spells
        -- would return wrong values and feed wrong data to our logic
        return IsPlayerSpell(spellID)
    end
end

-- Forever's objective tracker can show itself during content updates. Own suppression only while requested,
-- and defer protected visibility changes until combat ends. Classic keeps its existing WatchFrame policy.
local hideObjectiveTracker = false
local objectiveTrackerHooked = false
local visibilityFrame

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
            -- Forever: let Blizzard decide whether content/edit mode requires a visible tracker.
            ObjectiveTrackerFrame:Update()
        end
    end
end

if isForever then
    visibilityFrame = CreateFrame("Frame")
    visibilityFrame:SetScript("OnEvent", ApplyObjectiveTrackerVisibility)
end

---@return nil
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

---@return nil
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

---@return any ... Frame anchor tuple.
function QuestieCompat.GetWatchFramePoint()
    if isForever then
        -- Forever: anchor to the modern objective tracker.
        return ObjectiveTrackerFrame:GetPoint()
    end
    -- Classic: anchor to the legacy watch frame captured at load time.
    return WatchFrame:GetPoint()
end

-- Shared wrappers preserve legacy tuples while selecting available client APIs.
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumQuestLogEntries)
---Returns the number of entries (including headers) in the player's quest log.
---@return number numEntries
---@return number numQuests
function QuestieCompat.GetNumQuestLogEntries()
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        -- Forever / modern Classic: same entry/count tuple, moved to the namespace.
        return C_QuestLog.GetNumQuestLogEntries()
    elseif GetNumQuestLogEntries then
        -- Classic: native legacy counts.
        return GetNumQuestLogEntries()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLogTitle)
---Returns information about an entry in the player's quest log.
---@param questLogIndex number
---@return any ... Legacy title tuple, or nil when the entry is absent.
function QuestieCompat.GetQuestLogTitle(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return nil end
    if C_QuestLog and C_QuestLog.GetInfo then
        -- Forever / modern Classic: expand the record into the legacy tuple consumed by QuestLogCache.
        -- Slot 3 is the quest tag, not suggestedGroup; incomplete stays nil, complete is 1, failed is -1.
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

        return info.title, info.level, questTag, info.isHeader, info.isCollapsed,
            isComplete, info.frequency, info.questID, info.startEvent,
            info.questID, info.isOnMap, info.hasLocalPOI, info.isTask,
            info.isBounty, info.isStory, info.isHidden, info.isScaling
    elseif GetQuestLogTitle then
        -- Classic: the native global already returns the expected tuple.
        return GetQuestLogTitle(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SelectQuestLogEntry)
---Sets the selected entry in the quest log.
---@param questLogIndex number
function QuestieCompat.SelectQuestLogEntry(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetInfo then
        -- Forever / modern Classic: callers pass a log index, but selection takes a quest ID. Headers are not quests.
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info and not info.isHeader then
            C_QuestLog.SetSelectedQuest(info.questID)
        end
        return
    elseif SelectQuestLogEntry then
        -- Classic: selection takes the log index directly.
        return SelectQuestLogEntry(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLogSelection)
---Returns the index of the currently selected quest log entry.
---@return number questLogIndex
function QuestieCompat.GetQuestLogSelection()
    if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetLogIndexForQuestID then
        -- Forever / modern Classic: convert the selected ID back to an index; Classic uses 0 for no selection.
        local questID = C_QuestLog.GetSelectedQuest()
        return (questID and C_QuestLog.GetLogIndexForQuestID(questID)) or 0
    elseif GetQuestLogSelection then
        -- Classic: already an index, including the absent-selection sentinel.
        return GetQuestLogSelection()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitAura)
---Returns information about a buff/debuff on a unit by index.
---@param unit string
---@param index number
---@param filter string|nil
---@return any ... Legacy aura tuple, or nil when the index has no aura.
function QuestieCompat.UnitAura(unit, index, filter)
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
        if not aura then return nil end
        if isForever then
            -- Forever: the existing UnitAura global can fail internally. Preserve the full legacy tuple,
            -- including spell ID in slot 10 and the trailing flags/points supplied by AuraUtil.
            return AuraUtil.UnpackAuraData(aura)
        end
        -- Modern Classic: preserve the tuple used by the existing compatibility path.
        return aura.name, aura.icon, aura.applications, aura.dispelName,
            aura.duration, aura.expirationTime, aura.sourceUnit,
            aura.isStealable, aura.nameplateShowPersonal, aura.spellId
    elseif UnitAura then
        -- Classic: native legacy aura tuple.
        return UnitAura(unit, index, filter)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetItemInfo)
---Returns information about an item.
---@param item ItemId|string
---@return string name
---@return string itemLink
---@return number quality
---@return number level
---@return number minLevel
---@return string type
---@return string subType
---@return number stackCount
---@return number equipLoc
---@return number texture
---@return number vendorPrice
---@return number classID
---@return number subClassID
---@return number bindType
---@return number expacID
---@return number setID
---@return boolean isCraftingReagent
function QuestieCompat.GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        return C_Item.GetItemInfo(item)
    elseif GetItemInfo then
        return GetItemInfo(item)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsQuestFlaggedCompleted)
---Returns whether the given quest has been completed by the player.
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
---Returns the number of objectives for a quest log entry.
---@param questLogIndex number|nil
---@return number numObjectives
function QuestieCompat.GetNumQuestLeaderBoards(questLogIndex)
    if C_QuestLog and C_QuestLog.GetNumQuestObjectives then
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
---Returns the number of quests currently being watched.
---@param arg any|nil Legacy-only argument, ignored by the modern C_QuestLog API.
---@return number numQuestWatches
function QuestieCompat.GetNumQuestWatches(arg)
    if C_QuestLog and C_QuestLog.GetNumQuestWatches then
        -- Forever / modern Classic: native count, not the tracker's synthetic legacy count.
        return C_QuestLog.GetNumQuestWatches()
    elseif GetNumQuestWatches then
        -- Classic: preserve the caller's internal-count argument for legacy tracker interception.
        return GetNumQuestWatches(arg)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestIndexForWatch)
---Returns the quest log index of a watched quest.
---@param watchIndex number
---@return number? questLogIndex
function QuestieCompat.GetQuestIndexForWatch(watchIndex)
    if C_QuestLog and C_QuestLog.GetQuestIDForQuestWatchIndex and C_QuestLog.GetLogIndexForQuestID then
        -- Forever / modern Classic: watch position -> quest ID -> quest-log position.
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(watchIndex)
        return questID and C_QuestLog.GetLogIndexForQuestID(questID)
    elseif GetQuestIndexForWatch then
        -- Classic: native helper already returns a log index.
        return GetQuestIndexForWatch(watchIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AddQuestWatch)
---Adds a quest log entry to the tracked quest watches.
---@param questLogIndex number
function QuestieCompat.AddQuestWatch(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.AddQuestWatch and C_QuestLog.GetInfo then
        -- Forever / modern Classic: translate the log index and add a manual watch, never a toggle.
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info and not info.isHeader then
            return C_QuestLog.AddQuestWatch(info.questID, Enum.QuestWatchType.Manual)
        end
        return
    elseif AddQuestWatch then
        -- Classic: native watch API takes the log index.
        return AddQuestWatch(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RemoveQuestWatch)
---Removes a quest log entry from the tracked quest watches.
---@param questLogIndex number
---@param isQuestie boolean? Legacy hook bypass for Questie-owned removals.
function QuestieCompat.RemoveQuestWatch(questLogIndex, isQuestie)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.RemoveQuestWatch and C_QuestLog.GetInfo then
        -- Forever / modern Classic: removal takes a quest ID and must not change quest selection.
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info and not info.isHeader then
            return C_QuestLog.RemoveQuestWatch(info.questID)
        end
        return
    elseif RemoveQuestWatch then
        -- Classic: forward the internal-removal flag so tracker hooks do not treat it as a user action.
        return RemoveQuestWatch(questLogIndex, isQuestie)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_UnitQuestTrivialLevelRange)
---Returns the level spread at which a quest is considered "green" (trivial) relative to the player.
---@return number range
function QuestieCompat.GetQuestGreenRange()
    if isForever then
        -- Forever: the replacement is unit-based rather than a quest-log helper.
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
---@param includeBank boolean|nil
---@param includeCharges boolean|nil
---@param includeReagentBank boolean|nil
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
---@return number|string texture
function QuestieCompat.GetItemIcon(item)
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(item)
    elseif GetItemIcon then
        return GetItemIcon(item)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumFactions)
---Returns the number of entries (including headers) in the player's reputation list.
---@return number numFactions
function QuestieCompat.GetNumFactions()
    if C_Reputation and C_Reputation.GetNumFactions then
        -- Forever / modern Classic: same count, moved to the namespace.
        return C_Reputation.GetNumFactions()
    elseif GetNumFactions then
        -- Classic: native legacy count.
        return GetNumFactions()
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFactionInfo)
---Returns information about a reputation list entry.
---@param index number
---@return any ... Legacy faction tuple, including header/bonus flags, or nil when absent.
function QuestieCompat.GetFactionInfo(index)
    if C_Reputation and C_Reputation.GetFactionDataByIndex then
        -- Forever / modern Classic: flatten the named fields into Classic's positional faction contract.
        local d = C_Reputation.GetFactionDataByIndex(index)
        if not d then return nil end
        return d.name, d.description, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.atWarWith,
            d.canToggleAtWar, d.isHeader, d.isCollapsed, d.isHeaderWithRep,
            d.isWatched, d.isChild, d.factionID, d.hasBonusRepGain,
            d.canSetInactive
    elseif GetFactionInfo then
        -- Classic: native legacy tuple.
        return GetFactionInfo(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ExpandFactionHeader)
---Expands a reputation list header.
---@param index number
function QuestieCompat.ExpandFactionHeader(index)
    if C_Reputation and C_Reputation.ExpandFactionHeader then
        -- Forever / modern Classic: indices keep their meaning in the namespaced API.
        return C_Reputation.ExpandFactionHeader(index)
    elseif ExpandFactionHeader then
        -- Classic: native legacy expansion.
        return ExpandFactionHeader(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_CollapseFactionHeader)
---Collapses a reputation list header.
---@param index number
function QuestieCompat.CollapseFactionHeader(index)
    if C_Reputation and C_Reputation.CollapseFactionHeader then
        return C_Reputation.CollapseFactionHeader(index)
    elseif CollapseFactionHeader then
        return CollapseFactionHeader(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFactionInfoByID)
---Returns information about a reputation entry by faction ID.
---@param factionID number
---@return any ... Legacy faction tuple, including header/bonus flags, or nil when absent.
function QuestieCompat.GetFactionInfoByID(factionID)
    if C_Reputation and C_Reputation.GetFactionDataByID then
        -- Forever / modern Classic: preserve the same tuple as the index-based query above.
        local d = C_Reputation.GetFactionDataByID(factionID)
        if not d then return nil end
        return d.name, d.description, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.atWarWith,
            d.canToggleAtWar, d.isHeader, d.isCollapsed, d.isHeaderWithRep,
            d.isWatched, d.isChild, d.factionID, d.hasBonusRepGain,
            d.canSetInactive
    elseif GetFactionInfoByID then
        -- Classic: native legacy tuple.
        return GetFactionInfoByID(factionID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLogIndexByID)
---Returns the quest log index for a given quest ID.
---@param questID QuestId
---@return number questLogIndex
function QuestieCompat.GetQuestLogIndexByID(questID)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        -- Forever / modern Classic: normalize an absent ID from nil to Classic's 0 sentinel.
        return C_QuestLog.GetLogIndexForQuestID(questID) or 0
    elseif GetQuestLogIndexByID then
        -- Classic: native legacy lookup.
        return GetQuestLogIndexByID(questID)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestLink)
---Returns a quest hyperlink.
---@param arg QuestId|string
---@return string questLink
function QuestieCompat.GetQuestLink(arg)
    if C_QuestLog and C_QuestLog.GetQuestLink then
        return C_QuestLog.GetQuestLink(arg)
    elseif GetQuestLink then
        return GetQuestLink(arg)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestResetTime)
---Returns the number of seconds until the daily quest reset.
---@return number secondsUntilReset
function QuestieCompat.GetQuestResetTime()
    if C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset then
        return C_DateAndTime.GetSecondsUntilDailyReset()
    elseif GetQuestResetTime then
        return GetQuestResetTime()
    end
    error(errorMsg, 2)
end

---Returns a completed-quest set, optionally adding to an existing set.
---@param target table|nil
---@return table<QuestId, boolean>
function QuestieCompat.GetQuestsCompleted(target)
    if C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs then
        -- Forever / modern Classic: convert the ID array to Classic's [questID] = true set.
        local completed = target or {}
        for _, questID in ipairs(C_QuestLog.GetAllCompletedQuestIDs()) do
            completed[questID] = true
        end
        return completed
    elseif GetQuestsCompleted then
        -- Classic: native helper fills the caller's set.
        return GetQuestsCompleted(target)
    end
    error(errorMsg, 2)
end

---Returns the legacy quest-tag tuple, including optional world-quest fields.
---@param questID QuestId
---@return any ... Tag ID/name followed by world-quest type, quality, elite, profession, and expiration fields.
function QuestieCompat.GetQuestTagInfo(questID)
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local info = C_QuestLog.GetQuestTagInfo(questID)
        if not info then return nil end
        -- Forever / modern Classic: expand the record rather than dropping the optional tuple fields.
        return info.tagID, info.tagName, info.worldQuestType, info.quality, info.isElite,
            info.tradeskillLineID, info.displayExpiration
    elseif GetQuestTagInfo then
        -- Classic: native legacy tuple.
        return GetQuestTagInfo(questID)
    end
    error(errorMsg, 2)
end

-- Blizzard constant; Questie uses it as a "for" limit, so a nil aborts the loop.
QuestieCompat.MAX_NUM_QUESTS = (Constants and Constants.QuestLogConsts and Constants.QuestLogConsts.MAXIMUM_NUM_QUESTS_LOG_CAN_ACCEPT) or MAX_NUM_QUESTS

-- The old default quest-log/watch UI is gone. Questie calls these purely to ask
-- Blizzard's own frames to redraw, so doing nothing is correct here.
---Redraws the quest watch frame (no-op on modern clients where the frame no longer exists).
function QuestieCompat.WatchFrame_Update()
    if WatchFrame_Update then
        return WatchFrame_Update()
    elseif QuestWatch_Update then
        return QuestWatch_Update()
    end
end

---Redraws the quest log frame (no-op on modern clients where the frame no longer exists).
function QuestieCompat.QuestLog_Update()
    if QuestLog_Update then
        return QuestLog_Update()
    end
end

---@param questID QuestId?
---@return number? ... Legacy timer seconds.
function QuestieCompat.GetQuestTimers(questID)
    if isForever then
        -- Forever: the native array contains {questID, questTimer} records; callers here expect seconds as varargs.
        -- Do not change quest selection to inspect timers. TrackerQuestTimers matches the native records by ID.
        local timers = {}
        for _, info in ipairs(C_QuestLog.GetQuestTimers()) do
            timers[#timers + 1] = info.questTimer
        end
        return unpack(timers)
    elseif GetQuestTimers then
        -- Classic: keep the native timer contract, including clients with no timer API.
        return GetQuestTimers(questID)
    end
end

-- Removed global helper; the equivalent is now a method on the frame itself.
---[Documentation](https://warcraft.wiki.gg/wiki/API_MouseIsOver)
---Returns whether the mouse is over a frame.
---@param frame frame
---@param top number|nil
---@param bottom number|nil
---@param left number|nil
---@param right number|nil
---@return boolean
function QuestieCompat.MouseIsOver(frame, top, bottom, left, right)
    if isForever then
        -- Forever: the legacy global can exist but call removed internals. Use the frame method even then.
        return frame:IsMouseOver(top, bottom, left, right)
    end
    -- Classic: keep the legacy offset behavior; use the method only when the global is absent.
    if MouseIsOver then
        return MouseIsOver(frame, top, bottom, left, right)
    end
    if not frame or not frame.IsMouseOver then return false end
    return frame:IsMouseOver(top, bottom, left, right)
end

-- Gossip quest lists moved under C_GossipInfo.
---@return number numActiveQuests
function QuestieCompat.GetNumGossipActiveQuests()
    if C_GossipInfo and C_GossipInfo.GetNumActiveQuests then
        return C_GossipInfo.GetNumActiveQuests()
    elseif GetNumGossipActiveQuests then
        return GetNumGossipActiveQuests()
    end
    error(errorMsg, 2)
end

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
---Sets the quest to be abandoned.
---Questie calls these from its tracker's right-click menu
---and from the breadcrumb handling, both without a nil check.
function QuestieCompat.SetAbandonQuest()
    if SetAbandonQuest then
        return SetAbandonQuest()
    end
    if C_QuestLog and C_QuestLog.SetAbandonQuest then
        return C_QuestLog.SetAbandonQuest()
    end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAbandonQuestName)
---Returns the name of the quest set for abandonment.
---@return string name
function QuestieCompat.GetAbandonQuestName()
    if GetAbandonQuestName then
        return GetAbandonQuestName()
    end
    if C_QuestLog and C_QuestLog.GetAbandonQuestName then
        return C_QuestLog.GetAbandonQuestName()
    end
    -- Fall back to the title of whatever quest is currently selected.
    if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetTitleForQuestID then
        return C_QuestLog.GetTitleForQuestID(C_QuestLog.GetSelectedQuest())
    end
    return ""
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetAbandonQuestItems)
---Returns the item names used by the abandonment confirmation dialog.
---@return string|nil items
function QuestieCompat.GetAbandonQuestItems()
    if GetAbandonQuestItems then
        return GetAbandonQuestItems()
    end
    if C_QuestLog and C_QuestLog.GetAbandonQuestItems then
        -- Modern APIs return IDs; legacy popup formatting expects comma-separated names.
        -- Like Blizzard's dialog, omit names that are not cached yet.
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
---Abandons the currently selected quest.
function QuestieCompat.AbandonQuest()
    if AbandonQuest then
        return AbandonQuest()
    end
    if C_QuestLog and C_QuestLog.AbandonQuest then
        return C_QuestLog.AbandonQuest()
    end
end

---@param questLogIndex number
---@return QuestId? questID
function QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.GetInfo then
        -- Forever / modern Classic: headers have no selectable quest ID, even if the record contains 0.
        local info = C_QuestLog.GetInfo(questLogIndex)
        return info and not info.isHeader and info.questID or nil
    elseif GetQuestIDFromLogIndex then
        -- Classic: native legacy lookup.
        return GetQuestIDFromLogIndex(questLogIndex)
    end
    error(errorMsg, 2)
end

---@param questLogIndex number
function QuestieCompat.QuestLog_SetSelection(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return end
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetInfo then
        local questID = QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
        if questID then
            return C_QuestLog.SetSelectedQuest(questID)
        end
        return
    elseif QuestLog_SetSelection then
        return QuestLog_SetSelection(questLogIndex)
    end
end

-- Redraw helpers for the old quest log window, which no longer exists.
---Redraws the quest log details frame (no-op on modern clients).
function QuestieCompat.QuestLog_UpdateQuestDetails()
    if QuestLog_UpdateQuestDetails then
        return QuestLog_UpdateQuestDetails()
    end
end

---Resizes a static popup dialog.
function QuestieCompat.StaticPopup_Resize(...)
    if StaticPopup_Resize then
        return StaticPopup_Resize(...)
    end
end

-- Questie uses this only for "Copied URL to clipboard" feedback.
---@param message string
function QuestieCompat.ActionStatus_DisplayMessage(message)
    if ActionStatus_DisplayMessage then
        return ActionStatus_DisplayMessage(message)
    end
    if UIErrorsFrame and message then
        UIErrorsFrame:AddMessage(message, 1, 1, 1)
    end
end

-- No achievement UI on this client. These are reached from tracker clicks.
---Toggles the achievement frame.
function QuestieCompat.AchievementFrame_ToggleAchievementFrame()
    if AchievementFrame_ToggleAchievementFrame then
        return AchievementFrame_ToggleAchievementFrame()
    end
end

---@param achievementId number
function QuestieCompat.AchievementFrame_SelectAchievement(achievementId)
    if AchievementFrame_SelectAchievement then
        return AchievementFrame_SelectAchievement(achievementId)
    end
end

---Forces an update of the achievement frame.
function QuestieCompat.AchievementFrameAchievements_ForceUpdate()
    if AchievementFrameAchievements_ForceUpdate then
        return AchievementFrameAchievements_ForceUpdate()
    end
end

-- Returns a varargs list; Questie packs it into a table, so returning nothing
-- yields an empty table rather than an error.
---@return ...
function QuestieCompat.GetTrackedAchievements()
    if GetTrackedAchievements then
        return GetTrackedAchievements()
    end
end

---@param isQuestie boolean|nil
---@return number
function QuestieCompat.GetNumTrackedAchievements(isQuestie)
    if GetNumTrackedAchievements then
        return GetNumTrackedAchievements(isQuestie)
    end
    return 0
end

---@param achieveId number
---@param isQuestie boolean|nil
function QuestieCompat.RemoveTrackedAchievement(achieveId, isQuestie)
    if RemoveTrackedAchievement then
        return RemoveTrackedAchievement(achieveId, isQuestie)
    end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetStablePetFoodTypes)
-- Preserve legacy varargs: the townsfolk menu packs these into its own array.
---@param index number
---@return ...
function QuestieCompat.GetStablePetFoodTypes(index)
    if C_StableInfo and C_StableInfo.GetStablePetFoodTypes then
        return unpack(C_StableInfo.GetStablePetFoodTypes(index) or {})
    elseif GetStablePetFoodTypes then
        return GetStablePetFoodTypes(index)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_IsQuestWatched)
---Returns whether a quest log entry is currently being watched.
---@param questLogIndex number
---@return boolean isWatched
function QuestieCompat.IsQuestWatched(questLogIndex)
    if not questLogIndex or questLogIndex <= 0 then return false end
    if isForever then
        -- Forever: query native state by quest ID, not Questie's synthetic legacy global. Watch type 0 is valid.
        local questID = QuestieCompat.GetQuestIDFromLogIndex(questLogIndex)
        return questID ~= nil and C_QuestLog.GetQuestWatchType(questID) ~= nil
    end
    -- Classic: retain the existing legacy watch interception and fallback behavior.
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
-- Spell data and early library bridges
------------------------------------------

---@param spell number|string
---@return any ... Legacy spell-info tuple.
function QuestieCompat.GetSpellInfo(spell)
    if C_Spell and C_Spell.GetSpellInfo then
        -- Forever / modern Classic: callers expect the legacy tuple, including its unused rank slot.
        local info = C_Spell.GetSpellInfo(spell)
        if info then
            return info.name, nil, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID
        end
    elseif not isForever and GetSpellInfo then
        -- Classic: native legacy tuple. On Forever this global can be our own bridge, so never call it back.
        return GetSpellInfo(spell)
    end
end

---@param texture Texture
---@param desaturated boolean
---@return nil
function QuestieCompat.SetDesaturation(texture, desaturated)
    texture:SetDesaturated(desaturated)
end

if isForever then
    -- Forever: embedded AceGUI still calls these globals and loads immediately after this file.
    -- First-party code imports QuestieCompat; do not install these bridges on Classic or replace existing globals.
    GetSpellInfo = GetSpellInfo or QuestieCompat.GetSpellInfo
    SetDesaturation = SetDesaturation or QuestieCompat.SetDesaturation
end

---@param addon string
---@param field string
---@return string?
function QuestieCompat.GetAddOnMetadata(addon, field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addon, field)
    end
    return GetAddOnMetadata(addon, field)
end
