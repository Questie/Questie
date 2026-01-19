import json
from pathlib import Path

json_path = 'item_drop/item_drop_data.json' #input
lua_path = 'item_drop/item_drop_data.lua' #output

class ItemDropFormatter:

    def __call__(self, **kwargs):
        self.__format()

    def __format(self) -> None:
        npc_input = self.__load_json_file(json_path)
        with Path(lua_path).open("w", encoding="utf-8") as g:
            g.write("return {\n")
            try:
                with open(json_path, 'r') as file:
                    data = json.load(file)
                excluded_keys = {"itemId", "name"}
                for entry in data:
                    #print(entry)
                    if len(entry) > 2:
                        g.write("    [{id}] = {{ -- {name}\n".format(id=entry["itemId"],name=entry["name"]))
                        for key, value in entry.items():
                            if key not in excluded_keys:
                                droprate = (value[0] / value[1]) * 100 # converts droprate fraction to percent
                                rounded = 0
                                if droprate >= 10: # if droprate is above 10%
                                    rounded = int(round(droprate, 0)) # round to integer
                                elif droprate >= 2: # if droprate is above 5% (but less than 10%)
                                    rounded = str(round(droprate, 1)) # round to 1 decimal
                                elif droprate >= 0.01: # if droprate is above 0.01% (but less than 5%)
                                    rounded = str(round(droprate, 2)) # round to 2 decimals
                                else: # if droprate is below 0.01%
                                    rounded = str(round(droprate, 3)) # round to 3 decimals
                                g.write("        [{npcid}] = {rate},\n".format(npcid=key,rate=rounded))
                        g.write("    },\n")
            except FileNotFoundError:
                print(f"Error: Could not find the file at '{json_path}'.")
                print("Please check that the 'item_drop' folder and the JSON file exist.")
            except json.JSONDecodeError:
                print(f"Error: The file '{json_path}' contains invalid JSON data.")
            g.write("}\n")

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        sorted_data = sorted(data, key=lambda x: x.get('itemId', 0))
        print("Data contains {} entries".format(len(sorted_data)))
        return sorted_data

if __name__ == '__main__':
    formatter = ItemDropFormatter()
    formatter()
