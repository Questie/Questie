local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")

describe("small addon dialogs", function()
  local env, errors, harness, dialogs
  before_each(function()
    env, errors, harness = fixture.NewEnvironment()
    dialogs = env.AddonDialog
    dialogs.Dialogs.A = { text = "Confirm %s", button1 = "Yes", button2 = "No", whileDead = true }
    dialogs.Dialogs.B = { text = "Another decision", button2 = "Close", whileDead = true }
  end)

  it("formats text and assigns data before OnShow", function()
    local seen
    dialogs.Dialogs.A.OnShow = function(frame, data)
      seen = { frame.Text:GetText(), frame.Text.text_arg1, data }
    end
    local frame = dialogs.Show("A", "this", nil, 42)
    assert.are.same({ "Confirm this", "this", 42 }, seen)
    assert.are.equal(frame, dialogs.FindVisible("A"))
    assert.are.equal(320, frame:GetWidth())
  end)

  it("keeps independent frames per definition instead of reusing another purpose's controls", function()
    local first = dialogs.Show("A", "first")
    first:SetFrameStrata("TOOLTIP")
    first.EditBox:SetScript("OnKeyDown", function() end)
    dialogs.Hide("A")
    local second = dialogs.Show("B")
    assert.are_not.equal(first, second)
    assert.are.equal("DIALOG", second.strata)
    assert.is_nil(second.EditBox:GetScript("OnKeyDown"))
    assert.are.equal(first, dialogs.Show("A", "again"))
  end)

  it("supports cancel-on-replacement and noCancelOnReuse", function()
    local cancelled = {}
    dialogs.Dialogs.A.OnCancel = function(_, data, reason) cancelled[#cancelled + 1] = { data, reason } end
    local frame = dialogs.Show("A", "old", nil, 1)
    assert.are.equal(frame, dialogs.Show("A", "new", nil, 2))
    assert.are.same({ { 1, "override" } }, cancelled)
    dialogs.Dialogs.A.noCancelOnReuse = true
    dialogs.Show("A", "latest", nil, 3)
    assert.are.equal(1, #cancelled)
    assert.are.equal(3, frame.data)
  end)

  it("distinguishes button decisions from programmatic dismissal", function()
    local accepted, cancelled = {}, {}
    dialogs.Dialogs.A.OnAccept = function(_, data) accepted[#accepted + 1] = data end
    dialogs.Dialogs.A.OnCancel = function(_, data, reason) cancelled[#cancelled + 1] = { data, reason } end
    local frame = dialogs.Show("A", "one", nil, 1)
    frame:Hide()
    assert.are.same({}, cancelled)
    assert.is_nil(frame.data)
    frame = dialogs.Show("A", "two", nil, 2)
    frame.Button2:Click()
    assert.are.same({ { 2, "clicked" } }, cancelled)
    frame = dialogs.Show("A", "three", nil, 3)
    frame.Button1:Click()
    assert.are.same({ 3 }, accepted)
    assert.is_false(dialogs.IsAnyDialogShown())
  end)

  it("does not dispatch cancellation when an accept button has no callback", function()
    dialogs.Dialogs.A.OnCancel = function() error("must not be called") end
    dialogs.Show("A", "this").Button1:Click()
    assert.are.same({}, errors)
    assert.is_false(dialogs.IsShown("A"))
  end)

  it("allows a callback to keep open or explicitly reopen the same definition", function()
    dialogs.Dialogs.A.OnAccept = function() return true end
    local frame = dialogs.Show("A", "first")
    frame.Button1:Click()
    assert.is_true(frame:IsShown())
    dialogs.Dialogs.A.OnCancel = function() error("An accepted decision must not also be cancelled") end
    dialogs.Dialogs.A.OnAccept = function() dialogs.Show("A", "replacement", nil, 9) end
    frame.Button1:Click()
    assert.are.same({}, errors)
    assert.are.equal(9, frame.data)
    assert.are.equal("Confirm replacement", frame.Text:GetText())
    assert.is_true(frame:IsShown())
  end)

  it("does not cancel twice when No reopens the same definition", function()
    local calls = {}
    dialogs.Dialogs.A.OnCancel = function(_, data, reason)
      calls[#calls + 1] = { data, reason }
      dialogs.Show("A", "replacement", nil, 2)
    end
    local frame = dialogs.Show("A", "original", nil, 1)
    frame.Button2:Click()
    assert.are.same({ { 1, "clicked" } }, calls)
    assert.are.equal(2, frame.data)
    assert.is_true(frame:IsShown())
  end)

  it("consumes a rebound menu key even when cancellation reopens the decision", function()
    local calls = {}
    dialogs.Dialogs.A.hideOnEscape = true
    dialogs.Dialogs.A.OnCancel = function(_, data, reason)
      calls[#calls + 1] = { data, reason }
      dialogs.Show("A", "replacement", nil, 2)
    end
    local frame = dialogs.Show("A", "original", nil, 1)
    -- Resolve the current binding at keypress time, not when the dialog was shown.
    env.GetBindingFromClick = function(key)
      if key == "F10" then return "TOGGLEGAMEMENU" end
      return ""
    end
    frame:OnKeyDown("F10")
    assert.are.same({ { 1, "clicked" } }, calls)
    assert.are.equal(2, frame.data)
    assert.is_true(frame:IsShown())
    assert.is_false(frame.propagate)
  end)

  it("propagates Escape when it is assigned another action or unbound", function()
    dialogs.Dialogs.A.hideOnEscape = true
    dialogs.Dialogs.A.OnCancel = function() error("Must not cancel for an unrelated key") end
    local frame = dialogs.Show("A", "this")
    env.GetBindingFromClick = function() return "JUMP" end

    frame:OnKeyDown("ESCAPE")
    assert.is_true(frame:IsShown())
    assert.is_true(frame.propagate)

    env.GetBindingFromClick = function() return "" end
    frame:OnKeyDown("ESCAPE")
    assert.is_true(frame:IsShown())
    assert.is_true(frame.propagate)
    assert.are.same({}, errors)
  end)

  it("only lets the most recently shown eligible dialog consume Escape", function()
    dialogs.Dialogs.A.hideOnEscape = true
    local first = dialogs.Show("A", "first")
    local second = dialogs.Show("B")
    first:OnKeyDown("ESCAPE")
    assert.is_true(first:IsShown())
    assert.is_true(first.propagate)
    second:OnKeyDown("ESCAPE")
    assert.is_true(second:IsShown())
    dialogs.Dialogs.B.hideOnEscape = true
    second:OnKeyDown("ESCAPE")
    assert.is_false(second:IsShown())
    assert.is_false(second.propagate)
    first:OnKeyDown("W")
    assert.is_true(first.propagate)
  end)

  it("supports copyable input with explicit focus and Enter/Escape handlers", function()
    dialogs.Dialogs.B.hasEditBox, dialogs.Dialogs.B.editBoxWidth = true, 280
    dialogs.Dialogs.B.OnShow = function(frame)
      frame.EditBox:SetText("https://example.test")
      frame.EditBox:SetFocus()
      frame.EditBox:HighlightText()
    end
    dialogs.Dialogs.B.EditBoxOnEnterPressed = function(editBox) editBox:GetParent():Hide() end
    dialogs.Dialogs.B.EditBoxOnEscapePressed = dialogs.Dialogs.B.EditBoxOnEnterPressed
    local frame = dialogs.Show("B")
    assert.are.equal("https://example.test", frame:GetEditBoxText())
    assert.are.equal(frame.EditBox, env[frame:GetName() .. "EditBox"])
    assert.is_true(frame.EditBox.focused)
    assert.is_true(frame.EditBox.highlighted)
    frame.EditBox:GetScript("OnEnterPressed")(frame.EditBox)
    assert.is_false(frame:IsShown())
    assert.are.equal("", frame:GetEditBoxText())
    dialogs.Show("B")
    frame.EditBox:GetScript("OnEscapePressed")(frame.EditBox)
    assert.is_false(frame:IsShown())
  end)

  it("reports callback failures without leaking their payload and closes the decision", function()
    dialogs.Dialogs.A.OnShow = function() error("private callback payload") end
    assert.is_nil(dialogs.Show("A", "this"))
    assert.is_false(dialogs.IsAnyDialogShown())
    assert.are.same({ "AddonDialog callback failed (details withheld)." }, errors)
  end)

  it("uses modern assets when available and Classic fallback otherwise", function()
    local first = dialogs.Show("A", "fallback")
    assert.are.equal(env.BACKDROP_DIALOG_32_32, first.backdrop)
    env.C_Texture = { GetAtlasInfo = function() return {} end }
    dialogs.Dialogs.B.showAlert = true
    local second = dialogs.Show("B")
    assert.are.equal("UI-DiamondDialogBox-Border", second.Border.atlas)
    assert.is_nil(second.backdrop)
    assert.are.equal(420, second:GetWidth())
    assert.is_true(second.AlertIcon:IsShown())
  end)

  it("preserves shown decisions across parent hiding but honors explicit Hide", function()
    local frame = dialogs.Show("A", "this", nil, 42)
    env.UIParent:Hide()
    assert.are.equal(frame, dialogs.FindVisible("A"))
    assert.are.equal(42, frame.data)
    frame:Hide()
    assert.is_nil(dialogs.FindVisible("A"))
    assert.is_nil(frame.data)
    env.UIParent:Show()
    assert.is_false(frame:IsShown())
  end)

  it("shares identical lean installations without touching the older full namespace", function()
    local full = { marker = "older full library" }
    env.AddonPopup = full
    local frame = dialogs.Show("A", "first")
    local chunk = assert(loadfile("Libs/AddonDialog/Dialog.lua"))
    setfenv(chunk, env)()
    assert.are.equal(dialogs, env.AddonDialog)
    assert.are.equal(frame, dialogs.FindVisible("A"))
    assert.are.equal(full, env.AddonPopup)
  end)

  it("scans immediately and at 0.1 seconds, stopping when the last dialog closes", function()
    local calls = 0
    dialogs.PositionDialogs = function() calls = calls + 1 end
    local frame = dialogs.Show("A", "this")
    local driver = harness.lastCreatedFrame
    assert.are.equal(1, calls)
    driver.OnUpdate(driver, 0.05)
    assert.are.equal(1, calls)
    driver.OnUpdate(driver, 0.05)
    assert.are.equal(2, calls)
    frame:Hide()
    assert.is_false(driver:IsShown())
  end)
end)
