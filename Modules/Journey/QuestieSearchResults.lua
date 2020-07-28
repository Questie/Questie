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

local AceGUI = LibStub("AceGUI-3.0");

local lastOpenSearch = "quest";
local yellow = "|cFFFFFF00"
local green = "|cFF40C040"
local BY_NAME = 1
local BY_ID = 2


local function AddParagraph(frame, lookupObject, secondKey, header, query)
    if lookupObject[secondKey] then
        QuestieJourneyUtils:AddLine(frame,  yellow .. header .. "|r")
        for _,id in pairs(lookupObject[secondKey]) do
            local name = query(id, "name")
            if name then
                QuestieJourneyUtils:AddLine(frame, name.." ("..id..")")
            end
        end
    end
end

local function AddLinkedParagraph(frame, linkType, lookupObject, secondKey, header, query)
    if lookupObject[secondKey] then
        QuestieJourneyUtils:AddLine(frame,  yellow .. header .. "|r")
        for _,id in pairs(lookupObject[secondKey]) do
            -- QuestieJourneyUtils:AddLine(frame, lookupDB[id][lookupKey].." ("..id..")")
            local link = AceGUI:Create("InteractiveLabel")
            link:SetText(query(id, "name").." ("..id..")");
            link:SetCallback("OnClick", function(self) QuestieSearchResults:GetDetailFrame(linkType, id) end)
            frame:AddChild(link);
        end
    end
end

-- Create a button for showing/hiding manual notes of NPCs/objects
local function CreateShowHideButton(id)
    -- Initialise button
    local button = AceGUI:Create('Button')
    button.id = id
    if not QuestieMap.manualFrames[id] then
        button:SetText(QuestieLocale:GetUIString('Show on Map'))
        button:SetCallback('OnClick', function(self) self:ShowOnMap(self) end)
    else
        button:SetText(QuestieLocale:GetUIString('Remove from Map'))
        button:SetCallback('OnClick', function(self) self:RemoveFromMap(self) end)
    end
    -- Functions for showing/hiding and switching behaviour afterwards
    function button:RemoveFromMap(self)
        QuestieMap:UnloadManualFrames(self.id)
        self:SetText(QuestieLocale:GetUIString('Show on Map'))
        self:SetCallback('OnClick', function(self) self:ShowOnMap(self) end)
    end
    function button:ShowOnMap(self)
        if self.id > 0 then
            QuestieMap:ShowNPC(self.id)
        elseif self.id < 0 then
            QuestieMap:ShowObject(-self.id)
        end
        self:SetText(QuestieLocale:GetUIString('Remove from Map'))
        self:SetCallback('OnClick', function(self) self:RemoveFromMap(self) end)
    end
    return button
end

-- TODO move to QuestieDB
local function GetRacesString(raceMask)
    if not raceMask then return "" end
    if (raceMask == 0) or (raceMask == 255) then
        return "None"
    elseif (raceMask == 77) then
        return "Alliance"
    elseif (raceMask == 178) then
        return "Horde"
    else
        local raceString = ""
        local raceTable = QuestieLib:UnpackBinary(raceMask)
        local stringTable = {
            'Human',
            'Orc',
            'Dwarf',
            'Nightelf',
            'Undead',
            'Tauren',
            'Gnome',
            'Troll',
            'Goblin'
        }
        local firstRun = true
        for k,v in pairs(raceTable) do
            if v then
                if firstRun then
                    firstRun = false
                else
                    raceString = raceString .. ", "
                end
                raceString = raceString .. stringTable[k]
            end
        end
        return raceString
    end
end--]]

function QuestieSearchResults:QuestDetailsFrame(details, id)
    local name, questLevel, requiredLevel, requiredRaces, objectivesText, startedBy, finishedBy = unpack(QuestieDB.QueryQuest(id, "name", "questLevel", "requiredLevel", "requiredRaces", "objectivesText", "startedBy", "finishedBy"))

    -- header
    local title = AceGUI:Create("Heading")
    title:SetFullWidth(true);
    title:SetText(name)
    details:AddChild(title)

    -- is quest finished by player
    local finished = AceGUI:Create("CheckBox")
    finished:SetValue(Questie.db.char.complete[id])
    finished:SetLabel(_G['COMPLETE'])
    finished:SetDisabled(true)
    -- reduce offset to next checkbox
    finished:SetHeight(16)
    details:AddChild(finished)

    -- hidden by user
    local hiddenByUser = AceGUI:Create("CheckBox")
    hiddenByUser.id = id
    hiddenByUser:SetLabel("Hidden by user")
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
        GameTooltip:AddLine("Quests hidden by the user.")
        GameTooltip:AddLine("\nWhen selected, hides the quest from the map, even if it is active.\n\nHiding a quest is also possible by Shift-clicking it on the map.", 1, 1, 1, true);
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
    hiddenQuests:SetLabel("Hidden by Questie")
    hiddenQuests:SetDisabled(true)
    -- do not reduce offset, as checkbox is followed by text
    details:AddChild(hiddenQuests)

    -- general info
    QuestieJourneyUtils:AddLine(details, yellow .. "Quest ID:|r " .. id)
    QuestieJourneyUtils:AddLine(details,  yellow .. "Quest Level:|r " .. questLevel)
    QuestieJourneyUtils:AddLine(details,  yellow .. "Required Level:|r " .. requiredLevel)
    local reqRaces = GetRacesString(requiredRaces)
    if (reqRaces ~= "None") then
        QuestieJourneyUtils:AddLine(details, yellow .. "Required Races:|r " .. reqRaces)
    end

    -- objectives text
    if objectivesText then
        QuestieJourneyUtils:AddLine(details, "")
        QuestieJourneyUtils:AddLine(details,  yellow .. "Objectives:|r")
        for k,v in pairs(objectivesText) do
            QuestieJourneyUtils:AddLine(details, v)
        end
    end

    -- quest starters
    QuestieJourneyUtils:AddLine(details, "")
    AddLinkedParagraph(details, 'npc', startedBy, 1, "Creatures starting this quest:", QuestieDB.QueryNPCSingle)
    AddLinkedParagraph(details, 'object', startedBy, 2, "Objects starting this quest:", QuestieDB.QueryObjectSingle)
    -- TODO change to linked paragraph once item details page exists
    AddParagraph(details, startedBy, 3, "Items starting this quest:", QuestieDB.QueryItemSingle)
    -- quest finishers
    QuestieJourneyUtils:AddLine(details, "")
    AddLinkedParagraph(details, 'npc', finishedBy, 1, "Creatures finishing this quest:", QuestieDB.QueryNPCSingle)
    AddLinkedParagraph(details, 'object', finishedBy, 2, "Objects finishing this quest:", QuestieDB.QueryObjectSingle)
    QuestieJourneyUtils:AddLine(details, "")
end

function QuestieSearchResults:SpawnDetailsFrame(f, spawn, spawnType)
    local header = AceGUI:Create("Heading");
    header:SetFullWidth(true);
    
    local id = 0
    local typeLabel = ''
    local query
    if spawnType == 'npc' then
        id = spawn
        typeLabel = 'NPC'
        query = QuestieDB.QueryNPCSingle
    elseif spawnType == 'object' then
        id = -spawn
        typeLabel = 'Object'
        query = QuestieDB.QueryObjectSingle
    end

    header:SetText(query(spawn, "name"));
    f:AddChild(header);

    QuestieJourneyUtils:Spacer(f);

    local spawnID = AceGUI:Create("Label");
    spawnID:SetText(typeLabel..' ID: '..spawn);
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
            end
        end

        local continent = 'UNKNOWN ZONE';
        for i, v in ipairs(QuestieJourney.zones) do
            if v[startindex] then
                continent = QuestieJourney.zones[i][startindex];
            end
        end

        spawnZone:SetText(continent);
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
        spawnZone:SetText(QuestieLocale:GetUIString('No spawn data available.'))
        spawnZone:SetFullWidth(true);
        f:AddChild(spawnZone);
    end

    -- Also Starts
    local questStarts = query(spawn, "questStarts")
    if questStarts then
        local startGroup = AceGUI:Create("InlineGroup");
        startGroup:SetFullWidth(true);
        startGroup:SetLayout("flow");
        startGroup:SetTitle(QuestieLocale:GetUIString('Starts the following quests:'));
        f:AddChild(startGroup);

        local startQuests = {};
        local counter = 1;
        for i, v in pairs(questStarts) do
            startQuests[counter] = {};
            startQuests[counter].frame = AceGUI:Create("InteractiveLabel");
            startQuests[counter].quest = QuestieDB:GetQuest(v);
            startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName());
            startQuests[counter].frame:SetUserData('id', v);
            startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.name);
            startQuests[counter].frame:SetCallback("OnClick", function(self) QuestieSearchResults:GetDetailFrame('quest', v) end)
            startQuests[counter].frame:SetCallback("OnEnter", _QuestieJourney.ShowJourneyTooltip);
            startQuests[counter].frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip);
            startGroup:AddChild(startQuests[counter].frame);
            counter = counter + 1;
        end

        if #startQuests == 0 then
            local noquest = AceGUI:Create("Label");
            noquest:SetText(QuestieLocale:GetUIString('No quests to list.'));
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
        endGroup:SetTitle(QuestieLocale:GetUIString('Ends the following quests:'));
        f:AddChild(endGroup);

        local endQuests = {};
        local counter = 1;
        for i, v in ipairs(questEnds) do
            endQuests[counter] = {};
            endQuests[counter].frame = AceGUI:Create("InteractiveLabel");
            endQuests[counter].quest = QuestieDB:GetQuest(v);
            endQuests[counter].frame:SetText(endQuests[counter].quest:GetColoredQuestName());
            endQuests[counter].frame:SetUserData('id', v);
            endQuests[counter].frame:SetUserData('name', endQuests[counter].quest.name);
            endQuests[counter].frame:SetCallback("OnClick", function(self) QuestieSearchResults:GetDetailFrame('quest', v) end);
            endQuests[counter].frame:SetCallback("OnEnter", _QuestieJourney.ShowJourneyTooltip);
            endQuests[counter].frame:SetCallback("OnLeave", _QuestieJourney.HideJourneyTooltip);
            endGroup:AddChild(endQuests[counter].frame);
            counter = counter + 1;
        end

        if #endQuests == 0 then
            local noquest = AceGUI:Create("Label");
            noquest:SetText(QuestieLocale:GetUIString('No quests to list.'));
            noquest:SetFullWidth(true);
            endGroup:AddChild(noquest);
        end
    end

    QuestieJourneyUtils:Spacer(f);

    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);
end

-- draws a list of results of a certain type, e.g. "quest"
local searchTreeFrame = nil
function QuestieSearchResults:DrawResultTab(container, resultType)
    -- probably already done by `JourneySelectTabGroup`, doesn't hurt to be safe though
    container:ReleaseChildren();

    local results = {}
    local database
    local key
    if resultType == "quest" then
        database = QuestieDB.QueryQuestSingle--QuestieDB.questData
        key = QuestieDB.questKeys.name
    elseif resultType == "npc" then
        database = QuestieDB.QueryNPCSingle--QuestieDB.npcData
        key = QuestieDB.npcKeys.name
    elseif resultType == "object" then
        database = QuestieDB.QueryObjectSingle--QuestieDB.objectData
        key = QuestieDB.objectKeys.name
    elseif resultType == "item" then
        database = QuestieDB.QueryItemSingle--QuestieDB.itemData
        key = QuestieDB.itemKeys.name
    else
        return
    end
    for k,_ in pairs(QuestieSearch.LastResult[resultType]) do
        local name = database(k, "name")
        if name then
            local complete = ''
            if Questie.db.char.complete[k] and resultType == "quest" then
                complete = green .. '(' .. _G['COMPLETE'] .. ')|r '
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
    resultTree:SetCallback("OnGroupSelected", function(resultType)
        -- if they clicked on the header, don't do anything
        local sel = resultType.localstatus.selected;

        -- get master frame and create scroll frame inside
        local master = resultType.frame.obj;
        master:ReleaseChildren();
        master:SetLayout("Fill");
        master:SetFullWidth(true);
        master:SetFullHeight(true);

        local details = AceGUI:Create("ScrollFrame");
        details:SetLayout("Flow");
        master:AddChild(details);
        local id = tonumber(sel);

        if lastOpenSearch == "quest" then
            QuestieSearchResults:QuestDetailsFrame(details, id);
        elseif lastOpenSearch == "npc" then
            -- NPCs
            --local npc = QuestieDB:GetNPC(id);
            QuestieSearchResults:SpawnDetailsFrame(details, id, 'npc');
        elseif lastOpenSearch == "object" then
            QuestieSearchResults:SpawnDetailsFrame(details, id, 'object')
        end
    end);

    resultFrame:AddChild(resultTree)
    container:AddChild(resultFrame);
    searchTreeFrame = resultFrame
end

local function SelectTabGroup(container, event, resultType)
    QuestieSearchResults:DrawResultTab(container, resultType);
    lastOpenSearch = resultType
end

-- Draw search results from advanced search tab
local searchResultTabs = nil;
function QuestieSearchResults:DrawSearchResultTab(searchGroup, searchType, query, useLast)
    if not searchResultTabs then
        searchGroup:ReleaseChildren();
        if searchType == BY_NAME and not useLast then
            QuestieSearch:ByName(query)
        elseif searchType == BY_ID and not useLast then
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
        local resultCounts = {}
        resultCounts.total = 0
        resultCounts.quest = 0
        resultCounts.npc = 0
        resultCounts.object = 0
        resultCounts.item = 0
        for type,_ in pairs(resultTypes) do
            for _,_ in pairs(results[type]) do
                resultCountTotal = resultCountTotal + 1
                resultCounts[type] = resultCounts[type] + 1
            end
        end
        if (resultCountTotal == 0) then
            local noresults = AceGUI:Create("Label");
            noresults:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_SEARCH_NOMATCH', query), 'yellow'));
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
                text = "Quests ("..resultCounts.quest..")",
                value = "quest",
                disabled = resultCounts.quest == 0,
            },
            {
                text = "Mobs ("..resultCounts.npc..")",
                value = "npc",
                disabled = resultCounts.npc == 0,
            },
            {
                text = "Objects ("..resultCounts.object..")",
                value = "object",
                disabled = resultCounts.object == 0,
            },
            {
                text = "Items ("..resultCounts.item..")",
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
local typeDropdown = nil;
local searchBox = nil;
local searchGroup = nil;
local searchButton = nil;
function QuestieSearchResults:DrawSearchTab(container)
    -- Header
    local header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_SEARCH_HEAD'));
    header:SetFullWidth(true);
    container:AddChild(header);
    QuestieJourneyUtils:Spacer(container);
    -- Declare scopes
    typeDropdown = AceGUI:Create("LQDropdown");
    searchBox = AceGUI:Create("EditBox");
    searchGroup = AceGUI:Create("SimpleGroup");
    searchButton = AceGUI:Create("Button");
    -- switching between search types
    typeDropdown:SetList({
        [1] = QuestieLocale:GetUIString('JOURNEY_SEARCH_BY_NAME'),
        [2] = QuestieLocale:GetUIString('JOURNEY_SEARCH_BY_ID'),
    });
    typeDropdown:SetValue(Questie.db.char.searchType);
    typeDropdown:SetCallback("OnValueChanged", function(key, checked)
        Questie.db.char.searchType = key.value;
        searchGroup:ReleaseChildren();
        searchBox:HighlightText();
        searchBox:SetFocus();
    end)
    container:AddChild(typeDropdown);
    -- search input field
    searchBox:SetFocus();
    searchBox:SetRelativeWidth(0.6);
    searchBox:SetLabel(QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'));
    searchBox:DisableButton(true);
    searchBox:SetCallback("OnTextChanged", function()
        if not (searchBox:GetText() == '') then
            searchButton:SetDisabled(false);
        else
            searchButton:SetDisabled(true);
        end
    end);
    searchBox:SetCallback("OnEnterPressed", function()
        if not (searchBox:GetText() == '') then
            local text = string.trim(searchBox:GetText(), " \n\r\t[]");
            QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, text, false);
        end
    end);
    -- Check for existence of previous search, if present use its text
    if QuestieSearch.LastResult.query ~= '' then
        searchBox:SetText(QuestieSearch.LastResult.query)
    end
    container:AddChild(searchBox);
    -- search button
    searchButton:SetText(QuestieLocale:GetUIString('JOURNEY_SEARCH_EXE'));
    searchButton:SetDisabled(true);
    searchButton:SetCallback("OnClick", function()
        local text = string.trim(searchBox:GetText(), " \n\r\t[]");
        QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, text, false);
    end);
    container:AddChild(searchButton);
    -- search results
    searchGroup:SetFullHeight(true);
    searchGroup:SetFullWidth(true);
    searchGroup:SetLayout("fill");
    container:AddChild(searchGroup);
    -- Check for existence of previous search, if present use its result
    if QuestieSearch.LastResult.query ~= '' then
        searchButton:SetDisabled(false)
        local text = string.trim(searchBox:GetText(), " \n\r\t[]")
        QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, text, true)
    end
end

function QuestieSearchResults:JumpToQuest(button)
    local id = button:GetUserData('id');
    local name = button:GetUserData('name');

    if not QuestieJourney:IsShown() then
        QuestieJourney:ToggleJourneyWindow()
    end
    if not (_QuestieJourney.lastOpenWindow == 'search') then
        QuestieJourney.tabGroup:SelectTab('search');
    end

    if Questie.db.char.searchType == 1 then
        searchBox:SetText(name)
    else
        searchBox:SetText(id)
    end

    searchButton:SetDisabled(false)
    QuestieSearchResults:DrawSearchResultTab(searchGroup, Questie.db.char.searchType, name, false);
end

function QuestieSearchResults:GetDetailFrame(detailType, id)
    local frame = AceGUI:Create("Frame")
    frame:SetHeight(300)
    frame:SetWidth(300)
    if detailType == 'quest' then
        QuestieSearchResults:QuestDetailsFrame(frame, id)
        frame:SetTitle('Quest Details')
    elseif detailType == 'npc' then
        QuestieSearchResults:SpawnDetailsFrame(frame, id, detailType)
        frame:SetTitle('NPC Details')
    elseif detailType == 'object' then
        QuestieSearchResults:SpawnDetailsFrame(frame, id, detailType)
        frame:SetTitle('Object Details')
    -- TODO elseif detailType == 'item' then
    else
        frame:ReleaseChildren()
        return
    end
    frame:Show()
end
