dofile("setupTests.lua")

describe("Questie AceGUI TreeGroup customizations", function()
    local widget, aceGUI

    before_each(function()
        -- Reuse native controls, not dialog policy. Add only the APIs TreeGroup consumes.
        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local env = fixture.NewEnvironment()
        local createFrame = env.CreateFrame
        env.CreateFrame = function(kind, name, parent, template)
            local frame = createFrame(kind, name, parent)
            function frame:SetParent(value) self.parent = value end
            function frame:SetFrameLevel(value) self.frameLevel = value end
            function frame:GetFrameLevel() return self.frameLevel or 1 end
            function frame:GetPushedTextOffset() return 2, -3 end
            function frame:LockHighlight() self.locked = true end
            function frame:UnlockHighlight() self.locked = false end
            function frame:SetValue(value) self.value = value end
            function frame:GetValue() return self.value end
            function frame:SetMinMaxValues(low, high) self.min, self.max = low, high end
            function frame:GetMinMaxValues() return self.min, self.max end
            for _, method in ipairs({"EnableMouseWheel", "SetBackdropColor", "SetBackdropBorderColor",
                "SetResizable", "SetResizeBounds", "SetValueStep"}) do
                frame[method] = function() end
            end
            if template == "OptionsListButtonTemplate" then
                frame.text = frame:CreateFontString()
                frame.toggle = env.CreateFrame("Button", nil, frame)
            end
            return frame
        end
        local constructor
        local nextID = 0
        aceGUI = {tooltip = env.CreateFrame("Frame")}
        function aceGUI.tooltip:SetOwner(owner) self.owner = owner end
        function aceGUI:GetWidgetVersion() return nil end
        function aceGUI:GetNextWidgetNum() nextID = nextID + 1; return nextID end
        function aceGUI:RegisterWidgetType(kind, factory)
            assert.equals("TreeGroup", kind)
            constructor = factory
        end
        function aceGUI:RegisterAsContainer(container)
            container.frame.obj = container
            container.events = {}
            function container:Fire(event, value)
                self.events[#self.events + 1] = {event, value}
            end
            return container
        end
        function aceGUI:ClearFocus() end
        env.LibStub = function(name)
            assert.equals("AceGUI-3.0", name)
            return aceGUI
        end
        setfenv(assert(loadfile("Libs/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua")), env)()
        widget = constructor()
        -- A laid-out container has a non-UIParent parent and enough height for these rows.
        widget.frame:SetParent(env.CreateFrame("Frame"))
        widget.treeframe:SetHeight(200)
        widget:OnAcquire()
    end)

    it("renders inline and child-gutter icons with independent size and offset", function()
        widget.localstatus.groups.root = true
        widget:SetTree({{value = "root", text = "Root", icon = "root-icon", children = {
            {value = "quest", text = "Quest", icon = "quest-icon", iconSize = 20,
                useIconGutter = true, iconGutterOffset = 3, iconCoords = {0.1, 0.9, 0.2, 0.8}},
        }}})
        local root, child = widget.buttons[1], widget.buttons[2]
        assert.same({"LEFT", 24, 2}, root.text.points[#root.text.points])
        assert.same({"LEFT", 8, 0}, root.icon.points[1])
        assert.equals(16, root.icon:GetWidth())
        assert.equals("quest-icon", child.icon.texture)
        assert.equals(20, child.icon:GetWidth())
        assert.equals(20, child.icon:GetHeight())
        assert.same({0.1, 0.9, 0.2, 0.8}, child.icon.texCoords)
        assert.same({"LEFT", 9, 1}, child.icon.points[1])
        assert.same({"LEFT", 29, 2}, child.text.points[#child.text.points])
        assert.equals("root\001quest", child.uniquevalue)
    end)

    it("clears icon texture and pressed anchors when a row is recycled without an icon", function()
        widget:SetTree({{value = "first", text = "First", icon = "icon", iconSize = 24}})
        local button = widget.buttons[1]
        button:GetScript("OnMouseDown")(button)
        assert.same({"LEFT", 10, -3}, button.icon.points[1])
        button:GetScript("OnMouseUp")(button)
        assert.same({"LEFT", 8, 0}, button.icon.points[1])
        button:GetScript("OnMouseDown")(button)
        button:GetScript("OnLeave")(button)
        assert.same({"LEFT", 8, 0}, button.icon.points[1])

        widget:SetTree({{value = "second", text = "Second"}})
        assert.equals(button, widget.buttons[1])
        assert.is_nil(button.icon.texture)
        assert.is_nil(button.iconBaseOffset)
        assert.equals("Second", button.text:GetText())
        assert.same({"LEFT", 8, 2}, button.text.points[#button.text.points])
        button:GetScript("OnMouseDown")(button)
        assert.is_nil(button.icon.texture)
    end)

    it("selects on click but refreshes rows only after the button's next frame", function()
        widget:SetTree({{value = "root", text = "Root", children = {{value = "child", text = "Child"}}}})
        local button = widget.buttons[1]
        local refresh = spy.on(widget, "RefreshTree")
        button:Click()
        assert.equals("root", widget.localstatus.selected)
        assert.same({{"OnClick", "root"}, {"OnGroupSelected", "root"}}, widget.events)
        assert.spy(refresh).was.not_called()
        button:GetScript("OnUpdate")(button)
        assert.spy(refresh).was.called(1)
        assert.is_nil(button:GetScript("OnUpdate"))

        button:GetScript("OnDoubleClick")(button)
        assert.is_true(widget.localstatus.groups.root)
        assert.equals(1, #widget.lines)
        assert.spy(refresh).was.called(1)
        button:GetScript("OnUpdate")(button)
        assert.spy(refresh).was.called(2)
        assert.equals("Child", widget.buttons[2].text:GetText())
        assert.is_nil(button:GetScript("OnUpdate"))
    end)

    it("shows custom tooltip text, falls back to row text, and respects tooltip disabling", function()
        widget:SetTree({{value = "quest", text = "Short", tooltipText = "Full quest title"}})
        local button = widget.buttons[1]
        button:GetScript("OnEnter")(button)
        assert.equals(button, aceGUI.tooltip.owner)
        assert.equals("Full quest title", aceGUI.tooltip:GetText())
        assert.is_true(aceGUI.tooltip:IsShown())
        button:GetScript("OnLeave")(button)
        assert.is_false(aceGUI.tooltip:IsShown())
        widget:SetTree({{value = "other", text = "Other title"}})
        button:GetScript("OnEnter")(button)
        assert.equals("Other title", aceGUI.tooltip:GetText())
        button:GetScript("OnLeave")(button)
        widget:EnableButtonTooltips(false)
        button:GetScript("OnEnter")(button)
        assert.is_false(aceGUI.tooltip:IsShown())
    end)
end)
