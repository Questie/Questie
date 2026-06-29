dofile("setupTests.lua")

describe("LibDeflate Questie module", function()
    ---@type LibDeflate
    local LibDeflate
    local loadedLibDeflate
    local originalLibStub

    local function InstallFailingLibStub()
        _G.LibStub = {
            GetLibrary = function()
                error("LibDeflate should not read LibStub:GetLibrary")
            end,
            NewLibrary = function()
                error("LibDeflate should not register with LibStub:NewLibrary")
            end,
        }

        setmetatable(_G.LibStub, {
            __call = function()
                error("LibDeflate should not call LibStub")
            end,
        })
    end

    before_each(function()
        originalLibStub = _G.LibStub
        InstallFailingLibStub()

        loadedLibDeflate = dofile("Libs/LibDeflate/LibDeflate.lua")
        LibDeflate = QuestieLoader:ImportModule("LibDeflate")
    end)

    after_each(function()
        _G.LibStub = originalLibStub
    end)

    it("registers as a QuestieLoader module without using LibStub", function()
        assert.are.equal(loadedLibDeflate, LibDeflate)
        assert.is_equal("1.0.2-release", LibDeflate._VERSION)
        assert.is_equal("LibDeflate", LibDeflate._MAJOR)
        assert.is_equal(3, LibDeflate._MINOR)
        assert.is_equal("function", type(LibDeflate.CompressDeflate))
        assert.is_equal("function", type(LibDeflate.DecompressDeflate))
    end)

    it("round trips raw deflate data", function()
        local original = "Questie owns LibDeflate\000with binary\255 data"

        local compressed = LibDeflate:CompressDeflate(original)
        local decompressed, unprocessedBytes = LibDeflate:DecompressDeflate(compressed)

        assert.is_equal(original, decompressed)
        assert.is_equal(0, unprocessedBytes)
    end)

    it("round trips zlib data", function()
        local original = "Questie zlib payload with repeated repeated repeated data"

        local compressed = LibDeflate:CompressZlib(original)
        local decompressed, unprocessedBytes = LibDeflate:DecompressZlib(compressed)

        assert.is_equal(original, decompressed)
        assert.is_equal(0, unprocessedBytes)
    end)

    it("round trips addon-channel encoded data", function()
        local original = "Questie\000addon\001payload\010\255"

        local encoded = LibDeflate:EncodeForWoWAddonChannel(original)
        local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)

        assert.is_nil(encoded:find("\000", 1, true))
        assert.is_equal(original, decoded)
    end)

    it("round trips chat-channel encoded data", function()
        local original = "Questie\000chat\001payload\010\013\255"

        local encoded = LibDeflate:EncodeForWoWChatChannel(original)
        local decoded = LibDeflate:DecodeForWoWChatChannel(encoded)

        assert.is_equal(original, decoded)
    end)
end)
