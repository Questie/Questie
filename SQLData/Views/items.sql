CREATE VIEW `items` AS
SELECT i.entry AS 'id', i.name AS 'name'
FROM mangos.item_template i
WHERE i.bonding = 4 # bonding 4 means Quest Item
	AND i.entry IN (
		SELECT item_id FROM questie.quest_objective_items
	)