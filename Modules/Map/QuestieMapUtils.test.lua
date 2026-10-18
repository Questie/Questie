dofile("setupTests.lua")
local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("QuestieMapUtils", function()
    ---@type QuestieMap
    local QuestieMap

    before_each(function()
        LoadQuestieDBMock()
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        dofile("Modules/Map/QuestieMapUtils.lua")
    end)

    describe("SetDrawOrder", function()
        local function CreateMockFrame()
            return {
                data = nil,
                isManualIcon = false,
                SetFixedFrameLevel = function() end,
                SetFrameLevel = function() end,
            }
        end

        ---@param iconType number
        ---@param isComplete boolean
        local function CreateMockFrameWithData(iconType, isComplete)
            return {
                data = {
                    Type = isComplete and "complete" or "quest",
                    Icon = iconType,
                },
                isManualIcon = false,
                SetFixedFrameLevel = function() end,
                SetFrameLevel = function() end,
            }
        end

        it("should set frame level for quest completion icons at highest level", function()
            local frame = CreateMockFrameWithData(8, true) -- ICON_TYPE_COMPLETE
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- Two levels per tier: 2016 + 2 * 8 = 2032
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2032)
        end)

        it("should set correct frame level for regular quest icons based on icon type", function()
            -- ICON_TYPE_AVAILABLE (index 6) has draw order 1
            local frame = CreateMockFrameWithData(6, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 1) = 2026 (1 from icon type + 4 from MAX_DRAW_ORDER)
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2026)
        end)

        it("should set frame level for high priority icons (REPEATABLE_COMPLETE)", function()
            -- ICON_TYPE_REPEATABLE_COMPLETE (index 11) has draw order 3
            local frame = CreateMockFrameWithData(11, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 3) = 2030
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2030)
        end)

        it("should set frame level for low priority icons (SLAY)", function()
            -- ICON_TYPE_SLAY (index 1) has draw order 0
            local frame = CreateMockFrameWithData(1, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 0) = 2024
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2024)
        end)

        it("should place manual icons below regular quest icons", function()
            local regularFrame = CreateMockFrameWithData(6, false) -- ICON_TYPE_AVAILABLE
            local manualFrame = CreateMockFrameWithData(6, false) -- Same icon type
            manualFrame.isManualIcon = true

            local regularSpy = spy.on(regularFrame, "SetFrameLevel")
            local manualSpy = spy.on(manualFrame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(regularFrame)
            QuestieMap.utils.SetDrawOrder(manualFrame)

            -- Regular: 2016 + 2 * (4 + 1) = 2026
            -- Manual: 2016, the notes' own order, whatever icon a note shows
            assert.spy(regularSpy).was.called_with(regularFrame, 2026)
            assert.spy(manualSpy).was.called_with(manualFrame, 2016)
        end)

        it("should call SetFixedFrameLevel before and after setting frame level", function()
            local frame = CreateMockFrameWithData(6, false)
            local setFixedSpy = spy.on(frame, "SetFixedFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            assert.spy(setFixedSpy).was.called(2)
            assert.spy(setFixedSpy).was.called_with(frame, false)
            assert.spy(setFixedSpy).was.called_with(frame, true)
        end)

        it("leaves a pooled icon's level for its next draw", function()
            local frame = CreateMockFrame()
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            assert.spy(SetFrameLevelSpy).was.not_called()
        end)

        it("has a draw order for every one of QuestieDB's icon types", function()
            local savedError = Questie.Error
            Questie.Error = spy.new(function() end)
            for _, iconType in pairs(LibQuestieDB.Enum.iconTypes) do
                QuestieMap.utils.SetDrawOrder(CreateMockFrameWithData(iconType, false))
            end
            assert.spy(Questie.Error).was.not_called()
            Questie.Error = savedError
        end)

        it("reports an icon type without a draw order once, drawing it with the objectives", function()
            local savedError = Questie.Error
            Questie.Error = spy.new(function() end)
            local frame, again = CreateMockFrameWithData(99, false), CreateMockFrameWithData(99, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)
            QuestieMap.utils.SetDrawOrder(again)

            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2024)
            assert.spy(Questie.Error).was.called(1)
            Questie.Error = savedError
        end)

        it("should prioritize EVENTQUEST_COMPLETE icons correctly", function()
            -- ICON_TYPE_EVENTQUEST_COMPLETE (index 14) has draw order 3
            local frame = CreateMockFrameWithData(14, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 3) = 2030
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2030)
        end)

        it("should prioritize PVPQUEST_COMPLETE icons correctly", function()
            -- ICON_TYPE_PVPQUEST_COMPLETE (index 16) has draw order 3
            local frame = CreateMockFrameWithData(16, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 3) = 2030
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2030)
        end)

        it("should prioritize SODRUNE icons correctly", function()
            -- ICON_TYPE_SODRUNE (index 18) has draw order 3
            local frame = CreateMockFrameWithData(18, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 3) = 2030
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2030)
        end)

        it("should place medium priority icons (REPEATABLE) correctly", function()
            -- ICON_TYPE_REPEATABLE (index 10) has draw order 2
            local frame = CreateMockFrameWithData(10, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * (4 + 2) = 2028
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2028)
        end)

        it("should handle quest completion frames with manual icon flag", function()
            -- Quest completion should always be at highest level, even if manual
            local frame = CreateMockFrameWithData(8, true)
            frame.isManualIcon = true
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- 2016 + 2 * DRAW_ORDER_QUEST_COMPLETE (8) = 2032 (quest completion overrides everything)
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2032)
        end)

        it("should handle all valid icon type indices", function()
            -- Test indices 1-24 (all icon types in DRAW_ORDER_BY_ICON_TYPE_LOOKUP)
            for iconIndex = 1, 24 do
                local frame = CreateMockFrameWithData(iconIndex, false)
                local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

                QuestieMap.utils.SetDrawOrder(frame)

                -- Just verify it's called without errors for all valid indices
                assert.spy(SetFrameLevelSpy).was.called(1)
            end
        end)

        it("should correctly order icons from lowest to highest priority", function()
            -- Create frames with different priorities
            local lowPriorityFrame = CreateMockFrameWithData(1, false) -- ICON_TYPE_SLAY (0)
            local mediumPriorityFrame = CreateMockFrameWithData(10, false) -- ICON_TYPE_REPEATABLE (2)
            local highPriorityFrame = CreateMockFrameWithData(6, false) -- ICON_TYPE_AVAILABLE (1)
            local completionFrame = CreateMockFrameWithData(8, true) -- Complete (2032)

            local lowSpy = spy.on(lowPriorityFrame, "SetFrameLevel")
            local mediumSpy = spy.on(mediumPriorityFrame, "SetFrameLevel")
            local highSpy = spy.on(highPriorityFrame, "SetFrameLevel")
            local completionSpy = spy.on(completionFrame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(lowPriorityFrame)
            QuestieMap.utils.SetDrawOrder(mediumPriorityFrame)
            QuestieMap.utils.SetDrawOrder(highPriorityFrame)
            QuestieMap.utils.SetDrawOrder(completionFrame)

            -- Verify ordering: completion > medium > high > low
            assert.spy(lowSpy).was.called_with(lowPriorityFrame, 2024)
            assert.spy(highSpy).was.called_with(highPriorityFrame, 2026)
            assert.spy(mediumSpy).was.called_with(mediumPriorityFrame, 2028)
            assert.spy(completionSpy).was.called_with(completionFrame, 2032)
        end)

        it("draws every note at the notes' order, whatever texture it shows", function()
            local savedError = Questie.Error
            Questie.Error = spy.new(function() end)
            -- Townsfolk notes show a texture path or a texture file ID, never an icon type.
            for _, texture in ipairs({"Interface\\Minimap\\tracking\\mailbox", 133634}) do
                local frame = CreateMockFrameWithData(texture, false)
                frame.isManualIcon = true
                local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

                QuestieMap.utils.SetDrawOrder(frame)

                assert.spy(SetFrameLevelSpy).was.called_with(frame, 2016)
            end
            assert.spy(Questie.Error).was.not_called()
            Questie.Error = savedError
        end)

        it("should detect Type complete regardless of other fields", function()
            local frame = {
                data = {
                    Type = "complete",
                    Icon = 1, -- Low priority icon type
                },
                isManualIcon = true, -- Even if manual
                SetFixedFrameLevel = function() end,
                SetFrameLevel = function() end,
            }
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(frame)

            -- Should still be at completion level (2016 + 2 * 8 = 2032)
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2032)
        end)

        it("takes each icon type's number from QuestieDB's icon types", function()
            local savedError = Questie.Error
            Questie.Error = spy.new(function() end)
            LibQuestieDB.Enum.iconTypes.ICON_TYPE_AVAILABLE = 99
            dofile("Modules/Map/QuestieMapUtils.lua")
            local renumbered, former = CreateMockFrameWithData(99, false), CreateMockFrameWithData(6, false)
            local renumberedSpy, formerSpy = spy.on(renumbered, "SetFrameLevel"), spy.on(former, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(renumbered)
            QuestieMap.utils.SetDrawOrder(former)

            assert.spy(renumberedSpy).was.called_with(renumbered, 2026)
            -- The old number is no icon type any more.
            assert.spy(formerSpy).was.called_with(former, 2024)
            assert.spy(Questie.Error).was.called(1)
            Questie.Error = savedError
        end)

        it("draws a grown icon above the others of its tier, but below the next tier", function()
            local turnIn, note = CreateMockFrameWithData(8, true), CreateMockFrameWithData(6, false)
            turnIn.pictureScale, note.pictureScale, note.isManualIcon = 1.35, 1.35, true
            local turnInSpy, noteSpy = spy.on(turnIn, "SetFrameLevel"), spy.on(note, "SetFrameLevel")

            QuestieMap.utils.SetDrawOrder(turnIn)
            QuestieMap.utils.SetDrawOrder(note)

            assert.spy(turnInSpy).was.called_with(turnIn, 2033)
            -- A hovered townsfolk note stays below the objectives (2024 and up), whose smaller icons it
            -- would otherwise cover.
            assert.spy(noteSpy).was.called_with(note, 2017)
        end)

        describe("on the world map", function()
            local savedWorldMapFrame, inserted, insertResult

            ---The level the icon was drawn at.
            local function Level(iconType, fields)
                local frame = CreateMockFrameWithData(iconType, fields and fields.complete)
                for key, value in pairs(fields or {}) do frame[key] = value end
                frame.SetFrameLevel = function(self, level) self.level = level end
                QuestieMap.utils.SetDrawOrder(frame)
                return frame.level
            end

            before_each(function()
                savedWorldMapFrame = _G.WorldMapFrame
                inserted, insertResult = {}, true
                local levels = {
                    InsertFrameLevelBelow = function(_, frameLevelType, relativeFrameLevelType, range)
                        inserted[#inserted + 1] = {frameLevelType, relativeFrameLevelType, range}
                        return insertResult
                    end,
                    GetFrameLevelStart = function(_, frameLevelType)
                        return frameLevelType == "PIN_FRAME_LEVEL_QUESTIE" and 2740 or 2000
                    end,
                }
                _G.WorldMapFrame = {GetPinFrameLevelsManager = function() return levels end}
            end)

            after_each(function()
                _G.WorldMapFrame = savedWorldMapFrame
            end)

            it("draws in a block of its own below Blizzard's quest pins, by tier and then lower on the map in front", function()
                local objective, lowerObjective = Level(1, {y = 37.6}), Level(1, {y = 80})
                local giver, turnIn, note = Level(6, {y = 10}), Level(8, {complete = true, y = 0}), Level(6, {isManualIcon = true, y = 99})

                -- Nine tiers of 101 rows, each with one more level on top for a grown icon.
                assert.are.same({{"PIN_FRAME_LEVEL_QUESTIE", "PIN_FRAME_LEVEL_ACTIVE_QUEST", 918}}, inserted)
                assert.are.equal(2740 + 4 * 102 + 37, objective)
                assert.is_true(objective < lowerObjective)
                assert.is_true(lowerObjective < giver)
                assert.is_true(giver < turnIn)
                assert.is_true(note < objective)
                -- A grown icon draws above its tier's lowest icon, and below the next tier's highest.
                assert.are.equal(2740 + 4 * 102 + 101, Level(1, {y = 0, pictureScale = 1.35}))
                assert.are.equal(2740 + 917, Level(8, {complete = true, y = 100, pictureScale = 1.35}))
                assert.is_true(Level(6, {isManualIcon = true, y = 100, pictureScale = 1.35}) < Level(1, {y = 0}))
                -- Positions off the map's edges stay in their tier.
                assert.are.equal(2740 + 4 * 102, Level(1, {y = -5}))
                assert.are.equal(2740 + 4 * 102 + 100, Level(1, {y = 140}))
                -- The block is registered once.
                assert.are.equal(1, #inserted)
            end)

            it("keeps the fixed levels on the minimap, and where the world map gives no block", function()
                -- Two levels per tier: its icons', and a grown icon's above them.
                assert.are.equal(2024, Level(1, {miniMapIcon = true, y = 50}))
                assert.are.equal(2025, Level(1, {miniMapIcon = true, pictureScale = 1.35}))
                assert.are.equal(2026, Level(6, {miniMapIcon = true}))

                dofile("Modules/Map/QuestieMapUtils.lua")
                insertResult = false
                assert.are.equal(2024, Level(1, {y = 50}))
                assert.are.equal(2025, Level(1, {pictureScale = 1.35}))
            end)
        end)
    end)

    describe("MapExplorationUpdate", function()
        it("should keep map icons hidden when settings hide them", function()
            local frame = {
                x = 50,
                y = 50,
                UiMapID = 1,
                hidden = true,
                FakeShow = function() end,
                ShouldBeHidden = function() return true end,
            }
            _G.QuestieMapUtilsTestFrame = frame
            QuestieMap.questIdFrames = {
                [1] = {"QuestieMapUtilsTestFrame"},
            }
            QuestieMap.utils.IsExplored = function() return true end

            local fakeShowSpy = spy.on(frame, "FakeShow")

            QuestieMap.utils.MapExplorationUpdate()

            assert.spy(fakeShowSpy).was.not_called()
        end)
    end)
end)
