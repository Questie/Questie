# AddonDialog

A small addon-owned dialog for confirmations and copyable text. It keeps the original popup appearance and avoids Blizzard's shown dialogs without joining their popup manager.

Load `Dialog.lua`, `PopupPosition.lua`, then `Dialog.xml`. The module has no addon-core, persistence, or localization dependencies. Callers provide translated strings and actions.

```lua
AddonDialog.Dialogs["MY_ADDON_CONFIRM"] = {
  text = "Continue with %s?",
  button1 = YES,
  button2 = NO,
  whileDead = true,
  hideOnEscape = true,
  OnAccept = function(dialog, data)
    data.confirm()
  end,
}

AddonDialog.Show("MY_ADDON_CONFIRM", "this operation", nil, {
  confirm = function() --[[ perform the action ]] end,
})
```

## Supported behavior

- One lazily created frame per definition. Different purposes never share controls.
- `Show(key, arg1, arg2, data)`, `FindVisible(key)`, `Hide(key)`, `IsShown(key)`, `IsAnyDialogShown()`.
- Body text, optional warning icon (`showAlert`), and `button1`/`button2`.
- `OnShow(dialog, data)`, `OnAccept(dialog, data)`, and `OnCancel(dialog, data, reason)`.
- A truthy accept/cancel return keeps a clicked decision open. Programmatic Hide never invokes OnCancel. Escape closes the most recently shown eligible dialog, with cancellation reason `"clicked"`.
- Showing the same key replaces its current instance. Cancellation receives `"override"` unless `noCancelOnReuse` is true. Data and formatting arguments are available before OnShow, including `Text.text_arg1`/`text_arg2`.
- `hasEditBox`, `editBoxWidth`, `EditBoxOnEnterPressed(editBox)`, and `EditBoxOnEscapePressed(editBox)`. Use OnShow to set text, focus, and selection. Without custom handlers, Enter hides and Escape follows `hideOnEscape`.
- `whileDead` and `hideOnEscape` retain their familiar meanings.
- The frame exposes `Text`, `EditBox`, `Button1`, `Button2`, `GetEditBox()`, `GetEditBoxText()`, `GetButton1()`, and `GetButton2()`.

Closed dialogs release their data and input text. Reopening the same key increments `generation`; external delayed callbacks must check the captured generation and current visibility before touching that frame. Arbitrary custom hooks are the caller's responsibility. Callback error messages are withheld because they may contain private data.

## Placement and ownership

One throttled driver checks every 0.1 seconds while dialogs are shown. It reads Blizzard's official popup iterator (or four normal frames on older clients), then moves only owned frames relative to UIParent. It handles different scales, unavailable/secret geometry, and below/above/side placement. When no space fits, it keeps choices visible rather than silently hiding them.

The widget does not register with Blizzard's popup, focus, or Escape managers. Identical embedded copies share the `AddonDialog` namespace. All consumers of this slim widget share definitions and positioning. Its globals/templates are distinct from the older full `AddonPopup` implementation, so an older embedded copy cannot overwrite it.

There are no queues, frame pools, timers, progress controls, dropdowns, modal covers, extra buttons, or broad StaticPopup compatibility layer. Unlisted definition fields are not supported. Font/display changes may require reopening a dialog for relayout.

## Validation

```bash
busted -p '.test.lua' .
lua cli/validate-loader-usage.lua
luacheck -q Modules/Libs/QuestiePopup.lua Modules/Libs/QuestiePopup.test.lua
```

Questie's lint configuration excludes vendored libraries. Keep production Lua/XML byte-identical to the source widget; its lint runs there. These tests include the vendored widget and the Questie consumer integration.

Tests run the actual dialog and consent code against native-control stand-ins. In-client checks still cover XML loading, rendering/focus, combat behavior, coexistence, and the original Edit Mode taint reproduction. Use disposable data when testing destructive consumer actions.
