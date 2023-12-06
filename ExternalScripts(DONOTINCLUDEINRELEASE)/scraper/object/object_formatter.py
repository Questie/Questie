import json
from pathlib import Path


class ObjectFormatter:

    def __call__(self, **kwargs):
        self.__format()

    def __format(self) -> None:
        object_input = self.__load_json_file("object_data.json")
        with Path("object_data.lua").open("w", encoding="utf-8") as g:
            g.write("return {\n")
            for item in object_input:
                g.write("    [{id}] = {{\n".format(id=item["objectId"]))
                g.write("        [objectKeys.name] = \"{name}\",\n".format(name=item["name"]))
                g.write("        [objectKeys.zoneID] = {zone_id},\n".format(zone_id=self.__get_zone_id(item["zoneId"])))
                g.write("        [objectKeys.spawns] = {spawns},\n".format(spawns=self.__get_spawns(item["spawns"])))
                g.write("    },\n")
            g.write("}\n")

    def __get_zone_id(self, item):
        return item if "zoneId" in item else 0

    def __get_spawns(self, spawns) -> str:
        spawns_string = ""
        for spawn in spawns if spawns else []:
            spawns_string += "            [{}] = {{".format(spawn[0])
            # coords_string has the format "[51.8,48.8],[53.4,47.4],[53.4,47.8],[53.6,47.2],[53.6,47.6]"
            coords_string = spawn[1]
            spawn_entries = json.loads("[" + coords_string + "]")
            for entry in spawn_entries:
                spawns_string += "{{{}, {}}},".format(entry[0], entry[1])
            spawns_string += "},\n"
        if not spawns_string:
            spawns_string = "nil"
        else:
            spawns_string = "{\n" + spawns_string + "        }"
        return spawns_string

    def __load_json_file(self, file_name: str):
        print("Loading '{}'...".format(file_name))
        with Path(file_name).open("r", encoding="utf-8") as f:
            data = json.load(f)
        sorted_data = sorted(data, key=lambda x: x.get('objectId', 0))
        print("Data contains {} entries".format(len(sorted_data)))
        return sorted_data


if __name__ == '__main__':
    formatter = ObjectFormatter()
    formatter()
