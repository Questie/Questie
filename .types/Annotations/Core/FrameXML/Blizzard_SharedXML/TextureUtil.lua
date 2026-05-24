---@meta _
---[FrameXML](https://www.townlong-yak.com/framexml/go/GetTextureInfo)
---@param obj Texture
---@return string assetName
---@return string assetType
---@return number ulX
---@return number ulY
---@return number blX
---@return number blY
---@return number urX
---@return number urY
---@return number brX
---@return number brY
function GetTextureInfo(obj) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SetClampedTextureRotation)
---@param texture Texture
---@param rotationDegrees number
function SetClampedTextureRotation(texture, rotationDegrees) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ClearClampedTextureRotation)
---@param texture Texture
function ClearClampedTextureRotation(texture) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetMicroIconForRole
---@param role string
---@return string icon
function GetMicroIconForRole(role) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetTexCoordsByGrid)
---@param xOffset number
---@param yOffset number
---@param textureWidth number
---@param textureHeight number
---@param gridWidth number
---@param gridHeight number
---@return number minX
---@return number maxX
---@return number minY
---@return number maxY
function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetTexCoordsForRole)
---@param role string
---@return number minX
---@return number maxX
---@return number minY
---@return number maxY
function GetTexCoordsForRole(role) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateTextureMarkup)
---@param file number|string
---@param fileWidth number
---@param fileHeight number
---@param width number
---@param height number
---@param left number
---@param right number
---@param top number
---@param bottom number
---@param xOffset? number
---@param yOffset? number
---@return string
function CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateAtlasMarkup)
---@param atlasName number|string
---@param width? number
---@param height? number
---@param offsetX? number
---@param offsetY? number
---@param rVertexColor? number
---@param gVertexColor? number
---@param bVertexColor? number
---@return string
function CreateAtlasMarkup(atlasName, width, height, offsetX, offsetY, rVertexColor, gVertexColor, bVertexColor) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateAtlasMarkupWithAtlasSize)
---@param atlasName number|string
---@param offsetX? number
---@param offsetY? number
---@param rVertexColor? number
---@param gVertexColor? number
---@param bVertexColor? number
---@return string
function CreateAtlasMarkupWithAtlasSize(atlasName, offsetX, offsetY, rVertexColor, gVertexColor, bVertexColor, scale) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SetupAtlasesOnRegions)
--- Pass in a frame and a table containing parentKeys (on frame) as keys and atlas member names as the values
---@param frame Frame
---@param regionsToAtlases table
---@param useAtlasSize? boolean
function SetupAtlasesOnRegions(frame, regionsToAtlases, useAtlasSize) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetFinalNameFromTextureKit)
---@param fmt string
---@param textureKits string|table
---@return string
function GetFinalNameFromTextureKit(fmt, textureKits) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SetupTextureKitOnFrame)
--- Pass in a TextureKit name, a frame and a formatting string.
--- The TextureKit name will be inserted into fmt (at the first %s). The resulting atlas name will be set on frame
--- Use "%s" for fmt if the TextureKit name is the entire atlas element name
---@param textureKit string|table
---@param frame Texture|StatusBar
---@param fmt string
---@param setVisibility boolean
---@param useAtlasSize? boolean
function SetupTextureKitOnFrame(textureKit, frame, fmt, setVisibility, useAtlasSize) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SetupTextureKitOnFrames)
--- Pass in a TextureKit name and a table containing frames as keys and formatting strings as values
--- For each frame key in frames, the TextureKit name will be inserted into fmt (at the first %s). The resulting atlas name will be set on frame
--- Use "%s" for fmt if the TextureKit name is the entire atlas element name
---@param textureKit string|table
---@param frames table
---@param setVisibilityOfRegions boolean
---@param useAtlasSize? boolean
function SetupTextureKitOnFrames(textureKit, frames, setVisibilityOfRegions, useAtlasSize) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SetupTextureKitOnRegions)
--- Pass in a TextureKit name, a frame and a table containing parentKeys (on frame) as keys and formatting strings as values
--- For each frame key in frames, the TextureKit name will be inserted into fmt (at the first %s). The resulting atlas name will be set on frame
--- Use "%s" for fmt if the TextureKit name is the entire atlas element name
---@param textureKit string|table
---@param frame Frame
---@param regions table
---@param setVisibilityOfRegions boolean
---@param useAtlasSize? boolean
function SetupTextureKitOnRegions(textureKit, frame, regions, setVisibilityOfRegions, useAtlasSize) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/SetupTextureKitsFromRegionInfo)
--- Pass in a TextureKit name, a frame and a table containing parentKeys (on frame) as keys and a table as values
--- The values table should contain formatString as a member (setVisibility and useAtlasSize can also be added if desired)
--- For each frame key in frames, the TextureKit name will be inserted into formatString (at the first %s). The resulting atlas name will be set on frame
--- Use "%s" for formatString if the TextureKit name is the entire atlas element name
---@param textureKit string|table
---@param frame Frame
---@param regionInfoList table
function SetupTextureKitsFromRegionInfo(textureKit, frame, regionInfoList) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetFinalAtlasFromTextureKitIfExists)
--- Pass the texture and the textureKit, if the atlas exists in data then it will return the actual atlas name otherwise, return nil.
---@param texture string
---@param textureKit string|table
---@return string?
function GetFinalAtlasFromTextureKitIfExists(texture, textureKit) end
