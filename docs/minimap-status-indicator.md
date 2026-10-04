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

`message` and optional `action` are English localization keys. `args` is an optional array of strings or numbers for the message format. Optional `details` is an ordered array of `{message = "...", args = {...}}` records. Details appear as indented, wrapped lines between the main message and action, and are also localized on hover. Actions are explanatory text, not clickable callbacks. Add new keys through the usual localization files.

| Severity | Value | Meaning |
| --- | --- | --- |
| `Severity.Error` | 1 | Blocking failure or unavailable essential functionality |
| `Severity.Warning` | 2 | Known limitation while core functionality still works |
| `Severity.Info` | 3 | Context without a malfunction |

`Set(id, issue)` replaces that ID while retaining its activation position. `Clear(id)` removes only that ID; unknown IDs are a no-op. Clearing and re-adding gives the notice a new position. Notices can be recorded before settings, databases, or UI are ready.

`GetIssues()` returns snapshots sorted by ascending severity value, then activation order. `GetBadgeIssue()` returns the winning snapshot or `nil`: the lowest severity value wins. Within that severity, a notice without an icon override wins over custom icons; otherwise the earliest active notice wins.

The registry owns private, in-memory state. Inputs and returned snapshots copy the issue fields, argument array, detail records and their arguments, and icon descriptor, so caller mutations do not change stored notices.

### Custom icons

An optional `icon = {atlas = "...", texture = "..."}` overrides the severity image. Either field may be omitted; `texture` accepts a path or numeric file ID. The renderer tries an available atlas first, then the supplied texture, then the severity default if the custom image cannot be loaded.

The Source-mode notice uses Questie's bundled green plus. `Icons/green_plus.png` is a transparent, user-supplied crop from Blizzard's [ObjectIconsAtlas sheet](https://static.wikia.nocookie.net/wowpedia/images/4/4a/ObjectIconsAtlas.png), resized from 20 x 20 to 32 x 32 with nearest-neighbor sampling:

```lua
local QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")

QuestieStatus.Set("questiedb.source-mode", {
    severity = QuestieStatus.Severity.Info,
    message = "QuestieDB is running in Source mode.",
    icon = {texture = "Interface\\AddOns\\Questie\\Icons\\green_plus.png"},
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

[QuestieInit](../Modules/QuestieInit.lua) calls [SourceModeStatus.Update](../Modules/SourceModeStatus.lua) before creating the minimap UI. Source mode produces two informational notices with the same custom green-plus icon:

- `questiedb.source-mode`: client version/build/date, interface version, raw project constant name and ID, Questie's content expansion name and ID, season name/ID/active state, region name/ID, client locale, and all flags set by `VersionCheck`.
- `questiedb.source-load`: provider addon version, selected data expansion from `ModeIndicator.GetStatus()`, read mode, supported contract range, and the contract required by Questie's active TOC.

For example, Forever can report `WOW_PROJECT_MAINLINE (1)` alongside Questie expansion `Era (1)` and provider data expansion `Forever`. These are separate namespaces, not conflicting answers. Unknown numeric IDs remain visible as `unknown (ID)`; absent values read `unavailable`. Diagnostic identifiers and boolean values remain technical strings while row labels are localized. Values are gold, `true` is green, `false` is muted red, and unavailable values are grey. Flag entries use `IsForever: true` rather than equals signs. Source diagnostics use `%s` placeholders so value-only color markup survives localization without changing the labels' grey styling. This reports existing detection results rather than calculating replacement flags.

The details are startup snapshots, not live polling. Provider metadata describes the selected Source configuration, not successful materialization of every entity table. Reporting makes no entity queries and does not infer load durations or a Git revision. An absent optional provider diagnostics API yields unavailable fields. Failures collecting client or provider details become informational diagnostic-error lines, leaving the other block available and allowing the minimap UI and real compatibility checks to run. A failure in the optional provider status getter alone preserves the other provider metadata. Outside Source mode, both owned notices are cleared without affecting failures from other producers.

Questie hides the provider's `ModeIndicator` banner only after `MinimapIcon:Init()` returns `true`, meaning the badge was installed and its initial render succeeded. Missing UI or a missing `ModeIndicator.Hide` leaves the provider fallback in place. Successful installation still respects hidden and mouseover-only preferences; hiding the icon does not restore the banner.

Known provider contract, localization-correction, asynchronous object-indexing, and support-validation failures record an error. Errors from either startup coroutine (AddonLoaded or login stages) also record an error. The first failure latches startup stopped, cancels both startup tickers when present, resets `Questie.started` and API readiness, and preserves existing once-only chat diagnostics. Reports pass through `tostring`, including `error(nil)`, so the tooltip formatter retains its argument.

Startup failures require a reload; clearing a notice alone does not restart initialization. This is not rollback: side effects already performed remain. It is not a universal catch either. Synchronous errors before or during unwrapped startup work, including TOC loading and AceDB setup, do not all produce a badge. Questie cannot display a badge if it never loads or the UI cannot be created.

## Remaining validation

A live startup check on Forever build 70205 confirmed the Source-mode notice. Temporarily requiring contract 4 against provider contract 3 then stopped startup, selected the error notice over Source mode, and showed the `common-icon-redx` overlay. The client reported no unexpected Lua errors and one expected startup error in chat. The TOC requirement was restored immediately; another reload recovers. The green-plus replacement has not yet been checked live. The read-only probes below establish the original library layers and atlas availability.

The diagnostics extension passed 2,184 consumer tests against an isolated contract-3 provider snapshot, full lint, loader validation, and focused review. Its expanded tooltip has not been checked live; verify height and wrapping, especially the detection-flag lines.

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

## Built-in S asset search

No literal gold/white **S** asset was verified. The shop-button lead produced these exact candidates, not a confirmed match:

| Candidate | Source evidence and limits |
| --- | --- |
| `UI-HUD-MicroMenu-Shop-Up` (atlas) | Forever 70205 constructs this name for `StoreMicroButton`; `-Down`, `-Disabled`, and `-Mouseover` are sibling states. Camelot includes the store button, gated by `Enum.GameRule.StoreDisabled`. Source establishes its shop role, not whether its pixels depict S, $, or another logo. Preview still needed. |
| `Interface\Buttons\UI-MicroButton-BStore-Up` (texture) | Era 70003's Classic micro-menu uses this path, cropping UVs to `(0, 1, 0.359375, 1)`. A historical texture preview shows a gold **W in a circle**, not S or $. Current-client pixels/availability are unverified. |
| `store-icon-wowstore-small` (XML texture template, **not an established atlas**) | Era 70003 defines a 21 x 20 crop of `Interface\Store\Store-Main`, UVs `(0.97460938, 0.99511719, 0.27148438, 0.29101563)`. The same crop in the historical preview is a gold **W in a circle**, not S or $. Using the full sheet as the badge would be incorrect. |

Source/load-path references:

- Forever: [atlas-name construction](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_MicroMenu/Mainline/MainMenuBarMicroButtons.lua#L32-L38), [Shop selection](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_MicroMenu/Mainline/MainMenuBarMicroButtons.lua#L1824-L1835), [TOC](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_MicroMenu/Blizzard_MicroMenu.toc#L4-L18), [Camelot button list](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_MicroMenu/Camelot/MicroMenuContainerOverrides.lua#L2-L18).
- Era: [BStore selection](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_MicroMenu/Classic/MainMenuBarMicroButtons.lua#L903-L919), [path/crop construction](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_MicroMenu/Classic/MainMenuBarMicroButtons.lua#L22-L38), [micro-menu TOC](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_MicroMenu/Blizzard_MicroMenu_Classic.toc#L1-L10), [store crop](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_StoreUI/Classic/Blizzard_StoreUIPatchwerk.xml#L63-L66), [store TOC](https://github.com/Gethe/wow-ui-source/blob/8165d4cd6e48d606369336cc3a7977902310e81e/Interface/AddOns/Blizzard_StoreUI/Blizzard_StoreUI.toc#L8-L15).

Visual evidence is from Gethe's converted Blizzard textures at `d23deaf8f44a7d280dc974a5c9d5321c013db59b`, **Retail 9.2.7 (45114), not either target build**: [BStore image](https://github.com/Gethe/wow-ui-textures/blob/d23deaf8f44a7d280dc974a5c9d5321c013db59b/Buttons/UI-MicroButton-BStore-Up.PNG), [Store-Main image](https://github.com/Gethe/wow-ui-textures/blob/d23deaf8f44a7d280dc974a5c9d5321c013db59b/Store/Store-Main.PNG), [conversion provenance](https://github.com/Gethe/wow-ui-textures/blob/d23deaf8f44a7d280dc974a5c9d5321c013db59b/README.md). It rules out those historical images as literal S artwork, not future replacements.

Suggested read-only follow-up: call `C_Texture.GetAtlasInfo("UI-HUD-MicroMenu-Shop-Up")` and the three sibling states. A non-nil result establishes atlas availability and gives its file ID/UVs, **not its appearance**. No file IDs were inferred, no live calls were made, and no UI was created during this search. The supplied cached source revisions were rechecked, not refreshed. If preview does not identify the remembered S, a gold/white FontString `S` is an unambiguous fallback, but needs renderer support rather than an invented atlas name.
