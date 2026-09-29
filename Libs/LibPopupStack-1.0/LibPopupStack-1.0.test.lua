-- These mocks check geometry and ownership, not the client's taint enforcement.
local SOURCE = "Libs/LibPopupStack-1.0/LibPopupStack-1.0.lua"
local function FrameRect(left, bottom, width, height, scale)
  return {
    left = left, bottom = bottom, width = width, height = height, scale = scale or 1,
    visible = true, moves = 0, rectReads = 0,
    IsVisible = function(self) return self.visible end,
    IsForbidden = function(self) return self.forbidden or false end,
    IsProtected = function(self) return self.protected or false end,
    GetEffectiveScale = function(self) return self.scale end,
    GetWidth = function(self) return self.width end,
    GetHeight = function(self) return self.height end,
    GetRect = function(self)
      self.rectReads = self.rectReads + 1
      return self.left, self.bottom, self.width, self.height
    end,
    ClearAllPoints = function() end,
    SetPoint = function(self, point, relative, relativePoint, x, y)
      assert.equals("TOP", point)
      assert.equals("BOTTOMLEFT", relativePoint)
      self.relative, self.x, self.y, self.moves = relative, x, y, self.moves + 1
    end,
    Show = function(self) self.visible = true end,
    Hide = function(self) self.visible = false end,
    SetScript = function(self, name, callback) self[name] = callback end,
  }
end

local function Load(path, env)
  local chunk = assert(loadfile(path))
  setfenv(chunk, env)()
end

describe("LibPopupStack-1.0", function()
  local env, stack, first, second, drivers
  local function Tick(elapsed)
    if drivers[1].visible then drivers[1].OnUpdate(drivers[1], elapsed or 0.01) end
  end

  before_each(function()
    drivers = {}
    env = setmetatable({ LibStub = false, UIParent = FrameRect(0, 0, 1000, 800) }, { __index = _G })
    env._G = env
    env.CreateFrame = function(kind, name, parent)
      assert.equals("Frame", kind)
      assert.is_nil(name)
      assert.equals(env.UIParent, parent)
      local driver = FrameRect(0, 0, 1, 1)
      drivers[#drivers + 1] = driver
      return driver
    end
    Load("Libs/LibStub/LibStub.lua", env)
    Load(SOURCE, env)
    stack = env.LibStub("LibPopupStack-1.0")
    first, second = FrameRect(nil, nil, 420, 140), FrameRect(nil, nil, 420, 140)
  end)

  it("shares registration order across consumers and coalesces requests", function()
    local otherConsumer = env.LibStub("LibPopupStack-1.0")
    stack:Register(first)
    otherConsumer:Register(second)
    stack:Register(first)
    stack:RequestLayout()
    assert.equals(0, first.moves)
    Tick()
    assert.equals(665, first.y)
    assert.equals(515, second.y)
    assert.equals(env.UIParent, first.relative)
    Tick(0.1)
    assert.equals(1, first.moves)
    assert.equals(1, second.moves)
    stack:Unregister(first)
    stack:Unregister(first)
    Tick()
    assert.equals(665, second.y)
    assert.is_nil(stack.anchors[first])
    stack:Unregister(second)
    Tick()
    assert.is_false(drivers[1].visible)
    assert.equals(0, #stack.frames)
  end)

  it("uses individual heights and scales rather than current positions", function()
    first.height, second.scale = 100, 2
    stack:Register(first)
    stack:Register(second)
    Tick()
    assert.equals(500, first.x)
    assert.equals(665, first.y)
    assert.equals(250, second.x)
    assert.equals(277.5, second.y)
    first.height = 200
    stack:RequestLayout()
    Tick()
    assert.equals(227.5, second.y)
    assert.equals(0, first.rectReads)
  end)

  it("converts UIParent origins and effective scales", function()
    env.UIParent = FrameRect(100, 50, 1000, 800, 0.8)
    env.StaticPopup1 = FrameRect(300, 300, 200, 100, 1.2)
    first.scale = 0.4
    stack:Register(first)
    Tick()
    assert.near(1000, first.x, 0.0001)
    assert.near(780, first.y, 0.0001)
    assert.equals(env.UIParent, first.relative)
  end)

  it("observes special Blizzard dialogs without writing inside the iterator", function()
    local special = FrameRect(250, 300, 500, 220)
    env.StaticPopup_ForEachShownDialog = function(callback)
      callback(special)
      assert.equals(0, first.moves)
    end
    stack:Register(first)
    Tick()
    assert.equals(290, first.y)
    assert.equals(0, special.moves)
    assert.equals(0, env.UIParent.moves)
  end)

  it("polls legacy Blizzard dialogs and cleans hidden registrations", function()
    env.StaticPopup4 = FrameRect(290, 500, 420, 135)
    stack:Register(first)
    stack:Register(second)
    Tick()
    assert.equals(490, first.y)
    assert.equals(340, second.y)
    env.StaticPopup4.visible = false
    Tick(0.05)
    assert.equals(490, first.y)
    Tick(0.05)
    assert.equals(665, first.y)
    first:Hide()
    Tick(0.1)
    assert.equals(665, second.y)
    assert.is_nil(stack.anchors[first])
    assert.equals(second, stack.frames[1])
    second:Hide()
    Tick(0.1)
    assert.equals(0, #stack.frames)
    assert.is_false(drivers[1].visible)
    first:Show()
    stack:Register(first)
    Tick()
    assert.is_true(drivers[1].visible)
  end)

  it("retains state on compatible upgrades and creates no second driver", function()
    stack:Register(first)
    stack:Register(second)
    Tick()
    local registry, anchors, driver = stack.frames, stack.anchors, drivers[1]
    -- Simulate a higher-minor release of this same compatible implementation.
    local file = assert(io.open(SOURCE))
    local source = file:read("*a")
    file:close()
    source = source:gsub('NewLibrary%("LibPopupStack%-1%.0", 1%)', 'NewLibrary("LibPopupStack-1.0", 2)')
    setfenv(assert(loadstring(source)), env)()
    Load(SOURCE, env) -- Older copies must not replace the upgrade.
    assert.equals(2, env.LibStub.minors["LibPopupStack-1.0"])
    assert.equals(stack, env.LibStub("LibPopupStack-1.0"))
    assert.equals(registry, stack.frames)
    assert.equals(anchors, stack.anchors)
    assert.equals(driver, stack.driver)
    assert.equals(1, #drivers)
    Tick()
    assert.equals(1, first.moves)
    assert.equals(515, second.y)
    local calls = 0
    stack.Layout = function() calls = calls + 1 end
    Tick(0.1)
    assert.equals(1, calls)
  end)

  it("rejects protected and forbidden registrations using the native method", function()
    first.protected = true
    first.IsProtected = function() return false end
    assert.is_false(stack:Register(first))
    second.forbidden = true
    assert.is_false(stack:Register(second))
    assert.is_false(stack:Register(env.UIParent))
    assert.equals(0, #stack.frames)
    assert.is_false(drivers[1].visible)
  end)

  it("does not move a registered frame that later becomes protected", function()
    stack:Register(first)
    Tick()
    first.protected = true
    env.StaticPopup1 = FrameRect(290, 530, 420, 135)
    Tick(0.1)
    assert.equals(1, first.moves)
    first.protected = false
    Tick(0.1)
    assert.equals(520, first.y)
  end)

  it("leaves all placements unchanged on secret or unresolved Blizzard geometry", function()
    local secret = {}
    env.issecretvalue = function(value) return value == secret end
    stack:Register(first)
    Tick()
    env.StaticPopup1 = FrameRect(290, 530, 420, 135)
    local special = FrameRect(290, secret, 420, 135)
    env.StaticPopup_ForEachShownDialog = function(callback) callback(env.StaticPopup1); callback(special) end
    Tick(0.1)
    assert.equals(1, first.moves)
    special.bottom = nil
    Tick(0.1)
    assert.equals(1, first.moves)
    special.forbidden = true
    Tick(0.1)
    assert.equals(2, special.rectReads)
    assert.equals(1, first.moves)
    special.forbidden, special.bottom = false, 500
    Tick(0.1)
    assert.equals(490, first.y)
  end)

  it("does not read geometry with secret visibility or forbidden owned frames", function()
    local secret = {}
    env.issecretvalue = function(value) return value == secret end
    env.StaticPopup1 = FrameRect(290, 530, 420, 135)
    env.StaticPopup1.visible = secret
    stack:Register(first)
    Tick()
    assert.equals(0, env.StaticPopup1.rectReads)
    assert.equals(0, first.moves)
    env.StaticPopup1.visible = false
    first.forbidden = true
    Tick(0.1)
    assert.equals(0, first.moves)
    first.forbidden, first.visible = false, secret
    Tick(0.1)
    assert.equals(0, first.moves)
    first.visible, first.width = true, secret
    Tick(0.1)
    assert.equals(0, first.moves)
    first.width, env.UIParent.left = 420, nil
    Tick(0.1)
    assert.equals(0, first.moves)
  end)

  it("chooses above, side and deterministic overlap fallbacks", function()
    env.StaticPopup1 = FrameRect(290, 100, 420, 135)
    stack:Register(first)
    Tick()
    assert.equals(385, first.y)
    env.StaticPopup1 = FrameRect(0, 5, 300, 790)
    Tick(0.1)
    assert.equals(520, first.x)
    env.StaticPopup1.left = 700
    Tick(0.1)
    assert.equals(480, first.x)
    env.StaticPopup1 = FrameRect(0, 0, 1000, 800)
    Tick(0.1)
    assert.equals(500, first.x)
    assert.equals(665, first.y)
  end)
end)
