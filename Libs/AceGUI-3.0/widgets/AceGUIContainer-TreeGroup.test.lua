local function ReadSource(path)
    local file, errorMessage = io.open(path, "r")
    assert.is_not_nil(file, "Could not open " .. path .. ": " .. tostring(errorMessage))

    local source = file:read("*a")
    file:close()

    return source
end

local function AssertContains(source, pattern, description)
    assert.is_not_nil(source:find(pattern, 1, true), description)
end

describe("Questie AceGUI TreeGroup customizations", function()
    local treeGroupSource

    before_each(function()
        treeGroupSource = ReadSource("Libs/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua")
    end)

    it("keeps Questie's patched TreeGroup version and icon gutter support", function()
        AssertContains(treeGroupSource, "local Type, Version = \"TreeGroup\", 50", "TreeGroup widget version should stay bumped for Questie's patched widget")
        AssertContains(treeGroupSource, "-- Added by Questie", "TreeGroup should retain Questie customization markers")
        AssertContains(treeGroupSource, "treeline.iconSize", "TreeGroup should read per-line iconSize")
        AssertContains(treeGroupSource, "treeline.useIconGutter", "TreeGroup should read per-line useIconGutter")
        AssertContains(treeGroupSource, "treeline.iconGutterOffset", "TreeGroup should read per-line iconGutterOffset")
        AssertContains(treeGroupSource, "line.iconSize = v.iconSize", "TreeGroup should carry iconSize into built lines")
        AssertContains(treeGroupSource, "line.useIconGutter = v.useIconGutter", "TreeGroup should carry useIconGutter into built lines")
        AssertContains(treeGroupSource, "line.iconGutterOffset = v.iconGutterOffset", "TreeGroup should carry iconGutterOffset into built lines")
        AssertContains(treeGroupSource, "line.tooltipText = v.tooltipText", "TreeGroup should carry tooltipText into built lines")
        AssertContains(treeGroupSource, "frame.treeline.tooltipText or", "TreeGroup should use custom tooltipText when provided")
    end)

    it("keeps pushed-state and recycled icon safeguards wired", function()
        AssertContains(treeGroupSource, "QueueDeferredButtonRefresh", "TreeGroup should defer row refreshes while buttons may be pushed")
        AssertContains(treeGroupSource, "DeferredButtonRefresh_OnUpdate", "TreeGroup should use a one-frame deferred refresh helper")
        AssertContains(treeGroupSource, "QueueDeferredButtonRefresh(frame)", "TreeGroup should defer click refreshes from row buttons")
        AssertContains(treeGroupSource, "QueueDeferredButtonRefresh(button)", "TreeGroup should defer double-click refreshes from row buttons")
        AssertContains(treeGroupSource, "button:GetPushedTextOffset()", "TreeGroup icons should follow Blizzard pushed text movement")
        AssertContains(treeGroupSource, "ResetIconPushedOffset", "TreeGroup should reset pushed icon offsets")
        AssertContains(treeGroupSource, "button:SetScript(\"OnMouseDown\", Button_OnMouseDown)", "TreeGroup should wire pushed icon movement on mouse down")
        AssertContains(treeGroupSource, "button:SetScript(\"OnMouseUp\", Button_OnMouseUp)", "TreeGroup should wire pushed icon reset on mouse up")
        AssertContains(treeGroupSource, "button.iconBaseOffset = nil", "TreeGroup should clear stale icon anchors for recycled no-icon buttons")
        AssertContains(treeGroupSource, "button.icon:SetTexture(nil)", "TreeGroup should clear stale icon textures for recycled no-icon buttons")
    end)
end)
