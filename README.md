# Questie

[![Discord](https://img.shields.io/badge/discord-Questie-738bd7)](https://discord.gg/s33MAYKeZd)
[![Stars](https://img.shields.io/github/stars/Questie/Questie)](https://img.shields.io/github/stars/Questie/Questie)

[![Downloads](https://img.shields.io/github/downloads/Questie/Questie/total.svg)](https://github.com/Questie/Questie/releases/)
[![Downloads Latest](https://img.shields.io/github/downloads/Questie/Questie/v11.2.8/total.svg)](https://github.com/Questie/Questie/releases/latest)
[![Date Latest](https://img.shields.io/github/release-date/Questie/Questie.svg)](https://github.com/Questie/Questie/releases/latest)
[![Commits Since Latest](https://img.shields.io/github/commits-since/Questie/Questie/latest.svg)](https://github.com/Questie/Questie/commits/master)


## Download
We suggest you use the [CurseForge Client](https://curseforge.overwolf.com/) to manage your WoW addons in general. You will find Questie [here on CurseForge](https://www.curseforge.com/wow/addons/questie).

Alternatively you can always use [the latest GitHub release](https://github.com/Questie/Questie/releases/latest) and follow the [Installation Guide](https://github.com/Questie/Questie/wiki/Installation-Guide) in the Wiki to get the latest version of Questie up and running.

If you have problems, please read the [Frequently Asked Questions](https://github.com/Questie/Questie/wiki/FAQ-for-Classic-(1.13)).


## Information
- [Frequently Asked Questions](https://github.com/Questie/Questie/wiki/FAQ)
- Come chat with us on [our Discord server](https://discord.gg/s33MAYKeZd).
- You can use the [issue tracker](https://github.com/Questie/Questie/issues) to report bugs and post feature requests (requires a GitHub account).
- When creating an issue please follow the templated structure to speed up a possible fix.
- If you get an error message from the WoW client, please include the **complete** text or a screenshot of it in your report.
    - You need to enter `/console scriptErrors 1` once in the ingame chat for Lua error messages to be shown. You can later disable them again with `/console scriptErrors 0`.

Trust us it's (Good)!

## Languages

Questie comes with translations for all offical WoW Classic languages. These are:

English, German, French, Spanish, Portuguese, Russian, Simplified Chinese, Traditional Chinese and Korean.

If you want to help with translations then checkout the [Translation folder](https://github.com/Questie/Questie/tree/master/Localization/Translations) and search for missing translations by:
> `["<yourLanguage>"] = false` (e.g. `["deDE"] = false`) and replace the `false` with a string of the new translation, e.g. `["<yourLanguage>"] = "YourTranslation"`.

On top of that there is support for Ukrainian ([through another addon](https://www.curseforge.com/wow/addons/questie-translation-ukrainian)).
Following [this guide](https://github.com/Questie/Questie/wiki/Localization-to-more-languages) you can add support for even more languages.

## Contribution

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
- We are happy about every help and contribution we get, so feel free to submit a Pull Request on GitHub
- Additional information you might find interesting can be found [here](https://github.com/Questie/Questie/wiki/Contributing)

### Installing Lua

1. Install [Lua](https://www.lua.org/download.html) (5.1, since the WoW client uses Lua 5.1)
   - For macOS that is `brew install lua@5.1`
2. Install [luarocks](https://luarocks.org/)
   - For macOS that is `brew install luarocks`
3. Configure `luarocks` to use the correct Lua version (by default luarocks uses the latest installed Lua version)
   - `luarocks config lua_version 5.1`
4. Install [busted](https://github.com/lunarmodules/busted)
   - `luarocks install busted`
5. Install `bit32`
    - `luarocks install bit32`
6. Install [luacheck](https://github.com/lunarmodules/luacheck)
    - `luarocks install luacheck`

### luacheck

Questie uses `luacheck` for linting. You can run it locally with:

`luacheck -q Database Localization Modules Questie.lua`

### Unit Tests

1. Run `busted -p ".test.lua" .` in the root directory of the project
2. When adding new tests, make sure to name them `<module>.test.lua` and place them next to the module


## Donation
If you'd like to support the development of Questie by donating, you can do so via PayPal:

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JCUBJWKT395ME&source=url"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/></a>

## Features

### Show quests on map
- Show notes for quest start points, turn in points, and objectives.
- Waypoint lines for NPCs showing their pathing.

![Questie Quest Givers](https://i.imgur.com/4abi5yu.png)
![Questie Complete](https://i.imgur.com/DgvBHyh.png)
![Questie Tooltip](https://i.imgur.com/uPykHKC.png)

### Quest Tracker
- Automatically tracks quests on accepting
- Can show all quests from the log at once (instead of default 5)
- Left click quest to open quest log (configurable)
- Right-click for more options, e.g.:
    - Focus quest (makes other quest icons translucent)
    - Point arrow towards objective (requires [TomTom addon](https://www.curseforge.com/wow/addons/tomtom))

![QuestieTracker](https://user-images.githubusercontent.com/8838573/67285596-24dbab00-f4d8-11e9-9ae1-7dd6206b5e48.png)

### Quest Communication
- You can see party members quest progress on the tooltip.

### Tooltips
- Show tooltips on map notes and quest NPCs/objects.
- Holding Shift while hovering over a map icon displays more information, like quest XP.

### Journey Log
- Questie records the steps of your journey in the "My Journey" window. (left-click on minimap button and select the "My Journey" tab or type `/questie journey`)

![Journey](https://user-images.githubusercontent.com/8838573/67285651-3cb32f00-f4d8-11e9-95d8-e8ceb2a8d871.png)

### Quests by Zone
- Questie lists all the quests of a zone divided between completed and available quest. Gotta complete 'em all. (left-click on minimap button (or type `/questie journey`) and select the "Quests by Zone" tab)

![QuestsByZone](https://user-images.githubusercontent.com/8838573/67285665-450b6a00-f4d8-11e9-9283-325d26c7c70d.png)

### Search
- Questie's database can be searched. (left-click on minimap button (or type `/questie journey`) and select the "Advances Search" tab)

![Search](https://user-images.githubusercontent.com/8838573/67285691-4f2d6880-f4d8-11e9-8656-b3e37dce2f05.png)

### Configuration
- Extensive configuration options. (hold shift and left-click on minimap button to open or type `/questie`)


