---@meta
------------FRAME FUNCTIONS
---Hides frame and clears points
--- See Blizzard code [Documentation](https://github.com/tomrus88/BlizzardInterfaceCode/blob/ace1af63e38c058fa76cd3abca0b57b384c527d4/Interface/SharedXML/Pools.lua#L143)
function FramePool_HideAndClearAnchors() end



---@param pixels number         @Pixel size
---@param frameScale number     @Effective Frame scale
---@return number               @UI size
---See blizzard Util.lua [Documentation](https://github.com/tomrus88/BlizzardInterfaceCode/blob/ace1af63e38c058fa76cd3abca0b57b384c527d4/Interface/SharedXML/Util.lua#L128)
function ConvertPixelsToUI(pixels, frameScale)
    local physicalScreenHeight = select(2, GetPhysicalScreenSize());
    return (pixels * 768.0)/(physicalScreenHeight * frameScale);
end

---[FrameXML](https://www.townlong-yak.com/framexml/go/DevTools_Dump)
---@param value any
---@param startKey? string
function DevTools_Dump(value, startKey) end
