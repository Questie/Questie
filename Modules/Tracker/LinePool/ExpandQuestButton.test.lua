dofile("setupTests.lua")

describe("ExpandQuestButton", function()
    ---@type ExpandQuestButton
    local ExpandQuestButton
    local originalCreateFrame

    local function _Button()
        return ExpandQuestButton.New(1, CreateFrame("Button"))
    end

    before_each(function()
        Questie.db.profile.trackerFontSizeQuest = 12
        Questie.db.profile.trackerFadeMinMaxButtons = false

        originalCreateFrame = _G.CreateFrame
        -- The texture mock lacks the sizing functions of the expand button texture
        _G.CreateFrame = setmetatable({}, {
            __index = originalCreateFrame,
            __call = function(_, ...)
                local frame = originalCreateFrame(...)
                frame.CreateTexture = function()
                    local texture = {}
                    setmetatable(texture, {__index = function() return function() end end})
                    return texture
                end
                return frame
            end,
        })

        dofile("Modules/Tracker/LinePool/ExpandQuestButton.lua")
        ExpandQuestButton = QuestieLoader:ImportModule("ExpandQuestButton")
    end)

    after_each(function()
        _G.CreateFrame = originalCreateFrame
    end)

    it("should highlight the minus icon itself on hover", function()
        local button = _Button()

        assert.are_same("Interface\\Buttons\\UI-MinusButton-Up", button:GetHighlightTexture():GetTexture())
    end)

    it("should highlight the plus icon itself on hover when collapsed", function()
        local button = _Button()

        button:SetMode(0)

        assert.are_same("Interface\\Buttons\\UI-PlusButton-Up", button:GetHighlightTexture():GetTexture())
    end)
end)
