dofile("setupTests.lua")

describe("objective style tutorial", function()
    local Tutorial, utils
    local originals, buttons, frames

    local function _CreateFrame(frameType, name, parent, template)
        local frame = {frameType = frameType, name = name, parent = parent, template = template, scripts = {}, fonts = {}}
        function frame:SetSize(width, height) self.width, self.height = width, height end
        function frame:SetPoint(...) self.point = {...} end
        function frame:SetFrameStrata() end
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

    before_each(function()
        Tutorial = QuestieLoader:ImportModule("Tutorial")
        utils = QuestieLoader:ImportModule("QuestieOptionsUtils")
        originals = {
            db = Questie.db,
            IsForever = Questie.IsForever,
            CreateFrame = _G.CreateFrame,
            ExecuteTheme = utils.ExecuteTheme,
            CreateChooseObjectiveTypeFrame = Tutorial.CreateChooseObjectiveTypeFrame,
        }
        Questie.db = {global = {tutorialObjectiveTypeChosen = false}}
        Questie.IsForever = true
        buttons, frames = {}, {}
        _G.CreateFrame = _CreateFrame
        utils.ExecuteTheme = spy.new(function() end)
        dofile("Localization/l10n.lua")
        dofile("Localization/Translations/Tutorial.lua")
        dofile("Modules/Tutorial/ChooseObjectiveType.lua")
        Tutorial.CreateChooseObjectiveTypeFrame()
    end)

    after_each(function()
        Questie.db = originals.db
        Questie.IsForever = originals.IsForever
        _G.CreateFrame = originals.CreateFrame
        utils.ExecuteTheme = originals.ExecuteTheme
        Tutorial.CreateChooseObjectiveTypeFrame = originals.CreateChooseObjectiveTypeFrame
    end)

    it("selects the opt-in polygon preset and closes the popup", function()
        buttons["Questie blobs"]:GetScript("OnClick")()

        assert.is_true(Questie.db.global.tutorialObjectiveTypeChosen)
        assert.spy(utils.ExecuteTheme).was.called_with(nil, "polygon")
        assert.is_true(frames[1].hidden)
    end)

    it("makes the descriptive preview select the same polygon preset", function()
        local preview = buttons["Questie blobs"].point[2]

        preview:GetScript("OnClick")()

        assert.spy(utils.ExecuteTheme).was.called_with(nil, "polygon")
        assert.is_true(frames[1].hidden)
    end)

    it("describes map-only areas without borrowing another style's screenshot", function()
        local preview = buttons["Questie blobs"].point[2]

        assert.is_nil(preview.normalTexture)
        assert.are_same(
            "Clustered world-map markers.\n\nHover to preview an area.\nClick to keep it visible.\n\nMinimap icons stay unchanged.",
            preview.fonts[1].text
        )
    end)

    local existingChoices = {
        {label = "Questie Objectives", preset = "questie"},
        {label = "pfQuest Objectives", preset = "pfquest"},
        {label = "Blizzard Objectives", preset = "blizzard"},
    }
    for _, choice in ipairs(existingChoices) do
        it("keeps the existing " .. choice.label .. " choice", function()
            buttons[choice.label]:GetScript("OnClick")()

            assert.spy(utils.ExecuteTheme).was.called_with(nil, choice.preset)
            assert.is_true(Questie.db.global.tutorialObjectiveTypeChosen)
            assert.is_true(frames[1].hidden)
        end)
    end
end)
