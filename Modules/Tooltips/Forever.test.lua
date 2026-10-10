dofile("setupTests.lua")

describe("Forever", function()
    local Forever, QuestieLib
    local saved, entries, levels, levelCalls, colorCalls

    before_each(function()
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        saved = {
            C_QuestLog = _G.C_QuestLog, C_Intl = _G.C_Intl,
            C_StringUtil = _G.C_StringUtil, C_CurveUtil = _G.C_CurveUtil,
            Enum = _G.Enum, CreateColor = _G.CreateColor,
            GetDifficultyColorPercent = QuestieLib.GetDifficultyColorPercent,
            issecretvalue = _G.issecretvalue, issecrettable = _G.issecrettable,
            IsForever = Questie.IsForever, profile = Questie.db.profile, format = string.format,
        }
        Questie.IsForever = true
        Questie.db.profile = {enableTooltipsQuestLevel = true, enableTooltipsQuestID = false}
        _G.issecretvalue, _G.issecrettable = nil, nil
        entries = {{isHeader = true}, {questID = 4402}, {questID = 97279}}
        levels = {[4402] = 3, [97279] = 2}
        levelCalls = spy.new(function(id) return levels[id] end)
        _G.C_QuestLog = {
            GetNumQuestLogEntries = function() return #entries end,
            GetInfo = function(index) return entries[index] end,
            GetQuestDifficultyLevel = function(id) return levelCalls(id) end,
        }
        colorCalls = spy.new(function(_, id)
            if id == 4402 then return 0, 1, 0 end
            return 1, 0.5, 0
        end)
        QuestieLib.GetDifficultyColorPercent = function(_, level, id) return colorCalls(level, id) end
        _G.CreateColor = function(r, g, b)
            return {GenerateHexColorMarkup = function()
                return string.format("|cff%02x%02x%02x", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
            end}
        end
        _G.Enum = {CollationStrength = {Identical = 3}, NormalizationForm = {Nfc = 0}}
        -- Public-value stand-ins test selection/fallback composition. The native secret permissions
        -- and propagation are covered by the live probes recorded in the API audit, not these mocks.
        _G.C_Intl = {
            CompareStrings = function(left, right)
                if left == right then return 0 end
                if left < right then return -1 end
                return 1
            end,
            IsNormalized = function(text) return text == "" end,
        }
        _G.C_StringUtil = {
            TruncateWhenZero = function(value)
                if value == 0 then return "" end
                return tostring(math.floor(value))
            end,
            WrapString = function(infix, prefix, suffix)
                if infix == "" then return "" end
                return prefix .. infix .. suffix
            end,
        }
        _G.C_CurveUtil = {EvaluateColorValueFromBoolean = function(value, ifTrue, ifFalse)
            if value then return ifTrue end
            return ifFalse
        end}
        dofile("Modules/Tooltips/Forever.lua")
        Forever = QuestieLoader:ImportModule("Forever")
    end)

    after_each(function()
        _G.C_QuestLog, _G.C_Intl = saved.C_QuestLog, saved.C_Intl
        _G.C_StringUtil, _G.C_CurveUtil = saved.C_StringUtil, saved.C_CurveUtil
        _G.Enum, _G.CreateColor = saved.Enum, saved.CreateColor
        QuestieLib.GetDifficultyColorPercent = saved.GetDifficultyColorPercent
        _G.issecretvalue, _G.issecrettable = saved.issecretvalue, saved.issecrettable
        Questie.IsForever, Questie.db.profile, string.format = saved.IsForever, saved.profile, saved.format
    end)

    it("selects only the matching level and color from overlapping quest candidates", function()
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r|cff00ff00[3] Native apple title|r", formatTitle(4402, "Native apple title"))
        assert.are.equal("|c00000001|r|cffff8000[2] Native weapon title|r", formatTitle(97279, "Native weapon title"))
    end)

    it("uses Questie's title palette with the public candidate level and quest ID", function()
        QuestieLib.GetDifficultyColorPercent = function(_, level, id)
            colorCalls(level, id)
            return 1, 1, 0
        end
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r|cffffff00[3] Native apple title|r", formatTitle(4402, "Native apple title"))
        assert.spy(colorCalls).was.called_with(3, 4402)
        assert.spy(colorCalls).was.called_with(2, 97279)
    end)

    it("uses an explicit unknown fallback instead of another quest's presentation", function()
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r[??] Unknown native title", formatTitle(99999, "Unknown native title"))
    end)

    it("keeps native wording and displays quest IDs only when enabled", function()
        Questie.db.profile.enableTooltipsQuestID = true
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r|cff00ff00[3] Native title (4402)|r", formatTitle(4402, "Native title"))
        assert.are.equal("|c00000001|r[??] Unknown title (99999)", formatTitle(99999, "Unknown title"))
        assert.are.equal("[??] Missing ID (???)", formatTitle(nil, "Missing ID"))
    end)

    it("honors Show Quest Levels without removing the selected difficulty color", function()
        Questie.db.profile.enableTooltipsQuestLevel = false
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r|cff00ff00Native title|r", formatTitle(4402, "Native title"))
        assert.are.equal("|c00000001|rUnknown title", formatTitle(99999, "Unknown title"))
    end)

    it("builds public candidates once per formatter and picks up changes in a new rebuild", function()
        local formatTitle = Forever.CreateFormatter()
        levels[4402] = 4
        formatTitle(4402, "First title")
        assert.are.equal("|c00000001|r|cff00ff00[3] Second title|r", formatTitle(4402, "Second title"))
        assert.spy(levelCalls).was.called(2)

        local refreshed = Forever.CreateFormatter()
        assert.are.equal("|c00000001|r|cff00ff00[4] Refreshed title|r", refreshed(4402, "Refreshed title"))
        assert.spy(levelCalls).was.called(4)
    end)

    it("deduplicates quest IDs so repeated entries cannot draw duplicate titles", function()
        entries[4] = {questID = 4402}
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r|cff00ff00[3] Native title|r", formatTitle(4402, "Native title"))
        assert.spy(levelCalls).was.called(2)
    end)

    it("skips an unavailable public candidate without losing the other quest", function()
        C_QuestLog.GetQuestDifficultyLevel = function(id)
            if id == 4402 then error("Quest data unavailable") end
            return 2
        end
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r[??] Apple", formatTitle(4402, "Apple"))
        assert.are.equal("|c00000001|r|cffff8000[2] Weapon|r", formatTitle(97279, "Weapon"))
    end)

    it("skips secret candidate IDs and levels without using them in public lookups or formatting", function()
        local secretID, secretLevel = {}, {}
        _G.issecretvalue = function(value) return rawequal(value, secretID) or rawequal(value, secretLevel) end
        entries[4] = {questID = secretID}
        levels[4402] = secretLevel
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r[??] Apple", formatTitle(4402, "Apple"))
        assert.are.equal("|c00000001|r|cffff8000[2] Weapon|r", formatTitle(97279, "Weapon"))
        assert.spy(levelCalls).was.called_with(4402)
        assert.spy(levelCalls).was.called_with(97279)
        assert.spy(levelCalls).was.called(2)
    end)

    it("falls back with no usable candidates and retries the public data in a new rebuild", function()
        levels = {}
        local formatTitle = Forever.CreateFormatter()
        levels[4402] = 3

        assert.are.equal("[??] Apple", formatTitle(4402, "Apple"))
        local refreshed = Forever.CreateFormatter()
        assert.are.equal("|c00000001|r|cff00ff00[3] Apple|r", refreshed(4402, "Apple"))
    end)

    it("does not treat an unavailable native comparison as equality", function()
        _G.C_Intl.CompareStrings = function() end
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("[??] Native title", formatTitle(4402, "Native title"))
    end)

    it("discards a partial selection when a later native helper fails", function()
        local calls = 0
        _G.C_Intl.CompareStrings = function()
            calls = calls + 1
            if calls == 2 then error("Native helper unavailable") end
            return 0
        end
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("[??] Native title", formatTitle(4402, "Native title"))
    end)

    it("falls back without lookups when selection APIs are missing", function()
        _G.C_Intl = nil
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("[??] Native title", formatTitle(4402, "Native title"))
        assert.spy(levelCalls).was.not_called()
    end)

    it("does no candidate work on non-Forever clients", function()
        Questie.IsForever = false
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("[??] Native title", formatTitle(4402, "Native title"))
        assert.spy(levelCalls).was.not_called()
    end)

    it("passes an opaque ID to native comparison without using it in a quest lookup", function()
        local opaqueID = setmetatable({}, {__tostring = function() error("ID inspected") end})
        _G.issecretvalue = function(value) return rawequal(value, opaqueID) end
        local nativeFormat = string.format
        string.format = function(format, ...)
            local value = ...
            if format == "%d" and rawequal(value, opaqueID) then return "opaque ID text" end
            return nativeFormat(format, ...)
        end
        local comparison = spy.new(function(left, right)
            if left == "opaque ID text" and right == "4402" then return 0 end
            return 1
        end)
        _G.C_Intl.CompareStrings = function(...) return comparison(...) end
        local formatTitle = Forever.CreateFormatter()

        assert.are.equal("|c00000001|r|cff00ff00[3] Native title|r", formatTitle(opaqueID, "Native title"))
        assert.spy(levelCalls).was.called_with(4402)
        assert.spy(levelCalls).was.called_with(97279)
        assert.spy(levelCalls).was.called(2)
        assert.spy(comparison).was.called_with("opaque ID text", "4402", 3)
    end)
end)
