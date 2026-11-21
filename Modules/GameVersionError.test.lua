dofile("setupTests.lua")

describe("GameVersionError", function()
    local globalNames = {"QuestieLoader", "StaticPopupDialogs", "StaticPopup_Show", "DEFAULT_CHAT_FRAME"}
    local savedGlobals

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
    end)

    it("warns about an unsupported client with nothing but what Questie.toc loads", function()
        -- Questie.toc, the fallback for unsupported clients, loads only this file: no loader, no l10n.
        _G.QuestieLoader = nil
        _G.StaticPopupDialogs = {}
        _G.StaticPopup_Show = spy.new(function() end)
        _G.DEFAULT_CHAT_FRAME = {AddMessage = function() end}
        local loadTOC = dofile("cli/loadTOC.lua")

        loadTOC("Questie.toc")

        assert.spy(_G.StaticPopup_Show).was.called_with("QUESTIE_VERSION_ERROR")
        assert.matches("on an unsupported WoW game client!", _G.StaticPopupDialogs.QUESTIE_VERSION_ERROR.text, 1, true)
    end)
end)
