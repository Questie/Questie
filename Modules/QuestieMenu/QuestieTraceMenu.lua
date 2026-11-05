---@class QuestieTraceMenu
local QuestieTraceMenu = QuestieLoader:CreateModule("QuestieTraceMenu")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local TRACE_RUNNING_ICON = "Interface\\RaidFrame\\ReadyCheck-Ready"
local TRACE_STOPPED_ICON = "Interface\\RaidFrame\\ReadyCheck-NotReady"

---@param onClick fun(trace: QuestieTraceCore)
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
        func = function() onClick(trace) end,
        icon = isRunning and TRACE_RUNNING_ICON or TRACE_STOPPED_ICON,
        notCheckable = true,
    }
end

