dofile("setupTests.lua")

describe("PolygonQuestLogForever", function()
    local QuestLog, Polygon, savedGlobals, savedPolygon, hooks, titles, rows, leaderboards, objectiveStates, tooltip
    local markers, enabled, eventFrame, MapPreview, savedPreview, started, ended
    local GLOBALS = {"CreateFrame", "hooksecurefunc", "QuestScrollFrame", "GetNumQuestLeaderBoards", "GetQuestLogLeaderBoard",
        "PlaySound", "SOUNDKIT", "GameTooltip", "IsShiftKeyDown", "C_Timer"}
    local POLYGON_API = {"RegisterVisibilityCallback", "GetObjectiveAreaState", "SetObjectiveAreaShown", "SetQuestAreasShown",
        "IsEnabled"}

    local function Texture()
        local texture = {shown = true}
        texture.SetAtlas, texture.SetAllPoints, texture.SetPoint = function() end, function() end, function() end
        texture.SetVertexColor = function(self, r, g, b, a) self.color = {r, g, b, a} end
        texture.SetShown = function(self, shown) self.shown = shown end
        texture.SetTexture = function(self, path) self.path = path end
        texture.SetSnapToPixelGrid = function(self, snap) self.snap = snap end
        texture.SetTexelSnappingBias = function(self, bias) self.bias = bias end
        return texture
    end

    -- Pooled rows keep their identity while Blizzard rewrites their text.
    local function Row(questID, text)
        local row = {questID = questID, text = text}
        row.Text = {GetText = function() return row.text end}
        return row
    end

    -- Blizzard's quest marker on a title row, sized by its template.
    local function Marker(width)
        local marker = {width = width, scale = 1, Glow = {scale = 1}}
        marker.Glow.SetScale = function(self, scale) self.scale = scale end
        marker.GetWidth = function(self) return self.width end
        marker.GetScale = function(self) return self.scale end
        marker.SetScale = function(self, scale) self.scale = scale end
        marker.SetPoint = function(self, ...) self.point = {...} end
        return marker
    end

    local function Pool(list)
        return {EnumerateActive = function()
            local i = 0
            return function()
                i = i + 1
                return list[i]
            end
        end}
    end

    before_each(function()
        Polygon = QuestieLoader:ImportModule("QuestiePolygon")
        savedGlobals, savedPolygon = {}, {}
        for _, name in ipairs(GLOBALS) do savedGlobals[name] = _G[name] end
        for _, name in ipairs(POLYGON_API) do savedPolygon[name] = Polygon[name] end
        hooks, titles, rows, leaderboards, objectiveStates, markers, enabled = {}, {}, {}, {}, {}, {}, true
        _G.CreateFrame = function()
            local box = {shown = true}
            box.SetSize = function() end
            box.SetPoint = function(self, ...) self.point = {...} end
            box.CreateTexture = function(self)
                local texture = Texture()
                self.textures = self.textures or {}
                self.textures[#self.textures + 1] = texture
                return texture
            end
            box.scripts = {}
            box.SetScript = function(self, name, handler) self.scripts[name] = handler end
            box.Show = function(self) self.shown = true end
            box.Hide = function(self) self.shown = false end
            box.RegisterEvent = function(self, event)
                self.event = event
                eventFrame = self
            end
            return box
        end
        _G.hooksecurefunc = function(name, callback) hooks[name] = callback end
        _G.C_Timer = {After = function(_, callback) callback() end}
        _G.QuestScrollFrame = {titleFramePool = Pool(titles), objectiveFramePool = Pool(rows),
            Contents = {FindButtonByQuestID = function(_, questID) return markers[questID] end}}
        _G.GetNumQuestLeaderBoards = function(questLogIndex) return #(leaderboards[questLogIndex] or {}) end
        _G.GetQuestLogLeaderBoard = function(index, questLogIndex) return unpack(leaderboards[questLogIndex][index]) end
        _G.PlaySound = spy.new(function() end)
        _G.SOUNDKIT = {IG_MAINMENU_OPTION_CHECKBOX_ON = 1, IG_MAINMENU_OPTION_CHECKBOX_OFF = 2}
        tooltip = {SetOwner = function(self, owner) self.owner, self.hidden = owner, false end,
            SetText = function(self, text) self.text = text end, Show = function() end,
            AddLine = function(self, text) self.hint = text end,
            Hide = function(self) self.owner, self.hidden = nil, true end,
            IsOwned = function(self, frame) return self.owner == frame end}
        _G.GameTooltip = tooltip
        _G.IsShiftKeyDown = function() return false end
        dofile("Localization/l10n.lua")

        Polygon.RegisterVisibilityCallback = spy.new(function() end)
        Polygon.IsEnabled = function() return enabled end
        Polygon.GetObjectiveAreaState = function(questId, index)
            local state = objectiveStates[questId .. ":" .. index]
            if state then return state[1], state[2] end
        end
        Polygon.SetObjectiveAreaShown = spy.new(function() end)
        Polygon.SetQuestAreasShown = spy.new(function() end)
        MapPreview = QuestieLoader:ImportModule("MapPreview")
        savedPreview = {start = MapPreview.Start, finish = MapPreview.End}
        started, ended = {}, {}
        MapPreview.Start = function(questId, objectiveIndex)
            local preview = {questId = questId, objectiveIndex = objectiveIndex}
            started[#started + 1] = preview
            return preview
        end
        MapPreview.End = function(preview) ended[#ended + 1] = preview end
        dofile("Modules/Map/Polygon/PolygonQuestLogForever.lua")
        QuestLog = QuestieLoader:ImportModule("PolygonQuestLogForever")
    end)

    after_each(function()
        -- Explicit lists also restore globals and API functions that started out nil.
        for _, name in ipairs(GLOBALS) do _G[name] = savedGlobals[name] end
        for _, name in ipairs(POLYGON_API) do Polygon[name] = savedPolygon[name] end
        MapPreview.Start, MapPreview.End = savedPreview.start, savedPreview.finish
    end)

    it("refreshes after Blizzard's quest log rebuild and after area visibility changes", function()
        assert.are.equal(QuestLog.Update, hooks.QuestLogQuests_Update)
        assert.spy(Polygon.RegisterVisibilityCallback).was.called_with(QuestLog.Update)
    end)

    it("matches objective rows by leaderboard text, independent of pool order", function()
        titles[1] = {questID = 7, questLogIndex = 3}
        -- Objective 1 is finished, so Blizzard shows no row for it; the money row matches nothing.
        leaderboards[3] = {{"Kill 5 wolves", "monster", true}, {"0/8 Wolf Meat", "item", false}, {"0/2 Fang", "item", false}}
        rows[1], rows[2], rows[3] = Row(7, "0/2 Fang"), Row(7, "1g / 5g"), Row(7, "0/8 Wolf Meat")
        objectiveStates["7:2"], objectiveStates["7:3"] = {true, {0.2, 0.4, 0.6}}, {false, {0.9, 0.1, 0.1}}

        QuestLog.Update()

        local fang, money, meat = rows[1].QuestiePolygonAreaBox, rows[2].QuestiePolygonAreaBox, rows[3].QuestiePolygonAreaBox
        assert.are.same({3, 2}, {fang.objectiveIndex, meat.objectiveIndex})
        assert.are.same({true, false, true}, {fang.shown, money.shown, meat.shown})
        -- Shown: a muted, rounded fill in the area color. Hidden: an empty box.
        assert.are.same({true, false}, {meat.Fill.shown, fang.Fill.shown})
        assert.are.same({0.2, 0.4, 0.6, 0.5}, meat.Fill.color)
        assert.are.equal("Interface\\Addons\\Questie\\Icons\\quest-log-area-fill.png", meat.Fill.path)
        -- Border and fill both draw unsnapped, so fractional UI scales stay symmetric.
        for _, texture in ipairs(meat.textures) do
            assert.are.same({false, 0}, {texture.snap, texture.bias})
        end
        -- The box sits in the gutter left of the row, aligned with its first line.
        assert.are.same({"TOPRIGHT", rows[1], "TOPLEFT", -4, 1}, fang.point)
    end)

    it("hides a pooled row's box once it shows an objective without areas", function()
        titles[1] = {questID = 7, questLogIndex = 1}
        leaderboards[1] = {{"0/8 Wolf Meat", "item", false}}
        rows[1] = Row(7, "0/8 Wolf Meat")
        objectiveStates["7:1"] = {true, {1, 0, 0}}
        QuestLog.Update()
        assert.is_true(rows[1].QuestiePolygonAreaBox.shown)

        objectiveStates["7:1"] = nil
        QuestLog.Update()
        assert.is_false(rows[1].QuestiePolygonAreaBox.shown)
    end)

    it("restyles reused rows when Blizzard rebuilds the log before it becomes visible", function()
        titles[1] = {questID = 7, questLogIndex = 1}
        leaderboards[1] = {{"0/8 Wolf Meat", "item", false}}
        rows[1] = Row(7, "0/8 Wolf Meat")
        objectiveStates["7:1"] = {true, {1, 0, 0}}
        QuestLog.Update()

        -- Opening the log rebuilds it while still hidden, and no later rebuild is guaranteed.
        _G.QuestScrollFrame.IsVisible = function() return false end
        titles[1] = {questID = 8, questLogIndex = 1}
        leaderboards[1] = {{"0/3 Fang", "item", false}}
        rows[1].questID, rows[1].text = 8, "0/3 Fang"
        objectiveStates["8:1"] = {false, {0, 0, 1}}
        QuestLog.Update()

        local box = rows[1].QuestiePolygonAreaBox
        assert.are.same({8, 1}, {box.questId, box.objectiveIndex})
        assert.are.same({true, false}, {box.shown, box.Fill.shown})
        assert.are.same({0, 0, 1, 0.5}, box.Fill.color)
    end)

    it("fits Blizzard's quest marker into the box column only while areas are enabled", function()
        local title = {questID = 7, questLogIndex = 1, Text = {}}
        titles[1], leaderboards[1], markers[7] = title, {}, Marker(20)
        QuestLog.Update()

        -- Centred on the box column, raised above the text; offsets are in the marker's scaled units.
        local marker, scale = markers[7], 16 / 20
        assert.are.equal(scale, marker.scale)
        assert.are.same({"TOPLEFT", title.Text, "TOPLEFT", -19 / scale, 4 / scale}, marker.point)
        assert.are.equal(0.75, marker.Glow.scale)
        -- Selecting a quest restyles its marker without a rebuild, resetting the glow.
        marker.Glow.scale = 1
        assert.are.equal("SUPER_TRACKING_CHANGED", eventFrame.event)
        eventFrame.scripts.OnEvent(eventFrame, "SUPER_TRACKING_CHANGED")
        assert.are.equal(0.75, marker.Glow.scale)

        enabled = false
        QuestLog.Update()
        assert.are.same({1, 1}, {marker.scale, marker.Glow.scale})
        assert.are.same({"TOPLEFT", title, 6, -4}, marker.point)
    end)

    it("toggles the opposite state through the shared area API", function()
        titles[1] = {questID = 7, questLogIndex = 1}
        leaderboards[1] = {{"0/8 Wolf Meat", "item", false}}
        rows[1] = Row(7, "0/8 Wolf Meat")
        objectiveStates["7:1"] = {true, {1, 0, 0}}
        QuestLog.Update()

        local box = rows[1].QuestiePolygonAreaBox
        box.scripts.OnClick(box)

        assert.spy(Polygon.SetObjectiveAreaShown).was.called_with(7, 1, false)
        assert.spy(_G.PlaySound).was.called_with(2)

        -- Shift-click applies the row's new state to the whole quest instead.
        _G.IsShiftKeyDown = function() return true end
        box.scripts.OnClick(box)
        assert.spy(Polygon.SetQuestAreasShown).was.called_with(7, false)
        assert.spy(Polygon.SetObjectiveAreaShown).was.called(1)
    end)

    it("previews the hovered objective and clears that one after a rebuild reuses the row", function()
        titles[1] = {questID = 7, questLogIndex = 1}
        leaderboards[1] = {{"0/8 Wolf Meat", "item", false}, {"0/2 Fang", "item", false}}
        rows[1] = Row(7, "0/8 Wolf Meat")
        objectiveStates["7:1"], objectiveStates["7:2"] = {true, {1, 0, 0}}, {false, {0, 1, 0}}
        QuestLog.Update()
        local box = rows[1].QuestiePolygonAreaBox

        box.scripts.OnEnter(box)
        assert.are.same({{questId = 7, objectiveIndex = 1}}, started)
        assert.are.equal("Click to hide this objective's areas on the map.", tooltip.text)
        assert.are.equal("Shift-click to apply this to the whole quest.", tooltip.hint)

        rows[1].text = "0/2 Fang"
        QuestLog.Update()
        assert.are.equal(2, box.objectiveIndex)
        box.scripts.OnLeave(box)
        assert.are.same({started[1]}, ended)
        assert.is_true(tooltip.hidden)
    end)

    it("ends the preview when the box hides before the cursor leaves it", function()
        titles[1] = {questID = 7, questLogIndex = 1}
        leaderboards[1] = {{"0/8 Wolf Meat", "item", false}}
        rows[1] = Row(7, "0/8 Wolf Meat")
        objectiveStates["7:1"] = {true, {1, 0, 0}}
        QuestLog.Update()
        local box = rows[1].QuestiePolygonAreaBox

        box.scripts.OnEnter(box)
        box.scripts.OnHide(box)
        assert.are.same({started[1]}, ended)
        box.scripts.OnLeave(box)
        assert.are.equal(1, #ended)
    end)
end)
