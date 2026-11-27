dofile("setupTests.lua")

describe("QuestMapHover", function()
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestMapHover
    local QuestMapHover

    ---@type table<string, {func: function, owner: table}>
    local callbacks
    local onHide

    ---@param questId QuestId
    local function CreateIcon(questId)
        return {
            data = {Id = questId},
            miniMapIcon = false,
            SetHoverHighlight = spy.new(function() end),
        }
    end

    ---Whether any call restored the icon after a highlight.
    ---@param icon table
    local function WasCleared(icon)
        for _, call in ipairs(icon.SetHoverHighlight.calls) do
            if call.refs[2] == false then
                return true
            end
        end
        return false
    end

    local function Fire(event, questId)
        local callback = callbacks[event]
        assert.is_not_nil(callback, "expected the module to register " .. event)
        callback.func(callback.owner, questId)
    end

    before_each(function()
        callbacks = {}
        onHide = nil

        _G.EventRegistry = {
            RegisterCallback = function(_, event, func, owner)
                callbacks[event] = {func = func, owner = owner}
            end,
        }
        _G.QuestMapFrame = {
            HookScript = function(_, event, func)
                if event == "OnHide" then
                    onHide = func
                end
            end,
        }

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.questIdFrames = {}
        QuestieMap.GetFramesForQuest = function(_, questId)
            return QuestieMap.questIdFrames[questId] or {}
        end

        dofile("Modules/Map/QuestMapHover.lua")
        QuestMapHover = QuestieLoader:ImportModule("QuestMapHover")
    end)

    it("registers the map quest log highlight callbacks", function()
        assert.is_not_nil(callbacks["SetHighlightedQuestPOI"])
        assert.is_not_nil(callbacks["ClearHighlightedQuestPOI"])
    end)

    it("highlights the world map and minimap icons of the hovered quest", function()
        local mapIcon = CreateIcon(1)
        local minimapIcon = CreateIcon(1)
        minimapIcon.miniMapIcon = true
        QuestieMap.questIdFrames[1] = {mapIcon, minimapIcon}

        Fire("SetHighlightedQuestPOI", 1)

        assert.spy(mapIcon.SetHoverHighlight).was.called_with(mapIcon, true)
        assert.spy(minimapIcon.SetHoverHighlight).was.called_with(minimapIcon, true)
    end)

    it("leaves the icons of other quests alone", function()
        local hoveredIcon = CreateIcon(1)
        local otherIcon = CreateIcon(2)
        QuestieMap.questIdFrames[1] = {hoveredIcon}
        QuestieMap.questIdFrames[2] = {otherIcon}

        Fire("SetHighlightedQuestPOI", 1)

        assert.spy(hoveredIcon.SetHoverHighlight).was.called_with(hoveredIcon, true)
        assert.spy(otherIcon.SetHoverHighlight).was.not_called()
    end)

    it("restores the icons when the hover ends", function()
        local mapIcon = CreateIcon(1)
        QuestieMap.questIdFrames[1] = {mapIcon}

        Fire("SetHighlightedQuestPOI", 1)
        Fire("ClearHighlightedQuestPOI", 1)

        assert.spy(mapIcon.SetHoverHighlight).was.called_with(mapIcon, false)
    end)

    it("switches the highlight to the quest hovered next", function()
        local firstIcon = CreateIcon(1)
        local secondIcon = CreateIcon(2)
        QuestieMap.questIdFrames[1] = {firstIcon}
        QuestieMap.questIdFrames[2] = {secondIcon}

        Fire("SetHighlightedQuestPOI", 1)
        Fire("SetHighlightedQuestPOI", 2)

        assert.spy(firstIcon.SetHoverHighlight).was.called_with(firstIcon, false)
        assert.spy(secondIcon.SetHoverHighlight).was.called_with(secondIcon, true)
    end)

    it("highlights the icons of a quest hovered in the tracker", function()
        local mapIcon = CreateIcon(1)
        local minimapIcon = CreateIcon(1)
        minimapIcon.miniMapIcon = true
        QuestieMap.questIdFrames[1] = {mapIcon, minimapIcon}

        QuestMapHover.HighlightQuest(1, QuestMapHover.SOURCE_TRACKER)

        assert.spy(mapIcon.SetHoverHighlight).was.called_with(mapIcon, true)
        assert.spy(minimapIcon.SetHoverHighlight).was.called_with(minimapIcon, true)
    end)

    it("keeps a tracker highlight when the quest log clears", function()
        local mapIcon = CreateIcon(1)
        QuestieMap.questIdFrames[1] = {mapIcon}
        QuestMapHover.HighlightQuest(1, QuestMapHover.SOURCE_TRACKER)

        Fire("ClearHighlightedQuestPOI")

        assert.is_false(WasCleared(mapIcon))
    end)

    it("keeps a quest log highlight when the tracker clears", function()
        local mapIcon = CreateIcon(1)
        QuestieMap.questIdFrames[1] = {mapIcon}
        Fire("SetHighlightedQuestPOI", 1)

        QuestMapHover.ClearQuest(QuestMapHover.SOURCE_TRACKER)

        assert.is_false(WasCleared(mapIcon))

        QuestMapHover.ClearQuest(QuestMapHover.SOURCE_MAP_QUEST_LOG)

        assert.is_true(WasCleared(mapIcon))
    end)

    it("drops the highlight when the quest log panel hides", function()
        local mapIcon = CreateIcon(1)
        QuestieMap.questIdFrames[1] = {mapIcon}
        Fire("SetHighlightedQuestPOI", 1)

        assert.is_not_nil(onHide, "expected the module to hook the quest log panel's OnHide")
        onHide()

        assert.spy(mapIcon.SetHoverHighlight).was.called_with(mapIcon, false)
    end)

    it("keeps a tracker highlight when the quest log panel hides", function()
        local mapIcon = CreateIcon(1)
        QuestieMap.questIdFrames[1] = {mapIcon}
        -- Only a map quest log hover installs the panel hook, which the tracker highlight then has to survive.
        Fire("SetHighlightedQuestPOI", 1)
        QuestMapHover.HighlightQuest(1, QuestMapHover.SOURCE_TRACKER)

        assert.is_not_nil(onHide, "expected the module to hook the quest log panel's OnHide")
        local callCount = #mapIcon.SetHoverHighlight.calls
        onHide()

        assert.are.equal(callCount, #mapIcon.SetHoverHighlight.calls)
    end)
end)
