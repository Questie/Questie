dofile("setupTests.lua")

describe("BlobHitscanUI lifecycle", function()
    local UI, panel, blob, now, saved, inputs, clockStep
    local buttons, labels, textures, errors, lines, extractor, originalNew
    local names = {"GetBuildInfo", "CreateFrame", "GetTimePreciseSec", "InCombatLockdown", "C_QuestLog",
        "C_Map", "C_SuperTrack", "GetQuestPOIBlobCount", "SlashCmdList", "SLASH_QUESTIEBLOBHITSCAN1", "geterrorhandler"}

    -- Minimal frame mechanics: scripts/text/visibility are real state; drawing is recorded, not simulated.
    local function Frame(kind)
        local frame = {scripts = {}, text = "", shown = true}
        for _, name in ipairs({"SetSize", "SetPoint", "SetFrameStrata", "EnableMouse", "SetMovable", "RegisterForDrag",
            "SetAllPoints", "SetColorTexture", "SetClipsChildren", "SetFillTexture", "SetBorderTexture", "SetFillAlpha",
            "SetBorderAlpha", "SetBorderScalar", "SetFrameLevel", "SetJustifyH", "SetWidth", "SetAutoFocus", "ClearAllPoints",
            "RegisterEvent", "UnregisterAllEvents", "StopMovingOrSizing", "StartMoving", "SetMapID", "ClearFocus", "SetThickness"}) do
            frame[name] = function() end
        end
        frame.SetSize = function(self, width, height) self.width, self.height = width, height end
        frame.GetWidth = function(self) return self.width end
        frame.GetHeight = function(self) return self.height end
        frame.SetEnabled = function(self, enabled) self.enabled = enabled end
        frame.SetStartPoint = function(self, ...) self.startPoint = {...} end
        frame.SetEndPoint = function(self, ...) self.endPoint = {...} end
        frame.SetScript = function(self, event, callback) self.scripts[event] = callback end
        frame.Hide = function(self)
            self.shown = false
            if self.scripts.OnHide then self.scripts.OnHide(self) end
        end
        frame.Show = function(self) self.shown = true end
        frame.SetText = function(self, text)
            self.text = text
            if kind == "Button" then buttons[text] = self end
            if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
        end
        frame.GetText = function(self) return self.text end
        frame.GetFrameLevel = function() return 1 end
        frame.IsMouseOver = function() return false end
        frame.CreateTexture = function() return Frame("Texture") end
        frame.CreateLine = function() return Frame("Line") end
        frame.CreateFontString = function() return Frame("FontString") end
        frame.DrawNone = spy.new(function() end)
        frame.DrawBlob = spy.new(function() end)
        if kind == "QuestPOIFrame" then
            blob = frame
            frame.UpdateMouseOverTooltip = function() return 7, 1 end
            frame.GetTooltipIndex = function() return 0 end
        end
        if kind == "Line" then lines[#lines + 1] = frame end
        if kind == "FontString" then labels[#labels + 1] = frame end
        if kind == "Texture" then textures[#textures + 1] = frame end
        if kind == "EditBox" then inputs[#inputs + 1] = frame end
        return frame
    end

    local function AdvanceFrames(count)
        for _ = 1, count do
            now = now + 0.2
            panel.scripts.OnUpdate()
        end
    end

    local function StubContours(contours, vertices)
        -- Geometry belongs to the extractor; these fixtures exercise only UI rendering and lifecycle.
        extractor.New = function()
            return {
                status = "running", phase = "assembly", queries = 20, vertices = vertices,
                activeSeconds = 0.001, wallSeconds = 0.2, maxSliceSeconds = 0.001,
                Step = function(self) self.status, self.contours = "complete", contours end,
                Cancel = function(self) if self.status == "running" then self.status = "cancelled" end end,
            }
        end
    end

    before_each(function()
        saved = {}
        for _, name in ipairs(names) do saved[name] = _G[name] end
        now, panel, blob, inputs = 0, nil, nil, {}
        clockStep = 0
        buttons, labels, textures, lines = {}, {}, {}, {}
        errors = spy.new(function() end)
        _G.geterrorhandler = function() return errors end
        _G.GetBuildInfo = function() return "1.60.1", "69977", "", 16001 end
        _G.GetTimePreciseSec = function()
            local value = now
            now = now + clockStep
            return value
        end
        _G.InCombatLockdown = function() return false end
        _G.CreateFrame = function(kind)
            local frame = Frame(kind)
            if not panel then panel = frame end
            return frame
        end
        _G.C_QuestLog = {GetLogIndexForQuestID = function() return 2 end}
        _G.C_Map = {GetMapInfo = function() return {} end, GetBestMapForUnit = function() return 1429 end}
        _G.C_SuperTrack = {GetSuperTrackedQuestID = function() return 7 end}
        _G.GetQuestPOIBlobCount = function() return 1 end
        _G.SlashCmdList = {}
        dofile("Blob/BlobHitscan.lua")
        dofile("Blob/BlobExtractor.lua")
        extractor = QuestieLoader:ImportModule("BlobExtractor")
        originalNew = extractor.New
        dofile("Blob/BlobHitscanUI.lua")
        UI = QuestieLoader:ImportModule("BlobHitscanUI")
    end)

    after_each(function()
        extractor.New = originalNew
        for _, name in ipairs(names) do _G[name] = saved[name] end
    end)

    it("closing during layout cancels the job and prevents delayed drawing", function()
        UI.Show()
        UI.Start()
        local job = UI.job
        assert.are.equal("running", job.status)
        panel:Hide()
        assert.are.equal("cancelled", job.status)
        assert.is_nil(panel.scripts.OnUpdate)
        assert.spy(blob.DrawBlob).was.not_called()
        assert.is_false(blob.shown)
        UI.Show()
        assert.matches("Preview closed. Press Hitscan", labels[2]:GetText(), 1, true)
        assert.is_false(blob.shown)
    end)

    it("does not cancel a new job on a delayed notification for the same input text", function()
        UI.Show()
        UI.Start()
        local job = UI.job
        inputs[1].scripts.OnTextChanged(inputs[1])
        assert.are.equal(job, UI.job)
        assert.are.equal("running", job.status)
    end)

    it("changing the selected quest cancels the old job and invalidates its display", function()
        UI.Show()
        UI.Start()
        local previous = UI.job
        UI.Show(33)
        assert.are.equal("cancelled", previous.status)
        assert.is_nil(UI.job)
        assert.are.equal("33", inputs[1]:GetText())
    end)

    it("a restart cancels the old job before preparing the replacement", function()
        UI.Show()
        UI.Start()
        local previous = UI.job
        UI.Start()
        assert.are.equal("cancelled", previous.status)
        assert.are_not.equal(previous, UI.job)
        assert.are.equal("running", UI.job.status)
    end)

    it("moving the panel cancels work based on the old frame geometry", function()
        UI.Show()
        UI.Start()
        panel.scripts.OnDragStart()
        assert.are.equal("cancelled", UI.job.status)
        now = 1
        panel.scripts.OnUpdate()
        assert.spy(blob.DrawBlob).was.not_called()
    end)

    it("Hitscan resumes sampling after the update error handler stops a failed scan", function()
        UI.Show()
        inputs[4]:SetText("10")
        UI.Start()
        blob.UpdateMouseOverTooltip = function() error("native probe failure", 0) end
        AdvanceFrames(5) -- Layout, settling, then the first sampling frame.
        assert.is_nil(panel.scripts.OnUpdate)
        assert.are.equal("cancelled", UI.job.status)
        assert.spy(errors).was.called_with("native probe failure")

        blob.UpdateMouseOverTooltip = function() return 7, 1 end
        buttons.Hitscan.scripts.OnClick()
        assert.are.equal("function", type(panel.scripts.OnUpdate))
        AdvanceFrames(5)
        assert.are.equal("complete", UI.job.status)
        assert.are.equal(121, UI.job.samples)
        assert.are.equal(121, UI.job.matchedSamples)
        assert.spy(errors).was.called(1)
    end)

    it("reports cancellation during fitting without changing completed sampling results", function()
        UI.Show()
        inputs[4]:SetText("10")
        UI.Start()
        AdvanceFrames(5) -- Sampling is complete; fit layout has not finished.
        assert.are.equal("complete", UI.job.status)

        buttons.Cancel.scripts.OnClick()
        local status = labels[2]:GetText()
        assert.matches("cancelled during fit layout", status, 1, true)
        assert.matches("plot incomplete", status, 1, true)
        assert.matches("0 squares", status, 1, true)
        assert.are.equal("complete", UI.job.status)
        local textureCount = #textures
        AdvanceFrames(6)
        assert.are.equal(textureCount, #textures)
        assert.are.equal(status, labels[2]:GetText())
    end)

    it("stops partial plotting and reports the plotted square count when cancelled", function()
        UI.Show()
        inputs[4]:SetText("20")
        UI.Start()
        AdvanceFrames(10) -- Sampling/fit waits, followed by the first 128-square plot batch.
        assert.are.equal("complete", UI.job.status)
        assert.are.equal(441, UI.job.matchedSamples)
        assert.matches("128 squares", labels[2]:GetText(), 1, true)

        buttons.Cancel.scripts.OnClick()
        local status = labels[2]:GetText()
        assert.matches("cancelled during plotting", status, 1, true)
        assert.matches("plot incomplete", status, 1, true)
        assert.matches("128 squares", status, 1, true)
        local textureCount = #textures
        AdvanceFrames(4)
        assert.are.equal(textureCount, #textures)
        assert.are.equal(status, labels[2]:GetText())
        assert.are.equal("complete", UI.job.status)
    end)

    it("switching modes cancels stale work and remembers each mode's resolution", function()
        UI.Show()
        inputs[4]:SetText("120")
        UI.Start()
        local old = UI.job

        buttons.Outline.scripts.OnClick()

        assert.are.equal("cancelled", old.status)
        assert.is_nil(UI.job)
        assert.are.equal("outline", UI.mode)
        assert.are.equal("512", inputs[4]:GetText())
        assert.is_false(buttons.Outline.enabled)
        assert.matches("Boundary cells", inputs[4].caption:GetText(), 1, true)
        inputs[4]:SetText("1024")
        buttons["Grid hits"].scripts.OnClick()
        assert.are.equal("120", inputs[4]:GetText())
        buttons.Outline.scripts.OnClick()
        assert.are.equal("1024", inputs[4]:GetText())
    end)

    it("outline membership preserves native index zero and quest isolation", function()
        UI.Show()
        UI.SetMode("outline")
        inputs[3]:SetText("0")
        UI.Start()
        assert.is_true(UI.job.contains(0.5, 0.5))

        blob.GetTooltipIndex = function() return 1 end
        assert.is_false(UI.job.contains(0.5, 0.5))
        blob.UpdateMouseOverTooltip = function() return 33, 1 end
        blob.GetTooltipIndex = function() error("Wrong quest's indices must not be read") end
        assert.is_false(UI.job.contains(0.5, 0.5))
    end)

    it("draws every ring's closing segment and hides all outline elements on a mode switch", function()
        local contours = {
            {{0.4, 0.4}, {0.6, 0.4}, {0.6, 0.6}, {0.4, 0.6}},
            {{0.45, 0.45}, {0.55, 0.45}, {0.55, 0.55}, {0.45, 0.55}},
        }
        StubContours(contours, 8)
        UI.Show()
        UI.SetMode("outline")
        UI.Start()
        AdvanceFrames(11) -- Adds a bounded bounds pass before the existing fit/plot phases.

        assert.are.equal(8, #lines)
        assert.are.same({"TOPLEFT", blob, 0.4 * blob:GetWidth(), -0.4 * blob:GetHeight()}, lines[4].endPoint)
        assert.are.same({"TOPLEFT", blob, 0.45 * blob:GetWidth(), -0.45 * blob:GetHeight()}, lines[8].endPoint)
        assert.matches("2 rings | 8 vertices | 8 segments drawn", labels[2]:GetText(), 1, true)

        buttons["Grid hits"].scripts.OnClick()
        for _, line in ipairs(lines) do assert.is_false(line.shown) end
        for i = 2, #textures do assert.is_false(textures[i].shown) end -- Background remains visible.
        assert.is_nil(UI.job)
    end)

    it("budgets outline bounds across frames and cancels before any plotting", function()
        local ring = {}
        for i = 1, 129 do ring[i] = {0.4 + i / 10000, 0.5} end
        StubContours({ring}, 129)
        UI.Show()
        UI.SetMode("outline")
        UI.Start()
        AdvanceFrames(6) -- Only 128 of 129 bounds points fit in the first bounds batch.
        assert.matches("Outline: bounds", labels[2]:GetText(), 1, true)
        assert.are.equal(0, #lines)
        buttons.Cancel.scripts.OnClick()
        AdvanceFrames(10)
        assert.matches("cancelled during bounds", labels[2]:GetText(), 1, true)
        assert.are.equal(0, #lines)
    end)

    it("caps the outline pool and reuses it for a shorter following result", function()
        local ring = {}
        for i = 1, 4100 do
            local angle = i / 4100 * math.pi * 2
            ring[i] = {0.5 + 0.1 * math.cos(angle), 0.5 + 0.1 * math.sin(angle)}
        end
        StubContours({ring}, 4100)
        UI.Show()
        UI.SetMode("outline")
        UI.Start()
        AdvanceFrames(90)
        assert.are.equal(4096, #lines)
        assert.matches("Preview capped at 4,096 segments", labels[2]:GetText(), 1, true)
        local textureCount = #textures
        StubContours({{{0.4, 0.4}, {0.6, 0.4}, {0.6, 0.6}, {0.4, 0.6}}}, 4)
        UI.Start()
        AdvanceFrames(11)
        assert.are.equal(4096, #lines)
        assert.are.equal(textureCount, #textures)
        assert.is_true(lines[4].shown)
        assert.is_false(lines[5].shown)
        assert.is_false(lines[4096].shown)
        assert.matches("4 segments drawn", labels[2]:GetText(), 1, true)
    end)

    it("uses the elapsed-time cutoff before the outline work cap", function()
        local ring = {}
        for i = 1, 64 do ring[i] = {0.4 + i / 10000, 0.5} end
        StubContours({ring}, 64)
        UI.Show()
        UI.SetMode("outline")
        UI.Start()
        AdvanceFrames(5)
        clockStep = 0.0004
        AdvanceFrames(1)
        assert.matches("Outline: bounds", labels[2]:GetText(), 1, true)
        assert.are.equal(0, #lines)
        clockStep = 0
        AdvanceFrames(1)
        assert.matches("Outline: fit layout", labels[2]:GetText(), 1, true)
    end)

    it("reports extractor errors instead of remaining in the scanning phase", function()
        UI.Show()
        UI.SetMode("outline")
        UI.Start()
        AdvanceFrames(5) -- The mock hits the map boundary, which the extractor explicitly rejects.
        assert.are.equal("error", UI.job.status)
        assert.matches("Geometry touches the map bounds", labels[2]:GetText(), 1, true)
        assert.are.equal(0, #lines)
        assert.spy(errors).was.not_called()
    end)

    it("rejects negative objective indices in outline mode before starting work", function()
        UI.Show()
        UI.SetMode("outline")
        inputs[3]:SetText("-1")
        UI.Start()
        assert.is_nil(UI.job)
        assert.matches("nonnegative integer native index", labels[2]:GetText(), 1, true)
    end)

    it("quest data changes cancel the in-flight snapshot", function()
        UI.Show()
        UI.Start()
        panel.scripts.OnEvent(panel, "QUEST_POI_UPDATE")
        assert.are.equal("cancelled", UI.job.status)
        now = 1
        panel.scripts.OnUpdate()
        assert.spy(blob.DrawBlob).was.not_called()
    end)
end)
