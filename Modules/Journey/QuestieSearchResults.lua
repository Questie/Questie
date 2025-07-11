---@class QuestieSearchResults
local QuestieSearchResults = QuestieLoader:CreateModule("QuestieSearchResults")
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local GetItemInfo = C_Item.GetItemInfo or GetItemInfo
local stringrep = string.rep
local stringsub = string.sub

local AceGUI = LibStub("AceGUI-3.0");

local _HandleOnGroupSelected
local lastOpenSearch = "quest"
local _selected = 0

local BY_NAME = 1
local BY_ID = 2


local function AddParagraph(frame, lookupObject, secondKey, header, query)
    if lookupObject[secondKey] then
        QuestieJourneyUtils:AddLine(frame,  Questie:Colorize(header))
        for _,id in pairs(lookupObject[secondKey]) do
            local name = query(id, "name")
            if name then
                QuestieJourneyUtils:AddLine(frame, name.." ("..id..")")
            end
        end
    end
end

---Takes a frame and adds a paragraph with a header text and a list of links to other search results
---@param frame AceGUIWidget The frame to work on
---@param linkType string The type of result to link to (npc|object|quest|item)
---@param lookupObject table Table of IDs (npc|object|quest|item)
---@param header string The text header to show above the links
---@param query function The function used to get link name from
local function AddLinkedParagraph(frame, linkType, lookupObject, header, query)
    if lookupObject and #lookupObject > 0 then
        local group = AceGUI:Create("InlineGroup");
        group:SetFullWidth(true);
        group:SetLayout("flow");
        group:SetTitle(header);
        frame:AddChild(group);

        for _,id in pairs(lookupObject) do
            id = abs(id)
            local link = AceGUI:Create("InteractiveLabel")
            local name = query(id, "name")
            local text
            if linkType == 'quest' then
                text = QuestieLib:GetColoredQuestName(id,  true, true)
            elseif linkType == 'npc' then
                local lvl = query(id, 'maxLevel')
                text = QuestieLib:PrintDifficultyColor(lvl, '['..lvl..'] '..name..' ('..id..')')
            else
                text = name.." ("..id..")"
            end
            link:SetText(text);
            link:SetUserData("id", id)
            link:SetUserData("type", linkType)
            link:SetUserData("name", name)
            link:SetCallback("OnClick", function() QuestieSearchResults:SetSearch(linkType, id) end)
            link:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
            link:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)
            group:AddChild(link);
        end
    end
end

-- Create a button for showing/hiding manual notes of NPCs/objects
local function CreateShowHideButton(id)
    -- Initialise button
    local button = AceGUI:Create("Button")
    button.id = id
    if (not QuestieMap.manualFrames["any"]) or (not QuestieMap.manualFrames["any"][id]) then
        button:SetText(l10n("Show on Map"))
        button:SetCallback("OnClick", function(self) self:ShowOnMap(self) end)
    else
        button:SetText(l10n("Remove from Map"))
        button:SetCallback("OnClick", function(self) self:RemoveFromMap(self) end)
    end
    -- Functions for showing/hiding and switching behaviour afterwards
    button.RemoveFromMap = function(self)
        if self.idsToShow then
            for _, spawnId in pairs(self.idsToShow) do
                QuestieMap:UnloadManualFrames(spawnId)
            end
        else
            QuestieMap:UnloadManualFrames(self.id)
        end
        self:SetText(l10n("Show on Map"))
        self:SetCallback("OnClick", function() self:ShowOnMap(self) end)
    end
    button.ShowOnMap = function(self)
        if self.idsToShow then
            for _, spawnId in pairs(self.idsToShow) do
                if spawnId > 0 then
                    QuestieMap:ShowNPC(spawnId)
                else
                    QuestieMap:ShowObject(-spawnId)
                end
            end
        else
            if self.id > 0 then
                QuestieMap:ShowNPC(self.id)
            elseif self.id < 0 then
                QuestieMap:ShowObject(-self.id)
            end
        end
        self:SetText(l10n("Remove from Map"))
        self:SetCallback("OnClick", function() self:RemoveFromMap(self) end)
    end
    return button
end

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

function QuestieSearchResults:QuestDetailsFrame(details, id)
    local ret = QuestieDB.QueryQuest(id, {"name", "requiredLevel", "requiredRaces", "objectivesText", "startedBy", "finishedBy", "preQuestGroup", "preQuestSingle"}) or {}
    local name, requiredLevel, requiredRaces, objectivesText, startedBy, finishedBy, preQuestGroup, preQuestSingle = ret[1], ret[2], ret[3], ret[4], ret[5], ret[6], ret[7], ret[8]

    local questLevel, _ = QuestieLib.GetTbcLevel(id);

    -- header
    local title = AceGUI:Create("Heading")
    title:SetFullWidth(true);
    title:SetText(name)
    details:AddChild(title)

    -- is quest finished by player
    local finished = AceGUI:Create("CheckBox")
    finished:SetValue(Questie.db.char.complete[id])
    finished:SetLabel(l10n("Complete"))
    finished:SetDisabled(true)
    -- reduce offset to next checkbox
    finished:SetHeight(16)
    finished:SetFullWidth(true);
    details:AddChild(finished)

    -- hidden by Questie
    local hiddenQuests = AceGUI:Create("CheckBox")
    hiddenQuests:SetValue(QuestieCorrections.hiddenQuests[id])
    hiddenQuests:SetLabel(l10n("Hidden by Questie"))
    hiddenQuests:SetDisabled(true)
    -- reduce offset to next checkbox
    hiddenQuests:SetHeight(16)
    hiddenQuests:SetFullWidth(true);
    details:AddChild(hiddenQuests)

    -- hidden by user
    local hiddenByUser = AceGUI:Create("CheckBox")
    hiddenByUser.id = id
    hiddenByUser:SetLabel(l10n("Hidden"))
    if Questie.db.char.hidden[id] ~= nil then
        hiddenByUser:SetValue(true)
    else
        hiddenByUser:SetValue(false)
    end
    hiddenByUser:SetCallback("OnValueChanged", function(frame)
        if Questie.db.char.hidden[frame.id] ~= nil then
            frame:SetValue(false)
            QuestieQuest:UnhideQuest(frame.id)
        else
            frame:SetValue(true)
            QuestieQuest:HideQuest(frame.id)
        end
    end)
    hiddenByUser:SetCallback("OnEnter", function()
        if GameTooltip:IsShown() then
            return;
        end
        GameTooltip:SetOwner(_G["QuestieJourneyFrame"].frame:GetParent(), "ANCHOR_CURSOR");
        GameTooltip:AddLine(l10n("Quest is hidden"))
        GameTooltip:AddLine(l10n("\nWhen selected, hides the quest from the map, even if it is active.\n\nHiding a quest is also possible by Shift-clicking it on the map."), 1, 1, 1, true);
        GameTooltip:SetFrameStrata("TOOLTIP");
        GameTooltip:Show();
    end)
    hiddenByUser:SetCallback("OnLeave", function()
        if GameTooltip:IsShown() then
            GameTooltip:Hide();
        end
    end)
    hiddenByUser:SetFullWidth(true);
    details:AddChild(hiddenByUser)

    -- do not reduce offset, as checkbox is followed by text

    -- general info
    QuestieJourneyUtils:AddLine(details, Questie:Colorize(l10n("Quest ID")) .. ": " .. id)
    QuestieJourneyUtils:AddLine(details,  Questie:Colorize(l10n("Quest Level")) .. ": " .. questLevel)
    QuestieJourneyUtils:AddLine(details,  Questie:Colorize(l10n("Required Level")) .. ": " .. requiredLevel)
    local reqRaces = QuestieLib:GetRaceString(requiredRaces)
    if (reqRaces ~= "") then
        QuestieJourneyUtils:AddLine(details, Questie:Colorize(l10n("Required Race")) .. ": " .. reqRaces)
    end
    QuestieJourneyUtils:AddLine(details, Questie:Colorize(l10n("Doable")) .. ": " .. tostring(QuestieDB.IsDoableVerbose(id, false, true, true)))

    -- objectives text
    if objectivesText then
        QuestieJourneyUtils:AddLine(details, "")
        QuestieJourneyUtils:AddLine(details,  Questie:Colorize(l10n("Objectives")) .. ":")
        for _, v in pairs(objectivesText) do
            QuestieJourneyUtils:AddLine(details, v)
        end
    end

    if startedBy then
        -- quest starters
        QuestieJourneyUtils:AddLine(details, "")
        AddLinkedParagraph(details, "npc", startedBy[1], l10n("NPCs starting this quest:"), QuestieDB.QueryNPCSingle)
        AddLinkedParagraph(details, "object", startedBy[2], l10n("Objects starting this quest:"), QuestieDB.QueryObjectSingle)
        -- TODO change to linked paragraph once item details page exists
        AddLinkedParagraph(details, "item", startedBy[3], l10n("Items starting this quest:"), QuestieDB.QueryItemSingle)
    end
    if finishedBy then
        -- quest finishers
        QuestieJourneyUtils:AddLine(details, "")
        AddLinkedParagraph(details, "npc", finishedBy[1], l10n("NPCs finishing this quest:"), QuestieDB.QueryNPCSingle)
        AddLinkedParagraph(details, "object", finishedBy[2], l10n("Objects finishing this quest:"), QuestieDB.QueryObjectSingle)
    end

    -- pre quests
    if preQuestGroup then
        QuestieJourneyUtils:AddLine(details, "")
        AddLinkedParagraph(details, "quest", preQuestGroup, l10n("Requires all of these quests to be finished:"), QuestieDB.QueryQuestSingle)
    end
    if preQuestSingle then
        QuestieJourneyUtils:AddLine(details, "")
        AddLinkedParagraph(details, "quest", preQuestSingle, l10n("Requires one of these quests to be finished:"), QuestieDB.QueryQuestSingle)
    end
    QuestieJourneyUtils:AddLine(details, "")

    if Questie.db.profile.debugEnabled then
        QuestieJourneyUtils:AddLine(details, recurseTable(QuestieDB.GetQuest(id), QuestieDB.questKeys))
    end
end

function QuestieSearchResults:SpawnDetailsFrame(f, spawn, spawnType)
    local header = AceGUI:Create("Heading");
    header:SetFullWidth(true);

    local id = 0
    local typeLabel = ""
    local query
    local spawnObject
    if spawnType == "npc" then
        typeLabel = "NPC"
        spawnObject = QuestieDB:GetNPC(spawn)
    elseif spawnType == "object" then
        typeLabel = "Object"
        spawnObject = QuestieDB:GetObject(spawn)
    end

    header:SetText(spawnObject.name);
    f:AddChild(header);

    QuestieJourneyUtils:Spacer(f);

    QuestieJourneyUtils:AddLine(f, Questie:Colorize(l10n(typeLabel).." ID")..": "..spawn)
    if spawnType == "npc" then
        if spawnObject.subName then
            QuestieJourneyUtils:AddLine(f, Questie:Colorize(l10n("Title"))..": "..spawnObject.subName)
        end
        local minLevel = spawnObject.minLevel
        local maxLevel = spawnObject.maxLevel
        local level
        if minLevel == maxLevel then level = minLevel else level = minLevel.." - "..maxLevel end
        QuestieJourneyUtils:AddLine(f, Questie:Colorize(l10n("Level"))..": "..level)
        local minLevelHealth = spawnObject.minLevelHealth
        local maxLevelHealth = spawnObject.maxLevelHealth
        local health
        if minLevelHealth == maxLevelHealth then health = minLevelHealth else health = minLevelHealth.." - "..maxLevelHealth end
        QuestieJourneyUtils:AddLine(f, Questie:Colorize(l10n("Health"))..": "..health)
        local friendlyTo = l10n("no faction")
        if spawnObject.friendlyToFaction == "AH" then
            friendlyTo = l10n("both factions")
        elseif spawnObject.friendlyToFaction == "A" then
            friendlyTo = l10n("Alliance")
        elseif spawnObject.friendlyToFaction == "H" then
            friendlyTo = l10n("Horde")
        end
        QuestieJourneyUtils:AddLine(f, Questie:Colorize(l10n("Friendly to"))..": "..friendlyTo)
    end

    QuestieJourneyUtils:Spacer(f);

    -- Also Starts
    if spawnObject.questStarts then
        AddLinkedParagraph(f, "quest", spawnObject.questStarts, l10n("Starts the following quests:"), QuestieDB.QueryQuestSingle)
    end

    -- Also ends
    if spawnObject.questEnds then
        AddLinkedParagraph(f, "quest", spawnObject.questEnds, l10n("Ends the following quests:"), QuestieDB.QueryQuestSingle)
    end

    local spawnZone = AceGUI:Create("Label");
    local spawns = spawnObject.spawns

    if spawns then
        f:AddChild(CreateShowHideButton(spawnType == "npc" and spawn or -spawn))
        local startindex = 0;
        for i in pairs(spawns) do
            if spawns[i][1] then
                startindex = i;
                break;
            end
        end

        local zoneName = QuestieJourneyUtils:GetZoneName(startindex)

        spawnZone:SetText(l10n(zoneName));
        spawnZone:SetFullWidth(true);
        f:AddChild(spawnZone);

        if spawns[startindex] and spawns[startindex][1] then
            local startx = spawns[startindex][1][1];
            local starty = spawns[startindex][1][2];

            if (startx ~= -1 or starty ~= -1) then
                local spawnLoc = AceGUI:Create("Label");
                spawnLoc:SetText("X: ".. startx .." || Y: ".. starty);
                spawnLoc:SetFullWidth(true);
                f:AddChild(spawnLoc);
            end
        end
    else
        spawnZone:SetText(l10n("No spawn data available."))
        spawnZone:SetFullWidth(true);
        f:AddChild(spawnZone);
    end

    QuestieJourneyUtils:Spacer(f);

    if Questie.db.profile.debugEnabled then
        if spawnType == "npc" then
            QuestieJourneyUtils:AddLine(f, recurseTable(spawnObject, QuestieDB.npcKeys))
        elseif spawnType == "object" then
            QuestieJourneyUtils:AddLine(f, recurseTable(spawnObject, QuestieDB.objectKeys))
        end
    end

    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);
end

--- Used for pre-caching item data, see the function below
---@type GameTooltip
local QuestieScanningTooltip = CreateFrame("GameTooltip", "QuestieScanningTooltip", nil, "GameTooltipTemplate")
QuestieScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

--- This function queries an item tooltip from the server, waits for the result, then calls the following function to draw an item info frame to a given parent frame.
---@param f Frame The frame to attach the created item details frame to
---@param itemId ItemID The ID for the item to show details about
---@return nil
 function QuestieSearchResults:ItemDetailsFrame(f, itemId)
    -- Caching an item creates visible lag of 2 or 3 seconds at times (e.g. 13490, 13492 on Era)
    -- So we need to make sure the item data is *sufficiently* cached before we draw the frame
    -- We can't use the following because it creates a delay in the tooltip being drawn:
    -- C_Item.RequestLoadItemDataByID(itemId)

    -- Instead we use this:
    QuestieScanningTooltip:SetItemByID(itemId)

    -- Then we wait for client to say it cached the item
    local ticker
    ticker = C_Timer.NewTicker(0.05, function()
        -- When it does...
        if C_Item.IsItemDataCachedByID(itemId) then
            ticker:Cancel()
            -- We still need another tiny delay because the following content might still clip the last few lines otherwise
            C_Timer.After(0.05, function() QuestieSearchResults:ItemsFrameAfterTicker(f, itemId) end)
        end
    end)
end

--- This function draws an item info frame to a given parent frame after the previous function made sure its data is cached.
---@param f Frame The frame to attach the created item details frame to
---@param itemId ItemID The ID for the item to show details about
---@return nil
function QuestieSearchResults:ItemsFrameAfterTicker(f, itemId)
    local header = AceGUI:Create("Heading")
    header:SetFullWidth(true)

    local query = QuestieDB.QueryItemSingle

    header:SetText(query(itemId, "name"))
    f:AddChild(header)

    local grp = AceGUI:Create("SimpleGroup")
    grp:SetFullWidth(true)
    grp:SetLayout("Flow")

    local itemIcon = QuestieJourneyUtils.GetItemIcon(itemId)
    grp:AddChild(itemIcon)

    local spawnIdLabel = AceGUI:Create("Label")
    spawnIdLabel:SetText("  Item ID: " .. itemId)
    grp:AddChild(spawnIdLabel)

    f:AddChild(grp)

    local tooltip = AceGUI:Create("GameTooltipWidget", itemId)
    tooltip:SetOwner(itemIcon.frame, "ANCHOR_BOTTOMRIGHT")
    tooltip:SetItemByID(itemId)
    tooltip:ShowTooltip()

    f:AddChild(tooltip)

    if QuestieCorrections.questItemBlacklist[itemId] then
        QuestieJourneyUtils:Spacer(f)
        local itemBlacklistedLabel = AceGUI:Create("Label")
        itemBlacklistedLabel:SetText(l10n("This item is blacklisted because it has too many sources"))
        itemBlacklistedLabel:SetFullWidth(true)
        f:AddChild(itemBlacklistedLabel)
        return
    end

    local sources = QuestieDB.QueryItem(itemId, {"npcDrops", "objectDrops", "vendors"})
    local npcDrops = sources[1]
    local objectDrops = sources[2]
    local vendors = sources[3]

    local npcSpawnsHeading = AceGUI:Create("Heading")
    npcSpawnsHeading:SetText(l10n("NPCs"))
    npcSpawnsHeading:SetFullWidth(true)
    f:AddChild(npcSpawnsHeading)

    if (not npcDrops or not next(npcDrops)) then
        local noNPCSourcesLabel = AceGUI:Create("Label")
        noNPCSourcesLabel:SetText(l10n("No NPC drops this item"))
        noNPCSourcesLabel:SetFullWidth(true)
        f:AddChild(noNPCSourcesLabel)
    else
        local npcLabel = AceGUI:Create("Label")

        local npcIdsWithSpawns = {}
        for _, npcId in pairs(npcDrops) do
            local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
            if spawns then
                npcIdsWithSpawns[#npcIdsWithSpawns + 1] = npcId
            end
        end

        npcLabel:SetText(l10n("%d NPCs drop this item", #npcIdsWithSpawns))
        f:AddChild(npcLabel)
        if (#npcIdsWithSpawns > 0) then
            local showHideButton = CreateShowHideButton(itemId)
            showHideButton.idsToShow = npcIdsWithSpawns
            f:AddChild(showHideButton)
        end
        AddLinkedParagraph(f, "npc", npcIdsWithSpawns, l10n("NPCs dropping this item:"), QuestieDB.QueryNPCSingle)
    end

    local objectSpawnsHeading = AceGUI:Create("Heading")
    objectSpawnsHeading:SetText(l10n("Objects"))
    objectSpawnsHeading:SetFullWidth(true)
    f:AddChild(objectSpawnsHeading)

    if (not objectDrops or not next(objectDrops)) then
        local noObjectSourcesLabel = AceGUI:Create("Label")
        noObjectSourcesLabel:SetText(l10n("No Object drops this item"))
        noObjectSourcesLabel:SetFullWidth(true)
        f:AddChild(noObjectSourcesLabel)
    else
        local objectLabel = AceGUI:Create("Label")

        local objectIdsWithSpawns = {}
        for _, objectId in pairs(objectDrops) do
            local spawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
            if spawns then
                objectIdsWithSpawns[#objectIdsWithSpawns + 1] = -objectId
            end
        end

        objectLabel:SetText(l10n("%d Objects drop this item", #objectIdsWithSpawns))
        f:AddChild(objectLabel)
        if (#objectIdsWithSpawns > 0) then
            local showHideButton = CreateShowHideButton(itemId)
            showHideButton.idsToShow = objectIdsWithSpawns
            f:AddChild(showHideButton)
        end
        AddLinkedParagraph(f, "object", objectIdsWithSpawns, l10n("Objects containing this item:"), QuestieDB.QueryObjectSingle)
    end

    local vendorSpawnsHeading = AceGUI:Create("Heading")
    vendorSpawnsHeading:SetText(l10n("Vendors"))
    vendorSpawnsHeading:SetFullWidth(true)
    f:AddChild(vendorSpawnsHeading)

    if (not vendors or not next(vendors)) then
        local noVendorSourcesLabel = AceGUI:Create("Label")
        noVendorSourcesLabel:SetText(l10n("No Vendor sells this item"))
        noVendorSourcesLabel:SetFullWidth(true)
        f:AddChild(noVendorSourcesLabel)
    else
        local vendorLabel = AceGUI:Create("Label")

        local vendorIdsWithSpawns = {}
        for _, npcId in pairs(vendors) do
            local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")

            if spawns then
                vendorIdsWithSpawns[#vendorIdsWithSpawns + 1] = npcId
            end
        end

        vendorLabel:SetText(l10n("%d Vendors sell this item", #vendorIdsWithSpawns))
        f:AddChild(vendorLabel)
        if (#vendorIdsWithSpawns > 0) then
            local showHideButton = CreateShowHideButton(itemId)
            showHideButton.idsToShow = vendorIdsWithSpawns
            f:AddChild(showHideButton)
        end
        AddLinkedParagraph(f, "npc", vendorIdsWithSpawns, l10n("Vendors selling this item:"), QuestieDB.QueryNPCSingle)
    end

    if Questie.db.profile.debugEnabled then
        QuestieJourneyUtils:AddLine(f, recurseTable(QuestieDB:GetItem(itemId), QuestieDB.itemKeys))
    end
    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);
end

-- draws a list of results of a certain type, e.g. "quest"
function QuestieSearchResults:DrawResultTab(container, resultType)
    -- probably already done by `JourneySelectTabGroup`, doesn't hurt to be safe though
    container:ReleaseChildren();

    local results = {}
    local database
    if resultType == "quest" then
        database = QuestieDB.QueryQuestSingle
    elseif resultType == "npc" then
        database = QuestieDB.QueryNPCSingle
    elseif resultType == "object" then
        database = QuestieDB.QueryObjectSingle
    elseif resultType == "item" then
        database = QuestieDB.QueryItemSingle
    else
        return
    end
    local max=0
    for k,_ in pairs(QuestieSearch.LastResult[resultType]) do
        if k > max then max = k end
    end
    for k=1, max do
        if QuestieSearch.LastResult[resultType][k] then
            local name = database(k, "name")
            if name then
                local complete = ''
                if Questie.db.char.complete[k] and resultType == "quest" then
                    complete = Questie:Colorize("(" .. l10n("Complete") .. ")" , "green")
                end
                -- TODO rename option to "enabledIDs" or create separate ones for npcs/objects/items
                local id = ''
                if Questie.db.profile.enableTooltipsQuestID then
                    id = ' (' .. k .. ')'
                end
                table.insert(results, {
                    ["text"] = complete .. name .. id,
                    ["value"] = tonumber(k)
                })
            end
        end
    end
    local resultFrame = AceGUI:Create("SimpleGroup");
    resultFrame:SetLayout("Fill");
    resultFrame:SetFullWidth(true);
    resultFrame:SetFullHeight(true);

    local resultTree = AceGUI:Create("TreeGroup");
    resultTree:SetFullWidth(true);
    resultTree:SetFullHeight(true);
    resultTree.treeframe:SetWidth(415);
    resultTree:SetTree(results);
    resultTree:SetCallback("OnGroupSelected", _HandleOnGroupSelected)

    resultFrame:AddChild(resultTree)
    container:AddChild(resultFrame);
    if _selected ~= 0 then
        resultTree:SelectByValue(_selected)
        _selected = 0
    end
end

_HandleOnGroupSelected = function (resultType)
    -- This is either the questId, npcId, objectId or itemId
    local selectedId = tonumber(resultType.localstatus.selected)
    if IsShiftKeyDown() and lastOpenSearch == "quest" then
        local questName = QuestieDB.QueryQuestSingle(selectedId, "name")
        local questLevel, _ = QuestieLib.GetTbcLevel(selectedId);

        if Questie.db.profile.trackerShowQuestLevel then
            ChatEdit_InsertLink(QuestieLink:GetQuestLinkString(questLevel, questName, selectedId))
        else
            ChatEdit_InsertLink("[" .. questName .. " (" .. selectedId .. ")]")
        end
    end

    -- get master frame and create scroll frame inside
    local master = resultType.frame.obj;
    master:ReleaseChildren();
    master:SetLayout("Fill");
    master:SetFullWidth(true);
    master:SetFullHeight(true);

    local details = AceGUI:Create("ScrollFrame");
    details:SetLayout("Flow");
    master:AddChild(details);

    if lastOpenSearch == "quest" then
        QuestieSearchResults:QuestDetailsFrame(details, selectedId);
    elseif lastOpenSearch == "npc" then
        QuestieSearchResults:SpawnDetailsFrame(details, selectedId, 'npc');
    elseif lastOpenSearch == "object" then
        QuestieSearchResults:SpawnDetailsFrame(details, selectedId, 'object')
    elseif lastOpenSearch == "item" then
        QuestieSearchResults:ItemDetailsFrame(details, selectedId)
    end
end

local function SelectTabGroup(container, _, resultType)
    lastOpenSearch = resultType
    QuestieSearchResults:DrawResultTab(container, resultType);
end

local function _GetSearchFunction(searchBox, searchGroup)
    return function()
        if searchBox:GetText() ~= "" then
            local searchText = searchBox:GetText()

            local itemName = GetItemInfo(searchText)
            if stringsub(searchText, 1, 4) == "|cff" and itemName then
                -- An itemLink was added to the searchBox
                searchBox:SetText(itemName)
                QuestieSearchResults:DrawSearchResultTab(searchGroup, BY_NAME, itemName, false)
            elseif stringsub(searchText, 1, 4) == "|cff" then
                -- This should be impossible to reach, since when you see an item link in the game the item should
                -- be cached already which would be caught by the condition above
                Questie:Debug(Questie.DEBUG_DEVELOP, "Search with link of an uncached item")
            else
                -- Normal search
                local text = string.trim(searchText, " \n\r\t[]");
                QuestieSearchResults:DrawSearchResultTab(searchGroup, tonumber(text) and BY_ID or BY_NAME, text, false)
            end
            searchBox:ClearFocus()
        end
    end
end

-- Draw search results from advanced search tab
local searchResultTabs
function QuestieSearchResults:DrawSearchResultTab(searchGroup, searchType, query, useLast)
    if not searchResultTabs then
        searchGroup:ReleaseChildren();
        if searchType == BY_NAME and (not useLast) then
            QuestieSearch:ByName(query)
        elseif searchType == BY_ID and (not useLast) then
            QuestieSearch:ByID(query)
        end
        local results = QuestieSearch.LastResult;
        local resultTypes = {
            ["quest"] = "Quests",
            ["npc"] = "Mobs",
            ["object"] = "Objects",
            ["item"] = "Items",
        }
        local resultCountTotal = 0
        local resultCounts = {
            total = 0,
            quest = 0,
            npc = 0,
            object = 0,
            item = 0
        }
        for type,_ in pairs(resultTypes) do
            for _,_ in pairs(results[type]) do
                resultCountTotal = resultCountTotal + 1
                resultCounts[type] = resultCounts[type] + 1
            end
        end
        if (resultCountTotal == 0) then
            local noresults = AceGUI:Create("Label");
            noresults:SetText(Questie:Colorize(l10n('No Match for Search Results: %s', query), 'yellow'));
            noresults:SetFullWidth(true);
            searchGroup:AddChild(noresults);
            return;
        end
        searchResultTabs = AceGUI:Create("TabGroup");
        searchResultTabs:SetFullWidth(true);
        searchResultTabs:SetFullHeight(true);
        searchResultTabs:SetLayout("Flow");
        searchResultTabs:SetTabs({
            {
                text = l10n('Quests') .. " ("..resultCounts.quest..")",
                value = "quest",
                disabled = resultCounts.quest == 0,
            },
            {
                text = l10n('NPCs') .. " ("..resultCounts.npc..")",
                value = "npc",
                disabled = resultCounts.npc == 0,
            },
            {
                text = l10n('Objects') .. " ("..resultCounts.object..")",
                value = "object",
                disabled = resultCounts.object == 0,
            },
            {
                text = l10n('Items') .. " ("..resultCounts.item..")",
                value = "item",
                disabled = resultCounts.item == 0,
            },
        })
        searchResultTabs:SetCallback("OnGroupSelected", SelectTabGroup)
        if _selected == 0 then searchResultTabs:SelectTab("quest"); end
        searchGroup:AddChild(searchResultTabs);
    else
        searchGroup:ReleaseChildren();
        searchResultTabs = nil;
        self:DrawSearchResultTab(searchGroup, searchType, query, useLast);
    end
end

-- The "Advanced Search" tab
local typeDropdown
local searchBox
local searchGroup
local searchButton
function QuestieSearchResults:DrawSearchTab(container)
    -- Header
    local header = AceGUI:Create("Heading");
    header:SetText(l10n("Enter in your Search"));
    header:SetFullWidth(true);
    container:AddChild(header);
    QuestieJourneyUtils:Spacer(container);

    searchBox = AceGUI:Create("EditBox");
    searchGroup = AceGUI:Create("SimpleGroup");
    searchButton = AceGUI:Create("Button");

    searchButton:SetText(l10n("Search"));
    searchButton:SetDisabled(true);
    searchButton:SetCallback("OnClick", _GetSearchFunction(searchBox, searchGroup));
    container:AddChild(searchButton);

    searchBox:SetFocus();
    searchBox:SetRelativeWidth(0.6);
    searchBox:SetLabel(l10n("Advanced Search") .. " (".. l10n("Quests") .. ", ".. l10n("NPCs") .. ", ".. l10n("Objects") .. ", ".. l10n("Items") .. ")");
    searchBox:DisableButton(true);
    searchBox:SetCallback("OnTextChanged", function()
        if searchBox:GetText() ~= "" then
            searchButton:SetDisabled(false);
        else
            searchButton:SetDisabled(true);
        end
    end);
    searchBox:SetCallback("OnEnterPressed", _GetSearchFunction(searchBox, searchGroup));
    -- Check for existence of previous search, if present use its text
    if QuestieSearch.LastResult.query ~= "" then
        searchBox:SetText(QuestieSearch.LastResult.query)
    end
    container:AddChild(searchBox);

    searchGroup:SetFullHeight(true);
    searchGroup:SetFullWidth(true);
    searchGroup:SetLayout("fill");
    container:AddChild(searchGroup);
    -- Check for existence of previous search, if present use its result
    if QuestieSearch.LastResult.query ~= "" then
        searchButton:SetDisabled(false)
        local text = string.trim(searchBox:GetText(), " \n\r\t[]")
        QuestieSearchResults:DrawSearchResultTab(searchGroup, tonumber(text) and BY_ID or BY_NAME, text, true)
    end
end

function QuestieSearchResults:GetDetailFrame(detailType, id)
    local frame = AceGUI:Create("Frame")
    frame:SetHeight(500)
    frame:SetWidth(300)
    frame:SetLayout("Fill");
    local details = AceGUI:Create("ScrollFrame")
    details:SetFullWidth(true);
    details:SetFullHeight(true);
    details:SetLayout("Flow")
    frame:AddChild(details)
    if detailType == "quest" then
        QuestieSearchResults:QuestDetailsFrame(details, id)
        frame:SetTitle(l10n("Quest Details"))
    elseif detailType == "npc" then
        QuestieSearchResults:SpawnDetailsFrame(details, id, detailType)
        frame:SetTitle(l10n("NPC Details"))
    elseif detailType == "object" then
        QuestieSearchResults:SpawnDetailsFrame(details, id, detailType)
        frame:SetTitle(l10n("Object Details"))
    elseif detailType == "item" then
        QuestieSearchResults:ItemDetailsFrame(details, id)
        frame:SetTitle(l10n("Item Details"))
    else
        frame:ReleaseChildren()
        return
    end
    frame:Show()
end

function QuestieSearchResults:SetSearch(detailType, id)
    _selected = id
    searchBox:SetText(tostring(id))
    QuestieSearchResults:DrawSearchResultTab(searchGroup, BY_ID, id, false)
    searchResultTabs:SelectTab(detailType)
end
