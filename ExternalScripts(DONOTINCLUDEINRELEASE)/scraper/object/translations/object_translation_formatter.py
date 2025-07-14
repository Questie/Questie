from pathlib import Path

from load_json_file import load_json_file


class ObjectTranslationFormatter:
    def __call__(self, **kwargs):
        self.__format()

    def __format(self) -> None:
        object_input = load_json_file("scraped_data.json")

        data_by_locale = {}
        print("Filtering object names by locale...")
        for item in object_input:
            if "name" not in item:
                continue

            if item["locale"] not in data_by_locale:
                print("Adding locale: {}".format(item["locale"]))
                data_by_locale[item["locale"]] = []
            data_by_locale[item["locale"]].append(item)

        print("Sorting object names by object ID...")
        for locale, data in data_by_locale.items():
            print("data_by_locale[locale]", data_by_locale[locale][0])
            data_by_locale[locale].sort(key=lambda x: int(x.get("objectId", 0)))
            print("data_by_locale[locale]", data_by_locale[locale][0])

        print("Writing object names to file...")
        for locale, data in data_by_locale.items():
            with Path("object_names_{locale}.lua".format(locale=locale)).open("w", encoding="utf-8") as g:
                g.write("return {\n")
                for item in data:
                    name = item["name"].replace("\"", "\\\"")
                    g.write("[{id}] = \"{name}\",\n".format(id=item["objectId"], name=name))
                g.write("}")


if __name__ == "__main__":
    f = ObjectTranslationFormatter()
    f()