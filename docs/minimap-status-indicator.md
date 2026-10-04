# Minimap status indicator

Questie displays active notices as a badge on its native minimap button and as text in its shared tooltip. The base Questie icon remains unchanged. No badge means no recorded issues, not necessarily that startup has finished.

## Recording notices

Use [QuestieStatus](../Modules/QuestieStatus.lua) with a stable producer-owned ID. Producers explicitly set and clear their own notices; there is no persistence, automatic `Questie.Error()` capture, or global error hook.

```lua
local QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")

QuestieStatus.Set("example.startup", {
    severity = QuestieStatus.Severity.Error,
    message = "Questie could not start: %s",
    args = {"Example failure"},
    action = "Update Questie and QuestieDB, then reload the UI.",
})
QuestieStatus.Clear("example.startup")
```

`message` and optional `action` are English localization keys. `args` is an optional array of strings or numbers for the message format. Actions are explanatory text, not clickable callbacks. Add new keys through the usual localization files.

| Severity | Value | Meaning |
| --- | --- | --- |
| `Severity.Error` | 1 | Blocking failure or unavailable essential functionality |
| `Severity.Warning` | 2 | Known limitation while core functionality still works |
| `Severity.Info` | 3 | Context without a malfunction |

`Set(id, issue)` replaces that ID while retaining its activation position. `Clear(id)` removes only that ID; unknown IDs are a no-op. Clearing and re-adding gives the notice a new position. Notices can be recorded before settings, databases, or UI are ready.

`GetIssues()` returns snapshots sorted by ascending severity value, then activation order. `GetBadgeIssue()` returns the winning snapshot or `nil`: the lowest severity value wins. Within that severity, a notice without an icon override wins over custom icons; otherwise the earliest active notice wins.

The registry owns private, in-memory state. Inputs and returned snapshots copy the issue fields, argument array, and icon descriptor, so caller mutations do not change stored notices.

### Custom icons

An optional `icon = {atlas = "...", texture = "..."}` overrides the severity image. Either field may be omitted; `texture` accepts a path or numeric file ID. The renderer tries an available atlas first, then the supplied texture, then the severity default if the custom image cannot be loaded.

The Source-mode notice uses QuestieDB's own PNG:

```lua
local QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")

QuestieStatus.Set("questiedb.source-mode", {
    severity = QuestieStatus.Severity.Info,
    message = "QuestieDB is running in Source mode.",
    icon = {texture = "Interface\\AddOns\\QuestieDB\\icons\\QuestieTDB_64x64.png"},
})
```

### UI observer

`SetOnChange(callback)` replaces the single UI observer and immediately replays current state, including empty state. The synchronous, non-yielding callback reads snapshots through the getters. Passing `nil` detaches it. The return value is a boolean indicating whether replay succeeded (or detachment succeeded).

Observer calls are protected with `xpcall` and native error reporting. An observer failure retains both recorded state and the observer. `Set` and `Clear` do not return that success value. Producers should not replace the observer installed by the minimap UI.

## Display and visibility

[MinimapIcon](../Modules/MinimapIcon.lua) owns rendering, including its file-local `_AddStatusLines`; the registry has no `AddLines` method. The badge is a 10-by-10 texture on the native LibDBIcon button, at `OVERLAY` sublevel 1, anchored `TOPRIGHT` with offsets `-1, -1`.

| Severity | Default image |
| --- | --- |
| Error | `common-icon-redx` atlas, falling back to `Interface\RaidFrame\ReadyCheck-NotReady` |
| Warning | `Interface\DialogFrame\UI-Dialog-Icon-AlertNew` |
| Information | `Interface\FriendsFrame\InformationIcon` |

Status changes update the badge immediately. The tooltip localizes and formats all notices on hover, in severity and activation order. An already-open tooltip refreshes on the next hover, not on registry changes. Click controls and their tooltip instructions are unavailable while `Questie.started` is false.

The texture follows the button's movement, scale, visibility, and mouseover-only alpha. Questie does not force a hidden minimap button visible. A hidden button therefore also hides the notice.

There is no broker badge-rendering pipeline: the LDB `icon` stays unchanged. Supporting broker displays receive status text through the shared `OnTooltipShow`, but neither other brokers nor the addon compartment inherit the native minimap badge.

## Source mode and startup failures

[QuestieInit](../Modules/QuestieInit.lua) records Source mode as information, not a failure. It hides QuestieDB's `ModeIndicator` banner only after `MinimapIcon:Init()` returns `true`, meaning the badge was installed and its initial render succeeded. Missing UI or a missing `ModeIndicator.Hide` leaves the provider fallback in place. Successful installation still respects hidden and mouseover-only preferences; hiding the icon does not restore the banner.

Known provider contract, localization-correction, asynchronous object-indexing, and support-validation failures record an error. Errors from either startup coroutine (AddonLoaded or login stages) also record an error. The first failure latches startup stopped, cancels both startup tickers when present, resets `Questie.started` and API readiness, and preserves existing once-only chat diagnostics. Reports pass through `tostring`, including `error(nil)`, so the tooltip formatter retains its argument.

Startup failures require a reload; clearing a notice alone does not restart initialization. This is not rollback: side effects already performed remain. It is not a universal catch either. Synchronous errors before or during unwrapped startup work, including TOC loading and AceDB setup, do not all produce a badge. Questie cannot display a badge if it never loads or the UI cannot be created.

## Remaining validation

The read-only probes below establish existing library layers and atlas availability, not feature rendering. The latest bridge marker was missing, so there was no live feature validation. No new badge has been deployed or rendered anywhere.

Visually check badge legibility and hover layering, dragging, minimap/UI scale, hidden and mouseover-only settings, and transitions between error, warning, information, and no notices. Check ordinary addon updates during combat and tooltip behavior on supporting brokers. Skin compatibility and behavior across all Questie clients remain unverified.

## Sources and limits

Research performed against:

| Source | Revision |
| --- | --- |
| Questie's vendored LibDBIcon-1.0, minor 55, and LibDataBroker-1.1, minor 4 | Questie `3ddc29cfbb55388f5badf06f1b317926009f2c80`, the pre-implementation research snapshot |
| Gethe `classic_era` | `8165d4cd6e48d606369336cc3a7977902310e81e`, `1.15.9 (70003)` |
| Gethe `forever` | `e3ecc27b64d30fdc735a3f6579b866858f9f9df1`, `1.60.1 (70205)` |
| LibDataBroker's author-maintained wiki | Git revision `4f47157d62915ebc1044a67a91509f096e8c4a98`, `Data-Specifications.textile` |

Both Gethe branches refreshed successfully and their revisions were rechecked before writing. Forever's source build matches the live client probe below. Era's current runtime build was not established. Blizzard source proves the published Lua/XML usage and declarations, not arbitrary skin compatibility or combat safety.

### Read-only live probe

The running Forever client reports `1.60.1`, build `70205`, interface `16001`, with LibDBIcon minor `55`. Its Questie minimap button is shown and reports `IsProtected() == false` outside combat. `CreateTexture` and `GetRegions` are available. Existing texture regions are:

| Purpose | Draw layer | Sublevel |
| --- | --- | --- |
| Highlight | `HIGHLIGHT` | 0 |
| Border | `OVERLAY` | 0 |
| Background | `BACKGROUND` | 0 |
| Questie icon | `ARTWORK` | 0 |

These values came from `LibStub:GetLibrary("LibDBIcon-1.0")`, `GetMinimapButton("Questie")`, and the returned button/region getters. No textures, scripts, settings, or installation links were changed. This confirms the loaded library and existing layers, not a rendered badge or combat behavior.

## Library layering evidence

LibDBIcon already layers multiple textures on the same button: a background, an `ARTWORK` icon, an `OVERLAY` border, and a button highlight. The button is a normal `Button` parented to `Minimap`; its frame strata and level are fixed by the library. Its public getter returns that button. See [button construction](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L251-L333) and [the getter](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L465-L467).

The texture inherits the button's [positioning](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L158-L174), [visibility](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L409-L444), and [mouseover-only alpha](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L450-L463). It adds no click target or replacement input scripts. The display owns tooltip positioning and visibility, as described by the [LDB tooltip specification](https://github.com/tekkub/libdatabroker-1-1/wiki/Data-Specifications#ontooltipshowtooltip) and [LibDBIcon hover paths](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L69-L119).

## Classic Era and Forever evidence

- **Classic Era:** `Blizzard_Minimap_Classic.toc` explicitly includes `Classic/Minimap.xml` for the supported Classic game types. That XML layers `ARTWORK` and `OVERLAY` textures within the minimap hierarchy. Its generated API declares `CreateTexture(name, drawLayer, templateName, subLevel)` and `SetDrawLayer(layer, sublevel)`. Sources: [TOC](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_Minimap/Blizzard_Minimap_Classic.toc#L1-L24), [concrete layering](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_Minimap/Classic/Minimap.xml#L209-L240), [CreateTexture](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFrameAPIDocumentation.lua#L112-L129), [SetDrawLayer](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleRegionAPIDocumentation.lua#L138-L147).
- **Forever:** its minimap TOC selects `[Game]/Diel.lua` for `camelot`. That concrete implementation creates a `BACKGROUND` texture at sublevel 0 and an `OVERLAY` border at sublevel 1 on the same frame. The generated API also declares the four `CreateTexture` arguments. Sources: [TOC](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_Minimap/Blizzard_Minimap.toc#L7-L19), [Diel layering](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_Minimap/Camelot/Diel.lua#L18-L45), [CreateTexture](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFrameAPIDocumentation.lua#L131-L147).

This supports the texture primitive on those two source builds. It is not a live test across all Questie clients. In particular, do not change the minimap button's parent, strata, or protected attributes to obtain a badge. Inspect the actual loaded library/button and test ordinary addon updates in combat before making a combat-safety claim.

## Broker and addon-compartment limits

LibDataBroker supplies data and attribute-change callbacks, not a renderer. The [author's data specification](https://github.com/tekkub/libdatabroker-1-1/wiki/Data-Specifications) describes one `icon` texture and optional color/coordinate extensions, not a standard stack of icon textures. It also warns that displays need not support every optional field. Questie's vendored [attribute forwarding](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua#L21-L31) can transport a custom field, but that alone does not make displays render it.

LibDBIcon specifically watches `icon`, `iconCoords`, and RGB fields. An invented `iconOverlay` attribute would therefore do nothing in this library without additional consumer code. Its [`IconCallback`](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L24-L57) sets the minimap texture and updates a registered compartment entry when the icon changes.

The addon compartment is a **different UI**, not the minimap button returned by `GetMinimapButton`. LibDBIcon registers a record containing one icon and hover/click callbacks. Forever's compartment constructs a separate 16-by-16 texture for each menu entry. Sources: [LibDBIcon registration](https://github.com/Questie/Questie/blob/3ddc29cfbb55388f5badf06f1b317926009f2c80/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua#L501-L528), [compartment rendering and accepted fields](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_Minimap/Mainline/AddonCompartment.lua#L31-L62), [registration contract](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_Minimap/Mainline/AddonCompartment.lua#L126-L139). Actual compartment availability remains client-dependent.

## Built-in cross assets

A read-only atlas lookup on Forever `1.60.1 (70205)` confirmed two existing candidates:

| Atlas | Declared size | Texture FileDataID |
| --- | --- | --- |
| `common-icon-redx` | 25 x 25 | 3487944 |
| `UI-LFG-DeclineMark` | 40 x 40 | 5171843 |

The live `READY_CHECK_NOT_READY_TEXTURE` value is `UI-LFG-DeclineMark`. Classic Era's ready-check implementation also declares that atlas and the legacy texture path `Interface\\RaidFrame\\ReadyCheck-NotReady`: [declarations](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_ReadyCheck/Classic/ReadyCheck.lua#L1-L15), [load path](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_ReadyCheck/Blizzard_ReadyCheck_Classic.toc#L1-L9). Forever's character-creation UI uses `common-icon-redx` as a normal/highlight texture: [XML](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_CharacterCreate/Camelot/Blizzard_CharacterCreate.xml#L653-L654), [Camelot load selection](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_CharacterCreate/Blizzard_CharacterCreate.toc#L1-L11).

Prefer a built-in red cross over recoloring an unrelated gold asset. The atlas lookup confirms availability on the running Forever client; badge-size legibility and other clients still need visual/runtime checks. No texture was created or changed for these probes.
