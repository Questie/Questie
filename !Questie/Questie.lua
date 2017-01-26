---------------------------------------------------------------------------------------------------
-- Name: Questie for Vanilla WoW
-- Revision: 3.69
-- Authors: Aero/Schaka/Logon/Dyaxler/everyone else
-- Website: https://github.com/AeroScripts/QuestieDev
-- Description: Questie started out being a simple backport of QuestHelper but it has grown beyond
-- it's original design into something better. Questie will show you where quests are available and
-- only display the quests you're eligible for based on level, profession, class, race etc. Questie
-- will also assist you in where or what is needed to complete a quest. Map notes, an arrow, custom
-- tooltips, quest tracker are also some of the tools included with Questie to assist you.
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
DEBUG_LEVEL = nil; --0 Low info --1 Medium info --2 very spammy
Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate");
QuestRewardCompleteButton = nil;
QuestAbandonOnAccept = nil;
QuestAbandonWithItemsOnAccept = nil;
QuestieVersion = 3.69;
---------------------------------------------------------------------------------------------------
-- WoW Functions --PERFORMANCE CHANGE--
---------------------------------------------------------------------------------------------------
local QGet_QuestLogTitle = GetQuestLogTitle;
local QGet_NumQuestLeaderBoards = GetNumQuestLeaderBoards;
local QSelect_QuestLogEntry = SelectQuestLogEntry;
local QGet_QuestLogLeaderBoard = GetQuestLogLeaderBoard;
local QGet_AbandonQuestName = GetAbandonQuestName;
local QGet_QuestLogQuestText = GetQuestLogQuestText;
local QGet_TitleText = GetTitleText;
---------------------------------------------------------------------------------------------------
function GetQuestLogTitle(index)
    return QGet_QuestLogTitle(index);
end
---------------------------------------------------------------------------------------------------
function GetQuestLogQuestText()
    Questie.needsUpdate = true;
    return QGet_QuestLogQuestText();
end
---------------------------------------------------------------------------------------------------
-- Setup Default Profile
---------------------------------------------------------------------------------------------------
function Questie:SetupDefaults()
    if not QuestieConfig then QuestieConfig = {
        ["alwaysShowQuests"] = true,
        ["arrowEnabled"] = true,
        ["corpseArrow"] = true,
        ["boldColors"] = false,
        ["maxLevelFilter"] = false,
        ["maxShowLevel"] = 3,
        ["minLevelFilter"] = false,
        ["minShowLevel"] = 5,
        ["trackerMinimize"] = false,
        ["showMapAids"] = true,
        ["showProfessionQuests"] = false,
        ["showTrackerHeader"] = false,
        ["showToolTips"] = true,
        ["trackerEnabled"] = true,
        ["trackerList"] = false,
        ["trackerScale"] = 1.0,
        ["trackerBackground"] = false,
        ["trackerAlpha"] = 0.4,
        ["resizeWorldmap"] = false,
        ["hideMinimapIcons"] = false,
        ["hideObjectives"] = false,
        ["getVersion"] = QuestieVersion,
    }
    end
    if not QuestieTrackerVariables then QuestieTrackerVariables = {
        ["position"] = {
            ["relativeTo"] = "UIParent",
            ["point"] = "LEFT",
            ["relativePoint"] = "LEFT",
            ["yOfs"] = 0,
            ["xOfs"] = 0,
        },
    }
    end
end
---------------------------------------------------------------------------------------------------
-- Setup Default Values
---------------------------------------------------------------------------------------------------
function Questie:CheckDefaults()
    -- Setups default QuestieConfig toggles for first time users
    if QuestieConfig.alwaysShowQuests == nil then
        QuestieConfig.alwaysShowQuests = true;
    end
    if QuestieConfig.arrowEnabled == nil then
        QuestieConfig.arrowEnabled = true;
    end
    if QuestieConfig.corpseArrow == nile then
        QuestieConfig.corpseArrow = true;
    end
    if QuestieConfig.boldColors == nil then
        QuestieConfig.boldColors = false;
    end
    if QuestieConfig.maxLevelFilter == nil then
        QuestieConfig.maxLevelFilter = false;
    end
    if QuestieConfig.maxShowLevel == nil then
        QuestieConfig.maxShowLevel = false;
        QuestieConfig.maxShowLevel = 3;
    end
    if QuestieConfig.minLevelFilter == nil then
        QuestieConfig.minLevelFilter = false;
    end
    if QuestieConfig.minShowLevel == nil then
        QuestieConfig.minShowLevel = false;
        QuestieConfig.minShowLevel = 5;
    end
    if QuestieConfig.trackerMinimize == nil then
        QuestieConfig.trackerMinimize = false;
    end
    if QuestieConfig.showMapAids == nil then
        QuestieConfig.showMapAids = true;
    end
    if QuestieConfig.showProfessionQuests == nil then
        QuestieConfig.showProfessionQuests = false;
    end
    if QuestieConfig.showTrackerHeader == nil then
        QuestieConfig.showTrackerHeader = false;
    end
    if QuestieConfig.showToolTips == nil then
        QuestieConfig.showToolTips = true;
    end
    if QuestieConfig.trackerEnabled == nil then
        QuestieConfig.trackerEnabled = true;
    end
    if QuestieConfig.trackerList == nil then
        QuestieConfig.trackerList = false;
    end
    if QuestieConfig.trackerScale == nil then
        QuestieConfig.trackerScale = 1.0;
    end
    if QuestieConfig.trackerBackground == nil then
        QuestieConfig.trackerBackground = false;
    end
    if QuestieConfig.trackerAlpha == nil then
        QuestieConfig.trackerAlpha = 0.4;
    end
    if QuestieConfig.resizeWorldmap == nil then
        QuestieConfig.resizeWorldmap = false;
    end
    if QuestieConfig.hideMinimapIcons == nil then
        QuestieConfig.hideMinimapIcons = false;
    end
    if QuestieConfig.hideObjectives == nil then
        QuestieConfig.hideObjectives = false;
    end
    -- Setups default QuestDB's for fresh characters
    if QuestieTrackedQuests == nil then
        QuestieTrackedQuests = {}
    end
    -- Version check
    if (not QuestieConfig.getVersion) or (QuestieConfig.getVersion < QuestieVersion) then
        Questie:ClearConfig("version");
    end
    -- If the user deletes a character and makes a new one by the same name then it will continue to use
    -- the same Saved Varibles file. This check will delete the Questie Saved Varibles file to prevent
    -- any quest issues for the new character.
    if UnitLevel("player") == 1 then
        local i = 0;
        for i,v in pairs(QuestieSeenQuests) do
            if (i < 3) then
                i = i + 1;
            else
                break;
            end
        end
        if i > 2 then
            Questie:NUKE("newcharacter");
        end
    end
    -- Sets some EQL3 settings to keep it from conflicting with Questie fetures
    EQL3_Player = UnitName("player").."-"..GetRealmName();
    if IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest") then
        if(not QuestlogOptions[EQL3_Player]) then return end
        if (QuestieConfig.showToolTips == true) then
            QuestlogOptions[EQL3_Player].MobTooltip = 0;
            QuestlogOptions[EQL3_Player].ItemTooltip = 0;
        else
            QuestlogOptions[EQL3_Player].MobTooltip = 1;
            QuestlogOptions[EQL3_Player].ItemTooltip = 1;
        end
        QuestlogOptions[EQL3_Player].RemoveCompletedObjectives = 0;
        QuestlogOptions[EQL3_Player].RemoveFinished = 0;
        QuestlogOptions[EQL3_Player].MinimizeFinished = 0;
    end
end
---------------------------------------------------------------------------------------------------
-- In Vanilla WoW there is no official Russian client so an addon was made to translate some of the
-- global strings. Two of the translated strings conflicted with Questie, displying the wrong info
-- on the World Map. This function simply over-rides those stings to force them back to english so
-- Questie can understand the returned sting in order to disply the correct locations and icons.
---------------------------------------------------------------------------------------------------
function Questie:BlockTranslations()
    if (IsAddOnLoaded("RuWoW") or IsAddOnLoaded("ProffBot")) or (IsAddOnLoaded("ruRU")) then
        QUEST_MONSTERS_KILLED = "%s slain: %d/%d"; -- Lists the monsters killed for the selected quest
        ERR_QUEST_ADD_KILL_SII = "%s slain: %d/%d"; -- %s is the monster name
    end
end
---------------------------------------------------------------------------------------------------
-- Cleans and resets the users Questie SavedVariables. Will also perform some quest and quest
-- tracker database clean up to purge stale/invalid entries. More notes below. Popup confirmation
-- of Yes or No - Popup has a 60 second timeout.
---------------------------------------------------------------------------------------------------
function Questie:ClearConfig(arg)
    if arg == "slash" then
        msg = "|cFFFFFF00You are about to clear your characters settings. This will NOT delete your quest database but it will clean it up a little. This will reset abandonded quests, and remove any finished or stale quest entries in the QuestTracker database. Your UI will be reloaded automatically to finalize the new settings.|n|nAre you sure you want to continue?|r";
    elseif arg == "version" then
        msg = "|cFFFFFF00VERSION CHECK!|n|nIt appears you have installed Questie for the very first time or you have recently upgraded to a new version. Your UI will automatically be reloaded and your QuestieConfig will be updated and cleaned of any stale entries. This will NOT clear your quest history.|n|nPlease click Yes to begin the update.|r";
    end
    StaticPopupDialogs["CLEAR_CONFIG"] = {
        text = TEXT(msg),
        button1 = TEXT(YES),
        button2 = TEXT(NO),
        OnAccept = function()
            -- Clears config
            QuestieConfig = {}
            -- Setup default settings
            QuestieConfig = {
                ["alwaysShowQuests"] = true,
                ["arrowEnabled"] = true,
                ["corpseArrow"] = true,
                ["boldColors"] = false,
                ["maxLevelFilter"] = false,
                ["maxShowLevel"] = 3,
                ["minLevelFilter"] = false,
                ["minShowLevel"] = 5,
                ["trackerMinimize"] = false,
                ["showMapAids"] = true,
                ["showProfessionQuests"] = false,
                ["showTrackerHeader"] = false,
                ["showToolTips"] = true,
                ["trackerEnabled"] = true,
                ["trackerList"] = false,
                ["trackerScale"] = 1.0,
                ["trackerBackground"] = false,
                ["trackerAlpha"] = 0.4,
                ["resizeWorldmap"] = false,
                ["hideMinimapIcons"] = false,
                ["hideObjectives"] = false,
                ["getVersion"] = QuestieVersion,
            }
            -- Clears tracker settings
            QuestieTrackerVariables = {}
            -- Setup default settings and repositions the QuestTracker against the left side of the screen.
            QuestieTrackerVariables = {
                ["position"] = {
                    ["relativeTo"] = "UIParent",
                    ["point"] = "CENTER",
                    ["relativePoint"] = "CENTER",
                    ["yOfs"] = 0,
                    ["xOfs"] = 0,
                },
            }
            -- The following will clean up the Quest Database removing stale/invalid entries.
            -- The (== 0 in QuestieSeenQuests) flag usually means a quest has been picked up and the (== -1
            -- in QuestieSeenQuests) flag means the quest has been abandonded. Once we remove these flags
            -- Questie will readd the quests based on what is in your log. A refresh of sorts without
            -- touching or resetting your finished quests. When the quest log is crawled, Questie will
            -- check any prerequired quests and flag all those as complete upto the quest in your chain
            -- that you're currently on.
            local index = 0
            for i,v in pairs(QuestieSeenQuests) do
                if (v == 0) or (v == -1) then
                    QuestieSeenQuests[i] = nil
                end
                index = index + 1
            end
            -- This wipes the QuestTracker database and forces a refresh of all tracked data.
            QuestieTrackedQuests = {}
            ReloadUI()
            Questie:CheckDefaults()
        end,
        timeout = 60,
        exclusive = 1,
        hideOnEscape = 1
    }
    StaticPopup_Show ("CLEAR_CONFIG")
end
---------------------------------------------------------------------------------------------------
-- Clears and deletes the users Questie SavedVariables. One option is for a user initiated NUKE and
-- the other option will execute when Questie senses a new level 1 character using a Saved Variables
-- file from a deleted character. Popup confirmation of Yes or No - Popup has a 60 second timeout.
---------------------------------------------------------------------------------------------------
function Questie:NUKE(arg)
    if arg == "slash" then
        msg = "|cFFFFFF00You are about to clear your characters settings. This will NOT delete your quest database but it will clean it up a little. This will reset abandonded quests, and remove any finished or stale quest entries in the QuestTracker database. Your UI will be reloaded automatically to finalize the new settings.|n|nAre you sure you want to continue?|r";
    elseif arg == "newcharacter" then
        msg = "|cFFFFFF00ERROR! Database Detected!|n|nIt appears that you've used this name for a previous character. There are entries in the QuestDatabase that need to be cleared in order for Questie to work properly with this character. Your UI will be reloaded automatically to clear your config.|n|nAre you sure you want to continue?|r";
    end
    StaticPopupDialogs["NUKE_CONFIG"] = {
        text = TEXT(msg),
        button1 = TEXT(YES),
        button2 = TEXT(NO),
        OnAccept = function()
            -- Clears all quests
            QuestieSeenQuests = {}
            -- Clears all tracked quests
            QuestieTrackedQuests = {}
            -- Clears config
            QuestieConfig = {}
            -- Setup default settings
            QuestieConfig = {
                ["alwaysShowQuests"] = true,
                ["arrowEnabled"] = true,
                ["corpseArrow"] = true,
                ["boldColors"] = false,
                ["maxLevelFilter"] = false,
                ["maxShowLevel"] = 3,
                ["minLevelFilter"] = false,
                ["minShowLevel"] = 5,
                ["trackerMinimize"] = false,
                ["showMapAids"] = true,
                ["showProfessionQuests"] = false,
                ["showTrackerHeader"] = false,
                ["showToolTips"] = true,
                ["trackerEnabled"] = true,
                ["trackerList"] = false,
                ["trackerScale"] = 1.0,
                ["trackerBackground"] = false,
                ["trackerAlpha"] = 0.4,
                ["resizeWorldmap"] = false,
                ["hideMinimapIcons"] = false,
                ["hideObjectives"] = false,
                ["getVersion"] = QuestieVersion,
            }
            -- Clears tracker settings
            QuestieTrackerVariables = {}
            QuestieTrackerVariables = {
                ["position"] = {
                    ["relativeTo"] = "UIParent",
                    ["point"] = "CENTER",
                    ["relativePoint"] = "CENTER",
                    ["yOfs"] = 0,
                    ["xOfs"] = 0,
                },
            }
            ReloadUI()
            Questie:CheckDefaults()
        end,
        timeout = 60,
        exclusive = 1,
        hideOnEscape = 1
    }
    StaticPopup_Show ("NUKE_CONFIG")
end
---------------------------------------------------------------------------------------------------
-- OnLoad Handler
---------------------------------------------------------------------------------------------------
function Questie:OnLoad()
    this:RegisterEvent("QUEST_LOG_UPDATE");
    this:RegisterEvent("QUEST_PROGRESS");
    this:RegisterEvent("MINIMAP_UPDATE_ZOOM");
    this:RegisterEvent("UI_INFO_MESSAGE");
    this:RegisterEvent("CHAT_MSG_SYSTEM");
    this:RegisterEvent("QUEST_ITEM_UPDATE");
    this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    this:RegisterEvent("PLAYER_LOGIN");
    this:RegisterEvent("ADDON_LOADED");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("CHAT_MSG_LOOT");
    this:RegisterEvent("QUEST_FINISHED");
    this:RegisterEvent("PLAYER_UNGHOST");
    this:RegisterEvent("PLAYER_DEAD");
    QuestAbandonOnAccept = StaticPopupDialogs["ABANDON_QUEST"].OnAccept;
    StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function()
        local hash = Questie:GetHashFromName(QGet_AbandonQuestName());
        QuestieTrackedQuests[hash] = nil;
        QuestieSeenQuests[hash] = -1;
        local index = 0
        for i,v in pairs(QuestieTrackedQuests) do
            if QuestieSeenQuests[i] ~= QuestieTrackedQuests[i] then
                QuestieTrackedQuests[i] = nil
            end
            index = index + 1
        end
        if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
            TomTomCrazyArrow:Hide()
        end
        --Questie:AddEvent("CHECKLOG", 0.135);
        QuestAbandonOnAccept();
    end
    QuestAbandonWithItemsOnAccept = StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept;
    StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept = function()
        local hash = Questie:GetHashFromName(QGet_AbandonQuestName());
        QuestieTrackedQuests[hash] = nil;
        QuestieSeenQuests[hash] = -1;
        local index = 0
        for i,v in pairs(QuestieTrackedQuests) do
            if QuestieSeenQuests[i] ~= QuestieTrackedQuests[i] then
                QuestieTrackedQuests[i] = nil
            end
            index = index + 1
        end
        if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
            TomTomCrazyArrow:Hide()
        end
        --Questie:AddEvent("CHECKLOG", 0.135);
        QuestAbandonWithItemsOnAccept();
    end
    QuestRewardCompleteButton = QuestRewardCompleteButton_OnClick;
    QuestRewardCompleteButton_OnClick = function()
        local questTitle = QGet_TitleText();
        local _, _, level, qName = string.find(questTitle, "%[(.+)%] (.+)")
        if qName == nil then
            qName = QGet_TitleText();
        else
            qName = qName
        end
        local hash = Questie:GetHashFromName(qName);
        QuestieCompletedQuestMessages[qName] = 1;
        if(not QuestieSeenQuests[hash]) or (QuestieSeenQuests[hash] == 0) or (QuestieSeenQuests[hash] == -1) then
            Questie:finishAndRecurse(hash)
            if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
                TomTomCrazyArrow:Hide()
            end
            Questie:AddEvent("UPDATE", 0.135);
        end
        QuestRewardCompleteButton();
    end
    Questie:NOTES_LOADED();
    SlashCmdList["QUESTIE"] = Questie_SlashHandler;
    SLASH_QUESTIE1 = "/questie";
end
QUESTIE_LAST_UPDATE_FINISHED = GetTime();
---------------------------------------------------------------------------------------------------
-- Questie Worldmap Toggle Button
---------------------------------------------------------------------------------------------------
Active = true;
function Questie:Toggle()
    if (QuestieConfig.showMapAids == true) or (QuestieConfig.alwaysShowQuests == true) or ((QuestieConfig.showMapAids == true) and (QuestieConfig.alwaysShowQuests == false)) then
        if(Active == true) then
            Active = false;
            QuestieMapNotes = {};
            QuestieAvailableMapNotes = {};
            Questie:RedrawNotes();
            LastQuestLogHashes = nil;
            LastCount = 0;
        else
            Active = true;
            LastQuestLogHashes = nil;
            LastCount = 0;
            Questie:CheckQuestLog();
            Questie:SetAvailableQuests()
            Questie:RedrawNotes();
        end
    else
        QuestieMapNotes = {};
        QuestieAvailableMapNotes = {};
        Questie:RedrawNotes();
        LastQuestLogHashes = nil;
        LastCount = 0;
    end
end
---------------------------------------------------------------------------------------------------
-- Questie OnUpdate Handler
---------------------------------------------------------------------------------------------------
QUESTIE_EVENTQUEUE = {};
function Questie:OnUpdate(elapsed)
    if(not GameTooltip.IsVisible(GameTooltip) ) then
        GameTooltip.QuestieDone = nil;
        GameTooltip.lastmonster = nil;
        GameTooltip.lastobjective = nil;
    end
    Astrolabe:OnUpdate(nil, elapsed);
    Questie:NOTES_ON_UPDATE(elapsed);
    if(table.getn(QUESTIE_EVENTQUEUE) > 0) then
        for k, v in pairs(QUESTIE_EVENTQUEUE) do
            if(v.EVENT == "UPDATE" and GetTime()- v.TIME > v.DELAY) then
                while(true) do
                    local d = Questie:UpdateQuests();
                    if(not d) then
                        table.remove(QUESTIE_EVENTQUEUE, 1);
                        break;
                    end
                end
                Astrolabe.ForceNextUpdate = true;
            elseif(v.EVENT == "CHECKLOG" and GetTime() - v.TIME > v.DELAY) then
                Questie:CheckQuestLog();
                table.remove(QUESTIE_EVENTQUEUE, 1);
                break;
            elseif(v.EVENT == "TRACKER" and GetTime() - v.TIME > v.DELAY) then
                QuestieTracker:updateTrackingFrameSize()
                table.remove(QUESTIE_EVENTQUEUE, 1);
                break;
            end
        end
    end
    local bgactive = false
    for i=1, MAX_BATTLEFIELD_QUEUES do
        bgstatus = GetBattlefieldStatus(i);
        if (bgstatus and bgstatus == "active") then
            bgactive = true
        end
    end
    if UnitIsDeadOrGhost("player") and (UnitIsDead("player") ~= 1) and (bgactive == false) then
        if (QuestieConfig.corpseArrow == true) then
            if DiedAtX and DiedAtY and DiedAtX ~= 0 and DiedAtY ~= 0 then
                local ddist, xDelta, yDelta = Astrolabe:ComputeDistance(DiedInCont, DiedInZone, DiedAtX, DiedAtY, continent, zone, xNote, yNote)
                local dtitle = "My Dead Corpse"
                local dpoint = {c = DiedInCont, z = DiedInZone, x = DiedAtX, y = DiedAtY}
                SetCrazyArrow(dpoint, ddist, dtitle);
                if (not WorldMapFrame:IsVisible() == nil) then
                    return
                end
                if (WorldMapFrame:IsVisible() == nil) and (WorldMapUpdateSpamOff == nil) then
                    SetMapToCurrentZone()
                    WorldMapUpdateSpamOff = true
                end
            end
        end
        if (QuestieConfig.arrowEnabled == false) and (QuestieConfig.corpseArrow == false) then
            TomTomCrazyArrow:Hide()
        end
    elseif UnitIsDeadOrGhost("player") and (bgactive == true) then
        TomTomCrazyArrow:Hide()
    end
end
---------------------------------------------------------------------------------------------------
-- Questie Event Handlers
---------------------------------------------------------------------------------------------------
QuestieCompletedQuestMessages = {};
-- 1 means WE KNOW it's complete
-- 0 means We've seen it and it's probably in the questlog
-- -1 means we know its abandonnd
--Had to add a delay(Even if it's small)
function Questie:AddEvent(EVENT, DELAY)
    local evnt = {};
    evnt.EVENT = EVENT;
    evnt.TIME = GetTime();
    evnt.DELAY = DELAY;
    table.insert(QUESTIE_EVENTQUEUE, evnt);
end
---------------------------------------------------------------------------------------------------
QUESTIE_LAST_UPDATE = GetTime();
QUESTIE_LAST_CHECKLOG = GetTime();
QUESTIE_UPDATE_EVENT = 0;
---------------------------------------------------------------------------------------------------
function Questie:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if(event =="ADDON_LOADED" and arg1 == "Questie") then
        --DEFAULT_CHAT_FRAME:AddMessage("**EVENT: ADDON_LOADED**")
        QuestieTracker:updateTrackingFrameSize()
        QuestieTracker:fillTrackingFrame()
    elseif( event == "MINIMAP_UPDATE_ZOOM" ) then
        Astrolabe:isMinimapInCity()
    elseif(event == "QUEST_LOG_UPDATE" or event == "QUEST_ITEM_UPDATE") then
        QUESTIE_UPDATE_EVENT = 1;
        if(GetTime() - QUESTIE_LAST_CHECKLOG > 0.1) then
            Questie:AddEvent("CHECKLOG", 0.135);
            QUESTIE_LAST_CHECKLOG = GetTime();
        end
        if(GetTime() - QUESTIE_LAST_UPDATE > 0.1) then
            Questie:AddEvent("UPDATE", 0.15);
            QUESTIE_LAST_UPDATE = GetTime();
        end
        Questie:BlockTranslations();
    elseif(event == "QUEST_FINISHED") then
        QUESTIE_UPDATE_EVENT = 1;
        Questie:AddEvent("CHECKLOG", 0.135);
        QUESTIE_LAST_CHECKLOG = GetTime();
        Questie:AddEvent("UPDATE", 0.15);
        QUESTIE_LAST_UPDATE = GetTime();
    elseif(event == "QUEST_PROGRESS") then
        if IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest") then
            if IsQuestCompletable() then
                local questTitle = QGet_TitleText();
                local _, _, level, qName = string.find(questTitle, "%[(.+)%] (.+)");
                if qName == nil then
                    qName = QGet_TitleText();
                else
                    qName = qName;
                end
                local hash = Questie:GetHashFromName(qName);
                QuestieCompletedQuestMessages[qName] = 1;
                if(not QuestieSeenQuests[hash]) or (QuestieSeenQuests[hash] == 0) or (QuestieSeenQuests[hash] == -1) then
                    Questie:finishAndRecurse(hash);
                    if (TomTomCrazyArrow:IsVisible() ~= nil) and (arrow_objective == hash) then
                        TomTomCrazyArrow:Hide();
                    end
                end
            end
        end
    elseif(event == "VARIABLES_LOADED") then
        Questie:debug_Print("VARIABLES_LOADED");
        if(not QuestieSeenQuests) then
            QuestieSeenQuests = {};
        end
        Questie:BlockTranslations();
        Questie:SetupDefaults();
        Questie:CheckDefaults();
        Astrolabe:isMinimapInCity()
    elseif(event == "PLAYER_LOGIN") then
        Questie:CheckQuestLog();
        Questie:AddEvent("UPDATE", 1.15);
        local f = GameTooltip:GetScript("OnShow");
        -- Proper tooltip hooking!
        if not f then
            GameTooltip:SetScript("OnShow", function(self)
                Questie:Tooltip(self, true);
            end);
        end
        local Blizz_GameTooltip_Show = GameTooltip.Show
        GameTooltip.Show = function(self)
            Questie:Tooltip(self);
            Blizz_GameTooltip_Show(self);
        end
        local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem
        GameTooltip.SetLootItem = function(self, slot)
            Bliz_GameTooltip_SetLootItem(self, slot);
            Questie:Tooltip(self, true);
        end
        local index = self:GetID()
        local Bliz_GameTooltip_SetQuestLogItem = GameTooltip.SetQuestLogItem
        GameTooltip.SetQuestLogItem = function(self, type, index)
            local link = GetQuestLogItemLink(type, index)
            if link then
                Bliz_GameTooltip_SetQuestLogItem(self, type, index);
            end
        end
        Questie:hookTooltipLineCheck();
        Questie:CheckDefaults();
        --DEFAULT_CHAT_FRAME:AddMessage("**EVENT: PLAYER_LOGIN**")
        QuestieTracker:updateTrackingFrameSize()
        QuestieTracker:fillTrackingFrame()
    elseif(event == "CHAT_MSG_LOOT") then
        local _, _, msg, item = string.find(arg1, "(You receive loot%:) (.+)");
        if msg then
            Questie:CheckQuestLog();
        end
        local _, _, msg, item = string.find(arg1, "(Received item%:) (.+)");
        if msg then
            Questie:CheckQuestLog();
        end
    elseif(event == "PLAYER_DEAD") then
        DiedInCont, DiedInZone, DiedAtX, DiedAtY = Astrolabe:GetCurrentPlayerPosition();
    elseif(event == "PLAYER_UNGHOST") then
        if (QuestieConfig.corpseArrow == false) and (QuestieConfig.arrowEnabled == true) then
            return
        elseif (QuestieConfig.corpseArrow == true) and (QuestieConfig.arrowEnabled == true) then
            TomTomCrazyArrow:Hide()
        elseif (QuestieConfig.corpseArrow == true) and (QuestieConfig.arrowEnabled == false) then
            TomTomCrazyArrow:Hide()
        end
        WorldMapUpdateSpamOff = nil
    end
end
---------------------------------------------------------------------------------------------------
-- Questie Parsing Shortcuts
---------------------------------------------------------------------------------------------------
function findFirst(haystack, needle)
    local i=string.find(haystack, " ");
    if i==nil then return nil; else return i-1; end
end
---------------------------------------------------------------------------------------------------
function findLast(haystack, needle)
    local i=string.gfind(haystack, ".*"..needle.."()")()
    if i==nil then return nil; else return i-1; end
end
---------------------------------------------------------------------------------------------------
-- Questie Slash Handler and Help Menu
---------------------------------------------------------------------------------------------------
QuestieFastSlash = {
    ["color"] = function()
    -- Default: False
        QuestieConfig.boldColors = not QuestieConfig.boldColors;
        if QuestieConfig.boldColors then
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker Alternate Colors enabled");
            QuestieTracker:fillTrackingFrame();
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker Alternate Colors disabled");
            QuestieTracker:fillTrackingFrame();
        end
    end,
    ["listdirection"] = function()
    -- Default: False
        if (QuestieConfig.trackerList == false) then
            StaticPopupDialogs["BOTTOM_UP"] = {
                text = "|cFFFFFF00You are about to change the way quests are listed in the QuestTracker. They will grow from bottom --> up and sorted by distance from top --> down.|n|nYour UI will be automatically reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerList = true
                    QuestieTrackerVariables = {};
                    QuestieTrackerVariables["position"] = {
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["relativeTo"] = "UIParent",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    };
                    ReloadUI()
                end,
                timeout = 120,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("BOTTOM_UP")
        elseif (QuestieConfig.trackerList == true) then
            StaticPopupDialogs["TOP_DOWN"] = {
                text = "|cFFFFFF00You are about to change the tracker back to it's default state. Quests will grow from top --> down and also sorted by distance from top --> down in the QuestTracker.|n|nYour UI will be reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerList = false
                    QuestieTrackerVariables = {};
                    QuestieTrackerVariables["position"] = {
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["relativeTo"] = "UIParent",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    };
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("TOP_DOWN")
        end
    end,
    ["showquests"] = function()
    -- Default: True
        QuestieConfig.alwaysShowQuests = not QuestieConfig.alwaysShowQuests;
        if QuestieConfig.alwaysShowQuests then
            DEFAULT_CHAT_FRAME:AddMessage("Quests and Objectives: Always show.");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Quests and Objectives: Show only when tracking.");
            Questie:Toggle();
            Questie:Toggle();
        end
    end,
    ["tooltips"] = function()
    -- Default: True
        QuestieConfig.showToolTips = not QuestieConfig.showToolTips;
        if QuestieConfig.showToolTips then
            ReloadUI()
            Questie:CheckDefaults()
            DEFAULT_CHAT_FRAME:AddMessage("Quest and Objective Tool Tips: On.");
        else
            ReloadUI()
            Questie:CheckDefaults()
            DEFAULT_CHAT_FRAME:AddMessage("Quest and Objective Tool Tips: Off.");
        end
    end,
    ["mapnotes"] = function()
    -- Default: True
        QuestieConfig.showMapAids = not QuestieConfig.showMapAids;
        if QuestieConfig.showMapAids then
            DEFAULT_CHAT_FRAME:AddMessage("Questie notes Active!");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Questie notes removed!");
            Questie:Toggle();
            Questie:Toggle();
        end
    end,
    ["arrow"] = function()
    -- Default: True
        QuestieConfig.arrowEnabled = not QuestieConfig.arrowEnabled;
        if QuestieConfig.arrowEnabled then
            DEFAULT_CHAT_FRAME:AddMessage("Quest Arrow will now be shown");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Quest Arrow will now be hidden");
            Questie:Toggle();
            Questie:Toggle();
        end
    end,
    ["corpsearrow"] = function()
    -- Default: True
        QuestieConfig.corpseArrow = not QuestieConfig.corpseArrow;
        if QuestieConfig.corpseArrow then
            DEFAULT_CHAT_FRAME:AddMessage("Corpse Arrow will now be shown");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Corpse Arrow will now be hidden");
            Questie:Toggle();
            Questie:Toggle();
            TomTomCrazyArrow:Hide()
        end
    end,
    ["tracker"] = function()
    -- Default: True
        if (QuestieConfig.trackerEnabled == true) then
            StaticPopupDialogs["HIDE_TRACKER"] = {
                text = "|cFFFFFF00You are about to disable the QuestieTracker. If you're using a QuestLog mod with a built in tracker then after your UI reloads you will be using that mods default tracker. Otherwise you'll use WoW's default tracker.|n|nYour UI will be automatically reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerEnabled = false
                    QuestieTracker:Hide();
                    QuestieTracker.frame:Hide();
                    ReloadUI()
                end,
                timeout = 120,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("HIDE_TRACKER")
        elseif (QuestieConfig.trackerEnabled == false) then
            StaticPopupDialogs["SHOW_TRACKER"] = {
                text = "|cFFFFFF00You are about to enabled the QuestieTracker. The previous quest tracker will be disabled.|n|nYour UI will be reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerEnabled = true
                    QuestieTracker:Show();
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("SHOW_TRACKER")
        end
    end,
    ["mintracker"] = function()
    -- Default: False
        if QuestieConfig.trackerMinimize then
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker Maximized");
            QuestieConfig.trackerMinimize = false
            QuestieTracker.frame:Show();
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker Minimized");
            QuestieConfig.trackerMinimize = true
            QuestieTracker.frame:Hide();
        end
    end,
    ["header"] = function()
    -- Default: False
        if (QuestieConfig.showTrackerHeader == false) then
            StaticPopupDialogs["TRACKER_HEADER_F"] = {
                text = "|cFFFFFF00Due to the way the QuestTracker frame is rendered, your UI will automatically be reloaded.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.showTrackerHeader = true;
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("TRACKER_HEADER_F")
        end
        if (QuestieConfig.showTrackerHeader == true) then
            StaticPopupDialogs["TRACKER_HEADER_T"] = {
                text = "|cFFFFFF00Due to the way the QuestTracker frame is rendered, your UI will automatically be reloaded.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.showTrackerHeader = false;
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("TRACKER_HEADER_T")
        end
    end,
    ["qtscale"] = function(arg)
    -- Default: Small
        if arg == "large" then
            QuestieConfig.trackerScale = 1.4;
            ReloadUI();
        elseif arg == "medium" then
            QuestieConfig.trackerScale = 1.2;
            ReloadUI();
        elseif arg == "small" then
            QuestieConfig.trackerScale = 1.0;
            ReloadUI();
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid option supplied!");
        end
    end,
    ["background"] = function()
    -- Default: false
        QuestieConfig.trackerBackground = not QuestieConfig.trackerBackground;
        if QuestieConfig.trackerBackground then
            ReloadUI();
        else
            ReloadUI();
        end
    end,
    ["backgroundalpha"] = function(args)
    -- Default: 4
        if args then
            local val = tonumber(args)/10;
            QuestieConfig.trackerAlpha = val;
            ReloadUI();
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid number supplied!");
        end
    end,
    ["minlevel"] = function()
    -- Default: False
        QuestieConfig.minLevelFilter = not QuestieConfig.minLevelFilter;
        if QuestieConfig.minLevelFilter then
            DEFAULT_CHAT_FRAME:AddMessage("Min-level filter on");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Min-level filter off");
            Questie:Toggle();
            Questie:Toggle();
        end
    end,
    ["maxlevel"] = function()
    -- Default: False
        QuestieConfig.maxLevelFilter = not QuestieConfig.maxLevelFilter;
        if QuestieConfig.maxLevelFilter then
            DEFAULT_CHAT_FRAME:AddMessage("Max-level filter on");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Max-level filter off");
            Questie:Toggle();
            Questie:Toggle();
        end
    end,
    ["setminlevel"] = function(args)
    -- Default: 5 levels below current level - which is the Blizzard default
        if args then
            local val = tonumber(args);
            QuestieConfig.minShowLevel = val;
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid number supplied!");
        end
    end,
    ["setmaxlevel"] = function(args)
    -- Default: Quest will not appear until current level is 3 levels above Blizzards suggested level
        if args then
            local val = tonumber(args);
            QuestieConfig.maxShowLevel = val;
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: invalid number supplied!");
        end
    end,
    ["professions"] = function()
    -- Default: False
        QuestieConfig.showProfessionQuests = not QuestieConfig.showProfessionQuests;
        if QuestieConfig.showProfessionQuests then
            DEFAULT_CHAT_FRAME:AddMessage("Profession quests will now be shown");
            Questie:Toggle();
            Questie:Toggle();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Profession quests will now be hidden");
            Questie:Toggle();
            Questie:Toggle();
        end
    end,
    ["resizemap"] = function()
    -- Default: False
        QuestieConfig.resizeWorldmap = not QuestieConfig.resizeWorldmap;
        if QuestieConfig.resizeWorldmap then
            ReloadUI();
        else
            ReloadUI();
        end
    end,
    ["clearconfig"] = function()
        Questie:ClearConfig("slash")
    end,
    ["NUKE"] = function()
    -- Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
        Questie:NUKE("slash")
    end,
    ["cleartracker"] = function()
    -- Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
        StaticPopupDialogs["CLEAR_TRACKER"] = {
            text = "|cFFFFFF00You are about to reset your QuestTracker. This will only reset it's saved location and place it in the center of your screen. Your UI will be reloaded automatically.|n|nAre you sure you want to continue?|r",
            button1 = TEXT(YES),
            button2 = TEXT(NO),
            OnAccept = function()
                -- Clears tracker settings
                QuestieTrackerVariables = {}
                -- Setup default settings and repositions the QuestTracker against the left side of the screen.
                QuestieTrackerVariables = {
                    ["position"] = {
                        ["relativeTo"] = "UIParent",
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    },
                }
                ReloadUI()
            end,
            timeout = 60,
            exclusive = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show ("CLEAR_TRACKER")
    end,
    ["settings"] = function()
        Questie:CurrentUserToggles()
    end,
    ["hideminimap"] = function()
        QuestieConfig.hideMinimapIcons = not QuestieConfig.hideMinimapIcons;
        if QuestieConfig.hideMinimapIcons then
            DEFAULT_CHAT_FRAME:AddMessage("  Questie: MiniMap icons will now be hidden!");
        else
            DEFAULT_CHAT_FRAME:AddMessage("  Questie: MiniMap icons will now be shown!");
        end
        Questie:Toggle();
        Questie:Toggle();
    end,
    ["hideobjectives"] = function()
        QuestieConfig.hideobjectives = not QuestieConfig.hideobjectives;
        if QuestieConfig.hideobjectives then
            DEFAULT_CHAT_FRAME:AddMessage("  Questie: Objective icons will now be hidden!");
        else
            DEFAULT_CHAT_FRAME:AddMessage("  Questie: Objective icons will now be shown!");
        end
        Questie:Toggle();
        Questie:Toggle();
    end,
    ["help"] = function()
        DEFAULT_CHAT_FRAME:AddMessage("Questie SlashCommand Help Menu:", 1, 0.75, 0);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie arrow |r-- |c0000ffc0(toggle)|r QuestArrow", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie background |r-- |c0000ffc0(toggle)|r QuestTracker background will always remain on", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie backgroundalpha |r-- |c0000ffc0(1-9)|r QuestTracker background alpha level (default=4)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie corpsearrow |r-- |c0000ffc0(toggle)|r CorpseArrow", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie clearconfig |r-- Resets Questie settings. It does NOT delete your quest data.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie cleartracker |r-- Relocates the QuestTracker to the center of your screen.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie color |r-- Select from two different color schemes", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie header |r-- |c0000ffc0(toggle)|r QuestTracker log counter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie hideminimap |r-- |c0000ffc0(toggle)|r Hides quest starter icons on mini map only", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie hideobjectives |r-- |c0000ffc0(toggle)|r Objective Icons", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie listdirection |r-- Lists quests Top-->Down or Bottom-->Up", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mapnotes |r-- |c0000ffc0(toggle)|r World/Minimap icons", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie maxlevel |r-- |c0000ffc0(toggle)|r Max-Level Filter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie minlevel |r-- |c0000ffc0(toggle)|r Min-Level Filter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mintracker |r-- |c0000ffc0(toggle)|r Minimize or Maximize QuestieTracker", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie NUKE |r-- Resets ALL Questie data and settings", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie professions |r-- |c0000ffc0(toggle)|r Profession quests", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setmaxlevel |r|c0000ffc0<number>|r -- Hides quests until <X> levels above players level (default=3)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setminlevel |r|c0000ffc0<number>|r -- Hides quests <X> levels below players level (default=5)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie settings |r-- Displays your current toggles and settings.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie showquests |r-- |c0000ffc0(toggle)|r Always show quests and objectives", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tooltips |r-- |c0000ffc0(toggle)|r Always show quest and objective tool tips", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tracker |r-- |c0000ffc0(toggle)|r QuestTracker", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie qtscale |r-- |c0000ffc0(small|medium|large)|r QuestTracker Size (default=small)", 0.75, 0.75, 0.75);
        if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then
            return
        elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
            DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie resizemap |r-- |c0000ffc0(toggle)|r Resize Worldmap", 0.75, 0.75, 0.75);
        end
    end,
};
---------------------------------------------------------------------------------------------------
function Questie_SlashHandler(msgbase)
    local space = findFirst(msgbase, " ");
    local msg, args;
    if not space or space == 1 then
        msg = msgbase;
    else
        msg = string.sub(msgbase, 1, space);
        args = string.sub(msgbase, space+2);
    end
    if QuestieFastSlash[msg] ~= nil then
        QuestieFastSlash[msg](args);
    else
        if (not msg or msg=="") then
            QuestieFastSlash["help"]();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Unknown operation: " .. msg .. " try /questie help");
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Displays to the player all Questie vars
---------------------------------------------------------------------------------------------------
function Questie:CurrentUserToggles()
    DEFAULT_CHAT_FRAME:AddMessage("Questie Settings:", 0.5, 0.5, 1)
    local Vars = {
        [1] = { "alwaysShowQuests" },
        [2] = { "arrowEnabled" },
        [3] = { "corpseArrow" },
        [4] = { "boldColors" },
        [5] = { "maxLevelFilter" },
        [6] = { "maxShowLevel" },
        [7] = { "minLevelFilter" },
        [8] = { "minShowLevel" },
        [9] = { "trackerMinimize" },
        [10] = { "showMapAids" },
        [11] = { "showProfessionQuests" },
        [12] = { "showTrackerHeader" },
        [13] = { "showToolTips" },
        [14] = { "trackerEnabled" },
        [15] = { "trackerList" },
        [16] = { "trackerScale" },
        [17] = { "trackerBackground" },
        [18] = { "trackerAlpha" },
        [19] = { "resizeWorldmap" },
        [20] = { "getVersion" },
        [21] = { "hideMinimapIcons" },
        [22] = { "hideObjectives" }
    }
    if QuestieConfig then
        i = 1
        v = 1
        while Vars[i] and Vars[i][v]do
            curVar = Vars[i][v]
            DEFAULT_CHAT_FRAME:AddMessage("  "..curVar.." = "..(tostring(QuestieConfig[curVar])), 0.5, 0.5, 1)
            i = i + 1
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Misc helper functions and short cuts
---------------------------------------------------------------------------------------------------
function Questie:LinkToID(link)
    if link then
        local _, _, id = string.find(link, "(%d+):")
        return tonumber(id)
    end
end
---------------------------------------------------------------------------------------------------
function GetCurrentMapID()
    local file = GetMapInfo()
    if file == nil then
        return -1
    end
    local zid = QuestieZones[file];
    if zid == nil then
        return -1
    else
        return zid[1];
    end
end
---------------------------------------------------------------------------------------------------
function Questie:MixString(mix, str)
    return Questie:MixInt(mix, Questie:HashString(str));
end
---------------------------------------------------------------------------------------------------
-- Computes an Adler-32 checksum.
function Questie:HashString(text)
    local a, b = 1, 0
    for i=1,string.len(text) do
        a = Questie:Modulo((a+string.byte(text,i)), 65521)
        b = Questie:Modulo((b+a), 65521)
    end
    return b*65536+a
end
---------------------------------------------------------------------------------------------------
-- Lua5 doesnt support mod math via the % operator
function Questie:Modulo(val, by)
    return val - math.floor(val/by)*by
end
---------------------------------------------------------------------------------------------------
function Questie:MixInt(hash, addval)
    return bit.lshift(hash, 6) + addval;
end
---------------------------------------------------------------------------------------------------
-- Returns the Levenshtein distance between the two given strings
-- credit to https://gist.github.com/Badgerati/3261142
function Questie:Levenshtein(str1, str2)
    local len1 = string.len(str1)
    local len2 = string.len(str2)
    local matrix = {}
    local cost = 0
    -- quick cut-offs to save time
    if (len1 == 0) then
        return len2
    elseif (len2 == 0) then
        return len1
    elseif (str1 == str2) then
        return 0
    end
    -- initialise the base matrix values
    for i = 0, len1, 1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, len2, 1 do
        matrix[0][j] = j
    end
    -- actual Levenshtein algorithm
    for i = 1, len1, 1 do
        for j = 1, len2, 1 do
            if (string.byte(str1,i) == string.byte(str2,j)) then
                cost = 0
            else
                cost = 1
            end
            matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
        end
    end
    -- return the last value - this is the Levenshtein distance
    return matrix[len1][len2]
end
---------------------------------------------------------------------------------------------------
-- End of misc helper functions and short cuts
---------------------------------------------------------------------------------------------------
SetMapToCurrentZone();
