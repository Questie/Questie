import os
import re


# Set working directory to script's directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

INPUT_FILE = 'output/de.lua'
OUTPUT_FILE = '../../../../Localization/lookups/MoP/lookupNpcs/deDE.lua'


def main():
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        lines += f.readlines()

    # Only keep lines that look like [1234] = {"name",...},
    entry_re = re.compile(r"^\s*\[(\d+)]\s*=\s*\{(.*)},?\s*$")
    entries = []
    seen_ids = set()
    for line in lines:
        m = entry_re.match(line)
        if m:
            npc_id = int(m.group(1))
            if npc_id not in seen_ids:
                rest = m.group(2)
                entries.append((npc_id, rest))
                seen_ids.add(npc_id)

    entries.sort(key=lambda x: x[0])

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("if GetLocale() ~= \"deDE\" then\n")
        f.write("    return\n")
        f.write("end\n\n")
        f.write("---@type l10n\n")
        f.write("local l10n = QuestieLoader:ImportModule(\"l10n\")\n\n")
        f.write("l10n.npcNameLookup[\"deDE\"] = loadstring([[return {\n")

        for npc_id, rest in entries:
            f.write(f"[{npc_id}] = {{{rest}}},\n")

        f.write("}]])\n")

if __name__ == '__main__':
    main()

