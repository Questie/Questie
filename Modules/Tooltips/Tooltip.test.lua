dofile("setupTests.lua")

describe("Tooltip", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieTooltips
    local QuestieTooltips
    local cached

    local objective = {
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }
    local specialObjective = {
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }

    before_each(function()
        Questie.db.profile = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetItemDroprate = function () return nil end
        QuestieDB.GetQuest = spy.new(function(questId)
            return {
                Id = questId,
                Objectives = {
                    [1] = objective,
                },
                SpecialObjectives = {
                    [1] = specialObjective,
                },
            }
        end)
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = spy.new(function()
            return "Quest Name"
        end)
        QuestieLib.GetRGBForObjective = spy.new(function()
            return "gold"
        end)
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestieComms.remotePlayerClasses = {}
        QuestieComms.remotePlayerEnabled = {}
        QuestieComms.data = {
            KeyExists = function() return false end,
            GetTooltip = function() return {} end
        }
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetPartyMemberByName = function() return nil end
        QuestiePlayer.currentQuestlog = {}
        QuestiePlayer.numberOfGroupMembers = 0
        cached = {}
        QuestieLoader:ImportModule("QuestLogCache").TryGetQuest = function(id) return cached[id] end
        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetParentZoneId = function() return nil end
        dofile("Localization/l10n.lua")

        dofile("Modules/Tooltips/Tooltip.lua")
        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
    end)

    describe("Initialize", function()
        local savedGlobals
        local originalItemHandler
        local originalUnitHandler
        local originalObjectHandler
        local originalGetCurrentZoneId
        local gameScripts
        local itemScripts

        before_each(function()
            savedGlobals = {
                GameTooltip = _G.GameTooltip,
                ItemRefTooltip = _G.ItemRefTooltip,
                TooltipDataProcessor = _G.TooltipDataProcessor,
                Enum = _G.Enum,
                issecretvalue = _G.issecretvalue,
                issecrettable = _G.issecrettable,
                GameTooltipTextLeft1 = _G.GameTooltipTextLeft1,
            }
            gameScripts = {}
            itemScripts = {}
            _G.GameTooltip = {
                HookScript = spy.new(function(_, name, callback) gameScripts[name] = callback end),
                HasScript = function() return true end,
                IsForbidden = function() return false end,
                Show = spy.new(function() end),
            }
            _G.ItemRefTooltip = {
                HookScript = function(_, name, callback) itemScripts[name] = callback end,
                HasScript = function() return true end,
            }
            originalItemHandler = QuestieTooltips.private.AddItemDataToTooltip
            originalUnitHandler = QuestieTooltips.private.AddUnitDataToTooltip
            QuestieTooltips.private.AddItemDataToTooltip = spy.new(function() end)
            QuestieTooltips.private.AddUnitDataToTooltip = spy.new(function() end)
            originalObjectHandler = QuestieTooltips.private.AddObjectDataToTooltip
            originalGetCurrentZoneId = QuestiePlayer.GetCurrentZoneId
            QuestieTooltips.private.AddObjectDataToTooltip = spy.new(function() end)
            QuestiePlayer.GetCurrentZoneId = spy.new(function() return 440 end)
            Questie.db.profile.enableTooltips = true
            _G.issecretvalue = nil
            _G.issecrettable = nil
        end)

        after_each(function()
            _G.GameTooltip = savedGlobals.GameTooltip
            _G.ItemRefTooltip = savedGlobals.ItemRefTooltip
            _G.TooltipDataProcessor = savedGlobals.TooltipDataProcessor
            _G.Enum = savedGlobals.Enum
            _G.issecretvalue = savedGlobals.issecretvalue
            _G.issecrettable = savedGlobals.issecrettable
            _G.GameTooltipTextLeft1 = savedGlobals.GameTooltipTextLeft1
            QuestieTooltips.private.AddItemDataToTooltip = originalItemHandler
            QuestieTooltips.private.AddUnitDataToTooltip = originalUnitHandler
            QuestieTooltips.private.AddObjectDataToTooltip = originalObjectHandler
            QuestiePlayer.GetCurrentZoneId = originalGetCurrentZoneId
        end)

        it("routes modern callbacks only to supported tooltips and skips unit work in raids", function()
            local callbacks = {}
            _G.Enum = {TooltipDataType = {Item = 0, Unit = 2, Object = 4}}
            GameTooltip.GetPrimaryTooltipData = function() return {} end
            _G.TooltipDataProcessor = {
                AddTooltipPostCall = function(kind, callback) callbacks[kind] = callback end,
            }

            QuestieTooltips:Initialize()
            callbacks[0](GameTooltip)
            callbacks[0](ItemRefTooltip)
            callbacks[0]({})
            callbacks[2](GameTooltip)
            callbacks[2](ItemRefTooltip)
            callbacks[2]({})
            QuestiePlayer.numberOfGroupMembers = 7
            callbacks[2](GameTooltip)

            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called(2)
            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called_with(GameTooltip)
            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called_with(ItemRefTooltip)
            assert.spy(QuestieTooltips.private.AddUnitDataToTooltip).was.called(1)
            assert.spy(QuestieTooltips.private.AddUnitDataToTooltip).was.called_with(GameTooltip)
            assert.is_nil(gameScripts.OnTooltipSetItem)
            assert.is_nil(gameScripts.OnTooltipSetUnit)
            assert.is_nil(itemScripts.OnTooltipSetItem)
            assert.is_nil(gameScripts.OnUpdate)
            assert.is_function(callbacks[4])
        end)

        it("retains the Classic tooltip-set scripts when the modern processor is absent", function()
            _G.TooltipDataProcessor = nil

            QuestieTooltips:Initialize()
            gameScripts.OnTooltipSetItem(GameTooltip)
            itemScripts.OnTooltipSetItem(ItemRefTooltip)
            gameScripts.OnTooltipSetUnit(GameTooltip)

            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called(2)
            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called_with(GameTooltip)
            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called_with(ItemRefTooltip)
            assert.spy(QuestieTooltips.private.AddUnitDataToTooltip).was.called_with(GameTooltip)
            assert.is_function(gameScripts.OnUpdate)
        end)

        it("uses native scripts on Classic even when the shared processor exists", function()
            _G.Enum = {TooltipDataType = {Item = 0, Unit = 2, Object = 4}}
            _G.TooltipDataProcessor = {AddTooltipPostCall = spy.new(function() end)}

            QuestieTooltips:Initialize()
            gameScripts.OnTooltipSetItem(GameTooltip)
            itemScripts.OnTooltipSetItem(ItemRefTooltip)
            gameScripts.OnTooltipSetUnit(GameTooltip)

            assert.spy(TooltipDataProcessor.AddTooltipPostCall).was.not_called()
            assert.spy(QuestieTooltips.private.AddItemDataToTooltip).was.called(2)
            assert.spy(QuestieTooltips.private.AddUnitDataToTooltip).was.called_with(GameTooltip)
            assert.is_function(gameScripts.OnUpdate)
        end)

        it("does not hook unavailable tooltip-set scripts", function()
            _G.TooltipDataProcessor = nil
            GameTooltip.HasScript = function() return false end
            ItemRefTooltip.HasScript = function() return false end

            QuestieTooltips:Initialize()

            assert.is_nil(gameScripts.OnTooltipSetItem)
            assert.is_nil(gameScripts.OnTooltipSetUnit)
            assert.is_nil(itemScripts.OnTooltipSetItem)
        end)

        describe("Classic object polling", function()
            local originalProvider, originalGetTooltip
            local caption

            before_each(function()
                originalProvider = _G.LibQuestieDB
                originalGetTooltip = QuestieTooltips.GetTooltip
                _G.LibQuestieDB = {Object = {IdsByName = spy.new(function() return {1001} end)}}
                QuestieTooltips.GetTooltip = spy.new(function() return {"Quest objective"} end)
                _G.TooltipDataProcessor = nil
                GameTooltip.GetUnit = spy.new(function() end)
                GameTooltip.GetItem = spy.new(function() end)
                GameTooltip.GetSpell = spy.new(function() end)
                GameTooltip.NumLines = function() return 1 end
                GameTooltip.AddLine = spy.new(function()
                    assert.spy(GameTooltip.Show).was.not_called()
                end)
                caption = "Battered Chest"
                _G.GameTooltipTextLeft1 = {GetText = spy.new(function() return caption end)}
                -- Keep the real handler so its early exits and Object state participate in polling.
                dofile("Modules/Tooltips/TooltipHandler.lua")
                QuestieTooltips:Initialize()
            end)

            after_each(function()
                _G.LibQuestieDB = originalProvider
                QuestieTooltips.GetTooltip = originalGetTooltip
            end)

            it("shows the tooltip after adding lines without repeating unchanged work", function()
                gameScripts.OnUpdate(GameTooltip)
                gameScripts.OnUpdate(GameTooltip)

                assert.spy(LibQuestieDB.Object.IdsByName).was.called_with("Battered Chest")
                assert.spy(LibQuestieDB.Object.IdsByName).was.called(1)
                assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest objective")
                assert.spy(GameTooltip.Show).was.called(1)
            end)

            it("does not inspect or change the native tooltip while augmentation is disabled", function()
                Questie.db.profile.enableTooltips = false

                gameScripts.OnUpdate(GameTooltip)
                gameScripts.OnUpdate(GameTooltip)

                assert.spy(GameTooltip.GetUnit).was.not_called()
                assert.spy(GameTooltip.GetItem).was.not_called()
                assert.spy(GameTooltip.GetSpell).was.not_called()
                assert.spy(GameTooltipTextLeft1.GetText).was.not_called()
                assert.spy(QuestiePlayer.GetCurrentZoneId).was.not_called()
                assert.spy(LibQuestieDB.Object.IdsByName).was.not_called()
                assert.spy(GameTooltip.AddLine).was.not_called()
                assert.spy(GameTooltip.Show).was.not_called()
            end)

            it("does not show or augment a tooltip without a caption", function()
                caption = nil

                gameScripts.OnUpdate(GameTooltip)
                gameScripts.OnUpdate(GameTooltip)

                assert.spy(QuestiePlayer.GetCurrentZoneId).was.not_called()
                assert.spy(LibQuestieDB.Object.IdsByName).was.not_called()
                assert.spy(GameTooltip.AddLine).was.not_called()
                assert.spy(GameTooltip.Show).was.not_called()
            end)
        end)

        describe("structured Object callbacks", function()
            local callbacks
            local registration
            local primaryData

            before_each(function()
                callbacks = {}
                primaryData = {type = 4, dataInstanceID = 12, lines = {{leftText = "Battered Chest"}}}
                _G.Enum = {TooltipDataType = {Item = 0, Unit = 2, Object = 4}}
                registration = spy.new(function(kind, callback) callbacks[kind] = callback end)
                _G.TooltipDataProcessor = {
                    AddTooltipPostCall = function(kind, callback) registration(kind, callback) end,
                }
                GameTooltip.GetPrimaryTooltipData = function() return primaryData end
                QuestieTooltips:Initialize()
            end)

            it("resolves public primary Object text without touching legacy getters or FontStrings", function()
                -- None of the legacy getters or FontStrings exist on this frame.
                callbacks[4](GameTooltip, primaryData)

                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.called_with("Battered Chest", 440)
                assert.spy(GameTooltip.Show).was.not_called()
                assert.is_nil(gameScripts.OnUpdate)
            end)

            it("adds once per clear, including a rebuild that reuses the same payload and instance ID", function()
                callbacks[4](GameTooltip, primaryData)
                gameScripts.OnShow(GameTooltip)
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.called(1)

                gameScripts.OnTooltipCleared(GameTooltip)
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.called(2)
            end)

            it("allows an object again after the frame is cleared and reused for a unit", function()
                callbacks[4](GameTooltip, primaryData)
                gameScripts.OnTooltipCleared(GameTooltip)
                primaryData = {type = 2, guid = "Creature-0-0-0-0-2955-0"}
                callbacks[2](GameTooltip, primaryData)
                gameScripts.OnTooltipCleared(GameTooltip)
                primaryData = {type = 4, lines = {{leftText = "Wanted Poster"}}}
                callbacks[4](GameTooltip, primaryData)

                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.called(2)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.called_with("Wanted Poster", 440)
            end)

            it("ignores scanning frames, ItemRefTooltip and appended Object blocks", function()
                callbacks[4]({}, primaryData)
                callbacks[4](ItemRefTooltip, primaryData)
                callbacks[4](GameTooltip, {type = 4, lines = {{leftText = "Appended caption"}}})

                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
                assert.spy(QuestiePlayer.GetCurrentZoneId).was.not_called()
            end)

            it("does not register more hooks or callbacks when initialized twice", function()
                QuestieTooltips:Initialize()

                assert.spy(registration).was.called(3)
                assert.spy(GameTooltip.HookScript).was.called(3)
            end)

            it("skips disabled tooltips without consuming a later enabled render", function()
                Questie.db.profile.enableTooltips = false
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
                Questie.db.profile.enableTooltips = true
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.called(1)
            end)

            it("leaves forbidden tooltips untouched", function()
                GameTooltip.IsForbidden = function() return true end
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestiePlayer.GetCurrentZoneId).was.not_called()
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
            end)

            it("leaves map-icon and raid tooltip policy unchanged", function()
                GameTooltip.ShownAsMapIcon = true
                callbacks[4](GameTooltip, primaryData)
                GameTooltip.ShownAsMapIcon = nil
                QuestiePlayer.numberOfGroupMembers = 7
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
            end)

            it("does not inspect a secret payload or a table with secret contents", function()
                local inaccessible = setmetatable({}, {__index = function() error("restricted read") end})
                _G.issecretvalue = function(value) return value == inaccessible end
                callbacks[4](GameTooltip, inaccessible)
                _G.issecretvalue = function() return false end
                _G.issecrettable = function(value) return value == inaccessible end
                callbacks[4](GameTooltip, inaccessible)

                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
            end)

            it("rejects an inaccessible primary payload before comparing or indexing it", function()
                local data = primaryData
                primaryData = setmetatable({}, {__index = function() error("restricted read") end})
                _G.issecrettable = function(value) return value == primaryData end
                callbacks[4](GameTooltip, data)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
            end)

            it("does not index restricted line containers or title rows", function()
                local inaccessible = setmetatable({}, {__index = function() error("restricted read") end})
                _G.issecrettable = function(value) return value == inaccessible end
                primaryData.lines = inaccessible
                callbacks[4](GameTooltip, primaryData)
                primaryData.lines = {inaccessible}
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
            end)

            it("does not send restricted text to provider name lookup", function()
                local secretText = "Restricted object name"
                _G.issecretvalue = function(value) return value == secretText end
                primaryData.lines[1].leftText = secretText
                callbacks[4](GameTooltip, primaryData)
                assert.spy(QuestiePlayer.GetCurrentZoneId).was.not_called()
                assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
            end)

            local incompletePayloads = {
                {name = "missing lines", data = {}},
                {name = "empty lines", data = {lines = {}}},
                {name = "missing title text", data = {lines = {{}}}},
                {name = "empty title text", data = {lines = {{leftText = ""}}}},
                {name = "non-string title text", data = {lines = {{leftText = 42}}}},
            }
            for _, case in ipairs(incompletePayloads) do
                it("ignores " .. case.name, function()
                    primaryData = case.data
                    callbacks[4](GameTooltip, primaryData)
                    assert.spy(QuestieTooltips.private.AddObjectDataToTooltip).was.not_called()
                end)
            end
        end)
    end)

    describe("GetTooltip", function()
        it("uses the quest ID when coloring the starter icon", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieLib.GetEffectiveQuestLevel = function() return 2 end
            QuestieLib.GetDifficultyColorPercent = spy.new(function() return 0.753, 0.753, 0.753 end)
            QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function() return false end
            QuestieDB.IsPvPQuest = function() return false end
            QuestieDB.IsRepeatable = function() return false end
            QuestieTooltips:RegisterQuestStartTooltip(94414, "Quest giver", 123, "m_123", "NPC")

            local tooltip = QuestieTooltips.GetTooltip("m_123")

            assert.spy(QuestieLib.GetDifficultyColorPercent).was.called_with(QuestieLib, 2, 94414)
            assert.are.same({
                "|TInterface\\Addons\\Questie\\Icons\\tooltip_available.png:14:14:0:0:32:32:0:32:0:32:192:192:192|tQuest Name",
            }, tooltip)
        end)

        it("should return quest name when tooltip has name set and showQuestsInNpcTooltip is active", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name"}, tooltip)
        end)

        it("should return empty tooltip when tooltip has name set but showQuestsInNpcTooltip is not active", function()
            Questie.db.profile.showQuestsInNpcTooltip = false
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was.not_called()
            assert.are_same({}, tooltip)
        end)

        it("should skip spawn reads when neither local nor party tooltip data is registered", function()
            QuestieTooltips.lookupByKey = {}
            QuestieDB.QueryObjectSingle = spy.new(function() return {[440] = {{10, 10}}} end)

            local tooltip = QuestieTooltips.GetTooltip("o_123", 440)

            assert.spy(QuestieDB.QueryObjectSingle).was.not_called()
            assert.spy(QuestieLib.GetColoredQuestName).was.not_called()
            assert.is_nil(tooltip)
        end)

        it("should use the objective player name for remote player class lookup", function()
            _G.UnitName = function() return "Local" end
            _G.IsInGroup = function() return true end
            Questie.GetClassColor = spy.new(function()
                return "|cFFC79C6E"
            end)
            QuestieTooltips.lookupByKey = {}
            QuestieComms.remotePlayerEnabled["Bob"] = true
            QuestieComms.remotePlayerClasses["Bob"] = "WARRIOR"
            QuestieComms.remoteQuestLogs[1] = { ["Bob"] = {} }
            QuestieComms.data.KeyExists = function(_, key)
                return key == "m_123"
            end
            QuestieComms.data.GetTooltip = function(_, key)
                if key == "m_123" then
                    return {
                        [1] = {
                            ["Bob"] = {
                                [1] = {
                                    fulfilled = 3,
                                    required = 5,
                                    text = "do it",
                                }
                            }
                        }
                    }
                end

                return {}
            end

            local tooltip = QuestieTooltips.GetTooltip("m_123")

            assert.is_nil(QuestieComms.remotePlayerClasses["Local"])
            assert.spy(Questie.GetClassColor).was.called_with(Questie, "WARRIOR")
            assert.are_same({
                "Quest Name",
                "   gold3/5 do it (|cFFC79C6EBob|rgold)|r (Nearby)",
            }, tooltip)
        end)

        it("should return quest name and objective when tooltip has spell objective", function()
            QuestieDB.QueryItemSingle = spy.new(function()
                return "Item Name"
            end)
            QuestieTooltips.lookupByKey = {["m_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Type = "spell",
                    Update = function() end,
                    spawnList = {[123] = {ItemId = 5}}
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("m_123")

            assert.spy(QuestieDB.QueryItemSingle).was.called_with(5, "name")
            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   goldItem Name"}, tooltip)
        end)

        it("keeps fallback wording and punctuation with one progress counter", function()
            QuestieTooltips.lookupByKey = {["key"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "Collect Windstone Clusters.",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   gold3/5 Collect Windstone Clusters."}, tooltip)
        end)

        describe("native objective wording", function()
            local liveObjective, originalIsInGroup, originalUnitName

            before_each(function()
                originalIsInGroup, originalUnitName = _G.IsInGroup, _G.UnitName
                _G.IsInGroup = function() return false end
                _G.UnitName = function() return "Local" end
                liveObjective = {Index = 3, Id = 25, Type = "item", Needed = 15, Collected = 9,
                    Description = "Windstone Cluster", Update = function() end}
                QuestieTooltips:RegisterObjectiveTooltip(1, "m_123", liveObjective)
                QuestiePlayer.currentQuestlog[1] = {}
            end)

            after_each(function()
                _G.IsInGroup, _G.UnitName = originalIsInGroup, originalUnitName
            end)

            it("preserves accepted local text at its native index and keeps the drop rate", function()
                Questie.db.profile.enableTooltipDroprates = true
                QuestieDB.GetItemDroprate = function() return {25} end
                cached[1] = {objectives = {[3] = {text = "9/15 Windstone Cluster."}}}

                local tooltip = QuestieTooltips.GetTooltip("m_123")

                assert.are.same({"Quest Name", "   gold9/15 Windstone Cluster.  |cFF999999[25%]|r"}, tooltip)
                assert.are.equal("9/15 Windstone Cluster.", cached[1].objectives[3].text)
            end)

            it("does not invent a counter for a native action instruction", function()
                liveObjective.Type, liveObjective.Collected, liveObjective.Needed = "object", 1, 1
                cached[1] = {objectives = {[3] = {text = "Use Walk on Air"}}}

                assert.are.same({"Quest Name", "   goldUse Walk on Air"}, QuestieTooltips.GetTooltip("m_123"))
            end)

            it("keeps a synthetic source item's text even when its index collides with native data", function()
                liveObjective.IsSourceItem = true
                liveObjective.Description, liveObjective.Collected, liveObjective.Needed = "Quest item", 0, 1
                cached[1] = {objectives = {[3] = {text = "9/15 Windstone Cluster"}}}

                assert.are.same({"Quest Name", "   gold0/1 Quest item"}, QuestieTooltips.GetTooltip("m_123"))
            end)

            it("falls back when the accepted snapshot lacks this objective index", function()
                cached[1] = {objectives = {[1] = {text = "Unrelated objective"}}}

                assert.are.same({"Quest Name", "   gold9/15 Windstone Cluster"}, QuestieTooltips.GetTooltip("m_123"))
            end)

            local remoteCases = {
                {name = "Forever", text = "9/15 Windstone Cluster", expected = "3/15 Windstone Cluster"},
                {name = "Classic", text = "Windstone Cluster: 9/15", expected = "Windstone Cluster: 3/15"},
                {name = "instruction without a counter", text = "Use Walk on Air", expected = "3/15 Fallback wording"},
            }
            for _, case in ipairs(remoteCases) do
                it("uses remote progress for " .. case.name, function()
                    _G.IsInGroup = function() return true end
                    QuestieTooltips.lookupByKey = {}
                    QuestiePlayer.GetPartyMemberByName = function(_, name)
                        if name == "Bob" then return {colorHex = "FFFFFFFF"} end
                    end
                    QuestieComms.data.KeyExists = function() return true end
                    local remote = {nativeText = case.text, text = "Fallback wording", fulfilled = 3, required = 15}
                    QuestieComms.data.GetTooltip = function() return {[1] = {Bob = {[3] = remote}}} end

                    local tooltip = QuestieTooltips.GetTooltip("m_123")

                    assert.are.same({"Quest Name", "   gold" .. case.expected .. " (|cFFFFFFFFBob|rgold)|r"}, tooltip)
                    assert.are.equal(case.text, remote.nativeText)
                end)
            end
        end)

        it("should return quest name and objective description when tooltip has objective without Needed", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return {[440]={{10,10}}}
            end)
            local playerZone = 440

            local tooltip = QuestieTooltips.GetTooltip("o_123", playerZone)

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   golddo it"}, tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was.called_with(123, "spawns")
        end)

        it("should return nil for objects which are not in the zone of the player", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {
                ["1 1"] = {questId = 1, name = "test", starterId = 2},
            }}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return {[1]={{10,10}}}
            end)
            local playerZone = 440

            local tooltip = QuestieTooltips.GetTooltip("o_123", playerZone)

            assert.is_nil(tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was.called_with(123, "spawns")
        end)

        it("should return tooltip for objects in the parent zone of the players zone", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return {[721]={{10,10}}} -- Gnomeregan
            end)
            local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
            ZoneDB.GetParentZoneId = spy.new(function(_, areaId)
                if areaId == 10030 then return 721 end
            end)
            local playerZone = 10030 -- Gnomeregan - The Dormitory

            local tooltip = QuestieTooltips.GetTooltip("o_123", playerZone)

            assert.are_same({"Quest Name", "   golddo it"}, tooltip)
            assert.spy(ZoneDB.GetParentZoneId).was.called_with(ZoneDB, 10030)
        end)

        it("should return quest name and objective description when players zone ID is 0", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function() end)
            local playerZone = 0

            local tooltip = QuestieTooltips.GetTooltip("o_123", playerZone)

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   golddo it"}, tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was.not_called()
        end)

        it("should return quest name and objective description when players zone ID is nil", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function() end)
            _G.Questie.Debug = spy.new(function() end)

            local tooltip = QuestieTooltips.GetTooltip("o_123", nil)

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   golddo it"}, tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was.not_called()
            assert.spy(Questie.Debug).was.called_with(Questie.DEBUG_CRITICAL, "[QuestieTooltips.GetTooltip] was called without a playerZone for objects")
        end)

        it("should return quest name and objective description when object has no spawn", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return nil
            end)
            local playerZone = 440

            local tooltip = QuestieTooltips.GetTooltip("o_123", playerZone)

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   golddo it"}, tooltip)
            assert.spy(QuestieDB.QueryObjectSingle).was.called_with(123, "spawns")
        end)

        it("should return quest name and objective description when object has an empty spawn table", function()
            QuestieTooltips.lookupByKey = {["o_123"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Description = "do it",
                    Update = function() end,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestieDB.QueryObjectSingle = spy.new(function()
                return {}
            end)
            local playerZone = 440

            local tooltip = QuestieTooltips.GetTooltip("o_123", playerZone)

            assert.are_same({"Quest Name", "   golddo it"}, tooltip)
        end)

        it("should only return quest name when tooltip has completed objective and showQuestsInNpcTooltip is true", function()
            Questie.db.profile.showQuestsInNpcTooltip = true
            QuestieTooltips.lookupByKey = {["key"] = {
                ["1 test 2"] = {
                    questId = 1,
                    name = "test",
                    starterId = 2
                },
                ["1 1"] = {
                    questId = 1,
                    objective = {
                        Index = 1,
                        Needed = 3,
                        Collected = 3,
                        Description = "do it",
                        Update = function() end,
                    }
                }
            }}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name"}, tooltip)
        end)

        it("should return quest name and objective description when tooltip has completed objective and showQuestsInNpcTooltip is false", function()
            Questie.db.profile.showQuestsInNpcTooltip = false
            QuestieTooltips.lookupByKey = {["key"] = {
                ["1 test 2"] = {
                    questId = 1,
                    name = "test",
                    starterId = 2
                },
                ["1 1"] = {
                    questId = 1,
                    objective = {
                        Index = 1,
                        Needed = 5,
                        Collected = 3,
                        Description = "do it",
                        Update = function() end,
                    }
                }
            }}
            QuestiePlayer.currentQuestlog[1] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.are_same({"Quest Name", "   gold3/5 do it"}, tooltip)
        end)

        it("should return multiple objectives for same key", function()
            QuestieLib.GetColoredQuestName = spy.new(function(_, questId)
                 if questId == 1 then return "Quest Name" else return "Quest Name 2" end
            end)
            QuestieTooltips.lookupByKey = {["key"] = {
                ["1 1"] = {
                    questId = 1,
                    objective = {
                        Index = 1,
                        Needed = 5,
                        Collected = 3,
                        Description = "do it",
                        Update = function() end,
                    }
                },
                ["1 2"] = {
                    questId = 1,
                    objective = {
                        Index = 2,
                        Needed = 1,
                        Collected = 0,
                        Description = "do something else",
                        Update = function() end,
                    }
                },
                ["2 1"] = {
                    questId = 2,
                    objective = {
                        Index = 1,
                        Needed = 10,
                        Collected = 10,
                        Description = "do something",
                        Update = function() end,
                    }
                }
            }}
            QuestiePlayer.currentQuestlog[1] = {}
            QuestiePlayer.currentQuestlog[2] = {}

            local tooltip = QuestieTooltips.GetTooltip("key")

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 1, nil, true)
            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, 2, nil, true)
            assert.are_same({
                "Quest Name", "   gold0/1 do something else", "   gold3/5 do it",
                "Quest Name 2", "   gold10/10 do something"
            }, tooltip)
        end)

        it("should not Update objective for IsSourceItem", function()
            local updateSpy = spy.new(function() end)
            QuestieTooltips.lookupByKey = {["key"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "do it",
                    IsSourceItem = true,
                    Update = updateSpy,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            QuestieTooltips.GetTooltip("key")

            assert.spy(updateSpy).was.not_called()
        end)

        it("should not Update objective for IsRequiredSourceItem", function()
            local updateSpy = spy.new(function() end)
            QuestieTooltips.lookupByKey = {["key"] = {["1 1"] = {
                questId = 1,
                objective = {
                    Index = 1,
                    Needed = 5,
                    Collected = 3,
                    Description = "do it",
                    IsRequiredSourceItem = true,
                    Update = updateSpy,
                }
            }}}
            QuestiePlayer.currentQuestlog[1] = {}

            QuestieTooltips.GetTooltip("key")

            assert.spy(updateSpy).was.not_called()
        end)
    end)

    describe("RemoveQuest", function()
        it("should reset tooltip flags without clearing AlreadySpawned", function()
            local objectiveAlreadySpawned = {[123] = {}}
            local specialObjectiveAlreadySpawned = {[456] = {}}
            objective.AlreadySpawned = objectiveAlreadySpawned
            specialObjective.AlreadySpawned = specialObjectiveAlreadySpawned
            QuestieTooltips.lookupKeysByQuestId = {[1] = {"key"}}
            QuestieTooltips.lookupByKey = {["key"] = {["1 test 2"] = {questId = 1, name = "test", starterId = 2}}}

            QuestieTooltips:RemoveQuest(1)

            assert.spy(QuestieDB.GetQuest).was.called_with(1)

            assert.are_same(false, objective.hasRegisteredTooltips)
            assert.are_same(false, objective.registeredItemTooltips)
            assert.is_equal(objectiveAlreadySpawned, objective.AlreadySpawned)
            assert.are_same({[123] = {}}, objective.AlreadySpawned)

            assert.are_same(false, specialObjective.hasRegisteredTooltips)
            assert.are_same(false, specialObjective.registeredItemTooltips)
            assert.is_equal(specialObjectiveAlreadySpawned, specialObjective.AlreadySpawned)
            assert.are_same({[456] = {}}, specialObjective.AlreadySpawned)

            assert.are_same({}, QuestieTooltips.lookupByKey)
            assert.are_same({}, QuestieTooltips.lookupKeysByQuestId)
        end)

        it("should do nothing when tooltip is already removed", function()
            QuestieTooltips.lookupKeysByQuestId = {[1] = {"key"}}

            QuestieTooltips:RemoveQuest(2)

            assert.spy(QuestieDB.GetQuest).was.not_called()
            assert.are_same({[1] = {"key"}}, QuestieTooltips.lookupKeysByQuestId)
        end)
    end)
end)
