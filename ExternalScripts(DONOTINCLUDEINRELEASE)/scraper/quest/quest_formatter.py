import json
from pathlib import Path


class QuestFormatter:

    def __call__(self, **kwargs):
        self.__format_quests()

    def __format_quests(self) -> None:
        quest_input = self.__load_json_file("quest_data.json")
        with Path("quest_data.lua").open("w", encoding="utf-8") as g:
            g.write("return {\n")
            for item in quest_input:
                g.write("    [{id}] = {{\n".format(id=item["questId"]))
                g.write("        [questKeys.name] = \"{name}\",\n".format(name=item["name"]))
                g.write("        [questKeys.startedBy] = {{{{{npc_start}}}}},\n".format(npc_start=item["start"]))
                g.write("        [questKeys.finishedBy] = {{{{{npc_end}}}}},\n".format(npc_end=item["end"]))
                g.write("        [questKeys.requiredLevel] = {reqLevel},\n".format(reqLevel=item["reqLevel"]))
                g.write("        [questKeys.questLevel] = {level},\n".format(level=item["level"]))
                g.write("        [questKeys.requiredRaces] = {reqRace},\n".format(reqRace=self.__get_race_string(item["reqRace"])))
                g.write("        [questKeys.requiredClasses] = {reqClass},\n".format(reqClass=self.__get_class_string(item["reqClass"])))
                g.write("    },\n")
            g.write("}\n")

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        sorted_data = sorted(data, key=lambda x: x.get('questId', 0))
        print("Data contains {} entries".format(len(sorted_data)))
        return data

    def __get_race_string(self, req_race: int) -> str:
        if req_race == "0":
            return "raceIDs.NONE"
        if req_race == "1":
            return "raceIDs.HUMAN"
        if req_race == "2":
            return "raceIDs.ORC"
        if req_race == "4":
            return "raceIDs.DWARF"
        if req_race == "8":
            return "raceIDs.NIGHTELF"
        if req_race == "16":
            return "raceIDs.UNDEAD"
        if req_race == "32":
            return "raceIDs.TAUREN"
        if req_race == "64":
            return "raceIDs.GNOME"
        if req_race == "128":
            return "raceIDs.TROLL"

    def __get_class_string(self, req_class: int) -> str:
        if req_class == "0":
            return "classIDs.NONE"
        if req_class == "1":
            return "classIDs.WARRIOR"
        if req_class == "2":
            return "classIDs.PALADIN"
        if req_class == "4":
            return "classIDs.HUNTER"
        if req_class == "8":
            return "classIDs.ROGUE"
        if req_class == "16":
            return "classIDs.PRIEST"
        if req_class == "64":
            return "classIDs.SHAMAN"
        if req_class == "128":
            return "classIDs.MAGE"
        if req_class == "256":
            return "classIDs.WARLOCK"
        if req_class == "1024":
            return "classIDs.DRUID"


if __name__ == '__main__':
    formatter = QuestFormatter()
    formatter()
