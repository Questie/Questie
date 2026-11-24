dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyLinkInput", function()
    ---@type JourneyLinkInput
    local JourneyLinkInput
    local ui
    local originalHook, originalChatFrameUtil, originalInsertLink

    ---Like the client's, but only for functions that are called through the table they are in
    local function HookSecureFunction(owner, name, hook)
        if type(owner) == "string" then
            owner, name, hook = _G, owner, name
        end
        local original = assert(owner[name], "hooked something that doesn't exist")
        owner[name] = function(...)
            original(...)
            hook(...)
        end
    end

    before_each(function()
        ui = FakeUI.Install()
        originalHook, originalChatFrameUtil, originalInsertLink = _G.hooksecurefunc, _G.ChatFrameUtil, _G.ChatEdit_InsertLink
        _G.hooksecurefunc = HookSecureFunction
        _G.ChatFrameUtil, _G.ChatEdit_InsertLink = nil, nil

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Journey/JourneyLinkInput.lua")
        JourneyLinkInput = QuestieLoader:ImportModule("JourneyLinkInput")
    end)

    after_each(function()
        _G.hooksecurefunc, _G.ChatFrameUtil, _G.ChatEdit_InsertLink = originalHook, originalChatFrameUtil, originalInsertLink
        ui.Restore()
    end)

    ---@return table editBox
    local function CreateEditBox()
        local editBox = CreateFrame("EditBox", nil, UIParent)
        editBox:SetText("")
        JourneyLinkInput.Enable(editBox)
        return editBox
    end

    for name, install in pairs({
        ["ChatFrameUtil"] = function()
            _G.ChatFrameUtil = {InsertLink = function() end}
            return function(link) ChatFrameUtil.InsertLink(link) end
        end,
        ["the older function of Cata"] = function()
            _G.ChatEdit_InsertLink = function() end
            return function(link) ChatEdit_InsertLink(link) end
        end,
    }) do
        describe("with " .. name, function()
            local InsertLink

            before_each(function()
                InsertLink = install()
            end)

            it("should put a link into the box that is typed in", function()
                local first, second = CreateEditBox(), CreateEditBox()
                second:SetFocus()

                InsertLink("[Gnoll Paw]")

                assert.are_same({"", "[Gnoll Paw]"}, {first:GetText(), second:GetText()})
            end)

            it("should not touch a box that isn't typed in", function()
                local editBox = CreateEditBox()

                InsertLink("[Gnoll Paw]")

                assert.are.equal("", editBox:GetText())
            end)

            it("should only insert a link once, however many boxes take links", function()
                CreateEditBox()
                CreateEditBox()
                local third = CreateEditBox()
                third:SetFocus()

                InsertLink("[Gnoll Paw]")

                assert.are.equal("[Gnoll Paw]", third:GetText())
            end)
        end)
    end
end)
