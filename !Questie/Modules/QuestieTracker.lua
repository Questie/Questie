---------------------------------------------------------------------------------------------------
-- Name: QuestieTracker
-- Description: Handles all the quest tracker related functions
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
QuestieTracker = CreateFrame("Frame", "QuestieTracker", UIParent, "ActionButtonTemplate");
---------------------------------------------------------------------------------------------------
-- Local vars
---------------------------------------------------------------------------------------------------
local QGet_TitleText = GetTitleText;
local QGet_QuestLogTitle = GetQuestLogTitle;
local QGet_NumQuestLeaderBoards = GetNumQuestLeaderBoards;
local QGet_QuestLogLeaderBoard = GetQuestLogLeaderBoard;
local QGet_QuestLogQuestText = GetQuestLogQuestText;
local QGet_NumQuestLogEntries = GetNumQuestLogEntries;
local QGet_NumQuestWatches = GetNumQuestWatches;
local QGet_QuestLogSelection = GetQuestLogSelection;
local QSelect_QuestLogEntry = SelectQuestLogEntry;
---------------------------------------------------------------------------------------------------
-- Global vars
---------------------------------------------------------------------------------------------------
QuestieTracker.hasCleared = false;
QuestieTracker.questsyncUpdate = 0;
QuestieTracker.trackerUpdate = 0;
QuestieTracker.trackerSize = 0;
QuestieTracker.GeneralInterval = 0;
QuestieTracker.btnUpdate = 1;
QuestieTracker.questButtons = {};
QuestieTracker.questNames = {};
QuestieTracker.questObjects = {};
QuestieTracker.MaxButtonWidths = {};
QuestieTracker.highestIndex = 0;
QAddQuestWatch = nil;
QRemoveQuestWatch = nil;
QAutoQuestWatch_CheckDeleted = nil;
QAutoQuestWatch_Update = nil;
QIsQuestWatched = nil;
QAutoQuestWatch_OnUpdate = nil;
---------------------------------------------------------------------------------------------------
-- OnEvent
---------------------------------------------------------------------------------------------------
function QuestieTracker:OnEvent()
    QuestieTracker[event](QuestieTracker, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
end
---------------------------------------------------------------------------------------------------
-- OnUpdate
---------------------------------------------------------------------------------------------------
function QuestieTracker_OnUpdate()
    if (IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest")) then
        if (QuestieConfig.trackerEnabled == true) then
            QuestWatchFrame:Hide();
            EQL3_QuestWatchFrame:Hide();
        else
            QuestieTracker.frame:Hide();
            QuestieTrackerHeader:Hide();
        end
    else
        if (QuestieConfig.trackerEnabled == true) then
            QuestWatchFrame:Hide();
        else
            QuestieTracker.frame:Hide();
            QuestieTrackerHeader:Hide();
        end
    end
    if GetTime() - QuestieTracker.trackerUpdate >= 2 then
        if (QuestieConfig.showMapNotes == true) or (QuestieConfig.alwaysShowObjectives == true) then
            QuestieTracker:SortTrackingFrame();
        end
    end
    QuestieTracker.trackerUpdate = GetTime();
end
---------------------------------------------------------------------------------------------------
-- Register events
---------------------------------------------------------------------------------------------------
QuestieTracker:SetScript("OnEvent", QuestieTracker.OnEvent);
QuestieTracker:SetScript("OnUpdate", QuestieTracker_OnUpdate);
---------------------------------------------------------------------------------------------------
-- Automatically Calculates QuestieTracker Height and Width
---------------------------------------------------------------------------------------------------
function QuestieTracker:updateTrackingFrameSize()
    if (QuestieConfig.trackerEnabled == true) then
        if (QuestieTracker.highestIndex == 0) or (QGet_NumQuestLogEntries == 0) then
            QuestieTracker.frame:SetHeight(0.1);
            QuestieTracker.frame:SetWidth(0.1);
            QuestieTracker.frame:SetBackdropColor(0,0,0,0);
            QuestieTracker.frame:Hide();
            if (QuestieConfig.showTrackerHeader == true) then
                QuestieTrackerHeader:Hide();
            end
            return;
        end
        QuestieTracker.frame:Hide();
        local lastButton = QuestieTracker.questButtons[QuestieTracker.highestIndex];
        if lastButton == nil then return; end
        local maxWidth = QuestieTracker.questButtons.maxWidth;
        if maxWidth == nil then maxWidth = 0; end
        local totalWidth = maxWidth;
        QuestieTracker.frame:SetWidth(totalWidth);
        if (QuestieConfig.trackerList == true) then
            local lastbuttonTop = lastButton:GetTop();
            local trackerBottom = QuestieTracker.frame:GetBottom();
            --what if nothing is tracked?
            if trackerBottom == nil then trackerBottom = 0; end
            if lastbuttonTop == nil then lastbuttonTop = 0; end
            --dynamically set the size of the tracker
            local totalHeight = lastbuttonTop - trackerBottom;
            if (QuestieConfig.showTrackerHeader == true) then
                QuestieTracker.frame:SetHeight(totalHeight + 7);
                if totalWidth < watcher:GetStringWidth() + 22 then
                    QuestieTracker.frame:SetWidth(watcher:GetStringWidth() + 22);
                end
            else
                QuestieTracker.frame:SetHeight(totalHeight + 11);
                QuestieTracker.frame:SetWidth(totalWidth);
            end
            QuestieTracker.frame:SetBackdropColor(0,0,0,QuestieConfig.trackerAlpha);
        else
            local lastbuttonBottom = lastButton:GetBottom();
            local trackerTop = QuestieTracker.frame:GetTop();
            --what if nothing is tracked?
            if trackerTop == nil then trackerTop = 0; end
            if lastbuttonBottom == nil then lastbuttonBottom = 0; end
            --dynamically set the size of the tracker
            local totalHeight = trackerTop - lastbuttonBottom;
            if (QuestieConfig.showTrackerHeader == true) then
                QuestieTracker.frame:SetHeight(totalHeight + 11);
                if totalWidth < watcher:GetStringWidth() + 22 then
                    QuestieTracker.frame:SetWidth(watcher:GetStringWidth() + 22);
                end
            else
                QuestieTracker.frame:SetHeight(totalHeight + 11);
                QuestieTracker.frame:SetWidth(totalWidth);
            end
            QuestieTracker.frame:SetBackdropColor(0,0,0,QuestieConfig.trackerAlpha);
        end
        QuestieTracker.frame:Show();
    end
end
---------------------------------------------------------------------------------------------------
-- Color quest objective scheme for quest tracker color option 2
---------------------------------------------------------------------------------------------------
function QuestieTracker:getRGBForObjective(objective)
    if QuestieConfig.boldColors == false then
        if not (type(objective) == "function") then
            local lastIndex = findLast(objective, ":");
            if not (lastIndex == nil) then
                local progress = string.sub(objective, lastIndex+2);
                local slash = findLast(progress, "/");
                local have = tonumber(string.sub(progress, 0, slash-1));
                local need = tonumber(string.sub(progress, slash+1));
                if not have or not need then return 0.8, 0.8, 0.8; end
                local float = have / need;
                return 0.8-float/2, 0.8+float/3, 0.8-float/2;
            end
        end
        return 0.3, 1, 0.3;
    else
        if not (type(objective) == "function") then
            local lastIndex = findLast(objective, ":");
            if not (lastIndex == nil) then
                local progress = string.sub(objective, lastIndex+2);
                local slash = findLast(progress, "/");
                local have = tonumber(string.sub(progress, 0, slash-1));
                local need = tonumber(string.sub(progress, slash+1));
                if not have or not need then return 1, 0, 0; end
                local float = have / need;
                if float < .49 then return 1, 0+float/.5, 0; end
                if float == .50 then return 1, 1, 0; end
                if float > .50 then return 1-float/2, 1, 0; end
            end
        end
        return 0, 1, 0;
    end
end
---------------------------------------------------------------------------------------------------
-- Clears tracking frame
---------------------------------------------------------------------------------------------------
function QuestieTracker:clearTrackingFrame()
    for i=1, 8 do
        getglobal("QuestieTrackerButtonNew"..i):Hide();
        for j=1,20 do
            getglobal("QuestieTrackerButtonNew"..i.."QuestWatchLine"..j):Hide();
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
            parent = QuestieTracker.questButtons[index-1];
        end
        local btn = CreateFrame("Button", "QuestieTrackerButtonNew"..index, QuestieTracker.frame);
        btn.objectives = {};
        btn:SetWidth(0);
        btn:SetHeight(0);
        btn:EnableMouse(true);
        btn:SetMovable(true);
        btn:SetScript("OnDragStart", QuestieTracker.frame.StartMoving);
        btn:SetScript("OnDragStop", QuestieTracker.frame.StopMovingOrSizing);
        btn:SetScript("OnMouseDown", function()
            btn.dragstartx, btn.dragstarty = GetCursorPosition();
            if IsControlKeyDown() and IsShiftKeyDown() then
                QuestieTracker.frame:StartMoving();
            end
        end)
        btn:SetScript("OnMouseUp", function()
            local dragstopx, dragstopy = GetCursorPosition();
            if (btn.dragstartx == dragstopx and btn.dragstarty == dragstopy) then
                btn:click();
            end
            QuestieTracker.frame:StopMovingOrSizing();
            QuestieTracker.frame:SetUserPlaced(false);
            QuestieTracker:saveFramePosition();
        end)
        btn:SetScript("OnEnter", function()
            local questHash = btn.hash;
            local quest = QuestieCachedQuests[questHash];
            local questTitle = quest["questName"];
            Tooltip = GameTooltip;
            local questOb = nil;
            if questTitle then
                local x = tonumber(QuestieTrackerVariables["position"]["xOfs"]);
                if (x > 0 and x < 700) or (x > 1280 and x < 1700) then
                    Tooltip:SetOwner(this, "ANCHOR_RIGHT");
                else
                    Tooltip:SetOwner(this, "ANCHOR_LEFT");
                end
                local index = 0;
                for k,v in pairs(Questie:SanitisedQuestLookup(QuestieHashMap[questHash].name)) do
                    index = index + 1;
                    if (index == 1) and (v[2] == questHash) and (k ~= "") then
                        questOb = k;
                    elseif (index > 0) and(v[2] == questHash) and (k ~= "") then
                        questOb = k;
                    elseif (index == 1) and (v[2] ~= questHash) and (k ~= "") then
                        questOb = k;
                    end
                end
                if (QuestieConfig.showToolTips == true) then
                    if questOb ~= nil and (quest["isComplete"] or quest["leaderboards"] == 0) then
                        Tooltip:AddLine("|cFFa6a6a6To finish this quest... |r",1,1,1,true);
                        Tooltip:AddLine("|cffffffff"..Questie:RemoveUniqueSuffix(questOb).."|r",1,1,1,true);
                    elseif questOb == nil then
                        Tooltip:AddLine("Quest *Objective* not found in Questie Database!", 1, .8, .8);
                        Tooltip:AddLine("Please file a bug report on our GitHub portal:)", 1, .8, .8);
                        Tooltip:AddLine("https://github.com/AeroScripts/QuestieDev/issues", 1, .8, .8);
                    end
                    Tooltip:Show();
                end
            end
        end)
        btn:SetScript("OnLeave", function()
            Tooltip:SetFrameStrata("TOOLTIP");
            Tooltip:Hide();
        end)
        btn.dragstartx = 0;
        btn.dragstarty = 0;
        btn:RegisterForClicks("RightButtonDown","LeftButtonUp", "LeftClick");
        btn.click = function()
            if (QuestieConfig.arrowEnabled == true) and (not IsShiftKeyDown()) then
                SetArrowObjective(btn.hash);
            else
                return;
            end
        end
        if (QuestieConfig.showTrackerHeader == true) then
            if (QuestieConfig.trackerList == true) then
                if index == 1 then
                    btn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 22);
                else
                    btn:SetPoint("BOTTOMLEFT", parent, "TOPLEFT",  0, 2);
                end
            else
                if index == 1 then
                    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -22);
                else
                    btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT",  0, -2);
                end
            end
        else
            if (QuestieConfig.trackerList == true) then
                if index == 1 then
                    btn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 10);
                else
                    btn:SetPoint("BOTTOMLEFT", parent, "TOPLEFT",  0, 0);
                end
            else
                if index == 1 then
                    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -10);
                else
                    btn:SetPoint("TOPLEFT", parent, "BOTTOMLEFT",  0, -2);
                end
            end
        end
        local quest = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        quest:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, 0);
        btn.quest = quest;
        local level = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        level:SetPoint("TOPLEFT", btn, "TOPLEFT", 10, 0);
        btn.level = level;
        QuestieTracker.questButtons[index] = btn;
    end
    return QuestieTracker.questButtons[index];
end
---------------------------------------------------------------------------------------------------
-- Determines quest difficulty color based on payers level
---------------------------------------------------------------------------------------------------
function QuestieTracker:GetDifficultyColor(level)
    if type(level) == "string" then
        for x in string.gfind(level, "%d+") do level = x; end
        level = tonumber(level);
    end
    if level == nil then return "FFFFFFFF"; end
    local levelDiff = level - UnitLevel("player");
    if (levelDiff >= 5) then return "FFFF1A1A";
    elseif (levelDiff >= 3) then return "FFFF8040";
    elseif (levelDiff >= -2) then return "FFFFFF00";
    elseif (-levelDiff <= GetQuestGreenRange()) then return "FF40C040";
    else return "FFC0C0C0"; end
end
---------------------------------------------------------------------------------------------------
-- todo move to QuestieUtils
function RGBToHex(r, g, b)
    if r > 255 then r = 255; end
    if g > 255 then g = 255; end
    if b > 255 then b = 255; end
    return string.format("%02x%02x%02x", r, g, b);
end
---------------------------------------------------------------------------------------------------
-- todo move to QuestieUtils
function fRGBToHex(r, g, b)
    return RGBToHex(r*254, g*254, b*254);
end
---------------------------------------------------------------------------------------------------
-- Adds quest type 'objective' text to quest objective button
---------------------------------------------------------------------------------------------------
function QuestieTracker:AddObjectiveToButton(button, objective, index)
    local objt;
    if button.objectives[index] == nil then
        objt = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    else
        objt = button.objectives[index];
    end
    objt:SetPoint("TOPLEFT", button, "TOPLEFT", 20, -(index * 11+1));
    local r, g, b = QuestieTracker:getRGBForObjective(objective["desc"]);
    local clr = fRGBToHex(r, g, b);
    objt:SetText("|cFF"..clr..objective["desc"].."|r");
    button.objectives[index] = objt;
    for i, v in (button.objectives) do
        local otextWidth = button.objectives[i]:GetStringWidth() + 32;
        table.insert(QuestieTracker.questObjects, otextWidth);
    end
    local omaxWidth = 0;
    for i, v in ipairs(QuestieTracker.questObjects) do
        if (QuestieTracker.questObjects) then
            omaxWidth = math.max(omaxWidth, v);
            table.insert(QuestieTracker.MaxButtonWidths, omaxWidth);
            QuestieTracker.questObjects = {};
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Adds quest type 'event' text to quest objective button
---------------------------------------------------------------------------------------------------
function QuestieTracker:AddEventToButton(button, objective, index)
    local objt;
    if button.objectives[index] == nil then
        objt = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    else
        objt = button.objectives[index];
    end
    objt:SetPoint("TOPLEFT", button, "TOPLEFT", 20, -(index * 11+1));
    local r, g, b = QuestieTracker:getRGBForObjective(objective["desc"]);
    local clr = fRGBToHex(r, g, b);
    if QuestieConfig.boldColors == true then
        objt:SetText("|cFFFF0000"..objective["desc"].."|r");
    else
        objt:SetText("|cFFCCCCCC"..objective["desc"].."|r");
    end
    button.objectives[index] = objt;
    for i, v in (button.objectives) do
	    local otextWidth = button.objectives[i]:GetStringWidth() + 32;
		table.insert(QuestieTracker.questObjects, otextWidth);
	end
	local omaxWidth = 0;
	for i, v in ipairs(QuestieTracker.questObjects) do
	    if (QuestieTracker.questObjects) then
		    omaxWidth = math.max(omaxWidth, v);
			table.insert(QuestieTracker.MaxButtonWidths, omaxWidth);
			QuestieTracker.questObjects = {};
		end
	end
end
---------------------------------------------------------------------------------------------------
-- Finds quest finisher location by type and name
---------------------------------------------------------------------------------------------------
function QuestieTracker:GetFinisherLocations(typ, name)
    local C, Z, X, Y;
    if typ == "monster" then
        local paths = GetMonsterLocations(name);
        return Questie:RecursiveGetPathLocations(paths);
    elseif typ == "object" then
        local paths = GetObjectLocations(name);
        return Questie:RecursiveGetPathLocations(paths);
    end
    return C, Z, X, Y;
end
---------------------------------------------------------------------------------------------------
-- Updates the QuestieTracker frames distance sorting feature
---------------------------------------------------------------------------------------------------
function QuestieTracker:SortTrackingFrame()
    local sortedByDistance = {};
    local distanceControlTable = {};
    local C,Z,X,Y = Astrolabe:GetCurrentPlayerPosition(); -- continent, zone, x, y
    local distanceNotes = {};
    local objc = 0;
    QuestieTracker.GeneralInterval = QuestieTracker.GeneralInterval + 1;
    if (QuestieTracker.GeneralInterval > (QuestieTracker.btnUpdate*0.99)) then
        QuestieTracker.GeneralInterval = 0;
        for hash, quest in pairs(QuestieHandledQuests) do
            local questTrack = QuestieCachedQuests[hash];
            if questTrack ~= nil and questTrack.tracked then
                local objectiveCount = 0;
                if not questTrack.isComplete then
                    for objectiveid, objective in pairs(quest.objectives) do
                        if not objective.done then
                            local locations = Questie:RecursiveGetPathLocations(objective.path);
                            for i, location in pairs(locations) do
                                local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, location[1], location[2], location[3], location[4]);
                                if dist and xDelta and yDelta then
                                    local info = {
                                        ["dist"] = dist,
                                        ["hash"] = hash,
                                        ["xDelta"] = xDelta,
                                        ["yDelta"] = yDelta,
                                        ["c"] = location[1],
                                        ["z"] = location[2],
                                        ["x"] = location[3],
                                        ["y"] = location[4],
                                    };
                                    objectiveCount = objectiveCount + 1;
                                    table.insert(distanceNotes, info);
                                end
                            end
                        end
                    end
                end
                if objectiveCount == 0 then
                    -- Show quest finished in tracker
                    local quest = QuestieHashMap[hash];
                    if quest ~= nil then
                        local locations = QuestieTracker:GetFinisherLocations(quest.finishedType, quest.finishedBy) or {};
                        for i, location in pairs(locations) do
                            local dist, xDelta, yDelta = Astrolabe:ComputeDistance( C, Z, X, Y, location[1], location[2], location[3], location[4]);
                            if dist and xDelta and yDelta then
                                local info = {
                                    ["dist"] = dist,
                                    ["hash"] = hash,
                                    ["xDelta"] = xDelta,
                                    ["yDelta"] = yDelta,
                                    ["c"] = location[1],
                                    ["z"] = location[2],
                                    ["x"] = location[3],
                                    ["y"] = location[4],
                                };
                                table.insert(distanceNotes, info);
                            end
                        end
                    end
                end
            end
        end
    end
    sort(distanceNotes, function (a, b)
        if (not a["dist"]) or (not b["dist"]) then
            return false;
        end
        return a["dist"] < b["dist"];
    end)
    for k,v in pairs(distanceNotes) do
        if not distanceControlTable[v["hash"]] then
            distanceControlTable[v["hash"]] = true;
            table.insert(sortedByDistance, v);
        end
    end
    for i,v in pairs(sortedByDistance) do
        local hash = v["hash"];
        local quest = QuestieCachedQuests[hash];
        local colorString = "|c" .. QuestieTracker:GetDifficultyColor(quest["level"]);
        if QuestieConfig.boldColors == true then
            if quest["questTag"] then
                v["title"] = colorString .. "[" .. quest["level"] .. "+" .. "] |r" .. quest["questName"];
            else
                v["title"] = colorString .. "[" .. quest["level"] .. "] |r" .. quest["questName"];
            end
        else
            if quest["questTag"] then
                v["title"] = colorString .. "[" .. quest["level"] .. "+" .. "] " .. quest["questName"] .. "|r";
            else
                v["title"] = colorString .. "[" .. quest["level"] .. "] " .. quest["questName"] .. "|r";
            end
        end
        quest["arrowPoint"] = v;
    end
    return sortedByDistance;
end
---------------------------------------------------------------------------------------------------
-- Populates the quest tracker frame with objective buttons
---------------------------------------------------------------------------------------------------
function QuestieTracker:FillTrackingFrame()
    local index = 1;
    local sortedByDistance = QuestieTracker:SortTrackingFrame();
    for i,v in pairs(sortedByDistance) do
        local hash = v["hash"];
        local quest = QuestieCachedQuests[hash];
        local button = QuestieTracker:createOrGetTrackingButton(index);
        button.hash = hash;
        local colorString = "|c" .. QuestieTracker:GetDifficultyColor(quest["level"]);
        local titleData = colorString;
        if quest["questTag"] then
            titleData = titleData .. "[" .. quest["level"] .. "+" .. "] ";
        else
            titleData = titleData .. "[" .. quest["level"] .. "] ";
        end
        if QuestieConfig.boldColors == true then
            titleData = titleData .. "|r|cFFFFFFFF" .. quest["questName"] .. "|r";
        else
            titleData = titleData .. quest["questName"];
            titleData = titleData  .. "|r";
        end
        button.quest:SetText(titleData);
        local obj = 1;
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
            button.objectives[obj]:SetText("");
            heightLoss = heightLoss + 11;
            obj = obj + 1;
        end
        button:SetHeight(14 + (button.currentObjectiveCount * 11));
        for i, v in (button.quest) do
            local qtextWidth = button.quest:GetStringWidth() + 20;
            table.insert(QuestieTracker.questNames, qtextWidth);
        end
        local qmaxWidth = 0;
        for i, v in ipairs(QuestieTracker.questNames) do
            if (QuestieTracker.questObjects) then
                qmaxWidth = math.max(qmaxWidth, v);
                table.insert(QuestieTracker.MaxButtonWidths, qmaxWidth);
                 QuestieTracker.questNames = {};
            end
        end
        local maxWidth = 0;
        for i, v in ipairs(QuestieTracker.MaxButtonWidths) do
            maxWidth = math.max(maxWidth, v);
            QuestieTracker.questButtons.maxWidth = maxWidth;
        end
        button:SetWidth(maxWidth);
        button:Show();
        if (QuestieConfig.showTrackerHeader == true) and (QuestieConfig.trackerEnabled == true) then
            local numEntries, numQuests = QGet_NumQuestLogEntries();
            watcher:SetText("QuestLog Status: ("..numQuests.."/20)");
            QuestieTrackerHeader:Show();
        end
        index = index + 1;
    end
    QuestieTracker.highestIndex = index - 1;
    while true do
        local d = QuestieTracker.questButtons[index];
        if d == nil then break; end
        d:Hide();
        index = index + 1;
    end
    if (QuestieConfig.trackerEnabled == true) and (QuestieConfig.trackerMinimize == false) then
        if (QuestieTracker.highestIndex >= 1) and (QuestieConfig.trackerBackground == false) then
            trackerWidth = QuestieTracker.questButtons.maxWidth;
            if (QuestieConfig.trackerList == false) then
                trackerHeight = QuestieTracker.frame:GetTop() - QuestieTracker.questButtons[QuestieTracker.highestIndex]:GetBottom();
            else
                trackerHeight = QuestieTracker.questButtons[QuestieTracker.highestIndex]:GetTop() - QuestieTracker.frame:GetBottom();
            end
            QuestieTracker.frame:SetWidth(trackerWidth);
            QuestieTracker.frame:SetHeight(trackerHeight);
        end
        QuestieTracker.MaxButtonWidths = {};
        QuestieTracker:updateTrackingFrameSize();
    end
end
---------------------------------------------------------------------------------------------------
-- Creates a blank quest tracking frame and sets up the optional haeder
---------------------------------------------------------------------------------------------------
function QuestieTracker:createTrackingFrame()
    QuestieTracker.frame = CreateFrame("Frame", "QuestieTrackerFrame", UIParent, "ActionButtonTemplate");
    if trackerWidth or trackerHeight == nil then trackerWidth = 1; trackerHeight = 1; end
    QuestieTracker.frame:SetWidth(trackerWidth);
    QuestieTracker.frame:SetHeight(trackerHeight);
    QuestieTracker.frame:SetPoint(
        QuestieTrackerVariables["position"]["point"],
        QuestieTrackerVariables["position"]["relativeTo"],
        QuestieTrackerVariables["position"]["relativePoint"],
        QuestieTrackerVariables["position"]["xOfs"],
        QuestieTrackerVariables["position"]["yOfs"]
    );
    QuestieTracker.frame:SetScale(QuestieConfig.trackerScale);
    if (QuestieConfig.trackerBackground == true) then
        QuestieTracker.frame:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile=true, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
        QuestieTracker.frame:SetBackdropColor(0,0,0,QuestieConfig.trackerAlpha);
    end
    QuestieTracker.frame:EnableMouse(true);
    QuestieTracker.frame:SetMovable(true);
    QuestieTracker.frame:SetClampedToScreen(true);
    QuestieTracker.frame.prevoffset = 0;
    QuestieTracker.frame:SetScript("OnMouseUp", function()
        this:StopMovingOrSizing();
        this:SetUserPlaced(false);
        QuestieTracker:saveFramePosition();
    end)
    --QuestTracker Header Button
    local header = CreateFrame("Button", "QuestieTrackerHeader", UIParent);
    if (QuestieConfig.trackerList == true) then
        if (QuestieConfig.showTrackerHeader == true) then
            watcher = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            watcher:SetPoint("BOTTOMLEFT", QuestieTracker.frame, "BOTTOMLEFT", 10, 8);
            --QuestTracker Minimize Button
            qmenu = CreateFrame("Button", "QuestieTrackerMenu", watcher.frame);
            qmenu:SetPoint("BOTTOMLEFT", QuestieTracker.frame, "BOTTOMLEFT", 6, 5);
        else
            watcher = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            watcher:SetPoint("BOTTOMLEFT", QuestieTracker.frame, "BOTTOMLEFT", 10, 8);
        end
    else
        if (QuestieConfig.showTrackerHeader == true) then
            watcher = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            watcher:SetPoint("TOPLEFT", QuestieTracker.frame, "TOPLEFT", 6, -8);
            --QuestTracker Minimize Button
            qmenu = CreateFrame("Button", "QuestieTrackerMenu", watcher.frame);
            qmenu:SetPoint("TOPLEFT", QuestieTracker.frame, "TOPLEFT", 0, -6);
        else
            watcher = header:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            watcher:SetPoint("TOPLEFT", QuestieTracker.frame, "TOPLEFT", 6, -8);
        end
    end
    if (QuestieConfig.showTrackerHeader == true) and (QuestieConfig.trackerEnabled == true) then
        qmenu:SetFrameStrata("HIGH");
        qmenu:SetWidth(180);
        qmenu:SetHeight(10);
        qmenu.texture = qmenu:CreateTexture(nil, "BACKGROUND");
        qmenu.texture:SetTexture(0,0,0);
        qmenu.texture:SetAlpha(0.0);
        qmenu.texture:SetAllPoints(qmenu);
        qmenu:EnableMouse(true);
        qmenu:SetScript("OnClick", function()
            if (QuestieConfig.trackerMinimize == false) then
                QuestieConfig.trackerMinimize = true;
                QuestieTracker.frame:Hide();
            else
               QuestieConfig.trackerMinimize = false;
               QuestieTracker.frame:Show();
            end
        end)
    end
    QuestieTrackerHeader:Hide();
    QuestieTracker.frame:Hide();
end
---------------------------------------------------------------------------------------------------
--Credit to Shagu for this fix for EQL3's freezing and event flooding upon Login.
--Let QuestWatch Update only be triggered once per second in the first 10 seconds after login.
---------------------------------------------------------------------------------------------------
function Questie:LoadEQL3Fix()
    if (IsAddOnLoaded("EQL3")) and (not IsAddOnLoaded("ShaguQuest")) then
        local EQL_Loader = CreateFrame("Frame",nil);
        EQL_Loader.tick = GetTime();
        EQL_Loader.step = 0;
        EQL_Loader:SetScript("OnUpdate", function()
            if EQL_Loader.tick + 1 <= GetTime() then
                EQL_Loader.abort = false;
                QuestWatch_Update();
                EQL_Loader.tick = GetTime();
                if EQL_Loader.step < 10 then
                    EQL_Loader.step = EQL_Loader.step + 1;
                else
                    EQL_Loader:Hide();
                end
            end
        end)
    ---------------------------------------------------------------------------------------------------
    --Intercepts and injects extra code into EQL3
    ---------------------------------------------------------------------------------------------------
        local QQuestWatch_Update = QuestWatch_Update;
        function QuestWatch_Update()
            if EQL_Loader.abort == nil then EQL_Loader.abort = true end
            if(not EQL3_Temp.hasManaged) or (EQL_Loader.abort == true and EQL_Loader.step < 10) then
                QuestWatchFrame:Hide();
                return;
            end
            EQL_Loader.abort = true;
            QQuestWatch_Update();
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Adds or removes quests to be tracked from the quest tracker. Also handles 'chat linking'.
---------------------------------------------------------------------------------------------------
function QuestLogTitleButton_OnClick(button)
    if (IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest")) then
        local questName = this:GetText();
        local questIndex = this:GetID() + FauxScrollFrame_GetOffset(EQL3_QuestLogListScrollFrame);
        if (button == "LeftButton") then
            if (IsShiftKeyDown()) then
                if (IsControlKeyDown()) then
                    if (this.isHeader) then
                        return;
                    end
                    if (not ChatFrameEditBox:IsVisible()) then
                        EQL3_ClearTracker();
                        AddQuestWatch(questIndex);
                        Questie:AddEvent("SYNCLOG", 0);
                        QuestWatch_Update();
                    end
                else
                    local questLogTitleText, isHeader, isCollapsed, firstTrackable, lastTrackable, numTracked, numUntracked;
                    lastTrackable = -1;
                    numTracked = 0;
                    numUntracked = 0;
                    local track = false;
                    if (this.isHeader) then
                        local i = 1;
                        local qc = 0;
                        local nEntry, nQuests = QGet_NumQuestLogEntries();
                        local tEntry = nQuests;
                        while qc < nQuests do
                            questLogTitleText, _, _, isHeader, isCollapsed, _ = QGet_QuestLogTitle(i);
                            if (questLogTitleText == questName) then
                                track = true;
                                firstTrackable = i + 1;
                            elseif (track) then
                                if (not isHeader) then
                                    if (IsQuestWatched(i)) then
                                        numTracked = numTracked + 1;
                                        RemoveQuestWatch(i);
                                    else
                                        numUntracked = numUntracked + 1;
                                        RemoveQuestWatch(i);
                                    end
                                end
                                QuestWatch_Update();
                                if (isHeader and questLogTitleText ~= questName) then
                                    lastTrackable = i - 1;
                                    break;
                                end
                            end
                            if not isHeader then
                                qc = qc + 1;
                            else
                                tEntry = tEntry + 1;
                            end
                            i = i + 1;
                        end
                        if (lastTrackable == -1) then
                            lastTrackable = tEntry;
                        end
                        if (numUntracked == 0) then
                            for i = firstTrackable, lastTrackable, 1 do
                                RemoveQuestWatch(i);
                            end
                        else
                            for i = firstTrackable, lastTrackable, 1 do
                                AddQuestWatch(i);
                            end
                        end
                        Questie:AddEvent("SYNCLOG", 0);
                        if QuestieConfig["alwaysShowObjectives"] == false then
                            Questie:AddEvent("DRAWNOTES", 0.1);
                        end
                        QuestWatch_Update();
                        QuestLog_Update();
                    return;
                    end
                    if ChatFrameEditBox:IsVisible() then
                        ChatFrameEditBox:Insert("|cffffff00|Hquest:0:0:0:0|h["..gsub(this:GetText(), ".*%] (.*)", "%1").."]|h|r");
                    elseif (WIM_EditBoxInFocus) then
                        WIM_EditBoxInFocus:Insert("|cffffff00|Hquest:0:0:0:0|h["..gsub(this:GetText(), ".*%]  (.*)", "%1").."]|h|r");
                    else
                        if (IsQuestWatched(questIndex)) then
                            RemoveQuestWatch(questIndex);
                        else
                            if (GetNumQuestWatches() >= 20) then
                                UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, "20"), 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME);
                                return;
                            end
                            AddQuestWatch(questIndex);
                        end
                        Questie:AddEvent("SYNCLOG", 0);
                        if QuestieConfig["alwaysShowObjectives"] == false then
                            Questie:AddEvent("DRAWNOTES", 0.1);
                        end
                        QuestWatch_Update();
                    end
                end
            end
            if (this.isHeader) then
                if (EQL3_OrganizeFrame:IsVisible()) then
                    EQL3_OrganizeFrame_Text:SetText(questName);
                    EQL3_OrganizeFrame_Text:ClearFocus();
                    EQL3_OrganizeFunctions(questName);
                    EQL3_OrganizeFrame:Hide();
                end
            end
        end
        if (QuestLog_SetSelection(questIndex) == 1) then
            if (not EQL3_QuestLogFrame_Description:IsVisible() and not IsShiftKeyDown() and not IsControlKeyDown() and QuestlogOptions[EQL3_Player].RestoreUponSelect == 1) then
                EQL3_Maximize();
            end
        end
        if (button == "LeftButton") then
            if (not IsShiftKeyDown() and IsControlKeyDown()) then
                if ChatFrameEditBox:IsVisible() then
                    if (ChatFrameEditBox:IsVisible()) then
                        AddQuestStatusToChatFrame(questIndex, questName);
                    end
                end
            end
        else
            if (not this.isHeader ) then
                if (EQL3_IsQuestWatched(questIndex)) then
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
    else
        local prevQuestLogSelection = QGet_QuestLogSelection();
        local questName = this:GetText();
        local questIndex = this:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
        local qName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(questIndex);
        QSelect_QuestLogEntry(questIndex);
        local questText, objectiveText = QGet_QuestLogQuestText();
        if (IsShiftKeyDown()) then
            if (this.isHeader) then
                return;
            end
            local hash = Questie:getQuestHash(qName, level, objectiveText, headerName);
            if ChatFrameEditBox:IsVisible() then
                ChatFrameEditBox:Insert("|cffffff00|Hquest:0:0:0:0|h["..gsub(this:GetText(), "  (.)", "%1").."]|h|r");
            elseif (WIM_EditBoxInFocus) then
                WIM_EditBoxInFocus:Insert("|cffffff00|Hquest:0:0:0:0|h["..gsub(this:GetText(), "  (.)", "%1").."]|h|r");
            else
                if (IsQuestWatched(questIndex)) then
                    Questie:debug_Print("Tracker:QuestLogTitleButton_OnClick --> RemoveQuestWatch: [Id: "..questIndex.."] | [hash: "..hash.."]");
                    RemoveQuestWatch(questIndex);
                else
                    ------------------------------------------------------------------------------------
                    -- We want to track anything and more than 5 quests in the Defalut WoW Quest Tracker
                    --[[--------------------------------------------------------------------------------
                    if (QGet_NumQuestLeaderBoards(questIndex) == 0) then
                        UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0);
                        return;
                    end
                    if (QGet_NumQuestWatches() >= MAX_WATCHABLE_QUESTS) then
                        UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
                        return;
                    end
                    ----------------------------------------------------------------------------------]]
                    AddQuestWatch(questIndex);
                    Questie:debug_Print("Tracker:QuestLogTitleButton_OnClick --> AutoQuestWatch_Insert: [Id: "..questIndex.."] | [hash: "..hash.."]");
                end
                Questie:AddEvent("SYNCLOG", 0);
                if QuestieConfig["alwaysShowObjectives"] == false then
                    Questie:AddEvent("DRAWNOTES", 0.02);
                end
                QuestWatch_Update();
            end
        end
        QSelect_QuestLogEntry(prevQuestLogSelection);
        QuestLog_SetSelection(questIndex);
        QuestLog_Update();
    end
end
---------------------------------------------------------------------------------------------------
-- If a quest is tracked, add quest to tracker and retrieve cached quest data
---------------------------------------------------------------------------------------------------
local function trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1");
end
---------------------------------------------------------------------------------------------------
function QuestieTracker:addQuestToTrackerCache(hash, logId, level)
    if not QuestieCachedQuests[hash] then
        QuestieCachedQuests[hash] = {};
    end
    if not logId then
        logId = Questie:GetQuestIdFromHash(hash);
    end
    if logId == nil then
        DEFAULT_CHAT_FRAME:AddMessage("TrackerError! LogId still nil after GetQuestIdFromHash ", hash);
        return;
    end
    local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(logId);
    if (not QuestieCachedQuests[hash]["tracked"] == true) then
        QuestieCachedQuests[hash]["tracked"] = false;
    end
    QuestieCachedQuests[hash]["questName"] = questName;
    QuestieCachedQuests[hash]["level"] = level;
    QuestieCachedQuests[hash]["logId"] = logId;
    QuestieCachedQuests[hash]["questTag"] = questTag;
    QuestieCachedQuests[hash]["isComplete"] = isComplete;
    QuestieCachedQuests[hash]["leaderboards"] = QGet_NumQuestLeaderBoards(logId);
    for i=1, QGet_NumQuestLeaderBoards(logId) do
        local desc, type, done = QGet_QuestLogLeaderBoard(i, logId);
        if QuestieCachedQuests[hash]["objective"..i] then
            if isComplete or (QGet_NumQuestLeaderBoards() == 0) or (QuestieCachedQuests[hash]["objective"..i]["done"] == 1) then
                RemoveCrazyArrow(hash);
                QuestieCachedQuests[hash]["objective"..i] = {
                    ["desc"] = "Quest Complete!",
                    ["type"] = type,
                    ["done"] = true,
                    ["notes"] = {},
                };
            else
                QuestieCachedQuests[hash]["objective"..i] = {
                    ["desc"] = desc,
                    ["type"] = type,
                    ["done"] = done,
                    ["notes"] = {},
                };
            end
        else
            QuestieCachedQuests[hash]["objective"..i] = {
                ["desc"] = desc,
                ["type"] = type,
                ["done"] = done,
                ["notes"] = {},
            };
        end
    end
    --Questie:debug_Print("Tracker:addQuestToTrackerCache: [Hash: "..hash.."]");
    if QuestieCachedQuests[hash]["objective1"] then
        if (QuestieCachedQuests[hash]["objective1"]["done"] ~= true) or (QuestieCachedQuests[hash]["objective1"]["done"] ~= 1) or (QuestieCachedQuests[hash]["objective1"]["type"] == nil) or (not QuestieCachedQuests[hash]["arrowPoint"]) then
            QuestieTracker:updateTrackerCache(hash, logId, level);
        end
    end
end
---------------------------------------------------------------------------------------------------
-- This function is used to update the quest log index of a quest in the QUEST_WATCH_LIST and
-- QuestieCachedQuests tables when another quest is added/removed from the quest log, and therefore
-- the index might have changed. It's currently only called from updateTrackerCache and syncQuestLog
-- in this file, which might have to be changed yet, but testing has shown no errors so far.
---------------------------------------------------------------------------------------------------
function QuestieTracker:updateQuestWatchLogId(hash, logId)
    if QUEST_WATCH_LIST[hash] and QUEST_WATCH_LIST[hash].questIndex ~= logId then
        Questie:debug_Print("Tracker:updateQuestWatchLogId: QUEST_WATCH_LIST["..hash.."].questIndex changed from "..QUEST_WATCH_LIST[hash].questIndex.." to "..logId)
        QUEST_WATCH_LIST[hash].questIndex = logId
    end
    if QuestieCachedQuests[hash] and QuestieCachedQuests[hash].logId ~= logId then
        Questie:debug_Print("Tracker:updateQuestWatchLogId: QuestieCachedQuests["..hash.."].logId changed from "..QuestieCachedQuests[hash].logId.." to "..logId)
        QuestieCachedQuests[hash].logId = logId
    end
end
---------------------------------------------------------------------------------------------------
-- If a quest is tracked, update quest on tracker and also update quest data cache
---------------------------------------------------------------------------------------------------
function QuestieTracker:updateTrackerCache(hash, logId, level)
    if (not QUEST_WATCH_LIST[logId]) and (not QuestieCachedQuests[hash]) then
        QuestieTracker:addQuestToTrackerCache(hash, logId, level);
    end
    if not QuestieCachedQuests[hash] then
        QuestieCachedQuests[hash] = {};
    end
    if not logId then
        logId = Questie:GetQuestIdFromHash(hash);
    end
    if logId == nil then
        DEFAULT_CHAT_FRAME:AddMessage("TrackerError! LogId still nil after GetQuestIdFromHash ", hash);
        return;
    end
    local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(logId);
    QuestieCachedQuests[hash]["questName"] = questName;
    QuestieCachedQuests[hash]["isComplete"] = isComplete;
    QuestieCachedQuests[hash]["questTag"] = questTag;
    QuestieCachedQuests[hash]["level"] = level;
    QuestieCachedQuests[hash]["logId"] = logId;
    QuestieCachedQuests[hash]["leaderboards"] = QGet_NumQuestLeaderBoards(logId);
    QuestieTracker:updateQuestWatchLogId(hash, logId);
    local uggo = 0;
    for i=1, QGet_NumQuestLeaderBoards(logId) do
        local desc, type, done = QGet_QuestLogLeaderBoard(i, logId);
        if not QuestieCachedQuests[hash]["objective"..i] then
            QuestieCachedQuests[hash]["objective"..i] = {};
        end
        QuestieCachedQuests[hash]["objective"..i]["desc"] = desc;
        QuestieCachedQuests[hash]["objective"..i]["done"] = done;
        uggo = i;
    end
    uggo = uggo - 1;
    --Questie:debug_Print("Tracker:updateTrackerCache: [Hash: "..hash.."]");
end
---------------------------------------------------------------------------------------------------
-- Adds quest from tracker when it's tracked - will not clear cached quest data
---------------------------------------------------------------------------------------------------
function QuestieTracker:addQuestToTracker(hash)
    if (QuestieCachedQuests[hash] and QuestieCachedQuests[hash]["tracked"] ~= true) then
        QuestieCachedQuests[hash]["tracked"] = true;
    end
end
---------------------------------------------------------------------------------------------------
-- Removes quest from tracker when it's untracked - will not clear cached quest data
---------------------------------------------------------------------------------------------------
function QuestieTracker:removeQuestFromTracker(hash)
    if (QuestieSeenQuests[hash] == 0) and (QuestieCachedQuests[hash] ~= nil) then
        QuestieCachedQuests[hash]["tracked"] = false;
        RemoveCrazyArrow(hash);
    end
end
---------------------------------------------------------------------------------------------------
--Blizzard Hooks to override the Default QuestLog behaviors
---------------------------------------------------------------------------------------------------
function QuestieTracker:BlizzardHooks()
    if (not IsAddOnLoaded("EQL3")) and (not IsAddOnLoaded("ShaguQuest")) then
        --Hooks Blizzards AddQuestWatch to bypass thier method of populating the QUEST_WATCH_LIST table
        QAddQuestWatch = AddQuestWatch;
        function AddQuestWatch(questIndex)
            local prevQuestLogSelection = QGet_QuestLogSelection();
            local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(questIndex);
            QSelect_QuestLogEntry(questIndex);
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(questName, level, objectiveText);
            if not QUEST_WATCH_LIST[hash] then
                QUEST_WATCH_LIST[hash] = {};
            end
            if (QuestieCachedQuests[hash]) then
                QUEST_WATCH_LIST[hash]["questIndex"] = questIndex;
                QUEST_WATCH_LIST[hash]["questName"] = questName;
                --Questie:debug_Print("AddQuestWatch: [Hash: "..hash.."] | [Id: "..questIndex.."]");
            end
            QSelect_QuestLogEntry(prevQuestLogSelection);
            QAddQuestWatch(questIndex);
        end
        -----------------------------------------------------------------------------------------------
        --Hooks Blizzards RemoveQuestWatch to bypass thier
        --method of populating the QUEST_WATCH_LIST table
        QRemoveQuestWatch = RemoveQuestWatch;
        function RemoveQuestWatch(questIndex)
            local prevQuestLogSelection = QGet_QuestLogSelection();
            local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(questIndex);
            QSelect_QuestLogEntry(questIndex);
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(questName, level, objectiveText);
            if (QuestieCachedQuests[hash]) then
                QUEST_WATCH_LIST[hash] = nil;
                --Questie:debug_Print("RemoveQuestWatch: [Hash: "..hash.."] | [Id: "..questIndex.."]");
            end
            QSelect_QuestLogEntry(prevQuestLogSelection);
            QRemoveQuestWatch(questIndex);
        end
        -----------------------------------------------------------------------------------------------
        --Hooks Blizzards AutoQuestWatch_CheckDeleted to bypass the default quest log checks
        QAutoQuestWatch_CheckDeleted = AutoQuestWatch_CheckDeleted;
        function AutoQuestWatch_CheckDeleted()
        end
        -----------------------------------------------------------------------------------------------
        --Hooks Blizzards AutoQuestWatch_Update to bypass the default quest log checks
        QAutoQuestWatch_Update = AutoQuestWatch_Update;
        function AutoQuestWatch_Update(questIndex)
        end
        -----------------------------------------------------------------------------------------------
        --Hooks Blizzards AutoQuestWatch_OnUpdate to bypass the default quest log checks
        QAutoQuestWatch_OnUpdate = AutoQuestWatch_OnUpdate;
        function AutoQuestWatch_OnUpdate(elapsed)
            -- Prevents QuestWatcher "flickering bug"
            if (QuestieConfig.trackerEnabled == true) then
                QuestWatchFrame:Hide();
            end
        end
        -----------------------------------------------------------------------------------------------
        --Hooks Blizzards IsQuestWatched so we can return our own values
        QIsQuestWatched = IsQuestWatched;
        function IsQuestWatched(id)
            local isWatched = false
            local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(id)
            if not isHeader then
                local prevQuestLogSelection = QGet_QuestLogSelection()
                QSelect_QuestLogEntry(id)
                local questText, objectiveText = QGet_QuestLogQuestText()
                local hash = Questie:getQuestHash(questName, level, objectiveText)
                if (QuestieCachedQuests[hash]) then
                    if QUEST_WATCH_LIST[hash] then
                        --Questie:debug_Print("IsQuestWatched: [Hash: "..hash.."] | [Id: "..id.."] | YES")
                        isWatched = true
                    end
                end
                QSelect_QuestLogEntry(prevQuestLogSelection)
            end
            QIsQuestWatched(id)
            return isWatched
        end
    end
end
---------------------------------------------------------------------------------------------------
--End of Blizzard Hooks
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
--Adds new quests to the Blizzard QUEST_WATCH_LIST table and syncs with the quest log
---------------------------------------------------------------------------------------------------
function QuestieTracker:syncQuestWatch()
    if (not IsAddOnLoaded("EQL3")) and (not IsAddOnLoaded("ShaguQuest")) then
        if (AUTO_QUEST_WATCH == "1") then
            for hash,v in pairs(QuestieCachedQuests) do
                if hash and v["logId"] then
                    local id = v["logId"]
                    if QuestieSeenQuests[hash] == 0 and QuestieCachedQuests[hash]["tracked"] == true then
                        AddQuestWatch(id);
                        Questie:debug_Print("Tracker:syncQuestWatch --> AddQuestWatch: [ID: "..id.."] | [hash: "..hash.."]");
                    elseif QuestieSeenQuests[hash] == 0 and QuestieCachedQuests[hash]["tracked"] == false then
                        RemoveQuestWatch(id);
                        Questie:debug_Print("Tracker:syncQuestWatch --> RemoveQuestWatch: [ID: "..id.."] | [hash: "..hash.."]");
                    end
                    QuestWatch_Update();
                    -- Prevents QuestWatcher "flickering bug"
                    if (QuestieConfig.trackerEnabled == true) then
                        QuestWatchFrame:Hide();
                    end
                    QuestLog_SetSelection(id);
                    QuestLog_Update();
                end
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
--Checks and flags tracked quest status and then adds them to the quest tracker
---------------------------------------------------------------------------------------------------
function QuestieTracker:syncQuestLog()
    Questie:debug_Print("****************| Running QuestieTracker:syncQuestLog |**************** ");
    if IsAddOnLoaded("EQL3") or IsAddOnLoaded("ShaguQuest") then
        QuestLogSync = EQL3_IsQuestWatched;
    else
        QuestLogSync = IsQuestWatched;
    end
    local prevQuestLogSelection = QGet_QuestLogSelection();
    local id = 1;
    local qc = 0;
    local nEntry, nQuests = QGet_NumQuestLogEntries();
    while qc < nQuests do
        local isWatched = QuestLogSync(id);
        local questName, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(id);
        if not isHeader and not isCollapsed then
            QSelect_QuestLogEntry(id);
            local questText, objectiveText = QGet_QuestLogQuestText();
            local hash = Questie:getQuestHash(questName, level, objectiveText);
            QuestieTracker:updateQuestWatchLogId(hash, id);
            if (isWatched) and (QuestieCachedQuests[hash] and QuestieCachedQuests[hash]["tracked"] ~= true) then
                if QuestieCachedQuests[hash] then
                    Questie:debug_Print("Tracker:syncQuestLog --> addQuestToTracker: Flagging [Hash: "..hash.."] TRUE");
                    QuestieTracker:addQuestToTracker(hash);
                else
                    Questie:debug_Print("Tracker:syncQuestLog --> Add quest to Tracker and MapNotes caches: [Hash: "..hash.."]");
                    Questie:AddQuestToMap(hash);
                    QuestieTracker:addQuestToTrackerCache(hash, id, level);
                    QuestieTracker:addQuestToTracker(hash);
                end
            elseif (not isWatched) and (QuestieCachedQuests[hash] and QuestieCachedQuests[hash]["tracked"] ~= false) then
                Questie:debug_Print("Tracker:syncQuestLog --> removeQuestFromTracker: Flagging [Hash: "..hash.."] FALSE");
                QuestieTracker:removeQuestFromTracker(hash);
            end
        end
        if not isHeader then
            qc = qc + 1;
        end
        id = id + 1;
    end
    QSelect_QuestLogEntry(prevQuestLogSelection);
    QuestieTracker:FillTrackingFrame();
    QuestieTracker:updateTrackingFrameSize();
end
---------------------------------------------------------------------------------------------------
-- Saves the position of the tracker after the user moves it
---------------------------------------------------------------------------------------------------
function QuestieTracker:saveFramePosition()
    local frame = getglobal("QuestieTrackerFrame");
  	local resolution = ({GetScreenResolutions()})[GetCurrentResolution()];
	local _, _, x, y = string.find(resolution, "(%d+)x(%d+)");
	local scrndiv = tonumber(x) / 2;
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint();
    if QuestieTracker.frame:GetLeft() < scrndiv then
        if (QuestieConfig.trackerList == true) then
            QuestieTrackerVariables = {};
            QuestieTrackerVariables["position"] = {
                ["point"] = "BOTTOMLEFT",
                ["relativePoint"] = "BOTTOMLEFT",
                ["relativeTo"] = "UIParent",
                ["yOfs"] = (QuestieTracker.frame:GetBottom()),
                ["xOfs"] = (QuestieTracker.frame:GetLeft()),
            };
        else
                QuestieTrackerVariables = {}
                QuestieTrackerVariables["position"] = {
                ["point"] = "TOPLEFT",
                ["relativePoint"] = "TOPLEFT",
                ["relativeTo"] = "UIParent",
                ["yOfs"] = yOfs,
                ["xOfs"] = xOfs,
            };
        end
    else
        if (QuestieConfig.trackerList == true) then
            QuestieTrackerVariables = {}
            QuestieTrackerVariables["position"] = {
                ["point"] = "BOTTOMRIGHT",
                ["relativePoint"] = "BOTTOMLEFT",
                ["relativeTo"] = "UIParent",
                ["yOfs"] = (QuestieTracker.frame:GetBottom()),
                ["xOfs"] = (QuestieTracker.frame:GetRight()),
            };
        else
                QuestieTrackerVariables = {}
                QuestieTrackerVariables["position"] = {
                ["point"] = "TOPRIGHT",
                ["relativePoint"] = "TOPLEFT",
                ["relativeTo"] = "UIParent",
                ["yOfs"] = yOfs,
                ["xOfs"] = (QuestieTracker.frame:GetRight()),
            };
        end
    end
end
---------------------------------------------------------------------------------------------------
-- If no quest tracker frame position is present in the users SavedVariables then this sets a
-- default location in memory so when the user desicdes to move it, it won't throw a nil error.
-- This function will also resize the world map from fullscreen to 80% via a slash toggle when
-- map mods such as Cartographer or MetaMap aren't being used.
---------------------------------------------------------------------------------------------------
function QuestieTracker:LoadModule()
    if not ( QuestieTrackerVariables ) then
        QuestieTrackerVariables = {};
        QuestieTrackerVariables["position"] = {
            point = "CENTER",
            relativeTo = "UIParent",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
        };
    end
    -- This adds the ability to scale the Worldmap from FULLSCREEN or to a WINDOW if a player isn't using Cargographer or MetaMap.
    if (QuestieConfig == nil) or (QuestieConfig.resizeWorldmap == nil) or (QuestieConfig.resizeWorldmap == false) or (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) then return; end
    if (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) then
        UIPanelWindows["WorldMapFrame"] =   { area = "center",  pushable = 0 };
        WorldMapFrame:SetFrameStrata("FULLSCREEN");
        WorldMapFrame:SetScript("OnKeyDown", nil);
        WorldMapFrame:RegisterForDrag("LeftButton");
        WorldMapFrame:EnableMouse(true);
        WorldMapFrame:SetMovable(true);
        WorldMapFrame:SetScale(.8);
        WorldMapTooltip:SetScale(1);
        WorldMapFrame:SetWidth(1024);
        WorldMapFrame:SetHeight(768);
        WorldMapFrame:ClearAllPoints();
        WorldMapFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
        BlackoutWorld:Hide();
        WorldMapFrame:SetScript("OnDragStart", function()
            this:SetWidth(1024);
            this:SetHeight(768);
            this:StartMoving();
        end)
        WorldMapFrame:SetScript("OnDragStop", function()
            this:StopMovingOrSizing();
            this:SetWidth(1024);
            this:SetHeight(768);
            local x,y = this:GetCenter();
            local z = UIParent:GetEffectiveScale() / 2 / this:GetScale();
            x = x - GetScreenWidth() * z;
            y = y - GetScreenHeight() * z;
            this:ClearAllPoints();
            this:SetPoint("CENTER", "UIParent", "CENTER", x, y);
        end)
        WorldMapFrame:SetScript("OnShow", function()
            local continent = GetCurrentMapContinent();
            local zone = GetCurrentMapZone();
            SetMapZoom(continent, zone);
            SetMapToCurrentZone();
        end)
    end
end
