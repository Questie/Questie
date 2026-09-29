# Private addon dialogs

A small Lua-only dialog for confirmations and copyable text. Each addon owns its implementation, definitions, callbacks, and anonymous frames. Only positioning is shared through `LibPopupStack-1.0`.

Load LibStub, `Libs/LibPopupStack-1.0/LibPopupStack-1.0.lua`, then `Libs/AddonDialog/Dialog.lua`. No widget XML or global mixin is required. WoW passes a private table to each addon file; the widget attaches its interface as `addon.Dialog`.

```lua
local _, addon = ...
local Dialog = addon.Dialog

Dialog.Dialogs["CONFIRM_ACTION"] = {
  text = "Continue with %s?",
  button1 = YES,
  button2 = NO,
  whileDead = true,
  hideOnEscape = true,
  OnAccept = function(dialog, data)
    data.confirm()
  end,
}

Dialog.Show("CONFIRM_ACTION", "this operation", nil, {
  confirm = function() --[[ perform the action ]] end,
})
```

## Interface

- `Show(key, arg1, arg2, data)`, `FindVisible(key)`, `Hide(key)`, `IsShown(key)`, `IsAnyDialogShown()`.
- One lazily created frame per definition; different purposes never share controls.
- Body text, optional warning icon (`showAlert`), and `button1`/`button2`.
- `OnShow(dialog, data)`, `OnAccept(dialog, data)`, and `OnCancel(dialog, data, reason)`.
- A truthy accept/cancel return keeps a clicked decision open. Programmatic Hide never invokes OnCancel. The most recently shown eligible decision in this addon consumes the game-menu binding (Escape by default).
- Showing the same key replaces its current instance. Cancellation receives `"override"` unless `noCancelOnReuse` is true. Data and `Text.text_arg1`/`text_arg2` are set before OnShow.
- `hasEditBox`, `editBoxWidth`, `EditBoxOnEnterPressed(editBox)`, and `EditBoxOnEscapePressed(editBox)`. Set content, focus, and selection in OnShow. Without custom handlers, Enter hides and Escape follows `hideOnEscape`.
- `whileDead` and `hideOnEscape` retain their familiar meanings.
- Frames expose `Text`, `EditBox`, `Button1`, `Button2`, `GetEditBox()`, `GetEditBoxText()`, `GetButton1()`, and `GetButton2()`. They are anonymous: use these references, not `_G[frame:GetName() .. "EditBox"]`.

Closed dialogs release their data and input text. Reopening the same key increments `generation`; external delayed callbacks must check that generation and visibility before touching the frame. Arbitrary custom hooks remain the caller's responsibility. Callback error details are withheld because they may contain private data.

## Layout and ownership

Each addon rechecks its visible dialogs after the first frame and every 0.1 seconds. It updates geometry only when text/button/input measurements change, then requests positioning from the shared coordinator. Font settling and scale changes therefore update border and controls together.

The coordinator stores frame references and registration order, not definitions, text, callbacks, or layout methods. It reads dimensions and Blizzard's visible popup bounds and positions only explicitly registered addon-owned frames relative to UIParent. One coordinator prevents two addons' independent avoidance loops from chasing each other.

LibStub selects the coordinator implementation. Compatible upgrades preserve registered frames and its single driver. Dialog code is not version-selected globally: updating one addon's widget cannot replace the other addon's implementation or templates. Either addon works independently when the other is absent.

No frame pools, queues, timed decisions, dropdowns, progress bars, modal covers, or extra actions are implemented. The same Blizzard visual assets/fonts are reused without registering dialogs with Blizzard's popup manager.

## Validation

```bash
busted -p '.test.lua' .
lua cli/validate-loader-usage.lua
luacheck -q Modules/Libs/QuestiePopup.lua Modules/Libs/QuestiePopup.test.lua
```

Questie's lint configuration excludes vendored libraries. Validate the private widget and shared coordinator explicitly when modifying them.

Tests construct the actual Lua hierarchy using native-control stand-ins. They cover independent addon namespaces sharing a stack, late layout changes, input, consumer behavior, geometry, and coordinator upgrades. Native rendering, input, combat, and taint behavior still require client validation. Use disposable data for destructive consumer actions.
