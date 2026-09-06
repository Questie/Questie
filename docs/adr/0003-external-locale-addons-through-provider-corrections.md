# 3. External translation addons reach entity names through provider localization

Date: 2026-09-02. Status: accepted.

Third-party translation addons such as QuestieUkrainianTranslation define the
`QUESTIE_LOCALES_OVERRIDE` global with UI strings and optional entity lookups (`itemLookup`,
`questLookup`, `npcNameLookup`, `objectLookup`). QuestieTDB has no generated Base block for such
custom languages, so the external lookups are their source of translated entity names.

Questie keeps reading the upstream global unchanged, so one translation-addon build serves upstream
Questie and this branch. `l10n.InitializeUILocale` handles only UI locale selection and strings.
During Login Initialization, Questie requires QuestieTDB Contract Version 2 and checks that
`LibQuestieDB.l10n.SetCorrection` exists. It then forwards the effective UI locale and calls
`l10n.PublishLocaleOverrideEntityNames` before Questie initializes its entity projections.

The publisher converts each lookup to rows keyed by QuestieTDB's numeric entity field indexes. It
writes one slot per entity type through `LibQuestieDB.l10n.SetCorrection` under owner
`QuestieLocalesOverride` and name `EntityNames`. It accepts both Quest lookup shapes:
`{name, objectives}` and the older `{name, description, objectives}`. A present third slot is the
only objective source for the older shape, even when malformed, so the description cannot be
mistaken for objective text.

Only IDs that already exist in the composed database are admitted. Malformed lookup entries are
skipped. Empty or malformed fields are omitted while other valid fields in the same row can still
publish. `enUS` overrides are skipped.
Re-publishing replaces all four named slots, including withdrawing a slot whose lookup became empty.
Removing the external global or changing its locale withdraws the previous locale's slots without
touching other slot names under the owner.

The external locale does not have to be active when published. QuestieTDB stores the locale-specific
slots so a later `SetLocale` can select them. This supports custom locale strings such as `ukUA`
without adding generated Base blocks or changing the provider's nine-entry `localeIndex`. Missing
custom-locale fields fall through to corrected or base English values. This behavior depends on the
provider revision that accepts any non-empty `SetCorrection` locale except `enUS`; Questie fails its
capability gate instead of silently using the old entity-Correction path.

Two alternatives remain rejected. A separate `EntityLocale` module was written and removed because
it was a pass-through around one publisher. Moving the adapter into QuestieTDB would make the
provider understand a legacy Questie global that mixes UI and entity localization, reversing the
dependency direction.

The preferred long-term path is for translation addons to publish through
`LibQuestieDB.l10n.SetCorrection` under their own owner and stop using the entity lookup fields.
Questie should remove its compatibility adapter once known addons use that interface.
