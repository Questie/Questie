dofile("setupTests.lua")

describe("utf8", function()
    ---@type utf8
    local utf8

    before_each(function()
        package.loaded["Modules.Libs.utf8"] = nil
        dofile("Modules/Libs/utf8.lua")
        utf8 = QuestieLoader:ImportModule("utf8")
    end)

    it("should return the module table", function()
        assert.is_table(utf8)
        assert.is_function(utf8.sub)
        assert.is_function(utf8.strlen)
    end)

    describe("strlen", function()
        it("should count ASCII, CJK, mixed, and empty strings", function()
            assert.are_same(3, utf8.strlen("abc"))
            assert.are_same(2, utf8.strlen("你好"))
            assert.are_same(5, utf8.strlen("a你b好c"))
            assert.are_same(0, utf8.strlen(""))
        end)
    end)

    describe("sub", function()
        it("should slice mixed UTF-8 text by character index", function()
            assert.are_same("你b好", utf8.sub("a你b好c", 2, 4))
        end)

        it("should default nil end index to the last character", function()
            assert.are_same("你b", utf8.sub("a你b", 2))
        end)

        it("should support negative indexes", function()
            assert.are_same("b好", utf8.sub("a你b好", -2, -1))
        end)

        it("should clamp out-of-range indexes", function()
            assert.are_same("a你", utf8.sub("a你", -10, 10))
            assert.are_same("", utf8.sub("a你", 3, 4))
            assert.are_same("", utf8.sub("", 1, 1))
        end)
    end)

    describe("computeOffsets", function()
        it("should compute correct offsets for mixed text", function()
            local offsets = utf8.computeOffsets("a你b")
            assert.are_same({1, 2, 5}, offsets)
        end)

        it("should compute correct offsets for Chinese text", function()
            local offsets = utf8.computeOffsets("收集5个包裹")
            assert.are_same({1, 4, 7, 8, 11, 14}, offsets)
        end)
    end)

    describe("subWithOffsets", function()
        it("should slice using precomputed offsets", function()
            local offsets = utf8.computeOffsets("a你b好c")
            assert.are_same("你b好", utf8.subWithOffsets("a你b好c", offsets, 2, 4))
        end)

        it("should default nil end index to the last character", function()
            local offsets = utf8.computeOffsets("a你b")
            assert.are_same("你b", utf8.subWithOffsets("a你b", offsets, 2))
        end)

        it("should support negative indexes", function()
            local offsets = utf8.computeOffsets("a你b好")
            assert.are_same("b好", utf8.subWithOffsets("a你b好", offsets, -2, -1))
        end)

        it("should clamp out-of-range indexes", function()
            local offsets = utf8.computeOffsets("a你")
            assert.are_same("a你", utf8.subWithOffsets("a你", offsets, -10, 10))
            assert.are_same("", utf8.subWithOffsets("a你", offsets, 3, 4))
            assert.are_same("", utf8.subWithOffsets("", {}, 1, 1))
        end)
    end)

    describe("charIndexToByteIndexWithOffsets", function()
        it("should return byte index using precomputed offsets", function()
            local offsets = utf8.computeOffsets("a你b")
            assert.are_same(1, utf8.charIndexToByteIndexWithOffsets(offsets, 1, 5))
            assert.are_same(2, utf8.charIndexToByteIndexWithOffsets(offsets, 2, 5))
            assert.are_same(5, utf8.charIndexToByteIndexWithOffsets(offsets, 3, 5))
        end)

        it("should return string length + 1 for index > length", function()
            local offsets = utf8.computeOffsets("abc")
            assert.are_same(4, utf8.charIndexToByteIndexWithOffsets(offsets, 5, 3))
        end)

        it("should return 1 for index <= 1", function()
            local offsets = utf8.computeOffsets("abc")
            assert.are_same(1, utf8.charIndexToByteIndexWithOffsets(offsets, 0, 3))
            assert.are_same(1, utf8.charIndexToByteIndexWithOffsets(offsets, 1, 3))
        end)
    end)
end)
