
---@class QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney");
local _QuestieJourney = QuestieJourney.private
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
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions");
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation");

-- Useful doc about the AceGUI TreeGroup: https://github.com/hurricup/WoW-Ace3/blob/master/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}

local AceGUI = LibStub("AceGUI-3.0");

local journeyFrame = {};
local isWindowShown = false;
_QuestieJourney.lastOpenWindow = "journey";
local containerCache = nil;

function JumpToQuest(button)
    QuestieSearchResults:JumpToQuest(button)
    HideJourneyTooltip()
 end

local treeCache = nil;

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
            data.Party = QuestiePlayer:GetPartyMembers()

            tinsert(Questie.db.char.journey, data);

            _QuestieJourney:ManageJourneyTree(treeCache);

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
            text = QuestieLocale:GetUIString('JOURNEY_UNOBTAINABLE_TITLE'),
            children = {},
        }
    }

    local sortedQuestByLevel = QuestieLib:SortQuestsByLevel(quests)

    local availableCounter = 0
    local completedCounter = 0
    local unobtainableCounter = 0
    local repeatableCounter = 0

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local quest = levelAndQuest[2]
        local qId = quest.Id

        -- Only show quests which are not hidden
        if not quest.isHidden and QuestieCorrections.hiddenQuests and not QuestieCorrections.hiddenQuests[qId] then
            temp.value = qId
            temp.text = quests[qId]:GetColoredQuestName()

            -- Completed quests
            if Questie.db.char.complete[qId] then
                tinsert(zoneTree[2].children, temp)
                completedCounter = completedCounter + 1
            else
                -- Unobtainable quests
                if quest.exclusiveTo then
                    for _, exId in pairs(quest.exclusiveTo) do
                        if Questie.db.char.complete[exId] and zoneTree[4].children[qId] == nil then
                            tinsert(zoneTree[4].children, temp)
                            unobtainableCounter = unobtainableCounter + 1
                        end
                    end
                -- Unoptainable profession quests
                elseif not QuestieProfessions:HasProfessionAndSkill(quest.requiredSkill) then
                    tinsert(zoneTree[4].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Unoptainable reputation quests
                elseif not QuestieProfessions:HasReputation(quest.requiredMinRep, quest.requiredMaxRep) then
                    tinsert(zoneTree[4].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- Repeatable quests
                elseif quest.Repeatable then
                    tinsert(zoneTree[3].children, temp)
                    repeatableCounter = repeatableCounter + 1
                -- Available quests
                else
                    tinsert(zoneTree[1].children, temp)
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
    zoneTree[4].text = zoneTree[4].text .. ' [ '..  unobtainableCounter ..' ]';

    return zoneTree
end

function JourneySelectTabGroup(container, event, group)
    if not containerCache then
        containerCache = container;
    end

    container:ReleaseChildren();

    if group == "journey" then
        local treeGroup = _QuestieJourney.myJourney:DrawTab(container)
        treeCache = treeGroup
        _QuestieJourney.myJourney:ManageTree(treeGroup)
        _QuestieJourney.lastOpenWindow = "journey"
    elseif group == "zone" then
        _QuestieJourney.questsByZone:DrawTab(container);
        _QuestieJourney.lastOpenWindow = "zone";
    elseif group == "search" then
        QuestieSearchResults:DrawSearchTab(container);
        _QuestieJourney.lastOpenWindow = "search";
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
    tinsert(UISpecialFrames, "QuestieJourneyFrame");
end

function QuestieJourney:ToggleJourneyWindow()
    if not isWindowShown then
        PlaySound(882);

        JourneySelectTabGroup(containerCache, nil, _QuestieJourney.lastOpenWindow);

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
    ---@type JourneyEntry
    local entry = {};
    entry.Event = "Level";
    entry.NewLevel = level;
    entry.Timestamp = time();
    entry.Party = QuestiePlayer:GetPartyMembers()

    tinsert(Questie.db.char.journey, entry);
end

function QuestieJourney:AcceptQuest(questId)
    -- Add quest accept journey note.
    ---@type JourneyEntry
    local entry = {};
    entry.Event = "Quest";
    entry.SubType = "Accept";
    entry.Quest = questId;
    entry.Level = QuestiePlayer:GetPlayerLevel();
    entry.Timestamp = time();
    entry.Party = QuestiePlayer:GetPartyMembers()

    tinsert(Questie.db.char.journey, entry);
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
        ---@type JourneyEntry
        local entry = {};
        entry.Event = "Quest";
        entry.SubType = "Abandon";
        entry.Quest = questId;
        entry.Level = QuestiePlayer:GetPlayerLevel();
        entry.Timestamp = time()
        entry.Party = QuestiePlayer:GetPartyMembers()

        tinsert(Questie.db.char.journey, entry);
    end
end

function QuestieJourney:CompleteQuest(questId)
    -- Complete Quest added to Journey
    ---@class JourneyEntry
    local entry = {};
    entry.Event = "Quest";
    entry.SubType = "Complete";
    entry.Quest = questId;
    entry.Level = QuestiePlayer:GetPlayerLevel();
    entry.Timestamp = time();
    entry.Party = QuestiePlayer:GetPartyMembers()

    tinsert(Questie.db.char.journey, entry);
end
