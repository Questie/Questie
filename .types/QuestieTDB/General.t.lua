---@meta _

--------------------------------------------------------------------------------
-- Public primitives
--------------------------------------------------------------------------------

-- Shared with Questie's declarations; keep definitions here so QuestieTDB also type-checks alone.
---@alias QuestId number
---@alias NpcId number
---@alias ItemId number
---@alias ObjectId number
---@alias AreaId number
---@alias FactionId number
---@alias SkillId number

---@alias QuestieTDBCanonicalDatatype "Quest"|"Npc"|"Item"|"Object"
---@alias QuestieTDBDatatype QuestieTDBCanonicalDatatype|"quest"|"npc"|"item"|"object"
---@alias QuestieTDBReadMode "source"|"baked"

---@alias QuestieTDBQuestField "name"|"startedBy"|"finishedBy"|"requiredLevel"|"questLevel"|"requiredRaces"|"requiredClasses"|"objectivesText"|"triggerEnd"|"objectives"|"sourceItemId"|"preQuestGroup"|"preQuestSingle"|"childQuests"|"inGroupWith"|"exclusiveTo"|"zoneOrSort"|"requiredSkill"|"requiredMinRep"|"requiredMaxRep"|"requiredSourceItems"|"nextQuestInChain"|"questFlags"|"specialFlags"|"parentQuest"|"reputationReward"|"breadcrumbForQuestId"|"breadcrumbs"|"extraObjectives"|"requiredSpell"|"requiredSpecialization"|"requiredMaxLevel"|"availableUntilCompleted"|"availableStartingWith"|"requiredRanks"|"disabledByQuest"
---@alias QuestieTDBNpcField "name"|"minLevelHealth"|"maxLevelHealth"|"minLevel"|"maxLevel"|"rank"|"spawns"|"waypoints"|"zoneID"|"questStarts"|"questEnds"|"factionID"|"friendlyToFaction"|"subName"|"npcFlags"
---@alias QuestieTDBItemField "name"|"npcDrops"|"objectDrops"|"itemDrops"|"startQuest"|"questRewards"|"flags"|"foodType"|"itemLevel"|"requiredLevel"|"ammoType"|"class"|"subClass"|"vendors"|"relatedQuests"|"teachesSpell"
---@alias QuestieTDBObjectField "name"|"questStarts"|"questEnds"|"spawns"|"zoneID"|"factionID"|"waypoints"

--------------------------------------------------------------------------------
-- Shared read shapes
--------------------------------------------------------------------------------

---@alias QuestieTDBCoordinate {[1]: number, [2]: number, [3]: number?} Coordinates plus an optional phase.
---@alias QuestieTDBWaypoint {[1]: number, [2]: number} A waypoint never carries a phase.
---@alias QuestieTDBSpawnList table<AreaId, QuestieTDBCoordinate[]>
---@alias QuestieTDBWaypointList table<AreaId, QuestieTDBWaypoint[][]>

---@alias QuestieTDBStartedBy {[1]: NpcId[]?, [2]: ObjectId[]?, [3]: ItemId[]?}
---@alias QuestieTDBFinishedBy {[1]: NpcId[]?, [2]: ObjectId[]?}

---@alias QuestieTDBSkillPair {[1]: SkillId, [2]: number}
---@alias QuestieTDBSkillRankPair {[1]: SkillId, [2]: number}
---@alias QuestieTDBReputationPair {[1]: FactionId, [2]: number}

---@alias QuestieTDBCreatureObjective {[1]: NpcId, [2]: string?, [3]: number}
---@alias QuestieTDBObjectObjective {[1]: ObjectId, [2]: string?, [3]: number}
---@alias QuestieTDBItemObjective {[1]: ItemId, [2]: string?, [3]: number}
---@alias QuestieTDBKillCreditObjective {[1]: NpcId[], [2]: NpcId, [3]: string?, [4]: number}
---@alias QuestieTDBSpellObjective {[1]: number, [2]: string?, [3]: ItemId}
---@alias QuestieTDBObjectives {[1]: QuestieTDBCreatureObjective[]?, [2]: QuestieTDBObjectObjective[]?, [3]: QuestieTDBItemObjective[]?, [4]: QuestieTDBReputationPair?, [5]: QuestieTDBKillCreditObjective[]?, [6]: QuestieTDBSpellObjective[]?}

---Objective-ordering hints are the mutable sets populated while Corrections load.
---Consumers receive those same tables as read-only data and must not mutate them.
---@class QuestieTDBObjectiveFirst
---@field killCreditObjectiveFirst table<QuestId, true>
---@field objectObjectiveFirst table<QuestId, true>
---@field itemObjectiveFirst table<QuestId, true>
---@field eventObjectiveFirst table<QuestId, true>
---@field spellObjectiveFirst table<QuestId, true>

---@alias QuestieTDBTrigger {[1]: string, [2]: QuestieTDBSpawnList}
---@alias QuestieTDBReference
---| {[1]: "monster", [2]: NpcId}
---| {[1]: "item", [2]: ItemId}
---| {[1]: "object", [2]: ObjectId}
---@alias QuestieTDBExtraObjective {[1]: QuestieTDBSpawnList?, [2]: number, [3]: string?, [4]: number, [5]: QuestieTDBReference[]?}

---@class QuestieTDBPackedValues
---@field n integer Number of requested fields, including nil slots.
---@field [integer] any

--------------------------------------------------------------------------------
-- Localization
--------------------------------------------------------------------------------

---@alias QuestieTDBLocalizedValue string|string[]
---@alias QuestieTDBL10nProvider fun(id: number, entityFieldIndex: integer): QuestieTDBLocalizedValue?
---@alias QuestieTDBLocaleChangedCallback fun(locale: string)
---@alias QuestieTDBL10nFieldName "name"|"objectivesText"|"subName"

---@class QuestieTDBL10nField
---@field name QuestieTDBL10nFieldName Canonical entity field carrying translations.
---@field list? true The localized segment decodes to a string list instead of a scalar string.

---Localization state and dot-called controls. Missing translations fall back to base entity data.
---@class QuestieTDBL10n
---@field locales string[] Configured non-English locale order used by Baked metadata segments.
---@field separator string Separator between locale segments in a Metadata field.
---@field localeIndex table<string, integer> Stored locale to one-based segment index; enUS is absent.
---@field currentLocale string Active locale; enUS selects base entity data.
---@field currentIndex? integer Stored segment index for the active locale; nil for enUS or an unstored locale.
---@field onLocaleChanged QuestieTDBLocaleChangedCallback[] Callbacks invoked after cache invalidation with the selected locale.
---@field fields table<QuestieTDBCanonicalDatatype, QuestieTDBL10nField[]> Localized field coverage by entity type.
---@field CreateProvider fun(meta: QuestieTDBEntitySchema): QuestieTDBL10nProvider? Build a translation provider from a generated schema, or nil when that entity type has no localization data.
---@field Initialize fun() Attach available providers and select the client locale.
---@field DetectLocale fun(): string Return the client locale, or enUS outside the client.
---@field SetLocale fun(locale?: string): string Select a locale, defaulting nil to enUS, and invalidate entity caches.
---@field IsAvailable fun(): boolean Test whether any entity has localization data.

--------------------------------------------------------------------------------
-- Corrections
--------------------------------------------------------------------------------

---@alias QuestieTDBCorrectionFields table<integer, any>
---@alias QuestieTDBCorrections table<number, QuestieTDBCorrectionFields>
---@alias QuestieTDBCorrectionProvider fun(): QuestieTDBCorrections

---@class QuestieTDBCorrectionEntry
---@field owner string
---@field datatype QuestieTDBCanonicalDatatype
---@field name string
---@field func QuestieTDBCorrectionProvider? Provider of a function-shaped entry; absent on a data slot.
---@field data QuestieTDBCorrections? Rows of a data slot written through Set; absent on a function entry.
---@field materialized QuestieTDBCorrections? Memoized provider result; cleared by the owner's own apply.
---@field loadOrder number
---@field sequence integer Registration order used to break load-order ties.
---@field dynamic boolean
---@field expansions table<string, boolean>? Expansion allow-list for built-in correction sets.
---@field minExpansionOrder number? Earliest expansion for a built-in correction set.
---@field sourceExpansionOrder number? Source expansion used when adapting built-in options.
---@field options table<string, any>? Options passed to built-in correction sets.

---@class QuestieTDBRegistrar
---@field owner string
---@field RegisterCorrection fun(datatype: QuestieTDBDatatype, name: string, func: QuestieTDBCorrectionProvider, loadOrder?: number): QuestieTDBCorrectionEntry
---@field RegisterRuntimeCorrection fun(datatype: QuestieTDBDatatype, name: string, func: QuestieTDBCorrectionProvider, loadOrder?: number): QuestieTDBCorrectionEntry
---@field Apply fun(): integer
---@field Set fun(datatype: QuestieTDBDatatype, name: string, rows: QuestieTDBCorrections?): boolean Write-through data slot; nil rows removes it.

---@class QuestieTDBCorrectionsAPI
---@field OWNER string QuestieTDB's correction owner name.
---@field debug boolean Log when one owner overrides another on the same field.
---@field CanonicalDatatype fun(datatype: QuestieTDBDatatype): QuestieTDBCanonicalDatatype? Normalize a supported datatype spelling.
---@field RegisterCorrection fun(owner: string, datatype: QuestieTDBDatatype, name: string, func: QuestieTDBCorrectionProvider, loadOrder?: number): QuestieTDBCorrectionEntry
---@field RegisterRuntimeCorrection fun(owner: string, datatype: QuestieTDBDatatype, name: string, func: QuestieTDBCorrectionProvider, loadOrder?: number): QuestieTDBCorrectionEntry
---@field UnregisterCorrection fun(owner: string, datatype: QuestieTDBDatatype, name: string): boolean
---@field GetRegistrar fun(owner: string): QuestieTDBRegistrar
---@field ApplyRegisteredCorrections fun(owner?: string): integer
---@field Set fun(owner: string, datatype: QuestieTDBDatatype, name: string, rows: QuestieTDBCorrections?): boolean Write-through data slot; nil rows removes it.
---@field GetProvenance fun(datatype: QuestieTDBDatatype, id: number, key: string|integer): string?
---@field GetOwners fun(): string[]
