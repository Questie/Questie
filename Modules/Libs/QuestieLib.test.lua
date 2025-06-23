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
            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60] ", levelString)
        end)

        it("should handle Elite quests", function()
            QuestieDB.GetQuestTagInfo = function() return 1, "Elite" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60+] ", levelString)
        end)

        it("should handle Dungeon quests", function()
            QuestieDB.GetQuestTagInfo = function() return 81, "Dungeon" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests blizzLike", function()
            QuestieDB.GetQuestTagInfo = function() return 81, "Dungeon" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, true)

            assert.are_same("[60+] ", levelString)
        end)

        it("should handle Dungeon quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 81, "地下城" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 81, "地城" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 81, "던전" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Dungeon quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 81, "Подземелье" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60D] ", levelString)
        end)

        it("should handle Raid quests", function()
            QuestieDB.GetQuestTagInfo = function() return 62, "Raid" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 62, "团队" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 62, "團隊" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 62, "레이드" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 62, "Рейд" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60R] ", levelString)
        end)

        it("should handle Raid quests blizzLike", function()
            QuestieDB.GetQuestTagInfo = function() return 62, "Raid" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, true)

            assert.are_same("[60+] ", levelString)
        end)

        it("should handle PvP quests", function()
            QuestieDB.GetQuestTagInfo = function() return 41, "PvP" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60] ", levelString)
        end)

        it("should handle Legendary quests", function()
            QuestieDB.GetQuestTagInfo = function() return 83, "Legendary" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60++] ", levelString)
        end)

        it("should handle Account quests", function()
            QuestieDB.GetQuestTagInfo = function() return 102, "Account" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for zhCN", function()
            l10n.GetUILocale = function() return "zhCN" end
            QuestieDB.GetQuestTagInfo = function() return 102, "账号" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for zhTW", function()
            l10n.GetUILocale = function() return "zhTW" end
            QuestieDB.GetQuestTagInfo = function() return 102, "帳號" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for koKR", function()
            l10n.GetUILocale = function() return "koKR" end
            QuestieDB.GetQuestTagInfo = function() return 102, "레이드" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle Account quests for ruRU", function()
            l10n.GetUILocale = function() return "ruRU" end
            QuestieDB.GetQuestTagInfo = function() return 102, "Аккаунт" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60A] ", levelString)
        end)

        it("should handle unknown quests", function()
            QuestieDB.GetQuestTagInfo = function() return 999, "Unknown" end

            local levelString = QuestieLib:GetLevelString(QUEST_ID, 60, false)

            assert.are_same("[60] ", levelString)
        end)
    end)
end)
