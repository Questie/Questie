CREATE VIEW `item_objectdata` AS
SELECT ol.item AS 'item_id', ol.entry AS 'objectdata_id'
FROM mangos.gameobject_loot_template ol
WHERE ol.item IN (SELECT id FROM questie.items)