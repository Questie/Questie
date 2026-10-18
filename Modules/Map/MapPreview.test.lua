dofile("setupTests.lua")

describe("MapPreview", function()
    ---@type MapPreview
    local MapPreview
    local QuestieFrame, QuestieMap, savedError, hovered, ended, icons

    ---Registers an icon of quest 42 as QuestieMap does, by its frame's global name.
    local function Icon(name, data, fields)
        local icon = fields or {}
        icon.data = data
        _G[name] = icon
        QuestieMap.questIdFrames[42][name] = name
        icons[#icons + 1] = name
        return icon
    end

    before_each(function()
        hovered, ended, icons = {}, {}, {}
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.questIdFrames = {[42] = {}}
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrame.ApplyHoverHighlights = function(icon) hovered[icon] = icon.data end
        QuestieFrame.ResetHoverHighlights = function(icon, data) ended[#ended + 1] = {icon = icon, data = data} end
        savedError = Questie.Error
        dofile("Modules/Map/MapPreview.lua")
        MapPreview = QuestieLoader:ImportModule("MapPreview")
    end)

    after_each(function()
        Questie.Error = savedError
        for _, name in ipairs(icons) do _G[name] = nil end
    end)

    it("hovers each world map icon of the objective until it ends, each hover ending with its data", function()
        local first = Icon("QuestieFrame1", {Id = 42, Type = "monster", ObjectiveIndex = 1})
        local second = Icon("QuestieFrame2", {Id = 42, Type = "item", ObjectiveIndex = 1})
        local secondData = second.data
        Icon("QuestieFrame3", {Id = 42, Type = "monster", ObjectiveIndex = 2})
        Icon("QuestieFrame4", {Id = 42, Type = "monster", ObjectiveIndex = 1}, {miniMapIcon = true})
        Icon("QuestieFrame5", {Id = 42, Type = "monster", ObjectiveIndex = 1}, {hidden = true})
        Icon("QuestieFrame6", {Id = 42, Type = "complete"})
        Icon("QuestieFrame7", nil) -- Pooled.

        local preview = MapPreview.Start(42, 1)
        assert.are.same({[first] = first.data, [second] = secondData}, hovered)

        -- The pool hands an icon out for other data before the preview ends.
        second.data = {}
        MapPreview.End(preview)
        assert.are.equal(2, #ended)
        local endedData = {}
        for _, hover in ipairs(ended) do endedData[hover.icon] = hover.data end
        assert.are.same({[first] = first.data, [second] = secondData}, endedData)

        -- Ending it again ends nothing more.
        MapPreview.End(preview)
        assert.are.equal(2, #ended)
    end)

    it("previews every objective of the quest without an objective", function()
        local first = Icon("QuestieFrame1", {Id = 42, Type = "monster", ObjectiveIndex = 1})
        local other = Icon("QuestieFrame2", {Id = 42, Type = "event", ObjectiveIndex = 2})
        Icon("QuestieFrame3", {Id = 42, Type = "available"})

        MapPreview.Start(42)

        assert.are.same({[first] = first.data, [other] = other.data}, hovered)
        -- A quest without icons previews nothing.
        MapPreview.Start(7)
    end)

    it("tells each listener as a preview starts and ends, and reports a failing one once", function()
        local heard = {}
        Questie.Error = spy.new(function() end)
        MapPreview.Subscribe(function() error("broken feature") end)
        MapPreview.Subscribe(function(questId, objectiveIndex, previewing) heard[#heard + 1] = {questId, objectiveIndex, previewing} end)

        local objectivePreview = MapPreview.Start(42, 3)
        local questPreview = MapPreview.Start(42)
        MapPreview.End(objectivePreview)
        MapPreview.End(questPreview)

        assert.are.same({{42, 3, true}, {42, nil, true}, {42, 3, false}, {42, nil, false}}, heard)
        assert.spy(Questie.Error).was.called(1)
    end)
end)
