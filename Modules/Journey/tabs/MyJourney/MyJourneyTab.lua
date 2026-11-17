---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

local function AddModernDivider(container, text)
    if QuestieOptionsControls and QuestieOptionsControls.CreateModernDividerGroup then
        QuestieOptionsControls.CreateModernDividerGroup(container, text)
        return
    end

    local header = QuestieGUI:Create("Heading")
    header:SetText(text)
    header:SetFullWidth(true)
    container:AddChild(header)
end

--- Draw the "My Journey" tab
---@param container Frame
---@return SimpleGroup
function _QuestieJourney.myJourney:DrawTab(container)
    AddModernDivider(container, l10n('Your Recent History'))
    QuestieJourneyUtils:Spacer(container);

    -- get last 5 elements from table for history
    local counter = #Questie.db.char.journey;
    local recentEvents = {};
    for i = counter, counter-4, -1 do
        if i <= 0 then
            break;
        end

        recentEvents[i] = {};
        recentEvents[i] = QuestieGUI:Create("Label");
        recentEvents[i]:SetFullWidth(true);

        local timestamp = Questie:Colorize(QuestieLib.FormatDate(Questie.db.char.journey[i].Timestamp) .. " ", 'lightBlue');

        -- if it's a quest event
        if Questie.db.char.journey[i].Event == "Quest" then
            local qName = QuestieDB.QueryQuestSingle(Questie.db.char.journey[i].Quest, "name");
            if qName then
                qName = Questie:Colorize(qName, 'gray');

                if Questie.db.char.journey[i].SubType == "Accept" then
                    recentEvents[i]:SetText(timestamp .. Questie:Colorize(l10n('You Accepted the quest %s', qName), 'yellow'));
                elseif Questie.db.char.journey[i].SubType == "Abandon" then
                    recentEvents[i]:SetText(timestamp .. Questie:Colorize(l10n('You Abandoned the quest %s', qName), 'yellow'));
                elseif Questie.db.char.journey[i].SubType == "Complete" then
                    recentEvents[i]:SetText(timestamp .. Questie:Colorize(l10n('You Completed the quest %s', qName), 'yellow'));
                end
            end
        elseif Questie.db.char.journey[i].Event == "Level" then
            local level = Questie:Colorize(l10n('Level %s', Questie.db.char.journey[i].NewLevel), 'gray');
            recentEvents[i]:SetText(timestamp .. Questie:Colorize(l10n('Congratulations! You reached %s !', level), 'yellow'));
        elseif Questie.db.char.journey[i].Event == "Note" then
            local title = Questie:Colorize(Questie.db.char.journey[i].Title, 'gray');
            recentEvents[i]:SetText(timestamp .. Questie:Colorize(l10n('Note Created: %s', title), 'yellow'));
        end

        container:AddChild(recentEvents[i]);
    end

    if counter == 0 then
        local justdoit = QuestieGUI:Create("Label");
        justdoit:SetFullWidth(true);
        justdoit:SetText(Questie:Colorize(l10n("It's about time you embark on your first Journey!"), 'yellow'));
        container:AddChild(justdoit);
    end

    QuestieJourneyUtils:Spacer(container);

    AddModernDivider(container, l10n("%s's Journey", GetUnitName("player", true)))

    local noteButtonText = l10n('Add New Adventure Note')
    local noteButton = QuestieGUI:Create("SimpleGroup")
    noteButton:SetLayout("Fill")
    noteButton:SetFullWidth(true)
    noteButton:SetHeight(32)

    if QuestieOptionsControls and QuestieOptionsControls.CreateStyledButton then
        local nativeButton = noteButton.nativeButton
        if not nativeButton then
            nativeButton = QuestieOptionsControls.CreateStyledButton(noteButton.content, 220)
            noteButton.nativeButton = nativeButton
        end
        nativeButton:Show()
        nativeButton:SetText(noteButtonText)
        nativeButton:SetPoint("LEFT", noteButton.content, "LEFT", 0, 0)
        nativeButton:SetScript("OnClick", _QuestieJourney.ShowNotePopup)
    else
        local legacyButton = QuestieGUI:Create("Button")
        legacyButton:SetText(noteButtonText)
        legacyButton:SetWidth(220)
        legacyButton:SetHeight(32)
        legacyButton:SetCallback("OnClick", _QuestieJourney.ShowNotePopup)
        noteButton:AddChild(legacyButton)
    end

    noteButton:SetCallback("OnRelease", function(widget)
        if widget.nativeButton then
            widget.nativeButton:Hide()
        end
    end)
    container:AddChild(noteButton)

    QuestieJourneyUtils:Spacer(container);

    ---@class SimpleGroup
    local treeGroup = QuestieGUI:Create("SimpleGroup");
    treeGroup:SetLayout("fill");
    treeGroup:SetFullHeight(true);
    treeGroup:SetFullWidth(true);
    container:AddChild(treeGroup);

    return treeGroup
end
