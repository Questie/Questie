dofile("setupTests.lua")

describe("QuestieFrame", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieFrame
    local QuestieFrame
    ---@type QuestieWaypoints
    local QuestieWaypoints

    ---@type IconFrame
    local QuestieFrameInstance

    before_each(function()
        Questie.db.profile = {
            enabled = true,
            enableMapIcons = true,
            enableMiniMapIcons = true,
            enableTurnins = true,
            enableObjectives = true,
            enableAvailable = true,
            showRepeatableQuests = true,
            showEventQuests = true,
            showDungeonQuests = true,
            showRaidQuests = true,
            showPvPQuests = true,
            enableAvailableItems = true,
            hideUnexploredMapIcons = false,
            hideUntrackedQuestsMapIcons = false,
        }

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsActiveEventQuest = function() return false end
        QuestieDB.IsDungeonQuest = function() return false end
        QuestieDB.IsRaidQuest = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieDB.IsRuneAndShouldBeHidden = function() return false end

        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.utils = {IsExplored = function() return true end}

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ShouldShowQuestNotes = function() return true end

        QuestieLoader:ImportModule("DailyQuests")

        QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")
        QuestieWaypoints.SetHighlighted = spy.new(function() end)

        dofile("Localization/l10n.lua")
        dofile("Modules/FramePool/QuestieFrame.lua")
        QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
        QuestieFrameInstance = {
            data = {
                Type = "monster",
                Id = 123,
            }
        }
    end)

    it("passes the clicked quest name and ID to the hide confirmation", function()
        local Popup = QuestieLoader:ImportModule("QuestiePopup")
        Popup.Show = spy.new(function() end)
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function(_, id)
            return "Quest " .. id
        end
        _G.WorldMapFrame = {IsShown = function() return false end}
        _G.ChatEdit_GetActiveWindow = function() return nil end
        _G.IsShiftKeyDown = function() return true end
        _G.IsControlKeyDown = function() return false end
        QuestieFrameInstance.UiMapID = 1
        QuestieFrameInstance.data.Type = "available"

        QuestieFrame.private.OnClick(QuestieFrameInstance, "LeftButton")

        assert.spy(Popup.Show).was.called_with("QUESTIE_CONFIRMHIDE",
            "Are you sure you want to hide the quest 'Quest 123'?\nIf this quest isn't actually available, please report it to us!", nil, 123)
    end)

    it("should not change the world map on right click", function()
        local originalWorldMapFrame, originalIsModifierKeyDown, originalIsControlKeyDown = _G.WorldMapFrame, _G.IsModifierKeyDown, _G.IsControlKeyDown
        _G.WorldMapFrame = {
            IsShown = function() return true end,
            GetMapID = function() return 2 end,
            SetMapID = spy.new(function() end),
        }
        _G.IsModifierKeyDown = function() return false end
        _G.IsControlKeyDown = function() return false end
        QuestieFrameInstance.UiMapID = 1

        QuestieFrame.private.OnClick(QuestieFrameInstance, "RightButton")

        assert.spy(WorldMapFrame.SetMapID).was_not.called()
        _G.WorldMapFrame, _G.IsModifierKeyDown, _G.IsControlKeyDown = originalWorldMapFrame, originalIsModifierKeyDown, originalIsControlKeyDown
    end)

    it("should let the client switch the world map to the icon's zone on left click", function()
        local originalWorldMapFrame, originalIsModifierKeyDown, originalIsControlKeyDown = _G.WorldMapFrame, _G.IsModifierKeyDown, _G.IsControlKeyDown
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        local originalOpenWorldMap = QuestieCompat.OpenWorldMap
        QuestieCompat.OpenWorldMap = spy.new(function() end)
        _G.WorldMapFrame = {
            IsShown = function() return true end,
            GetMapID = function() return 2 end,
            SetMapID = spy.new(function() end),
        }
        _G.IsModifierKeyDown = function() return false end
        _G.IsControlKeyDown = function() return false end
        QuestieFrameInstance.UiMapID = 1

        QuestieFrame.private.OnClick(QuestieFrameInstance, "LeftButton")

        assert.spy(QuestieCompat.OpenWorldMap).was.called_with(1)
        assert.spy(WorldMapFrame.SetMapID).was_not.called()
        QuestieCompat.OpenWorldMap = originalOpenWorldMap
        _G.WorldMapFrame, _G.IsModifierKeyDown, _G.IsControlKeyDown = originalWorldMapFrame, originalIsModifierKeyDown, originalIsControlKeyDown
    end)

    describe("EnsureRightClickPassThrough", function()
        local match = require("luassert.match")
        local stub = require("luassert.stub")
        local originalInCombatLockdown, queueMock, queued

        before_each(function()
            originalInCombatLockdown = _G.InCombatLockdown
            local passThroughButtons = {}
            QuestieFrameInstance.SetPassThroughButtons = spy.new(function(_, ...)
                passThroughButtons = {}
                for _, button in ipairs({...}) do
                    passThroughButtons[button] = true
                end
            end)
            QuestieFrameInstance.ShouldButtonPassThrough = function(_, button)
                return passThroughButtons[button] == true
            end
            queued = {}
            queueMock = stub(QuestieLoader:ImportModule("QuestieCombatQueue"), "Queue", function(_, func, ...)
                queued[#queued + 1] = {func = func, args = {...}}
                return true
            end)
        end)

        after_each(function()
            _G.InCombatLockdown = originalInCombatLockdown
            queueMock:revert()
        end)

        local function runQueued()
            local entries = queued
            queued = {}
            for _, entry in ipairs(entries) do
                entry.func(unpack(entry.args))
            end
        end

        it("should pass right clicks through out of combat only once", function()
            _G.InCombatLockdown = function() return false end

            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)
            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)

            assert.spy(QuestieFrameInstance.SetPassThroughButtons).was.called(1)
            assert.spy(QuestieFrameInstance.SetPassThroughButtons).was.called_with(match.is_ref(QuestieFrameInstance), "RightButton")
            assert.are.equal(0, #queued)
        end)

        it("should defer passing right clicks through while in combat and queue a retry once", function()
            _G.InCombatLockdown = function() return true end

            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)
            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)

            assert.spy(QuestieFrameInstance.SetPassThroughButtons).was_not.called()
            assert.are.equal(1, #queued)
        end)

        it("should pass right clicks through when the queued retry runs after combat", function()
            _G.InCombatLockdown = function() return true end
            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)
            _G.InCombatLockdown = function() return false end

            runQueued()

            assert.spy(QuestieFrameInstance.SetPassThroughButtons).was.called_with(match.is_ref(QuestieFrameInstance), "RightButton")
        end)

        it("should queue again when combat starts before the retry runs", function()
            _G.InCombatLockdown = function() return true end
            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)

            runQueued()

            assert.spy(QuestieFrameInstance.SetPassThroughButtons).was_not.called()
            assert.are.equal(1, #queued)
        end)

        it("should queue a retry on a later call when the queue was not started yet", function()
            _G.InCombatLockdown = function() return true end
            local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
            queueMock:revert()
            queueMock = stub(QuestieCombatQueue, "Queue", function() return false end)
            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)
            queueMock:revert()
            queueMock = stub(QuestieCombatQueue, "Queue", function() return true end)

            QuestieFrame.EnsureRightClickPassThrough(QuestieFrameInstance)

            assert.stub(queueMock).was.called(1)
        end)
    end)

    describe("ResetHoverHighlights", function()
        it("should end the highlight of the NPC's waypoint paths", function()
            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.spy(QuestieWaypoints.SetHighlighted).was.called_with(QuestieFrameInstance.data, false)
        end)

        it("should restore touched pins in reverse order and clear them", function()
            local restored = {}
            local function CreateTouchedPin(name, color)
                return {
                    icon = {texture = {SetVertexColor = function() table.insert(restored, name) end}},
                    color = color,
                }
            end
            QuestieFrameInstance.data.touchedPins = {CreateTouchedPin("first", {1, 1, 1, 1}), CreateTouchedPin("second", {1, 1, 1, 1})}

            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.are_same({"second", "first"}, restored)
            assert.is_nil(QuestieFrameInstance.data.touchedPins)
        end)

        it("should do nothing without highlights", function()
            QuestieFrame.ResetHoverHighlights(QuestieFrameInstance)

            assert.is_nil(QuestieFrameInstance.data.touchedPins)
        end)
    end)

    describe("waypoint paths", function()
        before_each(function()
            QuestieWaypoints.OwnerChanged = spy.new(function() end)
        end)

        it("should redraw the icon's paths when it is fake hidden or shown", function()
            local shown = true
            QuestieFrameInstance.IsShown = function() return shown end
            QuestieFrameInstance.Hide = function() shown = false end
            QuestieFrameInstance.Show = function() shown = true end

            QuestieFrame.private.FakeHide(QuestieFrameInstance)
            assert.spy(QuestieWaypoints.OwnerChanged).was.called_with(QuestieFrameInstance)
            assert.is_true(QuestieFrameInstance.hidden)

            QuestieFrame.private.FakeShow(QuestieFrameInstance)
            assert.spy(QuestieWaypoints.OwnerChanged).was.called(2)
            assert.is_false(QuestieFrameInstance.hidden)
        end)

        it("should release the icon's paths and minimap twin when it unloads", function()
            local savedLibStub = _G.LibStub
            _G.LibStub = function() return {RemoveMinimapIcon = function() end, RemoveWorldMapIcon = function() end} end
            dofile("Modules/FramePool/QuestieFrame.lua")
            _G.LibStub = savedLibStub
            QuestieLoader:ImportModule("QuestieDBMIntegration").UnregisterHudQuestIcon = function() end
            QuestieMap.questIdFrames = {}
            QuestieWaypoints.RemoveOwner = spy.new(function() end)
            local function Region() return {Hide = function() end, SetVertexColor = function() end} end
            local icon = {_loaded = true, data = {Id = 123}, minimapTwin = {}, texture = Region(), glowTexture = Region(),
                overlayTexture = Region(), SetScript = function() end, GetName = function() return "QuestieFrame1" end,
                Hide = function() end}

            QuestieFrame.private.Unload(icon)

            -- Spies copy their arguments, and Unload clears the icon afterwards; compare the reference.
            assert.spy(QuestieWaypoints.RemoveOwner).was.called(1)
            assert.are.equal(icon, QuestieWaypoints.RemoveOwner.calls[1].refs[1])
            assert.is_nil(icon.minimapTwin)
        end)

        it("should forget that a flash hid the icon when it unloads", function()
            local savedLibStub = _G.LibStub
            _G.LibStub = function() return {RemoveMinimapIcon = function() end, RemoveWorldMapIcon = function() end} end
            dofile("Modules/FramePool/QuestieFrame.lua")
            _G.LibStub = savedLibStub
            QuestieLoader:ImportModule("QuestieDBMIntegration").UnregisterHudQuestIcon = function() end
            QuestieMap.questIdFrames = {}
            QuestieWaypoints.RemoveOwner = function() end
            local function Region() return {Hide = function() end, SetVertexColor = function() end} end
            local icon = {_loaded = true, _hidden_by_flash = true, data = {Id = 123}, texture = Region(), glowTexture = Region(),
                overlayTexture = Region(), SetScript = function() end, GetName = function() return "QuestieFrame1" end,
                Hide = function() end}

            QuestieFrame.private.Unload(icon)

            assert.is_nil(icon._hidden_by_flash)
        end)

        it("should release the icon's paths when it unloads while still waiting in the draw queue", function()
            QuestieWaypoints.RemoveOwner = spy.new(function() end)
            local icon = {data = {Id = 123}}

            QuestieFrame.private.Unload(icon)

            assert.spy(QuestieWaypoints.RemoveOwner).was.called(1)
            assert.are.equal(icon, QuestieWaypoints.RemoveOwner.calls[1].refs[1])
            assert.is_true(icon._needsUnload)
        end)

        it("should redraw the icon's paths when it fades", function()
            local function Texture()
                return {GetVertexColor = function() return 1, 1, 1, 1 end, SetVertexColor = function() end}
            end
            QuestieFrameInstance.texture, QuestieFrameInstance.glowTexture = Texture(), Texture()

            QuestieFrame.private.FadeOut(QuestieFrameInstance)
            QuestieFrame.private.FadeIn(QuestieFrameInstance)

            assert.spy(QuestieWaypoints.OwnerChanged).was.called(2)
        end)
    end)

    describe("ShouldBeHidden", function()
        it("should return true when all icons are disabled", function()
            Questie.db.profile.enabled = false

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame is map icon and map icons are disabled", function()
            Questie.db.profile.enableMapIcons = false
            QuestieFrameInstance.miniMapIcon = false

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame is minimap icon and minimap icons are disabled", function()
            Questie.db.profile.enableMiniMapIcons = false
            QuestieFrameInstance.miniMapIcon = true

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is complete and turn in icons are disabled", function()
            Questie.db.profile.enableTurnins = false
            QuestieFrameInstance.data.Type = "complete"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is monster and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "monster"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is object and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "object"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is event and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "event"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when icon type is item and objective icons are disabled", function()
            Questie.db.profile.enableObjectives = false
            QuestieFrameInstance.data.Type = "item"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when frame coords are unexplored and unexplored icons should be hidden", function()
            QuestieMap.utils.IsExplored = spy.new(function() return false end)
            Questie.db.profile.hideUnexploredMapIcons = true
            QuestieFrameInstance.UiMapID = 1
            QuestieFrameInstance.x = 50
            QuestieFrameInstance.y = 60

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
            assert.spy(QuestieMap.utils.IsExplored).was.called_with(1, 50, 60)
        end)

        it("should return false when frame coords are explored and unexplored icons should be hidden", function()
            QuestieMap.utils.IsExplored = spy.new(function() return true end)
            Questie.db.profile.hideUnexploredMapIcons = true
            QuestieFrameInstance.UiMapID = 1
            QuestieFrameInstance.x = 50
            QuestieFrameInstance.y = 60

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieMap.utils.IsExplored).was.called_with(1, 50, 60)
        end)

        it("should return true when quest notes should not be shown and untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return false end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Id = 123

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.called_with(QuestieQuest, 123)
        end)

        it("should return false when quest notes should be shown and untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return true end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Id = 123

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.called_with(QuestieQuest, 123)
        end)

        it("should return false for available icons when untracked icons should be hidden", function()
            QuestieQuest.ShouldShowQuestNotes = spy.new(function() return false end)
            Questie.db.profile.hideUntrackedQuestsMapIcons = true
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
            assert.spy(QuestieQuest.ShouldShowQuestNotes).was.not_called()
        end)

        it("should return true when ObjectiveData is set and icons should be hidden", function()
            QuestieFrameInstance.data.ObjectiveData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return true when QuestData is set and icons should be hidden for icons that are not complete", function()
            QuestieFrameInstance.data.Type = "monster"
            QuestieFrameInstance.data.QuestData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false when QuestData is set and icons should be hidden for complete icons", function()
            QuestieFrameInstance.data.Type = "complete"
            QuestieFrameInstance.data.QuestData = {HideIcons = true}

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when available icons should be hidden", function()
            Questie.db.profile.enableAvailable = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when available icons should be hidden but quest is repeatable", function()
            QuestieDB.IsRepeatable = function() return true end
            Questie.db.profile.enableAvailable = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when repeatable icons should be hidden", function()
            QuestieDB.IsRepeatable = function() return true end
            Questie.db.profile.showRepeatableQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when repeatable icons should be hidden but quest is normal", function()
            Questie.db.profile.showRepeatableQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when event icons should be hidden", function()
            QuestieDB.IsActiveEventQuest = function() return true end
            Questie.db.profile.showEventQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when event icons should be hidden but quest is normal", function()
            Questie.db.profile.showEventQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when dungeon icons should be hidden", function()
            QuestieDB.IsDungeonQuest = function() return true end
            Questie.db.profile.showDungeonQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when dungeon icons should be hidden but quest is normal", function()
            Questie.db.profile.showDungeonQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when raid icons should be hidden", function()
            QuestieDB.IsRaidQuest = function() return true end
            Questie.db.profile.showRaidQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when raid icons should be hidden but quest is normal", function()
            Questie.db.profile.showRaidQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when PvP icons should be hidden", function()
            QuestieDB.IsPvPQuest = function() return true end
            Questie.db.profile.showPvPQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when PvP icons should be hidden but quest is normal", function()
            Questie.db.profile.showPvPQuests = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when item drop icons should be hidden", function()
            Questie.db.profile.enableAvailableItems = false
            QuestieFrameInstance.data.Type = "available"
            QuestieFrameInstance.data.StarterType = "itemFromMonster"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when item drop icons should be hidden but quest is not started by a drop", function()
            Questie.db.profile.enableAvailableItems = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)

        it("should return true for available icons when quest is rune quest and should be hidden", function()
            Questie.IsSoD = true
            QuestieDB.IsRuneAndShouldBeHidden = function() return true end
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_true(result)
        end)

        it("should return false for available icons when not SoD", function()
            Questie.IsSoD = false
            QuestieFrameInstance.data.Type = "available"

            local result = QuestieFrame.private.ShouldBeHidden(QuestieFrameInstance)

            assert.is_false(result)
        end)
    end)
end)
