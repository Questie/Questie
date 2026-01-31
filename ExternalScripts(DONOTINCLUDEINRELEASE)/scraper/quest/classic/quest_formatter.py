import json
import re
from pathlib import Path

class ClassicQuestFormatter:

    def __call__(self, **kwargs):
        self.__format_quests()

    def __format_quests(self) -> None:
        quest_input = self.__load_json_file("quest/classic/quest_data.json")
        with Path("quest/classic/quest_data.lua").open("w", encoding="utf-8") as g:
            g.write("-- AUTO GENERATED FILE! DO NOT EDIT!")
            g.write("\n")
            g.write("---@class QuestieClassicQuestReputationFixes\n")
            g.write("local QuestieClassicQuestReputationFixes = QuestieLoader:CreateModule(\"QuestieClassicQuestReputationFixes\")\n")
            g.write("\n")
            g.write("---@type QuestieDB\n")
            g.write("local QuestieDB = QuestieLoader:ImportModule(\"QuestieDB\")\n")
            g.write("\n")
            g.write("function QuestieClassicQuestReputationFixes:Load()\n")
            g.write("    local questKeys = QuestieDB.questKeys\n")
            g.write("\n")
            g.write("    return {\n")
            for item in quest_input:
                g.write("        [{id}] = {{\n".format(id=item["questId"]))
                g.write("            [questKeys.reputationReward] = {repRewards},\n".format(repRewards=self.__get_reputation_rewards(item)))
                g.write("        },\n")
            g.write("    }\n")
            g.write("end\n")

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

    def __get_reputation_rewards(self, item) -> str:
        if "repRewards" in item:
            rewards = []
            for reward in item["repRewards"]:
                rewards.append("{" + reward[0] + "," + reward[1] + "}")

            return "{" + ",".join(rewards) + "}"
        else:
            return "{}"

if __name__ == '__main__':
    formatter = ClassicQuestFormatter()
    formatter()
