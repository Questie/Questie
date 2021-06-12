--- COMPATIBILITY ---
local GetNumQuestLogEntries = GetNumQuestLogEntries or C_QuestLog.GetNumQuestLogEntries

---@class QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private
local _Tracker = {}
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieArrow
local QuestieArrow = QuestieLoader:ImportModule("QuestieArrow")

local LibDropDown = LibStub:GetLibrary("LibUIDropDownMenuQuestie-4.0")

local LSM30 = LibStub("LibSharedMedia-3.0", true)

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local QuestieTSP = QuestieLoader:ImportModule("QuestieTSP")
local menuFrame = LibDropDown:Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

function QuestieTracker:Initialize()

end

function QuestieTracker:ResetLinesForChange()

end

function QuestieTracker:Update()

end

function QuestieTracker:RemoveQuest()

end


function QuestieTracker:Unhook()
    if (not QuestieTracker._alreadyHooked) then
        return
    end

    QuestieTracker._disableHooks = true
    if QuestieTracker._IsQuestWatched then
        IsQuestWatched = QuestieTracker._IsQuestWatched
        GetNumQuestWatches = QuestieTracker._GetNumQuestWatches
    end
    _QuestieTracker._alreadyHooked = nil
    QuestWatchFrame:Show()
end

function QuestieTracker:HookBaseTracker()
    if _QuestieTracker._alreadyHooked then
        return
    end
    QuestieTracker._disableHooks = nil

    if not QuestieTracker._alreadyHookedSecure then

        local _RemoveQuestWatch = function(index, isQuestie)
            Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: RemoveQuestWatch")
            if QuestieTracker._disableHooks then
                return
            end
        
            if not isQuestie then
                local qid = select(8,GetQuestLogTitle(index))
                if qid then
                    if "0" == GetCVar("autoQuestWatch") then
                        Questie.db.char.TrackedQuests[qid] = nil
                    else
                        Questie.db.char.AutoUntrackedQuests[qid] = true
                    end
                    --QuestieCombatQueue:Queue(function()
                    --    QuestieTracker:ResetLinesForChange()
                    --    QuestieTracker:Update()
                    --end)
                end
            end
        end
        
        local _AQW_Insert = function(index, expire)
            Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: AQW_Insert")
            if QuestieTracker._disableHooks then
                return
            end
        
            local now = GetTime()
            if index and index == QuestieTracker._last_aqw and (now - lastAQW) < 0.1 then return end -- this fixes double calling due to AQW+AQW_Insert (QuestGuru fix)
        
            lastAQW = now
            QuestieTracker._last_aqw = index
            RemoveQuestWatch(index, true) -- prevent hitting 5 quest watch limit
        
            local qid = select(8,GetQuestLogTitle(index))
            if qid then
                if "0" == GetCVar("autoQuestWatch") then
                    if Questie.db.char.TrackedQuests[qid] then
                        Questie.db.char.TrackedQuests[qid] = nil
                    else
                        Questie.db.char.TrackedQuests[qid] = true
                    end
                else
                    if Questie.db.char.AutoUntrackedQuests[qid] then
                        Questie.db.char.AutoUntrackedQuests[qid] = nil
                    elseif IsShiftKeyDown() and (QuestLogFrame:IsShown() or (QuestLogExFrame and QuestLogExFrame:IsShown())) then--hack
                        Questie.db.char.AutoUntrackedQuests[qid] = true
                    end
                end
        
                -- Make sure quests or zones (re)added to the tracker isn't in a minimized state
                local quest = QuestieDB:GetQuest(qid)
                if Questie.db.char.collapsedQuests[qid] == true then
                    Questie.db.char.collapsedQuests[qid] = nil
                end
                if quest then
                    local zoneId = quest.zoneOrSort
            
                    if Questie.db.char.collapsedZones[zoneId] == true then
                        Questie.db.char.collapsedZones[zoneId] = nil
                    end
                end
                --QuestieCombatQueue:Queue(function()
                --    QuestieTracker:ResetLinesForChange()
                --    QuestieTracker:Update()
                --end)
            end
        end

        hooksecurefunc("AutoQuestWatch_Insert", _AQW_Insert)
        hooksecurefunc("AddQuestWatch", _AQW_Insert)
        hooksecurefunc("RemoveQuestWatch", _RemoveQuestWatch)

        -- completed/objectiveless tracking fix
        -- blizzard quest tracker

        local baseQLTB_OnClick = QuestLogTitleButton_OnClick
        QuestLogTitleButton_OnClick = function(self, button) -- I wanted to use hooksecurefunc but this needs to be a pre-hook to work properly unfortunately
            if (not self) or self.isHeader or not IsShiftKeyDown() then baseQLTB_OnClick(self, button) return end
            local questLogLineIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
            local questId = GetQuestIDFromLogIndex(questLogLineIndex)

            if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
                if (self.isHeader) then
                    return
                end
                ChatEdit_InsertLink("["..gsub(self:GetText(), " *(.*)", "%1").." ("..questId..")]")

            else
                if GetNumQuestLeaderBoards(questLogLineIndex) == 0 and not IsQuestWatched(questLogLineIndex) then -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
                    _AQW_Insert(questLogLineIndex, QUEST_WATCH_NO_EXPIRE)
                    QuestWatch_Update()
                    QuestLog_SetSelection(questLogLineIndex)
                    QuestLog_Update()
                else
                    baseQLTB_OnClick(self, button)
                end
            end
        end
        -- other addons

        -- totally prevent the blizzard tracker frame from showing (BAD CODE, shouldn't be needed but some have had trouble)
        QuestWatchFrame:HookScript("OnShow", function(self) if QuestieTracker._disableHooks then return end self:Hide() end)
        QuestieTracker._alreadyHookedSecure = true
    end

    if not QuestieTracker._IsQuestWatched then
        QuestieTracker._IsQuestWatched = IsQuestWatched
        QuestieTracker._GetNumQuestWatches = GetNumQuestWatches
    end

    -- this is probably bad
    IsQuestWatched = function(index)
        if "0" == GetCVar("autoQuestWatch") then
            return Questie.db.char.TrackedQuests[select(8,GetQuestLogTitle(index)) or -1]
        else
            local qid = select(8,GetQuestLogTitle(index))
            return qid and QuestiePlayer.currentQuestlog[qid] and not Questie.db.char.AutoUntrackedQuests[qid]
        end
    end

    GetNumQuestWatches = function()
        return 0
    end

    QuestWatchFrame:Hide()
    QuestieTracker._alreadyHooked = true
end

-- get or create indexes in a table / child tables
local function getOrCreate(table, ...)
    local val = table
    for _, key in pairs({...}) do
        if not val[key] then
            val[key] = {}
        end
        val = val[key]
    end
    return val
end

local function newTracker(tracker)

    -- todo: config
    local LINE_HEIGHT_BASE = 8
    local QUEST_SPACING = 14
    local QUESTIE_ICON_SIZE = 12
    local BUTTON_SIZE_BASE = 20
    local BACKGROUND_PADDING = 18
    local INNER_BACKGROUND_PADDING = 32
    local TRACKER_INNER_PADDING_WIDTH = 4
    local QUEST_TITLE_PADDING = 5
    local TRACKER_WIDTH = 180

    local TRACKER_BORDER_BRIGHTNESS = 0.7
    

    if (not Questie.db.char.TrackerHiddenQuests) then
        Questie.db.char.TrackerHiddenQuests = {}
    end
    
    if (not Questie.db.char.TrackerHiddenObjectives) then
        Questie.db.char.TrackerHiddenObjectives = {}
    end

    if (not Questie.db.char.TrackedQuests) then
        Questie.db.char.TrackedQuests = {}
    end

    if (not Questie.db.char.AutoUntrackedQuests) then
        Questie.db.char.AutoUntrackedQuests = {}
    end
    
    if (not Questie.db.char.collapsedZones) then
        Questie.db.char.collapsedZones = {}
    end

    if (not Questie.db.char.collapsedQuests) then
        Questie.db.char.collapsedQuests = {}
    end



    local BUTTON_SIZE = BUTTON_SIZE_BASE
    local LINE_HEIGHT = LINE_HEIGHT_BASE

    local startDragAnchor, preSetPoint, startDragPos = nil, nil, nil
    
    local function OnDragStart(self, force)
        if (IsMouseButtonDown("LeftButton") and (true or IsModifierKeyDown() or (force==true))) and not tracker.dragging then
            tracker.dragging = true
            --print("ODStart")
            startDragAnchor = {tracker.frame.background:GetPoint()}
            preSetPoint = ({tracker.frame.background:GetPoint()})[1]
            tracker.frame.background:SetClampedToScreen(tracker.frame.background)
            tracker.frame.background:StartMoving()

            startDragPos = {tracker.frame.background:GetPoint()}
        end
    end

    local function OnDragStop(self, button)
        --print("ODEnd")
        if tracker.dragging then
            endDragPos = {tracker.frame.background:GetPoint()}
            tracker.frame.background:StopMovingOrSizing()

            local xMoved = endDragPos[4] - startDragPos[4]
            local yMoved = endDragPos[5] - startDragPos[5]

            if xMoved == 0 and yMoved == 0 then
                local clicked = self:HasScript("OnClick") and self:GetScript("OnClick")
                if clicked then
                    clicked(self, button)
                end
            else
                tracker.x = tracker.x + xMoved / tracker.scale
                tracker.y = tracker.y - yMoved / tracker.scale
            end
            --print("Finished dragging")
            tracker.dragging = false
            Questie.db.char.tracker_x = tracker.x
            Questie.db.char.tracker_y = tracker.y
            tracker:Update(true)
        end
    end

    local function OnLeave(self)
        tracker.hovered = false
        --print("hovered=false")
        tracker.frame.texture:SetVertexColor(1,1,1,0)
        C_Timer.After(0.1, function()
            if not tracker.hovered then
                for _, v in pairs(tracker.hovers) do
                    v:Hide()
                end
            end
        end)
    end

    local function OnEnter(self)
        tracker.hovered = true
        --print("hovered=true")
        tracker.frame.texture:SetVertexColor(1,1,1,0.3)
        for _, v in pairs(tracker.hovers) do
            v:Show()
        end
        --GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        --GameTooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1)
        --GameTooltip:AddLine(text, 1,1,1)
        --GameTooltip:Show()
    end

    local function newLine()
        local line = CreateFrame("Button")
        line.label = line:CreateFontString(line, "ARTWORK", "GameFontNormal")
        line.label:SetJustifyH("LEFT")
        line.label:SetPoint("TOPLEFT", line)
        line.SetText = function(self, text)
            self.label:SetText(text)
        end
        line.componentType = "lines"
        return line
    end
    
    local function newCheckbox()
        --local line = newLine()
        local button = CreateFrame("CheckButton", nil, nil, "ChatConfigCheckButtonTemplate")
        button.componentType = "checkboxes"
    
        button.onEnter = button:GetScript("OnEnter")
        button.onLeave = button:GetScript("OnLeave")

        button:HookScript("OnMouseDown", OnDragStart)
        button:HookScript("OnMouseUp", OnDragStop)
    
        return button
    end
    
    local function newItemButton()
        local button = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate, ActionButtonTemplate")
        button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.range = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
        button.count = button:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
        button:SetAttribute("type1", "item")
        button:SetAttribute("type2", "stop")
    

        button:HookScript("OnEnter", OnEnter)
        button:HookScript("OnLeave", OnLeave)
    
        button.Update = function(self)
            if not self.itemID or not self:IsVisible() then
                return
            end
    
            local start, duration, enabled = GetItemCooldown(self.itemID)
    
            if enabled and duration > 3 and enabled == 1 then
                self.cooldown:Show()
                self.cooldown:SetCooldown(start, duration)
            else
                self.cooldown:Hide()
            end
        end
    
        button.SetItem = function(self, itemId, size)
            local validTexture = nil
            local isFound = false
    
            for bag = 0 , 5 do
                for slot = 0 , 36 do
                    local texture, count, locked, quality, readable, lootable, link, filtered, noValue, itemID = GetContainerItemInfo(bag, slot)
                    itemID = tonumber(itemID)
                    if itemId == itemID then
                        validTexture = texture
                        isFound = true
                        break
                    end
                end
                if isFound then
                    break
                end
            end
    
            -- Edge case to find "equipped" quest items since they will no longer be in the players bag
            if not isFound then
                for i = 13, 18 do
                    local itemID = GetInventoryItemID("player", i)
                    local texture = GetInventoryItemTexture("player", i)
                    itemID = tonumber(itemID)
                    if itemId == itemID then
                        validTexture = texture
                        isFound = true
                        break
                    end
                end
            end
    
            --print("Found tex " .. validTexture)
    
            if validTexture and isFound then -- todo
                self.itemID = itemId
                --self.questID = quest.Id
                self.charges = GetItemCount(self.itemID, nil, true)
                self.rangeTimer = -1
    
                self:SetAttribute("item", "item:" .. tostring(self.itemID))
                self:SetNormalTexture(validTexture)
                self:SetPushedTexture(validTexture)
                self.NormalTexture:SetAllPoints(self)
                --self.PushedTexture:SetAllPoints(self)
    
                self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                self:SetSize(size, size)
    
                self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
                --self:HookScript("OnClick", self.OnClick)
                
                self:SetScript("OnShow", function()
                    self:RegisterEvent("PLAYER_TARGET_CHANGED")
                    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
                end)
        
                self:SetScript("OnHide", function()
                    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
                    self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
                end)
    
                self:SetScript("OnEvent", function(self, event)
                    if (event == "PLAYER_TARGET_CHANGED") then
                        self.rangeTimer = -1
                        self.range:Hide()
                    elseif (event == "BAG_UPDATE_COOLDOWN") then
                        self:Update()
                    end
                end)
    
                self:SetScript("OnUpdate", function(self, elapsed)
                    if not self.itemID or not self:IsVisible() then
                        return
                    end
        
                    local valid = nil
                    local rangeTimer = self.rangeTimer
                    local charges = GetItemCount(self.itemID, nil, true)
        
                    if (not charges or charges ~= self.charges) then
                        self.count:Hide()
                        self.charges = GetItemCount(self.itemID, nil, true)
                        if self.charges > 1 then
                            self.count:SetText(self.charges)
                            self.count:Show()
                        end
                    end
        
                    if UnitExists("target") then
                        if not self.itemName then
                            self.itemName = GetItemInfo(self.itemID)
                        end
        
                        if (rangeTimer) then
                            rangeTimer = rangeTimer - elapsed
        
                            if (rangeTimer <= 0) then
        
                                valid = IsItemInRange(self.itemName, "target")
        
                                if valid == false then
                                    self.range:SetVertexColor(1.0, 0.1, 0.1)
                                    self.range:Show()
        
                                elseif valid == true then
                                    self.range:SetVertexColor(0.6, 0.6, 0.6)
                                    self.range:Show()
                                end
        
                                rangeTimer = 0.3
                            end
        
                            self.rangeTimer = rangeTimer
                        end
                    end
                end)
                --self:SetScript("OnShow", self.OnShow)
                --self:SetScript("OnHide", self.OnHide)
                --self:SetScript("OnEnter", self.OnEnter)
                --self:SetScript("OnLeave", self.OnLeave)
    
                -- Cooldown Updates
                self.cooldown:SetSize(size-4, size-4)
                self.cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
                self.cooldown:Hide()
    
                -- Range Updates
                self.range:SetText("●")
                self.range:SetPoint("TOPRIGHT", self, "TOPRIGHT", 3, 0)
                self.range:Hide()
    
                -- Charges Updates
                self.count:Hide()
                self.count:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontSizeObjective), 0.40)
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                self.count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 3)
    
                self:Update()
    
                return true
            else
                self:Hide()
            end
    
            return false
        end
    
        button.componentType = "buttons"
        return button
    end

    local function newResizeButton()
        local resizeButton = CreateFrame("Button", nil, tracker.frame.background)
        resizeButton.texture = resizeButton:CreateTexture(nil, "BACKGROUND", nil, 0)
        resizeButton.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        resizeButton:SetWidth(QUESTIE_ICON_SIZE)
        resizeButton:SetHeight(QUESTIE_ICON_SIZE)
        resizeButton:SetFrameStrata("LOW")

        resizeButton.texture:SetAllPoints(resizeButton)

        resizeButton:EnableMouse(true)
        resizeButton:SetScript("OnMouseDown", function()
            if not tracker.dragging then
                tracker.resizeStart = {tracker.frame.background:GetWidth(), tracker.frame.background:GetHeight()}
                tracker.frame.background:StartSizing()
                tracker.dragging = true
            end
        end)
        resizeButton:SetScript("OnMouseUp", function()
            if tracker.dragging and tracker.resizeStart then
                tracker.frame.background:StopMovingOrSizing()
                local addW = tracker.frame.background:GetWidth() - tracker.resizeStart[1] 
                local addH = tracker.frame.background:GetHeight() - tracker.resizeStart[2]
                --print(tostring(tracker.frame:GetHeight()).. " " .. tostring(tracker.frame.scrollParent:GetHeight()))

                tracker.width = tracker.width + addW / tracker.scale
                tracker.heightConstraint = tracker.heightConstraint + addH

                if tracker.width < 64 then
                    tracker.width = 64
                end

                if tracker.heightConstraint < 64 then
                    tracker.heightConstraint = 64
                end

                Questie.db.char.tracker_w = tracker.width
                Questie.db.char.tracker_h = tracker.heightConstraint
            
                tracker.dragging = false
                tracker.resizeStart = nil
                tracker:Update(true)
            end
        end)

        resizeButton:SetScript("OnEnter", function(self)
            resizeButton.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
            OnEnter(self)
        end)
        resizeButton:SetScript("OnLeave", function(self)
            resizeButton.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
            OnLeave(self)
        end)
        

        return resizeButton

        --<NormalTexture file="Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up"/>
        --<HighlightTexture file="Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight"/>
        --<PushedTexture file="Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down"/>
    end

    local function newQuestieButton()
        local questieIcon = CreateFrame("Button", nil, tracker.frame.background)

        questieIcon:SetWidth(QUESTIE_ICON_SIZE)
        questieIcon:SetHeight(QUESTIE_ICON_SIZE)
        questieIcon:SetFrameStrata("LOW")
        -- Questie Icon Texture Settings
        questieIcon.texture = questieIcon:CreateTexture(nil, "BACKGROUND", nil, 0)
        questieIcon.texture:SetTexture(ICON_TYPE_COMPLETE)

        --<NormalTexture file="Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up"/>
        --<HighlightTexture file="Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight"/>
        --<PushedTexture file="Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down"/>


        questieIcon.texture:SetAllPoints(questieIcon)

        questieIcon:EnableMouse(true)
        questieIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        questieIcon:SetScript("OnClick", function (self, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    Questie.db.char.enabled = (not Questie.db.char.enabled)
                    QuestieQuest:ToggleNotes(Questie.db.char.enabled)

                    -- Close config window if it's open to avoid desyncing the Checkbox
                    QuestieOptions:HideFrame()

                    return

                elseif IsControlKeyDown() then
                    QuestieQuest:SmoothReset()

                    return
                end

                if InCombatLockdown() then
                    QuestieOptions:HideFrame()
                else
                    QuestieOptions:OpenConfigWindow()
                end

                if QuestieJourney:IsShown() then
                    QuestieJourney.ToggleJourneyWindow()
                end

                return

            elseif button == "RightButton" then
                if not IsModifierKeyDown() then

                    -- Close config window if it's open to avoid desyncing the Checkbox
                    QuestieOptions:HideFrame()

                    QuestieJourney.ToggleJourneyWindow()

                    return

                elseif IsControlKeyDown() then
                    Questie.db.profile.minimap.hide = true;
                    Questie.minimapConfigIcon:Hide("Questie")

                    return
                end
            end
        end)

        questieIcon:SetScript("OnEnter", function (self)
            GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            GameTooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1)
            GameTooltip:AddLine(Questie:Colorize(l10n("Left Click"), "gray") .. ": " .. l10n("Toggle Options"))
            GameTooltip:AddLine(Questie:Colorize(l10n("Right Click"), "gray") .. ": " .. l10n("Toggle My Journey"))
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(Questie:Colorize(l10n("Left Click + Hold"), "gray") .. ": " .. l10n("Drag while Unlocked"))
            GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Left Click + Hold"), "gray") .. ": " .. l10n("Drag while Locked"))
            GameTooltip:Show()
            OnEnter()
        end)

        questieIcon:SetScript("OnLeave", function (self)
            if GameTooltip:IsShown() then
                GameTooltip:Hide()
            end
            OnLeave()
        end)
        return questieIcon
    end

    local function newTrackerFrame()
        --CreateFrame("ScrollFrame", "ANewScrollFrame", self, "UIPanelScrollFrameTemplate");


        local backgroundFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

        local scrollParent = CreateFrame("Frame", nil, backgroundFrame)

        backgroundFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0,0)
        backgroundFrame:SetSize(TRACKER_WIDTH, TRACKER_WIDTH*2)

        scrollParent:SetPoint("TOPLEFT", backgroundFrame, "TOPLEFT", TRACKER_INNER_PADDING_WIDTH,-INNER_BACKGROUND_PADDING)
        scrollParent:SetSize(TRACKER_WIDTH, TRACKER_WIDTH*2)


        scrollParent.scroll = CreateFrame("ScrollFrame", nil, scrollParent, "UIPanelScrollFrameTemplate")
        scrollParent:SetFrameStrata(BACKGROUND)
        scrollParent:SetFrameLevel(0)

        backgroundFrame:SetFrameStrata(BACKGROUND)
        backgroundFrame:SetFrameLevel(0)


        __sf = scrollParent

        scrollParent:EnableMouse(true)
        scrollParent:SetMovable(true)
        scrollParent:SetScript("OnMouseDown", OnDragStart)
        scrollParent:SetScript("OnMouseUp", OnDragStop)
        scrollParent:SetScript("OnEnter", OnEnter)
        scrollParent:SetScript("OnLeave", OnLeave)

        backgroundFrame:EnableMouse(true)
        backgroundFrame:SetMovable(true)
        backgroundFrame:SetResizable(true)
        backgroundFrame:SetScript("OnMouseDown", OnDragStart)
        backgroundFrame:SetScript("OnMouseUp", OnDragStop)
        backgroundFrame:SetScript("OnEnter", OnEnter)
        backgroundFrame:SetScript("OnLeave", OnLeave)

        local scrollFunction = scrollParent.scroll:GetScript("OnMouseWheel")

        backgroundFrame:SetScript("OnMouseWheel", function(self, ...)
            scrollFunction(scrollParent.scroll, ...)
            tracker:Update(true)
        end)

        scrollParent.scroll:HookScript("OnMouseWheel", function()
            tracker:Update(true)
        end)
 
        scrollParent.scroll.ScrollBar.ScrollUpButton:ClearAllPoints();
        scrollParent.scroll.ScrollBar.ScrollUpButton:SetPoint("TOPRIGHT", scrollParent, "TOPRIGHT", -6, -8);
         
        scrollParent.scroll.ScrollBar.ScrollDownButton:ClearAllPoints();
        scrollParent.scroll.ScrollBar.ScrollDownButton:SetPoint("BOTTOMRIGHT", scrollParent, "BOTTOMRIGHT", -6, 6);
        
        scrollParent.scroll.ScrollBar:ClearAllPoints();
        scrollParent.scroll.ScrollBar:SetPoint("TOP", scrollParent.scroll.ScrollBar.ScrollUpButton, "BOTTOM", 0, -2);
        scrollParent.scroll.ScrollBar:SetPoint("BOTTOM", scrollParent.scroll.ScrollBar.ScrollDownButton, "TOP", 0, 2);


        local frm = CreateFrame("Frame", nil, UIParent)

        __fr = frm
    
        frm:SetWidth(300)
        frm:SetHeight(300)
    
        frm.texture = frm:CreateTexture(frm, "BACKGROUND")
    
        frm.texture:SetTexture(QuestieLoader:ImportModule("QuestieLib").AddonPath.."Icons\\black.blp")
        frm.texture:SetVertexColor(1,1,1,0.0)
        frm.texture:SetAllPoints(frm)
    
        frm.controls = {}
        frm.controls.settings = nil
        frm.controls.socialToggle = nil
        frm.controls.header = nil
        frm.controls.headerButton = nil
    
        frm:EnableMouse(true)
        frm:SetMovable(true)
        frm:SetScript("OnMouseDown", OnDragStart)
        frm:SetScript("OnMouseUp", OnDragStop)
        frm:SetScript("OnEnter", OnEnter)
        frm:SetScript("OnLeave", OnLeave)

        frm:SetFrameStrata(BACKGROUND)
        frm:SetFrameLevel(0)

        frm:SetScale(1)

        backgroundFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }})
                                            backgroundFrame:SetBackdropColor(0,0,0,0)
                                            backgroundFrame:SetBackdropBorderColor(TRACKER_BORDER_BRIGHTNESS,TRACKER_BORDER_BRIGHTNESS,TRACKER_BORDER_BRIGHTNESS,0)
        frm.texture:SetVertexColor(0,0,0,0)

        local setVertexColor = frm.texture.SetVertexColor

        -- todo: refactor
        frm.texture.SetVertexColor = function(self, r, g, b, a)
            --setVertexColor(self, r, g, b, a)
            if a > 0 then
                backgroundFrame:SetBackdropBorderColor(TRACKER_BORDER_BRIGHTNESS,TRACKER_BORDER_BRIGHTNESS,TRACKER_BORDER_BRIGHTNESS,1)

                if tracker.frame:GetHeight() > scrollParent:GetHeight() then
                    scrollParent.scroll.ScrollBar.ScrollUpButton:Show()
                    scrollParent.scroll.ScrollBar.ScrollDownButton:Show()
                    scrollParent.scroll.ScrollBar:Show()
                end
                tracker.resizeButton:Show()
            else
                backgroundFrame:SetBackdropBorderColor(TRACKER_BORDER_BRIGHTNESS,TRACKER_BORDER_BRIGHTNESS,TRACKER_BORDER_BRIGHTNESS,0)
                scrollParent.scroll.ScrollBar:Hide()
                tracker.resizeButton:Hide()
            end
            backgroundFrame:SetBackdropColor(0,0,0,a)
            --setVertexColor(self,0,0,0,a)
        end
        
        scrollParent.scroll:SetScrollChild(frm)
 
        -- set self.scrollframe points to the first frame that you created (in this case, self)
        scrollParent.scroll:SetAllPoints(scrollParent)
        --frm:Show()
        --frm.texture:Show()
        __frm = frm
        scrollParent:Show()
        backgroundFrame:Show()

        frm.scrollParent = scrollParent
        frm.background = backgroundFrame
    
        return frm
    end

    -- get or create a line of text
    local function getNextLine()
        local line = tremove(tracker.lines) or newLine()
        tinsert(tracker.components, line)
        return line
    end

    -- get or create an item button
    local function getNextButton()
        local button = tremove(tracker.buttons) or newItemButton()
        tinsert(tracker.components, button)
        return button
    end

    -- get or creaqte a checkbox
    local function getNextCheckbox()
        local button = tremove(tracker.checkboxes) or newCheckbox()
        tinsert(tracker.components, button)
        return button
    end

    local function addY(amount)
        tracker.renderYPrevious = tracker.renderY
        tracker.renderY = tracker.renderY + amount
    end

    local function renderCheckbox(data, checked, onClick, fadeOnHover)
        tinsert(data, function()
            local check = getNextCheckbox()
            check:SetChecked(checked)
            check:ClearAllPoints()
            --check:SetParent(tracker.frame)
            --check:SetPoint("TOPLEFT", tracker.frame, "TOPLEFT", (0) + BACKGROUND_PADDING, -(tracker.renderY + BACKGROUND_PADDING - 6))
            check:SetParent(tracker.frame.background)
            check:SetPoint("TOPLEFT", tracker.frame.background, "BOTTOMLEFT", BACKGROUND_PADDING-check:GetWidth()/3, BACKGROUND_PADDING/2+INNER_BACKGROUND_PADDING/2+check:GetHeight()/4)


            check:SetScript("OnEnter", function(self)
                self:onEnter()
                OnEnter(self)
            end)
            check:SetScript("OnLeave", function(self)
                self:onLeave()
                OnLeave(self)
            end)
            check:SetScript("OnClick", onClick)

            if not fadeOnHover or tracker.hovered then 
                check:Show()
            else
                check:Hide()
            end
            if fadeOnHover then
                tinsert(tracker.hovers, check)
            end
        end)
    end

    local function renderLine(data, text, scale, inset, textEnd, onClick, fadeOnHover, parentingFunction)
        tinsert(data, function()
            
            if type(text) == "function" then
                text = text()
            end

            local line = getNextLine()
            line.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT, LINE_HEIGHT * scale)
            line.label:SetHeight(LINE_HEIGHT * scale)
            line.label:SetWidth(tracker.width * tracker.scale - (inset or 0))
            line:SetHeight(LINE_HEIGHT * scale)
            
            if textEnd then -- textEnd must always be readable, truncate end of "text" instead
                line:SetText(text..textEnd)
                local len = string.len(text)
                local lenStart = len
                while line.label:GetUnboundedStringWidth() > line.label:GetStringWidth() and len > 1 do -- there has to be a more efficient way to do this
                    len = len - 1
                    line:SetText(string.sub(text,1,len).."..."..textEnd)--/dump string.sub("test", 1,3)
                end
                if lenStart ~= len then
                    text = string.sub(text,1,len).."..."..textEnd
                else
                    text = text .. textEnd
                end
            end

            line:SetText(text)

            line:SetScale(1)
            --line:SetScale(scale)
            --print("Rendering line " .. text)
            line:ClearAllPoints()
            if parentingFunction then
                parentingFunction(line)
            else
                line:SetParent(tracker.frame)
                line:SetPoint("TOPLEFT", tracker.frame, "TOPLEFT", (inset or 0) + BACKGROUND_PADDING + tracker.renderX, -(tracker.renderY + BACKGROUND_PADDING))--:SetPoint("TOPLEFT", UIParent, tracker.x, tracker.y)
            end
            --print("renline " .. tostring(tracker.x + (inset or 0)))
            __LGP = {line:GetPoint()}
            line:SetWidth(tracker.width - (inset or 0))--(line.label:GetWidth())
            line:SetFrameStrata("LOW")
            line:SetFrameLevel(0)
            

            line:EnableMouse(true)
            line:SetScript("OnEnter", OnEnter)
            line:SetScript("OnLeave", OnLeave)

            if not onClick then
                onClick = function() print("Null Onclick") end -- empty script to replace existing one from recycling
            end

            line:SetScript("OnClick", onClick)

            --line:RegisterForDrag("LeftButton")
            line:RegisterForClicks("RightButtonUp")

            line:SetMovable(true)
            line:SetScript("OnMouseDown", OnDragStart)
            line:SetScript("OnMouseUp", OnDragStop)

            if not fadeOnHover or tracker.hovered then 
                line:Show()
            else
                line:Hide()
            end

            if fadeOnHover then
                tinsert(tracker.hovers, line)
            end
            
            tracker.lastLineWidth = line.label:GetStringWidth()

            if not parentingFunction then
                addY((LINE_HEIGHT * scale))
            end
        end)
    end

    tracker.frame = newTrackerFrame()
    --tracker.header = newHeader(tracker.frame)
    tracker.questieButton = newQuestieButton()
    tracker.resizeButton = newResizeButton()
    tracker.lines = {}
    tracker.buttons = {}
    tracker.checkboxes = {}

    -- all tracker components are placed in this array for easy clearing on redraw
    tracker.components = {}

    tracker.renderData = {}
    tracker.x = Questie.db.char.tracker_x or BACKGROUND_PADDING * 2 -- todo: calculate this / load from savedvar
    tracker.y = Questie.db.char.tracker_y or BACKGROUND_PADDING * 2
    tracker.width = Questie.db.char.tracker_w or TRACKER_WIDTH
    tracker.height = 100 -- placeholder
    tracker.renderY = 0
    tracker.renderX = 0
    tracker.padX = 0
    tracker.padY = 0
    tracker.renderCount = 0
    tracker.renderYPrevious = 0
    tracker.heightConstraint = Questie.db.char.tracker_h or TRACKER_WIDTH*2
    tracker.hovers = {}

    tracker.frame.background:SetPoint("TOPLEFT", UIParent, "TOPLEFT", tracker.x, -tracker.y)

    -- reset all components in the tracker for redrawing
    tracker.Reset = function(self)
        local t = tremove(tracker.components)
        while t do
            if t.componentType == "buttons" then
                local button = t
                QuestieCombatQueue:Queue(function()
                    button:Hide()
                    tinsert(tracker[button.componentType], button) -- buttons or lines
                end)
            else
                t:Hide()
                tinsert(tracker[t.componentType], t)
            end
            t = tremove(tracker.components)
        end
    end

    tracker.FixPosition = function(self)
        if (tracker.x+tracker.width + BACKGROUND_PADDING+8+tracker.padX)*tracker.scale > GetScreenWidth() then
            tracker.x = (GetScreenWidth()/tracker.scale) - (tracker.width+BACKGROUND_PADDING+8+tracker.padX)
        elseif tracker.x < 24 then
            tracker.x = 24
        end

        if tracker.heightConstraint > tracker.frame.background:GetHeight() then
            tracker.heightConstraint = tracker.frame.background:GetHeight()
            if tracker.heightConstraint < 128 then
                tracker.heightConstraint = 128
            end
            -- hack: fix later
            C_Timer.After(0, function()
                tracker:Update(true)
            end)
        end

        --if (tracker.y + BACKGROUND_PADDING+16+26)*tracker.scale+tracker.height > GetScreenHeight() then
        --    tracker.y = (GetScreenHeight()/tracker.scale) - ((tracker.height/tracker.scale)+BACKGROUND_PADDING+16+26)
        --else
        if tracker.y < 24 then
            tracker.y = 24
        end
    end

    -- build data to be rendered. This is run when quest status changes
    tracker.Build = function(self) 

        tracker.questCount = 0
        tracker.renderY = 0
        tracker.renderX = ((tracker.x + (tracker.width/2))*tracker.scale > GetScreenWidth() / 2) and ((BUTTON_SIZE_BASE+QUEST_TITLE_PADDING+5)*tracker.scale) or 0


        -- todo: move this into its own file (DB?)
        local queryTable = {
            [1] = QuestieDB.QueryNPCSingle,
            [2] = QuestieDB.QueryObjectSingle,
            [3] = QuestieDB.QueryItemSingle
        }

        tracker.renderData = {} -- it is better for the garbage collector if we create a new table rather than clearing an existing one

        tinsert(tracker.renderData, function()
            tracker.questieButton:ClearAllPoints()
            tracker.questieButton:SetWidth(QUESTIE_ICON_SIZE*tracker.scale)
            tracker.questieButton:SetHeight(QUESTIE_ICON_SIZE*tracker.scale)
            tracker.questieButton:SetParent(tracker.frame.background)
            tracker.questieButton:SetPoint("TOPLEFT", tracker.frame.background, "TOPLEFT", BACKGROUND_PADDING / tracker.scale, -INNER_BACKGROUND_PADDING/2)
            tracker.questieButton:Show()

            tracker.resizeButton:ClearAllPoints()
            tracker.resizeButton:SetWidth(QUESTIE_ICON_SIZE*tracker.scale)
            tracker.resizeButton:SetHeight(QUESTIE_ICON_SIZE*tracker.scale)
            tracker.resizeButton:SetParent(tracker.frame.background)
            tracker.resizeButton:SetPoint("BOTTOMRIGHT", tracker.frame.background, "BOTTOMRIGHT", -3, 3)
            --tracker.resizeButton:Show()
        end)

        renderLine(tracker.renderData, Questie.TBC_BETA_BUILD_VERSION_SHORTHAND.."Questie Tracker", 1.5, (QUESTIE_ICON_SIZE*tracker.scale)-tracker.renderX, nil, function()
            tracker.shrink = not tracker.shrink
            tracker:Update(true)
        end, false, function(line)
            line:SetParent(tracker.frame.background)
            line:SetPoint("TOPLEFT", tracker.frame.background, "TOPLEFT", BACKGROUND_PADDING * 1.8, -INNER_BACKGROUND_PADDING/2)
            line:SetWidth(tracker.width*tracker.scale)
        end)

        tinsert(tracker.renderData, function()
            addY(-QUEST_SPACING)
        end)

        local quests = {}
        local you = UnitName("Player")
        for player, logData in pairs(QuestieTSP.logs[GetPlayerZoneFixed()] or {}) do
            if QuestieTSP.socialMode or player == you then
                for questId, objectives in pairs(logData) do

                    local questData = quests[questId] or (function() local t = {["objectives"] = {}} quests[questId] = t return t end)()

                    if true then--if not questData.itemButton then
                        local questItem = QuestieDB.QueryQuestSingle(questId, "sourceItemId") -- todo: or item you get from a mob that has a "use:"
                        if questItem == 0 then
                            questItem = nil
                        end

                        if questItem then
                            questData.itemButton = function()
                                --print("render item button stage 1")
                                local tx = tracker.x
                                local ty = tracker.y+(tracker.renderY-select(5, tracker.frame:GetPoint()))/tracker.scale
                                local llw = tracker.lastLineWidth

                                --print(tostring(ty) .. "    " .. tostring(tracker.height) .. "   " .. tostring(tracker.y))

                                if true then--if ty > tracker.y then
                                    --print("valid")
                                    QuestieCombatQueue:Queue(function()
                                        --print("render item button stage 2")
                                        
                                        local button = getNextButton()
                                        
                                        --button:SetWidth(32)
                                        --button:SetHeight(32)
                                        button:SetSize(BUTTON_SIZE,BUTTON_SIZE)
                                        button:SetWidth(BUTTON_SIZE)
                                        button:SetHeight(BUTTON_SIZE)
                                        
                                        if (tracker.x + (tracker.width/2))*tracker.scale > GetScreenWidth() / 2 then -- right side of the screen
                                            button:SetPoint("TOPLEFT", nil, "TOPLEFT", tx, -(ty + BUTTON_SIZE/2 - (LINE_HEIGHT * 1.1) + INNER_BACKGROUND_PADDING/tracker.scale))--("TOPLEFT", UIParent, tx - button:GetWidth(), -ty)
                                        else
                                            --button:SetPoint("TOPLEFT", nil, "TOPLEFT", tx + llw + (BUTTON_SIZE/2), -(ty - BUTTON_SIZE/2 - QUEST_TITLE_PADDING))--("TOPLEFT", UIParent, tx - button:GetWidth(), -ty)
                                            button:SetPoint("TOPLEFT", nil, "TOPLEFT", tx + tracker.width, -(ty + BUTTON_SIZE/2 - (LINE_HEIGHT * 1.1) + INNER_BACKGROUND_PADDING/tracker.scale))--("TOPLEFT", UIParent, tx - button:GetWidth(), -ty)
                                        end


                                        if button:SetItem(questItem, BUTTON_SIZE) then
                                            if ty > tracker.y then
                                                button:Show()
                                            else
                                                button:Hide()
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end

                    for _, objective in pairs(objectives) do
                        getOrCreate(questData.objectives, objective.type, objective.id)[player] = objective
                    end
                end
            end
        end
        
        -- todo: sorting here
        local renderQueue = {} -- for sorting
        if QuestieTSP.paths[GetPlayerZoneFixed()] and not tracker.shrink then
            for _, v in pairs(QuestieTSP.paths[GetPlayerZoneFixed()]) do
                local data = QuestieTSP.metadata[GetPlayerZoneFixed()][v]
                __DAT = data
                if data.spawn then
                    tracker.questCount = tracker.questCount + 1
                    local questId = data.spawn.questId
                    --print("build for id " .. tostring(questId))
                    local quest = QuestieDB:GetQuest(questId)
                    local click = function()
                        print("Clicked " .. tostring(questId))
                        EasyMenu(QuestieTracker.menu:GetMenuForQuest(quest), menuFrame, "cursor", 0 , 0, "MENU")
                    end
                    --local questData = quests[questId]

                    --___QD = questData

                    if true then
                        --print("[2]build for id " .. tostring(questId))
                        tinsert(getOrCreate(renderQueue, questId), function()
                            local playerList = nil
                            for _, p in pairs(data.spawn.players) do
                                if not playerList then
                                    playerList = p
                                else
                                    playerList = playerList .. ", " .. p
                                end
                            end
                            if playerList == you then
                                renderLine(tracker.renderData, "|cFFEEEEEE" .. name, 1, 20, ": " .. tostring(collected) .. "/" .. tostring(needed), click)
                            else
                                renderLine(tracker.renderData, "|cFFEEEEEE" .. name, 1, 20, ": " .. tostring(collected) .. "/" .. tostring(needed) .. " (" .. playerList .. ")", click)
                            end
                        end)
                    end
                end
            end
        end
        local first = true
        if QuestieTSP.paths[GetPlayerZoneFixed()] and not tracker.shrink then
            local duplicates = {} -- objectives are listed individually in .paths
            for _, v in pairs(QuestieTSP.paths[GetPlayerZoneFixed()]) do
                --print("[2.9]build for id " .. tostring(v))
                if QuestieTSP.metadata[GetPlayerZoneFixed()][v].spawn then
                    local questId = QuestieTSP.metadata[GetPlayerZoneFixed()][v].spawn.questId
                    --print("[3]build for id " .. tostring(questId))
                    local quest = QuestieDB:GetQuest(questId)
                    local click = function()
                        print("Clicked " .. tostring(questId))
                        EasyMenu(QuestieTracker.menu:GetMenuForQuest(quest), menuFrame, "cursor", 0 , 0, "MENU")
                    end
                    local data = quests[questId]
                    if data and not duplicates[questId] then
                        duplicates[questId] = true

                        local questName = QuestieLib:GetColoredQuestName(questId, true, true, true)

                        if first then
                            first = false
                            local x, y = QuestieTSP:IDToCoord(v)
                            QuestieArrow:SetWaypoint(x, y, GetPlayerZoneFixed())
                            if questName then
                                QuestieArrow:SetLabel(questName)
                            else
                                QuestieArrow:SetLabel("Error!")
                            end
                            
                            --if anchorArrowToTracker then
                            --    QuestieArrow:GetFrame():SetPoint("CENTER", tracker.frame.background, "TOPLEFT", (tracker.width * tracker.scale)/2, 50)
                            --end
                        end

                        --print("Getting " .. tostring(questId))
                        
                        renderLine(tracker.renderData, questName, 1.3, nil, nil, click)
                        if data.itemButton then
                            tinsert(tracker.renderData, data.itemButton)
                        end
                        tinsert(tracker.renderData, function()
                            addY(QUEST_TITLE_PADDING)
                        end)

                        local complete = true
                        for _, ids in pairs(data.objectives) do
                            for _, players in pairs(ids) do
                                for _, status in pairs(players) do
                                    if type(status) == "table" and status.collected ~= status.needed then
                                        complete = false
                                        break
                                    end
                                end
                                if not complete then break end
                            end
                            if not complete then break end
                        end

                        if complete then
                            local playerList = nil
                            for p, ids in pairs(QuestieTSP.logs[GetPlayerZoneFixed()]) do
                                if ids[questId] then
                                    if playerList then
                                        playerList = playerList .. ", " .. p
                                    else
                                        playerList = p
                                    end
                                end
                            end
                            renderLine(tracker.renderData, "|cFF22BB22Quest Complete!", 1, 20, " ("..playerList..")|r", click)
                        else

                            -- build ordered map
                            local _orderedPairs = {}
                            local orderedPairs = {}
                            local closest = 0
                            local match = nil

                            for type, ids in pairs(data.objectives) do
                                tinsert(_orderedPairs, {type, ids})
                            end
                            if false then
                            while #_orderedPairs > 0 do
                                closest = 99999999
                                match = nil
                                for i=1,#_orderedPairs do
                                    local objectiveData = _orderedPairs[i]
                                    for id, data in pairs(QuestieTSP.metadata[GetPlayerZoneFixed()]) do
                                        __DATA = data
                                        __ODATA = objectiveData
                                        __IIIQDDD = objectiveData[2][questId]

                                        if data.spawn and data.spawn.type == objectiveData[1] and data.spawn.objectiveId == objectiveData[2][questId] then

                                        end
                                        return
                                    end
                                    --return
                                end
                            end end

                            for _, data in pairs(_orderedPairs) do
                                local type, ids = data[1], data[2]
                            --for type, ids in pairs(data.objectives) do
                                --print(type)
                                local query = queryTable[tonumber(type)]
                                for id, players in pairs(ids) do

                                    local matchingNode = QuestieTSP.metadata[GetPlayerZoneFixed()][v]
                                    __MN = matchingNode

                                    local name = nil
                                    if type == 4 then
                                        local triggerEnd = QuestieDB.QueryQuestSingle(questId, "triggerEnd")
                                        if triggerEnd then
                                            name = triggerEnd[1] or "Event Trigger" -- objective text
                                        else
                                            name = "Event Trigger"
                                        end
                                    elseif query then
                                        name = query(id, "name")
                                    else
                                        name = tostring(type) .. "." .. tostring(id)
                                    end
            
                                    if type == 1 then
                                        if name == nil then
                                            print("NAME NIL!")
                                            ______DATA = data
                                        end
                                        name = name .. " Slain"
                                    end
            
                                    local progressMap = {}
                                    local needed = 0
                                    --local playerList = ""
                                    for player, status in pairs(players) do
                                        --playerList = " "..playerList .. player .. ":" .. tostring(status.collected) .. "/" .. tostring(status.needed)
                                        tinsert(getOrCreate(progressMap, tonumber(status.collected)), player)
                                        needed = status.needed -- todo: make this better
                                        
                                        local playerText = ""
                                        if player ~= UnitName("Player") then
                                            playerText = " (" .. player .. ")"
                                        end
            
                                        --renderLine(tracker.renderData, "|cFFEEEEEE" .. name, 1, 20, ": " .. tostring(status.collected) .. "/" .. tostring(status.needed) .. playerText, click)
                                    end

                                    for collected, players in pairs(progressMap) do
                                        local playerList = nil
                                        for _, p in pairs(players) do
                                            if not playerList then
                                                playerList = p
                                            else
                                                playerList = playerList .. ", " .. p
                                            end
                                        end
                                        if playerList == you then
                                            renderLine(tracker.renderData, "|cFFEEEEEE" .. name, 1, 20, ": " .. tostring(collected) .. "/" .. tostring(needed), click)
                                        else
                                            renderLine(tracker.renderData, "|cFFEEEEEE" .. name, 1, 20, ": " .. tostring(collected) .. "/" .. tostring(needed) .. " (" .. playerList .. ")", click)
                                        end
                                    end
                                    --renderLine(tracker.renderData, "|cFFEEEEEE    " ..name .. " =" .. playerList, 1)
                                end
                            end
                        end
                        tinsert(tracker.renderData, function()
                            addY(QUEST_SPACING)
                        end)
                    end
                end
            end
        end

        --print("finpop")

        if Questie and not tracker.shrink then 

            --tinsert(tracker.renderData, function()
            --    addY(QUEST_SPACING)
            --end)

            renderCheckbox(tracker.renderData, QuestieTSP.socialMode, function() QuestieTSP.socialMode = not QuestieTSP.socialMode tracker:Update() end, true)
            renderLine(tracker.renderData, "Social Mode", 1, 24 - tracker.renderX, nil, nil, true, function(line)
                line:SetParent(tracker.frame.background)
                line:SetPoint("BOTTOMLEFT", tracker.frame.background, "BOTTOMLEFT", BACKGROUND_PADDING * 1.8, INNER_BACKGROUND_PADDING / (2*tracker.scale))
            end) -- e(data, text, scale, inset, textEnd, onClick, fadeOnHover)

            if true then-- add debugging info
                --tinsert(tracker.renderData, function()
                --    addY(8)
                --end)
                renderLine(tracker.renderData, "|cFFFF0000 - TRACKER DEBUG - |r", 1)

                renderLine(tracker.renderData, function() return "|cFFFFFFFFActive Component Count: " .. tostring(#tracker.components) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() return "|cFFFFFFFFInactive Button Count: " .. tostring(#tracker.buttons) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() return "|cFFFFFFFFInactive Line Count: " .. tostring(#tracker.lines) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() return "|cFFFFFFFFInactive Checkbox Count: " .. tostring(#tracker.checkboxes) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() return "|cFFFFFFFFRender Count: " .. tostring(tracker.renderCount) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() return "|cFFFFFFFFQuest Count: " .. tostring(tracker.questCount) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, "", 1, 8)
                renderLine(tracker.renderData, function() return "|cFFFF0000 - ROUTES DEBUG - |r" end, 1)
                renderLine(tracker.renderData, function() local a = 0 for _,l in pairs(QuestieTSP.buttons) do a = a + #l end return "|cFFFFFFFFButtons (active / inactive): " .. tostring(a) .. " / " .. tostring(#QuestieTSP.buttonCache) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() local a = 0 for _,l in pairs(QuestieTSP.ants) do a = a + #l end return "|cFFFFFFFFAnts (active / inactive): " .. tostring(a) .. " / " .. tostring(#QuestieTSP.antCache) .. "|r" end, 0.8, 12)
                renderLine(tracker.renderData, function() local x, y = QuestieTSP:GetZoneEntryPoint(C_Map.GetBestMapForUnit("Player")) return "|cFFFFFFFFOrigin: " .. tostring(floor(x*1000)/10) .. ", " .. tostring(floor(y*1000)/10) .. "|r" end, 0.8, 12)
                
                --renderLine(tracker.renderData, "", 0.5, 8)
                --renderLine(tracker.renderData, function() return "|cFFFF0000 - VARIABLES - |r" end, 0.5)

                --for k, v in pairs(tracker) do
                --    if type(v) == "number" then
                --        renderLine(tracker.renderData, function() return "|cFFFFFFFF" .. tostring(k) .. ": " .. tostring(v) .. "|r" end, 0.5, 12)
                --    end
                --end
            end
        end
    end

    -- tracker is drawn using conventional rendering techniques instead of letting blizzard manage alignment. This is key for things like item buttons
    tracker.Render = function(self)
        tracker.renderCount = tracker.renderCount + 1


        -- rendering is done by increasing the value of Y, each render() call can affect it. This lets us avoid some weird behaviors around
        -- how blizzard handles frame positioning. And it lets us position the item buttons parented to UIParent, so the tracker can update while in combat
        tracker.renderYPrevious = 10 -- when no content is rendered, give the tracker some height


        -- used for fading on hover
        tracker.hovers = {}
        
        for _, render in pairs(tracker.renderData) do
            render()
        end

        tracker.height = tracker.renderYPrevious*tracker.scale

        tracker.padX = BACKGROUND_PADDING + BUTTON_SIZE_BASE - QUEST_TITLE_PADDING
        tracker.padY = BACKGROUND_PADDING

        local h = tracker.heightConstraint--(tracker.heightConstraint > tracker.height+tracker.padY*2) and (tracker.height+tracker.padY*2) or (tracker.heightConstraint)

        tracker.frame.background:SetSize(TRACKER_WIDTH, h)
        tracker.frame.scrollParent:SetSize(TRACKER_WIDTH, h - INNER_BACKGROUND_PADDING * 2)
        --tracker.frame.scrollParent:SetPoint("TOPLEFT", tracker.background, "TOPLEFT", 0, -INNER_BACKGROUND_PADDING)

        --local buttonsRightSide = (tracker.x + (tracker.width/2))*tracker.scale > GetScreenWidth() / 2

        --local shiftX = buttonsRightSide and BUTTON_SIZE or 0
        --local shiftY = 0
        local w = (tracker.width + (tracker.padX*2)) * tracker.scale

        tracker.frame.scrollParent:SetWidth(w-TRACKER_INNER_PADDING_WIDTH*2)
        tracker.frame.background:SetWidth(w)
        --tracker.frame:ClearAllPoints()
        tracker.frame:SetHeight((tracker.height/tracker.scale) + tracker.padY*2)
        tracker.frame:SetWidth(w-TRACKER_INNER_PADDING_WIDTH*2)


        tracker.frame.background:SetPoint("TOPLEFT", nil, "TOPLEFT", ((tracker.x)-tracker.padX/2)*tracker.scale, -(tracker.y-tracker.padY/2)*tracker.scale)
        tracker.frame.texture:SetAllPoints(tracker.frame)

        if tracker.frame:GetHeight() > tracker.frame.scrollParent:GetHeight() then
            tracker.frame.scrollParent.scroll.ScrollBar.ScrollUpButton:Show()
            tracker.frame.scrollParent.scroll.ScrollBar.ScrollDownButton:Show()
            tracker.frame.scrollParent.scroll.ScrollBar:Show()
        else
            tracker.frame.scrollParent.scroll.ScrollBar.ScrollUpButton:Hide()
            tracker.frame.scrollParent.scroll.ScrollBar.ScrollDownButton:Hide()
            tracker.frame.scrollParent.scroll.ScrollBar:Hide()
        end

        --tracker.header:Update()

    end

    tracker.Update = function(self, force)
        if not force and (tracker.dragging or tracker.hovered) then return end
        self.scale = GetScreenHeight() / 768
        --BUTTON_SIZE = BUTTON_SIZE_BASE / self.scale -- buttons rendered externally so they need to be scaled to be consistent
        LINE_HEIGHT = LINE_HEIGHT_BASE * self.scale
        self:FixPosition()
        self:Reset()
        self:Build()
        self:Render()
    end

    QuestieTracker:HookBaseTracker()

    C_Timer.NewTicker(2, function()
        tracker:Update()
    end)

    return tracker
end

function BUILD_NEW_TRACKER() -- todo
    newTracker(QuestieLoader:CreateModule("QuestieTrackerNew")):Update()
end
