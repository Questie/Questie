# 3. External translation addons reach entity names through provider Corrections

Date: 2026-09-02. Status: accepted.

Third-party translation addons such as QuestieUkrainianTranslation define the
`QUESTIE_LOCALES_OVERRIDE` global with UI strings and optional entity lookups (`itemLookup`,
`questLookup`, `npcNameLookup`, `objectLookup`). QuestieTDB has no built-in locale for such
languages, so the lookups are the only source of translated entity names.

Questie keeps reading the upstream contract unchanged, so one addon build serves upstream Questie and
this branch. `l10n.InitializeUILocale` applies the UI strings itself and forwards the entity lookups
to `LibQuestieDB.Corrections.Set` under the owner `QuestieLocalesOverride`, only when the override
locale is the effective one, and only for IDs the composed database already has. The existence
filter matters because a Correction can create an entity; stale lookup data must not create
name-only entities that then appear in ID maps.

Two alternatives were rejected. A separate `EntityLocale` module was written and removed: it was a
pass-through with one real function, and Login Initialization is the only production path because
locale changes reload the UI. Moving the adapter into QuestieTDB was rejected because it would make
the provider understand a legacy Questie global that mixes UI and entity localization, reversing the
dependency direction.

The preferred long-term path for such addons is to publish rows through their own
`LibQuestieDB.GetRegistrar(owner)` and stop using the entity lookup fields. Questie should not carry
both formats when that happens. Known wart: generators built before upstream dropped the quest
description element still emit `{name, {description}, {objectives}}`; Questie reads objectives from
index 3 when present so that data stays correct.
