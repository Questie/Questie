dofile("setupTests.lua")

describe("TrackerShortcuts", function()
    ---@type TrackerShortcuts
    local TrackerShortcuts
    local originalModifierChecks

    ---@param held table<string, boolean> e.g. {ctrl = true}
    local function _HoldModifiers(held)
        _G.IsShiftKeyDown = function() return held.shift == true end
        _G.IsControlKeyDown = function() return held.ctrl == true end
        _G.IsAltKeyDown = function() return held.alt == true end
    end

    before_each(function()
        originalModifierChecks = {_G.IsShiftKeyDown, _G.IsControlKeyDown, _G.IsAltKeyDown}
        _HoldModifiers({})
        Questie.db.profile = {
            trackerbindOpenQuestLog = "left",
            trackerbindUntrack = "disabled",
            trackerbindShareQuest = "shiftleft",
            trackerbindSetTomTom = "ctrlleft",
        }
        dofile("Modules/Tracker/TrackerShortcuts.lua")
        TrackerShortcuts = QuestieLoader:ImportModule("TrackerShortcuts")
    end)

    after_each(function()
        _G.IsShiftKeyDown, _G.IsControlKeyDown, _G.IsAltKeyDown = unpack(originalModifierChecks)
    end)

    describe("Matches", function()
        it("matches each click to its own shortcut and no other", function()
            -- The shortcuts the options offer, and the click each one stands for
            local clicks = {
                {shortcut = "left", button = "LeftButton", held = {}},
                {shortcut = "right", button = "RightButton", held = {}},
                {shortcut = "shiftleft", button = "LeftButton", held = {shift = true}},
                {shortcut = "shiftright", button = "RightButton", held = {shift = true}},
                {shortcut = "ctrlleft", button = "LeftButton", held = {ctrl = true}},
                {shortcut = "ctrlright", button = "RightButton", held = {ctrl = true}},
                {shortcut = "altleft", button = "LeftButton", held = {alt = true}},
                {shortcut = "altright", button = "RightButton", held = {alt = true}},
            }

            for _, click in ipairs(clicks) do
                _HoldModifiers(click.held)
                for _, bound in ipairs(clicks) do
                    Questie.db.profile.trackerbindUntrack = bound.shortcut
                    local isMatch = TrackerShortcuts.Matches("trackerbindUntrack", click.button)
                    assert.are_same(bound == click, isMatch, "click " .. click.shortcut .. ", bound to " .. bound.shortcut)
                end
            end
        end)

        it("matches no shortcut while several modifier keys are held", function()
            _HoldModifiers({ctrl = true, shift = true})

            assert.is_false(TrackerShortcuts.Matches("trackerbindOpenQuestLog", "LeftButton"))
            assert.is_false(TrackerShortcuts.Matches("trackerbindShareQuest", "LeftButton"))
            assert.is_false(TrackerShortcuts.Matches("trackerbindSetTomTom", "LeftButton"))
        end)

        it("matches no shortcut for another mouse button, even for a missing setting", function()
            Questie.db.profile.trackerbindUntrack = nil

            assert.is_false(TrackerShortcuts.Matches("trackerbindUntrack", "MiddleButton"))
        end)
    end)

    describe("IsLinkClick", function()
        local originalGetActiveWindow

        before_each(function()
            originalGetActiveWindow = _G.ChatEdit_GetActiveWindow
            _G.ChatEdit_GetActiveWindow = function() return {} end
        end)

        after_each(function()
            _G.ChatEdit_GetActiveWindow = originalGetActiveWindow
        end)

        it("links on Shift + Left Click while the chat input is open", function()
            _HoldModifiers({shift = true})

            assert.is_true(TrackerShortcuts.IsLinkClick("LeftButton"))
        end)

        it("does not link on any other click while the chat input is open", function()
            assert.is_false(TrackerShortcuts.IsLinkClick("LeftButton"))
            _HoldModifiers({shift = true})
            assert.is_false(TrackerShortcuts.IsLinkClick("RightButton"))
            _HoldModifiers({shift = true, ctrl = true})
            assert.is_false(TrackerShortcuts.IsLinkClick("LeftButton"))
            _HoldModifiers({alt = true})
            assert.is_false(TrackerShortcuts.IsLinkClick("LeftButton"))
        end)

        it("does not link on Shift + Left Click while the chat input is closed", function()
            _G.ChatEdit_GetActiveWindow = function() return nil end
            _HoldModifiers({shift = true})

            assert.is_false(TrackerShortcuts.IsLinkClick("LeftButton"))
        end)
    end)

    describe("Set", function()
        it("disables the action that had the click before, and only that one", function()
            TrackerShortcuts.Set("trackerbindUntrack", "ctrlleft")

            assert.are_same({
                trackerbindOpenQuestLog = "left",
                trackerbindUntrack = "ctrlleft",
                trackerbindShareQuest = "shiftleft",
                trackerbindSetTomTom = "disabled",
            }, Questie.db.profile)
        end)

        it("keeps a click the action already has", function()
            TrackerShortcuts.Set("trackerbindShareQuest", "shiftleft")

            assert.are_same("shiftleft", Questie.db.profile.trackerbindShareQuest)
        end)
    end)
end)
