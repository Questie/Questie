---@class QuestieTraceMenu
local QuestieTraceMenu = QuestieLoader:CreateModule("QuestieTraceMenu")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local TRACE_RUNNING_ICON = "Interface\\COMMON\\Indicator-Green"
local TRACE_STOPPED_ICON = "Interface\\COMMON\\Indicator-Red"

---@param onClick fun(trace: QuestieTraceCore, button: string?)
---@return table?
function QuestieTraceMenu.Build(onClick)
    local trace = rawget(_G, "QuestieTraceCore")
    if type(trace) ~= "table" or type(trace.ShowExportWindow) ~= "function" then
        return nil
    end

    local isRunning = false
    if type(trace.GetStatusData) == "function" then
        local ok, status = pcall(trace.GetStatusData)
        isRunning = ok and type(status) == "table" and status.isRunning == true
    end

    return {
        text = l10n("QuestieTrace"),
        func = function(_, _, _, _, button) onClick(trace, button) end,
        checked = isRunning,
        customCheckIconTexture = TRACE_RUNNING_ICON,
        customUncheckIconTexture = TRACE_STOPPED_ICON,
        registerForRightClick = true,
        isNotRadio = true,
    }
end

---@param trace QuestieTraceCore
function QuestieTraceMenu.Toggle(trace)
    local status = trace.GetStatusData()
    if status.isRunning then
        trace.StopCapture()
    else
        -- Preserve a stopped session before starting the next one.
        trace.SaveCapture()
        trace.StartCapture()
    end
end

