import json
from pathlib import Path

json_path = 'item_drop/item_drop_data.json' #input
lua_path = 'item_drop/item_drop_data.lua' #output

class ItemDropFormatter:

    def __call__(self, **kwargs):
        self.__format()

    def __format(self) -> None:
        with Path(lua_path).open("w", encoding="utf-8") as g:
            try:
                g.write("return {\n")
                with open(json_path, 'r') as file:
                    data = json.load(file)

                excluded_keys = {"itemId", "name"}
                sorted_data = sorted(data, key=lambda x: int(x.get("itemId", 0)))

                for entry in sorted_data:
                    if len(entry) > 2:
                        g.write("    [{id}] = {{ -- {name}\n".format(id=entry["itemId"], name=entry["name"]))

                        npc_keys = [k for k in entry.keys() if k not in excluded_keys]
                        npc_keys.sort(key=int)

                        for key in npc_keys:
                            value = entry[key]
                            if value[0] == 0 or value[1] == 0:
                                droprate = 0
                            else:
                                droprate = (value[0] / value[1]) * 100

                            g.write("        [{npcid}] = {rate},\n".format(npcid=key, rate=str(round(droprate, 4))))

                        g.write("    },\n")
                g.write("}\n")
            except FileNotFoundError:
                print(f"Error: Could not find the file at '{json_path}'.")
            except json.JSONDecodeError:
                print(f"Error: The file '{json_path}' contains invalid JSON data.")

if __name__ == '__main__':
    formatter = ItemDropFormatter()
    formatter()