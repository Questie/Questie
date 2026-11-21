dofile("setupTests.lua")
local stub = require("luassert.stub")
local match = require("luassert.match")

describe("QuestieMap", function()

    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieFramePool
    local QuestieFramePool

    before_each(function()
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
        QuestieFramePool.UnloadFrame = spy.new(function() end)
        dofile("Modules/Map/QuestieMap.lua")
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.questIdFrames = {}
    end)

    describe("DrawWorldIcon", function()
        local originalCMap
        local warning
        local getUiMapId
        local getParentZoneId
        local isSpawnVisible

        before_each(function()
            originalCMap = _G.C_Map
            _G.C_Map = {GetMapInfo = function() return nil end}
            ---@type ZoneDB
            local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
            ---@type Phasing
            local Phasing = QuestieLoader:ImportModule("Phasing")
            warning = stub(Questie, "Warning")
            getUiMapId = stub(ZoneDB, "GetUiMapIdByAreaId", function() return nil end)
            getParentZoneId = stub(ZoneDB, "GetParentZoneId", function() return nil end)
            isSpawnVisible = stub(Phasing, "IsSpawnVisible", function() return true end)
        end)

        after_each(function()
            _G.C_Map = originalCMap
            warning:revert()
            getUiMapId:revert()
            getParentZoneId:revert()
            isSpawnVisible:revert()
        end)

        it("should warn and skip the icon when no map or parent area exists", function()
            local worldIcon, minimapIcon = QuestieMap:DrawWorldIcon({Name = "Missing location"}, 123, 50, 50)

            assert.is_nil(worldIcon)
            assert.is_nil(minimapIcon)
            assert.spy(Questie.Warning).was.called_with("No UiMapID or fitting parentAreaId for areaId : 123 - Missing location")
        end)
    end)

    describe("ShowObject", function()
        local waypoints = {{{62, 60}, {65, 63}}}
        local getObject
        local getDungeonLocation

        before_each(function()
            dofile("Localization/l10n.lua")
            ---@type QuestieDB
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            ---@type ZoneDB
            local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
            getObject = stub(QuestieDB, "GetObject", function(_, id)
                return {id = id, name = "Mailbox", spawns = {[1519] = {{61, 76}}}, waypoints = {[1519] = waypoints, [12] = waypoints}}
            end)
            getDungeonLocation = stub(ZoneDB, "GetDungeonLocation", function() return nil end)
            QuestieMap.DrawManualIcon = spy.new(function(_, _, zone) return {zone = zone} end)
            QuestieMap.DrawWaypoints = spy.new(function() end)
        end)

        after_each(function()
            getObject:revert()
            getDungeonLocation:revert()
        end)

        it("should draw waypoints on the spawn icon in their zone, and on a new icon at the first waypoint elsewhere", function()
            QuestieMap:ShowObject(5)

            assert.spy(QuestieMap.DrawManualIcon).was.called(2)
            assert.spy(QuestieMap.DrawManualIcon).was.called_with(QuestieMap, match._, 1519, 61, 76, nil)
            assert.spy(QuestieMap.DrawManualIcon).was.called_with(QuestieMap, match._, 12, 62, 60, nil)
            assert.spy(QuestieMap.DrawWaypoints).was.called_with(QuestieMap, {zone = 1519}, "o_5", waypoints, 1519)
            assert.spy(QuestieMap.DrawWaypoints).was.called_with(QuestieMap, {zone = 12}, "o_5", waypoints, 12)
        end)
    end)

    describe("DrawManualIcon", function()
        local originalProfile, originalUtils, originalQueueDraw
        local ZoneDB, getUiMapId
        local mapIcon, minimapIcon
        local isExplored

        local function _CreateIcon()
            return {
                texture = {SetTexture = function() end, SetVertexColor = function() end},
                SetWidth = function() end,
                SetHeight = function() end,
                GetName = function() return "QuestieManualTestIcon" end,
                FakeHide = spy.new(function() end),
            }
        end

        local data = {id = 1, Name = "Innkeeper", GetIconScale = function() return 1 end}

        before_each(function()
            originalProfile = Questie.db.profile
            originalUtils = QuestieMap.utils
            originalQueueDraw = QuestieMap.QueueDraw
            Questie.db.profile = {enabled = true, enableMapIcons = true, enableMiniMapIcons = true, hideUnexploredMapIcons = true}
            isExplored = true
            QuestieMap.utils = {
                IsExplored = spy.new(function() return isExplored end),
                RescaleIcon = function() end,
            }
            QuestieMap.QueueDraw = function() end
            QuestieMap.manualFrames = {}
            ZoneDB = QuestieLoader:ImportModule("ZoneDB")
            getUiMapId = stub(ZoneDB, "GetUiMapIdByAreaId", function() return 1429 end)
            mapIcon = _CreateIcon()
            minimapIcon = _CreateIcon()
            local frames = {mapIcon, minimapIcon}
            QuestieFramePool.GetFrame = function() return table.remove(frames, 1) end
        end)

        after_each(function()
            Questie.db.profile = originalProfile
            QuestieMap.utils = originalUtils
            QuestieMap.QueueDraw = originalQueueDraw
            getUiMapId:revert()
        end)

        it("should hide the map and minimap icon when the area is unexplored", function()
            isExplored = false

            QuestieMap:DrawManualIcon(data, 12, 50, 60, "Inn")

            assert.spy(QuestieMap.utils.IsExplored).was.called_with(1429, 50, 60)
            assert.spy(mapIcon.FakeHide).was.called(1)
            assert.spy(minimapIcon.FakeHide).was.called(1)
        end)

        it("should show the icons when the area is explored", function()
            QuestieMap:DrawManualIcon(data, 12, 50, 60, "Inn")

            assert.spy(mapIcon.FakeHide).was.not_called()
            assert.spy(minimapIcon.FakeHide).was.not_called()
        end)

        it("should show the icons in an unexplored area when the option is off", function()
            isExplored = false
            Questie.db.profile.hideUnexploredMapIcons = false

            QuestieMap:DrawManualIcon(data, 12, 50, 60, "Inn")

            assert.spy(mapIcon.FakeHide).was.not_called()
            assert.spy(minimapIcon.FakeHide).was.not_called()
        end)

        it("should show icons the user explicitly shows from search in an unexplored area", function()
            isExplored = false

            QuestieMap:DrawManualIcon(data, 12, 50, 60)

            assert.spy(mapIcon.FakeHide).was.not_called()
            assert.spy(minimapIcon.FakeHide).was.not_called()
        end)

        it("should show the icons in a major city even though it counts as unexplored", function()
            -- IsExplored itself answers true for the major cities, regardless of the exploration data
            local realUtils = {}
            local originalMap = _G.C_MapExplorationInfo
            _G.C_MapExplorationInfo = {GetExploredAreaIDsAtPosition = function() return nil end}
            _G.CreateVector2D = _G.CreateVector2D or function(x, y) return {x = x, y = y} end
            getUiMapId:revert()
            getUiMapId = stub(ZoneDB, "GetUiMapIdByAreaId", function() return 1453 end)
            QuestieMap.utils = realUtils
            realUtils.RescaleIcon = function() end
            dofile("Modules/Map/QuestieMapUtils.lua")
            QuestieMap.utils.RescaleIcon = function() end

            QuestieMap:DrawManualIcon(data, 1519, 50, 60, "Inn")
            _G.C_MapExplorationInfo = originalMap

            assert.spy(mapIcon.FakeHide).was.not_called()
            assert.spy(minimapIcon.FakeHide).was.not_called()
        end)
    end)

    describe("UnloadQuestFrames", function()
        local QuestiePartyObjectives, originalScheduleUpdate

        before_each(function()
            QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
            originalScheduleUpdate = QuestiePartyObjectives.ScheduleUpdate
            QuestiePartyObjectives.ScheduleUpdate = spy.new(function() end)
        end)

        after_each(function()
            QuestiePartyObjectives.ScheduleUpdate = originalScheduleUpdate
        end)

        it("should clear AlreadySpawned for objective frames on full unload", function()
            local objective = {AlreadySpawned = {[123] = {}}}
            _G.QuestieFrame1 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame2 = {data = {ObjectiveData = objective}}
            QuestieMap.questIdFrames[1] = {
                QuestieFrame1 = "QuestieFrame1",
                QuestieFrame2 = "QuestieFrame2",
            }

            local thread = coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end)
            coroutine.resume(thread)

            assert.are_same({}, objective.AlreadySpawned)
            assert.is_nil(QuestieMap.questIdFrames[1])
            assert.spy(QuestieFramePool.UnloadFrame).was.called_with(QuestieFramePool, _G.QuestieFrame1)
            assert.spy(QuestieFramePool.UnloadFrame).was.called_with(QuestieFramePool, _G.QuestieFrame2)

            _G.QuestieFrame1 = nil
            _G.QuestieFrame2 = nil
        end)

        it("should keep the registrations of frames drawn while it yields, and drop the stale ones", function()
            local processed = {}
            QuestieFramePool.UnloadFrame = function(_, frame) processed[#processed + 1] = frame.name end
            QuestieMap.questIdFrames[1] = {QuestieStale = "QuestieStale"}
            for i = 1, 31 do
                local name = "QuestieFrame" .. i
                _G[name] = {name = name, data = {}}
                QuestieMap.questIdFrames[1][name] = name
            end

            local thread = coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end)
            coroutine.resume(thread)
            assert.are.equal("suspended", coroutine.status(thread))
            -- It yielded after 30 frames. A frame it unloaded is drawn again, and so is a new one.
            QuestieMap.questIdFrames[1][processed[1]] = processed[1]
            QuestieMap.questIdFrames[1].QuestieNew = "QuestieNew"
            coroutine.resume(thread)

            assert.are.equal(31, #processed)
            local registered = {}
            for name in pairs(QuestieMap.questIdFrames[1] or {}) do
                registered[#registered + 1] = name
            end
            table.sort(registered)
            local expected = {processed[1], "QuestieNew"}
            table.sort(expected)
            assert.are_same(expected, registered)

            for i = 1, 31 do
                _G["QuestieFrame" .. i] = nil
            end
        end)

        it("should finish when all registrations were cleared while it yields", function()
            QuestieFramePool.UnloadFrame = function() end
            QuestieMap.questIdFrames[1] = {}
            for i = 1, 31 do
                local name = "QuestieFrame" .. i
                _G[name] = {name = name, data = {}}
                QuestieMap.questIdFrames[1][name] = name
            end

            local thread = coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end)
            coroutine.resume(thread)
            assert.are.equal("suspended", coroutine.status(thread))
            QuestieMap.questIdFrames = {}
            local finished, err = coroutine.resume(thread)

            assert.is_true(finished, err)
            assert.are.equal("dead", coroutine.status(thread))
            assert.is_nil(QuestieMap.questIdFrames[1])

            for i = 1, 31 do
                _G["QuestieFrame" .. i] = nil
            end
        end)

        it("should schedule a party objectives update once all frames of the quest are unloaded", function()
            local unloadedWhenScheduled
            QuestiePartyObjectives.ScheduleUpdate = spy.new(function() unloadedWhenScheduled = QuestieMap.questIdFrames[1] == nil end)
            QuestieMap.questIdFrames[1] = {QuestieFrame1 = "QuestieFrame1"}

            coroutine.resume(coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end))

            -- The party icons of the quest went with it, and are drawn again afterwards
            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.called_with(QuestiePartyObjectives, 1)
            assert.is_true(unloadedWhenScheduled)
        end)

        it("should not schedule a party objectives update when only the frames of one icon type are unloaded", function()
            QuestieMap.questIdFrames[1] = {}

            coroutine.resume(coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1, "available")
            end))

            assert.spy(QuestiePartyObjectives.ScheduleUpdate).was.not_called()
        end)

        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames[1] = {QuestieFrame1 = "QuestieFrame1"}

            local co = coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieMap:UnloadQuestFrames(1)
            end, "UnloadQuestFrames must be called from a coroutine")
        end)
    end)

end)
