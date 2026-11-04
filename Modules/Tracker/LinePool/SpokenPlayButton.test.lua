dofile("setupTests.lua")

describe("SpokenPlayButton", function()
    ---@type SpokenPlayButton
    local SpokenPlayButton
    local queuedLines, playNow, remove

    before_each(function()
        queuedLines = {}
        playNow = spy.new(function(_, soundData) queuedLines[soundData.questID] = soundData end)
        remove = spy.new(function(_, soundData) queuedLines[soundData.questID] = nil end)
        _G.VoiceOver = {
            QuestOverlayUI = {
                QueuedLine = function(_, questId) return queuedLines[questId] end,
            },
            Player = {PlayNow = playNow, Remove = remove},
            DataModules = {
                GetQuestLogQuestGiverTypeAndID = function() return "Creature", 456 end,
                GetObjectName = function(_, _, id) return "NPC " .. id end,
                PrepareSound = function(_, soundData) return soundData.event == 1 and soundData.questID == 123 end,
            },
            Enums = {
                SoundEvent = {QuestAccept = 1},
                GUID = {
                    CanHaveID = function() return true end,
                    IsCreature = function() return true end,
                },
            },
            Utils = {MakeGUID = function(_, giverType, id) return giverType .. "-" .. id end},
        }
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetQuestLogIndexByID = function() return 1 end
        QuestieCompat.GetQuestLogTitle = function() return "Quest title" end

        dofile("Modules/Tracker/LinePool/SpokenPlayButton.lua")
        SpokenPlayButton = QuestieLoader:ImportModule("SpokenPlayButton")
    end)

    after_each(function()
        _G.VoiceOver = nil
    end)

    it("should show the play button only for quests Spoken has audio for", function()
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))
        local otherButton = SpokenPlayButton.New(2, CreateFrame("Button"))

        button:SetPlayButton(123)
        otherButton:SetPlayButton(789)

        assert.is_true(button:IsVisible())
        assert.is_false(otherButton:IsVisible())
    end)

    it("should play the quest on click and stop it on the next click", function()
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))
        button:SetPlayButton(123)

        button.scripts.OnClick(button)

        assert.spy(playNow).was.called(1)
        assert.are_same({
            event = 1,
            questID = 123,
            name = "NPC 456",
            title = "Quest title",
            unitGUID = "Creature-456",
            unitIsObjectOrItem = false,
            origin = "Questie's tracker Play button",
            stopCallback = queuedLines[123].stopCallback,
        }, queuedLines[123])
        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogStopButton", button:GetNormalTexture():GetTexture())

        button.scripts.OnClick(button)

        assert.spy(remove).was.called(1)
        assert.is_nil(queuedLines[123])
        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton", button:GetNormalTexture():GetTexture())
    end)

    it("should show the play icon again when Spoken stops the line", function()
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))
        button:SetPlayButton(123)
        button.scripts.OnClick(button)
        local soundData = queuedLines[123]

        queuedLines[123] = nil
        soundData.stopCallback()

        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton", button:GetNormalTexture():GetTexture())
    end)

    it("should redraw when Spoken's voice packs are loaded", function()
        local callbacks = {}
        _G.Spoken = {RegisterCallback = function(_, event, callback) callbacks[event] = callback end}
        local onVoicePacksLoaded = function() end

        SpokenPlayButton.Initialize(onVoicePacksLoaded)
        _G.Spoken = nil

        assert.are_same({VOICE_PACKS_LOADED = onVoicePacksLoaded}, callbacks)
    end)
end)
