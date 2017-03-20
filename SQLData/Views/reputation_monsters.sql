CREATE VIEW `reputation_monsters` AS
SELECT RewOnKillRepFaction1 as 'reputation_id', creature_id as 'monster_id' 
	FROM mangos.creature_onkill_reputation 
    WHERE RewOnKillRepFaction1 IN (SELECT reputation_id FROM quest_objective_reputations) AND RewOnKillRepValue1 > 0
UNION SELECT RewOnKillRepFaction2 as 'reputation_id', creature_id as 'monster_id' 
    FROM mangos.creature_onkill_reputation 
    WHERE RewOnKillRepFaction2 IN (SELECT reputation_id FROM quest_objective_reputations) AND RewOnKillRepValue2 > 0
ORDER BY reputation_id
;