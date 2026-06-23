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

_To be filled after implementation._
