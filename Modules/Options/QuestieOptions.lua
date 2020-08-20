---@class QuestieOptions
local QuestieOptions = QuestieLoader:CreateModule("QuestieOptions");
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieOptionsMinimapIcon
local QuestieOptionsMinimapIcon = QuestieLoader:ImportModule("QuestieOptionsMinimapIcon");


QuestieOptions.tabs = {...}
QuestieConfigFrame = nil

local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialogQuestie-3.0")

-- Forward declaration
local _CreateOptionsTable

function QuestieOptions:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieOptions]: Initializing...")

    local optionsTable = _CreateOptionsTable()
    LibStub("AceConfigQuestie-3.0"):RegisterOptionsTable("Questie", optionsTable)
    Questie.configFrame = AceConfigDialog:AddToBlizOptions("Questie", "Questie");

    local configFrame = AceGUI:Create("Frame");
    AceConfigDialog:SetDefaultSize("Questie", 625, 780)
    AceConfigDialog:Open("Questie", configFrame)
    configFrame:Hide();
    QuestieConfigFrame = configFrame;
    table.insert(UISpecialFrames, "QuestieConfigFrame");

    QuestieOptionsMinimapIcon:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieOptions]: Initialization done")
end

-- Generic function to hide the config frame.
function QuestieOptions:HideFrame()
  if QuestieConfigFrame and QuestieConfigFrame:IsShown() then
    QuestieConfigFrame:Hide();
  end
end

-- Open the configuration window
function QuestieOptions:OpenConfigWindow()
    if not QuestieConfigFrame:IsShown() then
        PlaySound(882)
        AceConfigDialog:Open("Questie", QuestieConfigFrame)
    else
        QuestieConfigFrame:Hide()
    end
end

-- get option value
function QuestieOptions:GetGlobalOptionValue(info)
    return Questie.db.global[info[#info]]
end

-- set option value
function QuestieOptions:SetGlobalOptionValue(info, value)
    if debug and Questie.db.global[info[#info]] ~= value then
        Questie:Debug(DEBUG_SPAM, "DEBUG: global option "..info[#info].." changed from '"..tostring(Questie.db.global[info[#info]]).."' to '"..tostring(value).."'")
    end
    Questie.db.global[info[#info]] = value
end

function QuestieOptions:AvailableQuestRedraw()
    QuestieQuest:CalculateAndDrawAvailableQuestsIterative()
end

function QuestieOptions:ClusterRedraw()
    Questie:Debug(DEBUG_INFO, "Clustering changed, redrawing!")
    --Redraw clusters here
    QuestieQuest:SmoothReset();
end


_CreateOptionsTable = function()
    return {
        name = "Questie",
        handler = Questie,
        type = "group",
        childGroups = "tab",
        args = {
            general_tab = QuestieOptions.tabs.general:Initialize(),
            minimap_tab = QuestieOptions.tabs.minimap:Initialize(),
            map_tab = QuestieOptions.tabs.map:Initialize(),
            dbm_hud_tab = QuestieOptions.tabs.dbm:Initialize(),
            tracker_tab = QuestieOptions.tabs.tracker:Initialize(),
            nameplate_tab = QuestieOptions.tabs.nameplate:Initialize(),
            tooltip_tab = QuestieOptions.tabs.tooltip:Initialize(),
            advanced_tab = QuestieOptions.tabs.advanced:Initialize(),
        }
    }
end
