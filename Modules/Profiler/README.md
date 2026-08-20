# Questie Profiler

An opt-in, in-game profiler for Questie: what each function cost, who called it, how long each file took to
load, and how much of that belongs to a bundled library rather than to Questie. It is off unless
`QuestieProfilerEnabled` is set, and a player who never enables it pays two branch tests per loader call - a
false boolean and a nil observer - plus the memory of the profiler files themselves, and no runtime cost
beyond that: no wrapper is built, no indirection is installed, no observer is attached, and no timer or frame
is created.

This file is the accumulated context for working on it, consolidated from the design notes that preceded it.
Most of what is here was measured in a live client rather than reasoned about, and those numbers are the part
most expensive to rediscover.

## The files

| File | Owns |
|---|---|
| `QuestieProfiler.lua` | The engine: wrappers, the shadow stack, caller/callee attribution, coroutine slice timing, session lifecycle, and which roots get traversed. |
| `QuestieProfilerPreHook.lua` | Loads second in every TOC, immediately after `QuestieLoader`. Puts a permanent indirection in every module function slot while the addon loads, so a file that copies one into a local copies something the engine can still redirect. Installs nothing unless startup profiling is enabled. |
| `QuestieProfilerReport.lua` | Pure model. Profiler tables in, display rows out. Reads no frame, writes no frame, imports no engine. |
| `QuestieProfilerUI.lua` | The window. Frames, anchors, scripts, rendering, and every presentation constant. |
| `Modules/Libs/QuestieLoader.lua` | Not in this folder, but part of the system: it stamps per-file load intervals, which is the only way file load cost is observable at all, and `SetModuleCallObserver` is the one place anything can run between two Questie files. |

The Report/UI split is by nature, not by length. One half is tables in, tables out and testable against plain
Lua; the other is 2,500 lines that only a live client can exercise. Keeping the seam physical is what stops
them growing back into each other.

## How it measures

A wrapper brackets the real call, so the frame directly below a call on the shadow stack *is* its caller -
nothing is inferred. **Self time** is the parent's inclusive elapsed minus the measured time of completed
profiled children, which is why a library row appearing beneath a Questie row moves milliseconds out of that
Questie row's self time rather than adding new cost.

Three execution contexts, deliberately treated differently:

| Context | Treatment |
|---|---|
| Main thread | Timed inside a `pcall`, so an error can never skip the epilogue that keeps the shadow stack exact. |
| ThreadLib coroutines | Only *active resume slices* are timed. A call that runs 2 ms, yields for several frames, then runs 1 ms reports 3 ms - suspension is excluded. |
| Raw coroutines | Counted but never timed. Without owning the resume boundary the profiler cannot separate execution from suspension, so it refuses to guess. |

**Addon load** is not a call, so it cannot be wrapped. `QuestieLoader` instead stamps the interval between
consecutive main-chunk `CreateModule`/`ImportModule` calls, and charges it to whichever file opened it. Rows
are therefore intervals, not parse costs: anything the client does between two stamps lands on the file that
opened the interval, garbage collection included, and a file that makes no loader call at all is charged to
its predecessor. XML groups that would otherwise be invisible open with
`<Script>QuestieLoader:StampLoadBoundary()</Script>` so they name their own interval.

## Rules that will break something if you change them

- **TOC order.** The engine and window load near the end of every TOC, and `QuestieProfilerReport.lua` loads
  *before* `QuestieProfilerUI.lua` - the window aliases the report's formatters at file scope and would
  otherwise capture `nil`.
- **`RefreshHooks` excludes `Profiler`, `ProfilerUI`, `ProfilerReport` and `ProfilerPreHook` by module name.**
  Without the third the profiler wraps the report builder and measures itself building the report you are
  reading; without the fourth it measures the machinery that made the measurement reachable.
- **`QuestieProfilerPreHook.lua` must stay directly under `QuestieLoader.lua` in every TOC.** Modules that
  already exist when it loads are wrapped by its seed pass, but a file *above* it has already run, and an alias
  that file captured holds the real implementation - wrapping the slot afterwards cannot reach a copy. Moving
  the line down the TOC blinds everything between the loader and its new position, and blinds it silently: the
  rows do not disappear, their cost moves into whichever caller is still visible. Nothing but `QuestieLoader`
  belongs above it.
- **`PROFILING_DISALLOWED_PATHS` and the pre-hook's exclusions must agree, and `FindPreHookExclusionMismatches`
  is what enforces it.** The two lists cannot be shared, because the pre-hook runs long before the engine file
  exists, so the engine re-derives its own list against `ProfilerPreHook.IsExcluded` once per session and
  reports any path the pre-hook would still wrap. A drift here installs a permanent indirection on a slot
  excluded precisely because it runs thousands of times inside one useful measurement: all of the cost, none
  of the benefit, and no symptom that names itself. Add to one list, add to the other.
- **`worldmapProviderPin` is excluded from the HBD Pins traversal by name.** `Mixin(frame, worldmapProviderPin)`
  copies it onto every pin as that pin is created, so a wrapper installed there rides onto live frames that
  `Unhook` cannot reach and outlives the session. `worldmapProvider` beside it is safe - nothing copies it a
  second time - and it owns the most expensive row in the report.
- **`QuestieProfilerUI.lua` sits near Lua 5.1's ceiling of 200 locals per main chunk.** Exceeding it is a
  load-time error, not a warning. Presentation constants live in the `LAYOUT`, `COLOR` and `ICON` tables for
  this reason; add to those rather than adding a file-scope local.
- **`StampLoad` reads `debugstack` at level 3** - StampLoad, Create/ImportModule, the calling file. Adding a
  frame to that chain silently collapses every file into one bucket named after `QuestieLoader.lua`.
- **Only a file's own main chunk may open or close a load interval.** A runtime import from inside a function
  is skipped on purpose; stamping there once made installing the profiler's hooks appear as
  `QuestieProfiler.lua`'s load cost.
- **`DescribeThreadJob` filters profiler frames by the filename `QuestieProfiler.lua`, not by a path.** Moving
  the file into this folder did not break it, and making it path-aware would.
- **The `pcall` in the measurement wrapper is on the main-thread branch only.** The ThreadLib branch must never
  pcall: Lua 5.1 cannot yield across a pcall boundary, so it would kill every yielding job.
- **`GetTimePreciseSec` is the only clock, and there is deliberately no fallback.** Any addon can reset
  `debugprofilestop` to zero by calling `debugprofilestart`, and a reset landing between a wrapper's two reads
  publishes a negative elapsed that accumulates - measured at -99 ms on a live client before this was removed.
  It also could never run: `QuestieLoader` calls `GetTimePreciseSec` directly and would have aborted the addon
  first. If the clock is ever absent the loader records nothing and the profiler declines to arm, saying so in
  chat. Do not reintroduce a second clock; a measurement that can go backwards is worse than none.
- **`PROFILING_DISALLOWED_PATHS` is deliberate.** `QuestieStreamLib`, the `DBCompiler` reader/writer/skipper
  tables, the serializer dispatch tables and the `QuestieDB.Query*` slots run thousands of times inside one
  useful high-level measurement and would otherwise dominate every result. Their cost is still visible
  inclusively in whatever called them. Do not "fix" this.
- **Never re-open generic frame traversal.** Frames are runtime objects with protected behaviour and enormous
  graphs. Only explicitly named frames are ever touched.
- **ThreadLib job rows have no self time.** A job is a scheduling unit with no call frame, so nothing
  attributes child time to it; the UI renders `-` rather than `0.00` so it does not read as "spends nothing".
- **UI actions never touch a measurement.** Sorting, filtering, grouping, scoping and freezing are display
  operations. A stopped session keeps its results until the next Start, and reopening a closed window must not
  cost them.

## Reaching code: the four bindings

There are four ways a function can be bound, and each needs a different technique. What decides the technique
is the binding, not what the function does - so you can tell in advance which applies.

| Binding | Technique | Reaches |
|---|---|---|
| A table slot | Replace the slot - `HookTable` / `HookFunction` | Questie modules, bundled library publics, and any "private" function that still lives on a table |
| A local copied from a Questie module | Own the slot *before* the copy is taken - `QuestieProfilerPreHook` | `local IsDoable = QuestieDB.IsDoable` and every alias like it |
| A frame script | Replace the script slot via `SetScript`, or read `GetFrameCPUUsage` | `HBDPins.updateFrame` OnUpdate/OnEvent, `HBD.eventFrame` OnEvent |
| A local the file defines itself | Nothing short of editing the vendored file | HBD's `UpdateMinimapPins`, `drawMinimapPin`; a file's alias of a Blizzard API |

"Private" was never the axis - "on a table or not" is. `worldmapProvider.RemovePinByIcon` is private in spirit
and became the report's largest row because it happens to sit on a table.

The last case has no technique and does not need one: the frame-script row gives the total, and reading the
vendored source identifies the culprit in about two minutes.

### The alias case, because it is not obvious

Replacing a table slot reaches every call that *reads* that slot. It reaches nothing that took a copy first,
and the engine loads near the end of the TOC, by which point every file-scope alias in the addon already holds
the real function. Those calls are not merely unmeasured - their cost lands in the caller's self time, so the
report is confidently wrong rather than visibly incomplete. Three aliases in `AvailableQuests` were hiding 40%
of a `CalculateAndDrawAll` pass.

`QuestieProfilerPreHook` fixes it by getting there first. Every module function slot gets a stable wrapper
while the addon is still loading:

```lua
local current = original                              -- what the wrapper calls today
local wrapper = function(...) return current(...) end -- what an aliasing file captures
local slot = setmetatable({}, {                       -- what the engine hooks, later
    __index = function() return current end,
    __newindex = function(_, _, value) current = value end,
})
module[functionName] = wrapper
```

The wrapper is never replaced - an alias already has it and cannot give it back - so what the engine hooks is
`current`, through a stand-in table shaped like an ordinary parent so `HookFunction` needs no special case.
`Unhook` restores it by the same ownership check it uses everywhere else, and a later session can hook it
again, which a plain hook on the module slot could not survive.

`QuestieLoader` drives the timing through `SetModuleCallObserver`: each module registration is the top of some
file, so every file above it has finished and everything it defined is wrappable before anything below it can
alias it. A dirty set defers the sweep of the module being named, since it is about to be filled. `Finish()`
runs a full sweep on `ADDON_LOADED` and detaches - after that no further file can capture anything.

Two consequences to be honest about. The indirection is permanent for the session, so **Stop does not remove
it - only a reload does**; the window says so. And the pre-hook is what makes the engine's exclusion list
load-bearing twice over, which is what the cross-check rule above is for.

Bundled libraries are allowlisted by LibStub major, Questie-suffixed ones only. The other ~22 majors LibStub
holds are generic (Ace3, CallbackHandler, LibSharedMedia, LibDBIcon, Krowi) and registration is not ownership:
the loaded copy may belong to another addon, so wrapping those tables would count other addons' calls, add
overhead to them, and let this report claim work that is not Questie's.

## What has been measured

All in-client on Era 1.15.9 unless noted.

**Bundled libraries** - a full icon redraw (696 available quests, 2,210 frames unloaded, 4,819 world map icons):

| Row | Calls | Self | Per call |
|---|---:|---:|---:|
| `Libs.HBDPins.worldmapProvider.RemovePinByIcon` | 5,892 | **694 ms** | 118 us |
| `Libs.HBDPins.AddWorldMapIconMap` | 4,819 | 66 ms | 14 us |
| `Libs.HBDPins.worldmapProvider.HandlePin` | 4,819 | 59 ms | 12 us |
| all `Libs.*` | | **1,007 ms** | |
| all Questie functions, same window | | 692 ms | |

`RemovePinByIcon` enumerates *every* pin on the world map to find one, and `QuestieFrame.private.Unload` calls
it once per frame - so clearing n icons is O(n^2). `RemoveAllWorldMapIcons(ref)` is the bulk path that already
exists in the library.

**The minimap updater** - 65 seconds and 442 yards of ordinary running:

| | |
|---|---|
| `Libs.HBDPins.updateFrame.OnUpdate` | 2,326 calls, **313 ms self** - the largest row in the session |
| next row | 22 ms |
| busiest Questie function | 3.2 ms |
| stationary | 0.36 ms/s |
| moving | 5-6.7 ms/s, ~115 us per frame |

The gap is because `UpdateMinimapIconPosition` is guarded on the player's position having changed. Standing
still it skips its loop entirely, which is why every stationary measurement said there was nothing there.
Roughly 1,105 minimap pins are registered so that ~26 can be active.

**Wrapper overhead** - about **3.7 us** per measured call in-client. Against that, a wrapped API is only worth
measuring if it costs more: `C_Item.GetItemCount` 9.6 us, `C_Map.GetPlayerMapPosition` 3.9 us, either
`GetItemInfo` 2.5 us, and everything else tried was 0.2-0.9 us. A row for a sub-microsecond call mostly reports
the profiler - the bracket includes the pcall and the packing of results. Cost also depends on the argument:
`C_QuestLog.GetQuestObjectives` measured 53 us on a real quest against 0.55 us on an empty one.

**The pre-hook** - 626 of 728 module functions wrapped, with the 102 skipped accounted for exactly by the
exclusion list and 0 cross-check mismatches. The indirection costs **0.073 us** per call, against roughly 3.7 us
for a measured call: about 2% while profiling, and it is the only thing that costs anything between Stop and a
reload. Load time was measured **interleaved** A/B over three pairs: +53.5 ms mean, sd 74.2 ms, one pair
negative - +1.5%, which is not distinguishable from noise. Removing one `IsDoable` alias by hand moved the dark
share of a redraw from 40.5% to 14.2% and surfaced `QuestieDB.IsDoable` at 2,158 calls / 37.2 ms, a row that
had never appeared before.

**Addon load** - naming the XML script groups moved 462-660 ms and 17.7 MB off `lookupZones.lua` and onto the
four locale groups that actually spend it. Each group's allocation matched its directory's on-disk size almost
byte for byte, which is the parse-interns-the-source explanation measured per group. That cost is still *spent*
on a client whose locale does not match; making it visible is all the profiler can do about it.

**Coroutines** - the stale-frame risk in cross-slice accumulation was measured at zero occurrences in 97,894
profiled coroutine returns, and is structurally impossible besides: a stale frame never returns, so it can
never publish.

**An observation worth acting on, unrelated to the profiler itself:** `_DrawAvailableQuest` reports submitted
jobs and resumes as exactly equal, meaning every one of those coroutines completed in a single resume without
ever yielding. A coroutine that never yields is pure overhead over a direct call, and this is the most
expensive job in a startup profile.

## Tried and rejected

- **A Questie-scoped `setfenv` environment** for catching Blizzard API calls before files capture them into
  locals. This was the one genuinely hard problem: a file-scope `local GetItemInfo = GetItemInfo` cannot be
  reached by replacing a slot afterwards, and the profiler loads near the end of the TOC, by which point every
  such alias already holds the real function. Interception has to happen when the alias is *read*. It was
  built in full and verified in-client - 734 of 784 hooked functions ran in the environment, `issecurevariable`
  reported no taint, return tuples and error identity were exact - and then **removed**. It found ~0.1 ms/s
  under the heaviest map load that could be driven, against a library method next door costing 694 ms, and it
  structurally could not reach file-locals, which is where the cost turned out to be. The cost of keeping it
  was that `QuestieLoader` - the file every Questie file passes through - would give every file a non-standard
  environment whenever a saved variable was set. The question it answered ("is API X slow?") is answerable ad
  hoc in a few lines whenever it is actually asked.
  *`QuestieProfilerPreHook` did not supersede this and does not make it viable.* The pre-hook solves the alias
  problem for functions that pass through `QuestieLoader`, which it can get in front of; a file's alias of a
  *Blizzard* API is captured from `_G` with nothing in between, and remains reachable only by an environment
  trick with the costs above.
- **Blanket `_G` traversal, blanket `LibStub:IterateLibraries()`, generic frame traversal, and global slot
  replacement.** Unbounded, affect unrelated addons, ambiguous ownership, taint risk. Global replacement also
  cannot be undone: a wrapper already captured into another addon's local survives restoration.
- **Re-registering vendored libraries through QuestieLoader** instead of the LibStub allowlist. Same coverage,
  but it edits vendored source, breaks LibStub's version guard, and creates a merge conflict on every update.
- **Rewriting the profiler around `C_AddOnProfiler.MeasureCall`** - see below.

## `C_AddOnProfiler.MeasureCall`, evaluated but not built

Declared on Era and MoP. It is a candidate to replace the *stopwatch* inside synchronous wrappers, and its
strongest draw is per-call allocation data, which this profiler has no accurate equivalent of at runtime. It is
**not** a candidate to replace the architecture: it executes a function handed to it and reports one inclusive
measurement, so it discovers nothing, intercepts nothing, and knows nothing about callers, self time, coroutine
suspension, session generations or addon load.

The expected outcome is a hybrid: native measurement for main-thread synchronous calls, the existing
active-slice clock for anything spanning a ThreadLib yield, count-only for raw coroutines, and QuestieLoader's
interval clock for file load.

Nothing should change in production before a standalone in-client spike establishes the unknowns, of which the
load-bearing ones are: whether nil-bearing argument and return tuples survive exactly; what happens when the
measured function errors, and whether error identity and tracebacks are preserved; whether nested and recursive
measured calls are safe; whether a measured function may yield at all, and if so whether suspension is excluded
from elapsed; whether `MeasureCall(coroutine.resume, thread)` measures one slice cleanly; and complete-wrapper
overhead against the current wrapper. Retain the current backend if error objects or tuples change, if nesting
is unsafe, or if overhead is materially worse.

## Measuring something new

The question "is X slow?" is usually answerable ad hoc in a few lines rather than by building anything - that
is how every number above was produced. A live client and the WoWDevBridge CLI are enough:

- Wrap a library table temporarily from a `/run` snippet, drive the workload, read the counters, restore
  ownership-safely: only put the original back if the slot still holds your wrapper.
- `GetFrameCPUUsage(frame, true)` needs the `scriptProfile` CVar, which is commonly already on.
  `ResetCPUUsage()` resets frame counters too. This is how the frame-script cost was found before any code
  existed to measure it.
- `C_AddOnProfiler.GetAddOnMetric("Questie", ...)` gives Blizzard's own view for a sanity check. Note it
  includes the profiler's own overhead while a session is running.
- **Interleave A/B runs, never run all of A then all of B.** A client drifts over a session - background
  addons, memory, whatever the OS is doing - and a sequential comparison attributes that drift to the change.
  The pre-hook's load cost was first reported at +5.1% from a sequential pair and turned out to be +1.5% and
  inside the noise when the same runs were interleaved. Report the spread and the sign of each pair, not just
  the mean; one pair coming out negative is the fact that settles it.
- Watch for the workload being wrong before the measurement is. Several early conclusions here were drawn from
  a stationary character, and the code paths that mattered were gated on movement.

## Open

- `RemoveWorldMapIcon`'s O(n^2) clear path - 694 ms per full redraw, with the bulk path already available.
- 1,105 registered minimap pins for ~26 active, which sets the per-frame cost of the largest row in a moving
  session.
- `QuestieMap`'s minimap fade logic is the only raw coroutine left in the addon - `coroutine.create` driven by
  a hand-rolled resume ticker. Everything it reaches is counted but reports 0.0 ms with no caller, and that
  zero is structural rather than a measurement. Converting it to a ThreadLib job would make it visible, but
  the loop is `while true` and never returns, so its error and teardown behaviour needs care.
- Nothing has been verified on a flavour other than Era. The library allowlist degrades safely when a major is
  absent, but that path is untested in a client.
