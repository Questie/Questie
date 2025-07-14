import json
import os
from pathlib import Path


class ObjectTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        object_input = self.__load_json_file("output/scraped_data.json")
        object_input = sorted(object_input, key=lambda x: int(x["objectId"])) # Sort by objectId
        locale_files = {}

        for item in object_input:
            if not "name" in item or not "locale" in item:
                continue  # Skip items without a name or locale

            locale = item["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            # Escape quotes in name
            item["name"] = item["name"].replace('"', '\\"')

            locale_files[locale].write("[{objectId}] = {{\"{name}\"}},\n".format(
                objectId=item["objectId"], name=item["name"]
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


if __name__ == "__main__":
    formatter = ObjectTranslationFormatter()
    formatter()