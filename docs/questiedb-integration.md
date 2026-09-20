# QuestieDB integration

Questie uses the QuestieDB addon as its only entity database. This guide describes the consumer
boundary, the code paths that depend on it, and how to validate changes. Historical branch work,
measurements, and migration findings live in [the cutover history](tdb-history.md).

## Ownership

The addon named **QuestieDB** exposes `LibQuestieDB`. The module named **QuestieDB** inside this
repository is Questie's consumer interface, not a second database backend.

| Owner | Responsibilities |
| --- | --- |
| QuestieDB addon | Quest, NPC, Item, and Object facts; provider corrections; entity localization; Objective Order; support payloads; composed reads and name indexes. |
| Questie's `QuestieDB` module | Rich entity projections, semantic caches, pointer bindings, and consumer refresh after corrections. |
| Questie runtime modules | Player-state and availability rules, blacklists, quest tags, support-data calculations, and overrides selected from Questie settings or runtime state. |
| Questie's `l10n` module | UI strings and compatibility with external translation addons. Entity names are read from the provider. |

There is no local entity compiler, compiler fallback, or dual backend. Provider-owned raw entity
and support payloads are not retained in this repository. The decisions and rejected alternatives
are recorded in [ADR 0001](adr/0001-questietdb-is-the-only-entity-database.md),
[ADR 0002](adr/0002-questie-policy-corrections.md), and
[ADR 0003](adr/0003-external-locale-addons-through-provider-corrections.md).

## Initialization and compatibility

Each flavor TOC declares `RequiredDeps: QuestieDB` and `X-QuestieDB-Contract: 2`. Build preflight
checks that contract declarations are valid and consistent. At runtime,
[`VersionCheckDB.Check`](../Modules/VersionCheckDB.lua) reads the active TOC's requirement.

The relevant ordering in [`QuestieInit`](../Modules/QuestieInit.lua) is:

```text
TOC file loading
  -> bind provider APIs, metadata, Objective Order, and static support references
ADDON_LOADED
  -> run migrations, initialize and validate Zones and Quest XP
Login Stage 1
  -> select UI locale, check provider contract and localization-correction capability
  -> forward entity locale and publish external entity translations
  -> initialize Questie policy, validate faction templates, bind composed ID maps
  -> build Townsfolk, then initialize calendar events
Login Stage 2
  -> warm the provider Object name index after locale and policy setup
Login Stage 3
  -> initialize and validate drop tables before completing quest/UI initialization
  -> advertise Questie readiness only after initialization succeeds
```

The Stage 1 check gates login work, **not earlier TOC-file bindings**. A provider that lacks an
API used during file loading can still fail before the compatibility message. Moving that gate
earlier is unfinished work in the [release-bundling plan](../PLAN-release-bundles.md).

Questie forwards the effective UI locale through `LibQuestieDB.l10n.SetLocale`. External entity
lookups are adapted into localization slots under owner `QuestieLocalesOverride`, rather than
ordinary entity corrections. Their format, replacement, withdrawal, and custom-locale behavior
are specified in [ADR 0003](adr/0003-external-locale-addons-through-provider-corrections.md).

## Questie-owned corrections

Use [`QuestieCorrections.SetCorrection`](../Database/Corrections/QuestieCorrections.lua) when
Questie-owned state must change a composed provider entity row. Rules that only decide whether
Questie displays an entity stay local. Do not copy provider-owned faction, class, race, expansion,
SoD, or Titan corrections into Questie.

| Slot | State owner | Input |
| --- | --- | --- |
| `Npc:DarkmoonFaire` | `QuestieEvent` | Calendar-selected location. |
| `Object:GatheringNodeDisplayPolicy` | `QuestieCorrections.Initialize` | Suppression of gathering-node spawns that Questie does not display. |
| `Quest:ContentPhasePolicy` | `QuestieCorrections.Initialize` and the TBC policy producer | Attunement prerequisites for the active Content Phase. Published from TBC onward, not on Era/SoD. |
| `Item:RuntimeItemRepair` | `QuestieLib` | Names loaded asynchronously from the client for missing objective Items. |

```text
State owner builds the slot's complete replacement rows
  -> QuestieCorrections.SetCorrection(datatype, name, rows)
  -> provider publishes under owner "Questie"
  -> Questie refreshes the union of the slot's previous and new entity IDs
```

Writes replace a named slot; they do not append rows. Passing `nil` withdraws it. Questie's wrapper
also treats an empty top-level table as withdrawal. This differs from an empty **field value**,
which can clear that field in a composed row. Withdrawal restores underlying provider values.
Keep the slot name consistent between writes and withdrawal; a typo addresses a different slot.
Within an owner, slots take effect in creation order; replacing a slot does not raise its priority.
Current Questie slots avoid overlapping fields. Check precedence explicitly before adding
another slot that writes the same field.

Refresh rebinds affected composed ID maps and evicts touched projections, not the entire Quest
cache. Other modules hold references to those projections, so unrelated identities must survive.

Missing-item repair preserves the previous client-name fallback and batches publication once per
frame. Uncached Items can still arrive across separate frames. Whether the fallback is still
needed with current provider data, and whether it should move into the provider, remain review
questions; do not remove it without evidence.

## Object-hover name resolution

QuestieDB owns name uniqueness and the reverse name index. Questie owns local tooltip registrations
in `QuestieTooltips.lookupByKey` and party registrations in `QuestieComms.data`, keyed by `o_<id>`.
There is no second Questie-owned Object-name index.

```text
Hovered name
  -> LibQuestieDB.Object.IdsByName(name), once
  -> provider-wide uniqueness selects the zone filter
  -> matching IDs with local or eligible party registrations
  -> spawn filtering, tooltip rendering, and duplicate-line removal
```

`IdsByName` returns all IDs with that exact composed name in ascending order, or nil for no match.
Treat the returned bucket as read-only. Provider
[ADR 0008](https://github.com/Questie/QuestieDB/blob/82a2d1088631c724ae8cebd936be221b7d92af41/docs/adr/0008-name-index.md)
defines this interface.

- A globally unique name uses zone filter `0`, even when the Object ID setting is disabled.
  Shared names use the player's area or its parent. Missing spawn data does not disprove a match.
- If Object IDs are enabled, the same bucket supplies the first ID and count. Counts above ten
  display as `10+` unless debug mode is enabled.
- `GetTooltip` rejects candidates with neither local nor eligible party data before reading spawns.
  Party-only entries can render, and party lines can remain after local registration is removed.
- Registrations use IDs, so a provider rename changes the hover name without re-registering the
  objective. For example, renaming an Object leaves its `o_<id>` quest registration intact.
- Lines shared by several same-name Objects are added once. Only nonempty tooltip results count
  toward the ten-Object cap; an empty result cannot hide a later candidate with visible lines.

Stage 2 warms `LibQuestieDB.Object.BuildNameIndex()`. Enabling Object IDs also warms it; disabling
that setting does not clear it. The provider owns invalidation after Object corrections, locale
changes, and explicit Object-cache invalidation. A later hover may rebuild an invalidated index
synchronously; Questie does not add a parallel cache or invalidation callback.

The relevant code and consumer tests are in
[`TooltipHandler`](../Modules/Tooltips/TooltipHandler.lua) and
[`Tooltip`](../Modules/Tooltips/Tooltip.lua), with adjacent `.test.lua` files. Provider tests and
conformance cases cover the provider's index behavior.

## Support data and retained caches

Zones, Quest XP, drop data, and faction templates come from `LibQuestieDB.Support.Get`. Questie
keeps the wrappers and calculations. Shared provider tables are read-only; decoded maps and
merged correction maps are consumer-owned. MoP deliberately uses MoP Wowhead drops and Cata
private-server drops.

[Runtime support-data validation](support-validation.md) describes the bounded controls, protected
decoding, initialization checkpoints, and failure reports. These checks are compatibility controls,
not a full provider-data audit or a replacement for the early contract gate.

Townsfolk rebuilds from composed reads on every login into module tables. Migration 39 removes
obsolete compiler state and the Townsfolk version marker; migration 40 removes the former persisted
Townsfolk tables. Cross-session caching needs a stable provider data revision before it can safely
be reintroduced.

## Tests and provider dependency

From the repository root, with Lua 5.1, Busted, bit32, LuaFileSystem, and luacheck installed:

```bash
busted -p ".test.lua" .
luacheck -q -- Database Localization Modules Public Questie.lua
lua cli/validate-loader-usage.lua
git diff --check

# Run the existing cases against the actual provider as well as the test double.
QUESTIE_DB_PATH=../QuestieDB busted test/QuestieDBMock.conformance.test.lua
```

The conformance suite loads a real provider checkout headlessly in Source mode. It compares the
same operations against that provider and Questie's double. With no explicit path, a missing
`../QuestieDB` produces a pending test; an explicitly configured missing `QUESTIE_DB_PATH` fails.

[The provider-conformance workflow](../.github/workflows/provider-conformance.yml) checks out
QuestieDB `master`, sets that path explicitly, and logs the resolved SHA. The job fails on test
errors; it is not currently an advisory job. Provider changes can alter the result for an unchanged
Questie revision. Branch-protection settings are managed separately from the workflow.

Conformance proves only the covered behavior. The double intentionally rejects some invalid
inputs more strictly and omits provider write-time normalization, encoding, and storage/cache
behavior. Its ownership is tracked in
[QuestieDB #22](https://github.com/Questie/QuestieDB/issues/22): move reusable test support and its
contract checks to the provider, while Questie retains its consumer tests and setup adapter.

`.types/QuestieDB/` contains copied provider LuaLS declarations, not runtime files. Refresh them
from the provider's `src/types/*.t.lua` when the consumed schema changes. The imported snapshot
was recorded at provider commit `fdf740d`; shared ID aliases on both sides are intentional.

## Planned release compatibility checks

This section is a proposal, **not coverage provided by the current master conformance job**.

| Target | Purpose | Intended merge policy |
| --- | --- | --- |
| Deliberately selected supported release | Prove compatibility with the provider users can install. | Required. |
| Provider `master` | Detect upcoming integration changes. | Advisory, with visible failures. |

Run both independently. Testing a release only when master fails misses consumer changes that
work exclusively with unreleased APIs. A failing release check must block compatibility approval
even if master passes; an advisory master failure must not be hidden in a successful log.

Select a published, non-prerelease reference deliberately and record the resolved SHA. A provider
is eligible only when `minSupportedContract <= required <= contractVersion`; that range is not
proof that every consumed API works. Update the declared requirement, selected CI target, and
vendored types together when requirements change. Do not silently drop an older supported baseline
by moving the test target.

Both jobs should run committed integration checks for entity reads, corrections, translation-slot
precedence/withdrawal, support-wrapper initialization, and contract/initialization ordering. In
particular, promote the offline support-wrapper checks to a committed entry point, covering all
flavors, both factions, and MoP's mixed drop sources. Missing providers or skipped intended
integration coverage must fail the required check.

Source-mode checks do not establish Baked artifact contents or generated localization. Add
released-artifact coverage where behavior depends on packaging, preserving intentional
Source/Baked differences. Report tested references and distinguish checkout failures from test
failures. Build/test jobs must not have publishing credentials or access live installations.

For a contract change, develop against the proposed provider revision, publish the supporting
provider release, then update the consumer's required target before merging. A temporary PR/commit
check does not replace released-provider validation. Distribution and release selection are covered
by the separate [release-bundling plan](../PLAN-release-bundles.md). The agreed
[release metadata structure](release-format.md) describes component ownership and bundling.

## Outstanding integration validation

These are unfinished checks, not guarantees established by the historical smoke runs:

- Reconcile provider-owned data changes from Questie master before merge. The last recorded sync
  covered Questie `215b0c757` via provider `be3e7f6`; verify later changes rather than assuming parity.
- Recheck provider issue evidence and acceptance, particularly
  [#13](https://github.com/Questie/QuestieDB/issues/13),
  [#14](https://github.com/Questie/QuestieDB/issues/14),
  [#15](https://github.com/Questie/QuestieDB/issues/15),
  [#17](https://github.com/Questie/QuestieDB/issues/17), and
  [#19](https://github.com/Questie/QuestieDB/issues/19). Recorded implementation evidence is in the
  [history](tdb-history.md#provider-handoff-evidence), not a claim that those issues are closed.
- Complete the early file-load compatibility gate and the release compatibility checks above.
- Complete the current Contract Version 2 live matrix below. Historical Contract Version 1 Era/SoD
  results do not satisfy it. Record both addon revisions, client build, flavor/season, locale, provider
  mode, and observations for each run. Coordinate client changes with the user; do not repoint a
  daily-driver installation without permission.

| Scenario | What to verify |
| --- | --- |
| Era and SoD | Fresh login, composed pointers/projections, gathering suppression, SoD provider ownership and required-race behavior. |
| TBC before and after phase 3 | Prerequisites for quests 10944 and 11007 match the active Content Phase. Re-publishing changed phase rows replaces the slot. Check Isle of Quel'Danas visibility separately. |
| WotLK and Titan season 109 | Provider-owned Titan corrections, no Questie Titan slot, and retained Titan quest tags. |
| Cata and MoP | Login, Townsfolk, tracker/map rendering, and the correct flavor TOC; MoP's mixed drop sources. |
| Darkmoon week and its end | Calendar-driven `Npc:DarkmoonFaire` publication and withdrawal, not only a manual producer probe. |
| Built-in non-English locale | Entity names, Object name lookup, and Special Objective text. |
| External locale addon | `QuestieLocalesOverride` translation provenance, replacement/withdrawal, and unchanged UI-string ownership. |

Across the matrix, check Available Quests, Objective Order, missing-item repair when encountered,
and correction replacement/withdrawal through normal UI flows. Accept or correct consumer handling
of the provider's raw coordinates; do not reintroduce legacy quantization without revisiting the
provider decision. Run a mock/provider conformance check alongside consumer tests, not just the fake.

Other recorded follow-ups:

- [QuestieDB #20](https://github.com/Questie/QuestieDB/issues/20) tracks the cost of recomposing a
  datatype for a small slot write. Re-measure on current code before changing repair batching.
- Confirm the current need and ownership of missing-item repair before removing or moving it.
- Surface provider Source/Baked mode in debug output; retain the support-validation report's mode.
- Pre-existing review notes: Isle of Quel'Danas profile/global setting disagreement, and shared-state
  leaks involving `Expansions.Current` and `C_Calendar` in the Event/QuestieLib test suites.

## Building standalone or bundled packages

`python3 build.py --standalone` (or `-s`) builds only Questie and makes no provider
download. QuestieDB remains a required dependency and must be installed separately.
Standalone is the default when neither mode is specified.
`python3 build.py --bundled` (or `-b`) includes QuestieDB.
Existing flavor switches and `--release` still apply.

Each mode writes one ZIP and a matching `release.json`. Standalone metadata contains
`releases` and `questie`; bundled metadata also copies the selected `questiedb` section
unchanged, including its upstream artifacts and extensions. There are no separate
build-result or provider metadata files. The bundled downloader requires QuestieDB's
wrapped manifest format; older flat manifests are not supported.

Use `python3 changelog.py --release-manifest releases/<build>/release.json`
to render the retained Questie changes first and database changes second, without Git
or network access. The publication workflow builds and uploads only the bundled ZIP
and its manifest. CF/Wago uploads remain disabled.
