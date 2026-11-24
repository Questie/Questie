dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyIcon", function()
    ---@type JourneyIcon
    local JourneyIcon
    local ui
    local texture

    local CHECKMARK = "Interface\\RaidFrame\\ReadyCheck-Ready"
    local COLORFUL = {1, 1, 1}

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")

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
