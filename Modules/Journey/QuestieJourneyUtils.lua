---@class QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:CreateModule("QuestieJourneyUtils")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0");

function QuestieJourneyUtils:GetSortedZoneKeys(zones)
    local function compare(a, b)
        return zones[a] < zones[b]
    end

    local zoneNames = {}
    for k, _ in pairs(zones) do
        table.insert(zoneNames, k)
    end
    table.sort(zoneNames, compare)
    return zoneNames
end

function QuestieJourneyUtils:Spacer(container, size)
    local spacer = AceGUI:Create("Label");
    spacer:SetFullWidth(true);
    spacer:SetText(" ");
    if size and size == "large" then
        spacer:SetFontObject(GameFontHighlightLarge);
    elseif size and size == "small" then
        spacer:SetFontObject(GameFontHighlightSmall);
    else
        spacer:SetFontObject(GameFontHighlight);
    end
    container:AddChild(spacer);
end

function QuestieJourneyUtils:AddLine(frame, text)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true);
    label:SetText(text)
    label:SetFontObject(GameFontNormal)
    frame:AddChild(label)
end

function QuestieJourneyUtils:GetZoneName(id)
    local name = l10n("Unknown Zone")
    for category, data in pairs(l10n.zoneLookup) do
        if data[id] then
            name = l10n.zoneLookup[category][id]
            break
        end
    end
    return name
end

---Get all the available/completed/repeatable/unavailable quests
---@param quests
---@return table<number,any> @The zoneTree table which represents the list of all the different quests
function QuestieJourneyUtils:CollectQuests(quests)
    if (not quests) then
        return nil
    end

    local tree = {
        [1] = {
            value = "a",
            text = l10n('Available Quests'),
            children = {}
        },
        [2] = {
            value = "p",
            text = l10n('Missing Pre Quest'),
            children = {}
        },
        [3] = {
            value = "c",
            text = l10n('Completed Quests'),
            children = {}
        },
        [4] = {
            value = "r",
            text = l10n('Repeatable Quests'),
            children = {},
        },
        [5] = {
            value = "u",
            text = l10n('Unobtainable Quests'),
            children = {},
        }
    }
    local sortedQuestByLevel = QuestieLib:SortQuestIDsByLevel(quests)

    local availableCounter = 0
    local prequestMissingCounter = 0
    local completedCounter = 0
    local unobtainableCounter = 0
    local repeatableCounter = 0

    local unobtainableQuestIds = {}
    local temp = {}

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        ---@type number
        local questId = levelAndQuest[2]
        -- Only show quests which are not hidden
        if QuestieCorrections.hiddenQuests and ((not QuestieCorrections.hiddenQuests[questId]) or QuestieEvent:IsEventQuest(questId)) and QuestieDB.QuestPointers[questId] then
            temp.value = questId
            temp.text = QuestieLib:GetColoredQuestName(questId, Questie.db.global.enableTooltipsQuestLevel, false, true)

            -- Completed quests
            if Questie.db.char.complete[questId] then
                tinsert(tree[3].children, temp)
                completedCounter = completedCounter + 1
            else
                local queryResult = QuestieDB.QueryQuest(
                    questId,
                    {
                        "exclusiveTo",
                        "nextQuestInChain",
                        "parentQuest",
                        "preQuestSingle",
                        "preQuestGroup",
                        "requiredMinRep",
                        "requiredMaxRep"
                    }
                ) or {}
                local exclusiveTo = queryResult[1]
                local nextQuestInChain = queryResult[2]
                local parentQuest = queryResult[3]
                local preQuestSingle = queryResult[4]
                local preQuestGroup = queryResult[5]
                local requiredMinRep = queryResult[6]
                local requiredMaxRep = queryResult[7]

                -- Exclusive quests will never be available since another quests permanently blocks them.
                -- Marking them as complete should be the most satisfying solution for user
                if (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
                    tinsert(tree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- The parent quest has been completed
                elseif parentQuest and Questie.db.char.complete[parentQuest] then
                    tinsert(tree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- Unoptainable reputation quests
                elseif not QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep) then
                    tinsert(tree[5].children, temp)
                    unobtainableQuestIds[questId] = true
                    unobtainableCounter = unobtainableCounter + 1
                -- A single pre Quest is missing
                elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
                    -- The pre Quest is unobtainable therefore this quest is it as well
                    if unobtainableQuestIds[preQuestSingle] ~= nil then
                        tinsert(tree[5].children, temp)
                        unobtainableQuestIds[questId] = true
                        unobtainableCounter = unobtainableCounter + 1
                    else
                        tinsert(tree[2].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- Multiple pre Quests are missing
                elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
                    local hasUnobtainablePreQuest = false
                    for _, preQuestId in pairs(preQuestGroup) do
                        if unobtainableQuestIds[preQuestId] ~= nil then
                            tinsert(tree[5].children, temp)
                            unobtainableQuestIds[questId] = true
                            unobtainableCounter = unobtainableCounter + 1
                            hasUnobtainablePreQuest = true
                            break
                        end
                    end

                    if not hasUnobtainablePreQuest then
                        tinsert(tree[2].children, temp)
                        prequestMissingCounter = prequestMissingCounter + 1
                    end
                -- Repeatable quests
                elseif QuestieDB:IsRepeatable(questId) then
                    tinsert(tree[4].children, temp)
                    repeatableCounter = repeatableCounter + 1
                -- Available quests
                else
                    tinsert(tree[1].children, temp)
                    availableCounter = availableCounter + 1
                end
            end
            temp = {}
        end
    end

    local totalCounter = availableCounter + completedCounter + prequestMissingCounter
    tree[1].text = tree[1].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    tree[2].text = tree[2].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    tree[3].text = tree[3].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    tree[4].text = tree[4].text .. ' [ '..  repeatableCounter ..' ]'
    tree[5].text = tree[5].text .. ' [ '..  unobtainableCounter ..' ]'

    tree.numquests = totalCounter + repeatableCounter + unobtainableCounter

    return tree
end
