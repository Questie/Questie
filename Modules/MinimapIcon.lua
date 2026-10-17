---@class MinimapIcon : QuestieModule
local MinimapIcon = QuestieLoader:CreateModule("MinimapIcon")
local _MinimapIcon = MinimapIcon.private
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieStatus
local QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")

local _LibDBIcon = LibStub("LibDBIcon-1.0")

local minimapButton
local statusBadge

local statusStyles = {
    [QuestieStatus.Severity.Error] = {
        label = "Error", r = 1, g = 0.2, b = 0.2,
        icon = {atlas = "common-icon-redx", texture = "Interface\\RaidFrame\\ReadyCheck-NotReady"},
    },
    [QuestieStatus.Severity.Warning] = {
        label = "Warning", r = 1, g = 0.82, b = 0,
        icon = {texture = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew"},
    },
    [QuestieStatus.Severity.Info] = {
        label = "Information", r = 0.4, g = 0.75, b = 1,
        icon = {texture = "Interface\\FriendsFrame\\InformationIcon"},
    },
}

---@param icon QuestieStatusIcon
---@return boolean loaded
local function _SetStatusTexture(icon)
    -- SetAtlas changes UVs; a later standalone texture must use its whole image.
    statusBadge:SetTexCoord(0, 1, 0, 1)
    if icon.atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(icon.atlas) then
        statusBadge:SetAtlas(icon.atlas)
        return true
    end
    if icon.texture then
        return statusBadge:SetTexture(icon.texture)
    end
    return false
end

local function _UpdateStatusBadge()
    local issue = QuestieStatus.GetBadgeIssue()
    if not issue then
        statusBadge:Hide()
        return
    end

    if not (issue.icon and _SetStatusTexture(issue.icon)) then
        assert(_SetStatusTexture(statusStyles[issue.severity].icon), "Questie minimap status icon could not be loaded")
    end
    statusBadge:Show()
end

local function _AddStatusLines(tooltip)
    for _, issue in ipairs(QuestieStatus.GetIssues()) do
        local style = statusStyles[issue.severity]
        tooltip:AddLine(" ")
        local message = l10n(issue.message, unpack(issue.args or {}))
        tooltip:AddLine(l10n(style.label) .. l10n(": ") .. message, style.r, style.g, style.b, true)
        for _, detail in ipairs(issue.details or {}) do
            local detailMessage = l10n(detail.message, unpack(detail.args or {}))
            tooltip:AddLine("  " .. detailMessage, 0.8, 0.8, 0.8, true)
        end
        if issue.action then
            tooltip:AddLine(l10n(issue.action), 1, 1, 1, true)
        end
    end
end

---@return boolean statusUIReady Whether a status badge was installed and its initial state rendered.
function MinimapIcon:Init()
    _LibDBIcon:Register("Questie", _MinimapIcon:CreateDataBrokerObject(), Questie.db.profile.minimap)

    minimapButton = _LibDBIcon:GetMinimapButton("Questie")

    _MinimapIcon.RepositionIcon()
    if not minimapButton then
        return false
    end

    -- This texture belongs to Questie, not LibDBIcon's icon/border machinery. Parent visibility,
    -- scale, and dragging carry it along without replacing any of the library's input scripts.
    statusBadge = minimapButton:CreateTexture(nil, "OVERLAY", nil, 1)
    statusBadge:SetSize(10, 10)
    statusBadge:SetPoint("TOPRIGHT", minimapButton, "TOPRIGHT", -1, -1)
    statusBadge:Hide()
    return QuestieStatus.SetOnChange(_UpdateStatusBadge)
end

function _MinimapIcon:CreateDataBrokerObject()
    local LDBDataObject = LibStub("LibDataBroker-1.1"):NewDataObject("Questie", {
        type = "data source",
        text = Questie.db.profile.ldbDisplayText,
        icon = "Interface\\Addons\\Questie\\Icons\\questie.png",

        OnClick = _MinimapIcon.OnClick,

        ---@param tooltip any
        OnTooltipShow = function (tooltip)
            if minimapButton and tooltip:GetOwner() == minimapButton then
                -- Tooltip top right on the button's bottom left, so it never overlaps the menu on its bottom right
                tooltip:ClearAllPoints()
                tooltip:SetPoint("TOPRIGHT", minimapButton, "BOTTOMLEFT")
            end
            tooltip:AddDoubleLine(Questie:Colorize("Questie", 'gold'), Questie:Colorize(QuestieLib:GetAddonVersionString(), 'gray'))
            _AddStatusLines(tooltip)
            if not Questie.started then
                return
            end
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Left Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle My Journey'), 'white'))
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Right Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle Menu'), 'white'))
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Shift + Left Click'), 'lightBlue'), Questie:Colorize(l10n('Questie Options'), 'white'))
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Ctrl + Left Click'), 'lightBlue'), Questie:Colorize(l10n('Reload Questie'), 'white'))
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Ctrl + Right Click'), 'lightBlue'), Questie:Colorize(l10n('Hide Minimap Button'), 'white'))
            tooltip:AddLine(" ")
            local toggleLabel = Questie.db.profile.enabled and l10n('Hide Questie') or l10n('Show Questie')
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Ctrl + Shift + Left Click'), 'lightBlue'), Questie:Colorize(toggleLabel, 'white'))
        end,
    })

    self.LDBDataObject = LDBDataObject

    return LDBDataObject
end

---@param displayFrame Frame The LDB display that was clicked (minimap button, addon compartment, broker bar, ...)
function _MinimapIcon.OnClick(displayFrame, button)
    if (not Questie.started) then
        return
    end

    if button == "LeftButton" then
        if IsShiftKeyDown() and IsControlKeyDown() then
            Questie.db.profile.enabled = (not Questie.db.profile.enabled)
            QuestieQuest:ToggleNotes(Questie.db.profile.enabled)

            if minimapButton and minimapButton:IsMouseOver() then
                local onEnter = minimapButton:GetScript("OnEnter")
                if onEnter then
                    GameTooltip:Hide()
                    onEnter(minimapButton)
                end
            end

            -- Close config window if it's open to avoid desyncing the Checkbox
            QuestieOptions:HideFrame()
            return
        end

        if IsShiftKeyDown() then
            if InCombatLockdown() then
                Questie:Print(l10n("Questie will open after combat ends."))
            end

            QuestieCombatQueue:Queue(function()
                QuestieOptions:ToggleConfigWindow()
            end)
            return
        end

        if IsControlKeyDown() then
            QuestieQuest:SmoothReset()
            return
        end

        QuestieJourney:ToggleJourneyWindow()
    elseif button == "RightButton" then
        if IsControlKeyDown() then
            Questie.db.profile.minimap.hide = true
            _LibDBIcon:Hide("Questie")
            return
        end

        if QuestieMenu.IsOpen() then
            QuestieMenu:Hide()
            return
        end

        -- Anchor to the minimap button only; other LDB displays open the menu at the cursor
        QuestieMenu:Show(nil, displayFrame == minimapButton and minimapButton or nil)
    end
end

--- Update the LibDataBroker text
function MinimapIcon:UpdateText(text)
    Questie.db.profile.ldbDisplayText = text
    _MinimapIcon.LDBDataObject.text = text
end

---@param shouldShow boolean
function MinimapIcon.Toggle(shouldShow)
    Questie.db.profile.minimap.hide = not shouldShow;

    if shouldShow then
        _LibDBIcon:Show("Questie")
    else
        _LibDBIcon:Hide("Questie")
    end
end

function _MinimapIcon.RepositionIcon()
    local button = _LibDBIcon:GetMinimapButton("Questie")
    if button then
        -- Slightly adjust the size and position of the icon to not overlap with the minimap button border
        button.icon:ClearAllPoints()
        button.icon:SetSize(17, 17)
        button.icon:SetPoint("CENTER", 0.5, 0.5)
    end
end