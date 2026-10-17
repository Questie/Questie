# LibPopupStack-1.0

A positioning-only LibStub library. It does not create dialogs or know their definitions, text, callbacks, controls, or layout implementation.

```lua
local stack = LibStub("LibPopupStack-1.0")
stack:Register(myFrame)      -- after showing an addon-owned, unprotected frame
stack:RequestLayout()        -- after its dimensions change
stack:Unregister(myFrame)    -- when dismissing it
```

Registration is idempotent and preserves order. Unregistering and registering again appends to the stack. A single unnamed driver coalesces requests until the next frame and polls visible registrations every 0.1 seconds. Hidden registrations are removed; register again when showing them. The driver stops when no registrations remain.

The library observes Blizzard's shown-popup iterator (with an older-client fallback), converts frame sizes to common coordinates, and positions the registered stack below, above, or beside those bounds. It never modifies Blizzard frames or anchors owned frames to them. Insufficient space uses a deterministic visible fallback; oversized dialogs are not guaranteed to fit.

Frames must be owned by the caller and unprotected. The library rejects protected registrations when the native query is available, but cannot independently identify arbitrary frames' creators. Registered frames delegate their anchors to this coordinator and must not run competing positioning loops. Unreadable, secret, or forbidden geometry suspends placement instead of using partial bounds.

Compatible LibStub upgrades preserve registrations, anchor cache, and the existing driver. Private dialog implementations can change independently; keep this three-method positioning contract compatible or use a new major library name.

Tests use real LibStub with native-frame stand-ins. Native taint and combat enforcement still require in-client validation.
