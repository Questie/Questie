dofile("setupTests.lua")

local match = require("luassert.match")

describe("TrackerQuestLogButton", function()
    ---@type TrackerQuestLogButton
    local TrackerQuestLogButton
    local originals, overlay, menuBuilder, combat, playerMap, questBlocks, campaignBlocks, questMaps, questTitles, compat, compatOriginals

    local function _FakeFrame()
        local frame = {scripts = {}, attributes = {}, points = {}, events = {}}
        function frame:SetScript(name, callback) self.scripts[name] = callback end
        function frame:GetScript(name) return self.scripts[name] end
        function frame:SetAttribute(key, value) self.attributes[key] = value end
        function frame:SetSize(width, height) self.width, self.height = width, height end
        function frame:ClearAllPoints() self.points = {} end
        function frame:SetPoint(point, relativeTo, _, x, y) table.insert(self.points, {point = point, relativeTo = relativeTo, x = x, y = y}) end
        function frame:RegisterEvent(event) table.insert(self.events, event) end
        function frame:SetFrameStrata(strata) self.strata = strata end
        function frame:SetFrameLevel(level) self.level = level end
        function frame:GetFrameStrata() return "MEDIUM" end
        function frame:GetFrameLevel() return 5 end
        function frame:IsMouseOver() return self.mouseOver == true end
        function frame:IsVisible() return self.visible ~= false end
        function frame:GetParent() return self.parent end
        frame.EnableMouse, frame.RegisterForClicks, frame.RegisterForDrag, frame.SetPropagateMouseMotion = function() end, function() end, function() end, function() end
        return frame
    end

    ---@return table line
    local function _QuestLine(questId)
        local line = _FakeFrame()
        line.label = _FakeFrame()
        function line.label:GetPoint() return "TOPLEFT", line, "TOPLEFT", 25, -1 end
        line.onClickMode = "quest"
        line.Quest = {Id = questId or 783}
        line.scripts.OnClick = spy.new(function() end)
        line.scripts.OnLeave = spy.new(function() end)
        line.mouseOver = true
        return line
    end

    before_each(function()
        originals = {
            CreateFrame = _G.CreateFrame,
            RegisterStateDriver = _G.RegisterStateDriver,
            InCombatLockdown = _G.InCombatLockdown,
            InputUtil = _G.InputUtil,
            IsShiftKeyDown = _G.IsShiftKeyDown,
            IsControlKeyDown = _G.IsControlKeyDown,
            IsAltKeyDown = _G.IsAltKeyDown,
            QuestLogQuests_GetQuestButton = _G.QuestLogQuests_GetQuestButton,
            C_QuestLog = _G.C_QuestLog,
            C_Map = _G.C_Map,
            IsModifiedClick = _G.IsModifiedClick,
            QuestObjectiveTracker = _G.QuestObjectiveTracker,
            CampaignQuestObjectiveTracker = _G.CampaignQuestObjectiveTracker,
        }
        combat = false
        _G.InCombatLockdown = function() return combat end
        _G.IsShiftKeyDown = function() return false end
        _G.IsControlKeyDown = function() return false end
        _G.IsAltKeyDown = function() return false end
        questMaps, questTitles = {[783] = 1429}, {}
        _G.QuestLogQuests_GetQuestButton = function(questId) return questTitles[questId] end
        _G.C_QuestLog = {SetSelectedQuest = spy.new(function() end)}
        playerMap = nil
        _G.IsModifiedClick = function() return false end
        questBlocks, campaignBlocks = {}, {}
        _G.QuestObjectiveTracker = {GetExistingBlock = function(_, questId) return questBlocks[questId] end}
        _G.CampaignQuestObjectiveTracker = {GetExistingBlock = function(_, questId) return campaignBlocks[questId] end}
        _G.C_Map = {GetBestMapForUnit = function() return playerMap end}
        compat = QuestieLoader:ImportModule("QuestieCompat")
        compatOriginals = {GetQuestUiMapID = compat.GetQuestUiMapID, OpenWorldMap = compat.OpenWorldMap}
        compat.GetQuestUiMapID = function(questId) return questMaps[questId] end
        compat.OpenWorldMap = spy.new(function() end)
        _G.InputUtil = {IsGamepadUIEnabled = function() return false end}
        _G.RegisterStateDriver = spy.new(function() end)
        _G.CreateFrame = function()
            overlay = _FakeFrame()
            return overlay
        end
        Questie.IsForever = true
        Questie.db = {profile = {trackerbindOpenQuestLog = "left"}}

        menuBuilder = QuestieLoader:ImportModule("QuestieMenuBuilder")
        menuBuilder.IsOpen = function() return false end
        menuBuilder.Close = spy.new(function() end)

        dofile("Modules/Tracker/TrackerShortcuts.lua")
        dofile("Modules/Tracker/LinePool/TrackerQuestLogButton.lua")
        TrackerQuestLogButton = QuestieLoader:ImportModule("TrackerQuestLogButton")
        TrackerQuestLogButton.Initialize()
    end)

    after_each(function()
        _G.CreateFrame = originals.CreateFrame
        _G.RegisterStateDriver = originals.RegisterStateDriver
        _G.InCombatLockdown = originals.InCombatLockdown
        _G.InputUtil = originals.InputUtil
        _G.IsShiftKeyDown = originals.IsShiftKeyDown
        _G.IsControlKeyDown = originals.IsControlKeyDown
        _G.IsAltKeyDown = originals.IsAltKeyDown
        _G.QuestLogQuests_GetQuestButton = originals.QuestLogQuests_GetQuestButton
        _G.C_QuestLog = originals.C_QuestLog
        _G.C_Map = originals.C_Map
        _G.IsModifiedClick = originals.IsModifiedClick
        _G.QuestObjectiveTracker = originals.QuestObjectiveTracker
        _G.CampaignQuestObjectiveTracker = originals.CampaignQuestObjectiveTracker
        compat.GetQuestUiMapID, compat.OpenWorldMap = compatOriginals.GetQuestUiMapID, compatOriginals.OpenWorldMap
        Questie.IsForever = nil
    end)

    local function _Attach(line)
        TrackerQuestLogButton.Attach(line)
        return line
    end

    describe("Initialize", function()
        it("should not create a button outside of Forever", function()
            overlay = nil
            Questie.IsForever = false
            dofile("Modules/Tracker/LinePool/TrackerQuestLogButton.lua")
            QuestieLoader:ImportModule("TrackerQuestLogButton").Initialize()

            assert.is_nil(overlay)
        end)

        it("should hide the button in combat through the secure state driver", function()
            assert.spy(_G.RegisterStateDriver).was.called_with(match.is_ref(overlay), "visibility", "[combat] hide; show")
            assert.are_same({"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, overlay.events)
        end)

        it("should leave the line right before the combat starts, so the tracker does not get protected by the button", function()
            local line = _Attach(_QuestLine())

            overlay.scripts.OnEvent(overlay, "PLAYER_REGEN_DISABLED")

            assert.are_same(1, #overlay.points)
            assert.are_not_equal(line, overlay.points[1].relativeTo)
        end)

        it("should act on the release of the click, whatever the key down CVar says", function()
            assert.is_false(overlay.attributes.useOnKeyDown)
        end)

        it("should move the button away when the combat ends", function()
            _Attach(_QuestLine())

            overlay.scripts.OnEvent(overlay, "PLAYER_REGEN_ENABLED")

            assert.are_same(1, overlay.width)
            assert.is_false(TrackerQuestLogButton.IsHovering(_QuestLine()))
        end)
    end)

    describe("Attach", function()
        it("should cover the line from where its label starts, anchored to the line as protected frames can not be anchored to regions", function()
            local line = _Attach(_QuestLine())

            assert.are_same({{point = "TOPLEFT", relativeTo = line, x = 25, y = -1}, {point = "BOTTOMRIGHT", relativeTo = line, x = 0, y = 0}}, overlay.points)
            assert.are_same("MEDIUM", overlay.strata)
            assert.are_same(7, overlay.level)
        end)

        it("should not cover a line that is no quest line", function()
            local line = _QuestLine()
            line.onClickMode = "achieve"

            _Attach(line)

            assert.are_same(1, overlay.width)
            assert.are_same(1, #overlay.points)
        end)

        it("should not cover a line without a quest", function()
            local line = _QuestLine()
            line.Quest = nil

            _Attach(line)

            assert.are_same(1, #overlay.points)
        end)

        it("should not cover a line in combat", function()
            combat = true

            _Attach(_QuestLine())

            assert.are_same(1, #overlay.points)
        end)

        it("should not cover a line in the gamepad UI", function()
            _G.InputUtil = {IsGamepadUIEnabled = function() return true end}

            _Attach(_QuestLine())

            assert.are_same(1, #overlay.points)
        end)

        it("should not cover a line when opening the quest log is disabled", function()
            Questie.db.profile.trackerbindOpenQuestLog = "disabled"

            _Attach(_QuestLine())

            assert.are_same(1, #overlay.points)
        end)

        it("should not cover a line when the quest log is bound to Shift + Left Click, which toggles the tracking on Blizzard's quest title", function()
            Questie.db.profile.trackerbindOpenQuestLog = "shiftleft"

            _Attach(_QuestLine())

            assert.are_same(1, #overlay.points)
        end)

        it("should not cover a line when the quest log is bound to a Right Click, which opens a menu on Blizzard's quest title", function()
            Questie.db.profile.trackerbindOpenQuestLog = "right"

            _Attach(_QuestLine())

            assert.are_same(1, #overlay.points)
        end)

        it("should move the button away on Detach", function()
            _Attach(_QuestLine())

            TrackerQuestLogButton.Detach()

            assert.are_same(1, #overlay.points)
            assert.are_same(1, overlay.width)
        end)
    end)

    describe("click", function()
        local titleButton

        before_each(function()
            titleButton = {}
            questTitles[783] = titleButton
        end)

        it("should select the quest, open its map and click its title in the map's quest log on the click bound to the quest log", function()
            local line = _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")
            overlay.scripts.PostClick(overlay, "LeftButton")

            assert.spy(_G.C_QuestLog.SetSelectedQuest).was.called_with(783)
            assert.spy(compat.OpenWorldMap).was.called_with(1429)
            assert.are_same("click", overlay.attributes.type)
            assert.are_equal(titleButton, overlay.attributes.clickbutton)
            assert.spy(line.scripts.OnClick).was_not.called()
        end)

        it("should click the quest's title on a Ctrl + Left Click bound to the quest log", function()
            Questie.db.profile.trackerbindOpenQuestLog = "ctrlleft"
            _G.IsControlKeyDown = function() return true end
            _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")

            assert.are_equal(titleButton, overlay.attributes.clickbutton)
        end)

        it("should click the quest's block in Blizzard's tracker when the map's quest log shows no title for the quest", function()
            questTitles[783] = nil
            local headerButton = {}
            questBlocks[783] = {HeaderButton = headerButton}
            _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")

            assert.spy(compat.OpenWorldMap).was.called_with(1429)
            assert.are_equal(headerButton, overlay.attributes.clickbutton)
        end)

        it("should click the quest's block in Blizzard's campaign tracker when the map's quest log shows no title for the quest", function()
            questTitles[783] = nil
            local headerButton = {}
            campaignBlocks[783] = {HeaderButton = headerButton}
            _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")

            assert.are_equal(headerButton, overlay.attributes.clickbutton)
        end)

        it("should not click the quest's block in Blizzard's tracker while the modifier that untracks the quest there is held", function()
            questTitles[783] = nil
            questBlocks[783] = {HeaderButton = {}}
            _G.IsModifiedClick = function(action) return action == "QUESTWATCHTOGGLE" end
            _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")

            assert.is_nil(overlay.attributes.type)
        end)

        it("should only open the map when neither the map's quest log nor Blizzard's tracker shows the quest", function()
            questTitles[783] = nil
            local line = _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")
            overlay.scripts.PostClick(overlay, "LeftButton")

            assert.spy(compat.OpenWorldMap).was.called_with(1429)
            assert.is_nil(overlay.attributes.type)
            assert.spy(line.scripts.OnClick).was_not.called()
        end)

        it("should open the map on the player's zone and click the quest's title there when the client knows no map for the quest", function()
            playerMap = 1411
            local title = {}
            questTitles[4974] = title
            _Attach(_QuestLine(4974))

            overlay.scripts.PreClick(overlay, "LeftButton")

            assert.spy(compat.OpenWorldMap).was.called_with(1411)
            assert.are_equal(title, overlay.attributes.clickbutton)
        end)

        it("should forward the click to the line when neither the quest nor the player has a map", function()
            local line = _Attach(_QuestLine(4974))

            overlay.scripts.PreClick(overlay, "LeftButton")
            overlay.scripts.PostClick(overlay, "LeftButton")

            assert.spy(compat.OpenWorldMap).was_not.called()
            assert.is_nil(overlay.attributes.type)
            assert.spy(line.scripts.OnClick).was.called_with(line, "LeftButton")
        end)

        it("should close an open menu before opening the quest log like a line click does", function()
            menuBuilder.IsOpen = function() return true end
            _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")

            assert.spy(menuBuilder.Close).was.called(1)
        end)

        it("should forward a click that does not open the quest log to the line", function()
            local line = _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "RightButton")
            overlay.scripts.PostClick(overlay, "RightButton")

            assert.spy(compat.OpenWorldMap).was_not.called()
            assert.is_nil(overlay.attributes.type)
            assert.spy(line.scripts.OnClick).was.called_with(line, "RightButton")
        end)

        it("should forward a modified click to the line, when only the plain click opens the quest log", function()
            _G.IsControlKeyDown = function() return true end
            local line = _Attach(_QuestLine())

            overlay.scripts.PreClick(overlay, "LeftButton")
            overlay.scripts.PostClick(overlay, "LeftButton")

            assert.is_nil(overlay.attributes.type)
            assert.spy(line.scripts.OnClick).was.called_with(line, "LeftButton")
        end)

        it("should not keep the clicked title of an earlier click for a click that does not open the quest log", function()
            local line = _Attach(_QuestLine())
            overlay.scripts.PreClick(overlay, "LeftButton")

            overlay.scripts.PreClick(overlay, "RightButton")
            overlay.scripts.PostClick(overlay, "RightButton")

            assert.is_nil(overlay.attributes.type)
            assert.is_nil(overlay.attributes.clickbutton)
            assert.spy(line.scripts.OnClick).was.called(1)
        end)

        it("should not open the quest log in combat", function()
            local line = _Attach(_QuestLine())
            combat = true

            overlay.scripts.PreClick(overlay, "LeftButton")
            overlay.scripts.PostClick(overlay, "LeftButton")

            assert.spy(compat.OpenWorldMap).was_not.called()
            assert.spy(line.scripts.OnClick).was.called_with(line, "LeftButton")
        end)
    end)

    describe("hover", function()
        it("should keep the line hovered while the mouse is on the button", function()
            local line = _Attach(_QuestLine())
            overlay.mouseOver = true

            assert.is_true(TrackerQuestLogButton.IsHovering(line))
        end)

        it("should not hold another line", function()
            _Attach(_QuestLine())
            overlay.mouseOver = true

            assert.is_false(TrackerQuestLogButton.IsHovering(_QuestLine()))
        end)

        it("should leave the line when the mouse left the line and the button", function()
            local line = _Attach(_QuestLine())
            line.mouseOver = false
            overlay.mouseOver = false

            overlay.scripts.OnLeave(overlay)

            assert.spy(line.scripts.OnLeave).was.called_with(line)
            assert.are_same(1, overlay.width)
        end)

        it("should stay on the line when the mouse is still on the button", function()
            local line = _Attach(_QuestLine())
            overlay.mouseOver = true

            overlay.scripts.OnLeave(overlay)

            assert.spy(line.scripts.OnLeave).was_not.called()
        end)

        it("should move away from a line the mouse is no longer over", function()
            local line = _Attach(_QuestLine())
            line.mouseOver = false

            overlay.scripts.OnUpdate(overlay, 1)

            assert.is_false(TrackerQuestLogButton.IsHovering(line))
            assert.are_same(1, overlay.width)
            assert.spy(line.scripts.OnLeave).was.called_with(line)
        end)

        it("should not leave a hidden line the mouse is still over", function()
            local line = _Attach(_QuestLine())
            line.visible = false

            overlay.scripts.OnUpdate(overlay, 1)

            assert.are_same(1, overlay.width)
            assert.spy(line.scripts.OnLeave).was_not.called()
        end)

        it("should move away from a line the mouse only reaches outside of the scroll frame", function()
            local line = _QuestLine()
            local scrollChild = _FakeFrame()
            local scrollFrame = _FakeFrame()
            line.parent, scrollChild.parent = scrollChild, scrollFrame
            scrollFrame.mouseOver = false
            _Attach(line)

            overlay.scripts.OnUpdate(overlay, 1)

            assert.are_same(1, overlay.width)
        end)

        it("should stay on a line the mouse is over", function()
            local line = _Attach(_QuestLine())
            overlay.mouseOver = true

            overlay.scripts.OnUpdate(overlay, 1)

            assert.are_same(2, #overlay.points)
            assert.is_true(TrackerQuestLogButton.IsHovering(line))
        end)
    end)
end)
