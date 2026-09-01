dofile("setupTests.lua")

describe("QuestieLink", function()
    ---@type QuestieLink
    local QuestieLink

    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type TrackerUtils
    local TrackerUtils
    ---@type QuestieReputation
    local QuestieReputation

    local tooltipLines

    before_each(function()
        Questie.started = true
        Questie.db.profile = {}
        Questie.db.char = {
            complete = {},
        }

        tooltipLines = {}

        _G.ItemRefTooltip = {
            AddLine = function(_, text)
                table.insert(tooltipLines, text)
            end,
            IsShown = function() return false end,
            SetOwner = function() end,
            ClearLines = function() end,
            Show = spy.new(function() end),
            Hide = function() end,
            SetHyperlink = function() end,
        }
        _G.ItemRefTooltipTextLeft1 = {
            GetText = function() return "Test Quest" end,
        }
        _G.ShowUIPanel = function() end
        _G.UIParent = {}
        _G.GameTooltip = {
            SetHyperlink = function() end,
        }

        _G.Questie.Colorize = function(_, text)
            return text
        end

        _G.HaveQuestData = function() return false end
        _G.GetQuestLink = nil
        _G.C_QuestLog.GetQuestObjectives = function() return nil end

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.DoableStates = {AVAILABLE = "AVAILABLE"}
        QuestieDB.IsComplete = function() return 0 end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieDB.QueryNPCSingle = spy.new(function() return nil end)
        QuestieDB.QueryObjectSingle = spy.new(function() return nil end)
        QuestieDB.QueryItemSingle = spy.new(function() return nil end)

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}

        QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
        QuestieReputation.GetFactionName = spy.new(function() return nil end)

        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetEffectiveQuestLevel = function() return 10 end
        QuestieLib.GetLevelString = function() return "[10] " end
        QuestieLib.PrintDifficultyColor = function(_, _, ...) return "|cffffffff" end

        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.IsEventQuest = function() return false end

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        QuestieLoader:ImportModule("ZoneDB")
        dofile("Localization/l10n.lua")

        dofile("Modules/QuestLinks/Link.lua")
        QuestieLink = QuestieLoader:ImportModule("QuestieLink")
        QuestieLink.lastItemRefTooltip = nil
    end)

    describe("GetQuestLinkStringById", function()
        it("should return default link when GetQuestLink API is available", function()
            _G.GetQuestLink = function()
                return "Test Link"
            end

            local result = QuestieLink:GetQuestLinkStringById(1234)

            assert.are_same("Test Link", result)
        end)

        it("should return a formatted link string with level and name from the database when trackerShowQuestLevel is true", function()
            Questie.db.profile.trackerShowQuestLevel = true
            QuestieDB.QueryQuestSingle = function()
                return "Test Quest"
            end
            QuestieLib.GetEffectiveQuestLevel = function()
                return 15
            end

            local result = QuestieLink:GetQuestLinkStringById(1234)

            assert.are_same("[[15] Test Quest (1234)]", result)
        end)

        it("should return a formatted link string without level when trackerShowQuestLevel is false", function()
            Questie.db.profile.trackerShowQuestLevel = false
            QuestieDB.QueryQuestSingle = function()
                return "Test Quest"
            end
            QuestieLib.GetEffectiveQuestLevel = function()
                return 15
            end

            local result = QuestieLink:GetQuestLinkStringById(1234)

            assert.are_same("[Test Quest (1234)]", result)
        end)
    end)

    describe("ItemRefTooltip:SetHyperlink native quest links", function()
        before_each(function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Test description"},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {},
                    Objectives = {},
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end
            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.QueryQuestSingle = function()
                return "Test Quest"
            end
            QuestieLib.GetEffectiveQuestLevel = function()
                return 15
            end
            QuestieLib.GetLevelString = function()
                return "[15] "
            end
            TrackerUtils.GetZoneNameByID = function()
                return "Test Zone"
            end
        end)

        it("should detect and handle questie quest links", function()
            local questieLink = "questie:74:GUID-0-1234"

            ItemRefTooltip:SetHyperlink(questieLink)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Test description",
            }, tooltipLines)
            assert.spy(_G.ItemRefTooltip.Show).was.called()
            assert.is_equal("Test Quest", QuestieLink.lastItemRefTooltip)
        end)

        it("should detect and handle native quest links", function()
            local nativeLink = "quest:74:28"

            ItemRefTooltip:SetHyperlink(nativeLink)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Test description",
            }, tooltipLines)
            assert.spy(_G.ItemRefTooltip.Show).was.called()
            assert.is_equal("Test Quest", QuestieLink.lastItemRefTooltip)
        end)

        it("should not detect non-quest links", function()
            local nonQuestLink = "item:12345:0:0:0"

            ItemRefTooltip:SetHyperlink(nonQuestLink)

            assert.are_same({}, tooltipLines)
            assert.spy(_G.ItemRefTooltip.Show).was.not_called()
            assert.is_equal("", QuestieLink.lastItemRefTooltip)
        end)

        it("should delegate native quest links not in QuestieDB to default handler", function()
            QuestieDB.GetQuest = function()
                return nil
            end

            local nativeLink = "quest:99999:28"

            ItemRefTooltip:SetHyperlink(nativeLink)

            assert.are_same({}, tooltipLines)
            assert.spy(_G.ItemRefTooltip.Show).was.not_called()
            assert.is_equal("", QuestieLink.lastItemRefTooltip)
        end)
    end)

    describe("CreateQuestTooltip", function()
        it("should show quest requirements including reputation when quest is not in the player quest log", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Kill some stuff and gain reputation."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {
                            Type = "monster",
                            Id = 101,
                            Text = nil,
                        },
                        {
                            Type = "reputation",
                            Id = 201,
                            Text = nil,
                        },
                    },
                    Objectives = {},
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.QueryNPCSingle = spy.new(function()
                return "Fierce Boar"
            end)
            QuestieReputation.GetFactionName = spy.new(function()
                return "Argent Dawn"
            end)
            TrackerUtils.GetZoneNameByID = function()
                return "Test Zone"
            end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234", ItemRefTooltip)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff and gain reputation.",
                " ",
                "Objectives",
                " - Fierce Boar",
                " - Argent Dawn",
            }, tooltipLines)
            assert.spy(QuestieDB.QueryNPCSingle).was.called_with(101, "name")
            assert.spy(QuestieReputation.GetFactionName).was.called_with(201)
        end)

        it("should show Blizzard objective text when HaveQuestData returns true", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Kill some stuff and gain reputation."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {Type = "monster", Id = 101, Text = nil},
                        {Type = "reputation", Id = 201, Text = nil},
                    },
                    Objectives = {},
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end
            _G.HaveQuestData = function() return true end
            _G.C_QuestLog.GetQuestObjectives = function()
                return {
                    {text = "Fierce Boar slain: 0/8"},
                    {text = "Argent Dawn reputation: 0/1000"},
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234", ItemRefTooltip)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff and gain reputation.",
                " ",
                "Objectives",
                " - Fierce Boar slain: 0/8",
                " - Argent Dawn reputation: 0/1000",
            }, tooltipLines)
            assert.spy(QuestieDB.QueryNPCSingle).was.not_called()
            assert.spy(QuestieReputation.GetFactionName).was.not_called()
        end)

        it("should use NPC names from DB when Blizzard objective is missing it", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Kill some stuff."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {Type = "monster", Id = 101, Text = nil},
                        {Type = "monster", Id = 102, Text = nil},
                    },
                    Objectives = {},
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end
            _G.HaveQuestData = function() return true end
            _G.C_QuestLog.GetQuestObjectives = function()
                return {
                    {text = "Fierce Boar slain: 3/8"},
                    {text = " : 0/1"},
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.QueryNPCSingle = spy.new(function() return "Kobold Miner" end)
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234", ItemRefTooltip)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff.",
                " ",
                "Objectives",
                " - Fierce Boar slain: 3/8",
                " - Kobold Miner: 0/1",
            }, tooltipLines)
        end)

        it("should use object names from DB when Blizzard objective is missing it", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Click some stuff."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {Type = "object", Id = 101, Text = nil},
                        {Type = "object", Id = 102, Text = nil},
                    },
                    Objectives = {},
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end
            _G.HaveQuestData = function() return true end
            _G.C_QuestLog.GetQuestObjectives = function()
                return {
                    {text = " : 0/1"},
                    {text = "Orb clicked: 0/1"},
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.QueryObjectSingle = spy.new(function() return "Different Orb" end)
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234", ItemRefTooltip)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Click some stuff.",
                " ",
                "Objectives",
                " - Different Orb: 0/1",
                " - Orb clicked: 0/1",
            }, tooltipLines)
        end)

        it("should use item names from DB when Blizzard objective is missing it", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Collect some stuff."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {Type = "item", Id = 101, Text = nil},
                        {Type = "item", Id = 102, Text = nil},
                        {Type = "item", Id = 103, Text = nil},
                    },
                    Objectives = {},
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end
            _G.HaveQuestData = function() return true end
            _G.C_QuestLog.GetQuestObjectives = function()
                return {
                    {text = "Linen Cloth: 5/10"},
                    {text = "Wool Cloth: 3/10"},
                    {text = " : 0/10"},
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.QueryItemSingle = spy.new(function() return "Silk Cloth" end)
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234", ItemRefTooltip)

            assert.are_same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Collect some stuff.",
                " ",
                "Objectives",
                " - Linen Cloth: 5/10",
                " - Wool Cloth: 3/10",
                " - Silk Cloth: 0/10",
            }, tooltipLines)
        end)

        it("should show player progress when quest is in the player quest log", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Progress Quest",
                    Description = {"Collect some items."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {
                            Type = "item",
                            Id = 301,
                            Text = nil,
                        },
                    },
                    Objectives = {
                        [1] = {
                            Description = "Wool Cloth",
                            Collected = 3,
                            Needed = 10,
                        },
                    },
                    Starts = nil,
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You are on this quest", nil, "AVAILABLE"
            end

            local questId = 5678
            QuestiePlayer.currentQuestlog = {
                [questId] = true,
            }

            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-5678", ItemRefTooltip)

            assert.are_same({
                "Progress Quest",
                "You are on this quest",
                " ",
                "Collect some items.",
                " ",
                "Your progress: ",
                " - |cFFEEEEEEWool Cloth: 3/10|r",
            }, tooltipLines)
        end)
    end)

    describe("hover tooltip via CreateQuestTooltip", function()
        it("should show quest title, status, description, and starter info", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Hover Quest",
                    Description = {"Do something."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {},
                    Objectives = {},
                    Starts = {NPC = {500}},
                    Finisher = {NPC = {600}, GameObject = nil},
                }
            end
            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.GetNPC = function(_, npcId)
                if npcId == 500 then return {name = "Quest Giver", zoneID = 0} end
                if npcId == 600 then return {name = "Quest Finisher", zoneID = 0} end
                return nil
            end
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            QuestieLink:CreateQuestTooltip("questie:1234:GUID", ItemRefTooltip)

            assert.are_same({
                "Hover Quest",
                "You have not done this quest",
                " ",
                "Do something.",
                " ",
                "Started by: Quest Giver",
                "Found in: Test Zone",
            }, tooltipLines)
        end)

        it("should not show Started by when quest is in the player quest log", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Active Quest",
                    Description = {"Fight things."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {},
                    Objectives = {},
                    Starts = {NPC = {500}},
                    Finisher = {NPC = nil, GameObject = nil},
                }
            end
            QuestieDB.IsDoableVerbose = function()
                return "You are on this quest", nil, "AVAILABLE"
            end
            QuestiePlayer.currentQuestlog = {[1234] = true}

            QuestieLink:CreateQuestTooltip("questie:1234:GUID", ItemRefTooltip)

            assert.are_same({
                "Active Quest",
                "You are on this quest",
                " ",
                "Fight things.",
                " ",
                "Your progress: ",
            }, tooltipLines)
        end)
    end)
end)
