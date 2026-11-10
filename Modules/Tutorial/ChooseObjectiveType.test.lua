dofile("setupTests.lua")

describe("objective style tutorial", function()
    local Tutorial, utils, ObjectivePreview, Expansions
    local originals, buttons, frames, previews, reported

    local function _CreateFrame(frameType, name, parent, template)
        local frame = {frameType = frameType, name = name, parent = parent, template = template, scripts = {}, fonts = {}}
        function frame:SetSize(width, height) self.width, self.height = width, height end
        function frame:SetPoint(...) self.point = {...} end
        function frame:SetFrameStrata() end
        function frame:SetFrameLevel() end
        function frame:GetFrameLevel() return 1 end
        function frame:EnableMouse() end
        function frame:SetMovable() end
        function frame:RegisterForDrag() end
        function frame:RegisterForClicks() end
        function frame:SetBackdrop() end
        function frame:SetBackdropBorderColor() end
        function frame:LockHighlight() end
        function frame:UnlockHighlight() end
        function frame:SetNormalTexture(texture) self.normalTexture = texture end
        function frame:SetText(text) self.text = text; buttons[text] = self end
        function frame:SetScript(event, callback) self.scripts[event] = callback end
        function frame:GetScript(event) return self.scripts[event] end
        function frame:Hide() self.hidden = true end
        function frame:StartMoving() end
        function frame:StopMovingOrSizing() end
        function frame:CreateFontString()
            local font = {}
            function font:SetText(text) self.text = text end
            function font:SetWidth(width) self.width = width end
            function font:SetPoint(...) self.point = {...} end
            self.fonts[#self.fonts + 1] = font
            return font
        end
        frames[#frames + 1] = frame
        return frame
    end

    -- Clients by how they come: Blizzard's objectives need both the client and its questPOI setting.
    local FOREVER = {forever = true, expansion = "Era", questPOI = true}
    local WRATH = {forever = false, expansion = "Wotlk", questPOI = true}
    local ERA = {forever = false, expansion = "Era", questPOI = false}
    local ERA_WITH_SETTING = {forever = false, expansion = "Era", questPOI = true}

    local function _Open(client)
        Questie.IsForever = client.forever
        Expansions.Current = Expansions[client.expansion]
        _G.GetCVar = function(name) if name == "questPOI" and client.questPOI then return "0" end end
        Tutorial.CreateChooseObjectiveTypeFrame()
    end

    local function _Popup()
        for _, frame in ipairs(frames) do
            if frame.name == "QuestieTutorialChooseObjectiveType" then return frame end
        end
    end

    before_each(function()
        Tutorial = QuestieLoader:ImportModule("Tutorial")
        utils = QuestieLoader:ImportModule("QuestieOptionsUtils")
        ObjectivePreview = QuestieLoader:ImportModule("ObjectivePreview")
        Expansions = QuestieLoader:ImportModule("Expansions")
        originals = {
            db = Questie.db,
            IsForever = Questie.IsForever,
            current = Expansions.Current,
            CreateFrame = _G.CreateFrame,
            GetCVar = _G.GetCVar,
            CallErrorHandler = _G.CallErrorHandler,
            ExecuteTheme = utils.ExecuteTheme,
            CreateChooseObjectiveTypeFrame = Tutorial.CreateChooseObjectiveTypeFrame,
            CreatePreview = ObjectivePreview.Create,
        }
        Questie.db = {global = {}}
        buttons, frames, previews = {}, {}, {}
        _G.CreateFrame = _CreateFrame
        -- Lua 5.1's xpcall needs a plain function for a handler.
        reported = {}
        _G.CallErrorHandler = function(message) reported[#reported + 1] = message end
        utils.ExecuteTheme = spy.new(function() end)
        dofile("Modules/Tutorial/ObjectivePreview.lua")
        ObjectivePreview.Create = function(parent, style)
            previews[style] = _CreateFrame("Button", nil, parent)
            return previews[style]
        end
        dofile("Localization/l10n.lua")
        dofile("Localization/Translations/Tutorial.lua")
        dofile("Modules/Tutorial/ChooseObjectiveType.lua")
    end)

    after_each(function()
        Questie.db = originals.db
        Questie.IsForever = originals.IsForever
        Expansions.Current = originals.current
        _G.CreateFrame = originals.CreateFrame
        _G.GetCVar = originals.GetCVar
        _G.CallErrorHandler = originals.CallErrorHandler
        utils.ExecuteTheme = originals.ExecuteTheme
        Tutorial.CreateChooseObjectiveTypeFrame = originals.CreateChooseObjectiveTypeFrame
        ObjectivePreview.Create = originals.CreatePreview
    end)

    it("selects the opt-in polygon preset and closes the popup", function()
        _Open(FOREVER)

        buttons["Questie blobs"]:GetScript("OnClick")()

        assert.is_true(Questie.db.global.tutorialObjectiveStyleWithBlobsChosen)
        assert.spy(utils.ExecuteTheme).was.called_with(nil, "polygon")
        assert.is_true(_Popup().hidden)
    end)

    it("shows each Questie style's own live map, which selects that style", function()
        _Open(FOREVER)

        previews.icons:GetScript("OnClick")()
        assert.spy(utils.ExecuteTheme).was.called_with(nil, "questie")
        previews.blobs:GetScript("OnClick")()
        assert.spy(utils.ExecuteTheme).was.called_with(nil, "polygon")
    end)

    local existingChoices = {
        {label = "Questie Objectives", preset = "questie"},
        {label = "Blizzard Objectives", preset = "blizzard"},
    }
    for _, choice in ipairs(existingChoices) do
        it("keeps the existing " .. choice.label .. " choice", function()
            _Open(FOREVER)

            buttons[choice.label]:GetScript("OnClick")()

            assert.spy(utils.ExecuteTheme).was.called_with(nil, choice.preset)
            assert.is_true(Questie.db.global.tutorialObjectiveStyleWithBlobsChosen)
            assert.is_true(_Popup().hidden)
        end)
    end

    it("offers Blizzard's objectives from WotLK on, where the client has them", function()
        _Open(WRATH)
        assert.is_not_nil(buttons["Blizzard Objectives"])

        buttons = {}
        _Open(ERA_WITH_SETTING)
        assert.is_nil(buttons["Blizzard Objectives"])
    end)

    it("offers only Questie's styles on a client without Blizzard's objectives", function()
        _Open(ERA)

        assert.is_nil(buttons["Blizzard Objectives"])
        buttons["Questie Objectives"]:GetScript("OnClick")()
        assert.spy(utils.ExecuteTheme).was.called_with(nil, "questie")
    end)

    it("still offers a style whose map fails to build, over its old picture", function()
        ObjectivePreview.Create = function() error("no map") end

        _Open(FOREVER)

        assert.are_equal(2, #reported) -- One for each live map.
        assert.truthy(reported[1]:find("no map", 1, true))
        local questiePicture = buttons["Questie Objectives"].point[2]
        assert.are_equal("Interface\\Addons\\Questie\\Modules\\Tutorial\\onlyQuestie.blp", questiePicture.normalTexture)
        buttons["Questie blobs"].point[2]:GetScript("OnClick")()
        assert.spy(utils.ExecuteTheme).was.called_with(nil, "polygon")
    end)
end)
