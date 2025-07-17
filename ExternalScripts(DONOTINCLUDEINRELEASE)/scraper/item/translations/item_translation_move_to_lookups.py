import os
import re

from supported_locales import LOCALES


def merge_locales(input_locale, output_locale):
    base_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(base_dir, f'output/{input_locale}.lua')
    output_file = os.path.join(base_dir, f'../../../../Localization/lookups/MoP/lookupItems/{output_locale}.lua')

    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    with open(output_file, 'r', encoding='utf-8') as f:
        lines += f.readlines()

    # Only keep lines that look like [1234] = "name",
    entry_re = re.compile(r"^\s*\[(\d+)]\s*=\s*\"(.*?)\",?\s*$")
    entries = []
    seen_ids = set()
    for line in lines:
        m = entry_re.match(line)
        if m:
            npc_id = int(m.group(1))
            if npc_id not in seen_ids:
                name = m.group(2)
                entries.append((npc_id, name))
                seen_ids.add(npc_id)

    entries.sort(key=lambda x: x[0])

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f'if GetLocale() ~= "{output_locale}" then\n')
        f.write("    return\n")
        f.write("end\n\n")
        f.write("---@type l10n\n")
        f.write("local l10n = QuestieLoader:ImportModule(\"l10n\")\n\n")
        f.write(f'l10n.itemLookup["{output_locale}"] = loadstring([[return {{\n')

        for npc_id, name in entries:
            f.write(f"[{npc_id}] = \"{name}\",\n")

        f.write("}]])\n")

def main():
    for locale in LOCALES:
        print(f"Merging {locale['input']} into {locale['output']}...")
        merge_locales(locale['input'], locale['output'])
    print("Done merging locales.")

if __name__ == '__main__':
    main()
