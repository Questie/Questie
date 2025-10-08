import json
import os
from pathlib import Path


def load_json_file(base_dir: str, file_name: str) -> list:
    file_path = os.path.join(base_dir, file_name)
    print(f"Loading '{file_path}'...")
    with Path(file_path).open("r", encoding="utf-8") as f:
        data = json.load(f)
    print(f"Data contains {len(data)} entries")
    return data
