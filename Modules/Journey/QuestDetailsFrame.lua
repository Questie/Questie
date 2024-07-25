---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")


-- TODO remove again once the call in manageZoneTree was removed
---@param container ScrollFrame
---@param quest Quest
function _QuestieJourney:DrawQuestDetailsFrame(container, quest)
    local questNameHeader = _QuestieJourney:CreateHeading(quest.name, true)
    container:AddChild(questNameHeader)

    QuestieJourneyUtils:Spacer(container)

    local obj = AceGUI:Create("Label")
    obj:SetText(_QuestieJourney:CreateObjectiveText(quest.Description))
    obj:SetFullWidth(true)
    container:AddChild(obj)

    QuestieJourneyUtils:Spacer(container)

    local questInfoHeader = _QuestieJourney:CreateHeading(l10n('Quest Information'), true)
    container:AddChild(questInfoHeader)

    -- Generic Quest Information

    local levelLabel = _QuestieJourney:CreateLabel(Questie:Colorize(l10n('Recommended Quest Level: '), 'yellow') .. quest.level, true)
    container:AddChild(levelLabel)

    local minLevelLabel = _QuestieJourney:CreateLabel(Questie:Colorize(l10n('Minimum Required Level for Quest: '), 'yellow') .. quest.requiredLevel, true)
    container:AddChild(minLevelLabel)

    local levelDiffString = _QuestieJourney:GetDifficultyString(quest.level, quest.requiredLevel)
    local levelDiffLabel = _QuestieJourney:CreateLabel(levelDiffString, true)
    container:AddChild(levelDiffLabel)

    local questIdLabel = _QuestieJourney:CreateLabel(Questie:Colorize(l10n('Quest ID: '), 'yellow') .. quest.Id, true)
    container:AddChild(questIdLabel)

    QuestieJourneyUtils:Spacer(container)

    local preQuestCounter, preQuestInlineGroup = _QuestieJourney:CreatePreQuestGroup(quest)
    if preQuestCounter > 1 then -- Don't add the group if it doesn't contain a pre quest
        QuestieJourneyUtils:Spacer(preQuestInlineGroup)
        container:AddChild(preQuestInlineGroup)
    end

    -- Get Quest Start NPC
    if quest.Starts and quest.Starts.NPC then
        local startNPCGroup = AceGUI:Create("InlineGroup")
        startNPCGroup:SetLayout("List")
        startNPCGroup:SetTitle(l10n('Quest Start NPC Information'))
        startNPCGroup:SetFullWidth(true)
        container:AddChild(startNPCGroup)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        local startNpc = QuestieDB:GetNPC(quest.Starts.NPC[1])

        local startNPCNameLabel = _QuestieJourney:CreateLabel(startNpc.name, true)
        startNPCNameLabel:SetFontObject(GameFontHighlight)
        startNPCNameLabel:SetColor(255, 165, 0)
        startNPCGroup:AddChild(startNPCNameLabel)

        local startNPCZoneLabel = AceGUI:Create("Label")
        local startindex = 0
        if (not startNpc.spawns) then
            return
        end
        for i in pairs(startNpc.spawns) do
            startindex = i
        end

        if startindex == 0 then
            return
        end
        
        local continent = QuestieJourneyUtils:GetZoneName(startindex)

        startNPCZoneLabel:SetText(l10n(continent))
        startNPCZoneLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCZoneLabel)

        local startx = startNpc.spawns[startindex][1][1]
        local starty = startNpc.spawns[startindex][1][2]
        if (startx ~= -1 or starty ~= -1) then
            local startNPCLocLabel = AceGUI:Create("Label")
            startNPCLocLabel:SetText("X: ".. startx .." || Y: ".. starty)
            startNPCLocLabel:SetFullWidth(true)
            startNPCGroup:AddChild(startNPCLocLabel)
        end

        local startNPCIdLabel = AceGUI:Create("Label")
        startNPCIdLabel:SetText("NPC ID: ".. startNpc.id)
        startNPCIdLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCIdLabel)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        -- Also Starts
        if startNpc.questStarts then

            local alsoStartsLabel = AceGUI:Create("Label")
            alsoStartsLabel:SetText(l10n('This NPC Also Starts the following quests:'))
            alsoStartsLabel:SetColor(255, 165, 0)
            alsoStartsLabel:SetFontObject(GameFontHighlight)
            alsoStartsLabel:SetFullWidth(true)
            startNPCGroup:AddChild(alsoStartsLabel)

            local startQuests = {}
            local counter = 1
            for _, v in pairs(startNpc.questStarts) do
                if v ~= quest.Id then
                    startQuests[counter] = {}
                    local startQuest = QuestieDB.GetQuest(v)
                    local label = _QuestieJourney:GetInteractiveQuestLabel(startQuest)
                    startQuests[counter].frame = label
                    startQuests[counter].quest = startQuest
                    startNPCGroup:AddChild(label)
                    counter = counter + 1
                end
            end

            if #startQuests == 0 then
                local noQuestLabel = AceGUI:Create("Label")
                noQuestLabel:SetText(l10n('No Quests to List'))
                noQuestLabel:SetFullWidth(true)
                startNPCGroup:AddChild(noQuestLabel)
            end
        end

        QuestieJourneyUtils:Spacer(startNPCGroup)

    end

    -- Get Quest Start GameObject
    if quest.Starts and quest.Starts.GameObject then
        local startObjectGroup = AceGUI:Create("InlineGroup")
        startObjectGroup:SetLayout("List")
        startObjectGroup:SetTitle(l10n('Quest Start Object Information'))
        startObjectGroup:SetFullWidth(true)
        container:AddChild(startObjectGroup)

        QuestieJourneyUtils:Spacer(startObjectGroup)

        for _, oid in pairs(quest.Starts.GameObject) do
            local startObj = QuestieDB:GetObject(oid)

            local startObjectNameLabel = AceGUI:Create("Label")
            startObjectNameLabel:SetText(startObj.name)
            startObjectNameLabel:SetFontObject(GameFontHighlight)
            startObjectNameLabel:SetColor(255, 165, 0)
            startObjectNameLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectNameLabel)

            local startObjectZoneLabel = AceGUI:Create("Label")
            local startindex = 0
            for i in pairs(startObj.spawns) do
                startindex = i
            end

            local continent = QuestieJourneyUtils:GetZoneName(startindex)

            startObjectZoneLabel:SetText(continent)
            startObjectZoneLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectZoneLabel)

            local startx = startObj.spawns[startindex][1][1]
            local starty = startObj.spawns[startindex][1][2]
            if (startx ~= -1 or starty ~= -1) then
                local startObjectLocLabel = AceGUI:Create("Label")
                startObjectLocLabel:SetText("X: ".. startx .." || Y: ".. starty)
                startObjectLocLabel:SetFullWidth(true)
                startObjectGroup:AddChild(startObjectLocLabel)
            end

            local startObjectIdLabel = AceGUI:Create("Label")
            startObjectIdLabel:SetText("Object ID: ".. startObj.id)
            startObjectIdLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectIdLabel)

            QuestieJourneyUtils:Spacer(startObjectGroup)

            -- Also Starts
            if startObj.questStarts then

                local alsoStartsLabel = AceGUI:Create("Label")
                alsoStartsLabel:SetText(l10n('This Object Also Starts the following quests:'))
                alsoStartsLabel:SetColor(255, 165, 0)
                alsoStartsLabel:SetFontObject(GameFontHighlight)
                alsoStartsLabel:SetFullWidth(true)
                startObjectGroup:AddChild(alsoStartsLabel)

                local startQuests = {}
                local counter = 1
                for _, v in pairs(startObj.questStarts) do
                    if v ~= quest.Id then
                        startQuests[counter] = {}
                        local startQuest = QuestieDB.GetQuest(v)
                        local label = _QuestieJourney:GetInteractiveQuestLabel(startQuest)
                        startQuests[counter].frame = label
                        startQuests[counter].quest = startQuest
                        startObjectGroup:AddChild(label)
                        counter = counter + 1
                    end
                end

                if #startQuests == 0 then
                    local noQuestLabel = AceGUI:Create("Label")
                    noQuestLabel:SetText(l10n('No Quests to List'))
                    noQuestLabel:SetFullWidth(true)
                    startObjectGroup:AddChild(noQuestLabel)
                end
            end

            QuestieJourneyUtils:Spacer(startObjectGroup)
        end
    end

    QuestieJourneyUtils:Spacer(container)

    if quest.Finisher and quest.Finisher.Name and quest.Finisher.Type == "monster" then
        local endNPCGroup = AceGUI:Create("InlineGroup")
        endNPCGroup:SetLayout("Flow")
        endNPCGroup:SetTitle(l10n('Quest Turn-in NPC Information'))
        endNPCGroup:SetFullWidth(true)
        container:AddChild(endNPCGroup)
        QuestieJourneyUtils:Spacer(endNPCGroup)

        local endNPC = QuestieDB:GetNPC(quest.Finisher.Id)

        local endNPCNameLabel = AceGUI:Create("Label")
        endNPCNameLabel:SetText(endNPC.name)
        endNPCNameLabel:SetFontObject(GameFontHighlight)
        endNPCNameLabel:SetColor(255, 165, 0)
        endNPCNameLabel:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCNameLabel)

        local endNPCZoneLabel = AceGUI:Create("Label")
        local endindex = 0
        if (not endNPC.spawns) then
            return
        end
        for i in pairs(endNPC.spawns) do
            endindex = i
        end

        local continent = QuestieJourneyUtils:GetZoneName(endindex)
        
        endNPCZoneLabel:SetText(l10n(continent))
        endNPCZoneLabel:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCZoneLabel)

        if (next(endNPC.spawns)) then
            local endx = endNPC.spawns[endindex][1][1]
            local endy = endNPC.spawns[endindex][1][2]
            if (endx ~= -1 or endy ~= -1) then
                local endNPCLocLabel = AceGUI:Create("Label")
                endNPCLocLabel:SetText("X: ".. endx .." || Y: ".. endy)
                endNPCLocLabel:SetFullWidth(true)
                endNPCGroup:AddChild(endNPCLocLabel)
            end
        end

        local endNPCIdLabel = AceGUI:Create("Label")
        endNPCIdLabel:SetText("NPC ID: ".. endNPC.id)
        endNPCIdLabel:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCIdLabel)

        QuestieJourneyUtils:Spacer(endNPCGroup)

        -- Also ends
        if endNPC.endQuests then
            local alsoEndsLabel = AceGUI:Create("Label")
            alsoEndsLabel:SetText(l10n('This NPC Also Completes the following quests:'))
            alsoEndsLabel:SetFontObject(GameFontHighlight)
            alsoEndsLabel:SetColor(255, 165, 0)
            alsoEndsLabel:SetFullWidth(true)
            endNPCGroup:AddChild(alsoEndsLabel)

            local endQuests = {}
            local counter = 1
            for _, v in ipairs(endNPC.endQuests) do
                if v ~= quest.Id then
                    endQuests[counter] = {}
                    local endQuest = QuestieDB.GetQuest(v)
                    local label = _QuestieJourney:GetInteractiveQuestLabel(endQuest)
                    endQuests[counter].frame = label
                    endQuests[counter].quest = endQuest
                    endNPCGroup:AddChild(label)
                    counter = counter + 1
                end
            end

            if #endQuests == 0 then
                local noQuestLabel = AceGUI:Create("Label")
                noQuestLabel:SetText(l10n('No Quests to List'))
                noQuestLabel:SetFullWidth(true)
                endNPCGroup:AddChild(noQuestLabel)
            end

            QuestieJourneyUtils:Spacer(endNPCGroup)
        end

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        container.content:SetHeight(10000)
    end
end

---@param text string
---@param fullWidth boolean
---@return AceHeader
function _QuestieJourney:CreateHeading(text, fullWidth)
    ---@class AceHeader
    local header = AceGUI:Create("Heading")
    header:SetFullWidth(fullWidth)
    header:SetText(text)

    return header
end

---@param text string
---@param fullWidth boolean
---@return AceLabel
function _QuestieJourney:CreateLabel(text, fullWidth)
    ---@class AceLabel
    local header = AceGUI:Create("Label")
    header:SetFullWidth(fullWidth)
    header:SetText(text)

    return header
end

---@param questLevel number
---@param questMinLevel number
---@return string
function _QuestieJourney:GetDifficultyString(questLevel, questMinLevel)
    local red, orange, yellow, green, gray = _QuestieJourney:GetLevelDifficultyRanges(questLevel, questMinLevel)
    local diffStr = ''

    if red then
        diffStr = diffStr .. "|cFFFF1A1A[".. red .."]|r "
    end

    if orange then
        diffStr = diffStr .. "|cFFFF8040[".. orange .."]|r "
    end

    diffStr = diffStr .. "|cFFFFFF00[".. yellow .."]|r "
    diffStr = diffStr .. "|cFF40C040[".. green .."]|r "
    diffStr = diffStr .. "|cFFC0C0C0[".. gray .."]|r "

    return Questie:Colorize(l10n('Difficulty Range: %s', diffStr), 'yellow')
end

---@param quest Quest
---@return number @The number of pre quests added to the group
---@return AceInlineGroup @The created Ace InlineGroup
function _QuestieJourney:CreatePreQuestGroup(quest)
    ---@class AceInlineGroup
    local preQuestInlineGroup = AceGUI:Create("InlineGroup")
    local preQuestCounter = 1

    preQuestInlineGroup:SetLayout("List")
    preQuestInlineGroup:SetTitle(l10n('Pre Quests'))
    preQuestInlineGroup:SetFullWidth(true)

    if (quest.preQuestSingle and next(quest.preQuestSingle)) then
        for _, v in pairs(quest.preQuestSingle) do
            if v ~= quest.Id then
                local preQuest = QuestieDB.GetQuest(v)
                local label = _QuestieJourney:GetInteractiveQuestLabel(preQuest)
                preQuestInlineGroup:AddChild(label)
                preQuestCounter = preQuestCounter + 1
            end
        end
    end

    if (quest.preQuestGroup and next(quest.preQuestGroup)) then
        for _, v in pairs(quest.preQuestGroup) do
            if v ~= quest.Id then
                local preQuest = QuestieDB.GetQuest(v)
                local label = _QuestieJourney:GetInteractiveQuestLabel(preQuest)
                preQuestInlineGroup:AddChild(label)
                preQuestCounter = preQuestCounter + 1
            end
        end
    end

    return preQuestCounter, preQuestInlineGroup
end

---@param quest Quest
---@return AceInteractiveLabel
function _QuestieJourney:GetInteractiveQuestLabel(quest)
    ---@class AceInteractiveLabel
    local label = AceGUI:Create("InteractiveLabel")
    local questId = quest.Id

    label:SetText(QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false, true))
    label:SetUserData('id', questId)
    label:SetUserData('name', quest.name)
    label:SetCallback("OnClick", function()
        ItemRefTooltip:SetHyperlink("%|Hquestie:" .. questId .. ":.*%|h", "%[%[" .. quest.level .. "%] " .. quest.name .. " %(" .. questId .. "%)%]")
    end)
    label:SetCallback("OnEnter", _QuestieJourney.ShowJourneyTooltip)
    label:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)

    return label
end
