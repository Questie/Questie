dofile("setupTests.lua")

describe("Forever", function()
    local Forever, QuestieLib
    local saved, entries, titles, objectives, titleCalls, objectiveCalls

    -- The gate prefix that opens a selected fragment.
    local OPEN = "|c00000001|r"

    before_each(function()
        dofile("Localization/l10n.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        saved = {
            C_QuestLog = _G.C_QuestLog, C_Intl = _G.C_Intl,
            C_StringUtil = _G.C_StringUtil, C_CurveUtil = _G.C_CurveUtil, Enum = _G.Enum,
            GetColoredQuestName = QuestieLib.GetColoredQuestName, GetRGBForObjective = QuestieLib.GetRGBForObjective,
            issecretvalue = _G.issecretvalue, issecrettable = _G.issecrettable,
            IsForever = Questie.IsForever, profile = Questie.db.profile, format = string.format,
        }
        Questie.IsForever = true
        Questie.db.profile = {enableTooltipsQuestLevel = true, enableTooltipsQuestID = false}
        _G.issecretvalue, _G.issecrettable = nil, nil
        entries = {{isHeader = true}, {questID = 4402}, {questID = 97279}}
        titles = {[4402] = "|cff00ff00[3+] Apple quest|r", [97279] = "|cffff8000[2] Weapon quest|r"}
        objectives = {
            [4402] = {{text = "3/10 Cactus Apple", numFulfilled = 3, numRequired = 10}},
            [97279] = {{text = "6/6 Training Weapon", numFulfilled = 6, numRequired = 6}},
        }
        objectiveCalls = spy.new(function(id) return objectives[id] end)
        _G.C_QuestLog = {
            GetNumQuestLogEntries = function() return #entries end,
            GetInfo = function(index) return entries[index] end,
            GetQuestObjectives = function(id) return objectiveCalls(id) end,
        }
        titleCalls = spy.new(function(id) return titles[id] or error("Quest missing from database") end)
        QuestieLib.GetColoredQuestName = function(_, id, showLevel, showState)
            assert.are.equal(Questie.db.profile.enableTooltipsQuestLevel, showLevel)
            assert.is_true(showState)
            return titleCalls(id)
        end
        QuestieLib.GetRGBForObjective = function(_, objective)
            if not objective.required then return "|cffeeeeee" end
            if objective.fulfilled == objective.required then return "|cff00ff00" end
            return "|cffff0000"
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
        _G.C_StringUtil, _G.C_CurveUtil, _G.Enum = saved.C_StringUtil, saved.C_CurveUtil, saved.Enum
        QuestieLib.GetColoredQuestName, QuestieLib.GetRGBForObjective = saved.GetColoredQuestName, saved.GetRGBForObjective
        _G.issecretvalue, _G.issecrettable = saved.issecretvalue, saved.issecrettable
        Questie.IsForever, Questie.db.profile, string.format = saved.IsForever, saved.profile, saved.format
    end)

    describe("Title", function()
        it("selects only the matching quest's normal Questie title from overlapping candidates", function()
            local formatter = Forever.CreateFormatter()

            assert.are.equal(OPEN .. "|cff00ff00[3+] Apple quest|r", formatter.Title(4402, "Native apple title"))
            assert.are.equal(OPEN .. "|cffff8000[2] Weapon quest|r", formatter.Title(97279, "Native weapon title"))
        end)

        it("uses Questie's title for a readable ID outside the quest log, such as a party member's quest", function()
            titles[5000] = "|cff21cce7[10] Repeatable party quest|r"
            local formatter = Forever.CreateFormatter()

            assert.are.equal(OPEN .. "|cff21cce7[10] Repeatable party quest|r", formatter.Title(5000, "Native title"))
        end)

        it("keeps Blizzard's title with an unknown marker that honors both display settings", function()
            local formatter = Forever.CreateFormatter()
            assert.are.equal(OPEN .. "[??] Unknown title", formatter.Title(99999, "Unknown title"))

            Questie.db.profile.enableTooltipsQuestID = true
            assert.are.equal(OPEN .. "[??] Unknown title (99999)", formatter.Title(99999, "Unknown title"))
            assert.are.equal("[??] Missing ID (???)", formatter.Title(nil, "Missing ID"))

            Questie.db.profile.enableTooltipsQuestLevel = false
            assert.are.equal(OPEN .. "Unknown title (99999)", formatter.Title(99999, "Unknown title"))
        end)

        it("keeps Blizzard's title for a logged quest missing from Questie's database", function()
            titles[4402] = nil
            local formatter = Forever.CreateFormatter()

            assert.are.equal(OPEN .. "[??] Native apple title", formatter.Title(4402, "Native apple title"))
        end)

        it("deduplicates quest IDs so repeated entries cannot draw duplicate titles", function()
            entries[4] = {questID = 4402}
            local formatter = Forever.CreateFormatter()

            assert.are.equal(OPEN .. "|cff00ff00[3+] Apple quest|r", formatter.Title(4402, "Native title"))
            assert.spy(objectiveCalls).was.called(2)
        end)

        it("does not treat an unavailable native comparison as equality", function()
            _G.C_Intl.CompareStrings = function() end
            local formatter = Forever.CreateFormatter()

            assert.are.equal("[??] Native title", formatter.Title(12345, "Native title"))
        end)

        it("discards a partial selection when a later native helper fails", function()
            local calls = 0
            _G.C_Intl.CompareStrings = function()
                calls = calls + 1
                if calls == 2 then error("Native helper unavailable") end
                return 0
            end
            local formatter = Forever.CreateFormatter()

            assert.are.equal("[??] Native title", formatter.Title(12345, "Native title"))
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
            local formatter = Forever.CreateFormatter()

            assert.are.equal(OPEN .. "|cff00ff00[3+] Apple quest|r", formatter.Title(opaqueID, "Native title"))
            assert.spy(titleCalls).was.called(2)
            assert.spy(titleCalls).was.called_with(4402)
            assert.spy(titleCalls).was.called_with(97279)
            assert.spy(comparison).was.called_with("opaque ID text", "4402", 3)
        end)
    end)

    describe("Objective", function()
        it("renders the selected quest's matching log objective in its progress color", function()
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")
            assert.are.equal(OPEN .. "|cffff0000" .. "3/10 Cactus Apple|r", formatter.Objective("3/10 Cactus Apple"))

            formatter.Title(97279, "Weapon")
            assert.are.equal(OPEN .. "|cff00ff00" .. "6/6 Training Weapon|r", formatter.Objective("6/6 Training Weapon"))
        end)

        it("draws one row when the same objective text repeats within or across quests", function()
            objectives[97279] = {{text = "0/6 Shared Rib", numFulfilled = 0, numRequired = 6}}
            objectives[4402] = {
                {text = "0/6 Shared Rib", numFulfilled = 0, numRequired = 6},
                {text = "0/6 Shared Rib", numFulfilled = 0, numRequired = 6},
            }
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")

            assert.are.equal(OPEN .. "|cffff0000" .. "0/6 Shared Rib|r", formatter.Objective("0/6 Shared Rib"))
        end)

        it("keeps native text when the objective, its title or any title is unknown", function()
            objectives[4402][2] = {text = "Explore the camp", numFulfilled = 0, numRequired = 0}
            local formatter = Forever.CreateFormatter()
            assert.are.equal("Before any title", formatter.Objective("Before any title"))

            formatter.Title(4402, "Apple")
            assert.are.equal(OPEN .. "4/10 Cactus Apple", formatter.Objective("4/10 Cactus Apple"))
            assert.are.equal(OPEN .. "|cffeeeeee" .. "Explore the camp|r", formatter.Objective("Explore the camp"))

            formatter.Title(99999, "Unknown")
            assert.are.equal(OPEN .. "3/10 Cactus Apple", formatter.Objective("3/10 Cactus Apple"))
            formatter.Title(nil, "Missing ID")
            assert.are.equal("3/10 Cactus Apple", formatter.Objective("3/10 Cactus Apple"))
        end)

        it("colors objectives of a logged quest missing from Questie's database", function()
            titles[4402] = nil
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")

            assert.are.equal(OPEN .. "|cffff0000" .. "3/10 Cactus Apple|r", formatter.Objective("3/10 Cactus Apple"))
        end)

        it("passes opaque objective text only to native comparison and the unmatched fragment", function()
            -- Concatenation is allowed on secrets and yields another secret; inspection is not.
            local opaqueText = setmetatable({}, {
                __concat = function() return "secret concatenation" end,
                __tostring = function() error("text inspected") end,
            })
            _G.issecretvalue = function(value) return rawequal(value, opaqueText) end
            local comparison = spy.new(function(left, right)
                if rawequal(left, opaqueText) then
                    if right == "3/10 Cactus Apple" then return 0 end
                    return 1
                end
                if left == right then return 0 end
                return 1
            end)
            _G.C_Intl.CompareStrings = function(...) return comparison(...) end
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")

            assert.are.equal(OPEN .. "|cffff0000" .. "3/10 Cactus Apple|r", formatter.Objective(opaqueText))
            assert.spy(comparison).was.called_with(opaqueText, "3/10 Cactus Apple", 3)
        end)

        it("keeps native text when a native helper fails during objective selection", function()
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")
            _G.C_Intl.CompareStrings = function() error("Native helper unavailable") end

            assert.are.equal("3/10 Cactus Apple", formatter.Objective("3/10 Cactus Apple"))
        end)
    end)

    describe("candidates", function()
        it("builds public candidates once per formatter and picks up changes in a new rebuild", function()
            local formatter = Forever.CreateFormatter()
            objectives[4402] = {{text = "4/10 Cactus Apple", numFulfilled = 4, numRequired = 10}}
            formatter.Title(4402, "Apple")
            assert.are.equal(OPEN .. "4/10 Cactus Apple", formatter.Objective("4/10 Cactus Apple"))
            assert.spy(objectiveCalls).was.called(2)

            local refreshed = Forever.CreateFormatter()
            refreshed.Title(4402, "Apple")
            assert.are.equal(OPEN .. "|cffff0000" .. "4/10 Cactus Apple|r", refreshed.Objective("4/10 Cactus Apple"))
            assert.spy(objectiveCalls).was.called(4)
        end)

        it("skips secret quest-log values without using them in lookups or formatting", function()
            -- Plain values flagged secret: without the guards they would pass the type checks.
            _G.issecretvalue = function(value) return value == 5555 or value == "Secret objective" end
            entries[4] = {questID = 5555}
            objectives[4402] = {
                {text = "Secret objective", numFulfilled = 1, numRequired = 2},
                {text = "3/10 Cactus Apple", numFulfilled = 3, numRequired = 10},
            }
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")

            assert.are.equal(OPEN .. "|cffff0000" .. "3/10 Cactus Apple|r", formatter.Objective("3/10 Cactus Apple"))
            assert.are.equal(OPEN .. "Secret objective", formatter.Objective("Secret objective"))
            assert.spy(titleCalls).was.not_called_with(5555)
            assert.spy(objectiveCalls).was.not_called_with(5555)
        end)

        it("keeps a quest's title when its objective list is unavailable", function()
            -- A flagged-secret ID cannot fall back to a title lookup, so only the candidate can supply the title.
            _G.issecretvalue = function(value) return value == "4402" end
            _G.C_QuestLog.GetQuestObjectives = function(id)
                if id == 4402 then error("Quest data unavailable") end
                return objectives[id]
            end
            local formatter = Forever.CreateFormatter()

            assert.are.equal(OPEN .. "|cff00ff00[3+] Apple quest|r", formatter.Title("4402", "Apple"))
            assert.are.equal(OPEN .. "3/10 Cactus Apple", formatter.Objective("3/10 Cactus Apple"))
            formatter.Title(97279, "Weapon")
            assert.are.equal(OPEN .. "|cff00ff00" .. "6/6 Training Weapon|r", formatter.Objective("6/6 Training Weapon"))
        end)

        it("skips objective work when the Objectives color setting gives every objective the same color", function()
            QuestieLib.GetRGBForObjective = function() return "|cffeeeeee" end
            local formatter = Forever.CreateFormatter()
            formatter.Title(4402, "Apple")

            assert.are.equal("3/10 Cactus Apple", formatter.Objective("3/10 Cactus Apple"))
            assert.spy(objectiveCalls).was.not_called()
        end)

        it("falls back without candidate work when selection is unavailable or the log is empty", function()
            entries = {}
            assert.are.equal("[??] Native title", Forever.CreateFormatter().Title(12345, "Native title"))

            entries = {{questID = 4402}}
            _G.C_Intl = nil
            assert.are.equal("[??] Native title", Forever.CreateFormatter().Title(12345, "Native title"))

            Questie.IsForever = false
            local formatter = Forever.CreateFormatter()
            assert.are.equal("[??] Native title", formatter.Title(12345, "Native title"))
            assert.are.equal("3/10 Cactus Apple", formatter.Objective("3/10 Cactus Apple"))
            assert.spy(objectiveCalls).was.not_called()
        end)
    end)
end)
