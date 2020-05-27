# LibQuestXP (Classic)

LibQuestXP is a **library** for other addons to provide experience reward information about quests **for addon developers**.

In Classic WoW the ```GetQuestLogRewardXP``` lua function was removed, and there's currently no other way to fetch XP reward information. This addon re-implements this function so Addons depending on ```GetQuestLogRewardXP``` can be ported to classic from retail.

**Important:** This is not a standalone addon! If you're **not** a developer, this addon is probably no use to you.

## Usage

LibQuestXP uses [LibStub](https://www.wowace.com/projects/libstub "LibStub") like many other libraries. If you want to embed it in your addon, please use ```LibQuestXP.xml```, which should load all necessary files.

### Utilizing GetQuestLogRewardXP

You can select a quest log index, then call GetQuestLogRewardXP without a parameter

```
SelectQuestLogEntry(questLogIndex);
GetQuestLogRewardXP()
```

or you can just call GetQuestLogRewardXP with a questID

```
GetQuestLogRewardXP(questID)
```
