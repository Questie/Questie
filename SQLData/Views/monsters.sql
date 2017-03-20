CREATE VIEW `monsters` AS
SELECT c.entry AS 'id', c.name AS 'name'
FROM mangos.creature_template c
WHERE c.entry IN (
    SELECT monster_id FROM questie.item_vendors
    UNION ALL
    SELECT monster_id FROM questie.item_drops 
    UNION ALL
    SELECT monster_id FROM questie.quest_objective_slay
    UNION ALL
    SELECT monster_id FROM questie.reputation_monsters
)