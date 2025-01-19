import re


def match_dungeon_spawns(text):
    spawns = []
    zone_id = None
    zone_id_match = re.search(r"zone=(\d+)", text)
    zone_name_match = re.search(r"Shadowfang Keep|Blackfathom Deeps|Scarlet Monastery|Gnomeregan|The Temple of Atal'Hakkar|Molten Core|Demon Fall Canyon|The Burning of Andorhal", text)
    if zone_id_match:
        zone_id = zone_id_match.group(1)
        if (zone_id == "719" or  # Blackfathom Deeps
                zone_id == "209" or  # Shadowfang Keep
                zone_id == "796" or  # Scarlet Monastery
                zone_id == "1477" or  # The Temple of Atal'Hakkar
                zone_id == "2717" or  # Molten Core
                zone_id == "721" or  # Gnomeregan
                zone_id == "15475" or # Demon Fall Canyon
                zone_id == "15828"): # The Burning of Andorhal
            spawns = [[zone_id, "[-1,-1]"]]
    elif zone_name_match:
        zone_name = zone_name_match.group(0)
        if zone_name == "Blackfathom Deeps":
            zone_id = "719"
            spawns = [["719", "[-1,-1]"]]
        elif zone_name == "Shadowfang Keep":
            zone_id = "209"
            spawns = [["209", "[-1,-1]"]]
        elif zone_name == "Scarlet Monastery":
            zone_id = "796"
            spawns = [["796", "[-1,-1]"]]
        elif zone_name == "Gnomeregan":
            zone_id = "721"
            spawns = [["721", "[-1,-1]"]]
        elif zone_name == "The Temple of Atal'Hakkar":
            zone_id = "1477"
            spawns = [["1477", "[-1,-1]"]]
        elif zone_name == "Molten Core":
            zone_id = "2717"
            spawns = [["2717", "[-1,-1]"]]
        elif zone_name == "Demon Fall Canyon":
            zone_id = "15475"
            spawns = [["15475", "[-1,-1]"]]
        elif zone_name == "The Burning of Andorhal":
            zone_id = "15828"
            spawns = [["15828", "[-1,-1]"]]
    return spawns, zone_id