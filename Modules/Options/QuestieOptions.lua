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
---@type AceConfigDialog-3.0
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
    journeyButton:SetText(l10n("My Journey"))
    journeyButton:SetWidth(journeyButton:GetFontString():GetStringWidth() + 30)
    journeyButton:SetPoint("TOPRIGHT", configFrame.frame, "TOPRIGHT", -50, -13)
    journeyButton:SetScript("OnClick", function()
        QuestieCombatQueue:Queue(function()
            QuestieJourney:ToggleJourneyWindow()
            QuestieOptions:ToggleConfigWindow()
        end)
    end)

    do
        local tabGroup = configFrame.children[1]
        if tabGroup and tabGroup.type == "TabGroup" then
            local origCallback = tabGroup.events.OnGroupSelected
            tabGroup.events.OnGroupSelected = function(widget, event, uniquevalue)
                origCallback(widget, event, uniquevalue)
                if uniquevalue == "icons_tab" then
                    QuestieOptions:RefreshIconsTabButtons(widget)
                end
            end
        end
    end

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
        AceConfigDialog:Open("Questie", QuestieConfigFrame)
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

function QuestieOptions:RefreshIconsTabButtons(widget)
    if not widget then
        return
    end
    local function _AutoSize(container)
        if container.children then
            for _, child in ipairs(container.children) do
                if child.type == "Button" and child.SetAutoWidth then
                    child:SetAutoWidth(true)
                elseif child.children then
                    _AutoSize(child)
                end
            end
        end
    end
    _AutoSize(widget)
    local function _CenterButtons(parent)
        if parent.children then
            local buttons = {}
            for _, child in ipairs(parent.children) do
                if child.type == "Button" then
                    table.insert(buttons, child)
                end
            end
            if #buttons >= 2 and parent.content then
                local contentWidth = parent.content:GetWidth()
                if contentWidth and contentWidth > 0 then
                    local totalWidth = 0
                    for _, btn in ipairs(buttons) do
                        totalWidth = totalWidth + (btn.frame:GetWidth() or 0)
                    end
                    totalWidth = totalWidth + (#buttons - 1) * 4
                    local leftOffset = (contentWidth - totalWidth) / 2
                    if leftOffset > 0 then
                        for i, btn in ipairs(buttons) do
                            btn.frame:ClearAllPoints()
                            if i == 1 then
                                btn.frame:SetPoint("LEFT", parent.content, "LEFT", leftOffset, 0)
                            else
                                btn.frame:SetPoint("LEFT", buttons[i-1].frame, "RIGHT", 4, 0)
                            end
                        end
                        parent.content:SetScript("OnSizeChanged", function()
                            QuestieOptions:RefreshIconsTabButtons(widget)
                        end)
                    end
                end
            end
        end
    end
    local function _FindButtonContainers(container)
        if container.children then
            for _, child in ipairs(container.children) do
                if child.type ~= "Button" and child.content then
                    _CenterButtons(child)
                end
                if child.children then
                    _FindButtonContainers(child)
                end
            end
        end
    end
    _FindButtonContainers(widget)
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
