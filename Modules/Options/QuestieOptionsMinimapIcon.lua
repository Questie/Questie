---@class QuestieOptionsMinimapIcon
local QuestieOptionsMinimapIcon = QuestieLoader:CreateModule("QuestieOptionsMinimapIcon");
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
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local minimapIconLDB = nil

function QuestieOptionsMinimapIcon:Initialize()
    minimapIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Questie", {
        type = "data source",
        text = "Questie",
        icon = ICON_TYPE_COMPLETE,

        OnClick = function (self, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() and IsControlKeyDown() then
                    Questie.db.char.enabled = (not Questie.db.char.enabled)
                    QuestieQuest:ToggleNotes(Questie.db.char.enabled)

                    -- CLose config window if it's open to avoid desyncing the Checkbox
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
                if not IsModifierKeyDown() then
                    -- CLose config window if it's open to avoid desyncing the Checkbox
                    QuestieOptions:HideFrame();

                    QuestieJourney.ToggleJourneyWindow();
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
            tooltip:AddLine(Questie:Colorize(l10n('Right Click') , 'gray') .. ": ".. l10n('Toggle My Journey'));
            tooltip:AddLine(Questie:Colorize(l10n('Ctrl + Right Click') , 'gray') .. ": ".. l10n('Hide Minimap Button'));
            tooltip:AddLine(Questie:Colorize(l10n('Ctrl + Left Click'),   'gray') .. ": ".. l10n('Reload Questie'));
        end,
    });
end

function QuestieOptionsMinimapIcon:Get()
    return minimapIconLDB
end
