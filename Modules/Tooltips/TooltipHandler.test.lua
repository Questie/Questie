dofile("setupTests.lua")

describe("TooltipHandler", function()
    ---@type l10n
    local l10n
    ---@type QuestieTooltips
    local QuestieTooltips
    local _QuestieTooltips

    local PLAYER_ZONE = 440
    local OBJECT_NAME = "Battered Chest"

    ---Installs GameTooltip spies for lines, ID double lines, and Show.
    ---@return nil
    local function _MockGameTooltip()
        _G.GameTooltip = {
            AddLine = spy.new(function() end),
            AddDoubleLine = spy.new(function() end),
            Show = spy.new(function() end),
        }
    end

    before_each(function()
        _G.Questie.db.profile.enableTooltips = true
        _G.Questie.db.profile.enableTooltipsObjectID = false
        _G.Questie.db.profile.debugEnabled = false
        _G.LibQuestieDB = {Object = {IdsByName = spy.new(function() return nil end)}}

        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")

        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieTooltips.objectIdsByName = {}
        QuestieTooltips.GetTooltip = spy.new(function() end)

        dofile("Modules/Tooltips/TooltipHandler.lua")
        _QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips").private
        _MockGameTooltip()
    end)

    after_each(function()
        _G.LibQuestieDB = nil
    end)

    describe("AddObjectDataToTooltip", function()
        describe("quest lines from registered Objects", function()
            it("should show a quest title with objectives for one registered Object", function()
                QuestieTooltips.objectIdsByName[OBJECT_NAME] = {[1] = true}
                QuestieTooltips.GetTooltip = spy.new(function()
                    return {"Quest Name", "0/1 Test Objective", "0/1 Other Objective"}
                end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddLine).was.called(3)
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Test Objective")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Other Objective")
                assert.spy(GameTooltip.Show).was.called()
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1", PLAYER_ZONE)
            end)

            it("should deduplicate lines across Objects sharing the hovered name", function()
                QuestieTooltips.objectIdsByName[OBJECT_NAME] = {[1] = true, [2] = true}
                QuestieTooltips.GetTooltip = spy.new(function(key)
                    if key == "o_1" then
                        return {"Quest Name"}
                    elseif key == "o_2" then
                        return {"Quest Name", "Quest Name 2"}
                    end
                end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddLine).was.called(2)
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name 2")
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1", PLAYER_ZONE)
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_2", PLAYER_ZONE)
            end)

            it("should stop after ten registered Objects with tooltip data", function()
                local registered = {}
                for objectId = 1, 11 do
                    registered[objectId] = true
                end
                QuestieTooltips.objectIdsByName[OBJECT_NAME] = registered
                QuestieTooltips.GetTooltip = spy.new(function() return {"Quest Name"} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                -- The set iterates with pairs, so which ten IDs are visited is undefined; only the cap is.
                assert.spy(QuestieTooltips.GetTooltip).was.called(10)
            end)

            it("should add nothing for a name without registered Objects", function()
                _QuestieTooltips.AddObjectDataToTooltip("Unknown Object", PLAYER_ZONE)

                assert.spy(QuestieTooltips.GetTooltip).was.not_called()
                assert.spy(GameTooltip.AddLine).was.not_called()
                assert.spy(GameTooltip.Show).was.called()
            end)
        end)

        describe("Object ID line from the provider name index", function()
            before_each(function()
                _G.Questie.db.profile.enableTooltipsObjectID = true
            end)

            it("should show a single Object ID", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(LibQuestieDB.Object.IdsByName).was.called_with(OBJECT_NAME)
                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1|r")
            end)

            it("should show the first ID with the count for several Objects", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (2)|r")
            end)

            it("should cap the count at 10+ outside debug mode", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (10+)|r")
            end)

            it("should show the full count above ten in debug mode", function()
                _G.Questie.db.profile.debugEnabled = true
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (11)|r")
            end)

            it("should add no Object ID line when the provider knows no Object with that name", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return nil end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.not_called()
            end)

            it("should derive the Object ID line from the provider, not from the registration set", function()
                QuestieTooltips.objectIdsByName[OBJECT_NAME] = {[1] = true, [2] = true, [3] = true}
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1|r")
            end)
        end)

        it("should not query the provider name index while the Object ID setting is disabled", function()
            QuestieTooltips.objectIdsByName[OBJECT_NAME] = {[1] = true}

            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

            assert.spy(LibQuestieDB.Object.IdsByName).was.not_called()
            assert.spy(GameTooltip.AddDoubleLine).was.not_called()
        end)
    end)
end)
