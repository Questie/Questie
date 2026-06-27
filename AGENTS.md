# AGENTS.md - Questie WoW Addon

Questie is a World of Warcraft Classic addon written in Lua 5.1 that displays quest objectives on the map/minimap. It supports Classic Era, TBC, WotLK, Cata, and MoP.

## Build & Test Commands

### Prerequisites
- Lua 5.1, luarocks, luacheck
- Luarocks packages: `bit32`, `busted`, `luafilesystem`

### Tests (Busted framework)
```bash
# Run all tests
busted -p ".test.lua" .

# Run a single test file
busted Modules/QuestiePlayer.test.lua

# Run tests matching a description pattern
busted -p ".test.lua" --filter "GetPartyMemberByName" .

# Run localization lookup loadstring checks
busted -p ".test.lua" Localization/lookups
```

### Linting (Luacheck)
```bash
luacheck -q -- Database Localization Modules Public Questie.lua
```

### Database Validation (CLI scripts)
```bash
lua cli/validate-era.lua
lua cli/validate-tbc.lua
lua cli/validate-wotlk.lua
lua cli/validate-mop.lua
lua cli/validate-sod.lua
```

> **Note:** Any change to `cli/validators.lua` must be accompanied by a matching test in `cli/validators.test.lua`.

### Build (release packaging)
```bash
python3 build.py --all          # all expansions
python3 build.py --classic      # era only
python3 build.py --release      # omit commit hash from name
```

### Commit Message Prefixes (Changelog)
Commits are automatically categorized in the changelog based on their prefix. Use one of these prefixes at the start of your commit message (case-insensitive):

- `[feature]` - New features → "## New Features"
- `[fix]` - General bug fixes → "## General Fixes"
- `[quest]` - Quest-related fixes → "## Quest Fixes"
- `[db]` - Database fixes → "## Database Fixes"
- `[locale]` - Localization fixes → "## Localization Fixes"

Example: `[fix] Fix journey keybind not working`

## Project Structure

```
Questie.lua          - Main addon entry point (OnInitialize, OnEnable, OnDisable)
Modules/             - Core addon modules (quest tracking, map, tooltips, etc.)
Modules/Libs/        - Internal utility libraries (QuestieLoader, QuestieLib, etc.)
Database/            - Quest/NPC/item/object database and corrections
Database/Corrections/- Per-expansion data fixes applied at runtime
Localization/        - Translation files
Public/              - Public API for other addons
Icons/               - Map/tracker icon assets
Libs/                - Third-party libraries (Ace3, LibStub, etc.)
cli/                 - CLI validation scripts and integration tests
cli/integrationTests/- Integration tests named by GitHub issue number
setupTests.lua       - Test environment setup (mocks WoW API globals)
```

## Code Style

### Module System
Every module uses the `QuestieLoader` system. Only `Questie` and `QuestieLoader` are globals.

**Creating a module** (owning file):
```lua
---@class QuestieTooltips
local QuestieTooltips = QuestieLoader:CreateModule("QuestieTooltips")
local _QuestieTooltips = QuestieTooltips.private
```

**Importing a module** (consumer file):
```lua
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
```

### Standard File Boilerplate
```lua
---@class MyModule
local MyModule = QuestieLoader:CreateModule("MyModule")
local _MyModule = MyModule.private

-------------------------
--Import modules.
-------------------------
---@type OtherModule
local OtherModule = QuestieLoader:ImportModule("OtherModule")

-- Performance: alias frequently used functions
local tinsert = table.insert
local band = bit.band
```

### Formatting
- Indent: 4 spaces (no tabs)
- Line endings: LF
- Quote style: double quotes
- Max line length: 140 (luacheck) / 160 (lua formatter)
- No trailing whitespace (ignored by luacheck but avoid it)

### Type Annotations (LuaCATS / EmmyLua)
Use annotations compatible with the sumneko.lua language server:
```lua
---@class ClassName
---@type ModuleName          -- above every ImportModule call
---@param name type @Description
---@return type @Description
---@field [public|private] fieldName type
```
Custom type aliases: `QuestId`, `NpcId`, `ObjectId`, `ItemId`, `AreaId`, `CoordPair`, etc.

### Naming Conventions
| Category             | Convention         | Example                                    |
|----------------------|--------------------|--------------------------------------------|
| Module names         | PascalCase         | `QuestieTooltips`, `BlacklistFilter`       |
| Local variables      | camelCase          | `tooltipData`, `playerName`                |
| Local functions      | `_` + PascalCase   | `_HelperFunction`, `_CompareSomething`     |
| Module methods       | PascalCase         | `QuestieTooltips:RemoveQuest()`            |
| Private tables       | `_` + PascalCase   | `_QuestieTooltips`, `_EventHandler`        |
| Constants            | UPPER_SNAKE_CASE   | `Questie.DEBUG_CRITICAL`, `MAX_GROUP_SIZE` |
| File names (modules) | PascalCase.lua     | `BlacklistFilter.lua`, `Tooltip.lua`       |
| Test files           | Source + .test.lua | `Tooltip.test.lua`                         |
| Correction files     | camelCase.lua      | `classicQuestFixes.lua`                    |

- Prefixing a function parameter name with `_` means that parameter is unused. Using that parameter anyway will fail `luacheck`

### Error Handling
- `Questie:Error(...)` - red `[ERROR]` prefix, always printed
- `Questie:Warning(...)` - yellow `[WARNING]`, only when debug enabled
- `Questie:Debug(level, ...)` - bitmask levels: `DEBUG_CRITICAL`, `DEBUG_ELEVATED`, `DEBUG_INFO`, `DEBUG_DEVELOP`, `DEBUG_SPAM`
- `xpcall(callback, CallErrorHandler)` for external/public API callbacks
- `pcall` for CLI validation scripts and risky operations
- `error()` for hard input validation failures

### Private vs Public Members
- Public: directly on the module table (`MyModule.field`, `function MyModule:Method()`)
- Private: via `.private` table (`local _MyModule = MyModule.private`)
    - Only use the private table, when the functionality also needs to be available outside the current file. Otherwise, prefer file-local functions/variables.
- File-local: plain `local function helper()` for truly internal code

### Expansion-Specific Code
Use numeric comparison with the `Expansions` module:
```lua
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

if Expansions.Current >= Expansions.Wotlk then
    -- WotLK+ only code
end
```
Constants: `Era=1, Tbc=2, Wotlk=3, Cata=4, MoP=5`. Boolean flags on `Questie`: `IsSoD`, `IsEra`, `IsTBC`, `IsWotlk`, `IsCata`, `IsMoP`, `IsHardcore`.

### Settings

Questie comes with a lot of settings a user can adjust to their liking. All the default values are stored in `Modules/Options/QuestieOptionsDefaults.lua`.

Whenever a new default value is added or an existing setting is adjusted, a matching change function in the `Modules/Migration.lua` is needed. This ensures that existing user
configurations are migrated and correctly updated to the new values.

### Database Corrections
Corrections are keyed by entity ID and use `*Keys` enum tables:
```lua
return {
    [1234] = {  -- questId
        [questKeys.preQuestSingle] = {567},
        [questKeys.requiredRaces] = HORDE_ONLY,
    },
}
```
Corrections load cumulatively in expansion order (Classic -> TBC -> WotLK -> Cata -> MoP).

## Test Conventions (Busted)

```lua
dofile("setupTests.lua")

describe("ModuleToTest", function()
    ---@type ModuleToTest
    local ModuleToTest
    
    ---@type MockedModule
    local MockedModule

    before_each(function()
        MockedModule = QuestieLoader:ImportModule("MockedModule")
        -- Mock some default functions on the mocked module if needed
        MockedModule.SomeFunction = function() return "mocked value" end
    
        dofile("Modules/ModuleToTest.lua")
        ModuleToTest = QuestieLoader:ImportModule("ModuleToTest")
    end)

    describe("MethodName", function()
        it("should do something specific", function()
            -- Mock WoW globals as needed
            _G.SomeWoWAPI = function() return "value" end
            
            -- Override the mocked module's functions if needed for this test case
            MockedModule.SomeFunction = function() return "different mocked value" end

            local result = ModuleToTest:Method()
            assert.are.same(expected, result)
        end)
    end)
end)
```

- Tests live alongside source files as `*.test.lua`
- Integration tests go in `cli/integrationTests/` named by issue number
- Mocking: override `_G.*` globals; use `spy.new()` for call verification
- Assertions: `assert.are.same()`, `assert.is_true()`, `assert.is_nil()`, `assert.spy().was.called_with()`, `assert.has_error()`
- Use `dofile` to load the module under test, not `require` any file
- Use `QuestieLoader` to stub modules, then mock functions called by the module under test. Exceptions are:
  - `l10n`, which should be loaded directly using `dofile("Localization/l10n.lua")`
  - `ContentPhases`, which should be loaded directly using `dofile("Database/Corrections/ContentPhases/ContentPhases.lua")`
  - `QuestieLib`, which CAN be loaded directly, when only pure function of it are required in the test case
- Add `dofile("setupTests.lua")` on top of each unit test file, so that the WoW API globals are mocked and `QuestieLoader` is fresh and available.

## CI Pipeline
CI runs on every push/PR: busted tests, database validators for each expansion, luacheck lint. Test files (`*.test.lua`) are excluded from release builds.

## Translations

Localization files are in `Localization/`.

- The `lookups` directory contains generated lookup tables for quests, NPCs, items, and objects. These are used at runtime to map IDs to localized names.
- The `Translations` directory contains the actual translation files for each supported locale
- Each translation entry is keyed by the English name and contains the localized string, e.g.:
```lua
    ["Human"] = {
        ["enUS"] = true,
        ["deDE"] = "Mensch",
        ["esES"] = "Humano",
        ["esMX"] = "Humano",
        ["frFR"] = "Humain",
        ["koKR"] = "인간",
        ["ptBR"] = "Humano",
        ["ruRU"] = "Человек",
        ["zhCN"] = "人类",
        ["zhTW"] = "人類",
    },
```
- For more complex translations, don't add the translations, but instead mark the entries as `false`. Human translators will take care of this. Example:
```lua
    ["Questie has detected the database to be corrupted. You may type \"/run ReloadUI()\" or \"/reload\" to start the recompiling process when the conditions allow it.\n\nThe process will take 1-2 minutes depending on your configuration."] = {
        ["enUS"] = true,
        ["deDE"] = false,
        ["esES"] = false,
        ["esMX"] = false,
        ["frFR"] = false,
        ["koKR"] = false,
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["zhCN"] = false,
        ["zhTW"] = false,
    },
```
