dofile("setupTests.lua")

describe("QuestieMapUtils", function()
    ---@type QuestieMap
    local QuestieMap

    before_each(function()
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

            QuestieMap.utils:SetDrawOrder(frame)

            -- Quest completion should be at 2015 + 2 * 4 = 2023
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2023)
        end)

        it("should set correct frame level for regular quest icons based on icon type", function()
            -- ICON_TYPE_AVAILABLE (index 6) has draw order 1
            local frame = CreateMockFrameWithData(6, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 1 + 4 = 2020 (1 from icon type + 4 from MAX_DRAW_ORDER)
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2020)
        end)

        it("should set frame level for high priority icons (REPEATABLE_COMPLETE)", function()
            -- ICON_TYPE_REPEATABLE_COMPLETE (index 11) has draw order 3
            local frame = CreateMockFrameWithData(11, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 3 + 4 = 2022
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2022)
        end)

        it("should set frame level for low priority icons (SLAY)", function()
            -- ICON_TYPE_SLAY (index 1) has draw order 0
            local frame = CreateMockFrameWithData(1, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 0 + 4 = 2019
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2019)
        end)

        it("should place manual icons below regular quest icons", function()
            local regularFrame = CreateMockFrameWithData(6, false) -- ICON_TYPE_AVAILABLE
            local manualFrame = CreateMockFrameWithData(6, false) -- Same icon type
            manualFrame.isManualIcon = true

            local regularSpy = spy.on(regularFrame, "SetFrameLevel")
            local manualSpy = spy.on(manualFrame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(regularFrame)
            QuestieMap.utils:SetDrawOrder(manualFrame)

            -- Regular: 2015 + 1 + 4 = 2020
            -- Manual: 2015 + 1 + 0 = 2016 (no MAX_DRAW_ORDER added)
            assert.spy(regularSpy).was.called_with(regularFrame, 2020)
            assert.spy(manualSpy).was.called_with(manualFrame, 2016)
        end)

        it("should call SetFixedFrameLevel before and after setting frame level", function()
            local frame = CreateMockFrameWithData(6, false)
            local setFixedSpy = spy.on(frame, "SetFixedFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            assert.spy(setFixedSpy).was.called(2)
            assert.spy(setFixedSpy).was.called_with(frame, false)
            assert.spy(setFixedSpy).was.called_with(frame, true)
        end)

        it("should handle frames with no data gracefully", function()
            local frame = CreateMockFrame()
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- Should default to lowest level: 2015 + 0 + 4 = 2019
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2019)
        end)

        it("should handle frames with nil data.Icon gracefully", function()
            local frame = CreateMockFrame()
            frame.data = {Type = "quest", Icon = nil}
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- Should default to 2015 + 0 + 4 = 2019
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2019)
        end)

        it("should prioritize EVENTQUEST_COMPLETE icons correctly", function()
            -- ICON_TYPE_EVENTQUEST_COMPLETE (index 14) has draw order 3
            local frame = CreateMockFrameWithData(14, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 3 + 4 = 2022
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2022)
        end)

        it("should prioritize PVPQUEST_COMPLETE icons correctly", function()
            -- ICON_TYPE_PVPQUEST_COMPLETE (index 16) has draw order 3
            local frame = CreateMockFrameWithData(16, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 3 + 4 = 2022
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2022)
        end)

        it("should prioritize SODRUNE icons correctly", function()
            -- ICON_TYPE_SODRUNE (index 18) has draw order 3
            local frame = CreateMockFrameWithData(18, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 3 + 4 = 2022
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2022)
        end)

        it("should place medium priority icons (REPEATABLE) correctly", function()
            -- ICON_TYPE_REPEATABLE (index 10) has draw order 2
            local frame = CreateMockFrameWithData(10, false)
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + 2 + 4 = 2021
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2021)
        end)

        it("should handle quest completion frames with manual icon flag", function()
            -- Quest completion should always be at highest level, even if manual
            local frame = CreateMockFrameWithData(8, true)
            frame.isManualIcon = true
            local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(frame)

            -- 2015 + DRAW_ORDER_QUEST_COMPLETE (8) = 2023 (quest completion overrides everything)
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2023)
        end)

        it("should handle all valid icon type indices", function()
            -- Test indices 1-24 (all icon types in DRAW_ORDER_BY_ICON_TYPE_LOOKUP)
            for iconIndex = 1, 24 do
                local frame = CreateMockFrameWithData(iconIndex, false)
                local SetFrameLevelSpy = spy.on(frame, "SetFrameLevel")

                QuestieMap.utils:SetDrawOrder(frame)

                -- Just verify it's called without errors for all valid indices
                assert.spy(SetFrameLevelSpy).was.called(1)
            end
        end)

        it("should correctly order icons from lowest to highest priority", function()
            -- Create frames with different priorities
            local lowPriorityFrame = CreateMockFrameWithData(1, false) -- ICON_TYPE_SLAY (0)
            local mediumPriorityFrame = CreateMockFrameWithData(10, false) -- ICON_TYPE_REPEATABLE (2)
            local highPriorityFrame = CreateMockFrameWithData(6, false) -- ICON_TYPE_AVAILABLE (1)
            local completionFrame = CreateMockFrameWithData(8, true) -- Complete (2023)

            local lowSpy = spy.on(lowPriorityFrame, "SetFrameLevel")
            local mediumSpy = spy.on(mediumPriorityFrame, "SetFrameLevel")
            local highSpy = spy.on(highPriorityFrame, "SetFrameLevel")
            local completionSpy = spy.on(completionFrame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(lowPriorityFrame)
            QuestieMap.utils:SetDrawOrder(mediumPriorityFrame)
            QuestieMap.utils:SetDrawOrder(highPriorityFrame)
            QuestieMap.utils:SetDrawOrder(completionFrame)

            -- Verify ordering: completion > medium > high > low
            assert.spy(lowSpy).was.called_with(lowPriorityFrame, 2019)
            assert.spy(highSpy).was.called_with(highPriorityFrame, 2020)
            assert.spy(mediumSpy).was.called_with(mediumPriorityFrame, 2021)
            assert.spy(completionSpy).was.called_with(completionFrame, 2023)
        end)

        it("should handle manual icons with varying priorities correctly", function()
            local manualLowPriorityFrame = CreateMockFrameWithData(1, false)
            manualLowPriorityFrame.isManualIcon = true
            local lowSpy = spy.on(manualLowPriorityFrame, "SetFrameLevel")

            local manualHighPriorityFrame = CreateMockFrameWithData(6, false)
            manualHighPriorityFrame.isManualIcon = true
            local highSpy = spy.on(manualHighPriorityFrame, "SetFrameLevel")

            QuestieMap.utils:SetDrawOrder(manualLowPriorityFrame)
            QuestieMap.utils:SetDrawOrder(manualHighPriorityFrame)

            -- Low priority manual: 2015 + 0 + 0 = 2015
            -- High priority manual: 2015 + 1 + 0 = 2016
            assert.spy(lowSpy).was.called_with(manualLowPriorityFrame, 2015)
            assert.spy(highSpy).was.called_with(manualHighPriorityFrame, 2016)
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

            QuestieMap.utils:SetDrawOrder(frame)

            -- Should still be at completion level
            assert.spy(SetFrameLevelSpy).was.called_with(frame, 2023)
        end)
    end)
end)
