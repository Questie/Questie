import json
from pathlib import Path


class ItemFormatter:

    def __call__(self, **kwargs):
        self.__format()

    def __format(self) -> None:
        npc_input = self.__load_json_file("item/item_data.json")
        with Path("item/item_data.lua").open("w", encoding="utf-8") as g:
            g.write("return {\n")
            for item in npc_input:
                g.write("    [{id}] = {{\n".format(id=item["itemId"]))
                g.write("        [itemKeys.name] = \"{name}\",\n".format(name=item["name"]))
                g.write("        [itemKeys.npcDrops] = {npc_drops},\n".format(npc_drops=self.__get_npc_drops(item)))
                g.write("        [itemKeys.objectDrops] = {object_drops},\n".format(object_drops=self.__get_object_drops(item)))
                g.write("        [itemKeys.itemDrops] = {item_drops},\n".format(item_drops=self.__get_item_drops(item)))
                g.write("        [itemKeys.vendors] = {vendors},\n".format(vendors=self.__get_vendors(item)))
                g.write("        [itemKeys.startQuest] = {start_quest},\n".format(start_quest=(item["questStarts"]) if "questStarts" in item else "nil"))
                g.write("    },\n")
            g.write("}\n")
    def __get_npc_drops(self, item):
        if "npcDrops" in item:
            npc_drops = map(str, sorted(set(item["npcDrops"])))
            return "{" + ",".join(npc_drops) + "}"
        else:
            return "nil"

    def __get_object_drops(self, item):
        if "objectDrops" in item:
            object_drops = map(str, sorted(set(item["objectDrops"])))
            return "{" + ",".join(object_drops) + "}"
        else:
            return "nil"

    def __get_item_drops(self, item):
        if "itemDrops" in item:
            item_drops = map(str, sorted(set(item["itemDrops"])))
            return "{" + ",".join(item_drops) + "}"
        else:
            return "nil"

    def __get_vendors(self, item):
        if "vendors" in item:
            vendors = map(str, sorted(set(item["vendors"])))
            return "{" + ",".join(vendors) + "}"
        else:
            return "nil"

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        sorted_data = sorted(data, key=lambda x: x.get('itemId', 0))
        print("Data contains {} entries".format(len(sorted_data)))
        return sorted_data


if __name__ == '__main__':
    formatter = ItemFormatter()
    formatter()
