# 2. Questie publishes Policy Corrections; the provider owns entity facts

Date: 2026-09-01. Status: accepted. Provider side: QuestieTDB ADR 0007 and 0009.

Some entity values depend on state only Questie has: which Darkmoon Faire location the calendar
selected, the active TBC Content Phase, the display policy that hides gathering nodes, and Item
names the client loads asynchronously. QuestieTDB must not learn Questie's calendar, settings, or
lifecycle, so Questie writes those values itself as Corrections under owner `"Questie"`.

Ownership follows the information needed to choose the value. Anything QuestieTDB can decide from
facts it owns (class, race, faction, expansion, season, SoD, Titan Reforged) is provider data, and
Questie publishes no copies. Blacklists, hidden quests, event visibility, and availability checks are
Questie display policy, not Corrections; they decide what Questie shows, not what an entity is.

Each Questie Correction is a named data slot written through `QuestieCorrections.SetCorrection`
(`LibQuestieDB.Corrections.Set`). The write publishes immediately, a rewrite replaces the slot, and
`nil` withdraws it. Slot state lives with the module that owns the input: `QuestieEvent` writes
Darkmoon, `QuestieLib` accumulates Item repairs. The earlier shape, a central registrar with load
orders, captured locals, provider closures, and one setter per Correction, was rejected because
every new Correction cost five artifacts in a module that did not own the state, and because a full
owner re-apply re-materialized every provider layer on each write.

`QuestieDB.RefreshAfterCorrectionApply(datatype, changedIds)` evicts only the touched entities.
Quest objects are evicted by ID rather than wiped wholesale because the tracker, quest log, and map
icons hold the object `GetQuest` returned and update it in place; a blanket wipe would split that
identity.
