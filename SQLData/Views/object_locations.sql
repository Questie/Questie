CREATE VIEW `object_locations` AS
SELECT o.id AS 'object_id', o.map AS 'map_id', o.position_x AS 'x', o.position_y AS 'y'
FROM mangos.gameobject o
WHERE o.id IN (SELECT id FROM questie.objects)