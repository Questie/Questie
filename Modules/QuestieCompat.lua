---@diagnostic disable: undefined-global, return-type-mismatch, undefined-field
---@class QuestieCompat
QuestieCompat = {}

local errorMsg = "Questie tried to call a blizzard API function that does not exist..."
local INDIZES_AVAILABLE = 7
local INDIZES_ACTIVE = 6

local tinsert = table.insert

-- QuestieDB loads later in the TOC, but ImportModule hands back the table CreateModule will populate, so this
-- reference is the real module by the time any function below runs. This file is only able to import at all
-- because QuestieLoader now loads ahead of it; it used to run first, when the global did not yet exist.
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local WatchFrame = QuestWatchFrame or WatchFrame

---Returns the quest log frame for the current client.
--- If all of these are nil it's fine to crash so users report it.
---@return frame
function QuestieCompat.GetQuestLogFrame()
    return QuestLogExFrame or ClassicQuestLog or QuestLogFrame or QuestMapFrame
end

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

-- Resolved on each call rather than once at load: the tracker frame is created
-- by an on-demand addon, so at load time it may not exist yet and the name would
-- stick as nil, leaving Blizzard's tracker visible underneath Questie's.
local function GetWatchFrame()
    return _G.WatchFrame or _G.ObjectiveTrackerFrame or _G.QuestWatchFrame
end

-- Hiding the modern tracker does not stick: Blizzard shows it again on the next
-- quest update. Parking it on a hidden parent keeps it out of the way without
-- fighting those Show calls every frame.
local hiddenParent

function QuestieCompat.HideWatchFrame()
    local watchFrame = GetWatchFrame()
    if not watchFrame then return end

    if watchFrame.SetParent and watchFrame ~= _G.WatchFrame then
        if not hiddenParent then
            hiddenParent = CreateFrame("Frame")
            hiddenParent:Hide()
        end
        if watchFrame:GetParent() ~= hiddenParent then
            watchFrame.questieOriginalParent = watchFrame:GetParent()
            watchFrame:SetParent(hiddenParent)
        end
        return
    end

    if Questie.IsTitanReforged then
        -- On titan reforged realms, the WatchFrame somehow behaves differently when hidden.
        -- details: https://github.com/Questie/Questie/issues/7497
        watchFrame:SetAlpha(0)
    else
        watchFrame:Hide()
    end
end

function QuestieCompat.ShowWatchFrame()
    local watchFrame = GetWatchFrame()
    if not watchFrame then return end

    if watchFrame.questieOriginalParent then
        watchFrame:SetParent(watchFrame.questieOriginalParent)
        watchFrame.questieOriginalParent = nil
        watchFrame:Show()
        return
    end

    if Questie.IsTitanReforged then
        -- On titan reforged realms, the WatchFrame somehow behaves differently when hidden.
        -- details: https://github.com/Questie/Questie/issues/7497
        watchFrame:SetAlpha(1)
    else
        watchFrame:Show()
    end
end

function QuestieCompat.GetWatchFramePoint()
    local watchFrame = GetWatchFrame()
    return watchFrame:GetPoint()
end

------------------------------------------
-- Newer client compatibility (1.60+)
------------------------------------------
-- The globals below were removed once the Classic clients moved onto the modern
-- UI code. Each is only defined when missing, so nothing here changes behaviour
-- on a client that still provides them.

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetNumQuestLogEntries)
---Returns the number of entries (including headers) in the player's quest log.
---@return number numEntries
---@return number numQuests
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
---TODO: C_QuestLog.GetInfo already returns a table; once all callers are migrated, return that table directly instead of flattening it into this legacy tuple.
function QuestieCompat.GetQuestLogTitle(questLogIndex)
    if C_QuestLog and C_QuestLog.GetInfo then
        local info = C_QuestLog.GetInfo(questLogIndex)
        if not info then return nil end

        local questTag
        if C_QuestLog.GetQuestTagInfo then
            local tagInfo = C_QuestLog.GetQuestTagInfo(info.questID)
            questTag = tagInfo and tagInfo.tagName
        end

        local isComplete
        if C_QuestLog.IsComplete and C_QuestLog.IsComplete(info.questID) then
            isComplete = 1
        end

        return info.title, info.level, questTag, info.isHeader, info.isCollapsed,
            isComplete, info.frequency, info.questID, info.startEvent,
            info.questID, info.isOnMap, info.hasLocalPOI, info.isTask,
            info.isBounty, info.isStory, info.isHidden, info.isScaling
    elseif GetQuestLogTitle then
        return GetQuestLogTitle(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SelectQuestLogEntry)
---Sets the selected entry in the quest log.
---@param questLogIndex number
function QuestieCompat.SelectQuestLogEntry(questLogIndex)
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetInfo then
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then
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
---@return number questLogIndex
function QuestieCompat.GetQuestLogSelection()
    if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetLogIndexForQuestID then
        local questID = C_QuestLog.GetSelectedQuest()
        return questID and C_QuestLog.GetLogIndexForQuestID(questID)
    elseif GetQuestLogSelection then
        return GetQuestLogSelection()
    end
    error(errorMsg, 2)
end

if not UnitAura and C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
    UnitAura = function(unit, index, filter)
        -- Aura data is refused outright once the execution is tainted, which it
        -- always is when called from an addon, so this must not be allowed to
        -- raise. Questie only reads these to spot XP/reputation buffs.
        local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, index, filter)
        if not ok or not aura then return nil end
        return aura.name, aura.icon, aura.applications, aura.dispelName,
            aura.duration, aura.expirationTime, aura.sourceUnit,
            aura.isStealable, aura.nameplateShowPersonal, aura.spellId
    end
end

if not GetSpellInfo and C_Spell and C_Spell.GetSpellInfo then
    GetSpellInfo = function(spell)
        local info = C_Spell.GetSpellInfo(spell)
        if not info then return nil end
        return info.name, nil, info.iconID, info.castTime,
            info.minRange, info.maxRange, info.spellID
    end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetItemInfo)
---Returns information about an item.
---@param item ItemId|string
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
        local info = C_QuestLog.GetInfo(questLogIndex or C_QuestLog.GetLogIndexForQuestID(C_QuestLog.GetSelectedQuest()))
        return info and C_QuestLog.GetNumQuestObjectives(info.questID) or 0
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
        return C_QuestLog.GetNumQuestWatches()
    elseif GetNumQuestWatches then
        return GetNumQuestWatches(arg)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestIndexForWatch)
---Returns the quest log index of a watched quest.
---@param watchIndex number
---@return number questLogIndex
function QuestieCompat.GetQuestIndexForWatch(watchIndex)
    if C_QuestLog and C_QuestLog.GetQuestIDForQuestWatchIndex and C_QuestLog.GetLogIndexForQuestID then
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(watchIndex)
        return questID and C_QuestLog.GetLogIndexForQuestID(questID)
    elseif GetQuestIndexForWatch then
        return GetQuestIndexForWatch(watchIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_AddQuestWatch)
---Adds a quest log entry to the tracked quest watches.
---@param questLogIndex number
function QuestieCompat.AddQuestWatch(questLogIndex)
    if C_QuestLog and C_QuestLog.AddQuestWatch and C_QuestLog.GetInfo then
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then C_QuestLog.AddQuestWatch(info.questID) end
        return
    elseif AddQuestWatch then
        return AddQuestWatch(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_RemoveQuestWatch)
---Removes a quest log entry from the tracked quest watches.
---@param questLogIndex number
function QuestieCompat.RemoveQuestWatch(questLogIndex)
    if C_QuestLog and C_QuestLog.RemoveQuestWatch and C_QuestLog.GetInfo then
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then C_QuestLog.RemoveQuestWatch(info.questID) end
        return
    elseif RemoveQuestWatch then
        return RemoveQuestWatch(questLogIndex)
    end
    error(errorMsg, 2)
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetQuestGreenRange)
---Returns the level spread at which a quest is considered "green" (trivial) relative to the player.
---No modern API replacement exists; falls back to a fixed spread matching Classic's own value.
---@return number range
function QuestieCompat.GetQuestGreenRange()
    if GetQuestGreenRange then
        return GetQuestGreenRange("player")
    end
    return 5
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
        return C_Reputation.GetNumFactions()
    elseif GetNumFactions then
        return GetNumFactions()
    end
    error(errorMsg, 2)
end

if not GetFactionInfo and C_Reputation and C_Reputation.GetFactionDataByIndex then
    GetFactionInfo = function(index)
        local d = C_Reputation.GetFactionDataByIndex(index)
        if not d then return nil end
        return d.name, d.description, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.atWarWith,
            d.canToggleAtWar, d.isHeader, d.isCollapsed, d.isHeaderWithRep,
            d.isWatched, d.isChild, d.factionID, d.hasBonusRepGain,
            d.canSetInactive
    end
end

if not ExpandFactionHeader and C_Reputation and C_Reputation.ExpandFactionHeader then
    ExpandFactionHeader = function(index)
        return C_Reputation.ExpandFactionHeader(index)
    end
end

if not CollapseFactionHeader and C_Reputation and C_Reputation.CollapseFactionHeader then
    CollapseFactionHeader = function(index)
        return C_Reputation.CollapseFactionHeader(index)
    end
end


-- Global SetDesaturation was removed; the method on the texture remains.
if not SetDesaturation then
    SetDesaturation = function(texture, desaturate)
        if texture and texture.SetDesaturated then
            texture:SetDesaturated(desaturate)
        end
    end
end

if not GetFactionInfoByID and C_Reputation and C_Reputation.GetFactionDataByID then
    GetFactionInfoByID = function(factionID)
        local d = C_Reputation.GetFactionDataByID(factionID)
        if not d then return nil end
        return d.name, d.description, d.reaction, d.currentReactionThreshold,
            d.nextReactionThreshold, d.currentStanding, d.atWarWith,
            d.canToggleAtWar, d.isHeader, d.isCollapsed, d.isHeaderWithRep,
            d.isWatched, d.isChild, d.factionID, d.hasBonusRepGain,
            d.canSetInactive
    end
end

if not GetQuestLogIndexByID and C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
    GetQuestLogIndexByID = function(questID)
        return C_QuestLog.GetLogIndexForQuestID(questID)
    end
end

if not GetQuestLink and C_QuestLog and C_QuestLog.GetQuestLink then
    GetQuestLink = function(arg)
        return C_QuestLog.GetQuestLink(arg)
    end
end

if not GetQuestResetTime and C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset then
    GetQuestResetTime = function()
        return C_DateAndTime.GetSecondsUntilDailyReset()
    end
end

-- The indexed skill-line API is gone. Questie walks it purely to learn which
-- professions the player has and at what rank, so rebuild that list from
-- whichever modern source this client provides and present it in the old shape.
if not GetNumSkillLines or not GetSkillLineInfo then
    local lines = {}

    local function collect()
        wipe(lines)

        if GetProfessions and GetProfessionInfo then
            local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
            for _, index in ipairs({prof1 or false, prof2 or false, archaeology or false,
                fishing or false, cooking or false}) do
                if index then
                    local name, _, rank = GetProfessionInfo(index)
                    if name then
                        lines[#lines + 1] = {name = name, rank = rank or 0}
                    end
                end
            end
        end

        if #lines == 0 and C_TradeSkillUI and C_TradeSkillUI.GetAllProfessionTradeSkillLines
            and C_TradeSkillUI.GetTradeSkillLineInfoByID then
            for _, skillLineID in ipairs(C_TradeSkillUI.GetAllProfessionTradeSkillLines()) do
                local info = C_TradeSkillUI.GetTradeSkillLineInfoByID(skillLineID)
                local name = info and (info.professionName or info.displayName)
                if name then
                    lines[#lines + 1] = {name = name, rank = info.skillLevel or 0}
                end
            end
        end

        return #lines
    end

    GetNumSkillLines = function()
        return collect()
    end

    GetSkillLineInfo = function(index)
        local line = lines[index]
        if not line then return nil end
        -- name, isHeader, isExpanded, rank
        return line.name, false, false, line.rank
    end
end

if not ExpandSkillHeader then
    ExpandSkillHeader = function() end
end

-- OnTooltipSetItem / OnTooltipSetUnit are no longer script types; the modern
-- client routes them through TooltipDataProcessor. Hook whichever exists so the
-- tooltip additions keep working instead of being silently dropped.
local tooltipDataType = {
    OnTooltipSetItem = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item,
    OnTooltipSetUnit = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit,
}

function QuestieCompat.HookTooltipScript(frame, script, handler)
    if not frame then return end

    if frame.HasScript and frame:HasScript(script) then
        return frame:HookScript(script, handler)
    end

    local dataType = tooltipDataType[script]
    if dataType and TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        return TooltipDataProcessor.AddTooltipPostCall(dataType, function(tooltip, ...)
            if tooltip ~= frame then return end
            -- Run on the next frame rather than inline. Executing addon code
            -- inside Blizzard's secure tooltip call taints it, and on this beta
            -- client Blizzard_PTRFeedback then fails reading a protected string
            -- ("secret string value") from that same tainted execution.
            local args = {...}
            C_Timer.After(0, function()
                if tooltip:IsShown() then
                    handler(tooltip, unpack(args))
                end
            end)
        end)
    end
end

-- Returned a [questID] = true map. The modern call returns a plain array, and
-- Questie indexes the result by quest id, so convert rather than pass through.
if not GetQuestsCompleted and C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs then
    GetQuestsCompleted = function(target)
        local completed = target or {}
        for _, questID in ipairs(C_QuestLog.GetAllCompletedQuestIDs()) do
            completed[questID] = true
        end
        return completed
    end
end

-- Old signature returned (tagId, tagName) directly; the modern call returns a
-- table, and Questie destructures two values from it.
if not GetQuestTagInfo and C_QuestLog and C_QuestLog.GetQuestTagInfo then
    GetQuestTagInfo = function(questID)
        local info = C_QuestLog.GetQuestTagInfo(questID)
        if not info then return nil end
        return info.tagID, info.tagName
    end
end

-- Questie hooks a number of Blizzard functions by name, several of which no
-- longer exist here. Each one raises and aborts whatever file it is in, so
-- skip the hook instead of letting a missing target take the module with it.
do
    local original = hooksecurefunc
    hooksecurefunc = function(arg1, arg2, arg3)
        if type(arg1) == "string" and type(_G[arg1]) ~= "function" then
            return
        end
        if arg3 ~= nil then
            return original(arg1, arg2, arg3)
        end
        return original(arg1, arg2)
    end
end

-- Blizzard constant; Questie uses it as a "for" limit, so a nil aborts the loop.
if not MAX_NUM_QUESTS then
    MAX_NUM_QUESTS = 32
end

-- The old default quest-log/watch UI is gone. Questie calls these purely to ask
-- Blizzard's own frames to redraw, so doing nothing is correct here.
if not WatchFrame_Update and not QuestWatch_Update then
    WatchFrame_Update = function() end
end
if not QuestLog_Update then
    QuestLog_Update = function() end
end

-- Questie only uses this as a "does this quest have a timer" gate; the value it
-- actually displays comes from GetQuestLogTimeLeft, which still exists. Report
-- the real remaining time so timed quests keep working.
if not GetQuestTimers then
    GetQuestTimers = function(questID)
        if not questID then return nil end

        if C_QuestLog and C_QuestLog.GetTimeAllowed then
            local total, elapsed = C_QuestLog.GetTimeAllowed(questID)
            if total and total > 0 then
                return total - (elapsed or 0)
            end
        end

        if GetQuestLogTimeLeft and C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
            local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
            local remaining = questLogIndex and GetQuestLogTimeLeft(questLogIndex)
            if remaining and remaining > 0 then
                return remaining
            end
        end

        return nil
    end
end

-- Removed global helper; the equivalent is now a method on the frame itself.
if not MouseIsOver then
    MouseIsOver = function(frame, top, bottom, left, right)
        if not frame or not frame.IsMouseOver then return false end
        return frame:IsMouseOver(top, bottom, left, right)
    end
end

-- Gossip quest lists moved under C_GossipInfo.
if not GetNumGossipActiveQuests and C_GossipInfo and C_GossipInfo.GetNumActiveQuests then
    GetNumGossipActiveQuests = function()
        return C_GossipInfo.GetNumActiveQuests()
    end
end

if not GetNumGossipAvailableQuests and C_GossipInfo and C_GossipInfo.GetNumAvailableQuests then
    GetNumGossipAvailableQuests = function()
        return C_GossipInfo.GetNumAvailableQuests()
    end
end

if not SelectGossipActiveQuest and C_GossipInfo and C_GossipInfo.SelectActiveQuest then
    SelectGossipActiveQuest = function(index)
        return C_GossipInfo.SelectActiveQuest(index)
    end
end

if not SelectGossipAvailableQuest and C_GossipInfo and C_GossipInfo.SelectAvailableQuest then
    SelectGossipAvailableQuest = function(index)
        return C_GossipInfo.SelectAvailableQuest(index)
    end
end

-- Abandoning a quest. Questie calls these from its tracker's right-click menu
-- and from the breadcrumb handling, both without a nil check.
if not SetAbandonQuest then
    SetAbandonQuest = function()
        if C_QuestLog and C_QuestLog.SetAbandonQuest then
            return C_QuestLog.SetAbandonQuest()
        end
    end
end

if not GetAbandonQuestName then
    GetAbandonQuestName = function()
        if C_QuestLog and C_QuestLog.GetAbandonQuestName then
            return C_QuestLog.GetAbandonQuestName()
        end
        -- Fall back to the title of whatever quest is currently selected.
        if C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetTitleForQuestID then
            return C_QuestLog.GetTitleForQuestID(C_QuestLog.GetSelectedQuest())
        end
        return ""
    end
end

if not GetAbandonQuestItems then
    GetAbandonQuestItems = function()
        if C_QuestLog and C_QuestLog.GetAbandonQuestItems then
            return C_QuestLog.GetAbandonQuestItems()
        end
        return nil
    end
end

if not AbandonQuest then
    AbandonQuest = function()
        if C_QuestLog and C_QuestLog.AbandonQuest then
            return C_QuestLog.AbandonQuest()
        end
    end
end

if not GetQuestIDFromLogIndex and C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
    GetQuestIDFromLogIndex = function(questLogIndex)
        return C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
    end
end

if not QuestLog_SetSelection then
    QuestLog_SetSelection = function(questLogIndex)
        if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetQuestIDForLogIndex then
            local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
            if questID then
                return C_QuestLog.SetSelectedQuest(questID)
            end
        end
    end
end

-- Redraw helpers for the old quest log window, which no longer exists.
if not QuestLog_UpdateQuestDetails then
    QuestLog_UpdateQuestDetails = function() end
end

if not StaticPopup_Resize then
    StaticPopup_Resize = function() end
end

-- Questie uses this only for "Copied URL to clipboard" feedback.
if not ActionStatus_DisplayMessage then
    ActionStatus_DisplayMessage = function(message)
        if UIErrorsFrame and message then
            UIErrorsFrame:AddMessage(message, 1, 1, 1)
        end
    end
end

-- No achievement UI on this client. These are reached from tracker clicks.
if not AchievementFrame_ToggleAchievementFrame then
    AchievementFrame_ToggleAchievementFrame = function() end
end

if not AchievementFrame_SelectAchievement then
    AchievementFrame_SelectAchievement = function() end
end

if not AchievementFrameAchievements_ForceUpdate then
    AchievementFrameAchievements_ForceUpdate = function() end
end

-- Returns a varargs list; Questie packs it into a table, so returning nothing
-- yields an empty table rather than an error.
if not GetTrackedAchievements then
    GetTrackedAchievements = function() end
end

if not GetNumTrackedAchievements then
    GetNumTrackedAchievements = function() return 0 end
end

if not RemoveTrackedAchievement then
    RemoveTrackedAchievement = function() end
end

-- Same pattern: packed into a table by the townsfolk menu.
if not GetStablePetFoodTypes then
    GetStablePetFoodTypes = function() end
end

if not IsQuestWatched then
    IsQuestWatched = function(questLogIndex)
        if C_QuestLog and C_QuestLog.GetQuestWatchType and C_QuestLog.GetQuestIDForLogIndex then
            local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
            return questID ~= nil and C_QuestLog.GetQuestWatchType(questID) ~= nil
        end
        return false
    end
end


-- This client can hand back "secret" strings from tooltip font strings.
-- Comparing or converting one raises, so probe it once and return nil when it
-- cannot be used. Callers then skip the text-driven path instead of erroring.
local function usableString(text)
    if text == nil then return false end
    return pcall(function() return text == "" end)
end

function QuestieCompat.GetTooltipText(fontString, tooltip)
    if fontString and fontString.GetText then
        local ok, text = pcall(fontString.GetText, fontString)
        if ok and usableString(text) then
            return text
        end
    end

    -- The font string is protected on this client. The structured tooltip data
    -- carries the same first line and is not, so fall back to that.
    if tooltip and tooltip.GetTooltipData then
        local ok, data = pcall(tooltip.GetTooltipData, tooltip)
        if ok and data and data.lines and data.lines[1] then
            local text = data.lines[1].leftText
            if usableString(text) then
                return text
            end
        end
    end

    return nil
end
