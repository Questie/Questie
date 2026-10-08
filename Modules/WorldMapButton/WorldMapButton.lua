---@class WorldMapButton
---@field Initialize function
local WorldMapButton = QuestieLoader:CreateModule("WorldMapButton")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")

local KButtons = LibStub("Krowi_WorldMapButtons-1.4")
if Questie.IsForever then
    -- Krowi classifies version 1.x as the old Classic map. Forever has modern overlay buttons;
    -- its old-map workaround reparents them away from the map and breaks GetMapID/TriggerEvent.
    KButtons.HasNoOverlay = false
end

---@type AceConfigDialog-3.0
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local mapButton

-- Forever positions Blizzard's own map buttons itself: the Map Pin on the left side of the map
-- and the Map Filter in the navigation bar. Krowi's layout adds a TOPRIGHT anchor without
-- clearing existing points, which drags them out of place (the Map Pin gets stretched across
-- the whole map header, and its hit area covers other buttons). Keep them out of Krowi's layout.
local function ReleaseBlizzardMapButtons()
    local buttons = KButtons.Buttons
    if not buttons then
        return
    end
    local pinOnLoad = WorldMapTrackingPinButtonMixin and WorldMapTrackingPinButtonMixin.OnLoad
    local optionsOnLoad = WorldMapTrackingOptionsButtonMixin and WorldMapTrackingOptionsButtonMixin.OnLoad
    for i = #buttons, 1, -1 do
        local onLoad = buttons[i].OnLoad
        if onLoad and (onLoad == pinOnLoad or onLoad == optionsOnLoad) then
            table.remove(buttons, i)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Blizzard quest POI pins ("?" toggle button + login restore)
-- ---------------------------------------------------------------------------
-- An always-on world-map button that shows/hides Blizzard's native quest POI pins via the questPOI
-- CVar. Those pins drive native supertracking (and the WaypointUI flare); this client resets the
-- CVar to 0 each login, so we re-apply the user's choice (questPOIEnabled) on login. Forever-only.
---@type Button?
local poiButton

---@return boolean
local function QuestPOIEnabled()
    return Questie.db.profile.questPOIEnabled == true
end

-- Reflect the on/off state on the "?" icon.
function WorldMapButton.UpdatePOIButton()
    if not (poiButton and poiButton.icon) then return end
    local on = QuestPOIEnabled()
    poiButton.icon:SetDesaturated(not on)
    poiButton.icon:SetAlpha(on and 1 or 0.45)
end

-- Some questPOI writes taint during combat, so defer the apply to combat end. Any afterApply
-- callbacks handed to ApplyQuestPOI while deferred run once the write actually lands.
local poiCombatFrame = CreateFrame("Frame")
---@type function[]
local poiApplyCallbacks = {}
poiCombatFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    local callbacks = poiApplyCallbacks
    poiApplyCallbacks = {}
    WorldMapButton.ApplyQuestPOI()
    for i = 1, #callbacks do
        callbacks[i]()
    end
end)

-- Apply the questPOI CVar from the setting and refresh the native pins. Combat-safe: if we're in
-- lockdown, defer the whole apply until combat ends. afterApply (optional) runs right after the
-- CVar write, including when the apply was deferred -- so callers that must read questPOI post-write
-- (e.g. the login map-hide check) stay correct in combat.
---@param afterApply function? Runs after the questPOI write lands (immediately or post-combat).
function WorldMapButton.ApplyQuestPOI(afterApply)
    if InCombatLockdown() then
        poiCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        if afterApply then
            poiApplyCallbacks[#poiApplyCallbacks + 1] = afterApply
        end
        WorldMapButton.UpdatePOIButton()
        return
    end
    local desired = QuestPOIEnabled() and "1" or "0"
    if GetCVar("questPOI") ~= desired then
        SetCVar("questPOI", desired)
    end
    if type(QuestMapFrame_UpdateAll) == "function" then pcall(QuestMapFrame_UpdateAll) end
    if type(QuestPOIUpdateIcons) == "function" then pcall(QuestPOIUpdateIcons) end
    -- Refresh the world-map data providers so pins appear/disappear immediately -- but only on the
    -- next frame and only while the map is shown. Refreshing a hidden or not-yet-sized canvas (e.g.
    -- on login) throws inside Blizzard's MapCanvas providers (division by zero / ipairs on nil), and
    -- those escape our pcall because RefreshAllDataProviders iterates via secureexecuterange.
    if WorldMapFrame and WorldMapFrame.RefreshAllDataProviders and C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if WorldMapFrame:IsShown() then
                pcall(function() WorldMapFrame:RefreshAllDataProviders() end)
            end
        end)
    end
    WorldMapButton.UpdatePOIButton()
    if afterApply then
        afterApply()
    end
end

-- Left-click the "?" button: flip native quest POIs on/off.
function WorldMapButton.ToggleQuestPOI()
    Questie.db.profile.questPOIEnabled = not QuestPOIEnabled()
    WorldMapButton.ApplyQuestPOI()
    -- Refresh the options UI if it's open, so its toggle reflects the new state.
    if _G.QuestieConfigFrame and _G.QuestieConfigFrame:IsShown() then
        AceConfigDialog:Open("Questie", _G.QuestieConfigFrame)
    end
end

---@param self Button
local function POITooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:ClearLines()
    GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)
    GameTooltip:AddLine(l10n("Quest POI"))
    local state = QuestPOIEnabled() and l10n("Shown") or l10n("Hidden")
    GameTooltip:AddDoubleLine(Questie:Colorize(l10n("Left Click"), 'lightBlue'), Questie:Colorize(state, 'white'))
    GameTooltip:Show()
end

-- Build the "?" toggle as a bare Krowi row button styled like Questie's own map button
-- (frameStrata HIGH so the map canvas can't render over it).
local function BuildPOIButton()
    if poiButton then return end
    poiButton = KButtons:Add(nil, "BUTTON")
    poiButton:SetSize(32, 32)
    poiButton:SetFrameStrata("HIGH")

    local bg = poiButton:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(25, 25)
    bg:SetPoint("TOPLEFT", 2, -4)

    local icon = poiButton:CreateTexture(nil, "ARTWORK")
    icon:SetSize(22, 22)
    icon:SetPoint("TOPLEFT", 6, -5)
    -- Prefer the real quest turn-in "?" POI atlas; fall back to the classic gossip "?" texture.
    if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("QuestTurnin") then
        icon:SetAtlas("QuestTurnin", false)
    else
        icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
    end
    poiButton.icon = icon

    local border = poiButton:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")

    poiButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    poiButton:RegisterForClicks("LeftButtonUp")
    poiButton:SetScript("OnClick", WorldMapButton.ToggleQuestPOI)
    poiButton:SetScript("OnEnter", POITooltip)
    -- Match Questie's own map-button template (OnLeave function="GameTooltip_Hide"); this is a bare
    -- (non-template) button, so it must clear its own tooltip -- Krowi does not manage GameTooltip.
    poiButton:SetScript("OnLeave", GameTooltip_Hide)
    poiButton.Refresh = function() end -- Krowi calls button:Refresh() on map refresh

    poiButton:Show()
    WorldMapButton.UpdatePOIButton()
end

function WorldMapButton.Initialize()
    mapButton = KButtons:Add("QuestieWorldMapButtonTemplate", "BUTTON")
    if Questie.IsForever then
        ReleaseBlizzardMapButtons()
    end

    Questie.WorldMap = {
        Button = mapButton
    }

    WorldMapButton.Toggle(Questie.db.profile.mapShowHideEnabled)

    -- Forever-only: add the always-on "?" quest POI toggle next to Questie's button. Both buttons
    -- are added here, back-to-back, so there is no cross-addon row-ordering race.
    if Questie.IsForever then
        BuildPOIButton()
        Questie.WorldMap.POIButton = poiButton
        if type(KButtons.SetPoints) == "function" then
            KButtons.SetPoints()
        end
    end
end

---@param shouldShow boolean
function WorldMapButton.Toggle(shouldShow)
    if shouldShow then
        mapButton:Show()
    else
        mapButton:Hide()
    end
end

---@param self Frame
---@return nil
local function UpdateTooltip(self)
    local tooltip = GameTooltip
    tooltip:SetOwner(self, "ANCHOR_NONE");
    tooltip:ClearLines()
    tooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);
    tooltip:AddDoubleLine(Questie:Colorize("Questie", 'gold'), Questie:Colorize(QuestieLib:GetAddonVersionString(), 'gray'))
    tooltip:AddLine(" ")
    local toggleLabel = Questie.db.profile.enabled and l10n('Hide Questie') or l10n('Show Questie')
    tooltip:AddDoubleLine(Questie:Colorize(l10n('Left Click'), 'lightBlue'), Questie:Colorize(toggleLabel, 'white'))
    tooltip:AddDoubleLine(Questie:Colorize(l10n('Right Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle Menu'), 'white'))
    tooltip:Show()
end

QuestieWorldMapButtonMixin = {
    OnLoad = function() end,
    OnHide = function() end,
    OnMouseDown = function(_, button)
        if button == "LeftButton" then
            Questie.db.profile.enabled = (not Questie.db.profile.enabled)
            QuestieQuest:ToggleNotes(Questie.db.profile.enabled)
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == mapButton then
                UpdateTooltip(mapButton)
            end
            -- Refresh options UI if open to reflect new state
            if _G.QuestieConfigFrame and _G.QuestieConfigFrame:IsShown() then
                AceConfigDialog:Open("Questie", _G.QuestieConfigFrame)
            end
        elseif button == "RightButton" then
            if QuestieMenu.IsOpen() then
                QuestieMenu:Hide()
            else
                QuestieMenu:Show()
            end
        end
    end,
    OnMouseUp = function() end,
    OnEnter = function(self)
        UpdateTooltip(self)
    end,
    OnLeave = function() end,
    OnClick = function() end, -- Only fires on left click
    Refresh = function() end,
}
