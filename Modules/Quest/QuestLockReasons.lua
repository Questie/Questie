---@class QuestLockReasons
local QuestLockReasons = QuestieLoader:CreateModule("QuestLockReasons")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests")
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local tconcat = table.concat
local abs = math.abs

local GetSpellName = (C_Spell and C_Spell.GetSpellName) or GetSpellInfo

-- The lowest reputation of each standing, from Hated (FACTION_STANDING_LABEL1) to Exalted (FACTION_STANDING_LABEL8)
local STANDING_THRESHOLDS = {-42000, -6000, -3000, 0, 3000, 9000, 21000, 42000}

-- The TBC quests that require an arena rating
local ARENA_RATING_QUESTS = {[95158] = true, [95251] = true, [95252] = true}

---@param text string
---@return string
local function _StripColors(text)
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

---@param questId QuestId
---@return boolean
local function _IsCompletedOrActive(questId)
    if Questie.db.char.complete[questId] then
        return true
    end
    return ActiveQuests.Get(questId) ~= nil
end

---@param questIds QuestId[]
---@return string
local function _GetQuestNames(questIds)
    local names = {}
    for i = 1, #questIds do
        names[i] = QuestieDB.QueryQuestSingle(questIds[i], "name") or tostring(questIds[i])
    end
    return tconcat(names, ", ")
end

---@param questIds QuestId[]
---@param questId QuestId
local function _AppendUnique(questIds, questId)
    for i = 1, #questIds do
        if questIds[i] == questId then
            return
        end
    end
    questIds[#questIds + 1] = questId
end

---@param reputationValue number
---@return string
local function _GetStandingName(reputationValue)
    local standing = 1
    for i = 2, #STANDING_THRESHOLDS do
        if reputationValue >= STANDING_THRESHOLDS[i] then
            standing = i
        end
    end
    return _G["FACTION_STANDING_LABEL" .. standing] or ""
end

---@param factionId FactionId
---@return string
local function _GetFactionName(factionId)
    return QuestieReputation.GetFactionName(factionId) or tostring(factionId)
end

---@param professionId number
---@param skillLevel number?
---@return string? @"Engineering (225)", or nil for an unknown profession
local function _GetSkillText(professionId, skillLevel)
    local professionName = QuestieProfessions:GetProfessionName(professionId)
    if not professionName then
        return nil
    end
    local text = l10n(professionName)
    if skillLevel and skillLevel >= 1 then
        text = text .. " " .. l10n("(") .. skillLevel .. l10n(")")
    end
    return text
end

---@param requiredRanks { [1]: number, [2]: number }[]
---@return string? @"Engineering (Artisan), Mining (Artisan)", or nil when no profession is known
local function _GetRanksText(requiredRanks)
    local parts = {}
    for i = 1, #requiredRanks do
        local professionName = QuestieProfessions:GetProfessionName(requiredRanks[i][1])
        if professionName then
            local text = l10n(professionName)
            local rankName = QuestieProfessions:GetRankName(abs(requiredRanks[i][2]))
            if rankName then
                text = text .. " " .. l10n("(") .. l10n(rankName) .. l10n(")")
            end
            parts[#parts + 1] = text
        end
    end
    return parts[1] and tconcat(parts, ", ") or nil
end

---@param professionId number
---@return boolean
local function _HasSpecializations(professionId)
    local professionKeys = QuestieProfessions.professionKeys
    return professionId == professionKeys.ALCHEMY or professionId == professionKeys.BLACKSMITHING or
        professionId == professionKeys.ENGINEERING or professionId == professionKeys.LEATHERWORKING or
        professionId == professionKeys.TAILORING
end

---@param questId QuestId
---@param permanent string[]
local function _AddRaceAndClassReasons(questId, permanent)
    local requiredRaces = QuestieDB.QueryQuestSingle(questId, "requiredRaces")
    if not QuestiePlayer.HasRequiredRace(requiredRaces) then
        local races = _StripColors(QuestieLib:GetRaceString(requiredRaces))
        if races ~= "" then
            permanent[#permanent + 1] = l10n("%s only", races)
        end
    end

    local requiredClasses = QuestieDB.QueryQuestSingle(questId, "requiredClasses")
    if not QuestiePlayer.HasRequiredClass(requiredClasses) then
        local classes = _StripColors(QuestieLib:GetClassString(requiredClasses))
        if classes ~= "" then
            permanent[#permanent + 1] = l10n("%s only", classes)
        end
    end
end

---@param questId QuestId
---@param permanent string[]
---@param temporary string[]
local function _AddProfessionReasons(questId, permanent, temporary)
    local requiredSkill = QuestieDB.QueryQuestSingle(questId, "requiredSkill")
    if requiredSkill and requiredSkill[1] then
        local skillText = _GetSkillText(requiredSkill[1], requiredSkill[2])
        local hasProfession, hasSkillLevel = QuestieProfessions:HasProfessionAndSkillLevel(requiredSkill)
        if skillText and not hasProfession then
            permanent[#permanent + 1] = l10n("%s only", skillText)
        elseif skillText and not hasSkillLevel then
            temporary[#temporary + 1] = l10n("Requires %s", skillText)
        end
    end

    local requiredRanks = QuestieDB.QueryQuestSingle(questId, "requiredRanks")
    if requiredRanks and requiredRanks[1] then
        local ranksText = _GetRanksText(requiredRanks)
        local hasProfession, hasRankLevel, hasNegativeRanks = QuestieProfessions:HasProfessionAndRankLevel(requiredRanks)
        if ranksText and hasNegativeRanks then
            -- The quest is for those who have not reached the rank yet
            if hasProfession and not hasRankLevel then
                permanent[#permanent + 1] = l10n("Before %s only", ranksText)
            end
        elseif ranksText and not hasProfession then
            permanent[#permanent + 1] = l10n("%s only", ranksText)
        elseif ranksText and not hasRankLevel then
            temporary[#temporary + 1] = l10n("Requires %s", ranksText)
        end
    end

    local requiredSpecialization = QuestieDB.QueryQuestSingle(questId, "requiredSpecialization")
    if requiredSpecialization and requiredSpecialization > 0 and not QuestieProfessions.HasSpecialization(requiredSpecialization) then
        -- A profession in place of a specialization asks for that profession, with no specialization chosen if it has any
        local professionName = QuestieProfessions:GetProfessionName(requiredSpecialization)
        local specializationName = QuestieProfessions:GetSpecializationName(requiredSpecialization)
        if professionName and _HasSpecializations(requiredSpecialization) then
            permanent[#permanent + 1] = l10n("No %s specialization", l10n(professionName))
        elseif professionName then
            permanent[#permanent + 1] = l10n("%s only", l10n(professionName))
        elseif specializationName then
            permanent[#permanent + 1] = l10n("%s only", l10n(specializationName))
        end
    end
end

---@param questId QuestId
---@param permanent string[]
---@param temporary string[]
local function _AddLevelReasons(questId, permanent, temporary)
    local playerLevel = QuestiePlayer.GetPlayerLevel()

    local requiredMaxLevel = QuestieDB.QueryQuestSingle(questId, "requiredMaxLevel")
    if requiredMaxLevel and requiredMaxLevel ~= 0 and playerLevel > requiredMaxLevel then
        permanent[#permanent + 1] = l10n("Up to level %d", requiredMaxLevel)
    end

    local requiredLevel = QuestieDB.QueryQuestSingle(questId, "requiredLevel")
    if requiredLevel and playerLevel < requiredLevel then
        temporary[#temporary + 1] = l10n("Requires level %d", requiredLevel)
    end
end

---@param questId QuestId
---@param permanent string[]
---@param temporary string[]
local function _AddReputationReasons(questId, permanent, temporary)
    local requiredMaxRep = QuestieDB.QueryQuestSingle(questId, "requiredMaxRep")
    if requiredMaxRep then
        local _, _, belowMaxRep, hasMaxFaction = QuestieReputation:HasFactionAndReputationLevel(nil, requiredMaxRep)
        if not (belowMaxRep and hasMaxFaction) then
            permanent[#permanent + 1] = l10n("Requires below %s with %s",
                _GetStandingName(requiredMaxRep[2]), _GetFactionName(requiredMaxRep[1]))
        end
    end

    local requiredMinRep = QuestieDB.QueryQuestSingle(questId, "requiredMinRep")
    if requiredMinRep then
        local aboveMinRep, hasMinFaction = QuestieReputation:HasFactionAndReputationLevel(requiredMinRep, nil)
        if not (aboveMinRep and hasMinFaction) then
            temporary[#temporary + 1] = l10n("Requires %s with %s",
                _GetStandingName(requiredMinRep[2]), _GetFactionName(requiredMinRep[1]))
        end
    end
end

---Sorts the exclusive quests of a quest into the turned-in ones, which close it for good, and the active ones, which block it.
---@param exclusiveQuestIds QuestId[]?
---@param closers QuestId[]
---@param blockers QuestId[]
---@return boolean found Whether any exclusive quest is turned in or active
local function _SortExclusiveQuests(exclusiveQuestIds, closers, blockers)
    local found = false
    for _, exclusiveQuestId in ipairs(exclusiveQuestIds or {}) do
        if Questie.db.char.complete[exclusiveQuestId] then
            _AppendUnique(closers, exclusiveQuestId)
            found = true
        elseif ActiveQuests.Get(exclusiveQuestId) then
            _AppendUnique(blockers, exclusiveQuestId)
            found = true
        end
    end
    return found
end

---@param questIds QuestId[]
---@param chainQuestIds table<QuestId, boolean>
---@return boolean
local function _ContainsChainQuest(questIds, chainQuestIds)
    for i = 1, #questIds do
        if chainQuestIds[questIds[i]] then
            return true
        end
    end
    return false
end

---@param preQuestGroup number[] Negative IDs are fulfilled only by that quest, not by one exclusive to it
---@param chainQuestIds table<QuestId, boolean>
---@return QuestId[] missingQuestIds The prequests that are neither turned in nor part of the chain
local function _GetMissingGroupPreQuests(preQuestGroup, chainQuestIds)
    local missingQuestIds = {}
    for _, entry in ipairs(preQuestGroup) do
        local preQuestId = abs(entry)
        if not (Questie.db.char.complete[preQuestId] or chainQuestIds[preQuestId]) then
            local isReplaced = false
            if entry > 0 then
                for _, exclusiveQuestId in ipairs(QuestieDB.QueryQuestSingle(preQuestId, "exclusiveTo") or {}) do
                    if Questie.db.char.complete[exclusiveQuestId] then
                        isReplaced = true
                        break
                    end
                end
            end
            if not isReplaced then
                missingQuestIds[#missingQuestIds + 1] = preQuestId
            end
        end
    end
    return missingQuestIds
end

---@param questId QuestId
---@param chainQuestIds table<QuestId, boolean>
---@param permanent string[]
---@param temporary string[]
local function _AddQuestReasons(questId, chainQuestIds, permanent, temporary)
    local closers, blockers = {}, {}

    _SortExclusiveQuests(QuestieDB.QueryQuestSingle(questId, "exclusiveTo"), closers, blockers)

    local availableUntilCompleted = QuestieDB.QueryQuestSingle(questId, "availableUntilCompleted")
    if availableUntilCompleted and availableUntilCompleted ~= 0 and Questie.db.char.complete[availableUntilCompleted] then
        _AppendUnique(closers, availableUntilCompleted)
    end

    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(questId, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 and _IsCompletedOrActive(breadcrumbForQuestId) then
        _AppendUnique(closers, breadcrumbForQuestId)
    end

    local nextQuestInChain = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
    if nextQuestInChain and nextQuestInChain ~= 0 and _IsCompletedOrActive(nextQuestInChain) then
        _AppendUnique(closers, nextQuestInChain)
    end

    local disabledByQuest = QuestieDB.QueryQuestSingle(questId, "disabledByQuest")
    if disabledByQuest and disabledByQuest ~= 0 and ActiveQuests.Get(disabledByQuest) then
        _AppendUnique(blockers, disabledByQuest)
    end

    for _, breadcrumbId in ipairs(QuestieDB.QueryQuestSingle(questId, "breadcrumbs") or {}) do
        if ActiveQuests.Get(breadcrumbId) then
            _AppendUnique(blockers, breadcrumbId)
        end
    end

    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle and preQuestSingle[1] and (not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)) then
        -- The only prequest can itself be closed or blocked by its exclusive quests, and with it this quest
        local isPreQuestLocked = #preQuestSingle == 1 and
            _SortExclusiveQuests(QuestieDB.QueryQuestSingle(preQuestSingle[1], "exclusiveTo"), closers, blockers)
        if (not isPreQuestLocked) and (not _ContainsChainQuest(preQuestSingle, chainQuestIds)) then
            if #preQuestSingle == 1 then
                temporary[#temporary + 1] = l10n("Requires %s", _GetQuestNames(preQuestSingle))
            else
                temporary[#temporary + 1] = l10n("Requires one of: %s", _GetQuestNames(preQuestSingle))
            end
        end
    end

    local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
    if preQuestGroup and preQuestGroup[1] and (not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)) then
        local missingQuestIds = _GetMissingGroupPreQuests(preQuestGroup, chainQuestIds)
        if missingQuestIds[1] then
            temporary[#temporary + 1] = l10n("Requires %s", _GetQuestNames(missingQuestIds))
        end
    end

    local parentQuest = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuest and parentQuest ~= 0 and (not ActiveQuests.Get(parentQuest)) then
        temporary[#temporary + 1] = l10n("Requires %s in the quest log", _GetQuestNames({parentQuest}))
    end

    local availableStartingWith = QuestieDB.QueryQuestSingle(questId, "availableStartingWith")
    if availableStartingWith and availableStartingWith ~= 0 and (not _IsCompletedOrActive(availableStartingWith)) and
        (not chainQuestIds[availableStartingWith]) then
        temporary[#temporary + 1] = l10n("After accepting %s", _GetQuestNames({availableStartingWith}))
    end

    if closers[1] then
        permanent[#permanent + 1] = l10n("Closed by %s", _GetQuestNames(closers))
    end
    if blockers[1] then
        temporary[#temporary + 1] = l10n("Blocked by %s", _GetQuestNames(blockers))
    end
end

---@param questId QuestId
---@return boolean
local function _IsDailyUnavailable(questId)
    if DailyQuests.ShouldBeHidden(questId, Questie.db.char.complete, ActiveQuests.GetAll()) then
        return true
    end
    local unavailableByRealm = Questie.db.global.unavailableQuestsDeterminedByTalking
    local unavailableQuests = unavailableByRealm and unavailableByRealm[GetRealmName()]
    return unavailableQuests ~= nil and unavailableQuests[questId] ~= nil
end

---@param questId QuestId
---@param permanent string[]
---@param temporary string[]
local function _AddOtherReasons(questId, permanent, temporary)
    local requiredSpell = QuestieDB.QueryQuestSingle(questId, "requiredSpell")
    if requiredSpell and requiredSpell ~= 0 then
        -- A negative spell is one the player must not know
        local spellId = abs(requiredSpell)
        local knowsSpell = QuestieCompat.IsSpellKnown(spellId)
        local spellName = (GetSpellName and GetSpellName(spellId)) or tostring(spellId)
        if requiredSpell > 0 and not knowsSpell then
            temporary[#temporary + 1] = l10n("Requires %s", spellName)
        elseif requiredSpell < 0 and knowsSpell then
            permanent[#permanent + 1] = l10n("Unavailable after learning %s", spellName)
        end
    end

    if QuestieDB.private:CheckAchievementRequirements(questId) == false then
        temporary[#temporary + 1] = l10n("Achievement requirement")
    end

    -- Questie hides the quests of a world event while it is not running
    if QuestieCorrections.hiddenQuests[questId] and QuestieEvent.IsEventQuest(questId) and
        (not QuestieEvent.IsEventActiveForQuest(questId)) then
        temporary[#temporary + 1] = l10n("During %s", l10n(QuestieEvent.GetEventNameFor(questId)))
    end

    if _IsDailyUnavailable(questId) then
        temporary[#temporary + 1] = l10n("Daily quest not active")
    end

    if Expansions.Current == Expansions.Tbc and ARENA_RATING_QUESTS[questId] and (not QuestiePlayer.HasArenaRating(questId)) then
        temporary[#temporary + 1] = l10n("Missing Arena Rating")
    end
end

---Lists everything that keeps the player from taking a quest, each as a localized text. Reasons that rule the quest out
---for good (race, class, professions, a turned-in quest) come before those that can pass (level, reputation, prequests).
---Unlike QuestieDB.IsDoableVerbose, which stops at the first, it lists all of them.
---@param questId QuestId A quest the player has neither turned in nor in the quest log
---@param chainQuestIds table<QuestId, boolean> Quests of the same chain the player takes before this one; requiring them is no reason
---@return string[] reasons Empty when nothing keeps the player from the quest
function QuestLockReasons.GetReasons(questId, chainQuestIds)
    local permanent, temporary = {}, {}

    _AddRaceAndClassReasons(questId, permanent)
    _AddProfessionReasons(questId, permanent, temporary)
    _AddLevelReasons(questId, permanent, temporary)
    _AddReputationReasons(questId, permanent, temporary)
    _AddQuestReasons(questId, chainQuestIds, permanent, temporary)
    _AddOtherReasons(questId, permanent, temporary)

    for i = 1, #temporary do
        permanent[#permanent + 1] = temporary[i]
    end
    return permanent
end

---Joins reasons from GetReasons into one red text, as shown after a quest's name.
---@param reasons string[]?
---@return string text Empty when there are no reasons
function QuestLockReasons.FormatReasons(reasons)
    if not (reasons and reasons[1]) then
        return ""
    end
    return Questie:Colorize(tconcat(reasons, "; "), "red")
end

return QuestLockReasons
