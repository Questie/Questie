# 1. QuestieTDB is the only entity database

Date: 2026-08-25. Status: accepted.

Questie used to ship raw Quest, NPC, Item, and Object tables per expansion, generated entity
localization, static correction files, and a runtime compiler that baked them into SavedVariables.
That was about five million lines that changed with every data fix and had to be recompiled on
every locale or version change.

Entity data, static corrections, entity localization, and Objective Order now belong to the
QuestieTDB addon, declared as a hard `RequiredDeps` in every flavor TOC. Questie gates on
`LibQuestieDB.RequireContract(1)` at Login Initialization and reads only the composed view. The
`QuestieDB` module stays as Questie's interface: rich projections, availability and player-state
policy, blacklists, quest tags, and semantic caches remain Questie's.

There is no compiler fallback, feature flag, or dual backend. A missing or incompatible provider is
a hard error, not a degraded mode. Keeping a fallback would have meant keeping the data it reads,
which is the thing being removed.

Support data (`Database/Zones`, `QuestXP`, `DropTables`, `FactionTemplates`) is still Questie-owned
until QuestieTDB #15 proves the provider copies are flavor-correct.
