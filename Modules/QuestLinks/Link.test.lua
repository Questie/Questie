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
        }
        _G.ItemRefTooltipTextLeft1 = {
            GetText = function() return "" end,
        }
        _G.ShowUIPanel = function() end
        _G.UIParent = {}

        _G.Questie.Colorize = function(_, text)
            return text
        end

        _G.HaveQuestData = function() return false end
        _G.C_QuestLog.GetQuestObjectives = function() return nil end

        QuestieDB = require("Database.QuestieDB")
        QuestieDB.DoableStates = {AVAILABLE = "AVAILABLE"}
        QuestieDB.IsComplete = function() return 0 end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsPvPQuest = function() return false end

        QuestiePlayer = require("Modules.QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}

        QuestieReputation = require("Modules.QuestieReputation")

        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieLib.GetTbcLevel = function() return 10 end
        QuestieLib.GetLevelString = function() return "[10] " end
        QuestieLib.PrintDifficultyColor = function(_, _, ...) return "|cffffffff" end

        QuestieEvent = require("Database.Corrections.Holidays.QuestieEvent")
        QuestieEvent.IsEventQuest = function() return false end

        TrackerUtils = require("Modules.Tracker.TrackerUtils")
        require("Localization.l10n")
        require("Database.Zones.zoneDB")

        QuestieLink = require("Modules.QuestLinks.Link")
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
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234")

            assert.are.same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff and gain reputation.",
                " ",
                "Objectives",
                "Fierce Boar",
                "Argent Dawn",
            }, tooltipLines)
            assert.spy(QuestieDB.QueryNPCSingle).was_called_with(101, "name")
            assert.spy(QuestieReputation.GetFactionName).was_called_with(201)
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
            QuestieDB.QueryNPCSingle = spy.new(function() return "Fierce Boar" end)
            QuestieReputation.GetFactionName = spy.new(function() return "Argent Dawn" end)
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234")

            assert.are.same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff and gain reputation.",
                " ",
                "Objectives",
                " - Fierce Boar slain: 0/8",
                " - Argent Dawn reputation: 0/1000",
            }, tooltipLines)
            assert.spy(QuestieDB.QueryNPCSingle).was_not_called()
            assert.spy(QuestieReputation.GetFactionName).was_not_called()
        end)

        it("should fall back to DB objectives when all Blizzard objective texts start with a space", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Kill some stuff."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {Type = "monster", Id = 101, Text = nil},
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
                }
            end

            QuestieDB.IsDoableVerbose = function()
                return "You have not done this quest", nil, "AVAILABLE"
            end
            QuestieDB.QueryNPCSingle = spy.new(function() return "Fierce Boar" end)
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234")

            assert.are.same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff.",
                " ",
                "Objectives",
                "Fierce Boar",
            }, tooltipLines)
            assert.spy(QuestieDB.QueryNPCSingle).was_called_with(101, "name")
        end)

        it("should show all Blizzard objectives when at least one is valid", function()
            QuestieDB.GetQuest = function(questId)
                return {
                    Id = questId,
                    name = "Test Quest",
                    Description = {"Kill some stuff."},
                    zoneOrSort = 0,
                    specialFlags = 0,
                    ObjectiveData = {
                        {Type = "monster", Id = 101, Text = nil},
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
            QuestieDB.QueryNPCSingle = spy.new(function() return "Fierce Boar" end)
            TrackerUtils.GetZoneNameByID = function() return "Test Zone" end

            local questId = 1234
            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-1234")

            assert.are.same({
                "Test Quest",
                "You have not done this quest",
                " ",
                "Kill some stuff.",
                " ",
                "Objectives",
                " - Fierce Boar slain: 3/8",
                " -  : 0/1",
            }, tooltipLines)
            assert.spy(QuestieDB.QueryNPCSingle).was_not_called()
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

            QuestieLink:CreateQuestTooltip("questie:" .. questId .. ":GUID-0-5678")

            assert.are.same({
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
end)
