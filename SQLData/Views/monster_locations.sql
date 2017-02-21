CREATE VIEW `monster_locations` AS
SELECT c.id AS 'monster_id', c.map AS 'map_id', c.position_x AS 'x', c.position_y AS 'y'
FROM mangos.creature c
WHERE c.id IN (SELECT id FROM questie.monsters)