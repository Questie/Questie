---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local AceGUI = LibStub("AceGUI-3.0");

--- Draw the "My Journey" tab
---@param container Frame
---@return SimpleGroup
function _QuestieJourney.myJourney:DrawTab(container)
    local header = AceGUI:Create("Heading");
    header:SetText(QuestieLocale:GetUIString('JOURNEY_RECENT_EVENTS'));
    header:SetFullWidth(true);
    container:AddChild(header);
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
            local qName = QuestieDB.QueryQuestSingle(Questie.db.char.journey[i].Quest, "name");
            if qName then
                local qName = Questie:Colorize(qName, 'gray');

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

    local treeHeader = AceGUI:Create("Heading");
    treeHeader:SetText(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")));
    treeHeader:SetFullWidth(true);
    container:AddChild(treeHeader);

    local noteButton = AceGUI:Create("Button");
    noteButton:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_BTN'));
    noteButton:SetPoint("RIGHT");
    noteButton:SetCallback("OnClick", NotePopup);
    container:AddChild(noteButton);

    QuestieJourneyUtils:Spacer(container);

    ---@class SimpleGroup
    local treeGroup = AceGUI:Create("SimpleGroup");
    treeGroup:SetLayout("fill");
    treeGroup:SetFullHeight(true);
    treeGroup:SetFullWidth(true);
    container:AddChild(treeGroup);

    return treeGroup
end
