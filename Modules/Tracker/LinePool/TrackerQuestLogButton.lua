---@class TrackerQuestLogButton
local TrackerQuestLogButton = QuestieLoader:CreateModule("TrackerQuestLogButton")

---@type TrackerShortcuts
local TrackerShortcuts = QuestieLoader:ImportModule("TrackerShortcuts")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type QuestieMenuBuilder
local QuestieMenuBuilder = QuestieLoader:ImportModule("QuestieMenuBuilder")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type TaintWatch
local TaintWatch = QuestieLoader:ImportModule("TaintWatch")

-- Forever: Opening the quest log from addon code taints the world map, and so does code run by a macro (/run).
-- Instead the click opens the quest's map through the client, which builds the map's quest log right away, and the
-- secure button then clicks the quest's title in it, or else the quest in Blizzard's own (hidden) tracker. Blizzard's
-- click handler shows the details untainted with the questID Blizzard stored on that button.
-- Secure buttons can not be changed in combat, so a single button is moved over the hovered quest line out of combat.
-- It only handles the "open quest log" click. Every other click is forwarded to the OnClick script of the line.

local UPDATE_INTERVAL = 0.1
local IDLE_OFFSET = -100
-- Blizzard's quest title toggles the tracking on Shift + Left Click and opens a menu on Right Click.
local TITLE_CLICK_SHORTCUTS = {left = true, ctrlleft = true, altleft = true}

---@type Button?
local overlay
---@type TrackerLineFrame?
local attachedLine
local timeSinceUpdate = 0

local function _IsGamepadUI()
    return InputUtil and InputUtil.IsGamepadUIEnabled()
end

---Moves the button out of the screen, as a secure button can not be hidden in combat.
local function _MoveAway()
    attachedLine = nil
    if (not overlay) or InCombatLockdown() then
        return
    end
    overlay:ClearAllPoints()
    overlay:SetSize(1, 1)
    overlay:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", IDLE_OFFSET, IDLE_OFFSET)
end

---Finds the quest's title in the map's quest log, or else its block's header in Blizzard's tracker. Quests in a header
---that is on no map (e.g. "Crafting") have no title, as opening the map collapses that header. Blizzard's tracker only
---has the quests that fit into its height.
---@param questId number
---@return Button?
local function _GetDetailsButton(questId)
    local titleButton = QuestLogQuests_GetQuestButton(questId)
    if titleButton then
        return titleButton
    end
    -- The block's header untracks the quest instead with this modifier
    if IsModifiedClick("QUESTWATCHTOGGLE") then
        return nil
    end
    for _, tracker in ipairs({QuestObjectiveTracker, CampaignQuestObjectiveTracker}) do
        local block = tracker:GetExistingBlock(questId)
        if block then
            return block.HeaderButton
        end
    end
    return nil
end

local function _PreClick(self, button)
    local line = attachedLine
    self.opensQuestLog = false
    self:SetAttribute("type", nil)
    self:SetAttribute("clickbutton", nil)
    -- A click bound to the quest log is bound to no other action (see TrackerShortcuts.Set), and Attach only covers
    -- lines when that shortcut can click Blizzard's title.
    if (not line) or (not line.Quest) or InCombatLockdown() or (not TrackerShortcuts.Matches("trackerbindOpenQuestLog", button)) then
        return
    end

    local questId = line.Quest.Id
    local uiMapId = QuestieCompat.GetQuestUiMapID(questId) or C_Map.GetBestMapForUnit("player")
    if (not uiMapId) then
        return
    end

    if QuestieMenuBuilder.IsOpen() then
        QuestieMenuBuilder.Close()
    end
    self.opensQuestLog = true
    TaintWatch.Note("C_QuestLog.SetSelectedQuest", questId)
    C_QuestLog.SetSelectedQuest(questId)
    QuestieCompat.OpenWorldMap(uiMapId)

    -- Without such a button the click only opens the map.
    local detailsButton = _GetDetailsButton(questId)
    if detailsButton then
        self:SetAttribute("clickbutton", detailsButton)
        self:SetAttribute("type", "click")
    end
end

local function _PostClick(self, button)
    local line = attachedLine
    if self.opensQuestLog or (not line) then
        return
    end

    local onClick = line:GetScript("OnClick")
    if onClick then
        onClick(line, button)
    end
end

---Runs the OnLeave script of a line the mouse is no longer over, as the button above it took the line's own OnLeave.
---@param line TrackerLineFrame
local function _LeaveLine(line)
    if line:IsMouseOver() then
        return
    end
    local onLeave = line:GetScript("OnLeave")
    if onLeave then
        onLeave(line)
    end
end

---The mouse left the button without entering the line again, so the line has to be left as well.
local function _OnLeave()
    local line = attachedLine
    if (not line) or overlay:IsMouseOver() then
        return
    end
    _MoveAway()
    _LeaveLine(line)
end

---A scrolled or hidden line can leave the button behind, where it would take clicks from other frames.
local function _OnUpdate(_, elapsed)
    timeSinceUpdate = timeSinceUpdate + elapsed
    if timeSinceUpdate < UPDATE_INTERVAL then
        return
    end
    timeSinceUpdate = 0

    local line = attachedLine
    if (not line) then
        return
    end
    local scrollFrame = line:GetParent() and line:GetParent():GetParent()
    if (not line:IsVisible()) or (not line:IsMouseOver()) or (scrollFrame and (not scrollFrame:IsMouseOver())) then
        _MoveAway()
        _LeaveLine(line)
    end
end

function TrackerQuestLogButton.Initialize()
    if overlay or (not Questie.IsForever) then
        return
    end

    overlay = CreateFrame("Button", "Questie_QuestLogButton", UIParent, "SecureActionButtonTemplate")
    overlay:SetSize(1, 1)
    overlay:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", IDLE_OFFSET, IDLE_OFFSET)
    overlay:EnableMouse(true)
    overlay:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    -- Tracker lines act on the release of the click. The template would wait for the press with the ActionButtonUseKeyDown CVar.
    overlay:SetAttribute("useOnKeyDown", false)
    overlay:RegisterForDrag("LeftButton")
    overlay:SetPropagateMouseMotion(true)

    overlay:SetScript("PreClick", _PreClick)
    overlay:SetScript("PostClick", _PostClick)
    overlay:SetScript("OnLeave", _OnLeave)
    overlay:SetScript("OnUpdate", _OnUpdate)
    overlay:SetScript("OnDragStart", TrackerBaseFrame.OnDragStart)
    overlay:SetScript("OnDragStop", TrackerBaseFrame.OnDragStop)

    -- A secure button can not be hidden by addon code in combat, the secure state driver can.
    -- Anchored to a line, the button would also protect the tracker in combat, so it leaves the line right before the
    -- combat starts, and again after it, in case the combat started while it was attached.
    RegisterStateDriver(overlay, "visibility", "[combat] hide; show")
    overlay:RegisterEvent("PLAYER_REGEN_DISABLED")
    overlay:RegisterEvent("PLAYER_REGEN_ENABLED")
    overlay:SetScript("OnEvent", _MoveAway)
end

---Moves the button over a quest line, if the click bound to the quest log can click Blizzard's quest title.
---@param line TrackerLineFrame
function TrackerQuestLogButton.Attach(line)
    if (not overlay) or InCombatLockdown() then
        return
    end

    if line.onClickMode ~= "quest" or (not line.Quest) or _IsGamepadUI() or (not TITLE_CLICK_SHORTCUTS[Questie.db.profile.trackerbindOpenQuestLog]) then
        _MoveAway()
        return
    end

    attachedLine = line
    -- The buttons in front of the label keep their own clicks. Protected frames can only be anchored to frames, not to the label.
    local _, _, _, labelX, labelY = line.label:GetPoint()
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPLEFT", line, "TOPLEFT", labelX or 0, labelY or 0)
    overlay:SetPoint("BOTTOMRIGHT", line, "BOTTOMRIGHT", 0, 0)
    overlay:SetFrameStrata(line:GetFrameStrata())
    overlay:SetFrameLevel(line:GetFrameLevel() + 2)
end

---Moves the button away from a line, e.g. because the tracker is drawn again.
function TrackerQuestLogButton.Detach()
    _MoveAway()
end

---While the mouse is on the button, the line below it is still hovered.
---@param line TrackerLineFrame
---@return boolean
function TrackerQuestLogButton.IsHovering(line)
    return overlay ~= nil and attachedLine == line and overlay:IsMouseOver()
end
