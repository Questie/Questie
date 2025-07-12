import json
import re
from pathlib import Path

class NPCTranslationFormatter:

    def __call__(self, **kwargs):
        self.__extract_subnames()

    def __extract_subnames(self) -> None:
        npc_input = self.__load_json_file("translations/scraped_data.json")
        with Path("translations/data_with_subnames.lua").open("w", encoding="utf-8") as g:
            updated_data = []
            for item in npc_input:
                if not "name" in item:
                    continue  # Skip items without a name

                match = re.match(r'^(.*?)\s*<(.*?)>$', item["name"])
                if match:
                    name, subname = match.groups()
                else:
                    name, subname = item["name"], ""

                item["name"] = name
                item["subname"] = subname
                updated_data.append(item)

            for item in updated_data:
                g.write("[{npcId}] = {{\"{name}\",{subName}}},\n".format(npcId=item["npcId"], name=item["name"], subName=f'"{item["subname"]}"' if item["subname"] else "nil"))

    def __load_json_file(self, file_name: str):
        print(f"Loading '{file_name}'...")
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        print(f"Data contains {len(data)} entries")
        return data

if __name__ == '__main__':
    formatter = NPCTranslationFormatter()
    formatter()
