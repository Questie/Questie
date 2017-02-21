CREATE VIEW `objects` AS
SELECT o.entry AS 'id', o.name AS 'name'
FROM mangos.gameobject_template o
WHERE o.entry IN (SELECT object_id FROM questie.objectdata_objects)