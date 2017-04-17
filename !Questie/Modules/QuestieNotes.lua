---------------------------------------------------------------------------------------------------
-- Name: QuestieNotes
-- Description: Handles all the quest map notes
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
-- Local Vars
---------------------------------------------------------------------------------------------------
local AllFrames = {};
local FramePool = {};
local Cluster = {};
local LastContinent = nil;
local LastZone = nil;
local Dewdrop = AceLibrary("Dewdrop-2.0");
local specialSources = { ["openedby"] = 1, };
local QGet_QuestLogTitle = GetQuestLogTitle;
local QGet_NumQuestLeaderBoards = GetNumQuestLeaderBoards;
local QSelect_QuestLogEntry = SelectQuestLogEntry;
local QGet_QuestLogLeaderBoard = GetQuestLogLeaderBoard;
local QGet_QuestLogQuestText = GetQuestLogQuestText;
local QGet_TitleText = GetTitleText;
local QGet_QuestLogSelection = GetQuestLogSelection;
---------------------------------------------------------------------------------------------------
-- Global Vars
---------------------------------------------------------------------------------------------------
QUESTIE_NOTES_MAP_ICON_SCALE = 1.2;
QUESTIE_NOTES_WORLD_MAP_ICON_SCALE = 0.75;
QUESTIE_NOTES_CONTINENT_ICON_SCALE = 1;
QUESTIE_NOTES_MINIMAP_ICON_SCALE = 1.0;
QuestieMapNotes = {};
QuestieUsedNoteFrames = {};
QuestieHandledQuests = {};
QuestieAvailableMapNotes = {};
QuestieCachedMonstersAndObjects = {};
Questie_LastTooltip = GetTime();
QUESTIE_DEBUG_TOOLTIP = nil;
Questie_TooltipCache = {};
CREATED_NOTE_FRAMES = 1;
INIT_POOL_SIZE = 11;
Cluster.__index = Cluster;
__TT_LineCache = {};
UIOpen = false;
---------------------------------------------------------------------------------------------------
-- Refreshes Quest Notes
---------------------------------------------------------------------------------------------------
function Questie:RefreshQuestNotes()
    QUESTIE_UPDATE_EVENT = 1;
    if (GetTime() - QUESTIE_LAST_SYNCLOG > 0.1) then
        Questie:AddEvent("SYNCLOG", 0);
        QUESTIE_LAST_SYNCLOG = GetTime();
    else
        QUESTIE_LAST_SYNCLOG = GetTime();
    end
    if (GetTime() - QUESTIE_LAST_DRAWNOTES > 0.1) then
        Questie:AddEvent("DRAWNOTES", 0.2);
        QUESTIE_LAST_DRAWNOTES = GetTime();
    else
        QUESTIE_LAST_DRAWNOTES = GetTime();
    end
    if (GetTime() - QUESTIE_LAST_TRACKER > 0.1) then
        Questie:AddEvent("TRACKER", 0.4);
        QUESTIE_LAST_TRACKER = GetTime();
    else
        QUESTIE_LAST_TRACKER = GetTime();
    end
end
---------------------------------------------------------------------------------------------------
-- Adds quest notes to map
---------------------------------------------------------------------------------------------------
function Questie:AddQuestToMap(questHash, redraw)
    if(IsQuestieActive == false) then return; end
    if questHash == -1 then return; end
    --Questie:debug_Print("Notes:AddQuestToMap --> Adding Quest to Map [Hash: "..questHash.."]");
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
    Questie:RemoveQuestFromMap(questHash);
    local objectives = Questie:GetQuestObjectivePaths(questHash)
    --Cache code
    local ques = {};
    ques["noteHandles"] = {};
    UsedContinents = {};
    UsedZones = {};
    local Quest = Questie:IsQuestFinished(questHash);
    if not (Quest) then
        Questie:debug_Print("Notes:AddQuestToMap --> Display Objective Icons: [Hash: "..questHash.."]");
        for objectiveid, objective in pairs(objectives) do
            if not objective.done then
                local typeToIcon = {
                    ["item"] = "loot",
                    ["event"] = "event",
                    ["monster"] = "slay",
                    ["object"] = "object",
                };
                local defaultIcon = typeToIcon[objective.type];
                local iconMeta = {
                    ["defaultIcon"] = defaultIcon
                };
                Questie:RecursiveCreateNotes(c, z, questHash, objective.path, iconMeta, objectiveid);
            end
        end
    else
        --Questie:debug_Print("Notes:AddQuestToMap --> Display Finished Quest Icon: [Hash: "..questHash.."]");
        local addedNote = false
        local questInfo = QuestieHashMap[Quest.questHash];
        if questInfo ~= nil then
            local typeFunctions = {
                ['monster'] = GetMonsterLocations,
                ['object'] = GetObjectLocations
            };
            local typeFunction = typeFunctions[questInfo.finishedType];
            local finishPath = typeFunction(questInfo.finishedBy);
            --print_r(finishPath);
            if finishPath == nil or (not next(finishPath)) then
                finishPath = typeFunction(QuestieFinishers[Quest.name]);
            end
            if(finishPath) then
                local locations = Questie:RecursiveGetPathLocations(finishPath);
                if next(locations) then
                    for i, location in pairs(locations) do
                        local c, z, x, y = location[1], location[2], location[3], location[4];
                        Questie:AddNoteToMap(c, z, x, y, "complete", questHash, 0);
                        addedNote = true
                    end
                end
            end
        end
        if addedNote == false then
            Questie:debug_Print("AddQuestToMap: ERROR Quest broken! ", Quest["name"], questHash, "report on github!")
        end
    end
    --Cache code
    ques["objectives"] = objectives;
    QuestieHandledQuests[questHash] = ques;
    if (redraw) then
        Questie:debug_Print("Notes:AddQuestToMap: redraw VAR true --> Questie:RefreshQuestStatus();");
        Questie:RefreshQuestNotes();
    end
end
---------------------------------------------------------------------------------------------------
-- Checks for a quest note in QuestieMapNotes
---------------------------------------------------------------------------------------------------
function Questie:CheckQuestNote(questHash)
    for continent, zoneTable in pairs(QuestieMapNotes) do
        for index, zone in pairs(zoneTable) do
            for i, note in pairs(zone) do
                if (note.questHash == questHash) then
                    return true
                end
            end
        end
    end
    return false
end
---------------------------------------------------------------------------------------------------
-- Updates quest notes on map
---------------------------------------------------------------------------------------------------
function Questie:UpdateQuestNotes(questHash, redraw)
    if not QuestieHandledQuests[questHash] then
        --Questie:debug_Print("UpdateQuestNotes: ERROR! Tried updating a quest not handled. Hash: ", questHash);
        return;
    end
    local prevQuestLogSelection = QGet_QuestLogSelection()
    local QuestLogID = Questie:GetQuestIdFromHash(questHash);
    QSelect_QuestLogEntry(QuestLogID);
    local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(QuestLogID);
    local count =  QGet_NumQuestLeaderBoards();
    local questText, objectiveText = QGet_QuestLogQuestText();
    for k, noteInfo in pairs(QuestieHandledQuests[questHash]["noteHandles"]) do
        for id, note in pairs(QuestieMapNotes[noteInfo.c][noteInfo.z]) do
            if(note.questHash == questHash) then
                local desc, typ, done = QGet_QuestLogLeaderBoard(note.objectiveid);
                --Questie:debug_Print("UpdateQuestNotes: Desc: "..tostring(desc).." Type: "..tostring(typ).." Done: "..tostring(done));
            end
        end
    end
    QSelect_QuestLogEntry(prevQuestLogSelection)
    if(redraw) then
        Questie:debug_Print("Notes:UpdateQuestNotes: redraw VAR true --> Questie:RefreshQuestStatus();");
        Questie:RefreshQuestNotes();
    end
end
---------------------------------------------------------------------------------------------------
-- Remove quest note from map
---------------------------------------------------------------------------------------------------
function Questie:RemoveQuestFromMap(questHash, redraw)
    local removed = false;
    for continent, zoneTable in pairs(QuestieMapNotes) do
        for index, zone in pairs(zoneTable) do
            for i, note in pairs(zone) do
                if(note.questHash == questHash) then
                    QuestieMapNotes[continent][index][i] = nil;
                    removed = true;
                end
            end
        end
    end
    if(redraw) then
        Questie:debug_Print("Notes:RemoveQuestFromMap: redraw VAR true --> Questie:RefreshQuestStatus();");
        Questie:RefreshQuestNotes();
    end
    if(QuestieHandledQuests[questHash]) then
        QuestieHandledQuests[questHash] = nil;
    end
end
---------------------------------------------------------------------------------------------------
function Questie:GetMapInfoFromID(id)
    return QuestieZoneIDLookup[id];
end
---------------------------------------------------------------------------------------------------
-- Add quest note to map
---------------------------------------------------------------------------------------------------
function Questie:AddNoteToMap(continent, zoneid, posx, posy, type, questHash, objectiveid, path)
    if (not type == "complete") then
        return;
    end
    if(QuestieMapNotes[continent] == nil) then
        QuestieMapNotes[continent] = {};
    end
    if(QuestieMapNotes[continent][zoneid] == nil) then
        QuestieMapNotes[continent][zoneid] = {};
    end
    Note = {};
    Note.x = posx;
    Note.y = posy;
    Note.zoneid = zoneid;
    Note.continent = continent;
    Note.icontype = type;
    Note.questHash = questHash;
    Note.objectiveid = objectiveid;
    Note.path = path
    table.insert(QuestieMapNotes[continent][zoneid], Note);
end
---------------------------------------------------------------------------------------------------
-- Add available quest note to map
---------------------------------------------------------------------------------------------------
function Questie:AddAvailableNoteToMap(continent, zoneid, posx, posy, type, questHash, objectiveid, path)
    --This is to set up the variables
    if(QuestieAvailableMapNotes[continent] == nil) then
        QuestieAvailableMapNotes[continent] = {};
    end
    if(QuestieAvailableMapNotes[continent][zoneid] == nil) then
        QuestieAvailableMapNotes[continent][zoneid] = {};
    end
    --Sets values that i want to use for the notes THIS IS WIP MORE INFO MAY BE NEDED BOTH IN PARAMETERS AND NOTES!!!
    Note = {};
    Note.x = posx;
    Note.y = posy;
    Note.zoneid = zoneid;
    Note.continent = continent;
    Note.icontype = type;
    Note.questHash = questHash;
    Note.objectiveid = objectiveid;
    Note.path = path
    --Inserts it into the right zone and continent for later use.
    table.insert(QuestieAvailableMapNotes[continent][zoneid], Note);
end
---------------------------------------------------------------------------------------------------
-- Gets a blank frame either from Pool or creates a new one!
---------------------------------------------------------------------------------------------------
function Questie:GetBlankNoteFrame(frame)
    if(table.getn(FramePool)==0) then
        Questie:CreateBlankFrameNote(frame);
    end
    f = FramePool[1];
    table.remove(FramePool, 1);
    return f;
end
---------------------------------------------------------------------------------------------------
-- Hook Tooltip
---------------------------------------------------------------------------------------------------
function Questie:hookTooltip()
    local f = GameTooltip:GetScript("OnShow");
    --Proper tooltip hooking!
    if not f then
        GameTooltip:SetScript("OnShow", function(self)
            Questie:Tooltip(self, true);
        end)
    end
    local Blizz_GameTooltip_Show = GameTooltip.Show;
    GameTooltip.Show = function(self)
        Questie:Tooltip(self);
        Blizz_GameTooltip_Show(self);
    end
    local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem;
    GameTooltip.SetLootItem = function(self, slot)
        Bliz_GameTooltip_SetLootItem(self, slot);
        Questie:Tooltip(self, true);
    end
    local index = self:GetID();
    local Bliz_GameTooltip_SetQuestLogItem = GameTooltip.SetQuestLogItem;
    GameTooltip.SetQuestLogItem = function(self, type, index)
        local link = GetQuestLogItemLink(type, index);
        if link then
            Bliz_GameTooltip_SetQuestLogItem(self, type, index);
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Tooltip code for quest objects
---------------------------------------------------------------------------------------------------
function Questie:hookTooltipLineCheck()
    local oh = GameTooltip:GetScript("OnHide");
    GameTooltip:SetScript("OnHide", function(self, arg)
        if oh then
            oh(self, arg);
    end
        __TT_LineCache = {};
    end)
    GameTooltip.AddLine_orig = GameTooltip.AddLine;
    GameTooltip.AddLine = function(self, line, r, g, b, wrap, lineNumber)
        GameTooltip:AddLine_orig(line, r, g, b, wrap);
        if (line) then
            if lineNumber == nil then lineNumber = 1; end
            __TT_LineCache[lineNumber] = {};
            __TT_LineCache[lineNumber][line] = true;
        end
    end
end
---------------------------------------------------------------------------------------------------
function Questie:Tooltip(this, forceShow, bag, slot)
    if (QuestieConfig.showToolTips == false) then return end

    -- Don't show detailed tooltip for regular minimap icons
    local anchorType = GameTooltip:GetAnchorType()
    if anchorType == "ANCHOR_CURSOR" then return end

    -- Don't show detailed tooltip for questie minimap icons
    local owner = GameTooltip.owner
    if owner and owner.type == "MiniMapNote" then return end

    local monster = UnitName("mouseover")
    local objective = GameTooltipTextLeft1:GetText()
    local cacheKey = ""-- .. monster .. objective
    local validKey = false
    if(monster) then
        cacheKey = cacheKey .. monster
        validKey = true
    end
    if(objective) then
        cacheKey = cacheKey .. objective
        validKey = true
    end
    if not validKey then
        return
    end
    local reaction = UnitReaction("mouseover", "player")
    local unitColorRGB = Questie:GetReactionColor(reaction)
    local unitColor = "ff"..fRGBToHex(unitColorRGB.r, unitColorRGB.g, unitColorRGB.b)
    if (Questie_TooltipCache[cacheKey] == nil) or (QUESTIE_LAST_UPDATE_FINISHED - Questie_TooltipCache[cacheKey]['updateTime']) > 0 then
        -- Create or Update Tooltip Cache
        Questie_TooltipCache[cacheKey] = {}
        Questie_TooltipCache[cacheKey]['lines'] = {}
        Questie_TooltipCache[cacheKey]['lineCount'] = 1
        Questie_TooltipCache[cacheKey]['updateTime'] = GetTime()
        local prevQuestLogSelection = QGet_QuestLogSelection()
        for questHash, quest in pairs(QuestieHandledQuests) do
            local QuestLogID = Questie:GetQuestIdFromHash(questHash)
            QSelect_QuestLogEntry(QuestLogID)
            local drawnQuestTitle = false
            for objectiveid, objectiveInfo in pairs(quest.objectives) do
                local highlightInfo = {
                    ["text"] = objective,
                    ["color"] = unitColor
                }
                local sourceNames = Questie:RecursiveGetSourceNamesFromRawPath(objectiveInfo.path)
                if objectiveInfo.name == objective or sourceNames[objective] then
                    local lineIndex = Questie_TooltipCache[cacheKey]['lineCount']
                    if drawnQuestTitle == false then
                        local questInfo = QuestieHashMap[questHash]
                        local colorString = "|c" .. QuestieTracker:GetDifficultyColor(questInfo.questLevel)
                        local title = colorString
                        title = title .. "[" .. questInfo.questLevel .. "] "
                        title = title .. questInfo.name .. "|r"
                        Questie_TooltipCache[cacheKey]['lines'][lineIndex] = {
                            ['color'] = {1,1,1},
                            ['data'] = " "
                        }
                        lineIndex = lineIndex + 1
                        Questie_TooltipCache[cacheKey]['lines'][lineIndex] = {
                            ['color'] = {1,1,1},
                            ['data'] = title,
                            ['wrap'] = false
                        }
                        lineIndex = lineIndex + 1
                        drawnQuestTitle = true
                    end
                    local desc, type, done = QGet_QuestLogLeaderBoard(objectiveid)
                    if done then
                        Questie_TooltipCache[cacheKey]['lines'][lineIndex] = {
                            ['color'] = {0.2,1,0.3},
                            ['data'] = desc,
                            ['wrap'] = false
                        }
                        lineIndex = lineIndex + 1
                        Questie_TooltipCache[cacheKey]['lineCount'] = lineIndex
                    else
                        local objectivePath = deepcopy(objectiveInfo.path)
                        Questie:PostProcessIconPath(objectivePath)
                        local lines = Questie:GetTooltipLines(objectivePath, 1, highlightInfo)
                        desc = string.gsub(desc, objective, "|c"..unitColor..objective.."|r")
                        Questie_TooltipCache[cacheKey]['lines'][lineIndex] = {
                            ['color'] = {1,1,1},
                            ['data'] = desc,
                            ['wrap'] = false
                        }
                        lineIndex = lineIndex + 1
                        for i, line in pairs(lines) do
                            Questie_TooltipCache[cacheKey]['lines'][lineIndex] = {
                                ['color'] = {1,1,1},
                                ['data'] = line
                            }
                            lineIndex = lineIndex + 1
                        end
                        Questie_TooltipCache[cacheKey]['lineCount'] = lineIndex
                    end
                end
            end
        end
        QSelect_QuestLogEntry(prevQuestLogSelection)
    end
    for k, v in pairs(Questie_TooltipCache[cacheKey]['lines']) do
        if (not __TT_LineCache[k]) or (not __TT_LineCache[k][v['data']]) then
            local wrap = v['wrap']
            if wrap == nil then wrap = true end
            GameTooltip:AddLine(v['data'], v['color'][1], v['color'][2], v['color'][3], wrap, k)
        end
    end
    if(QUESTIE_DEBUG_TOOLTIP) then
        GameTooltip:AddLine("--Questie hook--")
    end
    if(forceShow) then
        GameTooltip:Show()
    end
    GameTooltip.QuestieDone = true
    Questie_LastTooltip = GetTime()
    --Questie_TooltipCache = {}
    mi = nil
end
---------------------------------------------------------------------------------------------------
-- Tooltip code for quest starters and finishers
---------------------------------------------------------------------------------------------------
function Questie:GetTooltipLines(path, indent, highlightInfo, lines)
    if lines == nil then lines = {} end
    local indentString = "";
    for i=1,indent,1 do
        indentString = indentString.." ";
    end
    if path["contained_id"] then path["contained"] = nil; end
    for sourceType, sources in pairs(path) do
        local prefix;
        if sourceType == "drop" then
            prefix = "Dropped by";
        elseif sourceType == "rewardedby" then
            prefix = "Awarded by";
        elseif sourceType == "contained" then
            prefix = "Contained in";
        elseif sourceType == "contained_id" then
            prefix = "Contained in";
        elseif sourceType == "containedi" then
            prefix = "Opened in";
        elseif sourceType == "created" then
            prefix = "Created by";
        elseif sourceType == "openedby" then
            prefix = "Opened by";
        elseif sourceType == "transforms" then
            prefix = "Used on";
        elseif sourceType == "transformedby" then
            prefix = "Created by";
        end
        if prefix then
            for sourceName, sourcePath in pairs(sources) do
                local splitNames = Questie:SplitString(sourceName, ", ");
                local combinedNames = "";
                local countDown = table.getn(splitNames);
                for i, name in pairs(splitNames) do
                    if i <= 5 or (highlightInfo ~= nil and name == highlightInfo.text) then
                        if i > 1 then combinedNames = combinedNames..", "; end
                        if highlightInfo ~= nil and name == highlightInfo.text then
                            combinedNames = combinedNames.."|r|c"..highlightInfo.color..name.."|r|cFFa6a6a6";
                        else
                            combinedNames = combinedNames..name;
                        end
                        countDown = countDown - 1;
                    end
                end
                if countDown > 0 then
                    combinedNames = combinedNames.." and "..countDown.." more...";
                end
                table.insert(lines, indentString..prefix..": |cFFa6a6a6"..combinedNames.."|r");
                Questie:GetTooltipLines(sourcePath, indent+1, highlightInfo, lines, sourceNames);
            end
        end
    end
    return lines
end
---------------------------------------------------------------------------------------------------
function Questie:AddPathToTooltip(Tooltip, path, indent)
    local lines = Questie:GetTooltipLines(path, indent);
    for i, line in pairs(lines) do
        Tooltip:AddLine(line,1,1,1,true);
    end
end
---------------------------------------------------------------------------------------------------
function Questie_Tooltip_OnEnter()
    if(this.data.questHash) then
        local Tooltip = GameTooltip;
        if(this.type == "WorldMapNote") then
            Tooltip = WorldMapTooltip;
        else
            Tooltip = GameTooltip;
        end
        Tooltip:SetOwner(this, this);
        Tooltip.owner = this
        local count = 0;
        local canManualComplete = 0;
        local orderedQuests = {};
        for questHash, questMeta in pairs(this.quests) do
            orderedQuests[questMeta['sortOrder']] = questMeta;
        end
        local prevQuestLogSelection = QGet_QuestLogSelection();
        for i, questMeta in pairs(orderedQuests) do
            local data = questMeta['quest'];
            count = count + 1;
            if (count > 1) then
                Tooltip:AddLine(" ");
            end
            if(data.icontype ~= "available" and data.icontype ~= "availablesoon") then
                local Quest = Questie:IsQuestFinished(data.questHash);
                if not Quest then
                    local QuestLogID = Questie:GetQuestIdFromHash(data.questHash);
                    if QuestLogID then
                        QSelect_QuestLogEntry(QuestLogID);
                        local q, level, questTag, isHeader, isCollapsed, isComplete = QGet_QuestLogTitle(QuestLogID);
                        Tooltip:AddLine(q);
                        for objectiveid, objectivePath in pairs(questMeta['objectives']) do
                            local objectiveName;
                            if type(objectiveid) == "string" then
                                objectiveName = objectiveid;
                            else
                                local desc, typ, done = QGet_QuestLogLeaderBoard(objectiveid);
                                objectiveName = desc;
                            end
                            Tooltip:AddLine(objectiveName,1,1,1);
                            Questie:AddPathToTooltip(Tooltip, objectivePath, 1);
                        end
                    end
                else
                    Tooltip:AddLine("["..QuestieHashMap[data.questHash].questLevel.."] "..Quest["name"].." |cFF33FF00(complete)|r");
                    Tooltip:AddLine("Finished by: |cFFa6a6a6"..QuestieHashMap[data.questHash].finishedBy.."|r",1,1,1);
                end
            else
                questOb = nil;
                local QuestName = tostring(QuestieHashMap[data.questHash].name);
                if QuestName then
                    local index = 0;
                    for k,v in pairs(QuestieLevLookup[QuestName]) do
                        index = index + 1;
                        if (index == 1) and (v[2] == data.questHash) and (k ~= "") then
                            questOb = k;
                        elseif (index > 0) and(v[2] == data.questHash) and (k ~= "") then
                            questOb = k;
                        elseif (index == 1) and (v[2] ~= data.questHash) and (k ~= "") then
                            questOb = k;
                        end
                    end
                end
                local questLine = "["..QuestieHashMap[data.questHash].questLevel.."] "..QuestieHashMap[data.questHash].name;
                if data.icontype == "available" then
                    questLine = questLine.." |cFF33FF00(available)|r";
                elseif data.icontype == "availablesoon" then
                    questLine = questLine.." |cFFa6a6a6(not available)|r";
                end
                Tooltip:AddLine(questLine);
                Tooltip:AddLine("Min Level: |cFFa6a6a6"..QuestieHashMap[data.questHash].level.."|r",1,1,1);
                Tooltip:AddLine("Started by: |cFFa6a6a6"..QuestieHashMap[data.questHash].startedBy.."|r",1,1,1);
                Questie:AddPathToTooltip(Tooltip, questMeta['path'], 1);
                if questOb ~= nil then
                    Tooltip:AddLine("Description: |cFFa6a6a6"..questOb.."|r",1,1,1,true);
                end
                canManualComplete = 1;
            end
        end
        QSelect_QuestLogEntry(prevQuestLogSelection);
        if canManualComplete > 0 then
            if count > 1 then
                Tooltip:AddLine(" ");
            end
            Tooltip:AddLine("Shift+Click: |cFFa6a6a6Manually complete quest!|r",1,1,1);
        end
        if(NOTES_DEBUG and IsAltKeyDown()) then
            Tooltip:AddLine("!DEBUG!", 1, 0, 0);
            Tooltip:AddLine("QuestID: "..this.data.questHash, 1, 0, 0);
        end
        Tooltip:SetFrameStrata("TOOLTIP");
        Tooltip:Show();
    end
end
---------------------------------------------------------------------------------------------------
-- Force a quest to be finished via the Minimap or Worldmap (Shift-Click icon - NO confirmation)
---------------------------------------------------------------------------------------------------
function Questie_AvailableQuestClick()
    if this.type == "WorldMapNote" then
        local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
        local newC, newZ = c, z;
        if arg1 == "LeftButton" then
            if c == 0 then
                newC = this.data.continent;
            else
                newZ = this.data.zoneid;
            end
        end
        if arg1 == "RightButton" or arg1 == "MiddleButton" then
            if z == 0 then
                newC = 0;
            else
                newZ = 0;
            end
        end
        if newC ~= c or newZ ~= z then
            SetMapZoom(newC, newZ);
            return;
        end
    end
    local Tooltip = GameTooltip;
    if(this.type == "WorldMapNote") then
        Tooltip = WorldMapTooltip;
    else
        Tooltip = GameTooltip;
    end
    if (QuestieConfig.arrowEnabled == true) and (arg1 == "LeftButton") and (not IsControlKeyDown()) and (not IsShiftKeyDown()) then
        SetArrowFromIcon(this);
    end
    if ((this.data.icontype == "available" or this.data.icontype == "availablesoon" or this.data.icontype == "complete") and IsShiftKeyDown() and Tooltip ) then
        local finishQuest = function(quest)
            if (quest.icontype == "available" or quest.icontype == "availablesoon") then
                local hash = quest.questHash;
                local questName = "["..QuestieHashMap[hash].questLevel.."] "..QuestieHashMap[hash]['name'];
                Questie:finishAndRecurse(hash);
                DEFAULT_CHAT_FRAME:AddMessage("Completing quest |cFF00FF00\"" .. questName .. "\"|r ("..hash..") and parent quests.");
                --Questie:debug_Print("Notes:Questie_AvailableQuestClick --> Refreshing QuestNPC Icons: [AddEvent:DRAWNOTES]");
                Questie:AddEvent("DRAWNOTES", 0.1);
            end
        end
        local count = 0;
        local firstQuest;
        for questHash, questMeta in pairs(this.quests) do
            count = count + 1;
            if not firstQuest then
                firstQuest = questMeta['quest'];
            end
        end
        if (count < 2) then
            -- Finish first quest in list
            finishQuest(firstQuest);
        else
            -- Open Dewdrop to select which quest to finish
            local closeFunc = function()
                Dewdrop:Close();
            end
            local registerDewdrop = function(frame, quests, k1, v1, k2, v2)
                Dewdrop:Register(frame,
                    'children', function()
                        for questHash, questMeta in pairs(quests) do
                            local quest = questMeta.quest;
                            local hash = questHash;
                            local questName = "["..QuestieHashMap[hash].questLevel.."] "..QuestieHashMap[hash]['name']
                            local finishFunc = function(quest)
                                finishQuest(quest);
                                Dewdrop:Close();
                            end
                            Dewdrop:AddLine(
                                'text', questName,
                                'notClickable', quest.icontype ~= "available" and quest.icontype ~= "availablesoon",
                                'icon', QuestieIcons[quest.icontype].path,
                                'iconCoordLeft', 0,
                                'iconCoordRight', 1,
                                'iconCoordTop', 0,
                                'iconCoordBottom', 1,
                                'func', finishFunc,
                                'arg1', quest
                            );
                        end
                        Dewdrop:AddLine(
                            'text', "",
                            'notClickable', true
                        );
                        Dewdrop:AddLine(
                            'text', "Cancel",
                            'func', closeFunc
                        );
                    end,
                    'dontHook', true,
                    k1, v1,
                    k2, v2
                );
                Dewdrop:Open(frame);
                Dewdrop:Unregister(frame);
            end
            if (IsAddOnLoaded("Cartographer")) or (IsAddOnLoaded("MetaMap")) or (QuestieConfig.resizeWorldmap == true) then
                registerDewdrop(WorldMapFrame, this.quests, 'cursorX', true, 'cursorY', true);
            elseif (not IsAddOnLoaded("Cartographer")) or (not IsAddOnLoaded("MetaMap")) and (QuestieConfig.resizeWorldmap == false) then
                registerDewdrop(this, this.quests, 'point', "TOPLEFT", 'relativePoint', "BOTTOMRIGHT");
            elseif (IsAddOnLoaded("Cartographer")) and (CartographerDB["disabledModules"]["Default"]["Look 'n' Feel"] == true) then
                registerDewdrop(this, this.quests, 'point', "TOPLEFT", 'relativePoint', "BOTTOMRIGHT");
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Creates a blank frame for use within the map system
---------------------------------------------------------------------------------------------------
function Questie:CreateBlankFrameNote(frame)
    local f = CreateFrame("Button","QuestieNoteFrame"..CREATED_NOTE_FRAMES,frame);
    local t = f:CreateTexture(nil,"BACKGROUND");
    f.texture = t;
    f:SetScript("OnEnter", Questie_Tooltip_OnEnter);
    f:SetScript("OnLeave", function()
        if(WorldMapTooltip) then
            WorldMapTooltip:Hide();
        end
        if(GameTooltip) then
            GameTooltip:Hide();
            GameTooltip.owner = nil
        end
    end)
    f:SetScript("OnClick", Questie_AvailableQuestClick);
    f:RegisterForClicks("LeftButtonDown", "RightButtonDown", "MiddleButtonDown");
    CREATED_NOTE_FRAMES = CREATED_NOTE_FRAMES+1;
    table.insert(FramePool, f);
    table.insert(AllFrames, f);
end
---------------------------------------------------------------------------------------------------
function Questie:GetFrameNote(data, parentFrame, frameLevel, type, scale)
    if(table.getn(FramePool)==0) then
        Questie:CreateFrameNote(data, parentFrame, frameLevel, type, scale);
    end
    f = FramePool[1];
    table.remove(FramePool, 1);
    return f;
end
---------------------------------------------------------------------------------------------------
function Questie:SetFrameNoteData(f, data, parentFrame, frameLevel, type, scale)
    f.data = data;
    f.quests = {};
    Questie:AddFrameNoteData(f, data);
    f:SetParent(parentFrame);
    f:SetFrameLevel(frameLevel);
    f:SetPoint("CENTER",0,0);
    f.type = type;
    f:SetWidth(16*scale);
    f:SetHeight(16*scale);
    f.texture:SetTexture(QuestieIcons[data.icontype].path);
    f.texture:SetAllPoints(f);
end
---------------------------------------------------------------------------------------------------
function Questie:AddFrameNoteData(icon, data)
    if icon then
        if (icon.averageX == nil or icon.averageY == nil or icon.countForAverage == nil) then
            icon.averageX = 0;
            icon.averageY = 0;
            icon.countForAverage = 0;
        end
        local numQuests = 0;
        for k, v in pairs(icon.quests) do
            numQuests = numQuests + 1;
        end
        local newAverageX = (icon.averageX * icon.countForAverage + data.x) / (icon.countForAverage + 1);
        local newAverageY = (icon.averageY * icon.countForAverage + data.y) / (icon.countForAverage + 1);
        icon.averageX = newAverageX;
        icon.averageY = newAverageY;
        icon.countForAverage = icon.countForAverage + 1;
        if icon.quests[data.questHash] then
            -- Add cumulative quest data
            if icon.quests[data.questHash]['objectives'][data.objectiveid] == nil then
                icon.quests[data.questHash]['objectives'][data.objectiveid] = {};
            end
            if data.path then
                Questie:JoinPathTables(icon.quests[data.questHash]['path'], data.path);
            end
            if data.objectiveid and data.path then
                Questie:JoinPathTables(icon.quests[data.questHash]['objectives'][data.objectiveid], data.path);
            end
        else
            icon.quests[data.questHash] = {};
            icon.quests[data.questHash]['quest'] = data;
            icon.quests[data.questHash]['sortOrder'] = numQuests + 1;
            icon.quests[data.questHash]['objectives'] = {};
            icon.quests[data.questHash]['path'] = {};
            if data.objectiveid then
                icon.quests[data.questHash]['objectives'][data.objectiveid] = {};
                if data.path then
                    icon.quests[data.questHash]['objectives'][data.objectiveid] = deepcopy(data.path);
                end
            end
            if data.path then
                icon.quests[data.questHash]['path'] = deepcopy(data.path);
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
function Questie:JoinPathTables(path1, path2)
    for k, v in pairs(path2) do
        if path1[k] then
            --Questie:debug_Print("Joining values for "..k)
            Questie:JoinPathTables(path1[k], path2[k]);
        else
            --Questie:debug_Print("Setting value for "..k)
            path1[k] = path2[k];
        end
    end
end
---------------------------------------------------------------------------------------------------
function Questie:PathsAreIdentical(path1, path2)
    if not next(path1) and not next(path2) then
        return true;
    end
    for sourceType1, sources1 in pairs(path1) do
        for sourceType2, sources2 in pairs(path2) do
            if path1[sourceType2] == nil or path2[sourceType1] == nil then
                return false;
            end
        end
        for sourceName, sourcePath in pairs(path1[sourceType1]) do
            for otherSourceName, otherSourcePath in pairs(path2[sourceType1]) do
                if path1[sourceType1][otherSourceName] == nil or path2[sourceType1][sourceName] == nil then
                    return false;
                end
            end
        end
    end
    return true;
end
---------------------------------------------------------------------------------------------------
function Questie:PostProcessIconPath(path)
    if path["locations"] then path["locations"] = nil; end
    if path["name"] then path["name"] = nil; end
    for sourceType, sources in pairs(path) do
        for sourceName, sourcePath in pairs(sources) do
            Questie:PostProcessIconPath(sourcePath);
        end
        local newSources = {};
        for sourceName, sourcePath in pairs(sources) do
            for otherSourceName, otherSourcePath in pairs(sources) do
                if sourceName ~= otherSourceName and (newSources[sourceName] == nil or newSources[otherSourceName] == nil) then
                    if Questie:PathsAreIdentical(sourcePath, otherSourcePath) then
                        local newSource = newSources[sourceName];
                        if newSource == nil then
                            newSource = newSources[otherSourceName];
                        end
                        if newSource ~= nil then
                            newSource.name = newSource.name..", "..otherSourceName;
                            table.insert(newSource.names, otherSourceName);
                        else
                            newSource = {
                                ['name'] = sourceName..", "..otherSourceName,
                                ['names'] = {sourceName, otherSourceName},
                                ['sourcePath'] = sourcePath
                            };
                        end
                        for i, name in ipairs(newSource.names) do
                            newSources[name] = newSource;
                        end
                    end
                end
            end
        end
        for sourceName, sourcePath in pairs(sources) do
            if newSources[sourceName] == nil then
                newSources[sourceName] = {
                    ['name'] = sourceName,
                    ['sourcePath'] = sourcePath,
                    ['names'] = {sourceName}
                };
            end
        end
        local processedSources = {};
        for sourceName, data in pairs(newSources) do
            processedSources[data.name] = data.sourcePath;
        end
        path[sourceType] = processedSources;
    end
end
---------------------------------------------------------------------------------------------------
function Questie:RecursiveGetSourceNamesFromRawPath(path, sourceNames)
    if sourceNames == nil then sourceNames = {} end
    for sourceType, sources in pairs(path) do
        if sourceType ~= "locations" and sourceType ~= "name" then
            for sourceName, sourcePath in pairs(sources) do
                sourceNames[sourceName] = true
                Questie:RecursiveGetSourceNamesFromRawPath(sourcePath, sourceNames)
            end
        end
    end
    return sourceNames
end
---------------------------------------------------------------------------------------------------
function Questie:RecursiveFindAndCombineObjectiveName(pathToSearch, objectiveName, pathToAdd)
    local found = false;
    for sourceType, sources in pairs(pathToSearch) do
        for sourceName, sourcePath in pairs(sources) do
            if sourceName == objectiveName then
                sources[sourceName] = pathToAdd;
                found = true;
            else
                if Questie:RecursiveFindAndCombineObjectiveName(sourcePath, objectiveName, pathToAdd) then
                    found = true;
                end
            end
        end
    end
    return found;
end
---------------------------------------------------------------------------------------------------
function Questie:FindAndCombineObjectiveName(objectives, objectiveName, pathToAdd)
    for objectiveid, objectivePath in pairs(objectives) do
        if type(objectiveid) ~= "string" then
            if Questie:RecursiveFindAndCombineObjectiveName(objectivePath, objectiveName, pathToAdd) then
                objectives[objectiveName] = nil;
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
function Questie:PostProcessIconPaths(icon)
    for questHash, questMeta in pairs(icon.quests) do
        Questie:PostProcessIconPath(questMeta.path);
        for objectiveid, objectivePath in pairs(questMeta.objectives) do
            if type(objectiveid) == "string" then
                Questie:FindAndCombineObjectiveName(questMeta.objectives, objectiveid, objectivePath);
            end
            Questie:PostProcessIconPath(objectivePath);
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Updates notes for current zone only
---------------------------------------------------------------------------------------------------
function Questie:NOTES_ON_UPDATE(elapsed)
    if GameLoadingComplete == false then return; end
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
    if(c ~= LastContinent or LastZone ~= z) then
        --Questie:debug_Print("Notes:NOTES_ON_UPDATE: [AddEvent:DRAWNOTES]");
        Questie:SetAvailableQuests();
        Questie:RedrawNotes();
        LastContinent = c;
        LastZone = z;
    end
    if(WorldMapFrame:IsVisible() and UIOpen == false) then
        --Questie:debug_Print("NOTES_ON_UPDATE: Created Frames: "..CREATED_NOTE_FRAMES, "Used Frames: "..table.getn(QuestieUsedNoteFrames), "Free Frames: "..table.getn(FramePool));
        UIOpen = true;
    elseif(WorldMapFrame:IsVisible() == nil and UIOpen == true) then
        UIOpen = false;
    end
end
---------------------------------------------------------------------------------------------------
-- Inital pool size (Not tested how much you can do before it lags like shit, from experiance 11
-- is good)
---------------------------------------------------------------------------------------------------
function Questie:NOTES_LOADED()
    --Questie:debug_Print("NOTES_LOADED: Loading QuestieNotes");
    if(table.getn(FramePool) < 10) then
        for i = 1, INIT_POOL_SIZE do
            Questie:CreateBlankFrameNote();
        end
    end
    --Questie:debug_Print("NOTES_LOADED: Done Loading QuestieNotes");
end
---------------------------------------------------------------------------------------------------
function Questie:RecursiveGetPathLocations(path, locations)
    if locations == nil then locations = {}; end
    for sourceType, sources in pairs(path) do
        if sourceType == "locations" and next(sources) then
            for i, location in pairs(sources) do
                table.insert(locations, location);
            end
        elseif sourceType == "drop" or sourceType == "rewardedby" or sourceType == "contained" or sourceType == "contained_id" or sourceType == "created" or sourceType == "containedi" or sourceType == "transforms" or sourceType == "transformedby" then
            for sourceName, sourcePath in pairs(sources) do
                Questie:RecursiveGetPathLocations(sourcePath, locations);
            end
        end
    end
    return locations;
end
---------------------------------------------------------------------------------------------------
function Questie:RecursiveCreateNotes(c, z, v, locationMeta, iconMeta, objectiveid, path, pathKeys)
    if path == nil then path = {}; end
    if pathKeys == nil then pathKeys = {}; end
    for sourceType, sources in pairs(locationMeta) do
        if sourceType == "locations" and next(sources) then
            for specialSource, b in pairs(specialSources) do
                if locationMeta[specialSource] ~= nil and next(locationMeta[specialSource]) then
                    local pathToAppend = path;
                    for i, pathKey in pairs(pathKeys) do
                        pathToAppend = pathToAppend[pathKey];
                    end
                    pathToAppend[specialSource] = {};
                    for sourceName, sourcePath in pairs(locationMeta[specialSource]) do
                        pathToAppend[specialSource][sourceName] = {};
                    end
                end
            end
            for i, location in pairs(sources) do
                local MapInfo = QuestieZoneIDLookup[location[1]];
                if MapInfo ~= nil then
                    c = MapInfo[4];
                    z = MapInfo[5];
                    local icontype = iconMeta.selectedIcon;
                    if icontype == nil then icontype = iconMeta.defaultIcon; end
                    if icontype == "available" or icontype == "availablesoon" then
                        Questie:AddAvailableNoteToMap(location[1],location[2],location[3],location[4],icontype,v,-1,deepcopy(path));
                    else
                        Questie:AddNoteToMap(location[1],location[2],location[3],location[4],icontype,v,objectiveid,deepcopy(path));
                    end
                end
            end
        elseif sourceType == "drop" or sourceType == "rewardedby" or sourceType == "contained" or sourceType == "contained_id" or sourceType == "created" or sourceType == "containedi" or sourceType == "openedby" or sourceType == "transforms" or sourceType == "transformedby" then
            for sourceName, sourceLocationMeta in pairs(sources) do
                local newPath = deepcopy(path);
                local editPath = newPath;
                for i, pathKey in pairs(pathKeys) do
                    editPath = editPath[pathKey];
                end
                editPath[sourceType] = {};
                editPath[sourceType][sourceName] = {};
                local newPathKeys = deepcopy(pathKeys);
                table.insert(newPathKeys, sourceType);
                table.insert(newPathKeys, sourceName);
                local newIconMeta = deepcopy(iconMeta);
                if newIconMeta.selectedIcon == nil then
                    local typeToIcon = {
                        ["drop"] = "loot",
                        ["rewardedby"] = "slay",
                        ["contained"] = "object",
                        ["contained_id"] = "object",
                        ["created"] = "event",
                        ["containedi"] = "object",
                        ["openedby"] = "object",
                        ["transforms"] = "event",
                        ["transformedby"] = "loot",
                    };
                    newIconMeta.selectedIcon = typeToIcon[sourceType];
                end
                local newObjectiveId = objectiveid;
                if specialSources[sourceType] then
                    newPath = {};
                    newPathKeys = {};
                    newObjectiveId = sourceName;
                    newIconMeta.selectedIcon = nil;
                end
                Questie:RecursiveCreateNotes(c, z, v, sourceLocationMeta, newIconMeta, newObjectiveId, newPath, newPathKeys);
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Sets up all available quests
---------------------------------------------------------------------------------------------------
function Questie:SetAvailableQuests(customLevel)
    QuestieAvailableMapNotes = {};
    local saqtime = GetTime();
    local level = customLevel or UnitLevel("player");
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
    local mapFileName = GetMapInfo();
    local quests = nil;
    local minLevel = 0;
    local maxLevel = 100;
    if QuestieConfig.minLevelFilter then
        minLevel = level - QuestieConfig.minShowLevel;
    end
    if QuestieConfig.maxLevelFilter then
        maxLevel = level + QuestieConfig.maxShowLevel;
    end
    quests = Questie:GetAvailableQuestHashes(mapFileName, minLevel, maxLevel);
    if quests then
        local count = 0;
        for k, v in pairs(quests) do
            count = count + 1;
            local icontype = "available";
            if QuestieHashMap[k].level > level then icontype = "availablesoon"; end
            Questie:RecursiveCreateNotes(c, z, k, v, {["selectedIcon"] = icontype});
        end
        --Questie:debug_Print("SetAvailableQuests: Adding "..count.." available quests took "..tostring((GetTime()- saqtime)*1000).."ms");
        saqtime = nil;
    end
end
---------------------------------------------------------------------------------------------------
-- Reason this exists is to be able to call both clearnotes and drawnotes without doing 2 function
-- calls, and to be able to force a redraw
---------------------------------------------------------------------------------------------------
function Questie:RedrawNotes()
    Questie:CLEAR_ALL_NOTES();
    Questie:DRAW_NOTES();
end
---------------------------------------------------------------------------------------------------
function Questie:Clear_Note(v)
    v:SetParent(nil);
    v:Hide();
    v:SetAlpha(1);
    v:SetFrameLevel(9);
    v:SetHighlightTexture(nil, "ADD");
    v.questHash = nil;
    v.objId = nil;
    v.data = nil;
    v.quests = nil;
    v.averageX = nil;
    v.averageY = nil;
    v.countForAverage = nil;
    table.insert(FramePool, v);
end
---------------------------------------------------------------------------------------------------
-- Clears the notes, goes through the usednoteframes and clears them. Then sets the
-- QuestieUsedNotesFrame to new table;
---------------------------------------------------------------------------------------------------
function Questie:CLEAR_ALL_NOTES()
    --Questie:debug_Print("CLEAR_ALL_NOTES");
    Astrolabe:RemoveAllMinimapIcons();
    clustersByFrame = nil;
    for k, v in pairs(QuestieUsedNoteFrames) do
        Questie:Clear_Note(v);
    end
    QuestieUsedNoteFrames = {};
end
---------------------------------------------------------------------------------------------------
-- Logic for clusters
---------------------------------------------------------------------------------------------------
function Cluster.new(points)
    local self = setmetatable({}, Cluster);
    self.points = points;
    return self;
end
---------------------------------------------------------------------------------------------------
function Cluster:CountPoints()
    local count = 0;
    local counted = {};
    for i, q in pairs(self.points) do
        if not counted[q.questHash] then
            count = count + 1;
            counted[q.questHash] = true;
        end
    end
    return count;
end
---------------------------------------------------------------------------------------------------
function Cluster.CalculateDistance(x1, y1, x2, y2)
    local deltaX = x1 - x2;
    local deltaY = y1 - y2;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
end
---------------------------------------------------------------------------------------------------
function Cluster.CalculateLinkageDistance(cluster1, cluster2)
    local total = 0;
    for i, pi in cluster1 do
        for j, pj in cluster2 do
            if pi.zoneid ~= pj.zoneid then return -1; end
            local distance = Cluster.CalculateDistance(pi.x, pi.y, pj.x, pj.y);
            total = total + distance;
        end
    end
    return total / (table.getn(cluster1) * table.getn(cluster2));
end
---------------------------------------------------------------------------------------------------
function Cluster:CalculateClusters(clusters, distanceThreshold, maxClusterSize)
    while table.getn(clusters) > 1 do
        local nearest1;
        local nearest2;
        local nearestDistance;
        for i, cluster in pairs(clusters) do
            for j, otherCluster in pairs(clusters) do
                if cluster ~= otherCluster then
                    local distance = Cluster.CalculateLinkageDistance(cluster.points, otherCluster.points);
                    if distance >= 0 and (distance == 0 or ((nearestDistance == nil or distance < nearestDistance) and (cluster:CountPoints() + otherCluster:CountPoints() <= maxClusterSize))) then
                        nearestDistance = distance;
                        nearest1 = cluster;
                        nearest2 = otherCluster;
                    end
                end
                if nearestDistance == 0 then break; end
            end
            if nearestDistance == 0 then break; end
        end
        if nearestDistance == nil or nearestDistance > distanceThreshold then break; end
        local index1 = indexOf(clusters, nearest1);
        table.remove(clusters, index1);
        local index2 = indexOf(clusters, nearest2);
        table.remove(clusters, index2);
        local points = nearest1.points;
        for i, point in pairs(nearest2.points) do
            table.insert(points, point);
        end
        local newCluster = Cluster.new(points);
        table.insert(clusters, newCluster);
    end
end
---------------------------------------------------------------------------------------------------
-- splits the specified text into an array on the specified separator
-- todo make a QuestieUtils.lua file for things like this
---------------------------------------------------------------------------------------------------
function Questie:SplitString( text, separator, limit )
    local parts, position, length, last, jump, count = {}, 1, string.len( text ), nil, string.len( separator ), 0;
    while true do
        last = string.find( text, separator, position, true );
        if last and ( not limit or count < limit ) then
            table.insert( parts, string.sub( text, position, last - 1 ) );
            position, count = last + jump, count + 1;
        else
            table.insert( parts, string.sub( text, position ) );
            break;
        end
    end
    return parts;
end
---------------------------------------------------------------------------------------------------
function Questie:RoundCoordinate(coord, factor)
    if factor == nil then factor = 1; end
    return tonumber(string.format("%.2f", coord/factor)) * factor;
end
---------------------------------------------------------------------------------------------------
function Questie:GetReactionColor(reaction)
    if reaction == nil or reaction < 1 or reaction > 8 then reaction = 4; end
    return FACTION_BAR_COLORS[reaction];
end
---------------------------------------------------------------------------------------------------
function Questie:AddClusterFromNote(frame, identifier, v)
    if clustersByFrame == nil then
        clustersByFrame = {};
    end
    if clustersByFrame[frame] == nil then
        clustersByFrame[frame] = {};
    end
    if clustersByFrame[frame][identifier] == nil then
        clustersByFrame[frame][identifier] = {};
    end
    if clustersByFrame[frame][identifier][v.continent] == nil then
        clustersByFrame[frame][identifier][v.continent] = {};
    end
    if clustersByFrame[frame][identifier][v.continent][v.zoneid] == nil then
        clustersByFrame[frame][identifier][v.continent][v.zoneid] = {};
    end
    local roundedX = v.x;
    local roundedY = v.y;
    if QuestieConfig.clusterQuests and frame == "WorldMapNote" and identifier == "Objectives" then
        roundedX = Questie:RoundCoordinate(v.x, 5);
        roundedY = Questie:RoundCoordinate(v.y, 5);
    end
    if clustersByFrame[frame][identifier][v.continent][v.zoneid][roundedX] == nil then
        clustersByFrame[frame][identifier][v.continent][v.zoneid][roundedX] = {};
    end
    if clustersByFrame[frame][identifier][v.continent][v.zoneid][roundedX][roundedY] == nil then
        local points = { v };
        local cluster = Cluster.new(points);
        clustersByFrame[frame][identifier][v.continent][v.zoneid][roundedX][roundedY] = cluster;
    else
        table.insert(clustersByFrame[frame][identifier][v.continent][v.zoneid][roundedX][roundedY].points, v);
    end
end
---------------------------------------------------------------------------------------------------
function Questie:GetClustersByFrame(frame, identifier)
    if clustersByFrame == nil then
        clustersByFrame = {};
    end
    if clustersByFrame[frame] == nil then
        clustersByFrame[frame] = {};
    end
    if clustersByFrame[frame][identifier] == nil then
        clustersByFrame[frame][identifier] = {};
    end
    local clusters = {};
    for c, v in pairs(clustersByFrame[frame][identifier]) do
        for z, v in pairs(clustersByFrame[frame][identifier][c]) do
            for x, v in pairs(clustersByFrame[frame][identifier][c][z]) do
                for y, v in pairs(clustersByFrame[frame][identifier][c][z][x]) do
                    table.insert(clusters, clustersByFrame[frame][identifier][c][z][x][y]);
                end
            end
        end
    end
    return clusters;
end
---------------------------------------------------------------------------------------------------
-- Finds the index of an item in a table. Not sure if a function already exists somewhere.
---------------------------------------------------------------------------------------------------
function indexOf(table, item)
    for k, v in pairs(table) do
        if v == item then return k; end
    end
    return nil;
end
---------------------------------------------------------------------------------------------------
-- Checks first if there are any notes for the current zone, then draws the desired icon
---------------------------------------------------------------------------------------------------
function Questie:DRAW_NOTES()
    --Questie:debug_Print("DRAW_NOTES");
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
    if (not QuestieConfig.hideMinimapIcons) then
        -- Draw minimap objective markers
        if (QuestieMapNotes[c] and QuestieMapNotes[c][z]) then
            for k, v in pairs(QuestieMapNotes[c][z]) do
                --If an available quest isn't in the zone or we aren't tracking a quest on the QuestTracker then hide the objectives from the minimap
                local show = QuestieConfig.alwaysShowObjectives or ((MMLastX ~= 0) and (MMLastY ~= 0)) and (QuestieCachedQuests[v.questHash] ~= nil) and (QuestieCachedQuests[v.questHash]["tracked"] ~= false);
                if show then
                    if (v.icontype == "complete") then
                        Questie:AddClusterFromNote("MiniMapNote", "Quests", v);
                    else
                        Questie:AddClusterFromNote("MiniMapNote", "Objectives", v);
                    end
                end
            end
        end
    end
    -- Draw world map objective markers
    for k, Continent in pairs(QuestieMapNotes) do
        for zone, noteHeap in pairs(Continent) do
            for k, v in pairs(noteHeap) do
                if true then
                    --If we aren't tracking a quest on the QuestTracker then hide the objectives from the worldmap
                    if (((QuestieCachedQuests[v.questHash] ~= nil) and (QuestieCachedQuests[v.questHash]["tracked"] ~= false)) or (v.icontype == "complete")) and (QuestieConfig.alwaysShowObjectives == false) then
                        if (v.icontype == "complete") then
                            Questie:AddClusterFromNote("WorldMapNote", "Quests", v);
                        else
                            Questie:AddClusterFromNote("WorldMapNote", "Objectives", v);
                        end
                    elseif (QuestieConfig.alwaysShowObjectives == true) then
                        if (v.icontype == "complete") then
                            Questie:AddClusterFromNote("WorldMapNote", "Quests", v);
                        else
                            Questie:AddClusterFromNote("WorldMapNote", "Objectives", v);
                        end
                    end
                end
            end
        end
    end
    -- Draw available quest markers.
    if (QuestieAvailableMapNotes[c] and QuestieAvailableMapNotes[c][z]) then
        if (IsQuestieActive == true) then
            local con,zon,x,y = Astrolabe:GetCurrentPlayerPosition();
            for k, v in pairs(QuestieAvailableMapNotes[c][z]) do
                Questie:AddClusterFromNote("WorldMapNote", "Quests", v);
                if (not QuestieConfig.hideMinimapIcons) then
                    Questie:AddClusterFromNote("MiniMapNote", "Quests", v);
                end
            end
        end
    end
    local minimapObjectiveClusters = Questie:GetClustersByFrame("MiniMapNote", "Objectives");
    local worldMapObjectiveClusters = Questie:GetClustersByFrame("WorldMapNote", "Objectives");
    local minimapClusters = Questie:GetClustersByFrame("MiniMapNote", "Quests");
    local worldMapClusters = Questie:GetClustersByFrame("WorldMapNote", "Quests");
    if QuestieConfig.clusterQuests then
        Cluster:CalculateClusters(worldMapClusters, 0.025, 5);
    end
    local scale = QUESTIE_NOTES_MAP_ICON_SCALE;
    if (z == 0 and c == 0) then--Both continents
        scale = QUESTIE_NOTES_WORLD_MAP_ICON_SCALE;
    elseif (z == 0) then--Single continent
        scale = QUESTIE_NOTES_CONTINENT_ICON_SCALE;
    end
    Questie:DrawClusters(worldMapObjectiveClusters, "WorldMapNote", scale, WorldMapFrame, WorldMapButton);
    Questie:DrawClusters(worldMapClusters, "WorldMapNote", scale, WorldMapFrame, WorldMapButton);
    Questie:DrawClusters(minimapObjectiveClusters, "MiniMapNote", QUESTIE_NOTES_MINIMAP_ICON_SCALE, Minimap);
    Questie:DrawClusters(minimapClusters, "MiniMapNote", QUESTIE_NOTES_MINIMAP_ICON_SCALE, Minimap);
end
---------------------------------------------------------------------------------------------------
function Questie:DrawClusters(clusters, frameName, scale, frame, button)
    local frameLevel = 9;
    if frameName == "MiniMapNote" then
        frameLevel = 7;
    end
    for i, cluster in pairs(clusters) do
        table.sort(cluster.points, function(a, b)
            if QuestieIcons[a.icontype].priority ~= QuestieIcons[b.icontype].priority then return QuestieIcons[a.icontype].priority < QuestieIcons[b.icontype].priority end
            if a.questHash == b.questHash then return tostring(a) < tostring(b) end
            local questA = QuestieHashMap[a.questHash]
            local questB = QuestieHashMap[b.questHash]
            if not questA or not questB then return questA ~= nil end
            if questA and questB then
                if questA.level ~= questB.level then return questA.level < questB.level end
                local questLevelA = GetNumberFromString(questA.questLevel)
                local questLevelB = GetNumberFromString(questB.questLevel)
                if questLevelA ~= questLevelB then return questLevelA < questLevelB end
            end
            return a.questHash < b.questHash
        end)
        local Icon = Questie:GetBlankNoteFrame(frame);
        for j, v in pairs(cluster.points) do
            if j == 1 then
                local finalFrameLevel = frameLevel;
                if v.icontype == "complete" then finalFrameLevel = finalFrameLevel + 1; end
                Questie:SetFrameNoteData(Icon, v, frame, finalFrameLevel, frameName, scale);
            else
                Questie:AddFrameNoteData(Icon, v);
            end
        end
        Questie:PostProcessIconPaths(Icon);
        if frameName == "MiniMapNote" then
            Icon:SetHighlightTexture(QuestieIcons[Icon.data.icontype].path, "ADD");
            Astrolabe:PlaceIconOnMinimap(Icon, Icon.data.continent, Icon.data.zoneid, Icon.averageX, Icon.averageY);
            table.insert(QuestieUsedNoteFrames, Icon);
        else
            Icon:Show();
            xx, yy = Astrolabe:PlaceIconOnWorldMap(button, Icon, Icon.data.continent, Icon.data.zoneid, Icon.averageX, Icon.averageY);
            if(xx and yy and xx > 0 and xx < 1 and yy > 0 and yy < 1) then
                table.insert(QuestieUsedNoteFrames, Icon);
            else
                Questie:Clear_Note(Icon);
            end
        end
    end
end
---------------------------------------------------------------------------------------------------
-- Debug print function
---------------------------------------------------------------------------------------------------
function Questie:debug_Print(...)
    local debugWin = 0;
    local name, shown;
    for i=1, NUM_CHAT_WINDOWS do
        name,_,_,_,_,_,shown = GetChatWindowInfo(i);
        if (string.lower(name) == "questiedebug") then debugWin = i; break; end
    end
    if (debugWin == 0) then return; end
    local out = "";
    for i = 1, arg.n, 1 do
        if (i > 1) then out = out .. ", "; end
        local t = type(arg[i]);
        if (t == "string") then
            out = out .. '"'..arg[i]..'"';
        elseif (t == "number") then
            out = out .. arg[i];
        else
            out = out .. dump(arg[i]);
        end
    end
    getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end
---------------------------------------------------------------------------------------------------
-- Sets the icon type
---------------------------------------------------------------------------------------------------
QuestieIcons = {
    ["complete"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\complete",
        priority = 1
    },
    ["available"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\available",
        priority = 2
    },
    ["availablesoon"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\availablesoon",
        priority = 2
    },
    ["loot"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\loot",
        priority = 3
    },
    ["item"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\loot",
        priority = 3
    },
    ["event"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\event",
        priority = 3
    },
    ["object"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\object",
        priority = 3
    },
    ["slay"] = {
        text = "Complete",
        path = "Interface\\AddOns\\!Questie\\Icons\\slay",
        priority = 3
    }
};
