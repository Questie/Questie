-- Up value
local minimap = Minimap
local type = type

-- Cache minimap closure functions for speed
local functionCache = {}
---@class MinimapCanvas : Minimap, MinimapCanvasMixin
local MinimapCanvas = Mixin(QuestieLoader:CreateModule("MinimapCanvas"), QuestieLoader("MinimapCanvasMixin"))
setmetatable(MinimapCanvas,
    --? This allows us to call the original functions on the minimap
    --? While still maintaining the self reference to minimap
    --? Otherwise the self reference would be to MinimapCanvas
    { __index = function(self, key)
        -- Use the cache if possible
        if functionCache[key] then
            return functionCache[key]
        end

        -- If it is a function we create a closure where minimap is the self
        -- Otherwise just return the raw variable
        if type(minimap[key]) == "function" then
            functionCache[key] = function(...)
                return minimap[key](minimap, ...)
            end
            return functionCache[key]
        else
            return minimap[key]
        end
    end })

-- Add the original Minimap functions to the QuestieMinimap (More exist, but these are the relevant ones)
-- See: https://wowpedia.fandom.com/wiki/UIOBJECT_Minimap
-- QuestieMinimap.SetParent = Minimap.SetParent -- This is a base function of the minimap object, but is it used?
MinimapCanvas.SetMaskTexturee = Minimap.SetMaskTexture
MinimapCanvas.GetZoom = Minimap.GetZoom
MinimapCanvas.GetZoomLevels = Minimap.GetZoomLevels
MinimapCanvas.SetZoom = Minimap.SetZoom

-- Initialize the canvas
MinimapCanvas:OnLoad()
