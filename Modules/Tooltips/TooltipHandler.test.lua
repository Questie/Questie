dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("TooltipHandler", function()
    ---@type l10n
    local l10n
    ---@type QuestieTooltips
    local QuestieTooltips
    local _QuestieTooltips

    local PLAYER_ZONE = 440
    local OBJECT_NAME = "Battered Chest"

    ---Installs GameTooltip spies for lines, ID double lines, and Show.
    ---@return nil
    local function _MockGameTooltip()
        _G.GameTooltip = {
            AddLine = spy.new(function() end),
            AddDoubleLine = spy.new(function() end),
            Show = spy.new(function() end),
        }
    end

    before_each(function()
        _G.Questie.db.profile.enableTooltips = true
        _G.Questie.db.profile.enableTooltipsObjectID = false
        _G.Questie.db.profile.debugEnabled = false
        _G.LibQuestieDB = {Object = {IdsByName = spy.new(function() return nil end)}}

        dofile("Localization/l10n.lua")
        l10n = QuestieLoader:ImportModule("l10n")

        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieTooltips.GetTooltip = spy.new(function() end)

        dofile("Modules/Tooltips/TooltipHandler.lua")
        _QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips").private
        _MockGameTooltip()
    end)

    after_each(function()
        _G.LibQuestieDB = nil
    end)

    describe("Comms registration through object hover", function()
        local QuestieComms, QuestieDB, mock, objectKeys
        local originalIsInGroup, originalUnitName, originalCTimer, originalGetQuestObjectives
        local REMOTE_QUEST_ID = 42
        local PARTY_LINE = "   gold1/3 Open the chest (|cFFFFFFFFBob|rgold)|r"

        before_each(function()
            originalIsInGroup, originalUnitName = _G.IsInGroup, _G.UnitName
            originalCTimer, originalGetQuestObjectives = _G.C_Timer, C_QuestLog.GetQuestObjectives
            _G.IsInGroup = function() return true end
            _G.UnitName = function() return "Local" end
            _G.C_Timer = {After = function() end}
            C_QuestLog.GetQuestObjectives = function() return {} end

            mock = LoadQuestieDBMock()
            objectKeys = mock.lib.Meta.ObjectMeta.objectKeys
            mock.SetBaseRow("Object", 1001, {
                [objectKeys.name] = OBJECT_NAME,
                [objectKeys.spawns] = {[PLAYER_ZONE] = {{10, 10}}},
            })
            QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            QuestieDB.QueryObjectSingle = mock.lib.Object.Get
            QuestieDB.GetQuest = function() return nil end
            local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
            QuestieLib.GetColoredQuestName = function() return "Party Quest" end
            QuestieLib.GetRGBForObjective = function() return "gold" end
            QuestieLib.GetLoadedQuestObjectives = function()
                return {{text = "Open the chest: 0/3", type = "object"}}
            end
            QuestieLib.GetFullObjectiveText = function() return "Open the chest" end
            QuestieLib.Count = function(_, values)
                local count = 0
                for _ in pairs(values) do count = count + 1 end
                return count
            end
            local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
            QuestiePlayer.currentQuestlog = {}
            QuestiePlayer.numberOfGroupMembers = 2
            QuestiePlayer.GetPartyMemberByName = function(_, name)
                if name == "Bob" then return {colorHex = "FFFFFFFF"} end
            end
            QuestieLoader:ImportModule("ZoneDB").GetParentZoneId = function() return nil end
            QuestieComms = QuestieLoader:ImportModule("QuestieComms")
            QuestieComms.data = {}
            QuestieComms.remotePlayerEnabled = {}
            QuestieComms.remotePlayerClasses = {}
            QuestieComms.remoteQuestLogs = {}

            -- Exercise both registries and the real rendering path, not a stubbed GetTooltip.
            dofile("Modules/Network/QuestieCommsData.lua")
            dofile("Modules/Tooltips/Tooltip.lua")
            QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
            dofile("Modules/Tooltips/TooltipHandler.lua")
            _QuestieTooltips = QuestieTooltips.private
            QuestieComms.data:RegisterTooltip(REMOTE_QUEST_ID, "Bob", {
                {type = "o", id = 1001, fulfilled = 1, required = 3},
            })
        end)

        after_each(function()
            _G.IsInGroup, _G.UnitName = originalIsInGroup, originalUnitName
            _G.C_Timer, C_QuestLog.GetQuestObjectives = originalCTimer, originalGetQuestObjectives
        end)

        it("shows a party-only objective without local registration and removes it when the party quest ends", function()
            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Party Quest")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, PARTY_LINE)
            assert.spy(GameTooltip.AddLine).was.called(2)
            assert.is_nil(next(QuestieTooltips.lookupByKey))

            QuestieComms.data:RemoveQuestFromPlayer(REMOTE_QUEST_ID, "Bob")
            _MockGameTooltip()
            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)
            assert.spy(GameTooltip.AddLine).was.not_called()
        end)

        it("keeps party lines after local tooltip data is removed", function()
            QuestieTooltips:RegisterObjectiveTooltip(7, "o_1001", {Index = 1})
            QuestieTooltips:RemoveQuest(7)

            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

            assert.is_nil(next(QuestieTooltips.lookupByKey))
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, PARTY_LINE)
            assert.spy(GameTooltip.AddLine).was.called(2)
        end)

        it("filters party objectives for namesakes by zone, including a dungeon's parent area", function()
            mock.SetBaseRow("Object", 2002, {
                [objectKeys.name] = OBJECT_NAME,
                [objectKeys.spawns] = {[12] = {{20, 20}}},
            })
            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, 12)
            assert.spy(GameTooltip.AddLine).was.not_called()

            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, PARTY_LINE)

            _MockGameTooltip()
            QuestieLoader:ImportModule("ZoneDB").GetParentZoneId = function(_, areaId)
                if areaId == 999 then return PLAYER_ZONE end
            end
            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, 999)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, PARTY_LINE)
        end)

        it("moves local objective lines to a corrected name without re-registering the objective", function()
            _G.IsInGroup = function() return false end
            QuestieLoader:ImportModule("QuestiePlayer").currentQuestlog[7] = {}
            QuestieDB.GetItemDroprate = function() return nil end
            local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
            QuestieLib.GetColoredQuestName = function() return "Local Quest" end
            QuestieLib.GetObjectiveDescription = function(_, objective) return objective.Description end
            QuestieTooltips:RegisterObjectiveTooltip(7, "o_1001", {
                Index = 1, Id = 1001, Type = "object", Description = "Open the chest", Update = function() end,
            })
            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "   goldOpen the chest")

            mock.lib.Corrections.Set("Test", "Object", "rename", {[1001] = {[objectKeys.name] = "Renamed Chest"}})
            _MockGameTooltip()
            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)
            assert.spy(GameTooltip.AddLine).was.not_called()

            _QuestieTooltips.AddObjectDataToTooltip("Renamed Chest", PLAYER_ZONE)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Local Quest")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "   goldOpen the chest")
            assert.spy(GameTooltip.AddLine).was.called(2)
        end)
    end)

    describe("AddObjectDataToTooltip", function()
        describe("quest lines for provider-matched Objects", function()
            it("should show objectives without a zone filter for a provider-wide unique name", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1001} end)
                QuestieTooltips.GetTooltip = spy.new(function()
                    return {"Quest Name", "0/1 Test Objective", "0/1 Other Objective"}
                end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddLine).was.called(3)
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Test Objective")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Other Objective")
                assert.spy(GameTooltip.Show).was.called()
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1001", 0)
            end)

            it("should deduplicate lines across Objects sharing the hovered name", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2} end)
                QuestieTooltips.GetTooltip = spy.new(function(key)
                    if key == "o_1" then
                        return {"Quest Name"}
                    elseif key == "o_2" then
                        return {"Quest Name", "Quest Name 2"}
                    end
                end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddLine).was.called(2)
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name 2")
                assert.spy(GameTooltip.Show).was.called()
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1", PLAYER_ZONE)
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_2", PLAYER_ZONE)
            end)

            it("should stop after ten Objects with tooltip data", function()
                local providerIds = {}
                for objectId = 1, 11 do
                    providerIds[objectId] = objectId
                end
                LibQuestieDB.Object.IdsByName = spy.new(function() return providerIds end)
                QuestieTooltips.GetTooltip = spy.new(function() return {"Quest Name"} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(QuestieTooltips.GetTooltip).was.called(10)
            end)

            it("should add nothing for an unknown name", function()
                _QuestieTooltips.AddObjectDataToTooltip("Unknown Object", PLAYER_ZONE)

                assert.spy(QuestieTooltips.GetTooltip).was.not_called()
                assert.spy(GameTooltip.AddLine).was.not_called()
                assert.spy(GameTooltip.Show).was.called()
            end)
        end)

        describe("Object ID line from the provider name index", function()
            before_each(function()
                _G.Questie.db.profile.enableTooltipsObjectID = true
            end)

            it("should show a single Object ID", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(LibQuestieDB.Object.IdsByName).was.called_with(OBJECT_NAME)
                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1|r")
            end)

            it("should show the first ID with the count for several Objects", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (2)|r")
            end)

            it("should cap the count at 10+ outside debug mode", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (10+)|r")
            end)

            it("should show the full count above ten in debug mode", function()
                _G.Questie.db.profile.debugEnabled = true
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (11)|r")
            end)

            it("should add no Object ID line when the provider knows no Object with that name", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return nil end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(GameTooltip.AddDoubleLine).was.not_called()
            end)

            it("should count all matching Objects even when only one has quest lines", function()
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1, 2, 3} end)
                QuestieTooltips.GetTooltip = spy.new(function(key)
                    if key == "o_1" then return {"Quest Name"} end
                end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(LibQuestieDB.Object.IdsByName).was.called(1)
                assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (3)|r")
                assert.spy(QuestieTooltips.GetTooltip).was.called(3)
                assert.spy(GameTooltip.AddLine).was.called(1)
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
            end)
        end)

        for _, enableObjectID in ipairs({false, true}) do
            it("should hide wrong-zone quest lines with Object IDs " .. tostring(enableObjectID), function()
                Questie.db.profile.enableTooltipsObjectID = enableObjectID
                LibQuestieDB.Object.IdsByName = spy.new(function() return {1001, 2002} end)
                -- Only the Object in zone 12 has quest lines; its namesake is in the player's zone.
                ---@param key string
                ---@param zoneFilter AreaId
                ---@return string[]?
                QuestieTooltips.GetTooltip = spy.new(function(key, zoneFilter)
                    if key == "o_1001" and (zoneFilter == 0 or zoneFilter == 12) then
                        return {"Wrong-zone quest"}
                    end
                end)

                _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

                assert.spy(LibQuestieDB.Object.IdsByName).was.called(1)
                assert.spy(LibQuestieDB.Object.IdsByName).was.called_with(OBJECT_NAME)
                assert.spy(QuestieTooltips.GetTooltip).was.called(2)
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1001", PLAYER_ZONE)
                assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_2002", PLAYER_ZONE)
                assert.spy(GameTooltip.AddLine).was.not_called()
            end)
        end

        it("should not render Object IDs while the Object ID setting is disabled", function()
            LibQuestieDB.Object.IdsByName = spy.new(function() return {1} end)

            _QuestieTooltips.AddObjectDataToTooltip(OBJECT_NAME, PLAYER_ZONE)

            assert.spy(LibQuestieDB.Object.IdsByName).was.called_with(OBJECT_NAME)
            assert.spy(GameTooltip.AddDoubleLine).was.not_called()
        end)
    end)
end)
