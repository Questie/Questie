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
    ---@type MapIconTooltip
    local MapIconTooltip
    ---@type IconHighlight
    local IconHighlight

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
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        MapIconTooltip.Release = spy.new(function() end)
        IconHighlight = QuestieLoader:ImportModule("IconHighlight")
        IconHighlight.StartHover = spy.new(function() end)
        IconHighlight.EndHover = spy.new(function() end)
        IconHighlight.Forget = spy.new(function() end)

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

    it("ends only its own tooltip when the cursor leaves the icon, and leaves another holder's", function()
        local savedGameTooltip = _G.GameTooltip
        local tooltip = {Hide = spy.new(function() end)}
        _G.GameTooltip = tooltip

        QuestieFrame.private.OnLeave(QuestieFrameInstance)
        _G.GameTooltip = savedGameTooltip

        assert.spy(MapIconTooltip.Release).was.called(1)
        assert.are.equal(QuestieFrameInstance, MapIconTooltip.Release.calls[1].refs[1])
        assert.are.equal(tooltip, MapIconTooltip.Release.calls[1].refs[2])
        assert.spy(tooltip.Hide).was.not_called()
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
                heard[#heard + 1] = {event = event, icon = icon, data = data, iconData = icon.data, twin = icon.minimapTwin}
            end)
        end

        before_each(function()
            heard = {}
            saved = {LibStub = _G.LibStub, WorldMapFrame = _G.WorldMapFrame, C_Map = _G.C_Map, error = Questie.Error,
                IsModifierKeyDown = _G.IsModifierKeyDown, IsControlKeyDown = _G.IsControlKeyDown,
                ChatEdit_GetActiveWindow = _G.ChatEdit_GetActiveWindow, IsShiftKeyDown = _G.IsShiftKeyDown,
                ChatEdit_InsertLink = _G.ChatEdit_InsertLink}
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

        it("tells features when an icon shows, hides or fades, by Questie's own hiding apart from natively", function()
            Listen("VisibilityChanged")
            Listen("NativeVisibilityChanged")
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

            local events = {}
            for i, event in ipairs(heard) do
                assert.are.equal(icon, event.icon)
                events[i] = event.event
            end
            assert.are.same({"NativeVisibilityChanged", "NativeVisibilityChanged", "VisibilityChanged", "VisibilityChanged",
                "VisibilityChanged", "VisibilityChanged"}, events)
        end)

        it("tells features an icon unloads, also at once while queued and again as the queue finishes, while it shows its data", function()
            Listen("Unload")
            local data = {Id = 123}
            local queued = Icon(data)
            local twin = queued.minimapTwin

            QuestieFrame.private.Unload(queued)
            assert.is_true(queued._needsUnload)
            -- Its highlight goes at once too: the pool may hand it out again before the hover ends.
            assert.spy(IconHighlight.Forget).was.called(1)
            assert.are.equal(queued, IconHighlight.Forget.calls[1].refs[1])
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
            local failures = 0
            QuestieFrame.Subscribe("Unload", function()
                failures = failures + 1
                error("broken feature")
            end)
            Listen("Unload")
            local first, second = Icon({Id = 1}), Icon({Id = 2})
            first._loaded, second._loaded = true, true

            QuestieFrame.private.Unload(first)
            QuestieFrame.private.Unload(second)

            assert.are.equal(2, #heard)
            -- The failing listener still hears every unload: skipping one would leak what it owns.
            assert.are.equal(2, failures)
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

        it("leaves a plain left-click on a minimap icon to features, unless chat takes the quest's link", function()
            Listen("Click")
            _G.IsModifierKeyDown = function() return false end
            _G.IsControlKeyDown = function() return false end
            _G.IsShiftKeyDown = function() return false end
            _G.ChatEdit_GetActiveWindow = function() return nil end
            -- An open world map changes nothing for minimap icons.
            _G.WorldMapFrame = {IsShown = function() return true end}
            local icon = QuestieFrameInstance
            icon.UiMapID, icon.miniMapIcon, icon.data.QuestData = 10, true, {}

            QuestieFrame.private.OnClick(icon, "LeftButton")
            assert.are.equal(1, #heard)
            assert.are.equal(icon, heard[1].icon)

            _G.ChatEdit_GetActiveWindow = function() return {} end
            _G.ChatEdit_InsertLink = spy.new(function() end)
            QuestieLoader:ImportModule("QuestieLink").GetQuestLinkStringById = function(id) return "link " .. id end
            QuestieFrame.private.OnClick(icon, "LeftButton")
            assert.spy(ChatEdit_InsertLink).was.called_with("link 123")
            _G.ChatEdit_GetActiveWindow = function() return nil end
            _G.IsModifierKeyDown = function() return true end
            QuestieFrame.private.OnClick(icon, "LeftButton")
            assert.are.equal(1, #heard)
        end)
    end)

    it("keeps the glow ring as large as IconHighlight grew it through every glow update", function()
        local glow = {IsShown = function() return true end, GetWidth = function(self) return self.width end,
            SetSize = function(self, width, height) self.width, self.height = width, height end, SetVertexColor = function() end}
        local icon = {glowTexture = glow, texture = {a = 1}, GetWidth = function() return 10 end, GetHeight = function() return 20 end}

        icon.glowScale = 2
        QuestieFrame.private.GlowUpdate(icon)
        assert.are.near(22.6, glow.width, 1e-9)
        assert.are.near(45.2, glow.height, 1e-9)
        icon.glowScale = nil
        QuestieFrame.private.GlowUpdate(icon)
        assert.are.near(11.3, glow.width, 1e-9)
        assert.are.near(22.6, glow.height, 1e-9)
    end)

    it("fits the picture and its overlay to the frame, centred and larger while grown, through every resize", function()
        local function Picture()
            local picture = {}
            function picture:ClearAllPoints() self.points = {} end
            function picture:SetPoint(point, frame, relativePoint) self.points[#self.points + 1] = {point, frame, relativePoint} end
            function picture:SetAllPoints(frame) self.points = {{"all", frame}} end
            function picture:SetSize(width, height) self.size = {width, height} end
            return picture
        end
        local size = 10
        local icon = {texture = Picture(), overlayTexture = Picture(), glowTexture = {IsShown = function() return false end},
            GetWidth = function() return size end, GetHeight = function() return size end}

        icon.pictureScale = 1.5
        QuestieFrame.private.GlowUpdate(icon)
        for _, picture in ipairs({icon.texture, icon.overlayTexture}) do
            assert.are.same({{"CENTER", icon, "CENTER"}}, picture.points)
            assert.are.same({15, 15}, picture.size)
        end
        -- Another map type sizes the icon anew while it is grown; HereBeDragons shows it again.
        size = 20
        QuestieFrame.private.GlowUpdate(icon)
        assert.are.same({30, 30}, icon.overlayTexture.size)
        size = 12
        QuestieFrame.private.BaseOnShow(icon)
        assert.are.same({18, 18}, icon.texture.size)
        -- A quest giver's icon is drawn anew, at its plain size, while it is hovered.
        icon.data = {}
        icon.texture.SetTexture, icon.texture.SetVertexColor, icon.overlayTexture.Hide = function() end, function() end, function() end
        icon.overlayTexture.SetTexture, icon.SetAlpha = function() end, function() end
        icon.SetSize = function(_, width) size = width end
        QuestieFrame.private.UpdateTexture(icon, "texture")
        assert.are.same({24, 24}, icon.texture.size)

        icon.pictureScale = nil
        QuestieFrame.private.GlowUpdate(icon)
        assert.are.same({{"all", icon}}, icon.texture.points)
        assert.are.same({{"all", icon}}, icon.overlayTexture.points)
    end)

    describe("hovering", function()
        local order

        local function MapIcon(data)
            return {data = data, texture = {GetVertexColor = function(self) return 1, 1, 1, self.a end, a = 1}}
        end

        before_each(function()
            order = {}
            IconHighlight.StartHover = function(icon) order[#order + 1] = {"highlight", icon} end
            IconHighlight.EndHover = function(icon, data) order[#order + 1] = {"end highlight", icon, data} end
            MapIconTooltip.ShowOnTooltip = function(icon, tooltip) order[#order + 1] = {"tooltip", icon, tooltip} end
            QuestieFrame.Subscribe("HoverStart", function(icon) order[#order + 1] = {"hover start", icon} end)
            QuestieFrame.Subscribe("HoverEnd", function(icon, data) order[#order + 1] = {"hover end", icon, data} end)
        end)

        local function Steps()
            local steps = {}
            for i, step in ipairs(order) do steps[i] = step[1] end
            return steps
        end

        it("starts the hover, then its highlight, then the tooltip, and none for an icon faded out to nothing", function()
            local icon = MapIcon({Id = 123, Type = "monster"})

            QuestieFrame.private.OnEnter(icon)
            assert.are.same({"hover start", "highlight", "tooltip"}, Steps())
            assert.are.equal(icon, order[2][2])
            assert.are.equal(GameTooltip, order[3][3])

            order = {}
            icon.texture.a = 0
            QuestieFrame.private.OnEnter(icon)
            assert.are.same({}, order)
        end)

        it("ends the cursor's hover with the data it started with, though the pool handed the icon out since", function()
            local data = {Id = 123, Type = "monster"}
            local icon = MapIcon(data)
            QuestieFrame.private.OnEnter(icon)
            order = {}

            icon.data = {Id = 7, Type = "complete"}
            QuestieFrame.private.OnLeave(icon)

            -- The highlight ends first, so HoverEnd listeners see the quest's icons put back.
            assert.are.same({"end highlight", "hover end"}, Steps())
            assert.are.same({icon, data}, {order[1][2], order[1][3]})
            assert.are.equal(icon, order[2][2])
            assert.are.equal(data, order[2][3])
        end)

        it("ends a hover with the icon's data when given none", function()
            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.are.same({"end highlight", "hover end"}, Steps())
            assert.are.equal(QuestieFrameInstance.data, order[1][3])
            assert.are.equal(QuestieFrameInstance, order[2][2])
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
