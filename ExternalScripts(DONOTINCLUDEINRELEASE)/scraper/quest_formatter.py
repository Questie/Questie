import json
from pathlib import Path


class Formatter:

    def __call__(self, **kwargs):
        self.__format_quests()

    def __format_quests(self) -> None:
        quest_input = self.__load_json_file("quest_data.json")
        with Path("quest_data.lua").open("w", encoding="utf-8") as g:
            g.write("return {\n")
            for item in quest_input:
                g.write("\t[{id}] = {{\n".format(id=item["questId"]))
                g.write("\t\t[questKeys.name] = \"{name}\",\n".format(name=item["name"]))
                g.write("\t\t[questKeys.startedBy] = {{{{{npc_start}}}}},\n".format(npc_start=item["start"]))
                g.write("\t\t[questKeys.finishedBy] = {{{{{npc_end}}}}},\n".format(npc_end=item["end"]))
                g.write("\t\t[questKeys.requiredLevel] = {reqLevel},\n".format(reqLevel=item["reqLevel"]))
                g.write("\t\t[questKeys.questLevel] = {level},\n".format(level=item["level"]))
                g.write("\t\t[questKeys.requiredRaces] = {reqRace},\n".format(reqRace=self.__get_race_string(item["reqRace"])))
                g.write("\t\t[questKeys.requiredClasses] = {reqClass},\n".format(reqClass=self.__get_class_string(item["reqClass"])))
                g.write("\t},\n")
            g.write("}\n")

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
            # data.sort(key=lambda k: int(k["id"]))
        print("Data contains {} entries".format(len(data)))
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
    formatter = Formatter()
    formatter()
