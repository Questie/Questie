dofile("setupTests.lua")

describe("QuestLockReasons", function()
    ---@type QuestLockReasons
    local QuestLockReasons
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieProfessions
    local QuestieProfessions
    ---@type QuestieReputation
    local QuestieReputation
    ---@type QuestieEvent
    local QuestieEvent
    ---@type QuestieCorrections
    local QuestieCorrections
    ---@type DailyQuests
    local DailyQuests
    ---@type Expansions
    local Expansions

    local QUEST = 100
    local fields
    local activeQuests
    local knownSpells
    local savedGlobals

    local function GetReasons(chainQuestIds)
        return QuestLockReasons.GetReasons(QUEST, chainQuestIds or {})
    end

    local function SetQuestNames(names)
        for questId, name in pairs(names) do
            fields[questId] = fields[questId] or {}
            fields[questId].name = name
        end
    end

    before_each(function()
        fields = {[QUEST] = {}}
        activeQuests = {}
        knownSpells = {}

        savedGlobals = {
            char = Questie.db.char,
            global = Questie.db.global,
            Colorize = Questie.Colorize,
            C_Spell = _G.C_Spell,
        }
        Questie.db.char = {complete = {}}
        Questie.db.global = {unavailableQuestsDeterminedByTalking = {}}
        Questie.Colorize = function(_, text, color) return "[" .. color .. "]" .. text end
        _G.C_Spell = {GetSpellName = function(spellId) return "Spell " .. spellId end}
        for standing, name in ipairs({"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}) do
            _G["FACTION_STANDING_LABEL" .. standing] = name
        end

        dofile("Localization/l10n.lua")

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(questId, key)
            return fields[questId] and fields[questId][key]
        end
        QuestieDB.IsPreQuestSingleFulfilled = function(_, preQuestSingle)
            for _, preQuestId in ipairs(preQuestSingle) do
                if Questie.db.char.complete[preQuestId] then
                    return true
                end
            end
            return false
        end
        QuestieDB.IsPreQuestGroupFulfilled = function(_, preQuestGroup)
            for _, preQuestId in ipairs(preQuestGroup) do
                if not Questie.db.char.complete[math.abs(preQuestId)] then
                    return false
                end
            end
            return true
        end
        QuestieDB.private.CheckAchievementRequirements = function() return nil end

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.HasRequiredRace = function(requiredRaces) return requiredRaces == nil end
        QuestiePlayer.HasRequiredClass = function(requiredClasses) return requiredClasses == nil end
        QuestiePlayer.GetPlayerLevel = function() return 30 end
        QuestiePlayer.HasArenaRating = function() return false end

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetRaceString = function(_, requiredRaces)
            return ({[77] = "|cFF1E90FFAlliance|r", [8] = "Night Elf", [9] = "Human, Night Elf"})[requiredRaces] or ""
        end
        QuestieLib.GetClassString = function(_, requiredClasses)
            return ({[1] = "|cFFC69B6DWarrior|r", [3] = "|cFFC69B6DWarrior|r, |cFFF48CBAPaladin|r"})[requiredClasses] or ""
        end

        QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        QuestieProfessions.professionKeys = {ALCHEMY = 171, BLACKSMITHING = 164, ENGINEERING = 202, LEATHERWORKING = 165,
                                             TAILORING = 197, MINING = 186, FISHING = 356}
        QuestieProfessions.GetProfessionName = function(_, professionId)
            return ({[202] = "Engineering", [186] = "Mining", [356] = "Fishing"})[professionId]
        end
        QuestieProfessions.GetRankName = function(_, rankLevel) return ({[4] = "Artisan", [5] = "Master"})[rankLevel] end
        QuestieProfessions.GetSpecializationName = function(_, specializationId)
            return ({[20219] = "Gnomish Engineer"})[specializationId]
        end
        QuestieProfessions.HasProfessionAndSkillLevel = function() return true, true end
        QuestieProfessions.HasProfessionAndRankLevel = function() return true, true, false end
        QuestieProfessions.HasSpecialization = function() return true end

        QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
        QuestieReputation.HasFactionAndReputationLevel = function() return true, true, true, true end
        QuestieReputation.GetFactionName = function(factionId) return ({[529] = "Argent Dawn"})[factionId] end

        QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.IsEventQuest = function() return false end
        QuestieEvent.IsEventActiveForQuest = function() return false end
        QuestieEvent.GetEventNameFor = function() return "Hallow's End" end

        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}

        DailyQuests = QuestieLoader:ImportModule("DailyQuests")
        DailyQuests.ShouldBeHidden = function() return false end

        local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
        ActiveQuests.Get = function(questId) return activeQuests[questId] end
        ActiveQuests.GetAll = function() return activeQuests end

        QuestieLoader:ImportModule("QuestieCompat").IsSpellKnown = function(spellId) return knownSpells[spellId] == true end

        Expansions = QuestieLoader:ImportModule("Expansions")
        savedGlobals.expansion = Expansions.Current

        dofile("Modules/Quest/QuestLockReasons.lua")
        QuestLockReasons = QuestieLoader:ImportModule("QuestLockReasons")
    end)

    after_each(function()
        Questie.db.char = savedGlobals.char
        Questie.db.global = savedGlobals.global
        Questie.Colorize = savedGlobals.Colorize
        _G.C_Spell = savedGlobals.C_Spell
        Expansions.Current = savedGlobals.expansion
    end)

    describe("GetReasons", function()
        it("should return no reasons for a quest the player can take", function()
            assert.are_same({}, GetReasons())
        end)

        it("should name the faction or races the quest is for, without colors", function()
            fields[QUEST].requiredRaces = 77
            assert.are_same({"Alliance only"}, GetReasons())

            fields[QUEST].requiredRaces = 9
            assert.are_same({"Human, Night Elf only"}, GetReasons())
        end)

        it("should name the classes the quest is for, without colors", function()
            fields[QUEST].requiredClasses = 3
            assert.are_same({"Warrior, Paladin only"}, GetReasons())
        end)

        it("should name a missing profession with its skill level", function()
            fields[QUEST].requiredSkill = {202, 225}
            QuestieProfessions.HasProfessionAndSkillLevel = function() return false, false end

            assert.are_same({"Engineering (225) only"}, GetReasons())
        end)

        it("should ask for the skill level of a profession the player has", function()
            fields[QUEST].requiredSkill = {202, 225}
            QuestieProfessions.HasProfessionAndSkillLevel = function() return true, false end

            assert.are_same({"Requires Engineering (225)"}, GetReasons())
        end)

        it("should name missing profession ranks", function()
            fields[QUEST].requiredRanks = {{202, 4}, {186, 4}}
            QuestieProfessions.HasProfessionAndRankLevel = function() return false, false, false end
            assert.are_same({"Engineering (Artisan), Mining (Artisan) only"}, GetReasons())

            QuestieProfessions.HasProfessionAndRankLevel = function() return true, false, false end
            assert.are_same({"Requires Engineering (Artisan), Mining (Artisan)"}, GetReasons())
        end)

        it("should rule out a quest for those below a rank once the player reached it", function()
            fields[QUEST].requiredRanks = {{202, -5}}
            QuestieProfessions.HasProfessionAndRankLevel = function() return true, false, true end
            assert.are_same({"Before Engineering (Master) only"}, GetReasons())

            QuestieProfessions.HasProfessionAndRankLevel = function() return false, false, true end
            assert.are_same({}, GetReasons())
        end)

        it("should name a missing specialization", function()
            fields[QUEST].requiredSpecialization = 20219
            QuestieProfessions.HasSpecialization = function() return false end

            assert.are_same({"Gnomish Engineer only"}, GetReasons())
        end)

        it("should rule out a quest for choosing a specialization once one is chosen", function()
            fields[QUEST].requiredSpecialization = 202
            QuestieProfessions.HasSpecialization = function() return false end

            assert.are_same({"No Engineering specialization"}, GetReasons())
        end)

        it("should name a missing profession given as specialization when it has no specializations", function()
            fields[QUEST].requiredSpecialization = 356
            QuestieProfessions.HasSpecialization = function() return false end

            assert.are_same({"Fishing only"}, GetReasons())
        end)

        it("should name the level the player is above or below", function()
            fields[QUEST].requiredMaxLevel = 29
            assert.are_same({"Up to level 29"}, GetReasons())

            fields[QUEST].requiredMaxLevel = 0
            fields[QUEST].requiredLevel = 31
            assert.are_same({"Requires level 31"}, GetReasons())
        end)

        it("should name the reputation the player lacks or exceeds", function()
            fields[QUEST].requiredMinRep = {529, 9000}
            QuestieReputation.HasFactionAndReputationLevel = function(_, minRep)
                if minRep then
                    return false, true, true, true
                end
                return true, true, true, true
            end
            assert.are_same({"Requires Honored with Argent Dawn"}, GetReasons())

            fields[QUEST].requiredMinRep = nil
            fields[QUEST].requiredMaxRep = {529, 3000}
            QuestieReputation.HasFactionAndReputationLevel = function(_, _, maxRep)
                if maxRep then
                    return true, true, false, true
                end
                return true, true, true, true
            end
            assert.are_same({"Requires below Friendly with Argent Dawn"}, GetReasons())
        end)

        it("should name the turned-in quests that closed the quest, each once", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta", [203] = "Gamma"})
            Questie.db.char.complete = {[201] = true, [202] = true, [203] = true}
            fields[QUEST].exclusiveTo = {201}
            fields[QUEST].availableUntilCompleted = 202
            fields[QUEST].breadcrumbForQuestId = 201
            fields[QUEST].nextQuestInChain = 203

            assert.are_same({"Closed by Alpha, Beta, Gamma"}, GetReasons())
        end)

        it("should close a breadcrumb or a skipped quest when the quest after it is active", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta"})
            activeQuests = {[201] = {}, [202] = {}}
            fields[QUEST].breadcrumbForQuestId = 201
            fields[QUEST].nextQuestInChain = 202

            assert.are_same({"Closed by Alpha, Beta"}, GetReasons())
        end)

        it("should name the active quests that block the quest", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta", [203] = "Gamma"})
            activeQuests = {[201] = {}, [202] = {}, [203] = {}}
            fields[QUEST].exclusiveTo = {201}
            fields[QUEST].disabledByQuest = 202
            fields[QUEST].breadcrumbs = {203}

            assert.are_same({"Blocked by Alpha, Beta, Gamma"}, GetReasons())
        end)

        it("should close the quest when its only prequest is closed by an exclusive quest", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta"})
            Questie.db.char.complete = {[202] = true}
            fields[QUEST].preQuestSingle = {201}
            fields[201].exclusiveTo = {202}

            assert.are_same({"Closed by Beta"}, GetReasons())
        end)

        it("should name a missing prequest, or the prequests one of which is needed", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta"})
            fields[QUEST].preQuestSingle = {201}
            assert.are_same({"Requires Alpha"}, GetReasons())

            fields[QUEST].preQuestSingle = {201, 202}
            assert.are_same({"Requires one of: Alpha, Beta"}, GetReasons())
        end)

        it("should not name prequests the chain leads through", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta", [203] = "Gamma"})
            fields[QUEST].preQuestSingle = {201, 202}
            fields[QUEST].preQuestGroup = {201, 203}
            fields[QUEST].availableStartingWith = 201

            assert.are_same({"Requires Gamma"}, GetReasons({[201] = true}))
        end)

        it("should name the missing quests of a prequest group, unless an exclusive quest stands in for them", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta", [203] = "Gamma", [204] = "Delta"})
            Questie.db.char.complete = {[203] = true, [204] = true}
            fields[QUEST].preQuestGroup = {201, -202, 203, 205}
            fields[205] = {name = "Epsilon", exclusiveTo = {204}}

            assert.are_same({"Requires Alpha, Beta"}, GetReasons())
        end)

        it("should name an inactive parent quest and a quest that must be accepted first", function()
            SetQuestNames({[201] = "Alpha", [202] = "Beta"})
            fields[QUEST].parentQuest = 201
            fields[QUEST].availableStartingWith = 202

            assert.are_same({"Requires Alpha in the quest log", "After accepting Beta"}, GetReasons())

            activeQuests = {[201] = {}, [202] = {}}
            assert.are_same({}, GetReasons())
        end)

        it("should name a spell the player must learn or must not know", function()
            fields[QUEST].requiredSpell = 33388
            assert.are_same({"Requires Spell 33388"}, GetReasons())

            fields[QUEST].requiredSpell = -33388
            assert.are_same({}, GetReasons())
            knownSpells[33388] = true
            assert.are_same({"Unavailable after learning Spell 33388"}, GetReasons())
        end)

        it("should report a missing achievement", function()
            QuestieDB.private.CheckAchievementRequirements = function() return false end

            assert.are_same({"Achievement requirement"}, GetReasons())
        end)

        it("should name the world event of a quest hidden while the event is not running", function()
            QuestieEvent.IsEventQuest = function() return true end
            assert.are_same({}, GetReasons())

            QuestieCorrections.hiddenQuests[QUEST] = true
            assert.are_same({"During Hallow's End"}, GetReasons())

            QuestieEvent.IsEventActiveForQuest = function() return true end
            assert.are_same({}, GetReasons())
        end)

        it("should report a daily quest that is not offered today", function()
            DailyQuests.ShouldBeHidden = function() return true end
            assert.are_same({"Daily quest not active"}, GetReasons())

            DailyQuests.ShouldBeHidden = function() return false end
            Questie.db.global.unavailableQuestsDeterminedByTalking[GetRealmName()] = {[QUEST] = true}
            assert.are_same({"Daily quest not active"}, GetReasons())
        end)

        it("should report a missing arena rating for the TBC arena quests", function()
            Expansions.Current = Expansions.Tbc

            assert.are_same({}, GetReasons())
            assert.are_same({"Missing Arena Rating"}, QuestLockReasons.GetReasons(95158, {}))
        end)

        it("should list every reason, the ones that rule the quest out for good first", function()
            SetQuestNames({[201] = "Alpha"})
            fields[QUEST].requiredLevel = 31
            fields[QUEST].requiredRaces = 8
            fields[QUEST].requiredClasses = 1
            fields[QUEST].preQuestSingle = {201}
            fields[QUEST].requiredMaxLevel = 29

            assert.are_same({"Night Elf only", "Warrior only", "Up to level 29", "Requires level 31", "Requires Alpha"}, GetReasons())
        end)
    end)

    describe("FormatReasons", function()
        it("should join the reasons into one red text", function()
            assert.are_equal("[red]Warrior only; Requires level 31", QuestLockReasons.FormatReasons({"Warrior only", "Requires level 31"}))
        end)

        it("should return an empty text when there are no reasons", function()
            assert.are_equal("", QuestLockReasons.FormatReasons({}))
            assert.are_equal("", QuestLockReasons.FormatReasons(nil))
        end)
    end)
end)
