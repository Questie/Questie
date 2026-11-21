dofile("setupTests.lua")

describe("Bindings.xml", function()
    ---Each binding body by binding name, compiled the way the client does: a function of the key state, run in the
    ---global environment, where the addon namespace is out of reach.
    ---@return table<string, fun(keystate: string)>
    local function LoadBindings()
        local file = assert(io.open("Bindings.xml", "r"))
        local xml = file:read("*a")
        file:close()

        local bindings = {}
        for name, body in string.gmatch(xml, '<Binding name="([%w_]+)"[^>]*>(.-)</Binding>') do
            bindings[name] = assert(loadstring("return function(keystate) " .. body .. " end"))()
        end
        return bindings
    end

    local bindings
    local loader

    before_each(function()
        dofile("Modules/Journey/QuestieJourney.lua")
        dofile("Modules/Tracker/QuestieTracker.lua")
        bindings = LoadBindings()
        -- Tests hold the loader as a global; in the client a binding body finds none.
        loader = _G.QuestieLoader
        _G.QuestieLoader = nil
    end)

    after_each(function()
        _G.QuestieLoader = loader
    end)

    it("toggles the Journey window", function()
        local QuestieJourney = loader:ImportModule("QuestieJourney")
        QuestieJourney.ToggleJourneyWindow = spy.new(function() end)

        bindings.QUESTIE_TOGGLE_JOURNEY("down")

        assert.spy(QuestieJourney.ToggleJourneyWindow).was.called(1)
    end)

    it("toggles the tracker", function()
        local QuestieTracker = loader:ImportModule("QuestieTracker")
        QuestieTracker.ToggleTracker = spy.new(function() end)

        bindings.QUESTIE_TOGGLE_TRACKER("down")

        assert.spy(QuestieTracker.ToggleTracker).was.called(1)
    end)
end)
