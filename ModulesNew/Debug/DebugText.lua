---@class DebugText
local DebugText = QuestieLoader:CreateModule("DebugText");

local debugTextString = UIParent:CreateFontString(nil, "OVERLAY", "QuestFont")
debugTextString:SetWidth(500) --QuestLogObjectivesText default width = 275
debugTextString:SetHeight(0);
debugTextString:SetPoint("TOP", -250, 0);
debugTextString:SetJustifyH("LEFT");
---@diagnostic disable-next-line: redundant-parameter
debugTextString:SetWordWrap(true)
debugTextString:SetVertexColor(1, 1, 1, 1) --Set opacity to 0, even if it is shown it should be invisible
debugTextString:SetFont(debugTextString:GetFont(), 16, "OUTLINE")

local floor = math.floor
local tostring, Round, select = tostring, Round, select

local debugTable = {}

local function writeDebug()
    debugTextString:SetText("")
    for namespace, data in pairs(debugTable) do
        local text = ""
        text = namespace .. ":\n"
        for key, value in pairs(data) do
            text = text .. key .. ": " .. value .. "\n"
        end
        debugTextString:SetText((debugTextString:GetText() or "") .. text .. "\n")
    end
end
C_Timer.NewTicker(0.1, writeDebug)


function DebugText:Get(namespace)
    if not namespace or type(namespace) ~= "string" then
        return nil
    end

    local debugText = {}
    debugText.namespace = namespace
    debugText.debugTable = {}


    debugTable[namespace] = debugText.debugTable

    ---comment
    ---@param textKey string
    ---@param ... unknown
    function debugText:Print(textKey, ...)
        local text = ""
        for i = 1, select("#", ...) do
            local processedValue = select(i, ...)
            -- Cut off decimal values to something more readable
            if type(processedValue) == "number" and (processedValue < 1 or processedValue ~= floor(processedValue)) then
                -- Round to 3 decimals
                processedValue = Round(processedValue*1000)/1000
            end
            text = text .. tostring(processedValue) .. " "
        end
        debugText.debugTable[textKey] = text
    end

    return debugText
end
