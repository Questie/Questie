dofile("setupTests.lua")

describe("SpokenPlayButton", function()
    ---@type SpokenPlayButton
    local SpokenPlayButton
    local queuedLines, playNow, remove
    local originalQuestieDB
    local partOn, callbacks

    before_each(function()
        queuedLines = {}
        partOn = true
        callbacks = {}
        _G.Spoken = {
            IsPartOn = function(_, part) return part == "quests" and partOn end,
            RegisterCallback = function(_, event, callback) callbacks[event] = callback end,
        }
        originalQuestieDB = Questie.db
        Questie.db = {profile = {trackerShowPlayButtons = true}}
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
        _G.Spoken = nil
        Questie.db = originalQuestieDB
    end)

    it("should show the play button only for quests Spoken has audio for", function()
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))
        local otherButton = SpokenPlayButton.New(2, CreateFrame("Button"))

        button:SetPlayButton(123)
        otherButton:SetPlayButton(789)

        assert.is_true(button:IsVisible())
        assert.is_false(otherButton:IsVisible())
    end)

    it("should hide the play button when the play buttons setting is off", function()
        Questie.db.profile.trackerShowPlayButtons = false
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))

        button:SetPlayButton(123)

        assert.is_false(button:IsVisible())
        assert.is_nil(button.mode)
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

    it("should show the play icon on the new button when a playing quest moves to another line", function()
        SpokenPlayButton.Initialize(function() end)
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))
        local otherButton = SpokenPlayButton.New(2, CreateFrame("Button"))
        button:SetPlayButton(123)
        button.scripts.OnClick(button)
        button:SetPlayButton(nil)
        otherButton:SetPlayButton(123)

        queuedLines[123] = nil
        callbacks.AUDIO_CHANGED()

        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton", otherButton:GetNormalTexture():GetTexture())
    end)

    it("should show the stop icon when audio is queued outside of Questie", function()
        SpokenPlayButton.Initialize(function() end)
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))
        button:SetPlayButton(123)

        queuedLines[123] = {}
        callbacks.AUDIO_CHANGED()

        assert.are_same("Interface\\Addons\\Questie\\Icons\\QuestLogStopButton", button:GetNormalTexture():GetTexture())
    end)

    it("should hide the play button when Spoken's Quests part is off", function()
        partOn = false
        local button = SpokenPlayButton.New(1, CreateFrame("Button"))

        button:SetPlayButton(123)

        assert.is_false(button:IsVisible())
    end)

    it("should redraw when Spoken's voice packs are loaded or the Quests part is switched", function()
        local redraw = spy.new(function() end)

        SpokenPlayButton.Initialize(redraw)
        callbacks.VOICE_PACKS_LOADED()
        callbacks.PART_SWITCHED("gossip")
        callbacks.PART_SWITCHED("quests")

        assert.spy(redraw).was.called(2)
    end)
end)
