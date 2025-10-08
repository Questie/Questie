import os
import re
from pathlib import Path

from load_json_file import load_json_file


def cleanup_name(name):
    name = name.replace('"', '\\"')
    name = re.sub(r'.\[.*', '', name).strip()
    return name

def cleanup_objectives_text(objectives_text):
    objectives_text = objectives_text.replace('"', '\\"')

    # Untranslated things usually start with a [
    objectives_text = re.sub(r'\[.*', '', objectives_text).strip()

    # zhCN
    objectives_text = re.sub(r'。​.*', '', objectives_text).strip()

    # deDE
    objectives_text = re.sub(r'Eine Level .*', '', objectives_text).strip()
    objectives_text = re.sub(r'Ein/eine .*', '', objectives_text).strip()

    # esES
    objectives_text = re.sub(r'Una Misión .*', '', objectives_text).strip()

    # frFR
    objectives_text = re.sub(r'Une Quête.*', '', objectives_text).strip()

    # koKR
    objectives_text = re.sub(r'퀘스트.*', '', objectives_text).strip()

    # ptBR
    objectives_text = re.sub(r'Missão.*', '', objectives_text).strip()

    # ruRU
    objectives_text = re.sub(r'Задание.*', '', objectives_text).strip()

    return objectives_text

class QuestTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        quest_input = load_json_file(self.base_dir, "output/scraped_data.json")
        quest_input = sorted(quest_input, key=lambda x: int(x["questId"]))  # Sort by questId
        locale_files = {}

        for quest in quest_input:
            if not "name" in quest or not "locale" in quest:
                continue  # Skip quests without a name or locale

            locale = quest["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            name = quest["name"]
            objectives_text = quest["objectivesText"] if "objectivesText" in quest else "nil"

            # Escape quotes in name and objectives_text
            name = cleanup_name(name)

            objectives_text = cleanup_objectives_text(objectives_text)
            if quest["questId"] == "34060":
                print("objectives_text", locale, objectives_text)
            if objectives_text == "":
                objectives_text = "nil"

            objectives_text = objectives_text if objectives_text == "nil" else f"{{\"{objectives_text}\"}}"

            locale_files[locale].write("[{questId}] = {{\"{name}\", nil, {objectivesText}}},\n".format(
                questId=quest["questId"],
                name=name,
                objectivesText=objectives_text
            ))

        for file in locale_files.values():
            file.close()


if __name__ == '__main__':
    formatter = QuestTranslationFormatter()
    formatter()
