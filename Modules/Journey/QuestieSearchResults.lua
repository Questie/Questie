---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class QuestieSearchResults
local QuestieSearchResults = QuestieLoader:CreateModule("QuestieSearchResults")
-------------------------
--Import modules.
-------------------------
---@type QuestDetailsFrame
local QuestDetailsFrame = QuestieLoader:ImportModule("QuestDetailsFrame")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

-- this variable defines how many operations to run (batched at a time) before yielding for a frame.
-- 1 would mean yielding every operation (so lower = slower but less lag)
-- this variable is not a hard limit when invoked, but rather a guideline;
-- each code block may put a modifier on it, for instance 10x  if the loop is lightweight
local TICKS_PER_YIELD = 30

if Questie.IsHardcore then
    -- The addon timing restrictions from the Blizzard watchdog are much higher for HC servers.
    -- Therefore we need a quite low tick rate to make sure we don't get bitten on less performant machines.
    TICKS_PER_YIELD = 15
end

local GetItemInfo = QuestieCompat.GetItemInfo
local stringrep = string.rep
local stringsub = string.sub

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

local _HandleTreeItemSelected, _FindFirstSpawn
local lastOpenSearch = "quest"
local _selected = 0
local searchResultTabs
local detailsFrameGeneration = 0
local searchInteractionGeneration = 0
local searchDebounceGeneration = 0
local programmaticSearchUpdate = false
local programmaticSearchText
local activeResultTree
local clickHandledResultValue
local searchResultHost
local activeModernSearchEditBox
local modernSearchLinkHookInstalled = false

local BY_NAME = 1
local BY_ID = 2
-- A broad text search can match a very large part of the database. Keep the
-- result tree bounded so the UI does not create thousands of native frames in
-- one synchronous layout pass. The tab counters still show the full match
-- count, so users can narrow the query when the cap is reached.
local MAX_RENDERED_SEARCH_RESULTS = 500

local function InstallModernSearchLinkHook()
    if modernSearchLinkHookInstalled or type(hooksecurefunc) ~= "function" then
        return
    end

    local function InsertSearchLink(text)
        local editBox = activeModernSearchEditBox
        if editBox and editBox:IsShown() and editBox:HasFocus() then
            editBox:Insert(text)
        end
    end

    if ChatFrameUtil and ChatFrameUtil.InsertLink then
        hooksecurefunc(ChatFrameUtil, "InsertLink", InsertSearchLink)
        modernSearchLinkHookInstalled = true
    elseif ChatEdit_InsertLink then
        hooksecurefunc("ChatEdit_InsertLink", InsertSearchLink)
        modernSearchLinkHookInstalled = true
    end
end

local function ApplyModernButton(button, width)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyStyledButton then
        button:SetWidth(width)
        button:SetHeight(40)
        QuestieOptionsControls.ApplyStyledButton(button.frame, width, button.text)
    end
end

local function AddModernDivider(container, text)
    if QuestieOptionsControls and QuestieOptionsControls.CreateModernDividerGroup then
        return QuestieOptionsControls.CreateModernDividerGroup(container, text)
    end

    local header = QuestieGUI:Create("Heading")
    header:SetFullWidth(true)
    header:SetText(text)
    container:AddChild(header)
    return header
end

local function ApplyModernSearchBox(searchBox, placeholder)
    local frame = searchBox.frame
    if not frame or not frame.CreateTexture then
        return
    end

    local legacyEditBox = searchBox.editbox
    local originalDisableButton = searchBox.disablebutton
    legacyEditBox:Hide()
    -- QuestieGUI's note editor uses a custom backdrop and focus surface for
    -- its EditBox. Advanced Search replaces the real EditBox with Blizzard's
    -- SearchBoxTemplate, so those note-only layers must not remain visible or
    -- sit above the new search control.
    if searchBox.editSkin then searchBox.editSkin:Hide() end
    if searchBox.focusSurface then searchBox.focusSurface:Hide() end
    if searchBox.scrollBar then searchBox.scrollBar:Hide() end

    local editBox = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -7)
    editBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -7)
    editBox:SetHeight(26)
    editBox:SetMaxLetters(256)
    editBox:SetTextInsets(22, 4, 3, 3)
    if editBox.SetPropagateKeyboardInput then
        editBox:SetPropagateKeyboardInput(false)
    end

    searchBox.editbox = editBox
    activeModernSearchEditBox = editBox
    InstallModernSearchLinkHook()
    editBox.obj = searchBox
    searchBox.disablebutton = true
    searchBox.button:Hide()

    local rawSetText = searchBox.SetText
    local modernSearchBox = {
        editBox = editBox,
        legacyEditBox = legacyEditBox,
        rawSetText = rawSetText,
        disablebutton = originalDisableButton,
    }
    searchBox.modernSearchBox = modernSearchBox
    searchBox.SetText = function(self, text)
        rawSetText(self, text)
        self.editbox:SetTextInsets(22, 4, 3, 3)
    end

    editBox:SetScript("OnEscapePressed", function()
        searchBox:ClearFocus()
    end)
    editBox:SetScript("OnEnterPressed", function(self)
        local cancel = searchBox:Fire("OnEnterPressed", self:GetText())
        if not cancel then
            self:ClearFocus()
        end
    end)
    editBox:SetScript("OnTextChanged", function(self)
        if _G.SearchBoxTemplate_OnTextChanged then
            _G.SearchBoxTemplate_OnTextChanged(self)
        end
        searchBox:Fire("OnTextChanged", self:GetText())
    end)
    editBox:SetScript("OnEditFocusGained", function(self)
        if self.SetPropagateKeyboardInput then
            self:SetPropagateKeyboardInput(false)
        end
        QuestieGUI:SetFocus(searchBox)
    end)
    editBox:SetScript("OnEnter", function()
        searchBox:Fire("OnEnter")
    end)
    editBox:SetScript("OnLeave", function()
        searchBox:Fire("OnLeave")
    end)

    if type(editBox.Instructions) == "table" then
        editBox.Instructions:SetText(placeholder)
    end

    searchBox:SetHeight(40)

    searchBox:SetCallback("OnRelease", function(widget)
        local state = widget.modernSearchBox
        if not state then
            return
        end

        if activeModernSearchEditBox == state.editBox then
            activeModernSearchEditBox = nil
        end
        state.editBox:Hide()
        state.editBox.obj = nil
        state.legacyEditBox:Show()
        widget.editbox = state.legacyEditBox
        widget.SetText = state.rawSetText
        widget.disablebutton = state.disablebutton
        if not state.disablebutton then
            widget.button:Show()
        end
        widget.modernSearchBox = nil
    end)
end


---Takes a frame and adds a paragraph with a header text and a list of links to other search results
---@param frame QuestieGUIWidget The frame to work on
---@param linkType string The type of result to link to (npc|object|quest|item)
---@param lookup table Table of IDs (npc|object|quest|item)
---@param header string The text header to show above the links
---@param query function The function used to get link name from
---@param boolean addTomTomButton Whether to add a button for setting a TomTom target for the first spawn of each linked result, if available
local function AddLinkedParagraph(frame, linkType, lookup, header, query, addTomTomButton)
    if lookup and #lookup > 0 then
        local group = QuestieGUI:Create("InlineGroup");
        if QuestDetailsFrame.ResetInfoGroup then
            QuestDetailsFrame:ResetInfoGroup(group)
        end
        group:SetFullWidth(true);
        group:SetLayout("list");
        group:SetTitle(header);
        frame:AddChild(group);

        for _,id in pairs(lookup) do
            id = abs(id)
            local link = QuestieGUI:Create("InteractiveLabel")
            if QuestieJourneyUtils.ApplyModernQuestLinkStyle then
                QuestieJourneyUtils.ApplyModernQuestLinkStyle(link)
            end
            local name = query(id, "name")
            local text
            if linkType == 'quest' then
                text = QuestieLib:GetColoredQuestName(id,  true, true)
            elseif linkType == 'npc' then
                local lvl = query(id, 'maxLevel')
                text = '['..lvl..'] '..name..' ('..id..')'
            else
                text = name.." ("..id..")"
            end
            link:SetText(text);
            link:SetFullWidth(true)
            link:SetWordWrap(true)
            if link.modernQuestLinkRefresh then
                link.modernQuestLinkRefresh()
            end
            link:SetUserData("id", id)
            link:SetUserData("type", linkType)
            link:SetUserData("name", name)
            link:SetCallback("OnClick", function() QuestieSearchResults:SetSearch(linkType, id) end)
            link:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
            link:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)
            group:AddChild(link);
        end

        if addTomTomButton and TomTom and TomTom.AddWaypoint then
            for _, id in pairs(lookup) do
                id = abs(id)
                local spawns = query(id, "spawns")
                if spawns then
                    local zone, x, y = _FindFirstSpawn(spawns)
                    if zone then
                        local name = query(id, "name")
                        QuestieJourneyUtils:Spacer(group)
                        local button = QuestieGUI:Create("Button")
                        button:SetText(l10n("Set |cFF54e33bTomTom|r Target"))
                        ApplyModernButton(button, 220)
                        button:SetCallback("OnClick", function()
                            TrackerUtils:SetTomTomTarget(name, zone, x, y)
                        end)
                        group:AddChild(button)
                        break
                    end
                end
            end
        end
    end
end

-- Track which items the user explicitly chose to show on the map
---@type table<string, true>
local _shownItemIds = {}

function QuestieSearchResults.ClearShownItemIds()
    _shownItemIds = {}
end

-- Check whether the relevant manual frames are already shown on the map
---@param id NpcId|ObjectId|ItemId @NPC (>0) or object (<0) id, or item id when idsToShow is provided
---@param idsToShow NpcId[]|ObjectId[]? @NPC/object ids shown together (e.g. all mobs dropping an item)
---@param groupName string? @Source group name for items (e.g. "NPC", "Object", "Vendor")
local function _HasShownFrames(id, idsToShow, groupName)
    if idsToShow and groupName then
        return _shownItemIds[id .. ":" .. groupName] ~= nil
    end
    if (not QuestieMap.manualFrames["any"]) then
        return false
    end
    return QuestieMap.manualFrames["any"][id] ~= nil
end

-- Create a button for showing/hiding manual notes of NPCs/objects
---@param id NpcId|ObjectId|ItemId @NPC (>0) or object (<0) id, or item id when idsToShow is provided
---@param idsToShow NpcId[]|ObjectId[]? @NPC/object ids shown together (e.g. all mobs dropping an item)
---@param groupName string? @Source group name for items (e.g. "NPC", "Object", "Vendor")
local function CreateShowHideButton(id, idsToShow, groupName)
    -- Initialise button
    local button = QuestieGUI:Create("Button")
    button.id = id
    button.idsToShow = idsToShow
    button.groupName = groupName
    if (not _HasShownFrames(id, idsToShow, groupName)) then
        button:SetText(l10n("Show on Map"))
        button:SetCallback("OnClick", function(self) self:ShowOnMap(self) end)
    else
        button:SetText(l10n("Remove from Map"))
        button:SetCallback("OnClick", function(self) self:RemoveFromMap(self) end)
    end
    ApplyModernButton(button, 180)
    -- Functions for showing/hiding and switching behaviour afterwards
    button.RemoveFromMap = function(self)
        self:SetText(l10n("Show on Map"))
        self:SetCallback("OnClick", function() self:ShowOnMap(self) end)

        if self.idsToShow and self.groupName then
            _shownItemIds[self.id .. ":" .. self.groupName] = nil
            local ids = {}
            for _, spawnId in pairs(self.idsToShow) do
                ids[#ids + 1] = spawnId
            end

            ThreadLib.ThreadInstant(function()
                local yieldCount = 0
                for i = 1, #ids do
                    QuestieMap:UnloadManualFrames(ids[i])
                    yieldCount = yieldCount + 1
                    if yieldCount >= TICKS_PER_YIELD then
                        yieldCount = 0
                        coroutine.yield()
                    end
                end
            end)
        else
            QuestieMap:UnloadManualFrames(self.id)
        end
    end
    button.ShowOnMap = function(self)
        self:SetText(l10n("Remove from Map"))
        self:SetCallback("OnClick", function() self:RemoveFromMap(self) end)

        if self.idsToShow and self.groupName then
            _shownItemIds[self.id .. ":" .. self.groupName] = true
            local ids = {}
            for _, spawnId in pairs(self.idsToShow) do
                ids[#ids + 1] = spawnId
            end

            ThreadLib.ThreadInstant(function()
                local yieldCount = 0
                for i = 1, #ids do
                    if ids[i] > 0 then
                        QuestieMap:ShowNPC(ids[i])
                    else
                        QuestieMap:ShowObject(-ids[i])
                    end
                    yieldCount = yieldCount + 1
                    if yieldCount >= TICKS_PER_YIELD then
                        yieldCount = 0
                        coroutine.yield()
                    end
                end
            end)
        else
            if self.id > 0 then
                QuestieMap:ShowNPC(self.id)
            elseif self.id < 0 then
                QuestieMap:ShowObject(-self.id)
            end
        end
    end
    return button
end

--- Finds the first valid spawn location from a spawns table
---@param spawns table<AreaId, CoordPair[]>
---@return AreaId|nil zone
---@return number|nil x
---@return number|nil y
_FindFirstSpawn = function(spawns)
    for zoneId, coords in pairs(spawns) do
        if coords and coords[1] then
            local x = coords[1][1]
            local y = coords[1][2]
            if x and y and (x ~= -1 or y ~= -1) then
                return zoneId, x, y
            end
        end
    end
    return nil, nil, nil
end

local function rec(theTable, ret, indent)
    ret = ret..stringrep('    ', indent)..'{\n'
    indent = indent + 1
    for k, v in pairs(theTable) do
        local t = type(v)
        if t == 'nil' then
            ret = ret..stringrep('    ', indent)..'['..k..']=nil'
        elseif t == 'table' then
            ret = rec(v, ret..stringrep('    ', indent)..'['..k..']=\n', indent)
        else
            ret = ret..stringrep('    ', indent)..'['..k..']='..v
        end
        ret = ret..'\n'
    end
    return ret..stringrep('    ', indent-1)..'},'
end

local function recurseTable(theTable, theKeys)
    local ret = Questie:Colorize('Raw data (shown because debug is enabled):\n\n', 'red')
    for key, _ in pairs(theKeys) do
        ret = ret..Questie:Colorize(key, 'yellow')..': '
        local t = type(theTable[key])
        if t == 'nil' then
            ret = ret..'nil'
        elseif t == 'table' then
            ret = rec(theTable[key], ret, 0)
        else
            ret = ret..theTable[key]
        end
        ret = ret..'\n'
    end
    return ret
end

function QuestieSearchResults:SpawnDetailsFrame(f, spawn, spawnType)
    local id = 0
    local typeLabel = ""
    local query
    local spawnObject
    if spawnType == "npc" then
        typeLabel = l10n("NPC ID")
        spawnObject = QuestieDB:GetNPC(spawn)
    elseif spawnType == "object" then
        typeLabel = l10n("Object ID")
        spawnObject = QuestieDB:GetObject(spawn)
    end

    if not spawnObject then
        Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieSearchResults:SpawnDetailsFrame] Missing spawn data:", spawnType, spawn)
        AddModernDivider(f, l10n(typeLabel ~= "" and typeLabel or "Unknown"))
        QuestieJourneyUtils:AddLine(f, Questie:Colorize(typeLabel ~= "" and typeLabel or l10n("Unknown")) .. l10n(": ") .. tostring(spawn))
        return
    end

    AddModernDivider(f, spawnObject.name)

    local infoContainer = f
    if spawnType == "npc" then
        infoContainer = QuestieGUI:Create("InlineGroup")
        infoContainer:SetLayout("List")
        infoContainer:SetFullWidth(true)
        if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
            QuestieOptionsControls.ApplyModernInfoGroup(infoContainer)
        end
        f:AddChild(infoContainer)
        if QuestDetailsFrame.ApplyNPCInfoGroup then
            QuestDetailsFrame:ApplyNPCInfoGroup(infoContainer, spawnObject)
        end
    end

    QuestieJourneyUtils:Spacer(infoContainer);

    QuestieJourneyUtils:AddLine(infoContainer, Questie:Colorize(l10n(typeLabel))..l10n(": ")..spawn)
    if spawnType == "npc" then
        if spawnObject.subName then
            QuestieJourneyUtils:AddLine(infoContainer, Questie:Colorize(l10n("Title"))..l10n(": ")..spawnObject.subName)
        end
        local minLevel = spawnObject.minLevel
        local maxLevel = spawnObject.maxLevel
        local level
        if minLevel == maxLevel then level = minLevel else level = minLevel.." - "..maxLevel end
        QuestieJourneyUtils:AddLine(infoContainer, Questie:Colorize(l10n("Level"))..l10n(": ")..level)
        local minLevelHealth = spawnObject.minLevelHealth
        local maxLevelHealth = spawnObject.maxLevelHealth
        local health
        if minLevelHealth == maxLevelHealth then health = minLevelHealth else health = minLevelHealth.." - "..maxLevelHealth end
        QuestieJourneyUtils:AddLine(infoContainer, Questie:Colorize(l10n("Health"))..l10n(": ")..health)
        local friendlyTo = l10n("no faction")
        if spawnObject.friendlyToFaction == "AH" then
            friendlyTo = l10n("both factions")
        elseif spawnObject.friendlyToFaction == "A" then
            friendlyTo = l10n("Alliance")
        elseif spawnObject.friendlyToFaction == "H" then
            friendlyTo = l10n("Horde")
        end
        QuestieJourneyUtils:AddLine(infoContainer, Questie:Colorize(l10n("Friendly to"))..l10n(": ")..friendlyTo)
    end

    QuestieJourneyUtils:Spacer(infoContainer);

    -- Also Starts
    if spawnObject.questStarts then
        AddLinkedParagraph(f, "quest", spawnObject.questStarts, l10n("Starts the following quests"), QuestieDB.QueryQuestSingle, false)
    end

    -- Also ends
    if spawnObject.questEnds then
        AddLinkedParagraph(f, "quest", spawnObject.questEnds, l10n("Ends the following quests"), QuestieDB.QueryQuestSingle, false)
    end

    local spawnZone = QuestieGUI:Create("Label")
    spawnZone:SetFontObject(GameFontNormal)
    spawnZone:SetFullWidth(true)
    local spawns = spawnObject.spawns

    if spawns then
        local startindex
        for i in pairs(spawns) do
            local coords = spawns[i] and spawns[i][1]
            if coords and coords[1] and coords[2] and (coords[1] ~= -1 or coords[2] ~= -1) then
                startindex = i;
                break;
            end
        end

        if startindex then
            local mapButton = QuestieGUI:Create("Button")
            mapButton:SetText(l10n("Show on Map"))
            ApplyModernButton(mapButton, 180)
            local mapX = spawns[startindex][1][1]
            local mapY = spawns[startindex][1][2]
            mapButton:SetCallback("OnClick", function()
                if spawnType == "npc" then
                    TrackerUtils:ShowNPCOnMap(spawn, startindex, mapX, mapY)
                else
                    TrackerUtils:ShowObjectOnMap(spawn, startindex, mapX, mapY)
                end
            end)
            f:AddChild(mapButton)
        end

        if TomTom and TomTom.AddWaypoint and spawns[startindex] and spawns[startindex][1] then
            local tx = spawns[startindex][1][1]
            local ty = spawns[startindex][1][2]
            if tx ~= -1 or ty ~= -1 then
                local tomTomButton = QuestieGUI:Create("Button")
                tomTomButton:SetText(l10n("Set |cFF54e33bTomTom|r Target"))
                ApplyModernButton(tomTomButton, 220)
                tomTomButton:SetCallback("OnClick", function()
                    TrackerUtils:SetTomTomTarget(spawnObject.name, startindex, tx, ty)
                end)
                f:AddChild(tomTomButton)
            end
        end

        local zoneName = QuestieJourneyUtils:GetZoneName(startindex)

        spawnZone:SetText(l10n(zoneName));
        f:AddChild(spawnZone);

        if spawns[startindex] and spawns[startindex][1] then
            local startx = spawns[startindex][1][1];
            local starty = spawns[startindex][1][2];

            if (startx ~= -1 or starty ~= -1) then
                local spawnLoc = QuestieGUI:Create("Label");
                spawnLoc:SetText("X" .. l10n(": ") .. string.format("%.2f",startx) .." || Y" .. l10n(": ") .. string.format("%.2f",starty));
                spawnLoc:SetFontObject(GameFontNormal)
                spawnLoc:SetFullWidth(true);
                f:AddChild(spawnLoc);
            end
        end
    else
        spawnZone:SetText(l10n("No spawn data available."))
        f:AddChild(spawnZone);
    end

    QuestieJourneyUtils:Spacer(f);

    if Questie.db.profile.debugEnabled then
        if spawnType == "npc" then
            QuestieJourneyUtils:AddLine(f, recurseTable(spawnObject, QuestieDB.npcKeys))
        elseif spawnType == "object" then
            QuestieJourneyUtils:AddLine(f, recurseTable(spawnObject, QuestieDB.objectKeys))
        end
    end

    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);
end

--- Used for pre-caching item data, see the function below
---@type GameTooltip
local QuestieScanningTooltip = CreateFrame("GameTooltip", "QuestieScanningTooltip", nil, "GameTooltipTemplate")
QuestieScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

--- This function queries an item tooltip from the server, waits for the result, then calls the following function to draw an item info frame to a given parent frame.
---@param f Frame The frame to attach the created item details frame to
---@param itemId ItemId The ID for the item to show details about
---@return nil
function QuestieSearchResults:ItemDetailsFrame(f, itemId)
    -- Caching an item creates visible lag of 2 or 3 seconds at times (e.g. 13490, 13492 on Era)
    -- So we need to make sure the item data is *sufficiently* cached before we draw the frame
    -- We can't use the following because it creates a delay in the tooltip being drawn:
    -- C_Item.RequestLoadItemDataByID(itemId)

    -- Instead we use this:
    QuestieScanningTooltip:SetItemByID(itemId)

    local requestGeneration = f.journeyDetailsGeneration

    local function IsCurrentDetailsFrame()
        return f.frame and f.frame:IsShown() and f.journeyDetailsGeneration == requestGeneration
    end

    -- Then we wait for client to say it cached the item
    local ticker
    ticker = C_Timer.NewTicker(0.05, function()
        -- When it does...
        if C_Item.IsItemDataCachedByID(itemId) then
            ticker:Cancel()
            -- We still need another tiny delay because the following content might still clip the last few lines otherwise
            C_Timer.After(0.05, function()
                if IsCurrentDetailsFrame() then
                    QuestieSearchResults:ItemsFrameAfterTicker(f, itemId)
                end
            end)
        end
    end)
end

--- This function draws an item info frame to a given parent frame after the previous function made sure its data is cached.
---@param f Frame The frame to attach the created item details frame to
---@param itemId ItemId The ID for the item to show details about
function QuestieSearchResults:ItemsFrameAfterTicker(f, itemId)
    local query = QuestieDB.QueryItemSingle

    AddModernDivider(f, query(itemId, "name"))

    -- Keep the item identity row inside the same bordered info treatment as
    -- the other Journey detail sections. A plain flow group left the icon
    -- and ID label flush against the outer pane and made them look detached.
    local grp = QuestieGUI:Create("InlineGroup")
    grp:SetFullWidth(true)
    grp:SetLayout("Flow")
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernInfoGroup then
        QuestieOptionsControls.ApplyModernInfoGroup(grp)
    end

    local itemIcon = QuestieJourneyUtils.GetItemIcon(itemId)
    grp:AddChild(itemIcon)

    local spawnIdLabel = QuestieGUI:Create("Label")
    spawnIdLabel:SetText(l10n("Item ID")..l10n(": ") .. itemId)
    grp:AddChild(spawnIdLabel)

    f:AddChild(grp)

    if QuestieCorrections.questItemBlacklist[itemId] then
        QuestieJourneyUtils:Spacer(f)
        local itemBlacklistedLabel = QuestieGUI:Create("Label")
        itemBlacklistedLabel:SetText(l10n("This item is blacklisted because it has too many sources"))
        itemBlacklistedLabel:SetFullWidth(true)
        f:AddChild(itemBlacklistedLabel)
        return
    end

    local sources = QuestieDB.QueryItem(itemId, {"npcDrops", "objectDrops", "vendors"})
    local npcDrops = sources[1]
    local objectDrops = sources[2]
    local vendors = sources[3]

    AddModernDivider(f, l10n("NPCs"))

    if (not npcDrops or not next(npcDrops)) then
        local noNPCSourcesLabel = QuestieGUI:Create("Label")
        noNPCSourcesLabel:SetText(l10n("No NPC drops this item"))
        noNPCSourcesLabel:SetFullWidth(true)
        f:AddChild(noNPCSourcesLabel)
    else
        local npcLabel = QuestieGUI:Create("Label")

        local npcIdsWithSpawns = {}
        for _, npcId in pairs(npcDrops) do
            local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
            if spawns then
                npcIdsWithSpawns[#npcIdsWithSpawns + 1] = npcId
            end
        end

        npcLabel:SetText(l10n("%d NPCs drop this item", #npcIdsWithSpawns))
        f:AddChild(npcLabel)
        if (#npcIdsWithSpawns > 0) then
            local showHideButton = CreateShowHideButton(itemId, npcIdsWithSpawns, "NPC")
            f:AddChild(showHideButton)
        end
        AddLinkedParagraph(f, "npc", npcIdsWithSpawns, "", QuestieDB.QueryNPCSingle, false)
    end

    AddModernDivider(f, l10n("Objects"))

    if (not objectDrops or not next(objectDrops)) then
        local noObjectSourcesLabel = QuestieGUI:Create("Label")
        noObjectSourcesLabel:SetText(l10n("No Object drops this item"))
        noObjectSourcesLabel:SetFullWidth(true)
        f:AddChild(noObjectSourcesLabel)
    else
        local objectLabel = QuestieGUI:Create("Label")

        local objectIdsWithSpawns = {}
        for _, objectId in pairs(objectDrops) do
            local spawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
            if spawns then
                objectIdsWithSpawns[#objectIdsWithSpawns + 1] = -objectId
            end
        end

        objectLabel:SetText(l10n("%d Objects drop this item", #objectIdsWithSpawns))
        f:AddChild(objectLabel)
        if (#objectIdsWithSpawns > 0) then
            local showHideButton = CreateShowHideButton(itemId, objectIdsWithSpawns, "Object")
            f:AddChild(showHideButton)
        end
        AddLinkedParagraph(f, "object", objectIdsWithSpawns, "", QuestieDB.QueryObjectSingle, false)
    end

    AddModernDivider(f, l10n("Vendors"))

    if (not vendors or not next(vendors)) then
        local noVendorSourcesLabel = QuestieGUI:Create("Label")
        noVendorSourcesLabel:SetText(l10n("No Vendor sells this item"))
        noVendorSourcesLabel:SetFullWidth(true)
        f:AddChild(noVendorSourcesLabel)
    else
        local vendorLabel = QuestieGUI:Create("Label")

        local vendorIdsWithSpawns = {}
        for _, npcId in pairs(vendors) do
            local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
            local friendlyToFaction = QuestieDB.QueryNPCSingle(npcId, "friendlyToFaction")

            if spawns and QuestieDB.IsFriendlyToPlayer(friendlyToFaction) then
                vendorIdsWithSpawns[#vendorIdsWithSpawns + 1] = npcId
            end
        end

        vendorLabel:SetText(l10n("%d Vendors sell this item", #vendorIdsWithSpawns))
        f:AddChild(vendorLabel)
        if (#vendorIdsWithSpawns > 0) then
            local showHideButton = CreateShowHideButton(itemId, vendorIdsWithSpawns, "Vendor")
            f:AddChild(showHideButton)
        end
        AddLinkedParagraph(f, "npc", vendorIdsWithSpawns, "", QuestieDB.QueryNPCSingle)
    end

    if Questie.db.profile.debugEnabled then
        QuestieJourneyUtils:AddLine(f, recurseTable(QuestieDB:GetItem(itemId), QuestieDB.itemKeys))
    end
    -- Fix for sometimes the scroll content will max out and not show everything until window is resized
    f.content:SetHeight(10000);
end

-- draws a list of results of a certain type, e.g. "quest"
function QuestieSearchResults:DrawResultTab(container, resultType)
    -- probably already done by `JourneySelectTabGroup`, doesn't hurt to be safe though
    activeResultTree = nil
    container:ReleaseChildren();

    local results = {}
    local database
    if resultType == "quest" then
        database = QuestieDB.QueryQuestSingle
    elseif resultType == "npc" then
        database = QuestieDB.QueryNPCSingle
    elseif resultType == "object" then
        database = QuestieDB.QueryObjectSingle
    elseif resultType == "item" then
        database = QuestieDB.QueryItemSingle
    else
        return
    end
    local resultTotal = 0
    for k,_ in pairs(QuestieSearch.LastResult[resultType]) do
        resultTotal = resultTotal + 1
        if #results < MAX_RENDERED_SEARCH_RESULTS then
            local name = database(k, "name")
            if name then
                local complete = ''
                if Questie.db.char.complete[k] and resultType == "quest" then
                    complete = Questie:Colorize("(" .. l10n("Complete") .. ")" , "green")
                end
                -- TODO rename option to "enabledIDs" or create separate ones for npcs/objects/items
                local id = ''
                if Questie.db.profile.enableTooltipsQuestID then
                    id = ' (' .. k .. ')'
                end
                table.insert(results, {
                    ["text"] = name .. id .. " " .. complete,
                    ["value"] = tonumber(k)
                })
            end
        end
    end
    if resultTotal > MAX_RENDERED_SEARCH_RESULTS then
        table.insert(results, {
            ["text"] = "... " .. (resultTotal - MAX_RENDERED_SEARCH_RESULTS) .. " more results; refine your search",
            ["value"] = "__questie_search_limit__",
            ["disabled"] = true,
        })
    end
    local resultFrame = QuestieGUI:Create("SimpleGroup");
    resultFrame:SetLayout("Fill");
    resultFrame:SetFullWidth(true);
    resultFrame:SetFullHeight(true);

    local resultTree = QuestieGUI:Create("TreeGroup");
    activeResultTree = resultTree
    resultTree:SetFullWidth(true);
    resultTree:SetFullHeight(true);
    resultTree.treeframe:SetWidth(415);
    if searchResultTabs and searchResultTabs.SetTabBarWidth then
        searchResultTabs:SetTabBarWidth(resultTree.treeframe:GetWidth())
    end
    if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyTreeGroup then
        QuestieOptionsControls.ApplyJourneyTreeGroup(resultTree)
    end
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
        QuestieOptionsControls.ApplyModernScrollbar(resultTree.scrollbar)
    end
    resultTree:SetTree(results);
    -- Programmatic selection fires OnGroupSelected, while a real row click
    -- must render directly so the custom non-Ace tree does not depend on a
    -- secondary selection event.
    resultTree:SetCallback("OnGroupSelected", _HandleTreeItemSelected)
    resultTree:SetCallback("OnClick", function(_, _, selectedId, alreadySelected)
        if not alreadySelected then
            clickHandledResultValue = tostring(selectedId)
            _HandleTreeItemSelected(resultTree, nil, selectedId, true)
        end
        if IsShiftKeyDown() and lastOpenSearch == "quest" then
            ChatEdit_InsertLink(QuestieLink.GetQuestLinkStringById(tonumber(selectedId)))
        end
    end)

    resultFrame:AddChild(resultTree)
    container:AddChild(resultFrame);
    if container.RaiseTabs then
        container:RaiseTabs()
    end
    if _selected ~= 0 then
        resultTree:SelectByValue(_selected)
        _selected = 0
    end
end

_HandleTreeItemSelected = function(group, _, value, fromClick, resultTypeOverride)
    if group ~= activeResultTree or (group.IsReleasing and group:IsReleasing()) then
        return
    end

    if not fromClick and clickHandledResultValue == tostring(value) then
        clickHandledResultValue = nil
        return
    end

    if fromClick then
        clickHandledResultValue = tostring(value)
    end

    searchInteractionGeneration = searchInteractionGeneration + 1
    local detailType = resultTypeOverride or lastOpenSearch

    -- This is either the questId, npcId, objectId or itemId
    local selectedId = tonumber(value)

    if searchResultTabs then
        searchResultTabs.modernHoverLocked = true
        searchResultTabs.modernPinnedValue = detailType
    end

    -- get master frame and create scroll frame inside
    local master = group.frame.obj;
    master:ReleaseChildren();
    master:SetLayout("Fill");
    master:SetFullWidth(true);
    master:SetFullHeight(true);

    local details = QuestieGUI:Create("ScrollFrame");
    details:SetLayout("Flow");
    details:SetCallback("OnRelease", function(widget)
        widget.journeyDetailsGeneration = nil
    end)
    detailsFrameGeneration = detailsFrameGeneration + 1
    details.journeyDetailsGeneration = detailsFrameGeneration
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
        QuestieOptionsControls.ApplyModernScrollbar(details.scrollbar)
    end
    master:AddChild(details);
    if QuestieOptionsControls and QuestieOptionsControls.ApplyJourneyPane then
        QuestieOptionsControls.ApplyJourneyPane(details.frame)
    end
    if searchResultTabs and searchResultTabs.RaiseTabs then
        searchResultTabs:RaiseTabs()
    end

    if detailType == "quest" then
        local quest = QuestieDB.GetQuest(selectedId)
        if not quest then
            Questie.Debug(Questie.DEBUG_CRITICAL, "[QuestieSearchResults] Quest data missing in Journey:", selectedId)
            return
        end
        QuestDetailsFrame:Draw(details, quest)
    elseif detailType == "npc" then
        QuestieSearchResults:SpawnDetailsFrame(details, selectedId, 'npc');
    elseif detailType == "object" then
        QuestieSearchResults:SpawnDetailsFrame(details, selectedId, 'object')
    elseif detailType == "item" then
        QuestieSearchResults:ItemDetailsFrame(details, selectedId)
    end
end

local function SelectTabGroup(container, _, resultType)
    lastOpenSearch = resultType
    QuestieSearchResults:DrawResultTab(container, resultType);
end

local function _GetSearchFunction(searchBox, searchGroup)
    return function(keepFocus)
        if searchBox:GetText() ~= "" then
            local searchText = searchBox:GetText()

            local itemName = GetItemInfo(searchText)
            if stringsub(searchText, 1, 4) == "|cff" and itemName then
                -- An itemLink was added to the searchBox
                searchBox:SetText(itemName)
                QuestieSearchResults:DrawSearchResultTab(searchGroup, BY_NAME, itemName, false)
            elseif stringsub(searchText, 1, 4) == "|cff" then
                -- This should be impossible to reach, since when you see an item link in the game the item should
                -- be cached already which would be caught by the condition above
                Questie.Debug(Questie.DEBUG_DEVELOP, "Search with link of an uncached item")
            else
                -- Normal search
                local text = string.trim(searchText, " \n\r\t[]");
                QuestieSearchResults:DrawSearchResultTab(searchGroup, tonumber(text) and BY_ID or BY_NAME, text, false)
            end
            if not keepFocus then
                searchBox:ClearFocus()
            end
        end
    end
end

-- Draw search results from advanced search tab
function QuestieSearchResults:DrawSearchResultTab(searchGroup, searchType, query, useLast)
    -- Switching Journey tabs releases the canvas children but does not
    -- recursively release the nested result TabGroup. Never reuse that stale
    -- group inside a newly-created Advanced Search host.
    if searchResultTabs and searchResultHost ~= searchGroup then
        searchResultTabs = nil
        searchResultHost = nil
        activeResultTree = nil
    end

    if searchResultTabs then
        -- Hover locking belongs to one result set and must not carry into a new query.
        searchResultTabs.modernHoverLocked = false
        searchResultTabs.modernPinnedValue = nil
    end

    activeResultTree = nil
    if searchType == BY_NAME and (not useLast) then
        QuestieSearch:ByName(query)
    elseif searchType == BY_ID and (not useLast) then
        QuestieSearch:ByID(query)
    end

    local results = QuestieSearch.LastResult
    local resultTypes = {
        ["quest"] = "Quests",
        ["npc"] = "Mobs",
        ["object"] = "Objects",
        ["item"] = "Items",
    }
    local resultCountTotal = 0
    local resultCounts = {
        total = 0,
        quest = 0,
        npc = 0,
        object = 0,
        item = 0
    }
    for resultType in pairs(resultTypes) do
        for _,_ in pairs(results[resultType]) do
            resultCountTotal = resultCountTotal + 1
            resultCounts[resultType] = resultCounts[resultType] + 1
        end
    end

    if resultCountTotal == 0 then
        searchGroup:ReleaseChildren()
        searchResultTabs = nil
        searchResultHost = nil
        local noresults = QuestieGUI:Create("Label")
        noresults:SetText(Questie:Colorize(l10n('No Match for Search Results: %s', query), 'yellow'))
        noresults:SetFullWidth(true)
        searchGroup:AddChild(noresults)
        return
    end

    local tabs = {
            {
                text = l10n('Quests') .. " ("..resultCounts.quest..")",
                value = "quest",
                disabled = resultCounts.quest == 0,
            },
            {
                text = l10n('NPCs') .. " ("..resultCounts.npc..")",
                value = "npc",
                disabled = resultCounts.npc == 0,
            },
            {
                text = l10n('Objects') .. " ("..resultCounts.object..")",
                value = "object",
                disabled = resultCounts.object == 0,
            },
            {
                text = l10n('Items') .. " ("..resultCounts.item..")",
                value = "item",
                disabled = resultCounts.item == 0,
            },
    }

    if not searchResultTabs then
        searchResultTabs = QuestieGUI:Create("TabGroup")
        searchResultTabs:SetFullWidth(true)
        searchResultTabs:SetFullHeight(true)
        searchResultTabs:SetLayout("Flow")
        searchResultHost = searchGroup
        searchGroup:ReleaseChildren()
        searchGroup:AddChild(searchResultTabs)
    end

    -- Rebuild only the result content. Keeping the outer TabGroup alive
    -- prevents a query refresh from dropping the native tab strip.
    searchResultTabs:ReleaseChildren()
    searchResultTabs:SetTabs(tabs)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernTabGroup then
        QuestieOptionsControls.ApplyModernTabGroup(searchResultTabs)
    end
    searchResultTabs:SetCallback("OnGroupSelected", SelectTabGroup)
    if _selected == 0 then
        local selectedType = lastOpenSearch
        if not resultCounts[selectedType] or resultCounts[selectedType] == 0 then
            selectedType = "quest"
            if resultCounts[selectedType] == 0 then
                for resultType in pairs(resultTypes) do
                    if resultCounts[resultType] > 0 then
                        selectedType = resultType
                        break
                    end
                end
            end
        end
        searchResultTabs:SelectTab(selectedType)
    end
end

-- The "Advanced Search" tab
local typeDropdown
local searchBox
local searchGroup
function QuestieSearchResults:DrawSearchTab(container)
    AddModernDivider(container, l10n("Enter in your Search"))

    searchBox = QuestieGUI:Create("EditBox");
    searchGroup = QuestieGUI:Create("SimpleGroup");

    searchBox:SetRelativeWidth(0.35);
    local searchPlaceholder = l10n("Advanced Search") .. " (" .. l10n("Quests") .. ", " .. l10n("NPCs") .. ", " .. l10n("Objects") .. ", " .. l10n("Items") .. ")"
    ApplyModernSearchBox(searchBox, searchPlaceholder);
    local performSearch = _GetSearchFunction(searchBox, searchGroup)
    searchBox:SetCallback("OnTextChanged", function()
        if programmaticSearchUpdate then
            return
        end
        local searchText = searchBox:GetText()
        if programmaticSearchText then
            if searchText == programmaticSearchText then
                programmaticSearchText = nil
                return
            end
            programmaticSearchText = nil
        end
        searchInteractionGeneration = searchInteractionGeneration + 1
        searchDebounceGeneration = searchDebounceGeneration + 1
        local currentDebounceGeneration = searchDebounceGeneration
        if searchText == "" then
            activeResultTree = nil
            searchGroup:ReleaseChildren()
            if searchResultTabs then
                searchResultTabs.modernHoverLocked = false
                searchResultTabs.modernPinnedValue = nil
            end
            searchResultTabs = nil
            searchResultHost = nil
        else
            local function RunSearch()
                if currentDebounceGeneration == searchDebounceGeneration
                    and searchBox:GetText() == searchText then
                    performSearch(true)
                end
            end
            if C_Timer and C_Timer.After then
                C_Timer.After(0.15, RunSearch)
            else
                RunSearch()
            end
        end
    end);
    searchBox:SetCallback("OnEnterPressed", function(...)
        searchDebounceGeneration = searchDebounceGeneration + 1
        performSearch(...)
    end);
    container:AddChild(searchBox);

    searchGroup:SetFullHeight(true);
    searchGroup:SetFullWidth(true);
    searchGroup:SetLayout("fill");
    container:AddChild(searchGroup);
    -- Check for existence of previous search, if present use its result
    if QuestieSearch.LastResult.query ~= "" then
        local query = QuestieSearch.LastResult.query
        searchBox:SetText(query)
        local text = string.trim(searchBox:GetText(), " \n\r\t[]")
        QuestieSearchResults:DrawSearchResultTab(searchGroup, tonumber(text) and BY_ID or BY_NAME, text, true)
    end
    searchBox:SetFocus();
end

function QuestieSearchResults:SetSearch(detailType, id, selectResult)
    searchInteractionGeneration = searchInteractionGeneration + 1
    _selected = selectResult == false and 0 or id
    programmaticSearchText = tostring(id)
    programmaticSearchUpdate = true
    searchBox:SetText(tostring(id))
    programmaticSearchUpdate = false
    -- The linked navigation below is already doing the authoritative redraw,
    -- so cancel any previously scheduled live-search pass.
    searchDebounceGeneration = searchDebounceGeneration + 1
    QuestieSearchResults:DrawSearchResultTab(searchGroup, BY_ID, id, false)
    searchResultTabs:SelectTab(detailType)
end

---Open a search result's detail pane as if the result row had been clicked.
---@param detailType string
---@param id number
function QuestieSearchResults:OpenDetails(detailType, id)
    -- A link opened from an existing Advanced Search result should replace
    -- only the detail pane. Rebuilding the search group here destroys the
    -- outer TabGroup, which is why the result tabs used to disappear.
    if searchResultTabs and activeResultTree then
        searchResultTabs:SelectTab(detailType)
        if activeResultTree then
            clickHandledResultValue = nil
            activeResultTree:SelectByValue(id)
            return
        end
    end

    -- Rebuild the result tabs without selecting during the intermediate
    -- teardown/recreate cycle. The deferred selection below is the only
    -- selection performed for linked navigation.
    self:SetSearch(detailType, id, false)
    local requestGeneration = searchInteractionGeneration
    local requestTree = activeResultTree

    local selectResult = function()
        if requestGeneration == searchInteractionGeneration
            and activeResultTree == requestTree
            and lastOpenSearch == detailType then
            -- SetSearch can rebuild the result tree twice while the search box
            -- callback is settling. Select on the final tree so its selected
            -- row and details pane are updated together, just like a click.
            activeResultTree:SelectByValue(id)
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0, selectResult)
    else
        selectResult()
    end
end
