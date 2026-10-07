---@meta _

---@class QuestieDBFactionRaceMasks
---@field Alliance integer Active provider flavor's Alliance race mask.
---@field Horde integer Active provider flavor's Horde race mask.

---@class QuestieDBEnums
---@field factionRaceMasks QuestieDBFactionRaceMasks Active provider flavor faction masks; read-only by contract.
---@field raceMaskById table<integer, integer?> Actual race ID to requiredRaces mask; unknown IDs return nil. Encoding, not playability; read-only by contract.
---@field phases table<string, integer> Shared phase names to Blizzard or Questie-defined fake IDs; read-only by contract for consumers.

---A condition function returns true or false, or nil when it cannot read its state right now.
---@alias QuestieDBConditionFunction fun(...): boolean?

---One node of an explained condition. A leaf has `call` and `args`; an operator has `op` and
---`children`. `result` is true, false, or nil when unknown.
---@class QuestieDBConditionNode
---@field call string? Condition function name, on a leaf.
---@field args (number|string)[]? Leaf arguments.
---@field op "and"|"or"|"not"|nil Operator, on an inner node.
---@field children QuestieDBConditionNode[]? Operands.
---@field result boolean? Three-valued result of this node.

---@class QuestieDBConditions
---@field Get fun(questId: QuestId): string? Return a quest's condition expression.
---@field Evaluate fun(expression: string?): boolean? Evaluate an expression; nil or empty is true, nil means unknown.
---@field EvaluateQuest fun(questId: QuestId): boolean? Evaluate a quest's expression; true without one, nil means unknown.
---@field Explain fun(expression: string?): QuestieDBConditionNode? Explain an expression for display, evaluating every leaf; the root result equals Evaluate's. Nil without one, outside the builder's grammar, or when a function raised.
---@field ExplainQuest fun(questId: QuestId): QuestieDBConditionNode? Explain a quest's expression.
---@field SetFunctions fun(owner: string, functions: table<string, QuestieDBConditionFunction>?) Publish a trusted owner's functions for every consumer; nil withdraws them.

---@class LibQuestieDB
---@field Quest QuestDB Quest entity reads.
---@field Npc NpcDB NPC entity reads.
---@field Item ItemDB Item entity reads.
---@field Object ObjectDB Object entity reads.
---@field contractVersion integer Public API and storage contract version.
---@field addonName string Loaded addon name.
---@field readMode QuestieDBReadMode Active source or baked reader.
---@field RequireContract fun(required: number): boolean, string? Check whether this release supports a consumer contract.
---@field InvalidateCache fun(datatype?: QuestieDBDatatype, id?: number) Drop one entity cache, one datatype cache, or every cache.
---@field ApplyRegisteredCorrections fun(owner?: string): integer Apply pending Corrections for one owner or all pending owners.
---@field RegisterCorrection fun(owner: string, datatype: QuestieDBDatatype, name: string, func: QuestieDBCorrectionProvider, loadOrder?: number): QuestieDBCorrectionEntry Register a Static Correction.
---@field RegisterRuntimeCorrection fun(owner: string, datatype: QuestieDBDatatype, name: string, func: QuestieDBCorrectionProvider, loadOrder?: number): QuestieDBCorrectionEntry Register a query-time Correction.
---@field SetCorrection fun(owner: string, datatype: QuestieDBDatatype, name: string, rows: QuestieDBCorrections?): boolean Write-through data correction; nil rows removes the slot.
---@field GetRegistrar fun(owner: string): QuestieDBRegistrar Bind correction calls to one owner.
---@field GetProvenance fun(datatype: QuestieDBDatatype, id: number, key: string|integer): string? Return the owner of the composed value, including active translations.
---@field GetOwners fun(): string[] Return owners in applied precedence order.
---@field Corrections QuestieDBCorrectionsAPI Correction registration, application, and provenance API.
---@field Meta QuestieDBMeta Schema names, indices, storage types, and structures.
---@field Enum QuestieDBEnums Shared constants exposed to consumers.
---@field ObjectiveFirst QuestieDBObjectiveFirst Shared objective-ordering hints; read-only for consumers.
---@field l10n QuestieDBL10n Localization controls and state.
---@field Support table Whole-table support data.
---@field ModeIndicator table Source-mode indicator API.
---@field Conditions QuestieDBConditions Quest Condition expressions and their evaluator.
LibQuestieDB = {}
