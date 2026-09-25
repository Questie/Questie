dofile("setupTests.lua")

describe("BlobWorldMap", function()
    local module, map, canvas, blob, provider, saved, frameCount
    local globals = {"GetBuildInfo", "WorldMapFrame", "MapCanvasDataProviderMixin", "CreateFromMixins",
        "CreateFrame", "C_QuestLog", "SlashCmdList", "SLASH_QUESTIEBLOBMAP1"}

    local function DrawPending()
        local callback = blob.scripts.OnUpdate
        if callback then callback(blob) end
    end

    before_each(function()
        saved = {}
        for _, name in ipairs(globals) do saved[name] = _G[name] end
        _G.GetBuildInfo = function() return "1.60.1", "69977", "", 16001 end
        _G.SlashCmdList = {}
        _G.CreateFromMixins = function(...)
            local object = {}
            for i = 1, select("#", ...) do
                for key, value in pairs(select(i, ...)) do object[key] = value end
            end
            return object
        end
        _G.MapCanvasDataProviderMixin = {
            OnAdded = function(self, owner) self.owningMap = owner end,
            OnRemoved = function(self) self.owningMap = nil end,
            GetMap = function(self) return self.owningMap end,
        }
        local quests = {{isHeader = true}, {questID = 7}, {questID = 33}}
        _G.C_QuestLog = {
            GetNumQuestLogEntries = function() return #quests end,
            GetInfo = function(i) return quests[i] end,
            GetLogIndexForQuestID = function(id) return ({[7] = 2, [33] = 3})[id] end,
        }
        canvas, frameCount = {}, 0
        map = {
            shown = true, mapID = 1429, width = 1002, height = 668,
            adds = 0, removes = 0,
            GetCanvas = function() return canvas end,
            GetMapID = function(self) return self.mapID end,
            IsShown = function(self) return self.shown end,
            DenormalizeHorizontalSize = function(self, size) return self.width * size end,
            DenormalizeVerticalSize = function(self, size) return self.height * size end,
            GetPinFrameLevelsManager = function()
                return {GetValidFrameLevel = function(_, kind)
                    assert.are.equal("PIN_FRAME_LEVEL_QUEST_BLOB", kind)
                    return 123
                end}
            end,
            AddDataProvider = function(self, added)
                self.adds, provider = self.adds + 1, added
                added:OnAdded(self)
            end,
            RemoveDataProvider = function(self, removed)
                self.removes = self.removes + 1
                removed:RemoveAllData()
                removed:OnRemoved(self)
            end,
            AddDataProviderEvent = function() error("Do not own shared map event counts") end,
            UnregisterEvent = function() error("Do not unregister another provider's events") end,
        }
        _G.WorldMapFrame = map
        _G.CreateFrame = function(kind, name, parent)
            assert.are.equal("QuestPOIFrame", kind)
            assert.is_nil(name)
            assert.are.equal(canvas, parent)
            frameCount = frameCount + 1
            blob = {
                scripts = {}, events = {}, shown = true,
                Hide = function(self) self.shown = false end,
                Show = function(self) self.shown = true end,
                SetPoint = function(self, ...) self.point = {...} end,
                SetFillTexture = function() end, SetBorderTexture = function() end,
                SetFillAlpha = function() end, SetBorderAlpha = function() end, SetBorderScalar = function() end,
                SetFrameLevel = function(self, level) self.level = level end,
                EnableMouse = function(self, enabled) self.mouseEnabled = enabled end,
                SetMapID = function(self, id) self.mapID = id end,
                SetSize = function(self, width, height) self.width, self.height = width, height end,
                SetScript = function(self, event, callback) self.scripts[event] = callback end,
                RegisterEvent = function(self, event) self.events[event] = true end,
                UnregisterAllEvents = function(self) self.events = {} end,
                DrawNone = spy.new(function() end),
                DrawBlob = spy.new(function() end),
                UpdateMouseOverTooltip = function() error("This prototype does not hit-test or handle hover") end,
            }
            return blob
        end
        dofile("Blob/BlobWorldMap.lua")
        module = QuestieLoader:ImportModule("BlobWorldMap")
    end)

    after_each(function()
        for _, name in ipairs(globals) do _G[name] = saved[name] end
    end)

    it("draws loaded quests on the full map canvas without mouse handlers or idle polling", function()
        assert.is_true(module.Enable())
        assert.are.same({"CENTER", canvas, "CENTER"}, blob.point)
        assert.are.equal(1429, blob.mapID)
        assert.are.equal(1002, blob.width)
        assert.are.equal(668, blob.height)
        assert.are.equal(123, blob.level)
        assert.is_false(blob.mouseEnabled)
        assert.is_nil(blob.scripts.OnEnter)
        assert.is_nil(blob.scripts.OnMouseDown)
        assert.spy(blob.DrawBlob).was.not_called()
        DrawPending()
        assert.spy(blob.DrawBlob).was.called_with(blob, 7, true)
        assert.spy(blob.DrawBlob).was.called_with(blob, 33, true)
        assert.spy(blob.DrawBlob).was.called(2)
        assert.is_nil(blob.scripts.OnUpdate)
    end)

    it("changes the selected quest without adding another provider", function()
        module.Enable(33)
        module.Enable(7)
        DrawPending()
        assert.are.equal(1, map.adds)
        assert.spy(blob.DrawBlob).was.called_with(blob, 7, true)
        assert.spy(blob.DrawBlob).was.called(1)
    end)

    it("redraws with the current map and canvas dimensions after map/size/zoom changes", function()
        module.Enable(7)
        map.mapID, map.width, map.height = 1436, 1200, 700
        provider:OnMapChanged()
        provider:OnCanvasSizeChanged()
        provider:OnCanvasScaleChanged()
        DrawPending()
        assert.are.equal(1436, blob.mapID)
        assert.are.equal(1200, blob.width)
        assert.are.equal(700, blob.height)
        assert.spy(blob.DrawBlob).was.called(1)
    end)

    it("waits while the map is hidden and redraws on reopen", function()
        map.shown = false
        module.Enable(7)
        assert.is_false(blob.shown)
        assert.is_nil(blob.scripts.OnUpdate)
        map.shown = true
        provider:OnShow()
        DrawPending()
        assert.spy(blob.DrawBlob).was.called(1)
        map.shown = false
        provider:OnHide()
        blob.scripts.OnEvent(blob, "QUEST_POI_UPDATE")
        assert.is_nil(blob.scripts.OnUpdate)
        assert.is_false(blob.shown)
        map.shown = true
        provider:OnShow()
        DrawPending()
        assert.spy(blob.DrawBlob).was.called(2)
    end)

    it("clears the selected quest when it leaves the quest log", function()
        module.Enable(7)
        DrawPending()
        blob.DrawBlob:clear()
        blob.DrawNone:clear()
        _G.C_QuestLog.GetLogIndexForQuestID = function() return nil end
        blob.scripts.OnEvent(blob, "QUEST_LOG_UPDATE")
        DrawPending()
        assert.spy(blob.DrawNone).was.called()
        assert.spy(blob.DrawBlob).was.not_called()
    end)

    it("disabling cancels pending drawing and releases only its own events", function()
        module.Enable(7)
        module.Disable()
        module.Disable()
        assert.are.equal(1, map.removes)
        assert.is_nil(provider:GetMap())
        assert.is_nil(blob.scripts.OnUpdate)
        assert.is_nil(blob.scripts.OnEvent)
        assert.are.same({}, blob.events)
        assert.is_false(blob.shown)
        assert.spy(blob.DrawBlob).was.not_called()
    end)

    it("reuses its native frame after disable and enable", function()
        module.Enable(7)
        module.Disable()
        module.Enable(33)
        DrawPending()
        assert.are.equal(1, frameCount)
        assert.are.equal(2, map.adds)
        assert.is_true(blob.events.QUEST_POI_UPDATE)
        assert.spy(blob.DrawBlob).was.called_with(blob, 33, true)
    end)

    it("rejects unavailable quests before creating a provider", function()
        local ok, err = module.Enable(9999)
        assert.is_false(ok)
        assert.is_string(err)
        assert.are.equal(0, frameCount)
        assert.are.equal(0, map.adds)
    end)
end)
