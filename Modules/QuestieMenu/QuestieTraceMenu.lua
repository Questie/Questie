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

---Colors the dropdown indicator according to the current capture state.
---@param button Button
---@param isRunning boolean
local function tintButton(button, isRunning)
    if not button then
        return
    end

    local check = button.Check
    local uncheck = button.UnCheck
    if not check or not uncheck then
        return
    end

    local color = isRunning and TRACE_RUNNING_COLOR or TRACE_STOPPED_COLOR
    check:SetVertexColor(unpack(color))
    uncheck:SetVertexColor(unpack(color))
    -- Show the unchecked state as a filled radio dot, so "stopped" reads as a red dot instead of an empty circle.
    uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
    uncheck:SetTexCoord(0.0, 0.5, 0.5, 1.0)
end

---Refreshes the dropdown indicator after LibUIDropDownMenu finishes its click update.
---@param button Button
---@param api table
local function deferRefresh(button, api)
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            QuestieTraceMenu.RefreshButton(button, api)
        end)
    else
        QuestieTraceMenu.RefreshButton(button, api)
    end
end

---Builds the optional QuestieTrace entry for the Questie menu.
---@param onClick fun(api: table, button: string?)
---@return table?
function QuestieTraceMenu.Build(onClick)
    local api = getApi()
    if (not api) then
        return nil
    end

    return {
        text = "QuestieTrace",
        func = function(button, _, _, _, clickButton)
            onClick(api, clickButton)
            if clickButton == "RightButton" then
                -- LibUIDropDownMenu changes the check textures before calling this callback. Defer
                -- the refresh so a refused StartCapture cannot leave the menu falsely green.
                deferRefresh(button, api)
            end
        end,
        -- LibUIDropDownMenu calls this with the button on every redraw, so it is also where the
        -- indicator gets its running/stopped color.
        checked = function(button)
            local isRunning = getIsRunning(api)
            tintButton(button, isRunning)
            return isRunning
        end,
        registerForRightClick = true,
        keepShownOnClick = true,
        isNotRadio = false,
    }
end

---Synchronizes a dropdown button with QuestieTrace's actual capture state.
---@param button Button
---@param api table
function QuestieTraceMenu.RefreshButton(button, api)
    if not button then
        return
    end

    local isRunning = getIsRunning(api)
    tintButton(button, isRunning)
    button.checked = isRunning
    button.Check:SetShown(isRunning)
    button.UnCheck:SetShown(not isRunning)
    if isRunning then
        button:LockHighlight()
    else
        button:UnlockHighlight()
    end
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
