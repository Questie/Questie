import csv
import os
from supported_locales import LOCALES

PATCH_VERSION = "5.5.0.61916"

def process_csv(locale):
    base_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(base_dir, f"data/ItemSparse_{locale}.{PATCH_VERSION}.csv")
    output_file = os.path.join(base_dir, f"../../../../Localization/lookups/MoP/lookupItems/{locale}.lua")

    if not os.path.exists(input_file):
        print(f"Input file for locale {locale} does not exist: {input_file}")
        return

    items = []

    with open(input_file, "r", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            item_id = row.get("ID")
            display_name = row.get("Display_lang")
            if item_id and display_name:
                items.append((int(item_id), display_name.replace('"', '\\"')))

    items.sort(key=lambda x: x[0])

    with open(output_file, "w", encoding="utf-8") as lua_file:
        lua_file.write(f"if GetLocale() ~= \"{locale}\" then\n")
        lua_file.write("    return\n")
        lua_file.write("end\n\n")
        lua_file.write("---@type l10n\n")
        lua_file.write("local l10n = QuestieLoader:ImportModule(\"l10n\")\n\n")
        lua_file.write(f"l10n.itemLookup[\"{locale}\"] = loadstring([[return {{\n")

        for item_id, display_name in items:
            lua_file.write(f"[{item_id}] = \"{display_name}\",\n")

        lua_file.write("}]])\n")

    print(f"Processed {len(items)} items for locale {locale} and saved to {output_file}")

def main():
    for locale in [entry["output"] for entry in LOCALES]:
        print(f"Processing locale: {locale}")
        process_csv(locale)

if __name__ == "__main__":
    main()
