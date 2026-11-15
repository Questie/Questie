dofile("setupTests.lua")

describe("QuestieTraceMenu", function()
    local QuestieTraceMenu
    local originalTrace

    local function makeButton()
        local function makeTexture()
            return {
                SetVertexColor = function() end,
                SetTexture = function() end,
                SetTexCoord = function() end,
                SetShown = function() end,
            }
        end
        return {
            Check = makeTexture(),
            UnCheck = makeTexture(),
            SetShown = function() end,
            LockHighlight = function() end,
            UnlockHighlight = function() end,
        }
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
        local originalLibStub = _G.LibStub
        local originalTinsert = _G.tinsert
        local originalDb = Questie.db
        local menuTable
        local shown = 0
        local api = makeApi({running = true})
        api.ShowExportWindow = function() shown = shown + 1 end
        local questieLib = QuestieLoader:ImportModule("QuestieLib")
        local questieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
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
        questieProfessions.HasProfessionAndSkillLevel = function() return false end
        townsfolk.townsfolk = {}
        townsfolk.professionTrainers = {}
        Questie.db = {
            char = {townsfolk = {}, vendorList = {}},
            profile = {townsfolkConfig = {}, debugEnabled = false},
        }
        _G.QuestieTraceAPI = {v1 = api}

        local dropdown = {
            Create_UIDropDownMenu = function() return {} end,
            EasyMenu = function(_, entries) menuTable = entries end,
            CloseDropDownMenus = spy.new(function() end),
        }
        local questiePopup = QuestieLoader:ImportModule("QuestiePopup")
        questiePopup.Dialogs = questiePopup.Dialogs or {}
        _G.tinsert = table.insert
        _G.LibStub = {GetLibrary = function() return dropdown end}
        dofile("Modules/QuestieMenu/QuestieMenu.lua")
        local QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
        QuestieMenu.menu = nil
        QuestieMenu.Hide = spy.new(function() end)
        QuestieMenu:Show()

        local entry
        for _, menuEntry in ipairs(menuTable) do
            if menuEntry.text == "QuestieTrace" then
                entry = menuEntry
                break
            end
        end
        assert.is_not_nil(entry)
        assert.is_true(entry.checked(makeButton()))
        assert.is_true(entry.registerForRightClick)
        assert.is_true(entry.keepShownOnClick)
        entry.func(nil, nil, nil, nil, "LeftButton")
        assert.spy(QuestieMenu.Hide).was.called(1)
        assert.are_equal(1, shown)

        _G.LibStub = originalLibStub
        _G.tinsert = originalTinsert
        Questie.db = originalDb
    end)

    it("should show red when capture is not running", function()
        _G.QuestieTraceAPI = {v1 = makeApi({running = false})}

        local entry = QuestieTraceMenu.Build(function() end)
        assert.is_false(entry.checked(makeButton()))
    end)

    it("should refresh the indicator after a refused right-click start", function()
        local originalTimer = _G.C_Timer
        local deferred
        _G.C_Timer = {After = function(_, callback) deferred = callback end}
        _G.QuestieTraceAPI = {v1 = makeApi({running = false})}
        local entry = QuestieTraceMenu.Build(function() end)
        local button = makeButton()
        button.checked = true
        entry.func(button, nil, nil, true, "RightButton")
        assert.is_true(button.checked)
        deferred()
        assert.is_false(button.checked)
        _G.C_Timer = originalTimer
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
