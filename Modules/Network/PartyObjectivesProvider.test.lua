dofile("setupTests.lua")

describe("PartyObjectivesProvider", function()
    ---@type PartyObjectivesProvider
    local PartyObjectivesProvider
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestLogCache
    local QuestLogCache

    before_each(function()
        Questie.db.profile = {
            showPartyQuestObjectives = true,
            trimObjectiveText = false,
        }

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.remoteQuestLogs = {}

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function() return nil end
        QuestieDB.GetNPC = function() return nil end
        QuestieDB.GetObject = function() return nil end
        QuestieDB.GetItem = function() return nil end

        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.ColorWheel = function() return { 1, 1, 1 } end
        QuestieLib.GetFullObjectiveText = function(text) return text end

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.GetGroupType = function() return "party" end

        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        _G.GetNumGroupMembers = function() return 3 end
        _G.UnitIsConnected = function() return true end
        -- Default: the Blizzard quest data isn't cached, so the API-text path falls back and asks
        -- for a retry. Tests that exercise resolved text override these.
        _G.HaveQuestData = function() return false end
        _G.C_QuestLog.GetQuestObjectives = function() return nil end

        PartyObjectivesProvider = require("Modules.Network.PartyObjectivesProvider")
    end)

    describe("ShouldDraw", function()
        it("should return true when the setting is on and in a small group", function()
            assert.is_true(PartyObjectivesProvider.ShouldDraw())
        end)

        it("should return false when the setting is off", function()
            Questie.db.profile.showPartyQuestObjectives = false
            assert.is_false(PartyObjectivesProvider.ShouldDraw())
        end)

        it("should return false when not in a group", function()
            QuestiePlayer.GetGroupType = function() return nil end
            assert.is_false(PartyObjectivesProvider.ShouldDraw())
        end)

        it("should return false when the group is larger than 5", function()
            _G.GetNumGroupMembers = function() return 6 end
            assert.is_false(PartyObjectivesProvider.ShouldDraw())
        end)
    end)

    describe("GetAllRemoteQuestIds", function()
        it("should list every quest in the remote logs", function()
            QuestieComms.remoteQuestLogs = { [10] = {}, [20] = {}, [30] = {} }
            local ids = PartyObjectivesProvider.GetAllRemoteQuestIds()
            table.sort(ids)
            assert.same({ 10, 20, 30 }, ids)
        end)

        it("should return an empty list when there are no remote logs", function()
            assert.same({}, PartyObjectivesProvider.GetAllRemoteQuestIds())
        end)
    end)

    describe("BuildQuestPlan", function()
        it("should return nil when the local player already has the quest", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = { [42] = {} }
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false } } } }
            assert.is_nil(PartyObjectivesProvider.BuildQuestPlan(42))
        end)

        it("should return nil when no party member has the quest", function()
            assert.is_nil(PartyObjectivesProvider.BuildQuestPlan(42))
        end)

        it("should return nil when every objective is finished", function()
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = true } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "Wolf" } } }
            end
            assert.is_nil(PartyObjectivesProvider.BuildQuestPlan(42))
        end)

        it("should ignore objectives only needed by offline members", function()
            _G.UnitIsConnected = function() return false end
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "Wolf" } } }
            end
            assert.is_nil(PartyObjectivesProvider.BuildQuestPlan(42))
        end)

        it("should build a descriptor from the database ObjectiveData", function()
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "m" } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "Wolf", Icon = "icon" } } }
            end

            local plan = PartyObjectivesProvider.BuildQuestPlan(42)

            assert.equals(42, plan.questId)
            assert.equals(1, #plan.objectives)
            local descriptor = plan.objectives[1]
            assert.equals(5, descriptor.Id)
            assert.equals("monster", descriptor.Type)
            assert.equals(1, descriptor.Index)
            assert.equals("Wolf", descriptor.Description)
            assert.equals("icon", descriptor.Icon)
            assert.is_false(plan.needsApiRetry)
        end)

        it("should fall back to the target name when the DB has no objective text", function()
            -- The name fallback fires only when Text is absent: an empty string is truthy in Lua,
            -- so it stands as-is (preserving the pre-split behaviour).
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "m" } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5 } } }
            end
            QuestieDB.GetNPC = function() return { name = "Snarler" } end

            local descriptor = PartyObjectivesProvider.BuildQuestPlan(42).objectives[1]
            assert.equals("Snarler", descriptor.Description)
        end)

        it("should keep an empty DB text as-is rather than using the name", function()
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "m" } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "" } } }
            end
            QuestieDB.GetNPC = function() return { name = "Snarler" } end

            local descriptor = PartyObjectivesProvider.BuildQuestPlan(42).objectives[1]
            assert.equals("", descriptor.Description)
        end)

        it("should resolve the Blizzard API text when the comms type differs from the DB type", function()
            -- DB says monster, comms says item -> a kill-credit/flagged objective mismatch.
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "i" } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "Credit" } } }
            end
            _G.HaveQuestData = function() return true end
            _G.C_QuestLog.GetQuestObjectives = function() return { [1] = { text = "Slay the warlord" } } end

            local plan = PartyObjectivesProvider.BuildQuestPlan(42)
            assert.equals("Slay the warlord", plan.objectives[1].Description)
            assert.is_nil(plan.objectives[1].FullDescription)
            assert.is_false(plan.needsApiRetry)
        end)

        it("should keep the DB fallback and flags a retry when the quest data isn't cached yet", function()
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "i" } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "Credit" } } }
            end
            _G.HaveQuestData = function() return false end

            local plan = PartyObjectivesProvider.BuildQuestPlan(42)
            -- The name fallback is skipped for flagged objectives; the DB text stands as fallback.
            assert.equals("Credit", plan.objectives[1].Description)
            assert.is_nil(plan.objectives[1].FullDescription)
            assert.is_true(plan.needsApiRetry)
        end)

        it("should fall back to comms data when the DB objective index is missing", function()
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "o", id = 99 } } } }
            QuestieDB.GetQuest = function()
                return { ObjectiveData = {} } -- index 1 absent
            end
            QuestieDB.GetObject = function() return { name = "Crate" } end

            local descriptor = PartyObjectivesProvider.BuildQuestPlan(42).objectives[1]
            assert.equals(99, descriptor.Id)
            assert.equals("object", descriptor.Type)
            assert.equals("Crate", descriptor.Description)
        end)

        it("should return special objectives in their own list with offset indices", function()
            QuestieComms.remoteQuestLogs = { [42] = { Bob = { [1] = { finished = false, type = "m" } } } }
            QuestieDB.GetQuest = function()
                return {
                    ObjectiveData = { [1] = { Type = "monster", Id = 5, Text = "Wolf" } },
                    SpecialObjectives = {
                        { Id = 7, Type = "item", Description = "Runestone", Icon = "ico2" },
                    },
                }
            end

            local plan = PartyObjectivesProvider.BuildQuestPlan(42)
            assert.equals(1, #plan.objectives)
            assert.equals(1, #plan.specialObjectives)
            local special = plan.specialObjectives[1]
            assert.equals(65, special.Index) -- 64 + 1
            assert.equals("Runestone", special.Description)
        end)
    end)
end)
