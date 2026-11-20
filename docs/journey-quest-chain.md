# Quest chain in Journey details

Open a quest's details in Questie Journey to see the **Quest Chain** section.
Each row includes its position, level, and quest name. A `>` marks the quest
currently being viewed. Click any row to open that quest in Journey's search
details. Hovering uses Journey's existing quest tooltip.

Colors use Questie's difficulty calculation for the current character, including
its client-specific difficulty support. Repeatable, event, and PvP color overrides
do not replace difficulty colors in this section. Colors are calculated whenever
the details are drawn.

The section includes the entire connected chain, using prerequisite, next-quest,
and breadcrumb relationships in the database. Earlier steps appear before their
follow-ups even when a relationship is recorded on only one side. Branches and
alternative prerequisites are included; numbering is a reading order, not a claim
that every branch must be completed. The existing prerequisite sections still
explain which immediate prerequisites require one or all quests. Independent
branches are ordered by quest ID.

Hidden quests connect visible steps but are omitted from the list. Missing IDs
and self-links are ignored. Cyclic database relationships are displayed once each
in a deterministic order. Standalone quests have no chain section.

The relationship index is built on first use and reused for subsequent detail
views. It is rebuilt when QuestieDB replaces its quest ID map after corrections.
The accuracy of the chain depends on database relationships.

## In-game checks

1. Open a known multi-step chain from its first, middle, and final quest. Check
   that all three views show the same list and mark the selected quest correctly.
2. Click earlier and later quests, including when starting from Quests by Zone
   before opening the Search tab. Verify that the destination details load.
3. Check a branching chain: shared prerequisites should appear once and before
   their dependents. Verify the immediate prerequisite sections remain correct.
4. Check quests above and below the character's level, including a repeatable
   quest. Compare difficulty colors with the character's quest difficulty.
5. Check a standalone quest and a long chain. Verify the section is absent for
   the standalone quest, and all rows in the long chain can be scrolled to.

Automated tests cover ordering, navigation, difficulty-color delegation, hidden
steps, breadcrumbs, missing IDs, cycles, and index refresh. Actual WoW rendering
and client responsiveness require in-game validation.
