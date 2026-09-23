# SavedVariables timing investigation

## Outcome

**A minimal cold-start restoration failure is now reproduced outside Questie and AceDB on build `69913`.** A single probe waited two seconds after entering the world before its first SavedVariables access. Its disk file contained count 4 and the expected marker, but the new client saw nil and started at 1. No other third-party addon was loaded before that read.

This isolates the observed failure below Questie's database initialization. It does not identify the exact native client or environment defect. Reload-based tests succeeding did not establish cold-start persistence, and the deferred Questie startup prototype is not a demonstrated fix.

In the initial reload-only matrix, early reads, nested reads, table mutation, root replacement, scalar writes, and AceDB initialization persisted when performed after the variable's restoration point. Delaying initialization until login was not necessary for those reload-based probes.

One reproducible failure looked like lost persistence but was ordinary load ordering: with `LoadSavedVariablesFirst: 0`, file-level writes were overwritten when the previous saved data loaded. The final runtime values were then saved correctly.

This does not disprove the Discord report for another build, a full client restart, or a more specific access pattern. Do not move Questie's entire initialization lifecycle based on this result alone.

## Follow-up: Questie's real database still fails to restore

After the isolated tests, a Tauren character login displayed both the migration-reset notice and the full nine-step database compilation. Account-wide SavedVariables and its backup were preserved before further testing. They contained a valid compiled cache and migration version 38, and both parsed successfully with Lua 5.1.

A Forever-only deferral prototype was tested and subsequently removed. It:

- Registered startup events without initializing AceDB on `ADDON_LOADED`.
- Created AceDB and its settings consumers from the shared login path, with a load-after-login fallback.
- Gated early enable callbacks and handled disable/re-enable before configuration was ready.
- Ran configuration UI setup before database stages in the same startup coroutine.
- Avoided file-load reads of the profiler SavedVariable on Forever, suspending startup profiling during the experiment.
- Exposed unsaved `Questie.startupStatus` diagnostics for restoration and cache decisions.

The prototype passed 1,935 public tests, but **did not fix restoration in-game**. Two observed runs, including a reload confirmed by disappearance of a temporary session marker, reported:

```text
configReadAfterLogin = true
savedConfigPresent = false
savedCacheCompiled = false
cacheDecision = "compile"
cacheReasons = {"not-compiled", "addon-version", "locale", "expansion"}
```

AceDB's root matches the named SavedVariable after initialization. The important observation is that the named root was absent before AceDB created it, even at login. This does not identify why the client failed to restore it and is not evidence that AceDB discarded an already-restored root.

The raw/AceDB reload-probe results above remain valid, but cannot be generalized to this actual Questie database. Subsequent isolation is recorded below. Because the deferral did not solve the failure, its lifecycle changes, profiler guards, late-load handling, and experiment-only tests were removed. Existing initialization and profiling behavior are retained.

## Isolation round: payload, directory, and manifest controls

Further tests on build `69913` narrowed the failure to the existing Questie addon rather than showing a general SavedVariables or AceDB failure:

| Control | Observation |
| --- | --- |
| Small table in a regular addon folder | Restored its original marker at login. |
| 8 MiB of text, split across 16 strings | Restored; serialized file was about 8.39 MB. |
| Detached copy of Questie's runtime configuration, including compiled bins | Restored; serialized file was about 7.50 MB. This copy precedes AceDB's logout cleanup, so it is not byte-identical to Questie's own file. |
| Small table loaded through a directory link into the same checkout | Restored. |
| Linked directory whose physical basename differs from the addon name | Restored. |
| Fresh addon using a Camelot TOC with SavedVariables and a generic fallback without them | Restored; an execution marker confirmed the Camelot manifest was selected. |
| Fresh addon with Questie-like metadata length, localized fields, and account/character declarations | Restored. |
| Tiny number and table declared in Questie's own Camelot TOC | Written to Questie's SavedVariables file, but both absent on the following reload. Their counters restarted at 1. |

Seeding was disabled before the control restoration rounds, and runtime snapshots confirmed it remained disabled. The payload controls therefore did not silently recreate missing data. The directory controls used unprivileged Windows junctions through the existing link chain; they do not rule out every distinction involving native symbolic links.

An additional byte-preserving copy of Questie's serialized file was placed under a new test addon, with only the declared variable names changed. It did not load, but neither did a tiny hand-seeded disk control. Both files remained unchanged on disk. Consequently, that experiment does **not** establish a corrupt Questie payload. It instead exposes a distinction between data created by the running client and new files placed on disk while it is running.

A subsequent client restart changed this picture: previously successful controls were missing too. The earlier addon-specific interpretation was therefore too narrow. Existing Questie files and local experiment evidence were preserved; temporary diagnostic entries were later removed from the Camelot TOC.

### Post-restart observations and the clean control

The process ID changed, confirming a real client restart. Snapshots afterward showed nil/zero previous values in the raw, late-only, literal-global, and AceDB controls. Read-only small and copied-payload controls were also nil. Some files had already been rewritten with nil by the time they were inspected, so the initial markers remain preserved in the earlier snapshots rather than those live files.

The old early-access probes were still enabled on this character. To remove cross-addon interference as a confound, a new clean test was installed in a regular addon folder. It first accesses its only SavedVariable two seconds after `PLAYER_ENTERING_WORLD`. Inspection code loads only after that first access.

With only this control active during startup, reloads restored the preceding value and advanced its counter. Adding Questie back did not prevent the clean control from restoring, but Questie still reported its own root missing. No conclusion about cold-start persistence follows from those successful reloads.

**Completed clean cold-start test:** the user fully restarted with only the clean late probe enabled at startup. Its last known value was count 4, marker `1789733321:4572736.0530241`. The first read returned nil despite `IsLoggedIn()` being true and execution occurring two seconds after `PLAYER_ENTERING_WORLD`; it initialized count 1. The inspection helper loaded only after this observation. Questie was not loaded, so neither its modules nor its bundled AceDB could have performed the read or reset.

The on-disk file was copied immediately afterward and still contained the expected count 4 and marker. Thus this case is not merely a missing save or a counter overwritten before the evidence was collected. Blizzard's own UI remains present, so the experiment does not exclude a native or built-in UI defect, account/path/configuration issues, or every possible environment interaction.

Normal non-probe addon enable states were restored and verified. All temporary probe addons were disabled and confirmed unloaded. Temporary diagnostic SavedVariables and file references were removed from the Camelot TOC. Saved evidence and fixture files remain local. The unsuccessful deferred-startup prototype was removed rather than retained as a persistence workaround.

## Reduced reproducer for a client report

This is the tested probe's essential access pattern, without the observation helper. The failure was recorded before that helper was loaded.

`QuestieSVCleanLate.toc`:

```toc
## Interface: 16001
## Title: SavedVariables cold-start probe
## SavedVariables: QuestieSVCleanLateData
QuestieSVCleanLate.lua
```

`QuestieSVCleanLate.lua`:

```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    frame:UnregisterAllEvents()
    C_Timer.After(2, function()
        local previous = _G["QuestieSVCleanLateData"]
        print("Restored:", type(previous), previous and previous.count)
        local data = type(previous) == "table" and previous or {}
        data.count = (data.count or 0) + 1
        data.token = tostring(time())
        _G["QuestieSVCleanLateData"] = data
        print("Current:", data.count)
    end)
end)
```

Steps: enable only the probe among third-party addons; log in and let it write; confirm reloads increment the counter; fully exit and restart; compare the first printed restored value with the file written by the previous session. Preserve that file before another logout/reload can overwrite it. Expected: the old count is restored. Observed in the isolated test: nil, while the file still held count 4.

## Requested per-character storage trial

A temporary trial changed `Questie-Camelot.toc` to declare `QuestieConfig`, `QuestieProfilerEnabled`, and the existing `QuestieConfigCharacter` under `SavedVariablesPerCharacter`, with no account-wide declaration. Other manifests, global names, and the AceDB schema were unchanged; no automatic import from account-wide data was added.

Eight existing Questie SavedVariables/backup files were preserved before the change. The first load initialized a character-local cache, and the following save wrote the configuration into the character's file (approximately 7.49 MB). The second load was verified on the same character GUID, but still reported `savedConfigPresent = false` and compiled again. This did not demonstrate a restoration fix. A full restart after the TOC change was not tested.

The trial would make profiles, global settings, compiled cache, and profiler preference character-local and limit cross-character Journey browsing. At the user's request, it was reverted: `QuestieConfig` and `QuestieProfilerEnabled` are again account-wide, and only the legacy `QuestieConfigCharacter` is per character. The revert changed the manifest, not existing SavedVariables files; the backups remain available.

## Report being investigated

TheCrux / BreakBB reported on Discord:

> The UI server also found out that the "saved variables are not saved" is caused because they are accessed/filled before PLAYER_LOGIN. It's a bug Blizzard can fix

The quote supplied no minimal reproduction, affected build, or distinction between reload, logout, and client restart. A public search did not locate an independent Forever-specific reproduction. General SavedVariables guidance describes restoration ordering, but cannot establish whether this beta has a separate bug.

## Experiment design

Six disposable addons used new SavedVariables only. No probe modified or reset `QuestieConfig`, its profiles, migrations, or compiled data. Tests ran from ordinary addon Lua callbacks rather than changing control values from an external caller.

| Probe | Early restoration | Cases |
| --- | --- | --- |
| Raw early-load | `1` | File-load and own `ADDON_LOADED` root/nested reads, mutation, replacement; login, next-tick, entering-world writes; scalar and per-character controls. |
| Raw normal-load | `0` | Same matrix. |
| Independent late-only | `0` | No access to its SavedVariables before login; login, next-tick, entering-world, scalar, and per-character writes. |
| AceDB normal-load | `0` | Separate databases created at own `ADDON_LOADED`, `PLAYER_LOGIN`, and the next timer tick. |
| Literal globals | `1` | Direct named-global syntax instead of dynamic `_G[name]` access; file-level write/read, addon-loaded write, login write. |
| AceDB early-load | `1` | Same three AceDB phases as the normal-load probe. |

The late-only addon was independent so an addon-wide failure could not contaminate its baseline. Both account-wide and per-character storage were covered. Values were tables and non-default strings; nested AceDB defaults were also exercised.

Each session used a unique marker and incrementing counters. Observations were held in ordinary, non-persisted runtime tables. Controls were not inspected until login, entering-world, and next-tick phases had completed.

Three kinds of evidence were kept separate:

1. The value observed before the current session wrote anything at the assigned phase.
2. The final runtime value after all startup phases.
3. The serialized value on disk and its restoration in the following session.

There were six active probe sessions, followed by a final save/reload with all probes disabled. The raw probes ran throughout; AceDB and literal-global probes were introduced in later rounds. Initial creation and subsequent modification of already-restored tables were both exercised.

## Results

| Behavior | Result |
| --- | --- |
| Early-load root or nested read, followed by a login write | Persisted across repeated reloads. |
| Early-load file-scope table mutation/replacement | Persisted. |
| Normal-load file-scope mutation/replacement with existing disk data | Overwritten by restoration before own `ADDON_LOADED`. The resulting runtime value persisted correctly. |
| Own `ADDON_LOADED` reads and writes, with either metadata setting | Persisted. |
| Login, next-tick, and entering-world initialization | Persisted. |
| Independent late-only addon | Persisted; not uniquely successful compared with early controls. |
| Direct named globals | Persisted, including mutation of already-restored data. |
| Early versus late AceDB, both metadata settings | Persisted. Root and profile aliases matched their saved-variable tables. |
| Per-character login controls | Persisted. |

After the final save, **all 43 declared probe variables across nine SavedVariables files matched their final runtime snapshots**. This comparison intentionally used final runtime values, not writes already overwritten by normal restoration.

The original raw counters progressed through six sessions. The normal-load file-write cases retained their first persisted value because every later file-level write occurred before restoration and was replaced. This is materially different from the game failing to save the final global.

## Observations about Questie itself

Read-only inspection found:

- The current Camelot TOC uses `LoadSavedVariablesFirst: 0`; the other expansion TOCs use `1`.
- `QuestieConfig` is a table, `Questie.db.sv` refers to that same table, and the active profile alias matches the profile inside the saved database.
- The account-wide file contained the compiled database, `dbIsCompiled = true`, `dbCompiledCount = 1`, and profile migration version 38. Corresponding live values agreed.
- The file was approximately 7.5 MB, so this run also demonstrated that Questie's existing compiled data was being written. This is not a general size-limit test.
- Actual character settings are inside AceDB's `QuestieConfig.char`. `QuestieConfigCharacter` is declared in the TOCs but has no Lua consumers found in this checkout.

These post-startup values establish that data was written and that live state was internally consistent. They do not prove the next startup restored or reused it: a fresh root can recompile and reset `dbCompiledCount` to 1 again. The later startup instrumentation demonstrated that distinction. The earlier inference that a stable count of 1 proved cache reuse was not sufficient.

## What the source says about a possible workaround

If a reproducible early-access bug is found later, moving only `AceDB:New` is not enough:

- [`Questie.lua`](../Questie.lua), `OnInitialize()`, creates AceDB, registers early events, and invokes addon-loaded initialization.
- [`AceDB-3.0.lua`](../Libs/AceDB-3.0/AceDB-3.0.lua), `New`, initialization, and section metatables, creates `profileKeys`, profile/global/character sections, and defaults. Reading a section can mutate the database.
- [`QuestieInit.lua`](../Modules/QuestieInit.lua), `OnAddonLoaded()`, configures the minimap, migrates settings, and initializes consumers which retain nested-table references.
- [`AvailableQuests.lua`](../Modules/Quest/AvailableQuests/AvailableQuests.lua), `Initialize()`, caches per-realm tables from saved global state.
- [`EventHandler.lua`](../Modules/EventHandler/EventHandler.lua), `PlayerLogin()`, explicitly expects config to have been initialized already.
- [`AceAddon-3.0.lua`](../Libs/AceAddon-3.0/AceAddon-3.0.lua) can initialize and enable an addon loaded after login. A login-only callback would miss that case.
- [`QuestieLoader.lua`](../Modules/Libs/QuestieLoader.lua) and the profiler pre-hook read `QuestieProfilerEnabled` during file loading. Deferring that decision loses startup timing and early function-alias interception.

Any future timing workaround would need an explicitly ordered config/bootstrap phase and a load-after-login path, including cached aliases and optional startup profiling. That complexity is not currently justified by the evidence. Comments now clarify that startup profiling relies on `LoadSavedVariablesFirst: 1`, while Camelot retains its existing value of 0.

## Other ways values can appear unsaved

- A saved global is restored after a file creates and caches a different table. Later writes to the stale alias are not writes to the persisted root.
- AceDB removes default-valued fields and empty sections on logout. An absent default field does not prove a save failure; use a unique non-default marker.
- The active profile, character, account, or client installation differs from the one whose file is being inspected.
- A reload completion signal is missed. Confirm a new session marker rather than assuming either success or failure.
- Reading a control early during diagnosis changes the condition being tested. Keep observation after the intended phase.

## Limits and next steps

Coverage includes reloads and the isolated cold client restart described above on build `69913`. Not exhaustively tested: character/account switching, every SavedVariable type, cyclic values, other installations or builds, or operating-system/file-access causes. The large text control is not a proof that every payload size or structure is supported.

If settings still reset, obtain an exact setting/value and action sequence, then compare that same profile's value before save, on disk, and on restoration. Include the build and whether `LoadSavedVariablesFirst` was enabled. A minimal failing case would be a stronger basis for a Blizzard report or a targeted workaround than a broad initialization rewrite.

All probe addons were disabled and confirmed unloaded, and the original non-probe addon states were restored. Fixtures, evidence, and SavedVariables backups remain local. The startup-deferral prototype and per-character storage trial have both been reverted.

## Retained code

Only a small session-only cache diagnostic was kept from the runtime experiments:

```lua
QuestieLoader:ImportModule("QuestieInit").cacheStatus
-- { decision = "compile" or "reuse", reasons = { ... } }
```

Reasons are `not-compiled`, `addon-version`, `locale`, and `expansion`. This records the existing cache decision without changing startup order, persistence, or settings. Three focused tests cover valid reuse, missing metadata, and an isolated locale mismatch. The broader startup status record and its experimental API were removed.
