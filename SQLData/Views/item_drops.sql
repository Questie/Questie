CREATE VIEW `item_drops` AS
SELECT cl.item AS 'item_id', cl.entry AS 'monster_id'
FROM mangos.creature_loot_template cl
WHERE cl.item IN (SELECT id FROM questie.items)