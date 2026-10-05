dofile("setupTests.lua")

describe("QuestieNameplate removal", function()
    ---@type QuestieNameplate
    local QuestieNameplate
    local savedGlobals, originalIsForever, frames, guids
    local firstGuid = "Creature-0-0-0-0-123-00000001"
    local secondGuid = "Creature-0-0-0-0-456-00000002"
    local globalNames = {"UnitGUID", "UnitName", "IsInInstance", "C_NamePlate", "CreateFrame", "tremove"}

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        originalIsForever = Questie.IsForever
        Questie.IsForever = true
        Questie.db.profile.nameplateEnabled = true
        Questie.db.profile.nameplateScale = 1
        Questie.db.profile.nameplateX = 0
        Questie.db.profile.nameplateY = 0
        guids = {nameplate1 = firstGuid, nameplate2 = secondGuid}
        _G.UnitGUID = function(token) return guids[token] end
        _G.UnitName = function() return "Creature" end
        _G.IsInInstance = function() return false end
        _G.C_NamePlate = {GetNamePlateForUnit = function(token) return token end}
        _G.tremove = table.remove
        frames = {}
        local createFrame = savedGlobals.CreateFrame
        _G.CreateFrame = function(...)
            local frame = createFrame(...)
            frame.SetFrameStrata = function() end
            frame.SetFrameLevel = function() end
            frame.EnableMouse = function() end
            frame.SetParent = function(self, parent) self.parent = parent end
            frame.CreateTexture = function()
                return {
                    ClearAllPoints = function() end,
                    SetAllPoints = function() end,
                    SetTexture = spy.new(function() end),
                }
            end
            frames[#frames + 1] = frame
            return frame
        end
        dofile("Modules/QuestieNameplate.lua")
        QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")
        QuestieNameplate.GetIcon = spy.new(function() return "quest-icon" end)
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
        Questie.IsForever = originalIsForever
    end)

    for _, state in ipairs({"restricted identity", "disabled icons", "inside instance"}) do
        it("cleans up the recorded token with " .. state, function()
            QuestieNameplate:NameplateCreated("nameplate1")
            QuestieNameplate:NameplateCreated("nameplate2")
            _G.UnitGUID = function() error("Removal must not query the disappearing unit's identity") end
            if state == "disabled icons" then
                Questie.db.profile.nameplateEnabled = false
            elseif state == "inside instance" then
                _G.IsInInstance = function() return true end
            end

            QuestieNameplate:NameplateDestroyed("nameplate1")

            assert.is_false(frames[1]:IsVisible())
            assert.spy(frames[1].Icon.SetTexture).was.called_with(frames[1].Icon, nil)
            assert.is_true(frames[2]:IsVisible())
            QuestieNameplate:UpdateNameplate()
            assert.spy(QuestieNameplate.GetIcon).was.called(3)
            assert.spy(QuestieNameplate.GetIcon).was.called_with(secondGuid)
        end)
    end

    it("removes the old icon even when its token no longer resolves to a GUID", function()
        QuestieNameplate:NameplateCreated("nameplate1")
        guids.nameplate1 = nil

        QuestieNameplate:NameplateDestroyed("nameplate1")

        assert.is_false(frames[1]:IsVisible())
        QuestieNameplate:UpdateNameplate()
        assert.spy(QuestieNameplate.GetIcon).was.called(1)
    end)

    it("tolerates untracked and repeated removals and reuses the released icon frame", function()
        QuestieNameplate:NameplateCreated("nameplate1")
        QuestieNameplate:NameplateDestroyed("nameplate9")
        assert.is_true(frames[1]:IsVisible())

        QuestieNameplate:NameplateDestroyed("nameplate1")
        QuestieNameplate:NameplateDestroyed("nameplate1")
        guids.nameplate1 = secondGuid
        QuestieNameplate:NameplateCreated("nameplate1")

        assert.are.equal(1, #frames)
        assert.is_true(frames[1]:IsVisible())
        assert.are.equal("nameplate1", frames[1].parent)
        QuestieNameplate:NameplateDestroyed("nameplate1")
        assert.is_false(frames[1]:IsVisible())
    end)
end)
