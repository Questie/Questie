dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyIcon", function()
    ---@type JourneyIcon
    local JourneyIcon
    local ui
    local texture

    local CHECKMARK = "Interface\\RaidFrame\\ReadyCheck-Ready"
    local AVAILABLE = "Interface\\Addons\\Questie\\Icons\\available.blp"
    local COLORFUL = {1, 1, 1}

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
        Questie.icons = {available = AVAILABLE}

        texture = JourneyIcon.Create(CreateFrame("Frame", nil, UIParent))
    end)

    after_each(function()
        ui.Restore()
    end)

    local function AssertShowsCheckmark()
        assert.is_true(texture:IsShown())
        assert.are.equal(CHECKMARK, texture:GetTexture())
        assert.is_nil(texture.atlas)
        assert.is_false(texture.isDesaturated)
        assert.are_same(COLORFUL, texture.vertexColor)
    end

    local function AssertShowsHidden()
        assert.is_true(texture:IsShown())
        assert.are.equal("transmog-icon-hidden", texture.atlas)
        assert.is_true(texture.isDesaturated)
        assert.are_not_same(COLORFUL, texture.vertexColor)
    end

    it("should show a texture in its own colors", function()
        JourneyIcon.Set(texture, CHECKMARK)

        AssertShowsCheckmark()
    end)

    it("should show that something is hidden in gray", function()
        JourneyIcon.Set(texture, JourneyIcon.HIDDEN)

        AssertShowsHidden()
    end)

    it("should show a low-level quest as a darker available one", function()
        JourneyIcon.Set(texture, JourneyIcon.LOW_LEVEL)

        assert.is_true(texture:IsShown())
        assert.are.equal(AVAILABLE, texture:GetTexture())
        assert.is_false(texture.isDesaturated)
        assert.are_same({0.6, 0.6, 0.6}, texture.vertexColor)
    end)

    it("should show a texture in its own colors again after a darker one, and after a gray one", function()
        JourneyIcon.Set(texture, JourneyIcon.LOW_LEVEL)
        JourneyIcon.Set(texture, CHECKMARK)
        AssertShowsCheckmark()

        JourneyIcon.Set(texture, JourneyIcon.HIDDEN)
        JourneyIcon.Set(texture, JourneyIcon.LOW_LEVEL)
        assert.are_same({0, 1, 0, 1}, texture.texCoord)
        assert.is_false(texture.isDesaturated)
    end)

    it("should be the same in a text", function()
        assert.are.equal("|T" .. CHECKMARK .. ":14|t ", JourneyIcon.GetMarkup(CHECKMARK))
        assert.are.equal("|T" .. AVAILABLE .. ":14:14:0:0:64:64:0:64:0:64:153:153:153|t ", JourneyIcon.GetMarkup(JourneyIcon.LOW_LEVEL))
    end)

    it("should not keep anything of the icon it showed before", function()
        JourneyIcon.Set(texture, JourneyIcon.HIDDEN)
        JourneyIcon.Set(texture, CHECKMARK)
        AssertShowsCheckmark()

        JourneyIcon.Set(texture, JourneyIcon.HIDDEN)
        AssertShowsHidden()
    end)

    it("should not be stretched, whatever was shown before", function()
        for _ = 1, 2 do
            JourneyIcon.Set(texture, JourneyIcon.HIDDEN)
            -- The eye is 36 by 30 in one atlas, and 29 by 24 in the other
            assert.is_true(math.abs(texture:GetWidth() / texture:GetHeight() - 1.2) < 0.05)

            JourneyIcon.Set(texture, CHECKMARK)
            assert.are.equal(texture:GetHeight(), texture:GetWidth())
        end
    end)

    it("should show the whole image after a part of another one", function()
        JourneyIcon.Set(texture, JourneyIcon.HIDDEN)

        JourneyIcon.Set(texture, CHECKMARK)

        assert.are_same({0, 1, 0, 1}, texture.texCoord)
    end)

    it("should show nothing without an icon, and something again with one", function()
        JourneyIcon.Set(texture, JourneyIcon.HIDDEN)

        JourneyIcon.Set(texture, nil)
        assert.is_false(texture:IsShown())

        JourneyIcon.Set(texture, CHECKMARK)
        AssertShowsCheckmark()
    end)
end)
