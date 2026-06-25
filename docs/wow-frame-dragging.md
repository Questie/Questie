# WoW Frame Dragging Notes for AI Agents

This document explains how draggable World of Warcraft UI frames usually work. It is written for future AI coding agents working in Questie, and does not assume that a local copy of Blizzard's `WoW-API` UI source is available.

## Core mental model

Dragging is a cooperation between two things:

1. **A drag hit area**: the frame that receives mouse input and drag gestures, often a header/title bar.
2. **A movable target**: the frame that actually moves when the drag begins.

Those are often the same frame, but they do not have to be. Blizzard commonly uses a small title/header frame as the drag hit area and moves the larger parent window as the target.

The minimal lifecycle is:

```text
mouse-enabled drag frame
  -> RegisterForDrag("LeftButton")
  -> client detects a left-button drag gesture
  -> OnDragStart script fires
  -> target:StartMoving()
  -> optional SetCursor("UI_MOVE_CURSOR")
  -> OnDragStop script fires
  -> target:StopMovingOrSizing()
  -> SetCursor(nil)
```

## `RegisterForDrag` vs `StartMoving`

These APIs do different jobs:

- `dragFrame:RegisterForDrag("LeftButton")`
  - Tells the WoW client which mouse button should produce drag script events for `dragFrame`.
  - It does **not** move anything by itself.
  - It only enables `OnDragStart` / `OnDragStop` to fire when the user drags that frame with the registered button.

- `targetFrame:StartMoving()`
  - Actually starts moving `targetFrame`.
  - The target frame must be movable, usually via `targetFrame:SetMovable(true)` or XML `movable="true"`.

- `targetFrame:StopMovingOrSizing()`
  - Ends frame movement or resizing.
  - Call this on drag stop, and also during cleanup paths where a drag might be interrupted.

A useful rule of thumb:

```text
RegisterForDrag = "detect a drag gesture here"
StartMoving     = "move this frame now"
```

## Required setup for Lua-created frames

For frames created or configured in Lua, be explicit:

```lua
frame:SetMovable(true)
header:EnableMouse(true)
header:RegisterForDrag("LeftButton")
```

Do not rely on inherited or implicit mouse behavior. Some Blizzard XML templates become mouse-enabled because they declare mouse/drag scripts in XML, but Lua-created frames should explicitly call `EnableMouse(true)`.

## Recommended header/proxy pattern

Use this when only a header/titlebar should start moving a larger window:

```lua
local function MakeFrameDraggableByHeader(frame, header)
    frame:SetMovable(true)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")

    local function StopDrag()
        frame:StopMovingOrSizing()

        if SetCursor then
            SetCursor(nil)
        end
    end

    header:SetScript("OnDragStart", function()
        frame:StartMoving()

        if SetCursor then
            SetCursor("UI_MOVE_CURSOR")
        end
    end)

    header:SetScript("OnDragStop", StopDrag)
    header:SetScript("OnHide", StopDrag)
end
```

Notes for production code:

- If the frame position should persist, save the new point after `StopMovingOrSizing()`.
- If an existing `OnHide` script already exists, hook it instead of replacing it.
- If dragging should be conditional, check the condition before calling `StartMoving()`.
- If the frame uses anchors that fight movement, clear or manage anchors intentionally before/after dragging.

## Cursor handling

Blizzard's shared drag template changes the cursor on drag start:

```lua
SetCursor("UI_MOVE_CURSOR")
```

and resets it on drag stop:

```lua
SetCursor(nil)
```

Always reset the cursor in cleanup paths. If a frame hides while being dragged and `SetCursor(nil)` is not called, the cursor can remain visually wrong until another UI action changes it.

Use `if SetCursor then ... end` if code may run in test environments where WoW globals are mocked or absent.

## XML template equivalent

A Blizzard-style XML template wires drag scripts to a mixin:

```xml
<Frame name="PanelDragBarTemplate" mixin="PanelDragBarMixin" virtual="true">
    <Scripts>
        <OnLoad method="OnLoad"/>
        <OnDragStart method="OnDragStart"/>
        <OnDragStop method="OnDragStop"/>
    </Scripts>
</Frame>
```

The Lua mixin then registers the drag button and moves a target:

```lua
PanelDragBarMixin = {}

function PanelDragBarMixin:OnLoad()
    self:RegisterForDrag("LeftButton")
    self:SetTarget(self:GetParent())
end

function PanelDragBarMixin:SetTarget(target)
    self.target = target
end

function PanelDragBarMixin:OnDragStart()
    local target = self.target
    target:StartMoving()

    if SetCursor then
        SetCursor("UI_MOVE_CURSOR")
    end
end

function PanelDragBarMixin:OnDragStop()
    local target = self.target
    target:StopMovingOrSizing()

    if SetCursor then
        SetCursor(nil)
    end
end
```

Questie code does not need to use XML to follow this pattern. The same behavior can be implemented fully in Lua with `EnableMouse`, `RegisterForDrag`, and drag scripts.

## Blizzard EventTrace reference chain

If Blizzard UI source is available, EventTrace is a useful reference implementation. In the Classic UI source, the relevant files are typically:

- `Blizzard_EventTrace/Blizzard_EventTrace.xml`
- `Blizzard_EventTrace/Blizzard_EventTrace.lua`
- `Blizzard_SharedXML/Classic_SharedUIPanelTemplates.xml`
- `Blizzard_SharedXML/Classic_SharedUIPanelTemplates.lua`
- `Blizzard_SharedXML/ToolWindowOwnerMixin.lua`

The chain is:

1. `EventTrace` is declared as a movable/resizable frame.
2. Its `TitleBar` inherits `PanelDragBarTemplate`.
3. `PanelDragBarTemplate` maps XML `OnDragStart` / `OnDragStop` to `PanelDragBarMixin` methods.
4. `PanelDragBarMixin:OnLoad()` calls `RegisterForDrag("LeftButton")`.
5. `EventTracePanelMixin:OnLoad()` calls `self.TitleBar:Init(self)` so the titlebar moves the EventTrace panel/window.
6. On drag start, the shared mixin calls `StartMoving()` and `SetCursor("UI_MOVE_CURSOR")`.
7. On drag stop, it calls `StopMovingOrSizing()` and `SetCursor(nil)`.

EventTrace has one extra wrinkle: when shown, it moves itself into a native/simple window via `ToolWindowOwnerMixin:MoveToNewWindow(...)`. That mixin installs callbacks similar to:

```lua
self.onDragStartCallback = function()
    window:StartMoving()
    return false
end

self.onDragStopCallback = function()
    window:StopMovingOrSizing()
    return false
end
```

Returning `false` tells the shared drag mixin not to also call `target:StartMoving()` / `target:StopMovingOrSizing()`. Movement is delegated to the native `window` instead. The drag activation still comes from the titlebar's `RegisterForDrag("LeftButton")` and drag scripts.

## Gotchas and checklist

Before implementing or debugging draggable Questie UI, check:

- The drag hit area has `EnableMouse(true)` when created/configured in Lua.
- The drag hit area calls `RegisterForDrag("LeftButton")`.
- The drag hit area has `OnDragStart` and `OnDragStop` scripts.
- The moved target has `SetMovable(true)` or XML `movable="true"`.
- `OnDragStart` calls `StartMoving()` on the intended target, not accidentally on the header.
- `OnDragStop` calls `StopMovingOrSizing()` on the same target.
- Cursor state is reset with `SetCursor(nil)` on stop and hide/interruption paths.
- Existing scripts are preserved or hooked when needed; do not silently overwrite important handlers.
- Position persistence is handled after drag stop if the UI should remember its location.
- Combat lockdown or protected-frame restrictions may affect secure/protected frames. Avoid making protected frames movable unless that is already part of the design.

## Minimal same-frame drag example

Use this only when the entire frame should be draggable:

```lua
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    self:StartMoving()

    if SetCursor then
        SetCursor("UI_MOVE_CURSOR")
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    if SetCursor then
        SetCursor(nil)
    end
end)

frame:HookScript("OnHide", function(self)
    self:StopMovingOrSizing()

    if SetCursor then
        SetCursor(nil)
    end
end)
```
