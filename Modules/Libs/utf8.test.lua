dofile("setupTests.lua")

describe("utf8", function()
    ---@type utf8
    local utf8

    before_each(function()
        package.loaded["Modules.Libs.utf8"] = nil
        utf8 = require("Modules.Libs.utf8")
    end)

    it("should return the module table", function()
        assert.is_table(utf8)
        assert.is_function(utf8.sub)
        assert.is_function(utf8.strlen)
    end)

    describe("strlen", function()
        it("should count ASCII, CJK, mixed, and empty strings", function()
            assert.are.same(3, utf8.strlen("abc"))
            assert.are.same(2, utf8.strlen("你好"))
            assert.are.same(5, utf8.strlen("a你b好c"))
            assert.are.same(0, utf8.strlen(""))
        end)
    end)

    describe("sub", function()
        it("should slice mixed UTF-8 text by character index", function()
            assert.are.same("你b好", utf8.sub("a你b好c", 2, 4))
        end)

        it("should default nil end index to the last character", function()
            assert.are.same("你b", utf8.sub("a你b", 2))
        end)

        it("should support negative indexes", function()
            assert.are.same("b好", utf8.sub("a你b好", -2, -1))
        end)

        it("should clamp out-of-range indexes", function()
            assert.are.same("a你", utf8.sub("a你", -10, 10))
            assert.are.same("", utf8.sub("a你", 3, 4))
            assert.are.same("", utf8.sub("", 1, 1))
        end)
    end)
end)
