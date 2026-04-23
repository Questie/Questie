import json
from pathlib import Path


class NPCFormatter:

    def __call__(self, use_correction_format: bool = True) -> None:
        if use_correction_format:
            self.__format()
        else:
            self.__format_for_db()

    def __format(self) -> None:
        npc_input = self.__load_json_file("npc/npc_data.json")
        with Path("npc/npc_data.lua").open("w", encoding="utf-8") as g:
            g.write("return {\n")
            for item in npc_input:
                g.write("    [{id}] = {{\n".format(id=item["npcId"]))
                g.write("        [npcKeys.name] = \"{name}\",\n".format(name=item["name"]))
                g.write("        [npcKeys.minLevel] = {min_level},\n".format(min_level=self.__get_level(item["minLevel"])))
                g.write("        [npcKeys.maxLevel] = {max_level},\n".format(max_level=self.__get_level(item["maxLevel"])))
                g.write("        [npcKeys.zoneID] = {zone_id},\n".format(zone_id=self.__get_zone_id(item)))
                g.write("        [npcKeys.spawns] = {spawns},\n".format(spawns=self.__get_spawns(item["spawns"] if "spawns" in item else [])))
                g.write("        [npcKeys.friendlyToFaction] = {friendly_to},\n".format(friendly_to=self.__get_race_string(item["reactAlliance"], item["reactHorde"])))
                g.write("        [npcKeys.questStarts] = {quest_starts},\n".format(quest_starts=self.__get_quest_starts(item)))
                g.write("        [npcKeys.questEnds] = {quest_ends},\n".format(quest_ends=self.__get_quest_ends(item)))
                g.write("    },\n")
            g.write("}\n")

    def __format_for_db(self) -> None:
        npc_input = self.__load_json_file("npc/npc_data.json")
        with Path("npc/npc_data_db.lua").open("w", encoding="utf-8") as g:
            for item in npc_input:
                g.write("[{id}] = {{".format(id=item["npcId"]))
                g.write("\"{name}\",".format(name=item["name"]))
                g.write("0,")  # minLevelHealth
                g.write("0,")  # maxLevelHealth
                g.write("{min_level},".format(min_level=self.__get_level(item["minLevel"])))
                g.write("{max_level},".format(max_level=self.__get_level(item["maxLevel"])))
                g.write("0,")  # rank
                g.write("{spawns},".format(spawns=self.__get_spawns(item["spawns"] if "spawns" in item else [], multi_line=False)))
                g.write("nil,")  # waypoints
                g.write("{zone_id},".format(zone_id=self.__get_zone_id(item)))
                g.write("{quest_starts},".format(quest_starts=self.__get_quest_starts(item)))
                g.write("{quest_ends},".format(quest_ends=self.__get_quest_ends(item)))
                g.write("0,")  # factionID
                g.write("{friendly_to},".format(friendly_to=self.__get_race_string(item["reactAlliance"], item["reactHorde"])))
                g.write("nil,")  # subName
                g.write("0},\n")  # npcFlags

    def __get_quest_starts(self, item):
        if "questStarts" in item:
            return "{" + ",".join(item["questStarts"]) + "}"
        return "nil"

    def __get_quest_ends(self, item):
        if "questEnds" in item:
            return "{" + ",".join(item["questEnds"]) + "}"
        return "nil"

    def __get_level(self, item):
        return item if int(item) < 99 else 99  # "Son of Arugal" has level 9999

    def __get_zone_id(self, item):
        return item["zoneId"] if "zoneId" in item else 0

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        sorted_data = sorted(data, key=lambda x: x.get('npcId', 0))
        # TODO Filter "sic" quest ID
        print("Data contains {} entries".format(len(sorted_data)))
        return sorted_data

    def __get_race_string(self, react_alliance: str, react_horde) -> str:
        friendly_to = ""
        if react_alliance == "1":
            friendly_to += "A"
        if react_horde == "1":
            friendly_to += "H"
        if not friendly_to:
            return "nil"

        return "\"" + friendly_to + "\""

    def __get_spawns(self, spawns, multi_line: bool = True) -> str:
        spawns_string = ""
        for spawn in spawns:
            if multi_line:
                spawns_string += "            [{}] = {{".format(spawn[0])
            else:
                spawns_string += "[{}]={{".format(spawn[0])
            # coords_string has the format "[51.8,48.8],[53.4,47.4],[53.4,47.8],[53.6,47.2],[53.6,47.6]"
            coords_string = spawn[1]
            spawn_entries = json.loads("[" + coords_string + "]")
            for entry in spawn_entries:
                spawns_string += "{{{},{}}},".format(entry[0], entry[1])
            spawns_string = spawns_string[:-1]  # Remove last comma
            if multi_line:
                spawns_string += "},\n"
            else:
                spawns_string += "},"
        if not spawns_string:
            spawns_string = "nil"
        else:
            if multi_line:
                spawns_string = "{\n" + spawns_string + "        }"
            else:
                spawns_string = "{" + spawns_string[:-1] + "}"  # Remove last comma
        return spawns_string


if __name__ == '__main__':
    formatter = NPCFormatter()
    formatter(False)
