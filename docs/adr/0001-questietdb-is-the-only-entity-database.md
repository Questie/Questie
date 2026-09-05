# 1. QuestieTDB is the only entity database

Date: 2026-08-25. Status: accepted.

Questie used to ship raw Quest, NPC, Item, and Object tables per expansion, generated entity
localization, static correction files, and a runtime compiler that baked them into SavedVariables.
That was about five million lines that changed with every data fix and had to be recompiled on
every locale or version change.

Entity data, static corrections, entity localization, support data, and Objective Order now belong
to the QuestieTDB addon, declared as a hard `RequiredDeps` in every flavor TOC. Questie requires
Contract Version 2 at Login Initialization and separately checks for
`LibQuestieDB.l10n.SetCorrection` before forwarding a locale or publishing external entity
translations. The `QuestieDB` module stays as Questie's interface: rich projections, availability
and player-state policy, blacklists, quest tags, semantic caches, and support-data wrapper functions
remain Questie's.

There is no compiler fallback, feature flag, or dual backend. A missing or incompatible provider is
a hard error, not a degraded mode. Keeping a fallback would have meant keeping the data it reads,
which is the thing being removed.

Questie reads Zone, Quest XP, drop, and faction-template payloads through
`LibQuestieDB.Support`. The local payload files remain in the source tree for now but are no longer
loaded by the flavor TOCs. Questie owns the wrappers and any decoded or merged tables it mutates.
Mists keeps the established mixed drop sources: Mists Wowhead data and Cata private-server data.
