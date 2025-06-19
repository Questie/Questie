import re

dungeons = [
    ["Blackfathom Deeps", "719"],
    ["Shadowfang Keep", "209"],
    ["Scarlet Monastery", "796"],
    ["Gnomeregan", "721"],
    ["The Temple of Atal'Hakkar", "1477"],
    ["Molten Core", "2717"],
    ["Blackwing Lair", "2677"],
    ["Ruins of Ahn'Qiraj", "3429"],
    ["Ahn'Qiraj Temple", "3428"],
    ["Naxxramas", "3456"],
    ["Scarlet Halls", "6052"],
    ["Scholomance", "6066"],
    ["Demon Fall Canyon", "15475"],
    ["The Burning of Andorhal", "15828"],
    ["Karazhan Crypts", "16074"],
    ["Scarlet Enclave", "16236"],
]

def match_dungeon_spawns(text):
    spawns = []
    zone_id = None
    zone_id_match = re.search(r"zone=(\d+)", text)
    dungeon_names_regex = "|".join([dungeon[0] for dungeon in dungeons])
    zone_name_match = re.search(dungeon_names_regex, text)
    if zone_id_match:
        zone_id = zone_id_match.group(1)
        dungeon_zone_ids = [dungeon[1] for dungeon in dungeons]
        if zone_id in dungeon_zone_ids:
            spawns = [[zone_id, "[-1,-1]"]]
    elif zone_name_match:
        zone_name = zone_name_match.group(0)

        dungeon = [dungeon for dungeon in dungeons if dungeon[0] == zone_name][0]
        zone_id = dungeon[1]
        spawns = [[zone_id, "[-1,-1]"]]
    return spawns, zone_id