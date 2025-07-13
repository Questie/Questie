import json
import os
from pathlib import Path

class QuestTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        quest_input = self.__load_json_file("output/scraped_data.json")
        quest_input = sorted(quest_input, key=lambda x: int(x["questId"]))  # Sort by questId
        locale_files = {}

        for item in quest_input:
            if not "name" in item or not "locale" in item:
                continue  # Skip items without a name or locale

            locale = item["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            name = item["name"]
            objectives_text = item["objectivesText"] if "objectivesText" in item else "nil"

            # Escape quotes in name and objectives_text
            name = name.replace('"', '\\"')
            objectives_text = objectives_text.replace('"', '\\"')

            objectives_text = objectives_text if objectives_text == "nil" else f"{{\"{objectives_text}\"}}"

            locale_files[locale].write("[{questId}] = {{\"{name}\", nil, {objectivesText}}},\n".format(
                questId=item["questId"],
                name=name,
                objectivesText=objectives_text
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
    formatter = QuestTranslationFormatter()
    formatter()
