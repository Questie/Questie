dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

local LOADING_MESSAGE = "Please wait a moment for Questie to finish loading"
local CHECKBOX_TEMPLATE = "SettingsCheckboxTemplate"

describe("QuestieOptionsEngine", function()
    ---@type QuestieOptionsEngine
    local QuestieOptionsEngine
    ---@type ThreadLib
    local ThreadLib
    local ui
    local originalQuestie
    local settings, reads, threadErrors
    -- How long reading a setting takes, which a control does once when it is created
    local settingReadSeconds

    local function LoadEngineModules()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Options/QuestieOptionsLayout.lua")
        dofile("Modules/Options/QuestieOptionsWindow.lua")
        dofile("Modules/Options/QuestieOptionsEngine.lua")
        QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
    end

    local function CreateCheckbox(order, key, enabled)
        return {
            type = "checkbox",
            title = key,
            order = order,
            width = "full",
            enabled = enabled,
            get = function()
                reads[key] = (reads[key] or 0) + 1
                ui.clock = ui.clock + settingReadSeconds
                return settings[key]
            end,
            set = function(_, value) settings[key] = value end,
        }
    end

    local function RegisterTestTabs()
        QuestieOptionsEngine.tabs = {
            general = {Initialize = function()
                return {
                    title = "General",
                    order = 0,
                    items = {
                        parent = CreateCheckbox(1, "parent"),
                        dependent = CreateCheckbox(2, "dependent", function() return settings.parent end),
                    },
                }
            end},
            map = {Initialize = function()
                return {
                    title = "Map",
                    order = 1,
                    items = {
                        mapOption = CreateCheckbox(1, "mapOption"),
                    },
                }
            end},
            hidden = {Initialize = function()
                return {title = "Hidden", order = 2, visible = false, items = {}}
            end},
        }
    end

    local function RegisterLargeTab(controlCount)
        local items = {}
        for i = 1, controlCount do
            items["option" .. i] = CreateCheckbox(i, "option" .. i)
        end
        QuestieOptionsEngine.tabs = {
            large = {Initialize = function() return {title = "Large", order = 0, items = items} end},
            other = {Initialize = function() return {title = "Other", order = 1, items = {
                otherOption = CreateCheckbox(1, "otherOption"),
            }} end},
        }
    end

    local function Initialize()
        ThreadLib.Thread(function() QuestieOptionsEngine:Initialize() end, 0)
        ui.RunUntilIdle()
    end

    local function OpenBlizzardCategory(index)
        local canvas = ui.categories[index].canvas
        ui.DisplayCanvas(canvas)
        ui.RunUntilIdle()
        return canvas
    end

    local function OpenWindow()
        QuestieOptionsEngine:ToggleConfigWindow()
        ui.RunUntilIdle()
        return QuestieOptionsEngine.popup
    end

    local function CheckboxesIn(frame)
        return ui.FindByTemplate(frame, CHECKBOX_TEMPLATE)
    end

    local function ControlsIn(frame)
        return ui.FindAll(frame, function(candidate) return candidate.itemData ~= nil end)
    end

    local function ClickSideTab(key)
        for _, child in ipairs(QuestieOptionsEngine.popup.children) do
            if child.name == "$parent_Tab_" .. key then
                child.button.scripts.OnClick(child.button)
                ui.RunUntilIdle()
                return
            end
        end
        error("No side tab for " .. key)
    end

    ---Runs the timers out.
    ---@return number most The largest number of checkboxes that appeared in a single frame
    ---@return number frames How many frames it took
    local function MostCheckboxesPerFrame(root)
        local most, frames, previous = 0, 0, #CheckboxesIn(root)
        while #ui.tickers > 0 do
            ui.RunFrame()
            frames = frames + 1
            local count = #CheckboxesIn(root)
            most = math.max(most, count - previous)
            previous = count
        end
        return most, frames
    end

    before_each(function()
        ui = FakeUI.Install()
        settings = {parent = false, dependent = false, mapOption = false}
        reads = {}
        threadErrors = {}
        settingReadSeconds = 0

        originalQuestie = {Colorize = Questie.Colorize, Error = Questie.Error, IsForever = Questie.IsForever}
        Questie.Colorize = function(_, text) return text end
        Questie.Error = function(...)
            table.insert(threadErrors, table.concat({...}, " "))
        end
        Questie.IsForever = true

        LoadEngineModules()
        RegisterTestTabs()
    end)

    after_each(function()
        local errors = threadErrors
        Questie.Colorize = originalQuestie.Colorize
        Questie.Error = originalQuestie.Error
        Questie.IsForever = originalQuestie.IsForever
        ui.Restore()
        assert.are_same({}, errors)
    end)

    describe("Initialize", function()
        it("should register visible tabs in order, the first as the main category", function()
            Initialize()

            assert.are.equal(2, #ui.categories)
            assert.are.equal("Questie", ui.categories[1].name)
            assert.is_nil(ui.categories[1].parent)
            assert.are.equal("Map", ui.categories[2].name)
            assert.are.equal(ui.categories[1], ui.categories[2].parent)
        end)

        it("should add every category to the AddOns list of the settings panel", function()
            Initialize()

            assert.are_same(ui.categories, ui.addOnCategories)
        end)

        it("should sort tabs without an order last, and equal orders by title", function()
            QuestieOptionsEngine.tabs = {
                noOrder = {Initialize = function() return {title = "A last", items = {}} end},
                betaTab = {Initialize = function() return {title = "Beta", order = 1, items = {}} end},
                alphaTab = {Initialize = function() return {title = "Alpha", order = 1, items = {}} end},
            }

            Initialize()

            assert.are.equal("Questie", ui.categories[1].name)
            assert.are.equal("Beta", ui.categories[2].name)
            assert.are.equal("A last", ui.categories[3].name)
        end)

        it("should not build any controls until a tab is opened", function()
            Initialize()

            assert.are_same({}, ControlsIn(UIParent))
            assert.are_same({}, reads)
        end)

        it("should not create the window until it is opened", function()
            Initialize()

            assert.is_nil(QuestieOptionsEngine.popup)
            assert.are_same({}, UISpecialFrames)
        end)

        -- All of this together is too much for one frame in Hardcore.
        it("should define or register at most one tab per resume", function()
            local definitions = 0
            for _, tab in pairs(QuestieOptionsEngine.tabs) do
                local initialize = tab.Initialize
                tab.Initialize = function(...)
                    definitions = definitions + 1
                    return initialize(...)
                end
            end
            local thread = coroutine.create(function() QuestieOptionsEngine:Initialize() end)

            local mostInOneResume = 0
            while coroutine.status(thread) ~= "dead" do
                local before = definitions + #ui.categories
                assert(coroutine.resume(thread))
                mostInOneResume = math.max(mostInOneResume, definitions + #ui.categories - before)
            end

            assert.are.equal(3, definitions)
            assert.are.equal(2, #ui.categories)
            assert.are.equal(1, mostInOneResume)
        end)
    end)

    describe("building tabs", function()
        before_each(function()
            Initialize()
        end)

        it("should only build the Blizzard tab that was opened", function()
            local canvas = OpenBlizzardCategory(2)

            assert.are.equal(1, #CheckboxesIn(canvas))
            assert.are.equal(1, #CheckboxesIn(UIParent))
        end)

        it("should only build the first tab when the window opens", function()
            local window = OpenWindow()

            assert.are.equal(2, #CheckboxesIn(window))
        end)

        it("should build another tab when its side tab is selected", function()
            local window = OpenWindow()

            ClickSideTab("map")

            assert.are.equal(3, #CheckboxesIn(window))
        end)

        it("should build a tab only once", function()
            local window = OpenWindow()

            ClickSideTab("map")
            ClickSideTab("general")
            ClickSideTab("map")

            assert.are.equal(3, #CheckboxesIn(window))
        end)

        it("should keep the Blizzard panel and the window independent", function()
            local canvas = OpenBlizzardCategory(1)
            local window = OpenWindow()

            assert.are.equal(2, #CheckboxesIn(canvas))
            assert.are.equal(2, #CheckboxesIn(window))
        end)

        it("should show current settings on controls as they are built", function()
            settings.parent = true

            local window = OpenWindow()

            local checkboxes = CheckboxesIn(window)
            assert.is_true(checkboxes[1]:GetChecked())
            assert.is_true(checkboxes[2]:IsEnabled())
        end)

        it("should show the tab's controls when it is finished", function()
            local window = OpenWindow()

            assert.is_true(CheckboxesIn(window)[1]:IsVisible())
        end)

        it("should size the scroll area to the tab's content and lay it out", function()
            local canvas = OpenBlizzardCategory(2)

            local scrollChild = ui.FindByTemplate(canvas, "ResizeLayoutFrame")[1]
            local scrollBox = ui.FindByTemplate(canvas, "WowScrollBox")[1]
            -- One control of 30, the gap of 10, and 20 at the bottom
            assert.are.equal(60, scrollChild:GetHeight())
            assert.are.equal(1, scrollChild.layouts)
            assert.are.equal(1, scrollBox.fullUpdates)
        end)

        it("should lay out again each time the tab is shown", function()
            local canvas = OpenBlizzardCategory(2)
            local scrollChild = ui.FindByTemplate(canvas, "ResizeLayoutFrame")[1]

            ui.ClearCanvas(canvas)
            OpenBlizzardCategory(2)

            assert.are.equal(2, scrollChild.layouts)
        end)

        it("should report a failing tab instead of losing the error", function()
            QuestieOptionsEngine.tabs = {}
            ui.Restore()
            ui = FakeUI.Install()
            LoadEngineModules()
            QuestieOptionsEngine.tabs = {
                broken = {Initialize = function()
                    return {title = "Broken", items = {bad = {type = "not a real type", title = "Bad"}}}
                end},
            }
            Initialize()

            OpenWindow()

            assert.are.equal(1, #threadErrors)
            assert.is_truthy(threadErrors[1]:find("Unknown settings control type: not a real type", 1, true))
            threadErrors = {}
        end)
    end)

    describe("pacing a build", function()
        local LARGE_TAB_SIZE = 40

        -- Each control reads the clock once, so at this rate the 4 ms budget lasts about four controls.
        local SLOW_CLIENT_SECONDS_PER_CLOCK_READ = 0.001

        local SLOW_CONTROL_SECONDS = 0.003
        -- The budget, and the control that used up the rest of it
        local MOST_SECONDS_PER_FRAME = 0.004 + SLOW_CONTROL_SECONDS

        ---Runs the timers out.
        ---@return number longest The most time the timers took in a single frame
        local function LongestFrame()
            local longest = 0
            while #ui.tickers > 0 do
                local startedAt = ui.clock
                ui.RunFrame()
                longest = math.max(longest, ui.clock - startedAt)
            end
            return longest
        end

        -- Starts building on a slow client and runs it partway, but not to the end.
        local function StartSlowBuild()
            ui.clockStep = SLOW_CLIENT_SECONDS_PER_CLOCK_READ
            QuestieOptionsEngine:ToggleConfigWindow()
            ui.RunFrame()
            ui.RunFrame()
            local built = #CheckboxesIn(QuestieOptionsEngine.popup)
            assert.is_true(built > 0 and built < LARGE_TAB_SIZE, "built " .. built .. " controls")
        end

        before_each(function()
            RegisterLargeTab(LARGE_TAB_SIZE)
            Initialize()
        end)

        it("should create everything in one frame on a fast client", function()
            ui.clockStep = 0

            QuestieOptionsEngine:ToggleConfigWindow()
            ui.RunFrame()

            assert.are.equal(LARGE_TAB_SIZE, #CheckboxesIn(QuestieOptionsEngine.popup))
        end)

        -- The script time limit is much stricter in Hardcore.
        it("should spread out over frames when controls take long to create", function()
            ui.clockStep = SLOW_CLIENT_SECONDS_PER_CLOCK_READ

            QuestieOptionsEngine:ToggleConfigWindow()
            local mostInOneFrame, frames = MostCheckboxesPerFrame(QuestieOptionsEngine.popup)

            assert.are.equal(LARGE_TAB_SIZE, #CheckboxesIn(QuestieOptionsEngine.popup))
            assert.is_true(mostInOneFrame <= 5, "built " .. mostInOneFrame .. " controls in one frame")
            -- Each frame gets the whole budget again, so this doesn't degrade to a control per frame
            assert.is_true(frames <= LARGE_TAB_SIZE / 2, "took " .. frames .. " frames")
        end)

        -- Otherwise a control that takes long to create comes on top of the budget of the frame it resumes in
        it("should count the first control after resuming against the frame's budget", function()
            settingReadSeconds = SLOW_CONTROL_SECONDS

            QuestieOptionsEngine:ToggleConfigWindow()
            local longest = LongestFrame()

            assert.are.equal(LARGE_TAB_SIZE, #CheckboxesIn(QuestieOptionsEngine.popup))
            assert.is_true(longest <= MOST_SECONDS_PER_FRAME + 1e-9, "took " .. longest .. " seconds in one frame")
        end)

        it("should share the budget of a frame between tabs building at the same time", function()
            settingReadSeconds = SLOW_CONTROL_SECONDS
            ui.DisplayCanvas(ui.categories[1].canvas)
            QuestieOptionsEngine:ToggleConfigWindow()

            local longest = LongestFrame()

            assert.are.equal(LARGE_TAB_SIZE * 2, #CheckboxesIn(UIParent))
            -- A build that finds the budget spent waits for the next frame before creating anything
            assert.is_true(longest <= MOST_SECONDS_PER_FRAME + 1e-9, "took " .. longest .. " seconds in one frame")
        end)

        it("should keep other builds out of the frame a finished tab is laid out in", function()
            settingReadSeconds = SLOW_CONTROL_SECONDS
            local canvas = ui.categories[1].canvas
            ui.DisplayCanvas(canvas)
            QuestieOptionsEngine:ToggleConfigWindow()
            local window = QuestieOptionsEngine.popup

            local function IsLaidOut()
                local scrollChild = ui.FindByTemplate(canvas, "ResizeLayoutFrame")[1]
                return scrollChild ~= nil and scrollChild.layouts == 1
            end
            local windowCheckboxes
            repeat
                windowCheckboxes = #CheckboxesIn(window)
                ui.RunFrame()
            until IsLaidOut() or #ui.tickers == 0

            assert.is_true(IsLaidOut())
            assert.are.equal(windowCheckboxes, #CheckboxesIn(window))
            ui.RunUntilIdle()
            assert.are.equal(LARGE_TAB_SIZE, #CheckboxesIn(window))
        end)

        -- An edit box created visible can take the keyboard focus, and a half-built tab looks broken.
        it("should build out of sight, and only show the tab once it is complete", function()
            StartSlowBuild()
            local window = QuestieOptionsEngine.popup

            assert.is_false(CheckboxesIn(window)[1]:IsVisible())

            ui.RunUntilIdle()

            assert.is_true(CheckboxesIn(window)[1]:IsVisible())
        end)

        it("should lay out in a frame of its own after creating the controls", function()
            ui.clockStep = 0
            QuestieOptionsEngine:ToggleConfigWindow()
            ui.RunFrame()
            local scrollChild = ui.FindByTemplate(QuestieOptionsEngine.popup, "ResizeLayoutFrame")[1]
            assert.is_nil(scrollChild.layouts)

            ui.RunFrame()

            assert.are.equal(1, scrollChild.layouts)
        end)

        it("should keep building a tab that was closed in the meantime", function()
            StartSlowBuild()

            QuestieOptionsEngine:HideFrame()
            ui.RunUntilIdle()

            assert.are.equal(LARGE_TAB_SIZE, #CheckboxesIn(QuestieOptionsEngine.popup))
        end)

        it("should refresh the controls that exist so far during a build", function()
            StartSlowBuild()
            local built = CheckboxesIn(QuestieOptionsEngine.popup)
            for key in pairs(settings) do settings[key] = nil end
            for i = 1, LARGE_TAB_SIZE do settings["option" .. i] = true end

            QuestieOptionsEngine:RefreshStates()

            for _, checkbox in ipairs(built) do
                assert.is_true(checkbox:GetChecked())
            end
            ui.RunUntilIdle()
            for _, checkbox in ipairs(CheckboxesIn(QuestieOptionsEngine.popup)) do
                assert.is_true(checkbox:GetChecked())
            end
        end)

        it("should survive the window being reopened during a build", function()
            StartSlowBuild()

            QuestieOptionsEngine:HideFrame()
            QuestieOptionsEngine:ShowFrame()
            ui.RunUntilIdle()

            assert.are.equal(LARGE_TAB_SIZE, #CheckboxesIn(QuestieOptionsEngine.popup))
        end)
    end)

    describe("RefreshStates", function()
        before_each(function()
            Initialize()
        end)

        it("should update dependent controls when a checkbox is clicked, outside of a coroutine", function()
            local window = OpenWindow()
            local checkboxes = CheckboxesIn(window)
            assert.is_false(checkboxes[2]:IsEnabled())

            checkboxes[1]:SetChecked(true)
            checkboxes[1]:Click()

            assert.is_true(settings.parent)
            assert.is_true(checkboxes[2]:IsEnabled())
        end)

        it("should update both the window and the Blizzard panel while both are open", function()
            local canvas = OpenBlizzardCategory(1)
            local window = OpenWindow()
            local windowBoxes = CheckboxesIn(window)

            windowBoxes[1]:SetChecked(true)
            windowBoxes[1]:Click()

            assert.is_true(CheckboxesIn(canvas)[1]:GetChecked())
        end)

        it("should not read settings for a closed window", function()
            OpenWindow()
            QuestieOptionsEngine:HideFrame()
            reads = {}

            QuestieOptionsEngine:RefreshStates()

            assert.are_same({}, reads)
        end)

        it("should skip tabs that aren't showing", function()
            OpenWindow()
            ClickSideTab("map")
            reads = {}

            QuestieOptionsEngine:RefreshStates()

            assert.is_nil(reads.parent)
            assert.is_true(reads.mapOption > 0)
        end)

        it("should catch a hidden tab up on changes when it is shown again", function()
            local window = OpenWindow()
            local generalBoxes = CheckboxesIn(window)
            ClickSideTab("map")

            settings.parent = true
            settings.dependent = true
            QuestieOptionsEngine:RefreshStates()
            assert.is_false(generalBoxes[1]:GetChecked())

            ClickSideTab("general")

            assert.is_true(generalBoxes[1]:GetChecked())
            assert.is_true(generalBoxes[2]:IsEnabled())
        end)

        it("should catch up when the whole window is reopened", function()
            local window = OpenWindow()
            local checkboxes = CheckboxesIn(window)
            QuestieOptionsEngine:HideFrame()

            settings.parent = true
            QuestieOptionsEngine:ShowFrame()

            assert.is_true(checkboxes[1]:GetChecked())
        end)

        describe("with Blizzard's settings panel", function()
            it("should skip a category that was left, and catch up when coming back", function()
                local canvas = OpenBlizzardCategory(1)
                local checkboxes = CheckboxesIn(canvas)
                ui.ClearCanvas(canvas)
                reads = {}

                settings.parent = true
                QuestieOptionsEngine:RefreshStates()
                assert.are_same({}, reads)

                OpenBlizzardCategory(1)
                assert.is_true(checkboxes[1]:GetChecked())
            end)

            it("should skip the open category while the panel itself is closed, and catch up when it opens", function()
                local canvas = OpenBlizzardCategory(1)
                local checkboxes = CheckboxesIn(canvas)
                SettingsPanel:Hide()
                reads = {}

                settings.parent = true
                QuestieOptionsEngine:RefreshStates()
                assert.are_same({}, reads)

                SettingsPanel:Show()
                assert.is_true(checkboxes[1]:GetChecked())
            end)
        end)
    end)

    describe("QueueRefresh", function()
        it("should combine all calls of a frame into one refresh", function()
            local refreshes = 0
            local refreshStates = QuestieOptionsEngine.RefreshStates
            QuestieOptionsEngine.RefreshStates = function(...)
                refreshes = refreshes + 1
                return refreshStates(...)
            end
            Initialize()
            OpenWindow()

            QuestieOptionsEngine:QueueRefresh()
            QuestieOptionsEngine:QueueRefresh()
            assert.are.equal(0, refreshes)

            ui.RunFrame()
            assert.are.equal(1, refreshes)

            QuestieOptionsEngine:QueueRefresh()
            ui.RunFrame()
            assert.are.equal(2, refreshes)
        end)
    end)

    describe("the window", function()
        describe("before the tabs are registered", function()
            it("should tell the user to wait", function()
                QuestieOptionsEngine:ToggleConfigWindow()

                assert.are_same({LOADING_MESSAGE}, ui.printed)
                assert.is_false(QuestieOptionsEngine:IsShown())
            end)

            it("should stay silent when asked to hide or refresh", function()
                QuestieOptionsEngine:HideFrame()
                QuestieOptionsEngine:RefreshStates()

                assert.are_same({}, ui.printed)
                assert.is_false(QuestieOptionsEngine:IsShown())
            end)

            it("should open normally once they are", function()
                QuestieOptionsEngine:ToggleConfigWindow()
                Initialize()

                QuestieOptionsEngine:ToggleConfigWindow()

                assert.is_true(QuestieOptionsEngine:IsShown())
            end)
        end)

        describe("after the tabs are registered", function()
            before_each(function()
                Initialize()
            end)

            it("should open and close when toggled", function()
                QuestieOptionsEngine:ToggleConfigWindow()
                assert.is_true(QuestieOptionsEngine:IsShown())

                QuestieOptionsEngine:ToggleConfigWindow()
                assert.is_false(QuestieOptionsEngine:IsShown())
                assert.are_same({}, ui.printed)
            end)

            it("should reuse the same window", function()
                local window = OpenWindow()
                QuestieOptionsEngine:HideFrame()

                assert.are.equal(window, OpenWindow())
            end)

            it("should switch to My Journey from its button", function()
                local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
                local journeyToggles = 0
                QuestieJourney.ToggleJourneyWindow = function() journeyToggles = journeyToggles + 1 end
                local window = OpenWindow()

                local journeyButton = ui.FindAll(window, function(frame)
                    return frame.itemData ~= nil and frame.itemData.title == "My Journey"
                end)[1]
                journeyButton.widget:Click()

                assert.is_false(QuestieOptionsEngine:IsShown())
                assert.are.equal(1, journeyToggles)
            end)
        end)
    end)

    -- The strict UI fake makes this a real check: a mistyped method or a missing field fails here like in the game.
    describe("with the real tabs", function()
        local TAB_FILES = {"Advanced", "Auto", "DBM", "General", "Icons", "Map", "Nameplate", "Profiles", "Tracker"}

        local originalDb, originalGlobals

        local function LoadRealTabs()
            QuestieOptionsEngine.tabs = {}
            dofile("Modules/Options/QuestieOptionsDefaults.lua")
            local defaults = QuestieLoader:ImportModule("QuestieOptionsDefaults"):Load()
            Questie.db = {
                profile = defaults.profile,
                char = defaults.char,
                global = defaults.global or {},
                keys = {},
                GetProfiles = function() return {"Default", "Other"} end,
                GetCurrentProfile = function() return "Default" end,
            }

            QuestieLoader:ImportModule("IsleOfQuelDanas").localizedPhaseNames = {"Phase 1", "Phase 2"}
            local compat = QuestieLoader:ImportModule("QuestieCompat")
            compat.IsAddOnLoaded = function() return false end
            compat.IsSuperTrackingSupported = function() return true end
            local trackerUtils = QuestieLoader:ImportModule("TrackerUtils")
            trackerUtils.IsVoiceOverLoaded = function() return false end
            trackerUtils.IsSpokenLoaded = function() return false end
            QuestieLoader:ImportModule("QuestiePopup").Dialogs = {}
            dofile("Modules/Expansions.lua")

            for _, tabFile in ipairs(TAB_FILES) do
                dofile("Modules/Options/NativeOptions/NativeOptions" .. tabFile .. ".lua")
            end
        end

        ---@return number count Items that should become controls, independently of how the layout decides that
        local function CountVisibleItems(items)
            local count = 0
            for _, item in pairs(items) do
                if item.visible ~= false then
                    count = count + 1
                    if item.items then
                        count = count + CountVisibleItems(item.items)
                    end
                end
            end
            return count
        end

        before_each(function()
            originalDb = Questie.db
            originalQuestie.GetIconNameFromPath = Questie.GetIconNameFromPath
            originalQuestie.icons = Questie.icons
            Questie.GetIconNameFromPath = function() return "slay" end
            Questie.icons = setmetatable({}, {__index = function(_, name) return "Icons\\" .. name end})

            local tabGlobals = {
                UnitClass = function() return "Druid" end,
                GetMaxPlayerLevel = function() return 60 end,
                GetLocale = function() return "enUS" end,
                GetCVar = function() return "1" end,
                DBM = {HudMap = {}},
                YES = "Yes", NO = "No", CLOSE = "Close", NONE = "None", DEFAULT = "Default", SETTINGS = "Settings",
                MASTER_VOLUME = "Master", MUSIC_VOLUME = "Music", AMBIENCE_VOLUME = "Ambience", DIALOG_VOLUME = "Dialog",
                FX_VOLUME = "Effects", SELF_HIGHLIGHT_MODE_OUTLINE = "Outline",
            }
            originalGlobals = {}
            for name, value in pairs(tabGlobals) do
                originalGlobals[name] = {_G[name]}
                _G[name] = value
            end
        end)

        after_each(function()
            Questie.db = originalDb
            Questie.GetIconNameFromPath = originalQuestie.GetIconNameFromPath
            Questie.icons = originalQuestie.icons
            for name, original in pairs(originalGlobals) do
                _G[name] = original[1]
            end
        end)

        local function ExpectEveryTabToBuild()
            LoadRealTabs()
            Initialize()
            assert.are.equal(#TAB_FILES, #ui.categories)

            -- Both places every tab can be shown
            local blizzardControls = {}
            for index, category in ipairs(ui.categories) do
                local canvas = OpenBlizzardCategory(index)
                blizzardControls[category] = #ControlsIn(canvas)
                ui.ClearCanvas(canvas)
            end
            local window = OpenWindow()
            for _, tabFile in ipairs(TAB_FILES) do
                ClickSideTab(tabFile:lower())
            end

            -- Every item that should be shown became a control
            local totalItems = 0
            for _, tabFile in pairs(QuestieOptionsEngine.tabs) do
                totalItems = totalItems + CountVisibleItems(tabFile:Initialize().items)
            end
            local totalBuilt = 0
            for _, count in pairs(blizzardControls) do
                totalBuilt = totalBuilt + count
            end
            assert.are.equal(totalItems, totalBuilt)
            -- The window has the same controls, and a My Journey button on each tab
            assert.are.equal(totalItems + #TAB_FILES, #ControlsIn(window))

            -- Every menu generates all of its entries when it opens, which a closed dropdown doesn't do
            local menusWithoutEntries = {}
            for _, control in ipairs(ControlsIn(window)) do
                if control.itemData.type == "dropdown" or control.itemData.type == "fontDropdown" then
                    control.widget.enabled = true
                    control.widget:OpenMenu()
                    if not control.widget:IsMenuOpen() then
                        table.insert(menusWithoutEntries, control.itemData.title)
                    end
                    control.widget:CloseMenu()
                end
            end
            assert.are_same({}, menusWithoutEntries)
        end

        it("should build every tab on the Forever client art", function()
            Questie.IsForever = true

            ExpectEveryTabToBuild()
        end)

        it("should build every tab on the Classic client art", function()
            Questie.IsForever = false

            ExpectEveryTabToBuild()
        end)

        it("should use the General tab as the main category", function()
            LoadRealTabs()

            Initialize()

            assert.are.equal("Questie", ui.categories[1].name)
            assert.is_nil(ui.categories[1].parent)
            assert.is_truthy(ui.categories[1].canvas:GetName():find("general", 1, true))
        end)

        it("should skip the DBM tab when DBM isn't loaded", function()
            _G.DBM = nil
            LoadRealTabs()

            Initialize()

            assert.are.equal(#TAB_FILES - 1, #ui.categories)
        end)

        it("should show the Season of Discovery rune options on Season of Discovery only", function()
            local originalIsSoD = Questie.IsSoD
            LoadRealTabs()

            Questie.IsSoD = true
            local itemsOnSoD = QuestieOptionsEngine.tabs.icons:Initialize().items.icon_toggles_group.items
            Questie.IsSoD = false
            local itemsElsewhere = QuestieOptionsEngine.tabs.icons:Initialize().items.icon_toggles_group.items
            Questie.IsSoD = originalIsSoD

            for _, key in ipairs({"sod_rune_options", "showSoDRunes", "sodRuneSelection"}) do
                assert.is_true(itemsOnSoD[key].visible, key)
                assert.is_false(itemsElsewhere[key].visible, key)
            end
        end)

        it("should only define and register the tabs at startup", function()
            LoadRealTabs()

            Initialize()

            assert.are.equal(#TAB_FILES, #ui.categories)
            assert.are_same({}, ControlsIn(UIParent))
        end)
    end)
end)
