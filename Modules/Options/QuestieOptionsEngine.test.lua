dofile("setupTests.lua")

local LOADING_MESSAGE = "Please wait a moment for Questie to finish loading"

-- Stands in for the WoW UI at the system boundary. Any method can be called and template children such as
-- NineSlice exist, so the real build and click paths run without listing every UI call they make.
local NewFakeFrame
local fakeFrameMeta = {}
fakeFrameMeta.__call = function()
    return NewFakeFrame()
end
fakeFrameMeta.__index = function(fake, key)
    local child = NewFakeFrame()
    rawset(fake, key, child)
    return child
end

NewFakeFrame = function(template)
    local frame = setmetatable({template = template, scripts = {}, isShown = true}, fakeFrameMeta)
    frame.Show = function(self) self.isShown = true end
    frame.Hide = function(self) self.isShown = false end
    frame.IsShown = function(self) return self.isShown end
    frame.SetScript = function(self, scriptName, handler) self.scripts[scriptName] = handler end
    frame.GetScript = function(self, scriptName) return self.scripts[scriptName] end
    frame.SetChecked = function(self, isChecked) self.isChecked = isChecked end
    frame.GetChecked = function(self) return rawget(self, "isChecked") end
    frame.SetEnabled = function(self, isEnabled) self.isEnabled = isEnabled end
    frame.GetWidth = function() return 100 end
    frame.GetHeight = function() return 20 end
    frame.GetStringWidth = function() return 100 end
    frame.GetStringHeight = function() return 20 end
    return frame
end

describe("QuestieOptionsEngine", function()
    ---@type QuestieOptionsEngine
    local QuestieOptionsEngine

    local originalPrint, originalLibStub
    local settings
    local checkboxes
    local settingReads

    -- Controls are built once per canvas, Blizzard first, and radio buttons share the checkbox template.
    -- So each canvas adds four entries, in order: parent, dependent, and the two radio buttons.
    local BLIZZARD_PARENT, BLIZZARD_DEPENDENT, POPUP_PARENT, POPUP_DEPENDENT = 1, 2, 5, 6

    local function CountReads(get)
        return function(...)
            settingReads = settingReads + 1
            return get(...)
        end
    end

    local function CreateRadioButton(order, value)
        return {
            type = "radioButton",
            title = value,
            order = order,
            value = value,
            get = CountReads(function(radioValue) return settings.choice == radioValue end),
            set = function(radioValue) settings.choice = radioValue end,
        }
    end

    local function CreateGeneralTab()
        return {
            title = "General",
            order = 0,
            items = {
                {
                    type = "checkbox",
                    title = "Parent",
                    order = 1,
                    get = CountReads(function() return settings.parent end),
                    set = function(_, value) settings.parent = value end,
                },
                {
                    type = "checkbox",
                    title = "Dependent",
                    order = 2,
                    enabled = function() return settings.parent end,
                    get = CountReads(function() return settings.dependent end),
                    set = function(_, value) settings.dependent = value end,
                },
                CreateRadioButton(3, "first"),
                CreateRadioButton(4, "second"),
            },
        }
    end

    local function StubTabs()
        local function Hidden()
            return {Initialize = function() return {title = "Hidden", visible = false, items = {}} end}
        end

        QuestieOptionsEngine.tabs = {
            general = {Initialize = CreateGeneralTab},
            icons = Hidden(),
            map = Hidden(),
            tracker = Hidden(),
            auto = Hidden(),
            nameplate = Hidden(),
            dbm = Hidden(),
            advanced = Hidden(),
            profiles = Hidden(),
        }
    end

    local function ResumeBuild(buildThread)
        local success, buildError = coroutine.resume(buildThread)
        assert(success, buildError)
    end

    local function StartBuild()
        return coroutine.create(function() QuestieOptionsEngine:Initialize() end)
    end

    local function FinishBuild(buildThread)
        while coroutine.status(buildThread) ~= "dead" do
            ResumeBuild(buildThread)
        end
    end

    before_each(function()
        settings = {parent = false, dependent = false}
        checkboxes = {}
        settingReads = 0

        originalPrint = _G.print
        _G.print = spy.new(function() end)

        originalLibStub = _G.LibStub
        _G.LibStub = function()
            return {HashTable = function() return {} end}
        end

        _G.CreateFrame = function(_, _, _, template)
            local frame = NewFakeFrame(template)
            if template == "SettingsCheckboxTemplate" then
                table.insert(checkboxes, frame)
            end
            return frame
        end
        _G.GetScreenHeight = function() return 1000 end
        _G.UISpecialFrames = {}
        _G.tinsert = table.insert
        _G.SettingsPanel = NewFakeFrame()
        _G.CreateScrollBoxLinearView = function() return NewFakeFrame() end
        _G.ScrollUtil = NewFakeFrame()
        _G.Settings = {
            RegisterCanvasLayoutCategory = function() return {} end,
            RegisterCanvasLayoutSubcategory = function() return {} end,
            RegisterAddOnCategory = function() end,
        }
        Questie.Colorize = function(_, text) return text end

        -- A fresh registry, because the engine keeps its window on the module table between loads.
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsEngine.lua")
        QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        StubTabs()
    end)

    after_each(function()
        _G.print = originalPrint
        _G.LibStub = originalLibStub
    end)

    describe("after the startup build", function()
        before_each(function()
            FinishBuild(StartBuild())
        end)

        it("should refresh every control when a checkbox is clicked outside a coroutine", function()
            local parent = checkboxes[POPUP_PARENT]
            assert.is_false(checkboxes[POPUP_DEPENDENT].isEnabled)

            parent.isChecked = true
            parent.scripts.OnClick(parent)

            assert.is_true(settings.parent)
            assert.is_true(checkboxes[BLIZZARD_PARENT].isChecked)
            assert.is_true(checkboxes[BLIZZARD_DEPENDENT].isEnabled)
            assert.is_true(checkboxes[POPUP_DEPENDENT].isEnabled)
        end)

        it("should open and close the window when toggled", function()
            QuestieOptionsEngine:ToggleConfigWindow()
            assert.is_true(QuestieOptionsEngine:IsShown())

            QuestieOptionsEngine:ToggleConfigWindow()
            assert.is_false(QuestieOptionsEngine:IsShown())
            assert.spy(_G.print).was.not_called()
        end)

        it("should only refresh controls through RefreshIfShown while the window is open", function()
            settings.parent = true

            QuestieOptionsEngine:RefreshIfShown()
            assert.is_false(checkboxes[POPUP_DEPENDENT].isEnabled)

            QuestieOptionsEngine:ShowFrame()
            QuestieOptionsEngine:RefreshIfShown()
            assert.is_true(checkboxes[POPUP_DEPENDENT].isEnabled)
        end)
    end)

    describe("during the startup build", function()
        -- The Hardcore script limit is why this work is spread out. One resume may build one control and refresh one.
        it("should not refresh many controls in a single resume when radio buttons are built", function()
            local buildThread = StartBuild()
            local mostReadsInOneResume = 0

            while coroutine.status(buildThread) ~= "dead" do
                local readsBefore = settingReads
                ResumeBuild(buildThread)
                mostReadsInOneResume = math.max(mostReadsInOneResume, settingReads - readsBefore)
            end

            assert.is_true(mostReadsInOneResume <= 2, "read " .. mostReadsInOneResume .. " settings in one resume")
        end)
    end)

    describe("while the startup build is still running", function()
        local buildThread

        before_each(function()
            buildThread = StartBuild()
            while not QuestieOptionsEngine.standaloneWindow do
                ResumeBuild(buildThread)
            end
            assert.are_equal("suspended", coroutine.status(buildThread))
        end)

        it("should report the window as closed", function()
            assert.is_false(QuestieOptionsEngine:IsShown())
        end)

        it("should tell the user to wait instead of opening a half-built window", function()
            QuestieOptionsEngine:ToggleConfigWindow()

            assert.is_false(QuestieOptionsEngine.standaloneWindow:IsShown())
            assert.spy(_G.print).was.called_with(LOADING_MESSAGE)
        end)

        it("should stay silent when asked to hide or refresh", function()
            QuestieOptionsEngine:HideFrame()
            QuestieOptionsEngine:RefreshIfShown()

            assert.spy(_G.print).was.not_called()
        end)

        it("should open normally once the build finishes", function()
            FinishBuild(buildThread)

            QuestieOptionsEngine:ToggleConfigWindow()

            assert.is_true(QuestieOptionsEngine:IsShown())
        end)
    end)
end)
