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

        local startNPCZone = AceGUI:Create("Label")
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

        startNPCZone:SetText(continent)
        startNPCZone:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCZone)

        local startx = startnpc.spawns[startindex][1][1]
        local starty = startnpc.spawns[startindex][1][2]
        if (startx ~= -1 or starty ~= -1) then
            local startNPCLoc = AceGUI:Create("Label")
            startNPCLoc:SetText("X: ".. startx .." || Y: ".. starty)
            startNPCLoc:SetFullWidth(true)
            startNPCGroup:AddChild(startNPCLoc)
        end

        local startNPCID = AceGUI:Create("Label")
        startNPCID:SetText("NPC ID: ".. startnpc.id)
        startNPCID:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCID)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        -- Also Starts
        if startnpc.questStarts then

            local alsostarts = AceGUI:Create("Label")
            alsostarts:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS'))
            alsostarts:SetColor(255, 165, 0)
            alsostarts:SetFontObject(GameFontHighlight)
            alsostarts:SetFullWidth(true)
            startNPCGroup:AddChild(alsostarts)

            local startQuests = {}
            local counter = 1
            for i, v in pairs(startnpc.questStarts) do
                if not (v == quest.Id) then
                    startQuests[counter] = {}
                    startQuests[counter].frame = AceGUI:Create("InteractiveLabel")
                    startQuests[counter].quest = QuestieDB:GetQuest(v)
                    startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName())
                    startQuests[counter].frame:SetUserData('id', v)
                    startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.name)
                    startQuests[counter].frame:SetCallback("OnClick", JumpToQuest)
                    startQuests[counter].frame:SetCallback("OnEnter", ShowJourneyTooltip)
                    startQuests[counter].frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)
                    startNPCGroup:AddChild(startQuests[counter].frame)
                    counter = counter + 1
                end
            end

            if #startQuests == 0 then
                local noquest = AceGUI:Create("Label")
                noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'))
                noquest:SetFullWidth(true)
                startNPCGroup:AddChild(noquest)
            end
        end

        QuestieJourneyUtils:Spacer(startNPCGroup)

    end

    -- Get Quest Start GameObject
    if quest.Starts and quest.Starts.GameObject then
        local startGOGroup = AceGUI:Create("InlineGroup")
        startGOGroup:SetLayout("List")
        startGOGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_OBJ'))
        startGOGroup:SetFullWidth(true)
        container:AddChild(startGOGroup)

        QuestieJourneyUtils:Spacer(startGOGroup)

        for i, oid in pairs(quest.Starts.GameObject) do
            local startobj = QuestieDB:GetObject(oid)

            local startGOGName = AceGUI:Create("Label")
            startGOGName:SetText(startobj.name)
            startGOGName:SetFontObject(GameFontHighlight)
            startGOGName:SetColor(255, 165, 0)
            startGOGName:SetFullWidth(true)
            startGOGroup:AddChild(startGOGName)

            local starGOCZone = AceGUI:Create("Label")
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

            starGOCZone:SetText(continent)
            starGOCZone:SetFullWidth(true)
            startGOGroup:AddChild(starGOCZone)

            local startx = startobj.spawns[startindex][1][1]
            local starty = startobj.spawns[startindex][1][2]
            if (startx ~= -1 or starty ~= -1) then
                local startGOLoc = AceGUI:Create("Label")
                startGOLoc:SetText("X: ".. startx .." || Y: ".. starty)
                startGOLoc:SetFullWidth(true)
                startGOGroup:AddChild(startGOLoc)
            end

            local startGOID = AceGUI:Create("Label")
            startGOID:SetText("Object ID: ".. startobj.id)
            startGOID:SetFullWidth(true)
            startGOGroup:AddChild(startGOID)

            QuestieJourneyUtils:Spacer(startGOGroup)

            -- Also Starts
            if startobj.questStarts then

                local alsostarts = AceGUI:Create("Label")
                alsostarts:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS_GO'))
                alsostarts:SetColor(255, 165, 0)
                alsostarts:SetFontObject(GameFontHighlight)
                alsostarts:SetFullWidth(true)
                startGOGroup:AddChild(alsostarts)

                local startQuests = {}
                local counter = 1
                for i, v in pairs(startobj.questStarts) do
                    if not (v == quest.Id) then
                        startQuests[counter] = {}
                        startQuests[counter].frame = AceGUI:Create("InteractiveLabel")
                        startQuests[counter].quest = QuestieDB:GetQuest(v)
                        startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName())
                        startQuests[counter].frame:SetUserData('id', v)
                        startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.name)
                        startQuests[counter].frame:SetCallback("OnClick", JumpToQuest)
                        startQuests[counter].frame:SetCallback("OnEnter", ShowJourneyTooltip)
                        startQuests[counter].frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)
                        startGOGroup:AddChild(startQuests[counter].frame)
                        counter = counter + 1
                    end
                end

                if #startQuests == 0 then
                    local noquest = AceGUI:Create("Label")
                    noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'))
                    noquest:SetFullWidth(true)
                    startGOGroup:AddChild(noquest)
                end
            end

            QuestieJourneyUtils:Spacer(startGOGroup)
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

        local endnpc = QuestieDB:GetNPC(quest.Finisher.Id)

        local endNPCName = AceGUI:Create("Label")
        endNPCName:SetText(endnpc.name)
        endNPCName:SetFontObject(GameFontHighlight)
        endNPCName:SetColor(255, 165, 0)
        endNPCName:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCName)

        local endNPCZone = AceGUI:Create("Label")
        local endindex = 0
        if not endnpc.spawns then
            return
        end
        for i in pairs(endnpc.spawns) do
            endindex = i
        end

        local continent = 'UNKNOWN ZONE'
        for i, v in ipairs(QuestieJourney.zones) do
            if v[endindex] then
                continent = QuestieJourney.zones[i][endindex]
            end
        end

        endNPCZone:SetText(continent)
        endNPCZone:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCZone)

        local endx = endnpc.spawns[endindex][1][1]
        local endy = endnpc.spawns[endindex][1][2]
        if (endx ~= -1 or endy ~= -1) then
            local endNPCLoc = AceGUI:Create("Label")
            endNPCLoc:SetText("X: ".. endx .." || Y: ".. endy)
            endNPCLoc:SetFullWidth(true)
            endNPCGroup:AddChild(endNPCLoc)
        end

        local endNPCID = AceGUI:Create("Label")
        endNPCID:SetText("NPC ID: ".. endnpc.id)
        endNPCID:SetFullWidth(true)
        endNPCGroup:AddChild(endNPCID)

        QuestieJourneyUtils:Spacer(endNPCGroup)

        -- Also ends
        if endnpc.endQuests then
            local alsoends = AceGUI:Create("Label")
            alsoends:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_ENDS'))
            alsoends:SetFontObject(GameFontHighlight)
            alsoends:SetColor(255, 165, 0)
            alsoends:SetFullWidth(true)
            endNPCGroup:AddChild(alsoends)

            local endQuests = {}
            local counter = 1
            for i, v in ipairs(endnpc.endQuests) do
                if not (v == quest.Id) then
                    endQuests[counter] = {}
                    endQuests[counter].frame = AceGUI:Create("InteractiveLabel")
                    endQuests[counter].quest = QuestieDB:GetQuest(v)
                    endQuests[counter].frame:SetText(endQuests[counter].quest:GetColoredQuestName())
                    endQuests[counter].frame:SetUserData('id', v)
                    endQuests[counter].frame:SetUserData('name', endQuests[counter].quest.name)
                    endQuests[counter].frame:SetCallback("OnClick", JumpToQuest)
                    endQuests[counter].frame:SetCallback("OnEnter", ShowJourneyTooltip)
                    endQuests[counter].frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)
                    endNPCGroup:AddChild(endQuests[counter].frame)
                    counter = counter + 1
                end
            end

            if #endQuests == 0 then
                local noquest = AceGUI:Create("Label")
                noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'))
                noquest:SetFullWidth(true)
                endNPCGroup:AddChild(noquest)
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
