dofile("setupTests.lua")

describe("TrackerMenu", function()
    ---@type TrackerMenu
    local TrackerMenu
    ---@type QuestieQuest
    local QuestieQuest
    ---@type TrackerUtils
    local TrackerUtils
    local originalLibStub, originalDialogs
    ---@type QuestiePopup
    local Popup
    local dialogErrors
    local timers
    local ctrlDown
    local globalOriginals
    local colorizeOriginal
    local getQuestOriginal, getColoredQuestNameOriginal
    local TrackerData, displayQuests

    before_each(function()
        originalLibStub, originalDialogs = _G.LibStub, _G.StaticPopupDialogs
        globalOriginals = {
            C_Timer = _G.C_Timer,
            IsControlKeyDown = _G.IsControlKeyDown,
            CLOSE = _G.CLOSE,
            GetLocale = _G.GetLocale,
            GetAchievementInfo = _G.GetAchievementInfo,
        }
        timers = {}
        ctrlDown = false
        _G.C_Timer = {After = function(_, fn) timers[#timers + 1] = fn end}
        _G.IsControlKeyDown = function() return ctrlDown end
        _G.CLOSE = "Close"
        _G.GetLocale = function() return "enUS" end
        _G.GetAchievementInfo = function(id) return id, "Achievement " .. id end
        colorizeOriginal = Questie.Colorize
        Questie.Colorize = function(_, text) return text end

        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local _, errors, _, private = fixture.NewEnvironment()
        dialogErrors = errors
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", private)
        Popup = QuestieLoader:ImportModule("QuestiePopup")

        QuestieLoader:ImportModule("QuestieTracker")
        QuestieLoader:ImportModule("TrackerBaseFrame")

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.UnFocus = function() end
        TrackerUtils.ShowObjectiveOnMap = function() end

        QuestieLoader:ImportModule("QuestieLink")
        QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieLoader:ImportModule("QuestieLib")
        TrackerData = QuestieLoader:ImportModule("TrackerData")
        getQuestOriginal = TrackerData.GetQuest
        -- Nested blocks stub this per test; after_each restores it for the whole file.
        getColoredQuestNameOriginal = TrackerData.GetColoredQuestName
        TrackerData.GetQuest = function(id) return {name = "Quest " .. id} end
        QuestieLoader:ImportModule("DistanceUtils")

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleQuestNotes = function() end

        _G.StaticPopupDialogs = {}
        _G.LibStub = {
            GetLibrary = function(_, _)
                return {
                    Create_UIDropDownMenu = function() end,
                    CloseDropDownMenus = function() end,
                }
            end
        }

        Questie.db = {
            char = {
                TrackerHiddenObjectives = {},
                TrackerHiddenQuests = {},
                collapsedQuests = {},
            },
            profile = {
                debugEnabled = false,
            }
        }

        dofile("Localization/l10n.lua")
        dofile("Modules/Tracker/TrackerMapEligibility.lua")
        displayQuests = {}
        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.RefreshQuest = spy.new(function(id) return displayQuests[id] end)

        dofile("Modules/Tracker/LinePool/TrackerMenu.lua")
        TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
    end)

    after_each(function()
        _G.LibStub, _G.StaticPopupDialogs = originalLibStub, originalDialogs
        for name, value in pairs(globalOriginals) do
            _G[name] = value
        end
        Questie.Colorize = colorizeOriginal
        TrackerData.GetQuest = getQuestOriginal
        TrackerData.GetColoredQuestName = getColoredQuestNameOriginal
    end)

    describe("Blizzard-first quest menus", function()
        before_each(function()
            TrackerData = QuestieLoader:ImportModule("TrackerData")
            TrackerData.GetColoredQuestName = function(quest) return quest.name end
        end)

        it("keeps ordinary actions for an unknown quest without map actions or an empty submenu", function()
            local quest = {
                Id = 91741, name = "Nibbled-On Book", Objectives = {}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }
            local menu = TrackerMenu:GetMenuForQuest(quest)
            local labels = {}
            for _, entry in ipairs(menu) do
                labels[#labels + 1] = entry.text
            end
            assert.are.same({
                "Nibbled-On Book", "Minimize Quest", "Show in Quest Log", "Link Quest to chat",
                "Untrack Quest", "Abandon Quest", "|cFF39c0edWoWHead URL|r", "Lock Tracker", CANCEL,
            }, labels)
        end)

        it("uses the original verified objective for hiding and showing map icons", function()
            TrackerUtils.ShowObjectiveOnMap = spy.new(function() end)
            local originalObjective = {Index = 2, spawnList = {{Spawns = {}}}}
            local originalQuest = {Id = 100, Objectives = {originalObjective}, IsComplete = function() return 0 end}
            local objective = {Index = 1, Description = "3/5 Wolves slain.", enrichment = originalObjective}
            local quest = {
                Id = 100, name = "Wolves", Objectives = {objective}, SpecialObjectives = {}, enrichment = originalQuest,
                IsComplete = function() return 0 end,
            }
            displayQuests[100] = quest
            local menu = TrackerMenu:GetMenuForQuest(quest)
            assert.spy(TrackerData.RefreshQuest).was.not_called()
            assert.are.equal("Objectives", menu[2].text)
            assert.are.equal("3/5 Wolves slain.", menu[2].menuList[1].text)
            local objectiveMenu = menu[2].menuList[1].menuList
            assert.are.equal("Hide Icons", objectiveMenu[3].text)
            objectiveMenu[3].func()
            assert.is_true(originalObjective.HideIcons)
            assert.is_nil(objective.HideIcons)
            assert.is_true(Questie.db.char.TrackerHiddenObjectives["100 2"])

            assert.are.equal("Show on Map", objectiveMenu[4].text)
            objectiveMenu[4].func()

            assert.spy(TrackerUtils.ShowObjectiveOnMap).was.called_with(TrackerUtils, originalObjective)
            assert.is_nil(originalObjective.HideIcons)
        end)

        it("does not offer quest-wide focus when a live objective lacks verified enrichment", function()
            local originalObjective = {Index = 1, spawnList = {{Spawns = {}}}}
            local quest = {
                Id = 100, name = "Changed quest", SpecialObjectives = {},
                Objectives = {{Description = "Wolf", enrichment = originalObjective}, {Description = "New task"}},
                enrichment = {Id = 100}, IsComplete = function() return 0 end,
            }
            local menu = TrackerMenu:GetMenuForQuest(quest)
            for _, entry in ipairs(menu) do
                assert.are_not.equal("Focus Quest", entry.text)
                assert.are_not.equal("Hide Icons", entry.text)
            end
            assert.are.equal("Objectives", menu[2].text)
            assert.are.equal(1, #menu[2].menuList)
        end)
    end)

    describe("stale map menus", function()
        local originalQuest, originalObjective, display, distance

        before_each(function()
            originalObjective = {Index = 3, HideIcons = true, spawnList = {{}}}
            originalQuest = {Id = 100, Objectives = {[3] = originalObjective}, Finisher = {NPC = {240}}}
            display = {
                Id = 100, enrichment = originalQuest, Objectives = {{enrichment = originalObjective}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            displayQuests[100] = display
            Questie.db.char.TrackerFocus = 11
            QuestieQuest.ToggleQuestNotes = spy.new(function() end)
            TrackerUtils.UnFocus = spy.new(function() end)
            TrackerUtils.ShowObjectiveOnMap = spy.new(function() end)
            TrackerUtils.ShowFinisherOnMap = spy.new(function() end)
            TrackerUtils.SetTomTomTarget = spy.new(function() end)
            distance = QuestieLoader:ImportModule("DistanceUtils")
            distance.GetNearestObjective = spy.new(function() return {50, 50}, 12, "Wolf" end)
        end)

        it("does not mutate, unfocus or navigate an objective replaced at the same original index", function()
            local menu = {}
            TrackerMenu.addShowHideObjectivesOption(menu, originalQuest, originalObjective)
            TrackerMenu.addShowObjectivesOnMapOption(menu, originalQuest, originalObjective)
            TrackerMenu.addTomTomOptionForObjective(menu, originalQuest, originalObjective)
            local replacement = {Index = 3, spawnList = {{}}}
            display.Objectives[1].enrichment = replacement
            originalQuest.Objectives[3] = replacement

            menu[1].func()
            menu[2].func()
            menu[3].func()

            assert.is_true(originalObjective.HideIcons)
            assert.is_nil(replacement.HideIcons)
            assert.are.equal(11, Questie.db.char.TrackerFocus)
            assert.spy(QuestieQuest.ToggleQuestNotes).was.not_called()
            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(TrackerUtils.ShowObjectiveOnMap).was.not_called()
            assert.spy(distance.GetNearestObjective).was.not_called()
        end)

        it("rejects old objective actions after the quest completes while its menu is open", function()
            local menu = {}
            TrackerMenu.addShowHideObjectivesOption(menu, originalQuest, originalObjective)
            TrackerMenu.addShowObjectivesOnMapOption(menu, originalQuest, originalObjective)
            TrackerMenu.addTomTomOptionForObjective(menu, originalQuest, originalObjective)
            display.IsComplete = function() return 1 end

            menu[1].func()
            menu[2].func()
            menu[3].func()

            assert.is_true(originalObjective.HideIcons)
            assert.are.equal(11, Questie.db.char.TrackerFocus)
            assert.spy(QuestieQuest.ToggleQuestNotes).was.not_called()
            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(TrackerUtils.ShowObjectiveOnMap).was.not_called()
            assert.spy(distance.GetNearestObjective).was.not_called()
        end)

        it("does not change icons or show a finisher after the quest is removed", function()
            display.IsComplete = function() return 1 end
            local menu = {}
            TrackerMenu.addShowHideQuestsOption(menu, originalQuest)
            TrackerMenu.addShowFinisherOnMapOption(menu, originalQuest)
            displayQuests[100] = nil

            menu[1].func()
            menu[2].func()

            assert.is_nil(originalQuest.HideIcons)
            assert.spy(QuestieQuest.ToggleQuestNotes).was.not_called()
            assert.spy(TrackerUtils.ShowFinisherOnMap).was.not_called()
        end)

        it("does not hide the whole quest after one objective loses verified enrichment", function()
            local menu = {}
            TrackerMenu.addShowHideQuestsOption(menu, originalQuest)
            display.Objectives[2] = {Description = "Unmatched new objective"}

            menu[1].func()

            assert.is_nil(originalQuest.HideIcons)
            assert.spy(QuestieQuest.ToggleQuestNotes).was.not_called()
        end)

        describe("recovery after losing eligibility", function()
            local function _Labels(menu)
                local labels = {}
                for _, entry in ipairs(menu) do
                    if entry.text then
                        labels[entry.text] = entry
                    end
                end
                return labels
            end

            before_each(function()
                TrackerData.GetColoredQuestName = function() return "Wolves" end
                -- Complete with no finisher in the database: no map action is eligible any more.
                display.IsComplete = function() return 1 end
                originalQuest.Finisher = nil
            end)

            it("unfocuses the quest from an open menu and offers Unfocus in a rebuilt one", function()
                Questie.db.char.TrackerFocus = 100
                QuestieQuest.ToggleNotes = spy.new(function() end)
                local openMenu = {}
                TrackerMenu.addFocusUnfocusOption(openMenu, originalQuest)

                openMenu[1].func()

                assert.spy(TrackerUtils.UnFocus).was.called(1)
                assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, true)
                assert.is_not_nil(_Labels(TrackerMenu:GetMenuForQuest(display))["Unfocus"])
            end)

            it("offers Unfocus for a focused objective once the objective menus are gone", function()
                Questie.db.char.TrackerFocus = "100 3"
                QuestieQuest.ToggleNotes = spy.new(function() end)
                local openMenu = {}
                TrackerMenu.addFocusOption(openMenu, originalQuest, originalObjective)
                openMenu[1].func()
                assert.spy(TrackerUtils.UnFocus).was.called(1)

                local labels = _Labels(TrackerMenu:GetMenuForQuest(display))
                assert.is_nil(labels["Objectives"])
                labels["Unfocus"].func()
                assert.spy(TrackerUtils.UnFocus).was.called(2)
            end)

            it("does not clear a newer focus from an open menu", function()
                Questie.db.char.TrackerFocus = 100
                local openMenu = {}
                TrackerMenu.addFocusUnfocusOption(openMenu, originalQuest)
                Questie.db.char.TrackerFocus = 200

                openMenu[1].func()

                assert.spy(TrackerUtils.UnFocus).was.not_called()
            end)

            it("shows hidden quest icons from a rebuilt menu but does not offer hiding them", function()
                originalQuest.HideIcons = true
                Questie.db.char.TrackerHiddenQuests[100] = true

                local labels = _Labels(TrackerMenu:GetMenuForQuest(display))
                labels["Show Icons"].func()

                assert.is_nil(originalQuest.HideIcons)
                assert.is_nil(Questie.db.char.TrackerHiddenQuests[100])
                assert.spy(QuestieQuest.ToggleQuestNotes).was.called_with(true)
                assert.is_nil(_Labels(TrackerMenu:GetMenuForQuest(display))["Hide Icons"])
            end)
        end)

        it("retains the original quest identity when a navigation menu outlives its display snapshot", function()
            TrackerUtils.SetQuestTomTomTarget = spy.new(function() return false end)
            local menu = {}
            TrackerMenu.addTomTomOptionForQuest(menu, display)
            display.enrichment = {Id = 100}

            menu[1].func()

            assert.spy(TrackerUtils.SetQuestTomTomTarget).was.called_with(100, originalQuest)
        end)
    end)

    it("does not hide map notes if the quest loses focus eligibility while its menu is open", function()
        TrackerUtils.FocusQuest = function() return false end
        QuestieQuest.ToggleNotes = spy.new(function() end)
        local menu = {}
        TrackerMenu.addFocusUnfocusOption(menu, {Id = 54})

        menu[1].func()

        assert.spy(QuestieQuest.ToggleNotes).was.not_called()
    end)

    describe("quest actions without a legacy quest log", function()
        local originals
        local compat
        local tracker

        before_each(function()
            originals = {
                QuestLogExFrame = _G.QuestLogExFrame,
                ClassicQuestLog = _G.ClassicQuestLog,
                QuestLogFrame = _G.QuestLogFrame,
                QuestMapFrame = _G.QuestMapFrame,
                StaticPopup_Show = _G.StaticPopup_Show,
                StaticPopup_Hide = _G.StaticPopup_Hide,
            }
            _G.QuestLogExFrame = nil
            _G.ClassicQuestLog = nil
            _G.QuestLogFrame = nil
            _G.QuestMapFrame = {IsShown = function() return true end}
            _G.StaticPopup_Show = spy.new(function() end)
            _G.StaticPopup_Hide = function() end
            compat = QuestieLoader:ImportModule("QuestieCompat")
            compat.QuestLog_Update = spy.new(function() end)
            tracker = QuestieLoader:ImportModule("QuestieTracker")
            tracker.UntrackQuestId = spy.new(function() end)
        end)

        after_each(function()
            _G.QuestLogExFrame = originals.QuestLogExFrame
            _G.ClassicQuestLog = originals.ClassicQuestLog
            _G.QuestLogFrame = originals.QuestLogFrame
            _G.QuestMapFrame = originals.QuestMapFrame
            _G.StaticPopup_Show = originals.StaticPopup_Show
            _G.StaticPopup_Hide = originals.StaticPopup_Hide
        end)

        it("untracks a quest without trying to refresh the missing legacy frame", function()
            local menu = {}
            TrackerMenu.addUntrackOption(menu, {Id = 783})
            menu[1].func()
            assert.spy(tracker.UntrackQuestId).was.called_with(tracker, 783)
            assert.spy(compat.QuestLog_Update).was.not_called()
        end)

        it("opens abandonment confirmation and restores selection on the modern client", function()
            compat.GetQuestLogSelection = function() return 3 end
            compat.GetQuestLogIndexByID = function() return 2 end
            compat.SelectQuestLogEntry = spy.new(function() end)
            compat.SetAbandonQuest = spy.new(function() end)
            compat.GetAbandonQuestItems = function() return nil end
            compat.GetAbandonQuestName = function() return "A Threat Within" end
            local menu = {}
            TrackerMenu.addAbandonedQuest(menu, {Id = 783})
            menu[1].func()
            assert.spy(StaticPopup_Show).was.called_with("ABANDON_QUEST", "A Threat Within")
            assert.spy(compat.SelectQuestLogEntry).was.called_with(2)
            assert.spy(compat.SelectQuestLogEntry).was.called_with(3)
            assert.spy(compat.QuestLog_Update).was.not_called()
        end)

        it("still refreshes a visible third-party quest log", function()
            _G.QuestLogExFrame = {IsShown = function() return true end}
            local menu = {}
            TrackerMenu.addUntrackOption(menu, {Id = 783})
            menu[1].func()
            assert.spy(compat.QuestLog_Update).was.called(1)
        end)
    end)

    describe("addShowHideObjectivesOption", function()
        it("should add 'Hide Icons' option and call ToggleQuestNotes(false) when icons are visible", function()
            local quest = {Id = 100}
            local objective = {Index = 1, HideIcons = nil, spawnList = {{}}}
            displayQuests[quest.Id] = {
                Id = quest.Id, enrichment = quest, Objectives = {{enrichment = objective}}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideObjectivesOption(menu, quest, objective)

            assert.are_same(1, #menu)
            assert.are_same("Hide Icons", menu[1].text)

            menu[1].func()

            assert.is_true(objective.HideIcons)
            assert.is_true(Questie.db.char.TrackerHiddenObjectives["100 1"])
            assert.spy(toggleSpy).was.called_with(false)
        end)

        it("should add 'Show Icons' option and call ToggleQuestNotes(true) when icons are hidden", function()
            local quest = {Id = 100}
            local objective = {Index = 1, HideIcons = true, spawnList = {{}}}
            displayQuests[quest.Id] = {
                Id = quest.Id, enrichment = quest, Objectives = {{enrichment = objective}}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideObjectivesOption(menu, quest, objective)

            assert.are_same(1, #menu)
            assert.are_same("Show Icons", menu[1].text)

            menu[1].func()

            assert.is_nil(objective.HideIcons)
            assert.is_nil(Questie.db.char.TrackerHiddenObjectives["100 1"])
            assert.spy(toggleSpy).was.called_with(true)
        end)
    end)

    describe("addShowHideQuestsOption", function()
        it("should add 'Hide Icons' option and call ToggleQuestNotes(false) when icons are visible", function()
            local quest = {Id = 200, HideIcons = nil}
            displayQuests[200] = {
                Id = 200, enrichment = quest, Objectives = {{enrichment = {Index = 1, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideQuestsOption(menu, quest)

            assert.are_same(1, #menu)
            assert.are_same("Hide Icons", menu[1].text)

            menu[1].func()

            assert.is_true(quest.HideIcons)
            assert.is_true(Questie.db.char.TrackerHiddenQuests[200])
            assert.spy(toggleSpy).was.called_with(false)
        end)

        it("should add 'Show Icons' option and call ToggleQuestNotes(true) when icons are hidden", function()
            local quest = {Id = 200, HideIcons = true}
            displayQuests[200] = {
                Id = 200, enrichment = quest, Objectives = {{enrichment = {Index = 1, spawnList = {{}}}}},
                SpecialObjectives = {}, IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowHideQuestsOption(menu, quest)

            assert.are_same(1, #menu)
            assert.are_same("Show Icons", menu[1].text)

            menu[1].func()

            assert.is_nil(quest.HideIcons)
            assert.is_nil(Questie.db.char.TrackerHiddenQuests[200])
            assert.spy(toggleSpy).was.called_with(true)
        end)
    end)

    describe("addShowObjectivesOnMapOption", function()
        it("should call ToggleQuestNotes(true) when objective has HideIcons set", function()
            local quest = {Id = 300, HideIcons = nil}
            local objective = {Index = 1, HideIcons = true, spawnList = {{}}}
            displayQuests[quest.Id] = {
                Id = quest.Id, enrichment = quest, Objectives = {{enrichment = objective}}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.is_nil(objective.HideIcons)
            assert.spy(toggleSpy).was.called_with(true)
        end)

        it("should call ToggleQuestNotes(true) when quest has HideIcons set", function()
            local quest = {Id = 300, HideIcons = true}
            local objective = {Index = 1, HideIcons = nil, spawnList = {{}}}
            displayQuests[quest.Id] = {
                Id = quest.Id, enrichment = quest, Objectives = {{enrichment = objective}}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.is_nil(quest.HideIcons)
            assert.spy(toggleSpy).was.called_with(true)
        end)

        it("should not call ToggleQuestNotes when nothing is hidden", function()
            local quest = {Id = 300, HideIcons = nil}
            local objective = {Index = 1, HideIcons = nil, spawnList = {{}}}
            displayQuests[quest.Id] = {
                Id = quest.Id, enrichment = quest, Objectives = {{enrichment = objective}}, SpecialObjectives = {},
                IsComplete = function() return 0 end,
            }
            local menu = {}

            local toggleSpy = spy.new(function() end)
            QuestieQuest.ToggleQuestNotes = toggleSpy

            TrackerMenu.addShowObjectivesOnMapOption(menu, quest, objective)
            menu[1].func()

            assert.spy(toggleSpy).was.not_called()
        end)
    end)

    describe("WoWHead URL dialog", function()
        local originalStaticPopupShow
        local compat
        local originalDisplayMessage

        local function findEntry(menu)
            for _, entry in ipairs(menu) do
                if entry.text and entry.text:find("WoWHead URL", 1, true) then
                    return entry
                end
            end
            error("WoWHead URL entry not found")
        end

        local function pressKey(frame, key)
            local editBox = frame:GetEditBox()
            editBox:GetScript("OnKeyDown")(editBox, key)
        end

        local function _TrackerQuest(questId)
            return {Id = questId, Objectives = {}, SpecialObjectives = {}, IsComplete = function() return 0 end}
        end

        local function runTimers()
            local pending = timers
            timers = {}
            for _, fn in ipairs(pending) do
                fn()
            end
        end

        before_each(function()
            originalStaticPopupShow = _G.StaticPopup_Show
            _G.StaticPopup_Show = spy.new(function() end)
            compat = QuestieLoader:ImportModule("QuestieCompat")
            originalDisplayMessage = compat.ActionStatus_DisplayMessage
            compat.ActionStatus_DisplayMessage = spy.new(function() end)

            local noop = function() end
            for _, name in ipairs({"addObjectiveOption", "addFocusUnfocusOption", "addTomTomOptionForQuest", "minMaxQuestOption",
                "addShowHideQuestsOption", "addShowFinisherOnMapOption", "addShowInQuestLogOption", "addLinkToChatOption",
                "addUntrackOption", "addAbandonedQuest", "addLockUnlockOption", "addAchieveLinkToChatOption",
                "addShowInAchievementsOption", "addUntrackAchieveOption"}) do
                TrackerMenu[name] = noop
            end
            TrackerData.GetColoredQuestName = function() return "Quest" end
            Questie.db.char.trackedAchievementIds = {}
        end)

        after_each(function()
            _G.StaticPopup_Show = originalStaticPopupShow
            compat.ActionStatus_DisplayMessage = originalDisplayMessage
        end)

        it("opens Questie's dialog from the quest menu instead of a Blizzard popup", function()
            local menu = TrackerMenu:GetMenuForQuest(_TrackerQuest(783))
            findEntry(menu).func()

            assert.spy(_G.StaticPopup_Show).was.not_called()
            assert.is_nil(_G.StaticPopupDialogs.QUESTIE_WOWHEAD_URL)
            local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
            assert.is_not_nil(frame)
            assert.equals("https://www.wowhead.com/mop-classic/quest=783", frame:GetEditBoxText())
            assert.is_truthy(frame.Text:GetText():find("Quest 783", 1, true))
            assert.is_true(frame:GetEditBox().focused)
            assert.is_true(frame:GetEditBox().highlighted)
            assert.same({}, dialogErrors)
        end)

        it("opens Questie's dialog from the achievement menu instead of a Blizzard popup", function()
            local menu = TrackerMenu:GetMenuForAchievement({Id = 42})
            findEntry(menu).func()

            assert.spy(_G.StaticPopup_Show).was.not_called()
            assert.is_nil(_G.StaticPopupDialogs.QUESTIE_WOWHEAD_AURL)
            local frame = Popup.FindVisible("QUESTIE_WOWHEAD_AURL")
            assert.is_not_nil(frame)
            assert.equals("https://www.wowhead.com/mop-classic/achievement=42", frame:GetEditBoxText())
            assert.is_truthy(frame.Text:GetText():find("Achievement 42", 1, true))
            assert.same({}, dialogErrors)
        end)

        describe("focus", function()
            local originalSmartNavigation
            local originalIsMoP
            local originalIsForever

            before_each(function()
                originalSmartNavigation = _G.SmartNavigation
                originalIsMoP = Questie.IsMoP
                originalIsForever = Questie.IsForever
            end)

            after_each(function()
                _G.SmartNavigation = originalSmartNavigation
                Questie.IsMoP = originalIsMoP
                Questie.IsForever = originalIsForever
            end)

            local function openQuestDialog()
                local menu = TrackerMenu:GetMenuForQuest(_TrackerQuest(783))
                findEntry(menu).func()
                local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
                assert.is_not_nil(frame)
                assert.equals("https://www.wowhead.com/forever/quest=783", frame:GetEditBoxText())
                assert.same({}, dialogErrors)
                return frame:GetEditBox()
            end

            local function setSmartNavigationShown(shown)
                _G.SmartNavigation = {IsShown = function() return shown end}
            end

            it("selects the URL on Forever while Blizzard's controller navigation is hidden", function()
                Questie.IsForever = true
                setSmartNavigationShown(false)

                local editBox = openQuestDialog()

                assert.is_true(editBox.focused)
                assert.is_true(editBox.highlighted)
                assert.is_nil(editBox:GetScript("OnEditFocusGained"))
            end)

            it("selects the URL on the first click instead while Blizzard's controller navigation is shown", function()
                Questie.IsForever = true
                setSmartNavigationShown(true)

                local editBox = openQuestDialog()
                assert.is_falsy(editBox.focused)
                assert.is_falsy(editBox.highlighted)

                editBox:GetScript("OnEditFocusGained")(editBox)
                assert.is_true(editBox.highlighted)
            end)

            it("clears the click handler when a later dialog can select the URL itself", function()
                Questie.IsForever = true
                setSmartNavigationShown(true)
                openQuestDialog()
                Popup.Hide("QUESTIE_WOWHEAD_URL")

                setSmartNavigationShown(false)
                local editBox = openQuestDialog()
                assert.is_true(editBox.focused)
                assert.is_nil(editBox:GetScript("OnEditFocusGained"))
            end)

            it("always selects the URL on other flavors", function()
                Questie.IsMoP = true
                Questie.IsForever = false
                setSmartNavigationShown(true)

                local menu = TrackerMenu:GetMenuForQuest(_TrackerQuest(783))
                findEntry(menu).func()
                local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
                assert.is_not_nil(frame)
                assert.equals("https://www.wowhead.com/mop-classic/quest=783", frame:GetEditBoxText())
                assert.same({}, dialogErrors)
                local editBox = frame:GetEditBox()

                assert.is_true(editBox.focused)
                assert.is_true(editBox.highlighted)
            end)
        end)

        describe("in combat", function()
            local QuestieCombatQueue
            local originalQueue
            local originalInCombatLockdown
            local queued

            before_each(function()
                QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
                originalQueue = QuestieCombatQueue.Queue
                originalInCombatLockdown = _G.InCombatLockdown
                queued = {}
                QuestieCombatQueue.Queue = function(self, func, ...)
                    assert.equals(QuestieCombatQueue, self)
                    queued[#queued + 1] = {func = func, args = {...}}
                end
                _G.InCombatLockdown = function() return true end
            end)

            after_each(function()
                QuestieCombatQueue.Queue = originalQueue
                _G.InCombatLockdown = originalInCombatLockdown
            end)

            local function runQueue()
                _G.InCombatLockdown = function() return false end
                for _, entry in ipairs(queued) do
                    entry.func(unpack(entry.args))
                end
            end

            it("opens the quest dialog after combat", function()
                local menu = TrackerMenu:GetMenuForQuest(_TrackerQuest(783))
                findEntry(menu).func()

                assert.is_nil(Popup.FindVisible("QUESTIE_WOWHEAD_URL"))
                assert.equals(1, #queued)

                runQueue()

                local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
                assert.is_not_nil(frame)
                assert.equals("https://www.wowhead.com/mop-classic/quest=783", frame:GetEditBoxText())
                assert.spy(_G.StaticPopup_Show).was.not_called()
                assert.same({}, dialogErrors)
            end)

            it("opens the achievement dialog after combat", function()
                local menu = TrackerMenu:GetMenuForAchievement({Id = 42})
                findEntry(menu).func()

                assert.is_nil(Popup.FindVisible("QUESTIE_WOWHEAD_AURL"))
                assert.equals(1, #queued)

                runQueue()

                local frame = Popup.FindVisible("QUESTIE_WOWHEAD_AURL")
                assert.is_not_nil(frame)
                assert.equals("https://www.wowhead.com/mop-classic/achievement=42", frame:GetEditBoxText())
                assert.same({}, dialogErrors)
            end)
        end)

        it("still opens for a quest missing from the database", function()
            TrackerData.GetQuest = function() return nil end
            Popup.Show("QUESTIE_WOWHEAD_URL", 999999)

            local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
            assert.is_not_nil(frame)
            assert.equals("https://www.wowhead.com/mop-classic/quest=999999", frame:GetEditBoxText())
            assert.same({}, dialogErrors)
        end)

        it("closes after the delay on Ctrl+C and reports once for a double press", function()
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
            ctrlDown = true
            pressKey(frame, "C")
            pressKey(frame, "C")

            assert.equals(2, #timers)
            assert.is_not_nil(Popup.FindVisible("QUESTIE_WOWHEAD_URL"))
            runTimers()
            assert.is_nil(Popup.FindVisible("QUESTIE_WOWHEAD_URL"))
            assert.spy(compat.ActionStatus_DisplayMessage).was.called(1)
        end)

        it("does not let an old Ctrl+C timer close a reopened dialog", function()
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            ctrlDown = true
            pressKey(Popup.FindVisible("QUESTIE_WOWHEAD_URL"), "C")
            Popup.Hide("QUESTIE_WOWHEAD_URL")
            Popup.Show("QUESTIE_WOWHEAD_URL", 784)
            runTimers()

            local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
            assert.is_not_nil(frame)
            assert.is_truthy(frame:GetEditBoxText():find("quest=784$"))
            assert.spy(compat.ActionStatus_DisplayMessage).was.not_called()
        end)

        it("does not let an old Ctrl+C timer close a dialog reopened without hiding it", function()
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            ctrlDown = true
            pressKey(Popup.FindVisible("QUESTIE_WOWHEAD_URL"), "C")
            Popup.Show("QUESTIE_WOWHEAD_URL", 784)
            runTimers()

            local frame = Popup.FindVisible("QUESTIE_WOWHEAD_URL")
            assert.is_not_nil(frame)
            assert.is_truthy(frame:GetEditBoxText():find("quest=784$"))
            assert.spy(compat.ActionStatus_DisplayMessage).was.not_called()
        end)

        it("does not stack key handlers when the dialog is shown again", function()
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            Popup.Hide("QUESTIE_WOWHEAD_URL")
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            ctrlDown = true
            pressKey(Popup.FindVisible("QUESTIE_WOWHEAD_URL"), "C")

            assert.equals(1, #timers)
        end)

        it("ignores C without Ctrl", function()
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            ctrlDown = false
            pressKey(Popup.FindVisible("QUESTIE_WOWHEAD_URL"), "C")

            assert.equals(0, #timers)
        end)

        it("closes on Enter and on Escape", function()
            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            local editBox = Popup.FindVisible("QUESTIE_WOWHEAD_URL"):GetEditBox()
            editBox:GetScript("OnEnterPressed")(editBox)
            assert.is_nil(Popup.FindVisible("QUESTIE_WOWHEAD_URL"))

            Popup.Show("QUESTIE_WOWHEAD_URL", 783)
            editBox = Popup.FindVisible("QUESTIE_WOWHEAD_URL"):GetEditBox()
            editBox:GetScript("OnEscapePressed")(editBox)
            assert.is_nil(Popup.FindVisible("QUESTIE_WOWHEAD_URL"))
            assert.same({}, dialogErrors)
        end)
    end)
end)
