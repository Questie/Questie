-- Native-region stand-ins only. The real dialog code owns all UI policy.
local function Dispatch(region, script)
  if region.scripts[script] then region.scripts[script](region) end
  for _, child in ipairs(region.children) do
    if child:IsShown() then Dispatch(child, script) end
  end
end

local function NewRegion()
  local region = { shown = true, enabled = true, text = "", width = 120, height = 21, scale = 1,
    scripts = {}, children = {}, points = {} }
  function region:Show()
    if self.shown then return end
    self.shown = true
    if self:IsVisible() then Dispatch(self, "OnShow") end
  end
  function region:Hide()
    if not self.shown then return end
    local visible = self:IsVisible()
    self.shown = false
    if visible then Dispatch(self, "OnHide") end
  end
  function region:SetShown(shown) if shown then self:Show() else self:Hide() end end
  function region:IsShown() return self.shown end
  function region:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
  function region:IsEnabled() return self.enabled end
  function region:Enable() self.enabled = true end
  function region:Disable() self.enabled = false end
  function region:SetText(text) self.text = text end
  function region:GetText() return self.text end
  function region:GetTextWidth() return #self.text * 7 end
  function region:GetStringHeight() return math.ceil(math.max(1, #self.text * 7) / self.width) * 14 end
  function region:GetFontString() return self end
  function region:SetFontObject(font) self.font = font end
  function region:SetNormalFontObject(font) self.normalFont = font end
  function region:SetHighlightFontObject(font) self.highlightFont = font end
  function region:SetDisabledFontObject(font) self.disabledFont = font end
  function region:SetAtlas(atlas) self.atlas = atlas end
  function region:SetBackdrop(backdrop) self.backdrop = backdrop end
  function region:SetSize(width, height) self.width, self.height = width, height end
  function region:SetWidth(width) self.width = width end
  function region:SetHeight(height) self.height = height end
  function region:GetWidth() return self.width end
  function region:GetHeight() return self.height end
  function region:GetRect() return 0, 0, self.width, self.height end
  function region:GetEffectiveScale() return self.scale * (self.parent and self.parent:GetEffectiveScale() or 1) end
  function region:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function region:ClearAllPoints() self.points = {} end
  function region:GetParent() return self.parent end
  function region:GetName() return self.name end
  function region:SetScript(script, callback) self.scripts[script], self[script] = callback, callback end
  function region:GetScript(script) return self.scripts[script] end
  function region:RegisterEvent(event) self.events = self.events or {}; self.events[event] = true end
  function region:ClearFocus() self.focused = false end
  function region:SetFocus() self.focused = true end
  function region:HighlightText() self.highlighted = true end
  function region:SetFrameStrata(strata) self.strata = strata end
  function region:GetFrameStrata() return self.strata end
  function region:SetPropagateKeyboardInput(value) self.propagate = value end
  function region.Raise() end
  function region:Click() if self.scripts.OnClick then self.scripts.OnClick(self) end end
  return region
end

local function Install(env)
  local harness = { frames = {} }
  env.UIParent = NewRegion()
  env.UIParent:SetSize(1000, 800)
  env.GameFontHighlight, env.GameFontNormal, env.GameFontDisable = {}, {}, {}
  env.BACKDROP_DIALOG_32_32 = {}
  env.CreateFrame = function(_, name, parent, template)
    local frame = NewRegion()
    frame.name, frame.parent = name, parent
    if parent then parent.children[#parent.children + 1] = frame end
    if name then env[name] = frame end
    if template then
      assert(template == "AddonDialogTemplate", "Unexpected dialog template")
      frame.shown, frame.strata = false, "DIALOG"
      for key, value in pairs(env.AddonDialogMixin) do frame[key] = value end
      for _, key in ipairs({ "Text", "EditBox", "Button1", "Button2", "Background", "Border", "AlertIcon" }) do
        local child = NewRegion()
        child.parent = frame
        frame.children[#frame.children + 1] = child
        frame[key] = child
        env[name .. key] = child
      end
      frame.Text.width, frame.EditBox.height = 290, 28
      frame.Background.shown, frame.Border.shown = false, false
      frame:SetScript("OnHide", frame.OnHide)
      frame:SetScript("OnKeyDown", frame.OnKeyDown)
      frame:OnLoad()
    end
    harness.lastCreatedFrame = frame
    harness.frames[#harness.frames + 1] = frame
    return frame
  end
  return harness
end

local function NewEnvironment()
  local errors = {}
  local env = setmetatable({ geterrorhandler = function()
    return function(message) errors[#errors + 1] = message end
  end }, { __index = _G })
  env._G = env
  local harness = Install(env)
  for _, path in ipairs({ "Libs/AddonDialog/Dialog.lua", "Libs/AddonDialog/PopupPosition.lua" }) do
    local chunk = assert(loadfile(path))
    setfenv(chunk, env)()
  end
  return env, errors, harness
end

return { Install = Install, NewEnvironment = NewEnvironment }
