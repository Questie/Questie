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
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

QuestieOptions.tabs = { ... }
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

    AceConfigDialog:SetDefaultSize("Questie", 640, 700)
    AceConfigDialog:Open("Questie", configFrame) -- load the options into configFrame
    configFrame:SetLayout("Fill")
    configFrame:EnableResize(false)
    QuestieCompat.SetResizeBounds(configFrame.frame, 550, 400)

    configFrame:Hide()
    coroutine.yield()

    local journeyButton = CreateFrame("Button", nil, configFrame.frame, "UIPanelButtonTemplate")
    journeyButton:SetWidth(140)
    journeyButton:SetPoint("TOPRIGHT", configFrame.frame, "TOPRIGHT", -50, -13)
    journeyButton:SetText(l10n("My Journey"))
    journeyButton:SetScript("OnClick", function()
        QuestieCombatQueue:Queue(function()
            QuestieJourney:ToggleJourneyWindow()
            QuestieOptions:ToggleConfigWindow()
        end)
    end)

    configFrame:Hide()
    coroutine.yield()

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
function QuestieOptions:ToggleConfigWindow()
    if not QuestieConfigFrame:IsShown() then
        PlaySound(882)
        -- AceConfigDialog:Open("Questie", QuestieConfigFrame)
        QuestieConfigFrame:Show()
    else
        QuestieConfigFrame:Hide()
    end
end

-- get option value
function QuestieOptions:GetProfileValue(info)
    return Questie.db.profile[info[#info]]
end

-- set option value
function QuestieOptions:SetProfileValue(info, value)
    if debug and Questie.db.profile[info[#info]] ~= value then
        Questie:Debug(Questie.DEBUG_SPAM, "DEBUG: global option", info[#info], "changed from '" .. tostring(Questie.db.profile[info[#info]]) .. "' to '" .. tostring(value) .. "'")
    end
    Questie.db.profile[info[#info]] = value
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
    local icons_tab = QuestieOptions.tabs.icons:Initialize()
    coroutine.yield()
    local tracker_tab = QuestieOptions.tabs.tracker:Initialize()
    coroutine.yield()
    local auto_tab = QuestieOptions.tabs.auto:Initialize()
    coroutine.yield()
    local nameplate_tab = QuestieOptions.tabs.nameplate:Initialize()
    coroutine.yield()
    local dbm_hud_tab = QuestieOptions.tabs.dbm:Initialize()
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
            icons_tab = icons_tab,
            tracker_tab = tracker_tab,
            auto_tab = auto_tab,
            nameplate_tab = nameplate_tab,
            dbm_hud_tab = dbm_hud_tab,
            advanced_tab = advanced_tab,
            profiles_tab = LibStub("AceDBOptions-3.0"):GetOptionsTable(Questie.db)
        }
    }
end

return QuestieOptions
