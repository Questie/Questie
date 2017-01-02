---------------------------------------------------------------------------------------------------
-- Name: QuestieQuest
-- Description: Handles all the quest related functions
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
-- Setup tracker frame and event handler
---------------------------------------------------------------------------------------------------
local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience
QuestieTracker = CreateFrame("Frame", "QuestieTracker", UIParent, "ActionButtonTemplate")

function QuestieTracker:OnEvent() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
    QuestieTracker[event](QuestieTracker, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to Questie:event methods
end
---------------------------------------------------------------------------------------------------
-- Global vars
---------------------------------------------------------------------------------------------------
QuestieTracker.hasCleared = false
QuestieTracker.lastUpdate = 0;
QuestieTracker.questButtons = {};
QuestieTracker.GeneralInterval = 0;
QuestieTracker.btnUpdate = 1;
---------------------------------------------------------------------------------------------------
-- OnUpdate
---------------------------------------------------------------------------------------------------
function QuestieTracker_OnUpdate()
    if (IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest")) then
        if (QuestieConfig.trackerEnabled == true) then
            QuestWatchFrame:Hide();
            EQL3_QuestWatchFrame:Hide();
        elseif (QuestieConfig.trackerEnabled == false) then
            QuestWatchFrame:Hide();
            QuestieTracker:Hide();
            QuestieTracker.frame:Hide();
        end
    elseif (not IsAddOnLoaded("EQL3") or not IsAddOnLoaded("ShaguQuest")) then
        if (QuestieConfig.trackerEnabled == true) then
            QuestWatchFrame:Hide();
        elseif (QuestieConfig.trackerEnabled == false) then
            QuestieTracker:Hide();
            QuestieTracker.frame:Hide();
        end
    end
    if GetTime() - QuestieTracker.lastUpdate >= 1 then
        QuestieTracker:fillTrackingFrame()
        QuestieTracker.lastUpdate = GetTime()
        QuestieTracker:syncEQL3()
        QuestieTracker:syncQuestWatch()
        if (QuestieConfig.showMapAids == true) or (QuestieConfig.alwaysShowQuests == true) or ((QuestieConfig.showMapAids == true) and (QuestieConfig.alwaysShowQuests == false)) then
            Questie:SetAvailableQuests()
            Questie:RedrawNotes()
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Register events
---------------------------------------------------------------------------------------------------
QuestieTracker:SetScript("OnEvent", QuestieTracker.OnEvent)
QuestieTracker:SetScript("OnUpdate", QuestieTracker_OnUpdate)
QuestieTracker:RegisterEvent("PLAYER_LOGIN")
QuestieTracker:RegisterEvent("ADDON_LOADED")
---------------------------------------------------------------------------------------------------
-- WoW Functions --PERFORMANCE CHANGE--
---------------------------------------------------------------------------------------------------
local QGet_QuestLogTitle = GetQuestLogTitle;
local QGet_NumQuestLeaderBoards = GetNumQuestLeaderBoards;
local QGet_QuestLogLeaderBoard = GetQuestLogLeaderBoard;
---------------------------------------------------------------------------------------------------
-- Color quest objective scheme for quest tracker color option 2
---------------------------------------------------------------------------------------------------
function QuestieTracker:getRGBForObjectiveBold(objective)
    if not (type(objective) == "function") then
        local lastIndex = findLast(objective, ":");
        if not (lastIndex == nil) then
            local progress = string.sub(objective, lastIndex+2);
            local slash = findLast(progress, "/");
            local have = tonumber(string.sub(progress, 0, slash-1))
            local need = tonumber(string.sub(progress, slash+1))
            if not have or not need then
                return 1, 0, 0;
            end
            local float = have / need;
            if float < .49 then
                return 1, 0+float/.5, 0;
            end
            if float == .50 then
                return 1, 1, 0;
            end
            if float > .50 then
                return 1-float/2, 1, 0;
            end
        end
    end
    return 0, 1, 0;
end
---------------------------------------------------------------------------------------------------
-- Color quest objective scheme for quest tracker color option 1 (default)
---------------------------------------------------------------------------------------------------
function QuestieTracker:getRGBForObjective(objective)
    if not (type(objective) == "function") then
        local lastIndex = findLast(objective, ":");
        if not (lastIndex == nil) then
            local progress = string.sub(objective, lastIndex+2);
            local slash = findLast(progress, "/");
            local have = tonumber(string.sub(progress, 0, slash-1))
            local need = tonumber(string.sub(progress, slash+1))
            if not have or not need then
                return 0.8, 0.8, 0.8;
            end
            local float = have / need;
            return 0.8-float/2, 0.8+float/3, 0.8-float/2;
        end
    end
    return 0.3, 1, 0.3;
end
---------------------------------------------------------------------------------------------------
-- Clears tracking frame
---------------------------------------------------------------------------------------------------
function QuestieTracker:clearTrackingFrame()
    for i=1, 8 do
        getglobal("QuestieTrackerButton"..i):Hide();
        for j=1,20 do
            getglobal("QuestieTrackerButton"..i.."QuestWatchLine"..j):Hide();
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Makes or retrieves one of the quest objective buttons
---------------------------------------------------------------------------------------------------
function QuestieTracker:createOrGetTrackingButton(index)
    if QuestieTracker.questButtons[index] == nil then
        local parent;
        local parentString;
        if index == 1 then
            parent = QuestieTracker.frame;
        else
            parent = QuestieTracker.questButtons[index-1]; -- this allows easy dynamic positioning
        end
        local btn = CreateFrame("Button", "QuestieTrackerButtonNew"..index, QuestieTracker.frame);
        btn.objectives = {};
        btn:SetWidth(0);
        btn:SetHeight(0);
        btn:EnableMouse(true);
        btn:SetMovable(true);
        btn:SetScript("OnDragStart", QuestieTracker.frame.StartMoving)
        btn:SetScript("OnDragStop", QuestieTracker.frame.StopMovingOrSizing)
        btn:SetScript("OnMouseDown", function()
            btn.dragstartx, btn.dragstarty = GetCursorPosition();
            if IsControlKeyDown() and IsShiftKeyDown() then
                QuestieTracker.frame:StartMoving();
            end
        end);
        btn:SetScript("OnMouseUp", function()
            local dragstopx, dragstopy = GetCursorPosition();
            if (btn.dragstartx == dragstopx and btn.dragstarty == dragstopy) then
                btn:click();
            end
            QuestieTracker.frame:StopMovingOrSizing();
            QuestieTracker.frame:SetUserPlaced(false);
            QuestieTracker:saveFramePosition();
        end);
        btn.dragstartx = 0;
        btn.dragstarty = 0;
        btn:SetScript("OnEnter", function()
            QuestieTracker.frame.texture:SetAlpha(0.3);
        end);
        btn:SetScript("OnLeave", function()
            QuestieTracker.frame.texture:SetAlpha(0.0);
        end);
        btn:RegisterForClicks("RightButtonDown","LeftButtonUp", "LeftClick");
        btn.click = function()
            if (QuestieConfig.arrowEnabled == true) then
                SetArrowObjective(btn.hash);
            else
                return
            end
        end
        if (QuestieConfig.showTrackerHeader == true) then
            if (QuestieConfig.trackerList == true) then
                if index == 1 then
                    btn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 22);
                else
                    btn:SetPoint("BOTTOMLEFT", parent, "TOPLEFT",  0, 2);
                end
            elseif (QuestieConfig.trackerList == false) then
                if index == 1 then
                    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -22);
                else
                    btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT",  0, -2);
                end
            end
        elseif (QuestieConfig.showTrackerHeader == false) then
            if (QuestieConfig.trackerList == true) then
                if index == 1 then
                    btn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
                else
                    btn:SetPoint("BOTTOMLEFT", parent, "TOPLEFT",  0, 0);
                end
            elseif (QuestieConfig.trackerList == false) then
                if index == 1 then
                    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -10);
                else
                    btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT",  0, -2);
                end
            end
        end
        local quest = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        quest:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, 0)
        btn.quest = quest;
        local level = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        level:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, 0)
        btn.level = level;
        QuestieTracker.questButtons[index] = btn;
    end
    return QuestieTracker.questButtons[index];
end
QuestieTracker.highestIndex = 0;
---------------------------------------------------------------------------------------------------
-- Determines quest difficulty color based on payers level
---------------------------------------------------------------------------------------------------
function QuestieTracker:GetDifficultyColor(level)
    if level == nil then return "FFFFFFFF"; end
    local levelDiff = level - UnitLevel("player");
    if ( levelDiff >= 5 ) then
        return "FFFF1A1A";
    elseif ( levelDiff >= 3 ) then
        return "FFFF8040";
    elseif ( levelDiff >= -2 ) then
        return "FFFFFF00";
    elseif ( -levelDiff <= GetQuestGreenRange() ) then
        return "FF40C040";
    else
        return "FFC0C0C0";
    end
end
---------------------------------------------------------------------------------------------------
local function RGBToHex(r, g, b)
    if r > 255 then r = 255; end
    if g > 255 then g = 255; end
    if b > 255 then b = 255; end;
    return string.format("%02x%02x%02x", r, g, b)
end
---------------------------------------------------------------------------------------------------
local function fRGBToHex(r, g, b)
    return RGBToHex(r*254, g*254, b*254);
end
---------------------------------------------------------------------------------------------------
-- Adds quest type 'objective' text to quest objective button
---------------------------------------------------------------------------------------------------
function QuestieTracker:AddObjectiveToButton(button, objective, index)
    local objt;
    if button.objectives[index] == nil then
        objt = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    else
        objt = button.objectives[index];
    end
    objt:SetPoint("TOPLEFT", button, "TOPLEFT", 20, -(index * 11+1))
    if QuestieConfig.boldColors == true then
        local r, g, b = QuestieTracker:getRGBForObjectiveBold(objective["desc"]);
        local clr = fRGBToHex(r, g, b);
        objt:SetText("|cFF"..clr..objective["desc"].."|r");
        button.objectives[index] = objt;
    else
        local r, g, b = QuestieTracker:getRGBForObjective(objective["desc"]);
        local clr = fRGBToHex(r, g, b);
        objt:SetText("|cFF"..clr..objective["desc"].."|r");
        button.objectives[index] = objt;
    end
end
---------------------------------------------------------------------------------------------------
-- Adds quest type 'event' text to quest objective button
---------------------------------------------------------------------------------------------------
function QuestieTracker:AddEventToButton(button, objective, index)
    local objt;
    if button.objectives[index] == nil then
        objt = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    else
        objt = button.objectives[index];
    end
    objt:SetPoint("TOPLEFT", button, "TOPLEFT", 20, -(index * 11+1))
    if QuestieConfig.boldColors == true then
        local r, g, b = QuestieTracker:getRGBForObjectiveBold(objective["desc"]);
        local clr = fRGBToHex(r, g, b);
        objt:SetText("|cFFFF0000"..objective["desc"].."|r");
        button.objectives[index] = objt;
    else
        local r, g, b = QuestieTracker:getRGBForObjective(objective["desc"]);
        local clr = fRGBToHex(r, g, b);
        objt:SetText("|cFFCCCCCC"..objective["desc"].."|r");
        button.objectives[index] = objt;
    end
end
---------------------------------------------------------------------------------------------------
-- Finds quest finisher location by type and name
---------------------------------------------------------------------------------------------------
function QuestieTracker:GetFinisherLocation(typ, name)
    local C, Z, X, Y;
    if typ == "monster" then
        local npc = QuestieMonsters[name];
        if npc == nil then
            npc = QuestieAdditionalStartFinishLookup[name];
            if not (npc == nil) then
                C, Z, X, Y = npc[1], npc[2], npc[3], npc[4];
            else
            end
        else
            local loc = npc['locations'][1];
            mapid = loc[1];
            x = loc[2];
            y = loc[3];
            C, Z, X, Y = QuestieZoneIDLookup[mapid][4], QuestieZoneIDLookup[mapid][5], x, y
        end
    elseif typ == "object" then
        local obj = QuestieObjects[name];
        if not (obj == nil) then
            local loc = obj['locations'][1];
            mapid = loc[1];
            x = loc[2];
            y = loc[3];
            C, Z, X, Y = QuestieZoneIDLookup[mapid][4], QuestieZoneIDLookup[mapid][5], x, y
        else
            local npc = QuestieMonsters[name];
            if npc == nil then
                npc = QuestieAdditionalStartFinishLookup[name];
                if not (npc == nil) then
                    C, Z, X, Y = npc[1], npc[2], npc[3], npc[4];
                else
                end
            else
                local loc = npc['locations'][1];
                mapid = loc[1];
                x = loc[2];
                y = loc[3];
                C, Z, X, Y = QuestieZoneIDLookup[mapid][4], QuestieZoneIDLookup[mapid][5], x, y
            end
        end
    end
    return C, Z, X, Y;
end
---------------------------------------------------------------------------------------------------
-- Populates the quest tracker frame with objective buttons
---------------------------------------------------------------------------------------------------
function QuestieTracker:fillTrackingFrame()
  local index = 1;
    local sortedByDistance = {};
    local distanceControlTable = {};
    local C,Z,X,Y = Astrolabe:GetCurrentPlayerPosition() -- continent, zone, x, y
    local distanceNotes = {};
    local objc = 0;
    QuestieTracker.GeneralInterval = QuestieTracker.GeneralInterval + 1;
    if (QuestieTracker.GeneralInterval > (QuestieTracker.btnUpdate*0.99)) then
        QuestieTracker.GeneralInterval = 0
        for hash,quest in pairs(QuestieHandledQuests) do
            if (QuestieTrackedQuests[hash] ~= nil) and (QuestieTrackedQuests[hash]["tracked"] == true) and (QuestieHashMap[hash]) then
                objc = 0;
                if QuestieTrackedQuests[hash]["isComplete"] then
                else
                    for name,notes in pairs(quest.objectives.objectives) do
                        for k,v in pairs(notes) do
                            if not v.done then
                                local continent, zone, xNote, yNote = QuestieZoneIDLookup[v.mapid][4], QuestieZoneIDLookup[v.mapid][5], v.x, v.y
                                if continent and zone and xNote and yNote then
                                    local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, continent, zone, xNote, yNote )
                                    if dist and xDelta and yDelta then
                                        local info = {
                                            ["dist"] = dist,
                                            ["hash"] = hash,
                                            ["xDelta"] = xDelta,
                                            ["yDelta"] = yDelta,
                                            ["c"] = continent,
                                            ["z"] = zone,
                                            ["x"] = xNote,
                                            ["y"] = yNote,
                                        }
                                        objc = objc + 1;
                                        table.insert(distanceNotes, info);
                                    end
                                end
                            end
                        end
                    end
                end
                if objc == 0 then
                    local continent, zone, xNote, yNote = QuestieTracker:GetFinisherLocation(QuestieHashMap[hash]['finishedType'], QuestieHashMap[hash]['finishedBy']);
                    if continent and zone and xNote and yNote then
                        local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, continent, zone, xNote, yNote );
                        if dist and xDelta and yDelta  then
                            local info = {
                                ["dist"] = dist,
                                ["hash"] = hash,
                                ["xDelta"] = xDelta,
                                ["yDelta"] = yDelta,
                                ["c"] = continent,
                                ["z"] = zone,
                                ["x"] = xNote,
                                ["y"] = yNote,
                            }
                            table.insert(distanceNotes, info);
                        end
                    end
                end
            end
        end
    end
    sort(distanceNotes, function (a, b)
        return a["dist"] < b["dist"]
    end)
    for k,v in pairs(distanceNotes) do
        if not distanceControlTable[v["hash"]] then
            distanceControlTable[v["hash"]] = true
            table.insert(sortedByDistance, v);
        end
        distanceNotes = {}
    end
    if QuestieConfig.boldColors == true then
        for i,v in pairs(sortedByDistance) do
            local hash = v["hash"];
            local quest = QuestieTrackedQuests[hash];
            local button = QuestieTracker:createOrGetTrackingButton(index);
            button.hash = hash;
            local colorString = "|c" .. QuestieTracker:GetDifficultyColor(quest["level"]);
            local titleData = colorString;
                if QuestieConfig['alwaysShowLevel'] then
                    if quest["questTag"] then
                        titleData = titleData .. "[" .. quest["level"] .. "+" .. "] " ;
                    else
                        titleData = titleData .. "[" .. quest["level"] .. "] " ;
                    end
                end
                titleData = titleData .. "|r|cFFFFFFFF" .. quest["questName"] .. "|r";
                if QuestieConfig['AlwaysShowDistance'] then
                    titleData = titleData .. " ("..math.floor(v["dist"]).." Yd)";
                end
            button.quest:SetText(titleData);
            local obj = 1;
            if quest["questTag"] then
                v["title"] = colorString .. "[" .. quest["level"] .. "+" .. "] |r" .. quest["questName"];
            else
                v["title"] = colorString .. "[" .. quest["level"] .. "] |r" .. quest["questName"];
            end
            quest["arrowPoint"] = v
            if quest["isComplete"] or quest["leaderboards"] == 0 then
            QuestieTracker:AddObjectiveToButton(button, {['desc']="Quest Complete!"}, obj);
                obj = 2;
            else
                while true do
                    local beefcake = quest["objective" .. obj];
                    if beefcake == nil then break; end
                    if beefcake["type"] == "event" then
                        QuestieTracker:AddEventToButton(button, beefcake, obj);
                        obj = obj + 1;
                    else
                        QuestieTracker:AddObjectiveToButton(button, beefcake, obj);
                        obj = obj + 1;
                    end
                end
            end
            button.currentObjectiveCount = obj - 1;
            local heightLoss = 0;
            while true do
                if button.objectives[obj] == nil then break; end
                button.objectives[obj]:SetText(""); --hecks
                heightLoss = heightLoss + 11;
                obj = obj + 1;
            end
            button:SetHeight(14 + (button.currentObjectiveCount * 11));
            button:SetWidth(250);
            button:Show();
            if (QuestieConfig.showTrackerHeader == true) then
                local numEntries, numQuests = GetNumQuestLogEntries();
                watcher:SetText("QuestLog Status: ("..numQuests.."/20)");
                QuestieTrackerHeader:Show();
            end
            index = index + 1;
        end
        QuestieTracker.highestIndex = index - 1;
        while true do
            local d = QuestieTracker.questButtons[index];
            if d == nil then break end;
            d:Hide();
            index = index + 1;
        end
        if (QuestieConfig.trackerEnabled == true) then
            QuestieTracker.frame:Show();
        else
            QuestieTracker:Hide()
            QuestieTracker.frame:Hide()
        end
    else
        for i,v in pairs(sortedByDistance) do
            local hash = v["hash"];
            local quest = QuestieTrackedQuests[hash];
            local button = QuestieTracker:createOrGetTrackingButton(index);
            button.hash = hash;
            local colorString = "|c" .. QuestieTracker:GetDifficultyColor(quest["level"]);
            local titleData = colorString;
                if QuestieConfig['alwaysShowLevel'] then
                    if quest["questTag"] then
                        titleData = titleData .. "[" .. quest["level"] .. "+" .. "] " ;
                    else
                        titleData = titleData .. "[" .. quest["level"] .. "] " ;
                    end
                end
                titleData = titleData .. quest["questName"];
                if QuestieConfig['AlwaysShowDistance'] then
                    titleData = titleData .. " ("..math.floor(v["dist"]).." Yd)";
                end
            titleData = titleData  .. "|r";
            button.quest:SetText(titleData);
            local obj = 1;
            if quest["questTag"] then
                v["title"] = colorString .. "[" .. quest["level"] .. "+" .. "] " .. quest["questName"] .. "|r";
            else
                v["title"] = colorString .. "[" .. quest["level"] .. "] " .. quest["questName"] .. "|r";
            end
            quest["arrowPoint"] = v
            if quest["isComplete"] or quest["leaderboards"] == 0 then
                QuestieTracker:AddObjectiveToButton(button, {['desc']="Quest Complete!"}, obj);
                obj = 2;
            else
                while true do
                    local beefcake = quest["objective" .. obj];
                    if beefcake == nil then break; end
                    if beefcake["type"] == "event" then
                        QuestieTracker:AddEventToButton(button, beefcake, obj);
                        obj = obj + 1;
                    else
                        QuestieTracker:AddObjectiveToButton(button, beefcake, obj);
                        obj = obj + 1;
                    end
                end
            end
            button.currentObjectiveCount = obj - 1;
            local heightLoss = 0;
            while true do
                if button.objectives[obj] == nil then break; end
                button.objectives[obj]:SetText(""); --hecks
                heightLoss = heightLoss + 11;
                obj = obj + 1;
            end
            button:SetHeight(14 + (button.currentObjectiveCount * 11));
            button:SetWidth(250);
            button:Show();
            if (QuestieConfig.showTrackerHeader == true) then
                local numEntries, numQuests = GetNumQuestLogEntries();
                watcher:SetText("QuestLog Status: ("..numQuests.."/20)");
                QuestieTrackerHeader:Show();
            end
            index = index + 1;
        end
        QuestieTracker.highestIndex = index - 1;
        while true do
            local d = QuestieTracker.questButtons[index];
            if d == nil then break end;
            d:Hide();
            index = index + 1;
        end
        if (QuestieConfig.trackerEnabled == true) then
            QuestieTracker.frame:Show();
        else
            QuestieTracker:Hide()
            QuestieTracker.frame:Hide()
        end
    end
    sortedByDistance = {}
end
---------------------------------------------------------------------------------------------------
-- Creates a blank quest tracking frame and sets up the optional 'header'
---------------------------------------------------------------------------------------------------
function QuestieTracker:createTrackingFrame()
    QuestieTracker.frame = CreateFrame("Frame", "QuestieTrackerFrame", UIParent);
    QuestieTracker.frame:SetWidth(1);
    QuestieTracker.frame:SetHeight(1);
    QuestieTracker.frame:SetPoint(
        QuestieTrackerVariables["position"]["point"],
        QuestieTrackerVariables["position"]["relativeTo"],
        QuestieTrackerVariables["position"]["relativePoint"],
        QuestieTrackerVariables["position"]["xOfs"],
        QuestieTrackerVariables["position"]["yOfs"]
    );
    QuestieTracker.frame.texture = QuestieTracker.frame:CreateTexture(nil, "BACKGROUND");
    QuestieTracker.frame.texture:SetTexture(0,0,0); -- black
    QuestieTracker.frame.texture:SetAlpha(0.0);
    QuestieTracker.frame.texture:SetAllPoints(QuestieTracker.frame);
    if (QuestieConfig.trackerEnabled == true) then
        QuestieTracker.frame:Show();
    else
        QuestieTracker:Hide()
        QuestieTracker.frame:Hide()
    end
    QuestieTracker.frame:EnableMouse(true);
    QuestieTracker.frame:SetMovable(true);
    --Fix submitted by wardz - thank you!
    QuestieTracker.frame:SetClampedToScreen(true);
    QuestieTracker.frame.prevoffset = 0;
    QuestieTracker.frame:SetScript("OnMouseUp", function()
        this:StopMovingOrSizing();
        this:SetUserPlaced(false);
        QuestieTracker:saveFramePosition();
    end);
    if (QuestieConfig.trackerList == true) then
        local header = CreateFrame("Button", "QuestieTrackerHeader", QuestieTracker.frame);
        watcher = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        watcher:SetPoint("BOTTOMLEFT", QuestieTracker.frame, "BOTTOMLEFT", 10, 8)
        QuestieTrackerHeader:Hide();
    elseif (QuestieConfig.trackerList == false) then
        local header = CreateFrame("Button", "QuestieTrackerHeader", QuestieTracker.frame);
        watcher = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        watcher:SetPoint("TOPLEFT", QuestieTracker.frame, "TOPLEFT", 10, -8)
        QuestieTrackerHeader:Hide();
    end
end
---------------------------------------------------------------------------------------------------
-- Adds or removes quests to be tracked from the quest tracker. Also handles 'chat linking'.
---------------------------------------------------------------------------------------------------
function QuestLogTitleButton_OnClick(button)
    if (IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest")) then
        local questName = this:GetText();
        local questIndex = this:GetID() + FauxScrollFrame_GetOffset(EQL3_QuestLogListScrollFrame);
        if(button == "LeftButton") then
            if ( IsShiftKeyDown() ) then
                if( IsControlKeyDown() ) then
                    if ( this.isHeader ) then
                        return;
                    end
                    if ( not ChatFrameEditBox:IsVisible() ) then
                        EQL3_ClearTracker();
                        AddQuestWatch(questIndex);
                        QuestieTracker:syncEQL3();
                        QuestWatch_Update();
                    end
                else
                    local questLogTitleText, isHeader, isCollapsed, firstTrackable, lastTrackable, numTracked, numUntracked;
                    lastTrackable = -1;
                    numTracked = 0;
                    numUntracked = 0;
                    local track = false;
                    if ( this.isHeader ) then
                        for i=1, GetNumQuestLogEntries(), 1 do
                            questLogTitleText, _, _, isHeader, isCollapsed, _ = GetQuestLogTitle(i);
                            if ( questLogTitleText == questName ) then
                                track = true;
                                firstTrackable = i+1;
                            elseif ( track ) then
                                if ( not isHeader ) then
                                    if( IsQuestWatched(i) ) then
                                        numTracked = numTracked+1;
                                        RemoveQuestWatch(i);
                                        QuestieTracker:setQuestInfo(i);
                                    else
                                        numUntracked = numUntracked+1;
                                        RemoveQuestWatch(i);
                                        QuestieTracker:syncEQL3();
                                    end;
                                end
                                if ( isHeader and questLogTitleText ~= questName ) then
                                    lastTrackable = i-1;
                                    break;
                                end
                            end
                        end
                        if ( lastTrackable == -1 ) then
                            lastTrackable = GetNumQuestLogEntries();
                        end
                        if ( numUntracked == 0 ) then
                            for i=firstTrackable, lastTrackable, 1 do
                                RemoveQuestWatch(i);
                                QuestieTracker:syncEQL3();
                            end
                            QuestWatch_Update();
                        else
                            for i=firstTrackable, lastTrackable, 1 do
                                AddQuestWatch(i);
                                QuestieTracker:syncEQL3();
                            end
                            QuestWatch_Update();
                        end
                        QuestLog_Update();
                        return;
                    end
                    if ( ChatFrameEditBox:IsVisible() ) then
                        ChatFrameEditBox:Insert(gsub(this:GetText(), " *(.*)", "%1"));
                    else
                        if ( IsQuestWatched(questIndex) ) then
                            RemoveQuestWatch(questIndex);
                            QuestieTracker:syncEQL3();
                            QuestWatch_Update();
                        else
                            if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
                                UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME);
                                return;
                            end
                            AddQuestWatch(questIndex);
                            QuestieTracker:syncEQL3();
                            QuestWatch_Update();
                        end
                    end
                end
            end
            if(this.isHeader) then
                if ( EQL3_OrganizeFrame:IsVisible() ) then
                    EQL3_OrganizeFrame_Text:SetText(questName);
                    EQL3_OrganizeFrame_Text:ClearFocus();
                    EQL3_OrganizeFunctions(questName);
                    EQL3_OrganizeFrame:Hide();
                end
            end
        end
        if(QuestLog_SetSelection(questIndex) == 1) then
            if(not EQL3_QuestLogFrame_Description:IsVisible() and not IsShiftKeyDown() and not IsControlKeyDown() and QuestlogOptions[EQL3_Player].RestoreUponSelect == 1) then
                EQL3_Maximize();
            end
        end
        if(button == "LeftButton") then
            if( not IsShiftKeyDown() and IsControlKeyDown() ) then
                if ( ChatFrameEditBox:IsVisible() ) then
                    AddQuestStatusToChatFrame(questIndex, questName);
                end
            end
        else
            if ( not this.isHeader ) then
                if ( EQL3_IsQuestWatched(questIndex) ) then
                    EQL3_Organize_Popup_Track_Text:SetText(EQL3_POPUP_UNTRACK);
                else
                    EQL3_Organize_Popup_Track_Text:SetText(EQL3_POPUP_TRACK);
                end
                EQL3_Organize_Popup:ClearAllPoints();
                EQL3_Organize_Popup:SetPoint("TOPLEFT", this, "TOPLEFT", 24, 0);
                EQL3_Organize_Popup:Raise();
                EQL3_Organize_Popup:Show();
            end
        end
        QuestLog_Update();
    elseif (not IsAddOnLoaded("EQL3") or not IsAddOnLoaded("ShaguQuest")) then
        local questName = this:GetText();
        local questIndex = this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
        if ( IsShiftKeyDown() ) then
            if ( this.isHeader ) then
                return;
            end
            if ( ChatFrameEditBox:IsVisible() ) then
                ChatFrameEditBox:Insert(gsub(this:GetText(), " *(.*)", "%1"));
            else
                if ( IsQuestWatched(questIndex) ) then
                    QuestieTracker:setQuestInfo(questIndex);
                    tremove(QUEST_WATCH_LIST, questIndex);
                    RemoveQuestWatch(questIndex);
                    QuestWatch_Update();
                else
                    if ( GetNumQuestLeaderBoards(questIndex) == 0 ) then
                        UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0);
                        return;
                    end
                    if ( GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS ) then
                        UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
                        return;
                    end
                    QuestieTracker:setQuestInfo(questIndex);
                    AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE);
                    QuestWatch_Update();
                end
            end
        end
        QuestLog_SetSelection(questIndex)
        QuestLog_Update();
    end
end
---------------------------------------------------------------------------------------------------
-- Saves the position of the tracker after the user moves it
---------------------------------------------------------------------------------------------------
function QuestieTracker:saveFramePosition()
    local frame = getglobal("QuestieTrackerFrame");
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint();
    if (QuestieConfig.trackerList == true) then
        QuestieTrackerVariables = {};
        QuestieTrackerVariables["position"] = {
            ["point"] = "BOTTOMLEFT",
            ["relativePoint"] = "BOTTOMLEFT",
            ["relativeTo"] = "UIParent",
            ["yOfs"] = (QuestieTracker.frame:GetBottom()),
            ["xOfs"] = (QuestieTracker.frame:GetLeft()),
        };
    elseif (QuestieConfig.trackerList == false) then
            QuestieTrackerVariables = {};
            QuestieTrackerVariables["position"] = {
            ["point"] = "TOPLEFT",
            ["relativePoint"] = "TOPLEFT",
            ["relativeTo"] = "UIParent",
            ["yOfs"] = yOfs,
            ["xOfs"] = xOfs,
        };
    end
end
---------------------------------------------------------------------------------------------------
-- If a quest is tracked, add quest to tracker and retrieve cached quest data
---------------------------------------------------------------------------------------------------
local function trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end
---------------------------------------------------------------------------------------------------
function QuestieTracker:addQuestToTracker(hash, logId, level) -- never used???
    if (QuestieSeenQuests[hash] == 1) then
        return
    end
    if not QuestieTrackedQuests[hash] then
        QuestieTrackedQuests[hash] = {}
    end
    if not logId then
        logId = Questie:GetQuestIdFromHash(hash)
    end
    if logId == nil then
        DEFAULT_CHAT_FRAME:AddMessage("TrackerError! LogId still nil after GetQuestIdFromHash ", hash)
        return
    end
    local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(logId)
    if (not QuestieTrackedQuests[hash]["tracked"] == true) then
        QuestieTrackedQuests[hash]["tracked"] = false
    end
    QuestieTrackedQuests[hash]["questName"] = questName
    QuestieTrackedQuests[hash]["level"] = level
    QuestieTrackedQuests[hash]["questTag"] = questTag
    QuestieTrackedQuests[hash]["isComplete"] = isComplete
    QuestieTrackedQuests[hash]["leaderboards"] = QGet_NumQuestLeaderBoards(logId);
    for i=1, QGet_NumQuestLeaderBoards(logId) do
        local desc, type, done = QGet_QuestLogLeaderBoard(i, logId);
        if QuestieTrackedQuests[hash]["objective"..i] then
            if isComplete or (QGet_NumQuestLeaderBoards() == 0) or (QuestieTrackedQuests[hash]["objective"..i]["done"] == 1) then
                QuestieTrackedQuests[hash]["objective"..i] = {
                    ["desc"] = "Quest Complete!",
                    ["type"] = type,
                    ["done"] = true,
                    ["notes"] = {},
                }
            else
                QuestieTrackedQuests[hash]["objective"..i] = {
                    ["desc"] = desc,
                    ["type"] = type,
                    ["done"] = done,
                    ["notes"] = {},
                }
            end
        else
            QuestieTrackedQuests[hash]["objective"..i] = {
                ["desc"] = desc,
                ["type"] = type,
                ["done"] = done,
                ["notes"] = {},
            }
        end
    end
    LastQuestLogHashes = nil
    LastCount = 0
    Questie:CheckQuestLog()
    Questie:SetAvailableQuests()
    Questie:RedrawNotes()
    QuestieTracker:fillTrackingFrame()
    if QuestieTrackedQuests[hash]["objective1"] then
        if (QuestieTrackedQuests[hash]["objective1"]["done"] ~= true) or (QuestieTrackedQuests[hash]["objective1"]["done"] ~= 1) or (QuestieTrackedQuests[hash]["objective1"]["type"] == nil) or (not QuestieTrackedQuests[hash]["arrowPoint"])then
            QuestieTracker:updateFrameOnTracker(hash, logId, level)
        end
    end
end
---------------------------------------------------------------------------------------------------
-- If a quest is tracked, update quest on tracker and also update quest data cache
---------------------------------------------------------------------------------------------------
function QuestieTracker:updateFrameOnTracker(hash, logId, level)
    if (AUTO_QUEST_WATCH == "1") and (not QuestieTrackedQuests[hash]) then
        QuestieTracker:addQuestToTracker(hash, logId, level);
    end
    if (QuestieSeenQuests[hash] == 1) then
        return
    end
    if not QuestieTrackedQuests[hash] then
        QuestieTrackedQuests[hash] = {}
    end
    if not logId then
        logId = Questie:GetQuestIdFromHash(hash)
    end
    if logId == nil then
        DEFAULT_CHAT_FRAME:AddMessage("TrackerError! LogId still nil after GetQuestIdFromHash ", hash)
        return
    end
    local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(logId)
    QuestieTrackedQuests[hash]["questName"] = questName
    QuestieTrackedQuests[hash]["isComplete"] = isComplete
    QuestieTrackedQuests[hash]["questTag"] = questTag
    QuestieTrackedQuests[hash]["level"] = level
    QuestieTrackedQuests[hash]["leaderboards"] = QGet_NumQuestLeaderBoards(logId)
    local uggo = 0
    for i=1, QGet_NumQuestLeaderBoards(logId) do
        local desc, type, done = QGet_QuestLogLeaderBoard(i, logId)
        if not QuestieTrackedQuests[hash]["objective"..i] then
            QuestieTrackedQuests[hash]["objective"..i] = {}
        end
        QuestieTrackedQuests[hash]["objective"..i]["desc"] = desc
        QuestieTrackedQuests[hash]["objective"..i]["done"] = done
        uggo = i
    end
    uggo = uggo - 1
    QuestieTracker:fillTrackingFrame()
end
---------------------------------------------------------------------------------------------------
-- Removes quest from tracker when it's untracked - will not clear cached quest data
---------------------------------------------------------------------------------------------------
function QuestieTracker:removeQuestFromTracker(hash)
    if (QuestieSeenQuests[hash] == 0) and (QuestieTrackedQuests[hash] ~= nil) then
            QuestieTrackedQuests[hash]["tracked"] = false
    end
    QuestieTracker:fillTrackingFrame()
    Questie:SetAvailableQuests()
    Questie:RedrawNotes()
    if (QuestieTracker.highestIndex) == 0 then
        QuestieTrackerHeader:Hide()
        QuestieTracker.frame:SetHeight(1)
        QuestieTracker.frame:SetWidth(1)
    end
end
---------------------------------------------------------------------------------------------------
-- Determines quest log ID by quest name
---------------------------------------------------------------------------------------------------
function QuestieTracker:findLogIdByName(name)
    for i=1,GetNumQuestLogEntries() do
        local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(i);
        if(name == questName) then
            return i;
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Determines if a quest is currently being tracked
---------------------------------------------------------------------------------------------------
-- False: Quest is being tracked.
-- True: Quest is not being tracked.
function QuestieTracker:isTracked(quest)
    if quest == nil then return false; end
    if(type(quest) == "string") then
        local hash = Questie:GetHashFromName(quest)
        if(QuestieTrackedQuests[hash] and QuestieTrackedQuests[hash]["tracked"] ~= false) then
            return true
        end
    else
        local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(quest)
        local hash = Questie:GetHashFromName(questName)
        if(QuestieTrackedQuests[hash] and QuestieTrackedQuests[hash]["tracked"] ~= false) then
            return true
        end
    end
    return false
end
---------------------------------------------------------------------------------------------------
-- Adds quest to tracker based on quest ID
---------------------------------------------------------------------------------------------------
function QuestieTracker:setQuestInfo(id)
    local questInfo = {}
    local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(id)
    if not isHeader and not isCollapsed then
        local hash = Questie:GetHashFromName(questName)
        if(QuestieTracker:isTracked(questName)) then
            QuestieTracker:removeQuestFromTracker(hash)
            return
        end
        if QuestieTrackedQuests[hash] then
            QuestieTrackedQuests[hash]["tracked"] = true
            QuestieTracker:addQuestToTracker(hash, id, level)
        else
            QuestieTracker:addQuestToTracker(hash, id, level)
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Sets up quest tracker frame and sync's with EQL3 if present after player logs in
---------------------------------------------------------------------------------------------------
function QuestieTracker:PLAYER_LOGIN()
    QuestieTracker:createTrackingFrame()
    QuestieTracker:syncEQL3()
    QuestieTracker:syncQuestWatch()
end
---------------------------------------------------------------------------------------------------
-- EQL3 sync'ing function
---------------------------------------------------------------------------------------------------
function QuestieTracker:syncEQL3()
    if IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest") then
        for id=1, GetNumQuestLogEntries() do
            local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(id)
            if not isHeader and not isCollapsed then
                local hash = Questie:GetHashFromName(questName)
                if ( not isHeader and EQL3_IsQuestWatched(id) and not QuestieTracker:isTracked(questName) ) then
                    if QuestieTrackedQuests[hash] then
                        QuestieTrackedQuests[hash]["tracked"] = true
                        QuestieTracker:addQuestToTracker(hash, id, level)
                    else
                        QuestieTracker:addQuestToTracker(hash, id, level)
                    end
                elseif( not isHeader and not EQL3_IsQuestWatched(id) and QuestieTracker:isTracked(questName) ) then
                    QuestieTracker:removeQuestFromTracker(hash)
                end
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
-- WoW QuestWatch sync'ing function
---------------------------------------------------------------------------------------------------
function QuestieTracker:syncQuestWatch()
    if (not IsAddOnLoaded("EQL3")) or (not IsAddOnLoaded("ShaguQuest")) then
        for id=1, GetNumQuestLogEntries() do
            local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(id)
            if not isHeader and not isCollapsed then
                local hash = Questie:GetHashFromName(questName)
                if ( not isHeader and IsQuestWatched(id) and not QuestieTracker:isTracked(questName) ) then
                    if QuestieTrackedQuests[hash] then
                        QuestieTrackedQuests[hash]["tracked"] = true
                        QuestieTracker:addQuestToTracker(hash, id, level)
                    else
                        QuestieTracker:addQuestToTracker(hash, id, level)
                    end
                elseif( not isHeader and not IsQuestWatched(id) and QuestieTracker:isTracked(questName) ) then
                    QuestieTracker:removeQuestFromTracker(hash)
                end
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
-- If no quest tracker frame position is present in the users SavedVariables then this sets a
-- default location in memory so when the user desicdes to move it, it won't throw a nil error.
-- This function will also resize the world map from fullscreen to 80% via a slash toggle when
-- map mods such as Cartographer or MetaMap aren't being used.
---------------------------------------------------------------------------------------------------
function QuestieTracker:ADDON_LOADED()
    if not ( QuestieTrackerVariables ) then
        QuestieTrackerVariables = {}
        QuestieTrackerVariables["position"] = {
            point = "LEFT",
            relativeTo = "UIParent",
            relativePoint = "LEFT",
            xOfs = 0,
            yOfs = 0,
        };
    end
    if not QuestieTrackedQuests then
        QuestieTrackedQuests = {}
    end
    -- This adds the ability to scale the Worldmap from FULLSCREEN or to a WINDOW if a player isn't using Cargographer or MetaMap.
    if (QuestieConfig == nil) then return end
    if (QuestieConfig.resizeWorldmap == nil) then return end
    if (QuestieConfig.resizeWorldmap == false) then return end
    if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then
        return
    elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
        UIPanelWindows["WorldMapFrame"] =   { area = "center",  pushable = 0 }
        WorldMapFrame:SetFrameStrata("FULLSCREEN")
        WorldMapFrame:SetScript("OnKeyDown", nil)
        WorldMapFrame:RegisterForDrag("LeftButton")
        WorldMapFrame:EnableMouse(true)
        WorldMapFrame:SetMovable(true)
        WorldMapFrame:SetScale(.8)
        WorldMapTooltip:SetScale(1)
        WorldMapFrame:SetWidth(1024)
        WorldMapFrame:SetHeight(768)
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
        BlackoutWorld:Hide()
        WorldMapFrame:SetScript("OnDragStart", function()
            this:SetWidth(1024)
            this:SetHeight(768)
            this:StartMoving()
        end)
        WorldMapFrame:SetScript("OnDragStop", function()
            this:StopMovingOrSizing()
            this:SetWidth(1024)
            this:SetHeight(768)
            local x,y = this:GetCenter()
            local z = UIParent:GetEffectiveScale() / 2 / this:GetScale()
            x = x - GetScreenWidth() * z
            y = y - GetScreenHeight() * z
            this:ClearAllPoints()
            this:SetPoint("CENTER", "UIParent", "CENTER", x, y)
        end)
        WorldMapFrame:SetScript("OnShow", function()
            local continent = GetCurrentMapContinent()
            local zone = GetCurrentMapZone()
            SetMapZoom(continent, zone)
            SetMapToCurrentZone()
        end)
    end
end
