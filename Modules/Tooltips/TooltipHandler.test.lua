dofile("setupTests.lua")

describe("TooltipHandler", function()
    ---@type l10n
    local l10n
    ---@type QuestieTooltips
    local QuestieTooltips
    local _QuestieTooltips

    local PLAYER_ZONE = 440

    before_each(function()
        _G.Questie.db.profile.enableTooltips = true

        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")

        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")

        dofile("Modules/Tooltips/TooltipHandler.lua")
        _QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips").private
    end)

    describe("AddItemDataToTooltip", function()
        local originalTooltip
        local originalGetTooltip
        local originalQueryItem
        local originalItemIDSetting
        local QuestieDB

        before_each(function()
            originalTooltip = _G.GameTooltip
            originalGetTooltip = QuestieTooltips.GetTooltip
            originalItemIDSetting = Questie.db.profile.enableTooltipsItemID
            Questie.db.profile.enableTooltipsItemID = false
            QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            originalQueryItem = QuestieDB.QueryItemSingle
            QuestieDB.QueryItemSingle = function() return nil end
            QuestieTooltips.GetTooltip = spy.new(function() return {"Wolves Across the Border", "0/8 Tough Wolf Meat"} end)
        end)

        after_each(function()
            _G.GameTooltip = originalTooltip
            QuestieTooltips.GetTooltip = originalGetTooltip
            QuestieDB.QueryItemSingle = originalQueryItem
            Questie.db.profile.enableTooltipsItemID = originalItemIDSetting
        end)

        local links = {
            {name = "Classic hex-colored links", link = "|cffffffff|Hitem:750::::::::1:::::::::|h[Tough Wolf Meat]|h|r"},
            {name = "Forever named-color links", link = "|cnIQ1:|Hitem:750::::::::1:1488:::::::::|h[Tough Wolf Meat]|h|r"},
        }
        for _, case in ipairs(links) do
            it("adds objective text to " .. case.name, function()
                _G.GameTooltip = {
                    GetItem = function() return "Tough Wolf Meat", case.link end,
                    GetName = function() return "GameTooltip" end,
                    NumLines = function() return 0 end,
                    AddLine = spy.new(function() end),
                }

                _QuestieTooltips.AddItemDataToTooltip(GameTooltip)

                assert.spy(QuestieTooltips.GetTooltip).was.called_with("i_750")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/8 Tough Wolf Meat")
            end)
        end
    end)

    describe("AddObjectDataToTooltip", function()
        it("should show a quest title with objective", function()
            local name = "test"
            local objectId = 1
            l10n.objectNameLookup[name] = {objectId}

            QuestieTooltips.GetTooltip = spy.new(function()
                return {"Quest Name", "0/1 Test Objective", "0/1 Other Objective"}
            end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddLine).was.called(3)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Test Objective")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Other Objective")
            assert.spy(GameTooltip.Show).was.called()
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_" .. objectId, 0) -- unique name, no zone filter
        end)

        it("should add list of quest names", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2}

            QuestieTooltips.GetTooltip = spy.new(function(id)
                if id == "o_1" then
                    return {"Quest Name"}
                elseif id == "o_2" then
                    return {"Quest Name", "Quest Name 2"}
                end
            end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddLine).was.called(2)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name 2")
            assert.spy(GameTooltip.Show).was.called()
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1", PLAYER_ZONE)
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_2", PLAYER_ZONE)
        end)

        it("should add object IDs", function()
            local name = "test"
            local objectId = 1
            l10n.objectNameLookup[name] = {objectId}

            QuestieTooltips.GetTooltip = spy.new(function() end)

            _G.GameTooltip = {
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF" .. objectId .. "|r")
        end)

        it("should add multiple object IDs", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2}

            QuestieTooltips.GetTooltip = spy.new(function() end)

            _G.GameTooltip = {
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (2)|r")
        end)

        it("should stop counting after 10", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

            QuestieTooltips.GetTooltip = spy.new(function() return {""} end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (10+)|r")
            assert.spy(QuestieTooltips.GetTooltip).was.called(10, PLAYER_ZONE)
            assert.spy(QuestieTooltips.GetTooltip).was.not_called_with("o_11", PLAYER_ZONE)
        end)
    end)
end)
