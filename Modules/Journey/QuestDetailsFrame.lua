---@class QuestDetailsFrame
local QuestDetailsFrame = QuestieLoader:CreateModule("QuestDetailsFrame")

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
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")

local AceGUI = LibStub("AceGUI-3.0")

local stringrep = string.rep

local function rec(theTable, ret, indent)
    ret = ret..stringrep('    ', indent)..'{\n'
    indent = indent + 1
    for k, v in pairs(theTable) do
        local t = type(v)
        if t == 'nil' then
            ret = ret..stringrep('    ', indent)..'['..k..']=nil'
        elseif t == 'table' then
            ret = rec(v, ret..stringrep('    ', indent)..'['..k..']=\n', indent)
        else
            ret = ret..stringrep('    ', indent)..'['..k..']='..v
        end
        ret = ret..'\n'
    end
    return ret..stringrep('    ', indent-1)..'},'
end

local function recurseTable(theTable, theKeys)
    local ret = Questie:Colorize('Raw data (shown because debug is enabled):\n\n', 'red')
    for key, _ in pairs(theKeys) do
        ret = ret..Questie:Colorize(key, 'yellow')..': '
        local t = type(theTable[key])
        if t == 'nil' then
            ret = ret..'nil'
        elseif t == 'table' then
            ret = rec(theTable[key], ret, 0)
        else
            ret = ret..theTable[key]
        end
        ret = ret..'\n'
    end
    return ret
end

---Creates a TomTom waypoint button if TomTom is available and coordinates are valid, otherwise returns nil.
---@param name string
---@param zone AreaId
---@param x number
---@param y number
---@return AceGUIWidget|nil
local function CreateTomTomButton(name, zone, x, y)
    if (not (TomTom and TomTom.AddWaypoint)) or (x == -1 and y == -1) then
        return nil
    end

    local tomTomButton = AceGUI:Create("Button")
    tomTomButton:SetText(l10n("Set |cFF54e33bTomTom|r Target"))
    tomTomButton:SetCallback("OnClick", function()
        TrackerUtils:SetTomTomTarget(name, zone, x, y)
    end)
    return tomTomButton
end

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

---@param text string
---@param fullWidth boolean
---@return AceHeader
local function CreateHeading(text, fullWidth)
    ---@class AceHeader
    local header = AceGUI:Create("Heading")
    header:SetFullWidth(fullWidth)
    header:SetText(text)

    return header
end

---@param text string
---@param fullWidth boolean
---@return AceLabel
local function CreateLabel(text, fullWidth)
    ---@class AceLabel
    local header = AceGUI:Create("Label")
    header:SetFullWidth(fullWidth)
    header:SetText(text)

    return header
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
        if (questLevel <= 5) then
            gray =  questLevel + 5
        elseif (questLevel <= 39) then
            gray = (questLevel + math.ceil(questLevel / 10) + 5)
        else
            gray = (questLevel + math.ceil(questLevel / 5) + 1)
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

---Takes a frame and adds a paragraph with a header text and a list of links to other search results
---@param frame ScrollFrame The frame to work on
---@param linkType string The type of result to link to (npc|object|quest|item)
---@param lookup table Table of IDs (npc|object|quest|item)
---@param header string The text header to show above the links
---@param query function The function used to get link name from
local function AddLinkedParagraph(frame, linkType, lookup, header, query)
    if lookup and #lookup > 0 then
        local group = AceGUI:Create("InlineGroup")
        group:SetFullWidth(true)
        group:SetLayout("List")
        group:SetTitle(header)
        frame:AddChild(group)

        for _, id in pairs(lookup) do
            id = math.abs(id)
            local link = AceGUI:Create("InteractiveLabel")
            local name = query(id, "name")
            local text
            if linkType == 'quest' then
                text = QuestieLib:GetColoredQuestName(id, true, true)
            elseif linkType == 'npc' then
                local lvl = query(id, 'maxLevel')
                text = '['..lvl..'] '..name..' ('..id..')'
            else
                text = name.." ("..id..")"
            end
            link:SetText(text)
            link:SetUserData("id", id)
            link:SetUserData("type", linkType)
            link:SetUserData("name", name)
            link:SetCallback("OnClick", function() end) -- No-op; could be used for navigation
            link:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
            link:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)
            group:AddChild(link)
        end
    end
end

---@param container ScrollFrame
---@param quest Quest
function QuestDetailsFrame:Draw(container, quest)
    local questNameHeader = CreateHeading(quest.name, true)
    container:AddChild(questNameHeader)

    QuestieJourneyUtils:Spacer(container)

    local obj = AceGUI:Create("Label")
    obj:SetText(QuestieJourneyUtils.CreateObjectiveText(quest.Description))
    obj:SetFullWidth(true)
    container:AddChild(obj)

    QuestieJourneyUtils:Spacer(container)

    local questInfoHeader = CreateHeading(l10n('Quest Information'), true)
    container:AddChild(questInfoHeader)

    -- Complete checkbox (disabled/read-only)
    local completedCheckbox = AceGUI:Create("CheckBox")
    completedCheckbox:SetValue(Questie.db.char.complete[quest.Id])
    completedCheckbox:SetLabel(l10n("Complete"))
    completedCheckbox:SetDisabled(true)
    completedCheckbox:SetHeight(16)
    completedCheckbox.text:SetFontObject(GameFontHighlightSmall)
    completedCheckbox:SetFullWidth(true)
    container:AddChild(completedCheckbox)

    -- Hidden by Questie checkbox (disabled/read-only)
    local hiddenByQuestieCheckbox = AceGUI:Create("CheckBox")
    hiddenByQuestieCheckbox:SetValue(QuestieCorrections.hiddenQuests[quest.Id])
    hiddenByQuestieCheckbox:SetLabel(l10n("Hidden by Questie"))
    hiddenByQuestieCheckbox:SetDisabled(true)
    hiddenByQuestieCheckbox:SetHeight(16)
    hiddenByQuestieCheckbox.text:SetFontObject(GameFontHighlightSmall)
    hiddenByQuestieCheckbox:SetFullWidth(true)
    container:AddChild(hiddenByQuestieCheckbox)

    -- Hidden checkbox (interactive with tooltip)
    local hideQuestCheckbox = AceGUI:Create("CheckBox")
    hideQuestCheckbox.questId = quest.Id
    hideQuestCheckbox:SetLabel(l10n("Hidden"))
    hideQuestCheckbox:SetValue(Questie.db.char.hidden[quest.Id] ~= nil)
    hideQuestCheckbox.text:SetFontObject(GameFontHighlightSmall)
    hideQuestCheckbox:SetFullWidth(true)
    hideQuestCheckbox:SetCallback("OnValueChanged", function(frame)
        if Questie.db.char.hidden[frame.questId] ~= nil then
            QuestieQuest:UnhideQuest(frame.questId)
        else
            QuestieQuest:HideQuest(frame.questId)
        end
    end)
    hideQuestCheckbox:SetCallback("OnEnter", function()
        if GameTooltip:IsShown() then
            return
        end
        GameTooltip:SetOwner(_G["QuestieJourneyFrame"].frame:GetParent(), "ANCHOR_CURSOR")
        GameTooltip:AddLine(l10n("Quest is hidden"))
        GameTooltip:AddLine(l10n("\nIf checked, hides the quest from the map, even if it is active.\n\nHiding a quest is also possible by Shift-clicking it on the map."), 1, 1, 1, true)
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end)
    hideQuestCheckbox:SetCallback("OnLeave", function()
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end
    end)
    container:AddChild(hideQuestCheckbox)

    -- Generic Quest Information

    local questIdLabel = CreateLabel(Questie:Colorize(l10n("Quest ID") .. l10n(": "), 'yellow') .. quest.Id, true)
    container:AddChild(questIdLabel)

    local questLevel = QuestieLib.GetTbcLevel(quest.Id)
    local levelLabel = CreateLabel(Questie:Colorize(l10n("Quest Level") .. l10n(": "), 'yellow') .. questLevel, true)
    container:AddChild(levelLabel)

    -- We need to query this so we don't get wrong results for -1 type quests
    local requiredLevel = QuestieDB.QueryQuestSingle(quest.Id, "requiredLevel")
    local questDbLevel = QuestieDB.QueryQuestSingle(quest.Id, "questLevel")
    local minLevelLabel = CreateLabel(Questie:Colorize(l10n("Required Level") .. l10n(": "), 'yellow') .. requiredLevel, true)
    container:AddChild(minLevelLabel)

    -- Required Race
    local requiredRaces = QuestieDB.QueryQuestSingle(quest.Id, "requiredRaces")
    local reqRaces = QuestieLib:GetRaceString(requiredRaces)
    if (reqRaces ~= "") then
        local reqRacesLabel = CreateLabel(Questie:Colorize(l10n("Required Race") .. l10n(": "), 'yellow') .. reqRaces, true)
        container:AddChild(reqRacesLabel)
    end

    -- Required Class
    local requiredClasses = QuestieDB.QueryQuestSingle(quest.Id, "requiredClasses")
    local reqClasses = QuestieLib:GetClassString(requiredClasses)
    if (reqClasses ~= "") then
        local reqClassesLabel = CreateLabel(Questie:Colorize(l10n("Required Class") .. l10n(": "), 'yellow') .. reqClasses, true)
        container:AddChild(reqClassesLabel)
    end

    local levelDiffString = GetDifficultyString(questDbLevel, requiredLevel)
    local levelDiffLabel = CreateLabel(levelDiffString, true)
    container:AddChild(levelDiffLabel)

    local reputationRewardString = GetReputationRewardString(quest.Id)
    if reputationRewardString then
        local labelText = Questie:Colorize(l10n("Reputation Reward") .. l10n(": "), 'yellow') .. Questie:Colorize(reputationRewardString, "reputationBlue")
        local reputationRewardLabel = CreateLabel(labelText, true)
        container:AddChild(reputationRewardLabel)
    end

    local breadcrumbForQuestId = QuestieDB.QueryQuestSingle(quest.Id, "breadcrumbForQuestId")
    if breadcrumbForQuestId and breadcrumbForQuestId ~= 0 then
        local completedStatus = Questie.db.char.complete[quest.Id] and Questie:Colorize(YES, 'green') or Questie:Colorize(NO, 'red')
        local completedLabel = CreateLabel(Questie:Colorize(l10n("Completed") .. l10n(": "), 'yellow') .. completedStatus, true)
        container:AddChild(completedLabel)
    end

    if QuestieDB.IsRepeatable(quest.Id) then
        local repeatableLabel = CreateLabel(Questie:Colorize(l10n("Repeatable"), 'yellow'), true)
        container:AddChild(repeatableLabel)
    end

    local eligibilityText, shouldShowDoableLabel = QuestieDB.IsDoableVerbose(quest.Id, false, true, true)
    if shouldShowDoableLabel then
        local eligibilityTextLabel = CreateLabel(Questie:Colorize(l10n("Doable") .. l10n(": "), 'yellow') .. eligibilityText, true)
        container:AddChild(eligibilityTextLabel)
    end

    -- Pre Quests - two separate labeled sections
    if quest.preQuestSingle and next(quest.preQuestSingle) then
        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", quest.preQuestSingle, l10n("Requires one of these quests to be finished"), QuestieDB.QueryQuestSingle)
    end

    if quest.preQuestGroup and next(quest.preQuestGroup) then
        QuestieJourneyUtils:Spacer(container)
        AddLinkedParagraph(container, "quest", quest.preQuestGroup, l10n("Requires all of these quests to be finished"), QuestieDB.QueryQuestSingle)
    end

    QuestieJourneyUtils:Spacer(container)

    -- Get Quest Start NPC
    if quest.Starts and quest.Starts.NPC then
        local startNPCGroup = AceGUI:Create("InlineGroup")
        startNPCGroup:SetLayout("List")
        startNPCGroup:SetTitle(l10n("Quest Start NPC Information"))
        startNPCGroup:SetFullWidth(true)
        container:AddChild(startNPCGroup)

        QuestieJourneyUtils:Spacer(startNPCGroup)

        local startNpc = QuestieDB:GetNPC(quest.Starts.NPC[1])

        local startNPCNameLabel = CreateLabel(startNpc.name, true)
        startNPCNameLabel:SetFontObject(GameFontHighlight)
        startNPCNameLabel:SetColor(255, 165, 0)
        startNPCGroup:AddChild(startNPCNameLabel)

        local startNPCIdLabel = AceGUI:Create("Label")
        startNPCIdLabel:SetText(l10n("NPC ID").. l10n(": ") .. startNpc.id)
        startNPCIdLabel:SetFullWidth(true)
        startNPCGroup:AddChild(startNPCIdLabel)

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
            startNPCLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",startx) .." || Y" .. l10n(": ") .. string.format("%.2f",starty))
            startNPCLocLabel:SetFullWidth(true)
            startNPCGroup:AddChild(startNPCLocLabel)
        end

        local tomTomButton = CreateTomTomButton(startNpc.name, startindex, startx, starty)
        if tomTomButton then
            QuestieJourneyUtils:Spacer(startNPCGroup)
            startNPCGroup:AddChild(tomTomButton)
        end

        -- Also Starts
        if startNpc.questStarts and #startNpc.questStarts >= 2 then
            QuestieJourneyUtils:Spacer(startNPCGroup)

            local alsoStartsLabel = AceGUI:Create("Label")
            alsoStartsLabel:SetText(l10n('This NPC Also Starts the following quests:'))
            alsoStartsLabel:SetColor(255, 165, 0)
            alsoStartsLabel:SetFontObject(GameFontHighlight)
            alsoStartsLabel:SetFullWidth(true)
            startNPCGroup:AddChild(alsoStartsLabel)

            QuestieJourneyUtils:Spacer(startNPCGroup)
            for _, v in pairs(startNpc.questStarts) do
                if v ~= quest.Id then
                    local startQuest = QuestieDB.GetQuest(v)
                    local label = QuestieJourneyUtils.GetInteractiveQuestLabel(startQuest)
                    startNPCGroup:AddChild(label)
                end
            end
        end
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

            local startObjectIdLabel = AceGUI:Create("Label")
            startObjectIdLabel:SetText(l10n("Object ID") .. l10n(": ") .. startObj.id)
            startObjectIdLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectIdLabel)

            local startObjectZoneLabel = AceGUI:Create("Label")
            local startindex = 0
            for i in pairs(startObj.spawns) do
                startindex = i
            end

            local continent = QuestieJourneyUtils:GetZoneName(startindex)

            startObjectZoneLabel:SetText(l10n(continent))
            startObjectZoneLabel:SetFullWidth(true)
            startObjectGroup:AddChild(startObjectZoneLabel)

            local startx = startObj.spawns[startindex][1][1]
            local starty = startObj.spawns[startindex][1][2]
            if (startx ~= -1 or starty ~= -1) then
                local startObjectLocLabel = AceGUI:Create("Label")
                startObjectLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",startx) .." || Y" .. l10n(": ") .. string.format("%.2f",starty))
                startObjectLocLabel:SetFullWidth(true)
                startObjectGroup:AddChild(startObjectLocLabel)
            end

            local tomTomButton = CreateTomTomButton(startObj.name, startindex, startx, starty)
            if tomTomButton then
                QuestieJourneyUtils:Spacer(startObjectGroup)
                startObjectGroup:AddChild(tomTomButton)
            end

            -- Also Starts
            if startObj.questStarts and #startObj.questStarts >= 2 then
                QuestieJourneyUtils:Spacer(startObjectGroup)

                local alsoStartsLabel = AceGUI:Create("Label")
                alsoStartsLabel:SetText(l10n('This Object Also Starts the following quests:'))
                alsoStartsLabel:SetColor(255, 165, 0)
                alsoStartsLabel:SetFontObject(GameFontHighlight)
                alsoStartsLabel:SetFullWidth(true)
                startObjectGroup:AddChild(alsoStartsLabel)

                QuestieJourneyUtils:Spacer(startObjectGroup)
                for _, v in pairs(startObj.questStarts) do
                    if v ~= quest.Id then
                        local startQuest = QuestieDB.GetQuest(v)
                        local label = QuestieJourneyUtils.GetInteractiveQuestLabel(startQuest)
                        startObjectGroup:AddChild(label)
                    end
                end
            end
        end
    end

    -- Get Quest Start Item
    if quest.Starts and quest.Starts.Item then
        local startItemGroup = AceGUI:Create("InlineGroup")
        startItemGroup:SetLayout("List")
        startItemGroup:SetTitle(l10n('Quest Start Item Information'))
        startItemGroup:SetFullWidth(true)
        container:AddChild(startItemGroup)

        QuestieJourneyUtils:Spacer(startItemGroup)

        local startItem = QuestieDB:GetItem(quest.Starts.Item[1])

        local startItemNameLabel = AceGUI:Create("Label")
        startItemNameLabel:SetText(startItem.name)
        startItemNameLabel:SetFontObject(GameFontHighlight)
        startItemNameLabel:SetColor(255, 165, 0)
        startItemNameLabel:SetFullWidth(true)
        startItemGroup:AddChild(startItemNameLabel)

        local startItemIdLabel = AceGUI:Create("Label")
        startItemIdLabel:SetText(l10n("Item ID") .. l10n(": ") .. startItem.Id)
        startItemIdLabel:SetFullWidth(true)
        startItemGroup:AddChild(startItemIdLabel)
    end

    QuestieJourneyUtils:Spacer(container)

    if quest.Finisher.NPC then
        local endNPCGroup = AceGUI:Create("InlineGroup")
        endNPCGroup:SetLayout("List")
        endNPCGroup:SetTitle(l10n('Quest Turn-in NPC Information'))
        endNPCGroup:SetFullWidth(true)
        container:AddChild(endNPCGroup)

        QuestieJourneyUtils:Spacer(endNPCGroup)

        for i, npcId in ipairs(quest.Finisher.NPC) do
            if i > 1 then
                QuestieJourneyUtils:Spacer(endNPCGroup)
            end

            local endNPC = QuestieDB:GetNPC(npcId)

            local endNPCNameLabel = AceGUI:Create("Label")
            endNPCNameLabel:SetText(endNPC.name)
            endNPCNameLabel:SetFontObject(GameFontHighlight)
            endNPCNameLabel:SetColor(255, 165, 0)
            endNPCNameLabel:SetFullWidth(true)
            endNPCGroup:AddChild(endNPCNameLabel)

            local endNPCIdLabel = AceGUI:Create("Label")
            endNPCIdLabel:SetText(l10n("NPC ID") .. l10n(": ") .. endNPC.id)
            endNPCIdLabel:SetFullWidth(true)
            endNPCGroup:AddChild(endNPCIdLabel)

            if endNPC.spawns then
                local endNPCZoneLabel = AceGUI:Create("Label")
                local endindex = 0
                for zone in pairs(endNPC.spawns) do
                    endindex = zone
                end

                local continent = QuestieJourneyUtils:GetZoneName(endindex)

                endNPCZoneLabel:SetText(l10n(continent))
                endNPCZoneLabel:SetFullWidth(true)
                endNPCGroup:AddChild(endNPCZoneLabel)

                if next(endNPC.spawns) then
                    local endx = endNPC.spawns[endindex][1][1]
                    local endy = endNPC.spawns[endindex][1][2]
                    if (endx ~= -1 or endy ~= -1) then
                        local endNPCLocLabel = AceGUI:Create("Label")
                        endNPCLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",endx) .." || Y" .. l10n(": ") .. string.format("%.2f",endy))
                        endNPCLocLabel:SetFullWidth(true)
                        endNPCGroup:AddChild(endNPCLocLabel)
                    end

                    local tomTomButton = CreateTomTomButton(endNPC.name, endindex, endx, endy)
                    if tomTomButton then
                        QuestieJourneyUtils:Spacer(endNPCGroup)
                        endNPCGroup:AddChild(tomTomButton)
                    end
                end
            end

            -- Also ends
            if endNPC.questEnds and #endNPC.questEnds >= 2 then
                QuestieJourneyUtils:Spacer(endNPCGroup)

                local alsoEndsLabel = AceGUI:Create("Label")
                alsoEndsLabel:SetText(l10n('This NPC Also Completes the following quests:'))
                alsoEndsLabel:SetFontObject(GameFontHighlight)
                alsoEndsLabel:SetColor(255, 165, 0)
                alsoEndsLabel:SetFullWidth(true)
                endNPCGroup:AddChild(alsoEndsLabel)

                QuestieJourneyUtils:Spacer(endNPCGroup)
                for _, v in ipairs(endNPC.questEnds) do
                    if v ~= quest.Id then
                        local endQuest = QuestieDB.GetQuest(v)
                        local label = QuestieJourneyUtils.GetInteractiveQuestLabel(endQuest)
                        endNPCGroup:AddChild(label)
                    end
                end
            end
        end

        QuestieJourneyUtils:Spacer(endNPCGroup)

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        container.content:SetHeight(10000)
    end

    if quest.Finisher.GameObject then
        local endObjectGroup = AceGUI:Create("InlineGroup")
        endObjectGroup:SetLayout("List")
        endObjectGroup:SetTitle(l10n('Quest Turn-in Object Information'))
        endObjectGroup:SetFullWidth(true)
        container:AddChild(endObjectGroup)

        QuestieJourneyUtils:Spacer(endObjectGroup)

        for i, objectId in ipairs(quest.Finisher.GameObject) do
            if i > 1 then
                QuestieJourneyUtils:Spacer(endObjectGroup)
            end

            local endObject = QuestieDB:GetObject(objectId)

            local endObjectNameLabel = AceGUI:Create("Label")
            endObjectNameLabel:SetText(endObject.name)
            endObjectNameLabel:SetFontObject(GameFontHighlight)
            endObjectNameLabel:SetColor(255, 165, 0)
            endObjectNameLabel:SetFullWidth(true)
            endObjectGroup:AddChild(endObjectNameLabel)

            local endObjectIdLabel = AceGUI:Create("Label")
            endObjectIdLabel:SetText(l10n("Object ID") .. l10n(": ") .. endObject.id)
            endObjectIdLabel:SetFullWidth(true)
            endObjectGroup:AddChild(endObjectIdLabel)

            if endObject.spawns then
                local endObjectZoneLabel = AceGUI:Create("Label")
                local endindex = 0
                for zone in pairs(endObject.spawns) do
                    endindex = zone
                end

                local continent = QuestieJourneyUtils:GetZoneName(endindex)

                endObjectZoneLabel:SetText(l10n(continent))
                endObjectZoneLabel:SetFullWidth(true)
                endObjectGroup:AddChild(endObjectZoneLabel)

                if next(endObject.spawns) then
                    local endx = endObject.spawns[endindex][1][1]
                    local endy = endObject.spawns[endindex][1][2]
                    if (endx ~= -1 or endy ~= -1) then
                        local endObjectLocLabel = AceGUI:Create("Label")
                        endObjectLocLabel:SetText("X" .. l10n(": ") .. string.format("%.2f",endx) .." || Y" .. l10n(": ") .. string.format("%.2f",endy))
                        endObjectLocLabel:SetFullWidth(true)
                        endObjectGroup:AddChild(endObjectLocLabel)
                    end

                    local tomTomButton = CreateTomTomButton(endObject.name, endindex, endx, endy)
                    if tomTomButton then
                        QuestieJourneyUtils:Spacer(endObjectGroup)
                        endObjectGroup:AddChild(tomTomButton)
                    end
                end
            end

            -- Also ends
            if endObject.questEnds and #endObject.questEnds >= 2 then
                QuestieJourneyUtils:Spacer(endObjectGroup)

                local alsoEndsLabel = AceGUI:Create("Label")
                alsoEndsLabel:SetText(l10n('This Object Also Completes the following quests:'))
                alsoEndsLabel:SetFontObject(GameFontHighlight)
                alsoEndsLabel:SetColor(255, 165, 0)
                alsoEndsLabel:SetFullWidth(true)
                endObjectGroup:AddChild(alsoEndsLabel)

                QuestieJourneyUtils:Spacer(endObjectGroup)
                for _, v in ipairs(endObject.questEnds) do
                    if v ~= quest.Id then
                        local endQuest = QuestieDB.GetQuest(v)
                        local label = QuestieJourneyUtils.GetInteractiveQuestLabel(endQuest)
                        endObjectGroup:AddChild(label)
                    end
                end
            end
        end

        QuestieJourneyUtils:Spacer(endObjectGroup)

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        container.content:SetHeight(10000)
    end

    if Questie.db.profile.debugEnabled then
        QuestieJourneyUtils:Spacer(container)
        QuestieJourneyUtils:AddLine(container, recurseTable(quest, QuestieDB.questKeys))
    end
end

return QuestDetailsFrame
