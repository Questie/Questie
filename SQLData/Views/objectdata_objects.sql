CREATE VIEW `objectdata_objects` AS
SELECT o.data1 AS 'objectdata_id', o.entry AS 'object_id'
FROM mangos.gameobject_template o
WHERE o.data1 IN (SELECT objectdata_id FROM questie.item_objectdata)