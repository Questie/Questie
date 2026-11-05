dofile("setupTests.lua")

describe("QuestieTraceMenu", function()
    local QuestieTraceMenu
    local originalTrace

    before_each(function()
        originalTrace = _G.QuestieTraceCore
        _G.QuestieTraceCore = nil
        dofile("Localization/l10n.lua")
        dofile("Modules/QuestieMenu/QuestieTraceMenu.lua")
        QuestieTraceMenu = QuestieLoader:ImportModule("QuestieTraceMenu")
    end)

    after_each(function()
        _G.QuestieTraceCore = originalTrace
    end)

    it("does not add a menu entry when QuestieTrace is not installed", function()
        assert.is_nil(QuestieTraceMenu.Build(function() end))
    end)

    it("opens the export window and shows green while capture is running", function()
        local shown = 0
        local trace = {
            GetStatusData = function() return {isRunning = true} end,
            ShowExportWindow = function() shown = shown + 1 end,
        }
        _G.QuestieTraceCore = trace

        local clickedTrace, clickedButton
        local entry = QuestieTraceMenu.Build(function(value, button)
            clickedTrace, clickedButton = value, button
        end)
        assert.are_equal("QuestieTrace", entry.text)
        assert.is_true(entry.checked)
        assert.are_equal("Interface\\COMMON\\Indicator-Green", entry.customCheckIconTexture)
        assert.are_equal("Interface\\COMMON\\Indicator-Red", entry.customUncheckIconTexture)
        entry.func(nil, nil, nil, nil, "LeftButton")
        assert.are_same(trace, clickedTrace)
        assert.are_equal("LeftButton", clickedButton)
        clickedTrace.ShowExportWindow()
        assert.are_equal(1, shown)
    end)

    it("shows red when capture is not running", function()
        _G.QuestieTraceCore = {
            GetStatusData = function() return {isRunning = false} end,
            ShowExportWindow = function() end,
        }

        local entry = QuestieTraceMenu.Build(function() end)
        assert.is_false(entry.checked)
        assert.are_equal("Interface\\COMMON\\Indicator-Green", entry.customCheckIconTexture)
        assert.are_equal("Interface\\COMMON\\Indicator-Red", entry.customUncheckIconTexture)
    end)

    it("stops a running capture", function()
        local calls = {}
        local trace = {
            GetStatusData = function() return {isRunning = true} end,
            StopCapture = function() calls[#calls + 1] = "stop" end,
            SaveCapture = function() calls[#calls + 1] = "save" end,
            StartCapture = function() calls[#calls + 1] = "start" end,
        }

        QuestieTraceMenu.Toggle(trace)
        assert.are_same({"stop"}, calls)
    end)

    it("saves a stopped capture before starting the next one", function()
        local calls = {}
        local trace = {
            GetStatusData = function() return {isRunning = false} end,
            StopCapture = function() calls[#calls + 1] = "stop" end,
            SaveCapture = function() calls[#calls + 1] = "save" end,
            StartCapture = function() calls[#calls + 1] = "start" end,
        }

        QuestieTraceMenu.Toggle(trace)
        assert.are_same({"save", "start"}, calls)
    end)
end)

