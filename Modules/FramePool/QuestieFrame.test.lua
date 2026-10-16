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

    describe("icon events", function()
        local heard, saved, reportError

        -- An icon complete enough to unload.
        local function Icon(data)
            local function Region() return {Hide = function() end, SetVertexColor = function() end} end
            return {data = data, minimapTwin = {}, texture = Region(), glowTexture = Region(), overlayTexture = Region(),
                SetScript = function() end, GetName = function() return "QuestieFrame1" end, Hide = function() end}
        end

        -- Records each event with what the icon showed at that moment.
        local function Listen(event)
            QuestieFrame.Subscribe(event, function(icon, data)
                heard[#heard + 1] = {icon = icon, data = data, iconData = icon.data, twin = icon.minimapTwin}
            end)
        end

        before_each(function()
            heard = {}
            saved = {LibStub = _G.LibStub, WorldMapFrame = _G.WorldMapFrame, C_Map = _G.C_Map, error = Questie.Error,
                IsModifierKeyDown = _G.IsModifierKeyDown, IsControlKeyDown = _G.IsControlKeyDown,
                ChatEdit_GetActiveWindow = _G.ChatEdit_GetActiveWindow, IsShiftKeyDown = _G.IsShiftKeyDown}
            reportError = spy.new(function() end)
            Questie.Error = reportError
            _G.LibStub = function() return {RemoveMinimapIcon = function() end, RemoveWorldMapIcon = function() end} end
            dofile("Modules/FramePool/QuestieFrame.lua")
            QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
            QuestieLoader:ImportModule("QuestieDBMIntegration").UnregisterHudQuestIcon = function() end
            QuestieMap.questIdFrames = {}
        end)

        after_each(function()
            for name, value in pairs(saved) do _G[name] = value end
            Questie.Error = saved.error
        end)

        it("tells features when an icon shows, hides or fades, natively or by Questie's own hiding", function()
            Listen("VisibilityChanged")
            local icon, shown = QuestieFrameInstance, true
            icon.IsShown = function() return shown end
            icon.Hide = function() shown = false end
            icon.Show = function() shown = true end
            local function Texture()
                return {Hide = function() end, GetVertexColor = function() return 1, 1, 1, 1 end, SetVertexColor = function() end}
            end
            icon.texture, icon.glowTexture = Texture(), Texture()

            QuestieFrame.private.BaseOnShow(icon)
            QuestieFrame.private.BaseOnHide(icon)
            QuestieFrame.private.FakeHide(icon)
            QuestieFrame.private.FakeShow(icon)
            QuestieFrame.private.FadeOut(icon)
            QuestieFrame.private.FadeIn(icon)

            assert.are.equal(6, #heard)
            for _, event in ipairs(heard) do assert.are.equal(icon, event.icon) end
        end)

        it("tells features an icon unloads, also at once while queued and again as the queue finishes, while it shows its data", function()
            Listen("Unload")
            local data = {Id = 123}
            local queued = Icon(data)
            local twin = queued.minimapTwin

            QuestieFrame.private.Unload(queued)
            assert.is_true(queued._needsUnload)
            -- The draw queue reaches it and finishes the unload.
            queued._loaded = true
            QuestieFrame.private.Unload(queued)

            assert.are.equal(2, #heard)
            for _, event in ipairs(heard) do
                assert.are.equal(queued, event.icon)
                assert.are.equal(data, event.iconData)
                assert.are.equal(twin, event.twin)
            end
            assert.is_nil(queued.data)
            assert.is_nil(queued.minimapTwin)

            local drawn = Icon(data)
            drawn._loaded = true
            QuestieFrame.private.Unload(drawn)
            assert.are.equal(3, #heard)
            assert.are.equal(data, heard[3].iconData)
            assert.is_nil(drawn.data)
        end)

        it("finishes an unload whatever a listener does, and reports a failing listener once", function()
            QuestieFrame.Subscribe("Unload", function() error("broken feature") end)
            Listen("Unload")
            local first, second = Icon({Id = 1}), Icon({Id = 2})
            first._loaded, second._loaded = true, true

            QuestieFrame.private.Unload(first)
            QuestieFrame.private.Unload(second)

            assert.are.equal(2, #heard)
            assert.spy(reportError).was.called(1)
            assert.is_nil(first.data)
            assert.is_nil(second.data)
        end)

        it("leaves a plain left-click on an icon on its own map to features", function()
            Listen("Click")
            _G.IsModifierKeyDown = function() return false end
            _G.IsControlKeyDown = function() return false end
            _G.WorldMapFrame = {IsShown = function() return true end, GetMapID = function() return 10 end,
                SetMapID = spy.new(function() end)}
            _G.C_Map = {GetMapInfo = function() return {parentMapID = 20} end}
            local icon = QuestieFrameInstance
            icon.UiMapID = 10

            QuestieFrame.private.OnClick(icon, "LeftButton")
            assert.are.equal(1, #heard)
            assert.are.equal(icon, heard[1].icon)

            -- Right-click goes to the parent map, and a click on another map's icon goes to its map.
            QuestieFrame.private.OnClick(icon, "RightButton")
            assert.spy(WorldMapFrame.SetMapID).was.called_with(WorldMapFrame, 20)
            icon.UiMapID = 11
            QuestieFrame.private.OnClick(icon, "LeftButton")
            assert.spy(WorldMapFrame.SetMapID).was.called_with(WorldMapFrame, 11)
            -- Modifier clicks keep their own actions.
            icon.UiMapID = 10
            _G.IsModifierKeyDown = function() return true end
            _G.ChatEdit_GetActiveWindow = function() return nil end
            _G.IsShiftKeyDown = function() return false end
            QuestieFrame.private.OnClick(icon, "LeftButton")
            assert.are.equal(1, #heard)
        end)
    end)

    describe("ResetHoverHighlights", function()
        it("should end the hover with the data it started with, after restoring the colors it tinted", function()
            local order, ended = {}, {}
            local data = QuestieFrameInstance.data
            data.touchedPins = {{icon = {texture = {SetVertexColor = function() order[#order + 1] = "untint" end}},
                color = {1, 1, 1, 1}}}
            QuestieFrame.Subscribe("HoverEnd", function(icon, endedData)
                order[#order + 1] = "listener"
                ended = {icon = icon, data = endedData}
            end)
            -- The pool handed the hovered icon out for other data before the hover ended.
            QuestieFrameInstance.data = {}

            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance, data)

            assert.are.same({"untint", "listener"}, order)
            assert.are.equal(QuestieFrameInstance, ended.icon)
            assert.are.equal(data, ended.data)
            assert.is_nil(data.touchedPins)
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

    describe("ShouldBeHidden", function()
        describe("quest category lookups", function()
            before_each(function()
                spy.on(QuestieDB, "IsRepeatable")
                spy.on(QuestieDB, "IsActiveEventQuest")
                spy.on(QuestieDB, "IsDungeonQuest")
                spy.on(QuestieDB, "IsRaidQuest")
                spy.on(QuestieDB, "IsPvPQuest")
            end)

            for _, iconType in ipairs({"monster", "object", "item", "event", "complete"}) do
                it("skips category lookups for " .. iconType .. " icons", function()
                    QuestieFrameInstance.data.Type = iconType
                    Questie.db.profile.enableAvailable = false
                    Questie.db.profile.showRepeatableQuests = false
                    Questie.db.profile.showEventQuests = false
                    Questie.db.profile.showDungeonQuests = false
                    Questie.db.profile.showRaidQuests = false
                    Questie.db.profile.showPvPQuests = false

                    assert.is_false(QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance))

                    assert.spy(QuestieDB.IsRepeatable).was.not_called()
                    assert.spy(QuestieDB.IsActiveEventQuest).was.not_called()
                    assert.spy(QuestieDB.IsDungeonQuest).was.not_called()
                    assert.spy(QuestieDB.IsRaidQuest).was.not_called()
                    assert.spy(QuestieDB.IsPvPQuest).was.not_called()
                end)
            end

            it("skips category lookups for available icons already hidden by map settings", function()
                QuestieFrameInstance.data.Type = "available"
                Questie.db.profile.enableMapIcons = false

                assert.is_true(QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance))

                assert.spy(QuestieDB.IsRepeatable).was.not_called()
                assert.spy(QuestieDB.IsActiveEventQuest).was.not_called()
                assert.spy(QuestieDB.IsDungeonQuest).was.not_called()
                assert.spy(QuestieDB.IsRaidQuest).was.not_called()
                assert.spy(QuestieDB.IsPvPQuest).was.not_called()
            end)
        end)

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
