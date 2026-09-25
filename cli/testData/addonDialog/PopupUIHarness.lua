-- Native controls only; production Lua builds the actual dialog hierarchy.
local function Dispatch(region, script)
  if region.scripts[script] then region.scripts[script](region) end
  for _, child in ipairs(region.children) do
    if child:IsShown() then Dispatch(child, script) end
  end
end

local function NewRegion(parent)
  local region = { parent = parent, shown = true, enabled = true, text = "", width = 120, height = 21, scale = 1,
    scripts = {}, children = {}, points = {} }
  if parent then parent.children[#parent.children + 1] = region end
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
  function region.IsProtected(frame) return frame.protected or false end
  function region:IsEnabled() return self.enabled end
  function region:Enable() self.enabled = true end
  function region:Disable() self.enabled = false end
  function region:SetText(text)
    self.text = text
    if self.fontString then self.fontString:SetText(text) end
  end
  function region:GetText() return self.text end
  function region:GetTextWidth() return #self.text * 7 end
  function region:GetStringHeight() return math.ceil(math.max(1, #self.text * 7) / self.width) * 14 end
  function region:GetFontString() return self.fontString or self end
  function region:SetFontString(text) self.fontString = text end
  function region:SetFontObject(font) self.font = font end
  function region:SetNormalFontObject(font) self.normalFont = font end
  function region:SetHighlightFontObject(font) self.highlightFont = font end
  function region:SetDisabledFontObject(font) self.disabledFont = font end
  function region:SetAtlas(atlas) self.atlas = atlas end
  function region:SetTexture(texture) self.texture = texture end
  function region:SetColorTexture(...) self.color = { ... } end
  function region:SetTexCoord(...) self.texCoords = { ... } end
  function region:SetBackdrop(backdrop) self.backdrop = backdrop end
  function region:SetSize(width, height) self.width, self.height = width, height end
  function region:SetWidth(width) self.width = width end
  function region:SetHeight(height) self.height = height end
  function region:GetWidth() return self.width end
  function region:GetHeight() return self.height end
  function region:GetRect() return 0, 0, self.width, self.height end
  function region:GetEffectiveScale() return self.scale * (self.parent and self.parent:GetEffectiveScale() or 1) end
  function region:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function region:SetAllPoints(target) self.allPoints = target end
  function region:ClearAllPoints() self.points = {} end
  function region:GetParent() return self.parent end
  function region:GetName() return self.name end
  function region:SetScript(script, callback) self.scripts[script], self[script] = callback, callback end
  function region:GetScript(script) return self.scripts[script] end
  function region:RegisterEvent(event) self.events = self.events or {}; self.events[event] = true end
  function region:RegisterForClicks(...) self.clicks = { ... } end
  function region:ClearFocus() self.focused = false end
  function region:SetFocus() self.focused = true end
  function region:HighlightText() self.highlighted = true end
  function region:SetAutoFocus(value) self.autoFocus = value end
  function region:SetTextInsets(...) self.textInsets = { ... } end
  function region:SetJustifyH(value) self.justifyH = value end
  function region:SetJustifyV(value) self.justifyV = value end
  function region:SetToplevel(value) self.toplevel = value end
  function region:SetClampedToScreen(value) self.clamped = value end
  function region:EnableMouse(value) self.mouse = value end
  function region:EnableKeyboard(value) self.keyboard = value end
  function region:SetFrameStrata(strata) self.strata = strata end
  function region:GetFrameStrata() return self.strata end
  function region:SetPropagateKeyboardInput(value) self.propagate = value end
  function region.Raise() end
  function region:Click() if self.scripts.OnClick then self.scripts.OnClick(self) end end
  function region:CreateTexture() return NewRegion(self) end
  function region:CreateFontString() return NewRegion(self) end
  for _, state in ipairs({ "Normal", "Pushed", "Disabled", "Highlight" }) do
    region["Set" .. state .. "Texture"] = function(self, path, blend)
      self[state .. "Texture"] = NewRegion(self)
      self[state .. "Texture"].texture = path
      self[state .. "Texture"].blend = blend
    end
    region["Get" .. state .. "Texture"] = function(self) return self[state .. "Texture"] end
  end
  return region
end

local function Install(env)
  local harness = { frames = {} }
  env.UIParent = NewRegion()
  env.UIParent:SetSize(1000, 800)
  env.GameFontHighlight, env.GameFontNormal, env.GameFontDisable = {}, {}, {}
  env.BACKDROP_DIALOG_32_32 = {}
  env.GetBindingFromClick = function(key)
    if key == "ESCAPE" then return "TOGGLEGAMEMENU" end
    return ""
  end
  env.CreateFrame = function(_, name, parent, template)
    assert(not template or template == "BackdropTemplate", "Custom XML templates must not be needed")
    local frame = NewRegion(parent)
    frame.name = name
    if name then env[name] = frame end
    harness.lastCreatedFrame = frame
    harness.frames[#harness.frames + 1] = frame
    return frame
  end
  -- Use real version negotiation, isolated from other tests' LibStub instances.
  env.LibStub = { minor = 0, libs = {}, minors = {} }
  for _, path in ipairs({ "Libs/LibStub/LibStub.lua", "Libs/LibPopupStack-1.0/LibPopupStack-1.0.lua" }) do
    local chunk = assert(loadfile(path))
    setfenv(chunk, env)()
  end
  harness.stack = env.LibStub("LibPopupStack-1.0")
  return harness
end

local function LoadDialog(env, private)
  local chunk = assert(loadfile("Libs/AddonDialog/Dialog.lua"))
  setfenv(chunk, env)("TestAddon", private)
  return private.Dialog
end

local function NewEnvironment()
  local errors = {}
  local env = setmetatable({ geterrorhandler = function()
    return function(message) errors[#errors + 1] = message end
  end }, { __index = _G })
  env._G = env
  local harness = Install(env)
  local private = {}
  LoadDialog(env, private)
  return env, errors, harness, private
end

return { Install = Install, NewEnvironment = NewEnvironment, LoadDialog = LoadDialog }
