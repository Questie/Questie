dofile("setupTests.lua")

describe("QuestieDatabase", function()
    local Database
    local savedConfig

    before_each(function()
        savedConfig = _G.QuestieConfig
        _G.QuestieConfig = nil
        dofile("Modules/QuestieDatabase.lua")
        Database = QuestieLoader:ImportModule("QuestieDatabase")
    end)

    after_each(function()
        _G.QuestieConfig = savedConfig
    end)

    it("creates a default profile and character scope", function()
        local db = Database:New("QuestieConfig", {
            profile = {enabled = true},
            char = {journey = {}},
            global = {locale = "auto"},
        })

        assert.equals("Default", db:GetCurrentProfile())
        assert.is_true(db.profile.enabled)
        assert.same({}, db.char.journey)
        assert.equals("auto", db.global.locale)
        assert.equals("Default", QuestieConfig.profileKeys["Testi - Ook Ook"])
    end)

    it("switches and copies profiles while firing profile callbacks", function()
        local db = Database:New("QuestieConfig", {profile = {enabled = true}})
        local events = {}
        local target = {
            OnProfileChanged = function(_, event, _, name)
                events[#events + 1] = event .. ":" .. name
            end,
        }
        db:RegisterCallback(target, "OnProfileChanged", "OnProfileChanged")

        db:SetProfile("Other")
        assert.is_true(db.profile.enabled)
        db.profile.enabled = false
        db:CopyProfile("Default")

        assert.is_true(db.profile.enabled)
        assert.same({"OnProfileChanged:Other"}, events)
    end)
end)
