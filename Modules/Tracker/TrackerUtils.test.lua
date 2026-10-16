dofile("setupTests.lua")
dofile("Modules/Quest/ActiveQuests.lua")
---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
local stub = require("luassert.stub")

local _GetMockedLine

describe("TrackerUtils", function()
    ---@type ZoneIDs
    local ZoneIDs
    ---@type QuestieLib
    local QuestieLib
    ---@type TrackerLinePool
    local TrackerLinePool
    ---@type TrackerUtils
    local TrackerUtils
    ---@type Expansions
    local Expansions
    ---@type QuestieTracker
    local QuestieTracker

    local TrackerData, trackerQuests
    local originalSpecialItemInfo
    local originalGlobals, originalExpansion, originalIsCata, originalIsWotlk
    local globalNames = {"C_Map", "GetNumQuestWatches", "GetQuestLogIndexByID",
        "IsQuestWatched", "GetQuestLogCompletionText"}
    local rePositionLineMock
    local match = require("luassert.match")
    local _ = match._ -- any match

    local getItemSpellMock, isEquippableItemMock, isAddOnLoadedMock
    local getItemCountMock

    before_each(function()
        originalGlobals = {}
        for _, name in ipairs(globalNames) do originalGlobals[name] = _G[name] end
        originalExpansion = QuestieLoader:ImportModule("Expansions").Current
        originalIsCata, originalIsWotlk = Questie.IsCata, Questie.IsWotlk
        Questie.db.profile = {
            trackerShowCompleteQuests = true
        }
        Questie.db.char = {
            collapsedQuests = {},
            collapsedZones = {},
        }
        CreateFrame.resetMockedFrames()
        local compat = QuestieLoader:ImportModule("QuestieCompat")
        getItemSpellMock = stub(compat, "GetItemSpell")
        isEquippableItemMock = stub(compat, "IsEquippableItem", function() return false end)
        isAddOnLoadedMock = stub(compat, "IsAddOnLoaded", function() return false end)
        getItemCountMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetItemCount", function() return 0 end)

        Expansions = QuestieLoader:ImportModule("Expansions")
        ZoneIDs = QuestieLoader:ImportModule("ZoneDB").zoneIDs
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        ActiveQuests.Reset()
        local Polygon = QuestieLoader:ImportModule("QuestiePolygon")
        Polygon.GetObjectiveMarkers = function() return {} end
        Polygon.ScheduleRefresh = function() end
        QuestieLoader:ImportModule("QuestieWaypoints").SetSolo = function() end
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.GetNumTrackedQuests = function() return 0 end
        QuestieTracker.IsTrackedByQuestie = function() return false end
        QuestieLoader:ImportModule("TrackerLayout").GetMargins = function() return {quest = 43, itemButtonLeft = 17} end
        trackerQuests = {}
        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.Refresh = spy.new(function() return trackerQuests end)
        TrackerData.GetQuests = function() return trackerQuests end
        TrackerData.GetQuest = function(id) return trackerQuests[id] end
        TrackerData.RefreshQuest = spy.new(function(id) return trackerQuests[id] end)
        QuestieLoader:ImportModule("TrackerRecipes").HasShownRecipes = function() return false end
        dofile("Modules/Tracker/TrackerMapEligibility.lua")
        originalSpecialItemInfo = _G.GetQuestLogSpecialItemInfo
        _G.GetQuestLogSpecialItemInfo = nil
        TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
        QuestieLoader:ImportModule("TrackerItemButton")

        dofile("Modules/Tracker/TrackerUtils.lua")
        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")

        rePositionLineMock = spy.new(function() end)
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do _G[name] = originalGlobals[name] end
        Expansions.Current = originalExpansion
        Questie.IsCata, Questie.IsWotlk = originalIsCata, originalIsWotlk
        _G.GetQuestLogSpecialItemInfo = originalSpecialItemInfo
        getItemCountMock:revert()
        getItemSpellMock:revert()
        isEquippableItemMock:revert()
        isAddOnLoadedMock:revert()
    end)

    describe("FlashFinisher", function()
        local originalCTimer, tickers, icon, QuestieMap, originalQuestIdFrames, originalManualFrames, QuestieWaypoints, originalSetSolo

        before_each(function()
            originalCTimer = _G.C_Timer
            QuestieMap = QuestieLoader:ImportModule("QuestieMap")
            originalQuestIdFrames = QuestieMap.questIdFrames
            originalManualFrames = QuestieMap.manualFrames
            QuestieMap.manualFrames = {}
            QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
            originalSetSolo = QuestieWaypoints.SetSolo
            tickers = {}
            _G.C_Timer = {
                NewTicker = function(interval, callback)
                    local ticker = {Cancel = spy.new(function() end), callback = callback, interval = interval}
                    table.insert(tickers, ticker)
                    return ticker
                end,
                After = function() end,
            }
            QuestieLoader:ImportModule("QuestieWaypoints").SetSolo = spy.new(function() end)
            icon = CreateFrame("Button")
            icon:SetWidth(16)
            icon:SetHeight(16)
            _G.QuestieFlashTestIcon = icon
            QuestieLoader:ImportModule("QuestieMap").questIdFrames = {[54] = {"QuestieFlashTestIcon"}}
        end)

        after_each(function()
            _G.C_Timer = originalCTimer
            _G.QuestieFlashTestIcon = nil
            QuestieMap.questIdFrames = originalQuestIdFrames
            QuestieMap.manualFrames = originalManualFrames
            QuestieWaypoints.SetSolo = originalSetSolo
        end)

        it("should hide townsfolk icons only while the flash runs", function()
            local townsfolkIcon = CreateFrame("Button")
            townsfolkIcon:Show()
            townsfolkIcon.IsShown = function(self) return self:IsVisible() end
            _G.QuestieFlashTestTownsfolk = townsfolkIcon
            QuestieMap.manualFrames = {Vendor = {[1] = {"QuestieFlashTestTownsfolk"}}}

            TrackerUtils:FlashFinisher({Id = 54})
            local hiddenDuringFlash = not townsfolkIcon:IsVisible()
            local afters = {}
            _G.C_Timer.After = function(_, callback) table.insert(afters, callback) end
            for _ = 1, 50 do
                if #afters > 0 then
                    break
                end
                tickers[1].callback()
            end
            for _, callback in ipairs(afters) do
                callback()
            end
            _G.QuestieFlashTestTownsfolk = nil

            assert.is_true(hiddenDuringFlash)
            assert.is_true(townsfolkIcon:IsVisible())
        end)

        it("should animate the flash in steps of 0.065 seconds", function()
            TrackerUtils:FlashFinisher({Id = 54})

            assert.are_same(0.065, tickers[1].interval)
        end)

        it("should stop a running flash and restore icon sizes before flashing again", function()
            TrackerUtils:FlashFinisher({Id = 54})
            tickers[1].callback()

            TrackerUtils:FlashFinisher({Id = 54})

            assert.spy(tickers[1].Cancel).was.called()
            assert.are_same(16, icon._size)
        end)
    end)

    describe("show on map", function()
        local openMock, nearestObjectiveMock, nearestFinisherMock, uiMapIdMock, originalWorldMapFrame, nearestSpawnMock

        before_each(function()
            local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
            openMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "OpenWorldMap", function() return true end)
            nearestObjectiveMock = stub(DistanceUtils, "GetNearestObjective", function() return {50, 50}, 12 end)
            nearestFinisherMock = stub(DistanceUtils, "GetNearestFinisherOrStarter", function() return {50, 50}, 12 end)
            uiMapIdMock = stub(QuestieLoader:ImportModule("ZoneDB"), "GetUiMapIdByAreaId", function() return 1429 end)
            originalWorldMapFrame = _G.WorldMapFrame
            _G.WorldMapFrame = {Show = spy.new(function() end), SetMapID = spy.new(function() end)}
            TrackerUtils.FlashObjective = function() end
            TrackerUtils.FlashFinisher = function() end
        end)

        after_each(function()
            openMock:revert()
            nearestObjectiveMock:revert()
            nearestFinisherMock:revert()
            uiMapIdMock:revert()
            if nearestSpawnMock then
                nearestSpawnMock:revert()
                nearestSpawnMock = nil
            end
            _G.WorldMapFrame = originalWorldMapFrame
        end)

        it("should let the client open the map for an objective", function()
            TrackerUtils:ShowObjectiveOnMap({spawnList = {}})

            assert.stub(openMock).was.called_with(1429)
            assert.spy(WorldMapFrame.Show).was_not.called()
            assert.spy(WorldMapFrame.SetMapID).was_not.called()
        end)

        it("should let the client open the map for a finisher", function()
            TrackerUtils:ShowFinisherOnMap({Finisher = {}})

            assert.stub(openMock).was.called_with(1429)
            assert.spy(WorldMapFrame.Show).was_not.called()
            assert.spy(WorldMapFrame.SetMapID).was_not.called()
        end)

        it("should open the map on the zone of the nearest quest spawn and flash the quest", function()
            local original = {Id = 100}
            local quest = {
                Id = 100, enrichment = original, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            trackerQuests[100] = quest
            nearestSpawnMock = stub(QuestieLoader:ImportModule("DistanceUtils"), "GetNearestSpawnForQuest", function() return {50, 60}, 40 end)
            TrackerUtils.FlashFinisher = spy.new(function() end)

            assert.is_true(TrackerUtils.ShowQuestOnMap(100, original))

            assert.stub(nearestSpawnMock).was.called_with(quest)
            assert.stub(uiMapIdMock).was.called_with(match.is_ref(QuestieLoader:ImportModule("ZoneDB")), 40)
            assert.stub(openMock).was.called_with(1429)
            assert.spy(TrackerUtils.FlashFinisher).was.called_with(TrackerUtils, original)
        end)

        it("should not flash the quest when the client blocks opening the map", function()
            local original = {Id = 100}
            trackerQuests[100] = {
                Id = 100, enrichment = original, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            nearestSpawnMock = stub(QuestieLoader:ImportModule("DistanceUtils"), "GetNearestSpawnForQuest", function() return {50, 60}, 40 end)
            openMock.invokes(function() return false end)
            TrackerUtils.FlashFinisher = spy.new(function() end)

            assert.is_false(TrackerUtils.ShowQuestOnMap(100, original))

            assert.spy(TrackerUtils.FlashFinisher).was.not_called()
        end)

        it("should not flash an objective, quest objectives or a finisher when the client blocks opening the map", function()
            openMock.invokes(function() return false end)
            TrackerUtils.FlashObjective = spy.new(function() end)
            TrackerUtils.FlashObjectives = spy.new(function() end)
            TrackerUtils.FlashFinisher = spy.new(function() end)

            TrackerUtils:ShowObjectiveOnMap({spawnList = {}})
            TrackerUtils:ShowQuestObjectivesOnMap({{spawnList = {}}})
            TrackerUtils:ShowFinisherOnMap({Finisher = {}})

            assert.spy(TrackerUtils.FlashObjective).was.not_called()
            assert.spy(TrackerUtils.FlashObjectives).was.not_called()
            assert.spy(TrackerUtils.FlashFinisher).was.not_called()
        end)

        it("should not open the map for a quest without spawns", function()
            local original = {Id = 100}
            trackerQuests[100] = {
                Id = 100, enrichment = original, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            nearestSpawnMock = stub(QuestieLoader:ImportModule("DistanceUtils"), "GetNearestSpawnForQuest", function() end)
            TrackerUtils.FlashFinisher = spy.new(function() end)

            assert.is_false(TrackerUtils.ShowQuestOnMap(100, original))

            assert.stub(openMock).was.not_called()
            assert.spy(TrackerUtils.FlashFinisher).was.not_called()
        end)

        it("should not open the map for a quest that can not be navigated", function()
            trackerQuests[91741] = {Id = 91741, Objectives = {}, SpecialObjectives = {}}
            TrackerUtils.FlashFinisher = spy.new(function() end)

            assert.is_false(TrackerUtils.ShowQuestOnMap(91741))

            assert.stub(openMock).was.not_called()
            assert.spy(TrackerUtils.FlashFinisher).was.not_called()
        end)

        describe("all quest objectives", function()
            local flashed, originalFlashObjectives

            before_each(function()
                originalFlashObjectives = TrackerUtils.FlashObjectives
                -- Each fake spawn list names its own zone and distance.
                QuestieLoader:ImportModule("DistanceUtils").GetNearestObjective = function(spawnList)
                    return spawnList.spawn, spawnList.zone, "Name", spawnList.distance
                end
                QuestieLoader:ImportModule("ZoneDB").GetUiMapIdByAreaId = function(_, zone) return zone + 1000 end
                flashed = nil
                TrackerUtils.FlashObjectives = function(_, objectives) flashed = objectives end
            end)

            after_each(function()
                TrackerUtils.FlashObjectives = originalFlashObjectives
            end)

            it("should open the map at the nearest objective and flash every objective", function()
                local far = {spawnList = {spawn = {2, 2}, zone = 2, distance = 50}}
                local near = {spawnList = {spawn = {3, 3}, zone = 3, distance = 20}}
                local objectives = {far, near}

                TrackerUtils:ShowQuestObjectivesOnMap(objectives)

                assert.stub(openMock).was.called_with(1003)
                assert.are.equal(objectives, flashed)
            end)

            it("does nothing when no objective has a spawn", function()
                TrackerUtils:ShowQuestObjectivesOnMap({{spawnList = {}}})

                assert.stub(openMock).was_not.called()
                assert.is_nil(flashed)
            end)
        end)
    end)

    describe("FlashObjectives", function()
        local originalTimer, originalQuestIdFrames, originalSetSolo, tick, solo

        local function _Frame(width)
            return {
                GetWidth = function() return width end,
                IsShown = function() return true end,
                SetWidth = spy.new(function() end),
                SetHeight = spy.new(function() end),
                Show = spy.new(function() end),
                Hide = spy.new(function() end),
                data = {},
            }
        end

        before_each(function()
            originalTimer = _G.C_Timer
            tick = nil
            _G.C_Timer = {
                NewTicker = function(_, fn) tick = fn return {Cancel = function() end} end,
                After = function() end,
            }
            local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
            originalQuestIdFrames = QuestieMap.questIdFrames
            QuestieMap.questIdFrames = {[200] = {"QuestieTestOtherIcon"}}
            _G.QuestieTestOtherIcon = _Frame(16)
            local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
            originalSetSolo = QuestieWaypoints.SetSolo
            QuestieWaypoints.SetSolo = function(data) solo = data end
            solo = nil
        end)

        after_each(function()
            _G.C_Timer = originalTimer
            QuestieLoader:ImportModule("QuestieMap").questIdFrames = originalQuestIdFrames
            QuestieLoader:ImportModule("QuestieWaypoints").SetSolo = originalSetSolo
            _G.QuestieTestOtherIcon = nil
        end)

        it("pulses the icons of every objective together and hides other icons", function()
            local wolfIcon, bearIcon = _Frame(16), _Frame(12)
            local wolves = {AlreadySpawned = {{mapRefs = {wolfIcon}}}}
            local bears = {AlreadySpawned = {{mapRefs = {bearIcon}}}}

            TrackerUtils:FlashObjectives({wolves, bears})
            tick()

            assert.spy(_G.QuestieTestOtherIcon.Hide).was.called()
            assert.spy(wolfIcon.SetWidth).was.called_with(wolfIcon, 17)
            assert.spy(bearIcon.SetWidth).was.called_with(bearIcon, 13)
            assert.is_true(solo[wolfIcon.data])
            assert.is_true(solo[bearIcon.data])
        end)

        it("still flashes a single objective", function()
            local icon = _Frame(16)

            TrackerUtils:FlashObjective({AlreadySpawned = {{mapRefs = {icon}}}})
            tick()

            assert.spy(icon.SetWidth).was.called_with(icon, 17)
        end)

        it("does nothing when no objective has spawned icons", function()
            TrackerUtils:FlashObjectives({{AlreadySpawned = {}}, {}})

            assert.is_nil(tick)
            assert.spy(_G.QuestieTestOtherIcon.Hide).was_not.called()
        end)
    end)

    describe("ShowQuestLog", function()
        local originals, legacyFrame, scrollBar
        local getIndexMock, selectMock, detailsMock, updateMock, printMock
        local originalIsForever
        local globalNames = {
            "QuestLogFrame", "QuestLogExFrame", "ClassicQuestLog", "QuestLogEx", "QuestLogListScrollFrame",
            "QuestLogListScrollFrameScrollBar", "QuestMapFrame_OpenToQuestDetails", "ShowUIPanel", "InCombatLockdown",
            "InputUtil",
        }

        before_each(function()
            originals = {}
            for _, name in ipairs(globalNames) do
                originals[name] = _G[name]
                _G[name] = nil
            end
            legacyFrame = {IsShown = function() return false end}
            scrollBar = {GetValueStep = function() return 10 end, SetValue = spy.new(function() end)}
            _G.QuestLogFrame = legacyFrame
            _G.QuestLogListScrollFrame = {ScrollBar = scrollBar}
            _G.QuestMapFrame_OpenToQuestDetails = spy.new(function() end)
            _G.ShowUIPanel = spy.new(function() end)
            _G.InCombatLockdown = function() return false end
            local compat = QuestieLoader:ImportModule("QuestieCompat")
            getIndexMock = stub(compat, "GetQuestLogIndexByID", function() return 5 end)
            selectMock = stub(compat, "SelectQuestLogEntry")
            detailsMock = stub(compat, "QuestLog_UpdateQuestDetails")
            updateMock = stub(compat, "QuestLog_Update")
            printMock = stub(Questie, "Print")
            originalIsForever = Questie.IsForever
            dofile("Localization/l10n.lua")
            dofile("Modules/Tracker/TrackerUtils.lua")
        end)

        after_each(function()
            getIndexMock:revert()
            selectMock:revert()
            detailsMock:revert()
            updateMock:revert()
            printMock:revert()
            Questie.IsForever = originalIsForever
            for _, name in ipairs(globalNames) do _G[name] = originals[name] end
        end)

        it("opens and selects the Classic quest log when the map-details helper also exists", function()
            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(getIndexMock).was.called_with(783)
            assert.spy(selectMock).was.called_with(5)
            assert.spy(scrollBar.SetValue).was.called_with(scrollBar, 20)
            assert.spy(ShowUIPanel).was.called_with(legacyFrame)
            assert.spy(detailsMock).was.called(1)
            assert.spy(updateMock).was.called(1)
            assert.spy(_G.QuestMapFrame_OpenToQuestDetails).was.not_called()
        end)

        it("uses the modern quest ID route when no standalone quest log exists", function()
            _G.QuestLogFrame = nil
            _G.QuestLogListScrollFrame = nil
            dofile("Modules/Tracker/TrackerUtils.lua")

            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(_G.QuestMapFrame_OpenToQuestDetails).was.called_with(783)
            assert.spy(getIndexMock).was.not_called()
            assert.spy(selectMock).was.not_called()
            assert.spy(scrollBar.SetValue).was.not_called()
            assert.spy(ShowUIPanel).was.not_called()
            assert.spy(detailsMock).was.not_called()
            assert.spy(updateMock).was.not_called()
        end)

        it("opens nothing and prints a hint on Forever with the gamepad UI", function()
            Questie.IsForever = true
            _G.InputUtil = {IsGamepadUIEnabled = function() return true end}
            _G.QuestLogFrame = nil
            _G.QuestLogListScrollFrame = nil
            dofile("Modules/Tracker/TrackerUtils.lua")

            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(_G.QuestMapFrame_OpenToQuestDetails).was.not_called()
            assert.spy(ShowUIPanel).was.not_called()
            assert.spy(selectMock).was.not_called()
            assert.spy(printMock).was.called(1)
        end)

        it("still opens the quest log on Forever without the gamepad UI", function()
            Questie.IsForever = true
            _G.InputUtil = {IsGamepadUIEnabled = function() return false end}
            _G.QuestLogFrame = nil
            _G.QuestLogListScrollFrame = nil
            dofile("Modules/Tracker/TrackerUtils.lua")

            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(_G.QuestMapFrame_OpenToQuestDetails).was.called_with(783)
            assert.spy(printMock).was.not_called()
        end)

        it("ignores the gamepad UI on other flavors", function()
            Questie.IsForever = false
            _G.InputUtil = {IsGamepadUIEnabled = function() return true end}

            TrackerUtils:ShowQuestLog({Id = 783})

            assert.spy(ShowUIPanel).was.called_with(legacyFrame)
            assert.spy(printMock).was.not_called()
        end)
    end)

    describe("polygon objective map highlighting", function()
        local Polygon, objective, marker, unrelated, originalGlobals, flashTick, quest
        local QuestieMap, FramePool, QuestieCompat, originalDraw, originalUnload, originalOpenWorldMap
        local originalRendererNew, originalCacheNew

        before_each(function()
            QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
            originalOpenWorldMap = QuestieCompat.OpenWorldMap
            QuestieCompat.OpenWorldMap = spy.new(function() return true end)
            originalGlobals = {LibStub = _G.LibStub, WorldMapFrame = _G.WorldMapFrame, C_Timer = _G.C_Timer,
                CreateFromMixins = _G.CreateFromMixins, MapCanvasDataProviderMixin = _G.MapCanvasDataProviderMixin,
                PolygonTrackerMarker = _G.PolygonTrackerMarker, PolygonTrackerOther = _G.PolygonTrackerOther}
            _G.LibStub = function()
                return {GetWorldCoordinatesFromZone = function(_, x, y) return x * 1000, y * 1000, 1 end}
            end
            _G.MapCanvasDataProviderMixin = {}
            _G.CreateFromMixins = function(base, methods)
                local result = {}
                for key, value in pairs(base) do result[key] = value end
                for key, value in pairs(methods) do result[key] = value end
                return result
            end
            _G.C_Timer = {After = function() end, NewTicker = function(_, callback)
                flashTick = callback
                return {Cancel = function() end}
            end}
            _G.WorldMapFrame = {GetCanvas = function() return {} end, IsShown = function() return false end,
                AddDataProvider = function(self, provider) provider:OnAdded(self) end,
                RemoveDataProvider = function(_, provider) provider:OnRemoved() end,
                Show = spy.new(function() end), SetMapID = spy.new(function() end)}
            local Renderer = QuestieLoader:ImportModule("PolygonRenderer")
            local RenderCache = QuestieLoader:ImportModule("PolygonRenderCache")
            originalRendererNew, originalCacheNew = Renderer.New, RenderCache.New
            local renderer = {}
            Renderer.New = function() return renderer end
            -- Tracker highlighting borrows marker frames, not rendered polygon views.
            RenderCache.New = function(renderDependency)
                assert.are.equal(renderer, renderDependency)
                return {Present = function() return true end, Hide = function() end,
                    Clear = function() end, Release = function() end}
            end
            QuestieLoader:ImportModule("PolygonNudging").New = function()
                return {Update = function() end, Remove = function() end, Clear = function() end,
                    SetEnabled = function() end, Reapply = function() end}
            end
            QuestieLoader:ImportModule("PolygonMinimap").New = function()
                return {Invalidate = function() end, Clear = function() end}
            end
            local WorldMapLayers = QuestieLoader:ImportModule("WorldMapLayers")
            WorldMapLayers.AddLayer, WorldMapLayers.Invalidate = function() end, function() end
            WorldMapLayers.FrameLevel = function() return 10 end
            QuestieLoader:ImportModule("QuestieFrame").Subscribe = function() end
            dofile("Polygon/PolygonGeometry.lua")
            QuestieLoader:ImportModule("PolygonGeometry").Build = function(points)
                return {{uiMapId = 10, x = 10, y = 20, representative = points[1]}}
            end
            Questie.db.profile.enableQuestiePolygons = true
            Questie.db.profile.enableObjectives = true
            QuestieLoader:ImportModule("ZoneDB").GetUiMapIdByAreaId = function() return 10 end
            QuestieLoader:ImportModule("Phasing").IsSpawnVisible = function() return true end
            QuestieLoader:ImportModule("DistanceUtils").GetNearestObjective = function() return {10, 20}, 1 end
            objective = {Index = 1, questId = 42, Type = "monster", AlreadySpawned = {[123] = {mapRefs = {}, minimapRefs = {{}}}},
                spawnList = {[123] = {Id = 123, Name = "Wolf", Icon = 1, GetIconScale = function() return 1 end,
                    Spawns = {[1] = {{10, 20}}}}}}
            quest = {Id = 42, Color = {1, 1, 1}}
            ActiveQuests.Add(42, quest)
            QuestieMap = QuestieLoader:ImportModule("QuestieMap")
            originalDraw = QuestieMap.DrawWorldIcon
            QuestieMap.DrawWorldIcon = function(_, data, _areaId, _x, _y, _phase, _showFlag, destination)
                -- Tracker highlighting uses world-map markers only.
                if destination == "minimap" then return nil, nil end
                marker = CreateFrame("Button", "PolygonTrackerMarker")
                marker:SetSize(12, 12)
                marker.IsShown = marker.IsVisible
                marker.data = data
                marker.texture = {a = 1}
                _G.PolygonTrackerMarker = marker
                return marker
            end
            FramePool = QuestieLoader:ImportModule("QuestieFramePool")
            originalUnload = FramePool.UnloadFrame
            FramePool.UnloadFrame = function(_, frame) frame.data = nil; frame:Hide() end
            unrelated = CreateFrame("Button", "PolygonTrackerOther")
            unrelated:SetSize(12, 12)
            unrelated.IsShown = unrelated.IsVisible
            unrelated.data = {}
            _G.PolygonTrackerOther = unrelated
            QuestieMap.questIdFrames = {[42] = {"PolygonTrackerMarker"}, [99] = {"PolygonTrackerOther"}}
            dofile("Polygon/QuestiePolygon.lua")
            Polygon = QuestieLoader:ImportModule("QuestiePolygon")
            local thread = coroutine.create(function() Polygon.UpdateObjective(quest, objective, 1) end)
            while coroutine.status(thread) ~= "dead" do
                local ok, err = coroutine.resume(thread)
                assert.is_true(ok, err)
            end
        end)

        after_each(function()
            Polygon.Reset()
            QuestieCompat.OpenWorldMap = originalOpenWorldMap
            QuestieLoader:ImportModule("PolygonRenderer").New = originalRendererNew
            QuestieLoader:ImportModule("PolygonRenderCache").New = originalCacheNew
            QuestieMap.DrawWorldIcon = originalDraw
            FramePool.UnloadFrame = originalUnload
            for name, value in pairs(originalGlobals) do _G[name] = value end
            _G.LibStub, _G.WorldMapFrame, _G.C_Timer = originalGlobals.LibStub, originalGlobals.WorldMapFrame, originalGlobals.C_Timer
            _G.CreateFromMixins = originalGlobals.CreateFromMixins
            _G.MapCanvasDataProviderMixin = originalGlobals.MapCanvasDataProviderMixin
            _G.PolygonTrackerMarker, _G.PolygonTrackerOther = originalGlobals.PolygonTrackerMarker, originalGlobals.PolygonTrackerOther
        end)

        it("restores and flashes the polygon-owned marker for the actual Show on Map action", function()
            TrackerUtils:ShowObjectiveOnMap(objective)
            assert.spy(QuestieCompat.OpenWorldMap).was.called_with(10)
            assert.is_true(marker:IsShown())
            assert.is_false(unrelated:IsShown())
            assert.is_nil(marker._hidden_by_flash)
            assert.are.same({}, objective.AlreadySpawned[123].mapRefs)
            flashTick()
            assert.are.equal(13, marker:GetWidth())
            assert.are.equal(12, unrelated:GetWidth())
        end)

        it("does not animate a removed polygon marker recycled for another objective", function()
            TrackerUtils:ShowObjectiveOnMap(objective)
            Polygon.RemoveQuest(42)
            marker.data = {ObjectiveData = {Index = 2}}
            marker:SetSize(24, 24)
            flashTick()
            assert.are.equal(24, marker:GetWidth())
            assert.are.equal(24, marker:GetHeight())
        end)
    end)

    describe("IsQuestItemUsable", function()
        it("accepts equippable quest items without an associated spell", function()
            isEquippableItemMock.returns(true)

            assert.is_true(TrackerUtils:IsQuestItemUsable(123))
            assert.spy(getItemSpellMock).was.called_with(123)
            assert.spy(isEquippableItemMock).was.called_with(123)
        end)

        it("rejects items without either a spell or an equipment slot", function()
            assert.is_false(TrackerUtils:IsQuestItemUsable(123))
        end)
    end)

    describe("IsVoiceOverLoaded", function()
        it("requires both the addon and its Vanilla data", function()
            local loaded = {AI_VoiceOver = true}
            isAddOnLoadedMock:revert()
            isAddOnLoadedMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "IsAddOnLoaded", function(addon)
                return loaded[addon] == true
            end)
            dofile("Modules/Tracker/TrackerUtils.lua")

            assert.is_false(TrackerUtils:IsVoiceOverLoaded())
            loaded.AI_VoiceOverData_Vanilla = true
            assert.is_true(TrackerUtils:IsVoiceOverLoaded())
            assert.spy(isAddOnLoadedMock).was.called_with("AI_VoiceOver")
            assert.spy(isAddOnLoadedMock).was.called_with("AI_VoiceOverData_Vanilla")
        end)

        it("should be false when Spoken is loaded as well", function()
            local loaded = {AI_VoiceOver = true, AI_VoiceOverData_Vanilla = true, Spoken = true, Spoken_Quests = true}
            isAddOnLoadedMock:revert()
            isAddOnLoadedMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "IsAddOnLoaded", function(addon)
                return loaded[addon] == true
            end)
            dofile("Modules/Tracker/TrackerUtils.lua")

            assert.is_false(TrackerUtils:IsVoiceOverLoaded())
        end)
    end)

    describe("IsSpokenLoaded", function()
        it("should require Spoken and Spoken_Quests", function()
            local loaded = {Spoken = true}
            isAddOnLoadedMock:revert()
            isAddOnLoadedMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "IsAddOnLoaded", function(addon)
                return loaded[addon] == true
            end)
            dofile("Modules/Tracker/TrackerUtils.lua")

            assert.is_false(TrackerUtils:IsSpokenLoaded())
            loaded.Spoken_Quests = true
            assert.is_true(TrackerUtils:IsSpokenLoaded())
        end)
    end)

    describe("GetQuestItemIds", function()
        it("returns owned, usable candidates in button order without touching frames", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.invokes(function(itemId) return itemId == 789 and 0 or 1 end)
            TrackerLinePool.GetNextItemButton = spy.new(function() end)
            local quest = {
                Id = 1,
                sourceItemId = 123,
                requiredSourceItems = {456, 789},
                Objectives = {},
                ObjectiveData = {{Type = "item", Id = 123}},
            }

            local itemIds, nativeItemId = TrackerUtils.GetQuestItemIds(quest, 0)

            assert.are.same({123, 456}, itemIds)
            assert.is_nil(nativeItemId)
            assert.spy(TrackerLinePool.GetNextItemButton).was.not_called()
        end)
    end)

    describe("AddQuestItemButtons", function()
        it("should add sourceItemId as primary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local button = CreateFrame("Button")
            TrackerLinePool.GetNextItemButton = function()
                button.SetItem = spy.new(function()
                    return true
                end)
                button:Hide() -- initially item buttons are hidden
                return button
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(button.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.is_true(button:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should add single requiredSourceItems entry as primary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local button = CreateFrame("Button")
            TrackerLinePool.GetNextItemButton = function()
                button.SetItem = spy.new(function()
                    return true
                end)
                button:Hide() -- initially item buttons are hidden
                return button
            end
            local quest = {
                Id = 1,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(button.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(button:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should add single objective item entry as primary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local button = CreateFrame("Button")
            TrackerLinePool.GetNextItemButton = function()
                button.SetItem = spy.new(function()
                    return true
                end)
                button:Hide() -- initially item buttons are hidden
                return button
            end
            local quest = {
                Id = 1,
                Objectives = {},
                ObjectiveData = {
                    [1] = {
                        Id = 123,
                        Type = "item",
                    },
                },
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(button.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.is_true(button:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should add sourceItemId as primary button and single requiredSourceItems as secondary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
            local buttonIndex = 0

            TrackerLinePool.GetNextItemButton = function()
                if buttonIndex == 0 then
                    primaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    primaryButton:Hide() -- initially item buttons are hidden
                    buttonIndex = buttonIndex + 1
                    return primaryButton
                else
                    secondaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    secondaryButton:Hide() -- initially item buttons are hidden
                    return secondaryButton
                end
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(primaryButton.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.spy(secondaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())
            assert.is_true(secondaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.called()
        end)

        it("should add sourceItemId as primary button and single objective item as secondary button", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
            local buttonIndex = 0

            TrackerLinePool.GetNextItemButton = function()
                if buttonIndex == 0 then
                    primaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    primaryButton:Hide() -- initially item buttons are hidden
                    buttonIndex = buttonIndex + 1
                    return primaryButton
                else
                    secondaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    secondaryButton:Hide() -- initially item buttons are hidden
                    return secondaryButton
                end
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                Objectives = {},
                ObjectiveData = {
                    [1] = {
                        Id = 456,
                        Type = "item",
                    },
                },
            }
            local line = _GetMockedLine()
            primaryButton.SetPoint = spy.new(function() end)
            secondaryButton.SetPoint = spy.new(function() end)

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(primaryButton.SetPoint).was.called_with(_, "TOPLEFT", _, "TOPLEFT", 17, 1)
            assert.spy(secondaryButton.SetPoint).was.called_with(_, "TOPLEFT", _, "TOPLEFT", 43, 1)
            assert.spy(primaryButton.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.spy(secondaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())
            assert.is_true(secondaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.called()
        end)

        it("should add multiple requiredSourceItems entries as primary and secondary buttons", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
            local buttonIndex = 0

            TrackerLinePool.GetNextItemButton = function()
                if buttonIndex == 0 then
                    primaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    primaryButton:Hide() -- initially item buttons are hidden
                    buttonIndex = buttonIndex + 1
                    return primaryButton
                else
                    secondaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    secondaryButton:Hide() -- initially item buttons are hidden
                    return secondaryButton
                end
            end
            local quest = {
                Id = 1,
                requiredSourceItems = {123,456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(primaryButton.SetItem).was.called_with(_, 123, 1, 12, false)
            assert.spy(secondaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())
            assert.is_true(secondaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.called()
        end)

        it("should add second item of requiredSourceItems as primary button if first is not in the inventory", function()
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock:revert()
            getItemCountMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetItemCount", function(itemId)
                return itemId == 456 and 1 or 0
            end)
            dofile("Modules/Tracker/TrackerUtils.lua")
            local primaryButton = CreateFrame("Button")

            TrackerLinePool.GetNextItemButton = function()
                primaryButton.SetItem = spy.new(function()
                    return true
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                return primaryButton
            end
            local quest = {
                Id = 1,
                requiredSourceItems = {123,456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(shouldContinue)
            assert.spy(primaryButton.SetItem).was.called_with(_, 456, 1, 12, false)
            assert.is_true(primaryButton:IsVisible())

            assert.is_false(line.expandQuest:IsVisible())
        end)

        it("should show expandQuest button without quest item", function()
            local quest = {
                Id = 1,
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_true(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should hide expandQuest button for complete quests without quest item and collapseCompletedQuests is true", function()
            Questie.db.profile.collapseCompletedQuests = true
            local quest = {
                Id = 1,
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            TrackerUtils.AddQuestItemButtons(quest, 1, line, 12, {}, true, rePositionLineMock)

            assert.is_false(line.expandQuest:IsVisible())

            assert.spy(rePositionLineMock).was.not_called()
        end)

        it("should show expandQuest button and hide item buttons when quest is collapsed", function()
            Questie.db.char.collapsedQuests[1] = true
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
            local buttonIndex = 0

            TrackerLinePool.GetNextItemButton = function()
                if buttonIndex == 0 then
                    primaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    primaryButton:Hide() -- initially item buttons are hidden
                    buttonIndex = buttonIndex + 1
                    return primaryButton
                else
                    secondaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    secondaryButton:Hide() -- initially item buttons are hidden
                    return secondaryButton
                end
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_false(primaryButton:IsVisible())
            assert.is_false(secondaryButton:IsVisible())
            assert.is_true(line.expandQuest:IsVisible())
        end)

        it("should show expandQuest button when no primary button is added", function()
            Questie.db.char.collapsedQuests[1] = true
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton = CreateFrame("Button")

            TrackerLinePool.GetNextItemButton = function()
                primaryButton.SetItem = spy.new(function()
                    return false
                end)
                primaryButton:Hide() -- initially item buttons are hidden
                return primaryButton
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_false(primaryButton:IsVisible())
            assert.is_true(line.expandQuest:IsVisible())
        end)

        it("should hide expandQuest button and hide item buttons when quest is collapsed and collapseCompletedQuests is true", function()
            Questie.db.char.collapsedQuests[1] = true
            Questie.db.profile.collapseCompletedQuests = true
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
            local buttonIndex = 0

            TrackerLinePool.GetNextItemButton = function()
                if buttonIndex == 0 then
                    primaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    primaryButton:Hide() -- initially item buttons are hidden
                    buttonIndex = buttonIndex + 1
                    return primaryButton
                else
                    secondaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    secondaryButton:Hide() -- initially item buttons are hidden
                    return secondaryButton
                end
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, true, rePositionLineMock)

            assert.is_false(primaryButton:IsVisible())
            assert.is_false(secondaryButton:IsVisible())
            assert.is_false(line.expandQuest:IsVisible())
        end)

        it("should hide item buttons when zone is collapsed", function()
            Questie.db.char.collapsedZones["Durotar"] = true
            getItemSpellMock.returns("Use Quest Item", 111)
            getItemCountMock.returns(1)
            local primaryButton, secondaryButton = CreateFrame("Button"), CreateFrame("Button")
            local buttonIndex = 0

            TrackerLinePool.GetNextItemButton = function()
                if buttonIndex == 0 then
                    primaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    primaryButton:Hide() -- initially item buttons are hidden
                    buttonIndex = buttonIndex + 1
                    return primaryButton
                else
                    secondaryButton.SetItem = spy.new(function()
                        return true
                    end)
                    secondaryButton:Hide() -- initially item buttons are hidden
                    return secondaryButton
                end
            end
            local quest = {
                Id = 1,
                sourceItemId = 123,
                requiredSourceItems = {456},
                Objectives = {},
                ObjectiveData = {},
            }
            local line = _GetMockedLine()

            TrackerUtils.AddQuestItemButtons(quest, 0, line, 12, {}, false, rePositionLineMock)

            assert.is_false(primaryButton:IsVisible())
            assert.is_false(secondaryButton:IsVisible())
            assert.is_false(line.expandQuest:IsVisible())
        end)

        describe("native quest items", function()
            local indexMock, button, quest

            before_each(function()
                indexMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetQuestLogIndexByID", function() return 2 end)
                button = CreateFrame("Button")
                button.SetItem = spy.new(function() return true end)
                TrackerLinePool.GetNextItemButton = spy.new(function() return button end)
                quest = {Id = 91741, Objectives = {}, ObjectiveData = {}}
                _G.GetQuestLogSpecialItemInfo = spy.new(function() return "|Hitem:90001|h[Book]|h", nil, 1, false end)
                getItemCountMock.returns(1)
            end)

            after_each(function()
                indexMock:revert()
            end)

            it("uses Blizzard's quest item without database metadata", function()
                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, false, rePositionLineMock)

                assert.spy(_G.GetQuestLogSpecialItemInfo).was.called_with(2)
                assert.spy(button.SetItem).was.called_with(button, 90001, 91741, 12, true)
                assert.spy(getItemSpellMock).was.not_called()
            end)

            it("falls back to an owned database item when the native item is not in the inventory", function()
                getItemCountMock.invokes(function(itemId) return itemId == 456 and 1 or 0 end)
                getItemSpellMock.returns("Use Item")
                quest.sourceItemId = 456

                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, false, rePositionLineMock)

                assert.spy(button.SetItem).was.called(1)
                assert.spy(button.SetItem).was.called_with(button, 456, 91741, 12, false)
            end)

            it("deduplicates a native item also listed as a source and objective item", function()
                getItemSpellMock.returns("Use Book")
                quest.sourceItemId = 90001
                quest.requiredSourceItems = {90001}
                quest.ObjectiveData = {{Type = "item", Id = 90001}}

                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, false, rePositionLineMock)

                assert.spy(TrackerLinePool.GetNextItemButton).was.called(1)
                assert.spy(button.SetItem).was.called_with(button, 90001, 91741, 12, true)
            end)

            it("keeps a native action explicitly allowed after completion", function()
                _G.GetQuestLogSpecialItemInfo = function() return "|Hitem:90001|h[Book]|h", nil, 1, true end

                TrackerUtils.AddQuestItemButtons(quest, 1, _GetMockedLine(), 12, {}, true, rePositionLineMock)

                assert.spy(button.SetItem).was.called_with(button, 90001, 91741, 12, true)
            end)

            it("hides a native action on additional Questie completion unless Blizzard allows it", function()
                quest.isComplete = true

                TrackerUtils.AddQuestItemButtons(quest, 0, _GetMockedLine(), 12, {}, true, rePositionLineMock)

                assert.spy(TrackerLinePool.GetNextItemButton).was.not_called()
            end)
        end)

        _GetMockedLine = function()
            local line = CreateFrame("Frame")
            line:SetPoint("TOPLEFT", 0, 0)
            line:SetSize(1, 1)
            line.label = CreateFrame("Button")
            line.expandQuest = CreateFrame("Button")
            line.expandQuest:Hide()
            line.expandZone = {zoneId = "Durotar"}
            return line
        end
    end)

    describe("HasQuest", function()
        local achievementIds, originalGetTrackedIds

        before_each(function()
            Questie.IsCata = false
            Questie.IsWotlk = false
            achievementIds = {}
            local AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
            originalGetTrackedIds = AchievementTracking.GetTrackedIds
            AchievementTracking.GetTrackedIds = function() return achievementIds end
        end)

        after_each(function()
            QuestieLoader:ImportModule("AchievementTracking").GetTrackedIds = originalGetTrackedIds
        end)

        it("should return true when a quest is tracked", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when no quest is tracked but an achievement for Cata", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            achievementIds = {1}
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when no quest is tracked but an achievement for WotLK", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            achievementIds = {1}
            Questie.IsWotlk = true
            Expansions.Current = Expansions.Wotlk

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return false when no quest and achievement is tracked for Cata", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            achievementIds = {}
            Questie.IsCata = true
            Expansions.Current = Expansions.Cata

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return false when no quest and achievement is tracked for WotLK", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            achievementIds = {}
            Questie.IsWotlk = true
            Expansions.Current = Expansions.Wotlk

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return false when no quest is tracked", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return true when no quest is tracked but a recipe", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            QuestieLoader:ImportModule("TrackerRecipes").HasShownRecipes = function() return true end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return false when no quest is tracked and no tracked recipe can be shown yet", function()
            QuestieTracker.GetNumTrackedQuests = function() return 0 end
            local TrackerRecipes = QuestieLoader:ImportModule("TrackerRecipes")
            TrackerRecipes.HasTrackedRecipes = function() return true end
            TrackerRecipes.HasShownRecipes = function() return false end

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)

        it("should return true when a single quest is tracked and it is not complete and complete quests should not show", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end
            QuestieTracker.IsTrackedByQuestie = function() return true end
            Questie.db.profile.trackerShowCompleteQuests = false
            trackerQuests = {
                [1] = {
                    IsComplete = function() return 0 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return true when a single quest is tracked and it is not complete but another is and complete quests should not show", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end
            QuestieTracker.IsTrackedByQuestie = function(questId)
                return questId == 1
            end
            Questie.db.profile.trackerShowCompleteQuests = false
            trackerQuests = {
                [1] = {
                    Id = 1,
                    IsComplete = function() return 0 end
                },
                [2] = {
                    Id = 2,
                    IsComplete = function() return 1 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_true(hasQuest)
        end)

        it("should return false when a quest is tracked and it is complete and complete quests should not show", function()
            QuestieTracker.GetNumTrackedQuests = function() return 1 end
            QuestieTracker.IsTrackedByQuestie = function() return true end
            Questie.db.profile.trackerShowCompleteQuests = false
            trackerQuests = {
                [1] = {
                    IsComplete = function() return 1 end
                }
            }

            local hasQuest = TrackerUtils.HasQuest()

            assert.is_false(hasQuest)
        end)
    end)

    describe("focus without verified enrichment", function()
        it("does not change existing focus when an unknown quest is selected", function()
            Questie.db.char.TrackerFocus = 11
            trackerQuests[91741] = {Id = 91741, Objectives = {}, SpecialObjectives = {}}

            assert.is_false(TrackerUtils:FocusQuest(91741))
            assert.are.equal(11, Questie.db.char.TrackerFocus)
        end)

        it("can focus a known finisher even when the completed quest has a new log objective", function()
            local original = {Id = 54, Objectives = {}, Finisher = {NPC = {240}}}
            ActiveQuests.Add(54, original)
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            QuestieDB.GetQuest = function() return original end
            trackerQuests[54] = {
                Id = 54, enrichment = original, Finisher = original.Finisher,
                Objectives = {{Index = 1, Type = "log"}}, IsComplete = function() return 1 end,
            }

            assert.is_true(TrackerUtils:FocusQuest(54))
            assert.are.equal(54, Questie.db.char.TrackerFocus)
            assert.is_nil(original.FadeIcons)
        end)
    end)

    describe("map commands recheck current eligibility", function()

        it("rejects whole-quest focus when only some live objectives are verified", function()
            trackerQuests[100] = {
                Id = 100, enrichment = {Id = 100},
                Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}, {Description = "Unknown step"}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            Questie.db.char.TrackerFocus = 11

            assert.is_false(TrackerUtils:FocusQuest(100))
            assert.are.equal(11, Questie.db.char.TrackerFocus)
        end)

        it("navigates using the refreshed display quest and its verified locations", function()
            local original = {Id = 100}
            local quest = {
                Id = 100, enrichment = original, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            trackerQuests[100] = quest
            local distance = QuestieLoader:ImportModule("DistanceUtils")
            distance.GetNearestSpawnForQuest = spy.new(function() return {50, 60}, 12, "Wolf" end)
            TrackerUtils.SetTomTomTarget = spy.new(function() end)

            assert.is_true(TrackerUtils.SetQuestTomTomTarget(100, original))
            assert.spy(TrackerData.RefreshQuest).was.called_with(100)
            assert.spy(distance.GetNearestSpawnForQuest).was.called_with(quest)
            assert.spy(TrackerUtils.SetTomTomTarget).was.called_with(TrackerUtils, "Wolf", 12, 50, 60)
        end)

        it("does not navigate a quest whose original enrichment was replaced", function()
            trackerQuests[100] = {
                Id = 100, enrichment = {Id = 100}, Objectives = {{enrichment = {Index = 3, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            local distance = QuestieLoader:ImportModule("DistanceUtils")
            distance.GetNearestSpawnForQuest = spy.new(function() end)

            assert.is_false(TrackerUtils.SetQuestTomTomTarget(100, {Id = 100}))
            assert.spy(distance.GetNearestSpawnForQuest).was.not_called()
        end)
    end)

    describe("Blizzard super tracking", function()
        local compat
        local superTrackedQuestId
        local original

        before_each(function()
            compat = QuestieLoader:ImportModule("QuestieCompat")
            superTrackedQuestId = nil
            compat.GetSuperTrackedQuestID = function() return superTrackedQuestId end
            compat.SetSuperTrackedQuestID = spy.new(function(questId) superTrackedQuestId = questId end)
            compat.ClearSuperTrackedQuest = spy.new(function() superTrackedQuestId = nil end)

            original = {Id = 54, Objectives = {}, Finisher = {NPC = {240}}}
            ActiveQuests.Add(54, original)
            QuestieLoader:ImportModule("QuestieDB").GetQuest = function() return original end
            trackerQuests[54] = {
                Id = 54, enrichment = original, Finisher = original.Finisher,
                Objectives = {}, IsComplete = function() return 1 end,
            }
        end)

        it("should super track a focused quest", function()
            TrackerUtils:FocusQuest(54)

            assert.spy(compat.SetSuperTrackedQuestID).was.called_with(54)
        end)

        it("should not super track a quest that can not be focused", function()
            trackerQuests[91741] = {Id = 91741, Objectives = {}, SpecialObjectives = {}}

            TrackerUtils:FocusQuest(91741)

            assert.spy(compat.SetSuperTrackedQuestID).was.not_called()
        end)

        it("should clear super tracking when unfocusing the super tracked quest", function()
            Questie.db.char.TrackerFocus = 54
            superTrackedQuestId = 54

            TrackerUtils:UnFocus()

            assert.spy(compat.ClearSuperTrackedQuest).was.called()
        end)

        it("should have cleared the focus when super tracking changes notify right away", function()
            Questie.db.char.TrackerFocus = 54
            superTrackedQuestId = 54
            local focusSeenOnClear
            compat.ClearSuperTrackedQuest = function() focusSeenOnClear = Questie.db.char.TrackerFocus or false end

            TrackerUtils:UnFocus()

            assert.is_false(focusSeenOnClear)
        end)

        it("should keep super tracking of another quest when unfocusing", function()
            Questie.db.char.TrackerFocus = 54
            superTrackedQuestId = 99

            TrackerUtils:UnFocus()

            assert.spy(compat.ClearSuperTrackedQuest).was.not_called()
        end)
    end)

    describe("GetCompletionText", function()
        it("should return API completion text", function()
            _G.GetQuestLogCompletionText = function() return "Return to that NPC" end
            _G.GetQuestLogIndexByID = function() return 1 end
            local quest = {Id = 1}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal("Return to that NPC", text)
        end)

        it("should return quest description when GetQuestLogCompletionText API is not available", function()
            _G.GetQuestLogCompletionText = nil
            local quest = {Id = 1, Description = {"Return to that other NPC"}}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal("Return to that other NPC", text)
        end)

        it("should return quest description when API does not return a completion text", function()
            _G.GetQuestLogCompletionText = function() return nil end
            _G.GetQuestLogIndexByID = function() return 1 end
            local quest = {Id = 1, Description = {"Return to that other NPC"}}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal("Return to that other NPC", text)
        end)

        it("should return nil when API does not return a completion text and quest also has no description", function()
            _G.GetQuestLogCompletionText = nil
            local quest = {Id = 1}

            local text = TrackerUtils:GetCompletionText(quest)

            assert.is_equal(nil, text)
        end)
    end)

    describe("GetQuestGroupName", function()
        it("uses the native header when sorting by zone", function()
            Questie.db.profile.trackerSortObjectives = "byZone"

            assert.are.equal("Northshire Abbey", TrackerUtils.GetQuestGroupName({Id = 1, zoneName = "Northshire Abbey", zoneOrSort = 12}))
        end)

        it("uses the sort mode's single group instead of the zone in other sort modes", function()
            Questie.db.profile.trackerSortObjectives = "byLevel"

            assert.are.equal("Quests (By Level)", TrackerUtils.GetQuestGroupName({Id = 1, zoneName = "Northshire Abbey", zoneOrSort = 12}))
        end)
    end)

    describe("GetSortedQuestIds", function()
        before_each(function()
            trackerQuests = {}
            Questie.db.profile.trackerSortObjectives = "byZone"
            QuestieLib.GetQuestTypeSuffix = function() return "" end

            dofile("Modules/Tracker/Sorter/Sorter.lua")
            dofile("Modules/Tracker/Sorter/byComplete.lua")
            dofile("Modules/Tracker/Sorter/byLevel.lua")
            dofile("Modules/Tracker/Sorter/byZone.lua")

            _G.C_Map = {
                GetAreaInfo = function(zoneId)
                    local zoneNames = {
                        [ZoneIDs.DUN_MOROGH] = "Dun Morogh",
                        [ZoneIDs.DUROTAR] = "Durotar",
                        [ZoneIDs.ELWYNN_FOREST] = "Elwynn Forest",
                        [ZoneIDs.ZUL_DRAK] = "Zul'Drak",
                    }
                    return zoneNames[zoneId]
                end
            }
        end)

        it("uses native headers for quests absent from the database", function()
            trackerQuests = {
                [91741] = {Id = 91741, level = 2, zoneName = "Northshire Abbey", Objectives = {}, IsComplete = function() return 1 end},
            }

            local ids, details = TrackerUtils:GetSortedQuestIds()

            assert.are.same({91741}, ids)
            assert.spy(TrackerData.Refresh).was.not_called()
            assert.are.equal("Northshire Abbey", details[91741].zoneName)
            assert.are.equal(trackerQuests[91741], details[91741].quest)
            assert.is_nil(next(ActiveQuests.GetAll()))
        end)

        it("does not treat pending or zero-total objectives as completed", function()
            trackerQuests = {
                [1] = {Id = 1, level = 2, zoneName = "Northshire Abbey", Objectives = {}, objectivesLoaded = false,
                    IsComplete = function() return 0 end},
                [2] = {Id = 2, level = 2, zoneName = "Northshire Abbey", Objectives = {{Collected = 0, Needed = 0, Completed = false}},
                    IsComplete = function() return 0 end},
                [3] = {Id = 3, level = 2, zoneName = "Northshire Abbey", Objectives = {{Collected = 0, Needed = 0, Completed = true}},
                    IsComplete = function() return 0 end},
            }

            local _, details = TrackerUtils:GetSortedQuestIds()

            assert.are.equal(0, details[1].questCompletePercent)
            assert.are.equal(0, details[2].questCompletePercent)
            assert.are.equal(1, details[3].questCompletePercent)
        end)

        it("should return quest IDs correctly sorted for 'byZone' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byZone"
            trackerQuests = {
                [1] = {Id = 1, level = 10, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [2] = {Id = 2, level = 5, zoneOrSort = ZoneIDs.ELWYNN_FOREST, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 80, zoneOrSort = ZoneIDs.ZUL_DRAK, IsComplete = function() return 1 end},
                [4] = {Id = 4, level = 15, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [5] = {Id = 5, level = 6, zoneOrSort = ZoneIDs.ELWYNN_FOREST, IsComplete = function() return 1 end},
                [6] = {Id = 6, level = 5, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [7] = {Id = 7, level = 79, zoneOrSort = ZoneIDs.ZUL_DRAK, IsComplete = function() return 1 end},
                [8] = {Id = 8, level = 10, zoneOrSort = ZoneIDs.DUN_MOROGH, IsComplete = function() return 1 end},
                [9] = {Id = 9, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [10] = {Id = 10, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [11] = {Id = 11, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [12] = {Id = 12, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
                [13] = {Id = 13, level = 12, zoneOrSort = ZoneIDs.DUROTAR, IsComplete = function() return 1 end},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [11] = "D",
                    [12] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({8, 6, 1, 9, 10, 13, 12, 11, 4, 2, 5, 7, 3}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byComplete' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byComplete"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 0, Needed = 1}}},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [4] = {Id = 4, level = 15, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [5] = {Id = 5, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
                [7] = {Id = 7, level = 10, IsComplete = function() return 1 end},
                [8] = {Id = 8, level = 5, IsComplete = function() return 1 end},
                [9] = {Id = 9, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 9, Needed = 10}}},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [6] = "D",
                    [8] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({2, 8, 6, 7, 9, 3, 5, 4, 1}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byCompleteReversed' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byCompleteReversed"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 0, Needed = 1}}},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [4] = {Id = 4, level = 15, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [5] = {Id = 5, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 5, Needed = 10}}},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
                [7] = {Id = 7, level = 10, IsComplete = function() return 1 end},
                [8] = {Id = 8, level = 5, IsComplete = function() return 1 end},
                [9] = {Id = 9, level = 10, IsComplete = function() return 0 end, Objectives = {{Collected = 9, Needed = 10}}},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [6] = "D",
                    [8] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({1, 3, 5, 4, 9, 2, 8, 6, 7}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byLevel' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byLevel"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 1 end},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 1 end},
                [4] = {Id = 4, level = 15, IsComplete = function() return 1 end},
                [5] = {Id = 5, level = 10, IsComplete = function() return 1 end},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [3] = "D",
                    [5] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({2, 6, 1, 5, 3, 4}, sortedIds)
        end)

        it("should return quest IDs correctly sorted for 'byLevelReversed' sorting", function()
            Questie.db.profile.trackerSortObjectives = "byLevelReversed"
            trackerQuests = {
                [1] = {Id = 1, level = 10, IsComplete = function() return 1 end},
                [2] = {Id = 2, level = 5, IsComplete = function() return 1 end},
                [3] = {Id = 3, level = 10, IsComplete = function() return 1 end},
                [4] = {Id = 4, level = 15, IsComplete = function() return 1 end},
                [5] = {Id = 5, level = 10, IsComplete = function() return 1 end},
                [6] = {Id = 6, level = 5, IsComplete = function() return 1 end},
            }

            QuestieLib.GetQuestTypeSuffix = function(_, questId)
                local suffixes = {
                    [3] = "D",
                    [5] = "+", -- Elite has higher prio than dungeon
                }
                return suffixes[questId] or ""
            end

            local sortedIds = TrackerUtils:GetSortedQuestIds()

            assert.are_same({4, 1, 5, 3, 2, 6}, sortedIds)
        end)
    end)
end)
