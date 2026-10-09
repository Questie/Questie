---@class TooltipDataDebug
local TooltipDataDebug = QuestieLoader:CreateModule("TooltipDataDebug")

local MAX_FIELDS = 240
local MAX_DEPTH = 5
local MAX_STRING = 400
local LINE_NAMES = {"QuestTitle", "QuestObjective", "QuestPlayer"}

local initialized = false
local frame, pendingText
local paused = false

local function _IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function _CanReadTable(value)
    if _IsSecret(value) then return false end
    return type(value) == "table" and (not issecrettable or not issecrettable(value))
        and (not _G.canaccesstable or _G.canaccesstable(value))
end

local function _Scalar(value)
    -- Test secrecy before type checks, string conversion, comparisons or formatting.
    if _IsSecret(value) then return "secret" end
    local kind = type(value)
    if kind == "string" then
        local text = value:sub(1, MAX_STRING):gsub("|", "||"):gsub("\n", "\\n"):gsub("\r", "\\r")
        return '"' .. text .. (#value > MAX_STRING and "..." or "") .. '"'
    elseif kind == "number" or kind == "boolean" or kind == "nil" then
        return tostring(value)
    end
    -- Do not call a userdata/table __tostring metamethod while inspecting client data.
    return "<" .. kind .. ">"
end

---Builds a bounded, public-text snapshot. No raw tooltip values survive in the view.
---@param data any
---@param lineName string
---@param lineData any
---@return string
function TooltipDataDebug.FormatSnapshot(data, lineName, lineData)
    local lines = {"Observed: " .. lineName, "Native quest data captured before styling.", ""}
    local seen = {}
    local fieldCount = 0
    local truncated = false
    local function dump(label, value, depth)
        if fieldCount >= MAX_FIELDS then
            truncated = true
            return
        end
        fieldCount = fieldCount + 1
        local indent = string.rep("  ", depth)
        if _IsSecret(value) then
            lines[#lines + 1] = indent .. label .. " = secret"
        elseif type(value) ~= "table" then
            lines[#lines + 1] = indent .. label .. " = " .. _Scalar(value)
        elseif not _CanReadTable(value) then
            lines[#lines + 1] = indent .. label .. " = secret (restricted table)"
        elseif seen[value] then
            lines[#lines + 1] = indent .. label .. " = <already shown>"
        elseif depth >= MAX_DEPTH then
            lines[#lines + 1] = indent .. label .. " = <table: depth limit>"
        else
            seen[value] = true
            lines[#lines + 1] = indent .. label .. " = {"
            -- Sort only sanitized labels. Secret keys never become lookup keys or comparison operands.
            local fields = {}
            for key, entry in pairs(value) do
                fields[#fields + 1] = {label = "[" .. _Scalar(key) .. "]", value = entry}
                if #fields >= MAX_FIELDS then
                    truncated = true
                    break
                end
            end
            table.sort(fields, function(a, b) return a.label < b.label end)
            for _, entry in ipairs(fields) do
                dump(entry.label, entry.value, depth + 1)
                if fieldCount >= MAX_FIELDS then
                    truncated = true
                    break
                end
            end
            lines[#lines + 1] = indent .. "}"
        end
    end
    dump("lineData", lineData, 0)
    dump("tooltipData", data, 0)
    if truncated then lines[#lines + 1] = "<field limit reached>" end
    return table.concat(lines, "\n")
end

local function _CreateInspector()
    frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(650, 520)
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -130)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    frame:SetBackdropColor(0.03, 0.03, 0.03, 0.95)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText("Blizzard tooltip data | /qtooltipdata")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 0, 0)
    local pause = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    pause:SetSize(90, 22)
    pause:SetPoint("TOPRIGHT", -38, -7)
    pause:SetText("Pause")
    pause:SetScript("OnClick", function()
        paused = not paused
        pause:SetText(paused and "Resume" or "Pause")
    end)

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -40)
    scroll:SetPoint("BOTTOMRIGHT", -32, 12)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(595, 1)
    local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT")
    text:SetWidth(595)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetWordWrap(true)
    scroll:SetScrollChild(content)
    -- Coalesce line callbacks into one UI update. Only sanitized strings are retained.
    frame:SetScript("OnUpdate", function()
        if pendingText then
            text:SetText(pendingText)
            content:SetHeight(math.max(1, text:GetStringHeight() + 8))
            scroll:SetVerticalScroll(0)
            pendingText = nil
        end
    end)
    pendingText = "Hover a unit or object with Blizzard quest-helper lines.\nThe last snapshot stays here after mouseout."
    -- Inspection is opt-in; a closed frame does no payload formatting or UI updates.
    frame:Hide()
end

---Observes native quest data before styling; the inspector itself never consumes a line.
function TooltipDataDebug.Initialize()
    if initialized or not (TooltipDataProcessor and type(TooltipDataProcessor.AddLinePreCall) == "function"
        and Enum and Enum.TooltipDataLineType) then
        return
    end
    initialized = true
    _CreateInspector()
    _G.SLASH_QUESTIETOOLTIPDATA1 = "/qtooltipdata"
    SlashCmdList.QUESTIETOOLTIPDATA = function()
        if frame:IsShown() then frame:Hide() else frame:Show() end
    end

    for _, name in ipairs(LINE_NAMES) do
        local lineType = Enum.TooltipDataLineType[name]
        if lineType then
            TooltipDataProcessor.AddLinePreCall(lineType, function(tooltip, lineData)
                if tooltip == GameTooltip and not tooltip:IsForbidden() and frame:IsShown() and not paused then
                    -- Inspect inside the native callback; never retain a raw payload for a later frame.
                    local ok, snapshot = pcall(function()
                        local info = tooltip.processingInfo
                        local data = info
                        if _CanReadTable(info) then data = info.tooltipData end
                        return TooltipDataDebug.FormatSnapshot(data, name, lineData)
                    end)
                    pendingText = ok and snapshot or "Tooltip inspection unavailable (restricted or unreadable data)."
                end
                return false
            end)
        end
    end
end
