dofile("setupTests.lua")

describe("QuestieMenuBuilder", function()
    local QuestieMenuBuilder
    local root
    local manager
    local saved = {}
    local globalNames = {"MenuUtil", "Menu", "MenuResponse", "MenuVariants", "UIParent", "CreateAnchor"}

    local function Description(kind, text, callback, isSelected)
        local description = {kind = kind, text = text, callback = callback, isSelected = isSelected, children = {}, initializers = {}}
        function description:CreateButton(childText, childCallback)
            local child = Description("button", childText, childCallback)
            self.children[#self.children + 1] = child
            return child
        end
        function description:CreateCheckbox(childText, childIsSelected, childCallback)
            local child = Description("checkbox", childText, childCallback, childIsSelected)
            self.children[#self.children + 1] = child
            return child
        end
        function description:CreateTitle(childText)
            self.children[#self.children + 1] = Description("title", childText)
        end
        function description:CreateDivider()
            self.children[#self.children + 1] = Description("divider")
        end
        function description:SetEnabled(isEnabled) self.isEnabled = isEnabled end
        function description:AddInitializer(initializer) self.initializers[#self.initializers + 1] = initializer end
        return description
    end

    before_each(function()
        for _, name in ipairs(globalNames) do
            saved[name] = _G[name]
        end
        root = Description("root")
        manager = {open = false}
        function manager:CloseMenus() self.closed = true end
        function manager:IsAnyMenuOpen() return self.open end
        function manager:OpenMenu(owner, description, anchor)
            self.openedOwner, self.openedDescription, self.openedAnchor = owner, description, anchor
        end
        _G.MenuResponse = {Open = 1, Refresh = 2, Close = 3, CloseAll = 4}
        _G.UIParent = {}
        _G.Menu = {GetManager = function() return manager end}
        _G.MenuVariants = {GetDefaultContextMenuMixin = function() return "mixin" end}
        _G.CreateAnchor = function(...) return {...} end
        _G.Menu.PopulateDescription = function(generator, owner, description) generator(owner, description) end
        _G.MenuUtil = {
            CreateContextMenu = function(owner, generator)
                manager.owner = owner
                generator(owner, root)
            end,
            CreateRootMenuDescription = function(mixin) root.mixin = mixin return root end,
        }

        QuestieLoader._modules["QuestieMenuBuilder"] = nil
        dofile("Modules/Libs/QuestieMenuBuilder.lua")
        QuestieMenuBuilder = QuestieLoader:ImportModule("QuestieMenuBuilder")
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = saved[name]
        end
    end)

    it("should open a context menu on the UIParent", function()
        QuestieMenuBuilder.Show({{text = "A"}})

        assert.are.equal(UIParent, manager.owner)
    end)

    it("should open the menu to the right of the anchor frame when one is given", function()
        local anchorFrame = {}
        QuestieMenuBuilder.Show({{text = "A"}}, anchorFrame)

        assert.are.equal(anchorFrame, manager.openedOwner)
        assert.are.equal(root, manager.openedDescription)
        assert.are.equal("mixin", root.mixin)
        assert.are.same({"TOPLEFT", anchorFrame, "TOPRIGHT"}, manager.openedAnchor)
        assert.are.equal("A", root.children[1].text)
        assert.is_nil(manager.owner)
    end)

    it("should attach the menu at the given points of the anchor frame", function()
        local anchorFrame = {}
        QuestieMenuBuilder.Show({{text = "A"}}, anchorFrame, "TOPLEFT", "BOTTOMLEFT")

        assert.are.same({"TOPLEFT", anchorFrame, "BOTTOMLEFT"}, manager.openedAnchor)
    end)

    it("should add titles, dividers and buttons in order", function()
        QuestieMenuBuilder.Show({{text = "T", isTitle = true}, {isDivider = true}, {text = "B"}})

        assert.are.same({"title", "divider", "button"}, {root.children[1].kind, root.children[2].kind, root.children[3].kind})
    end)

    it("should prefix the label with the icon", function()
        QuestieMenuBuilder.Show({{text = "B", icon = "Interface\\Icons\\x"}})

        assert.are.equal("|TInterface\\Icons\\x:16|t B", root.children[1].text)
    end)

    it("should close the menu after a click by default", function()
        QuestieMenuBuilder.Show({{text = "B", func = function() end}})

        assert.are.equal(MenuResponse.CloseAll, root.children[1].callback(nil, {buttonName = "LeftButton"}))
    end)

    it("should refresh the menu after a click when keepShownOnClick is set", function()
        QuestieMenuBuilder.Show({{text = "B", keepShownOnClick = true}})

        assert.are.equal(MenuResponse.Refresh, root.children[1].callback(nil, {}))
    end)

    it("should prefer the response returned by func", function()
        QuestieMenuBuilder.Show({{text = "B", keepShownOnClick = true, func = function() return MenuResponse.CloseAll end}})

        assert.are.equal(MenuResponse.CloseAll, root.children[1].callback(nil, {}))
    end)

    it("should ignore a return value of func that is not a menu response", function()
        QuestieMenuBuilder.Show({{text = "B", func = function() return true end}})

        assert.are.equal(MenuResponse.CloseAll, root.children[1].callback(nil, {}))
    end)

    it("should call func synchronously with the clicked mouse button", function()
        local clicked
        QuestieMenuBuilder.Show({{text = "B", func = function(button) clicked = button end}})

        root.children[1].callback(nil, {buttonName = "RightButton"})

        assert.are.equal("RightButton", clicked)
    end)

    it("should create a checkbox that evaluates checked on every redraw", function()
        local value = false
        QuestieMenuBuilder.Show({{text = "C", checked = function() return value end}})
        local checkbox = root.children[1]

        assert.are.equal("checkbox", checkbox.kind)
        assert.is_false(checkbox.isSelected())
        value = true
        assert.is_true(checkbox.isSelected())
    end)

    it("should create a submenu from menuList", function()
        QuestieMenuBuilder.Show({{text = "Parent", menuList = {{text = "Child"}}}})

        assert.is_nil(root.children[1].callback)
        assert.are.equal("Child", root.children[1].children[1].text)
    end)

    it("should enable entries based on the current disabled state", function()
        local disabled = true
        QuestieMenuBuilder.Show({{text = "B", disabled = function() return disabled end}})
        local description = root.children[1]

        assert.is_false(description.isEnabled())
        disabled = false
        assert.is_true(description.isEnabled())
    end)

    it("should register right clicks on the entry's button", function()
        QuestieMenuBuilder.Show({{text = "B", registerForRightClick = true}})
        local registered
        local button = {RegisterForClicks = function(_, ...) registered = {...} end}

        root.children[1].initializers[1](button)

        assert.are.same({"LeftButtonUp", "RightButtonUp"}, registered)
    end)

    it("should run the entry initializer", function()
        local initializer = spy.new(function() end)
        QuestieMenuBuilder.Show({{text = "B", initializer = initializer}})

        root.children[1].initializers[1]("button")

        assert.spy(initializer).was.called_with("button")
    end)

    it("should close and report open menus through the menu manager", function()
        manager.open = true

        assert.is_true(QuestieMenuBuilder.IsOpen())
        QuestieMenuBuilder.Close()
        assert.is_true(manager.closed)
    end)
end)
