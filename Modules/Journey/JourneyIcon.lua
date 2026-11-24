---The small icons of the Journey, like the one in front of a quest.
---@class JourneyIcon
local JourneyIcon = QuestieLoader:CreateModule("JourneyIcon")

local HEIGHT, WIDTH = 14, 14
local GRAY = 0.75

---An icon from one of Blizzard's atlases, shown in gray.
---@class JourneyIcon.GrayAtlas
---@field atlas string
---@field width number

---@alias JourneyIcon.Icon string|JourneyIcon.GrayAtlas A string is the path of a texture

---A crossed-out eye, for a quest that is hidden. Every supported client has it, in two versions that only look the same in
---gray (checked in UiTextureAtlasMember).
---@type JourneyIcon.GrayAtlas
JourneyIcon.HIDDEN = {atlas = "transmog-icon-hidden", width = 17}

---@param parent Frame
---@return Texture texture Shows nothing yet
function JourneyIcon.Create(parent)
    return parent:CreateTexture(nil, "ARTWORK")
end

---@param texture Texture It may have shown another icon before
---@param icon JourneyIcon.Icon? Nothing is shown when nil
function JourneyIcon.Set(texture, icon)
    texture:SetShown(icon ~= nil)
    if type(icon) == "table" then
        texture:SetSize(icon.width, HEIGHT)
        texture:SetAtlas(icon.atlas)
        texture:SetDesaturated(true)
        texture:SetVertexColor(GRAY, GRAY, GRAY)
    else
        texture:SetSize(WIDTH, HEIGHT)
        texture:SetTexture(icon)
        texture:SetTexCoord(0, 1, 0, 1) -- The whole image, because an atlas is only a part of one
        texture:SetDesaturated(false)
        texture:SetVertexColor(1, 1, 1)
    end
end

return JourneyIcon
