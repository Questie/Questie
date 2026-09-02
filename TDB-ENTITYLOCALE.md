# Entity locale compatibility direction

## Decision status

David is leaning toward removing `Localization/EntityLocale.lua` after external entity locale addons migrate to QuestieTDB's dynamic correction system.

This is a proposed direction, not an approved removal. The existing compatibility path has a known user: [Jakanis/QuestieUkrainianTranslation](https://github.com/Jakanis/QuestieUkrainianTranslation).

The proposal does not remove external Questie UI translations. `QUESTIE_LOCALES_OVERRIDE.locale`, `.localeName`, and `.translations` should remain supported by `Localization/l10n.lua` and the locale options.

## Ownership split

Questie and QuestieTDB own different kinds of translated text:

- `Localization/l10n.lua` owns Questie UI strings, UI locale selection, messages, and settings labels.
- QuestieTDB owns entity strings: Item names, Quest names and objective text, NPC names and subnames, and Object names.

Questie forwards the effective UI locale to the provider with `LibQuestieDB.l10n.SetLocale` in `Modules/QuestieInit.lua`. QuestieTDB supplies built-in entity localization for `deDE`, `esES`, `esMX`, `frFR`, `koKR`, `ptBR`, `ruRU`, `zhCN`, and `zhTW`. Its locale list is in `QuestieTDB/src/config.lua`. English comes from the base entity data.

`ukUA` is not a built-in QuestieTDB locale.

## What EntityLocale does today

`Localization/EntityLocale.lua` is a compatibility adapter for entity lookups attached to the legacy `QUESTIE_LOCALES_OVERRIDE` global. It reads four optional fields:

- `itemLookup`
- `questLookup`
- `npcNameLookup`
- `objectLookup`

`EntityLocale.BuildExternalLocaleCorrections(locale)` accepts lookup functions or tables, rejects an override whose locale does not match the effective locale, and converts the old lookup shapes into QuestieTDB correction rows using QuestieDB's key enums.

It also checks `LibQuestieDB.Item.Exists`, `.Quest.Exists`, `.Npc.Exists`, and `.Object.Exists` before accepting a row. This matters because a QuestieTDB Correction can create an entity. Without the check, an outdated external lookup could create stale name-only entities that then appear in ID maps and composed queries.

`EntityLocale.ApplyExternalLocaleCorrections(locale)` publishes the result through four Questie-owned write-through slots:

| Datatype | Slot |
| --- | --- |
| Item | `ExternalLocaleItem` |
| Quest | `ExternalLocaleQuest` |
| Npc | `ExternalLocaleNpc` |
| Object | `ExternalLocaleObject` |

`Modules/QuestieInit.lua` calls it during Stage 1 after `QuestieCorrections.Initialize()` and before `QuestieDB.Initialize()`.

Current flow:

```text
External locale addon
    |
    | QUESTIE_LOCALES_OVERRIDE
    |   locale, localeName, translations
    |   itemLookup, questLookup, npcNameLookup, objectLookup
    v
Questie
    |-- l10n.lua -> UI translations
    |
    `-- EntityLocale.lua -> Questie-owned Correction slots -> QuestieTDB entities
```

When no external addon defines the global, or its locale is not effective, the four tables are empty and `QuestieCorrections.SetCorrection` treats them as withdrawals or no-ops.

## Known external producer

`Jakanis/QuestieUkrainianTranslation` defines `QUESTIE_LOCALES_OVERRIDE` with `locale = "ukUA"`. It supplies Questie UI translations and entity lookup files for Items, Quests, NPCs, and Objects.

QuestieTDB cannot localize those entities through `LibQuestieDB.l10n.SetLocale("ukUA")` because `ukUA` has no provider locale index. `EntityLocale` currently preserves that addon's entity translations by converting them into Corrections.

There is a lookup-shape mismatch to resolve during migration. The external Quest data appears to use:

```text
{name, description, objectives}
```

`EntityLocale` currently expects:

```text
{name, objectives}
```

That means the current adapter can mistake description lines for objective text. The migration should establish one supported shape rather than carrying both formats forward implicitly.

## Why not move EntityLocale into QuestieTDB

Moving this exact module would make QuestieTDB understand `QUESTIE_LOCALES_OVERRIDE`, a legacy Questie global that mixes UI and entity localization. It would reverse the intended dependency direction and put Questie compatibility policy into the provider.

The entity data should move to the provider seam. The compatibility adapter should not.

## Preferred migration

External entity locale addons should publish their entity rows directly through QuestieTDB's dynamic correction system under their own owner:

```lua
local registrar = LibQuestieDB.GetRegistrar("QuestieUkrainianTranslation")

registrar.RegisterRuntimeCorrection("Item", "ukUA-item-names", buildItemRows, 10)
registrar.RegisterRuntimeCorrection("Quest", "ukUA-quest-text", buildQuestRows, 20)
registrar.RegisterRuntimeCorrection("Npc", "ukUA-npc-names", buildNpcRows, 30)
registrar.RegisterRuntimeCorrection("Object", "ukUA-object-names", buildObjectRows, 40)

registrar.Apply()
```

The builders must return QuestieTDB's correction shape, `entityId -> field key -> value`, using key enums from `LibQuestieDB.Meta`. Large generated lookup tables should stay behind the registered functions until `Apply()` materializes them.

The external addon should remain the Correction owner. This gives QuestieTDB accurate provenance and keeps Questie out of the entity data path.

Target flow:

```text
External locale addon
    |-- QUESTIE_LOCALES_OVERRIDE
    |     locale, localeName, translations
    |                |
    |                `-> Questie l10n.lua -> UI strings
    |
    `-- QuestieTDB dynamic Corrections -> entity strings
```

No new QuestieTDB locale interface is required for this migration. The existing `LibQuestieDB.GetRegistrar(owner)`, `RegisterRuntimeCorrection`, and `Apply` interface is sufficient if the addon preserves locale activation and withdrawal behavior.

## Requirements before removal

Coordinate the change with `QuestieUkrainianTranslation` before deleting the adapter. The migrated addon must:

1. Publish Item, Quest, NPC, and Object rows through its own QuestieTDB registrar.
2. Apply entity rows only when `ukUA` is the effective Questie locale, and withdraw or avoid them for other locales.
3. Register and apply at a point that preserves the current startup order before Questie consumes the composed database.
4. Use QuestieTDB's key enums and correction row shapes.
5. Filter unknown IDs unless creating a new entity is intentional, so stale locale data cannot create name-only entities.
6. Resolve the Quest description/objective lookup mismatch.
7. Keep `QUESTIE_LOCALES_OVERRIDE.locale`, `.localeName`, and `.translations` for Questie UI localization.

Removing `EntityLocale` before that migration would leave Ukrainian UI strings working but make Ukrainian entity names fall back to English.

## Removal scope after migration

Once the external addon migration is released and verified, remove only the entity compatibility path:

- `Localization/EntityLocale.lua`
- `Localization/EntityLocale.test.lua`
- `Localization\EntityLocale.lua` from every expansion TOC
- the `EntityLocale` import and `ApplyExternalLocaleCorrections` call in `Modules/QuestieInit.lua`
- affected initialization tests
- the entity lookup fields from the documented `QUESTIE_LOCALES_OVERRIDE` contract

Keep the UI override path in `Localization/l10n.lua` and `Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua`.
