import csv
import os

def build_zone_dicts(uimap_assignment, uimap, area_table):
    area_id_to_ui_map_id = {}
    ui_map_id_to_area_id = {}
    for row_id in uimap_assignment:
        row = uimap_assignment[row_id]
        if row['OrderIndex'] == '0':
            area_id = row['AreaID']
            map_id = row['UiMapID']
            if uimap[map_id]['Type'] == '5':  # 5 = "Micro-Dungeon"
                map_id = uimap[map_id]['ParentUiMapID']

            if area_id == '0':
                # Some entries in X_uimap_assignment have AreaID 0, even though there is an areaId in X_area_table.
                # So we search for it by the zone name.
                name_lang = uimap[map_id]['Name_lang']
                for mop_area_id, area in area_table.items():
                    if area['AreaName_lang'] == name_lang:
                        area_id = mop_area_id
                        break
            if area_id == '0':
                print('AreaID is 0 for UiMapID:', map_id, uimap[map_id]["Name_lang"])
                continue

            if area_id not in area_id_to_ui_map_id:
                area_id_to_ui_map_id[area_id] = map_id
            else:
                print('double for AreaID:', area_id)
            if map_id not in ui_map_id_to_area_id:
                ui_map_id_to_area_id[map_id] = area_id
            else:
                print('double for UiMapID:', map_id)

    return area_id_to_ui_map_id, ui_map_id_to_area_id

print('Reading cata files...')

cata_area_table = {}
with open('../DBC - WoW.tools/areatable_cata.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cata_area_table[row['ID']] = row

cata_uimap = {}
with open('../DBC - WoW.tools/uimap_cata.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cata_uimap[row['ID']] = row

cata_uimap_assignment = {}
with open('../DBC - WoW.tools/uimapassignment_cata.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cata_uimap_assignment[row['ID']] = row

print('Reading mop files...')

mop_area_table = {}
with open('../DBC - WoW.tools/AreaTable.5.5.0.60700.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mop_area_table[row['ID']] = row

mop_uimap = {}
with open('../DBC - WoW.tools/Uimap.5.5.0.60700.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mop_uimap[row['ID']] = row

mop_uimap_assignment = {}
with open('../DBC - WoW.tools/Uimapassignment.5.5.0.60700.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mop_uimap_assignment[row['ID']] = row

print("Successfully read files")
print("Generating MoP mappings...")

area_id_to_ui_map_id, ui_map_id_to_area_id = build_zone_dicts(mop_uimap_assignment, mop_uimap, mop_area_table)

print("Successfully generated MoP mappings")

if not os.path.exists('mop'):
    os.makedirs('mop')

print("Printing results into mop/areaIdToUiMapId.lua...")
with open('mop/areaIdToUiMapId.lua', 'w') as f:
    f.write('ZoneDB.private.areaIdToUiMapId = [[return {\n')
    for area_id in sorted(area_id_to_ui_map_id.keys(), key=lambda x: int(x)):
        map_id = area_id_to_ui_map_id[area_id]
        is_dungeon_or_raid = mop_uimap[map_id]['Type'] == '4' and mop_uimap[map_id]['ParentUiMapID'] != 0
        f.write(f'    [{area_id}] = {map_id}, -- {mop_uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
    f.write('}]]')

print("Printing results into mop/uiMapIdToAreaId.lua...")
with open('mop/uiMapIdToAreaId.lua', 'w') as f:
    f.write('ZoneDB.private.uiMapIdToAreaId = [[return {\n')
    for map_id in sorted(ui_map_id_to_area_id.keys(), key=lambda x: int(x)):
        area_id = ui_map_id_to_area_id[map_id]
        is_dungeon_or_raid = mop_uimap[map_id]['Type'] == '4' and mop_uimap[map_id]['ParentUiMapID'] != 0
        f.write(f'    [{map_id}] = {area_id}, -- {mop_uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
    f.write('}]]')

print("Done with MoP!")

print("Generating Cata mappings...")

area_id_to_ui_map_id, ui_map_id_to_area_id = build_zone_dicts(cata_uimap_assignment, cata_uimap, cata_area_table)

print("Successfully generated Cata mappings")

if not os.path.exists('cata'):
    os.makedirs('cata')

print("Printing results into cata/areaIdToUiMapId.lua...")
with open('cata/areaIdToUiMapId.lua', 'w') as f:
    f.write('ZoneDB.private.areaIdToUiMapId = [[return {\n')
    for area_id in sorted(area_id_to_ui_map_id.keys(), key=lambda x: int(x)):
        map_id = area_id_to_ui_map_id[area_id]
        is_dungeon_or_raid = cata_uimap[map_id]['Type'] == '4' and cata_uimap[map_id]['ParentUiMapID'] != 0
        f.write(f'    [{area_id}] = {map_id}, -- {cata_uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
    f.write('}]]')

print("Printing results into cata/uiMapIdToAreaId.lua...")
with open('cata/uiMapIdToAreaId.lua', 'w') as f:
    f.write('ZoneDB.private.uiMapIdToAreaId = [[return {\n')
    for map_id in sorted(ui_map_id_to_area_id.keys(), key=lambda x: int(x)):
        area_id = ui_map_id_to_area_id[map_id]
        is_dungeon_or_raid = cata_uimap[map_id]['Type'] == '4' and cata_uimap[map_id]['ParentUiMapID'] != 0
        f.write(f'    [{map_id}] = {area_id}, -- {cata_uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
    f.write('}]]')

print("Done with Cata!")
