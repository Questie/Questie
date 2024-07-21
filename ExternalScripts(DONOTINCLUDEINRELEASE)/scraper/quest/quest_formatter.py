import json
import re
from pathlib import Path


class QuestFormatter:

    def __call__(self, **kwargs):
        self.__format_quests()

    def __format_quests(self) -> None:
        quest_input = self.__load_json_file("quest/quest_data.json")
        with Path("quest/quest_data.lua").open("w", encoding="utf-8") as g:
            g.write("return {\n")
            for item in quest_input:
                g.write("    [{id}] = {{\n".format(id=item["questId"]))
                g.write("        [questKeys.name] = \"{name}\",\n".format(name=item["name"]))
                g.write("        [questKeys.startedBy] = {npc_start},\n".format(npc_start=self.__get_start(item)))
                g.write("        [questKeys.finishedBy] = {npc_end},\n".format(npc_end=self.__get_end(item["end"])))
                g.write("        [questKeys.requiredLevel] = {reqLevel},\n".format(reqLevel=item["reqLevel"]))
                g.write("        [questKeys.questLevel] = {level},\n".format(level=item["level"]))
                g.write("        [questKeys.requiredRaces] = {reqRace},\n".format(reqRace=self.__get_race_string(item["reqRace"])))
                g.write("        [questKeys.requiredClasses] = {reqClass},\n".format(reqClass=self.__get_class_string(item["reqClass"])))
                g.write("        [questKeys.objectivesText] = {text},\n".format(text=self.__get_objectives_text(item)))
                g.write("        [questKeys.objectives] = {text},\n".format(text=self.__get_objectives(item)))
                g.write("    },\n")
            g.write("}\n")

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        filtered_sorted_data = self.__sort_and_filter_data(data)
        print("Data contains {} entries".format(len(filtered_sorted_data)))
        return filtered_sorted_data

    def __sort_and_filter_data(self, data):
        sorted_data = sorted(data, key=lambda x: int(x.get('questId', 0)))
        filtered_sorted_data = []
        for x in sorted_data:
            entry_name = x["name"]
            if entry_name != "[Never used]" and entry_name.startswith("[DNT]") is False:
                filtered_sorted_data.append(x)
        return filtered_sorted_data

    def __get_start(self, item):
        if "npcStart" in item:
            return "{{" + item["npcStart"] + "}}"
        if "objectStart" in item:
            return "{nil,{" + item["objectStart"] + "}}"
        return "nil"

    def __get_end(self, end_entry):
        if end_entry == "nil":
            return "nil"
        if isinstance(end_entry, list):
            ret = "{{"
            for entry in end_entry:
                ret += entry + ","
            ret += "}}"
            return ret
        return "{{" + end_entry + "}}"

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
        if req_race == "77":
            return "raceIDs.ALL_ALLIANCE"
        if req_race == "128":
            return "raceIDs.TROLL"
        if req_race == "178":
            return "raceIDs.ALL_HORDE"

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

    def __get_objectives_text(self, item):
        if "objectivesText" in item:
            scripped_text = re.sub(r'A level .*', '', item["objectivesText"]).strip()
            if scripped_text:
                return "{\"" + scripped_text.replace("\"", "\\\"") + "\"}"
        return "nil"

    def __get_objectives(self, item):
        if "killObjective" in item:
            objectives = ["{" + i + "}" for i in item["killObjective"]]
            return "{{" + ",".join(objectives) + "}}"
        elif "itemObjective" in item:
            objectives = ["{" + i + "}" for i in item["itemObjective"]]
            return "{nil,nil,{" + ",".join(objectives) + "}}"
        elif "spellObjective" in item:
            return "{nil,nil,nil,nil,nil,{{" + item["spellObjective"] + "}}}"
        else:
            return "nil"


if __name__ == '__main__':
    formatter = QuestFormatter()
    formatter()
