QuestieOptions = {...}
QuestieConfigFrame = {...}
local _QuestieOptions = {...}

local AceGUI = LibStub("AceGUI-3.0")

function QuestieOptions:Initialize()
    Questie:Debug(DEBUG_DEVELOP, "[QuestieOptions]: Initializing...")
    LibStub("AceConfigQuestie-3.0"):RegisterOptionsTable("Questie", _QuestieOptions.optionsGUI)
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
    --Redraw clusters here
end


_QuestieOptions.optionsGUI = {
    name = "Questie",
    handler = Questie,
    type = "group",
    childGroups = "tab",
    args = {
        general_tab = QuestieOptionsGeneral:Initialize(),
        minimap_tab = QuestieOptionsMinimap:Initalize(),
        map_tab = QuestieOptionsMap:Initialize(),
        dbm_hud_tab = QuestieOptionsDBM:Initalize(),
        tracker_tab = QuestieOptionsTracker:Initialize(),
        nameplate_tab = QuestieOptionsNameplate:Initialize(),
        advanced_tab = QuestieOptionsAdvanced:Initalize(),
    }
}
