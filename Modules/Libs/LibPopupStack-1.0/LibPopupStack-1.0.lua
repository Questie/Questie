-- luacheck: globals LibStub CreateFrame UIParent StaticPopup_ForEachShownDialog issecretvalue
-- Positioning-only coordinator for independently implemented addon dialogs.
-- Load after LibStub and before consumers; acquire with LibStub("LibPopupStack-1.0").
-- Register after Show, RequestLayout after resizing, Unregister on dismissal.
-- Only frame references, order and placement state are shared, never definitions,
-- callback dispatch, style or control layout. One stack avoids competing addons'
-- avoidance loops chasing each other's positions.
local lib = LibStub:NewLibrary("LibPopupStack-1.0", 1)
if not lib then return end

-- LibStub skips older/equal copies. Compatible upgrades retain registration order,
-- cached anchors and the sole driver, then replace its dispatch below. Preserve
-- this state/API contract across minor versions; incompatible changes need a new major.
lib.frames = lib.frames or {}
lib.anchors = lib.anchors or {}
lib.driver = lib.driver or CreateFrame("Frame", nil, UIParent)
lib.elapsed = lib.elapsed or 0
local NativeIsProtected = lib.driver.IsProtected

---Register only addon-owned, ordinary unprotected frames, after showing them.
---Ownership is the caller's responsibility: the native protection check cannot
---identify arbitrary frame creators. Never pass Blizzard frames or protected UI.
---Registration delegates anchors to this library; do not run a competing positioner.
---Repeated registration keeps order; unregistering then registering appends at the end.
---Layout removes effectively hidden frames, including ones with hidden ancestors;
---register again when they become visible. Registration itself does not show them.
---@param frame Frame Caller-owned frame with readable dimensions and scale.
---@return boolean accepted False for UIParent, forbidden frames, or native protected frames when that query exists.
function lib:Register(frame)
  if frame == UIParent or (frame.IsForbidden and frame:IsForbidden()) then return false end
  if NativeIsProtected and NativeIsProtected(frame) then return false end
  for _, existing in ipairs(self.frames) do
    if existing == frame then self:RequestLayout(); return true end
  end
  self.frames[#self.frames + 1] = frame
  self:RequestLayout()
  return true
end

---Release registration and cached anchors without hiding or otherwise resetting the frame.
---Safe to repeat or call for a frame that is not registered; remaining frames keep order.
---@param frame Frame
function lib:Unregister(frame)
  for i, existing in ipairs(self.frames) do
    if existing == frame then table.remove(self.frames, i); break end
  end
  self.anchors[frame] = nil
  self:RequestLayout()
end

---Coalesce show, hide and size changes into the next rendered frame, not synchronously.
---The same driver polls every 0.1 seconds while registrations remain, observing
---Blizzard popup movement and scale changes without hooking their lifecycle.
---Callers still measure/resize their own controls; this library only places frames.
function lib:RequestLayout()
  self.pending = true
  self.driver:Show()
end

-- Spacing is measured in UIParent units, regardless of an individual dialog's scale.
local GAP, MARGIN = 10, 8

---Check secrets before comparisons/arithmetic; NaN and infinities are not usable bounds.
---@param value any
---@return boolean
local function ReadableNumber(value)
  return not (issecretvalue and issecretvalue(value)) and type(value) == "number"
    and value == value and value > -math.huge and value < math.huge
end

---Read native geometry without invoking helpers that register or reposition popups.
---Return all five values together, or none when incomplete/restricted. Rect values
---use the frame's effective scale; callers convert them to a common coordinate space.
---@param frame Frame
---@return number? left
---@return number? bottom
---@return number? width
---@return number? height
---@return number? scale Effective scale for the returned rectangle.
local function ReadableRect(frame)
  if frame.IsForbidden and frame:IsForbidden() then return end
  local left, bottom, width, height = frame:GetRect()
  local scale = frame:GetEffectiveScale()
  if not (ReadableNumber(left) and ReadableNumber(bottom) and ReadableNumber(width)
      and ReadableNumber(height) and ReadableNumber(scale)) then return end
  if width <= 0 or height <= 0 or scale <= 0 then return end
  return left, bottom, width, height, scale
end

--- Keep our stack outside Blizzard's popup lists. Joining those lists can carry
--- addon taint into unrelated UI. The official iterator is read-only; collect
--- bounds first, then position only owned frames relative to UIParent.
---@param dialogs Frame[] Registered visible frames, in display order.
local function PositionDialogs(dialogs)
  if #dialogs == 0 then return end
  local parentLeft, parentBottom, parentWidth, parentHeight, parentScale = ReadableRect(UIParent)
  if not parentLeft then return end

  -- Measure the whole owned stack in UIParent units, even if callers scale an
  -- individual frame. Convert offsets back to each frame's units at SetPoint.
  ---@type {frame: Frame, ratio: number, offset: number}[], table<Frame, boolean>
  local placements, owned = {}, {}
  local width, height = 0, 0
  for _, frame in ipairs(dialogs) do
    local scale, fw, fh = frame:GetEffectiveScale(), frame:GetWidth(), frame:GetHeight()
    if not (ReadableNumber(scale) and ReadableNumber(fw) and ReadableNumber(fh)) then return end
    if scale <= 0 or fw <= 0 or fh <= 0 then return end
    local ratio = scale / parentScale
    fw, fh = fw * ratio, fh * ratio
    placements[#placements + 1] = { frame = frame, ratio = ratio, offset = height }
    owned[frame] = true
    width = math.max(width, fw)
    height = height + fh + GAP
  end
  height = height - GAP

  -- Measure Blizzard separately: its union of bounds is an obstacle, never an
  -- anchor or a registration target. Normalize to UIParent's bottom-left origin.
  ---@type number?, number?, number?, number?
  local left, bottom, right, top
  local unreadable = false
  -- Iterator callback also serves the legacy four-frame fallback.
  ---@param frame Frame?
  local function IncludePopup(frame)
    if unreadable or not frame or owned[frame] then return end
    if frame.IsForbidden and frame:IsForbidden() then unreadable = true; return end
    local visible = frame:IsVisible()
    if issecretvalue and issecretvalue(visible) then unreadable = true; return end
    if not visible then return end
    local px, py, pw, ph, scale = ReadableRect(frame)
    if not px then unreadable = true; return end
    local ratio = scale / parentScale
    px, py, pw, ph = px * ratio - parentLeft, py * ratio - parentBottom, pw * ratio, ph * ratio
    left, bottom = math.min(left or px, px), math.min(bottom or py, py)
    right, top = math.max(right or (px + pw), px + pw), math.max(top or (py + ph), py + ph)
  end
  -- The official iterator includes special dialogs such as Edit Mode prompts.
  -- Older clients expose only the familiar four globals. Both paths read bounds;
  -- no Blizzard frame is moved, hooked or added to an addon-owned popup list.
  if type(StaticPopup_ForEachShownDialog) == "function" then
    StaticPopup_ForEachShownDialog(IncludePopup)
  else
    for i = 1, 4 do IncludePopup(_G["StaticPopup" .. i]) end
  end
  -- Callback returns cannot abort the iterator; never place from partial bounds.
  if unreadable then return end

  -- Choose a position for the whole stack: below Blizzard first, then above,
  -- right, then left. Without readable visible popups, use normal top-center.
  -- Only a stack that fits the screen gets edge-constrained avoidance placement.
  local x, y = parentWidth / 2, parentHeight - 135
  local fits = width + MARGIN * 2 <= parentWidth and height + MARGIN * 2 <= parentHeight
  if fits then
    y = math.max(height + MARGIN, math.min(y, parentHeight - MARGIN))
    if left then
      local centeredX = math.max(width / 2 + MARGIN, math.min((left + right) / 2, parentWidth - width / 2 - MARGIN))
      local below = math.min(bottom - GAP, parentHeight - MARGIN)
      local above = math.max(top + GAP + height, height + MARGIN)
      if below - height >= MARGIN then
        x, y = centeredX, below
      elseif above <= parentHeight - MARGIN then
        x, y = centeredX, above
      elseif right + GAP + width <= parentWidth - MARGIN then
        x = math.max(width / 2 + MARGIN, right + GAP + width / 2)
      elseif left - GAP - width >= MARGIN then
        x = math.min(parentWidth - width / 2 - MARGIN, left - GAP - width / 2)
      end
    end
  end
  -- No free side (or an oversized stack): retain deterministic normal placement.
  -- Never hide a decision to avoid overlap. Oversized stacks may still overlap
  -- or extend beyond the screen; this coordinator does not shrink their controls.
  -- Apply TOP offsets in each frame's own units. Cached offsets avoid repeatedly
  -- invalidating unchanged layouts during polling; callers must not replace anchors.
  for _, placement in ipairs(placements) do
    local frame = placement.frame
    local fx, fy = x / placement.ratio, (y - placement.offset) / placement.ratio
    local anchor = lib.anchors[frame]
    if not anchor or anchor.x ~= fx or anchor.y ~= fy then
      frame:ClearAllPoints()
      frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", fx, fy)
      lib.anchors[frame] = { x = fx, y = fy }
    end
  end
end

-- Visibility cleanup precedes geometry reads, so unresolved geometry cannot retain
-- hidden dialogs. Never derive the next stack from our previous frame positions.
-- This is driver work; consumers use Register/Unregister/RequestLayout instead.
function lib:Layout()
  local blocked = false
  for i = #self.frames, 1, -1 do
    local frame = self.frames[i]
    if (frame.IsForbidden and frame:IsForbidden()) or (NativeIsProtected and NativeIsProtected(frame)) then
      blocked = true
    else
      local visible = frame:IsVisible()
      if issecretvalue and issecretvalue(visible) then
        blocked = true
      elseif not visible then
        table.remove(self.frames, i)
        self.anchors[frame] = nil
      end
    end
  end
  if #self.frames == 0 then self.driver:Hide(); return end
  -- Keep restricted registrations for retry, but do not place a partial stack.
  -- If an owner can no longer supply usable geometry, it must unregister the frame.
  if not blocked then PositionDialogs(self.frames) end
end

-- Dispatch through the shared table so upgrades replace behavior without another driver.
lib.driver:SetScript("OnUpdate", function(_, elapsed)
  lib.elapsed = lib.elapsed + elapsed
  if lib.pending or lib.elapsed >= 0.1 then
    lib.pending, lib.elapsed = false, 0
    lib:Layout()
  end
end)
if #lib.frames > 0 then lib:RequestLayout() else lib.driver:Hide() end
