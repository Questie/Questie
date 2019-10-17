QuestieOptions = {...}
QuestieOptions.tabs = {...}
QuestieConfigFrame = {...}

local AceGUI = LibStub("AceGUI-3.0")

-- Forward declaration
local _CreateGUI

function QuestieOptions:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieOptions]: Initializing...")

    local optionsGUI = _CreateGUI()
    LibStub("AceConfigQuestie-3.0"):RegisterOptionsTable("Questie", optionsGUI)
    Questie.configFrame = LibStub("AceConfigDialogQuestie-3.0"):AddToBlizOptions("Questie", "Questie");

    local configFrame = AceGUI:Create("Frame");
    LibStub("AceConfigDialogQuestie-3.0"):SetDefaultSize("Questie", 625, 700)
    LibStub("AceConfigDialogQuestie-3.0"):Open("Questie", configFrame)
    configFrame:Hide();
    QuestieConfigFrame = configFrame.frame;
    table.insert(UISpecialFrames, "QuestieConfigFrame");

    QuestieOptionsMinimapIcon:Initalize()
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
        QuestieConfigFrame:Show()
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
    QuestieQuest:CalculateAvailableQuests()
    QuestieQuest:DrawAllAvailableQuests()
end

function QuestieOptions:ClusterRedraw()
    Questie:Debug(DEBUG_INFO, "Clustering changed, redrawing!")
    --Redraw clusters here
    QuestieQuest:SmoothReset();
end


_CreateGUI = function()
    return {
        name = "Questie",
        handler = Questie,
        type = "group",
        childGroups = "tab",
        args = {
            general_tab = QuestieOptions.tabs.general:Initialize(),
            minimap_tab = QuestieOptions.tabs.minimap:Initalize(),
            map_tab = QuestieOptions.tabs.map:Initialize(),
            dbm_hud_tab = QuestieOptions.tabs.dbm:Initalize(),
            tracker_tab = QuestieOptions.tabs.tracker:Initialize(),
            nameplate_tab = QuestieOptions.tabs.nameplate:Initialize(),
            advanced_tab = QuestieOptions.tabs.advanced:Initalize(),
        }
    }
end
