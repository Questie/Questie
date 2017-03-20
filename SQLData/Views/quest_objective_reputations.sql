CREATE VIEW `quest_objective_reputations` AS
SELECT q.entry as 'quest_id', q.RepObjectiveFaction as 'reputation_id' 
FROM mangos.quest_template q
WHERE q.RepObjectiveFaction > 0