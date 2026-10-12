dofile("setupTests.lua")

describe("QuestieStatus", function()
    local QuestieStatus
    local originalQuestie, originalProvider, originalUIParent, originalGetErrorHandler
    local reportError

    before_each(function()
        originalQuestie = _G.Questie
        originalProvider = _G.LibQuestieDB
        originalUIParent = _G.UIParent
        originalGetErrorHandler = _G.geterrorhandler
        _G.Questie = nil
        _G.LibQuestieDB = nil
        _G.UIParent = nil
        reportError = spy.new(function() end)
        _G.geterrorhandler = function()
            return function(message) reportError(message) end
        end
        dofile("Modules/Status/QuestieStatus.lua")
        QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")
    end)

    after_each(function()
        _G.Questie = originalQuestie
        _G.LibQuestieDB = originalProvider
        _G.UIParent = originalUIParent
        _G.geterrorhandler = originalGetErrorHandler
    end)

    it("replays pre-UI state and notifies the single observer when an issue is replaced", function()
        QuestieStatus.Set("startup", {severity = 1, message = "Startup failed"})
        local observed
        local firstObserver = spy.new(function() observed = QuestieStatus.GetIssues() end)
        assert.is_true(QuestieStatus.SetOnChange(firstObserver))
        assert.are.same({{id = "startup", severity = 1, message = "Startup failed"}}, observed)
        QuestieStatus.Set("startup", {severity = 2, message = "Partially recovered", icon = {texture = "warning"}})
        assert.are.same({{
            id = "startup", severity = 2, message = "Partially recovered", icon = {texture = "warning"},
        }}, observed)

        local replacement = spy.new(function() observed = QuestieStatus.GetIssues() end)
        assert.is_true(QuestieStatus.SetOnChange(replacement))
        QuestieStatus.Clear("startup")
        assert.are.same({}, observed)
        assert.spy(firstObserver).was.called(2)
        assert.spy(replacement).was.called(2)
        assert.is_true(QuestieStatus.SetOnChange(nil))
        QuestieStatus.Set("later", {severity = 3, message = "Later"})
        assert.spy(replacement).was.called(2)
    end)

    it("replaces stable IDs without reordering and clears only the named issue", function()
        QuestieStatus.Set("first", {
            severity = 2, message = "First", args = {"old"}, action = "Old action", icon = {texture = "old"},
            details = {{message = "Old details", args = {1}}},
        })
        QuestieStatus.Set("second", {severity = 2, message = "Second"})
        QuestieStatus.Set("error", {severity = 1, message = "Error"})
        QuestieStatus.Set("first", {severity = 2, message = "Updated"})
        assert.are.same({
            {id = "error", severity = 1, message = "Error"},
            {id = "first", severity = 2, message = "Updated"},
            {id = "second", severity = 2, message = "Second"},
        }, QuestieStatus.GetIssues())

        QuestieStatus.Clear("first")
        QuestieStatus.Clear("unknown")
        QuestieStatus.Set("first", {severity = 2, message = "Reactivated"})
        assert.are.same({
            {id = "error", severity = 1, message = "Error"},
            {id = "second", severity = 2, message = "Second"},
            {id = "first", severity = 2, message = "Reactivated"},
        }, QuestieStatus.GetIssues())
    end)

    it("keeps a custom error above lower-severity defaults and returns through warning, info, and none", function()
        local severity = QuestieStatus.Severity
        assert.are_same({Error = 1, Warning = 2, Info = 3}, severity)
        assert.is_nil(QuestieStatus.GetBadgeIssue())
        QuestieStatus.Set("info", {severity = severity.Info, message = "Info"})
        QuestieStatus.Set("warning", {severity = severity.Warning, message = "Warning"})
        QuestieStatus.Set("error", {severity = severity.Error, message = "Error", icon = {texture = 123}})
        assert.are.equal("error", QuestieStatus.GetBadgeIssue().id)
        QuestieStatus.Clear("error")
        assert.are.equal("warning", QuestieStatus.GetBadgeIssue().id)
        QuestieStatus.Clear("warning")
        assert.are.equal("info", QuestieStatus.GetBadgeIssue().id)
        QuestieStatus.Clear("info")
        assert.is_nil(QuestieStatus.GetBadgeIssue())
    end)

    local severities = {{name = "error", value = 1}, {name = "warning", value = 2}, {name = "info", value = 3}}
    for _, severity in ipairs(severities) do
        it("prefers a default " .. severity.name .. " badge over customs, otherwise the earliest custom", function()
            QuestieStatus.Set("first", {severity = severity.value, message = "First", icon = {atlas = "first"}})
            QuestieStatus.Set("second", {severity = severity.value, message = "Second", icon = {texture = "second"}})
            QuestieStatus.Set("first", {severity = severity.value, message = "Updated", icon = {atlas = "updated"}})
            assert.are.equal("first", QuestieStatus.GetBadgeIssue().id)
            QuestieStatus.Set("plain", {severity = severity.value, message = "Plain notice"})
            assert.are.equal("plain", QuestieStatus.GetBadgeIssue().id)
            QuestieStatus.Clear("plain")
            assert.are.equal("first", QuestieStatus.GetBadgeIssue().id)
            QuestieStatus.Clear("first")
            QuestieStatus.Set("first", {severity = severity.value, message = "Reactivated", icon = {atlas = "first"}})
            assert.are.equal("second", QuestieStatus.GetBadgeIssue().id)
        end)
    end

    it("owns input fields and returns independent list and badge snapshots", function()
        local input = {
            severity = 1, message = "Missing %s (%d)", args = {"data", 7},
            action = "Reload", icon = {atlas = "status", texture = 123},
            details = {{message = "Loaded %s (%d)", args = {"quests", 42}}, {message = "Source mode"}},
        }
        QuestieStatus.Set("owned", input)
        input.message = "Changed"
        input.args[1] = "changed"
        input.icon.texture = 999
        input.details[1].message = "Changed"
        input.details[1].args[1] = "changed"
        input.details[2] = {message = "Changed"}

        local list = QuestieStatus.GetIssues()
        list[1].severity = 3
        list[1].args[2] = 0
        list[1].icon.atlas = "changed"
        list[1].details[1].message = "Changed"
        list[1].details[1].args[2] = 0
        list[1].details[2] = nil
        list[2] = {id = "injected"}
        local badge = QuestieStatus.GetBadgeIssue()
        badge.message = "Changed"
        badge.args[1] = "changed"
        badge.icon.texture = 999
        badge.details[1].message = "Changed"
        badge.details[1].args[1] = "changed"
        badge.details[2] = nil
        assert.are.same({{
            id = "owned", severity = 1, message = "Missing %s (%d)", args = {"data", 7},
            action = "Reload", icon = {atlas = "status", texture = 123},
            details = {{message = "Loaded %s (%d)", args = {"quests", 42}}, {message = "Source mode"}},
        }}, QuestieStatus.GetIssues())
    end)

    it("reports observer failures without losing state or replacing the original startup error", function()
        QuestieStatus.Set("retained", {severity = 2, message = "Warning"})
        assert.is_false(QuestieStatus.SetOnChange(function() error("display failed", 0) end))
        assert.has_error(function()
            QuestieStatus.Set("startup", {severity = 1, message = "Startup failed"})
            error("original startup failure", 0)
        end, "original startup failure")
        assert.are.equal("startup", QuestieStatus.GetBadgeIssue().id)
        QuestieStatus.Clear("startup")
        assert.are.equal("retained", QuestieStatus.GetBadgeIssue().id)
        assert.spy(reportError).was.called(3)
        assert.spy(reportError).was.called_with("display failed")
    end)
end)
