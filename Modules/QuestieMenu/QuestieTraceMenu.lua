---@class QuestieTraceMenu
local QuestieTraceMenu = QuestieLoader:CreateModule("QuestieTraceMenu")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
local TRACE_RUNNING_COLOR = { 0.25, 1.0, 0.25 }
local TRACE_STOPPED_COLOR = { 1.0, 0.25, 0.25 }

---Returns the versioned QuestieTrace API, or nil when QuestieTrace is not installed.
---@return table?
local function getApi()
    return QuestieTraceAPI and QuestieTraceAPI.v1
end

---Returns whether QuestieTrace currently has an active capture.
---@param api table
---@return boolean isRunning
local function getIsRunning(api)
    return api.IsCaptureRunning() == true
end

---Colors the entry text according to the current capture state.
---@param button Button
---@param isRunning boolean
local function tintButton(button, isRunning)
    local fontString = button and button.fontString
    if (not fontString) then
        return
    end

    fontString:SetTextColor(unpack(isRunning and TRACE_RUNNING_COLOR or TRACE_STOPPED_COLOR))
end

---Builds the optional QuestieTrace entry for the Questie menu.
---@param onClick fun(api: table, button: string?): MenuResponse?
---@return MenuBuilderEntry?
function QuestieTraceMenu.Build(onClick)
    local api = getApi()
    if (not api) then
        return nil
    end

    return {
        text = "QuestieTrace",
        func = function(clickButton)
            return onClick(api, clickButton)
        end,
        -- Evaluated on every redraw, so the menu follows a refused StartCapture too.
        checked = function()
            return getIsRunning(api)
        end,
        -- Runs on every redraw, which is where the text gets its running/stopped color.
        initializer = function(button)
            tintButton(button, getIsRunning(api))
        end,
        registerForRightClick = true,
        keepShownOnClick = true,
    }
end

---Starts or stops QuestieTrace from the menu. Never starts without explicit consent.
---@param api table
function QuestieTraceMenu.Toggle(api)
    if getIsRunning(api) then
        api.StopCapture()
        Questie:Print(l10n("QuestieTrace stopped"))
        return
    end

    if api.GetConsentState() ~= "granted" then
        api.ShowConsentPrompt()
        return
    end

    if api.StartCapture() then
        Questie:Print(l10n("QuestieTrace started"))
    end
end
