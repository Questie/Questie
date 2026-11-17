dofile("setupTests.lua")

describe("QuestieRuntime", function()
    local Runtime
    local oldChatInfo, oldTimer

    before_each(function()
        oldChatInfo, oldTimer = _G.C_ChatInfo, _G.C_Timer
        dofile("Modules/QuestieRuntime.lua")
        Runtime = QuestieLoader:ImportModule("QuestieRuntime")
    end)

    after_each(function()
        _G.C_ChatInfo, _G.C_Timer = oldChatInfo, oldTimer
    end)

    it("dispatches native events with the event name first", function()
        local addon = Runtime:CreateAddon()
        local received
        addon:RegisterEvent("QUESTIE_TEST", function(event, value)
            received = event .. ":" .. value
        end)

        addon._runtime.frame.scripts.OnEvent(addon._runtime.frame, "QUESTIE_TEST", "ok")
        assert.equals("QUESTIE_TEST:ok", received)
    end)

    it("reassembles multipart addon messages", function()
        local messages = {}
        local sent = {}
        _G.C_ChatInfo = {
            RegisterAddonMessagePrefix = function() end,
            SendAddonMessage = function(_, message, distribution, target)
                sent[#sent + 1] = {message, distribution, target}
            end,
        }
        local addon = Runtime:CreateAddon()
        addon:RegisterComm("QuestieTest", function(_, message)
            messages[#messages + 1] = message
        end)

        addon:SendCommMessage("QuestieTest", string.rep("x", 300), "PARTY", "Target")
        assert.equals(2, #sent)
        addon._runtime.frame.scripts.OnEvent(addon._runtime.frame, "CHAT_MSG_ADDON", "QuestieTest", sent[1][1], "PARTY", "Sender")
        addon._runtime.frame.scripts.OnEvent(addon._runtime.frame, "CHAT_MSG_ADDON", "QuestieTest", sent[2][1], "PARTY", "Sender")
        assert.equals(string.rep("x", 300), messages[1])
    end)
end)
