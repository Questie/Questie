import csv

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
with open('../DBC - WoW.tools/AreaTable.5.5.0.60548.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mop_area_table[row['ID']] = row

mop_uimap = {}
with open('../DBC - WoW.tools/Uimap.5.5.0.60548.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mop_uimap[row['ID']] = row

mop_uimap_assignment = {}
with open('../DBC - WoW.tools/Uimapassignment.5.5.0.60548.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        mop_uimap_assignment[row['ID']] = row

print("Successfully read files")
print("Generating mappings...")

area_id_to_ui_map_id = {}
ui_map_id_to_area_id = {}
for row_id in mop_uimap_assignment:
    row = mop_uimap_assignment[row_id]
    if row['OrderIndex'] == '0':
        area_id = row['AreaID']
        map_id = row['UiMapID']

        if area_id == '0':
            # Some entries in mop_uimap_assignment have AreaID 0, even though there is an areaId in mop_area_table.
            # So we search for it by the zone name.
            name_lang = mop_uimap[map_id]['Name_lang']
            for mop_area_id, area in mop_area_table.items():
                if area['AreaName_lang'] == name_lang:
                    area_id = mop_area_id
                    break
        if area_id == '0':
            print('AreaID is 0 for UiMapID:', map_id, mop_uimap[map_id]["Name_lang"])
            continue

        if area_id not in area_id_to_ui_map_id:
            area_id_to_ui_map_id[area_id] = map_id
        else:
            print('double for AreaID:', area_id)
        if map_id not in ui_map_id_to_area_id:
            ui_map_id_to_area_id[map_id] = area_id
        else:
            print('double for UiMapID:', map_id)

print("Successfully generated mappings")

print("Printing results into areaIdToUiMapId.lua...")
with open('areaIdToUiMapId.lua', 'w') as f:
    f.write('ZoneDB.private.areaIdToUiMapId = [[return {\n')
    for area_id in sorted(area_id_to_ui_map_id.keys(), key=lambda x: int(x)):
        map_id = area_id_to_ui_map_id[area_id]
        is_dungeon_or_raid = mop_uimap[map_id]['Type'] == '4' and mop_uimap[map_id]['ParentUiMapID'] != 0
        f.write(f'    [{area_id}] = {map_id}, -- {mop_uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
    f.write('}]]')

print("Printing results into uiMapIdToAreaId.lua...")
with open('uiMapIdToAreaId.lua', 'w') as f:
    f.write('ZoneDB.private.uiMapIdToAreaId = [[return {\n')
    for map_id in sorted(ui_map_id_to_area_id.keys(), key=lambda x: int(x)):
        area_id = ui_map_id_to_area_id[map_id]
        is_dungeon_or_raid = mop_uimap[map_id]['Type'] == '4' and mop_uimap[map_id]['ParentUiMapID'] != 0
        f.write(f'    [{map_id}] = {area_id}, -- {mop_uimap[map_id]["Name_lang"]}{" - (Dungeon/Raid)" if is_dungeon_or_raid else ""}\n')
    f.write('}]]')

print("Done!")
