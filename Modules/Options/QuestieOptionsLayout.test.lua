dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("QuestieOptionsLayout", function()
    ---@type QuestieOptionsLayout
    local QuestieOptionsLayout
    local ui, parent
    local created

    local MAX_WIDTH = 585
    local ROOT_INDENT = 20
    local HALF_WIDTH = 287.5 -- Half of MAX_WIDTH, leaving room for half of the gap between neighbors

    local function Build(items, level)
        created = {}
        return QuestieOptionsLayout.Build(parent, items, MAX_WIDTH, level or 1, function(control)
            created[control.itemData.title] = control
        end)
    end

    ---@return number x
    ---@return number y
    local function PositionOf(control)
        local point = control.points[#control.points]
        return point[4], point[5]
    end

    before_each(function()
        ui = FakeUI.Install()
        parent = CreateFrame("Frame", nil, UIParent)

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Options/QuestieOptionsLayout.lua")
        QuestieOptionsLayout = QuestieLoader:ImportModule("QuestieOptionsLayout")
    end)

    after_each(function()
        ui.Restore()
    end)

    it("should place controls in their order, not the order of the table", function()
        local items = {}
        for order = 1, 20 do
            local key = "item" .. order
            items[key] = {type = "spacer", title = key, order = order, width = "full"}
        end

        Build(items)

        for order = 1, 20 do
            -- Spacer height of 16 plus the gap of 10
            assert.are.equal(-26 * (order - 1), select(2, PositionOf(created["item" .. order])))
        end
    end)

    it("should fill a row before wrapping to the next", function()
        Build({
            left = {type = "spacer", title = "left", order = 1, width = "half"},
            right = {type = "spacer", title = "right", order = 2, width = "half"},
            next = {type = "spacer", title = "next", order = 3, width = "half"},
        })

        assert.are.equal(ROOT_INDENT, (PositionOf(created.left)))
        assert.are.equal(ROOT_INDENT + HALF_WIDTH + 10, (PositionOf(created.right)))

        local nextX, nextY = PositionOf(created.next)
        assert.are.equal(ROOT_INDENT, nextX)
        assert.are.equal(-26, nextY)
    end)

    it("should fit three controls of a third on one row", function()
        Build({
            a = {type = "spacer", title = "a", order = 1, width = "third"},
            b = {type = "spacer", title = "b", order = 2, width = "third"},
            c = {type = "spacer", title = "c", order = 3, width = "third"},
        })

        assert.are.equal(0, select(2, PositionOf(created.c)))
    end)

    it("should start a new row for a control asking for one", function()
        Build({
            left = {type = "spacer", title = "left", order = 1, width = "quarter"},
            next = {type = "spacer", title = "next", order = 2, width = "quarter", newline = true},
        })

        local nextX, nextY = PositionOf(created.next)
        assert.are.equal(ROOT_INDENT, nextX)
        assert.are.equal(-26, nextY)
    end)

    it("should give dividers a row of their own", function()
        Build({
            left = {type = "spacer", title = "left", order = 1, width = "half"},
            divider = {type = "divider", title = "divider", order = 2},
            below = {type = "spacer", title = "below", order = 3, width = "half"},
        })

        assert.are.equal(-26, select(2, PositionOf(created.divider)))
        assert.are.equal(-51, select(2, PositionOf(created.below))) -- Divider height of 15 plus the gap of 10
    end)

    it("should center controls shorter than the tallest of their row", function()
        Build({
            short = {type = "checkbox", title = "short", order = 1, width = "half"},
            tall = {type = "slider", title = "tall", order = 2, width = "half", min = 0, max = 1},
            next = {type = "spacer", title = "next", order = 3, width = "full"},
        })

        assert.are.equal(-9, select(2, PositionOf(created.short))) -- Half of the difference between 30 and 48
        assert.are.equal(0, select(2, PositionOf(created.tall)))
        assert.are.equal(-58, select(2, PositionOf(created.next)))
    end)

    it("should also center the controls of the last row", function()
        Build({
            short = {type = "checkbox", title = "short", order = 1, width = "half"},
            tall = {type = "slider", title = "tall", order = 2, width = "half", min = 0, max = 1},
        })

        assert.are.equal(-9, select(2, PositionOf(created.short)))
    end)

    it("should not move a finished row when later rows are aligned", function()
        Build({
            firstShort = {type = "checkbox", title = "firstShort", order = 1, width = "half"},
            firstTall = {type = "slider", title = "firstTall", order = 2, width = "half", min = 0, max = 1},
            secondShort = {type = "checkbox", title = "secondShort", order = 3, width = "half"},
            secondTall = {type = "slider", title = "secondTall", order = 4, width = "half", min = 0, max = 1},
        })

        assert.are.equal(-9, select(2, PositionOf(created.firstShort)))
        assert.are.equal(-67, select(2, PositionOf(created.secondShort))) -- The first row of 48, the gap of 10, then centered
    end)

    it("should skip invisible items without leaving a gap, and without even needing a valid type", function()
        Build({
            hidden = {type = "not a real type", title = "hidden", order = 1, visible = false},
            shown = {type = "spacer", title = "shown", order = 2, visible = true, width = "full"},
        })

        assert.is_nil(created.hidden)
        assert.are.equal(0, select(2, PositionOf(created.shown)))
    end)

    it("should report the height used by everything it placed", function()
        local height = Build({
            first = {type = "spacer", title = "first", order = 1, width = "full"},
            second = {type = "spacer", title = "second", order = 2, width = "half"},
        })

        -- A full row of 16 and its gap of 10, then a row of 16
        assert.are.equal(42, height)
    end)

    describe("containers", function()
        local function BuildContainer()
            return Build({
                group = {
                    type = "container",
                    title = "group",
                    order = 1,
                    items = {
                        inner = {type = "spacer", title = "inner", order = 1, width = "full"},
                    },
                },
                below = {type = "spacer", title = "below", order = 2, width = "full"},
            })
        end

        it("should report nested controls too", function()
            BuildContainer()

            assert.is_not_nil(created.group)
            assert.is_not_nil(created.inner)
        end)

        it("should place its children inside of it without another indent", function()
            BuildContainer()

            assert.are.equal(created.group.contentArea, created.inner.parent)
            local innerX, innerY = PositionOf(created.inner)
            assert.are.equal(0, innerX)
            assert.are.equal(-10, innerY) -- Room for the container's art
        end)

        it("should grow around its children and leave room for its title", function()
            BuildContainer()

            -- The inner row ends at -36, plus the gap of 10
            assert.are.equal(46, created.group:GetHeight())
            assert.are.equal(-24, select(2, PositionOf(created.group)))
            assert.are.equal(-80, select(2, PositionOf(created.below)))
        end)

        it("should indent children of a canvas, but not of a nested level", function()
            Build({inner = {type = "spacer", title = "inner", order = 1, width = "full"}}, 2)

            assert.are.equal(0, (PositionOf(created.inner)))
        end)
    end)

    describe("normalizing items", function()
        -- A field missing from the normalized item would silently do nothing on every control using it.
        it("should hand every field the controls read over to them", function()
            local function NoOp() end
            local raw = {
                type = "spacer", title = "Title", description = "Description", tooltip = "Tooltip", order = 3, get = NoOp, set = NoOp,
                value = "value", width = 0.25, newline = true, enabled = NoOp, min = 1, max = 2, step = 0.5, showValue = false,
                isPercent = true, minLabel = "Low", maxLabel = "High", options = {a = "A"}, sortOrder = {"a"}, titleAlign = "RIGHT",
                titleSize = 12, titleFormat = NoOp, descriptionAlign = "CENTER", descriptionSize = 11, func = NoOp, align = "CENTER",
                btnLabel = "Press", fonts = {Font = "font.ttf"}, hasOpacity = true, textBoxCharLimit = 50,
            }
            local control

            QuestieOptionsLayout.Build(parent, {item = raw}, MAX_WIDTH, 1, function(created_) control = created_ end)

            for field, value in pairs(raw) do
                assert.are_same(value, control.itemData[field], field)
            end
        end)

        it("should translate titles and pass format arguments along", function()
            local control

            QuestieOptionsLayout.Build(parent, {
                slider = {type = "slider", title = {"Limit: %s", 5}, tooltip = {"Default: %s", 10}, order = 1},
            }, MAX_WIDTH, 1, function(created_) control = created_ end)

            assert.are.equal("Limit: 5", control.itemData.title)
            assert.are.equal("Default: 10", control.itemData.tooltip)
        end)

        it("should default to half a row, enabled, and left aligned", function()
            local control

            QuestieOptionsLayout.Build(parent, {
                checkbox = {type = "checkbox", title = "Title", order = 1},
            }, MAX_WIDTH, 1, function(created_) control = created_ end)

            assert.are.equal(0.5, control.itemData.width)
            assert.is_true(control.itemData.enabled)
            assert.are.equal("LEFT", control.itemData.titleAlign)
        end)

        it("should give sliders a working range and step by default", function()
            local control

            QuestieOptionsLayout.Build(parent, {
                slider = {type = "slider", title = "Title", order = 1},
            }, MAX_WIDTH, 1, function(created_) control = created_ end)

            assert.are.equal(0, control.widget.minValue)
            assert.are.equal(10, control.widget.maxValue)
            assert.are.equal(0.1, control.widget.valueStep)
        end)

        it("should center divider titles by default", function()
            local control

            QuestieOptionsLayout.Build(parent, {
                divider = {type = "divider", title = "Title", order = 1},
            }, MAX_WIDTH, 1, function(created_) control = created_ end)

            assert.are.equal("CENTER", control.itemData.titleAlign)
        end)

        it("should keep enabled = false instead of replacing it with the default", function()
            local control

            QuestieOptionsLayout.Build(parent, {
                checkbox = {type = "checkbox", title = "Title", order = 1, enabled = false},
            }, MAX_WIDTH, 1, function(created_) control = created_ end)

            assert.is_false(control.widget:IsEnabled())
        end)
    end)
end)
