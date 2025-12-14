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

local _LibDBIcon = LibStub("LibDBIcon-1.0")

function MinimapIcon:Init()
    _LibDBIcon:Register("Questie", _MinimapIcon:CreateDataBrokerObject(), Questie.db.profile.minimap)

    _MinimapIcon.RepositionIcon()
end

function _MinimapIcon:CreateDataBrokerObject()
    local LDBDataObject = LibStub("LibDataBroker-1.1"):NewDataObject("Questie", {
        type = "data source",
        text = Questie.db.profile.ldbDisplayText,
        icon = "Interface\\Addons\\Questie\\Icons\\questie.png",

        OnClick = _MinimapIcon.OnClick,

        ---@param tooltip any
        OnTooltipShow = function (tooltip)
            tooltip:AddDoubleLine(Questie:Colorize("Questie", 'gold'), Questie:Colorize(QuestieLib:GetAddonVersionString(), 'gray'))
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Left Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle My Journey'), 'white'))
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Right Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle Menu'), 'white'))
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Shift + Left Click'), 'lightBlue'), Questie:Colorize(l10n('Questie Options'), 'white'))
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Ctrl + Left Click'), 'lightBlue'), Questie:Colorize(l10n('Reload Questie'), 'white'))
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Ctrl + Right Click'), 'lightBlue'), Questie:Colorize(l10n('Hide Minimap Button'), 'white'))
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(Questie:Colorize(l10n('Ctrl + Shift + Left Click'), 'lightBlue'), Questie:Colorize(l10n('Toggle Questie'), 'white'))
        end,
    })

    self.LDBDataObject = LDBDataObject

    return LDBDataObject
end

function _MinimapIcon.OnClick(_, button)
    if (not Questie.started) then
        return
    end

    if button == "LeftButton" then
        if IsShiftKeyDown() and IsControlKeyDown() then
            Questie.db.profile.enabled = (not Questie.db.profile.enabled)
            QuestieQuest:ToggleNotes(Questie.db.profile.enabled)

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

        QuestieMenu:Show()
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

return MinimapIcon