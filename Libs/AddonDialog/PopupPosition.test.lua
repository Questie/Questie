-- Geometry tests do not emulate the client's taint/secret enforcement.
local function RectFrame(left, bottom, width, height, scale)
  return {
    left = left, bottom = bottom, width = width, height = height, scale = scale or 1,
    visible = true, rectReads = 0,
    IsVisible = function(self) return self.visible end,
    IsForbidden = function(self) return self.forbidden or false end,
    GetEffectiveScale = function(self) return self.scale end,
    GetRect = function(self)
      self.rectReads = self.rectReads + 1
      return self.left, self.bottom, self.width, self.height
    end,
  }
end

describe("owned popup stack positioning", function()
  local env, popup, frame, NewOwnedFrame
  before_each(function()
    env = { AddonDialog = {}, UIParent = RectFrame(0, 0, 1000, 800) }
    setmetatable(env, { __index = _G })
    env._G = env
    local chunk = assert(loadfile("Libs/AddonDialog/PopupPosition.lua"))
    setfenv(chunk, env)
    chunk()
    popup = env.AddonDialog
    NewOwnedFrame = function(scale)
      return {
        scale = scale or 1, moves = 0,
        GetWidth = function() return 420 end,
        GetHeight = function() return 140 end,
        GetEffectiveScale = function(self) return self.scale end,
        ClearAllPoints = function() end,
        SetPoint = function(self, point, relative, relativePoint, x, y)
          assert.equals("TOP", point)
          assert.equals(env.UIParent, relative)
          assert.equals("BOTTOMLEFT", relativePoint)
          self.x, self.y, self.moves = x, y, self.moves + 1
        end,
      }
    end
    frame = NewOwnedFrame()
  end)

  it("does not invalidate unchanged anchors", function()
    env.StaticPopup1 = RectFrame(290, 530, 420, 135)
    popup.PositionDialogs({ frame })
    popup.PositionDialogs({ frame })
    assert.equals(500, frame.x)
    assert.equals(520, frame.y)
    assert.equals(1, frame.moves)
  end)

  it("stacks owned frames without overlap and restores normal placement", function()
    local second = NewOwnedFrame()
    env.StaticPopup4 = RectFrame(290, 500, 420, 135)
    popup.PositionDialogs({ frame, second })
    assert.equals(490, frame.y)
    assert.equals(340, second.y)
    env.StaticPopup4.visible = false
    popup.PositionDialogs({ frame, second })
    assert.equals(665, frame.y)
    assert.equals(515, second.y)
  end)

  it("accounts for the height of the entire stack when choosing a free side", function()
    local second = NewOwnedFrame()
    env.StaticPopup1 = RectFrame(290, 200, 420, 135)
    popup.PositionDialogs({ frame, second })
    assert.equals(635, frame.y)
    assert.equals(485, second.y)
  end)

  it("observes special dialogs without moving anything inside Blizzard's iterator", function()
    local special = RectFrame(250, 300, 500, 220)
    env.StaticPopup_ForEachShownDialog = function(callback)
      callback(special)
      assert.equals(0, frame.moves)
    end
    popup.PositionDialogs({ frame })
    assert.equals(290, frame.y)
    assert.equals(1, special.rectReads)
  end)

  it("converts different scales and UIParent origins", function()
    env.UIParent = RectFrame(100, 50, 1000, 800, 0.8)
    env.StaticPopup1 = RectFrame(300, 300, 200, 100, 1.2)
    frame.scale = 0.4
    popup.PositionDialogs({ frame })
    assert.near(1000, frame.x, 0.0001)
    assert.near(780, frame.y, 0.0001)
  end)

  it("uses each owned frame's scale when stacking", function()
    local second = NewOwnedFrame(2)
    popup.PositionDialogs({ frame, second })
    assert.equals(500, frame.x)
    assert.equals(665, frame.y)
    assert.equals(250, second.x)
    assert.equals(257.5, second.y)
  end)

  it("fits beside a tall Blizzard stack", function()
    env.StaticPopup1 = RectFrame(0, 5, 300, 790)
    popup.PositionDialogs({ frame })
    assert.equals(520, frame.x)
    assert.equals(665, frame.y)
    env.StaticPopup1.left = 700
    popup.PositionDialogs({ frame })
    assert.equals(480, frame.x)
  end)

  it("keeps choices visible at the normal position when no free side fits", function()
    env.StaticPopup1 = RectFrame(0, 0, 1000, 800)
    popup.PositionDialogs({ frame })
    assert.equals(500, frame.x)
    assert.equals(665, frame.y)
  end)

  it("rejects a partial scan when another popup has secret coordinates", function()
    local normal = RectFrame(290, 530, 420, 135)
    local special = RectFrame(290, 123456, 420, 135)
    env.issecretvalue = function(value) return value == 123456 end
    env.StaticPopup_ForEachShownDialog = function(callback) callback(normal); callback(special) end
    popup.PositionDialogs({ frame })
    assert.equals(0, frame.moves)
  end)

  it("does not branch on secret visibility", function()
    local secret = {}
    env.issecretvalue = function(value) return value == secret end
    env.StaticPopup1 = RectFrame(290, 530, 420, 135)
    env.StaticPopup1.visible = secret
    popup.PositionDialogs({ frame })
    assert.equals(0, env.StaticPopup1.rectReads)
    assert.equals(0, frame.moves)
  end)

  it("waits for unresolved coordinates and avoids forbidden frames", function()
    env.StaticPopup1 = RectFrame(nil, nil, 420, 135)
    popup.PositionDialogs({ frame })
    assert.equals(0, frame.moves)
    env.StaticPopup1.forbidden = true
    popup.PositionDialogs({ frame })
    assert.equals(1, env.StaticPopup1.rectReads)
    env.StaticPopup1.forbidden = false
    env.StaticPopup1.left, env.StaticPopup1.bottom = 290, 530
    popup.PositionDialogs({ frame })
    assert.equals(520, frame.y)
  end)
end)
