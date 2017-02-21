CREATE VIEW `quest_objective_slay` AS
SELECT q.entry AS 'quest_id', q.ReqCreatureOrGOId1 AS 'monster_id' FROM mangos.quest_template q WHERE q.ReqCreatureOrGOId1 > 0 AND q.ReqSpellCast1 = 0 AND q.ObjectiveText1 = ''
UNION
SELECT q.entry AS 'quest_id', q.ReqCreatureOrGOId2 AS 'monster_id' FROM mangos.quest_template q WHERE q.ReqCreatureOrGOId2 > 0 AND q.ReqSpellCast2 = 0 AND q.ObjectiveText2 = ''
UNION
SELECT q.entry AS 'quest_id', q.ReqCreatureOrGOId3 AS 'monster_id' FROM mangos.quest_template q WHERE q.ReqCreatureOrGOId3 > 0 AND q.ReqSpellCast3 = 0 AND q.ObjectiveText3 = ''
UNION
SELECT q.entry AS 'quest_id', q.ReqCreatureOrGOId4 AS 'monster_id' FROM mangos.quest_template q WHERE q.ReqCreatureOrGOId4 > 0 AND q.ReqSpellCast4 = 0 AND q.ObjectiveText4 = ''