-- luacheck: globals AddonDialog issecretvalue
local Popup = AddonDialog
if Popup.PositionDialogs then return end
local GAP, MARGIN = 10, 8

---@param value any
---@return boolean
local function ReadableNumber(value)
  return not (issecretvalue and issecretvalue(value)) and type(value) == "number"
end

---Reject incomplete or restricted geometry rather than moving from partial bounds.
---@param frame Frame
---@return number? left
---@return number? bottom
---@return number? width
---@return number? height
---@return number? scale
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
---@param dialogs DialogFrame[] Active owned frames, in display order.
function Popup.PositionDialogs(dialogs)
  if #dialogs == 0 then return end
  local parentLeft, parentBottom, parentWidth, parentHeight, parentScale = ReadableRect(UIParent)
  if not parentLeft then return end

  -- Measure the whole owned stack in UIParent units, even if callers scale an
  -- individual frame. Convert offsets back to each frame's units at SetPoint.
  ---@type {frame: DialogFrame, ratio: number, height: number, offset: number}[], table<Frame, boolean>
  local placements, owned = {}, {}
  local width, height = 0, 0
  for _, frame in ipairs(dialogs) do
    local scale, fw, fh = frame:GetEffectiveScale(), frame:GetWidth(), frame:GetHeight()
    if not (ReadableNumber(scale) and ReadableNumber(fw) and ReadableNumber(fh)) then return end
    if scale <= 0 or fw <= 0 or fh <= 0 then return end
    local ratio = scale / parentScale
    fw, fh = fw * ratio, fh * ratio
    placements[#placements + 1] = { frame = frame, ratio = ratio, height = fh, offset = height }
    owned[frame] = true
    width = math.max(width, fw)
    height = height + fh + GAP
  end
  height = height - GAP

  -- Union of readable Blizzard bounds, in UIParent units.
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
  if type(StaticPopup_ForEachShownDialog) == "function" then
    StaticPopup_ForEachShownDialog(IncludePopup)
  else
    for i = 1, 4 do IncludePopup(_G["StaticPopup" .. i]) end
  end
  -- Callback returns cannot abort the iterator; never place from partial bounds.
  if unreadable then return end

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
  -- No free side (or an oversized stack): retain a deterministic normal
  -- placement, never hide an active decision just to avoid overlap.
  for _, placement in ipairs(placements) do
    local frame = placement.frame
    local fx, fy = x / placement.ratio, (y - placement.offset) / placement.ratio
    if frame.popupAnchorX ~= fx or frame.popupAnchorY ~= fy then
      frame:ClearAllPoints()
      frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", fx, fy)
      frame.popupAnchorX, frame.popupAnchorY = fx, fy
    end
  end
end
