---@meta _

--------------------------------------------------------------------------------
-- Public primitives
--------------------------------------------------------------------------------

-- Shared with Questie's declarations; keep definitions here so QuestieDB also type-checks alone.
---@alias QuestId number
---@alias NpcId number
---@alias ItemId number
---@alias ObjectId number
---@alias AreaId number
---@alias FactionId number
---@alias SkillId number

---@alias QuestieDBCanonicalDatatype "Quest"|"Npc"|"Item"|"Object"
---@alias QuestieDBDatatype QuestieDBCanonicalDatatype|"quest"|"npc"|"item"|"object"
---@alias QuestieDBReadMode "source"|"baked"

---@alias QuestieDBQuestField "name"|"startedBy"|"finishedBy"|"requiredLevel"|"questLevel"|"requiredRaces"|"requiredClasses"|"objectivesText"|"triggerEnd"|"objectives"|"sourceItemId"|"preQuestGroup"|"preQuestSingle"|"childQuests"|"inGroupWith"|"exclusiveTo"|"zoneOrSort"|"requiredSkill"|"requiredMinRep"|"requiredMaxRep"|"requiredSourceItems"|"nextQuestInChain"|"questFlags"|"specialFlags"|"parentQuest"|"reputationReward"|"breadcrumbForQuestId"|"breadcrumbs"|"extraObjectives"|"requiredSpell"|"requiredSpecialization"|"requiredMaxLevel"|"availableUntilCompleted"|"availableStartingWith"|"requiredRanks"|"disabledByQuest"
---@alias QuestieDBNpcField "name"|"minLevelHealth"|"maxLevelHealth"|"minLevel"|"maxLevel"|"rank"|"spawns"|"waypoints"|"zoneID"|"questStarts"|"questEnds"|"factionID"|"friendlyToFaction"|"subName"|"npcFlags"
---@alias QuestieDBItemField "name"|"npcDrops"|"objectDrops"|"itemDrops"|"startQuest"|"questRewards"|"flags"|"foodType"|"itemLevel"|"requiredLevel"|"ammoType"|"class"|"subClass"|"vendors"|"relatedQuests"|"teachesSpell"
---@alias QuestieDBObjectField "name"|"questStarts"|"questEnds"|"spawns"|"zoneID"|"factionID"|"waypoints"

--------------------------------------------------------------------------------
-- Shared read shapes
--------------------------------------------------------------------------------

---@alias QuestieDBCoordinate {[1]: number, [2]: number, [3]: number?} Coordinates plus an optional phase.
---@alias QuestieDBWaypoint {[1]: number, [2]: number} A waypoint never carries a phase.
---@alias QuestieDBSpawnList table<AreaId, QuestieDBCoordinate[]>
---@alias QuestieDBWaypointList table<AreaId, QuestieDBWaypoint[][]>

---@alias QuestieDBStartedBy {[1]: NpcId[]?, [2]: ObjectId[]?, [3]: ItemId[]?}
---@alias QuestieDBFinishedBy {[1]: NpcId[]?, [2]: ObjectId[]?}

---@alias QuestieDBSkillPair {[1]: SkillId, [2]: number}
---@alias QuestieDBSkillRankPair {[1]: SkillId, [2]: number}
---@alias QuestieDBReputationPair {[1]: FactionId, [2]: number}

---@alias QuestieDBCreatureObjective {[1]: NpcId, [2]: string?, [3]: number}
---@alias QuestieDBObjectObjective {[1]: ObjectId, [2]: string?, [3]: number}
---@alias QuestieDBItemObjective {[1]: ItemId, [2]: string?, [3]: number}
---@alias QuestieDBKillCreditObjective {[1]: NpcId[], [2]: NpcId, [3]: string?, [4]: number}
---@alias QuestieDBSpellObjective {[1]: number, [2]: string?, [3]: ItemId}
---@alias QuestieDBObjectives {[1]: QuestieDBCreatureObjective[]?, [2]: QuestieDBObjectObjective[]?, [3]: QuestieDBItemObjective[]?, [4]: QuestieDBReputationPair?, [5]: QuestieDBKillCreditObjective[]?, [6]: QuestieDBSpellObjective[]?}

---Objective-ordering hints are the mutable sets populated while Corrections load.
---Consumers receive those same tables as read-only data and must not mutate them.
---@class QuestieDBObjectiveFirst
---@field killCreditObjectiveFirst table<QuestId, true>
---@field objectObjectiveFirst table<QuestId, true>
---@field itemObjectiveFirst table<QuestId, true>
---@field eventObjectiveFirst table<QuestId, true>
---@field spellObjectiveFirst table<QuestId, true>

---@alias QuestieDBTrigger {[1]: string, [2]: QuestieDBSpawnList}
---@alias QuestieDBReference
---| {[1]: "monster", [2]: NpcId}
---| {[1]: "item", [2]: ItemId}
---| {[1]: "object", [2]: ObjectId}
---@alias QuestieDBExtraObjective {[1]: QuestieDBSpawnList?, [2]: number, [3]: string?, [4]: number, [5]: QuestieDBReference[]?}

---@class QuestieDBPackedValues
---@field n integer Number of requested fields, including nil slots.
---@field [integer] any

--------------------------------------------------------------------------------
-- Localization
--------------------------------------------------------------------------------

---@alias QuestieDBLocalizedValue string|string[]
---@alias QuestieDBL10nProvider fun(id: number, entityFieldIndex: integer): QuestieDBLocalizedValue?, string?
---@alias QuestieDBL10nScalarFields table<integer, true>
---@alias QuestieDBL10nIsActive fun(): boolean
---@alias QuestieDBLocaleChangedCallback fun(locale: string)
---@alias QuestieDBTranslationLocale string Non-empty locale other than enUS; custom locales need no Baked blocks.
---@alias QuestieDBTranslationRows table<integer, table<integer, QuestieDBLocalizedValue>>
---@alias QuestieDBL10nFieldName "name"|"objectivesText"|"subName"
---@alias QuestieDBEntity QuestDB|NpcDB|ItemDB|ObjectDB

---@class QuestieDBL10nField
---@field name QuestieDBL10nFieldName Canonical entity field carrying translations.
---@field list? true The Localization block column contains string lists instead of scalar strings.

---Localization state and dot-called controls. Missing translations fall back to corrected entity data.
---@class QuestieDBL10n
---@field locales string[] Configured non-English locales with Baked Localization blocks.
---@field localeIndex table<string, integer> Stored locale to stable configuration index; enUS is absent.
---@field currentLocale string Active locale; enUS selects base entity data.
---@field currentIndex? integer Configuration index for a stored locale; nil for enUS or a custom locale.
---@field onLocaleChanged QuestieDBLocaleChangedCallback[] Callbacks invoked after cache invalidation with the selected locale.
---@field available boolean Whether the artifact declares Localization blocks.
---@field fields table<QuestieDBCanonicalDatatype, QuestieDBL10nField[]> Localized field coverage by entity type.
---@field CreateProvider fun(meta: QuestieDBEntitySchema, entity: QuestieDBEntity): QuestieDBL10nProvider?, QuestieDBL10nScalarFields?, QuestieDBL10nIsActive? Build a provider over active columns plus Baked scalar-row cache hints, or nil when the entity type has no translatable fields.
---@field Initialize fun() Attach available providers and select the client locale.
---@field DetectLocale fun(): string Return the client locale, or enUS outside the client.
---@field SetLocale fun(locale?: string): string Select and eagerly decode a changed locale, defaulting nil to enUS, then invalidate entity caches; selecting the active locale is a no-op.
---@field IsAvailable fun(): boolean Test whether the artifact contains base Localization blocks; dynamic translations also work in Source mode.
---@field SetCorrection fun(owner: string, locale: QuestieDBTranslationLocale, datatype: QuestieDBDatatype, name: string, rows: QuestieDBTranslationRows?): boolean Snapshot and publish a translation slot; nil withdraws it. Accepts custom non-English locales and only translatable entity field indices.
---@field GetProvenance fun(datatype: QuestieDBDatatype, id: number, key: string|integer): string? Return the active translation owner, or nil when entity fallback supplies the value.

--------------------------------------------------------------------------------
-- Corrections
--------------------------------------------------------------------------------

---@alias QuestieDBCorrectionFields table<integer, any>
---@alias QuestieDBCorrections table<number, QuestieDBCorrectionFields>
---@alias QuestieDBCorrectionProvider fun(): QuestieDBCorrections

---@class QuestieDBCorrectionEntry
---@field owner string
---@field datatype QuestieDBCanonicalDatatype
---@field name string
---@field func QuestieDBCorrectionProvider? Provider of a function-shaped entry; absent on a data slot.
---@field data QuestieDBCorrections? Rows of a data slot written through Set; absent on a function entry.
---@field materialized QuestieDBCorrections? Memoized provider result; cleared by the owner's own apply.
---@field loadOrder number
---@field sequence integer Registration order used to break load-order ties.
---@field dynamic boolean
---@field expansions table<string, boolean>? Expansion allow-list for built-in correction sets.
---@field minExpansionOrder number? Earliest expansion for a built-in correction set.
---@field sourceExpansionOrder number? Source expansion used when adapting built-in options.
---@field options table<string, any>? Options passed to built-in correction sets.

---@class QuestieDBRegistrar
---@field owner string
---@field RegisterCorrection fun(datatype: QuestieDBDatatype, name: string, func: QuestieDBCorrectionProvider, loadOrder?: number): QuestieDBCorrectionEntry
---@field RegisterRuntimeCorrection fun(datatype: QuestieDBDatatype, name: string, func: QuestieDBCorrectionProvider, loadOrder?: number): QuestieDBCorrectionEntry
---@field Apply fun(): integer
---@field Set fun(datatype: QuestieDBDatatype, name: string, rows: QuestieDBCorrections?): boolean Write-through data slot; nil rows removes it.

---@class QuestieDBCorrectionsAPI
---@field OWNER string QuestieDB's correction owner name.
---@field debug boolean Log when one owner overrides another on the same field.
---@field CanonicalDatatype fun(datatype: QuestieDBDatatype): QuestieDBCanonicalDatatype? Normalize a supported datatype spelling.
---@field RegisterCorrection fun(owner: string, datatype: QuestieDBDatatype, name: string, func: QuestieDBCorrectionProvider, loadOrder?: number): QuestieDBCorrectionEntry
---@field RegisterRuntimeCorrection fun(owner: string, datatype: QuestieDBDatatype, name: string, func: QuestieDBCorrectionProvider, loadOrder?: number): QuestieDBCorrectionEntry
---@field UnregisterCorrection fun(owner: string, datatype: QuestieDBDatatype, name: string): boolean
---@field GetRegistrar fun(owner: string): QuestieDBRegistrar
---@field ApplyRegisteredCorrections fun(owner?: string): integer
---@field Set fun(owner: string, datatype: QuestieDBDatatype, name: string, rows: QuestieDBCorrections?): boolean Write-through data slot; nil rows removes it.
---@field GetProvenance fun(datatype: QuestieDBDatatype, id: number, key: string|integer): string?
---@field GetOwners fun(): string[]
