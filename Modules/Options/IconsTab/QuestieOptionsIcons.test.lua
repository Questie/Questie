dofile("setupTests.lua")

describe("objective rendering presets", function()
    local options, utils, quest, expansions, defaults
    local originals
    local nativeObjectives

    before_each(function()
        options = QuestieLoader:ImportModule("QuestieOptions")
        utils = QuestieLoader:ImportModule("QuestieOptionsUtils")
        quest = QuestieLoader:ImportModule("QuestieQuest")
        expansions = QuestieLoader:ImportModule("Expansions")
        originals = {
            db = Questie.db,
            icons = Questie.icons,
            SetIcons = Questie.SetIcons,
            tabs = options.tabs,
            Spacer = utils.Spacer,
            DetermineTheme = utils.DetermineTheme,
            ExecuteTheme = utils.ExecuteTheme,
            SetPfQuestIcons = utils.SetPfQuestIcons,
            SmoothReset = quest.SmoothReset,
            expansion = expansions.Current,
            GetCVar = _G.GetCVar,
            SetCVar = _G.SetCVar,
            WorldMapQuestShowObjectives = _G.WorldMapQuestShowObjectives,
        }
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsDefaults.lua")
        defaults = QuestieLoader:ImportModule("QuestieOptionsDefaults"):Load()
        Questie.db = defaults
        Questie.icons = {
            slay = "slay", loot = "loot", event = "event", object = "object",
            talk = "talk", interact = "interact", node = "node", complete = "complete",
        }
        Questie.SetIcons = spy.new(function() end)
        quest.SmoothReset = spy.new(function() end)
        options.tabs = {}
        utils.Spacer = function() return {} end
        nativeObjectives = "1"
        _G.GetCVar = function() return nativeObjectives end
        _G.SetCVar = spy.new(function(_, value) nativeObjectives = value end)
        _G.WorldMapQuestShowObjectives = nil
        expansions.Current = expansions.Wotlk
        dofile("Modules/Options/IconsTab/QuestieOptionsIcons.lua")
    end)

    after_each(function()
        Questie.db = originals.db
        Questie.icons = originals.icons
        Questie.SetIcons = originals.SetIcons
        options.tabs = originals.tabs
        utils.Spacer = originals.Spacer
        utils.DetermineTheme = originals.DetermineTheme
        utils.ExecuteTheme = originals.ExecuteTheme
        utils.SetPfQuestIcons = originals.SetPfQuestIcons
        quest.SmoothReset = originals.SmoothReset
        expansions.Current = originals.expansion
        _G.GetCVar = originals.GetCVar
        _G.SetCVar = originals.SetCVar
        _G.WorldMapQuestShowObjectives = originals.WorldMapQuestShowObjectives
    end)

    it("leaves new profiles on ordinary Questie objectives", function()
        assert.is_false(defaults.profile.enableQuestiePolygons)
        assert.are_same("questie", defaults.profile.iconTheme)
    end)

    it("selects generated map areas without changing minimap visibility", function()
        Questie.db.profile.enableObjectives = false
        Questie.db.profile.enableMiniMapIcons = false

        utils.ExecuteTheme(nil, "polygon")

        assert.is_true(Questie.db.profile.enableQuestiePolygons)
        assert.is_true(Questie.db.profile.enableObjectives)
        assert.is_false(Questie.db.profile.enableMiniMapIcons)
        assert.are_same("polygon", Questie.db.profile.iconTheme)
        assert.are_same("slay", Questie.db.profile.ICON_SLAY)
        assert.are_same("loot", Questie.db.profile.ICON_LOOT)
        assert.are_same("0", nativeObjectives)
        assert.spy(_G.SetCVar).was.called_with("questPOI", "0")
        assert.spy(Questie.SetIcons).was.called_with(Questie)
        assert.spy(quest.SmoothReset).was.called_with(quest)
    end)

    it("allows the polygon preset on clients without native quest POIs", function()
        nativeObjectives = nil

        utils.ExecuteTheme(nil, "polygon")

        assert.is_true(Questie.db.profile.enableQuestiePolygons)
        assert.spy(_G.SetCVar).was.not_called()
        assert.spy(quest.SmoothReset).was.called_with(quest)
    end)

    it("keeps polygon mode selected after an icon preference changes", function()
        utils.ExecuteTheme(nil, "polygon")
        Questie.db.profile.ICON_SLAY = "custom-icon"
        Questie.db.profile.alwaysGlowMap = false

        utils.DetermineTheme()

        assert.are_same("polygon", Questie.db.profile.iconTheme)
        assert.is_true(Questie.db.profile.enableQuestiePolygons)
    end)

    local otherPresets = {
        {name = "Questie", value = "questie", objectives = true, native = "0"},
        {name = "pfQuest", value = "pfquest", objectives = true, native = "0"},
        {name = "Blizzard", value = "blizzard", objectives = false, native = "1"},
    }
    for _, preset in ipairs(otherPresets) do
        it("disables polygons and resets drawing when selecting " .. preset.name, function()
            Questie.db.profile.enableQuestiePolygons = true

            utils.ExecuteTheme(nil, preset.value)

            assert.is_false(Questie.db.profile.enableQuestiePolygons)
            assert.are_same(preset.objectives, Questie.db.profile.enableObjectives)
            assert.are_same(preset.native, nativeObjectives)
            assert.are_same(preset.value, Questie.db.profile.iconTheme)
            assert.spy(quest.SmoothReset).was.called_with(quest)
        end)
    end

    it("leaves polygon mode for Custom without overwriting customized icons", function()
        Questie.db.profile.enableQuestiePolygons = true
        Questie.db.profile.ICON_SLAY = "custom-icon"

        utils.ExecuteTheme(nil, "custom")

        assert.is_false(Questie.db.profile.enableQuestiePolygons)
        assert.are_same("custom-icon", Questie.db.profile.ICON_SLAY)
        assert.are_same("1", nativeObjectives)
        assert.spy(quest.SmoothReset).was.called_with(quest)
    end)

    it("does not redraw when selecting Custom outside polygon mode", function()
        utils.ExecuteTheme(nil, "custom")

        assert.is_false(Questie.db.profile.enableQuestiePolygons)
        assert.spy(quest.SmoothReset).was.not_called()
    end)

    it("offers Questie blobs in Era options without offering Blizzard objectives", function()
        expansions.Current = expansions.Era
        local picker = options.tabs.icons:Initialize().args.iconThemePicker

        assert.are_same("Questie blobs", picker.values().polygon)
        assert.is_nil(picker.values().blizzard)
        assert.are_same({"questie", "polygon", "pfquest", "custom"}, picker.sorting)
    end)

    it("keeps existing themes alongside Questie blobs on WotLK and later", function()
        local picker = options.tabs.icons:Initialize().args.iconThemePicker

        assert.are_same("Questie blobs", picker.values().polygon)
        assert.are_same({"questie", "polygon", "blizzard", "pfquest", "custom"}, picker.sorting)
    end)
end)
