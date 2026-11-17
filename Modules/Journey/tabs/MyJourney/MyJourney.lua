---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.myJourney = {}
_QuestieJourney.notePopup = nil

---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")
local journeyTreeFrame

local function ApplyStyledButton(button, width)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyStyledButton then
        QuestieOptionsControls.ApplyStyledButton(button.frame, width, button.text)
    end
end

-- manage the journey tree
function _QuestieJourney.myJourney:ManageTree(container)
    if not journeyTreeFrame then
        journeyTreeFrame = QuestieGUI:Create("TreeGroup");
        journeyTreeFrame:SetFullWidth(true);
        journeyTreeFrame:SetFullHeight(true);
        journeyTreeFrame:EnableButtonTooltips(false)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyTreeGroup then
            QuestieOptionsControls.ApplyJourneyTreeGroup(journeyTreeFrame)
        end
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
            QuestieOptionsControls.ApplyModernScrollbar(journeyTreeFrame.scrollbar)
        end

        journeyTreeFrame.treeframe:SetWidth(415);

        local journeyTree = _QuestieJourney:GetHistory();
        journeyTreeFrame:SetTree(journeyTree);
        local latestMonth, latestYear = _QuestieJourney:GetMonthAndYearOfLatestEntry()
        if latestMonth and latestYear then
            journeyTreeFrame:SelectByPath(latestYear, latestMonth)
        end
        journeyTreeFrame:SetCallback("OnGroupSelected", function(group)
            Questie.Debug(Questie.DEBUG_DEVELOP, "[Journey] OnGroupSelected - Path:", group.localstatus.selected)

            local _, _, e = strsplit("\001", group.localstatus.selected);

            if e then
                local master = group.frame.obj;
                master:ReleaseChildren();
                master:SetLayout("fill");
                master:SetFullWidth(true);
                master:SetFullHeight(true);

                local f = QuestieGUI:Create("ScrollFrame");
                f:SetLayout("flow");
                if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
                    QuestieOptionsControls.ApplyModernScrollbar(f.scrollbar)
                end
                master:AddChild(f);

                local header
                if QuestieOptionsControls and QuestieOptionsControls.CreateModernDividerGroup then
                    header = QuestieOptionsControls.CreateModernDividerGroup(f, "")
                else
                    header = QuestieGUI:Create("Heading")
                    header:SetFullWidth(true)
                    f:AddChild(header)
                end
                local function SetHeaderText(text)
                    if header.modernDivider and header.modernDivider.title then
                        header.modernDivider.title:SetText(text)
                    else
                        header:SetText(text)
                    end
                end

                QuestieJourneyUtils:Spacer(f);

                local created = QuestieGUI:Create("Label");
                created:SetFullWidth(true);

                local entry = Questie.db.char.journey[tonumber(e)];
                local timestamp = Questie:Colorize(QuestieLib.FormatDate(entry.Timestamp), 'lightBlue');

                if entry.Event == "Note" then
                    SetHeaderText(l10n('Note: %s', entry.Title));

                    local note = QuestieGUI:Create("Label");
                    note:SetFullWidth(true);
                    note:SetText(entry.Note);
                    f:AddChild(note);
                    QuestieJourneyUtils:Spacer(f);

                    created:SetText(l10n('Note Created: %s', timestamp));
                    f:AddChild(created);

                    QuestieJourneyUtils:Spacer(f);

                    local deleteButton = QuestieGUI:Create("Button");
                    deleteButton:SetText(l10n('Delete Note'));
                    deleteButton:SetWidth(150);
                    deleteButton:SetHeight(40);
                    ApplyStyledButton(deleteButton, 150)
                    deleteButton:SetCallback("OnClick", function()
                        Popup.Show("QUESTIE_DELETE_NOTE_CONFIRM", nil, nil, tonumber(e));
                    end);
                    f:AddChild(deleteButton);

                elseif entry.Event == "Level" then
                    SetHeaderText(l10n('You Reached Level %s', entry.NewLevel));

                    local congrats = QuestieGUI:Create("Label");
                    congrats:SetText(l10n('Congratulations! You reached %s !', entry.NewLevel));
                    congrats:SetFullWidth(true);
                    f:AddChild(congrats);

                    created:SetText(timestamp);
                    f:AddChild(created);

                elseif entry.Event == "Quest" then
                    local state
                    if entry.SubType == "Accept" then
                        state = l10n("Accepted");
                    elseif entry.SubType == "Complete" then
                        state = l10n("Completed");
                    elseif entry.SubType == "Abandon" then
                        state = l10n("Abandoned");
                    else
                        state = "ERROR!!";
                    end

                    local quest = QuestieDB.GetQuest(entry.Quest)
                    if quest then
                        local qName = quest.name;
                        SetHeaderText(l10n('Quest %s: %s', state, qName));


                        local obj = QuestieGUI:Create("Label");
                        obj:SetFullWidth(true);
                        obj:SetText(QuestieJourneyUtils.CreateObjectiveText(quest.Description));
                        f:AddChild(obj);
                    end

                    QuestieJourneyUtils:Spacer(f);

                    created:SetText(l10n('Quest %s: %s', state, timestamp));
                    f:AddChild(created);

                    local questIdLabel = QuestieGUI:Create("Label");
                    questIdLabel:SetFullWidth(true);
                    questIdLabel:SetText(l10n("Quest ID") .. l10n(": ") .. entry.Quest);
                    f:AddChild(questIdLabel);
                else
                    SetHeaderText("ERROR!!");
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
---@return number @The month of the latest entry
---@return number @The year of the latest entry
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
