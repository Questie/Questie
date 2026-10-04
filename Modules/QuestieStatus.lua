---@class QuestieStatus
local QuestieStatus = QuestieLoader:CreateModule("QuestieStatus")

-- Runtime issues only: an empty registry does not imply that Questie is ready.
-- Producers can record English localization keys before settings, databases, or UI exist.
QuestieStatus.Severity = {Error = 1, Warning = 2, Info = 3}

---@class QuestieStatusIcon
---@field atlas string?
---@field texture string|number? Fallback when the atlas is unavailable.

---@class QuestieStatusDetail
---@field message string English localization key.
---@field args (string|number)[]?

---@class QuestieStatusIssue
---@field severity 1|2|3
---@field message string English localization key.
---@field args (string|number)[]?
---@field action string? English localization key.
---@field details QuestieStatusDetail[]? Ordered diagnostic lines displayed before the action.
---@field icon QuestieStatusIcon? Omit to use the severity's default badge.

---@class QuestieStatusSnapshot : QuestieStatusIssue
---@field id string

---@type table<string, QuestieStatusSnapshot>
local issues = {}
local activationOrder = {}
local nextOrder = 0
---@type fun()?
local onChange

local function _CopyText(text)
    local copy = {message = text.message}
    if text.args then
        copy.args = {}
        for index, value in ipairs(text.args) do
            copy.args[index] = value
        end
    end
    return copy
end

local function _CopyIssue(issue, id)
    local copy = _CopyText(issue)
    copy.id = id
    copy.severity = issue.severity
    copy.action = issue.action
    if issue.details then
        copy.details = {}
        for index, detail in ipairs(issue.details) do
            copy.details[index] = _CopyText(detail)
        end
    end
    if issue.icon then
        copy.icon = {atlas = issue.icon.atlas, texture = issue.icon.texture}
    end
    return copy
end

local function _NotifyChanged()
    if not onChange then
        return true
    end
    -- A broken display must not replace the startup failure being recorded.
    local success = xpcall(onChange, geterrorhandler())
    return success
end

---Replaces only this producer's issue, preserving its original activation order.
---Copies the supplied fields; later caller mutations cannot change registry state.
---@param id string Stable producer-owned identifier.
---@param issue QuestieStatusIssue
function QuestieStatus.Set(id, issue)
    local copy = _CopyIssue(issue, id)
    if not issues[id] then
        nextOrder = nextOrder + 1
        activationOrder[id] = nextOrder
    end
    issues[id] = copy
    _NotifyChanged()
end

---Clearing then setting an ID gives it a new activation order. Unknown IDs are a no-op.
---@param id string
function QuestieStatus.Clear(id)
    if not issues[id] then
        return
    end
    issues[id] = nil
    activationOrder[id] = nil
    _NotifyChanged()
end

---Returns owned snapshots, ordered by severity then activation order.
---@return QuestieStatusSnapshot[]
function QuestieStatus.GetIssues()
    local result = {}
    for id, issue in pairs(issues) do
        result[#result + 1] = _CopyIssue(issue, id)
    end
    table.sort(result, function(left, right)
        if left.severity ~= right.severity then
            return left.severity < right.severity
        end
        return activationOrder[left.id] < activationOrder[right.id]
    end)
    return result
end

---Returns an owned snapshot for the badge, or nil when no issues are recorded.
---@return QuestieStatusSnapshot?
function QuestieStatus.GetBadgeIssue()
    local sorted = QuestieStatus.GetIssues()
    local first = sorted[1]
    if not first then
        return nil
    end
    -- Within the highest severity, a default badge beats all custom icons.
    -- Otherwise the earliest active custom icon wins. Lower severities never override it.
    for _, issue in ipairs(sorted) do
        if issue.severity ~= first.severity then
            break
        end
        if not issue.icon then
            return issue
        end
    end
    return first
end

---Replaces the single observer and immediately replays current state, including empty state.
---The synchronous, non-yielding callback reads snapshots through the getters. Nil detaches it.
---A failing observer remains registered; recorded state is retained and native error reporting is used.
---@param callback fun()?
---@return boolean success Whether replay completed without an observer error (or detached successfully).
function QuestieStatus.SetOnChange(callback)
    onChange = callback
    return _NotifyChanged()
end
