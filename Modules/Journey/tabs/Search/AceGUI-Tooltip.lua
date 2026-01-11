--[[-----------------------------------------------------------------------------
GameTooltip Widget
Wrapper for WoW's GameTooltip.

Used by QuestieSearchResults.lua to pre-cache item tooltips
-------------------------------------------------------------------------------]]
local Type, Version = "GameTooltipWidget", 1 -- Changed Type and reset Version
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent -- Removed PlaySound

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@class AceGUIGameTooltipWidget : AceGUIWidget
local methods = {
    ["OnAcquire"] = function(self)
        Questie:Debug(Questie.DEBUG_INFO, "GameTooltipWidget OnAcquire called")
        -- restore default values
        self.frame:ClearLines() -- Clear any existing lines in the GameTooltip
        -- self.frame:ClearLines()
        -- self.frame:SetOwner(UIParent, "ANCHOR_NONE")
        -- self.frame:SetScale(1.0)
        -- self.frame:Hide()
        -- AceGUI default width/height behavior might be sufficient or may need specific handling if "wrap" is desired.
        -- For a GameTooltip, width/height are usually content-driven.
        -- self:SetWidth(150) -- Example default, though GameTooltip auto-sizes
        -- self:SetHeight(50)  -- Example default
    end,

    ["OnRelease"] = function (self)
        Questie:Debug(Questie.DEBUG_INFO, "GameTooltipWidget OnRelease called")
        -- GameTooltips are usually not released; they are reused.
        self.frame:Hide() -- Hide the tooltip instead of releasing it
        self.frame:SetOwner(UIParent, "ANCHOR_NONE") -- Reset owner to avoid issues
    end,

    ---@param ownerFrame Frame
    ---@param anchorPoint string
    ---@param offsetX? number
    ---@param offsetY? number
    ["SetOwner"] = function(self, ownerFrame, anchorPoint, offsetX, offsetY)
        self.frame:SetOwner(ownerFrame, anchorPoint, offsetX, offsetY)
    end,

    ---@param hyperlink string
    ["SetHyperlink"] = function(self, hyperlink)
        self.frame:SetHyperlink(hyperlink)
    end,

    ---@param itemID number
    ["SetItemByID"] = function(self, itemID)
        self.frame:SetItemByID(itemID)
    end,

    ---@param unitToken string
    ["SetUnit"] = function(self, unitToken)
        self.frame:SetUnit(unitToken)
    end,

    ---@param spellID number
    ["SetSpellByID"] = function(self, spellID)
        self.frame:SetSpellByID(spellID)
    end,

    ---@param text string
    ---@param r? number
    ---@param g? number
    ---@param b? number
    ---@param wrapText? boolean
    ["AddLine"] = function(self, text, r, g, b, wrapText)
        self.frame:AddLine(text, r, g, b, wrapText)
    end,

    ---@param textLeft string
    ---@param textRight string
    ---@param rL? number
    ---@param gL? number
    ---@param bL? number
    ---@param rR? number
    ---@param gR? number
    ---@param bR? number
    ["AddDoubleLine"] = function(self, textLeft, textRight, rL, gL, bL, rR, gR, bR)
        self.frame:AddDoubleLine(textLeft, textRight, rL, gL, bL, rR, gR, bR)
    end,

    ["ClearLines"] = function(self)
        self.frame:ClearLines()
    end,

    ["ShowTooltip"] = function(self) -- Renamed to avoid conflict with AceGUI's base Show if any specific logic needed
        self.frame:Show()
    end,

    ["HideTooltip"] = function(self) -- Renamed to avoid conflict with AceGUI's base Hide
        self.frame:Hide()
    end,

    ---@param scale number
    ["SetTooltipScale"] = function(self, scale) -- Renamed to avoid conflict with AceGUI's base SetScale
        self.frame:SetScale(scale)
    end,

    ---@param ownerFrame Frame
    ---@param anchorPoint string
    ---@param offsetX? number
    ---@param offsetY? number
    ["SetTooltipOwner"] = function(self, ownerFrame, anchorPoint, offsetX, offsetY)
        self.frame:SetOwner(ownerFrame, anchorPoint, offsetX, offsetY)
    end,

    ---@param right number
    ---@param bottom number
    ---@param left number
    ---@param top number
    ["SetPadding"] = function(self, right, bottom, left, top)
        self.frame:SetPadding(right, bottom, left, top)
    end,

    -- Standard AceGUI methods like SetWidth, SetHeight, SetPoint, Show, Hide
    -- will generally work on self.frame if not overridden.
    -- GameTooltip auto-sizes, so SetWidth/SetHeight might have limited or undesired effects.
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    local name = "AceGUIGameTooltip" .. AceGUI:GetNextWidgetNum(Type) -- Changed name prefix
    -- Create a GameTooltip. Initial parent can be nil; AceGUI will reparent it when added to a container.

    local frame = CreateFrame("GameTooltip", name, nil, "GameTooltipTemplate")
    frame:Hide() -- Widgets are hidden by default

    Questie:Debug(Questie.DEBUG_INFO, "GameTooltipWidget Constructor called")

    -- GameTooltips don't typically need mouse enabled on the tooltip frame itself for interaction.
    -- frame:EnableMouse(true)

	-- frame:SetPoint("TOP", 0, -5)


    -- Scripts for OnEnter/OnLeave on the tooltip frame itself (optional)
    -- frame:SetScript("OnEnter", Control_OnEnter)
    -- frame:SetScript("OnLeave", Control_OnLeave)

    -- No separate text FontString like the button; GameTooltip manages its own text lines.

    local widget = {
        -- text  = text, -- Removed
        frame = frame,
        type  = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
