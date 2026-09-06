# Runtime support-data validation

Questie validates a small set of independently authored controls in the QuestieTDB support data it consumes. This catches incompatible or unexpectedly changed support payloads before Questie reports itself ready. It is a consumer-side compatibility check, not a provider data audit.

## Checkpoints

[`Database/SupportValidation.lua`](../Database/SupportValidation.lua) defines four validators:

- `ValidateZones` checks stable zone IDs, effective map relationships and one dungeon shape after the zone wrapper decodes its maps and applies overrides.
- `ValidateQuestXP` checks raw quest level and XP rows before player-level and buff adjustments.
- `ValidateFactionTemplates` checks faction-template values before QuestieDB binds its composed entity ID maps.
- `ValidateDropTables` checks the selected private-server source, a usable Wowhead percentage, and authored correction rows after the drop wrapper decodes and merges them. The Wowhead control accepts any numeric percentage greater than zero and at most 100 because that rate changes over time.

The validators receive the tables already bound or decoded by the existing wrappers. They do not fetch the support payload again, initialize entity payloads, scan a complete dataset, mutate the inputs, or retain a copy.

Zone and XP validation run during addon-load initialization. A failure there prevents deferred addon-load work and prevents `PLAYER_LOGIN` from scheduling the staged initialization. Faction-template validation runs in Stage 1. Drop validation remains in Stage 3 at the normal `DropDB` initialization point.

## Failure behavior

A failed checkpoint stops subsequent initialization, so `Questie.started` and `Questie.API.isReady` remain false. Questie reports the failure through `Questie.Error` once for that addon instance. The report includes:

- the failed dataset and all failed controls from that validator pass;
- the consumer flavor;
- the provider `readMode`, or `unknown` when unavailable;
- the Questie and QuestieTDB addon versions, or `unknown` when metadata is unavailable.

Initialization stops at the first failed dataset checkpoint. Within that checkpoint, the validator aggregates its failed controls. Validation does not depend on Questie's debug setting.

This validation does not prove that every support-data entry is correct. Entries outside the controls are deliberately unverified, and malformed Lua source that fails during `loadstring` compilation or execution still follows the existing Lua error path before validation. Do not describe this as catching all corruption or as live-client verification.

## Updating controls

The authoritative control values live in [`Database/SupportValidation.lua`](../Database/SupportValidation.lua). Do not duplicate their numeric values in documentation or derive expected values from provider exports. When a legitimate data or mapping change affects a control, review and update that control deliberately, then run:

```bash
busted Database/SupportValidation.test.lua Database/Zones/zoneDB.test.lua Database/QuestXP/QuestieXP.test.lua Database/DropTables/dropDB.test.lua Database/QuestieDB.test.lua Modules/QuestieInit.test.lua
busted -p ".test.lua" .
lua cli/validate-loader-usage.lua
luacheck -q Database Localization Modules Public Questie.lua
```

See [QuestieTDB cutover status](../TDB-STATUS.md) for integration gates and validation history.
