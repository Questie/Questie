-- This file does not use the module system, so it names its own load-timing interval.
QuestieLoader:StampLoadBoundary()

local addonName, _ = ...

-- Check addon is not renamed to avoid conflicts in global name space.
if addonName ~= "Questie" then
    local msg = {"You have renamed Questie addon.", "This is restricted to avoid issues.", "Please remove '" .. addonName .. "'",
        "and reinstall the original version."}
    StaticPopupDialogs["QUESTIE_ADDON_NAME_ERROR"] = {
        text = "|cffff0000ERROR|r\n" .. msg[1] .. "\n" .. msg[2] .. "\n\n" .. msg[3] .. "\n" .. msg[4],
        button2 = "OK",
        hasEditBox = false,
        whileDead = true,
    }

    C_Timer.After(4, function()
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[1] .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[2] .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[3] .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[4] .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
        error("ERROR: " .. msg[1] .. " " .. msg[2] .. " " .. msg[3])
    end)
    StaticPopup_Show("QUESTIE_ADDON_NAME_ERROR")
    return
end

if Questie then
    C_Timer.After(4, function()
        error("ERROR!! -> Questie already loaded! Please only have one Questie installed!")
        for _ = 1, 10 do
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ERROR!!|r -> Questie already loaded! Please only have one Questie installed!")
        end
    end);
    error("ERROR!! -> Questie already loaded! Please only have one Questie installed!")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ERROR!!|r -> Questie already loaded! Please only have one Questie installed!")
    Questie = {}
    return
end

--Initialized below
---@class Questie : AceAddon, AceConsole-3.0, AceEvent-3.0, AceTimer-3.0, AceComm-3.0, AceBucket-3.0
Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceBucket-3.0")

Questie.API = {
    isReady = false,
}

-- preinit placeholder to stop tukui crashing from literally force-removing one of our features no matter what users select in the config ui
Questie.db = {profile = {minimap = {hide = false}}}

-- prevent multiple warnings for the same ID, not sure the best place to put this
Questie._sessionWarnings = {}

--- Addon is running on World of Warcraft: Forever client
--- There is no WOW_PROJECT_ID for it yet, so the interface version (e.g. 16001) is used instead
---@type boolean
Questie.IsForever = string.sub(select(4, GetBuildInfo()), 1, 2) == "16"

--- Addon is running on Classic MoP client
---@type boolean
Questie.IsMoP = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC

--- Addon is running on Classic Cata client
---@type boolean
Questie.IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

--- Addon is running on Classic Wotlk client
---@type boolean
Questie.IsWotlk = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

--- Addon is running on Classic TBC client
---@type boolean
Questie.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

--- Addon is running on Classic "Vanilla" client: Means Classic Era and its seasons like SoM
---@type boolean
Questie.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

--- Addon is running on Classic "Vanilla" client and on Era realm (non-seasonal)
---@type boolean
Questie.IsEra = Questie.IsClassic and (not C_Seasons.HasActiveSeason())

-- See https://warcraft.wiki.gg/wiki/API_C_Seasons.GetActiveSeason

--- Addon is running on Classic "Vanilla" client and on Season of Mastery realm specifically
---@type boolean
Questie.IsSoM = Questie.IsClassic and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfMastery)

--- Addon is running on Classic "Vanilla" client and on Season of Discovery realm specifically
---@type boolean
Questie.IsSoD = Questie.IsClassic and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfDiscovery)

--- Addon is running on Classic "WotLK" client and on a Titan Forged realm specifically
---@type boolean
Questie.IsTitanReforged = Questie.IsWotlk and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == 109) -- There is no entry in Enum.SeasonID for this

--- Addon is running on Classic "Vanilla" client and on Classic Anniversary realm ( )
---@type boolean
Questie.IsAnniversaryEra = Questie.IsClassic and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.Fresh)

--- Addon is running on Classic "Vanilla" client and on Classic Anniversary realm ( )
---@type boolean
Questie.IsAnniversaryTBC = Questie.IsTBC and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.Fresh)

--- Addon is running on Classic "Vanilla" client and on Classic Anniversary Hardcore realm
---@type boolean
Questie.IsAnniversaryHardcore = Questie.IsClassic and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.FreshHardcore)

--- Addon is running on a HardCore realm specifically
---@type boolean
Questie.IsHardcore = C_GameRules and C_GameRules.IsHardcoreActive()

--- Addon is running on a Chinese realm
---@type boolean
Questie.IsChinaRegion = GetCurrentRegion() == 5

--- Addon is running on EU realm
---@type boolean
Questie.IsEURegion = GetCurrentRegion() == 3

------------------------------------------
-- WoW: Forever compatibility
------------------------------------------
-- Forever runs the modern UI code, which removed the globals below. They are
-- restored here rather than guarded at every call site, and only when Forever
-- is the running client, so no other client sees a behaviour change. This has
-- to happen before any module captures one of them into a local at load time.

if Questie.IsForever and not GetNumQuestLogEntries then
    GetNumQuestLogEntries = function()
        return C_QuestLog.GetNumQuestLogEntries()
    end
end

if Questie.IsForever and not GetQuestLogTitle then
    GetQuestLogTitle = function(questLogIndex)
        local info = C_QuestLog.GetInfo(questLogIndex)
        if not info then return nil end

        -- Headers have a questID of 0 and carry neither a tag nor a completion state
        local questTag, isComplete
        if info.questID > 0 then
            local tagInfo = C_QuestLog.GetQuestTagInfo(info.questID)
            questTag = tagInfo and tagInfo.tagName

            -- Questie expects the number the old API returned:
            -- -1 = failed, nil = not complete, 1 = complete
            if C_QuestLog.IsFailed(info.questID) then
                isComplete = -1
            elseif C_QuestLog.IsComplete(info.questID) then
                isComplete = 1
            end
        end

        return info.title, info.level, questTag, info.isHeader, info.isCollapsed,
            isComplete, info.frequency, info.questID, info.startEvent,
            info.questID, info.isOnMap, info.hasLocalPOI, info.isTask,
            info.isBounty, info.isStory, info.isHidden, info.isScaling
    end
end

if Questie.IsForever and not SelectQuestLogEntry then
    SelectQuestLogEntry = function(questLogIndex)
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then
            C_QuestLog.SetSelectedQuest(info.questID)
        end
    end
end

if Questie.IsForever and not GetQuestLogSelection then
    GetQuestLogSelection = function()
        local questID = C_QuestLog.GetSelectedQuest()
        return questID and C_QuestLog.GetLogIndexForQuestID(questID)
    end
end

if Questie.IsForever and not UnitAura then
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

if Questie.IsForever and not GetSpellInfo then
    GetSpellInfo = function(spell)
        local info = C_Spell.GetSpellInfo(spell)
        if not info then return nil end
        return info.name, nil, info.iconID, info.castTime,
            info.minRange, info.maxRange, info.spellID
    end
end

if Questie.IsForever and not GetItemInfo then
    GetItemInfo = function(item)
        return C_Item.GetItemInfo(item)
    end
end

if Questie.IsForever and not IsQuestFlaggedCompleted then
    IsQuestFlaggedCompleted = function(questID)
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    end
end

if Questie.IsForever and not GetNumQuestLeaderBoards then
    GetNumQuestLeaderBoards = function(questLogIndex)
        local info = C_QuestLog.GetInfo(questLogIndex or C_QuestLog.GetLogIndexForQuestID(C_QuestLog.GetSelectedQuest()))
        return info and C_QuestLog.GetNumQuestObjectives(info.questID) or 0
    end
end

if Questie.IsForever and not GetNumQuestWatches then
    GetNumQuestWatches = function()
        return C_QuestLog.GetNumQuestWatches()
    end
end

if Questie.IsForever and not GetQuestIndexForWatch then
    GetQuestIndexForWatch = function(watchIndex)
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(watchIndex)
        return questID and C_QuestLog.GetLogIndexForQuestID(questID)
    end
end

if Questie.IsForever and not AddQuestWatch then
    AddQuestWatch = function(questLogIndex)
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then C_QuestLog.AddQuestWatch(info.questID) end
    end
end

if Questie.IsForever and not RemoveQuestWatch then
    RemoveQuestWatch = function(questLogIndex)
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then C_QuestLog.RemoveQuestWatch(info.questID) end
    end
end

-- Only used to tint quest levels. A fixed spread matches Classic's own value.
if Questie.IsForever and not GetQuestGreenRange then
    GetQuestGreenRange = function()
        return 5
    end
end

if Questie.IsForever and not GetItemCount then
    GetItemCount = function(item, includeBank, includeCharges, includeReagentBank)
        return C_Item.GetItemCount(item, includeBank, includeCharges, includeReagentBank)
    end
end

if Questie.IsForever and not GetItemIcon then
    GetItemIcon = function(item)
        return C_Item.GetItemIconByID(item)
    end
end

if Questie.IsForever and not GetNumFactions then
    GetNumFactions = function()
        return C_Reputation.GetNumFactions()
    end
end

if Questie.IsForever and not GetFactionInfo then
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

if Questie.IsForever and not ExpandFactionHeader then
    ExpandFactionHeader = function(index)
        return C_Reputation.ExpandFactionHeader(index)
    end
end

if Questie.IsForever and not CollapseFactionHeader then
    CollapseFactionHeader = function(index)
        return C_Reputation.CollapseFactionHeader(index)
    end
end


-- Global SetDesaturation was removed; the method on the texture remains.
if Questie.IsForever and not SetDesaturation then
    SetDesaturation = function(texture, desaturate)
        if texture and texture.SetDesaturated then
            texture:SetDesaturated(desaturate)
        end
    end
end

if Questie.IsForever and not GetFactionInfoByID then
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

if Questie.IsForever and not GetQuestLogIndexByID then
    GetQuestLogIndexByID = function(questID)
        return C_QuestLog.GetLogIndexForQuestID(questID)
    end
end

if Questie.IsForever and not GetQuestLink then
    GetQuestLink = function(arg)
        return C_QuestLog.GetQuestLink(arg)
    end
end

if Questie.IsForever and not GetQuestResetTime then
    GetQuestResetTime = function()
        return C_DateAndTime.GetSecondsUntilDailyReset()
    end
end

-- The indexed skill-line API is gone. Questie walks it purely to learn which
-- professions the player has and at what rank, so rebuild that list from
-- whichever modern source this client provides and present it in the old shape.
if Questie.IsForever and (not GetNumSkillLines or not GetSkillLineInfo) then
    local lines = {}

    local function collect()
        wipe(lines)

        if GetProfessions and GetProfessionInfo then
            local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
            for _, index in ipairs({ prof1 or false, prof2 or false, archaeology or false,
                                     fishing or false, cooking or false }) do
                if index then
                    local name, _, rank = GetProfessionInfo(index)
                    if name then
                        lines[#lines + 1] = { name = name, rank = rank or 0 }
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
                    lines[#lines + 1] = { name = name, rank = info.skillLevel or 0 }
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

if Questie.IsForever and not ExpandSkillHeader then
    ExpandSkillHeader = function() end
end


-- Returned a [questID] = true map. The modern call returns a plain array, and
-- Questie indexes the result by quest id, so convert rather than pass through.
if Questie.IsForever and not GetQuestsCompleted then
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
if Questie.IsForever and not GetQuestTagInfo then
    GetQuestTagInfo = function(questID)
        local info = C_QuestLog.GetQuestTagInfo(questID)
        if not info then return nil end
        return info.tagID, info.tagName
    end
end

-- Questie hooks a number of Blizzard functions by name, several of which no
-- longer exist here. Each one raises and aborts whatever file it is in, so
-- skip the hook instead of letting a missing target take the module with it.
if Questie.IsForever then
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
if Questie.IsForever and not MAX_NUM_QUESTS then
    MAX_NUM_QUESTS = 32
end

-- The old default quest-log/watch UI is gone. Questie calls these purely to ask
-- Blizzard's own frames to redraw, so doing nothing is correct here.
if Questie.IsForever and not WatchFrame_Update and not QuestWatch_Update then
    WatchFrame_Update = function() end
end
if Questie.IsForever and not QuestLog_Update then
    QuestLog_Update = function() end
end

-- Questie only uses this as a "does this quest have a timer" gate; the value it
-- actually displays comes from GetQuestLogTimeLeft, which still exists. Report
-- the real remaining time so timed quests keep working.
if Questie.IsForever and not GetQuestTimers then
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
if Questie.IsForever and not MouseIsOver then
    MouseIsOver = function(frame, top, bottom, left, right)
        if not frame or not frame.IsMouseOver then return false end
        return frame:IsMouseOver(top, bottom, left, right)
    end
end

-- Gossip quest lists moved under C_GossipInfo.
if Questie.IsForever and not GetNumGossipActiveQuests then
    GetNumGossipActiveQuests = function()
        return C_GossipInfo.GetNumActiveQuests()
    end
end

if Questie.IsForever and not GetNumGossipAvailableQuests then
    GetNumGossipAvailableQuests = function()
        return C_GossipInfo.GetNumAvailableQuests()
    end
end

if Questie.IsForever and not SelectGossipActiveQuest then
    SelectGossipActiveQuest = function(index)
        return C_GossipInfo.SelectActiveQuest(index)
    end
end

if Questie.IsForever and not SelectGossipAvailableQuest then
    SelectGossipAvailableQuest = function(index)
        return C_GossipInfo.SelectAvailableQuest(index)
    end
end

-- Abandoning a quest. Questie calls these from its tracker's right-click menu
-- and from the breadcrumb handling, both without a nil check.
if Questie.IsForever and not SetAbandonQuest then
    SetAbandonQuest = function()
        if C_QuestLog and C_QuestLog.SetAbandonQuest then
            return C_QuestLog.SetAbandonQuest()
        end
    end
end

if Questie.IsForever and not GetAbandonQuestName then
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

if Questie.IsForever and not GetAbandonQuestItems then
    GetAbandonQuestItems = function()
        if C_QuestLog and C_QuestLog.GetAbandonQuestItems then
            return C_QuestLog.GetAbandonQuestItems()
        end
        return nil
    end
end

if Questie.IsForever and not AbandonQuest then
    AbandonQuest = function()
        if C_QuestLog and C_QuestLog.AbandonQuest then
            return C_QuestLog.AbandonQuest()
        end
    end
end

if Questie.IsForever and not GetQuestIDFromLogIndex then
    GetQuestIDFromLogIndex = function(questLogIndex)
        return C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
    end
end

if Questie.IsForever and not QuestLog_SetSelection then
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
if Questie.IsForever and not QuestLog_UpdateQuestDetails then
    QuestLog_UpdateQuestDetails = function() end
end

if Questie.IsForever and not StaticPopup_Resize then
    StaticPopup_Resize = function() end
end

-- Questie uses this only for "Copied URL to clipboard" feedback.
if Questie.IsForever and not ActionStatus_DisplayMessage then
    ActionStatus_DisplayMessage = function(message)
        if UIErrorsFrame and message then
            UIErrorsFrame:AddMessage(message, 1, 1, 1)
        end
    end
end

-- No achievement UI on this client. These are reached from tracker clicks.
if Questie.IsForever and not AchievementFrame_ToggleAchievementFrame then
    AchievementFrame_ToggleAchievementFrame = function() end
end

if Questie.IsForever and not AchievementFrame_SelectAchievement then
    AchievementFrame_SelectAchievement = function() end
end

if Questie.IsForever and not AchievementFrameAchievements_ForceUpdate then
    AchievementFrameAchievements_ForceUpdate = function() end
end

-- Returns a varargs list; Questie packs it into a table, so returning nothing
-- yields an empty table rather than an error.
if Questie.IsForever and not GetTrackedAchievements then
    GetTrackedAchievements = function() end
end

if Questie.IsForever and not GetNumTrackedAchievements then
    GetNumTrackedAchievements = function() return 0 end
end

if Questie.IsForever and not RemoveTrackedAchievement then
    RemoveTrackedAchievement = function() end
end

-- Same pattern: packed into a table by the townsfolk menu.
if Questie.IsForever and not GetStablePetFoodTypes then
    GetStablePetFoodTypes = function() end
end

if Questie.IsForever and not IsQuestWatched then
    IsQuestWatched = function(questLogIndex)
        if C_QuestLog and C_QuestLog.GetQuestWatchType and C_QuestLog.GetQuestIDForLogIndex then
            local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
            return questID ~= nil and C_QuestLog.GetQuestWatchType(questID) ~= nil
        end
        return false
    end
end

if Questie.IsForever and not GetItemCooldown then
    GetItemCooldown = function(itemID)
        return C_Item.GetItemCooldown(itemID)
    end
end

-- Replaced by GetMouseFoci, which returns a list instead of a single frame.
if Questie.IsForever and not GetMouseFocus and GetMouseFoci then
    GetMouseFocus = function()
        local foci = GetMouseFoci()
        return foci and foci[1]
    end
end
