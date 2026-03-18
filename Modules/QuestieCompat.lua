---@diagnostic disable: undefined-global, return-type-mismatch, undefined-field
---@class QuestieCompat
QuestieCompat = setmetatable({}, {__index = _G})

-- addon is running on 3.3.5 WotLK client
QuestieCompat.Is335 = (select(4, GetBuildInfo()) == 30300)

local errorMsg = "Questie tried to call a blizzard API function that does not exist..."

------------------------------------------
-- Older client compatibility (pre 1.14.1)
------------------------------------------

-- Add missing Seasons object, if not available (e.g. 1.14.0 and below is missing it)
if not C_Seasons then
    C_Seasons = {
        ---[C_Seasons.HasActiveSeason Documentation](https://wowpedia.fandom.com/wiki/API_C_Seasons.HasActiveSeason)
        ---Returns true if the player is on a seasonal realm.
        HasActiveSeason = function()
            return false
        end,
        ---[C_Seasons.GetActiveSeason Documentation](https://wowpedia.fandom.com/wiki/API_C_Seasons.GetActiveSeason)
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

---[SetMinResize Documentation](https://wowpedia.fandom.com/wiki/API_Frame_SetMinResize)
---[SetMaxResize Documentation](https://wowpedia.fandom.com/wiki/API_Frame_SetMaxResize)
---[SetResizeBounds Documentation](https://wowpedia.fandom.com/wiki/API_Frame_SetMinResize)
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

---[Documentation](https://wowpedia.fandom.com/wiki/API_C_GossipInfo.GetAvailableQuests)
---Returns the available quests at a quest giver.
---@return GossipQuestUIInfo[] info
function QuestieCompat.GetAvailableQuests()
    if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        local info = C_GossipInfo.GetAvailableQuests()
        local availableQuests = {}
        local index = 1
        for _, availableQuest in pairs(info) do
            availableQuests[index] = availableQuest.title
            availableQuests[index + 1] = availableQuest.questLevel
            availableQuests[index + 2] = availableQuest.isTrivial
            availableQuests[index + 3] = availableQuest.frequency
            availableQuests[index + 4] = availableQuest.repeatable
            availableQuests[index + 5] = availableQuest.isLegendary
            availableQuests[index + 6] = availableQuest.isIgnored
            index = index + 7
        end
        return unpack(availableQuests)
    elseif GetGossipAvailableQuests then
        return GetGossipAvailableQuests() -- https://wowpedia.fandom.com/wiki/API_GetGossipAvailableQuests
    end
    error(errorMsg, 2)
end

---[Documentation](https://wowpedia.fandom.com/wiki/API_C_GossipInfo.GetActiveQuests)
---Returns the quests which can be turned in at a quest giver.
---@return GossipQuestUIInfo[] info
function QuestieCompat.GetActiveQuests()
    if C_GossipInfo and C_GossipInfo.GetActiveQuests then
        -- QuestieDB needs to be loaded locally, otherwise it will be an empty module
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        local info = C_GossipInfo.GetActiveQuests()
        local activeQuests = {}
        local index = 1
        for _, activeQuest in pairs(info) do
            activeQuests[index] = activeQuest.title
            activeQuests[index + 1] = activeQuest.questLevel
            activeQuests[index + 2] = activeQuest.isTrivial
            activeQuests[index + 3] = activeQuest.isComplete or QuestieDB.IsComplete(activeQuest.questID) == 1
            activeQuests[index + 4] = activeQuest.isLegendary
            activeQuests[index + 5] = activeQuest.isIgnored
            index = index + 6
        end
        return unpack(activeQuests)
    elseif GetGossipActiveQuests then
        return GetGossipActiveQuests() -- https://wowpedia.fandom.com/wiki/API_GetGossipActiveQuests
    end
    error(errorMsg, 2)
end

---[Documentation](https://wowpedia.fandom.com/wiki/API_C_GossipInfo.SelectAvailableQuest)
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

---[Documentation](https://wowpedia.fandom.com/wiki/API_C_GossipInfo.SelectActiveQuest)
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

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetContainerNumSlots)
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

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetContainerItemInfo)
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

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetItemCooldown)
---Returns info about the cooldown state and time of an item.
---@param itemID number The item ID.
---@return number startTime The time when the cooldown started (as returned by GetTime()) or zero if no cooldown.
---@return number duration The number of seconds the cooldown will last, or zero if no cooldown.
---@return number enable 1 if the item is ready or on cooldown, 0 if the item is used, but the cooldown didn't start yet (e.g. potion in combat).
function QuestieCompat.GetItemCooldown(itemID)
    if C_Container and C_Container.GetItemCooldown then
        return C_Container.GetItemCooldown(itemID)
    else
        return GetItemCooldown(itemID)
    end
end
