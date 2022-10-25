---@class QuestieOptions
local QuestieOptions = QuestieLoader:CreateModule("QuestieOptions");
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

QuestieOptions.tabs = {...}
QuestieConfigFrame = nil

local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Forward declaration
local _CreateOptionsTable

---Initializes the frames for the options menu
function QuestieOptions:Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieOptions]: Initializing...")

    local optionsTable = _CreateOptionsTable()

    coroutine.yield()

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Questie", optionsTable)
    AceConfigDialog:AddToBlizOptions("Questie", "Questie");

    coroutine.yield()

    ---@type AceGUIFrame, AceGUIFrame
    local configFrame = AceGUI:Create("Frame")

    configFrame:Hide()
    coroutine.yield()

    AceConfigDialog:SetDefaultSize("Questie", 625, 780)
    AceConfigDialog:Open("Questie", configFrame) -- load the options into configFrame
    configFrame:SetLayout("Fill")
    configFrame.frame:SetMinResize(550, 400)

    configFrame:Hide()
    coroutine.yield()

    local journeyButton = AceGUI:Create("Button")
    journeyButton:SetWidth(140)
    journeyButton:SetPoint("TOPRIGHT", configFrame.frame, "TOPRIGHT", -50, -13)
    journeyButton:SetText(l10n('My Journey'))
    journeyButton:SetCallback("OnClick", function()
        QuestieOptions:OpenConfigWindow()
        QuestieJourney:ToggleJourneyWindow()
    end)

    configFrame:Hide()
    coroutine.yield()

    configFrame:AddChild(journeyButton)
    QuestieConfigFrame = configFrame
    table.insert(UISpecialFrames, "QuestieConfigFrame")

    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieOptions]: Initialization done")
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
        -- AceConfigDialog:Open("Questie", QuestieConfigFrame)
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
        Questie:Debug(Questie.DEBUG_SPAM, "DEBUG: global option", info[#info], "changed from '"..tostring(Questie.db.global[info[#info]]).."' to '"..tostring(value).."'")
    end
    Questie.db.global[info[#info]] = value
end

function QuestieOptions:AvailableQuestRedraw()
    QuestieQuest.CalculateAndDrawAvailableQuestsIterative()
end

function QuestieOptions:ClusterRedraw()
    Questie:Debug(Questie.DEBUG_INFO, "Clustering changed, redrawing!")
    --Redraw clusters here
    QuestieQuest:SmoothReset();
end



---@return table
_CreateOptionsTable = function()
    local general_tab = QuestieOptions.tabs.general:Initialize()
    coroutine.yield()
    local social_tab = QuestieOptions.tabs.social:Initialize()
    coroutine.yield()
    local minimap_tab = QuestieOptions.tabs.minimap:Initialize()
    coroutine.yield()
    local map_tab = QuestieOptions.tabs.map:Initialize()
    coroutine.yield()
    local dbm_hud_tab = QuestieOptions.tabs.dbm:Initialize()
    coroutine.yield()
    local tracker_tab = QuestieOptions.tabs.tracker:Initialize()
    coroutine.yield()
    local nameplate_tab = QuestieOptions.tabs.nameplate:Initialize()
    coroutine.yield()
    local tooltip_tab = QuestieOptions.tabs.tooltip:Initialize()
    coroutine.yield()
    local advanced_tab = QuestieOptions.tabs.advanced:Initialize()
    coroutine.yield()
    return {
        name = "Questie",
        handler = Questie,
        type = "group",
        childGroups = "tab",
        args = {
            general_tab = general_tab,
            social_tab = social_tab,
            minimap_tab = minimap_tab,
            map_tab = map_tab,
            dbm_hud_tab = dbm_hud_tab,
            tracker_tab = tracker_tab,
            nameplate_tab = nameplate_tab,
            tooltip_tab = tooltip_tab,
            advanced_tab = advanced_tab,
        }
    }
end
