dofile("setupTests.lua")

describe("QuestieFrame", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieFrame
    local QuestieFrame
    ---@type QuestieWaypoints
    local QuestieWaypoints

    ---@type IconFrame
    local QuestieFrameInstance

    before_each(function()
        Questie.db.profile = {
            enabled = true,
            enableMapIcons = true,
            enableMiniMapIcons = true,
            enableTurnins = true,
            enableObjectives = true,
            enableAvailable = true,
            showRepeatableQuests = true,
            showEventQuests = true,
            showDungeonQuests = true,
            showRaidQuests = true,
            showPvPQuests = true,
            enableAvailableItems = true,
            hideUnexploredMapIcons = false,
            hideUntrackedQuestsMapIcons = false,
        }

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsActiveEventQuest = function() return false end
        QuestieDB.IsDungeonQuest = function() return false end
        QuestieDB.IsRaidQuest = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieDB.IsRuneAndShouldBeHidden = function() return false end

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.utils = {IsExplored = function() return true end}

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ShouldShowQuestNotes = function() return true end

        QuestieLoader:ImportModule("DailyQuests")

        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.SetHighlighted = spy.new(function() end)
        QuestieWaypoints.OwnerChanged = spy.new(function() end)
        QuestieWaypoints.RemoveOwner = spy.new(function() end)

        dofile("Localization/l10n.lua")
        dofile("Modules/FramePool/QuestieFrame.lua")
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrameInstance = {
            data = {
                Type = "monster",
                Id = 123,
            }
        }
    end)

    it("passes the clicked quest name and ID to the hide confirmation", function()
        local Popup = QuestieLoader:ImportModule("QuestiePopup")
        Popup.Show = spy.new(function() end)
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function(_, id)
            return "Quest " .. id
        end
        _G.WorldMapFrame = {IsShown = function() return false end}
        _G.ChatEdit_GetActiveWindow = function() return nil end
        _G.IsShiftKeyDown = function() return true end
        _G.IsControlKeyDown = function() return false end
        QuestieFrameInstance.UiMapID = 1
        QuestieFrameInstance.data.Type = "available"

        QuestieFrame.private.OnClick(QuestieFrameInstance, "LeftButton")

        assert.spy(Popup.Show).was.called_with("QUESTIE_CONFIRMHIDE",
            "Are you sure you want to hide the quest 'Quest 123'?\nIf this quest isn't actually available, please report it to us!", nil, 123)
    end)

    describe("polygon marker interaction", function()
        local Polygon, saved
        before_each(function()
            Polygon = QuestieLoader:ImportModule("QuestiePolygon")
            Polygon.ToggleMarker = spy.new(function() end)
            Polygon.LeaveMarker = spy.new(function() end)
            Polygon.MarkerRemoved = spy.new(function(frame) frame.polygonMarker = nil end)
            Polygon.MarkerChanged = spy.new(function() end)
            Polygon.ScheduleRefresh = spy.new(function() end)
            saved = {WorldMapFrame = _G.WorldMapFrame, IsModifierKeyDown = _G.IsModifierKeyDown,
                IsControlKeyDown = _G.IsControlKeyDown, C_Map = _G.C_Map,
                ChatEdit_GetActiveWindow = _G.ChatEdit_GetActiveWindow, IsShiftKeyDown = _G.IsShiftKeyDown,
                GameTooltip = _G.GameTooltip, WorldMapTooltip = _G.WorldMapTooltip}
            _G.IsModifierKeyDown = function() return false end
            _G.IsControlKeyDown = function() return false end
            _G.GameTooltip = {Hide = function() end}
            _G.WorldMapTooltip = nil
            _G.WorldMapFrame = {IsShown = function() return true end, GetMapID = function() return 10 end,
                SetMapID = spy.new(function() end)}
            _G.C_Map = {GetMapInfo = function() return {parentMapID = 20} end}
            QuestieFrameInstance.UiMapID = 10
            QuestieFrameInstance.polygonMarker = {}
        end)
        after_each(function()
            _G.WorldMapFrame, _G.C_Map = saved.WorldMapFrame, saved.C_Map
            _G.IsModifierKeyDown, _G.IsControlKeyDown = saved.IsModifierKeyDown, saved.IsControlKeyDown
            _G.ChatEdit_GetActiveWindow, _G.IsShiftKeyDown = saved.ChatEdit_GetActiveWindow, saved.IsShiftKeyDown
            _G.GameTooltip, _G.WorldMapTooltip = saved.GameTooltip, saved.WorldMapTooltip
        end)

        it("toggles the blob only for a plain left-click on its own map", function()
            QuestieFrame.private.OnClick(QuestieFrameInstance, "LeftButton")
            assert.spy(Polygon.ToggleMarker).was.called_with(QuestieFrameInstance)
        end)

        it("navigates to another map instead of toggling a blob", function()
            QuestieFrameInstance.UiMapID = 11
            QuestieFrame.private.OnClick(QuestieFrameInstance, "LeftButton")
            assert.spy(WorldMapFrame.SetMapID).was.called_with(WorldMapFrame, 11)
            assert.spy(Polygon.ToggleMarker).was.not_called()
        end)

        it("keeps right-click parent navigation without toggling", function()
            QuestieFrame.private.OnClick(QuestieFrameInstance, "RightButton")
            assert.spy(WorldMapFrame.SetMapID).was.called_with(WorldMapFrame, 20)
            assert.spy(Polygon.ToggleMarker).was.not_called()
        end)

        it("does not toggle a blob for modifier clicks", function()
            _G.IsModifierKeyDown = function() return true end
            _G.ChatEdit_GetActiveWindow = function() return nil end
            _G.IsShiftKeyDown = function() return false end
            QuestieFrame.private.OnClick(QuestieFrameInstance, "LeftButton")
            assert.spy(Polygon.ToggleMarker).was.not_called()
        end)

        it("clears temporary polygon preview on marker leave", function()
            QuestieFrame.private.OnLeave(QuestieFrameInstance)
            assert.spy(Polygon.LeaveMarker).was.called_with(QuestieFrameInstance)
        end)

        it("releases polygon ownership before a queued icon defers its unload", function()
            QuestieFrame.private.Unload(QuestieFrameInstance)
            assert.spy(Polygon.MarkerRemoved).was.called(1)
            assert.is_nil(QuestieFrameInstance.polygonMarker)
            assert.is_true(QuestieFrameInstance._needsUnload)
        end)

        it("schedules polygon drawing after native marker show and hide without changing ownership", function()
            local marker = QuestieFrameInstance.polygonMarker
            QuestieFrameInstance.glowTexture = {Hide = spy.new(function() end)}
            QuestieFrame.private.BaseOnShow(QuestieFrameInstance)
            QuestieFrame.private.BaseOnHide(QuestieFrameInstance)

            assert.spy(Polygon.ScheduleRefresh).was.called(2)
            assert.are.equal(marker, QuestieFrameInstance.polygonMarker)
            assert.spy(Polygon.MarkerChanged).was.not_called() -- No redundant nudging work.
            assert.spy(Polygon.ToggleMarker).was.not_called()
            assert.spy(QuestieFrameInstance.glowTexture.Hide).was.called(1)
        end)

        it("does not schedule polygon refreshes for ordinary icon show and hide", function()
            QuestieFrameInstance.polygonMarker = nil
            QuestieFrameInstance.glowTexture = {Hide = function() end}
            QuestieFrame.private.BaseOnShow(QuestieFrameInstance)
            QuestieFrame.private.BaseOnHide(QuestieFrameInstance)
            assert.spy(Polygon.ScheduleRefresh).was.not_called()
        end)

        it("notifies the adapter when logical visibility changes", function()
            QuestieFrameInstance.Show = function() end
            QuestieFrameInstance.Hide = function() end
            QuestieFrameInstance.IsShown = function() return true end
            QuestieFrame.private.FakeHide(QuestieFrameInstance)
            QuestieFrame.private.FakeShow(QuestieFrameInstance)
            assert.spy(Polygon.MarkerChanged).was.called(2)
            assert.is_false(QuestieFrameInstance.hidden)
        end)
    end)

    describe("ResetHoverHighlights", function()
        it("should end the highlight of the NPC's waypoint paths", function()
            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(QuestieFrameInstance.data, false)
        end)

        it("should restore touched pins in reverse order and clear them", function()
            local restored = {}
            local function CreateTouchedPin(name, color)
                return {
                    icon = {texture = {SetVertexColor = function() table.insert(restored, name) end}},
                    color = color,
                }
            end
            QuestieFrameInstance.data.touchedPins = {CreateTouchedPin("first", {1, 1, 1, 1}), CreateTouchedPin("second", {1, 1, 1, 1})}

            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.are_same({"second", "first"}, restored)
            assert.is_nil(QuestieFrameInstance.data.touchedPins)
        end)

        it("should do nothing without highlights", function()
            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.is_nil(QuestieFrameInstance.data.touchedPins)
        end)
    end)

    describe("waypoint paths", function()
        before_each(function()
            QuestieWaypoints.OwnerChanged = spy.new(function() end)
        end)

        it("should redraw the icon's paths when it is fake hidden or shown", function()
            local shown = true
            QuestieFrameInstance.IsShown = function() return shown end
            QuestieFrameInstance.Hide = function() shown = false end
            QuestieFrameInstance.Show = function() shown = true end

            QuestieFrame.private.FakeHide(QuestieFrameInstance)
            assert.spy(QuestieWaypoints.OwnerChanged).was.called_with(QuestieFrameInstance)
            assert.is_true(QuestieFrameInstance.hidden)

            QuestieFrame.private.FakeShow(QuestieFrameInstance)
            assert.spy(QuestieWaypoints.OwnerChanged).was.called(2)
            assert.is_false(QuestieFrameInstance.hidden)
        end)

        it("should release the icon's paths and minimap twin when it unloads", function()
            local savedLibStub = _G.LibStub
            _G.LibStub = function() return {RemoveMinimapIcon = function() end, RemoveWorldMapIcon = function() end} end
            dofile("Modules/FramePool/QuestieFrame.lua")
            _G.LibStub = savedLibStub
            QuestieLoader:ImportModule("QuestieDBMIntegration").UnregisterHudQuestIcon = function() end
            QuestieMap.questIdFrames = {}
            QuestieWaypoints.RemoveOwner = spy.new(function() end)
            local function Region() return {Hide = function() end, SetVertexColor = function() end} end
            local icon = {_loaded = true, data = {Id = 123}, minimapTwin = {}, texture = Region(), glowTexture = Region(),
                overlayTexture = Region(), SetScript = function() end, GetName = function() return "QuestieFrame1" end,
                Hide = function() end}

            QuestieFrame.private.Unload(icon)

            -- Spies copy their arguments, and Unload clears the icon afterwards; compare the reference.
            assert.spy(QuestieWaypoints.RemoveOwner).was.called(1)
            assert.are.equal(icon, QuestieWaypoints.RemoveOwner.calls[1].refs[1])
            assert.is_nil(icon.minimapTwin)
        end)

        it("should release the icon's paths when it unloads while still waiting in the draw queue", function()
            QuestieWaypoints.RemoveOwner = spy.new(function() end)
            local icon = {data = {Id = 123}}

            QuestieFrame.private.Unload(icon)

            assert.spy(QuestieWaypoints.RemoveOwner).was.called(1)
            assert.are.equal(icon, QuestieWaypoints.RemoveOwner.calls[1].refs[1])
            assert.is_true(icon._needsUnload)
        end)

        it("should redraw the icon's paths when it fades", function()
            local function Texture()
                return {GetVertexColor = function() return 1, 1, 1, 1 end, SetVertexColor = function() end}
            end
            QuestieFrameInstance.texture, QuestieFrameInstance.glowTexture = Texture(), Texture()

            QuestieFrame.private.FadeOut(QuestieFrameInstance)
            QuestieFrame.private.FadeIn(QuestieFrameInstance)

            assert.spy(QuestieWaypoints.OwnerChanged).was.called(2)
        end)
    end)

    describe("ShouldBeHidden", function()
        it("should return true when all icons are disabled", function()
            Questie.db.profile.enabled = false

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame is map icon and map icons are disabled", function()
            Questie.db.profile.enableMapIcons = false
            QuestieFrameInstance.miniMapIcon = false

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame is minimap icon and minimap icons are disabled", function()
            Questie.db.profile.enableMiniMapIcons = false
            QuestieFrameInstance.miniMapIcon = true

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is complete and turn in icons are disabled", function()
            Questie.db.profile.enableTurnins = false
            QuestieFrameInstance.data.Type = "complete"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is monster and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "monster"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is object and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "object"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is event and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "event"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is item and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "item"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame coords are unexplored and unexplored icons should be hidden", function()
            QuestieMap.utils.IsExplored = spy.new(function() return false end)
            Questie.db.profile.hideUnexploredMapIcons = true
            QuestieFrameInstance.UiMapID = 1
            QuestieFrameInstance.x = 50
            QuestieFrameInstance.y = 60

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
            assert.spy(QuestieMap.utils.IsExplored).was.called_with(1, 50, 60)
        end)

        it("should return false when frame coords are explored and unexplored icons should be hidden", function()
            QuestieMap.utils.IsExplored = spy.new(function() return true end)
            Questie.db.profile.hideUnexploredMapIcons = true
            QuestieFrameInstance.UiMapID = 1
            QuestieFrameInstance.x = 50
            QuestieFrameInstance.y = 60

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieMap.utils.IsExplored).was.called_with(1, 50, 60)
        end)

        it("should return true when quest notes should not be shown and untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return false end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Id = 123

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.called_with(QuestieQuest, 123)
        end)

        it("should return false when quest notes should be shown and untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return true end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Id = 123

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.called_with(QuestieQuest, 123)
        end)

        it("should return false for available icons when untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return false end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.not_called()
        end)

        it("should return true when ObjectiveData is set and icons should be hidden", function()
            QuestieFrameInstance.data.ObjectiveData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when QuestData is set and icons should be hidden for icons that are not complete", function()
            QuestieFrameInstance.data.Type = "monster"
            QuestieFrameInstance.data.QuestData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false when QuestData is set and icons should be hidden for complete icons", function()
            QuestieFrameInstance.data.Type = "complete"
            QuestieFrameInstance.data.QuestData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when available icons should be hidden", function()
            Questie.db.profile.enableAvailable = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when available icons should be hidden but quest is repeatable", function()
            QuestieDB.IsRepeatable = function() return true end
            Questie.db.profile.enableAvailable = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when repeatable icons should be hidden", function()
            QuestieDB.IsRepeatable = function() return true end
            Questie.db.profile.showRepeatableQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when repeatable icons should be hidden but quest is normal", function()
            Questie.db.profile.showRepeatableQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when event icons should be hidden", function()
            QuestieDB.IsActiveEventQuest = function() return true end
            Questie.db.profile.showEventQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when event icons should be hidden but quest is normal", function()
            Questie.db.profile.showEventQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when dungeon icons should be hidden", function()
            QuestieDB.IsDungeonQuest = function() return true end
            Questie.db.profile.showDungeonQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when dungeon icons should be hidden but quest is normal", function()
            Questie.db.profile.showDungeonQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when raid icons should be hidden", function()
            QuestieDB.IsRaidQuest = function() return true end
            Questie.db.profile.showRaidQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when raid icons should be hidden but quest is normal", function()
            Questie.db.profile.showRaidQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when PvP icons should be hidden", function()
            QuestieDB.IsPvPQuest = function() return true end
            Questie.db.profile.showPvPQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when PvP icons should be hidden but quest is normal", function()
            Questie.db.profile.showPvPQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when item drop icons should be hidden", function()
            Questie.db.profile.enableAvailableItems = false
            QuestieFrameInstance.data.Type = "available"
            QuestieFrameInstance.data.StarterType = "itemFromMonster"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when item drop icons should be hidden but quest is not started by a drop", function()
            Questie.db.profile.enableAvailableItems = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when quest is rune quest and should be hidden", function()
            Questie.IsSoD = true
            QuestieDB.IsRuneAndShouldBeHidden = function() return true end
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when not SoD", function()
            Questie.IsSoD = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)
    end)
end)
