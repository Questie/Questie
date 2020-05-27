---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.myJourney = {}
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")


local AceGUI = LibStub("AceGUI-3.0");
local journeyTreeFrame = nil;

-- manage the journey tree
function _QuestieJourney.myJourney:ManageTree(container)
    if not journeyTreeFrame then
        journeyTreeFrame = AceGUI:Create("TreeGroup");
        journeyTreeFrame:SetFullWidth(true);
        journeyTreeFrame:SetFullHeight(true);

        journeyTreeFrame.treeframe:SetWidth(220);

        local journeyTree = {};
        journeyTree = _QuestieJourney:GetHistory();
        journeyTreeFrame:SetTree(journeyTree);
        local latestMonth, latestYear = _QuestieJourney:GetMonthAndYearOfLatestEntry()
        if latestMonth and latestYear then
            journeyTreeFrame:SelectByPath(latestYear, latestMonth)
        end
        journeyTreeFrame:SetCallback("OnGroupSelected", function(group)
            Questie:Debug(DEBUG_DEVELOP, "[Journey] OnGroupSelected - Path:", group.localstatus.selected)

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
                        obj:SetText(_QuestieJourney:CreateObjectiveText(quest.Description));
                        f:AddChild(obj);
                    end

                    QuestieJourneyUtils:Spacer(f);

                    -- Only show party members if you weren't alone
                    if entry.Party and #entry.Party > 0 then

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
        _QuestieJourney.myJourney:ManageTree(container);
    end
end

--- Get the month and year of the latest entry in the Journey.
--- This is used to select it in the tree view.
---@return integer @The month of the latest entry
---@return integer @The year of the latest entry
function _QuestieJourney:GetMonthAndYearOfLatestEntry()
    local journeyEntries = _QuestieJourney:GetJourneyEntries()
    local years = {}
    local months = {}

    for year, _ in pairs(journeyEntries) do
        table.insert(years, year)
    end
    if not next(years) then
        return nil, nil
    end
    local maxYear = math.max(unpack(years))

    for month, _ in pairs(journeyEntries[maxYear]) do
        table.insert(months, month)
    end
    local maxMonth = math.max(unpack(months))

    return maxMonth, maxYear
end