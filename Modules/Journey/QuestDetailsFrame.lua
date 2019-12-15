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

    local questInfoHeader = _QuestieJourney:CreateHeading(QuestieLocale:GetUIString('JOURNEY_QUESTINFO'), true)
    container:AddChild(questInfoHeader)

    -- Generic Quest Information

    local levelLabel = _QuestieJourney:CreateLabel(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_LEVEL'), 'yellow') .. quest.level, true)
    container:AddChild(levelLabel)

    local minLevelLabel = _QuestieJourney:CreateLabel(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_MINLEVEL'), 'yellow') .. quest.requiredLevel, true)
    container:AddChild(minLevelLabel)

    local levelDiffString = _QuestieJourney:GetDifficultyString(quest.level, quest.requiredLevel)
    local levelDiffLabel = _QuestieJourney:CreateLabel(levelDiffString, true)
    container:AddChild(levelDiffLabel)

    local questIdLabel = _QuestieJourney:CreateLabel(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_ID'), 'yellow') .. quest.Id, true)
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
        startNPCGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_NPC'))
        startNPCGroup:SetFullWidth(true)
        container:AddChild(startNPCGroup)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        local startnpc = QuestieDB:GetNPC(quest.Starts.NPC[1])

        local startNPCNameLabel = _QuestieJourney:CreateLabel(startnpc.name, true)
        startNPCNameLabel:SetFontObject(GameFontHighlight)
        startNPCNameLabel:SetColor(255, 165, 0)
        startNPCGroup:AddChild(startNPCNameLabel)

        local startNPCZoneLabel = AceGUI:Create("Label")
        local startindex = 0
        if not startnpc.spawns then
            return
        end
        for i in pairs(startnpc.spawns) do
            startindex = i
        end

        local continent = 'UNKNOWN ZONE'
        for i, v in ipairs(QuestieJourney.zones) do
            if v[startindex] then
                continent = QuestieJourney.zones[i][startindex]
            end
        end

        startNPCZoneLabel:SetText(continent)
        startNPCZoneLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCZoneLabel)

        local startx = startnpc.spawns[startindex][1][1]
        local starty = startnpc.spawns[startindex][1][2]
        if (startx ~= -1 or starty ~= -1) then
            local startNPCLocLabel = AceGUI:Create("Label")
            startNPCLocLabel:SetText("X: ".. startx .." || Y: ".. starty)
            startNPCLocLabel:SetFullWidth(true)
            startNPCGroup:AddChild(startNPCLocLabel)
        end

        local startNPCIdLabel = AceGUI:Create("Label")
        startNPCIdLabel:SetText("NPC ID: ".. startnpc.id)
        startNPCIdLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCIdLabel)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        -- Also Starts
        if startnpc.questStarts then

            local alsoStartsLabel = AceGUI:Create("Label")
            alsoStartsLabel:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS'))
            alsoStartsLabel:SetColor(255, 165, 0)
            alsoStartsLabel:SetFontObject(GameFontHighlight)
            alsoStartsLabel:SetFullWidth(true)
            startNPCGroup:AddChild(alsoStartsLabel)

            local startQuests = {}
            local counter = 1
            for i, v in pairs(startnpc.questStarts) do
                if not (v == quest.Id) then
                    startQuests[counter] = {}
                    local startQuest = QuestieDB:GetQuest(v)
                    local label = _QuestieJourney:GetInteractiveQuestLabel(startQuest)
                    startQuests[counter].frame = label
                    startQuests[counter].quest = startQuest
                    startNPCGroup:AddChild(label)
                    counter = counter + 1
                end
            end

            if #startQuests == 0 then
                local noQuestLabel = AceGUI:Create("Label")
                noQuestLabel:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'))
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
        startObjectGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_OBJ'))
        startObjectGroup:SetFullWidth(true)
        container:AddChild(startObjectGroup)

        QuestieJourneyUtils:Spacer(startObjectGroup)

        for _, oid in pairs(quest.Starts.GameObject) do
            local startobj = QuestieDB:GetObject(oid)

            local startObjectNameLabel = AceGUI:Create("Label")
            startObjectNameLabel:SetText(startobj.name)
            startObjectNameLabel:SetFontObject(GameFontHighlight)
            startObjectNameLabel:SetColor(255, 165, 0)
            startObjectNameLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectNameLabel)

            local startObjectZoneLabel = AceGUI:Create("Label")
            local startindex = 0
            for i in pairs(startobj.spawns) do
                startindex = i
            end

            local continent = 'UNKNOWN ZONE'
            for i, v in ipairs(QuestieJourney.zones) do
                if v[startindex] then
                    continent = QuestieJourney.zones[i][startindex]
                end
            end

            startObjectZoneLabel:SetText(continent)
            startObjectZoneLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectZoneLabel)

            local startx = startobj.spawns[startindex][1][1]
            local starty = startobj.spawns[startindex][1][2]
            if (startx ~= -1 or starty ~= -1) then
                local startObjectLocLabel = AceGUI:Create("Label")
                startObjectLocLabel:SetText("X: ".. startx .." || Y: ".. starty)
                startObjectLocLabel:SetFullWidth(true)
                startObjectGroup:AddChild(startObjectLocLabel)
            end

            local startObjectIdLabel = AceGUI:Create("Label")
            startObjectIdLabel:SetText("Object ID: ".. startobj.id)
            startObjectIdLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectIdLabel)

            QuestieJourneyUtils:Spacer(startObjectGroup)

            -- Also Starts
            if startobj.questStarts then

                local alsoStartsLabel = AceGUI:Create("Label")
                alsoStartsLabel:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS_GO'))
                alsoStartsLabel:SetColor(255, 165, 0)
                alsoStartsLabel:SetFontObject(GameFontHighlight)
                alsoStartsLabel:SetFullWidth(true)
                startObjectGroup:AddChild(alsoStartsLabel)

                local startQuests = {}
                local counter = 1
                for _, v in pairs(startobj.questStarts) do
                    if not (v == quest.Id) then
                        startQuests[counter] = {}
                        local startQuest = QuestieDB:GetQuest(v)
                        local label = _QuestieJourney:GetInteractiveQuestLabel(startQuest)
                        startQuests[counter].frame = label
                        startQuests[counter].quest = startQuest
                        startObjectGroup:AddChild(label)
                        counter = counter + 1
                    end
                end

                if #startQuests == 0 then
                    local noQuestLabel = AceGUI:Create("Label")
                    noQuestLabel:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'))
                    noQuestLabel:SetFullWidth(true)
                    startObjectGroup:AddChild(noQuestLabel)
                end
            end

            QuestieJourneyUtils:Spacer(startObjectGroup)
        end
    end

    QuestieJourneyUtils:Spacer(container)

    -- Get Quest Turnin NPC
    if quest.Finisher and quest.Finisher.Name and quest.Finisher.Type == "monster" then
        local endNPCGroup = AceGUI:Create("InlineGroup")
        endNPCGroup:SetLayout("Flow")
        endNPCGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_END_NPC'))
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
        if not endNPC.spawns then
            return
        end
        for i in pairs(endNPC.spawns) do
            endindex = i
        end

        local continent = 'UNKNOWN ZONE'
        for i, v in ipairs(QuestieJourney.zones) do
            if v[endindex] then
                continent = QuestieJourney.zones[i][endindex]
            end
        end

        endNPCZoneLabel:SetText(continent)
        endNPCZoneLabel:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCZoneLabel)

        local endx = endNPC.spawns[endindex][1][1]
        local endy = endNPC.spawns[endindex][1][2]
        if (endx ~= -1 or endy ~= -1) then
            local endNPCLocLabel = AceGUI:Create("Label")
            endNPCLocLabel:SetText("X: ".. endx .." || Y: ".. endy)
            endNPCLocLabel:SetFullWidth(true)
            endNPCGroup:AddChild(endNPCLocLabel)
        end

        local endNPCIdLabel = AceGUI:Create("Label")
        endNPCIdLabel:SetText("NPC ID: ".. endNPC.id)
        endNPCIdLabel:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCIdLabel)

        QuestieJourneyUtils:Spacer(endNPCGroup)

        -- Also ends
        if endNPC.endQuests then
            local alsoEndsLabel = AceGUI:Create("Label")
            alsoEndsLabel:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_ENDS'))
            alsoEndsLabel:SetFontObject(GameFontHighlight)
            alsoEndsLabel:SetColor(255, 165, 0)
            alsoEndsLabel:SetFullWidth(true)
            endNPCGroup:AddChild(alsoEndsLabel)

            local endQuests = {}
            local counter = 1
            for i, v in ipairs(endNPC.endQuests) do
                if not (v == quest.Id) then
                    endQuests[counter] = {}
                    local endQuest = QuestieDB:GetQuest(v)
                    local label = _QuestieJourney:GetInteractiveQuestLabel(endQuest)
                    endQuests[counter].frame = label
                    endQuests[counter].quest = endQuest
                    endNPCGroup:AddChild(label)
                    counter = counter + 1
                end
            end

            if #endQuests == 0 then
                local noQuestLabel = AceGUI:Create("Label")
                noQuestLabel:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'))
                noQuestLabel:SetFullWidth(true)
                endNPCGroup:AddChild(noQuestLabel)
            end

        end

        QuestieJourneyUtils:Spacer(endNPCGroup)

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

---@param questLevel integer
---@param questMinLevel integer
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

    return Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_DIFFICULTY', diffStr), 'yellow')
end

---@param quest Quest
---@return integer @The number of pre quests added to the group
---@return AceInlineGroup @The created Ace InlineGroup
function _QuestieJourney:CreatePreQuestGroup(quest)
    ---@class AceInlineGroup
    local preQuestInlineGroup = AceGUI:Create("InlineGroup")
    local preQuestCounter = 1
    local preQuests = {}

    preQuestInlineGroup:SetLayout("List")
    preQuestInlineGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_PREQUEST'))
    preQuestInlineGroup:SetFullWidth(true)

    if (quest.preQuestSingle and next(quest.preQuestSingle)) then
        for _, v in pairs(quest.preQuestSingle) do
            if not (v == quest.Id) then
                preQuests[preQuestCounter] = {}
                local preQuest = QuestieDB:GetQuest(v)
                local label = _QuestieJourney:GetInteractiveQuestLabel(preQuest)
                preQuests[preQuestCounter].frame = label
                preQuests[preQuestCounter].quest = preQuest
                preQuestInlineGroup:AddChild(label)
                preQuestCounter = preQuestCounter + 1
            end
        end
    end

    if (quest.preQuestGroup and next(quest.preQuestGroup)) then
        for _, v in pairs(quest.preQuestGroup) do
            if not (v == quest.Id) then
                preQuests[preQuestCounter] = {}
                local preQuest = QuestieDB:GetQuest(v)
                local label = _QuestieJourney:GetInteractiveQuestLabel(preQuest)
                preQuests[preQuestCounter].frame = label
                preQuests[preQuestCounter].quest = preQuest
                preQuestInlineGroup:AddChild(label)
                preQuestCounter = preQuestCounter + 1
            end
        end
    end

    return preQuestCounter, preQuestInlineGroup
end

---@param preQuest Quest
---@return AceInteractiveLabel
function _QuestieJourney:GetInteractiveQuestLabel(preQuest)
    ---@class AceInteractiveLabel
    local label = AceGUI:Create("InteractiveLabel")

    label:SetText(preQuest:GetColoredQuestName())
    label:SetUserData('id', preQuest.Id)
    label:SetUserData('name', preQuest.name)
    label:SetCallback("OnClick", _QuestieJourney.JumpToQuest)
    label:SetCallback("OnEnter", _QuestieJourney.ShowJourneyTooltip)
    label:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)

    return label
end