---@class QuestieSearchResults
local QuestieSearchResults = QuestieLoader:CreateModule("QuestieSearchResults")
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
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

local AceGUI = LibStub("AceGUI-3.0");

local _HandleOnGroupSelected
local lastOpenSearch = "quest"

local BY_NAME = 1
local BY_ID = 2


local function AddParagraph(frame, lookupObject, secondKey, header, query)
    if lookupObject[secondKey] then
        QuestieJourneyUtils:AddLine(frame,  Questie:Colorize(header, "yellow"))
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
        QuestieJourneyUtils:AddLine(frame,  Questie:Colorize(header, "yellow"))
        for _,id in pairs(lookupObject) do
            -- QuestieJourneyUtils:AddLine(frame, lookupDB[id][lookupKey].." ("..id..")")
            local link = AceGUI:Create("InteractiveLabel")
            link:SetText(query(id, "name").." ("..id..")");
            link:SetCallback("OnClick", function() QuestieSearchResults:GetDetailFrame(linkType, id) end)
            frame:AddChild(link);
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

function QuestieSearchResults:QuestDetailsFrame(details, id)
    local ret = QuestieDB.QueryQuest(id, "name", "requiredLevel", "requiredRaces", "objectivesText", "startedBy", "finishedBy", "preQuestGroup", "preQuestSingle") or {}
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
    details:AddChild(finished)

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
    -- reduce offset to next checkbox
    hiddenByUser:SetHeight(16)
    details:AddChild(hiddenByUser)

    -- hidden by Questie
    local hiddenQuests = AceGUI:Create("CheckBox")
    hiddenQuests:SetValue(QuestieCorrections.hiddenQuests[id])
    hiddenQuests:SetLabel(l10n("Hidden by Questie"))
    hiddenQuests:SetDisabled(true)
    -- do not reduce offset, as checkbox is followed by text
    details:AddChild(hiddenQuests)

    -- general info
    QuestieJourneyUtils:AddLine(details, Questie:Colorize(l10n("Quest ID"), "yellow") .. ": " .. id)
    QuestieJourneyUtils:AddLine(details,  Questie:Colorize(l10n("Quest Level"), "yellow") .. ": " .. questLevel)
    QuestieJourneyUtils:AddLine(details,  Questie:Colorize(l10n("Required Level"), "yellow") .. ": " .. requiredLevel)
    local reqRaces = QuestieLib:GetRaceString(requiredRaces)
    if (reqRaces ~= "None") then
        QuestieJourneyUtils:AddLine(details, Questie:Colorize(l10n("Required Race"), "yellow") .. ": " .. reqRaces)
    end

    -- objectives text
    if objectivesText then
        QuestieJourneyUtils:AddLine(details, "")
        QuestieJourneyUtils:AddLine(details,  Questie:Colorize(l10n("Objectives"), "yellow") .. ":")
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
        AddParagraph(details, startedBy, 3, l10n("Items starting this quest:"), QuestieDB.QueryItemSingle)
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
end

function QuestieSearchResults:SpawnDetailsFrame(f, spawn, spawnType)
    local header = AceGUI:Create("Heading");
    header:SetFullWidth(true);
    
    local id = 0
    local typeLabel = ""
    local query
    if spawnType == "npc" then
        id = spawn
        typeLabel = "NPC"
        query = QuestieDB.QueryNPCSingle
    elseif spawnType == "object" then
        id = -spawn
        typeLabel = "Object"
        query = QuestieDB.QueryObjectSingle
    end

    header:SetText(query(spawn, "name"));
    f:AddChild(header);

    QuestieJourneyUtils:Spacer(f);

    local spawnID = AceGUI:Create("Label");
    spawnID:SetText(typeLabel.." ID: "..spawn);
    spawnID:SetFullWidth(true);
    f:AddChild(spawnID);

    QuestieJourneyUtils:Spacer(f);

    local spawnZone = AceGUI:Create("Label");
    local spawns = query(spawn, "spawns")

    if spawns then
        f:AddChild(CreateShowHideButton(id))
        local startindex = 0;
        for i in pairs(spawns) do
            if spawns[i][1] then
                startindex = i;
                break;
            end
        end

        local zoneName = QuestieJourneyUtils:GetZoneName(startindex)

        spawnZone:SetText(zoneName);
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

    -- Also Starts
    local questStarts = query(spawn, "questStarts")
    if questStarts then
        local startGroup = AceGUI:Create("InlineGroup");
        startGroup:SetFullWidth(true);
        startGroup:SetLayout("flow");
        startGroup:SetTitle(l10n("Starts the following quests:"));
        f:AddChild(startGroup);

        local startQuests = {};
        local counter = 1;
        for _, v in pairs(questStarts) do
            local quest = QuestieDB:GetQuest(v)
            local frame = AceGUI:Create("InteractiveLabel")
            frame:SetUserData("id", v)
            frame:SetUserData("name", quest.name)
            frame:SetCallback("OnClick", function() QuestieSearchResults:GetDetailFrame("quest", v) end)
            frame:SetCallback("OnEnter", _QuestieJourney.ShowJourneyTooltip)
            frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)
            frame:SetText(QuestieLib:GetColoredQuestName(quest.Id,  true, true))

            startQuests[counter] = {
                frame = frame,
                quest = quest
            }
            startGroup:AddChild(frame)
            counter = counter + 1
        end

        if #startQuests == 0 then
            local noquest = AceGUI:Create("Label");
            noquest:SetText(l10n("No quests to list."));
            noquest:SetFullWidth(true);
            startGroup:AddChild(noquest);
        end
    end

    QuestieJourneyUtils:Spacer(f);

    -- Also ends
    local questEnds = query(spawn, "questEnds")
    if questEnds then
        local endGroup = AceGUI:Create("InlineGroup");
        endGroup:SetFullWidth(true);
        endGroup:SetLayout("flow");
        endGroup:SetTitle(l10n("Ends the following quests:"));
        f:AddChild(endGroup);

        local endQuests = {};
        local counter = 1;
        for _, v in ipairs(questEnds) do
            local quest = QuestieDB:GetQuest(v)
            local frame = AceGUI:Create("InteractiveLabel")
            frame:SetText(QuestieLib:GetColoredQuestName(quest.Id, true, true))
            frame:SetUserData("id", v)
            frame:SetUserData("name", quest.name)
            frame:SetCallback("OnClick", function() QuestieSearchResults:GetDetailFrame("quest", v) end)
            frame:SetCallback("OnEnter", _QuestieJourney.ShowJourneyTooltip)
            frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip)

            endQuests[counter] = {
                frame = frame,
                quest = quest
            }
            endGroup:AddChild(frame)
            counter = counter + 1
        end

        if #endQuests == 0 then
            local noquest = AceGUI:Create("Label");
            noquest:SetText(l10n("No quests to list."));
            noquest:SetFullWidth(true);
            endGroup:AddChild(noquest);
        end
    end

    QuestieJourneyUtils:Spacer(f);

    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);
end

function QuestieSearchResults:ItemDetailsFrame(f, itemId)
    local header = AceGUI:Create("Heading")
    header:SetFullWidth(true)

    local query = QuestieDB.QueryItemSingle

    header:SetText(query(itemId, "name"))
    f:AddChild(header)

    local itemLink = select(2, GetItemInfo(itemId))
    local itemIcon = AceGUI:Create("Icon")
    itemIcon:SetWidth(25)
    itemIcon:SetHeight(25)
    itemIcon:SetImage(GetItemIcon(itemId))
    itemIcon:SetImageSize(25, 25)
    itemIcon:SetCallback("OnEnter", function()
        if (not itemLink) then
            itemLink = select(2, GetItemInfo(itemId))
        end
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Show()
    end)
    itemIcon:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
    f:AddChild(itemIcon)

    local spawnIdLabel = AceGUI:Create("Label")
    spawnIdLabel:SetText("  Item ID: " .. itemId)
    f:AddChild(spawnIdLabel)

    if QuestieCorrections.questItemBlacklist[itemId] then
        QuestieJourneyUtils:Spacer(f)
        local itemBlacklistedLabel = AceGUI:Create("Label")
        itemBlacklistedLabel:SetText(l10n("This item is blacklisted because it has too many sources"))
        itemBlacklistedLabel:SetFullWidth(true)
        f:AddChild(itemBlacklistedLabel)
        return
    end

    local npcDrops, objectDrops, vendors = unpack(QuestieDB.QueryItem(itemId, "npcDrops", "objectDrops", "vendors"))

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
    for k,_ in pairs(QuestieSearch.LastResult[resultType]) do
        local name = database(k, "name")
        if name then
            local complete = ''
            if Questie.db.char.complete[k] and resultType == "quest" then
                complete = Questie:Colorize("(" .. l10n("Complete") .. ")" , "green")
            end
            -- TODO rename option to "enabledIDs" or create separate ones for npcs/objects/items
            local id = ''
            if Questie.db.global.enableTooltipsQuestID then
                id = ' (' .. k .. ')'
            end
            table.insert(results, {
                ["text"] = complete .. name .. id,
                ["value"] = tonumber(k)
            })
        end
    end
    local resultFrame = AceGUI:Create("SimpleGroup");
    resultFrame:SetLayout("Fill");
    resultFrame:SetFullWidth(true);
    resultFrame:SetFullHeight(true);

    local resultTree = AceGUI:Create("TreeGroup");
    resultTree:SetFullWidth(true);
    resultTree:SetFullHeight(true);
    resultTree.treeframe:SetWidth(260);
    resultTree:SetTree(results);
    resultTree:SetCallback("OnGroupSelected", _HandleOnGroupSelected)

    resultFrame:AddChild(resultTree)
    container:AddChild(resultFrame);
end

_HandleOnGroupSelected = function (resultType)
    -- This is either the questId, npcId, objectId or itemId
    local selectedId = tonumber(resultType.localstatus.selected)
    if IsShiftKeyDown() and lastOpenSearch == "quest" then
        local questName = QuestieDB.QueryQuestSingle(selectedId, "name")
        local questLevel, _ = QuestieLib.GetTbcLevel(selectedId);

        if Questie.db.global.trackerShowQuestLevel then
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
        QuestieSearchResults:ItemDetailsFrame(details, selectedId, 'item')
    end
end

local function SelectTabGroup(container, _, resultType)
    QuestieSearchResults:DrawResultTab(container, resultType);
    lastOpenSearch = resultType
end

local function _GetSearchFunction(searchBox, searchGroup)
    return function()
        if searchBox:GetText() ~= "" then
            local searchText = searchBox:GetText()
    
            local itemName = GetItemInfo(searchText)
            if itemName then -- An itemLink was added to the searchBox
                searchBox:SetText(itemName)
                QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, itemName, false)
            else
                local text = string.trim(searchText, " \n\r\t[]");
                QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, text, false)
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
        searchResultTabs:SelectTab("quest");
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

    typeDropdown = AceGUI:Create("Dropdown");
    typeDropdown:SetList({
        [1] = l10n("Search By Name"),
        [2] = l10n("Search By ID"),
    });
    typeDropdown:SetValue(Questie.db.char.searchType);
    typeDropdown:SetCallback("OnValueChanged", function(key, _)
        Questie.db.char.searchType = key.value;
        searchGroup:ReleaseChildren();
        searchBox:HighlightText();
        searchBox:SetFocus();
    end)
    container:AddChild(typeDropdown);

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

    searchButton:SetText(l10n("Search"));
    searchButton:SetDisabled(true);
    searchButton:SetCallback("OnClick", _GetSearchFunction(searchBox, searchGroup));
    container:AddChild(searchButton);

    searchGroup:SetFullHeight(true);
    searchGroup:SetFullWidth(true);
    searchGroup:SetLayout("fill");
    container:AddChild(searchGroup);
    -- Check for existence of previous search, if present use its result
    if QuestieSearch.LastResult.query ~= "" then
        searchButton:SetDisabled(false)
        local text = string.trim(searchBox:GetText(), " \n\r\t[]")
        QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, text, true)
    end
end

function QuestieSearchResults:GetDetailFrame(detailType, id)
    local frame = AceGUI:Create("Frame")
    frame:SetHeight(300)
    frame:SetWidth(300)
    if detailType == "quest" then
        QuestieSearchResults:QuestDetailsFrame(frame, id)
        frame:SetTitle(l10n("Quest Details"))
    elseif detailType == "npc" then
        QuestieSearchResults:SpawnDetailsFrame(frame, id, detailType)
        frame:SetTitle(l10n("NPC Details"))
    elseif detailType == "object" then
        QuestieSearchResults:SpawnDetailsFrame(frame, id, detailType)
        frame:SetTitle(l10n("Object Details"))
    elseif detailType == "item" then
        QuestieSearchResults:ItemDetailsFrame(frame, id)
        frame:SetTitle(l10n("Item Details"))
    else
        frame:ReleaseChildren()
        return
    end
    frame:Show()
end
