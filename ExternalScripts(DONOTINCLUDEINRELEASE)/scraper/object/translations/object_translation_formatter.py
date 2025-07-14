import os
from pathlib import Path

from load_json_file import load_json_file


class ObjectTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        object_input = load_json_file(self.base_dir, "output/scraped_data.json")
        object_input = sorted(object_input, key=lambda x: int(x["objectId"])) # Sort by objectId
        locale_files = {}

        for object in object_input:
            if not "name" in object or not "locale" in object:
                continue  # Skip objects without a name or locale

            locale = object["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            # Escape quotes in name
            object["name"] = object["name"].replace('"', '\\"')

            locale_files[locale].write("[{objectId}] = \"{name}\",\n".format(
                objectId=object["objectId"], name=object["name"]
            ))

        for file in locale_files.values():
            file.close()


if __name__ == "__main__":
    formatter = ObjectTranslationFormatter()
    formatter()