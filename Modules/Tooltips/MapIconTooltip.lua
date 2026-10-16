---@class MapIconTooltip
local MapIconTooltip = QuestieLoader:CreateModule("MapIconTooltip");
local _MapIconTooltip = {}
local tinsert = table.insert;

---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type TooltipLayout
local TooltipLayout = QuestieLoader:ImportModule("TooltipLayout")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestiePolygon
local QuestiePolygon = QuestieLoader:ImportModule("QuestiePolygon")

local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")
local GetCoinTextureString = C_CurrencyInfo.GetCoinTextureString or GetCoinTextureString


local REPUTATION_ICON_PATH = QuestieLib.AddonPath .. "Icons\\reputation.blp"
local REPUTATION_ICON_TEXTURE_SIZE = 14
local REPUTATION_ICON_TEXTURE = "|T" .. REPUTATION_ICON_PATH .. ":" .. REPUTATION_ICON_TEXTURE_SIZE .. ":" .. REPUTATION_ICON_TEXTURE_SIZE .. ":2:0|t"

local NEXT_QUEST_ICON_PATH = QuestieLib.AddonPath .. "Icons\\nextquest.blp"
local NEXT_QUEST_ICON_TEXTURE_SIZE = 16
local NEXT_QUEST_ICON_TEXTURE = "|T" .. NEXT_QUEST_ICON_PATH .. ":" .. NEXT_QUEST_ICON_TEXTURE_SIZE .. ":" .. NEXT_QUEST_ICON_TEXTURE_SIZE .. ":2:0|t"

local BREADCRUMB_QUEST_ICON_PATH = QuestieLib.AddonPath .. "Icons\\breadcrumbtooltip.png"
local BREADCRUMB_QUEST_ICON_TEXTURE_SIZE = 16
local BREADCRUMB_QUEST_ICON_TEXTURE = "|T" .. BREADCRUMB_QUEST_ICON_PATH .. ":" .. BREADCRUMB_QUEST_ICON_TEXTURE_SIZE .. ":" .. BREADCRUMB_QUEST_ICON_TEXTURE_SIZE .. ":2:0|t"

local lastTooltipShowTimestamp = GetTime()

-- Shown tooltips
-- MapIconTooltip alone keeps what each tooltip frame last showed for it. That state counts only while
-- its owner still holds the tooltip, so a frame that took the tooltip since needs no cleanup and is
-- never redrawn over. Owners ask GetOwner whether theirs still shows and end it with Release; Shift
-- redraws every one through Redraw.

---What a tooltip frame last showed for MapIconTooltip.
---@class MapIconTooltipShown
---@field owner Frame The frame it was shown for, which holds and anchors it.
---@field rebuild fun(tooltip: GameTooltip) Adds its rows to the cleared tooltip, reading Shift.

---@type table<GameTooltip, MapIconTooltipShown>
local shown = {}
---@type GameTooltip?
local minimapTooltip

---The tooltip map icon tooltips show on over the minimap, which hovers there use instead of GameTooltip:
---Forever's minimap takes GameTooltip every frame while the cursor is over it, for its blip tooltips
---(Minimap_OnUpdate in Blizzard_Minimap/Mainline/Minimap.lua). Each hover owns it with a frame of its
---own, so one hover ending never hides another's.
---@return GameTooltip
function MapIconTooltip.MinimapTooltip()
    minimapTooltip = minimapTooltip or CreateFrame("GameTooltip", "QuestieMinimapTooltip", UIParent, "GameTooltipTemplate")
    return minimapTooltip
end

-- helper function to format a label with a colon, respecting localization rules
---@param label string
---@return string
local function FormatLabelWithColon(label)
    local locale = GetLocale()
    if locale == "frFR" then
        return label .. " :"
    else
        return label .. ":"
    end
end

---The visible icons around a spot, as a hovered icon's tooltip lists them: those of the spot's zone within
---the cluster distance for the world map's type, or for the minimap's zoom.
---@param onMinimap boolean? Minimap icons instead of world map icons.
---@param areaId AreaId The spot's zone.
---@param x number Percent on the zone's map.
---@param y number
---@param keep IconFrame? Listed even while hidden or faded out: the hovered icon itself.
---@return IconFrame[]
function MapIconTooltip.IconsNear(onMinimap, areaId, x, y, keep)
    local maxDistCluster = 1
    if onMinimap then
        if _MapIconTooltip:IsMinimapInside() then
            maxDistCluster = 0.3 / (1 + Minimap:GetZoom())
        else
            maxDistCluster = 0.5 / (1 + Minimap:GetZoom())
        end
    elseif C_Map and C_Map.GetMapInfo then
        local mapInfo = C_Map.GetMapInfo(WorldMapFrame:GetMapID())
        if mapInfo then
            if (mapInfo.mapType == 0 or mapInfo.mapType == 1) then -- Cosmic or World
                maxDistCluster = 6
            elseif mapInfo.mapType == 2 then -- Continent
                maxDistCluster = 4
            end
        end
    end

    local icons = {}
    ---@param icon IconFrame
    local function consider(icon)
        if not icon.data then
            Questie.Error("[MapIconTooltip.IconsNear] A shown icon has no data, skipping it")
            return
        end
        -- Skip icons that are hidden (FakeHide'd or faded out), unless it's the hovered icon itself
        if icon ~= keep and (icon.hidden or icon.texture.a == 0) then
            return
        end
        if icon.x and icon.AreaID == areaId and QuestieLib:Maxdist(icon.x, icon.y, x, y) < maxDistCluster then
            icons[#icons + 1] = icon
        end
    end

    if onMinimap then
        for icon in pairs(HBDPins.activeMinimapPins) do
            consider(icon)
        end
    else
        for pin in HBDPins.worldmapProvider:GetMap():EnumeratePinsByTemplate("HereBeDragonsPinsTemplateQuestie") do
            consider(pin.icon)
        end
    end
    return icons
end

---Shows a hovered map icon's tooltip: the quests and notes of the icon, of the visible icons clustered
---around it on its map, and of the quest areas beneath it. An icon faded out shows nothing, and the
---icon's own tooltip shown less than 0.05 s ago is kept. It changes nothing but the tooltip:
---QuestieFrame.ApplyHoverHighlights starts the hover's effects.
---@param self IconFrame
---@param tooltip GameTooltip GameTooltip, or a private tooltip such as the gamepad's.
function MapIconTooltip.ShowOnTooltip(self, tooltip)
    local _, _, _, alpha = self.texture:GetVertexColor();
    if alpha == 0 then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[MapIconTooltip.ShowOnTooltip] Alpha of texture is 0, nothing to show")
        return
    end
    -- Only this icon's own tooltip is throttled; another owner's, such as a quest area's, is replaced.
    if GetTime() - lastTooltipShowTimestamp < 0.05 and tooltip:IsShown() and tooltip:IsOwned(self) then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[MapIconTooltip.ShowOnTooltip] Call has been too fast, not showing again")
        return
    end
    lastTooltipShowTimestamp = GetTime()

    -- FIXME: `data` can be nil here which leads to an error, will have to debug:
    -- https://discordapp.com/channels/263036731165638656/263040777658171392/627808795715960842
    -- happens when a note doesn't get removed after a quest has been finished, see #1170
    -- TODO: change how the logic works, so this [ObjectiveIndex?] can be nil
    -- it is nil on some notes like starters/finishers, because its for objectives. However, it needs to be an number here for duplicate checks
    if not self.data.ObjectiveIndex then
        self.data.ObjectiveIndex = 0
    end

    --for k,v in pairs(self.data.tooltip) do
    --Tooltip:AddLine(v);
    --end

    -- The hovered icon, the visible icons clustered around it and the icons of the areas beneath it share
    -- one tooltip.
    local tooltipIcons = MapIconTooltip.IconsNear(self.miniMapIcon, self.AreaID, self.x, self.y, self)
    local listed = {}
    for _, icon in ipairs(tooltipIcons) do listed[icon] = true end
    for _, icon in ipairs(QuestiePolygon.AreaIconsAt(self)) do
        if not listed[icon] then
            listed[icon] = true
            tooltipIcons[#tooltipIcons + 1] = icon
        end
    end
    MapIconTooltip.ShowForIcons(self, tooltipIcons, tooltip)
end

---Shows the map icon tooltip for exactly these icons, wherever they are and however faded, at the
---cursor. `owner` holds it until another frame takes the tooltip or `Release` ends it; Redraw renders
---it again meanwhile.
---@param owner Frame Holds the tooltip, which hides with it. Only a world map icon owner adds Journey's shift-click hint.
---@param icons IconFrame[] At least one icon with data. Objectives repeated across icons are listed once; while quest areas draw, each icon's own objective line starts with its area colour.
---@param tooltip GameTooltip
function MapIconTooltip.ShowForIcons(owner, icons, tooltip)
    tooltip:SetOwner(owner, "ANCHOR_CURSOR")

    local usedText = {}
    local npcAndObjectOrder = {};
    local questOrder = {};
    local manualOrder = {}
    for _, icon in ipairs(icons) do
        local iconData = icon.data
        if iconData.Type == "available" or iconData.Type == "complete" then
            if not npcAndObjectOrder[iconData.Name] then
                npcAndObjectOrder[iconData.Name] = {};
            end

            local tip = _MapIconTooltip:GetAvailableOrCompleteTooltip(icon)
            npcAndObjectOrder[iconData.Name][tip.title] = tip
        elseif iconData.ObjectiveData and iconData.ObjectiveData.Description then
            local key = iconData.Id
            if not questOrder[key] then
                questOrder[key] = {};
            end

            local orderedTooltips = {}
            iconData.ObjectiveData:Update()
            local tooltips = _MapIconTooltip:GetObjectiveTooltip(icon, QuestiePolygon.ObjectiveSwatch(icon))
            for _, tip in pairs(tooltips) do
                tinsert(orderedTooltips, 1, tip);
            end
            for _, tip in pairs(orderedTooltips) do
                local quest = questOrder[key]
                _MapIconTooltip:AddTooltipsForQuest(icon, tip, quest, usedText)
            end
        elseif iconData.ManualTooltipData then
            manualOrder[iconData.ManualTooltipData.Title] = iconData.ManualTooltipData
        end
    end

    tooltip.npcAndObjectOrder = npcAndObjectOrder
    tooltip.questOrder = questOrder
    tooltip.manualOrder = manualOrder
    tooltip.miniMapIcon = owner.miniMapIcon

    -- Texture indents are more robust than raw spaces in tooltip layout.
    -- Base indent is 6 UI units, then each deeper level scales by 1.5.
    local indent = 6 -- 6 UI units is around two spaces.
    local indentScale = 1.5
    local indentHalf, indentHalfWidth = TooltipLayout.CreateIndentUI(indent / 2) -- 3
    local indentTwo, indentTwoWidth = TooltipLayout.CreateIndentUI(indent * (indentScale ^ 1)) -- 9
    local indentThree = TooltipLayout.CreateIndentUI(indent * (indentScale ^ 2)) -- 13.5
    local indentSix = TooltipLayout.CreateIndentUI(indent * (indentScale ^ 3)) -- 20.25
    local indentReputation = TooltipLayout.CreateIndentUI(REPUTATION_ICON_TEXTURE_SIZE) -- 14
    local nextQuestLabelPrefix = indentTwo .. NEXT_QUEST_ICON_TEXTURE .. indentHalf -- Keep this in sync with nextQuestTitleIndent.
    local nextQuestTitleIndent = TooltipLayout.CreateIndentUI(indentTwoWidth + NEXT_QUEST_ICON_TEXTURE_SIZE + indentHalfWidth)
    local breadcrumbLabelPrefix = indentTwo .. BREADCRUMB_QUEST_ICON_TEXTURE .. indentHalf -- Keep this in sync with breadcrumbTitleIndent.
    local breadcrumbTitleIndent = TooltipLayout.CreateIndentUI(indentTwoWidth + BREADCRUMB_QUEST_ICON_TEXTURE_SIZE + indentHalfWidth)


    ---@param self GameTooltip
    local function rebuild(self)
        -- Build rows first so description wrapping cannot change the width used to wrap itself.
        local xpString = l10n("xp");
        local shift = IsShiftKeyDown()
        local haveGiver = false -- hack
        local firstLine = true;
        local tooltipRows = TooltipLayout:CreateRows()

        -- tooltips for quest icons on the map
        -- Givers by name, each with its quests by level. The entries were collected into tables, which
        -- pairs walks in no particular order, so the order would otherwise change with how they were collected.
        local giverNames = {}
        for name in pairs(self.npcAndObjectOrder) do giverNames[#giverNames + 1] = name end
        table.sort(giverNames)
        for _, npcOrObjectName in ipairs(giverNames) do -- this logic really needs to be improved
            local quests = self.npcAndObjectOrder[npcOrObjectName]
            haveGiver = true
            if shift and (not firstLine) then
                -- Spacer between NPCs
                tooltipRows:AddLine("             ")
            end
            if (firstLine and not shift) then
                tooltipRows:AddDoubleLine(npcOrObjectName, l10n("(") .. l10n("Hold Shift") .. l10n(")"), 0.2, 1, 0.2, 0.43, 0.43, 0.43);
                firstLine = false;
            elseif (firstLine and shift) then
                tooltipRows:AddLine(npcOrObjectName, 0.2, 1, 0.2);
                firstLine = false;
            else
                tooltipRows:AddLine(npcOrObjectName, 0.2, 1, 0.2);
            end

            -- A giver's quests are keyed by title; sorting by level needs them by quest ID.
            local questsById = {}
            for _, questData in pairs(quests) do questsById[questData.questId] = questData end
            for _, questId in ipairs(QuestieLib:SortQuestIDsByLevel(questsById, true)) do
                local questData = questsById[questId]
                local reputationReward = QuestieReputation.GetReputationReward(questData.questId)

                if questData.title ~= nil then
                    local quest = QuestieDB.GetQuest(questData.questId)
                    local rewardString = ""
                    if (quest and shift) then
                        local xpReward = QuestXP:GetQuestLogRewardXP(questData.questId, Questie.db.profile.showQuestXpAtMaxLevel)
                        if xpReward > 0 then
                            rewardString = QuestieLib:PrintDifficultyColor(quest.level, l10n("(") .. FormatLargeNumber(xpReward) .. xpString .. l10n(")") .. " ",
                                QuestieDB.IsRepeatable(questData.questId), QuestieEvent.IsEventQuest(questData.questId), QuestieDB.IsPvPQuest(questData.questId), questData.questId)
                        end

                        local moneyReward = QuestXP.GetQuestRewardMoney(questData.questId)
                        if moneyReward > 0 then
                            rewardString = rewardString .. Questie:Colorize(l10n("(") .. GetCoinTextureString(moneyReward) .. l10n(")") .. " ", "white")
                        end
                    end
                    rewardString = rewardString .. questData.type

                    if (not shift) and next(reputationReward) then
                        tooltipRows:AddDoubleLine(REPUTATION_ICON_TEXTURE .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                    else
                        if shift then
                            tooltipRows:AddDoubleLine(questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                        else
                            -- We indent the same width as the reputation icon
                            tooltipRows:AddDoubleLine(indentReputation .. " " .. questData.title, rewardString, 1, 1, 1, 1, 1, 0);
                        end
                    end
                    -- Add dungeon information if this is a dungeon quest
                    if shift and quest then
                        local zoneOrSort = quest.zoneOrSort
                        if zoneOrSort and zoneOrSort > 0 then
                            local localizedDungeonName = ZoneDB:GetLocalizedDungeonName(zoneOrSort)
                            if localizedDungeonName then
                                tooltipRows:AddLine(indentTwo .. FormatLabelWithColon(l10n("Instance")) .. " " .. localizedDungeonName, 0.7, 0.7, 0.7)
                            end
                        end
                    end
                end
                if questData.subData and shift then
                    local dataType = type(questData.subData)
                    if dataType == "table" then
                        for _, rawLine in pairs(questData.subData) do
                            tooltipRows:AddDescription(rawLine, indentTwo, 0.86, 0.86, 0.86);
                        end
                    elseif dataType == "string" then
                        tooltipRows:AddDescription(questData.subData, indentTwo, 0.86, 0.86, 0.86);
                    end
                end

                if shift and next(reputationReward) then
                    local rewardString = QuestieReputation.GetReputationRewardString(reputationReward)
                    -- Apply color through AddLine args so description wrapping cannot split color escape sequences.
                    tooltipRows:AddDescription(REPUTATION_ICON_TEXTURE .. " " .. rewardString, indentTwo, Questie:ColorizeRGB("reputationBlue"))
                end
                
                if shift and Questie.db.profile.enableTooltipsBreadcrumbQuests then
                    local breadcrumbs = QuestieDB.QueryQuestSingle(questData.questId, "breadcrumbs")
                    if breadcrumbs then
                        local firstBreadcrumb = true
                        local exclusiveQuestCompleted = false
                        for _, breadcrumbId in ipairs(breadcrumbs) do
                            local exclusiveQuests = QuestieDB.QueryQuestSingle(breadcrumbId, "exclusiveTo")
                            if exclusiveQuests then
                                for _, exclusiveQuestId in pairs(exclusiveQuests) do
                                    if Questie.db.char.complete[exclusiveQuestId] or QuestiePlayer.currentQuestlog[exclusiveQuestId] then
                                        exclusiveQuestCompleted = true
                                        break
                                    end
                                end
                            end
                        end
                        for _, breadcrumbId in ipairs(breadcrumbs) do
                            local requiredRaces = QuestieDB.QueryQuestSingle(breadcrumbId, "requiredRaces")
                            local requiredClasses = QuestieDB.QueryQuestSingle(breadcrumbId, "requiredClasses")
                            local availableUntilCompleted = QuestieDB.QueryQuestSingle(breadcrumbId, "availableUntilCompleted")
                            if (not QuestieCorrections.hiddenQuests[breadcrumbId]) and (not Questie.db.char.complete[breadcrumbId]) and
                                QuestiePlayer.HasRequiredRace(requiredRaces) and QuestiePlayer.HasRequiredClass(requiredClasses) and
                                (not exclusiveQuestCompleted) and (not Questie.db.char.complete[availableUntilCompleted]) then
                                if firstBreadcrumb then
                                    tooltipRows:AddLine(breadcrumbLabelPrefix .. l10n("Breadcrumb Quests") .. l10n(": "), 0.86, 0.86, 0.86)
                                    firstBreadcrumb = false
                                end
                                local breadcrumbLevel, _ = QuestieLib.GetEffectiveQuestLevel(breadcrumbId)
                                local questTitle, rewardString = _MapIconTooltip.GetNextQuestInChainLines(breadcrumbId, breadcrumbLevel, breadcrumbTitleIndent)
                                tooltipRows:AddDoubleLine(questTitle, rewardString, 1, 1, 1)
                            end
                        end
                    end
                end

                if shift and Questie.db.profile.enableTooltipsNextInChain then
                    local DoableStates = QuestieDB.DoableStates
                    local nextQuestId = QuestieDB.QueryQuestSingle(questData.questId, "nextQuestInChain")
                    if nextQuestId > 0 and (not QuestieCorrections.hiddenQuests[nextQuestId]) then
                        local _, _, returnReason = QuestieDB.IsDoableVerbose(nextQuestId, false, true, true)
                        local firstInChain = true;
                        while nextQuestId ~= nil and (not QuestieCorrections.hiddenQuests[nextQuestId]) and (returnReason ~= DoableStates.WRONG_RACE and returnReason ~= DoableStates.WRONG_CLASS and returnReason ~= DoableStates.PROFESSION_MISSING) do
                            if firstInChain then
                                tooltipRows:AddLine(nextQuestLabelPrefix .. l10n("Next in chain") .. l10n(": "), 0.86, 0.86, 0.86)
                                firstInChain = false
                            end
                            local nextQuestLevel, _ = QuestieLib.GetEffectiveQuestLevel(nextQuestId)
                            local questTitle, rewardString = _MapIconTooltip.GetNextQuestInChainLines(nextQuestId, nextQuestLevel, nextQuestTitleIndent)
                            tooltipRows:AddDoubleLine(questTitle, rewardString, 1, 1, 1)

                            local nextNextQuestId = QuestieDB.QueryQuestSingle(nextQuestId, "nextQuestInChain")
                            if nextNextQuestId > 0 then
                                nextQuestId = nextNextQuestId
                            else
                                break
                            end
                        end
                    end
                end
            end
        end

        -- tooltips for objectives of active quests, by quest level
        for _, questId in ipairs(QuestieLib:SortQuestIDsByLevel(self.questOrder, true)) do -- this logic really needs to be improved
            local textList = self.questOrder[questId]
            ---@type Quest
            local quest = QuestieDB.GetQuest(questId);
            local questTitle = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true);
            local xpReward = QuestXP:GetQuestLogRewardXP(questId, Questie.db.profile.showQuestXpAtMaxLevel) or 0
            local rewardString = xpReward > 0 and
                QuestieLib:PrintDifficultyColor(quest.level, l10n("(") .. FormatLargeNumber(xpReward) .. xpString .. l10n(")") .. " ",
                    QuestieDB.IsRepeatable(questId), QuestieEvent.IsEventQuest(questId), QuestieDB.IsPvPQuest(questId), questId) or ""
            if haveGiver then
                if shift and xpReward > 0 then
                    tooltipRows:AddLine(" ");
                    tooltipRows:AddDoubleLine(questTitle, rewardString .. l10n("(") .. l10n("Active") .. l10n(")"), 0.2, 1, 0.2, 1, 1, 0);
                    haveGiver = false -- looks better when only the first one shows (active)
                else
                    tooltipRows:AddLine(" ");
                    tooltipRows:AddDoubleLine(questTitle, l10n("(") .. l10n("Active") .. l10n(")"), 1, 1, 1, 1, 1, 0);
                    haveGiver = false -- looks better when only the first one shows (active)
                end
            else
                if (quest and shift and xpReward > 0) then
                    tooltipRows:AddDoubleLine(questTitle, rewardString, 0.2, 1, 0.2, 1, 0, 1); -- magenta to spot any missing text color
                    firstLine = false;
                elseif (firstLine and not shift) then
                    tooltipRows:AddDoubleLine(questTitle, l10n("(") .. l10n("Hold Shift") .. l10n(")"), 0.2, 1, 0.2, 0.43, 0.43, 0.43); --"(Shift+click)"
                    firstLine = false;
                else
                    tooltipRows:AddLine(questTitle);
                end
            end

            -- Used to get the white color for the quests which don't have anything to collect
            local defaultQuestColor = QuestieLib:GetRGBForObjective({})

            -- Add what dungeon this is in if this is a dungeon quest
            if shift and quest then
                local zoneOrSort = quest.zoneOrSort
                if zoneOrSort and zoneOrSort > 0 then
                    local localizedDungeonName = ZoneDB:GetLocalizedDungeonName(zoneOrSort)
                    if localizedDungeonName then
                        tooltipRows:AddLine(indentTwo .. FormatLabelWithColon(l10n("Instance")) .. " " .. localizedDungeonName, 0.7, 0.7, 0.7)
                    end
                end
            end

            if shift then
                local creatureLevels = QuestieDB:GetCreatureLevels(quest) -- Data for min and max level
                local addedCreatureNames = {}
                for _, textData in pairs(textList) do
                    for textLine, nameData in pairs(textData) do
                        local dataType = type(nameData)
                        if dataType == "table" then
                            for name in pairs(nameData) do
                                if (not addedCreatureNames[name]) then
                                    addedCreatureNames[name] = true
                                    name = _MapIconTooltip.GetLevelString(creatureLevels, name)
                                    tooltipRows:AddLine(indentThree .. "|cFFDDDDDD" .. name);
                                end
                            end
                        elseif dataType == "string" and (not addedCreatureNames[nameData]) then
                            addedCreatureNames[nameData] = true
                            nameData = _MapIconTooltip.GetLevelString(creatureLevels, nameData)
                            tooltipRows:AddLine(indentThree .. "|cFFDDDDDD" .. nameData);
                        end
                        tooltipRows:AddLine(indentSix .. defaultQuestColor .. textLine);
                    end
                end
            else
                for _, textData in pairs(textList) do
                    for textLine, _ in pairs(textData) do
                        tooltipRows:AddLine(indentThree .. defaultQuestColor .. textLine);
                    end
                end
            end
        end

        if next(self.npcAndObjectOrder) and next(self.manualOrder) then
            -- Spacer before townsfolk
            tooltipRows:AddLine("             ")
        end

        -- Manually activated icons through Journey
        for title, data in pairs(self.manualOrder) do
            local body = data.Body
            tooltipRows:AddLine(title)
            for _, stringOrTable in ipairs(body) do
                local dataType = type(stringOrTable)
                if dataType == "string" then
                    tooltipRows:AddLine(stringOrTable)
                elseif dataType == "table" then
                    tooltipRows:AddDoubleLine(stringOrTable[1], "|cFFffffff" .. stringOrTable[2] .. "|r") --normal, white
                end
            end
            if self.miniMapIcon == false and not data.disableShiftToRemove then
                tooltipRows:AddLine(Questie:Colorize(l10n("Shift-click to hide"), "gray")) -- gray
            end
        end

        -- Measure fixed rows, expand descriptions, then render once to avoid dynamic width feedback.
        TooltipLayout:Render(self, tooltipRows)
    end
    shown[tooltip] = {owner = owner, rebuild = rebuild}
    rebuild(tooltip)
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:Show()
end

---Ends the map icon tooltip shown for `owner`: hides the tooltip while `owner` still holds it, and
---stops Redraw from rendering it. A map icon tooltip shown since for another frame, and any other
---tooltip `owner` holds, such as another addon's for the map, are left alone.
---@param owner Frame
---@param tooltip GameTooltip
function MapIconTooltip.Release(owner, tooltip)
    local state = shown[tooltip]
    if not (state and state.owner == owner) then return end
    shown[tooltip] = nil
    if tooltip:IsOwned(owner) then tooltip:Hide() end
end

---The frame a map icon tooltip shows for on `tooltip`, while that frame still holds it. Answers both
---"is a map icon tooltip showing" and, compared with a frame, "is mine still showing".
---@param tooltip GameTooltip
---@return Frame? owner nil while the tooltip is hidden, was released, or another frame took it.
function MapIconTooltip.GetOwner(tooltip)
    local state = shown[tooltip]
    if state and tooltip:IsShown() and tooltip:IsOwned(state.owner) then
        return state.owner
    end
end

---Renders every map icon tooltip still held by its owner again, at the same anchor: Shift changes
---the detail it shows.
function MapIconTooltip.Redraw()
    for tooltip, state in pairs(shown) do
        if tooltip:IsShown() and tooltip:IsOwned(state.owner) then
            -- The gamepad's tooltip sits ANCHOR_RIGHT, beside its cursor.
            local anchor = tooltip:GetAnchorType()
            tooltip:Hide()
            tooltip:ClearLines()
            tooltip:SetOwner(state.owner, anchor)
            state.rebuild(tooltip)
            tooltip:SetFrameStrata("TOOLTIP")
            tooltip:Show()
        end
    end
end

local isLastMinimapInside, lastMinimapInsideCheckTimestamp

function _MapIconTooltip:IsMinimapInside()
    if lastMinimapInsideCheckTimestamp and GetTime() - lastMinimapInsideCheckTimestamp < 1 then
        return isLastMinimapInside
    end
    local tempzoom = 0;
    if (GetCVar("minimapZoom") == GetCVar("minimapInsideZoom")) then
        if (GetCVar("minimapInsideZoom") + 0 >= 3) then
            Minimap:SetZoom(Minimap:GetZoom() - 1);
            tempzoom = 1;
        else
            Minimap:SetZoom(Minimap:GetZoom() + 1);
            tempzoom = -1;
        end
    end
    if (GetCVar("minimapInsideZoom") + 0 == Minimap:GetZoom()) then
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        isLastMinimapInside = true
        lastMinimapInsideCheckTimestamp = GetTime()
        return true
    else
        isLastMinimapInside = false
        lastMinimapInsideCheckTimestamp = GetTime()
        Minimap:SetZoom(Minimap:GetZoom() + tempzoom);
        return false
    end
end

--- Get the quest tag to display in the tooltip
---@param quest Quest
---@return string tag
local function _GetQuestTag(quest)
    if quest.Type == "complete" then
        return l10n("(") .. l10n("Complete") .. l10n(")");
    else
        local questTagId, questTagName = QuestieDB.GetQuestTagInfo(quest.Id)

        if (QuestieEvent and QuestieEvent.activeQuests[quest.Id]) then
            return l10n("(") .. l10n("Event") .. l10n(")");
        elseif (questTagId == 41) then
            if QuestieDB.IsDailyQuest(quest.Id) then
                return l10n("(") .. l10n("Daily PvP") .. l10n(")");
            end
            return l10n("(") .. l10n("PvP") .. l10n(")");
        elseif (questTagId == 102) then
            if QuestieDB.IsWeeklyQuest(quest.Id) then
                return l10n("(") .. l10n("Weekly Account") .. l10n(")");
            elseif QuestieDB.IsDailyQuest(quest.Id) then
                return l10n("(") .. l10n("Daily Account") .. l10n(")");
            end
            return l10n("(") .. l10n("Account") .. l10n(")");
        elseif (QuestieDB.IsWeeklyQuest(quest.Id)) then
            -- These show as "Raid"
            if questTagId == 62 then
                return l10n("(") .. (RAID or l10n("Raid")) .. l10n(")");
            end
            return l10n("(") .. (WEEKLY or l10n("Weekly")) .. l10n(")");
        elseif (QuestieDB.IsMonthlyQuest(quest.Id)) then
            return l10n("(") .. (l10n("Monthly")) .. l10n(")");
        elseif (QuestieDB.IsDailyQuest(quest.Id)) then
            if questTagId == 81 then
                return l10n("(") .. l10n("Daily Dungeon") .. l10n(")");
            elseif questTagId == 85 then
                return l10n("(") .. l10n("Daily Heroic") .. l10n(")");
            elseif questTagId == 294 then
                return l10n("(") .. l10n("Daily Celestial") .. l10n(")");
            end
            return l10n("(") .. (DAILY or l10n("Daily")) .. l10n(")");
        elseif (QuestieDB.IsRepeatable(quest.Id)) then
            return l10n("(") .. l10n("Repeatable") .. l10n(")");
            --  Group(Elite)       Class               Raid                Dungeon             World Event         Legendary           Escort              Heroic              Raid(10)            Raid(25)            Scenario            Celestial
        elseif (questTagId == 1 or questTagId == 21 or questTagId == 62 or questTagId == 81 or questTagId == 82 or questTagId == 83 or questTagId == 84 or questTagId == 85 or questTagId == 88 or questTagId == 89 or questTagId == 98 or questTagId == 294) then
            return l10n("(") .. questTagName .. l10n(")");
        elseif (Questie.IsSoD and QuestieDB.IsSoDRuneQuest(quest.Id)) then
            return l10n("(") .. l10n("Rune") .. l10n(")");
        else
            return l10n("(") .. l10n("Available") .. l10n(")");
        end
    end
end

function _MapIconTooltip:GetAvailableOrCompleteTooltip(icon)
    local tip = {};
    tip.type = _GetQuestTag(icon.data)
    tip.title = QuestieLib:GetColoredQuestName(icon.data.Id, Questie.db.profile.enableTooltipsQuestLevel, false)
    tip.subData = icon.data.QuestData.Description
    tip.questId = icon.data.Id;

    return tip
end

---@param icon IconFrame
---@param prefix string? Placed before the local objective line.
function _MapIconTooltip:GetObjectiveTooltip(icon, prefix)
    local tooltips = {}
    local iconData = icon.data
    -- Local wording comes from the accepted cache. Party-only objectives carry validated API wording
    -- from their loading path; it is a template for remote progress, never a local progress line.
    local objective = iconData.ObjectiveData
    local cached = QuestLogCache.TryGetQuest(iconData.Id)
    local native = cached and not objective.IsPartyObjective and not objective.IsSourceItem and not objective.IsRequiredSourceItem
        and cached.objectives[iconData.ObjectiveIndex]
    local nativeText = native and native.text or objective.NativeText
    local text = objective.Description or ""
    local color = QuestieLib:GetRGBForObjective(objective)
    if native then
        text = color .. native.text
    elseif iconData.ObjectiveData.Needed then
        if iconData.ObjectiveData.Type == "spell" and iconData.ObjectiveData.spawnList[iconData.ObjectiveTargetId].ItemId then
            text = color .. tostring(QuestieDB.QueryItemSingle(iconData.ObjectiveData.spawnList[iconData.ObjectiveTargetId].ItemId, "name"))
        else
            text = color .. tostring(iconData.ObjectiveData.Collected) .. "/" .. tostring(iconData.ObjectiveData.Needed) .. " " .. text
        end
    end
    if QuestieComms then
        local anotherPlayer = false;
        local quest = QuestieComms:GetQuest(iconData.Id)
        if quest then
            for playerName, objectiveData in pairs(quest) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName)
                local playerColor
                local playerType = ""
                if playerInfo then
                    playerColor = "|c" .. playerInfo.colorHex
                else
                    playerColor = QuestieComms.remotePlayerClasses[playerName]
                    if playerColor then
                        playerColor = Questie:GetClassColor(playerColor)
                        playerType = " " .. l10n("(") .. l10n("Nearby") .. l10n(")")
                    end
                end
                if not playerColor then
                    -- We have this player's objective data but can't resolve their class;
                    -- show the name anyway instead of silently dropping the line.
                    playerColor = "|cFFCCCCCC"
                end
                if playerColor then
                    local objectiveEntry = objectiveData[iconData.ObjectiveIndex]
                    if not objectiveEntry then
                        Questie.Debug(Questie.DEBUG_DEVELOP, "[_MapIconTooltip:GetObjectiveTooltip] No objective data for quest", quest.Id)
                        objectiveEntry = {} -- This will make "GetRGBForObjective" return default color
                    end
                    local remoteColor = QuestieLib:GetRGBForObjective(objectiveEntry)
                    local colorizedPlayerName = " " .. l10n("(") .. playerColor .. playerName .. "|r" .. remoteColor .. l10n(")") .. "|r" .. playerType
                    local remoteText = objective.Description or ""

                    if objectiveEntry and objectiveEntry.fulfilled and objectiveEntry.required then
                        local fulfilled = objectiveEntry.fulfilled;
                        local required = objectiveEntry.required;
                        local replacedText = QuestieLib.ReplaceObjectiveTextProgress(nativeText, fulfilled, required)
                        remoteText = remoteColor .. (replacedText or (tostring(fulfilled) .. "/" .. tostring(required) .. " " .. remoteText))
                            .. colorizedPlayerName
                    else
                        remoteText = remoteColor .. remoteText .. colorizedPlayerName;
                    end
                    local partyMemberTip = {
                        [remoteText] = {},
                    }
                    for _, name in ipairs(iconData.Names or {iconData.Name}) do
                        partyMemberTip[remoteText][name] = true
                    end
                    tinsert(tooltips, partyMemberTip);
                    anotherPlayer = true;
                end
            end
            -- Don't label the objective with the local player's name when it belongs to a
            -- party member and the local player doesn't have the quest themselves.
            if anotherPlayer and (not iconData.ObjectiveData.IsPartyObjective) then
                local name = GetUnitName("player", true);
                local playerClass = UnitClassBase("player")
                local _, _, _, argbHex = GetClassColor(playerClass)
                name = " " .. l10n("(") .. "|c" .. argbHex .. name .. "|r" .. color .. l10n(")") .. "|r";
                text = text .. name;
            end
        end
    end

    -- For a party member's objective the local player doesn't have, skip the unattributed
    -- objective line; the per-player lines above already cover it. Keep it as a fallback if
    -- no party lines were added, so the tooltip is never empty.
    if (not iconData.ObjectiveData.IsPartyObjective) or (#tooltips == 0) then
        text = (prefix or "") .. text
        local t = {
            [text] = {},
        }
        for _, name in ipairs(iconData.Names or {iconData.Name}) do
            t[text][name] = true
        end
        tinsert(tooltips, 1, t);
    end
    return tooltips
end

function _MapIconTooltip:AddTooltipsForQuest(icon, tip, quest, usedText)
    for text, nameTable in pairs(tip) do
        local data = {}
        data[text] = nameTable
        -- Add the data for the first time
        if not usedText[icon.data.Id] then
            usedText[icon.data.Id] = {
                [text] = true
            }
            tinsert(quest, data)
            -- add another line to an existing entry
        elseif not usedText[icon.data.Id][text] then
            tinsert(quest, data)
            usedText[icon.data.Id][text] = true
        else
            --We want to add more NPCs as possible candidates when shift is pressed.
            if icon.data.Name then
                for dataIndex, _ in pairs(quest) do
                    if quest[dataIndex][text] then
                        quest[dataIndex][text][icon.data.Name] = true;
                    end
                end
            end
        end
    end
end

---@param creatureLevels table<string, table<number, number, number>>
---@param name string
---@return string
function _MapIconTooltip.GetLevelString(creatureLevels, name)
    local levelString = name
    if creatureLevels[name] then
        local minLevel = creatureLevels[name][1]
        local maxLevel = creatureLevels[name][2]
        local rank = creatureLevels[name][3]
        if minLevel == maxLevel then
            levelString = name .. " " .. l10n("(") .. minLevel
        else
            levelString = name .. " " .. l10n("(") .. minLevel .. "-" .. maxLevel
        end

        if rank and rank == 1 then
            levelString = levelString .. "+"
        end

        levelString = levelString .. l10n(")")
    end
    return levelString
end

---@param questId QuestId
---@param questLevel number
---@param indent string
---@return string, string
function _MapIconTooltip.GetNextQuestInChainLines(questId, questLevel, indent)
    local questTitle = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false);

    local nextQuestXpRewardString = "";
    local xpReward = QuestXP:GetQuestLogRewardXP(questId, Questie.db.profile.showQuestXpAtMaxLevel)
    if xpReward > 0 then
        nextQuestXpRewardString = QuestieLib:PrintDifficultyColor(questLevel, l10n("(") .. FormatLargeNumber(xpReward) .. l10n("xp") .. l10n(")") .. " ",
            QuestieDB.IsRepeatable(questId), QuestieEvent.IsEventQuest(questId), QuestieDB.IsPvPQuest(questId), questId)
    end

    local nextQuestMoneyRewardString = "";
    local moneyReward = QuestXP.GetQuestRewardMoney(questId)
    if moneyReward > 0 then
        nextQuestMoneyRewardString = Questie:Colorize(l10n("(") .. GetCoinTextureString(moneyReward) .. l10n(")") .. " ", "white")
    end

    return indent .. questTitle, nextQuestXpRewardString .. nextQuestMoneyRewardString
end
