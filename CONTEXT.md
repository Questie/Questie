# Ubiquitous Language

## Addon lifecycle, modules, and public API

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Runtime Addon Object** | The global `Questie` AceAddon instance that owns lifecycle hooks, settings database, logging/debug helpers, communications, and the public API table. | Questie checkout, repository, runtime module |
| **Addon Load** | The file-load and `ADDON_LOADED` phase where saved variables are available and non-login setup runs. | Startup, boot |
| **Login Initialization** | The `PLAYER_LOGIN`-driven initialization path that starts staged Questie setup. | Startup, load |
| **Initialization Stage** | One ordered Questie initialization step for database, player/cache, UI, network, tracker, or late systems. | Init step, boot step |
| **Game Cache Validation** | Waiting for the client quest cache to become usable before later Questie initialization proceeds. | Database validation |
| **Early Event** | A WoW event registered before full Questie initialization to bridge into login or setup behavior. | Normal event |
| **Late Event** | A WoW event registered only after Questie core systems and data are initialized. | Event, post-load event |
| **Addon Started State** | The internal `Questie.started` flag set near the end of core initialization. | Ready state |
| **API Ready State** | The external `Questie.API.isReady` flag indicating stable public APIs should return valid data. | Started, loaded |
| **Module Loader** | The global `QuestieLoader` singleton that creates and imports named Questie modules through an internal registry. | Loader |
| **Questie Module** | A named table created or imported through `QuestieLoader`, usually with public fields and a `.private` table. | Lua module, runtime module |
| **Module Registry** | The internal name-keyed table that stores Questie modules and placeholder modules. | Globals, module list |
| **Module Creation** | The owning-file call that creates a named Questie module. | Constructor |
| **Module Import** | A consumer-file call that retrieves a shared Questie module table. | Require |
| **Private Module Table** | A module’s `.private` table for internals that must be shared outside the owning file. | Private globals |
| **Debug Module Globals** | Debug-only globals populated from the module registry. | Public API |
| **Public API** | The stable external contract exposed under `Questie.API` for other addon authors. | Internal API, QuestieAPI module |
| **Internal API Propagator** | Internal functions that fan out public callbacks without themselves being the external API contract. | Public callback |
| **API Callback** | A function registered through `Questie.API` and invoked defensively. | Event handler |
| **On-Ready Callback** | A public callback invoked once the API Ready State is true. | Init callback |
| **Quest Update Callback** | A public callback invoked when Questie propagates a quest or objective change. | Quest event |
| **Quest Update Trigger Reason** | The public enum describing why a quest update callback fired: accepted, updated, turned in, or abandoned. | Event type |
| **Objective Index** | The numeric index of a quest objective passed to update callbacks, or nil when the whole quest changed. | Objective ID |
| **Unit GUID** | A WoW unit GUID accepted by public APIs such as objective-icon lookup. | NPC ID |

## Quest lifecycle and player state

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Quest** | An in-game task tracked by Questie and identified by a quest ID. | Mission, task |
| **Quest Log** | The player’s active quest list from the game client and Questie runtime cache. | Quest database, tracker |
| **Active Quest** | A quest currently in the player’s Quest Log. | Current quest |
| **Available Quest** | A quest that the player can accept. | New quest, available icon |
| **Turn-in Quest** | A quest whose requirements are complete and can be handed in. | Complete quest |
| **Completed Quest** | A quest already handed in or flagged complete in character completion state. | Turn-in quest, complete quest |
| **Failed Quest** | An Active Quest whose game completion state is failed. | Failed objective |
| **Repeatable Quest** | A quest that can be completed more than once. | Repeat quest |
| **Event Quest** | A quest tied to a game event or holiday. | Holiday quest |
| **PvP Quest** | A quest tied to player-versus-player content. | Battleground quest |
| **Quest Starter** | An NPC, Game Object, or Item that starts a quest. | Start point, giver |
| **Quest Finisher** | An NPC or Game Object where a quest is turned in. | End point, turn-in NPC |
| **Quest Chain** | An ordered relationship between quests where one quest leads to another. | Chain, next quest |
| **Breadcrumb Quest** | An optional lead-in quest that points to another quest or hub. | Lead-in quest |
| **Prerequisite Quest** | A quest that must be completed before another quest becomes available. | Pre-quest, prereq |
| **Alternative Prerequisite** | A prerequisite set where any one listed quest can satisfy the requirement. | Pre-Quest Single, OR prereq |
| **Grouped Prerequisite** | A prerequisite set where listed quests are expected together. | Pre-Quest Group, AND prereq |
| **Parent Quest** | A quest that owns or unlocks one or more child quests. | Parent |
| **Child Quest** | A quest linked back to a parent quest. | Child |
| **Availability Gate** | A race, class, level, skill, reputation, spell, phase, or quest-state requirement that controls quest availability. | Requirement, restriction |

## Objectives and objective data

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Quest Objective** | A requirement within a quest that can be displayed, tracked, validated, or completed. | Goal, step, objective without qualifier |
| **Raw Objective Slot** | A positional entry in database objectives for creature, Game Object, Item, reputation, kill credit, or spell requirements. | Objective slot |
| **Runtime Objective Data** | The normalized objective list generated from database objectives and Trigger End data. | ObjectiveData, normalized objective |
| **Quest Log Objective** | An objective entry populated from the player’s quest-log progress. | Database objective |
| **Database Objective** | Objective type, ID, and text from Questie’s compiled and corrected data. | Questie objective |
| **Live API Objective** | Objective type or text reported by the game client at runtime. | API objective, Blizzard objective |
| **Objective Type** | The category of objective requirement, including database slot names and runtime types such as monster, object, item, reputation, killcredit, spell, or event. | Type, slot type |
| **Objective Progress** | The fulfilled count, required count, and finished flag for a Quest Log Objective. | Progress, completion count |
| **Kill Credit Objective** | An objective satisfied by credit for killing or interacting with an entity that may differ from the visible NPC name. | Kill objective, credit objective |
| **Spell Objective** | An objective satisfied by casting or receiving a specific spell. | Cast objective |
| **Reputation Objective** | An objective satisfied by reaching a reputation standing. | Rep objective |
| **Source Item** | An item supplied by a quest starter. | Starter item |
| **Required Source Item** | A quest-required item that is not itself an item objective. | Required item, source requirement |
| **Trigger End** | A quest completion marker for exploration, escort, or event-style completion. | End trigger, completion trigger |
| **Extra Objective** | A helper objective used to draw guidance for hidden or non-standard quest requirements. | Hidden objective, helper step |
| **Special Objective** | A runtime objective entry generated from Required Source Items or Extra Objectives. | Quest-log objective, normal objective slot |
| **DB Reference** | An Extra Objective reference to an existing monster, item, or Game Object database entity. | Database link |
| **Objective Order Correction** | A correction that forces one objective type to be considered first for a specific quest. | Objective-first fix |

## Quest display, tracker, map, and tooltips

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Map Note** | A Questie marker shown on map-like surfaces for a quest, objective, starter, finisher, or manual entity. | Icon, frame, note |
| **World Map Note** | A Map Note drawn on the world map. | World map icon |
| **Minimap Note** | A Map Note drawn on the minimap. | Minimap icon |
| **Manual Note** | A user-visible marker for an NPC or Game Object that is not generated from quest objective state. | Manual icon, custom marker |
| **Map Note Cluster** | Nearby map notes combined into one tooltip interaction. | Clustered icon |
| **Map Note Tooltip** | A tooltip opened from a map or minimap note. | Map icon tooltip |
| **Quest Start Tooltip** | A tooltip entry showing an available quest on its starter or drop source. | Starter tooltip |
| **Objective Tooltip** | A tooltip entry attached to an objective’s NPC, Item, or Game Object reference. | Objective hover |
| **Drop Rate Tooltip** | Objective tooltip detail showing item drop chance and source provenance. | Drop tooltip |
| **Tooltip** | A contextual display of quest or objective information on maps and world entities. | Hover text, info popup |
| **Waypoint Path** | A path or line drawn through known coordinates for an NPC or objective. | Waypoint line, path line |
| **Quest Tracker** | Questie’s player-facing quest watch display. | Tracker, watch frame |
| **Tracked Quest** | A quest currently included in the Quest Tracker. | Watched quest |
| **Auto-Untracked Quest** | An auto-trackable quest the user explicitly removed from the Quest Tracker. | Removed tracked quest |
| **Collapsed Quest** | A minimized quest group in the Quest Tracker. | Minimized quest |
| **Collapsed Zone** | A minimized zone group in the Quest Tracker. | Minimized zone |
| **Tracker Sort Mode** | The selected ordering of tracker rows, such as by zone, completion, level, or proximity. | Sort order |
| **Timed Quest** | An Active Quest with remaining time shown by Questie or Blizzard timer UI. | Timer quest |
| **Quest Timer** | The countdown display for a Timed Quest. | Timer |
| **Auto-Complete Quest** | A quest completed through the client’s auto-complete popup rather than a finisher. | Popup quest |
| **Tracked Achievement** | An achievement shown in Questie’s tracker alongside quests. | Achievement row |
| **Tracker Line** | A single rendered row in the Quest Tracker for a zone, quest, objective, or achievement. | Tracker row |
| **Objective Focus** | A tracker state that emphasizes one objective or quest and fades unrelated map notes. | Focus, tracker focus |
| **User-Hidden Quest** | A quest the user hid from map or Journey display via character state. | Quest blacklist, ignored quest |
| **Tracker-Hidden Quest Icons** | Tracker state that suppresses map notes for one quest without blacklisting or completing it. | Hidden quest |
| **Tracker-Hidden Objective Icons** | Tracker state that suppresses map notes for one objective. | Hidden objective |

## Journey

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Journey** | Questie’s player-facing history and quest browsing interface. | My Journey, history window |
| **Journey Tab** | A top-level Journey view such as My Journey, Quests by Zone, Quests by Faction, or Advanced Search. | Journey page |
| **Journey Entry** | A recorded level, note, or quest event in the Journey. | History entry, timeline row |
| **Journey Quest Event** | A Journey record for accepting, completing, or abandoning exactly one Quest. | Quest Event |
| **Journey Note** | A user-authored Journey Entry with title, body, and timestamp. | Note |
| **Level Journey Entry** | A Journey Entry recording a player level-up. | Level record |
| **Journey Import** | Replacing the current character’s Journey data with validated Journey data from another character. | Journey sync, import |
| **Search Result** | A Journey Advanced Search result for a quest, NPC, Item, or Game Object. | Search row |

## World entities, services, and locations

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **NPC** | A non-player character entity identified by an NPC ID. | Mob, creature, unit |
| **Game Object** | A world-interactable object entity identified by an object ID. | Object, node |
| **Item** | An inventory, loot, reward, vendor, or quest-start entity identified by an item ID. | Drop, thing |
| **Zone** | A named game area used to group quests, spawns, triggers, and Journey browsing. | Area, map |
| **Spawn Location** | A zone-indexed coordinate where an NPC or Game Object can appear. | Spawn, point |
| **Spawn Phase** | A phase ID stored on a spawn coordinate and evaluated for spawn visibility. | Content phase |
| **Trigger Location** | A coordinate area that satisfies an exploration, escort, or event completion trigger. | Trigger, event location |
| **Waypoint Location** | A coordinate in a path associated with an NPC or objective. | Waypoint, route point |
| **Quest Category** | A Journey or database grouping such as zone, faction, class, profession, event, dungeon, or battleground. | Addon category, sort |
| **Quest Sort** | A negative QuestSort category ID used when a quest is categorized by class, profession, event, dungeon, or similar instead of a zone. | Category ID |
| **Zone or Sort** | The quest field where positive values are zone IDs and negative values are Quest Sort IDs. | Zone, category |
| **Townsfolk** | A user-toggleable service NPC or service Game Object shown as a Manual Note. | Service marker, townsfolk icon |
| **Service NPC** | An NPC that provides a non-quest service such as banking, repairs, training, travel, vendors, or battleground entry. | Vendor NPC, trainer, townsfolk |
| **Service Game Object** | A Game Object that provides a non-quest service marker such as a mailbox or meeting stone. | Service object, townsfolk object |
| **Vendor Category** | A townsfolk grouping for vendors that sell a selected item family. | Vendor type, vendor list |

## Database schema and entity data

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Database Addon** | QuestieTDB, the separately released addon that owns and serves all entity data. Questie declares a hard dependency on it. | Database, QuestieDB, the DB |
| **Quest Data** | The canonical record for a quest, served by the **Database Addon**. | Quest row, quest table entry |
| **NPC Data** | The canonical record for an NPC, served by the **Database Addon**. | Creature data |
| **Item Data** | The canonical record for an Item, served by the **Database Addon**. | Item row |
| **Game Object Data** | The canonical record for a Game Object, served by the **Database Addon**. | Object data |
| **Database Key Enum** | A `*Keys` table mapping semantic field names to positional numeric indices. Defined by the **Database Addon**; Questie consumes it. | Key table, schema enum |
| **Contract Version** | The compatibility number Questie checks against the **Database Addon** at initialization. | DB version, schema version |
| **Quest Giver Tuple** | The nested starter or finisher structure grouping NPC, Game Object, and Item quest links. | Giver record |
| **Entity Back-reference** | A reverse link from entity data back to quests, drops, rewards, vendors, or related quests. | Backlink |
| **Objective Text** | The user-facing quest objective description. | Objective string, objective description |

## Corrections, blacklists, phasing, and validation

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Database Correction** | An authored change to entity facts, owned by the **Database Addon**. Questie registers only those that depend on its own state. | Fix, patch, workaround, override |
| **Policy Correction** | A **Database Correction** Questie registers because it depends on a Questie setting, mode, or phase — event quests, Season of Discovery, content phases, Isle of Quel'Danas. | Runtime override, dynamic fix |
| **Correction Registration** | The call through which Questie supplies its **Policy Corrections** to the **Database Addon**, applied explicitly during an **Initialization Stage**. | Override, patching |
| **Expansion-Cumulative Correction** | A correction loaded in expansion order from earlier game versions through the current one. | Expansion fix, version fix |
| **Quest Blacklist** | A Questie rule that suppresses a quest for a flavor, phase, or mode. Hiding is Questie's policy, not a fact about the data — a blacklisted quest still exists in the **Database Addon**. | User-hidden quest, ignored quest, correction |
| **Map-only Quest Blacklist** | A blacklist entry that suppresses map display without treating the quest like fully unavailable data. | Hide-on-map quest |
| **Entity Blacklist** | A data rule that hides or disables NPC or Item data for a flavor, phase, or mode. | Game Object blacklist |
| **Content Phase** | A release-phase gate used primarily to blacklist or enable quests and events for a mode or release state. | Spawn Phase |
| **Expansion** | A supported World of Warcraft ruleset whose data and corrections can differ. | Version, client |
| **Season of Discovery** | A Classic Era mode with additional Questie data and corrections. | SoD |
| **Hardcore Mode** | A Classic Era mode with additional Questie quest filtering. | Hardcore |
| **Database Integration Check** | The CI job that loads a pinned **Database Addon** release and asserts it loads and the **Contract Version** matches. Data-invariant validation belongs to the **Database Addon**, not Questie. | Validator, database validation |

## Localization

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Supported Locale** | A language code Questie recognizes for UI strings or localized database names. | Locale, language |
| **Fallback Locale** | The supported locale code selected after resolving nil, unsupported, or aliased locale requests. | English fallback |
| **Locale Alias** | A requested locale code mapped to another supported locale. | Locale fallback |
| **User Locale Selection** | A Questie setting that chooses the active UI locale instead of the WoW client locale. | Locale override |
| **External Locale Override** | Localization data supplied by another addon through `QUESTIE_LOCALES_OVERRIDE`. | Locale patch, translation override |
| **Translation Entry** | A UI string record keyed by English text and mapped to per-locale values. | Translation, string row |
| **English Key** | The English source text used as the stable key for a Translation Entry. | Source string |
| **English Text Fallback** | Runtime behavior where untranslated UI text formats and displays the English Key. | Fallback locale |
| **Missing Translation** | A translation value that is absent or explicitly marked for human translation. | Untranslated string |
| **Zone/Category Lookup** | English label data for zones, continents, and quest categories used by Journey or map categorization. Questie owns this; localized *entity* names come from the **Database Addon**. | Entity lookup, lookup table |

## Settings, saved variables, profiles, and migration

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Settings Database** | The AceDB-backed `Questie.db` object created from saved variables and defaults during addon initialization. | Config, profile |
| **Saved Variables Store** | The WoW-persisted AceDB database that stores Questie data across sessions. | Config file, saved vars |
| **Saved Variable Scope** | An AceDB partition such as profile, character, or global that determines persistence behavior. | Namespace, section |
| **Settings Profile** | A named profile containing profile-scoped user preferences. | Profile, config profile |
| **Active Settings Profile** | The Settings Profile currently selected for reads and writes to profile-scoped settings. | Current profile |
| **Profile Setting** | A user preference stored under the active profile scope. | Profile option, option value |
| **Character State** | Per-character Questie state such as completed quests, hidden quests, Journey entries, and tracker state. | Character config, character setting |
| **Global State** | Account-wide Questie state shared across characters and profiles. | Global config, account state |
| **Defaults Table** | The built-in profile, character, and global default values supplied to AceDB. | Defaults, option defaults |
| **Default Setting** | A built-in setting value used when saved data lacks an explicit value. | Default, option default |
| **Options Tab** | A grouped settings UI area such as General, Icons, Tracker, Auto, Nameplate, DBM HUD, Advanced, or Profiles. | Option group, settings section |
| **Profile Operation** | A Profiles tab action that changes, copies, resets, deletes, or creates a Settings Profile. | Profile action |
| **Profile Refresh** | Runtime reconfiguration after a Settings Profile is changed, copied, or reset. | Refresh config, profile reload |
| **Settings Migration** | An ordered update that brings saved Questie settings or state forward after defaults or schema changes. | Migration, config upgrade |
| **Migration Step** | A numbered migration function applied in sequence when the stored migration version is behind the current target. | Migration function |
| **Migration Version** | The profile-scoped numeric marker recording the last applied Migration Step for a Settings Profile. | Migration step count |

## Network, party sync, and remote progress

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Addon Message** | A serialized message sent through addon communication channels with a prefix and distribution. | Chat message |
| **Comm Prefix** | The addon-message namespace used to route incoming Questie messages. | Channel |
| **Quest Communication** | Questie’s addon-message exchange of quest log, objective progress, version, and removal data with group members. | QuestieComms, party sync, comms |
| **Quest Communication Packet** | An internal packet with a message ID and version carrying quest log or progress data. | Public quest update |
| **Remote Quest Log** | Cached quest and objective data received from other players through Quest Communication. | Remote progress, party quest log |
| **Party Progress** | Another group member’s quest or objective completion state received through Quest Communication. | Remote progress, synced progress |
| **Remote Player Progress** | Party or nearby remote-player objective progress shown in tooltips. | Party Progress when not grouped |
| **Party Objective Map Note** | A Map Note drawn for another online party member’s incomplete objective. | Party objective icon, shared objective marker |
| **Daily Quest Availability Message** | A communication event that suppresses unavailable daily quests for today. | Quest update |

## Peripheral displays and controls

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **Nameplate Objective Icon** | A quest objective marker attached to an NPC nameplate or target frame. | Nameplate icon, target icon |
| **DBM HUD Marker** | A Questie objective marker registered with DeadlyBossMods HudMap for screen-space radar display. | HUD icon, DBM icon |
| **Minimap Button** | Questie’s launcher or control button shown around the minimap. | Minimap icon, addon button |
| **World Map Button** | Questie’s launcher or control button shown on the world map UI. | Map button, world map icon |
| **Map Coordinates Display** | Player or cursor coordinates rendered on the world map or minimap UI. | Coordinate text, coords |

## Build, release, and tests

| Term | Definition | Aliases to avoid |
| ---- | ---------- | ---------------- |
| **TOC Manifest** | A `.toc` addon manifest that declares client interface compatibility, metadata, saved variables, and load order for one Questie flavor. | Manifest, TOC file |
| **Fallback TOC Manifest** | The unsupported-client stub loaded when no supported flavor TOC applies. | Default TOC |
| **Addon Flavor** | A release compatibility target such as `classic`, `bcc`, `wrath`, `cata`, or `mists`. | Expansion, build target |
| **Selected Flavor Set** | The set of addon flavors included in one build invocation. | Included expansions |
| **Interface Version** | The numeric WoW client interface value from `## Interface` copied into release metadata. | Client version, expansion version |
| **Release Package** | The ZIP produced under a release version containing selected addon files and excluding tests. | Build artifact, package |
| **Release Metadata** | The generated metadata describing release files, nolib status, flavors, and interface versions. | Metadata |
| **Addon Category Metadata** | TOC `## Category` fields used by addon managers to classify Questie. | Quest Category |
| **Busted Unit Test** | A Lua test file matched by `*.test.lua` and run by Busted, usually colocated with the module under test. | Test file |
| **Integration Regression Test** | A Busted test under `cli/integrationTests/` that preserves behavior for a specific issue or cross-module flow. | Integration test |
| **Test Harness** | Shared test setup that loads Questie infrastructure and provides mocked WoW globals. | Test setup |
| **WoW API Mock** | A replacement global function or table used by tests or CLI scripts to simulate game-client APIs. | Fake API, stub |
| **Validator Unit Test** | A Busted test for validator rules, including mocked process-exit behavior. | Validator test |

## Relationships

- The **Runtime Addon Object** is created before **Addon Load**, proceeds through **Login Initialization** and **Initialization Stages**, then exposes the **API Ready State**.
- **Early Events** bridge addon load and login behavior; **Late Events** are registered after core data and systems are ready.
- **Questie Modules** are created through **Module Creation**, stored in the **Module Registry**, and consumed through **Module Import**.
- **Debug Module Globals** are not the **Public API**; external addons should use **Public API** callbacks and accessors.
- **On-Ready Callbacks** are invoked once **API Ready State** is true.
- **Quest Update Callbacks** carry a quest ID, optional **Objective Index**, and **Quest Update Trigger Reason**.
- A **Quest** may have **Quest Starters**, **Quest Finishers**, **Prerequisite Quests**, **Breadcrumb Quests**, **Parent Quests**, **Child Quests**, and **Availability Gates**.
- An **Active Quest** belongs to the **Quest Log**; a **Completed Quest** belongs to character completion state; a **Turn-in Quest** is ready to be handed in.
- A **Quest Objective** can appear as a **Raw Objective Slot**, **Runtime Objective Data**, **Database Objective**, **Live API Objective**, or **Quest Log Objective** depending on source and lifecycle phase.
- **Objective Progress** belongs to a **Quest Log Objective**, not to the raw database schema.
- A **Special Objective** is generated from **Required Source Items** or **Extra Objectives**, while **Trigger End** represents a completion trigger.
- **NPC Data**, **Item Data**, and **Game Object Data** can reference quests through **Entity Back-references**.
- **Spawn Locations**, **Trigger Locations**, and **Waypoint Locations** belong to **Zones**; **Spawn Phases** are distinct from **Content Phases**.
- A **Quest Objective** can produce a **Map Note**, **Nameplate Objective Icon**, **DBM HUD Marker**, or **Party Objective Map Note** depending on settings and integration state.
- **World Map Notes** and **Minimap Notes** are quest/objective markers; the **World Map Button** and **Minimap Button** are launcher/control UI.
- **Townsfolk** produce **Manual Notes** rather than quest-derived Map Notes.
- **User-Hidden Quests**, **Tracker-Hidden Quest Icons**, **Tracker-Hidden Objective Icons**, **Quest Blacklists**, and **Map-only Quest Blacklists** are separate hiding mechanisms.
- Questie reads all entity data from the **Database Addon** and owns none of it; a **Contract Version** mismatch is reported rather than worked around.
- Questie supplies **Policy Corrections** through **Correction Registration**; all other **Database Corrections** belong to the **Database Addon**.
- A **Quest Blacklist** is Questie policy and never a **Database Correction** — the two answer different questions: what to show, versus what is true.
- **Expansion-Cumulative Corrections** load from earlier **Expansions** through the active **Expansion**.
- A **Supported Locale** selects **Translation Entries** for UI strings; localized entity names are served by the **Database Addon** for the same locale.
- An **Active Settings Profile** owns **Profile Settings**; **Character State** and **Global State** do not follow profile copy/reset behavior.
- A **Profile Operation** can trigger a **Profile Refresh**.
- A changed **Default Setting** or **Defaults Table** entry may require a **Settings Migration** with a new **Migration Step**.
- **Quest Communication** produces **Remote Quest Logs**, **Party Progress**, **Remote Player Progress**, objective tooltips, and **Party Objective Map Notes**.
- A **Release Package** is produced for a **Selected Flavor Set** using **TOC Manifests**, **Interface Versions**, and **Release Metadata**.
- **Busted Unit Tests**, **Integration Regression Tests**, **Validator Unit Tests**, and CLI validation share **WoW API Mocks** through a **Test Harness** or script-local setup.

## Example dialogue

> **Dev:** "This marker is wrong on both the minimap and the target frame. Should I call it a bad icon?"
>
> **Domain expert:** "Separate the projections: the map marker is a **Minimap Note**, while the target-frame marker is a **Nameplate Objective Icon**. Both may come from the same **Quest Objective**."
>
> **Dev:** "The game client reports a kill-credit objective first, but the database order differs."
>
> **Domain expert:** "Compare the **Live API Objective** with the **Database Objective** and decide whether an **Objective Order Correction** or another **Database Correction** is warranted."
>
> **Dev:** "If I add a helper location that is not the completion trigger, is that a **Trigger End**?"
>
> **Domain expert:** "No. Use an **Extra Objective** for helper guidance; reserve **Trigger End** for the completion marker."
>
> **Dev:** "The user hid the quest, but there is also a blacklist entry. Are those the same?"
>
> **Domain expert:** "No. A **User-Hidden Quest** is character state, while a **Quest Blacklist** is data gating; **Tracker-Hidden Quest Icons** are a third mechanism."
>
> **Dev:** "When can another addon call Questie safely?"
>
> **Domain expert:** "Register an **On-Ready Callback** on the **Public API** and wait for **API Ready State**; do not rely on **Debug Module Globals** or internal modules."

## Flagged ambiguities

- "Questie" can mean the addon, repository, checkout folder, **Runtime Addon Object**, or a module name; use the exact term.
- "Startup" is vague across **Addon Load**, **Login Initialization**, **Initialization Stage**, **Addon Started State**, and **API Ready State**.
- "API" can mean the stable **Public API**, internal **Internal API Propagator**, WoW API, or module methods; qualify it.
- "Event" can mean a WoW event, **Journey Quest Event**, **Event Quest**, or **Quest Update Trigger Reason**; do not use **Quest Event** unqualified.
- "Objective" can mean **Raw Objective Slot**, **Runtime Objective Data**, **Quest Log Objective**, **Database Objective**, **Live API Objective**, **Special Objective**, **Extra Objective**, or **Trigger End**; qualify it when source or semantics matter.
- "Complete" can mean a **Turn-in Quest**, **Completed Quest**, or satisfied objective progress; avoid complete/completed without qualifier.
- "Object" is overloaded between Lua objects and WoW world objects; use **Game Object** for the WoW entity.
- "Hidden" can mean **User-Hidden Quest**, **Tracker-Hidden Quest Icons**, **Tracker-Hidden Objective Icons**, **Quest Blacklist**, or **Map-only Quest Blacklist**.
- "Fix", "correction", "override", and "patch" overlap; use **Database Correction** for authored changes to entity facts, and **Policy Correction** for the subset Questie registers because it depends on Questie state. "Override" is retired — the **Database Addon** composes corrections, Questie does not patch data.
- "Database" can mean the **Database Addon**, the entity records it serves, or Questie's settings store (`Questie.db`); qualify it.
- "Phase" can mean **Content Phase** or **Spawn Phase**; these are distinct mechanisms.
- "Zone", "Area", "UI Map", **Zone or Sort**, **Quest Sort**, and **Quest Category** are related but not interchangeable.
- "Category" can mean **Quest Category** in quest/Journey data or **Addon Category Metadata** in TOC manifests.
- "Translation" can mean a UI **Translation Entry** (Questie's) or a localized entity name (the **Database Addon**'s); these are separate systems and change independently.
- "Fallback" can mean **Fallback Locale** selection or **English Text Fallback** for untranslated UI strings.
- "Locale Override" should not be used for user selection; distinguish **External Locale Override** from **User Locale Selection**.
- "Global" can mean a profile setting name such as global scale or the AceDB **Global State** scope.
- "Profile" can mean **Settings Profile**, **Active Settings Profile**, **Profile Setting**, or **Profile Operation**.
- "Map icon" can mean **World Map Note**, **Minimap Note**, **Minimap Button**, **World Map Button**, **DBM HUD Marker**, or **Nameplate Objective Icon**; choose the surface-specific term.
- "Party progress" should mean group-member state from **Quest Communication**; use **Remote Player Progress** for broader nearby-player tooltip data.
- "Classic" can mean Era, Hardcore, Anniversary, or the broader Classic client family; prefer **Expansion**, **Addon Flavor**, or the exact mode name.
