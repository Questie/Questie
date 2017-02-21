CREATE VIEW `quest_objective_items` AS
SELECT q.entry AS 'quest_id', q.ReqItemId1 AS 'item_id' FROM mangos.quest_template q WHERE q.ReqItemId1 != 0
UNION
SELECT q.entry AS 'quest_id', q.ReqItemId2 AS 'item_id' FROM mangos.quest_template q WHERE q.ReqItemId2 != 0
UNION
SELECT q.entry AS 'quest_id', q.ReqItemId3 AS 'item_id' FROM mangos.quest_template q WHERE q.ReqItemId3 != 0
UNION
SELECT q.entry AS 'quest_id', q.ReqItemId4 AS 'item_id' FROM mangos.quest_template q WHERE q.ReqItemId4 != 0