dofile("setupTests.lua")

describe("QuestieFramePool", function()
    ---@type QuestieFramePool
    local QuestieFramePool

    local function CreateFakeFrame(frameId)
        local frame = {
            frameId = frameId,
            texture = {SetVertexColor = function() end},
            SetAlpha = function() end,
            SetScript = function() end,
        }
        frame.Unload = function(self)
            if (not self._loaded) then
                self._needsUnload = true
                return
            end
            self._needsUnload = nil
            self._loaded = nil
            self.data = nil
        end
        return frame
    end

    before_each(function()
        QuestieLoader:ImportModule("QuestiePopup").Dialogs = {}
        _G.tremove = table.remove
        _G.tinsert = table.insert
        local QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrame.CreateIconFrame = function(frameId) return CreateFakeFrame(frameId) end
        QuestieFrame.EnsureRightClickPassThrough = function() end

        dofile("Modules/FramePool/QuestieFramePool.lua")
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
    end)

    describe("UnloadFrame", function()
        it("should not mark a pooled frame for unload when it is unloaded again", function()
            local frame = QuestieFramePool:GetFrame()
            frame._loaded = true
            QuestieFramePool:UnloadFrame(frame)

            QuestieFramePool:UnloadFrame(frame)

            assert.is_nil(frame._needsUnload)
        end)

        it("should not return a frame to the pool twice when it is unloaded twice", function()
            local frame = QuestieFramePool:GetFrame()
            frame._loaded = true
            QuestieFramePool:UnloadFrame(frame)
            QuestieFramePool:UnloadFrame(frame)

            local first = QuestieFramePool:GetFrame()
            local second = QuestieFramePool:GetFrame()

            assert.are.equal(frame, first)
            assert.are_not.equal(frame, second)
        end)

        it("should keep deferring the unload of a frame that is still waiting in the draw queue", function()
            local frame = QuestieFramePool:GetFrame()

            QuestieFramePool:UnloadFrame(frame)

            assert.is_true(frame._needsUnload)
        end)
    end)

    describe("GetFrame", function()
        it("should hand out a reused frame without a pending unload", function()
            local frame = QuestieFramePool:GetFrame()
            frame._loaded = true
            QuestieFramePool:UnloadFrame(frame)
            frame._needsUnload = true

            local reused = QuestieFramePool:GetFrame()

            assert.are.equal(frame, reused)
            assert.is_nil(reused._needsUnload)
            assert.is_nil(reused._loaded)
        end)
    end)
end)
