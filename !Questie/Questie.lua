---------------------------------------------------------------------------------------------------
--Name: Questie for Vanilla WoW
--Revision: 3.70
--Authors: Aero/Schaka/Logon/Dyaxler/Muehe/Zoey/everyone else
--Website: https://github.com/AeroScripts/QuestieDev
--Description: Questie started out being a simple backport of QuestHelper but it has grown beyond
--it's original design into something better. Questie will show you where quests are available and
--only display the quests you're eligible for based on level, profession, class, race etc. Questie
--will also assist you in where or what is needed to complete a quest. Map notes, an arrow, custom
--tooltips, quest tracker are also some of the tools included with Questie to assist you.
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
Questie = CreateFrame("Frame", "QuestieLua", UIParent, "ActionButtonTemplate");
QuestieVersion = 3.70;
---------------------------------------------------------------------------------------------------
--Setup Default Profile
---------------------------------------------------------------------------------------------------
function Questie:SetupDefaults()
    if not QuestieSeenQuests then QuestieSeenQuests = {}; end
    if not QuestieCachedQuests then QuestieCachedQuests = {}; end
    if not QuestieConfig then QuestieConfig = {
        ["alwaysShowObjectives"] = true,
        ["arrowEnabled"] = true,
        ["arrowTime"] = true,
        ["boldColors"] = false,
        ["clusterQuests"] = true,
        ["corpseArrow"] = true,
        ["getVersion"] = QuestieVersion,
        ["hideMinimapIcons"] = false,
        ["hideObjectives"] = false,
        ["maxLevelFilter"] = true,
        ["maxShowLevel"] = 7,
        ["minimapButton"] = true,
        ["minimapZoom"] = false,
        ["minLevelFilter"] = true,
        ["minShowLevel"] = 4,
        ["resizeWorldmap"] = false,
        ["showMapNotes"] = true,
        ["showProfessionQuests"] = false,
        ["showToolTips"] = true,
        ["showTrackerHeader"] = false,
        ["trackerAlpha"] = 0.6,
        ["trackerBackground"] = false,
        ["trackerEnabled"] = true,
        ["trackerList"] = false,
        ["trackerMinimize"] = false,
        ["trackerScale"] = 1.0,
    };
    end
    --Setup default settings and repositions the QuestTracker against the left side of the screen.
    if not QuestieTrackerVariables then QuestieTrackerVariables = {
        ["position"] = {
            ["relativeTo"] = "UIParent",
            ["point"] = "CENTER",
            ["relativePoint"] = "CENTER",
            ["yOfs"] = 0,
            ["xOfs"] = 0,
        },
    };
    end
end
---------------------------------------------------------------------------------------------------
--Setup Default Values
---------------------------------------------------------------------------------------------------
function Questie:CheckDefaults()
    --Setups default QuestieConfig toggles for first time users. These are necessary to prevent nil
    --errors from occurring after creating a new character or clearing the config
    if QuestieConfig.alwaysShowObjectives == nil then
        QuestieConfig.alwaysShowObjectives = true;
    end
    if QuestieConfig.arrowEnabled == nil then
        QuestieConfig.arrowEnabled = true;
    end
    if QuestieConfig.arrowTime == nil then
        QuestieConfig.arrowTime = false;
    end
    if QuestieConfig.boldColors == nil then
        QuestieConfig.boldColors = false;
    end
    if QuestieConfig.clusterQuests == nil then
        QuestieConfig.clusterQuests = true;
    end
    if QuestieConfig.corpseArrow == nil then
        QuestieConfig.corpseArrow = true;
    end
    if QuestieConfig.hideMinimapIcons == nil then
        QuestieConfig.hideMinimapIcons = false;
    end
    if QuestieConfig.hideObjectives == nil then
        QuestieConfig.hideObjectives = false;
    end
    if QuestieConfig.maxLevelFilter == nil then
        QuestieConfig.maxLevelFilter = true;
    end
    if QuestieConfig.maxShowLevel == nil then
        QuestieConfig.maxShowLevel = 7;
    end
    if QuestieConfig.minimapButton == nil then
        QuestieConfig.minimapButton = true;
    elseif QuestieConfig.minimapButton == false then
        Questie.minimapButton:Hide();
    end
    if QuestieConfig.minimapZoom == nil then
        QuestieConfig.minimapZoom = false;
    end
    if QuestieConfig.minLevelFilter == nil then
        QuestieConfig.minLevelFilter = true;
    end
    if QuestieConfig.minShowLevel == nil then
        QuestieConfig.minShowLevel = 4;
    end
    if QuestieConfig.resizeWorldmap == nil then
        QuestieConfig.resizeWorldmap = false;
    end
    if QuestieConfig.showMapNotes == nil then
        QuestieConfig.showMapNotes = true;
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
    if QuestieConfig.trackerAlpha == nil then
        QuestieConfig.trackerAlpha = 0.6;
    end
    if QuestieConfig.trackerBackground == nil then
        QuestieConfig.trackerBackground = false;
    end
    if QuestieConfig.trackerEnabled == nil then
        QuestieConfig.trackerEnabled = true;
    end
    if QuestieConfig.trackerList == nil then
        QuestieConfig.trackerList = false;
    end
    if QuestieConfig.trackerMinimize == nil then
        QuestieConfig.trackerMinimize = false;
    end
    if QuestieConfig.trackerScale == nil then
        QuestieConfig.trackerScale = 1.0;
    end
    --Version check
    if (not QuestieConfig.getVersion) or (QuestieConfig.getVersion ~= QuestieVersion) then
        Questie:ClearConfig("version");
    end
    --Setups default QuestDB's for fresh characters
    if QuestieCachedQuests == nil then
        QuestieCachedQuests = {};
    end
    --If the user deletes a character and makes a new one by the same name then it will continue to use
    --the same Saved Variables file. This check will delete the Questie Saved Variables file to prevent
    --any quest issues for the new character
    if UnitLevel("player") == 1 then
        local i = 0;
        for _,_ in pairs(QuestieSeenQuests) do
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
    --Sets some EQL3 settings to keep it from conflicting with Questie features
    EQL3_Player = UnitName("player").."-"..GetRealmName();
    if IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest") then
        if (not QuestlogOptions[EQL3_Player]) then return; end
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
--In Vanilla WoW there is no official Russian client so an addon was made to translate some of the
--global strings. Two of the translated strings conflicted with Questie, displaying the wrong info
--on the World Map. This function simply over-rides those stings to force them back to English so
--Questie can understand the returned sting in order to display the correct locations and icons.
---------------------------------------------------------------------------------------------------
function Questie:BlockTranslations()
    if (IsAddOnLoaded("RuWoW") or IsAddOnLoaded("ProffBot")) or (IsAddOnLoaded("ruRU")) then
        QUEST_MONSTERS_KILLED = "%s slain: %d/%d"; --Lists the monsters killed for the selected quest
        ERR_QUEST_ADD_KILL_SII = "%s slain: %d/%d"; --%s is the monster name
    end
end
---------------------------------------------------------------------------------------------------
--OnLoad Handler
---------------------------------------------------------------------------------------------------
function Questie:OnLoad()
    this:RegisterEvent("ADDON_LOADED");
    this:RegisterEvent("CHAT_MSG_LOOT");
    this:RegisterEvent("MINIMAP_UPDATE_ZOOM");
    this:RegisterEvent("PLAYER_DEAD");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
    this:RegisterEvent("PLAYER_LEAVING_WORLD");
    this:RegisterEvent("PLAYER_LEVEL_UP");
    this:RegisterEvent("PLAYER_LOGIN");
    this:RegisterEvent("PLAYER_UNGHOST");
    this:RegisterEvent("QUEST_PROGRESS");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    Questie:NOTES_LOADED();
    QuestieTracker:BlizzardHooks();
    SlashCmdList["QUESTIE"] = Questie_SlashHandler;
    SLASH_QUESTIE1 = "/questie";
end
---------------------------------------------------------------------------------------------------
--QuestEvents OnLoad Handler
---------------------------------------------------------------------------------------------------
function Questie:OnLoad_QuestEvents()
    this:RegisterEvent("QUEST_LOG_UPDATE");
    this:RegisterEvent("QUEST_ITEM_UPDATE");
end
---------------------------------------------------------------------------------------------------
--Global vars
---------------------------------------------------------------------------------------------------
IsQuestieActive = true;
QUESTIE_EVENTQUEUE = {};
QuestieCompletedQuestMessages = {};
QUESTIE_LAST_UPDATE_FINISHED = GetTime();
QUESTIE_LAST_UPDATE = GetTime();
QUESTIE_LAST_CHECKLOG = GetTime();
QUESTIE_LAST_UPDATECACHE = GetTime();
QUESTIE_LAST_TRACKER = GetTime();
QUESTIE_LAST_SYNCLOG = GetTime();
QUESTIE_LAST_DRAWNOTES = GetTime();
QUESTIE_UPDATE_EVENT = 0;
SetMapToCurrentZone();
GameLoadingComplete = false;
---------------------------------------------------------------------------------------------------
--Questie OnUpdate Handler
---------------------------------------------------------------------------------------------------
function Questie:OnUpdate(elapsed)
    if (not GameTooltip.IsVisible(GameTooltip) ) then
        GameTooltip.QuestieDone = nil;
        GameTooltip.lastmonster = nil;
        GameTooltip.lastobjective = nil;
    end
    Astrolabe:OnUpdate(nil, elapsed);
    Questie:NOTES_ON_UPDATE(elapsed);
    local index = 1;
    if (table.getn(QUESTIE_EVENTQUEUE) > 0) then
        for k, v in pairs(QUESTIE_EVENTQUEUE) do
            if GetTime()- v.TIME > v.DELAY then
                if (v.EVENT == "UPDATE") then
                    local UpdateTime = GetTime();
                    while (true) do
                        local d = Questie:UpdateQuests();
                        if (not d) then
                            QUESTIE_EVENTQUEUE[k] = nil;
                            break;
                        end
                    end
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring(GetTime()- UpdateTime).." ms");
                    Questie:debug_Print();
                elseif (v.EVENT == "UPDATECACHE") then
                    local UpdateCacheTime = GetTime();
                    Questie:UpdateGameClientCache();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- UpdateCacheTime)*1000).." ms");
                    Questie:debug_Print();
                elseif (v.EVENT == "CHECKLOG") then
                    local CheckLogTime = GetTime();
                    Questie:CheckQuestLog();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- CheckLogTime)*1000).." ms");
                elseif (v.EVENT == "TRACKER") then
                    local TrackerTime = GetTime();
                    QuestieTracker:SortTrackingFrame();
                    QuestieTracker:FillTrackingFrame();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- TrackerTime)*1000).." ms");
                    Questie:debug_Print();
                elseif (v.EVENT == "SYNCLOG") then
                    local SyncLogTime = GetTime();
                    QuestieTracker:syncQuestLog();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- SyncLogTime)*1000).." ms");
                    Questie:debug_Print();
                elseif (v.EVENT == "SYNCWATCH") and (not IsAddOnLoaded("EQL3")) and (not IsAddOnLoaded("ShaguQuest")) then
                    local SyncWoWLogTime = GetTime();
                    QuestieTracker:syncQuestWatch();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- SyncWoWLogTime)*1000).." ms");
                    Questie:debug_Print();
                elseif (v.EVENT == "DRAWNOTES") then
                    local DrawNotesTime = GetTime();
                    Questie:SetAvailableQuests();
                    Questie:RedrawNotes();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- DrawNotesTime)*1000).." ms");
                    Questie:debug_Print();
                elseif (v.EVENT == "LOADEVENTS") then
                    local LoadEventsTime = GetTime();
                    GameLoadingComplete = true;
                    Questie:OnLoad_QuestEvents();
                    QUESTIE_EVENTQUEUE[k] = nil;
                    Questie:debug_Print("OnUpdate: "..v.EVENT.." Took: "..tostring((GetTime()- LoadEventsTime)*1000).." ms");
                    Questie:debug_Print();
                end
            else
                if k ~= index then
                    QUESTIE_EVENTQUEUE[index] = v;
                    QUESTIE_EVENTQUEUE[k] = nil;
                end
                index = index + 1;
            end
        end
    end
    --Check if player is dead and NOT released and if the corpseArrow is on. No sense entering the
    --function if the player is not dead or the corpseArrow isn't turned on.
    local runonce = true
    if UnitIsDeadOrGhost("player") and (QuestieConfig.corpseArrow == true) and (runonce == true) then
        local bgactive = false
        for i=1, MAX_BATTLEFIELD_QUEUES do
            bgstatus = GetBattlefieldStatus(i)
            if (bgstatus and bgstatus == "active") then
                bgactive = true
            end
        end
        --Checks if player released and not in a Battleground. No sense painting a corpseArrow if
        --the player is waiting to be rez'd. If player is in a Battleground then this code never
        --runs.
        if (UnitIsDead("player") ~= 1) and (bgactive == false) then
            if DiedAtX and DiedAtY and DiedAtX ~= 0 and DiedAtY ~= 0 then --<--set globally by PLAYER_DEAD event
                local ddist, xDelta, yDelta = Astrolabe:ComputeDistance(DiedInCont, DiedInZone, DiedAtX, DiedAtY, continent, zone, xNote, yNote)
                local dtitle = "My Dead Corpse"
                local dpoint = {c = DiedInCont, z = DiedInZone, x = DiedAtX, y = DiedAtY}
                SetCrazyArrow(dpoint, ddist, dtitle) --<--sets corpseArrow
                if (not WorldMapFrame:IsVisible() == nil) then
                    return
                end
                --Allows the player to browse to a different map zone while dead. Otherwise, they'd
                --be stuck looking at the map zone they died in.
                if (WorldMapFrame:IsVisible() == nil) and (WorldMapUpdateSpamOff == nil) then
                    SetMapToCurrentZone()
                    WorldMapUpdateSpamOff = true
                end
            end
        else
            --Catch-all while the 'if' statement is false and hiding the arrow fails to fire in
            --some other update, event or function. This function always overwrites the objective
            --point so it's safe to always hide the arrow once we're inside the function.
            TomTomCrazyArrow:Hide()
        end
    end
    runonce = false
end
---------------------------------------------------------------------------------------------------
--Questie Event Handlers
---------------------------------------------------------------------------------------------------
function Questie:AddEvent(EVENT, DELAY, MSG)
    local evnt = {};
    evnt.EVENT = EVENT;
    evnt.TIME = GetTime();
    evnt.DELAY = DELAY;
    evnt.MSG = MSG;
    table.insert(QUESTIE_EVENTQUEUE, evnt);
end
---------------------------------------------------------------------------------------------------
function Questie:CheckQuestLogStatus()
    QUESTIE_UPDATE_EVENT = 1;
    if(GetTime() - QUESTIE_LAST_UPDATECACHE > 0.01) then
        Questie:AddEvent("UPDATECACHE", 0.2);
        QUESTIE_LAST_UPDATECACHE = GetTime();
    else
        QUESTIE_LAST_UPDATECACHE = GetTime();
    end
    if(GetTime() - QUESTIE_LAST_CHECKLOG > 0.01) then
        Questie:AddEvent("CHECKLOG", 0.4);
        QUESTIE_LAST_CHECKLOG = GetTime();
    else
        QUESTIE_LAST_CHECKLOG = GetTime();
    end
    if(GetTime() - QUESTIE_LAST_UPDATE > 0.01) then
        Questie:AddEvent("UPDATE", 0.6);
        QUESTIE_LAST_UPDATE = GetTime();
    else
        QUESTIE_LAST_UPDATE = GetTime();
    end
end
---------------------------------------------------------------------------------------------------
function Questie:RefreshQuestStatus()
    QUESTIE_UPDATE_EVENT = 1;
    if (GetTime() - QUESTIE_LAST_SYNCLOG > 0.1) then
        Questie:AddEvent("SYNCLOG", 1.0);
        QUESTIE_LAST_SYNCLOG = GetTime();
    else
        QUESTIE_LAST_SYNCLOG = GetTime();
    end
    if (GetTime() - QUESTIE_LAST_DRAWNOTES > 0.1) then
        Questie:AddEvent("DRAWNOTES", 1.2);
        QUESTIE_LAST_DRAWNOTES = GetTime();
    else
        QUESTIE_LAST_DRAWNOTES = GetTime();
    end
    if (GetTime() - QUESTIE_LAST_TRACKER > 0.1) then
        Questie:AddEvent("TRACKER", 1.2);
        QUESTIE_LAST_TRACKER = GetTime();
    else
        QUESTIE_LAST_TRACKER = GetTime();
    end
end
---------------------------------------------------------------------------------------------------
function Questie:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if (event =="ADDON_LOADED" and arg1 == "!Questie") then
        Questie:CreateMinimapButton();
    -------------------------------------------------
    elseif (event == "CHAT_MSG_LOOT") then
        --Questie:debug_Print("OnEvent: CHAT_MSG_LOOT");
        Questie:ParseQuestLoot(arg1);
    -------------------------------------------------
    elseif (event == "MINIMAP_UPDATE_ZOOM" ) then
        if (QuestieConfig.minimapZoom == true) then
            Astrolabe:isMinimapInCity();
        end
    -------------------------------------------------
    elseif (event == "PLAYER_DEAD") then
        --Records players continent, zone and coordinates upon death to be used later. This is more
        --accurate than "posX, posY = GetCorpseMapPosition()" Blizzards API only records X and Y
        --coordinates.
        DiedInCont, DiedInZone, DiedAtX, DiedAtY = Astrolabe:GetCurrentPlayerPosition();
    -------------------------------------------------
    elseif ( event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" ) then
        if not WorldMapFrame:IsVisible() then SetMapToCurrentZone() end
    -------------------------------------------------
    elseif ( event == "PLAYER_LEAVING_WORLD" ) then
        Questie:CLEAR_ALL_NOTES();
    -------------------------------------------------
    elseif (event == "PLAYER_LEVEL_UP") then
        Questie:SetAvailableQuests(tonumber(arg1));
        Questie:AddEvent("DRAWNOTES", 0.1);
    -------------------------------------------------
    elseif (event == "PLAYER_LOGIN") then
        Questie:debug_Print("OnEvent: PLAYER_LOGIN");
        Questie:hookTooltip();
        Questie:hookTooltipLineCheck();
        QuestieTracker:createTrackingFrame();
        QuestieTracker:LoadModule();
        Questie:BlockTranslations();
        Astrolabe:isMinimapInCity();
        Questie:LoadEQL3Fix();
        Questie:Toggle_Position();
        Questie:AddEvent("UPDATECACHE", 1.8);
        Questie:AddEvent("CHECKLOG", 2.0);
        Questie:AddEvent("UPDATE", 2.2);
        Questie:AddEvent("LOADEVENTS", 2.4);
        Questie:AddEvent("SYNCWATCH", 2.5);
        Questie:AddEvent("SYNCLOG", 2.6);
        Questie:AddEvent("DRAWNOTES", 2.7);
        Questie:AddEvent("TRACKER", 2.8);
    -------------------------------------------------
    elseif (event == "PLAYER_UNGHOST") then
        --If the corpseArrow is turned off and if the player has an objective active on the
        --questArrow, this check won't clear it. The corpseArrow is only active when it's enabled
        if (QuestieConfig.corpseArrow == false) and (QuestieConfig.arrowEnabled == true) then
            return;
        --Safety check in case this isn't done in another event or function.
        elseif (QuestieConfig.corpseArrow == true) then
            TomTomCrazyArrow:Hide();
        end
        WorldMapUpdateSpamOff = nil;
    -------------------------------------------------
    elseif (event == "QUEST_PROGRESS") then
        Questie:debug_Print("OnEvent: QUEST_PROGRESS.\n    GetNumQuestItems: "..GetNumQuestItems())
        Questie:OnQuestProgress()
    -------------------------------------------------
    elseif (event == "QUEST_LOG_UPDATE") then
        --Questie:debug_Print("OnEvent: QUEST_LOG_UPDATE");
        Questie:CheckQuestLogStatus();
    -------------------------------------------------
    elseif (event == "QUEST_ITEM_UPDATE") then
        Questie:debug_Print("OnEvent: QUEST_ITEM_UPDATE");
        Questie:CheckQuestLogStatus();
    -------------------------------------------------
    elseif (event == "VARIABLES_LOADED") then
        Questie:SetupDefaults();
        Questie:CheckDefaults();
    end
end
---------------------------------------------------------------------------------------------------
--Questie Worldmap Toggle Button
---------------------------------------------------------------------------------------------------
function Questie:Toggle()
    if (QuestieConfig.showMapNotes == true) and (IsQuestieActive == true) then
        QuestieConfig.showMapNotes = false;
        IsQuestieActive = false;
        QuestieMapNotes = {};
        QuestieAvailableMapNotes = {};
        Questie:CLEAR_ALL_NOTES();
        LastQuestLogHashes = nil;
    else
        LastQuestLogHashes = nil;
        IsQuestieActive = true;
        QuestieConfig.showMapNotes = true;
        Questie:UpdateGameClientCache(true)
    end
end
---------------------------------------------------------------------------------------------------
--Reposition Questie Worldmap Toggle Button - MetaMap & Cartographer support
---------------------------------------------------------------------------------------------------
function Questie:Toggle_Position()
    if IsAddOnLoaded("MetaMap") then
        Questie_Toggle:ClearAllPoints();
        Questie_Toggle:SetPoint("CENTER", WorldMapFrame, "CENTER", -430, 335);
    end
    if IsAddOnLoaded("Cartographer") then 
        Questie_Toggle:ClearAllPoints();
        Questie_Toggle:SetPoint("CENTER", WorldMapFrame, "CENTER", 0, 338);
    end
end
---------------------------------------------------------------------------------------------------
-- QuestieSeenQuests flags to denote quest status in all cache and saved variable checks.
--    1 : Quest Complete
--    0 : Found in QuestLog
--   -1 : Abandoned Quest
-- Example: QuestieSeenQuests[hash] = flag
---------------------------------------------------------------------------------------------------
--Cleans and resets the users Questie SavedVariables. Will also perform some quest and quest
--tracker database clean up to purge stale/invalid entries. More notes below. Popup confirmation
--of Yes or No - Popup has a 60 second timeout.
---------------------------------------------------------------------------------------------------
function Questie:ClearConfig(arg)
    if arg == "slash" then
        msg = "|cFFFFFF00You are about to clear your characters settings. This will NOT delete your quest database but it will clean it up a little. This will reset abandoned quests, and remove any finished or stale quest entries in the QuestTracker database. Your UI will be reloaded automatically to finalize the new settings.|n|nAre you sure you want to continue?|r";
    elseif arg == "version" then
        msg = "|cFFFFFF00VERSION CHECK!|n|nIt appears you have installed Questie for the very first time or you have recently upgraded to a new version. Your UI will automatically be reloaded and your QuestieConfig will be updated and cleaned of any stale entries. This will NOT clear your quest history.|n|nPlease click Yes to begin the update.|r";
    end
    StaticPopupDialogs["CLEAR_CONFIG"] = {
        text = TEXT(msg),
        button1 = TEXT(YES),
        button2 = TEXT(NO),
        OnAccept = function()
            --Clears config
            QuestieConfig = nil;
            --Clears tracker settings
            QuestieTrackerVariables = nil;
            --Set default settings
            Questie:SetupDefaults();
            --Clean QuestieSeenQuests DB
            for k,v in pairs(QuestieSeenQuests) do
                if (k == 0) or (k == -1) then
                    QuestieSeenQuests[k] = nil;
                end
            end
            --Clear QuestieCachedQuests DB
            QuestieCachedQuests = {};
            Questie:CheckDefaults();
            ReloadUI();
        end,
        timeout = 60,
        exclusive = 1,
        hideOnEscape = 1
    };
    StaticPopup_Show ("CLEAR_CONFIG");
end
---------------------------------------------------------------------------------------------------
--Clears and deletes the users Questie SavedVariables. One option is for a user initiated NUKE and
--the other option will execute when Questie senses a new level 1 character using a Saved Variables
--file from a deleted character. Popup confirmation of Yes or No - Popup has a 60 second timeout.
---------------------------------------------------------------------------------------------------
function Questie:NUKE(arg)
    if arg == "slash" then
        msg = "|cFFFFFF00You are about to completely wipe your characters saved variables. This includes all quests you've completed, settings and preferences, and QuestTracker location.|n|nAre you sure you want to continue?|r";
    elseif arg == "newcharacter" then
        msg = "|cFFFFFF00ERROR! Database Detected!|n|nIt appears that you've used this name for a previous character. There are entries in the QuestDatabase that need to be cleared in order for Questie to work properly with this character. Your UI will be reloaded automatically to clear your config.|n|nAre you sure you want to continue?|r";
    end
    StaticPopupDialogs["NUKE_CONFIG"] = {
        text = TEXT(msg),
        button1 = TEXT(YES),
        button2 = TEXT(NO),
        OnAccept = function()
            --Clears quests DB
            QuestieSeenQuests = {};
            --Clears cached quests DB
            QuestieCachedQuests = {};
            --Clears config settings
            QuestieConfig = nil;
            --Clears tracker settings
            QuestieTrackerVariables = nil;
            --Set default settings
            Questie:SetupDefaults();
            Questie:CheckDefaults();
            ReloadUI();
        end,
        timeout = 60,
        exclusive = 1,
        hideOnEscape = 1
    }
    StaticPopup_Show ("NUKE_CONFIG");
end
---------------------------------------------------------------------------------------------------
--Questie Slash Handler and Help Menu
---------------------------------------------------------------------------------------------------
QuestieFastSlash = {
    ["arrow"] = function()
    --Default: True
        QuestieConfig.arrowEnabled = not QuestieConfig.arrowEnabled;
        if QuestieConfig.arrowEnabled then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Arrow On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Arrow Off) |r");
            TomTomCrazyArrow:Hide();
        end
    end,
    ["arrowtime"] = function()
    --Default: False
        QuestieConfig.arrowTime = not QuestieConfig.arrowTime;
        if QuestieConfig.arrowTime then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Arrow Time to Arrive On) |r");
            TomTomCrazyArrow.tta:Show();
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Arrow Time to Arrive Off) |r");
            TomTomCrazyArrow.tta:Hide();
        end
    end,
    ["background"] = function()
    --Default: False
        QuestieConfig.trackerBackground = not QuestieConfig.trackerBackground;
        if QuestieConfig.trackerBackground then
            ReloadUI();
        else
            ReloadUI();
        end
    end,
    ["backgroundalpha"] = function(args)
    --Default: 0.6 (60%)
        if args then
            local val = tonumber(args);
            QuestieConfig.trackerAlpha = val/100;
            QuestieTracker:FillTrackingFrame();
            DEFAULT_CHAT_FRAME:AddMessage("QuestieTracker:|c0000ffc0 (Background Alpha Set To: |r|c0000c0ff"..val.."%|r|c0000ffc0)|r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222 Error: Invalid Number Supplied! |r");
        end
    end,
    ["clearconfig"] = function()
        Questie:ClearConfig("slash")
    end,
    ["cleartracker"] = function()
    --Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
        StaticPopupDialogs["CLEAR_TRACKER"] = {
            text = "|cFFFFFF00You are about to reset your QuestTracker. This will only reset it's saved location and place it in the center of your screen. Your UI will be reloaded automatically.|n|nAre you sure you want to continue?|r",
            button1 = TEXT(YES),
            button2 = TEXT(NO),
            OnAccept = function()
                --Clears tracker settings
                QuestieTrackerVariables = {};
                --Setup default settings and repositions the QuestTracker against the left side of
                --the screen.
                QuestieTrackerVariables = {
                    ["position"] = {
                        ["relativeTo"] = "UIParent",
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    },
                };
                ReloadUI();
            end,
            timeout = 60,
            exclusive = 1,
            hideOnEscape = 1
        };
        StaticPopup_Show ("CLEAR_TRACKER");
    end,
    ["cluster"] = function()
    --Default: True
        QuestieConfig.clusterQuests = not QuestieConfig.clusterQuests;
        if QuestieConfig.clusterQuests then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Clustered Icons On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Clustered Icons Off) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["color"] = function()
    --Default: False
        QuestieConfig.boldColors = not QuestieConfig.boldColors;
        if QuestieConfig.boldColors then
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Alternate Colors On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Alternate Colors Off) |r");
        end
        QuestieTracker:FillTrackingFrame();
    end,
    ["corpsearrow"] = function()
    --Default: True
        QuestieConfig.corpseArrow = not QuestieConfig.corpseArrow;
        if QuestieConfig.corpseArrow then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieCorpse:|c0000ffc0 (Arrow On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieCorpse:|c0000ffc0 (Arrow Off) |r");
            TomTomCrazyArrow:Hide();
        end
    end,
    ["header"] = function()
    --Default: False
        if (QuestieConfig.showTrackerHeader == false) then
            StaticPopupDialogs["TRACKER_HEADER_F"] = {
                text = "|cFFFFFF00Due to the way the QuestTracker frame is rendered, your UI will automatically be reloaded.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.showTrackerHeader = true;
                    ReloadUI();
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            };
            StaticPopup_Show ("TRACKER_HEADER_F");
        end
        if (QuestieConfig.showTrackerHeader == true) then
            StaticPopupDialogs["TRACKER_HEADER_T"] = {
                text = "|cFFFFFF00Due to the way the QuestTracker frame is rendered, your UI will automatically be reloaded.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.showTrackerHeader = false;
                    ReloadUI();
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            };
            StaticPopup_Show ("TRACKER_HEADER_T");
        end
    end,
    ["hideminimap"] = function()
    --Default: False
        QuestieConfig.hideMinimapIcons = not QuestieConfig.hideMinimapIcons;
        if QuestieConfig.hideMinimapIcons then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieStarters:|c0000ffc0 (Are now being hidden) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieStarters:|c0000ffc0 (Are now being shown) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["hideobjectives"] = function()
    --Default: False
        QuestieConfig.hideObjectives = not QuestieConfig.hideObjectives;
        if QuestieConfig.hideObjectives then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieObjectives:|c0000ffc0 (Set to always hide) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieObjectives:|c0000ffc0 (Set to always show) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["listdirection"] = function()
    --Default: False
        if (QuestieConfig.trackerList == false) then
            StaticPopupDialogs["BOTTOM_UP"] = {
                text = "|cFFFFFF00You are about to change the way quests are listed in the QuestTracker. They will grow from bottom --> up and sorted by distance from top --> down.|n|nYour UI will be automatically reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerList = true;
                    QuestieTrackerVariables = {};
                    QuestieTrackerVariables["position"] = {
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["relativeTo"] = "UIParent",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    };
                    ReloadUI();
                end,
                timeout = 120,
                exclusive = 1,
                hideOnEscape = 1
            };
            StaticPopup_Show ("BOTTOM_UP");
        elseif (QuestieConfig.trackerList == true) then
            StaticPopupDialogs["TOP_DOWN"] = {
                text = "|cFFFFFF00You are about to change the tracker back to it's default state. Quests will grow from top --> down and also sorted by distance from top --> down in the QuestTracker.|n|nYour UI will be reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerList = false;
                    QuestieTrackerVariables = {};
                    QuestieTrackerVariables["position"] = {
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["relativeTo"] = "UIParent",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    };
                    ReloadUI();
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            };
            StaticPopup_Show ("TOP_DOWN");
        end
    end,
    ["mapnotes"] = function()
    --Default: True
        Questie:Toggle();
        if QuestieConfig.showMapNotes then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Map Notes On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Map Notes Off) |r");
        end
    end,
    ["maxlevel"] = function()
    --Default: True
        QuestieConfig.maxLevelFilter = not QuestieConfig.maxLevelFilter;
        if QuestieConfig.maxLevelFilter then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Max-Level Filter On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Max-Level Filter Off) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["minimapbutton"] = function()
    --Default: True
        QuestieConfig.minimapButton = not QuestieConfig.minimapButton;
        if QuestieConfig.minimapButton then
            Questie.minimapButton:Show();
        else
            Questie.minimapButton:Hide();
        end
    end,
    ["minimapzoom"] = function()
    --Default: False
        QuestieConfig.minimapZoom = not QuestieConfig.minimapZoom;
        if QuestieConfig.minimapZoom then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieMiniMap:|c0000ffc0 (MiniMap Auto-Zoom On) |r");
            QuestieConfig.minimapZoom = true;
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieMiniMap:|c0000ffc0 (MiniMap Auto-Zoom Off) |r");
            QuestieConfig.minimapZoom = false;
        end
    end,
    ["minlevel"] = function()
    --Default: True
        QuestieConfig.minLevelFilter = not QuestieConfig.minLevelFilter;
        if QuestieConfig.minLevelFilter then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Min-Level Filter On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Min-Level Filter Off) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["mintracker"] = function()
    --Default: False
        if QuestieConfig.trackerMinimize then
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Maximized) |r");
            QuestieConfig.trackerMinimize = false;
            QuestieTracker.frame:Show();
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Minimized) |r");
            QuestieConfig.trackerMinimize = true;
            QuestieTracker.frame:Hide();
        end
    end,
    ["NUKE"] = function()
    --Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
        Questie:NUKE("slash")
    end,
    ["professions"] = function()
    --Default: False
        QuestieConfig.showProfessionQuests = not QuestieConfig.showProfessionQuests;
        if QuestieConfig.showProfessionQuests then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Profession Quests On) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Profession Quests Off) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["qtscale"] = function(arg)
    --Default: Small
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
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222 Error: Invalid Option.");
        end
    end,
    ["resizemap"] = function()
    --Default: False
        QuestieConfig.resizeWorldmap = not QuestieConfig.resizeWorldmap;
        if QuestieConfig.resizeWorldmap then
            ReloadUI();
        else
            ReloadUI();
        end
    end,
    ["setmaxlevel"] = function(args)
    --Default7:Quests will not appear until your level is 7 levels below the quest's minimum level
        if args then
            local val = tonumber(args);
            DEFAULT_CHAT_FRAME:AddMessage("Max-Level filter set to "..val);
            QuestieConfig.maxShowLevel = val;
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: Invalid Number Supplied!");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["setminlevel"] = function(args)
    --Default4:Quests will stop appearing when their recommended level is below your level minus 4
        if args then
            local val = tonumber(args);
            DEFAULT_CHAT_FRAME:AddMessage("Min-Level filter set to "..val);
            QuestieConfig.minShowLevel = val;
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: Invalid Number Supplied!");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["settings"] = function()
        Questie:CurrentUserToggles();
    end,
    ["showobjectives"] = function()
    --Default: True
        QuestieConfig.alwaysShowObjectives = not QuestieConfig.alwaysShowObjectives;
        if QuestieConfig.alwaysShowObjectives then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieOjectives:|c0000ffc0 (Set to always show) |r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieObjectives:|c0000ffc0 (Only show on maps while tracking) |r");
        end
        Questie:AddEvent("DRAWNOTES", 0.1);
    end,
    ["tooltips"] = function()
    --Default: True
        QuestieConfig.showToolTips = not QuestieConfig.showToolTips;
        if QuestieConfig.showToolTips then
            ReloadUI();
            Questie:CheckDefaults();
        else
            ReloadUI();
            Questie:CheckDefaults();
        end
    end,
    ["tracker"] = function()
    --Default: True
        if (QuestieConfig.trackerEnabled == true) then
            StaticPopupDialogs["HIDE_TRACKER"] = {
                text = "|cFFFFFF00You are about to disable the QuestieTracker. If you're using a QuestLog mod with a built in tracker then after your UI reloads you will be using that mods default tracker. Otherwise you'll use WoW's default tracker.|n|nYour UI will be automatically reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerEnabled = false;
                    QuestieTracker:Hide();
                    QuestieTracker.frame:Hide();
                    ReloadUI();
                end,
                timeout = 120,
                exclusive = 1,
                hideOnEscape = 1
            };
            StaticPopup_Show ("HIDE_TRACKER");
        elseif (QuestieConfig.trackerEnabled == false) then
            StaticPopupDialogs["SHOW_TRACKER"] = {
                text = "|cFFFFFF00You are about to enabled the QuestieTracker. The previous quest tracker will be disabled.|n|nYour UI will be reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerEnabled = true;
                    QuestieTracker:Show();
                    ReloadUI();
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            };
            StaticPopup_Show ("SHOW_TRACKER");
        end
    end,
---------------------------------------------------------------------------------------------------
--Questie Help Menu
---------------------------------------------------------------------------------------------------
    ["help"] = function()
        DEFAULT_CHAT_FRAME:AddMessage("Questie SlashCommand Help Menu:", 1, 0.75, 0);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie arrow |r|c0000ffc0(toggle)|r QuestArrow: Toggle", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie arrowtime |r|c0000ffc0(toggle)|r QuestArrow: Toggle Time to Arrive", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie background |r|c0000ffc0(toggle)|r QuestTracker: Background", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie backgroundalpha |r|c0000ffc0(10-100%)|r QuestTracker: Background Alpha Level (default=60%)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie clearconfig |r|c0000ffc0(Pop-up)|r UserSettings: Reset settings. Will NOT delete quest data.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie cleartracker |r|c0000ffc0(Pop-up)|r QuestTracker: Reset & move tracker to center screen.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie cluster |r|c0000ffc0(toggle)|r QuestMap: Groups nearby start/finish/objective icons together.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie color |r|c0000ffc0(toggle)|r QuestTracker: Select two different color themes", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie corpsearrow |r|c0000ffc0(toggle)|r CorpseArrow: Toggle", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie header |r|c0000ffc0(toggle)|r QuestTracker: Header & Quest Counter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie hideminimap |r|c0000ffc0(toggle)|r QuestMap: Removes quest starter icons from Minimap", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie hideobjectives |r|c0000ffc0(toggle)|r QuestMap: Hide all objectives for obtained quests", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie listdirection |r|r|c0000ffc0(list)|r QuestTracker: Change list order: Top-->Down or Bottom-->Up", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mapnotes |r|c0000ffc0(toggle)|r Questie: Commandline version of ToggleQuestie button", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie maxlevel |r|c0000ffc0(toggle)|r QuestMap: Filter - see setmaxlevel", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie minimapbutton |r|c0000ffc0(toggle)|r QuestMap: Removes questie minimap button", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie minimapzoom |r|c0000ffc0(toggle)|r QuestMap: Removes questie minimap auto-zoom", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie minlevel |r|c0000ffc0(toggle)|r QuestMap: Filter - see setminlevel", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mintracker |r|c0000ffc0(toggle)|r QuestTracker: Minimize or Maximize the QuestieTracker", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie NUKE |r|r|c0000ffc0(Pop-up)|r Database: Resets ALL Questie data and settings", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie options |r-- Displays the Questie Options configuration interface", 0.75, 0.75, 0.75); -- TODO:Remove when minimap button is used
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie professions |r|c0000ffc0(toggle)|r QuestQuest: Profession quest filter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setmaxlevel |r|c0000ffc0<number>|r QuestMap: Show quests <X> levels above players level (default=7)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setminlevel |r|c0000ffc0<number>|r QuestMap: Show quests <X> levels below players level (default=4)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie settings |r|c0000ffc0(list)|r Questie: Displays your current toggles and settings.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie showobjectives |r|c0000ffc0(toggle)|r QuestTracker: Show only quest objectives for actively tracked quests  ", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tooltips |r|c0000ffc0(toggle)|r QuestMobs&Items: Always show quest and objective tool tips", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tracker |r|c0000ffc0(toggle)|r QuestTracker: Turn on and off the quest tracker", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie qtscale |r|c0000ffc0(small|medium|large)|r QuestTracker: Adjust the scale of the tracker (default=small)", 0.75, 0.75, 0.75);
        if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then
            return;
        elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
            DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie resizemap |r--|c0000ffc0(toggle)|r QuestMap: Shrinks Worldmap and allows dragging", 0.75, 0.75, 0.75);
        end
    end,
    ["options"] = function()
        Questie:OptionsForm_Display()
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
        if ( QuestieOptionsForm:IsVisible() ) then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Error: cannot execute commands while the Questie options window is open.|r")
        else
            QuestieFastSlash[msg](args);
        end
    else
        if (not msg or msg=="") then
            QuestieFastSlash["help"]();
        else
            DEFAULT_CHAT_FRAME:AddMessage("Unknown operation: " .. msg .. " try /questie help");
        end
    end
end
---------------------------------------------------------------------------------------------------
--Displays to the player all Questie vars
---------------------------------------------------------------------------------------------------
function Questie:CurrentUserToggles()
    DEFAULT_CHAT_FRAME:AddMessage("Questie Settings:", 0.5, 0.5, 1);
    local Vars = {
        [1] = { "alwaysShowObjectives" },
        [2] = { "arrowEnabled" },
        [3] = { "arrowTime" },
        [4] = { "boldColors" },
        [5] = { "clusterQuests" },
        [6] = { "corpseArrow" },
        [7] = { "getVersion" },
        [8] = { "hideMinimapIcons" },
        [9] = { "hideObjectives" },
        [10] = { "maxLevelFilter" },
        [11] = { "maxShowLevel" },
        [12] = { "minimapButton" },
        [13] = { "minimapZoom" },
        [14] = { "minLevelFilter" },
        [15] = { "minShowLevel" },
        [16] = { "resizeWorldmap" },
        [17] = { "showMapNotes" },
        [18] = { "showProfessionQuests" },
        [19] = { "showTrackerHeader" },
        [20] = { "showToolTips" },
        [21] = { "trackerAlpha" },
        [22] = { "trackerBackground" },
        [23] = { "trackerEnabled" },
        [24] = { "trackerList" },
        [25] = { "trackerMinimize" },
        [26] = { "trackerScale" },
    };
    if QuestieConfig then
        i = 1;
        v = 1;
        while Vars[i] and Vars[i][v]do
            curVar = Vars[i][v];
            DEFAULT_CHAT_FRAME:AddMessage("  "..curVar.." = "..(tostring(QuestieConfig[curVar])), 0.5, 0.5, 1);
            i = i + 1;
        end
    end
end
---------------------------------------------------------------------------------------------------
--Handles linked Quests from chat - functionality introduced in Burning Crusade.
---------------------------------------------------------------------------------------------------
local HookSetItemRef = SetItemRef;
function SetItemRef(link, text, button)
    if ItemRefTooltip:IsVisible() then
        ItemRefTooltip:Hide();
    else
        isQuest, _, _ = string.find(link, "quest:(%d+):.*");
        if isQuest then
            _, _, QuestTitle = string.find(text, ".*|h%[(.*)%]|h.*");
            local questTitle = tostring(QuestTitle);
            if questTitle then
                ShowUIPanel(ItemRefTooltip);
                ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
                ItemRefTooltip:AddLine(questTitle);
                local questHash = Questie:getQuestHash(questTitle);
                questOb = nil;
                local QuestName = QuestieHashMap[questHash].name;
                if QuestName == questTitle then
                    local index = 0;
                    for k,v in pairs(Questie:SanitisedQuestLookup(QuestName)) do
                        index = index + 1;
                        if (index == 1) and (v[2] == questHash) and (k ~= "") then
                            questOb = k;
                        elseif (index > 0) and(v[2] == questHash) and (k ~= "") then
                            questOb = k;
                        elseif (index == 1) and (v[2] ~= questHash) and (k ~= "") then
                            questOb = k;
                        end
                    end
                    ItemRefTooltip:AddLine("Started by: |cFFa6a6a6"..QuestieHashMap[questHash].startedBy.."|r",1,1,1);
                    if questOb ~= nil then
                        ItemRefTooltip:AddLine("|cffffffff"..questOb.."|r",1,1,1,true);
                    else
                        ItemRefTooltip:AddLine("Quest *Objective* not found in Questie Database!", 1, .8, .8);
                        ItemRefTooltip:AddLine("Please file a bug report on our GitHub portal:)", 1, .8, .8);
                        ItemRefTooltip:AddLine("https://github.com/AeroScripts/QuestieDev/issues", 1, .8, .8);
                    end
                    local _, _, questLevel = string.find(QuestieHashMap[questHash].questLevel, "(%d+)");
                    if questLevel ~= 0 and questLevel ~= "0" then
                        local color = GetDifficultyColor(questLevel);
                        ItemRefTooltip:AddLine("Quest Level " ..QuestieHashMap[questHash].questLevel, color.r, color.g, color.b);
                    end
                    ItemRefTooltip:Show();
                else
                    ShowUIPanel(ItemRefTooltip);
                    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
                    ItemRefTooltip:AddLine(questTitle, 1,1,0);
                    ItemRefTooltip:AddLine("Quest not found in Questie Database!", 1, .8, .8);
                    ItemRefTooltip:AddLine("Please file a bug report on our GitHub portal:)", 1, .8, .8);
                    ItemRefTooltip:AddLine("https://github.com/AeroScripts/QuestieDev/issues", 1, .8, .8);
                end
                ItemRefTooltip:Show();
            end
        else
            HookSetItemRef(link, text, button);
        end
    end
end
---------------------------------------------------------------------------------------------------
--Misc helper functions and short cuts
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
function Questie:LinkToID(link)
    if link then
        local _, _, id = string.find(link, "(%d+):");
        return tonumber(id);
    end
end
---------------------------------------------------------------------------------------------------
function GetCurrentMapID()
    local file = GetMapInfo();
    if file == nil then
        return -1;
    end
    local zid = QuestieZones[file];
    if zid == nil then
        return -1;
    else
        return zid[1];
    end
end
---------------------------------------------------------------------------------------------------
function Questie:MixString(mix, str)
    return Questie:MixInt(mix, Questie:HashString(str));
end
---------------------------------------------------------------------------------------------------
--Computes an Adler-32 checksum.
function Questie:HashString(text)
    local a, b = 1, 0;
    for i=1,string.len(text) do
        a = Questie:Modulo((a+string.byte(text,i)), 65521);
        b = Questie:Modulo((b+a), 65521);
    end
    return b*65536+a;
end
---------------------------------------------------------------------------------------------------
--Lua5 doesnt support mod math via the % operator
function Questie:Modulo(val, by)
    return val - math.floor(val/by)*by;
end
---------------------------------------------------------------------------------------------------
function Questie:MixInt(hash, addval)
    return bit.lshift(hash, 6) + addval;
end
---------------------------------------------------------------------------------------------------
--Returns the Levenshtein distance between the two given strings credit to:
--https://gist.github.com/Badgerati/3261142
function Questie:Levenshtein(str1, str2)
    local len1 = string.len(str1);
    local len2 = string.len(str2);
    local matrix = {};
    local cost = 0;
    --quick cut-offs to save time
    if (len1 == 0) then
        return len2;
    elseif (len2 == 0) then
        return len1;
    elseif (str1 == str2) then
        return 0;
    end
    --initialise the base matrix values
    for i = 0, len1, 1 do
        matrix[i] = {};
        matrix[i][0] = i;
    end
    for j = 0, len2, 1 do
        matrix[0][j] = j;
    end
    --actual Levenshtein algorithm
    for i = 1, len1, 1 do
        for j = 1, len2, 1 do
            if (string.byte(str1,i) == string.byte(str2,j)) then
                cost = 0;
            else
                cost = 1;
            end
            matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost);
        end
    end
    --return the last value - this is the Levenshtein distance
    return matrix[len1][len2];
end

-- Simple function to convert values to booleans
function Questie:toboolean(bool)
    return not not bool
end
---------------------------------------------------------------------------------------------------
--End of misc helper functions and short cuts
---------------------------------------------------------------------------------------------------
