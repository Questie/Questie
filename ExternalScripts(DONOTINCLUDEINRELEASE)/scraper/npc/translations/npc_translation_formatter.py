import json
import os
import re
from pathlib import Path

class NPCTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        npc_input = self.__load_json_file("output/scraped_data.json")
        npc_input = sorted(npc_input, key=lambda x: int(x["npcId"]))  # Sort by npcId
        locale_files = {}

        for item in npc_input:
            if not "name" in item or not "locale" in item:
                continue  # Skip items without a name or locale

            locale = item["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            match = re.match(r'^(.*?)\s*<(.*?)>$', item["name"])
            if match:
                name, subname = match.groups()
            else:
                name, subname = item["name"], ""

            # Escape quotes in name and subname
            name = name.replace('"', '\\"')
            subname = subname.replace('"', '\\"')

            item["name"] = name
            item["subname"] = subname

            locale_files[locale].write("[{npcId}] = {{\"{name}\",{subName}}},\n".format(
                npcId=item["npcId"], name=item["name"], subName=f'\"{item["subname"]}\"' if item["subname"] else "nil"
            ))

        for file in locale_files.values():
            file.close()

    def __load_json_file(self, file_name: str):
        file_path = os.path.join(self.base_dir, file_name)
        print(f"Loading '{file_path}'...")
        with Path(file_path).open("r", encoding="utf-8") as f:
            data = json.load(f)
        print(f"Data contains {len(data)} entries")
        return data

if __name__ == '__main__':
    formatter = NPCTranslationFormatter()
    formatter()
