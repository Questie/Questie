-- luacheck: globals C_Texture BACKDROP_DIALOG_32_32 GameFontDisable GetBindingFromClick
-- luacheck: globals UserScaledFontGameHighlight UserScaledFontGameNormal UserScaledFontGameDisable

-- Private, Lua-only confirmations and copyable text for any addon.
-- Load LibStub, LibPopupStack-1.0, this file, then consumers in that order.
-- Consumers use the WoW-provided private table: local _, addon = ...; addon.Dialog.
-- Each addon owns its definitions, anonymous frames, scripts and layout methods;
-- only positioning is shared through LibStub. Another addon's copy cannot replace
-- this implementation. There is no widget global or XML template to coordinate.
-- See the accompanying README.md for a complete definition and usage example.
local _, addon = ...
if addon.Dialog then return end
local PopupStack = LibStub("LibPopupStack-1.0")

---Stored by reference in addon.Dialog.Dialogs[key]; define before calling Show.
---Extra fields are allowed for consumers but have no built-in behavior.
---@class DialogDefinition
---@field text string Body text; formatted with Show's arguments when either is non-nil.
---@field button1 string? Accept label; nil omits the button, an empty string still shows it.
---@field button2 string? Cancel label; nil omits the button, an empty string still shows it.
---@field showAlert boolean? Show the warning icon and use a wider minimum frame width.
---@field hasEditBox boolean? Show a single-line input; populate and focus it in OnShow.
---@field editBoxWidth number? Input width in frame units; defaults to 280.
---@field whileDead boolean? Allow Show while dead or a ghost; otherwise Show returns nil.
---@field hideOnEscape boolean? Let this addon's newest active decision consume the game-menu binding.
---@field noCancelOnReuse boolean? Suppress the previous decision's override callback when showing this definition.
---@field OnShow fun(dialog: DialogFrame, data: any)? Runs after setup and Show; return ignored, failure closes this generation.
---@field OnAccept (fun(dialog: DialogFrame, data: any): any)? Truthy return keeps a clicked decision open; failure closes it.
---@field OnCancel (fun(dialog: DialogFrame, data: any, reason: "clicked"|"override"): any)? Truthy keeps a button click open only.
---@field EditBoxOnEnterPressed fun(editBox: EditBox)? Replaces default programmatic Hide; return ignored.
---@field EditBoxOnEscapePressed fun(editBox: EditBox)? Replaces the hideOnEscape/binding path; return ignored.
-- OnCancel also receives "clicked" for the game-menu binding, whose return is ignored.
-- Reuse sends "override" after clearing frame.data/input, but passes the old payload
-- as the data argument. Its return cannot veto reuse.
-- Programmatic Hide never calls OnCancel. Input callbacks receive only the EditBox;
-- use editBox:GetParent() to reach the frame and its data. Input never takes focus automatically.

---@class DialogText : FontString
---@field text_arg1 string|number?
---@field text_arg2 string|number?

---@class DialogLayout
---@field width number
---@field height number
---@field textHeight number
---@field buttonWidth number
---@field buttonHeight number
---@field buttonMask integer
---@field inputWidth number
---@field inputHeight number

---@class DialogFrame : Frame
---@field Text DialogText
---@field EditBox EditBox
---@field Button1 Button
---@field Button2 Button
---@field Background Texture
---@field Border Texture
---@field AlertIcon Texture
---@field definition DialogDefinition Most recently shown definition, retained after dismissal.
---@field data any Caller-owned payload, available during the decision and cleared on release.
---@field generation integer Increments on each new decision; guard delayed work against reuse.
---@field active boolean? Decision is open, even when an ancestor temporarily hides it.
---@field handlingChoice boolean?
---@field layout DialogLayout? Last applied measurements; fonts can settle after Show.
local FrameMixin = {}

---@class AddonDialog
---@field Dialogs table<string, DialogDefinition> Definitions belong only to this addon's private namespace.
local Dialogs = { Dialogs = {} }
addon.Dialog = Dialogs
---@type table<string, DialogFrame>
local frames = {}
---@type DialogFrame[]
local active = {}
local driver
local elapsedSinceScan = 0
local layoutPending = false

---Isolate consumer failures without reporting error text that could contain private data.
---Only the first callback return is used, as the clicked-choice keep-open flag.
---@param callback function?
---@param ... any
---@return boolean ok
---@return any result
local function Call(callback, ...)
  if not callback then return true end
  local ok, result = pcall(callback, ...)
  if not ok and geterrorhandler then
    pcall(geterrorhandler(), "AddonDialog callback failed (details withheld).")
  end
  return ok, result
end

-- Font metrics can settle after Show or change with UI font settings. Recheck on
-- the next frame and every 0.1 seconds while decisions remain active, without
-- installing lifecycle hooks on Blizzard controls or other addons' dialogs.
local function UpdateDriver()
  if #active > 0 then
    if not driver then
      driver = CreateFrame("Frame", nil, UIParent)
      driver:SetScript("OnUpdate", function(_, elapsed)
        elapsedSinceScan = elapsedSinceScan + elapsed
        if elapsedSinceScan < 0.1 and not layoutPending then return end
        elapsedSinceScan = 0
        layoutPending = false
        -- Resize only our controls. Changed dimensions notify the coordinator,
        -- which sees both addons' frames but never invokes their layout code.
        for _, frame in ipairs(active) do frame:Resize() end
      end)
    end
    driver:Show()
  elseif driver then
    driver:Hide()
    elapsedSinceScan = 0
    layoutPending = false
  end
end

---End this decision, not the reusable frame's lifetime. Custom fields/hooks are
---not reset; consumers must manage them. Before delayed work touches this frame,
---check both its captured generation and active state (plus visibility if needed).
---@param frame DialogFrame
local function Release(frame)
  if not frame.active then return end
  frame.active = false
  for i, shown in ipairs(active) do
    if shown == frame then table.remove(active, i); break end
  end
  PopupStack:Unregister(frame)
  frame.data = nil
  frame.Text.text_arg1, frame.Text.text_arg2 = nil, nil
  frame.EditBox:SetText("")
  frame.EditBox:ClearFocus()
  UpdateDriver()
end

---@param parent DialogFrame
---@return Button
local function CreateButton(parent)
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(120, 21)
  button:RegisterForClicks("LeftButtonUp")
  local text = button:CreateFontString(nil, "ARTWORK")
  text:SetPoint("CENTER", button, "CENTER", 0, 1)
  button:SetFontString(text)
  button:SetNormalTexture("Interface\\Buttons\\UI-DialogBox-Button-Up")
  button:SetPushedTexture("Interface\\Buttons\\UI-DialogBox-Button-Down")
  button:SetDisabledTexture("Interface\\Buttons\\UI-DialogBox-Button-Disabled")
  button:SetHighlightTexture("Interface\\Buttons\\UI-DialogBox-Button-Highlight", "ADD")
  for _, texture in ipairs({ button:GetNormalTexture(), button:GetPushedTexture(),
      button:GetDisabledTexture(), button:GetHighlightTexture() }) do
    texture:SetTexCoord(0, 1, 0, 0.71875)
  end
  return button
end

---Build owned controls without StaticPopupTemplate or Blizzard popup registration.
---Anonymous frames expose child references directly; no generated global names exist.
---@return DialogFrame
local function CreateDialog()
  local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  for key, method in pairs(FrameMixin) do frame[key] = method end
  frame:Hide()
  frame:SetSize(420, 136)
  frame:SetPoint("TOP", UIParent, "TOP", 0, -135)
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:EnableMouse(true)
  frame:EnableKeyboard(true)

  frame.Background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
  frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -7)
  frame.Background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 7)
  frame.Background:Hide()
  frame.Border = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
  frame.Border:SetAllPoints(frame)
  frame.Border:Hide()
  frame.AlertIcon = frame:CreateTexture(nil, "ARTWORK")
  frame.AlertIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
  frame.AlertIcon:SetSize(36, 36)
  frame.AlertIcon:SetPoint("LEFT", frame, "LEFT", 24, 0)
  frame.Text = frame:CreateFontString(nil, "ARTWORK")
  frame.Text:SetSize(290, 0)
  frame.Text:SetPoint("TOP", frame, "TOP", 0, -16)
  frame.Text:SetJustifyH("CENTER")
  frame.Text:SetJustifyV("MIDDLE")
  frame.Button1, frame.Button2 = CreateButton(frame), CreateButton(frame)

  frame.EditBox = CreateFrame("EditBox", nil, frame)
  frame.EditBox:SetSize(280, 28)
  frame.EditBox:SetAutoFocus(false)
  frame.EditBox:SetFontObject(GameFontHighlight)
  frame.EditBox:SetTextInsets(6, 6, 2, 2)
  local background = frame.EditBox:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints(frame.EditBox)
  background:SetColorTexture(0, 0, 0, 0.8)
  frame.EditBox:Hide()

  frame:SetScript("OnShow", frame.OnShow)
  frame:SetScript("OnHide", frame.OnHide)
  frame:SetScript("OnKeyDown", frame.OnKeyDown)
  frame:OnLoad()
  return frame
end

---Open a decision using this addon's definition table. Unknown keys assert;
---death eligibility is checked before creating or replacing a frame.
---Each key lazily owns one frame for the UI session; different keys never share
---controls. Reuse closes the old decision, then calls its OnCancel("override")
---unless the new definition suppresses it or a choice callback is already running.
---A callback that reopens this key wins over the older Show/choice operation.
---If an override callback reopens then closes it, the outer Show still returns the
---retained frame; check its active state rather than treating every return as open.
---@param which string Definition key in addon.Dialog.Dialogs.
---@param arg1 string|number? First string.format argument, also exposed as Text.text_arg1.
---@param arg2 string|number? Second string.format argument, also exposed as Text.text_arg2.
---@param data any Payload passed by reference; set before OnShow, released on dismissal.
---@return DialogFrame? frame Reusable frame; normally nil when ineligible/closed, with the reentrant exception above.
function Dialogs.Show(which, arg1, arg2, data)
  local definition = assert(Dialogs.Dialogs[which], "Unknown dialog definition")
  if not definition.whileDead and UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") then return end
  local frame = frames[which]
  if not frame then
    frame = CreateDialog()
    frames[which] = frame
    frame.generation = 0
    local nativeHide = frame.Hide
    -- Parent-only hiding leaves the shown bit intact. Explicit Hide must still
    -- release a decision when a hidden ancestor suppresses native OnHide.
    function frame:Hide()
      local generation = self.generation
      nativeHide(self)
      if self.generation == generation then Release(self) end
    end
  elseif frame.active then
    local previous, previousData, generation = frame.definition, frame.data, frame.generation
    frame:Hide()
    -- A choice callback may reopen this key. That decision already has its
    -- accept/cancel notification; replacing it must not dispatch another one.
    if not definition.noCancelOnReuse and not frame.handlingChoice then
      Call(previous.OnCancel, frame, previousData, "override")
    end
    if frame.generation ~= generation then return frame end
  end

  -- Install the new decision before OnShow so callbacks can inspect data and
  -- formatting arguments. Generation checks stop old callbacks closing a replacement.
  frame.generation = frame.generation + 1
  local generation = frame.generation
  frame.definition, frame.data = definition, data
  frame.layout = nil
  frame.Text.text_arg1, frame.Text.text_arg2 = arg1, arg2
  local text = definition.text or ""
  frame.Text:SetText((arg1 ~= nil or arg2 ~= nil) and string.format(text, arg1, arg2) or text)
  frame.Button1:SetText(definition.button1 or "")
  frame.Button2:SetText(definition.button2 or "")
  frame.Button1:SetShown(definition.button1 ~= nil)
  frame.Button2:SetShown(definition.button2 ~= nil)
  frame.AlertIcon:SetShown(not not definition.showAlert)
  frame.EditBox:SetShown(not not definition.hasEditBox)
  frame.active = true
  active[#active + 1] = frame
  frame:Resize()
  frame:SetPropagateKeyboardInput(true)
  frame:Show()
  frame:Raise()
  local ok = Call(definition.OnShow, frame, data)
  if frame.generation == generation and frame.active then
    if not ok then frame:Hide(); return end
    frame:Resize()
    PopupStack:RequestLayout()
  end
  -- One next-frame check handles first-show layout settling without waiting
  -- for the normal polling interval. Later font changes use that same watcher.
  layoutPending = true
  UpdateDriver()
  return frame.active and frame or nil
end

---Find an active decision, not necessarily a frame currently visible on screen.
---Hiding UIParent alone preserves the decision, payload and shown bit.
---@param which string
---@return DialogFrame?
function Dialogs.FindVisible(which)
  local frame = frames[which]
  return frame and frame.active and frame or nil
end

---Dismiss without OnCancel, clearing payload, format arguments, input and focus.
---Unknown or already closed keys are harmless; the frame remains reusable.
---@param which string
function Dialogs.Hide(which)
  local frame = Dialogs.FindVisible(which)
  if frame then frame:Hide() end
end

---Tests decision lifetime, like FindVisible, rather than ancestor visibility.
---@param which string
---@return boolean
function Dialogs.IsShown(which) return Dialogs.FindVisible(which) ~= nil end

---Whether this addon has any open decisions, including ones hidden by an ancestor.
---@return boolean
function Dialogs.IsAnyDialogShown() return #active > 0 end

---Only the newest active decision in this addon can consume the game-menu binding,
---and only with hideOnEscape. Older dialogs do not take over if it opts out.
---Unlike a cancel button, binding dismissal ignores OnCancel's keep-open return.
---@param key string
function FrameMixin:OnKeyDown(key)
  local handled = GetBindingFromClick(key) == "TOGGLEGAMEMENU"
    and active[#active] == self and self.definition.hideOnEscape and not self.handlingChoice
  self:SetPropagateKeyboardInput(not handled)
  if not handled then return end
  local generation = self.generation
  self.handlingChoice = true
  Call(self.definition.OnCancel, self, self.data, "clicked")
  self.handlingChoice = false
  if self.generation == generation then self:Hide() end
  -- Reopening during the callback resets input propagation. Consume this key
  -- after the callback so the same key cannot reach another window/binding.
  self:SetPropagateKeyboardInput(false)
end

---Ignore hidden/disabled actions and nested clicks. A truthy callback result keeps
---this decision open; an error closes it. Reentrant Show creates a new generation
---on the same frame, so the old result must not dismiss that replacement.
---@param index integer 1 accepts, 2 cancels.
function FrameMixin:Choose(index)
  if not self.active or self.handlingChoice then return end
  local button = index == 1 and self.Button1 or self.Button2
  if not button:IsShown() or not button:IsEnabled() then return end
  local callback
  if index == 1 then callback = self.definition.OnAccept else callback = self.definition.OnCancel end
  local generation = self.generation
  self.handlingChoice = true
  local ok, keepOpen = Call(callback, self, self.data, index == 2 and "clicked" or nil)
  self.handlingChoice = false
  if self.generation == generation and (not ok or not keepOpen) then self:Hide() end
end

-- Parent visibility returning re-registers an open decision that the coordinator
-- may have removed while hidden. Parent-only OnHide must not release its payload.
function FrameMixin:OnShow()
  if self.active then PopupStack:Register(self) end
end

function FrameMixin:OnHide()
  if not self:IsShown() then Release(self) end
end

---Borrow Blizzard's appearance, not its popup state. Classic clients lacking
---either modern atlas use the dialog backdrop instead.
function FrameMixin:OnLoad()
  local atlas = C_Texture and C_Texture.GetAtlasInfo
  if atlas and atlas("UI-DialogBox-Background-Dark") and atlas("UI-DiamondDialogBox-Border") then
    self.Background:SetAtlas("UI-DialogBox-Background-Dark")
    self.Border:SetAtlas("UI-DiamondDialogBox-Border")
    self.Background:Show()
    self.Border:Show()
  else
    self:SetBackdrop(BACKDROP_DIALOG_32_32)
  end
  -- Font objects are shared read-only assets. Set fonts on our instances; never
  -- change the shared font objects themselves, which would affect unrelated UI.
  self.Text:SetFontObject(UserScaledFontGameHighlight or GameFontHighlight)
  for index, button in ipairs({ self.Button1, self.Button2 }) do
    button:SetNormalFontObject(UserScaledFontGameNormal or GameFontNormal)
    button:SetHighlightFontObject(UserScaledFontGameHighlight or GameFontHighlight)
    button:SetDisabledFontObject(UserScaledFontGameDisable or GameFontDisable)
    button:SetScript("OnClick", function() self:Choose(index) end)
  end
  -- Custom input handlers own their action; no default accept/cancel is appended.
  -- SetAutoFocus(false) leaves content, focus and selection to definition.OnShow.
  self.EditBox:SetScript("OnEnterPressed", function(editBox)
    local callback = self.definition.EditBoxOnEnterPressed
    if callback then Call(callback, editBox) else self:Hide() end
  end)
  self.EditBox:SetScript("OnEscapePressed", function(editBox)
    local callback = self.definition.EditBoxOnEscapePressed
    if callback then Call(callback, editBox) else self:OnKeyDown("ESCAPE") end
  end)
  self:SetPropagateKeyboardInput(true)
end

--- The compact layout needed by confirmations and copyable text: body, optional
--- edit box, and one or two actions. No general-purpose control/layout engine.
function FrameMixin:Resize()
  local info = self.definition
  -- Measure actions together so translated labels and late font metrics grow
  -- both buttons and their containing border, rather than only the body text.
  local buttons = {}
  local buttonWidth, buttonHeight, buttonMask = 120, 21, 0
  for index, button in ipairs({ self.Button1, self.Button2 }) do
    if button:IsShown() then
      buttons[#buttons + 1] = button
      buttonMask = buttonMask + index
      buttonWidth = math.max(buttonWidth, button:GetTextWidth() + 20)
      buttonHeight = math.max(buttonHeight, button:GetFontString():GetStringHeight() + 8)
    end
  end
  -- Body/input/action rows: 16-unit outer padding and 9-unit vertical gaps.
  -- The body keeps its wrapping width; the frame expands for actions and input.
  local width = info.showAlert and 420 or 320
  width = math.max(width, #buttons * buttonWidth + math.max(0, #buttons - 1) * 10 + 32)
  local textHeight = self.Text:GetStringHeight()
  local inputWidth = info.hasEditBox and (info.editBoxWidth or 280) or 0
  local inputHeight = info.hasEditBox and self.EditBox:GetHeight() or 0
  local buttonY = 16 + textHeight
  if info.hasEditBox then
    width = math.max(width, inputWidth + 32)
    buttonY = buttonY + 9 + inputHeight
  end
  local height = buttonY + (#buttons > 0 and (9 + buttonHeight) or 0) + 16
  -- Polling stable measurements must not keep invalidating anchors or geometry.
  -- Include which buttons are shown, not just their shared dimensions.
  local previous = self.layout
  if previous and previous.width == width and previous.height == height and previous.textHeight == textHeight
      and previous.buttonWidth == buttonWidth and previous.buttonHeight == buttonHeight and previous.buttonMask == buttonMask
      and previous.inputWidth == inputWidth and previous.inputHeight == inputHeight then return end

  -- Apply one coherent layout, then let the shared coordinator place the frame.
  if info.hasEditBox then
    self.EditBox:SetWidth(inputWidth)
    self.EditBox:ClearAllPoints()
    self.EditBox:SetPoint("TOP", self, "TOP", 0, -16 - textHeight - 9)
  end
  for index, button in ipairs(buttons) do
    local x = #buttons == 1 and 0 or (index == 1 and -1 or 1) * (buttonWidth + 10) / 2
    button:SetSize(buttonWidth, buttonHeight)
    button:ClearAllPoints()
    button:SetPoint("TOP", self, "TOP", x, -buttonY - 9)
  end
  self:SetWidth(width)
  self:SetHeight(height)
  self.layout = { width = width, height = height, textHeight = textHeight, buttonWidth = buttonWidth,
    buttonHeight = buttonHeight, buttonMask = buttonMask, inputWidth = inputWidth, inputHeight = inputHeight }
  PopupStack:RequestLayout()
end

-- Use owned child references, never _G[frame:GetName() .. suffix]. These controls
-- persist across reuse, but input text and focus are cleared when a decision ends.
---@return EditBox
function FrameMixin:GetEditBox() return self.EditBox end
---@return string
function FrameMixin:GetEditBoxText() return self.EditBox:GetText() end
---@return Button
function FrameMixin:GetButton1() return self.Button1 end
---@return Button
function FrameMixin:GetButton2() return self.Button2 end
