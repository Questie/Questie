dofile("setupTests.lua")

describe("Tutorial", function()
    local Tutorial
    local originals

    ---Starts Questie's tutorials for the account and profile; true if the objective style popup opened.
    local function _Initialize(global, profile)
        Questie.db = {global = global, profile = profile}
        local opened = false
        Tutorial.CreateChooseObjectiveTypeFrame = function() opened = true end
        Tutorial.Initialize()
        return opened
    end

    before_each(function()
        originals = {db = Questie.db, IsSoD = Questie.IsSoD, IsForever = Questie.IsForever}
        Questie.IsSoD = false
        Questie.IsForever = true -- Leaves out the battleground tutorial.
        QuestieLoader:ImportModule("QuestieCombatQueue").Queue = function(_, callback) callback() end
        dofile("Modules/Tutorial/Tutorial.lua")
        Tutorial = QuestieLoader:ImportModule("Tutorial")
    end)

    after_each(function()
        Questie.db, Questie.IsSoD, Questie.IsForever = originals.db, originals.IsSoD, originals.IsForever
    end)

    describe("objective style choice", function()
        it("asks an account once more that chose before blobs were offered", function()
            assert.is_true(_Initialize({tutorialObjectiveTypeChosen = true}, {enableQuestiePolygons = false}))
        end)

        it("asks a new account", function()
            assert.is_true(_Initialize({}, {}))
        end)

        it("does not ask an account that chose with blobs offered", function()
            assert.is_false(_Initialize({tutorialObjectiveStyleWithBlobsChosen = true}, {enableQuestiePolygons = false}))
        end)

        it("counts a profile showing blobs as having chosen, also after it leaves blobs", function()
            local global = {}
            assert.is_false(_Initialize(global, {enableQuestiePolygons = true}))
            assert.is_false(_Initialize(global, {enableQuestiePolygons = false}))
        end)
    end)
end)
