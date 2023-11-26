---@class MinimapIcon
local MinimapIcon = QuestieLoader:CreateModule("MinimapIcon");
local _MinimapIcon = {}
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestieMenu
local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local _LibDBIcon = LibStub("LibDBIcon-1.0");

function MinimapIcon:Init()
    _LibDBIcon:Register("Questie", _MinimapIcon:CreateDataBrokerObject(), Questie.db.profile.minimap);
    Questie.minimapConfigIcon = _LibDBIcon
end

function _MinimapIcon:CreateDataBrokerObject()
    local LDBDataObject = LibStub("LibDataBroker-1.1"):NewDataObject("Questie", {
        type = "data source",
        text = Questie.db.profile.ldbDisplayText,
        icon = "Interface\\Addons\\Questie\\Icons\\complete.blp",

        OnClick = function (_, button)
            if (not Questie.started) then
                return
            end

            if button == "LeftButton" then
                if IsShiftKeyDown() and IsControlKeyDown() then
                    Questie.db.profile.enabled = (not Questie.db.profile.enabled)
                    QuestieQuest:ToggleNotes(Questie.db.profile.enabled)

                    -- Close config window if it's open to avoid desyncing the Checkbox
                    QuestieOptions:HideFrame();
                    return;
                elseif IsControlKeyDown() then
                    QuestieQuest:SmoothReset()
                    return
                end

                QuestieMenu:Show()

                if QuestieJourney:IsShown() then
                    QuestieJourney.ToggleJourneyWindow();
                end

                return;
            elseif button == "RightButton" then
                if (not IsModifierKeyDown()) then
                    -- CLose config window if it's open to avoid desyncing the Checkbox
                    QuestieOptions:HideFrame();
                    if InCombatLockdown() then
                        Questie:Print(l10n("Questie will open after combat ends."))
                    end
                    QuestieCombatQueue:Queue(function()
                        QuestieOptions:OpenConfigWindow()
                    end)
                    return;
                elseif IsControlKeyDown() then
                    Questie.db.profile.minimap.hide = true;
                    Questie.minimapConfigIcon:Hide("Questie");
                    return;
                end
            end
        end,

        OnTooltipShow = function (tooltip)
            tooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1);
            tooltip:AddLine(Questie:Colorize(l10n('Left Click') , 'gray') .. ": ".. l10n('Toggle Menu'));
            tooltip:AddLine(Questie:Colorize(l10n('Ctrl + Shift + Left Click') , 'gray') .. ": ".. l10n('Toggle Questie'));
            tooltip:AddLine(Questie:Colorize(l10n('Right Click') , 'gray') .. ": ".. l10n('Questie Options'));
            tooltip:AddLine(Questie:Colorize(l10n('Ctrl + Right Click') , 'gray') .. ": ".. l10n('Hide Minimap Button'));
            tooltip:AddLine(Questie:Colorize(l10n('Ctrl + Left Click'),   'gray') .. ": ".. l10n('Reload Questie'));
        end,
    });

    self.LDBDataObject = LDBDataObject

    return LDBDataObject
end

--- Update the LibDataBroker text
function MinimapIcon:UpdateText(text)
    Questie.db.profile.ldbDisplayText = text
    _MinimapIcon.LDBDataObject.text = text
end

