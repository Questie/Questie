import os
from pathlib import Path

from load_json_file import load_json_file


class ItemTranslationFormatter:

    def __call__(self, **kwargs):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.__format()

    def __format(self) -> None:
        item_input = load_json_file(self.base_dir, "output/scraped_data.json")
        item_input = sorted(item_input, key=lambda x: int(x["itemId"])) # Sort by itemId
        locale_files = {}

        for item in item_input:
            if not "name" in item or not "locale" in item:
                continue  # Skip items without a name or locale

            locale = item["locale"]
            if locale not in locale_files:
                print(f"Creating file for locale: {locale}")
                file_path = os.path.join(self.base_dir, f"output/{locale}.lua")
                locale_files[locale] = Path(file_path).open("w", encoding="utf-8")

            # Escape quotes in name
            item["name"] = item["name"].replace('"', '\\"')

            locale_files[locale].write("[{itemId}] = \"{name}\",\n".format(
                itemId=item["itemId"], name=item["name"]
            ))

        for file in locale_files.values():
            file.close()


if __name__ == "__main__":
    formatter = ItemTranslationFormatter()
    formatter()