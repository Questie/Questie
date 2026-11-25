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
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")
---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type ManualNotes
local ManualNotes = QuestieLoader:ImportModule("ManualNotes")
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
---@type JourneyPrerequisites
local JourneyPrerequisites = QuestieLoader:ImportModule("JourneyPrerequisites")
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

---@param quest Quest
---@return QuestId[] questIds Those before the quest that lead to it, first one first
local function _GetPreviousInChain(quest)
    local questIds, visited = {}, {[quest.Id] = true}
    local questId = quest.Id
    while #questIds < 30 do
        local shown = JourneyPrerequisites.GetShown(
            QuestieDB.QueryQuestSingle(questId, "requiredRaces"), QuestieDB.QueryQuestSingle(questId, "preQuestSingle") or {})
        local previousId
        for _, id in ipairs(shown) do
            if not previousId or Questie.db.char.complete[id] then
                previousId = id
            end
        end
        if not previousId or visited[previousId] or not QuestieDB.QuestPointers[previousId] then
            break
        end
        visited[previousId] = true
        table.insert(questIds, 1, previousId)
        questId = previousId
    end
    return questIds
end

---@param icon string
---@return string
local function _Inline(icon)
    return "|T" .. icon .. ":14|t "
end

---@param questId QuestId
---@param isCurrent boolean?
---@return JourneyDetails.Row
local function _GetStep(questId, isCurrent)
    local category = JourneyQuestCategories.Get(questId)
    local row = {
        type = "step",
        text = QuestieLib:GetColoredQuestName(questId, true, false),
        trailingIcon = JourneyQuestCategories.GetIcon(questId, category),
        isCurrent = isCurrent,
    }
    if isCurrent then
        row.tag = l10n("this quest")
        return row
    end
    return JourneyLinks.Link(row, "quest", questId)
end

---@class JourneyPerson
---@field kind ManualNoteKind
---@field entity NPC|Object
---@field starts boolean?
---@field ends boolean?

---@param quest Quest
---@return JourneyPerson[]
local function _GetPeople(quest)
    local people, peopleByKey = {}, {}
    local function Add(kind, ids, role)
        for _, id in ipairs(ids or {}) do
            local entity
            if kind == "npc" then entity = QuestieDB:GetNPC(id) else entity = QuestieDB:GetObject(id) end
            local key = kind .. id
            if entity and not peopleByKey[key] then
                peopleByKey[key] = {kind = kind, entity = entity}
                table.insert(people, peopleByKey[key])
            end
            if entity then peopleByKey[key][role] = true end
        end
    end
    local starts, finisher = quest.Starts or {}, quest.Finisher or {}
    Add("npc", starts.NPC, "starts")
    Add("object", starts.GameObject, "starts")
    Add("npc", finisher.NPC, "ends")
    Add("object", finisher.GameObject, "ends")
    return people
end

---@param person JourneyPerson
---@return string
local function _GetRole(person)
    if person.starts and person.ends then
        return l10n("Starts and ends this quest")
    end
    return person.starts and l10n("Starts this quest") or l10n("Ends this quest")
end

---@param rows JourneyDetails.Row[]
---@param person JourneyPerson
---@param quest Quest
local function _AddPerson(rows, person, quest)
    local place, showOnMap = JourneyEntityDetails.GetPlace(person.kind, person.entity)
    local row = {
        type = "entity",
        npcId = person.kind == "npc" and person.entity.id or nil,
        title = person.entity.name,
        text = Questie:Colorize(_GetRole(person), "gray") .. (place and "\n" .. place or ""),
    }
    if showOnMap then
        row.action = {icon = JourneyWindow.MAP_ICON, tooltip = l10n("Show on Map"), isOn = true, onClick = showOnMap}
    end
    table.insert(rows, JourneyLinks.Link(row, person.kind, person.entity.id))

    -- Others worth a visit at the same place
    local others = {}
    for _, questId in pairs(person.entity.questStarts or {}) do
        local category = questId ~= quest.Id and QuestieDB.QuestPointers[questId] and JourneyQuestCategories.Get(questId)
        if category == "available" or category == "repeatable" then
            table.insert(others, questId)
        end
    end
    if #others > 0 then
        table.insert(rows, {type = "text", text = Questie:Colorize(l10n("Also available there"), "gray"), font = "GameFontHighlightSmall"})
        for _, questId in ipairs(others) do
            table.insert(rows, _GetStep(questId))
        end
    end
end

---@param quest Quest
---@param category JourneyQuestCategory?
---@param reason string?
---@param stateName string?
---@return string
local function _GetStatus(quest, category, reason, stateName)
    if category == "log" then
        local progress = JourneyQuestCategories.GetProgress(quest.Id)
        local isDone = QuestieDB.IsComplete(quest.Id) == 1
        return _Inline(Questie.icons[isDone and "complete" or "incomplete"])
            .. (isDone and QUEST_WATCH_QUEST_READY or QUEST_LOG .. (progress and "  " .. progress or ""))
    elseif category == "available" or category == "repeatable" then
        return _Inline(Questie.icons[category]) .. Questie:Colorize(l10n("Available"), "green")
    elseif category == "completed" then
        return _Inline(Questie.icons["checkmark"]) .. l10n("Completed")
    elseif category == "later" then
        if stateName == "NO_PREQUESTSINGLE" then
            reason = l10n("Incomplete pre-quest")
        elseif stateName == "NO_PREQUESTGROUP" then
            reason = l10n("Incomplete pre-quest group")
        elseif stateName == "LEVEL_TOO_LOW" then
            reason = ITEM_MIN_LEVEL:format(QuestieDB.QueryQuestSingle(quest.Id, "requiredLevel"))
        end
        return _Inline(Questie.icons["cross"]) .. l10n("Unavailable") .. l10n(": ") .. (reason or "")
    elseif category == "unobtainable" then
        return _Inline(Questie.icons["cross"]) .. l10n("Unavailable") .. l10n(": ") .. (reason or l10n("Exclusive quest completed"))
    end
    return _Inline(Questie.icons["cross"]) .. (QuestieDB.IsDoableVerbose(quest.Id, false, true, true) or "")
end

---@param quest Quest
---@param people JourneyPerson[]
---@param category JourneyQuestCategory?
---@return JourneyDetails.Row
local function _GetButtons(quest, people, category)
    local buttons = {}
    local isLeaving = category == "log"
    local target
    for _, person in ipairs(people) do
        if not target or isLeaving and person.ends and not target.ends then
            target = person
        end
    end
    if target then
        local _, showOnMap, setTomTomTarget = JourneyEntityDetails.GetPlace(target.kind, target.entity)
        if showOnMap then
            table.insert(buttons, {text = l10n("Show on Map"), onClick = showOnMap})
        end
        if setTomTomTarget then
            table.insert(buttons, {text = "TomTom", onClick = setTomTomTarget})
        end
    end
    local isHidden = Questie.db.char.hidden[quest.Id]
    table.insert(buttons, {
        text = isHidden and l10n("Show on map again") or l10n("Hide from map"),
        onClick = function()
            if Questie.db.char.hidden[quest.Id] then
                QuestieQuest:UnhideQuest(quest.Id)
            else
                QuestieQuest:HideQuest(quest.Id)
            end
        end,
    })
    local texts = {}
    for _, button in ipairs(buttons) do table.insert(texts, button.text) end
    return {type = "buttons", buttons = buttons, state = table.concat(texts, "|")}
end

---@param rows JourneyDetails.Row[]
---@param quest Quest
---@param category JourneyQuestCategory?
---@param onChanged fun()
local function _AddObjectives(rows, quest, category, onChanged)
    local added = {}
    for index, objective in ipairs(quest.ObjectiveData or {}) do
        local kind, id
        if objective.Type == "monster" then
            kind, id = "npc", objective.Id
        elseif objective.Type == "killcredit" then
            kind, id = "npc", objective.RootId
        elseif objective.Type == "object" or objective.Type == "item" then
            kind, id = objective.Type, objective.Id
        end
        local name
        if kind == "npc" then
            name = QuestieDB.QueryNPCSingle(id, "name")
        elseif kind == "object" then
            name = QuestieDB.QueryObjectSingle(id, "name")
        elseif kind == "item" then
            name = QuestieDB.QueryItemSingle(id, "name")
        end
        if name then
            local row = {
                type = "step",
                text = name,
                trailingIcon = Questie.icons[kind == "npc" and "slay" or kind == "object" and "object" or "loot"],
            }
            local live = category == "log" and (quest.Objectives or {})[index]
            if live and (live.Needed or 0) > 0 then
                row.tag = live.Collected .. "/" .. live.Needed
            elseif kind ~= "item" and category ~= "log" then
                local isShown = ManualNotes.IsShown(kind, id)
                row.state = isShown and "shown" or "not shown"
                row.action = {
                    icon = JourneyWindow.MAP_ICON,
                    isOn = isShown,
                    tooltip = isShown and l10n("Remove from Map") or l10n("Show on Map"),
                    onClick = function()
                        if ManualNotes.IsShown(kind, id) then ManualNotes.Hide(kind, id) else ManualNotes.Show(kind, id) end
                        onChanged()
                    end,
                }
            end
            table.insert(added, JourneyLinks.Link(row, kind, id))
        end
    end
    for _, row in ipairs(added) do table.insert(rows, row) end
end

---@param rows JourneyDetails.Row[]
---@param label string Is translated
---@param value string|number?
local function _AddFact(rows, label, value)
    if value and value ~= "" then
        table.insert(rows, {type = "text", text = JourneyDetails.GetFactText(label, value)})
    end
end

---@param quest Quest
---@return JourneyDetails.Row[]
local function _GetRewards(quest)
    local rows = {}
    local xp = QuestXP:GetQuestLogRewardXP(quest.Id, Questie.db.profile.showQuestXpAtMaxLevel)
    if xp and xp > 0 then
        _AddFact(rows, COMBAT_XP_GAIN, BreakUpLargeNumbers(xp))
    end
    local reputationReward = GetReputationRewardString(quest.Id)
    if reputationReward then
        _AddFact(rows, "Reputation Reward", Questie:Colorize(reputationReward, "reputationBlue"))
    end
    return rows
end

local HISTORY_TEXTS = {Accept = "Accepted", Complete = "Completed", Abandon = "Abandoned"}
local HISTORY_ICONS = {Accept = "available", Complete = "checkmark", Abandon = "cross"}

---What the journey knows about the quest.
---@param quest Quest
---@return JourneyDetails.Row[]
local function _GetHistory(quest)
    local rows = {}
    for _, entry in ipairs(Questie.db.char.journey) do
        if entry.Event == "Quest" and entry.Quest == quest.Id then
            table.insert(rows, {
                type = "step",
                text = l10n(HISTORY_TEXTS[entry.SubType]) .. (entry.Level and Questie:Colorize("   " .. l10n("Level %s", entry.Level), "gray") or ""),
                tag = JourneyQuestCategories.GetShortDate(entry.Timestamp) .. ", " .. date("%H:%M", entry.Timestamp),
                trailingIcon = Questie.icons[HISTORY_ICONS[entry.SubType]],
            })
        end
    end
    return rows
end

---@param rows JourneyDetails.Row[]
---@param caption string
---@param section JourneyDetails.Row[]
local function _AddSection(rows, caption, section)
    if #section > 0 then
        table.insert(rows, {type = "caption", text = l10n(caption)})
        for _, row in ipairs(section) do table.insert(rows, row) end
    end
end

---@param quest Quest
---@return string[] tags
local function _GetTags(quest)
    local tags = {}
    if QuestieDB.IsDailyQuest(quest.Id) then table.insert(tags, l10n("Daily"))
    elseif QuestieDB.IsWeeklyQuest(quest.Id) then table.insert(tags, l10n("Weekly"))
    elseif QuestieDB.IsRepeatable(quest.Id) then table.insert(tags, l10n("Repeatable")) end
    if QuestieDB.IsDungeonQuest(quest.Id) then table.insert(tags, l10n("Dungeon")) end
    if QuestieDB.IsRaidQuest(quest.Id) then table.insert(tags, l10n("Raid")) end
    if QuestieDB.IsPvPQuest(quest.Id) then table.insert(tags, l10n("PvP")) end
    return tags
end

---@param quest Quest
---@return JourneyDetails.Row[]
local function _GetFacts(quest)
    local rows = {}
    -- Queried, so it isn't wrong for quests of level -1
    local requiredLevel = QuestieDB.QueryQuestSingle(quest.Id, "requiredLevel")
    local questLevel = QuestieDB.QueryQuestSingle(quest.Id, "questLevel")
    _AddFact(rows, "Level", QuestieLib.GetEffectiveQuestLevel(quest.Id) .. Questie:Colorize("   " .. l10n("Required Level") .. l10n(": ") .. requiredLevel, "gray"))
    table.insert(rows, {type = "text", text = GetDifficultyString(questLevel, requiredLevel)})

    local requiredRaces = QuestieDB.QueryQuestSingle(quest.Id, "requiredRaces")
    local raceString = QuestieLib:GetRaceString(requiredRaces)
    local isFaction = requiredRaces == QuestieDB.raceKeys.ALL_ALLIANCE or requiredRaces == QuestieDB.raceKeys.ALL_HORDE
    _AddFact(rows, isFaction and "Required Faction" or "Required Race", raceString)
    _AddFact(rows, "Required Class", QuestieLib:GetClassString(QuestieDB.QueryQuestSingle(quest.Id, "requiredClasses")))
    _AddFact(rows, "Required Profession", table.concat(_GetRequiredProfessions(quest), ", "))
    _AddFact(rows, "Quest ID", quest.Id)
    return rows
end

---@param quest Quest
---@param onChanged fun()? Called after the user changed something the rows show
---@return JourneyDetails.Row[]
function JourneyQuestDetails.GetRows(quest, onChanged)
    local category, reason, stateName = JourneyQuestCategories.Get(quest.Id)
    local people = _GetPeople(quest)

    ---@type JourneyDetails.Row[]
    local rows = {
        {type = "page", text = QuestieLib:GetColoredQuestName(quest.Id, true, false), tag = table.concat(_GetTags(quest), ", ")},
        {type = "gap", height = 6},
        {type = "text", text = _GetStatus(quest, category, reason, stateName)},
    }
    if Questie.db.char.hidden[quest.Id] then
        table.insert(rows, {type = "text", text = Questie:Colorize(l10n("You hid it from the map"), "gray") .. " ", trailingIcon = JourneyIcon.HIDDEN})
    elseif QuestieCorrections.hiddenQuests[quest.Id] then
        table.insert(rows, {type = "text", text = Questie:Colorize(l10n("Hidden by Questie"), "gray") .. " ", trailingIcon = JourneyIcon.HIDDEN})
    end
    local previous, following = _GetPreviousInChain(quest), _GetNextInChain(quest)
    if category == "later" then
        for _, id in ipairs(previous) do
            if not Questie.db.char.complete[id] then
                local step = _GetStep(id)
                step.tag = l10n("start with this one")
                table.insert(rows, step)
                break
            end
        end
    end
    table.insert(rows, _GetButtons(quest, people, category))
    table.insert(rows, {type = "gap", height = 4})

    table.insert(rows, {type = "text", text = strtrim(QuestieJourneyUtils.CreateObjectiveText(quest.Description))})
    local objectives = {}
    _AddObjectives(objectives, quest, category, onChanged or JourneyWindow.Refresh)
    if #objectives > 0 then
        table.insert(rows, {type = "gap", height = 4})
        for _, row in ipairs(objectives) do table.insert(rows, row) end
    end

    local who = {}
    for _, person in ipairs(people) do _AddPerson(who, person, quest) end
    local startItem = quest.Starts and quest.Starts.Item and QuestieDB:GetItem(quest.Starts.Item[1])
    if startItem then
        table.insert(who, 1, {
            type = "entity",
            icon = QuestieCompat.GetItemIcon(startItem.Id),
            title = startItem.name,
            text = Questie:Colorize(l10n("Starts this quest"), "gray"),
            onClick = function() JourneyWindow.OpenLink("item", startItem.Id) end,
            showTooltip = function() GameTooltip:SetItemByID(startItem.Id) end,
        })
    end
    _AddSection(rows, "Where", who)

    local needed = {}
    for _, id in pairs(quest.preQuestGroup or {}) do
        if QuestieDB.QuestPointers[math.abs(id)] then table.insert(needed, _GetStep(math.abs(id))) end
    end
    _AddSection(rows, "Requires all of these quests to be finished", needed)

    if #previous + #following > 0 then
        local chain = {}
        for _, id in ipairs(previous) do table.insert(chain, _GetStep(id)) end
        table.insert(chain, _GetStep(quest.Id, true))
        for _, id in ipairs(following) do table.insert(chain, _GetStep(id)) end
        table.insert(rows, {type = "caption", text = l10n("Chain") .. Questie:Colorize("   " .. (#previous + 1) .. " / " .. #chain, "gray")})
        for _, row in ipairs(chain) do table.insert(rows, row) end
    end

    _AddSection(rows, REWARDS, _GetRewards(quest))
    _AddSection(rows, "Quest Information", _GetFacts(quest))
    _AddSection(rows, "Your history", _GetHistory(quest)) -- Last, because it grows

    JourneyRawData.AddRows(rows, quest, QuestieDB.questKeys)
    return rows
end

return JourneyQuestDetails
