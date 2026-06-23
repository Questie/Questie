# Review: PR #7574 party member quest objectives

## Source information

- PR: #7574 — `[feature] Show party members quests on map`
- URL: https://github.com/Questie/Questie/pull/7574
- State: MERGED
- Author: Sommos
- Base branch: `master`
- Head branch: `feature/7477-show-party-members-quests-on-map`
- Original merge commit reviewed: `fa172d5b33d380cb163cdd71ab5bbf45d330c245`
- Review target branch: `review/party-icons`
- Review target starting HEAD: `909baebee85fd0b247a81bf1e695bd68c0c13640`

## PR body summary

PR #7574 fixed issue #7477 by adding support for showing party members' quest objectives and extra objectives on the world map. It also added frame-chunked processing for quest objective drawing and transparency for other party members' quest objective icons.

## Initial validation from review

- `busted -p ".test.lua" Modules/QuestiePlayer.test.lua Modules/EventHandler/QuestEventHandler.test.lua cli/integrationTests/6734.test.lua`: passed, 17 successes.
- `luacheck` on touched Lua files: passed, 0 warnings / 0 errors.
- `lua cli/validate-localization.lua`: not completed locally because the environment was missing the `bit32` Lua module.

## Findings to resolve

| ID | Severity | Finding | Relevant files |
| --- | --- | --- | --- |
| F1 | High | Party member kill credit and event objectives can fail to serialize or draw because those ObjectiveData shapes do not always have `Id`. | `Modules/Network/QuestieComms.lua`, `Modules/Network/QuestiePartyObjectives.lua`, `Database/QuestieDB.lua` |
| F2 | Medium | Recycled map frames can retain party-objective alpha or stale overlay textures when reused by paths that bypass `UpdateTexture`. | `Modules/FramePool/QuestieFrame.lua`, `Modules/FramePool/QuestieFramePool.lua`, `Modules/Map/QuestieMap.lua` |
| F3 | Medium | Accepted quests can get stuck if the initial accept handling and its single retry both hit cache-missed objective data. | `Modules/EventHandler/QuestEventHandler.lua` |
| F4 | Medium | Party extra/special objectives only check the global party icon cap before drawing and can exceed it after population. | `Modules/Network/QuestiePartyObjectives.lua` |
| F5 | Medium/Low | Individual party member removal can leave stale remote quest and tooltip data. | `Modules/EventHandler/GroupEventHandler.lua`, `Modules/Network/QuestieComms.lua`, `Modules/Network/QuestieCommsData.lua` |
| F6 | Medium/Low | Party objective drawing trusts local objective index without validating transmitted objective identity, so mismatched Questie database versions can draw the wrong objective anchor. | `Modules/Network/QuestiePartyObjectives.lua`, `Modules/Network/QuestieComms.lua` |
| F7 | Low | `QuestieQuest:IsQuestTracked` returns true for absent quests when auto-track is enabled. | `Modules/Quest/QuestieQuest.lua` |
| F8 | Low | Challenge Mode detection compares localized difficulty text instead of a numeric difficulty ID. | `Modules/Tracker/QuestieTracker.lua`, `Modules/Tracker/ChallengeModeTimer.lua` |
| F9 | Low | Migration sound reset condition has Lua `and`/`or` precedence bug and can reset TBC+ sound choices. | `Modules/Migration.lua` |

## Resolution table

| ID | Resolution commit | Validation |
| --- | --- | --- |
| F1 | `a0ec36b36` — `[fix] Support party objectives without direct IDs` | `busted -p ".test.lua" Modules/QuestiePlayer.test.lua Modules/EventHandler/QuestEventHandler.test.lua cli/integrationTests/6734.test.lua Modules/Tracker/ChallengeModeTimers.test.lua`; `luacheck -q --` changed Lua files |
| F2 | `3be0e57c3` — `[fix] Reset reused quest icon frame visuals` | `luacheck -q --` changed Lua files |
| F3 | `a8f6f3bd4` — `[fix] Keep retrying accepted quest cache misses` | `busted -p ".test.lua" Modules/EventHandler/QuestEventHandler.test.lua`; included in combined targeted test run |
| F4 | `a6a85c539` — `[fix] Enforce party special objective icon cap` | `luacheck -q --` changed Lua files |
| F5 | `13c98428b` — `[fix] Clear stale party objective data` | `luacheck -q --` changed Lua files |
| F6 | `a0ec36b36` — `[fix] Support party objectives without direct IDs` | Identity validation was implemented with the no-ID objective handling; `luacheck -q --` changed Lua files |
| F7 | `943407b42` — `[fix] Treat absent quests as untracked` | `luacheck -q --` changed Lua files |
| F8 | `fd60a2d05` — `[fix] Use challenge mode difficulty ID` | `busted -p ".test.lua" Modules/Tracker/ChallengeModeTimers.test.lua`; included in combined targeted test run |
| F9 | `5b26ef93c` — `[fix] Guard sound migration by expansion` | `luacheck -q --` changed Lua files |

## Final validation on `review/party-icons`

- `busted -p ".test.lua" Modules/QuestiePlayer.test.lua Modules/EventHandler/QuestEventHandler.test.lua cli/integrationTests/6734.test.lua Modules/Tracker/ChallengeModeTimers.test.lua`: passed, 24 successes / 0 failures / 0 errors.
- `luacheck -q -- Modules/EventHandler/GroupEventHandler.lua Modules/EventHandler/QuestEventHandler.lua Modules/FramePool/QuestieFramePool.lua Modules/Migration.lua Modules/Network/QuestieComms.lua Modules/Network/QuestiePartyObjectives.lua Modules/Quest/QuestieQuest.lua Modules/Tracker/ChallengeModeTimer.lua Modules/Tracker/ChallengeModeTimers.test.lua Modules/Tracker/QuestieTracker.lua`: passed, 0 warnings / 0 errors.

## Follow-up review resolutions

| Follow-up | Resolution commit | Validation |
| --- | --- | --- |
| Accepted-quest retry timers could still fire after quest removal or turn-in. | `94e257e85` — `[fix] Ignore stale accepted quest retries` | `busted -p ".test.lua" Modules/EventHandler/QuestEventHandler.test.lua`; combined targeted busted run; changed-file luacheck |
| Stale remote-player cleanup only ran when group size changed, missing same-size roster swaps. | `c69c3aabb` — `[fix] Prune stale players on roster updates` | changed-file luacheck |
| Synthetic objective id `0` could be registered as a real tooltip key and stop later tooltip registration for invalid item IDs. | `dff824a0e` — `[fix] Ignore synthetic tooltip objective IDs` | changed-file luacheck |

## Final follow-up validation

- `busted -p ".test.lua" Modules/EventHandler/QuestEventHandler.test.lua Modules/QuestiePlayer.test.lua cli/integrationTests/6734.test.lua Modules/Tracker/ChallengeModeTimers.test.lua`: passed, 25 successes / 0 failures / 0 errors.
- `luacheck -q -- Modules/EventHandler/QuestEventHandler.lua Modules/EventHandler/QuestEventHandler.test.lua Modules/EventHandler/GroupEventHandler.lua Modules/Network/QuestieComms.lua Modules/Network/QuestieCommsData.lua`: passed, 0 warnings / 0 errors.

## Notes

- The pre-existing untracked `Modules/FramePool/QuestieFramePool.test.lua` file was not staged or committed.
- Other pre-existing untracked files (`CONTEXT.md`, `docs/`, `specs/`) were left untouched and untracked.
