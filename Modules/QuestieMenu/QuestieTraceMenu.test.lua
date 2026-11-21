dofile("setupTests.lua")

describe("QuestieTraceMenu", function()
    local QuestieTraceMenu
    local originalTrace

    local function makeButton()
        local button = {fontString = {}}
        function button.fontString:SetTextColor(...) self.color = {...} end
        return button
    end

    local function makeApi(state)
        local api = {calls = {}, state = state}
        function api.GetConsentState() return state.consent end
        function api.IsCaptureRunning() return state.running end
        function api.ShowConsentPrompt() api.calls[#api.calls + 1] = "prompt" end
        function api.StartCapture() api.calls[#api.calls + 1] = "start"; state.running = true; return true end
        function api.StopCapture() api.calls[#api.calls + 1] = "stop"; state.running = false end
        function api.ShowExportWindow() api.calls[#api.calls + 1] = "export" end
        return api
    end

    before_each(function()
        originalTrace = _G.QuestieTraceAPI
        _G.QuestieTraceAPI = nil
        dofile("Localization/l10n.lua")
        dofile("Modules/QuestieMenu/QuestieTraceMenu.lua")
        QuestieTraceMenu = QuestieLoader:ImportModule("QuestieTraceMenu")
    end)

    after_each(function()
        _G.QuestieTraceAPI = originalTrace
    end)

    it("should not add a menu entry when QuestieTrace is not installed", function()
        assert.is_nil(QuestieTraceMenu.Build(function() end))
    end)

    it("should open the export window through the QuestieMenu callback and show green while capture is running", function()
        local originalTinsert = _G.tinsert
        local originalDb = Questie.db
        local originalMenuResponse = _G.MenuResponse
        local menuTable
        local shown = 0
        local api = makeApi({running = true})
        api.ShowExportWindow = function() shown = shown + 1 end
        local questieLib = QuestieLoader:ImportModule("QuestieLib")
        local questieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        local professionStations = QuestieLoader:ImportModule("ProfessionStations")
        local townsfolk = QuestieLoader:ImportModule("Townsfolk")
        local professionKeys = {}
        for _, key in ipairs({
            "FIRST_AID", "BLACKSMITHING", "LEATHERWORKING", "ALCHEMY", "HERBALISM", "COOKING", "MINING",
            "TAILORING", "ENGINEERING", "ENCHANTING", "FISHING", "SKINNING", "JEWELCRAFTING", "ARCHAEOLOGY",
            "INSCRIPTION", "RIDING",
        }) do
            professionKeys[key] = key
        end

        questieLib.AddonPath = ""
        questieProfessions.professionKeys = professionKeys
        questieProfessions.Update = function() end
        questieProfessions.HasProfessionAndSkillLevel = function() return false end
        professionStations.stations = {}
        townsfolk.townsfolk = {}
        townsfolk.professionTrainers = {}
        Questie.db = {
            char = {townsfolk = {}, vendorList = {}},
            profile = {townsfolkConfig = {}, debugEnabled = false},
        }
        _G.QuestieTraceAPI = {v1 = api}
        _G.MenuResponse = {CloseAll = 4}

        local builder = QuestieLoader:CreateModule("QuestieMenuBuilder")
        builder.Show = function(entries) menuTable = entries end
        local questiePopup = QuestieLoader:ImportModule("QuestiePopup")
        questiePopup.Dialogs = questiePopup.Dialogs or {}
        _G.tinsert = table.insert
        dofile("Modules/QuestieMenu/QuestieMenu.lua")
        local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
        QuestieMenu:Show()

        local entry
        for _, menuEntry in ipairs(menuTable) do
            if menuEntry.text == "QuestieTrace" then
                entry = menuEntry
                break
            end
        end
        assert.is_not_nil(entry)
        assert.is_true(entry.checked())
        assert.is_true(entry.registerForRightClick)
        assert.is_true(entry.keepShownOnClick)
        local button = makeButton()
        entry.initializer(button)
        assert.are_same({0.25, 1.0, 0.25}, button.fontString.color)
        assert.are_equal(MenuResponse.CloseAll, entry.func("LeftButton"))
        assert.are_equal(1, shown)

        _G.tinsert = originalTinsert
        _G.MenuResponse = originalMenuResponse
        Questie.db = originalDb
    end)

    it("should show red when capture is not running", function()
        _G.QuestieTraceAPI = {v1 = makeApi({running = false})}

        local entry = QuestieTraceMenu.Build(function() end)
        local button = makeButton()
        entry.initializer(button)

        assert.is_false(entry.checked())
        assert.are_same({1.0, 0.25, 0.25}, button.fontString.color)
    end)

    it("should pass the clicked mouse button and the response to the callback", function()
        _G.QuestieTraceAPI = {v1 = makeApi({running = false})}
        local clicked
        local entry = QuestieTraceMenu.Build(function(_, button) clicked = button; return "response" end)

        assert.are_equal("response", entry.func("RightButton"))
        assert.are_equal("RightButton", clicked)
    end)

    it("should follow the real capture state after a refused right-click start", function()
        local api = makeApi({running = false, consent = "granted"})
        api.StartCapture = function() return false end
        _G.QuestieTraceAPI = {v1 = api}
        local entry = QuestieTraceMenu.Build(function(traceApi) QuestieTraceMenu.Toggle(traceApi) end)

        entry.func("RightButton")

        assert.is_false(entry.checked())
    end)

    it("should stop a running capture", function()
        local api = makeApi({running = true})
        QuestieTraceMenu.Toggle(api)
        assert.are_same({"stop"}, api.calls)
    end)

    it("should start when consent is granted", function()
        local api = makeApi({running = false, consent = "granted"})
        QuestieTraceMenu.Toggle(api)
        assert.are_same({"start"}, api.calls)
    end)

    for _, consent in ipairs({"unset", "declined"}) do
        it("should only show the consent prompt and never start when consent is " .. consent, function()
            local api = makeApi({running = false, consent = consent})
            QuestieTraceMenu.Toggle(api)
            assert.are_same({"prompt"}, api.calls)
        end)
    end

    it("should print start and stop messages only when the state changed", function()
        local originalPrint = Questie.Print
        local messages = {}
        Questie.Print = function(_, message) messages[#messages + 1] = message end
        local api = makeApi({running = false, consent = "granted"})

        api.StartCapture = function() return false end
        QuestieTraceMenu.Toggle(api)
        assert.are_same({}, messages)

        api.StartCapture = function() api.state.running = true; return true end
        QuestieTraceMenu.Toggle(api)
        QuestieTraceMenu.Toggle(api)
        Questie.Print = originalPrint

        assert.are_same({"QuestieTrace started", "QuestieTrace stopped"}, messages)
    end)
end)
