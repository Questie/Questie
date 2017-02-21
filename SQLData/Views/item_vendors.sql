CREATE VIEW `item_vendors` AS
SELECT v.item AS 'item_id', v.entry AS 'monster_id'
FROM mangos.npc_vendor v
WHERE v.item IN (SELECT id FROM questie.items)