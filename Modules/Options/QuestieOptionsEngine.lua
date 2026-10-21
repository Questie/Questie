---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@class QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:CreateModule("QuestieOptionsEngine");
-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type Sounds
local Sounds = QuestieLoader:ImportModule("Sounds")
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")

local AceGUI = LibStub("AceGUI-3.0")
---@type AceConfigDialog-3.0
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

---- Explaining Questie's Native Settings Engine (introduced in 13.0.0?)
--
-- To define a few terms that will be used throughout this description:
--
-- Control - An element the user interacts with to adjust settings.
--             This could be a checkbox, slider, dropdown, etc.
--
-- Element - Any object placed on the canvas. All controls are elements, but there are
--             also non-control elements like containers, dividers, and text.
--
-- Canvas  - An area of the UI that the layout engine is placing elements on. Blizzard's
--             settings menu holds a canvas we can draw to, but we can also create
--             our own pop-up window with a canvas on it.
--
-- Questie's options menu consists of three main components: 'data', the 'constructor', and the 'layout engine'.
--
-- Data is the actual information that is used to build the settings, which are read and then
-- built dynamically (rather than static, hard-coded declarations) upon initialization.
--
-- The constructor is what takes the data, determines how to draw, and eventually draws each element,
-- based upon the data's parameters and our decisions for what each individual element looks like.
--
-- The layout engine iteratively ingests the data, feeds it to the constructor, and then after
-- receiving the rendered element from the constructor, actually places it on the canvas.
--
-- In essence, while the constructor builds each element, the layout engine determines how those
-- elements should be arranged relative to each other.
--
-- As long as there isn't a bug or you don't need new functionality, you should only need to modify
-- the data section in order to tweak, remove, or add new settings.
--
-- We (mostly) follow AceGUI's data structure, in the sense that each control only specifies relevant
-- data about itself, alongside a desired control width (but not height or coordinates). The layout
-- engine fills rows of controls until the row is horizontally full, then creates a new row, where it
-- begins populating the next set of controls.
--
-- One key difference versus AceGUI is that controls specify their width in fractions of the window width,
-- rather than set units. This allows the settings panel to render mostly the same regardless of window width,
-- simply stretching control width, unlike Ace which would reflow controls between rows if the window width changed.
--
-- Main differences going from AceGUI -> Native data structure:
-- 1. Tab top level data is not simply a group control. It needs title, subtitle, order, icon, and items fields.
--
-- 2. Many data fields are renamed: (this list is not exhaustive)
--   - name -> title
--   - desc -> description
--   - disabled -> enabled (inverted booleans)
--   - hidden -> visible (inverted booleans)
--
--   A full list of available data fields are detailed in QuestieOptionsEngine.BuildLayout()
--
-- 3. Many data fields behave differently now:
--   - Order fields are now 0-indexed instead of 1-indexed. If a tab is order 0, that becomes the 'primary' tab in the Blizzard options UI.
--   - width is still called width, but is now a percentage of available screen width, where 0.0 = 0% and 1.0 = 100%.
--   - title, description, label, and tooltip values now call l10n() within the options engine, so you don't need to specify the l10n function in data.
--
-- 4. Most controls are renamed. Full list of supported controls:
--   "checkbox"      Typical checkbox. AceGUI equivalent: "toggle"
--   "slider"        Slider between numeric values. AceGUI: "range"
--   "dropdown"      Dropdown or multi/combo box that lets you pick a single value from a preset list. AceGUI: "select"
--   "fontDropdown"  Nearly identical to a dropdown, except assumes the values are fonts, and renders each item with that font.
--   "divider"       Simple horizontal divider. Title optional. AceGUI: "header"
--   "container"     Container to group and nest other controls together. AceGUI: "group"
--   "text"          Simple text label. AceGUI: "description"
--   "button"        A button. The 'label' field is what appears on the button; 'title' is only used for the tooltip. AceGUI: "execute"
--   "soundButton"   A button, but instead of using a label field, it's square and shows a play symbol.
--   "colorPicker"   Opens a dialog allowing users to pick an RGB(A) color. AceGUI: "color"
--   "radioButton"   Similar to a checkbox in function, but used in conjunction and exclusive with other radio buttons. AceGUI: type "select", with style "radio".

QuestieOptionsEngine.tabs = { ... }

QuestieOptionsEngine.popup = nil

local registeredControls = {} -- Used to loop back and refresh enable/disable states later

-- Constants
local spacingX = 10 -- configurable horizontal gap between elements
local spacingY = 10 -- configurable vertical gap between elements
local indentingLevel = 20 -- Base amount of left/right padding for control render space for root controls. Controls in containers 1 level deep will use half this level, containers 2 levels deep will use 0.

local RenderMode = {
    BLIZZARD = 1,
    POPUP = 2,
}

local minControlHeight = { -- This is the starting height used for elements, but they can be larger if they overflow this size
    ["checkbox"]     = 30,
    ["slider"]       = 48,
    ["dropdown"]     = 50,
    ["fontDropdown"] = 50,
    ["textbox"]      = 50,
    ["divider"]      = 15,
    ["container"]    = 20,
    ["text"]         = 20,
    ["button"]       = 40,
    ["soundButton"]  = 40,
    ["colorPicker"]  = 40,
    ["radioButton"]  = 16,
}

local defaultLabelColor = {1, 0.82, 0, 1}
local defaultTextColor = {1, 1, 1, 1}

local disabledLabelColor = {0.65, 0.65, 0.65, 1}
local disabledTextColor = {0.55, 0.55, 0.55, 1}

local QuestieOptionsList = { -- Table containing option items
    GeneralTab = { -- General tab
        title = "General", -- Name of the tab, shown as a header in the panel and also used as the subcategory name
        subtitle = "General Settings",
        order = 0, -- the index used to sort control and tab hierarchy
        icon = 133736,
        items = { -- controls within the General tab
            checkbox1 = { -- element name, must be unique
                order = 1,
                title = "TestCheckbox1", -- user-readable text label
                description = "This is an example of Speex.", -- if present, shows helper text below the title
                tooltip = "This is an example of a checkbox.", -- tooltip shown to user when hovering over control
                type = "checkbox", -- valid options are: 'checkbox', 'slider', 'dropdown', 'container', 'divider', 'spacer'
                width = 1, -- total screen width this control occupies where 1 = 100%; if 'full', do not place the next control beside it, if both are 'half' (0.5) then do place them side-by-side
                get = function() return Questie.db.profile.checkbox1_value end,
                set = function(info, val) Questie.db.profile.checkbox1_value = val end,
                visible = true, -- whether this control is shown; this setting is only checked upon init, mainly used to filter options based on client expansion level (classic-only settings vs tbc-only)
                enabled = true, -- whether this control is enabled or disabled; this is re-calculated upon any settings change
            },
            slider1 = {
                order = 2,
                title = "Map Icon Scale",
                tooltip = "This is an example of a slider.",
                type = "slider",
                width = "half",
                get = function() return Questie.db.profile.slider1_value end,
                set = function(info, val) Questie.db.profile.slider1_value = val end,
                min = 0, -- the minimum value for the slider (left)
                max = 10, -- the maximum value for the slider (right)
                step = 0.2, -- the size of the 'steps' along the slider
                showvalue = true, -- Shows raw value below the slider
                minlabel = nil, -- label shown on the left side of the slider; if nil, show min value
                maxlabel = nil, -- label shown on the right side of the slider; if nil, show max value
                newline = true, -- if true, force begin a newline for this element
                enabled = function() return Questie.db.profile.checkbox1_value end,
            },
            slider2 = {
                order = 3,
                title = "Minimap Icon Scale",
                tooltip = "This is an example of a slider.",
                type = "slider",
                width = "half",
                get = function() return Questie.db.profile.slider2_value end,
                set = function(info, val) Questie.db.profile.slider2_value = val end,
                min = 0, -- the minimum value for the slider (left)
                max = 10, -- the maximum value for the slider (right)
                step = 0.2, -- the size of the 'steps' along the slider
                showvalue = true, -- Shows raw value below the slider
                minlabel = "Smaller", -- label shown on the left side of the slider; if nil, show min value
                maxlabel = "Bigger", -- label shown on the right side of the slider; if nil, show max value
            },
            container1 = {
                order = 4,
                title = "Container Title",
                type = "container", -- containers hold other controls within them, and only show a title labelling the container
                items = {
                    checkbox2 = {
                        order = 1,
                        title = "TestCheckbox2",
                        description = "This is a very long note and it should hopefully overflow",
                        tooltip = "This is an example of a checkbox within a container.",
                        type = "checkbox",
                        width = "half",
                        get = function() return Questie.db.profile.checkbox3_value end,
                        set = function(info, val) Questie.db.profile.checkbox3_value = val end,
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                    checkbox3 = {
                        order = 2,
                        title = "TestCheckbox3",
                        tooltip = "This is an example of a checkbox within a container.",
                        type = "checkbox",
                        width = "half",
                        get = function() return Questie.db.profile.checkbox3_value end,
                        set = function(info, val) Questie.db.profile.checkbox3_value = val end,
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                    divider1 = {
                        order = 2.5,
                        title = "Center Test",
                        type = "divider",
                        width = "full",
                    },
                    divider2 = {
                        order = 2.6,
                        title = "Left Test",
                        titleAlign = "LEFT",
                        type = "divider",
                        width = "full",
                    },
                    divider3 = {
                        order = 2.7,
                        title = "Right Test",
                        titleAlign = "RIGHT",
                        type = "divider",
                        width = "full",
                    },
                    container2 = {
                        order = 3,
                        title = "Subcontainer Title",
                        type = "container", -- containers hold other controls within them, and only show a title labelling the container
                        items = {
                                checkbox4 = {
                                    order = 3,
                                    title = "CompletedQuests",
                                    description = "This is a very long note and it should hopefully overflow. I am making this description very, very, very very long so it should really test the maxmimum limits. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                                    tooltip = "This is an example of a checkbox within a container. This one is almost similarly massively long. Please don't think too badly of me. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                    type = "checkbox",
                                    width = "half",
                                    get = function() return Questie.db.profile.checkbox4_value end,
                                    set = function(info, val) Questie.db.profile.checkbox4_value = val end,
                                },
                                checkbox5 = {
                                    order = 4,
                                    title = "RepeatableQuests",
                                    tooltip = "This is an example of a checkbox within a container.",
                                    type = "checkbox",
                                    width = "half",
                                    get = function() return Questie.db.profile.checkbox5_value end,
                                    set = function(info, val) Questie.db.profile.checkbox5_value = val end,
                                },
                        },
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                    radioButton1 = {
                        order = 4,
                        title = "radioButton1",
                        tooltip = "This is an example of a radio button within a container.",
                        type = "radioButton",
                        width = "full",
                        value = 1,
                        get = function() return Questie.db.profile.radiobuttontest_value == 1 end,
                        set = function(info, val) Questie.db.profile.radiobuttontest_value = val end,
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                    radioButton2 = {
                        order = 5,
                        title = "radioButton2",
                        tooltip = "This is an example of a radio button within a container.",
                        type = "radioButton",
                        width = "full",
                        value = 2,
                        get = function() return Questie.db.profile.radiobuttontest_value == 2 end,
                        set = function(info, val) Questie.db.profile.radiobuttontest_value = val end,
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                    radioButton3 = {
                        order = 6,
                        title = "radioButton3",
                        tooltip = "This is an example of a radio button within a container.",
                        type = "radioButton",
                        width = "full",
                        value = 3,
                        get = function() return Questie.db.profile.radiobuttontest_value == 3 end,
                        set = function(info, val) Questie.db.profile.radiobuttontest_value = val end,
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                    radioButton4 = {
                        order = 7,
                        title = "radioButton4",
                        tooltip = "This is an example of a radio button within a container.",
                        type = "radioButton",
                        width = "full",
                        value = 4,
                        get = function() return Questie.db.profile.radiobuttontest_value == 4 end,
                        set = function(info, val) Questie.db.profile.radiobuttontest_value = val end,
                        enabled = function() return Questie.db.profile.checkbox1_value end,
                    },
                },
            },
            text1 = {
                order = 4.5,
                title = "Lorem ipsum dolor sit amet",
                description = "Donec eleifend dui quis tortor dapibus facilisis. Nulla quis eleifend nisl, et sagittis risus. Morbi vehicula turpis justo, nec iaculis augue posuere quis. Aliquam risus mauris, ultricies vel risus in, vulputate consequat ante. Sed finibus enim vitae neque sagittis, eget ultrices nulla accumsan. Sed ullamcorper mattis est, a tincidunt metus bibendum sit amet. Nam eget odio nisi. Integer at est odio. Vestibulum velit mi, imperdiet ac arcu ac, malesuada sollicitudin lacus. Integer quis iaculis nisi, at luctus ex.",
                type = "text",
                width = "full",
                titleAlign = "CENTER",
                descriptionAlign = "CENTER",
                enabled = function() return Questie.db.profile.checkbox1_value end,
            },
            dropdown1 = {
                order = 5,
                title = "Dropdown 1",
                tooltip = "This is an example of a dropdown.",
                type = "dropdown",
                width = "full",
                get = function() return Questie.db.profile.dropdown1_value end,
                set = function(val) Questie.db.profile.dropdown1_value = val end,
                options = { -- the entries within the dropdown; index is the key, and text label shown is the value
                    ["Troll Male"]       = l10n("Troll Male"),
                    ["Troll Female"]     = l10n("Troll Female"),
                    ["Tauren Male"]      = l10n("Tauren Male"),
                    ["Tauren Female"]    = l10n("Tauren Female"),
                },
                enabled = function() return Questie.db.profile.checkbox1_value end,
            },
            fontDropdown1 = {
                order = 5.1,
                title = "Font Dropdown 1",
                tooltip = "This is an example of a font dropdown.",
                type = "fontDropdown",
                width = "full",
                get = function() return Questie.db.profile.trackerFontHeader or "Friz Quadrata TT" end,
                set = function(val)
                    Questie.db.profile.trackerFontHeader = val
                    QuestieTracker:Update()
                    end,
                enabled = function() return Questie.db.profile.checkbox1_value end,
                fonts = SharedMedia:HashTable("font"),
            },
            soundButton1 = { -- element name, must be unique
                order = 5.5,
                title = "SoundButton1", -- user-readable text label
                description = "This is an example of Speex.", -- if present, shows helper text below the title
                tooltip = "This is an example of a sound button.", -- tooltip shown to user when hovering over control
                type = "soundButton", -- valid options are: 'checkbox', 'slider', 'dropdown', 'container', 'divider', 'spacer'
                width = "full", -- total screen width this control occupies where 1 = 100%; if 'full', do not place the next control beside it, if both are 'half' (0.5) then do place them side-by-side
                align = "CENTER",
                func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel) end,
                visible = true, -- whether this control is shown; this setting is only checked upon init, mainly used to filter options based on client expansion level (classic-only settings vs tbc-only)
                enabled = function() return Questie.db.profile.checkbox1_value end,
            },
            checkbox6 = {
                order = 6,
                title = "Completed Quests",
                description = "This is a very long note and it should hopefully overflow",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "third",
                get = function() return Questie.db.profile.checkbox4_value end,
                set = function(info, val) Questie.db.profile.checkbox4_value = val end,
                newline = false,
            },
            checkbox7 = {
                order = 7,
                title = "RepeatableQuests7",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "third",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox8 = {
                order = 8,
                title = "RepeatableQuests8",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "third",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox9 = {
                order = 9,
                title = "RepeatableQuests9",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox10 = {
                order = 10,
                title = "RepeatableQuests10",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox11 = {
                order = 11,
                title = "RepeatableQuests11",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox12 = {
                order = 12,
                title = "RepeatableQuests12",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox13 = {
                order = 13,
                title = "RepeatableQuests13",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox14 = {
                order = 14,
                title = "RepeatableQuests14",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox15 = {
                order = 15,
                title = "RepeatableQuests15",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox16 = {
                order = 16,
                title = "RepeatableQuests16",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            checkbox17 = {
                order = 17,
                title = "RepeatableQuests17",
                tooltip = "This is an example of a checkbox within a container.",
                type = "checkbox",
                width = "half",
                get = function() return Questie.db.profile.checkbox5_value end,
                set = function(info, val) Questie.db.profile.checkbox5_value = val end,
            },
            colorPicker1 = {
                order = 17.8,
                title = "colorPicker1",
                description = "This is a very long note and it should hopefully overflow",
                tooltip = "This is an example of a color picker.",
                type = "colorPicker",
                width = "half",
                get = function()
                    local c = Questie.db.profile.trackerBackdropColor
                    return c.r, c.g, c.b, c.a
                end,
                set = function(r, g, b, a)
                    Questie.db.profile.trackerBackdropColor = {r = r, g = g, b = b, a = a}
                    if Questie.db.profile.trackerBackdropEnabled then
                        TrackerBaseFrame.baseFrame:SetBackdropColor(r, g, b, a)
                    end

                    if Questie.db.profile.trackerBorderEnabled then
                        TrackerBaseFrame.baseFrame:SetBackdropBorderColor(1, 1, 1, a)
                    end
                end,
                hasOpacity = true,
                enabled = function() return Questie.db.profile.checkbox1_value end,
            },
            button1 = { -- element name, must be unique
                order = 18,
                title = "Button 1", -- user-readable text label
                description = "This is an example of Speex.", -- if present, shows helper text below the title
                tooltip = "This is an example of a button.", -- tooltip shown to user when hovering over control
                type = "button", -- valid options are: 'checkbox', 'slider', 'dropdown', 'container', 'divider', 'spacer'
                width = "third", -- total screen width this control occupies where 1 = 100%; if 'full', do not place the next control beside it, if both are 'half' (0.5) then do place them side-by-side
                align = "CENTER",
                func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel) end,
                visible = true, -- whether this control is shown; this setting is only checked upon init, mainly used to filter options based on client expansion level (classic-only settings vs tbc-only)
                enabled = function() return Questie.db.profile.checkbox1_value end,
                btnLabel = "This is a very long label!",
            },
            button2 = { -- element name, must be unique
                order = 19,
                title = "Button 2", -- user-readable text label
                description = "This is an example of Speex.", -- if present, shows helper text below the title
                tooltip = "This is an example of a button.", -- tooltip shown to user when hovering over control
                type = "button", -- valid options are: 'checkbox', 'slider', 'dropdown', 'container', 'divider', 'spacer'
                width = "third", -- total screen width this control occupies where 1 = 100%; if 'full', do not place the next control beside it, if both are 'half' (0.5) then do place them side-by-side
                align = "CENTER",
                func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel) end,
                visible = true, -- whether this control is shown; this setting is only checked upon init, mainly used to filter options based on client expansion level (classic-only settings vs tbc-only)
                enabled = function() return Questie.db.profile.checkbox1_value end,
                btnLabel = "This is a very long label! It better overflow.",
            },
            button3 = { -- element name, must be unique
                order = 20,
                title = "Button 3", -- user-readable text label
                description = "This is an example of Speex.", -- if present, shows helper text below the title
                tooltip = "This is an example of a button.", -- tooltip shown to user when hovering over control
                type = "button", -- valid options are: 'checkbox', 'slider', 'dropdown', 'container', 'divider', 'spacer'
                width = "third", -- total screen width this control occupies where 1 = 100%; if 'full', do not place the next control beside it, if both are 'half' (0.5) then do place them side-by-side
                align = "CENTER",
                func = function() PlaySoundFile(Sounds.GetSelectedSoundFile(Questie.db.profile.questCompleteSoundChoiceName), Questie.db.profile.soundChannel) end,
                visible = true, -- whether this control is shown; this setting is only checked upon init, mainly used to filter options based on client expansion level (classic-only settings vs tbc-only)
                enabled = function() return Questie.db.profile.checkbox1_value end,
                btnLabel = "This is a very long label!",
            },
        }
    },
    SecondTab = { -- General tab
        title = "Secondary", -- Name of the tab, shown as a header in the panel and also used as the subcategory name
        subtitle = "Secondary Settings", -- Name of the tab, shown as a header in the panel and also used as the subcategory name
        order = 1, -- the index used to sort control and tab hierarchy
        items = {

        }
    },
}

local UsePlaceholderOptions = false

---@return table
local function CreateOptionsTable()
    if UsePlaceholderOptions then
        return QuestieOptionsList
    else
        local general_tab = QuestieOptionsEngine.tabs.general:Initialize()
        coroutine.yield()
        local icons_tab = QuestieOptionsEngine.tabs.icons:Initialize()
        coroutine.yield()
        local tracker_tab = QuestieOptionsEngine.tabs.tracker:Initialize()
        coroutine.yield()
        local auto_tab = QuestieOptionsEngine.tabs.auto:Initialize()
        coroutine.yield()
        local nameplate_tab = QuestieOptionsEngine.tabs.nameplate:Initialize()
        coroutine.yield()
        local dbm_hud_tab = QuestieOptionsEngine.tabs.dbm:Initialize()
        coroutine.yield()
        local advanced_tab = QuestieOptionsEngine.tabs.advanced:Initialize()
        coroutine.yield()
        local profiles_tab = QuestieOptionsEngine.tabs.profiles:Initialize()
        coroutine.yield()
        return {
            general_tab = general_tab,
            icons_tab = icons_tab,
            tracker_tab = tracker_tab,
            auto_tab = auto_tab,
            nameplate_tab = nameplate_tab,
            dbm_hud_tab = dbm_hud_tab,
            advanced_tab = advanced_tab,
            profiles_tab = profiles_tab,
        }
    end
end

local function DisableSnapping(tex)
    if tex and tex.SetSnapToPixelGrid then
        tex:SetSnapToPixelGrid(false)
        tex:SetTexelSnappingBias(0)
    end
end

-- Helper function to sort dictionary items by order key
local function GetSortedItems(itemsTable)
    local sorted = {}
    for key, data in pairs(itemsTable) do
        data.key = key
        table.insert(sorted, data)
    end
    table.sort(sorted, function(a, b)
        return (a.order or 999) < (b.order or 999)
    end)
    return sorted
end

local function ApplyTooltip(widget, item, attachPoint, x, y)
    if item.tooltip then
        widget:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, attachPoint, x or 0, y or 0)
            GameTooltip:SetText(item.title, nil, nil, nil)
            GameTooltip:AddLine(item.tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        widget:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

local function CreateControl(parent, item, width, height, level)
    local frame = CreateFrame("Button", nil, parent)
    frame:SetSize(width, height)

    frame.itemData = item

    if item.type == "checkbox" then

        -- Set up initial frames
        local cbWrapper = CreateFrame("Frame", nil, parent)
        cbWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        cbWrapper:SetSize(width, 30)

        cbWrapper.CheckBox = CreateFrame("CheckButton", nil, cbWrapper, "SettingsCheckboxTemplate")
        cbWrapper.CheckBox:SetPoint("LEFT", cbWrapper, "LEFT", 0, 0)

        -- Custom texture editing/manipulation

        -- Create disabled texture
        local tex = cbWrapper.CheckBox:CreateTexture(nil, "BACKGROUND", nil, 0)
        tex:SetAtlas("checkbox-minimal",nil,"TRILINEAR")
        tex:SetDesaturated(true)
        tex:SetVertexColor(0.7, 0.7, 0.7, 1)
        cbWrapper.CheckBox:SetDisabledTexture(tex)

        -- Anchor the base box to the lowest layer
        local normalTex = cbWrapper.CheckBox:GetNormalTexture()
        if normalTex then
            normalTex:SetDrawLayer("BACKGROUND", 0)
        end

        -- Create the hover texture in the middle layer
        local hoverTex = cbWrapper.CheckBox:CreateTexture(nil, "ARTWORK", nil, 1)
        hoverTex:SetAllPoints(cbWrapper.CheckBox, true)
        --hoverTex:SetPoint("CENTER", cbWrapper.CheckBox, "CENTER", 0, 0)
        -- Set your desired hover asset (e.g., custom atlas, highlight atlas, or additive box)
        hoverTex:SetTexture("Interface\\Addons\\Questie\\Icons\\checkbox-minimal-highlight.png")
        --hoverTex:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
        --hoverTex:SetSize(26, 24)
        hoverTex:SetBlendMode("ADD")
        --hoverTex:SetAtlas("checkbox-minimal", true)
        --hoverTex:SetBlendMode("ADD")
        hoverTex:SetAlpha(0.5)
        hoverTex:Hide()


        --local mask = cbWrapper.CheckBox:CreateMaskTexture(nil, "ARTWORK", nil, 1)
        --mask:SetTexture("interface\\hud\\uicooldownmanagermask")
        --mask:SetPoint("CENTER", hoverTex, "CENTER", 0, 0)
        --mask:SetSize(26, 24)
        --hoverTex:AddMaskTexture(mask)
        cbWrapper.CheckBox.HoverTex = hoverTex
        --cbWrapper.CheckBox.Mask = mask

        -- Force the checkmark to render on top of the hover texture
        local checkedTex = cbWrapper.CheckBox:GetCheckedTexture()
        if checkedTex then
            checkedTex:SetDrawLayer("OVERLAY", 1)
        end

        -- Ensure the disabled checked texture also stays on top if ever toggled while disabled
        local disabledCheckedTex = cbWrapper.CheckBox:GetDisabledCheckedTexture()
        if disabledCheckedTex then
            disabledCheckedTex:SetDrawLayer("OVERLAY", 1)
        end

        frame:RegisterForClicks("LeftButtonUp")
        frame:SetScript("OnClick", function(self, button, down)
            if (type(item.enabled) == "function" and item.enabled() == true) or (type(item.enabled) == "boolean" and item.enabled == true) then
                cbWrapper.CheckBox:Click()
            end
        end)

        cbWrapper.CheckBox:SetScript("OnEnter", function()
            local onEnter = frame:GetScript("OnEnter")
            if onEnter then onEnter(frame) end
        end)
        cbWrapper.CheckBox:SetScript("OnLeave", function()
            local onLeave = frame:GetScript("OnLeave")
            if onLeave then onLeave(frame) end
        end)

        local titleFrame = cbWrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
        titleFrame:SetText(item.title)
        titleFrame:SetWordWrap(true)
        titleFrame:SetJustifyH("LEFT")
        titleFrame:SetWidth(width - 40)
        frame.titleFrame = titleFrame

        local descriptionFrame = nil

        if not item.description then -- If there is no note, the label should be in-line with the checkbox
            titleFrame:SetPoint("LEFT", cbWrapper, "LEFT", 38, 0)

        else -- If there is a note, the label should be raised a bit to compensate
            titleFrame:SetPoint("LEFT", cbWrapper, "LEFT", 38, 6)

            descriptionFrame = cbWrapper:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            descriptionFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, -2)
            descriptionFrame:SetText(item.description)
            descriptionFrame:SetWordWrap(true)
            descriptionFrame:SetJustifyH("LEFT")
            descriptionFrame:SetWidth(width - 40)
            frame.descriptionFrame = descriptionFrame
        end

        if item.get then cbWrapper.CheckBox:SetChecked(item.get()) end
        cbWrapper.CheckBox:SetScript("OnClick", function(self)
            if item.set then item.set(self, self:GetChecked()) end
            QuestieOptionsEngine:RefreshStates()
        end)

        local function UpdateCheckboxHover()
            local isOver = (frame:IsMouseOver() or cbWrapper.CheckBox:IsMouseOver())
            local isEnabled = cbWrapper.CheckBox:IsEnabled()
            hoverTex:SetShown(isOver and isEnabled)
        end

        -- Hook the wrapper/row button
        frame:HookScript("OnEnter", UpdateCheckboxHover)
        frame:HookScript("OnLeave", UpdateCheckboxHover)

        -- Hook the CheckBox directly
        cbWrapper.CheckBox:HookScript("OnEnter", UpdateCheckboxHover)
        cbWrapper.CheckBox:HookScript("OnLeave", UpdateCheckboxHover)

        local labelHeight = titleFrame:GetStringHeight()
        local descriptionHeight = 0
        if item.description then descriptionHeight = descriptionFrame:GetStringHeight() + 2 end -- we add 2 if there's a note because we offset the note 2 units down
        local wrapperHeight = cbWrapper:GetHeight()

        local finalHeight = math.max(labelHeight + descriptionHeight, wrapperHeight)
        if finalHeight > wrapperHeight and descriptionFrame then
            frame:SetHeight(finalHeight)
            titleFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 38, 0)
        end

        frame.widget = cbWrapper.CheckBox

        ApplyTooltip(frame, item, "ANCHOR_TOPLEFT", 2, 0)

    elseif item.type == "slider" then
        local slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)
        slider:SetWidth(width - 30)
        slider:SetMinMaxValues(item.min or 0, item.max or 100)
        slider:SetValueStep(item.step or 1)
        slider:SetObeyStepOnDrag(true)
        frame.widget = slider

        if slider.Text then
            slider.Text:SetText(item.title)
            slider.Text:SetFontObject("GameFontNormalSmall2")
        end
        if slider.Low then
            slider.Low:SetText(item.minlabel or tostring(item.min or 0))
            slider.Low:SetFontObject("GameFontDisableTiny")
        end
        if slider.High then
            slider.High:SetText(item.maxlabel or tostring(item.max or 100))
            slider.High:SetFontObject("GameFontDisableTiny")
        end

        local valueDisplay
        if item.showValue then
            valueDisplay = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            valueDisplay:SetPoint("TOP", slider, "BOTTOM", 0, -1)
            frame.valueDisplay = valueDisplay
        end

        local startVal = 0
        if item.get then startVal = tonumber(item.get()) or item.min or 0 end
        slider:SetValue(startVal)
        if valueDisplay then valueDisplay:SetText(string.format("%g", startVal)) end

        slider:SetScript("OnValueChanged", function(self, value)
            if item.set then item.set(self, value) end
            if valueDisplay then valueDisplay:SetText(string.format("%g", value)) end
            QuestieOptionsEngine:RefreshStates()
        end)

        if slider.NineSlice then
            slider.NineSlice:Hide() -- this hides default artwork so we can draw our own
        end

        local thumb = slider:GetThumbTexture()
        if thumb then
            thumb:SetAtlas("Minimal_SliderBar_Button", true)

            thumb:SetSize(16, 16)
            frame.thumb = thumb
        end

        local trackLeft = slider:CreateTexture(nil, "BACKGROUND")
        trackLeft:SetAtlas("Minimal_SliderBar_Left", true)
        trackLeft:SetPoint("LEFT", slider, "LEFT", 0, 0)
--
        local trackRight = slider:CreateTexture(nil, "BACKGROUND")
        trackRight:SetAtlas("Minimal_SliderBar_Right", true)
        trackRight:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
--
        local trackMiddle = slider:CreateTexture(nil, "BACKGROUND")
        trackMiddle:SetAtlas("_Minimal_SliderBar_Middle", false)
        trackMiddle:SetPoint("LEFT", trackLeft, "RIGHT", 0, 0)
        trackMiddle:SetPoint("RIGHT", trackRight, "LEFT", 0, 0)
        trackMiddle:SetHeight(trackLeft:GetHeight())
--
        slider.TrackLeft = trackLeft
        slider.TrackRight = trackRight
        slider.TrackMiddle = trackMiddle

        ApplyTooltip(slider, item, "ANCHOR_TOP", 0, 14)

    elseif item.type == "dropdown" then
        local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -18)
        dropdown:SetWidth(width - 20)
        frame.widget = dropdown

        local titleFrame = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFrame:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 6, 2)
        titleFrame:SetText(item.title)
        frame.titleFrame = titleFrame

        dropdown:SetupMenu(function(owner, rootDescription)
            -- Resolve options if passed as a function or table
            local options = item.options
            if type(options) == "function" then
                options = options()
            end
            options = options or {}

            -- Resolve custom sort order if provided
            local sorting = item.sortOrder
            if type(sorting) == "function" then
                sorting = sorting()
            end

            local orderedKeys = {}

            if type(sorting) == "table" and #sorting > 0 then
                -- Use the explicit sort array, ensuring the key exists in options
                for _, key in ipairs(sorting) do
                    if options[key] ~= nil then
                        table.insert(orderedKeys, key)
                    end
                end
            else
                -- Fallback: extract all keys and sort alphabetically by display text
                for key in pairs(options) do
                    table.insert(orderedKeys, key)
                end
                table.sort(orderedKeys, function(a, b)
                    local textA = tostring(options[a] or a):lower()
                    local textB = tostring(options[b] or b):lower()
                    return textA < textB
                end)
            end

            for _, key in ipairs(orderedKeys) do
                local displayText = options[key]

                local isSelected = function()
                    return item.get and item.get() == key
                end

                local setSelected = function()
                    if item.set then item.set(key) end
                    QuestieOptionsEngine:RefreshStates()
                end

                rootDescription:CreateRadio(displayText, isSelected, setSelected, key)
            end
        end)

        ApplyTooltip(frame, item, "ANCHOR_TOPLEFT", 0, 0)

    elseif item.type == "fontDropdown" then
        local fontObjectCache = {}
        local fontCounter = 0

        local function GetFontPreviewObject(fontPath)
            if not fontObjectCache[fontPath] then
                fontCounter = fontCounter + 1
                local fontObj = CreateFont("QuestieDropdownFont_" .. fontCounter)
                local _, height, flags = GameFontHighlightSmall:GetFont()
                fontObj:SetFont(fontPath, 14, flags or "")
                fontObj:SetTextColor(unpack(defaultTextColor))
                fontObjectCache[fontPath] = fontObj
            end
            return fontObjectCache[fontPath]
        end

        local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -18)
        dropdown:SetWidth(width - 20)
        frame.widget = dropdown

        local titleFrame = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFrame:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 6, 2)
        titleFrame:SetText(item.title)
        frame.titleFrame = titleFrame

        dropdown:SetupMenu(function(owner, rootDescription)
            rootDescription:SetScrollMode(250)

            local fontNames = {}
            local fonts = item.fonts or {}
            for name in pairs(fonts) do
                table.insert(fontNames, name)
            end
            table.sort(fontNames, function(a, b) return a:lower() < b:lower() end)

            for _, fontName in ipairs(fontNames) do
                local fontPath = fonts[fontName]

                local isSelected = function()
                    return item.get and item.get() == fontName
                end
                local setSelected = function()
                    if item.set then item.set(fontName) end
                    QuestieOptionsEngine:RefreshStates()
                end

                local radio = rootDescription:CreateRadio(fontName, isSelected, setSelected, fontName)

                radio:AddInitializer(function(button, description, menu)
                    if button.fontString and fontPath then
                        local fontObj = GetFontPreviewObject(fontPath)
                        button.fontString:SetFontObject(fontObj)
                    end
                end)
            end
        end)

        ApplyTooltip(frame, item, "ANCHOR_TOPLEFT", 0, 0)

    elseif item.type == "divider" then
        local dividerWrapper = CreateFrame("Frame", nil, parent)
        dividerWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        dividerWrapper:SetSize(width, minControlHeight[item.type])

        if item.title == "" then
            local line = dividerWrapper:CreateTexture(nil, "ARTWORK")
            line:SetPoint("CENTER", dividerWrapper, "CENTER", 0, 0)
            line:SetSize(width, 1)
            line:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        else
            local titleFrame = dividerWrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
            titleFrame:SetText(item.title)

            if item.titleAlign == "LEFT" then
                titleFrame:SetPoint("LEFT", dividerWrapper, "LEFT", 0, 0)
                local lineRight = dividerWrapper:CreateTexture(nil, "ARTWORK")
                lineRight:SetPoint("RIGHT", dividerWrapper, "RIGHT", 0, 0)
                lineRight:SetPoint("LEFT", titleFrame, "RIGHT", 6, 0)
                lineRight:SetAtlas("Options_HorizontalDivider", true)
                DisableSnapping(lineRight)

            elseif item.titleAlign == "RIGHT" then
                titleFrame:SetPoint("RIGHT", dividerWrapper, "RIGHT", 0, 0)
                local lineLeft = dividerWrapper:CreateTexture(nil, "ARTWORK")
                lineLeft:SetPoint("LEFT", dividerWrapper, "LEFT", 0, 0)
                lineLeft:SetPoint("RIGHT", titleFrame, "LEFT", -6, 0)
                lineLeft:SetAtlas("Options_HorizontalDivider", true)
                lineLeft:SetTexCoord(1,0,0,1)
                DisableSnapping(lineLeft)

            else -- nil or centered (default)
                titleFrame:SetPoint("CENTER", dividerWrapper, "CENTER", 0, 0)
                local lineLeft = dividerWrapper:CreateTexture(nil, "ARTWORK")
                lineLeft:SetPoint("LEFT", dividerWrapper, "LEFT", 0, 0)
                lineLeft:SetPoint("RIGHT", titleFrame, "LEFT", -6, 0)
                lineLeft:SetAtlas("Options_HorizontalDivider", true)
                lineLeft:SetTexCoord(1,0.4,0,1)
                DisableSnapping(lineLeft)
                local lineRight = dividerWrapper:CreateTexture(nil, "ARTWORK")
                lineRight:SetPoint("RIGHT", dividerWrapper, "RIGHT", 0, 0)
                lineRight:SetPoint("LEFT", titleFrame, "RIGHT", 6, 0)
                lineRight:SetAtlas("Options_HorizontalDivider", true)
                lineRight:SetTexCoord(0.4,1,0,1)
                DisableSnapping(lineRight)

            end

            frame.titleFrame = titleFrame
        end

    elseif item.type == "container" then
        -- Calculate layout bleeding/overprint based on nesting depth
        local bleed = 0
        if level == 1 then bleed = indentingLevel
        elseif level == 2 then bleed = indentingLevel / 2
        end

        local containerFrame = CreateFrame("Frame", nil, frame, "NineSlicePanelTemplate")
        containerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", -bleed - 4, 2)
        containerFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", bleed + 1, -6)
        containerFrame:SetAlpha(0.45)
        containerFrame:SetFrameLevel(1)
        frame.containerFrame = containerFrame

        local optionSlice = {
            TopEdge = {
                atlas = "_OptionsFrame-NineSlice-EdgeTop",
            },
            BottomEdge = {
                atlas = "_OptionsFrame-NineSlice-EdgeBottom",
            },
            LeftEdge = {
                atlas = "!OptionsFrame-NineSlice-EdgeLeft",
            },
            RightEdge = {
                atlas = "!OptionsFrame-NineSlice-EdgeRight",
            },
            TopLeftCorner = {
                atlas = "OptionsFrame-NineSlice-CornerTopLeft",
            },
            TopRightCorner = {
                atlas = "OptionsFrame-NineSlice-CornerTopRight",
            },
            BottomLeftCorner = {
                atlas = "OptionsFrame-NineSlice-CornerBottomLeft",
            },
            BottomRightCorner = {
                atlas = "OptionsFrame-NineSlice-CornerBottomRight",
            },
        }

        NineSliceUtil.ApplyLayoutByName(containerFrame,"TooltipGluesLayout")

        local titleFrame = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -bleed + 30, 4)
        titleFrame:SetText(item.title)
        frame.titleFrame = titleFrame

        local content = CreateFrame("Frame", nil, frame)
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        frame.contentArea = content

    elseif item.type == "text" then
        local textWrapper = CreateFrame("Frame", nil, parent)
        textWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        textWrapper:SetSize(width, 30)

        local titleFrame = textWrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
        local initText = item.title
        if item.get then
            initText = item.get()
        end
        titleFrame:SetText(initText)
        titleFrame:SetWordWrap(true)
        titleFrame:SetJustifyH(item.titleAlign)
        titleFrame:SetWidth(width)
        if item.titleSize then
            titleFrame:SetFontHeight(item.titleSize)
        end
        frame.titleFrame = titleFrame

        local descriptionFrame = nil

        if not item.description then -- If there is no note, the label should be in-line with the checkbox
            titleFrame:SetPoint("LEFT", textWrapper, "LEFT", 0, 0)
        else -- If there is a note, the label should be raised a bit to compensate
            titleFrame:SetPoint("LEFT", textWrapper, "LEFT", 0, 6)
            descriptionFrame = textWrapper:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            descriptionFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, -2)
            descriptionFrame:SetText(item.description)
            descriptionFrame:SetWordWrap(true)
            descriptionFrame:SetJustifyH(item.descriptionAlign)
            descriptionFrame:SetWidth(width)
            if item.descriptionSize then
                descriptionFrame:SetFontHeight(item.descriptionSize)
            end
            frame.descriptionFrame = descriptionFrame
        end

        local labelHeight = titleFrame:GetStringHeight()
        local descriptionHeight = 0
        if item.description then descriptionHeight = descriptionFrame:GetStringHeight() + 2 end -- we add 2 if there's a description because we offset the description 2 units down
        local wrapperHeight = textWrapper:GetHeight()

        local finalHeight = math.max(labelHeight + descriptionHeight, wrapperHeight)
        if finalHeight > wrapperHeight and descriptionFrame then
            frame:SetHeight(finalHeight)
            titleFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        end

        ApplyTooltip(frame, item, "ANCHOR_TOPLEFT", 2, 0)

    elseif item.type == "button" then

        local RAW_ASSET_HEIGHT = 128
        local RAW_LEFT_WIDTH   = 114
        local RAW_RIGHT_WIDTH  = 292

        local buttonWrapper = CreateFrame("Frame", nil, parent)
        buttonWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        buttonWrapper:SetSize(width, height)

        buttonWrapper.Button = CreateFrame("Button", nil, buttonWrapper)
        local btn = buttonWrapper.Button

        local buttonHeight = 32
        local hPadding = 24
        local scale = buttonHeight / RAW_ASSET_HEIGHT

        local leftPieceWidth  = math.floor(RAW_LEFT_WIDTH * scale)
        local rightPieceWidth = math.floor(RAW_RIGHT_WIDTH * scale)
        local minWidth = leftPieceWidth + rightPieceWidth
        btn.maxWidth = width

        btn:SetHeight(buttonHeight)
        btn.minWidth = minWidth
        btn.horizontalPadding = hPadding

        local function CreateSliceGroup(atlasSet)
            if not atlasSet then return nil end

            local left = btn:CreateTexture(nil, "BACKGROUND")
            left:SetPoint("LEFT", btn, "LEFT", 0, 0)
            left:SetSize(leftPieceWidth, buttonHeight)
            left:SetAtlas(atlasSet.left, false)

            local right = btn:CreateTexture(nil, "BACKGROUND")
            right:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
            right:SetSize(rightPieceWidth, buttonHeight)
            right:SetAtlas(atlasSet.right, false)

            local center = btn:CreateTexture(nil, "BACKGROUND")
            center:SetPoint("LEFT", left, "RIGHT", 0, 0)
            center:SetPoint("RIGHT", right, "LEFT", 0, 0)
            center:SetHeight(buttonHeight)
            center:SetAtlas(atlasSet.center, false)
            center:SetHorizTile(true)

            return {
                left = left,
                center = center,
                right = right,
                SetShown = function(self, shown)
                    self.left:SetShown(shown)
                    self.center:SetShown(shown)
                    self.right:SetShown(shown)
                end,
            }
        end

        local groups = {
            normal   = CreateSliceGroup({ left = "128-RedButton-Left", center = "_128-RedButton-Center", right = "128-RedButton-Right" }),
            disabled = CreateSliceGroup({ left = "128-RedButton-Left-Disabled",  center = "_128-RedButton-Center-Disabled",  right = "128-RedButton-Right-Disabled"  }),
            pressed  = CreateSliceGroup({ left = "128-RedButton-Left-Pressed", center = "_128-RedButton-Center-Pressed", right = "128-RedButton-Right-Pressed" }),
        }

        local text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn:SetFontString(text)

        local function UpdateVisualState(self)
            local isEnabled = self:IsEnabled()
            local isPushed = self.isPressed and isEnabled

            if groups.disabled then
                groups.disabled:SetShown(not isEnabled)
            end
            if groups.pressed then
                groups.pressed:SetShown(isPushed)
            end
            if groups.normal then
                groups.normal:SetShown(isEnabled and not isPushed)
            end

            if not isEnabled then
                text:SetTextColor(unpack(disabledTextColor)) -- Gray, disabled
            else
                if self.isHovered then
                    text:SetTextColor(unpack(defaultTextColor)) -- White, hovered
                else
                    text:SetTextColor(unpack(defaultLabelColor)) -- Yellow, normal
                end
            end
        end

        btn:SetHighlightAtlas("128-RedButton-Highlight")
        btn:HookScript("OnMouseDown", function(self, buttonName)
            if self:IsEnabled() and buttonName == "LeftButton" then
                self.isPressed = true
                UpdateVisualState(self)
            end
        end)
        btn:HookScript("OnMouseUp", function(self, buttonName)
            if buttonName == "LeftButton" then
                self.isPressed = false
                UpdateVisualState(self)
            end
        end)
        btn:HookScript("OnEnter", function(self)
            if self:IsEnabled() then
                self.isHovered = true
                UpdateVisualState(self)
            end
        end)
        btn:HookScript("OnLeave", function(self)
            self.isHovered = false
            UpdateVisualState(self)
        end)
        btn:HookScript("OnEnable", UpdateVisualState)
        btn:HookScript("OnDisable", UpdateVisualState)

        local rawSetText = btn.SetText
        btn.SetText = function(self, newText)
            text:SetWidth(0)
            text:SetHeight(0)
            text:SetWordWrap(false)

            rawSetText(self, newText)

            local strWidth = text:GetStringWidth() or 0
            local targetWidth = math.max(self.minWidth, strWidth + self.horizontalPadding)
            local isExpanded = false

            if self.maxWidth and targetWidth > self.maxWidth then
                targetWidth = self.maxWidth
                isExpanded = true
            end

            local currentHeight = isExpanded and (buttonHeight * 1.5) or buttonHeight

            local currentScale = currentHeight / RAW_ASSET_HEIGHT
            local currentLeftWidth = math.floor(RAW_LEFT_WIDTH * currentScale)
            local currentRightWidth = math.floor(RAW_RIGHT_WIDTH * currentScale)

            self:SetSize(targetWidth, currentHeight)

            for _, group in pairs(groups) do
                if group then
                    group.left:SetSize(currentLeftWidth, currentHeight)
                    group.right:SetSize(currentRightWidth, currentHeight)
                    group.center:SetHeight(currentHeight)
                end
            end

            if isExpanded then
                text:SetWidth(targetWidth - self.horizontalPadding)
                text:SetHeight(currentHeight - 8)
                text:SetWordWrap(true)
                text:SetJustifyV("MIDDLE")
            end
        end

        UpdateVisualState(btn) -- trigger once after creation to get correct state

        buttonWrapper.Button:SetText(item.btnLabel)
        buttonWrapper.Button:SetPoint(item.align, buttonWrapper, item.align, 0, 0)
        buttonWrapper.Button:SetScript("OnClick", function(self, buttonName, down)
            if item.func then
                item.func()
            end
        end)
        frame.widget = buttonWrapper.Button
        ApplyTooltip(frame.widget, item, "ANCHOR_TOPLEFT", 2, 0)

    elseif item.type == "soundButton" then

        local buttonWrapper = CreateFrame("Frame", nil, parent)
        buttonWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        buttonWrapper:SetSize(width, height)

        buttonWrapper.Button = CreateFrame("Button", nil, buttonWrapper)
        buttonWrapper.Button:SetSize(32, 32)
        buttonWrapper.Button:SetPoint(item.align, buttonWrapper, item.align, 0, 0)

        local function CreateStateTexture(atlasKey, degrees, flipV, flipH)
            if not atlasKey then return nil end

            local tex = buttonWrapper.Button:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints(buttonWrapper.Button)
            tex:SetAtlas(atlasKey,nil,"TRILINEAR")

            if flipV and not flipH then
                tex:SetTexCoord(0,1,1,0)
            elseif not flipV and flipH then
                tex:SetTexCoord(1,0,0,1)
            elseif flipV and flipH then
                tex:SetTexCoord(1,1,1,1)
            end

            if degrees then
                tex:SetRotation(math.rad(degrees or 0))
            end

            return tex
        end

        local btnNormal = CreateStateTexture("128-RedButton-ArrowDown", 90, false, true)
        local btnPushed = CreateStateTexture("128-RedButton-ArrowDown-Pressed", -90, true)
        local btnDisabled = CreateStateTexture("128-RedButton-ArrowDown-Disabled", 90, false, true)
        local btnHighlight = CreateStateTexture("128-RedButton-ArrowDown-Highlight", 90)
        buttonWrapper.Button:SetNormalTexture(btnNormal)
        buttonWrapper.Button:SetPushedTexture(btnPushed)
        buttonWrapper.Button:SetDisabledTexture(btnDisabled)
        buttonWrapper.Button:SetHighlightTexture(btnHighlight)

        buttonWrapper.Button:SetScript("OnClick", function(self, buttonName, down)
            if item.func then
                item.func()
            end
        end)

        frame.widget = buttonWrapper.Button

        ApplyTooltip(frame.widget, item, "ANCHOR_TOPLEFT", 2, 0)

    elseif item.type == "colorPicker" then

        local cpWrapper = CreateFrame("Frame", nil, parent)
        cpWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        cpWrapper:SetSize(width, 30)

        local swatchButton = CreateFrame("Button", nil, cpWrapper)
        swatchButton:SetSize(28, 28)
        swatchButton:SetPoint("LEFT", cpWrapper, "LEFT", 0, 0)

        -- Border (circle art)
        local border = swatchButton:CreateTexture(nil, "ARTWORK")
        if Questie.IsForever then
            border:SetAtlas("UI-HUD-Minimap-Frame-Cycle")
            border:SetSize(28, 28)
        else
            border:SetAtlas("Trinket-Frame")
            border:SetSize(34, 34)
        end
        border:SetPoint("CENTER", swatchButton, "CENTER", 0, 0)
        swatchButton.border = border

        -- Inner color swatch
        local swatch = swatchButton:CreateTexture(nil, "BACKGROUND")
        swatch:SetColorTexture(1, 1, 1, 1)
        swatch:SetSize(18, 18)
        swatch:SetPoint("CENTER", swatchButton, "CENTER", 0, 0)
        swatchButton.swatch = swatch

        -- Mask color swatch to a circle
        local mask = swatchButton:CreateMaskTexture()
        mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(swatch)
        swatch:AddMaskTexture(mask)

        frame:RegisterForClicks("LeftButtonUp")
        frame:SetScript("OnClick", function(self, button, down)
            if (type(item.enabled) == "function" and item.enabled() == true) or (type(item.enabled) == "boolean" and item.enabled == true) or item.enabled == nil then
                swatchButton:Click()
            end
        end)

        swatchButton:SetScript("OnEnter", function()
            if frame:GetScript("OnEnter") then frame:GetScript("OnEnter")(frame) end
        end)
        swatchButton:SetScript("OnLeave", function()
            if frame:GetScript("OnLeave") then frame:GetScript("OnLeave")(frame) end
        end)

        local titleFrame = cpWrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
        titleFrame:SetText(item.title)
        titleFrame:SetWordWrap(true)
        titleFrame:SetJustifyH("LEFT")
        titleFrame:SetWidth(width - 40)
        frame.titleFrame = titleFrame

        local descriptionFrame = nil

        if not item.description then
            titleFrame:SetPoint("LEFT", cpWrapper, "LEFT", 38, 0)
        else
            titleFrame:SetPoint("LEFT", cpWrapper, "LEFT", 38, 6)

            descriptionFrame = cpWrapper:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            descriptionFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, -2)
            descriptionFrame:SetText(item.description)
            descriptionFrame:SetWordWrap(true)
            descriptionFrame:SetJustifyH("LEFT")
            descriptionFrame:SetWidth(width - 40)
            frame.descriptionFrame = descriptionFrame
        end

        -- ColorPicker-specific logic

        -- Classic API returns 0 = opaque, 1 = transparent from color picker.
        -- Modern API returns 1 = transparent, 0 = opaque from color picker.
        -- This function converts between the two as needed.
        local function ConvertPickerAlpha(a)
            if not Questie.IsForever then
                return 1 - (a or 1)
            end
            return a or 1
        end

        swatchButton:SetScript("OnClick", function()
            local curR, curG, curB, curA = 1, 1, 1, 1
            if item.get then
                curR, curG, curB, curA = item.get()
            end

            local function GetCurrentAlpha()
                if not item.hasOpacity then return 1 end
                return ConvertPickerAlpha(ColorPickerFrame:GetColorAlpha())
            end

            local info = {
                swatchFunc = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    local a = GetCurrentAlpha()
                    if item.set then item.set(r, g, b, a) end
                    QuestieOptionsEngine:RefreshStates()
                end,
                opacityFunc = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    local a = GetCurrentAlpha()
                    --UpdateSwatchDisplay(r, g, b, a)
                    if item.set then item.set(r, g, b, a) end
                    QuestieOptionsEngine:RefreshStates()
                end,
                cancelFunc = function()
                    local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues();
                    newA = ConvertPickerAlpha(newA)
                    --UpdateSwatchDisplay(newR, newG, newB, newA)
                    if item.set then item.set(newR, newG, newB, newA) end
                    QuestieOptionsEngine:RefreshStates()
                end,
                r = curR,
                g = curG,
                b = curB,
                opacity = ConvertPickerAlpha(curA),
                hasOpacity = item.hasOpacity or false,
                previousValues = { r = curR, g = curG, b = curB, a = curA },
            }

            ColorPickerFrame:SetupColorPickerAndShow(info)
        end)

        local labelHeight = titleFrame:GetStringHeight()
        local descriptionHeight = 0
        if item.description then descriptionHeight = descriptionFrame:GetStringHeight() + 2 end
        local wrapperHeight = cpWrapper:GetHeight()

        local finalHeight = math.max(labelHeight + descriptionHeight, wrapperHeight)
        if finalHeight > wrapperHeight and descriptionFrame then
            frame:SetHeight(finalHeight)
            titleFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 38, 0)
        end

        frame.widget = swatchButton

        ApplyTooltip(frame, item, "ANCHOR_TOPLEFT", 2, 0)
    elseif item.type == "radioButton" then

        -- There is genuinely not a good radio button class to base this off of.
        -- So we implement our own from scratch using checkboxes as a template.

        local rbWrapper = CreateFrame("Frame", nil, parent)
        rbWrapper:SetPoint("LEFT", frame, "LEFT", 0, 0)
        rbWrapper:SetSize(width, 20)

        rbWrapper.RadioButton = CreateFrame("CheckButton", nil, rbWrapper, "SettingsCheckboxTemplate")
        rbWrapper.RadioButton:SetPoint("LEFT", rbWrapper, "LEFT", 0, 0)

        if Questie.IsForever then
            local texNormal = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texNormal:SetAtlas("gamepad-flyout-circular-slot-normal",nil,"TRILINEAR")
            rbWrapper.RadioButton:SetNormalTexture(texNormal)

            local texPushed = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texPushed:SetAtlas("gamepad-flyout-circular-slot-normal",nil,"TRILINEAR")
            rbWrapper.RadioButton:SetPushedTexture(texPushed)

            local texDisabled = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texDisabled:SetAtlas("gamepad-flyout-circular-slot-disabled",nil,"TRILINEAR")
            rbWrapper.RadioButton:SetDisabledTexture(texDisabled)

            local texChecked = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texChecked:SetAtlas("common-dropdown-icon-radialtick-yellow",nil,"TRILINEAR")
            rbWrapper.RadioButton:SetCheckedTexture(texChecked)

            local texCheckedDisabled = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texCheckedDisabled:SetAtlas("common-dropdown-icon-radialtick-yellow",nil,"TRILINEAR")
            texCheckedDisabled:SetDesaturated(true)
            rbWrapper.RadioButton:SetDisabledCheckedTexture(texCheckedDisabled)
        else
            rbWrapper.RadioButton:SetPoint("LEFT", rbWrapper, "LEFT", 4, 0)
            rbWrapper.RadioButton:SetSize(22,22)

            local texNormal = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texNormal:SetTexture("interface\\common\\commondropdownclassic2x",nil,nil,"TRILINEAR")
            texNormal:SetTexCoord((285/512),(329/512),(121/512),(165/512))
            rbWrapper.RadioButton:SetNormalTexture(texNormal)

            local texPushed = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texPushed:SetTexture("interface\\common\\commondropdownclassic2x",nil,nil,"TRILINEAR")
            texPushed:SetTexCoord((285/512),(329/512),(121/512),(165/512))
            rbWrapper.RadioButton:SetPushedTexture(texPushed)

            local texDisabled = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texDisabled:SetTexture("interface\\common\\commondropdownclassic2x",nil,nil,"TRILINEAR")
            texDisabled:SetTexCoord((285/512),(329/512),(121/512),(165/512))
            texDisabled:SetDesaturated(true)
            rbWrapper.RadioButton:SetDisabledTexture(texDisabled)

            local texChecked = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texChecked:SetTexture("interface\\common\\commondropdownclassic2x",nil,nil,"TRILINEAR")
            texChecked:SetTexCoord((465/512),(509/512),(1/512),(45/512))
            rbWrapper.RadioButton:SetCheckedTexture(texChecked)

            local texCheckedDisabled = rbWrapper.RadioButton:CreateTexture(nil, "ARTWORK")
            texCheckedDisabled:SetTexture("interface\\common\\commondropdownclassic2x",nil,nil,"TRILINEAR")
            texCheckedDisabled:SetTexCoord((465/512),(509/512),(1/512),(45/512))
            texCheckedDisabled:SetDesaturated(true)
            rbWrapper.RadioButton:SetDisabledCheckedTexture(texCheckedDisabled)
        end

        frame:RegisterForClicks("LeftButtonUp")
        frame:SetScript("OnClick", function(self, button, down)
            if (type(item.enabled) == "function" and item.enabled() == true) or (type(item.enabled) == "boolean" and item.enabled == true) then
                rbWrapper.RadioButton:Click()
            end
        end)

        rbWrapper.RadioButton:SetScript("OnEnter", function()
            local onEnter = frame:GetScript("OnEnter")
            if onEnter then onEnter(frame) end
        end)
        rbWrapper.RadioButton:SetScript("OnLeave", function()
            local onLeave = frame:GetScript("OnLeave")
            if onLeave then onLeave(frame) end
        end)

        local titleFrame = rbWrapper:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
        titleFrame:SetText(item.title)
        titleFrame:SetWordWrap(true)
        titleFrame:SetJustifyH("LEFT")
        titleFrame:SetWidth(width - 40)
        frame.titleFrame = titleFrame

        local descriptionFrame = nil

        if not item.description then -- If there is no note, the label should be in-line with the checkbox
            titleFrame:SetPoint("LEFT", rbWrapper, "LEFT", 38, 0)

        else -- If there is a note, the label should be raised a bit to compensate
            titleFrame:SetPoint("LEFT", rbWrapper, "LEFT", 38, 6)

            descriptionFrame = rbWrapper:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            descriptionFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT", 0, -2)
            descriptionFrame:SetText(item.description)
            descriptionFrame:SetWordWrap(true)
            descriptionFrame:SetJustifyH("LEFT")
            descriptionFrame:SetWidth(width - 40)
            frame.descriptionFrame = descriptionFrame
        end

        if item.get then
            rbWrapper.RadioButton:SetChecked(item.get(item.value))
            QuestieOptionsEngine:RefreshStates()
        end

        rbWrapper.RadioButton:SetScript("OnClick", function(self)
            if item.set then
                item.set(item.value)
            end
            QuestieOptionsEngine:RefreshStates()
        end)

        local labelHeight = titleFrame:GetStringHeight()
        local descriptionHeight = 0
        if item.description then descriptionHeight = descriptionFrame:GetStringHeight() + 2 end -- we add 2 if there's a note because we offset the note 2 units down
        local wrapperHeight = rbWrapper:GetHeight()

        local finalHeight = math.max(labelHeight + descriptionHeight, wrapperHeight)
        if finalHeight > wrapperHeight and descriptionFrame then
            frame:SetHeight(finalHeight)
            titleFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 38, 0)
        end

        frame.widget = rbWrapper.RadioButton

        ApplyTooltip(frame, item, "ANCHOR_TOPLEFT", 2, 0)
    elseif item.type == "textbox" then
        local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        editBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -18)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject("ChatFontNormal")
        frame.widget = editBox

        local titleFrame = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFrame:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", -2, 4)
        titleFrame:SetText(item.title)
        frame.titleFrame = titleFrame

        -- Confirmation "Okay" button (matches AceGUI EditBox behavior)
        local okBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        okBtn:SetSize(60, 22)
        okBtn:SetPoint("LEFT", editBox, "RIGHT", 6, 0)
        okBtn:SetText(OKAY or "Okay")
        okBtn:Hide()
        frame.okBtn = okBtn

        -- Leave room on the right for the Okay button
        editBox:SetSize(width - 26 - 66, 22)

        local function CommitText()
            local text = editBox:GetText()
            editBox:ClearFocus()
            okBtn:Hide()
            if item.set then
                item.set(text)
            end
            QuestieOptionsEngine:RefreshStates()
        end

        if item.get then
            editBox:SetText(tostring(item.get() or ""))
        end

        editBox:SetScript("OnTextChanged", function(self, isUserInput)
            if isUserInput then
                local currentVal = item.get and tostring(item.get() or "") or ""
                local enteredText = self:GetText()
                if enteredText ~= currentVal and strtrim(enteredText) ~= "" then
                    okBtn:Show()
                else
                    okBtn:Hide()
                end
            end
        end)

        editBox:SetScript("OnEnterPressed", CommitText)
        okBtn:SetScript("OnClick", CommitText)

        editBox:SetScript("OnEscapePressed", function(self)
            if item.get then
                self:SetText(tostring(item.get() or ""))
            end
            self:ClearFocus()
            okBtn:Hide()
        end)

        editBox:SetScript("OnEditFocusLost", function(self)
            -- Prevent resetting if the user clicked the Okay button itself
            if not okBtn:IsMouseOver() then
                if item.get then
                    self:SetText(tostring(item.get() or ""))
                end
                okBtn:Hide()
            end
        end)

        ApplyTooltip(editBox, item, "ANCHOR_TOPLEFT", 0, 0)
    end

    table.insert(registeredControls, frame)
    return frame
end

local function BuildLayout(parentFrame, itemsTable, maxWidth, level, categoryName)
    -- The BuildLayout function is fed a table of control data and populates an already-spawned frame with controls based on our layout rules.
    -- It first ingests this data raw, sorts it, sanitizes it, then begins building controls in order.
    -- BuildLayout goes through multiple passes when placing controls; it first creates the control, then creates the rest
    -- of the controls on the same row until the row is filled. Once the row is filled, it goes back through and adjusts the
    -- completed row to be the height that the largest control ended up being (which accounts for word-wrapped text,
    -- including longer strings from translations). This final pass ensures that controls are aligned vertically on a grid relative to each other.

    level = level or 1 -- effectively current Z layer; used to determine if we're drawing on the root canvas, container, or nested container
    local sortedItems = GetSortedItems(itemsTable) -- ingests item data and sorts it according to order value

    local cursorX = 0 -- the current horizontal destination for drawing new elements
    local cursorY = 0 -- the current vertical destination for drawing new elements
    local currentMaxRowHeight = 0 -- the bounding box height of the current row, so we know how far to move the cursorY down when beginning a new row
    local currentRowFrames = {} -- Tracks frames on the immediate line
    local rowStartY = -10 -- Tracks the absolute top of the current row

    -- Detect if we're within a container or actual page
    if level == 1 then
        cursorY = 0 -- If root panel, draw right against top edge
    elseif level > 1 then
        cursorY = -10 -- Leave room for art at top of containers
    end

    for _, rawitem in ipairs(sortedItems) do

        local function safe_l10n(val)
            if val == nil then
                return nil
            end

            -- If a table of format arguments was passed: unpack into l10n
            if type(val) == "table" then
                return l10n(unpack(val))
            end

            -- Otherwise, regular string / single value
            return l10n(val)
        end

        -- Sanitizer & Defaults
        local item = {
            order = rawitem.order or 0,                                -- the index used to sort control and tab hierarchy, required for all items
            type = rawitem.type or "",                                 -- valid options are: checkbox, slider, dropdown, container, divider, spacer, text, button, soundButton
            title = safe_l10n(rawitem.title),                          -- user-readable text label
            description = safe_l10n(rawitem.description),              -- description of the control, appears below the label in small white text (checkboxes only)
            tooltip = safe_l10n(rawitem.tooltip),                      -- text shown in tooltip when hovering over control (longer description)
            get = rawitem.get,                                         -- function used to determine what state the control should show (get value of variable)
            set = rawitem.set,                                         -- function used to set the target variable when the control is used
            value = rawitem.value,                                     -- radio button value for this control
            width = rawitem.width or 0.5,                              -- screen width this control occupies where 1 = 100%; also accepts 'full' = 1 and 'half' = 0.5
            newline = rawitem.newline or false,                        -- if true, force this element to be at the start of a new line
            visible = rawitem.visible == nil or rawitem.visible,       -- whether this control is shown; this setting is only checked upon init, mainly used to filter options based on client expansion level (classic-only settings vs tbc-only)
            enabled = rawitem.enabled == nil or rawitem.enabled,       -- whether this control is enabled or disabled; this is re-evaluated upon any settings change
            min = rawitem.min or 0,                                    -- the minimum value for a slider (left)
            max = rawitem.max or 10,                                   -- the maximum value for a slider (right)
            step = rawitem.step or 0.1,                                -- the size of the 'steps' along a slider
            showValue = rawitem.showValue == nil or rawitem.showValue, -- whether or not to show the raw value beneath a slider
            minLabel = safe_l10n(rawitem.minLabel),                    -- label shown on the left side of a slider; if nil, show min value
            maxLabel = safe_l10n(rawitem.maxLabel),                    -- label shown on the right side of a slider; if nil, show max value
            options = rawitem.options,                                 -- a list of entries within a dropdown
            sortOrder = rawitem.sortOrder,                             -- a sorted table of keys matching item.options that can be used as a sort order
            items = rawitem.items,                                     -- a nested array of controls within a container
            titleAlign = rawitem.titleAlign,                           -- title text alignment
            titleSize = rawitem.titleSize,                             -- title text font size
            descriptionAlign = rawitem.descriptionAlign or "LEFT",     -- description text alignment
            descriptionSize = rawitem.descriptionSize,                 -- description text font size
            func = rawitem.func,                                       -- function called when control is pressed (buttons only)
            align = rawitem.align or "LEFT",                           -- control alignment within its spacer/wrapper (only noticeable with buttons)
            btnLabel = safe_l10n(rawitem.btnLabel),                    -- text label placed on a button (may differ from title used in tooltips)
            fonts = rawitem.fonts,                                     -- list of fonts to select from
            hasOpacity = rawitem.hasOpacity or false,                  -- whether a colorPicker should show an alpha selector alongside RGB
        }

        if item.titleAlign == nil then
            if item.type == "divider" then
                item.titleAlign = "CENTER"
            else
                item.titleAlign = "LEFT"
            end
        end

        if item.visible ~= false then
            -- Convert strings to actual values
            if item.width == "half" then item.width = 0.5
            elseif item.width == "full" then item.width = 1.0
            elseif item.width == "third" then item.width = 0.32 -- because of rounding quirks, defining 0.33 causes third elements to wrap
            elseif item.width == "quarter" then item.width = 0.25
            end

            if (item.type == "container" or item.type == "divider") and item.width ~= 1.0 then
                item.width = 1.0
            end

            -- Determine actual unit width for this control by multiplying its percentage width by the unit width of its canvas
            local controlWidth = maxWidth * item.width

            -- If the control won't be a full line, then shrink it to leave room for horizontal gap space
            if item.width < 1.0 then
                controlWidth = controlWidth - (spacingX / 2)
            end

            -- Check if the incoming item forces a new row
            local isFullWidth = (item.width == 1.0)
            local needsNewRow = (cursorX + controlWidth > maxWidth)
                or (item.type == "divider")
                or (item.type == "container")
                or (item.newline == true)
                or (isFullWidth and cursorX > 0) -- Only force wrap if previous items exist on this row

            if needsNewRow and #currentRowFrames > 0 then
                -- We've determined we've exceeded the previous row;
                -- go back and vertically align all of the previous row's
                -- elements with each other before moving on
                if #currentRowFrames > 1 then
                    for _, rFrame in ipairs(currentRowFrames) do
                        local fHeight = rFrame:GetHeight()
                        if fHeight < currentMaxRowHeight then -- If this control is shorter than the tallest item on its line
                            local offset = (currentMaxRowHeight - fHeight) / 2 -- Calculate how much empty space is left, and split it in half
                            local point, relTo, relPoint, xOfs = rFrame:GetPoint(1) -- Pull its existing X coordinate so we don't break horizontal flow
                            rFrame:SetPoint(point, relTo, relPoint, xOfs, cursorY - offset) -- Re-anchor it shifted downwards relative to where the row started
                        end
                    end
                end

                -- Clear the running tally of row elements so the next row starts fresh
                wipe(currentRowFrames)
                cursorY = cursorY - currentMaxRowHeight - spacingY
                cursorX = 0
                currentMaxRowHeight = 0
            end

            ---- Time to begin rendering the new control

            if item.type == "container" and item.title then
                -- If we're in a container, begin rendering the row after the start of
                -- a container with a starting gap, to not overlap the container's title
                cursorY = cursorY - 24
            end

            -- Shift absolute rendering coordinate rightward if on root layer
            local absoluteX = cursorX
            if level == 1 then
                absoluteX = cursorX + indentingLevel
            end

            local control = CreateControl(parentFrame, item, controlWidth, minControlHeight[item.type] or 40, level)
            control:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", absoluteX, cursorY)
            table.insert(currentRowFrames, control)

            if item.type == "container" and item.items then
                local innerConsumedHeight = BuildLayout(control.contentArea, item.items, maxWidth, level + 1)
                control:SetHeight(innerConsumedHeight + spacingY)
            end

            -- If the control is larger than the current row height, expand the row height to fit it
            if control:GetHeight() > currentMaxRowHeight then
                currentMaxRowHeight = control:GetHeight()
            end

            -- Advance cursorX or immediately flush full-width rows
            if isFullWidth or item.type == "divider" then
                cursorY = cursorY - currentMaxRowHeight - spacingY
                cursorX = 0
                currentMaxRowHeight = 0
                wipe(currentRowFrames)
            else
                cursorX = cursorX + controlWidth + spacingX
            end
        end
    end

    -- Before we finish, do a vertical alignment on the final row
    if #currentRowFrames > 1 then
        for _, rFrame in ipairs(currentRowFrames) do
            local fHeight = rFrame:GetHeight()

            -- If this control is shorter than the tallest item on its line
            if fHeight < currentMaxRowHeight then
                -- Calculate how much empty space is left, and split it in half
                local offset = (currentMaxRowHeight - fHeight) / 2

                -- Pull its existing X coordinate so we don't break horizontal flow
                local point, relTo, relPoint, xOfs, yOfs = rFrame:GetPoint(1)

                -- Re-anchor it shifted downwards relative to where the row started
                rFrame:SetPoint(point, relTo, relPoint, xOfs, cursorY - offset)
            end
        end

        wipe(currentRowFrames)
    end

    return math.abs(cursorY - currentMaxRowHeight)
end

---@param parent Frame
---@param name string
local CreateScrollFrames = function(parent, name, header, mode)
    local scrollBoxBottom = -1
    if mode == RenderMode.POPUP then
        if Questie.IsForever then
            scrollBoxBottom = -10
        else
            scrollBoxBottom = -7
        end
    end
	local scrollBox = CreateFrame("Frame", name, parent, "WowScrollBox") --[[@as WowScrollBox|Frame]]
	local scrollBar = CreateFrame("EventFrame", name.."ScrollBar", parent, "MinimalScrollBar")
	local barPadding = 12
	scrollBar:SetPoint("RIGHT", parent, "RIGHT", -barPadding, 0)
	scrollBar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 5)
	scrollBar:SetPoint("TOP", parent, "TOP", 0, -36)
	scrollBox:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
	scrollBox:SetPoint("BOTTOM", parent, 0, scrollBoxBottom)
	scrollBox:SetPoint("RIGHT", scrollBar, "LEFT", -barPadding, 0)
	-- For now, the scrollChild serves as an expanding canvas for the scrollBox.
	-- Allows the scroll frame to behave like the previously used template.
	---@class SettingsCategoryPanelScrollChild: ResizeLayoutFrame
	local scrollChild = CreateFrame('Frame', name..'ScrollChild', scrollBox, 'ResizeLayoutFrame')
	scrollChild.scrollable = true
	scrollChild:SetFixedWidth(SettingsPanel.Container.SettingsCanvas:GetWidth() - scrollBar:GetWidth())
	scrollChild:SetHeight(100) -- initial arbitrary height
	scrollChild.ScrollBox = scrollBox;
	scrollChild.ScrollBar = scrollBar;
	-- Updates the canvas's resizable layout height, and then the scroll parent to match.
	function scrollChild.UpdateScrollLayout()
		scrollChild:Layout()
		scrollBox:FullUpdate(true)
	end
	local scrollView = CreateScrollBoxLinearView();
	scrollView:SetPadding(10, 25) -- pad bottom of view with 25px
	scrollView:SetPanExtent(50) -- scroll step
	ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollView);
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar); -- adds autohide to scrollbar
	return scrollBox, scrollChild
end

function QuestieOptionsEngine:Initialize()
    local sortedTabs = {}
    for tabKey, tabData in pairs(CreateOptionsTable()) do
        table.insert(sortedTabs, { key = tabKey, data = tabData })
    end

    table.sort(sortedTabs, function(a, b)
        local aOrder = a.data.order or 100
        local bOrder = b.data.order or 100
        if aOrder == bOrder then
            return (a.data.title or "") < (b.data.title or "")
        end
        return aOrder < bOrder
    end)

    local primaryTabKey = nil
    for _, tabInfo in ipairs(sortedTabs) do
        if tabInfo.data.order == 0 then
            primaryTabKey = tabInfo.key
            break
        end
    end

    local popup = self:GetOrCreateStandaloneWindow()
    self.standaloneCanvases = {}
    self.sideTabs = {}

    local mainCategory = nil
    if not primaryTabKey then
        local mainFrame = CreateFrame("Frame", "QuestieOptionsCanvasMain", UIParent)
        mainFrame:Hide()
        mainCategory = Settings.RegisterCanvasLayoutCategory(mainFrame, "Questie")
        Settings.RegisterAddOnCategory(mainCategory)
    end

    local previousTabButton = nil

    for index, tabInfo in ipairs(sortedTabs) do

        local tabKey = tabInfo.key
        local tabData = tabInfo.data
        local fullWidth = 625

        if tabData.visible ~= false then
            local blizzFrameName = "QuestieOptionsTab_Blizz_" .. tabKey
            local blizzTabFrame = self:CreateTabCanvas(UIParent, tabData, blizzFrameName, fullWidth, RenderMode.BLIZZARD)

            if tabKey == primaryTabKey then
                mainCategory = Settings.RegisterCanvasLayoutCategory(blizzTabFrame, "Questie")
                Settings.RegisterAddOnCategory(mainCategory)
            else
                local subCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, blizzTabFrame, tabData.title)
                Settings.RegisterAddOnCategory(subCategory)
            end

            local standaloneFrameName = "QuestieOptionsTab_Popup_" .. tabKey
            local popupTabFrame = self:CreateTabCanvas(popup.canvasContainer, tabData, standaloneFrameName, fullWidth, RenderMode.POPUP)
            self.standaloneCanvases[tabKey] = popupTabFrame

            local sideTab = self:CreateSideTabs(popup, tabKey, tabData, index)
            self.sideTabs[tabKey] = sideTab

            -- Anchor side tabs to the outside right edge of the popup window
            if not previousTabButton then
                if Questie.IsForever then
                    sideTab:SetPoint("TOPLEFT", popup, "TOPRIGHT", -1, -35)
                else
                    sideTab:SetPoint("TOPLEFT", popup, "TOPRIGHT", -2, -35)
                end
            else
                if Questie.IsForever then
                    sideTab:SetPoint("TOPLEFT", previousTabButton, "BOTTOMLEFT", 0, 0)
                else
                    sideTab:SetPoint("TOPLEFT", previousTabButton, "BOTTOMLEFT", 0, 10)
                end
            end
            previousTabButton = sideTab
        end
    end

    -- Default selection for the standalone window
    local initialTabKey = primaryTabKey or (sortedTabs[1] and sortedTabs[1].key)
    if initialTabKey then
        QuestieOptionsEngine:SelectStandaloneTab(initialTabKey)
    end

    -- Synchronize both canvas layouts
    QuestieOptionsEngine:RefreshStates()

    QuestieOptionsEngine.popup = popup
end

function QuestieOptionsEngine:RefreshStates()

    local function DesaturateNineSlice(frame, disable, shade)
        local nineSlice = frame.NineSlice or frame
        if nineSlice and nineSlice.GetRegions then
            for _, region in ipairs({ nineSlice:GetRegions() }) do
                if region:IsObjectType("Texture") then
                    region:SetDesaturated(disable)
                    if shade then region:SetVertexColor(unpack(not disable and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1})) end
                end
            end
        end
    end

    for _, control in ipairs(registeredControls) do
        local data = control.itemData
        local currentValue = nil
        if data and data.get then currentValue = data.get(data.value) end

        if data then
            -- Figure out if this control should be enabled
            local isEnabled = true
            if type(data.enabled) == "function" then
                isEnabled = (data.enabled() == nil) or data.enabled()
            elseif type(data.enabled) == "boolean" then
                isEnabled = (data.enabled == nil) or data.enabled
            end

            if control.widget and control.widget.SetEnabled then
                control.widget:SetEnabled(isEnabled)
            end

            local labelColors = isEnabled and defaultLabelColor or disabledLabelColor
            local textColors = isEnabled and defaultTextColor or disabledTextColor

            if control.titleFrame then control.titleFrame:SetTextColor(unpack(labelColors)) end
            if control.descriptionFrame then control.descriptionFrame:SetTextColor(unpack(textColors)) end

            -- Custom properties to apply to each control type if enabled/disabled
            if data.type == "checkbox" then
                local isChecked = (currentValue == true or currentValue == 1)
                control.widget:SetChecked(isChecked)
                if not isEnabled and control.widget.HoverTex then
                    control.widget.HoverTex:Hide()
                end
            elseif data.type == "slider" then
                if control.widget.Text then control.widget.Text:SetTextColor(unpack(labelColors)) end
                if control.valueDisplay then control.valueDisplay:SetTextColor(unpack(textColors)) end
                if control.thumb then
                    control.thumb:SetDesaturated(not isEnabled)
                    control.thumb:SetAlpha(isEnabled and 1.0 or 0.5) -- This helps differentiate the disabled state when gray Dragonflight theme
                end
                if control.widget.TrackLeft then control.widget.TrackLeft:SetDesaturated(not isEnabled) end
                if control.widget.TrackMiddle then control.widget.TrackMiddle:SetDesaturated(not isEnabled) end
                if control.widget.TrackRight then control.widget.TrackRight:SetDesaturated(not isEnabled) end
                if type(currentValue) == "number" then
                    control.widget:SetValue(currentValue)
                end
            elseif data.type == "dropdown" or data.type == "fontDropdown" then
                DesaturateNineSlice(control.widget, not isEnabled, true)
                control.widget:GenerateMenu()
            elseif data.type == "container" then
                DesaturateNineSlice(control.containerFrame, not isEnabled, true)
            elseif data.type == "colorPicker" then
                control.widget.border:SetDesaturated(not isEnabled)
                control.widget.border:SetVertexColor(unpack(isEnabled and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1}))
                local r, g, b, a = nil, nil, nil, nil
                if data.get then r, g, b, a = data.get() end
                control.widget.swatch:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
            elseif data.type == "radioButton" then
                control.widget:SetChecked(currentValue)
            elseif data.type == "textbox" then
                control.widget:SetTextColor(unpack(textColors))
                control.widget:EnableMouse(isEnabled)
                if not isEnabled and control.widget:HasFocus() then
                    control.widget:ClearFocus()
                end
                if control.okBtn then
                    control.okBtn:SetEnabled(isEnabled)
                    if not isEnabled then control.okBtn:Hide() end
                end
                for _, region in ipairs({ control.widget:GetRegions() }) do
                    if region:IsObjectType("Texture") then
                        region:SetDesaturated(not isEnabled)
                        region:SetVertexColor(unpack(isEnabled and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1}))
                    end
                end
                if not control.widget:HasFocus() and data.get then
                    control.widget:SetText(tostring(currentValue or ""))
                    if control.okBtn then control.okBtn:Hide() end
                end
            elseif data.type == "text" then
                if data.get and control.titleFrame then
                    control.titleFrame:SetText(tostring(data.get() or ""))
                end
            end
        end
    end
end

-- Helper to construct a canvas frame for either Blizzard Settings or the Standalone window
function QuestieOptionsEngine:CreateTabCanvas(parent, tabData, frameName, fullWidth, mode)
    local leftInset = 0
    if mode == RenderMode.POPUP then
        leftInset = 44
    end

    local tabFrame = CreateFrame("Frame", frameName, parent)
    tabFrame:SetAllPoints(parent)

    local headerWrapper = CreateFrame("Frame", frameName .. "_headerWrapper", tabFrame)
    headerWrapper:SetAllPoints(tabFrame)
    headerWrapper:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -4)

    -- Header title & subtitle
    local title = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 8 + leftInset, -4)
    title:SetText("Questie")

    local bullet = tabFrame:CreateFontString(nil, "OVERLAY", "Game13Font")
    bullet:SetPoint("LEFT", title, "RIGHT", 4, -1)
    bullet:SetTextColor(0.9, 0.9, 0.9, 1.0)
    bullet:SetText("•")

    local subtitle = tabFrame:CreateFontString(nil, "OVERLAY", "Game13Font")
    subtitle:SetPoint("LEFT", bullet, "RIGHT", 8, 0)
    subtitle:SetTextColor(0.9, 0.9, 0.9, 1.0)
    subtitle:SetText(tabData.subtitle or tabData.title)

    headerWrapper:SetPoint("BOTTOM", title, "BOTTOM", 0, 0)

    local scrollFrame, scrollChild = CreateScrollFrames(tabFrame, frameName, headerWrapper, mode)
    tabFrame:HookScript("OnShow", scrollChild.UpdateScrollLayout)
    tabFrame:Hide()

    local header = tabFrame:CreateTexture(nil, "BORDER")
    header:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 2)
    header:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 0, 0.5)
    header:SetAtlas("Options_HorizontalDivider", true)
    DisableSnapping(header)

    local logicalWidth = fullWidth - (indentingLevel * 2)
    local totalHeight = BuildLayout(scrollChild, tabData.items, logicalWidth, 1)
    scrollChild:SetHeight(totalHeight + 20)

    return tabFrame
end

-- Constructs the side-tab button using the modern retail sidetab atlases and masking
function QuestieOptionsEngine:CreateSideTabs(parent, tabKey, tabData, index)
    local tabFrame = CreateFrame("Frame", "$parent_Tab_" .. tabKey, parent)
    tabFrame.tabKey = tabKey
    local tabButton = CreateFrame("Button", "$tabButton_" .. tabKey, tabFrame)
    tabFrame.button = tabButton
    tabFrame.button.tabKey = tabKey

    local bg = tabFrame:CreateTexture(nil, "BACKGROUND")
    if Questie.IsForever then
        bg:SetAtlas("common-sidetab", true)
        bg:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, 0)
        tabFrame:SetSize(bg:GetSize())
    else
        bg:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
        bg:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, 0)
        tabFrame:SetSize(64, 64)
    end
    tabFrame.Background = bg

    local icon = tabFrame:CreateTexture(nil, "ARTWORK")
    if Questie.IsForever then
        icon:SetPoint("CENTER", tabFrame, "CENTER", -1, 0)
        icon:SetSize(62, 62)
        tabButton:SetSize(50, 50)
        tabButton:SetPoint("CENTER", icon, "CENTER", -1, -1)
    else
        icon:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 1, -9)
        icon:SetSize(36, 36)
        tabButton:SetSize(36, 36)
        tabButton:SetPoint("CENTER", icon, "CENTER", 0, 0)
    end
    icon:SetTexture(tabData.icon or 134400) -- Fallback to question mark icon
    tabFrame.Icon = icon

    local mask = tabFrame:CreateMaskTexture(nil, "ARTWORK")
    if Questie.IsForever then
        mask:SetAtlas("common-sidetab-mask", true)
        mask:SetPoint("CENTER", icon, "CENTER", -1, 0)
        mask:SetSize(62, 62)
    else
        mask:SetTexture("interface\\hud\\uicooldownmanagermask")
        mask:SetPoint("CENTER", icon, "CENTER", 0, 0)
        mask:SetSize(36, 36)
    end
    icon:AddMaskTexture(mask)
    tabFrame.Mask = mask

    local selected = tabFrame:CreateTexture(nil, "OVERLAY")
    if Questie.IsForever then
        selected:SetAtlas("common-sidetab-selected", true)
        selected:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, 0)
    else
        selected:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        selected:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
        selected:SetSize(36, 36)
        selected:SetBlendMode("ADD")
    end
    selected:Hide()
    tabFrame.Selected = selected

    local highlight = tabButton:CreateTexture(nil, "HIGHLIGHT")
    if Questie.IsForever then
        highlight:SetAtlas("common-sidetab-hover", true)
        highlight:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, 0)
    else
        highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        highlight:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
        highlight:SetSize(36, 36)
    end
    highlight:SetBlendMode("ADD")
    tabFrame.Highlight = highlight

    DisableSnapping(tabFrame.Background)
    DisableSnapping(tabFrame.Icon)
    DisableSnapping(tabFrame.Mask)
    DisableSnapping(tabFrame.Selected)
    DisableSnapping(tabFrame.Highlight)

    -- Tooltips
    tabButton:SetScript("OnEnter", function(btn)
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:SetText(tabData.title or tabKey, 1, 1, 1)
        if tabData.subtitle then
            GameTooltip:AddLine(tabData.subtitle, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)
    tabButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Click handler
    tabButton:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        self:SelectStandaloneTab(tabKey)
    end)

    return tabFrame
end

-- Constructs the main standalone dialog frame
function QuestieOptionsEngine:GetOrCreateStandaloneWindow()
    if self.standaloneWindow then return self.standaloneWindow end
    local popoutFrame = Questie.IsForever and "PortraitFrameFlatTemplate" or "PortraitFrameTemplate"
    local popupHeight = math.floor(GetScreenHeight() * 0.7) or 580

    local f = CreateFrame("Frame", "QuestieStandaloneSettings", UIParent, popoutFrame)
    f:SetSize(675, popupHeight)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:Hide()
    f:SetTitle("Questie")
    f:EnableMouse(true)

    local disableBatch = {
        f.CloseButton:GetNormalTexture(), f.CloseButton:GetPushedTexture(), f.CloseButton:GetHighlightTexture(), f.CloseButton:GetDisabledTexture(),
        f.PortraitFrame, f.TopRightCorner, f.TopLeftCorner, f.TopBorder, f.TopTileStreaks,
        f.BotLeftCorner, f.BotRightCorner, f.BottomBorder, f.LeftBorder, f.RightBorder,
    }

    for i, frameTexture in pairs(disableBatch) do
        if frameTexture then DisableSnapping(frameTexture) end
    end

    local dragBar = CreateFrame("Frame", nil, f) -- Create a frame along the top of the window so it can be moved with click+drag
    dragBar:SetPoint("TOPLEFT", f, "TOPLEFT", 55, 0) -- Offset from left so it doesn't overlap the portrait
    dragBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -30, 0) -- Offset from right so it doesn't block the close button
    dragBar:SetHeight(28)
    dragBar:EnableMouse(true)

    dragBar:SetScript("OnMouseDown", function(bar, button)
        if button == "LeftButton" and not f.isMoving then
            f:StartMoving()
            f.isMoving = true
        end
    end)

    dragBar:SetScript("OnMouseUp", function(bar, button)
        if button == "LeftButton" and f.isMoving then
            f:StopMovingOrSizing()
            f.isMoving = false
        end
    end)

    -- Safety check: stop moving if the frame hides mid-drag
    f:HookScript("OnHide", function()
        if f.isMoving then
            f:StopMovingOrSizing()
            f.isMoving = false
        end
    end)

    f:SetPortraitTextureRaw("Interface\\AddOns\\Questie\\Icons\\questie_portrait.png", nil, nil, "TRILINEAR")
    local portrait = f.PortraitContainer.portrait
    if Questie.IsForever then
        portrait:SetTexCoord(0.16, 0.86, 0.17, 0.87)
    else
        portrait:SetTexCoord(0.21, 0.815, 0.21, 0.815)
    end
    DisableSnapping(portrait)

    -- Content host area inside the portrait frame
    f.canvasContainer = CreateFrame("Frame", nil, f)
    f.canvasContainer:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
    f.canvasContainer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)

    -- ESC key to close
    tinsert(UISpecialFrames, "QuestieStandaloneSettings")

    self.standaloneWindow = f
    return f
end

-- Tab selection handler for the standalone popup
function QuestieOptionsEngine:SelectStandaloneTab(selectedKey)
    for tabKey, canvas in pairs(self.standaloneCanvases) do
        local isCurrent = (tabKey == selectedKey)
        canvas:SetShown(isCurrent)

        local tabButton = self.sideTabs[tabKey]
        if tabButton then
            tabButton.Selected:SetShown(isCurrent)
            -- Slightly desaturate or darken inactive tab icons
            tabButton.Icon:SetDesaturated(not isCurrent)
            tabButton.Icon:SetAlpha(isCurrent and 1.0 or 0.75)
        end
    end
end