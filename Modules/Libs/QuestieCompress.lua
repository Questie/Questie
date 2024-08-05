---@class QuestieCompress
local QuestieCompress = {...};
QuestieLoader:CreateModule("QuestieCompress", QuestieCompress);

local _QuestieCompress = {...};
local libS = LibStub:GetLibrary("AceSerializer-3.0")
local libC = LibStub:GetLibrary("LibCompress")
local libCE = libC:GetAddonEncodeTable()

-- What compression method should be used?
QuestieCompress.method = 10;

-- Compression lookup table
_QuestieCompress.compressionMethods = {
    [10] = _QuestieCompress.LibAceCompress,
}

-- Decompression lookup table
_QuestieCompress.decompressionMethods = {
   [10] = _QuestieCompress.LibAceDecompress,
}

-- Global Functions --

-- Generic compress uses the QuestieCompress.method to decide which one to use.
function QuestieCompress:Compress(data)
    local compressedData = _QuestieCompress.compressionMethods[QuestieCompress.method](data);
    -- Set the compression type char.
    compressedData = string.char(QuestieCompress.method)..compressedData;
    local compressedAndEncoded = libCE:Encode(compressedData);
    Questie:Debug(DEBUG_SPAM, "[QuestieCompress] Compressed&Encoded", compressedAndEncoded);
    return compressedAndEncoded;
end

-- Generic decompress reads first byte to decide on method.
function QuestieCompress:Decompress(data)
    if type(data) ~= "string" then
        error("QuestieCompress:Decompress -> parameter data is not of type string");
    end
    -- Decode the compressed data
    local decodedData = libCE:Decode(data);
    -- Get compression method
    local header_info = string.byte(decodedData);
    -- Strip compression method char
    decodedData = decodedData:sub(2)
    return _QuestieCompress.compressionMethods[header_info](decodedData);
end

-- Local Functions --

---- LibAce Methods ----

function _QuestieCompress:LibAceCompress(data)
    local serializedData = libS:Serialize(data);
    Questie:Debug(DEBUG_SPAM, "[QuestieCompress] Serialized", serializedData);
    local compressedData = libC:CompressHuffman(serializedData);
    Questie:Debug(DEBUG_SPAM, "[QuestieCompress] Compressed", compressedData);
    return compressedData
end

function _QuestieCompress:LibAceDecompress(decodedData)
     -- Decompress the decoded data
    local decompressedData, message = libC:Decompress(decodedData);
    if(not decompressedData) then
        error("QuestieCompress:Decompress -> Decompression failed : " .. message);
    end
    -- Deserialize the decompressed data
    local success, deserializedData = libS:Deserialize(decompressedData)
    if (not success) then
        print("QuestieCompress:Decompress -> error deserializing " .. deserializedData)
        return
    end
    return decompressedData;
end

---- LibAce Methods ----