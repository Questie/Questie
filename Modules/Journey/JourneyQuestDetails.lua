---What the Journey shows about a quest.
---@class JourneyQuestDetails
local JourneyQuestDetails = QuestieLoader:CreateModule("JourneyQuestDetails")

-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyEntityDetails
local JourneyEntityDetails = QuestieLoader:ImportModule("JourneyEntityDetails")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyRawData
local JourneyRawData = QuestieLoader:ImportModule("JourneyRawData")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")

---@param questId QuestId
---@return string|nil
local function GetReputationRewardString(questId)
    if not questId then
        return nil
    end

    local reputationRewards = QuestieReputation.GetReputationReward(questId)
    if not reputationRewards or not next(reputationRewards) then
        return nil
    end

    return QuestieReputation.GetReputationRewardString(reputationRewards)
end

---@param questLevel number
---@param questMinLevel number
---@return number|nil red
---@return number|nil orange
---@return number|nil yellow
---@return number|nil green
---@return number|nil gray
local function GetLevelDifficultyRanges(questLevel, questMinLevel)
    local charLevel = UnitLevel("player")
    local red, orange, yellow, green, gray

    -- Gray Level based on level range.
    if (questLevel ~= -1) then
        if Expansions.Current == Expansions.Era then
            -- values observed on wowhead
            if (questLevel <= 4) then
                gray = questLevel + 5
            elseif (questLevel <= 13) then
                gray = questLevel + 6
            elseif (questLevel <= 22) then
                gray = questLevel + 7
            elseif (questLevel <= 31) then
                gray = questLevel + 8
            elseif (questLevel <= 40) then
                gray = questLevel + 9
            elseif (questLevel <= 49) then
                gray = questLevel + 10
            elseif (questLevel <= 58) then
                gray = questLevel + 11
            else
                gray = questLevel + 12
            end
        else
            -- values observed on TBC and MoP. Assuming Wotlk follows same values.
            -- GetQuestGreenRange() returns 8 from 40-90
            if (questLevel <= 4) then
                gray = questLevel + 5
            elseif (questLevel <= 13) then
                gray = questLevel + 6
            elseif (questLevel <= 22) then
                gray = questLevel + 7
            elseif (questLevel <= 31) then
                gray = questLevel + 8
            else
                gray = questLevel + 9
            end
        end
    end

    -- Calculate Base Values
    if questLevel == -1 then
        questLevel = (questMinLevel <= charLevel and charLevel) or (questMinLevel > charLevel and questMinLevel)
        if questMinLevel == questLevel then
            yellow = questLevel
        elseif questMinLevel ~= questLevel then
            yellow = questMinLevel .. "-" .. questLevel
        end
    else
        red = questMinLevel
        orange = questLevel - 4
        yellow = questLevel - 2
        green = questLevel + 3

        -- Double check for negative values
        if yellow <= 0 or yellow < questMinLevel then
            yellow = questMinLevel
        end

        if orange and orange < questMinLevel then
            orange = questMinLevel
        end

        if orange == yellow then
            orange = nil
        end

        if red and (red == orange or not orange) then
            red = nil
        end

        if green and green < questMinLevel then
            green = questMinLevel
        end

        if gray and gray < questMinLevel then
            gray = questMinLevel
        end

    end

    return red, orange, yellow, green, gray
end

---@param questLevel number
---@param questMinLevel number
---@return string
local function GetDifficultyString(questLevel, questMinLevel)
    local red, orange, yellow, green, gray = GetLevelDifficultyRanges(questLevel, questMinLevel)
    local diffStr = ''

    if red then
        diffStr = diffStr .. "|cFFFF1A1A[".. red .."]|r "
    end

    if orange then
        diffStr = diffStr .. "|cFFFF8040[".. orange .."]|r "
    end

    diffStr = diffStr .. "|cFFFFFF00[".. yellow .."]|r "

    if green then
        diffStr = diffStr .. "|cFF40C040[".. green .."]|r "
    end

    if gray then
        diffStr = diffStr .. "|cFFC0C0C0[".. gray .."]|r "
    end

    return Questie:Colorize(l10n('Difficulty Range: %s', diffStr), 'yellow')
end

---@param rows JourneyDetails.Row[]
---@param label string
---@param value string|number
local function _AddFact(rows, label, value)
    table.insert(rows, {type = "text", text = JourneyDetails.GetFactText(label, value)})
end

---@param rows JourneyDetails.Row[]
---@param label string Is translated
---@param icon JourneyIcon.Icon
local function _AddIconFact(rows, label, icon)
    table.insert(rows, {type = "text", text = JourneyDetails.GetFactText(label, ""), trailingIcon = icon})
end

---@param rows JourneyDetails.Row[]
---@param kind ManualNoteKind
---@param entity NPC|Object
local function _AddSpawn(rows, kind, entity)
    if #rows > 0 then
        table.insert(rows, {type = "gap", height = 10})
    end
    table.insert(rows, JourneyLinks.Link({
        type = "entity",
        npcId = kind == "npc" and entity.id or nil,
        title = entity.name,
        text = l10n(kind == "npc" and "NPC ID" or "Object ID") .. l10n(": ") .. entity.id,
    }, kind, entity.id))
    JourneyEntityDetails.AddPlace(rows, kind, entity)
    JourneyEntityDetails.AddTomTom(rows, entity)
end

---@param rows JourneyDetails.Row[]
---@param text string
---@param questIds QuestId[]?
---@param questId QuestId The quest that is shown, which isn't listed
local function _AddOtherQuests(rows, text, questIds, questId)
    local links = JourneyLinks.GetRows("quest", questIds or {}, questId)
    if #links == 0 then
        return
    end
    table.insert(rows, {type = "gap", height = 6})
    table.insert(rows, {type = "text", text = text, font = "GameFontNormal"})
    for _, link in ipairs(links) do
        table.insert(rows, link)
    end
end

---@param kind ManualNoteKind
---@param ids number[]
---@param relation "questStarts"|"questEnds"
---@param relationText string
---@param questId QuestId
---@return JourneyDetails.Row[]
local function _GetSpawnRows(kind, ids, relation, relationText, questId)
    local rows = {}
    for _, id in ipairs(ids) do
        local entity
        if kind == "npc" then
            entity = QuestieDB:GetNPC(id)
        else
            entity = QuestieDB:GetObject(id)
        end
        if entity then
            _AddSpawn(rows, kind, entity)
            _AddOtherQuests(rows, relationText, entity[relation], questId)
        end
    end
    return rows
end

---@param quest Quest
---@return string[] professions
local function _GetRequiredProfessions(quest)
    local requiredSkill = QuestieDB.QueryQuestSingle(quest.Id, "requiredSkill")
    local requiredSpecialization = QuestieDB.QueryQuestSingle(quest.Id, "requiredSpecialization")
    local requiredRanks = QuestieDB.QueryQuestSingle(quest.Id, "requiredRanks")
    local professions = {}

    if requiredSkill and requiredSkill[1] and QuestieProfessions:GetProfessionName(requiredSkill[1]) then
        local specializationName = requiredSpecialization and QuestieProfessions:GetSpecializationName(requiredSpecialization)
        local entry = l10n(specializationName or QuestieProfessions:GetProfessionName(requiredSkill[1]))
        if requiredSkill[2] and requiredSkill[2] >= 1 then
            entry = entry .. " " .. l10n("(") .. requiredSkill[2] .. l10n(")")
        end
        table.insert(professions, entry)
    end

    for _, requiredRank in ipairs(requiredRanks or {}) do
        local professionName = QuestieProfessions:GetProfessionName(requiredRank[1])
        if professionName then
            local rankName = QuestieProfessions:GetRankName(math.abs(requiredRank[2]))
            local entry = l10n(professionName)
            if rankName then
                entry = entry .. " " .. l10n("(") .. l10n(rankName) .. l10n(")")
            end
            if requiredRank[2] < 0 then
                entry = l10n("Not") .. " " .. entry
            end
            table.insert(professions, entry)
        end
    end

    return professions
end

---@param quest Quest
---@return QuestId[]
local function _GetNextInChain(quest)
    local questIds, visited = {}, {}

    local function GetNext(questId)
        local nextId = QuestieDB.QueryQuestSingle(questId, "nextQuestInChain")
        if not nextId or nextId == 0 then
            nextId = QuestieDB.QueryQuestSingle(questId, "breadcrumbForQuestId")
        end
        return nextId
    end

    local nextId = GetNext(quest.Id)
    while nextId and nextId > 0 and not visited[nextId] and not QuestieCorrections.hiddenQuests[nextId] do
        visited[nextId] = true
        table.insert(questIds, nextId)
        nextId = GetNext(nextId)
    end
    return questIds
end

---@param rows JourneyDetails.Row[]
---@param quest Quest
local function _AddQuestInformation(rows, quest)
    table.insert(rows, {
        type = "checkbox",
        text = l10n("Hide from map"),
        get = function() return Questie.db.char.hidden[quest.Id] ~= nil end,
        set = function()
            if Questie.db.char.hidden[quest.Id] ~= nil then
                QuestieQuest:UnhideQuest(quest.Id)
            else
                QuestieQuest:HideQuest(quest.Id)
            end
        end,
        showTooltip = function()
            GameTooltip:AddLine(l10n("Hide from map"))
            GameTooltip:AddLine(l10n("\nIf checked, hides the quest from the map, even if it is active.\n\nHiding a quest is also possible by Shift-clicking it on the map."), 1, 1, 1, true)
        end,
    })
    table.insert(rows, {type = "gap", height = 6})

    _AddIconFact(rows, "Complete", Questie.icons[Questie.db.char.complete[quest.Id] and "checkmark" or "cross"])
    -- Only keeps the quest from being shown as available, unlike the checkbox
    if QuestieCorrections.hiddenQuests[quest.Id] then
        _AddIconFact(rows, "Hidden by Questie", JourneyIcon.HIDDEN)
    end

    -- Queried, so it isn't wrong for quests of level -1
    local requiredLevel = QuestieDB.QueryQuestSingle(quest.Id, "requiredLevel")
    local questLevel = QuestieDB.QueryQuestSingle(quest.Id, "questLevel")

    _AddFact(rows, "Quest ID", quest.Id)
    _AddFact(rows, "Quest Level", QuestieLib.GetEffectiveQuestLevel(quest.Id))
    _AddFact(rows, "Required Level", requiredLevel)

    local requiredRaces = QuestieDB.QueryQuestSingle(quest.Id, "requiredRaces")
    local raceString = QuestieLib:GetRaceString(requiredRaces)
    if raceString ~= "" then
        local isFaction = requiredRaces == QuestieDB.raceKeys.ALL_ALLIANCE or requiredRaces == QuestieDB.raceKeys.ALL_HORDE
        _AddFact(rows, isFaction and "Required Faction" or "Required Race", raceString)
    end

    local classString = QuestieLib:GetClassString(QuestieDB.QueryQuestSingle(quest.Id, "requiredClasses"))
    if classString ~= "" then
        _AddFact(rows, "Required Class", classString)
    end

    local professions = _GetRequiredProfessions(quest)
    if #professions == 1 then
        _AddFact(rows, "Required Profession", professions[1])
    elseif #professions > 1 then
        _AddFact(rows, "Required Profession", "\n  " .. table.concat(professions, "\n  "))
    end

    table.insert(rows, {type = "text", text = GetDifficultyString(questLevel, requiredLevel)})

    local reputationReward = GetReputationRewardString(quest.Id)
    if reputationReward then
        _AddFact(rows, "Reputation Reward", Questie:Colorize(reputationReward, "reputationBlue"))
    end

    if QuestieDB.IsRepeatable(quest.Id) then
        if QuestieDB.IsDailyQuest(quest.Id) then
            _AddFact(rows, "Repeatable", l10n("Daily"))
        elseif QuestieDB.IsWeeklyQuest(quest.Id) then
            _AddFact(rows, "Repeatable", l10n("Weekly"))
        elseif QuestieDB.IsMonthlyQuest(quest.Id) then
            _AddFact(rows, "Repeatable", l10n("Monthly"))
        else
            table.insert(rows, {type = "text", text = Questie:Colorize(l10n("Repeatable"), "yellow")})
        end
    end

    local eligibilityText, shouldShowEligibility = QuestieDB.IsDoableVerbose(quest.Id, false, true, true)
    if shouldShowEligibility then
        _AddFact(rows, "Doable", eligibilityText)
    end
end

---@param quest Quest
---@return JourneyDetails.Row[]
function JourneyQuestDetails.GetRows(quest)
    ---@type JourneyDetails.Row[]
    local rows = {}

    table.insert(rows, {type = "heading", text = quest.name})
    table.insert(rows, {type = "text", text = strtrim(QuestieJourneyUtils.CreateObjectiveText(quest.Description))})
    table.insert(rows, {type = "gap", height = 8})

    table.insert(rows, {type = "heading", text = l10n("Quest Information")})
    _AddQuestInformation(rows, quest)

    JourneyDetails.AddBox(rows, l10n("Requires one of these quests to be finished"), JourneyLinks.GetRows("quest", quest.preQuestSingle or {}))
    JourneyDetails.AddBox(rows, l10n("Requires all of these quests to be finished"), JourneyLinks.GetRows("quest", quest.preQuestGroup or {}))
    JourneyDetails.AddBox(rows, l10n("Next in chain"), JourneyLinks.GetRows("quest", _GetNextInChain(quest)))

    local starts, finisher = quest.Starts or {}, quest.Finisher or {}
    JourneyDetails.AddBox(rows, l10n("Quest Start NPC Information"), _GetSpawnRows(
        "npc", {starts.NPC and starts.NPC[1]}, "questStarts", l10n("This NPC Also Starts the following quests:"), quest.Id))
    JourneyDetails.AddBox(rows, l10n("Quest Start Object Information"), _GetSpawnRows(
        "object", starts.GameObject or {}, "questStarts", l10n("This Object Also Starts the following quests:"), quest.Id))

    local startItem = starts.Item and QuestieDB:GetItem(starts.Item[1])
    if startItem then
        JourneyDetails.AddBox(rows, l10n("Quest Start Item Information"), {
            {
                type = "entity",
                icon = QuestieCompat.GetItemIcon(startItem.Id),
                title = startItem.name,
                text = l10n("Item ID") .. l10n(": ") .. startItem.Id,
                onClick = function() JourneyWindow.OpenLink("item", startItem.Id) end,
                showTooltip = function() GameTooltip:SetItemByID(startItem.Id) end,
            },
        })
    end

    JourneyDetails.AddBox(rows, l10n("Quest Turn-in NPC Information"), _GetSpawnRows(
        "npc", finisher.NPC or {}, "questEnds", l10n("This NPC Also Completes the following quests:"), quest.Id))
    JourneyDetails.AddBox(rows, l10n("Quest Turn-in Object Information"), _GetSpawnRows(
        "object", finisher.GameObject or {}, "questEnds", l10n("This Object Also Completes the following quests:"), quest.Id))

    JourneyRawData.AddRows(rows, quest, QuestieDB.questKeys)
    return rows
end

return JourneyQuestDetails
