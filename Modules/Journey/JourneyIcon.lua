---The small icons of the Journey, like the one in front of a quest.
---@class JourneyIcon
local JourneyIcon = QuestieLoader:CreateModule("JourneyIcon")

local HEIGHT, WIDTH = 14, 14
local GRAY = 0.75
local LOW_LEVEL_BRIGHTNESS = 0.6

---An icon from one of Blizzard's atlases, shown in gray.
---@class JourneyIcon.GrayAtlas
---@field atlas string
---@field width number

---One of Questie's icons, shown darker.
---@class JourneyIcon.DarkIcon
---@field name string In Questie.icons
---@field brightness number 1 is as bright as it is

---@alias JourneyIcon.Icon string|JourneyIcon.GrayAtlas|JourneyIcon.DarkIcon A string is the path of a texture

---A crossed-out eye, for a quest that is hidden. Every supported client has it, in two versions that only look the same in
---gray (checked in UiTextureAtlasMember).
---@type JourneyIcon.GrayAtlas
JourneyIcon.HIDDEN = {atlas = "transmog-icon-hidden", width = 17}

---@type table<string, JourneyIcon.DarkIcon>
local lowLevelIcons = {}

-- The arrow of the player on the minimap
JourneyIcon.ARROW = "Interface\\Minimap\\MinimapArrow"

---The icon of a quest that is too low level to be worth it. Like Blizzard's for those, TrivialQuests, but a bit brighter.
---@param name string In Questie.icons
---@return JourneyIcon.DarkIcon icon Always the same table, because a row with another one counts as changed
function JourneyIcon.GetLowLevel(name)
    lowLevelIcons[name] = lowLevelIcons[name] or {name = name, brightness = LOW_LEVEL_BRIGHTNESS}
    return lowLevelIcons[name]
end

---@param parent Frame
---@return Texture texture Shows nothing yet
function JourneyIcon.Create(parent)
    return parent:CreateTexture(nil, "ARTWORK")
end

---@param texture Texture It may have shown another icon before
---@param icon JourneyIcon.Icon? Nothing is shown when nil
function JourneyIcon.Set(texture, icon)
    texture:SetShown(icon ~= nil)
    if type(icon) == "table" and icon.atlas then
        texture:SetSize(icon.width, HEIGHT)
        texture:SetAtlas(icon.atlas)
        texture:SetDesaturated(true)
        texture:SetVertexColor(GRAY, GRAY, GRAY)
    else
        local isDark = type(icon) == "table"
        local brightness = isDark and icon.brightness or 1
        texture:SetSize(WIDTH, HEIGHT)
        texture:SetTexture(isDark and Questie.icons[icon.name] or icon)
        texture:SetTexCoord(0, 1, 0, 1) -- The whole image, because an atlas is only a part of one
        texture:SetDesaturated(false)
        texture:SetVertexColor(brightness, brightness, brightness)
    end
end

---@param icon string|JourneyIcon.DarkIcon
---@return string text The icon, for the start of a text
function JourneyIcon.GetMarkup(icon)
    if type(icon) == "string" then
        return "|T" .. icon .. ":" .. HEIGHT .. "|t "
    end
    local color = math.floor(icon.brightness * 255 + 0.5)
    -- The colors come after the size, the offset, and the part of the image that is shown, which is all of it
    return ("|T%s:%d:%d:0:0:64:64:0:64:0:64:%d:%d:%d|t "):format(Questie.icons[icon.name], HEIGHT, WIDTH, color, color, color)
end

return JourneyIcon
