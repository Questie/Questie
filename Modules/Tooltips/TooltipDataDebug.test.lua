dofile("setupTests.lua")

describe("TooltipDataDebug", function()
    local TooltipDataDebug
    local originals, callbacks, frames, paintedText, registration
    local globals = {
        "CreateFrame", "TooltipDataProcessor", "Enum", "GameTooltip", "issecretvalue", "issecrettable", "canaccesstable",
        "SlashCmdList", "SLASH_QUESTIETOOLTIPDATA1",
    }

    before_each(function()
        originals = {}
        for _, name in ipairs(globals) do originals[name] = _G[name] end
        _G.issecretvalue, _G.issecrettable, _G.canaccesstable = nil, nil, nil
        _G.Enum = {TooltipDataLineType = {QuestTitle = 1, QuestObjective = 2, QuestPlayer = 3}}
        _G.GameTooltip = {IsForbidden = function() return false end}
        _G.SlashCmdList = {}
        callbacks, frames, paintedText = {}, {}, nil
        registration = spy.new(function(kind, callback) callbacks[kind] = callback end)
        _G.TooltipDataProcessor = {
            AddLinePreCall = function(kind, callback) registration(kind, callback) end,
        }
        _G.CreateFrame = function(_, _, _, template)
            local frame = {scripts = {}, shown = false, template = template}
            local function noop() end
            for _, method in ipairs({
                "SetSize", "SetPoint", "SetFrameStrata", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag",
                "StartMoving", "StopMovingOrSizing", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
                "SetScrollChild", "SetHeight", "SetVerticalScroll",
            }) do frame[method] = noop end
            function frame:SetScript(name, callback) self.scripts[name] = callback end
            function frame:SetText(text) self.text = text end
            function frame:Show() self.shown = true end
            function frame:Hide() self.shown = false end
            function frame:IsShown() return self.shown end
            function frame:CreateFontString()
                return {
                    SetPoint = noop, SetWidth = noop, SetJustifyH = noop, SetJustifyV = noop, SetWordWrap = noop,
                    SetText = function(_, text) paintedText = text end,
                    GetStringHeight = function() return 100 end,
                }
            end
            frames[#frames + 1] = frame
            return frame
        end
        dofile("Modules/Tooltips/TooltipDataDebug.lua")
        TooltipDataDebug = QuestieLoader:ImportModule("TooltipDataDebug")
    end)

    after_each(function()
        for _, name in ipairs(globals) do _G[name] = originals[name] end
    end)

    it("shows public fields, false values and literal markup without modifying the payload", function()
        local line = {questID = 42, leftText = "|cffff0000Quest|r", completed = false}
        local data = {type = 2, lines = {line}}

        local text = TooltipDataDebug.FormatSnapshot(data, "QuestObjective", line)

        assert.is_truthy(text:find('["questID"] = 42', 1, true))
        assert.is_truthy(text:find('["completed"] = false', 1, true))
        assert.is_truthy(text:find('"||cffff0000Quest||r"', 1, true))
        assert.is_truthy(text:find("<already shown>", 1, true))
        assert.are.same({questID = 42, leftText = "|cffff0000Quest|r", completed = false}, line)
    end)

    it("labels secret values and keys without indexing, comparing or stringifying them", function()
        local secret = setmetatable({}, {
            __index = function() error("secret indexed") end,
            __tostring = function() error("secret stringified") end,
            __eq = function() error("secret compared") end,
        })
        _G.issecretvalue = function(value) return rawequal(value, secret) end

        local text = TooltipDataDebug.FormatSnapshot({[secret] = secret, leftText = secret}, "QuestTitle", secret)

        assert.is_truthy(text:find("lineData = secret", 1, true))
        assert.is_truthy(text:find('["leftText"] = secret', 1, true))
        assert.is_truthy(text:find("[secret] = secret", 1, true))
    end)

    it("does not enumerate a table marked secret or inaccessible", function()
        local restricted = {mustNotAppear = "hidden"}
        _G.issecrettable = function(value) return value == restricted end
        local secretText = TooltipDataDebug.FormatSnapshot(restricted, "QuestTitle", {})
        _G.issecrettable = nil
        _G.canaccesstable = function(value) return value ~= restricted end
        local inaccessibleText = TooltipDataDebug.FormatSnapshot(restricted, "QuestTitle", {})

        assert.is_truthy(secretText:find("tooltipData = secret (restricted table)", 1, true))
        assert.is_truthy(inaccessibleText:find("tooltipData = secret (restricted table)", 1, true))
        assert.is_nil(secretText:find("mustNotAppear", 1, true))
        assert.is_nil(inaccessibleText:find("mustNotAppear", 1, true))
    end)

    it("bounds cyclic, deep and large payloads", function()
        local data = {longText = string.rep("x", 1000)}
        data.self = data
        data.nested = {a = {b = {c = {d = {e = {f = "too deep"}}}}}}
        local text = TooltipDataDebug.FormatSnapshot(data, "QuestTitle", {})
        local large = {}
        for id = 1, 500 do large[id] = id end
        local largeText = TooltipDataDebug.FormatSnapshot(large, "QuestTitle", {})

        assert.is_truthy(text:find("<already shown>", 1, true))
        assert.is_truthy(text:find("<table: depth limit>", 1, true))
        assert.is_nil(text:find(string.rep("x", 401), 1, true))
        assert.is_truthy(largeText:find("<field limit reached>", 1, true))
        assert.is_true(#largeText < 15000)
    end)

    it("starts hidden and does not inspect payloads until explicitly opened", function()
        TooltipDataDebug.Initialize()
        local formatter = spy.new(TooltipDataDebug.FormatSnapshot)
        TooltipDataDebug.FormatSnapshot = formatter
        assert.is_false(frames[1]:IsShown())
        assert.is_false(callbacks[1](GameTooltip, {leftText = "Not captured"}))
        assert.spy(formatter).was.not_called()

        SlashCmdList.QUESTIETOOLTIPDATA()
        assert.is_true(frames[1]:IsShown())
        assert.is_false(callbacks[1](GameTooltip, {leftText = "Captured"}))
        assert.spy(formatter).was.called(1)
        frames[1].scripts.OnUpdate()
        assert.is_truthy(paintedText:find("Captured", 1, true))
        assert.is_nil(paintedText:find("Not captured", 1, true))
    end)

    it("never suppresses lines and paints only a sanitized snapshot after the callback", function()
        TooltipDataDebug.Initialize()
        SlashCmdList.QUESTIETOOLTIPDATA()
        frames[1].scripts.OnUpdate()
        local line = {questID = 42, leftText = "Original"}
        GameTooltip.processingInfo = {tooltipData = {type = 2, lines = {line}}}

        assert.is_false(callbacks[2](GameTooltip, line))
        line.leftText = "Changed after callback"
        frames[1].scripts.OnUpdate()

        assert.is_truthy(paintedText:find("Original", 1, true))
        assert.is_nil(paintedText:find("Changed after callback", 1, true))
        assert.is_truthy(paintedText:find("Observed: QuestObjective", 1, true))
        assert.is_false(callbacks[1](GameTooltip, line))
        assert.is_false(callbacks[3](GameTooltip, line))
    end)

    it("keeps the snapshot when paused or closed and ignores other tooltip frames", function()
        TooltipDataDebug.Initialize()
        SlashCmdList.QUESTIETOOLTIPDATA()
        frames[1].scripts.OnUpdate()
        local originalText = paintedText
        local pause = frames[3]
        pause.scripts.OnClick()
        assert.are.equal("Resume", pause.text)
        assert.is_false(callbacks[1](GameTooltip, {questID = 42}))
        frames[1].scripts.OnUpdate()
        assert.are.equal(originalText, paintedText)

        pause.scripts.OnClick()
        SlashCmdList.QUESTIETOOLTIPDATA()
        assert.is_false(frames[1]:IsShown())
        assert.is_false(callbacks[1](GameTooltip, {questID = 43}))
        SlashCmdList.QUESTIETOOLTIPDATA()
        assert.is_true(frames[1]:IsShown())
        assert.is_false(callbacks[1]({}, {questID = 44}))
        frames[1].scripts.OnUpdate()
        assert.are.equal(originalText, paintedText)
    end)

    it("contains inspection errors and leaves forbidden tooltips untouched", function()
        TooltipDataDebug.Initialize()
        SlashCmdList.QUESTIETOOLTIPDATA()
        GameTooltip.processingInfo = setmetatable({}, {__index = function() error("unreadable") end})

        assert.is_false(callbacks[1](GameTooltip, {}))
        frames[1].scripts.OnUpdate()
        assert.are.equal("Tooltip inspection unavailable (restricted or unreadable data).", paintedText)
        GameTooltip.IsForbidden = function() return true end
        assert.is_false(callbacks[1](GameTooltip, {}))
    end)

    it("does not register twice and does nothing on clients without line pre-calls", function()
        TooltipDataDebug.Initialize()
        TooltipDataDebug.Initialize()
        assert.spy(registration).was.called(3)
        assert.are.equal(5, #frames)

        dofile("Modules/Tooltips/TooltipDataDebug.lua")
        _G.TooltipDataProcessor = nil
        TooltipDataDebug.Initialize()
        assert.are.equal(5, #frames)
    end)
end)
