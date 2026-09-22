-- luacheck: globals AddonDialog AddonDialogMixin C_Texture BACKDROP_DIALOG_32_32 GameFontDisable
-- luacheck: globals UserScaledFontGameHighlight UserScaledFontGameNormal UserScaledFontGameDisable

-- Independent of the older, full AddonPopup library while consumers migrate.
-- Identical embedded copies share definitions and frames instead of resetting them.
local existing = rawget(_G, "AddonDialog")
if existing then
  assert(type(existing) == "table" and existing.version == 1, "Incompatible AddonDialog installation")
  return
end

---@class DialogDefinition
---@field text string
---@field button1 string?
---@field button2 string?
---@field showAlert boolean?
---@field hasEditBox boolean?
---@field editBoxWidth number?
---@field whileDead boolean?
---@field hideOnEscape boolean?
---@field noCancelOnReuse boolean?
---@field OnShow fun(dialog: DialogFrame, data: any)?
---@field OnAccept (fun(dialog: DialogFrame, data: any): any)? Truthy return keeps the decision open.
---@field OnCancel (fun(dialog: DialogFrame, data: any, reason: string): any)? Clicked or replaced; never programmatic Hide.
---@field EditBoxOnEnterPressed fun(editBox: EditBox)?
---@field EditBoxOnEscapePressed fun(editBox: EditBox)?

---@class DialogText : FontString
---@field text_arg1 string|number?
---@field text_arg2 string|number?

---@class DialogFrame : Frame
---@field Text DialogText
---@field EditBox EditBox
---@field Button1 Button
---@field Button2 Button
---@field Background Texture
---@field Border Texture
---@field AlertIcon Texture
---@field definition DialogDefinition
---@field data any
---@field generation integer
---@field active boolean?
---@field handlingChoice boolean?
---@field popupAnchorX number?
---@field popupAnchorY number?
AddonDialogMixin = {}
local FrameMixin = AddonDialogMixin

AddonDialog = { Dialogs = {}, version = 1 }
local Dialogs = AddonDialog
---@type table<string, DialogFrame>
local frames = {}
---@type DialogFrame[]
local active = {}
local frameCount = 0
local driver
local elapsedSinceScan = 0

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

local function UpdateDriver()
  if #active > 0 then
    if not driver then
      driver = CreateFrame("Frame", nil, UIParent)
      driver:SetScript("OnUpdate", function(_, elapsed)
        elapsedSinceScan = elapsedSinceScan + elapsed
        if elapsedSinceScan < 0.1 then return end
        elapsedSinceScan = 0
        Dialogs.PositionDialogs(active)
      end)
    end
    driver:Show()
  elseif driver then
    driver:Hide()
    elapsedSinceScan = 0
  end
end

---@param frame DialogFrame
local function Release(frame)
  if not frame.active then return end
  frame.active = false
  for i, shown in ipairs(active) do
    if shown == frame then table.remove(active, i); break end
  end
  frame.data = nil
  frame.Text.text_arg1, frame.Text.text_arg2 = nil, nil
  frame.EditBox:SetText("")
  frame.EditBox:ClearFocus()
  UpdateDriver()
end

--- Definitions own their frames. No pool means scripts/fonts from one dialog
--- cannot leak into another purpose, and callbacks never borrow another key's frame.
---@param which string
---@param arg1 string|number?
---@param arg2 string|number?
---@param data any
---@return DialogFrame?
function Dialogs.Show(which, arg1, arg2, data)
  local definition = assert(Dialogs.Dialogs[which], "Unknown dialog definition")
  if not definition.whileDead and UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") then return end
  local frame = frames[which]
  if not frame then
    frameCount = frameCount + 1
    frame = CreateFrame("Frame", "AddonDialog" .. frameCount, UIParent, "AddonDialogTemplate")
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

  frame.generation = frame.generation + 1
  local generation = frame.generation
  frame.definition, frame.data = definition, data
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
    Dialogs.PositionDialogs(active)
  end
  UpdateDriver()
  return frame.active and frame or nil
end

---@param which string
---@return DialogFrame?
function Dialogs.FindVisible(which)
  local frame = frames[which]
  return frame and frame.active and frame or nil
end

---@param which string
function Dialogs.Hide(which)
  local frame = Dialogs.FindVisible(which)
  if frame then frame:Hide() end
end

---@param which string
---@return boolean
function Dialogs.IsShown(which) return Dialogs.FindVisible(which) ~= nil end

---@return boolean
function Dialogs.IsAnyDialogShown() return #active > 0 end

--- The most recently shown decision consumes Escape; ordinary keys propagate.
---@param key string
function FrameMixin:OnKeyDown(key)
  local handled = key == "ESCAPE" and active[#active] == self and self.definition.hideOnEscape and not self.handlingChoice
  self:SetPropagateKeyboardInput(not handled)
  if not handled then return end
  local generation = self.generation
  self.handlingChoice = true
  Call(self.definition.OnCancel, self, self.data, "clicked")
  self.handlingChoice = false
  if self.generation == generation then self:Hide() end
  -- Reopening during the callback resets input propagation. Consume this key
  -- after the callback so the same Escape cannot reach another window/binding.
  self:SetPropagateKeyboardInput(false)
end

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

function FrameMixin:OnHide()
  if not self:IsShown() then Release(self) end
end

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
  self.Text:SetFontObject(UserScaledFontGameHighlight or GameFontHighlight)
  for index, button in ipairs({ self.Button1, self.Button2 }) do
    button:SetNormalFontObject(UserScaledFontGameNormal or GameFontNormal)
    button:SetHighlightFontObject(UserScaledFontGameHighlight or GameFontHighlight)
    button:SetDisabledFontObject(UserScaledFontGameDisable or GameFontDisable)
    button:SetScript("OnClick", function() self:Choose(index) end)
  end
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
  local buttons = {}
  local buttonWidth, buttonHeight = 120, 21
  for _, button in ipairs({ self.Button1, self.Button2 }) do
    if button:IsShown() then
      buttons[#buttons + 1] = button
      buttonWidth = math.max(buttonWidth, button:GetTextWidth() + 20)
      buttonHeight = math.max(buttonHeight, button:GetFontString():GetStringHeight() + 8)
    end
  end
  local width = info.showAlert and 420 or 320
  width = math.max(width, #buttons * buttonWidth + math.max(0, #buttons - 1) * 10 + 32)
  self.Text:SetWidth(290)
  local y = 16 + self.Text:GetStringHeight()
  if info.hasEditBox then
    local inputWidth = info.editBoxWidth or 280
    width = math.max(width, inputWidth + 32)
    self.EditBox:SetWidth(inputWidth)
    self.EditBox:ClearAllPoints()
    self.EditBox:SetPoint("TOP", self, "TOP", 0, -y - 9)
    y = y + 9 + self.EditBox:GetHeight()
  end
  for index, button in ipairs(buttons) do
    local x = #buttons == 1 and 0 or (index == 1 and -1 or 1) * (buttonWidth + 10) / 2
    button:SetSize(buttonWidth, buttonHeight)
    button:ClearAllPoints()
    button:SetPoint("TOP", self, "TOP", x, -y - 9)
  end
  self:SetWidth(width)
  self:SetHeight(y + (#buttons > 0 and (9 + buttonHeight) or 0) + 16)
end

---@return EditBox
function FrameMixin:GetEditBox() return self.EditBox end
---@return string
function FrameMixin:GetEditBoxText() return self.EditBox:GetText() end
---@return Button
function FrameMixin:GetButton1() return self.Button1 end
---@return Button
function FrameMixin:GetButton2() return self.Button2 end
