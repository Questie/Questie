import json
import re
from pathlib import Path


class TranslationFormatter:

    def __call__(self, **kwargs):
        self.__format_quests()

    def __format_quests(self) -> None:
        quest_input = self.__load_json_file("quest_data.json")

        input_by_locale = {}
        for item in quest_input:
            if item["locale"] not in input_by_locale:
                input_by_locale[item["locale"]] = []
            input_by_locale[item["locale"]].append(item)

        for locale, data in input_by_locale.items():
            locale = self.__get_locale(locale)
            with Path("quest_data_{}.lua".format(locale)).open("w", encoding="utf-8") as g:
                g.write("local lookup = l10n.questLookup[\"{}\"]\n\n".format(locale))
                for item in data:
                    g.write("lookup[{id}] = {{{title},nil}}\n".format(id=item["questId"], title=self.__get_title(item)))

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        filtered_sorted_data = self.__sort_and_filter_data(data)
        print("Data contains {} entries".format(len(filtered_sorted_data)))
        return filtered_sorted_data

    def __sort_and_filter_data(self, data):
        sorted_data = sorted(data, key=lambda x: int(x.get('questId', 0)))
        return sorted_data

    def __get_locale(self, locale):
        if locale == "cn":
            return "zhCN"
        if locale == "de":
            return "deDE"
        if locale == "es":
            return "esES"
        if locale == "fr":
            return "frFR"
        if locale == "ko":
            return "koKR"
        if locale == "pt":
            return "ptBR"
        if locale == "ru":
            return "ruRU"


    def __get_title(self, item):
        if "title" in item:
            return "\"" + item["title"].replace("\"", "\\\"") + "\""
        return "nil"



if __name__ == '__main__':
    formatter = TranslationFormatter()
    formatter()
