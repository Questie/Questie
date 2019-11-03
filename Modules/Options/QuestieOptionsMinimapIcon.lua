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

local minimapIconLDB = nil

function QuestieOptionsMinimapIcon:Initalize()
    minimapIconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MinimapIcon", {
        type = "data source",
        text = "Questie",
        icon = ICON_TYPE_COMPLETE,

        OnClick = function (self, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    QuestieQuest:ToggleNotes();

                    -- CLose config window if it's open to avoid desyncing the Checkbox
                    QuestieOptions:HideFrame();
                    return;
                elseif IsControlKeyDown() then
                    QuestieQuest:SmoothReset()
                    return
                end

                QuestieOptions:OpenConfigWindow()

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
                    Questie.minimapConfigIcon:Hide("MinimapIcon");
                    return;
                end
            end
        end,

        OnTooltipShow = function (tooltip)
            tooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1);
            tooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString('ICON_LEFT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_TOGGLE'));
            tooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString('ICON_SHIFTLEFT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_TOGGLE_QUESTIE'));
            tooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString('ICON_RIGHT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_JOURNEY'));
            tooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString('ICON_CTRLRIGHT_CLICK') , 'gray') .. ": ".. QuestieLocale:GetUIString('ICON_HIDE'));
            tooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString('ICON_CTRLLEFT_CLICK'),   'gray') .. ": ".. QuestieLocale:GetUIString('ICON_RELOAD'));
        end,
    });
end

function QuestieOptionsMinimapIcon:Get()
    return minimapIconLDB
end
