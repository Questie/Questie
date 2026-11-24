dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("Quests by Faction", function()
    local questsByFaction
    local ui
    local originalQuestie
    local canvas, watchedFaction, headers, areHeadersExpanded

    local TIMBERMAW, ARGENT_DAWN, ALDOR = 576, 529, 932

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie = _G.Questie
        _G.Questie = {db = {profile = {}, char = {complete = {}, hidden = {}}}, icons = {}, Error = function(_, message) error(message) end}
        watchedFaction, headers, areHeadersExpanded = nil, {}, false

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return {Id = id} end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            return {{type = "text", text = "Details of quest " .. quest.Id}}
        end
        QuestieLoader:ImportModule("ActiveQuests").Get = function() end
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function() end
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        local factions = {{}, {id = TIMBERMAW}, {id = ARGENT_DAWN}, {id = ALDOR}} -- The first one is a header
        -- Factions below a collapsed header aren't listed
        QuestieCompat.ExpandFactionHeader = function(index) areHeadersExpanded = areHeadersExpanded or index == 0 end
        QuestieCompat.GetNumFactions = function() return areHeadersExpanded and #factions or 1 end
        QuestieCompat.GetFactionInfo = function(index)
            local faction = factions[index]
            local isWatched = faction.id ~= nil and faction.id == watchedFaction
            local isHeader = faction.id == nil or headers[faction.id] == true
            return "name", nil, nil, nil, nil, nil, nil, nil, isHeader, nil, nil, isWatched, nil, faction.id
        end

        local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieJourney.availableFactionExpansions = {classic = "Classic", tbc = "Burning Crusade"}
        QuestieJourney.availableFactionExpansionOrder = {"classic", "tbc"}
        QuestieJourney.factionsByExpansion = {
            classic = {[TIMBERMAW] = "Timbermaw Hold", [ARGENT_DAWN] = "Argent Dawn"},
            tbc = {[ALDOR] = "The Aldor"},
        }
        -- Which quests belong to a faction has its own tests
        questsByFaction = {
            CollectFactionQuests = function(_, factionId)
                if factionId == ARGENT_DAWN then return nil end -- Has no quests
                return {{value = "a", text = "Quests of " .. factionId, children = {{value = 54, text = "Quest 54"}}}}
            end,
        }
        QuestieJourney.private.questsByFaction = questsByFaction
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end

        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyPanes.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyQuestList.lua")
        dofile("Modules/Journey/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/tabs/QuestsByFaction/QuestsByFactionsTab.lua")
        questsByFaction.Build(canvas)
    end)

    after_each(function()
        _G.Questie = originalQuestie
        ui.Restore()
    end)

    ---@param index number
    ---@return table dropdown
    local function Dropdown(index)
        return ui.FindByTemplate(canvas, "WowStyle1DropdownTemplate")[index]
    end

    ---@param index number
    ---@param text string
    local function Choose(index, text)
        local dropdown = Dropdown(index)
        dropdown:OpenMenu()
        for _, entry in ipairs(dropdown.menuEntries) do
            if entry.text == text then
                dropdown:Pick(entry)
                ui.RunUntilIdle()
                return
            end
        end
        error("There is no choice " .. text)
    end

    local function Refresh()
        questsByFaction.Refresh()
        ui.RunUntilIdle()
    end

    -- Opens the tab, like JourneyWindow does
    local function Open()
        questsByFaction.OnSelected()
        Refresh()
    end

    ---@return string[]
    local function ListTexts()
        return ui.RowTexts(canvas, 1)
    end

    ---@return boolean
    local function SaysThereAreNone()
        return #ui.FindAll(canvas, function(frame) return frame.text == "No Quests found" and frame:IsVisible() end) == 1
    end

    it("should start with the faction the player watches, in whichever expansion it is", function()
        watchedFaction = ALDOR

        Open()

        assert.are_same({"Quests of 932"}, ListTexts())
        assert.are_same({"Burning Crusade", "The Aldor"}, {Dropdown(1).text, Dropdown(2).text})
    end)

    it("should start with the first expansion and no faction when none is watched", function()
        Open()

        assert.are_same({}, ListTexts())
        assert.is_false(SaysThereAreNone())
        assert.are_same({"Classic", "Select Faction"}, {Dropdown(1).text, Dropdown(2).text})
    end)

    it("should follow the watched faction as long as nothing was chosen", function()
        watchedFaction = ALDOR
        Open()
        watchedFaction = TIMBERMAW

        Open()

        assert.are_same({"Quests of 576"}, ListTexts())
        assert.are_same({"Classic", "Timbermaw Hold"}, {Dropdown(1).text, Dropdown(2).text})
    end)

    it("should not go to another faction while it is open, whatever about quests changes", function()
        watchedFaction = ALDOR
        Open()
        watchedFaction = TIMBERMAW

        Refresh()

        assert.are_same({"Quests of 932"}, ListTexts())
        assert.are_same({"Burning Crusade", "The Aldor"}, {Dropdown(1).text, Dropdown(2).text})
    end)

    it("should stay with the faction the user chose", function()
        watchedFaction = ALDOR
        Open()
        Choose(1, "Classic")
        assert.are_same({}, ListTexts())
        Choose(2, "Timbermaw Hold")

        watchedFaction = ALDOR
        Open()

        assert.are_same({"Quests of 576"}, ListTexts())
        assert.are_same({"Classic", "Timbermaw Hold"}, {Dropdown(1).text, Dropdown(2).text})
    end)

    it("should not follow a header, although some can be watched", function()
        watchedFaction = ALDOR
        headers[ALDOR] = true

        Open()

        assert.are_same({"Classic", "Select Faction"}, {Dropdown(1).text, Dropdown(2).text})
    end)

    it("should close the details when another faction is chosen", function()
        watchedFaction = ALDOR
        Open()
        questsByFaction.OpenQuest(54)
        ui.RunUntilIdle()
        assert.are.equal(1, #ui.Rows(canvas, 2))

        Choose(1, "Classic")
        Choose(2, "Timbermaw Hold")

        assert.are.equal(0, #ui.Rows(canvas, 2))
    end)

    it("should only offer the factions of the chosen expansion, sorted by name", function()
        Open()
        Dropdown(2):OpenMenu()

        local texts = {}
        for _, entry in ipairs(Dropdown(2).menuEntries) do
            table.insert(texts, entry.text)
        end
        assert.are_same({"Argent Dawn", "Timbermaw Hold"}, texts)
    end)

    it("should offer no factions for an expansion without any", function()
        QuestieLoader:ImportModule("QuestieJourney").factionsByExpansion.tbc = {}
        Open()

        Choose(1, "Burning Crusade")

        Dropdown(2):OpenMenu()
        assert.are.equal(0, #Dropdown(2).menuEntries)
    end)

    it("should list nothing for a faction without quests", function()
        Open()

        Choose(2, "Argent Dawn")

        assert.are_same({}, ListTexts())
        assert.is_true(SaysThereAreNone())
    end)

    it("should show a quest without choosing another faction", function()
        watchedFaction = TIMBERMAW
        Open()

        questsByFaction.OpenQuest(99)

        assert.are.equal("Details of quest 99", ui.Rows(canvas, 2)[1].elementData.text)
        assert.are_same({"Quests of 576"}, ListTexts())
        assert.are.equal("Timbermaw Hold", Dropdown(2).text)
    end)
end)
