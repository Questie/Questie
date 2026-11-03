dofile("setupTests.lua")

describe("VoiceOverPlayButton", function()
    ---@type VoiceOverPlayButton
    local VoiceOverPlayButton
    local playingSound

    before_each(function()
        playingSound = nil
        _G.VoiceOver = {
            QuestOverlayUI = {questPlayButtons = {[123] = {soundData = {questID = 123}}}},
            SoundQueue = {Contains = function(_, soundData) return soundData == playingSound end},
        }
        QuestieLoader:ImportModule("TrackerUtils").IsVoiceOverLoaded = function() return true end

        dofile("Modules/Tracker/LinePool/VoiceOverPlayButton.lua")
        VoiceOverPlayButton = QuestieLoader:ImportModule("VoiceOverPlayButton")
    end)

    after_each(function()
        _G.VoiceOver = nil
    end)

    it("should always show the play button of a quest without holding shift", function()
        local button = VoiceOverPlayButton.New(1, CreateFrame("Button"))

        button:SetPlayButton(123)

        assert.is_true(button:IsVisible())
        assert.are_same(1, button:GetAlpha())
        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton", button:GetNormalTexture():GetTexture())
    end)

    it("should show the stop icon while the quest sound plays", function()
        playingSound = _G.VoiceOver.QuestOverlayUI.questPlayButtons[123].soundData
        local button = VoiceOverPlayButton.New(1, CreateFrame("Button"))

        button:SetPlayButton(123)

        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogStopButton", button:GetNormalTexture():GetTexture())
    end)

    it("should hide without a quest", function()
        local button = VoiceOverPlayButton.New(1, CreateFrame("Button"))
        button:SetPlayButton(123)

        button:SetPlayButton(nil)

        assert.is_false(button:IsVisible())
    end)
end)
