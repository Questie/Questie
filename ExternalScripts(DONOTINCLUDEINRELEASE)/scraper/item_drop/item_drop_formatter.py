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
                for entry in data:
                    #print(entry)
                    if len(entry) > 2:
                        g.write("    [{id}] = {{ -- {name}\n".format(id=entry["itemId"],name=entry["name"]))
                        for key, value in entry.items():
                            if key not in excluded_keys:
                                if value[0] == 0 or value[1] == 0:
                                    # we don't want to skip with a 'continue' because that will lead to empty NPC data,
                                    # so instead, if we detect a potential divide by zero, we simply hardcode the droprate to 0%
                                    # realistically this should never happen because wowhead will not report 0 drops but who knows!
                                    droprate = 0
                                else:
                                    droprate = (value[0] / value[1]) * 100 # converts droprate fraction to percent
                                rounded = 0
                                if droprate >= 10: # if droprate is above 10%
                                    rounded = int(round(droprate, 0)) # round to integer
                                elif droprate >= 2: # if droprate is above 2% (but less than 10%)
                                    rounded = str(round(droprate, 1)) # round to 1 decimal
                                elif droprate >= 0.01: # if droprate is above 0.01% (but less than 2%)
                                    rounded = str(round(droprate, 2)) # round to 2 decimals
                                else: # if droprate is below 0.01%
                                    rounded = str(round(droprate, 3)) # round to 3 decimals (this should almost never come up in our use case but catches 0.001% drop rates which do exist)
                                g.write("        [{npcid}] = {rate},\n".format(npcid=key,rate=rounded))
                        g.write("    },\n")
                g.write("}\n")
            except FileNotFoundError:
                print(f"Error: Could not find the file at '{json_path}'.")
                print("Please check that the 'item_drop' folder and the JSON file exist.")
            except json.JSONDecodeError:
                print(f"Error: The file '{json_path}' contains invalid JSON data.")

if __name__ == '__main__':
    formatter = ItemDropFormatter()
    formatter()
