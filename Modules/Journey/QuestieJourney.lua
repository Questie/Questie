
---@class QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney");
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils");
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

QuestieJourney.continents = {}
QuestieJourney.zones = {}

local AceGUI = LibStub("AceGUI-3.0");

local journeyFrame = {};
local isWindowShown = false;
QuestieJourney.lastOpenWindow = "journey";
local containerCache = nil;

function JumpToQuest(button)
    QuestieSearchResults:JumpToQuest(button)
    HideJourneyTooltip()
 end

local journeyTreeFrame = nil;
local treeCache = nil;

local function SplitJourneyByDate()

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

        local e = {};
        e.idx = i;
        e.value = v;

        table.insert(dateTable[year][month], e);
    end

    -- now take those sorted dates and create a tree table
    local returnTable = {};
    for i, v in pairs(dateTable) do
        local yearTable = {
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

            for idx, e in pairs(dateTable[i][mon]) do

                local entry = e.value;
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
                    local quest = QuestieDB:GetQuest(entry.Quest)
                    if quest then
                        local qName = quest.name;
                        entryText = QuestieLocale:GetUIString('JOURNEY_TABLE_QUEST', state, qName);
                    else
                        entryText = QuestieLocale:GetUIString('JOURNEY_MISSING_QUEST');
                    end
                end

                local entryView = {
                    value = e.idx,
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
local function ManageJourneyTree(container)
    if not journeyTreeFrame then
        journeyTreeFrame = AceGUI:Create("TreeGroup");
        journeyTreeFrame:SetFullWidth(true);
        journeyTreeFrame:SetFullHeight(true);

        journeyTreeFrame.treeframe:SetWidth(220);

        local journeyTree = {};
        journeyTree = SplitJourneyByDate();
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

                QuestieJourneyUtils:Spacer(f);

                local created = AceGUI:Create("Label");
                created:SetFullWidth(true);


                local entry = Questie.db.char.journey[tonumber(e)];
                local day = CALENDAR_WEEKDAY_NAMES[ tonumber(date('%w', entry.Timestamp)) + 1 ];
                local month = CALENDAR_FULLDATE_MONTH_NAMES[ tonumber(date('%m', entry.Timestamp)) ];
                local timestamp = Questie:Colorize(date( day ..', '.. month ..' %d @ %H:%M' , entry.Timestamp), 'blue');

                if entry.Event == "Note" then

                    header:SetText(QuestieLocale:GetUIString('JOURNEY_TABLE_NOTE', entry.Title));

                    local note = AceGUI:Create("Label");
                    note:SetFullWidth(true);
                    note:SetText(Questie:Colorize( entry.Note , 'yellow'));
                    f:AddChild(note);
                    QuestieJourneyUtils:Spacer(f);

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
                    if quest then
                        local qName = quest.name;
                        header:SetText(QuestieLocale:GetUIString('JOURNEY_TABLE_QUEST', state, qName));


                        local obj = AceGUI:Create("Label");
                        obj:SetFullWidth(true);
                        obj:SetText(CreateObjectiveText(quest.Description));
                        f:AddChild(obj);
                    end

                    QuestieJourneyUtils:Spacer(f);

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

                        QuestieJourneyUtils:Spacer(f);
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
        ManageJourneyTree(container);
    end
end

-- function that draws the Tab for the "My Journey"
local function DrawJourneyTab(container)
    local head = AceGUI:Create("Heading");
    head:SetText(QuestieLocale:GetUIString('JOURNEY_RECENT_EVENTS'));
    head:SetFullWidth(true);
    container:AddChild(head);
    QuestieJourneyUtils:Spacer(container);

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
            if quest then
                local qName = Questie:Colorize(quest.name, 'gray');

                if Questie.db.char.journey[i].SubType == "Accept" then
                    recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_QUEST_ACCEPT', qName) , 'yellow')  );
                elseif Questie.db.char.journey[i].SubType == "Abandon" then
                    recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_QUEST_ABANDON', qName) , 'yellow')  );
                elseif Questie.db.char.journey[i].SubType == "Complete" then
                    recentEvents[i]:SetText( timestamp .. Questie:Colorize( QuestieLocale:GetUIString('JOURNEY_QUEST_COMPLETE', qName) , 'yellow')  );
                end
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

    QuestieJourneyUtils:Spacer(container);

    local treeHead = AceGUI:Create("Heading");
    treeHead:SetText(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")));
    treeHead:SetFullWidth(true);
    container:AddChild(treeHead);

    local noteBtn = AceGUI:Create("Button");
    noteBtn:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_BTN'));
    noteBtn:SetPoint("RIGHT");
    noteBtn:SetCallback("OnClick", NotePopup);
    container:AddChild(noteBtn);

    QuestieJourneyUtils:Spacer(container);

    local treeGroup = AceGUI:Create("SimpleGroup");
    treeGroup:SetLayout("fill");
    treeGroup:SetFullHeight(true);
    treeGroup:SetFullWidth(true);
    container:AddChild(treeGroup);

    treeCache = treeGroup;

    ManageJourneyTree(treeGroup);
end


local notesPopupWin = nil;
local notesPopupWinIsOpen = false;
function NotePopup()
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

        QuestieJourneyUtils:Spacer(frame);


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


            ManageJourneyTree(treeCache);

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

function ShowJourneyTooltip(button)
    if GameTooltip:IsShown() then
        return;
    end

    local qid = button:GetUserData('id');
    local quest = QuestieDB:GetQuest(tonumber(qid));
    if quest then
        GameTooltip:SetOwner(_G["QuestieJourneyFrame"], "ANCHOR_CURSOR");
        GameTooltip:AddLine("[".. quest.level .."] ".. quest.name);
        GameTooltip:AddLine("|cFFFFFFFF" .. CreateObjectiveText(quest.Description))
        GameTooltip:SetFrameStrata("TOOLTIP");
        GameTooltip:Show();
    end
end

function HideJourneyTooltip()
    if GameTooltip:IsShown() then
        GameTooltip:Hide();
    end
end

function CreateObjectiveText(desc)
    local objText = "";

    if desc then
        if type(desc) == "table" then
            for i, v in ipairs(desc) do
                objText = objText .. v .. "\n";
            end
        else
            objText = objText .. tostring(desc) .. "\n"
        end
    else
        objText = Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_AUTO_QUEST'), 'yellow');
    end

    return objText;
end

local zoneTreeFrame = nil;

-- TODO remove again once the call in manageZoneTree was removed
local function QuestFrame(f, quest)
    local header = AceGUI:Create("Heading");
    header:SetFullWidth(true);
    header:SetText(quest.name);
    f:AddChild(header);

    QuestieJourneyUtils:Spacer(f);

    local obj = AceGUI:Create("Label");
    obj:SetText(CreateObjectiveText(quest.Description));


    obj:SetFullWidth(true);
    f:AddChild(obj);
    QuestieJourneyUtils:Spacer(f);

    local questinfo = AceGUI:Create("Heading");
    questinfo:SetFullWidth(true);
    questinfo:SetText(QuestieLocale:GetUIString('JOURNEY_QUESTINFO'));
    f:AddChild(questinfo);

    -- Generic Quest Information
    local level = AceGUI:Create("Label");
    level:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_LEVEL'), 'yellow') .. quest.level);
    level:SetFullWidth(true);
    f:AddChild(level);

    local minLevel = AceGUI:Create("Label");
    minLevel:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_QUEST_MINLEVEL'), 'yellow') .. quest.requiredLevel);
    minLevel:SetFullWidth(true);
    f:AddChild(minLevel);

    local diff = AceGUI:Create("Label");
    diff:SetFullWidth(true);
    local red, orange, yellow, green, gray = QuestieJourney:GetLevelDifficultyRanges(quest.level, quest.requiredLevel);
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
    QuestieJourneyUtils:Spacer(f);

    -- Get Quest Start NPC
    if quest.Starts and quest.Starts.NPC then
        local startNPCGroup = AceGUI:Create("InlineGroup");
        startNPCGroup:SetLayout("List");
        startNPCGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_NPC'));
        startNPCGroup:SetFullWidth(true);
        f:AddChild(startNPCGroup);

        QuestieJourneyUtils:Spacer(startNPCGroup);

        local startnpc = QuestieDB:GetNPC(quest.Starts.NPC[1]);

        local startNPCName = AceGUI:Create("Label");
        startNPCName:SetText(startnpc.name);
        startNPCName:SetFontObject(GameFontHighlight);
        startNPCName:SetColor(255, 165, 0);
        startNPCName:SetFullWidth(true);
        startNPCGroup:AddChild(startNPCName);

        local startNPCZone = AceGUI:Create("Label");
        local startindex = 0;
        for i in pairs(startnpc.spawns) do
            startindex = i;
        end

        local continent = 'UNKNOWN ZONE';
        for i, v in ipairs(QuestieJourney.zones) do
            if v[startindex] then
                continent = QuestieJourney.zones[i][startindex];
            end
        end

        startNPCZone:SetText(continent);
        startNPCZone:SetFullWidth(true);
        startNPCGroup:AddChild(startNPCZone);

        local startx = startnpc.spawns[startindex][1][1];
        local starty = startnpc.spawns[startindex][1][2];
        if (startx ~= -1 or starty ~= -1) then
            local startNPCLoc = AceGUI:Create("Label");
            startNPCLoc:SetText("X: ".. startx .." || Y: ".. starty);
            startNPCLoc:SetFullWidth(true);
            startNPCGroup:AddChild(startNPCLoc);
        end

        local startNPCID = AceGUI:Create("Label");
        startNPCID:SetText("NPC ID: ".. startnpc.id);
        startNPCID:SetFullWidth(true);
        startNPCGroup:AddChild(startNPCID);

        QuestieJourneyUtils:Spacer(startNPCGroup);

        -- Also Starts
        if startnpc.questStarts then

            local alsostarts = AceGUI:Create("Label");
            alsostarts:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS'));
            alsostarts:SetColor(255, 165, 0);
            alsostarts:SetFontObject(GameFontHighlight);
            alsostarts:SetFullWidth(true);
            startNPCGroup:AddChild(alsostarts);

            local startQuests = {};
            local counter = 1;
            for i, v in pairs(startnpc.questStarts) do
                if not (v == quest.Id) then
                    startQuests[counter] = {};
                    startQuests[counter].frame = AceGUI:Create("InteractiveLabel");
                    startQuests[counter].quest = QuestieDB:GetQuest(v);
                    startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName());
                    startQuests[counter].frame:SetUserData('id', v);
                    startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.name);
                    startQuests[counter].frame:SetCallback("OnClick", JumpToQuest);
                    startQuests[counter].frame:SetCallback("OnEnter", ShowJourneyTooltip);
                    startQuests[counter].frame:SetCallback("OnLeave", HideJourneyTooltip);
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

        QuestieJourneyUtils:Spacer(startNPCGroup);

    end

    -- Get Quest Start GameObject
    if quest.Starts and quest.Starts.GameObject then
        local startGOGroup = AceGUI:Create("InlineGroup");
        startGOGroup:SetLayout("List");
        startGOGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_START_OBJ'));
        startGOGroup:SetFullWidth(true);
        f:AddChild(startGOGroup);

        QuestieJourneyUtils:Spacer(startGOGroup);

        for i, oid in pairs(quest.Starts.GameObject) do
            local startobj = QuestieDB:GetObject(oid);

            local startGOGName = AceGUI:Create("Label");
            startGOGName:SetText(startobj.name);
            startGOGName:SetFontObject(GameFontHighlight);
            startGOGName:SetColor(255, 165, 0);
            startGOGName:SetFullWidth(true);
            startGOGroup:AddChild(startGOGName);

            local starGOCZone = AceGUI:Create("Label");
            local startindex = 0;
            for i in pairs(startobj.spawns) do
                startindex = i;
            end

            local continent = 'UNKNOWN ZONE';
            for i, v in ipairs(QuestieJourney.zones) do
                if v[startindex] then
                    continent = QuestieJourney.zones[i][startindex];
                end
            end

            starGOCZone:SetText(continent);
            starGOCZone:SetFullWidth(true);
            startGOGroup:AddChild(starGOCZone);

            local startx = startobj.spawns[startindex][1][1];
            local starty = startobj.spawns[startindex][1][2];
            if (startx ~= -1 or starty ~= -1) then
                local startGOLoc = AceGUI:Create("Label");
                startGOLoc:SetText("X: ".. startx .." || Y: ".. starty);
                startGOLoc:SetFullWidth(true);
                startGOGroup:AddChild(startGOLoc);
            end

            local startGOID = AceGUI:Create("Label");
            startGOID:SetText("Object ID: ".. startobj.id);
            startGOID:SetFullWidth(true);
            startGOGroup:AddChild(startGOID);

            QuestieJourneyUtils:Spacer(startGOGroup);

            -- Also Starts
            if startobj.questStarts then

                local alsostarts = AceGUI:Create("Label");
                alsostarts:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_STARTS_GO'));
                alsostarts:SetColor(255, 165, 0);
                alsostarts:SetFontObject(GameFontHighlight);
                alsostarts:SetFullWidth(true);
                startGOGroup:AddChild(alsostarts);

                local startQuests = {};
                local counter = 1;
                for i, v in pairs(startobj.questStarts) do
                    if not (v == quest.Id) then
                        startQuests[counter] = {};
                        startQuests[counter].frame = AceGUI:Create("InteractiveLabel");
                        startQuests[counter].quest = QuestieDB:GetQuest(v);
                        startQuests[counter].frame:SetText(startQuests[counter].quest:GetColoredQuestName());
                        startQuests[counter].frame:SetUserData('id', v);
                        startQuests[counter].frame:SetUserData('name', startQuests[counter].quest.name);
                        startQuests[counter].frame:SetCallback("OnClick", JumpToQuest);
                        startQuests[counter].frame:SetCallback("OnEnter", ShowJourneyTooltip);
                        startQuests[counter].frame:SetCallback("OnLeave", HideJourneyTooltip);
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

            QuestieJourneyUtils:Spacer(startGOGroup);
        end
    end

    QuestieJourneyUtils:Spacer(f);

    -- Get Quest Turnin NPC
    if quest.Finisher and quest.Finisher.Name and quest.Finisher.Type == "monster" then
        local endNPCGroup = AceGUI:Create("InlineGroup");
        endNPCGroup:SetLayout("Flow");
        endNPCGroup:SetTitle(QuestieLocale:GetUIString('JOURNEY_END_NPC'));
        endNPCGroup:SetFullWidth(true);
        f:AddChild(endNPCGroup);
        QuestieJourneyUtils:Spacer(endNPCGroup);

        local endnpc = QuestieDB:GetNPC(quest.Finisher.Id);

        local endNPCName = AceGUI:Create("Label");
        endNPCName:SetText(endnpc.name);
        endNPCName:SetFontObject(GameFontHighlight);
        endNPCName:SetColor(255, 165, 0);
        endNPCName:SetFullWidth(true);
        endNPCGroup:AddChild(endNPCName);

        local endNPCZone = AceGUI:Create("Label");
        local endindex = 0;
        for i in pairs(endnpc.spawns) do
            endindex = i;
        end

        local continent = 'UNKNOWN ZONE';
        for i, v in ipairs(QuestieJourney.zones) do
            if v[endindex] then
                continent = QuestieJourney.zones[i][endindex];
            end
        end

        endNPCZone:SetText(continent);
        endNPCZone:SetFullWidth(true);
        endNPCGroup:AddChild(endNPCZone);

        local endx = endnpc.spawns[endindex][1][1];
        local endy = endnpc.spawns[endindex][1][2];
        if (endx ~= -1 or endy ~= -1) then
            local endNPCLoc = AceGUI:Create("Label");
            endNPCLoc:SetText("X: ".. endx .." || Y: ".. endy);
            endNPCLoc:SetFullWidth(true);
            endNPCGroup:AddChild(endNPCLoc);
        end

        local endNPCID = AceGUI:Create("Label");
        endNPCID:SetText("NPC ID: ".. endnpc.id);
        endNPCID:SetFullWidth(true);
        endNPCGroup:AddChild(endNPCID);

        QuestieJourneyUtils:Spacer(endNPCGroup);

        -- Also ends
        if endnpc.endQuests then
            local alsoends = AceGUI:Create("Label");
            alsoends:SetText(QuestieLocale:GetUIString('JOURNEY_ALSO_ENDS'));
            alsoends:SetFontObject(GameFontHighlight);
            alsoends:SetColor(255, 165, 0);
            alsoends:SetFullWidth(true);
            endNPCGroup:AddChild(alsoends);

            local endQuests = {};
            local counter = 1;
            for i, v in ipairs(endnpc.endQuests) do
                if not (v == quest.Id) then
                    endQuests[counter] = {};
                    endQuests[counter].frame = AceGUI:Create("InteractiveLabel");
                    endQuests[counter].quest = QuestieDB:GetQuest(v);
                    endQuests[counter].frame:SetText(endQuests[counter].quest:GetColoredQuestName());
                    endQuests[counter].frame:SetUserData('id', v);
                    endQuests[counter].frame:SetUserData('name', endQuests[counter].quest.name);
                    endQuests[counter].frame:SetCallback("OnClick", JumpToQuest);
                    endQuests[counter].frame:SetCallback("OnEnter", ShowJourneyTooltip);
                    endQuests[counter].frame:SetCallback("OnLeave", HideJourneyTooltip);
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

        QuestieJourneyUtils:Spacer(endNPCGroup);

        -- Fix for sometimes the scroll content will max out and not show everything until window is resized
        f.content:SetHeight(10000);

    end
end

-- Manage the zone tree itself and the contents of the per-quest window
local function ManageZoneTree(container, zt)
    if not zoneTreeFrame then
        zoneTreeFrame = AceGUI:Create("TreeGroup");
        zoneTreeFrame:SetFullWidth(true);
        zoneTreeFrame:SetFullHeight(true);
        zoneTreeFrame:SetTree(zt);

        zoneTreeFrame.treeframe:SetWidth(220);

        zoneTreeFrame:SetCallback("OnGroupSelected", function(group)

            -- if they clicked on the header, don't do anything
            local sel = group.localstatus.selected;
            if sel == "a" or sel == "c" or sel == "r" or sel == "u" then
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

            local _, qid = strsplit("\001", sel);
            qid = tonumber(qid);

            -- TODO replace with fillQuestDetailsFrame and remove the questFrame function
            local quest = QuestieDB:GetQuest(qid);
            if quest then
                QuestFrame(f, quest);
            end
        end);

        container:AddChild(zoneTreeFrame);

    else
        container:ReleaseChildren();
        zoneTreeFrame = nil;
        ManageZoneTree(container, zt);
    end

end

  -- function that draws the Tab for Zone Quests
local function DrawZoneQuestTab(container)
    -- Header
    local header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_HEAD'));
    header:SetFullWidth(true);
    container:AddChild(header);
    QuestieJourneyUtils:Spacer(container);

    local CDropdown = AceGUI:Create("LQDropdown");
    local zDropdown = AceGUI:Create("LQDropdown");
    local treegroup = AceGUI:Create("SimpleGroup");

    -- Dropdown for Continent
    CDropdown:SetList(QuestieJourney.continents);
    CDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_CONT'));

    local currentContinentId = QuestiePlayer:GetCurrentContinentId()
    if currentContinentId > 0 then
        CDropdown:SetValue(currentContinentId)
    end

    CDropdown:SetCallback("OnValueChanged", function(key, checked)
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[key.value])
        zDropdown:SetList(QuestieJourney.zones[key.value], sortedZones);
        zDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'));
        zDropdown:SetDisabled(false);
    end)
    container:AddChild(CDropdown);

    -- Dropdown for Zone
    zDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'));

    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if currentZoneId > 0 then
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[currentContinentId])
        zDropdown:SetList(QuestieJourney.zones[currentContinentId], sortedZones);
        zDropdown:SetValue(currentZoneId)
        local zoneTree = CollectZoneQuests(currentZoneId)
        -- Build Tree
        ManageZoneTree(treegroup, zoneTree);
    else
        zDropdown:SetDisabled(true);
    end

    zDropdown:SetCallback("OnValueChanged", function(key, checked)
        -- Create Tree View
        local zoneTree = CollectZoneQuests(key.value);
        -- Build Tree
        ManageZoneTree(treegroup, zoneTree);
    end);
    container:AddChild(zDropdown);

    QuestieJourneyUtils:Spacer(container);

    header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_QUESTS'));
    header:SetFullWidth(true);
    container:AddChild(header);

    QuestieJourneyUtils:Spacer(container);

    treegroup:SetFullHeight(true);
    treegroup:SetFullWidth(true);
    treegroup:SetLayout("fill");
    container:AddChild(treegroup);
end

-- Get all the available/completed/repeatable/unavailable quests

---@param zoneId integer @The zone ID (Check `LangZoneLookup`)
---@return table<integer,any> @The zoneTree table which represents the list of all the different quests
function CollectZoneQuests(zoneId)
    local quests = QuestieDB:GetQuestsByZoneId(zoneId)
    local temp = {}

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
        },
        [3] = {
            value = "r",
            text = QuestieLocale:GetUIString('JOURNEY_REPEATABLE_TITLE'),
            children = {},
        },
        [4] = {
            value = "u",
            text = QuestieLocale:GetUIString('JOURNEY_UNOPTAINABLE_TITLE'),
            children = {},
        }
    }

    local sortedQuestByLevel = QuestieLib:SortQuestsByLevel(quests)

    local availableCounter = 0
    local completedCounter = 0
    local unoptainableCounter = 0
    local repeatableCounter = 0

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local quest = levelAndQuest[2]
        local qId = quest.Id

        -- Only show quests which are not hidden
        if not quest.Hidden and QuestieCorrections.hiddenQuests and not QuestieCorrections.hiddenQuests[qId] then
            temp.value = qId
            temp.text = quests[qId]:GetColoredQuestName()

            -- Completed quests
            if Questie.db.char.complete[qId] then
                table.insert(zoneTree[2].children, temp)
                completedCounter = completedCounter + 1
            else
                -- Unoptainable quests
                if quest.exclusiveTo then
                    for _, exId in pairs(quest.exclusiveTo) do
                        if Questie.db.char.complete[exId] and zoneTree[4].children[qId] == nil then
                            table.insert(zoneTree[4].children, temp)
                            unoptainableCounter = unoptainableCounter + 1
                        end
                    end
                end
                -- Repeatable quests
                if quest.Repeatable == 1 then
                    table.insert(zoneTree[3].children, temp)
                    repeatableCounter = repeatableCounter + 1
                -- Available quests
                else
                    table.insert(zoneTree[1].children, temp)
                    availableCounter = availableCounter + 1;
                end
            end
            temp = {}
        end
    end

    local totalCounter = availableCounter + completedCounter;
    zoneTree[1].text = zoneTree[1].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]';
    zoneTree[2].text = zoneTree[2].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]';
    zoneTree[3].text = zoneTree[3].text .. ' [ '..  repeatableCounter ..' ]';
    zoneTree[4].text = zoneTree[4].text .. ' [ '..  unoptainableCounter ..' ]';

    return zoneTree
end

function JourneySelectTabGroup(container, event, group)
    if not containerCache then
        containerCache = container;
    end

    container:ReleaseChildren();

    if group == "journey" then
        DrawJourneyTab(container);
        QuestieJourney.lastOpenWindow = "journey";
    elseif group == "zone" then
        DrawZoneQuestTab(container);
        QuestieJourney.lastOpenWindow = "zone";
    elseif group == "search" then
        QuestieSearchResults:DrawSearchTab(container);
        QuestieJourney.lastOpenWindow = "search";
    end
end

QuestieJourney.tabGroup = nil;
function QuestieJourney:Initialize()
    QuestieJourney.continents = LangContinentLookup
    QuestieJourney.zones = LangZoneLookup
    journeyFrame.frame = AceGUI:Create("Frame");

    journeyFrame.frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")));
    journeyFrame.frame:SetLayout("Fill");

    QuestieJourney.tabGroup = AceGUI:Create("TabGroup")
    QuestieJourney.tabGroup:SetLayout("Flow");
    QuestieJourney.tabGroup:SetTabs({
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
    QuestieJourney.tabGroup:SetCallback("OnGroupSelected", JourneySelectTabGroup);
    QuestieJourney.tabGroup:SelectTab("journey");

    journeyFrame.frame:AddChild(QuestieJourney.tabGroup);

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

function QuestieJourney:ToggleJourneyWindow()
    if not isWindowShown then
        PlaySound(882);

        JourneySelectTabGroup(containerCache, nil, QuestieJourney.lastOpenWindow);

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

function QuestieJourney:PlayerLevelUp(level)
    -- Complete Quest added to Journey
    local data = {};
    data.Event = "Level";
    data.NewLevel = level;
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
end

function QuestieJourney:AcceptQuest(questId)
    -- Add quest accept journey note.
    local data = {};
    data.Event = "Quest";
    data.SubType = "Accept";
    data.Quest = questId;
    data.Level = QuestiePlayer:GetPlayerLevel();
    data.Timestamp = time();
    data.Party = {};

    if GetHomePartyInfo() then
        data.Party = {};
        local p = {};
        for i, v in pairs(GetHomePartyInfo()) do
            p.Name = v;
            p.Class,_ ,_ = UnitClass(v);
            p.Level = UnitLevel(v);
            table.insert(data.Party, p);
        end
    end

    table.insert(Questie.db.char.journey, data);
end

function QuestieJourney:AbandonQuest(questId)
    -- Abandon Quest added to Journey
    -- first check to see if the quest has been completed already or not
    local skipAbandon = false;
    for i in ipairs(Questie.db.char.journey) do

        local entry = Questie.db.char.journey[i];
        if entry.Event == "Quest" then
            if entry.Quest == questId then
                if entry.SubType == "Complete" then
                    skipAbandon = true;
                end
            end
        end
    end

    if not skipAbandon then
        local data = {};
        data.Event = "Quest";
        data.SubType = "Abandon";
        data.Quest = questId;
        data.Level = QuestiePlayer:GetPlayerLevel();
        data.Timestamp = time()
        data.Party = {};

        if GetHomePartyInfo() then
            local p = {};
            for i, v in pairs(GetHomePartyInfo()) do
                p.Name = v;
                p.Class, _, _ = UnitClass(v);
                p.Level = UnitLevel(v);
                table.insert(data.Party, p);
            end
        end

        table.insert(Questie.db.char.journey, data);
    end
end

function QuestieJourney:CompleteQuest(questId)
     -- Complete Quest added to Journey
    local data = {};
    data.Event = "Quest";
    data.SubType = "Complete";
    data.Quest = questId;
    data.Level = QuestiePlayer:GetPlayerLevel();
    data.Timestamp = time();
    data.Party = {};

    if GetHomePartyInfo() then
        local p = {};
        for i, v in pairs(GetHomePartyInfo()) do
            p.Name = v;
            p.Class, _, _ = UnitClass(v);
            p.Level = UnitLevel(v);
            table.insert(data.Party, p);
        end
    end

    table.insert(Questie.db.char.journey, data);
end
