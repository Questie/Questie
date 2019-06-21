QuestieJourney = {};
local AceGUI = LibStub("AceGUI-3.0");

local journeyFrame = {};
local isWindowShown = false;
local lastOpenWindow = "journey";
containerCache = nil;

local function Spacer(container, size)
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


local journeyTreeFrame = nil;
local treeCache = nil;

local function splitJourneyByDate()

    local dateTable = {};

    -- Sort all of the entries by year and month
    for i, v in ipairs(Questie.db.char.journey) do
        local year = date('%Y', v.Timestamp);

        if not dateTable[year] then
            dateTable[year] = {};
        end

        local month = date('%m', v.Timestamp);

        if not dateTable[year][month] then
            dateTable[year][month] = {};
        end

        table.insert(dateTable[year][month], v);
    end

    -- now take those sorted dates and create a tree table
    local returnTable = {};
    for i, v in pairs(dateTable) do
        yearTable = {
            value = i,
            text = QuestieLocale:GetUIString('JOURNEY_TABLE_YEAR', i),
            children = {},
        };

        for mon, entries in pairs(dateTable[i]) do
            local monthView = {
                value = mon,
                text = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(mon)] .. ' '.. i,
                children = {},
            };

            for idx, entry in pairs(dateTable[i][mon]) do

                local entryText = '';
                if entry.Event == "Level" then
                    entryText = QuestieLocale:GetUIString('JOURNEY_LEVELREACH', entry.NewLevel);
                elseif entry.Event == "Note" then
                    entryText = QuestieLocale:GetUIString('JOURNEY_TABLE_NOTE', entry.Title);
                elseif entry.Event == "Quest" then
                    local state = '';
                    if entry.SubType == "Accept" then
                        state = QuestieLocale:GetUIString('JOURNEY_ACCEPT');
                    elseif entry.SubType == "Complete" then
                        state = QuestieLocale:GetUIString('JOUNREY_COMPLETE');
                    elseif entry.SubType == "Abandon" then
                        state = QuestieLocale:GetUIString('JOURNEY_ABADON');
                    else
                        state = "ERROR!!";
                    end

                    local qName = QuestieDB:GetQuest(entry.Quest).Name;
                    entryText = QuestieLocale:GetUIString('JOURNEY_TABLE_QUEST', state, qName);
                end


                local entryView = {
                    value = idx,
                    text = entryText,
                };

                table.insert(monthView.children, entryView);
            end

            table.insert(yearTable.children, monthView);
        end

        table.insert(returnTable, yearTable);
    end

    return returnTable;
end

-- manage the journey tree
local function manageJourneyTree(container)
    if not journeyTreeFrame then
        journeyTreeFrame = AceGUI:Create("TreeGroup");
        journeyTreeFrame:SetFullWidth(true);
        journeyTreeFrame:SetFullHeight(true);

        journeyTreeFrame.treeframe:SetWidth(220);
        
        journeyTree = {};
        journeyTree = splitJourneyByDate();
        journeyTreeFrame:SetTree(journeyTree);
        journeyTreeFrame:SetCallback("OnGroupSelected", function(group)

            local _, _, e = strsplit("\001", group.localstatus.selected);

            if e then
                local master = group.frame.obj;
                master:ReleaseChildren();
                master:SetLayout("fill");
                master:SetFullWidth(true);
                master:SetFullHeight(true);
    
                local f = AceGUI:Create("ScrollFrame");
                f:SetLayout("flow");
                master:AddChild(f);

                local header = AceGUI:Create("Heading");
                header:SetFullWidth(true);
                f:AddChild(header);

                Spacer(f);

                local created = AceGUI:Create("Label");
                created:SetFullWidth(true);
                

                entry = Questie.db.char.journey[tonumber(e)];
                local day = CALENDAR_WEEKDAY_NAMES[ tonumber(date('%w', entry.Timestamp)) + 1 ];
                local month = CALENDAR_FULLDATE_MONTH_NAMES[ tonumber(date('%m', entry.Timestamp)) ];
                local timestamp = Questie:Colorize(date( day ..', '.. month ..' %d @ %H:%M' , entry.Timestamp), 'blue');

                if entry.Event == "Note" then

                    header:SetText(QuestieLocale:GetUIString('JOURNEY_TABLE_NOTE', entry.Title));

                    local note = AceGUI:Create("Label");
                    note:SetFullWidth(true);
                    note:SetText(Questie:Colorize( entry.Note , 'yellow'));
                    f:AddChild(note);
                    Spacer(f);

                    created:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_CREATED', timestamp));
                    f:AddChild(created);

                elseif entry.Event == "Level" then

                    header:SetText(QuestieLocale:GetUIString('JOURNEY_LEVELREACH', entry.NewLevel));

                    local congrats = AceGUI:Create("Label");
                    congrats:SetText(QuestieLocale:GetUIString('JOURNEY_LEVELUP', entry.NewLevel));
                    congrats:SetFullWidth(true);
                    f:AddChild(congrats);

                    created:SetText(timestamp);
                    f:AddChild(created);

                elseif entry.Event == "Quest" then

                    local state = '';
                    if entry.SubType == "Accept" then
                        state = QuestieLocale:GetUIString('JOURNEY_ACCEPT');
                    elseif entry.SubType == "Complete" then
                        state = QuestieLocale:GetUIString('JOUNREY_COMPLETE');
                    elseif entry.SubType == "Abandon" then
                        state = QuestieLocale:GetUIString('JOURNEY_ABADON');
                    else
                        state = "ERROR!!";
                    end

                    local quest = QuestieDB:GetQuest(entry.Quest)
                    local qName = quest.Name;
                    header:SetText(QuestieLocale:GetUIString('JOURNEY_TABLE_QUEST', state, qName));


                    local obj = AceGUI:Create("Label");
                    obj:SetFullWidth(true);
                    obj:SetText(createObjectiveText(quest.Description));
                    f:AddChild(obj);

                    Spacer(f);

                    -- Only show party members if you weren't alone
                    if #entry.Party > 0 then
                        
                        -- Display Party Members
                        local partyFrame = AceGUI:Create("InlineGroup");
                        partyFrame:SetTitle(QuestieLocale:GetUIString('JOURNEY_PARTY_TITLE'));
                        partyFrame:SetFullWidth(true);
                        f:AddChild(partyFrame);

                        for i, v in ipairs(entry.Party) do
                            local color = Questie:GetClassColor(v.Class);
                            local str = color .. '['.. v.Level ..'] ' .. v.Class ..' ' .. v.Name .. '|r';

                            local pf = AceGUI:Create("Label");
                            pf:SetFullWidth(true);
                            pf:SetText(str);
                            partyFrame:AddChild(pf);
                        end

                        Spacer(f);
                    end


                    created:SetText(QuestieLocale:GetUIString('JOURNEY_TABLE_QUEST', state, timestamp));
                    f:AddChild(created);

                else
                    header:SetText("ERROR!!");
                end

            end
        end);

        container:AddChild(journeyTreeFrame);

    else
        container:ReleaseChildren();
        journeyTreeFrame = nil;
        manageJourneyTree(container);
    end
end

-- function that draws the Tab for the "My Journey" 
local function DrawJourneyTab(container)
    local head = AceGUI:Create("Heading");
    head:SetText(QuestieLocale:GetUIString('JOURNEY_RECENT_EVENTS'));
    head:SetFullWidth(true);
    container:AddChild(head);
    Spacer(container);

    -- get last 5 elements from table for history
    local counter = #Questie.db.char.journey;
    local recentEvents = {};
    for i = counter, counter-4, -1 do
        if i <= 0 then
            break;
        end

        recentEvents[i] = {};
        recentEvents[i] = AceGUI:Create("Label");
        recentEvents[i]:SetFullWidth(true);

        local day = CALENDAR_WEEKDAY_NAMES[ tonumber(date('%w', Questie.db.char.journey[i].Timestamp)) + 1 ];
        local month = CALENDAR_FULLDATE_MONTH_NAMES[ tonumber(date('%m', Questie.db.char.journey[i].Timestamp)) ];

        local timestamp = Questie:Colorize(date( '[ '..day ..', '.. month ..' %d @ %H:%M ]  ' , Questie.db.char.journey[i].Timestamp), 'blue');

        -- if it's a quest event
        if Questie.db.char.journey[i].Event == "Quest" then
            local quest = QuestieDB:GetQuest(Questie.db.char.journey[i].Quest);
            local qName = Questie:Colorize(quest.Name, 'gray');

            if Questie.db.char.journey[i].SubType == "Accept" then
                recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_QUEST_ACCEPT', qName) , 'yellow')  );
            elseif Questie.db.char.journey[i].SubType == "Abandon" then
                recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_QUEST_ABANDON', qName) , 'yellow')  );
            elseif Questie.db.char.journey[i].SubType == "Complete" then
                recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_QUEST_COMPLETE', qName) , 'yellow')  );
            end
        elseif Questie.db.char.journey[i].Event == "Level" then
            local level = Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_LEVELNUM', Questie.db.char.journey[i].NewLevel), 'gray');
            recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_LEVELUP', level) , 'yellow')  );
        elseif Questie.db.char.journey[i].Event == "Note" then
            local title = Questie:Colorize(Questie.db.char.journey[i].Title, 'gray');
            recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_NOTE_CREATED', title) , 'yellow')  );
        end

        container:AddChild(recentEvents[i]);
    end

    if counter == 0 then
        local justdoit = AceGUI:Create("Label");
        justdoit:SetFullWidth(true);
        justdoit:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_BEGIN'), 'yellow'));
        container:AddChild(justdoit);
    end

    Spacer(container);

    local treeHead = AceGUI:Create("Heading");
    treeHead:SetText(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")));
    treeHead:SetFullWidth(true);
    container:AddChild(treeHead);

    local noteBtn = AceGUI:Create("Button");
    noteBtn:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_BTN'));
    noteBtn:SetPoint("RIGHT");
    noteBtn:SetCallback("OnClick", notePopup);
    container:AddChild(noteBtn);

    Spacer(container);

    local treeGroup = AceGUI:Create("SimpleGroup");
    treeGroup:SetLayout("fill");
    treeGroup:SetFullHeight(true);
    treeGroup:SetFullWidth(true);
    container:AddChild(treeGroup);

    treeCache = treeGroup;

    manageJourneyTree(treeGroup);
end


local notesPopupWin = nil;
local notesPopupWinIsOpen = false;
function notePopup()
    if not notesPopupWin then
        notesPopupWin = AceGUI:Create("Window");
        notesPopupWin:Show();
        notesPopupWin:SetTitle(QuestieLocale:GetUIString('JOURNEY_NOTE_BTN'));
        notesPopupWin:SetWidth(400);
        notesPopupWin:SetHeight(400);
        notesPopupWin:EnableResize(false);
        notesPopupWin.frame:SetFrameStrata("HIGH");

        journeyFrame.frame.frame:SetFrameStrata("MEDIUM");

        notesPopupWinIsOpen = true;
        _G["QuestieJourneyFrame"] = notesPopupWin.frame;

        notesPopupWin:SetCallback("OnClose", function() 
            notesPopupWin = nil;
            notesPopupWinIsOpen = false;
            journeyFrame.frame.frame:SetFrameStrata("FULLSCREEN_DIALOG");

            _G["QuestieJourneyFrame"] = journeyFrame.frame.frame;
        end);

        -- Setup Note Taking
        local day = CALENDAR_WEEKDAY_NAMES[ tonumber(date('%w', time())) + 1];
        local month = CALENDAR_FULLDATE_MONTH_NAMES[ tonumber(date('%m', time())) ];
        local today = date(day ..', '.. month ..' %d', time());
        local frame = AceGUI:Create("InlineGroup");
        frame:SetFullHeight(true);
        frame:SetFullWidth(true);
        frame:SetLayout('flow');
        frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_NOTE_TITLE', today));
        notesPopupWin:AddChild(frame);

        local desc = AceGUI:Create("Label");
        desc:SetText( Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_NOTE_DESC'), 'yellow')  );
        desc:SetFullWidth(true);
        frame:AddChild(desc);

        Spacer(frame);


        local titleBox = AceGUI:Create("EditBox");
        titleBox:SetFullWidth(true);
        titleBox:SetLabel(QuestieLocale:GetUIString('JOURNEY_NOTE_ENTRY_TITLE'));
        titleBox:DisableButton(true);
        titleBox:SetFocus();
        frame:AddChild(titleBox);

        local messageBox = AceGUI:Create("MultiLineEditBox");
        messageBox:SetFullWidth(true);
        messageBox:SetNumLines(12);
        messageBox:SetLabel(QuestieLocale:GetUIString('JOUNREY_NOTE_ENTRY_BODY'));
        messageBox:DisableButton(true);
        frame:AddChild(messageBox);

        local addEntryBtn = AceGUI:Create("Button");
        addEntryBtn:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_SUBMIT_BTN'));
        addEntryBtn:SetCallback("OnClick", function() 
            local err = Questie:Colorize('[Questie] ', 'blue');
            if titleBox:GetText() == '' then
                print (err .. QuestieLocale:GetUIString('JOURNEY_ERR_NOTITLE'));
                return;
            elseif messageBox:GetText() == '' then
                print (err .. QuestieLocale:GetUIString('JOURNEY_ERR_NONOTE'));
                return;
            end

            local data = {};
            data.Event = "Note";
            data.Note = messageBox:GetText();
            data.Title = titleBox:GetText();
            data.Timestamp = time();
            data.Party = {};

            if GetHomePartyInfo() then
                data.Party = {};
                local p = {};
                for i, v in pairs(GetHomePartyInfo()) do
                    p.Name = v;
                    p.Class, _, _ = UnitClass(v);
                    p.Level = UnitLevel(v);
                    table.insert(data.Party, p);
                end
            end
            
            table.insert(Questie.db.char.journey, data);


            manageJourneyTree(treeCache);

            notesPopupWin:Hide();
            notesPopupWin = nil;
            notesPopupWinIsOpen = false;

        end);
        frame:AddChild(addEntryBtn);

    else
        notesPopupWin:Hide();
        notesPopupWin = nil;
        notesPopupWinIsOpen = false;
    end
end


local continentTable = {
    [1] = "Eastern Kingdoms",
    [2] = "Kalimdor",
    [3] = "Dungeons",
  --  [4] = "Raids",
  --  [5] = "Battle Grounds"
};
  

local zoneTable = {
    [1] = {
        [36] = "Alterac Mountains",
        [45] = "Arathi Highlands",
        [3] = "Badlands",
        [4] = "Blasted Lands",
        [46] = "Burning Steppes",
        [41] = "Deadwind Pass",
        [2257] = "Deeprun Tram",
        [1] = "Dun Morogh",
        [10] = "Duskwood",
        [139] = "Eastern Plaguelands",
        [12] = "Elwynn Forest",
        [267] = "Hillsbrad Foothills",
        [1537] = "Ironforge",
        [38] = "Loch Modan",
        [44] = "Redridge Mountains",
        [51] = "Searing Gorge",
        [130] = "Silverpine Forest",
        [1519] = "Stormwind City",
        [33] = "Strangelthorn Vale",
        [8] = "Swamp of Sorrows",
        [47] = "The Hinterlands",
        [85] = "Tirisfal Glade",
        [1497] = "Undercity",
        [28] = "Western Plaguelands",
        [40] = "Westfall",
        [11] = "Wetlands"
    },
    [2] = {
        [331] = "Ashenvale",
        [16] = "Azshara",
        [148] = "Darkshore",
        [1657] = "Darnassus",
        [405] = "Desolace",
        [14] = "Durotar",
        [15] = "Dustwallow Marsh",
        [361] = "Felwood",
        [357] = "Feralas",
        [493] = "Moonglade",
        [215] = "Mulgore",
        [1637] = "Orgrimmar",
        [1377] = "Silithus",
        [406] = "Stonetalon Mountains",
        [440] = "Tanaris",
        [141] = "Teldrassil",
        [17] = "The Barrens",
        [400] = "Thousand Needles",
        [1638] = "Thunder Bluff",
        [490] = "Un'Goro Crater",
        [618] = "Winterspring"
    },
    [3] = {
        [2437] = "Ragefire Chasm",
        [1581] = "The Deadmines",
        [718] = "Wailing Caverns",
        [209] = "Shadowfang Keep",
        [719] = "Blackfathom Deeps",
        [717] = "The Stockades",
        [721] = "Gnomeregan",
        [491] = "Razorfen Kraul",
        [796] = "Scarlet Monastery",
        [722] = "Razorfen Downs",
        [1337] = "Uldaman",
        [2100] = "Maraudon",
        [1176] = "Zul'Farrak",
        [1477] = "The Temple of Atal'Hakkar",
        [1584] = "Blackrock Depths",
        [1583] = "Blackrock Spire",
        [2017] = "Stratholme",
        [2557] = "Dire Maul",
        [2057] = "Scholomance",
    }
};


function jumpToSearch(button)
    local qid = button:GetUserData('id');
    local qname = button:GetUserData('name');

    if not (lastOpenWindow == 'search') then
        tabGroup:SelectTab('search');
    end

    typeDropdown:SetValue(1);
    searchBox:SetText(qname);
    DrawSearchResults(searchGroup, 1, qname);
    searchTreeFrame:SelectByValue(qid);

    hideJourneyTooltip();
end

function showJourneyTooltip(button)
    if GameTooltip:IsShown() then
        return;
    end

    local qid = button:GetUserData('id');
    local quest = QuestieDB:GetQuest(tonumber(qid));

    GameTooltip:SetOwner(_G["QuestieJourneyFrame"], "ANCHOR_CURSOR");
    GameTooltip:AddLine("[".. quest.Level .."] ".. quest.Name);
    GameTooltip:AddLine("|cFFFFFFFF" .. createObjectiveText(quest.Description))
    GameTooltip:SetFrameStrata("TOOLTIP");
    GameTooltip:Show();
end

function hideJourneyTooltip()
    if GameTooltip:IsShown() then
        GameTooltip:Hide();
    end
end

function createObjectiveText(desc)
    local objText = "";

    if desc then 
        for i, v in ipairs(desc) do
            objText = objText .. v .. "\n";
        end
    else
        objText = Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_AUTO_QUEST'), 'yellow');
    end

    return objText;
end

local zoneTreeFrame = nil;
local selectedContinent = 0;

local function questFrame(f, quest)
    local header = AceGUI:Create("Heading");
    header:SetFullWidth(true);
    header:SetText(quest.Name);
    f:AddChild(header);

    Spacer(f);

    local obj = AceGUI:Create("Label");
    obj:SetText(createObjectiveText(quest.Description));


    obj:SetFullWidth(true);
    f:AddChild(obj);
    Spacer(f);

    local questinfo = AceGUI:Create("Heading");
    questinfo:SetFullWidth(true);
    questinfo:SetText(QuestieLocale:GetUIString('JOURNEY_QUESTINFO'));
    f:AddChild(questinfo);

    -- Generic Quest Information
    local level = AceGUI:Create("Label");
    level:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_LEVEL'), 'yellow') .. quest.Level);
    level:SetFullWidth(true);
    f:AddChild(level);

    local minLevel = AceGUI:Create("Label");
    minLevel:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_MINLEVEL'), 'yellow') .. quest.MinLevel);
    minLevel:SetFullWidth(true);
    f:AddChild(minLevel);
    
    local diff = AceGUI:Create("Label");
    diff:SetFullWidth(true);
    local red, orange, yellow, green, gray = QuestieJourney:GetLevelDifficultyRanges(quest.Level, quest.MinLevel);
    local diffStr = '';

    if red then
        diffStr = diffStr .. "|cFFFF1A1A[".. red .."]|r ";
    end

    if orange then
        diffStr = diffStr .. "|cFFFF8040[".. orange .."]|r ";
    end

    diffStr = diffStr .. "|cFFFFFF00[".. yellow .."]|r ";
    diffStr = diffStr .. "|cFF40C040[".. green .."]|r ";
    diffStr = diffStr .. "|cFFC0C0C0[".. gray .."]|r ";

    diff:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_DIFFICULTY', diffStr), 'yellow'));
    f:AddChild(diff);

    local id = AceGUI:Create("Label");
    id:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_ID'), 'yellow') .. quest.Id);
    id:SetFullWidth(true);
    f:AddChild(id);
    Spacer(f);



    -- Get Quest Start NPC
    if quest.Starts and quest.Starts.NPC then
        local startNPCGroup = AceGUI:Create("InlineGroup"); 
        startNPCGroup:SetLayout("List");
        startNPCGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_NPC'));
        startNPCGroup:SetFullWidth(true);
        f:AddChild(startNPCGroup);

        Spacer(startNPCGroup);

        local startnpc = QuestieDB:GetNPC(quest.Starts.NPC[1]);

        local startNPCName = AceGUI:Create("Label");
        startNPCName:SetText(startnpc.Name);
        startNPCName:SetFontObject(GameFontHighlight);
        startNPCName:SetColor(255, 165, 0);
        startNPCName:SetFullWidth(true);
        startNPCGroup:AddChild(startNPCName);

        local startNPCZone = AceGUI:Create("Label");
        local startindex = 0;
        for i in pairs(startnpc.Spawns) do
            startindex = i;
        end

        local continent = 'UNKNOWN ZONE';
        for i, v in ipairs(zoneTable) do
            if v[startindex] then
                continent = zoneTable[i][startindex];
            end
        end

        startNPCZone:SetText(continent);
        startNPCZone:SetFullWidth(true);
        startNPCGroup:AddChild(startNPCZone);

        local startx = startnpc.Spawns[startindex][1][1];
        local starty = startnpc.Spawns[startindex][1][2];
        if (startx ~= -1 or starty ~= -1) then 
            local startNPCLoc = AceGUI:Create("Label");
            startNPCLoc:SetText("X: ".. startx .." || Y: ".. starty);
            startNPCLoc:SetFullWidth(true);
            startNPCGroup:AddChild(startNPCLoc);
        end

        local startNPCID = AceGUI:Create("Label");
        startNPCID:SetText("NPC ID: ".. startnpc.Id);
        startNPCID:SetFullWidth(true);
        startNPCGroup:AddChild(startNPCID);

        Spacer(startNPCGroup);

        -- Also Starts
        if startnpc.Starts then

            local alsostarts = AceGUI:Create("Label");
            alsostarts:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS'));
            alsostarts:SetColor(255, 165, 0);
            alsostarts:SetFontObject(GameFontHighlight);
            alsostarts:SetFullWidth(true);
            startNPCGroup:AddChild(alsostarts);

            local startQuests = {};
            local counter = 1;
            for i, v in pairs(startnpc.Starts) do
                if not (v == quest.Id) then
                    startQuests[counter] = {};
                    startQuests[counter].frame = AceGUI:Create("InteractiveLabel");
                    startQuests[counter].quest = QuestieDB:GetQuest(v);
                    startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName());
                    startQuests[counter].frame:SetUserData('id', v);
                    startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.Name);
                    startQuests[counter].frame:SetCallback("OnClick", jumpToSearch);
                    startQuests[counter].frame:SetCallback("OnEnter", showJourneyTooltip);
                    startQuests[counter].frame:SetCallback("OnLeave", hideJourneyTooltip);
                    startNPCGroup:AddChild(startQuests[counter].frame);
                    counter = counter + 1;
                end
            end

            if #startQuests == 0 then
                local noquest = AceGUI:Create("Label");
                noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'));
                noquest:SetFullWidth(true);
                startNPCGroup:AddChild(noquest);
            end
        end

        Spacer(startNPCGroup);

    end

    -- Get Quest Start GameObject
    if quest.Starts and quest.Starts.GameObject then
        local startGOGroup = AceGUI:Create("InlineGroup"); 
        startGOGroup:SetLayout("List");
        startGOGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_OBJ'));
        startGOGroup:SetFullWidth(true);
        f:AddChild(startGOGroup);

        Spacer(startGOGroup);

        local startObjects = {}
        for i, oid in pairs(quest.Starts.GameObject) do
            local startobj = QuestieDB:GetObject(oid);

            local startGOGName = AceGUI:Create("Label");
            startGOGName:SetText(startobj.Name);
            startGOGName:SetFontObject(GameFontHighlight);
            startGOGName:SetColor(255, 165, 0);
            startGOGName:SetFullWidth(true);
            startGOGroup:AddChild(startGOGName);

            local starGOCZone = AceGUI:Create("Label");
            local startindex = 0;
            for i in pairs(startobj.Spawns) do
                startindex = i;
            end

            local continent = 'UNKNOWN ZONE';
            for i, v in ipairs(zoneTable) do
                if v[startindex] then
                    continent = zoneTable[i][startindex];
                end
            end

            starGOCZone:SetText(continent);
            starGOCZone:SetFullWidth(true);
            startGOGroup:AddChild(starGOCZone);

            local startx = startobj.Spawns[startindex][1][1];
            local starty = startobj.Spawns[startindex][1][2];
            if (startx ~= -1 or starty ~= -1) then 
                local startGOLoc = AceGUI:Create("Label");
                startGOLoc:SetText("X: ".. startx .." || Y: ".. starty);
                startGOLoc:SetFullWidth(true);
                startGOGroup:AddChild(startGOLoc);
            end

            local startGOID = AceGUI:Create("Label");
            startGOID:SetText("Object ID: ".. startobj.Id);
            startGOID:SetFullWidth(true);
            startGOGroup:AddChild(startGOID);

            Spacer(startGOGroup);

            -- Also Starts
            if startobj.Starts then

                local alsostarts = AceGUI:Create("Label");
                alsostarts:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS_GO'));
                alsostarts:SetColor(255, 165, 0);
                alsostarts:SetFontObject(GameFontHighlight);
                alsostarts:SetFullWidth(true);
                startGOGroup:AddChild(alsostarts);

                local startQuests = {};
                local counter = 1;
                for i, v in pairs(startobj.Starts) do
                    if not (v == quest.Id) then
                        startQuests[counter] = {};
                        startQuests[counter].frame = AceGUI:Create("InteractiveLabel");
                        startQuests[counter].quest = QuestieDB:GetQuest(v);
                        startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName());
                        startQuests[counter].frame:SetUserData('id', v);
                        startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.Name);
                        startQuests[counter].frame:SetCallback("OnClick", jumpToSearch);
                        startQuests[counter].frame:SetCallback("OnEnter", showJourneyTooltip);
                        startQuests[counter].frame:SetCallback("OnLeave", hideJourneyTooltip);
                        startGOGroup:AddChild(startQuests[counter].frame);
                        counter = counter + 1;
                    end
                end

                if #startQuests == 0 then
                    local noquest = AceGUI:Create("Label");
                    noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'));
                    noquest:SetFullWidth(true);
                    startGOGroup:AddChild(noquest);
                end
            end

            Spacer(startGOGroup);
        end
    end

    Spacer(f);

    -- Get Quest Turnin NPC
    if quest.Finisher and quest.Finisher.Name and quest.Finisher.Type == "monster" then
        local endNPCGroup = AceGUI:Create("InlineGroup"); 
        endNPCGroup:SetLayout("Flow");
        endNPCGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_END_NPC'));
        endNPCGroup:SetFullWidth(true);
        f:AddChild(endNPCGroup);
        Spacer(endNPCGroup);

        local endnpc = QuestieDB:GetNPC(quest.Finisher.Id);

        local endNPCName = AceGUI:Create("Label");
        endNPCName:SetText(endnpc.Name);
        endNPCName:SetFontObject(GameFontHighlight);
        endNPCName:SetColor(255, 165, 0);
        endNPCName:SetFullWidth(true);
        endNPCGroup:AddChild(endNPCName);

        local endNPCZone = AceGUI:Create("Label");
        local endindex = 0;
        for i in pairs(endnpc.Spawns) do
            endindex = i;
        end

        local continent = 'UNKNOWN ZONE';
        for i, v in ipairs(zoneTable) do
            if v[endindex] then
                continent = zoneTable[i][endindex];
            end
        end

        endNPCZone:SetText(continent);
        endNPCZone:SetFullWidth(true);
        endNPCGroup:AddChild(endNPCZone);

        local endx = endnpc.Spawns[endindex][1][1];
        local endy = endnpc.Spawns[endindex][1][2];
        if (endx ~= -1 or endy ~= -1) then 
            local endNPCLoc = AceGUI:Create("Label");
            endNPCLoc:SetText("X: ".. endx .." || Y: ".. endy);
            endNPCLoc:SetFullWidth(true);
            endNPCGroup:AddChild(endNPCLoc);
        end

        local endNPCID = AceGUI:Create("Label");
        endNPCID:SetText("NPC ID: ".. endnpc.Id);
        endNPCID:SetFullWidth(true);
        endNPCGroup:AddChild(endNPCID);

        Spacer(endNPCGroup);

        -- Also ends
        if endnpc.Ends then
            local alsoends = AceGUI:Create("Label");
            alsoends:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_ENDS'));
            alsoends:SetFontObject(GameFontHighlight);
            alsoends:SetColor(255, 165, 0);
            alsoends:SetFullWidth(true);
            endNPCGroup:AddChild(alsoends);

            local endQuests = {};
            local counter = 1;
            for i, v in ipairs(endnpc.Ends) do
                if not (v == quest.Id) then
                    endQuests[counter] = {};
                    endQuests[counter].frame = AceGUI:Create("InteractiveLabel");
                    endQuests[counter].quest = QuestieDB:GetQuest(v);
                    endQuests[counter].frame:SetText(endQuests[counter].quest:GetColoredQuestName());
                    endQuests[counter].frame:SetUserData('id', v);
                    endQuests[counter].frame:SetUserData('name', endQuests[counter].quest.Name);
                    endQuests[counter].frame:SetCallback("OnClick", jumpToSearch);
                    endQuests[counter].frame:SetCallback("OnEnter", showJourneyTooltip);
                    endQuests[counter].frame:SetCallback("OnLeave", hideJourneyTooltip);
                    endNPCGroup:AddChild(endQuests[counter].frame);
                    counter = counter + 1;
                end
            end

            if #endQuests == 0 then
                local noquest = AceGUI:Create("Label");
                noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'));
                noquest:SetFullWidth(true);
                endNPCGroup:AddChild(noquest);
            end

        end

        Spacer(endNPCGroup);

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        f.content:SetHeight(10000);
   
    end
end

local function npcFrame(f, npc)
    local header = AceGUI:Create("Heading");
    header:SetFullWidth(true);
    header:SetText(npc.Name);
    f:AddChild(header);

    Spacer(f);

    local npcZone = AceGUI:Create("Label");
    local startindex = 0;
    for i in pairs(npc.Spawns) do
        startindex = i;
    end

    local continent = 'UNKNOWN ZONE';
    for i, v in ipairs(zoneTable) do
        if v[startindex] then
            continent = zoneTable[i][startindex];
        end
    end

    npcZone:SetText(continent);
    npcZone:SetFullWidth(true);
    f:AddChild(npcZone);

    local startx = npc.Spawns[startindex][1][1];
    local starty = npc.Spawns[startindex][1][2];

    if (startx ~= -1 or starty ~= -1) then 
        local npcLoc = AceGUI:Create("Label");
        npcLoc:SetText("X: ".. startx .." || Y: ".. starty);
        npcLoc:SetFullWidth(true);
        f:AddChild(npcLoc);
    end

    local npcID = AceGUI:Create("Label");
    npcID:SetText("NPC ID: ".. npc.Id);
    npcID:SetFullWidth(true);
    f:AddChild(npcID);

    Spacer(f);

    
    -- Also Starts
    if npc.Starts then
        local startGroup = AceGUI:Create("InlineGroup");
        startGroup:SetFullWidth(true);
        startGroup:SetLayout("flow");
        startGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS'));
        f:AddChild(startGroup);    

        local startQuests = {};
        local counter = 1;
        for i, v in pairs(npc.Starts) do
            startQuests[counter] = {};
            startQuests[counter].frame = AceGUI:Create("InteractiveLabel");
            startQuests[counter].quest = QuestieDB:GetQuest(v);
            startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName());
            startQuests[counter].frame:SetUserData('id', v);
            startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.Name);
            startQuests[counter].frame:SetCallback("OnClick", jumpToSearch);
            startQuests[counter].frame:SetCallback("OnEnter", showJourneyTooltip);
            startQuests[counter].frame:SetCallback("OnLeave", hideJourneyTooltip);
            startGroup:AddChild(startQuests[counter].frame);
            counter = counter + 1;
        end

        if #startQuests == 0 then
            local noquest = AceGUI:Create("Label");
            noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'));
            noquest:SetFullWidth(true);
            startGroup:AddChild(noquest);
        end
    end

    Spacer(f);

     -- Also ends
     if npc.Ends then

        local endGroup = AceGUI:Create("InlineGroup");
        endGroup:SetFullWidth(true);
        endGroup:SetLayout("flow");
        endGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_ALSO_ENDS'));
        f:AddChild(endGroup);
    
        local endQuests = {};
        local counter = 1;
        for i, v in ipairs(npc.Ends) do
            endQuests[counter] = {};
            endQuests[counter].frame = AceGUI:Create("InteractiveLabel");
            endQuests[counter].quest = QuestieDB:GetQuest(v);
            endQuests[counter].frame:SetText(endQuests[counter].quest:GetColoredQuestName());
            endQuests[counter].frame:SetUserData('id', v);
            endQuests[counter].frame:SetUserData('name', endQuests[counter].quest.Name);
            endQuests[counter].frame:SetCallback("OnClick", jumpToSearch);
            endQuests[counter].frame:SetCallback("OnEnter", showJourneyTooltip);
            endQuests[counter].frame:SetCallback("OnLeave", hideJourneyTooltip);
            endGroup:AddChild(endQuests[counter].frame);
            counter = counter + 1;
        end

        if #endQuests == 0 then
            local noquest = AceGUI:Create("Label");
            noquest:SetText(QuestieLocale:GetUIString('JOURNEY_NO_QUEST'));
            noquest:SetFullWidth(true);
            endGroup:AddChild(noquest);
        end
    end

    Spacer(f);

    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);

end

-- Manage teh zone tree itself and the contents of the per-quest window
local function manageZoneTree(container, zt)
    if not zoneTreeFrame then
        zoneTreeFrame = AceGUI:Create("TreeGroup");
        zoneTreeFrame:SetFullWidth(true);
        zoneTreeFrame:SetFullHeight(true);
        zoneTreeFrame:SetTree(zt);
        
        zoneTreeFrame.treeframe:SetWidth(220);
 
        zoneTreeFrame:SetCallback("OnGroupSelected", function(group)

            -- if they clicked on the header, don't do anything
            local sel = group.localstatus.selected;
            if sel == "a" or sel == "c" then
                return;
            end

            -- get master frame and create scroll frame inside
            local master = group.frame.obj;
            master:ReleaseChildren();
            master:SetLayout("fill");
            master:SetFullWidth(true);
            master:SetFullHeight(true);

            local f = AceGUI:Create("ScrollFrame");
            f:SetLayout("flow");
            f:SetFullHeight(true);
            master:AddChild(f);

            _, qid = strsplit("\001", sel);
            qid = tonumber(qid);

            local quest = QuestieDB:GetQuest(qid);
            questFrame(f, quest);

        end);

        container:AddChild(zoneTreeFrame);

    else
        container:ReleaseChildren();
        zoneTreeFrame = nil;
        manageZoneTree(container, zt);
    end

end

  -- function that draws the Tab for Zone Quests
local function DrawZoneQuestTab(container)
    -- Header
    local header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_HEAD'));
    header:SetFullWidth(true);
    container:AddChild(header);
    Spacer(container);

    -- Dropdown for Continent 
    local CDropdown = AceGUI:Create("Dropdown");
    local zDropdown = AceGUI:Create("Dropdown");
    local treegroup = AceGUI:Create("SimpleGroup");

    CDropdown:SetList(continentTable);
    CDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_CONT'));

    CDropdown:SetCallback("OnValueChanged", function(key, checked) 
        -- set the zone table to be used. 
        selectedContinent = key.value;
        zDropdown:SetList(zoneTable[key.value]); 
        zDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'));
        zDropdown:SetDisabled(false);  
    end)
    container:AddChild(CDropdown);

    -- Dropdown for Zone
    zDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'));
    zDropdown:SetDisabled(true);

    zDropdown:SetCallback("OnValueChanged", function(key, checked)
        -- Create Tree View
        CollectZoneQuests(treegroup, key.value);
    end);
    container:AddChild(zDropdown);

    Spacer(container);

    header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_QUESTS'));
    header:SetFullWidth(true);
    container:AddChild(header);
   
    Spacer(container);

    treegroup:SetFullHeight(true);
    treegroup:SetFullWidth(true);
    treegroup:SetLayout("fill");
    container:AddChild(treegroup);

end

-- populate the available and complteded quests for the given zone
function CollectZoneQuests(container, zoneid)
    local quests = QuestieDB:GetQuestsByZoneId(zoneid);
    local temp = {};

    local zoneTree = {
        [1] = {
            value = "a",
            text = QuestieLocale:GetUIString('JOURNEY_AVAILABLE_TITLE'),
            children = {}
        },
        [2] = {
            value = "c",
            text = QuestieLocale:GetUIString('JOURNEY_COMPLETE_TITLE'),
            children = {}
        }
    };

    -- populate available non complete quests
    local availableCounter = 0;
    for qid, q in pairs(quests) do
        if not Questie.db.char.complete[qid] and not q.Hidden then

            -- see if it's supposed to be a hidden quest
            if qHide and not qHide[qid] then

                -- remove any breadcrumb quests too
                if questExclusiveGroupFixes and not questExclusiveGroupFixes[qid] then
                    temp.value = qid;
                    temp.text = q:GetColoredQuestName();
                    table.insert(zoneTree[1].children, temp);
                    temp = {}; -- Weird Lua bug requires this to be reset?
                    availableCounter = availableCounter + 1;
                end
            end
        end
    end

    -- populate complete quests
    local completedCounter = 0;
    for qid, _ in pairs(Questie.db.char.complete) do
        if quests[qid] then
            temp.value = qid;
            temp.text = quests[qid]:GetColoredQuestName();
            table.insert(zoneTree[2].children, temp);
            temp = {}; -- Weird Lua bug requires this to be reset?
            completedCounter = completedCounter + 1;
        end
    end

    local totalCounter = availableCounter + completedCounter;
    zoneTree[1].text = zoneTree[1].text .. ' [ '..  availableCounter .. ' ]';
    zoneTree[2].text = zoneTree[2].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]';

    -- Build Tree
    manageZoneTree(container, zoneTree);
end


-- Draw search results from advanced search tab
searchTreeFrame = nil;
function DrawSearchResults(searchGroup, selectedKey, content)
    if not searchTreeFrame then
        searchGroup:ReleaseChildren();
        local results = PopulateSearchResults(selectedKey, content);

        if #results == 0 then
            local noresults = AceGUI:Create("Label");
            noresults:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_SEARCH_NOMATCH', content), 'yellow'));
            noresults:SetFullWidth(true);
            searchGroup:AddChild(noresults);
            return;
        end

        searchTreeFrame = AceGUI:Create("TreeGroup");
        searchTreeFrame:SetFullWidth(true);
        searchTreeFrame:SetFullHeight(true);
        searchTreeFrame:SetTree(results);

        searchTreeFrame.treeframe:SetWidth(220);

        searchTreeFrame:SetCallback("OnGroupSelected", function(group)
            -- if they clicked on the header, don't do anything
            local sel = group.localstatus.selected;

            -- get master frame and create scroll frame inside
            local master = group.frame.obj;
            master:ReleaseChildren();
            master:SetLayout("fill");
            master:SetFullWidth(true);
            master:SetFullHeight(true);

            local f = AceGUI:Create("ScrollFrame");
            f:SetLayout("flow");
            master:AddChild(f);

            --_, qid = strsplit("\001", sel);
            qid = tonumber(sel);


            if selectedKey == 1 or selectedKey == 2 then
                -- Quests
                local quest = QuestieDB:GetQuest(qid);
                questFrame(f, quest);
                
            elseif selectedKey == 3 or selectedKey == 4 then
                -- NPCs
                local npc = QuestieDB:GetNPC(qid);
                npcFrame(f, npc);
                
            end
        end);
       
        searchGroup:AddChild(searchTreeFrame);
    else
        searchGroup:ReleaseChildren();
        searchTreeFrame = nil;
        DrawSearchResults(searchGroup, selectedKey, content);
    end
end

-- Populate Search Results
function PopulateSearchResults(selectedKey, content)
    local returnTable = {
    };

    if selectedKey == 1 then
        -- Quests
        local quests = QuestieDB:GetQuestsByName(content);
        local temp = {};

        if quests then
            for i, v in ipairs(quests) do
                local q = QuestieDB:GetQuest(tonumber(v));
                temp.value = tostring(v);
                --temp.text = '['.. q.Level ..'] '.. q.Name;
                temp.text = q:GetColoredQuestName();

                table.insert(returnTable, temp);

                temp = {};
            end
        end
    elseif selectedKey == 2 then
        -- Get Quest ID
        local quest = QuestieDB:GetQuest(tonumber(content));

        local temp = {};

        if quest then
            temp.value = tostring(quest.Id);
            --temp.text = '['.. quest.Level ..'] '.. quest.Name;
            temp.text = q:GetColoredQuestName();

            table.insert(returnTable, temp);

            temp = {};
        end

    elseif selectedKey == 3 then
        -- NPCs
        local npcs = QuestieDB:GetNPCsByName(content);
        local temp = {};

        if npcs then
            for i, v in ipairs(npcs) do
                temp.value = tostring(v);
                temp.text = QuestieDB:GetNPC(tonumber(v)).Name;

                table.insert(returnTable, temp);

                temp = {};
            end
        end
    elseif selectedKey == 4 then
        -- NPC by ID
        local npc = QuestieDB:GetNPC(tonumber(content));

        local temp = {};

        if npc then
            temp.value = tostring(npc.Id);
            temp.text = npc.Name;

            table.insert(returnTable, temp);

            temp = {};
        end
    end

    return returnTable;
end

-- Advanced Search Tab
typeDropdown = nil;
searchBox = nil;
searchGroup = nil;
local function DrawSearchTab(container)

    -- Header
    local header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_SEARCH_HEAD'));
    header:SetFullWidth(true);
    container:AddChild(header);
    Spacer(container);

    -- Declare scopes
    typeDropdown = AceGUI:Create("Dropdown");
    searchBox = AceGUI:Create("EditBox");
    searchGroup = AceGUI:Create("SimpleGroup");
    local searchBtn = AceGUI:Create("Button");
        
    -- Dropdown for Continent 
    typeDropdown:SetList({
        [1] = QuestieLocale:GetUIString('JOURNEY_SEARCH_QUESTS'),
        [2] = QuestieLocale:GetUIString('JOURNEY_SEARCH_QUESTS_ID'),
        [3] = QuestieLocale:GetUIString('JOURNEY_SEARCH_NPCS'),
        [4] = QuestieLocale:GetUIString('JOURNEY_SEARCH_NPCS_ID'),
    });
    typeDropdown:SetValue(Questie.db.char.searchCriteria);

    typeDropdown:SetCallback("OnValueChanged", function(key, checked) 
        Questie.db.char.searchCriteria = key.value;
        searchGroup:ReleaseChildren();
        searchBox:HighlightText();
        searchBox:SetFocus();
    end)
    container:AddChild(typeDropdown);

    searchBox:SetFocus();
    searchBox:SetRelativeWidth(0.6);
    searchBox:SetLabel(QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'));
    searchBox:DisableButton(true);
    searchBox:SetCallback("OnTextChanged", function() 
        if not (searchBox:GetText() == '') then
            searchBtn:SetDisabled(false);
        else
            searchBtn:SetDisabled(true);
        end
    end);

    searchBox:SetCallback("OnEnterPressed", function() 
        if not (searchBox:GetText() == '') then
            local text = string.trim(searchBox:GetText(), " \n\r\t[]");
            DrawSearchResults(searchGroup, Questie.db.char.searchCriteria, text);
        end
    end);
    

    container:AddChild(searchBox);

    searchBtn:SetText(QuestieLocale:GetUIString('JOURNEY_SEARCH_EXE'));
    searchBtn:SetDisabled(true);
    searchBtn:SetCallback("OnClick", function()
        local text = string.trim(searchBox:GetText(), " \n\r\t[]");
        DrawSearchResults(searchGroup, Questie.db.char.searchCriteria, text);
    end);

    container:AddChild(searchBtn);

    Spacer(container);

    local resultsHead = AceGUI:Create("Heading");
    resultsHead:SetText(QuestieLocale:GetUIString('JOURNEY_SEARCH_RESULTS'));
    resultsHead:SetFullWidth(true);
    container:AddChild(resultsHead);
    Spacer(container);

    searchGroup:SetFullHeight(true);
    searchGroup:SetFullWidth(true);
    searchGroup:SetLayout("fill");
    container:AddChild(searchGroup);



end
  
function journeySelectTabGroup(container, event, group)
    if not containerCache then
        containerCache = container;
    end

    container:ReleaseChildren();

    if group == "journey" then
        DrawJourneyTab(container);
        lastOpenWindow = "journey";
    elseif group == "zone" then
        DrawZoneQuestTab(container);
        lastOpenWindow = "zone";
    elseif group == "search" then
        DrawSearchTab(container);
       lastOpenWindow = "search"; 
    end
end

tabGroup = nil;
function QuestieJourney:Initialize()
    
    journeyFrame.frame = AceGUI:Create("Frame");

    journeyFrame.frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")));
    journeyFrame.frame:SetLayout("Fill");

    tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow");
    tabGroup:SetTabs({
        {
            text = QuestieLocale:GetUIString('JOUNREY_TAB'),
            value="journey"
        }, 
        {
            text = QuestieLocale:GetUIString('JOURNEY_ZONE_TAB'), 
            value="zone"
        },
        {
            text = QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'),
            value="search"
        }
    });
    tabGroup:SetCallback("OnGroupSelected", journeySelectTabGroup);
    tabGroup:SelectTab("journey");

    journeyFrame.frame:AddChild(tabGroup);

    journeyFrame.frame:SetCallback("OnClose", function() 
        isWindowShown = false;
        if notesPopupWinIsOpen then
            notesPopupWin:Hide();
            notesPopupWin = nil;
            notesPopupWinIsOpen = false;
        end
    end);


    journeyFrame.frame:Hide();

    _G["QuestieJourneyFrame"] = journeyFrame.frame.frame;
    table.insert(UISpecialFrames, "QuestieJourneyFrame");
end

function QuestieJourney:toggleJourneyWindow()
    if not isWindowShown then
        PlaySound(882);

        journeySelectTabGroup(containerCache, nil, lastOpenWindow);

        journeyFrame.frame:Show();
        isWindowShown = true;
    else
        journeyFrame.frame:Hide();
        isWindowShown = false;
    end
end

function QuestieJourney:IsShown()
    return isWindowShown;
end


function QuestieJourney:GetLevelDifficultyRanges(questLevel, questMinLevel)

    local red, orange, yellow, green, gray = 0,0,0,0,0;

    -- Calculate Base Values
    red = questMinLevel;
    orange = questLevel - 4;
    yellow = questLevel - 2;
    green = questLevel + 3;

    -- Gray Level based on level range.
    if (questLevel <= 13) then
        gray =  questLevel + 6;
    elseif (questLevel <= 39) then
        gray = (questLevel + math.ceil(questLevel / 10) + 5);
    else
        gray = (questLevel + math.ceil(questLevel / 5) + 1);
    end

    -- Double check for negative values
    if yellow <= 0 then
        yellow = questMinLevel;
    end

    if orange < questMinLevel then
        orange = questMinLevel;
    end

    if orange == yellow then
        orange = nil;
    end

    if red == orange or not orange then
        red = nil;
    end


    return red, orange, yellow, green, gray;
end