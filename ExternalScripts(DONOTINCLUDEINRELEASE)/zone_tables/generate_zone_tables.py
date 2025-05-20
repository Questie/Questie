import csv
import os

def read_csv(file_path: str) -> dict:
    csv_data = {}
    with open(file_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            csv_data[row['ID']] = row
    return csv_data

def build_zone_dicts(uimap_assignment: dict, uimap: dict, area_table: dict, read_micro_dungeons: bool) -> tuple[dict, dict]:
    area_id_to_ui_map_id = {}
    ui_map_id_to_area_id = {}
    for row_id in uimap_assignment:
        row = uimap_assignment[row_id]
        if row['OrderIndex'] == '0':
            area_id = row['AreaID']
            map_id = row['UiMapID']
            if not read_micro_dungeons and uimap[map_id]['Type'] == '5':  # 5 = "Micro-Dungeon"
                map_id = uimap[map_id]['ParentUiMapID']

            if area_id == '0':
                # Some entries in X_uimap_assignment have AreaID 0, even though there is an areaId in X_area_table.
                # So we search for it by the zone name.
                name_lang = uimap[map_id]['Name_lang']
                for mop_area_id, area in area_table.items():
                    if area['AreaName_lang'] == name_lang:
                        if mop_area_id not in area_id_to_ui_map_id:
                            area_id_to_ui_map_id[mop_area_id] = map_id
                        if map_id not in ui_map_id_to_area_id:
                            ui_map_id_to_area_id[map_id] = mop_area_id
                        else:
                            print('multiple areaIDs for UiMapID:', map_id)
                        area_id = mop_area_id
            if area_id == '0':
                print('AreaID is 0 for UiMapID:', map_id, uimap[map_id]["Name_lang"])
                continue

            if area_id not in area_id_to_ui_map_id:
                area_id_to_ui_map_id[area_id] = map_id
            if map_id not in ui_map_id_to_area_id:
                ui_map_id_to_area_id[map_id] = area_id

    return area_id_to_ui_map_id, ui_map_id_to_area_id

def write_area_to_ui_map_file(file_path: str, mappings: dict, uimap: dict):
    print("Printing results into %s..." % file_path)
    with open(file_path, 'w') as f:
        f.write('ZoneDB.private.areaIdToUiMapId = [[return {\n')
        for area_id in sorted(mappings.keys(), key=lambda x: int(x)):
            map_id = mappings[area_id]
            is_dungeon_or_raid = uimap[map_id]['Type'] == '4' and uimap[map_id]['ParentUiMapID'] != 0
            f.write(f'    [{area_id}] = {map_id}, -- {uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
        f.write('}]]')

def write_ui_map_to_area_file(file_path: str, mappings: dict, uimap: dict):
    print("Printing results into %s..." % file_path)
    with open(file_path, 'w') as f:
        f.write('ZoneDB.private.uiMapIdToAreaId = [[return {\n')
        for map_id in sorted(mappings.keys(), key=lambda x: int(x)):
            area_id = mappings[map_id]
            is_dungeon_or_raid = uimap[map_id]['Type'] == '4' and uimap[map_id]['ParentUiMapID'] != 0
            f.write(f'    [{map_id}] = {area_id}, -- {uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
        f.write('}]]')

print('Reading cata files...')
cata_area_table = read_csv('../DBC - WoW.tools/areatable_cata.csv')
cata_uimap = read_csv('../DBC - WoW.tools/uimap_cata.csv')
cata_uimap_assignment = read_csv('../DBC - WoW.tools/uimapassignment_cata.csv')

print('Reading mop files...')
mop_build_version = '5.5.0.60700'
mop_area_table = read_csv('../DBC - WoW.tools/AreaTable.%s.csv' % mop_build_version)
mop_uimap = read_csv('../DBC - WoW.tools/Uimap.%s.csv' % mop_build_version)
mop_uimap_assignment = read_csv('../DBC - WoW.tools/Uimapassignment.%s.csv' % mop_build_version)

print("Successfully read files")

print("Generating MoP mappings...")

area_id_to_ui_map_id, ui_map_id_to_area_id = build_zone_dicts(mop_uimap_assignment, mop_uimap, mop_area_table, True)

print("Successfully generated MoP mappings")

if not os.path.exists('mop'):
    os.makedirs('mop')

write_area_to_ui_map_file('mop/areaIdToUiMapId.lua', area_id_to_ui_map_id, mop_uimap)
write_ui_map_to_area_file('mop/uiMapIdToAreaId.lua', ui_map_id_to_area_id, mop_uimap)

print("Done with MoP!")

print("Generating Cata mappings...")

area_id_to_ui_map_id, ui_map_id_to_area_id = build_zone_dicts(cata_uimap_assignment, cata_uimap, cata_area_table, False)

print("Successfully generated Cata mappings")

if not os.path.exists('cata'):
    os.makedirs('cata')

write_area_to_ui_map_file('cata/areaIdToUiMapId.lua', area_id_to_ui_map_id, cata_uimap)
write_ui_map_to_area_file('cata/uiMapIdToAreaId.lua', ui_map_id_to_area_id, cata_uimap)

print("Done with Cata!")
