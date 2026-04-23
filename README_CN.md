# Questie

[![Discord](https://img.shields.io/badge/discord-Questie-738bd7)](https://discord.gg/s33MAYKeZd)
[![Stars](https://img.shields.io/github/stars/Questie/Questie)](https://img.shields.io/github/stars/Questie/Questie)

[![Downloads](https://img.shields.io/github/downloads/Questie/Questie/total.svg)](https://github.com/Questie/Questie/releases/)
[![Downloads Latest](https://img.shields.io/github/downloads/Questie/Questie/v11.25.0/total.svg)](https://github.com/Questie/Questie/releases/latest)
[![Date Latest](https://img.shields.io/github/release-date/Questie/Questie.svg)](https://github.com/Questie/Questie/releases/latest)
[![Commits Since Latest](https://img.shields.io/github/commits-since/Questie/Questie/latest.svg)](https://github.com/Questie/Questie/commits/master)

## 语言版本
- [中文版本](README_CN.md)
- [English version](README.md)

## 下载
我们一般建议您使用 [CurseForge 客户端](https://curseforge.overwolf.com/) 来管理您的《魔兽世界》插件。您可以在 [CurseForge 上的此链接](https://www.curseforge.com/wow/addons/questie) 找到 Questie 插件。

另外，您也可以始终使用 [最新的 GitHub 版本](https://github.com/Questie/Questie/releases/latest) 并按照维基中的 [安装指南](https://github.com/Questie/Questie/wiki/Installation-Guide) 来安装并运行 Questie 的最新版本。

如果您遇到问题，请阅读 [常见问题解答](https://github.com/Questie/Questie/wiki/FAQ-for-Classic-(1.13)) 。


## 信息
- [常见问题解答](https://github.com/Questie/Questie/wiki/FAQ)
- 快来 [我们的 Discord 服务器](https://discord.gg/s33MAYKeZd) 和我们一起聊天。
- 您可以使用 [问题追踪器](https://github.com/Questie/Questie/issues) 来报告漏洞并提出功能请求（需要一个 GitHub 账号）。
- 创建问题时，请遵循模板结构，以便可能的修复能加快进程。
- 如果您从《魔兽世界》客户端收到错误信息，请在报告中附上**完整**的文本内容或截图。
    - 您需要在游戏内聊天框中输入一次`/console scriptErrors 1` 才能显示 Lua 错误信息。之后您可以使用`/console scriptErrors 0`再次禁用错误显示。

相信我们，这（很有用）！

## 语言

Questie 拥有《魔兽世界》经典怀旧服所有官方语言的翻译版本。具体如下：

英语、德语、法语、西班牙语、葡萄牙语、俄语、简体中文、繁体中文和韩语。

如果您想帮忙进行翻译工作，可以查看 [翻译文件夹](https://github.com/Questie/Questie/tree/master/Localization/Translations) 并通过以下方式查找缺失的翻译内容：
> `["<您的语言>"] = false` (例如`["deDE"] = false`)然后将`false` 替换为新的翻译字符串，例如`["<您的语言>"] = "您的翻译内容"`。

除此之外，它还支持乌克兰语 ([通过另一款插件](https://www.curseforge.com/wow/addons/questie-translation-ukrainian)) 。
按照 [本指南](https://github.com/Questie/Questie/wiki/Localization-to-more-languages) 您甚至可以添加对更多语言的支持。

## 贡献

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
- 我们对所获得的每一份帮助与贡献都深表感激，所以请随意在 GitHub 上提交拉取请求。
- 您可能感兴趣的更多信息可在 [此处](https://github.com/Questie/Questie/wiki/Contributing)找到 。

### 安装 Lua

1. 安装 [Lua](https://www.lua.org/download.html) (5.1, 因为《魔兽世界》客户端使用 Lua 5.1)
   - 对于 macOS 系统，使用命令`brew install lua@5.1`
2. 安装 [luarocks](https://luarocks.org/)
   - 对于 macOS 系统，使用命令`brew install luarocks`
3. 配置 `luarocks` 以使用正确的 Lua 版本（默认情况下，luarocks 使用最新安装的 Lua 版本）
   - `luarocks config lua_version 5.1`
4. 安装 [busted](https://github.com/lunarmodules/busted)
   - `luarocks install busted`
5. 安装 `bit32`
    - `luarocks install bit32`
6. 安装 [luacheck](https://github.com/lunarmodules/luacheck)
    - `luarocks install luacheck`

### luacheck

Questie 使用 `luacheck`进行代码规范检查。你可以在本地运行此命令：

`luacheck -q Database Localization Modules Questie.lua`

### 单元测试

1. 在项目根目录中运行 `busted -p ".test.lua" .`
2. 添加新测试时，确保将测试文件命名为 `<模块名>.test.lua` 并将其放置在对应模块旁。

### 数据库验证

每个扩展包都有一个验证脚本，用于检查数据库中常见的错误。通过这种方式，我们尽量保证数据的正确性，并且当我们调整 `Quest.startedBy` 时，不会忘记调整 `NPC.questStarts` 字段。你可以运行以下脚本：

`lua cli/validate-<扩展包名>.lua`

将 `<扩展包名>` 替换为你想要验证的扩展包名称 (可查看 `cli` 文件夹获取可用脚本).

## 捐赠
如果您想通过捐赠来支持 Questie 的开发，您可以通过贝宝（PayPal）进行捐赠：

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JCUBJWKT395ME&source=url"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/></a>

## 将 Questie 集成到您的插件中

查看 [Questie API 的 README 文档](./Public/README.md).

## 功能特性

### 在地图上显示任务
- 显示任务起始点、交付点和目标的标注。
- 为非玩家角色（NPC）显示其行动路线的路径指引线。

![Questie Quest Givers](https://i.imgur.com/4abi5yu.png)
![Questie Complete](https://i.imgur.com/DgvBHyh.png)
![Questie Tooltip](https://i.imgur.com/uPykHKC.png)

### 任务追踪器
- 接受任务时自动追踪
- 可一次性显示任务日志中的所有任务（而非默认的 5 个）
- 左键点击任务可打开任务日志（可配置）
- 右键点击可获取更多选项，例如：
    - 聚焦任务（使其他任务图标半透明）
    - 箭头指向任务目标 (需安装 [TomTom 插件](https://www.curseforge.com/wow/addons/tomtom))

![QuestieTracker](https://user-images.githubusercontent.com/8838573/67285596-24dbab00-f4d8-11e9-9ae1-7dd6206b5e48.png)

### 任务交流
- 你可以在工具提示中查看队友的任务进度。

### 工具提示
- 在地图标注以及任务相关的NPC / 物体上显示工具提示。
- 鼠标悬停在地图图标上时按住 Shift 键，会显示更多信息，比如任务经验值。

### 旅程日志
- Questie 会在 “我的旅程” 窗口中记录你旅程的各个步骤。(左键点击小地图按钮，选择 “我的旅程” 标签，或者输入 `/questie journey`)

![Journey](https://user-images.githubusercontent.com/8838573/67285651-3cb32f00-f4d8-11e9-95d8-e8ceb2a8d871.png)

### 按地区查询
- Questie 会列出某个区域内已完成和可接取的所有任务，一项都别错过。 (左键点击小地图按钮 (或者输入 `/questie journey`) 然后选择 “按地区查询” 标签)

![QuestsByZone](https://user-images.githubusercontent.com/8838573/67285665-450b6a00-f4d8-11e9-9283-325d26c7c70d.png)

### 搜索
- 可以搜索 Questie 的数据库。(左键点击小地图按钮 (或者输入 `/questie journey`) 然后选择 “高级搜索” 标签)

![Search](https://user-images.githubusercontent.com/8838573/67285691-4f2d6880-f4d8-11e9-8656-b3e37dce2f05.png)

### 配置
- 丰富的配置选项。 (按住 Shift 键并左键点击小地图按钮打开，或者输入 `/questie`)