dofile("setupTests.lua")
dofile("Localization/l10n.lua")

describe("QuestieEvent", function()

    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type QuestieNPCFixes
    local QuestieNPCFixes
    ---@type ContentPhases
    local ContentPhases

    before_each(function()
        Questie.IsClassic = false
        Questie.IsAnniversary = false
        _G.Questie.Colorize = function(_, str) return str end
        _G.print = spy.new(function() end)
        QuestieCorrections = require("Database.Corrections.QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}
        QuestieNPCFixes = require("Database.Corrections.classicNPCFixes")
        QuestieNPCFixes.LoadDarkmoonFixes = function() return {} end
        ContentPhases = require("Database.Corrections.ContentPhases.ContentPhases")
        QuestieEvent = require("Database.Corrections.Holidays.QuestieEvent")
        QuestieEvent.eventQuests = {} -- This is done on top level in QuestieEvent.lua
        dofile("Database/Corrections/Holidays/quests/DarkmoonFaire.lua")
    end)

    describe("Darkmoon Faire", function()
        it("should not load for Anniversary servers in P1", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}
            ContentPhases.activePhases.Anniversary = 1

            Questie.IsClassic = true
            Questie.IsAnniversary = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary HC servers in P1", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}
            ContentPhases.activePhases.Anniversary = 1

            Questie.IsClassic = true
            Questie.IsAnniversary = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary servers in P2", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}
            ContentPhases.activePhases.Anniversary = 2

            Questie.IsClassic = true
            Questie.IsAnniversary = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should not load for Anniversary servers in P2", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}
            ContentPhases.activePhases.Anniversary = 2

            Questie.IsClassic = true
            Questie.IsAnniversary = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.not_called()
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_equal(0, #QuestieEvent.activeQuests)
        end)

        it("should load for Anniversary servers in P3", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}
            ContentPhases.activePhases.Anniversary = 3

            Questie.IsClassic = true
            Questie.IsAnniversary = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should load for Anniversary HC servers in P3", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}
            ContentPhases.activePhases.Anniversary = 3

            Questie.IsClassic = true
            Questie.IsAnniversary = false
            Questie.IsAnniversaryHardcore = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)

        it("should load for Classic servers", function()
            _G.QuestieCompat = {GetCurrentCalendarTime=function()
                return {
                    weekday = 4,
                    monthDay = 11,
                    month = 12,
                    year = 2024,
                    hour = 0,
                    minute = 0,
                }
            end}

            Questie.IsClassic = true

            QuestieEvent:Load()

            assert.spy(_G.print).was.called_with("[Questie]", "|cFF6ce314The 'Darkmoon Faire' world event is active!")
            assert.is_nil(QuestieEvent.eventQuests)
            assert.is_true(table.getn(QuestieEvent.activeQuests) > 0)
        end)
    end)
end)
