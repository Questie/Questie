---------------------------------------------------------------------------------------------------
-- Name: Questie for Vanilla WoW
-- Revision: 3.70
-- Authors: Aero/Schaka/Logon/Dyaxler/Muehe/Zoey/everyone else
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
QuestieVersion = 3.70;
---------------------------------------------------------------------------------------------------
-- Setup Default Profile
---------------------------------------------------------------------------------------------------
function Questie:SetupDefaults()
    if not QuestieConfig then QuestieConfig = {
        ["alwaysShowObjectives"] = true,
        ["arrowEnabled"] = true,
        ["boldColors"] = false,
        ["clusterQuests"] = true,
        ["corpseArrow"] = true,
        ["hideMinimapIcons"] = false,
        ["maxLevelFilter"] = true,
        ["maxShowLevel"] = 7,
        ["minLevelFilter"] = true,
        ["minShowLevel"] = 4,
        ["resizeWorldmap"] = false,
        ["showMapAids"] = true,
        ["showProfessionQuests"] = false,
        ["showTrackerHeader"] = false,
        ["showToolTips"] = true,
        ["trackerAlpha"] = 0.4,
        ["trackerBackground"] = false,
        ["trackerEnabled"] = true,
        ["trackerList"] = false,
        ["trackerMinimize"] = false,
        ["trackerScale"] = 1.0,
        ["getVersion"] = QuestieVersion,
    }
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
    }
    end
end
---------------------------------------------------------------------------------------------------
-- Setup Default Values
---------------------------------------------------------------------------------------------------
function Questie:CheckDefaults()
    --Setups default QuestieConfig toggles for first time users.
    --These are necessary to prevent nil errors from occurring
    --after creating a new character or clearing the config.
    --[1] --
    if QuestieConfig.alwaysShowObjectives == nil then
        QuestieConfig.alwaysShowObjectives = true;
    end
    --[2] --
    if QuestieConfig.arrowEnabled == nil then
        QuestieConfig.arrowEnabled = true;
    end
    --[3] --
    if QuestieConfig.boldColors == nil then
        QuestieConfig.boldColors = false;
    end
    --[4] --
    if QuestieConfig.clusterQuests == nil then
        QuestieConfig.clusterQuests = true;
    end
    --[5] --
    if QuestieConfig.corpseArrow == nil then
        QuestieConfig.corpseArrow = true;
    end
    --[6] --
    if QuestieConfig.hideMinimapIcons == nil then
        QuestieConfig.hideMinimapIcons = false;
    end
    --[7] --
    if QuestieConfig.maxLevelFilter == nil then
        QuestieConfig.maxLevelFilter = true;
    end
    --[8] --
    if QuestieConfig.maxShowLevel == nil then
        QuestieConfig.maxShowLevel = 7;
    end
    --[9] --
    if QuestieConfig.minLevelFilter == nil then
        QuestieConfig.minLevelFilter = true;
    end
    --[10] --
    if QuestieConfig.minShowLevel == nil then
        QuestieConfig.minShowLevel = 4;
    end
    --[11] --
    if QuestieConfig.resizeWorldmap == nil then
        QuestieConfig.resizeWorldmap = false;
    end
    --[12] --
    if QuestieConfig.showMapAids == nil then
        QuestieConfig.showMapAids = true;
    end
    --[13] --
    if QuestieConfig.showProfessionQuests == nil then
        QuestieConfig.showProfessionQuests = false;
    end
    --[14] --
    if QuestieConfig.showTrackerHeader == nil then
        QuestieConfig.showTrackerHeader = false;
    end
    --[15] --
    if QuestieConfig.showToolTips == nil then
        QuestieConfig.showToolTips = true;
    end
    --[16] --
    if QuestieConfig.trackerAlpha == nil then
        QuestieConfig.trackerAlpha = 0.4;
    end
    --[17] --
    if QuestieConfig.trackerBackground == nil then
        QuestieConfig.trackerBackground = false;
    end
    --[18] --
    if QuestieConfig.trackerEnabled == nil then
        QuestieConfig.trackerEnabled = true;
    end
    --[19] --
    if QuestieConfig.trackerList == nil then
        QuestieConfig.trackerList = false;
    end
    --[20] --
    if QuestieConfig.trackerMinimize == nil then
        QuestieConfig.trackerMinimize = false;
    end
    --[21] --
    if QuestieConfig.trackerScale == nil then
        QuestieConfig.trackerScale = 1.0;
    end
    --Version check
    --[22] --
    if (not QuestieConfig.getVersion) or (QuestieConfig.getVersion ~= QuestieVersion) then
        Questie:ClearConfig("version")
    end
    --Setups default QuestDB's for fresh characters
    if QuestieTrackedQuests == nil then
        QuestieTrackedQuests = {}
    end
    --If the user deletes a character and makes a new one by the same name then it will continue to use
    --the same Saved Variables file. This check will delete the Questie Saved Variables file to prevent
    --any quest issues for the new character.
    if UnitLevel("player") == 1 then
        local i = 0
        for i,v in pairs(QuestieSeenQuests) do
            if (i < 3) then
                i = i + 1
            else
                break
            end
        end
        if i > 2 then
            Questie:NUKE("newcharacter")
        end
    end
    --Sets some EQL3 settings to keep it from conflicting with Questie features
    EQL3_Player = UnitName("player").."-"..GetRealmName()
    if IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest") then
        if(not QuestlogOptions[EQL3_Player]) then return end
        if (QuestieConfig.showToolTips == true) then
            QuestlogOptions[EQL3_Player].MobTooltip = 0
            QuestlogOptions[EQL3_Player].ItemTooltip = 0
        else
            QuestlogOptions[EQL3_Player].MobTooltip = 1
            QuestlogOptions[EQL3_Player].ItemTooltip = 1
        end
        QuestlogOptions[EQL3_Player].RemoveCompletedObjectives = 0
        QuestlogOptions[EQL3_Player].RemoveFinished = 0
        QuestlogOptions[EQL3_Player].MinimizeFinished = 0
    end
end
---------------------------------------------------------------------------------------------------
-- In Vanilla WoW there is no official Russian client so an addon was made to translate some of the
-- global strings. Two of the translated strings conflicted with Questie, displaying the wrong info
-- on the World Map. This function simply over-rides those stings to force them back to English so
-- Questie can understand the returned sting in order to display the correct locations and icons.
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
        msg = "|cFFFFFF00You are about to clear your characters settings. This will NOT delete your quest database but it will clean it up a little. This will reset abandoned quests, and remove any finished or stale quest entries in the QuestTracker database. Your UI will be reloaded automatically to finalize the new settings.|n|nAre you sure you want to continue?|r";
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
                ["alwaysShowObjectives"] = true,
                ["arrowEnabled"] = true,
                ["boldColors"] = false,
                ["clusterQuests"] = true,
                ["corpseArrow"] = true,
                ["hideMinimapIcons"] = false,
                ["maxLevelFilter"] = true,
                ["maxShowLevel"] = 7,
                ["minLevelFilter"] = true,
                ["minShowLevel"] = 4,
                ["resizeWorldmap"] = false,
                ["showMapAids"] = true,
                ["showProfessionQuests"] = false,
                ["showTrackerHeader"] = false,
                ["showToolTips"] = true,
                ["trackerAlpha"] = 0.4,
                ["trackerBackground"] = false,
                ["trackerEnabled"] = true,
                ["trackerList"] = false,
                ["trackerMinimize"] = false,
                ["trackerScale"] = 1.0,
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
            -- in QuestieSeenQuests) flag means the quest has been abandoned. Once we remove these flags
            -- Questie will re add the quests based on what is in your log. A refresh of sorts without
            -- touching or resetting your finished quests. When the quest log is crawled, Questie will
            -- check any pre required quests and flag all those as complete up to the quest in your chain
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
        msg = "|cFFFFFF00You are about to completely wipe your characters saved variables. This includes all quests you've completed, settings and preferences, and QuestTracker location.|n|nAre you sure you want to continue?|r";
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
                ["alwaysShowObjectives"] = true,
                ["arrowEnabled"] = true,
                ["boldColors"] = false,
                ["clusterQuests"] = true,
                ["corpseArrow"] = true,
                ["hideMinimapIcons"] = false,
                ["maxLevelFilter"] = true,
                ["maxShowLevel"] = 7,
                ["minLevelFilter"] = true,
                ["minShowLevel"] = 4,
                ["resizeWorldmap"] = false,
                ["showMapAids"] = true,
                ["showProfessionQuests"] = false,
                ["showTrackerHeader"] = false,
                ["showToolTips"] = true,
                ["trackerAlpha"] = 0.4,
                ["trackerBackground"] = false,
                ["trackerEnabled"] = true,
                ["trackerList"] = false,
                ["trackerMinimize"] = false,
                ["trackerScale"] = 1.0,
                ["getVersion"] = QuestieVersion,
            }
            -- Clears tracker settings
            QuestieTrackerVariables = {}
            --Setup default settings and repositions the QuestTracker against the center of the screen.
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
    this:RegisterEvent("ADDON_LOADED");
    this:RegisterEvent("MINIMAP_UPDATE_ZOOM");
    this:RegisterEvent("QUEST_LOG_UPDATE");
    this:RegisterEvent("QUEST_ITEM_UPDATE");
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("PLAYER_LOGIN");
    this:RegisterEvent("PLAYER_DEAD");
    this:RegisterEvent("PLAYER_UNGHOST");
    this:RegisterEvent("PLAYER_LEVEL_UP");
    Questie:NOTES_LOADED();
    SlashCmdList["QUESTIE"] = Questie_SlashHandler;
    SLASH_QUESTIE1 = "/questie";
end
---------------------------------------------------------------------------------------------------
-- Questie Worldmap Toggle Button
---------------------------------------------------------------------------------------------------
Active = true;
function Questie:Toggle()
    if (QuestieConfig.showMapAids == true) or (QuestieConfig.alwaysShowObjectives == true) then
        if(Active == true) then
            Active = false;
            QuestieMapNotes = {};
            QuestieAvailableMapNotes = {};
            Questie:RedrawNotes();
            LastQuestLogHashes = nil;
        else
            Active = true;
            LastQuestLogHashes = nil;
            Questie:CheckQuestLog();
            Questie:SetAvailableQuests();
            Questie:RedrawNotes();
        end
    else
        QuestieMapNotes = {};
        QuestieAvailableMapNotes = {};
        Questie:RedrawNotes();
        LastQuestLogHashes = nil;
    end
end
---------------------------------------------------------------------------------------------------
-- Questie OnUpdate Handler
---------------------------------------------------------------------------------------------------
QUESTIE_LAST_UPDATE_FINISHED = GetTime()
QUESTIE_EVENTQUEUE = {}
function Questie:OnUpdate(elapsed)
    if(not GameTooltip.IsVisible(GameTooltip) ) then
        GameTooltip.QuestieDone = nil
        GameTooltip.lastmonster = nil
        GameTooltip.lastobjective = nil
    end
    Astrolabe:OnUpdate(nil, elapsed)
    Questie:NOTES_ON_UPDATE(elapsed)
    local index = 1
    if(table.getn(QUESTIE_EVENTQUEUE) > 0) then
        for k, v in pairs(QUESTIE_EVENTQUEUE) do
            if GetTime() - v.TIME > v.DELAY then
                if(v.EVENT == "UPDATE") then
                    while(true) do
                        local d = Questie:UpdateQuests()
                        if(not d) then
                            QUESTIE_EVENTQUEUE[k] = nil
                            break
                        end
                    end
                elseif(v.EVENT == "CHECKLOG") then
                    Questie:CheckQuestLog()
                    QUESTIE_EVENTQUEUE[k] = nil
                elseif(v.EVENT == "TRACKER") then
                    QuestieTracker:SortTrackingFrame()
                    QuestieTracker:FillTrackingFrame()
                    QUESTIE_EVENTQUEUE[k] = nil
                elseif(v.EVENT == "TRACKERSIZE") then
                    QuestieTracker:updateTrackingFrameSize()
                    QUESTIE_EVENTQUEUE[k] = nil
                elseif(v.EVENT == "WOWSYNCLOG") then
                    QuestieTracker:syncWOWQuestLog()
                    QUESTIE_EVENTQUEUE[k] = nil
                elseif(v.EVENT == "SYNCLOG") then
                    QuestieTracker:syncQuestLog()
                    QUESTIE_EVENTQUEUE[k] = nil
                end
            else
                if k ~= index then
                    QUESTIE_EVENTQUEUE[index] = v
                    QUESTIE_EVENTQUEUE[k] = nil
                end
                index = index + 1
            end
        end
    end
    --Check if player is dead and NOT released and if the corpseArrow is on.
    --No sense entering the function if the player is not dead or the
    --corpseArrow isn't turned on.
    local runonce = true
    if UnitIsDeadOrGhost("player") and (QuestieConfig.corpseArrow == true) and (runonce == true) then
        local bgactive = false
        for i=1, MAX_BATTLEFIELD_QUEUES do
            bgstatus = GetBattlefieldStatus(i)
            if (bgstatus and bgstatus == "active") then
                bgactive = true
            end
        end
        --Checks if player released and not in a Battleground. No sense painting a corpseArrow if the
        --player is waiting to be rez'd. If player is in a Battleground then this code never runs.
        if (UnitIsDead("player") ~= 1) and (bgactive == false) then
            if DiedAtX and DiedAtY and DiedAtX ~= 0 and DiedAtY ~= 0 then --<--set globally by PLAYER_DEAD event
                local ddist, xDelta, yDelta = Astrolabe:ComputeDistance(DiedInCont, DiedInZone, DiedAtX, DiedAtY, continent, zone, xNote, yNote)
                local dtitle = "My Dead Corpse"
                local dpoint = {c = DiedInCont, z = DiedInZone, x = DiedAtX, y = DiedAtY}
                SetCrazyArrow(dpoint, ddist, dtitle) --<--sets corpseArrow
                if (not WorldMapFrame:IsVisible() == nil) then
                    return
                end
                --Allows the player to browse to a different map zone while dead.
                --Otherwise, they'd be stuck looking at the map zone they died in.
                if (WorldMapFrame:IsVisible() == nil) and (WorldMapUpdateSpamOff == nil) then
                    SetMapToCurrentZone()
                    WorldMapUpdateSpamOff = true
                end
            end
        else
            --Catch-all while the 'if' statement is false and hiding the
            --arrow fails to fire in some other update, event or function.
            --This function always overwrites the objective point so it's
            --safe to always hide the arrow once we're inside the function.
            TomTomCrazyArrow:Hide()
        end
    end
    runonce = false
end
---------------------------------------------------------------------------------------------------
-- Questie Event Handlers
---------------------------------------------------------------------------------------------------
QuestieCompletedQuestMessages = {}
--1 means WE KNOW it's complete
--0 means We've seen it and it's probably in the questlog
---1 means we know its abandonnd
--Had to add a delay(Even if it's small)
function Questie:AddEvent(EVENT, DELAY, MSG)
    local evnt = {}
    evnt.EVENT = EVENT
    evnt.TIME = GetTime()
    evnt.DELAY = DELAY
    evnt.MSG = MSG
    table.insert(QUESTIE_EVENTQUEUE, evnt)
end
---------------------------------------------------------------------------------------------------
QUESTIE_LAST_UPDATE = GetTime()
QUESTIE_LAST_CHECKLOG = GetTime()
QUESTIE_LAST_TRACKER = GetTime()
QUESTIE_LAST_TRACKERSIZE = GetTime()
QUESTIE_LAST_SYNCLOG = GetTime()
QUESTIE_UPDATE_EVENT = 0
---------------------------------------------------------------------------------------------------
function Questie:RefreshQuestEvents()
    QUESTIE_UPDATE_EVENT = 1
    if(GetTime() - QUESTIE_LAST_CHECKLOG > 0.1) then
        Questie:AddEvent("CHECKLOG", 0.165)
        QUESTIE_LAST_CHECKLOG = GetTime()
    end
    if(GetTime() - QUESTIE_LAST_UPDATE > 0.1) then
        Questie:AddEvent("UPDATE", 0.18)
        QUESTIE_LAST_UPDATE = GetTime()
    end
    if(GetTime() - QUESTIE_LAST_TRACKER > 0.1) then
        Questie:AddEvent("TRACKER", 0.3)
        QUESTIE_LAST_TRACKER = GetTime()
    end
    if(GetTime() - QUESTIE_LAST_SYNCLOG > 0.2) then
        if (not IsAddOnLoaded("EQL3")) and (not IsAddOnLoaded("ShaguQuest")) then
            Questie:AddEvent("WOWSYNCLOG", 0.2)
            QUESTIE_LAST_SYNCLOG = GetTime()
        end
        Questie:AddEvent("SYNCLOG", 1)
        QUESTIE_LAST_SYNCLOG = GetTime()
    end
end
---------------------------------------------------------------------------------------------------
function Questie:OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if(event =="ADDON_LOADED" and arg1 == "Questie") then
    elseif (event == "MINIMAP_UPDATE_ZOOM" ) then
        Astrolabe:isMinimapInCity()
    elseif (event == "QUEST_LOG_UPDATE" or event == "QUEST_ITEM_UPDATE") then
        Questie:RefreshQuestEvents()
        Questie:BlockTranslations()
    elseif (event == "VARIABLES_LOADED") then
        if(not QuestieSeenQuests) then
            QuestieSeenQuests = {}
        end
        Questie:BlockTranslations()
        Questie:SetupDefaults()
        Questie:CheckDefaults()
    elseif (event == "PLAYER_LOGIN") then
        local f = GameTooltip:GetScript("OnShow")
        --Proper tooltip hooking!
        if not f then
            GameTooltip:SetScript("OnShow", function(self)
                Questie:Tooltip(self, true)
            end)
        end
        local Blizz_GameTooltip_Show = GameTooltip.Show
        GameTooltip.Show = function(self)
            Questie:Tooltip(self)
            Blizz_GameTooltip_Show(self)
        end
        local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem
        GameTooltip.SetLootItem = function(self, slot)
            Bliz_GameTooltip_SetLootItem(self, slot)
            Questie:Tooltip(self, true)
        end
        local index = self:GetID()
        local Bliz_GameTooltip_SetQuestLogItem = GameTooltip.SetQuestLogItem
        GameTooltip.SetQuestLogItem = function(self, type, index)
            local link = GetQuestLogItemLink(type, index)
            if link then
                Bliz_GameTooltip_SetQuestLogItem(self, type, index)
            end
        end
        Questie:hookTooltipLineCheck()
        Questie:CheckDefaults()
    elseif (event == "PLAYER_DEAD") then
        --Records players continent, zone and coordinates upon death to be used later. This is more accurate
        --than "posX, posY = GetCorpseMapPosition()" Blizzards API only records X and Y coordinates.
        DiedInCont, DiedInZone, DiedAtX, DiedAtY = Astrolabe:GetCurrentPlayerPosition()
    elseif (event == "PLAYER_UNGHOST") then
        --If the corpseArrow is turned off and if the player has an objective
        --active on the questArrow, this check won't clear it. The corpseArrow
        --is only active when it's enabled.
        if (QuestieConfig.corpseArrow == false) and (QuestieConfig.arrowEnabled == true) then
            return
        --Safety check in case this isn't done in another event or function.
        elseif (QuestieConfig.corpseArrow == true) then
            TomTomCrazyArrow:Hide()
        end
        WorldMapUpdateSpamOff = nil
    elseif (event == "PLAYER_LEVEL_UP") then
        Questie:SetAvailableQuests(arg1)
        Questie:RedrawNotes()
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
    ["arrow"] = function()
    --Default: True
        QuestieConfig.arrowEnabled = not QuestieConfig.arrowEnabled
        if QuestieConfig.arrowEnabled then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Arrow On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Arrow Off) |r")
            TomTomCrazyArrow:Hide()
        end
    end,
    ["background"] = function()
    --Default: False
        QuestieConfig.trackerBackground = not QuestieConfig.trackerBackground
        if QuestieConfig.trackerBackground then
            ReloadUI()
        end
    end,
    ["backgroundalpha"] = function(args)
    --Default: 4
        if args then
            local val = tonumber(args)/10
            QuestieConfig.trackerAlpha = val
            QuestieTracker:FillTrackingFrame()
            DEFAULT_CHAT_FRAME:AddMessage("QuestieTracker:|c0000ffc0 (Background Alpha Set To: |r|c0000c0ff"..val.."|r|c0000ffc0)|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222 Error: Invalid Number Supplied! |r")
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
                QuestieTrackerVariables = {}
                --Setup default settings and repositions the QuestTracker against the left side of the screen.
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
    ["cluster"] = function()
    --Default: True
        QuestieConfig.clusterQuests = not QuestieConfig.clusterQuests
        if QuestieConfig.clusterQuests then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Clustered Icons On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Clustered Icons Off) |r")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["color"] = function()
    --Default: False
        QuestieConfig.boldColors = not QuestieConfig.boldColors
        if QuestieConfig.boldColors then
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Alternate Colors On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Alternate Colors Off) |r")
        end
        QuestieTracker:FillTrackingFrame()
    end,
    ["corpsearrow"] = function()
    --Default: True
        QuestieConfig.corpseArrow = not QuestieConfig.corpseArrow
        if QuestieConfig.corpseArrow then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieCorpse:|c0000ffc0 (Arrow On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieCorpse:|c0000ffc0 (Arrow Off) |r")
            TomTomCrazyArrow:Hide()
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
                    QuestieConfig.showTrackerHeader = true
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
                    QuestieConfig.showTrackerHeader = false
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("TRACKER_HEADER_T")
        end
    end,
    ["hideminimap"] = function()
    --Default: False
        QuestieConfig.hideMinimapIcons = not QuestieConfig.hideMinimapIcons
        if QuestieConfig.hideMinimapIcons then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieStarters:|c0000ffc0 (Are now being hidden) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieStarters:|c0000ffc0 (Are now being shown) |r")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["listdirection"] = function()
    --Default: False
        if (QuestieConfig.trackerList == false) then
            StaticPopupDialogs["BOTTOM_UP"] = {
                text = "|cFFFFFF00You are about to change the way quests are listed in the QuestTracker. They will grow from bottom --> up and sorted by distance from top --> down.|n|nYour UI will be automatically reloaded to apply the new settings.|n|nAre you sure you want to continue?|r",
                button1 = TEXT(YES),
                button2 = TEXT(NO),
                OnAccept = function()
                    QuestieConfig.trackerList = true
                    QuestieTrackerVariables = {}
                    QuestieTrackerVariables["position"] = {
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["relativeTo"] = "UIParent",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    }
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
                    QuestieTrackerVariables = {}
                    QuestieTrackerVariables["position"] = {
                        ["point"] = "CENTER",
                        ["relativePoint"] = "CENTER",
                        ["relativeTo"] = "UIParent",
                        ["yOfs"] = 0,
                        ["xOfs"] = 0,
                    }
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("TOP_DOWN")
        end
    end,
    ["mapnotes"] = function()
    --Default: True
        QuestieConfig.showMapAids = not QuestieConfig.showMapAids
        if QuestieConfig.showMapAids then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Map Notes On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Map Notes Off) |r")
        end
        Questie:Toggle()
        Questie:Toggle()
    end,
    ["maxlevel"] = function()
    --Default: True
        QuestieConfig.maxLevelFilter = not QuestieConfig.maxLevelFilter
        if QuestieConfig.maxLevelFilter then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Max-Level Filter On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Max-Level Filter Off) |r")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["minlevel"] = function()
    --Default: True
        QuestieConfig.minLevelFilter = not QuestieConfig.minLevelFilter
        if QuestieConfig.minLevelFilter then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Min-Level Filter On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Min-Level Filter Off) |r")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["mintracker"] = function()
    --Default: False
        if QuestieConfig.trackerMinimize then
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Maximized) |r")
            QuestieConfig.trackerMinimize = false
            QuestieTracker.frame:Show()
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestTracker:|c0000ffc0 (Minimized) |r")
            QuestieConfig.trackerMinimize = true
            QuestieTracker.frame:Hide()
        end
    end,
    ["NUKE"] = function()
    --Default: None - Popup confirmation of Yes or No - Popup has a 60 second timeout.
        Questie:NUKE("slash")
    end,
    ["professions"] = function()
    --Default: False
        QuestieConfig.showProfessionQuests = not QuestieConfig.showProfessionQuests
        if QuestieConfig.showProfessionQuests then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Profession Quests On) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieQuest:|c0000ffc0 (Profession Quests Off) |r")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["qtscale"] = function(arg)
    --Default: Small
        if arg == "large" then
            QuestieConfig.trackerScale = 1.4
            ReloadUI()
        elseif arg == "medium" then
            QuestieConfig.trackerScale = 1.2
            ReloadUI()
        elseif arg == "small" then
            QuestieConfig.trackerScale = 1.0
            ReloadUI()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222 Error: Invalid Option.")
        end
    end,
    ["resizemap"] = function()
    --Default: False
        QuestieConfig.resizeWorldmap = not QuestieConfig.resizeWorldmap
        if QuestieConfig.resizeWorldmap then
            ReloadUI()
        else
            ReloadUI()
        end
    end,
    ["setmaxlevel"] = function(args)
    --Default: 7. Quests will not appear until your level is 7 levels below the quest's minimum level
        if args then
            local val = tonumber(args)
            DEFAULT_CHAT_FRAME:AddMessage("Max-Level filter set to "..val);
            QuestieConfig.maxShowLevel = val
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: Invalid Number Supplied!")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["setminlevel"] = function(args)
    --Default: 4. Quests will stop appearing when their recommended level is below your level minus 4
        if args then
            local val = tonumber(args)
            DEFAULT_CHAT_FRAME:AddMessage("Min-Level filter set to "..val);
            QuestieConfig.minShowLevel = val
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2222Error: Invalid Number Supplied!")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["settings"] = function()
        Questie:CurrentUserToggles()
    end,
    ["showobjectives"] = function()
    --Default: True
        QuestieConfig.alwaysShowObjectives = not QuestieConfig.alwaysShowObjectives
        if QuestieConfig.alwaysShowObjectives then
            DEFAULT_CHAT_FRAME:AddMessage("QuestieOjectives:|c0000ffc0 (Set to always show) |r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("QuestieObjectives:|c0000ffc0 (Only show on maps while tracking) |r")
        end
        Questie:SetAvailableQuests()
        Questie:RedrawNotes()
    end,
    ["tooltips"] = function()
    --Default: True
        QuestieConfig.showToolTips = not QuestieConfig.showToolTips
        if QuestieConfig.showToolTips then
            ReloadUI()
            Questie:CheckDefaults()
        else
            ReloadUI()
            Questie:CheckDefaults()
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
                    QuestieConfig.trackerEnabled = false
                    QuestieTracker:Hide()
                    QuestieTracker.frame:Hide()
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
                    QuestieTracker:Show()
                    ReloadUI()
                end,
                timeout = 60,
                exclusive = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show ("SHOW_TRACKER")
        end
    end,
---------------------------------------------------------------------------------------------------
--Questie Help Menu
---------------------------------------------------------------------------------------------------
    ["help"] = function()
        DEFAULT_CHAT_FRAME:AddMessage("Questie SlashCommand Help Menu:", 1, 0.75, 0);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie arrow |r|c0000ffc0(toggle)|r QuestArrow: Toggle", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie background |r|c0000ffc0(toggle)|r QuestTracker: Background", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie backgroundalpha |r|c0000ffc0(1-9)|r QuestTracker: Background Alpha Level (default=4)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie corpsearrow |r|c0000ffc0(toggle)|r CorpseArrow: Toggle", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie clearconfig |r|c0000ffc0(Pop-up)|r UserSettings: Reset settings. Will NOT delete quest data.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie cleartracker |r|c0000ffc0(Pop-up)|r QuestTracker: Reset & move tracker to center screen.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie cluster |r|c0000ffc0(toggle)|r QuestMap: Groups nearby start/finish/objective icons together.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie color |r|c0000ffc0(toggle)|r QuestTracker: Select two different color themes", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie header |r|c0000ffc0(toggle)|r QuestTracker: Header & Quest Counter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie hideminimap |r|c0000ffc0(toggle)|r QuestMap: Removes quest starter icons from Minimap", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie listdirection |r|r|c0000ffc0(list)|r QuestTracker: Change list order: Top-->Down or Bottom-->Up", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mapnotes |r|c0000ffc0(toggle)|r Questie: Commandline version of ToggleQuestie button", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie maxlevel |r|c0000ffc0(toggle)|r QuestMap: Filter - see setmaxlevel", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie minlevel |r|c0000ffc0(toggle)|r QuestMap: Filter - see setminlevel", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie mintracker |r|c0000ffc0(toggle)|r QuestTracker: Minimize or Maximize the QuestieTracker", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie NUKE |r|r|c0000ffc0(Pop-up)|r Database: Resets ALL Questie data and settings", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie professions |r|c0000ffc0(toggle)|r QuestQuest: Profession quest filter", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setmaxlevel |r|c0000ffc0<number>|r QuestMap: Show quests <X> levels above players level (default=7)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie setminlevel |r|c0000ffc0<number>|r QuestMap: Show quests <X> levels below players level (default=4)", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie settings |r|c0000ffc0(list)|r Questie: Displays your current toggles and settings.", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie showobjectives |r|c0000ffc0(toggle)|r QuestTracker: Show only quest objectives for actively tracked quests  ", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tooltips |r|c0000ffc0(toggle)|r QuestMobs&Items: Always show quest and objective tool tips", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie tracker |r|c0000ffc0(toggle)|r QuestTracker: Turn on and off the quest tracker", 0.75, 0.75, 0.75);
        DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie qtscale |r|c0000ffc0(small|medium|large)|r QuestTracker: Adjust the scale of the tracker (default=small)", 0.75, 0.75, 0.75);
        if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then
            return
        elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
            DEFAULT_CHAT_FRAME:AddMessage("|c0000c0ff  /questie resizemap |r--|c0000ffc0(toggle)|r QuestMap: Shrinks Worldmap and allows dragging", 0.75, 0.75, 0.75);
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
        [1] = { "alwaysShowObjectives" },
        [2] = { "arrowEnabled" },
        [3] = { "boldColors" },
        [4] = { "clusterQuests" },
        [5] = { "corpseArrow" },
        [6] = { "hideMinimapIcons" },
        [7] = { "maxLevelFilter" },
        [8] = { "maxShowLevel" },
        [9] = { "minLevelFilter" },
        [10] = { "minShowLevel" },
        [11] = { "resizeWorldmap" },
        [12] = { "showMapAids" },
        [13] = { "showProfessionQuests" },
        [14] = { "showToolTips" },
        [15] = { "showTrackerHeader" },
        [16] = { "trackerAlpha" },
        [17] = { "trackerBackground" },
        [18] = { "trackerEnabled" },
        [19] = { "trackerList" },
        [20] = { "trackerMinimize" },
        [21] = { "trackerScale" },
        [22] = { "getVersion" }
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
--Handles linked Quests from chat - functionality introduced in Burning Crusade.
---------------------------------------------------------------------------------------------------
local HookSetItemRef = SetItemRef
function SetItemRef(link, text, button)
    if ItemRefTooltip:IsVisible() then
        ItemRefTooltip:Hide()
    else
        isQuest, _, _ = string.find(link, "quest:(%d+):.*")
        if isQuest then
            _, _, QuestTitle = string.find(text, ".*|h%[(.*)%]|h.*")
            local questTitle = tostring(QuestTitle)
            if questTitle then
                ShowUIPanel(ItemRefTooltip)
                ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
                ItemRefTooltip:AddLine(questTitle)
                local questHash = Questie:getQuestHash(questTitle)
                questOb = nil
                local QuestName = QuestieHashMap[questHash].name
                if QuestName == questTitle then
                    local index = 0
                    for k,v in pairs(QuestieLevLookup[QuestName]) do
                        index = index + 1
                        if (index == 1) and (v[2] == questHash) and (k ~= "") then
                            questOb = k
                        elseif (index > 0) and(v[2] == questHash) and (k ~= "") then
                            questOb = k
                        elseif (index == 1) and (v[2] ~= questHash) and (k ~= "") then
                            questOb = k
                        end
                    end
                    ItemRefTooltip:AddLine("Started by: |cFFa6a6a6"..QuestieHashMap[questHash].startedBy.."|r",1,1,1)
                    if questOb ~= nil then
                        ItemRefTooltip:AddLine("|cffffffff"..questOb.."|r",1,1,1,true)
                    else
                        ItemRefTooltip:AddLine("Quest *Objective* not found in Questie Database!", 1, .8, .8)
                        ItemRefTooltip:AddLine("Please file a bug report on our GitHub portal:)", 1, .8, .8)
                        ItemRefTooltip:AddLine("https://github.com/AeroScripts/QuestieDev/issues", 1, .8, .8)
                    end
                    local _, _, questLevel = string.find(QuestieHashMap[questHash].questLevel, "(%d+)")
                    if questLevel ~= 0 and questLevel ~= "0" then
                        local color = GetDifficultyColor(questLevel)
                        ItemRefTooltip:AddLine("Quest Level " ..QuestieHashMap[questHash].questLevel, color.r, color.g, color.b)
                    end
                    ItemRefTooltip:Show()
                else
                    ShowUIPanel(ItemRefTooltip)
                    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
                    ItemRefTooltip:AddLine(questTitle, 1,1,0)
                    ItemRefTooltip:AddLine("Quest not found in Questie Database!", 1, .8, .8)
                    ItemRefTooltip:AddLine("Please file a bug report on our GitHub portal:)", 1, .8, .8)
                    ItemRefTooltip:AddLine("https://github.com/AeroScripts/QuestieDev/issues", 1, .8, .8)
                end
                ItemRefTooltip:Show()
            end
        else
            HookSetItemRef(link, text, button)
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
