# Questie consumes its database rather than owning it

Questie owned its raw entity data and a bespoke binary compiler that rebuilt the database
into SavedVariables at login, which meant every correction or data fix required a full
Questie release, and every addon-version, expansion, or **UI locale** change triggered an
in-game recompile that was the slowest part of startup. The database — raw entity data,
schema, data corrections, entity localization, and support data — moves into a separate
project, QuestieTDB, and Questie consumes it through a small query API.

## Consequences

- Questie declares a hard `## Dependencies` on QuestieTDB. The client covers absence; a
  contract-version check in Questie covers "present but incompatible".
- Data and correction fixes ship on QuestieTDB's release cadence, independent of Questie's.
- `Database/compiler.lua`, the SavedVariables database, the parallel Season of Discovery
  database, and the whole `dbIsCompiled` / `dbCompiledLang` recompile path are removed.
- Questie keeps everything that decides *what to do* with the data: the `QuestieDB.lua`
  semantic layer, blacklists, and policy corrections that read `Questie.db`. Hiding an
  entity is consumer policy, not a database fact, so blacklists deliberately stay here.
- Questie retains the ability to register corrections, through QuestieTDB's public API —
  which is also the path third-party addons use.
