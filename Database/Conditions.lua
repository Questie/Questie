---@class QuestieConditions
local QuestieConditions = QuestieLoader:CreateModule("QuestieConditions")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")

-- Blizzard API locals
local UnitAura = UnitAura
local GetItemCount = C_Item and C_Item.GetItemCount or GetItemCount
local IsSpellKnown = IsSpellKnown
local GetAchievementInfo = GetAchievementInfo
local UnitFactionGroup = UnitFactionGroup
local IsEquippedItem = IsEquippedItem

--- Build the condition function environment table.
--- Must be called after Questie modules are initialized.
function QuestieConditions:Initialize()
    self.conditionFunctions = {
        -- Quest State
        QuestInLog = function(questId)
            if not questId then return false end
            return QuestiePlayer.currentQuestlog[questId] ~= nil
        end,

        QuestRewarded = function(questId)
            if not questId then return false end
            return Questie.db.char.complete[questId] == true
        end,

        QuestNone = function(questId)
            if not questId then return false end
            return QuestiePlayer.currentQuestlog[questId] == nil
                and not Questie.db.char.complete[questId]
        end,

        QuestAvailable = function(questId)
            if not questId then return false end
            local ok, result = pcall(QuestieDB.IsDoable, questId)
            if not ok then return false end
            return result == true
        end,

        -- Player Buffs/Debuffs
        HasAura = function(spellId)
            if not spellId then return false end
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, auraSpellId = UnitAura("player", i, "HELPFUL")
                if not auraSpellId then break end
                if auraSpellId == spellId then return true end
            end
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, auraSpellId = UnitAura("player", i, "HARMFUL")
                if not auraSpellId then break end
                if auraSpellId == spellId then return true end
            end
            return false
        end,

        -- Inventory
        HasItem = function(itemId, count)
            if not itemId then return false end
            count = count or 1
            local ok, result = pcall(GetItemCount, itemId)
            if not ok then return false end
            return (result or 0) >= count
        end,

        HasItemOrBank = function(itemId, count)
            if not itemId then return false end
            count = count or 1
            local ok, result = pcall(GetItemCount, itemId, true)
            if not ok then return false end
            return (result or 0) >= count
        end,

        -- Professions/Skills
        HasSkill = function(skillId, minLevel)
            if not skillId then return false end
            minLevel = minLevel or 1
            local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel({skillId, minLevel})
            return hasProfession and hasSkillLevel
        end,

        KnowsSpell = function(spellId)
            if not spellId then return false end
            local ok, result = pcall(IsSpellKnown, spellId)
            if not ok then return false end
            return result == true
        end,

        -- Reputation
        HasRep = function(factionId, minRank)
            if not factionId or not minRank then return false end
            local reps = QuestieReputation:GetPlayerReputations()
            local repData = reps[factionId]
            if not repData then return false end
            return repData[1] >= minRank
        end,

        RepBelow = function(factionId, maxRank)
            if not factionId or not maxRank then return false end
            local reps = QuestieReputation:GetPlayerReputations()
            local repData = reps[factionId]
            if not repData then return false end
            return repData[1] <= maxRank
        end,

        -- Player Identity
        IsTeam = function(teamId)
            if not teamId then return false end
            local faction = UnitFactionGroup("player")
            if teamId == 469 then
                return faction == "Alliance"
            elseif teamId == 67 then
                return faction == "Horde"
            end
            return false
        end,

        IsRace = function(raceMask)
            if not raceMask then return false end
            return QuestiePlayer.HasRequiredRace(raceMask)
        end,

        IsClass = function(classMask)
            if not classMask then return false end
            return QuestiePlayer.HasRequiredClass(classMask)
        end,

        IsRaceClass = function(raceMask, classMask)
            raceMask = raceMask or 0
            classMask = classMask or 0
            local raceOk = QuestiePlayer.HasRequiredRace(raceMask)
            local classOk = QuestiePlayer.HasRequiredClass(classMask)
            return raceOk and classOk
        end,

        IsLevel = function(minLevel)
            if not minLevel then return false end
            return QuestiePlayer.GetPlayerLevel() >= minLevel
        end,

        -- World State
        HasAchievement = function(achievementId)
            if not achievementId then return false end
            if not GetAchievementInfo then return true end
            local ok, _, _, _, completed = pcall(GetAchievementInfo, achievementId)
            if not ok then return true end
            return completed == true
        end,

        -- Additional Quest State
        QuestComplete = function(questId)
            if not questId then return false end
            return QuestiePlayer.currentQuestlog[questId] ~= nil
                and QuestieDB.IsComplete(questId) == 1
        end,

        -- Additional Inventory
        HasItemEquipped = function(itemId)
            if not itemId then return false end
            local ok, result = pcall(IsEquippedItem, itemId)
            if not ok then return false end
            return result == true
        end,

        -- Additional Player Identity
        IsLevelExact = function(level)
            if not level then return false end
            return QuestiePlayer.GetPlayerLevel() == level
        end,

        IsLevelBelow = function(level)
            if not level then return false end
            return QuestiePlayer.GetPlayerLevel() <= level
        end,

        --- Checks whether a cmangos game_event is currently active.
        --- Game events cover a broad range of server-side scheduled content:
        ---   - Calendar holidays (Brewfest=26, Hallow's End=12, Love is in the Air=8, ...)
        ---   - Isle of Quel'Danas phases (301-319)
        ---   - AQ War Effort phases (120-127)
        ---   - Scourge Invasion (17, 89-99)
        ---   - Sunwell Plateau gate progression (316-319)
        ---   - Edge of Madness boss rotations (29-32)
        ---   - Daily/weekly random quest rotations (1000-1254)
        ---   - Call to Arms BG weekends (18-21, 25, 38)
        ---   - Darkmoon Faire location variants (4=Elwynn, 5=Mulgore, 3=Terokkar)
        ---   - Daytime checks (400=7AM-8PM, 401=7AM-12AM)
        --- These IDs come from the cmangos game_event table (game_event.entry).
        --- Some events have a corresponding WoW holiday ID (game_event.holiday),
        --- but most do not — especially phases, rotations, and sub-events.
        --- Questie currently tracks events by quest ID and hardcoded date ranges,
        --- not by cmangos event IDs. Returns true (permissive) until Questie
        --- gains event ID tracking or a Blizzard API for phase queries.
        EventActive = function(eventId)
            return true
        end,

        --- Checks whether a WoW calendar holiday is currently active.
        --- Holiday IDs come from the client-side Holidays.dbc file and appear
        --- in the in-game calendar. Unlike EventActive, these are queryable
        --- client-side via C_Calendar APIs.
        --- Examples:
        ---   141 = Winter Veil
        ---   181 = Noblegarden
        ---   201 = Children's Week
        ---   283 = Call to Arms: Alterac Valley
        ---   301 = Fishing Extravaganza
        ---   324 = Hallow's End
        ---   327 = Lunar Festival
        ---   335/423 = Love is in the Air (ID changed between expansions)
        ---   341 = Midsummer Fire Festival
        ---   372 = Brewfest
        ---   374/375/376 = Darkmoon Faire (Elwynn/Mulgore/Terokkar)
        ---   409 = Day of the Dead
        --- Only 5 conditions in WotLK use this type. Most event checks use
        --- EventActive instead. Questie tracks holidays by string name and
        --- date ranges, not by DBC holiday ID. Returns true (permissive)
        --- until a holiday ID mapping is added.
        HolidayActive = function(holidayId)
            return true
        end,

        --- Checks a server-side worldstate variable against an expected value.
        --- Worldstates are server-managed integers that track progression such as:
        ---   - Isle of Quel'Danas building progress
        ---   - Wintergrasp battle state
        ---   - Scourge Invasion counters
        --- Only 1 quest condition uses this (quest 12267 "Neltharion's Flame").
        --- Questie has no worldstate infrastructure. IoQD phases are tracked via
        --- a user-configurable setting (Questie.db.profile.isleOfQuelDanasPhase).
        --- Returns true (permissive) — these are not evaluable client-side.
        WorldState = function(worldstateId, expectedValue)
            return true
        end,
    }
end

--- Evaluate a condition expression string.
---@param expression string A Lua boolean expression using condition functions
---@return boolean result True if the condition is met, true on error (permissive)
function QuestieConditions:Evaluate(expression)
    if not expression or expression == "" then return true end

    local fn = loadstring("return " .. expression)
    if not fn then return true end

    setfenv(fn, self.conditionFunctions)

    local ok, result = pcall(fn)
    if not ok then return true end

    return result
end

return QuestieConditions
