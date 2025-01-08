import json
from pathlib import Path


def load_json_file(file_name: str):
    print("Loading '{}'...".format(file_name))
    with Path(file_name).open("r", encoding="utf-8") as f:
        data = json.load(f)
    sorted_data = sorted(data, key=lambda x: x.get('objectId', 0))
    print("Data contains {} entries".format(len(sorted_data)))
    return sorted_data