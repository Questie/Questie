import os
import re
from pathlib import Path

from load_json_file import load_json_file


class NPCTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        npc_input = load_json_file(self.base_dir, "output/scraped_data.json")
        npc_input = sorted(npc_input, key=lambda x: int(x["npcId"]))  # Sort by npcId
        locale_files = {}

        for npc in npc_input:
            if not "name" in npc or not "locale" in npc:
                continue  # Skip npcs without a name or locale

            locale = npc["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            match = re.match(r'^(.*?)\s*<(.*?)>$', npc["name"])
            if match:
                name, subname = match.groups()
            else:
                name, subname = npc["name"], ""

            # Escape quotes in name and subname
            name = name.replace('"', '\\"')
            subname = subname.replace('"', '\\"')

            npc["name"] = name
            npc["subname"] = subname

            locale_files[locale].write("[{npcId}] = {{\"{name}\",{subName}}},\n".format(
                npcId=npc["npcId"],
                name=npc["name"],
                subName=f'\"{npc["subname"]}\"' if npc["subname"] else "nil"
            ))

        for file in locale_files.values():
            file.close()


if __name__ == '__main__':
    formatter = NPCTranslationFormatter()
    formatter()
