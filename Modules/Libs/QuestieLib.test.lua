dofile("setupTests.lua")

describe("QuestieLib", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type l10n
    local l10n
    ---@type QuestieLib
    local QuestieLib

    local QUEST_ID = 12345

    before_each(function()
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.GetQuestTagInfo = function() end
        l10n = require("Localization.l10n")
        l10n.GetUILocale = function() return "enUS" end

        QuestieLib = require("Modules.Libs.QuestieLib")
    end)

    describe("GetLevelString", function()
        it("should handle regular quests", function()
            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60] ", levelString)
        end)

        it("should handle Elite quests", function()
            QuestieDB.GetQuestTagInfo = function() return 1, "Elite" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60+] ", levelString)
        end)

        it("should handle Dungeon quests", function()
            QuestieDB.GetQuestTagInfo = function() return 81, "Dungeon" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 81, "地下城" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 81, "地城" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 81, "던전" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 81, "Подземелье" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Raid quests", function()
            QuestieDB.GetQuestTagInfo = function() return 62, "Raid" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 62, "团队" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 62, "團隊" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 62, "레이드" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 62, "Рейд" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle PvP quests", function()
            QuestieDB.GetQuestTagInfo = function() return 41, "PvP" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60] ", levelString)
        end)

        it("should handle Legendary quests", function()
            QuestieDB.GetQuestTagInfo = function() return 83, "Legendary" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60++] ", levelString)
        end)

        it("should handle Scenario quests", function()
            QuestieDB.GetQuestTagInfo = function() return 98, "Scenario" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 98, "场景战役" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 98, "事件" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 98, "시나리오" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Scenario quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 98, "Сценарий" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60S] ", levelString)
        end)

        it("should handle Account quests", function()
            QuestieDB.GetQuestTagInfo = function() return 102, "Account" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 102, "账号" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 102, "帳號" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 102, "레이드" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 102, "Аккаунт" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Celestial quests", function()
            QuestieDB.GetQuestTagInfo = function() return 294, "Celestial" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 294, "天神" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 294, "天尊" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 294, "천신" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle Celestial quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 294, "Небожители" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60C] ", levelString)
        end)

        it("should handle unknown quests", function()
            QuestieDB.GetQuestTagInfo = function() return 999, "Unknown" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60)

            assert.are_same("[60U] ", levelString)
        end)
    end)

    describe("DidDailyResetHappenSinceLastLogin", function()
        it("should return true when last login is not set", function()
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.lastKnownDailyReset = {}

            local result = QuestieLib.DidDailyResetHappenSinceLastLogin()

            assert.is_true(result)
        end)

        it("should return true when the server time exceeds the last know daily reset", function()
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.lastKnownDailyReset = {["Ook Ook"] = 1765833265}

            _G.GetServerTime = function() return 2000000000 end

            local result = QuestieLib.DidDailyResetHappenSinceLastLogin()

            assert.is_true(result)
        end)

        it("should return false when the server time did not exceed the last know daily reset", function()
            _G.GetRealmName = function() return "Ook Ook" end
            Questie.db.global.lastKnownDailyReset = {["Ook Ook"] = 1765833265}

            _G.GetServerTime = function() return 1500000000 end

            local result = QuestieLib.DidDailyResetHappenSinceLastLogin()

            assert.is_false(result)
        end)
    end)

    describe("FormatDate", function()
        it("should format date for enUS", function()
            l10n.GetUILocale = function() return "enUS" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"January","February","March","April","May","June","July","August","September","October","November","December"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Wednesday, February 18, 2026 at 19:35", formattedDate)
        end)

        it("should format date for deDE", function()
            l10n.GetUILocale = function() return "deDE" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Mittwoch, 18. Februar 2026 um 19:35", formattedDate)
        end)

        it("should format date for esES", function()
            l10n.GetUILocale = function() return "esES" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Miércoles, 18 de Febrero de 2026 a las 19:35", formattedDate)
        end)

        it("should format date for esMX", function()
            l10n.GetUILocale = function() return "esMX" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Miércoles, 18 de Febrero de 2026 a las 19:35", formattedDate)
        end)

        it("should format date for frFR", function()
            l10n.GetUILocale = function() return "frFR" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Mercredi 18 Février 2026 à 19:35", formattedDate)
        end)

        it("should format date for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            _G.CALENDAR_WEEKDAY_NAMES = {"일요일","월요일","화요일","수요일","목요일","금요일","토요일"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("2026년 2월 18일 수요일 19:35", formattedDate)
        end)

        it("should format date for ptBR", function()
            l10n.GetUILocale = function() return "ptBR" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Domingo","Segunda-feira","Terça-feira","Quarta-feira","Quinta-feira","Sexta-feira","Sábado"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            -- Match the exact output produced by the current formatter (keeps same assert style as other locale tests)
            assert.are_same("Quarta-feira, 18 de Fevereiro de 2026 às 19:35", formattedDate)
        end)

        it("should format date for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            _G.CALENDAR_WEEKDAY_NAMES = {"Воскресенье","Понедельник","Вторник","Среда","Четверг","Пятница","Суббота"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"января","февраля","марта","апреля","мая","июня","июля","августа","сентября","октября","ноября","декабря"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("Среда, 18 февраля 2026, 19:35", formattedDate)
        end)

        it("should format date for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            _G.CALENDAR_WEEKDAY_NAMES = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("2026年2月18日 星期三 19:35", formattedDate)
        end)

        it("should format date for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            _G.CALENDAR_WEEKDAY_NAMES = {"星期日","星期一","星期二","星期三","星期四","星期五","星期六"}
            _G.CALENDAR_FULLDATE_MONTH_NAMES = {"1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"}

            local formattedDate = QuestieLib.FormatDate(1771439740)

            assert.are_same("2026年2月18日 星期三 19:35", formattedDate)
        end)
    end)
end)
