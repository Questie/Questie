-------------------------
--Import modules.
-------------------------
---@type Blob
local Blob = QuestieLoader:ImportModule("Blob");

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

-- Regular Textures

local textureCount = 0;

local function textureReset(self, tex)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.TexturePool.resetterFunc")

    --Vertex offset
    tex.ULv = { x=0, y=0};
    tex.LLv = { x=0, y=0};
    tex.URv = { x=0, y=0};
    tex.LRv = { x=0, y=0};
    --TexCoord
    tex.ULt = { x=0, y=0};
    tex.LLt = { x=0, y=1};
    tex.URt = { x=1, y=0};
    tex.LRt = { x=1, y=1};
    tex.selectedTexture = "";
    
    --for i = 1, 5 do
    --    local maskTexture = tex:GetMaskTexture(i)
    --    tex:RemoveMaskTexture(maskTexture)
    --end

    --Remove all mask textures
    for _, maskTexture in pairs(tex.maskTextures or {}) do
        tex:RemoveMaskTexture(maskTexture);
    end
    tex.maskTextures = {}

    --tex:SetTexCoord(0,1,0,1)
    --tex:SetVertexOffset(0,0,0,0)
    --tex:SetParent(WorldMapFrame:GetCanvas())
    TexturePool_HideAndClearAnchors(self, tex)
    --tex:Hide();
	--tex:ClearAllPoints();
    --tex:SetParent(UIParent)
    --tex:Hide();
end

local function textureCreate(texturePool)
    textureCount = textureCount + 1;
    local tex = texturePool.parent:CreateTexture("BlobTexture"..textureCount, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer);
    --tex:SetSnapToPixelGrid(false)
    --tex:SetTexelSnappingBias(0)
    tex:SetSnapToPixelGrid(false)
    tex:SetTexelSnappingBias(0)

    tex.maskTextures = {}

    return tex
end

Blob.TexturePool = CreateTexturePool(WorldMapFrame:GetCanvas(), "OVERLAY", 0, nil, textureReset)
Blob.TexturePool.creationFunc = textureCreate;

-- Line Textures


local lineCount = 0;

local function lineReset(self, line)
    --Questie:Debug(DEBUG_DEVELOP, "Blob.TexturePool.resetterFunc")
    --line:SetParent(UIParent)
    --line:SetTexCoord(0,0,0,0);
    line.color = nil;
    line.startX = nil
    line.startY = nil
    line.endX = nil
    line.endY = nil
    line.thickness = nil

    --Remove all mask textures
    for _, maskTexture in pairs(line.maskTextures or {}) do
        line:RemoveMaskTexture(maskTexture);
    end
    line.maskTextures = {}

    --line:ClearAllPoints()
    --line:SetTexCoord(0,1,0,1)
    line:SetParent(WorldMapFrame:GetCanvas())
    TexturePool_HideAndClearAnchors(self, line)
    --line:Hide();
end

local function redraw(self, zoomScale)
    self:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
    self.drawlinefunction(self, self:GetParent(), self.startX, self.startY, self.endX, self.endY, self.thickness / (zoomScale or 1), 1, "TOPLEFT");
end

local function lineCreate(linePool)
    lineCount = lineCount + 1;
    local line = linePool.parent:CreateTexture("BlobLine"..textureCount, linePool.layer, nil, linePool.subLayer);
    line = Mixin(line, LineMixin)
    line.drawlinefunction = DrawLine
    line.redraw = redraw
    --Wibbley wobbly time travel stuff (stops texture from looking strange when moving)
    line:SetSnapToPixelGrid(false)
    line:SetTexelSnappingBias(0)
    line:SetTexture("Interface/BUTTONS/WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")--maskTex
    --line:SetTexture(QuestieLib.AddonPath.."Icons\\Raw\\Exported\\outline", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")--maskTex
    
    --Working black outline line texture! use width 3?
    --line:SetTexture(QuestieLib.AddonPath.."Icons\\Raw\\Exported\\WHITE32X32BLACKLINES", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")--maskTex
    --line:SetTexture(QuestieLib.AddonPath.."Icons\\Raw\\Exported\\WHITE32X32NOBORDERS", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")--maskTex

    line.maskTextures = {}
    return line
    --return linePool.parent:CreateLine("BlobLine"..lineCount, linePool.layer, nil, linePool.subLayer);
end

Blob.LinePool = CreateTexturePool(WorldMapFrame:GetCanvas(), "OVERLAY", 0, nil, lineReset)
Blob.LinePool.creationFunc = lineCreate;


---@class BlobTexture
Blob.TexturePool.TEXTURE = {
    path=QuestieLib.AddonPath.."Icons\\square",
    width=512,
    height=512,
    --The lower two numbers are kinda "magic" 132 is the number of pixels i want to move it
    offsetY=132,--Using 130 in the code
    --but texoffset is "magic" a good starting value for tweaking is offsetY/2
    texoffsetY=74 --Using 74 in code
}

--[[---@type BlobTexture
Blob.TexturePool.TEXTURECURVE = {
    path=QuestieLib.AddonPath.."Icons\\squarecurve",
    width=512,
    height=512,
    --The lower two numbers are kinda "magic" 132 is the number of pixels i want to move it
    offsetY=132,--Using 130 in the code
    --but texoffset is "magic" a good starting value for tweaking is offsetY/2
    texoffsetY=74 --Using 74 in code
}

--Not in use
---@type BlobTexture
Blob.TexturePool.TEXTURECURVESMALL = {
    path=QuestieLib.AddonPath.."Icons\\squaregrad",
    width=512,
    height=512,
    --The lower two numbers are kinda "magic" 132 is the number of pixels i want to move it
    offsetY=132,--Using 130 in the code
    --but texoffset is "magic" a good starting value for tweaking is offsetY/2
    texoffsetY=74 --Using 74 in code
}]]--