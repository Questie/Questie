# Prompt to create the code, GPT-3.5
# Please write me a Python program that reads the entire CSV for each locale and saves it in a dict with ID as key within each locale.
# Then it should create a lua table named "l10n.factionGroupLookup" with tables for each locale as a string and within that table have tables that have the ParentFactionID as key.
# Put a comment above the ParentFactionID key with the Name_lang of the faction that has ParentFactionID as it's ID within the same CSV, if the ID does not exist put UNKNOWN.
# Within the ParentFactionID table place all factions with the same ParentFactionID like this [ID] = "Name_lang".
# Put the locales in a list and use that to build the filenames instead of putting the full names into a list.
# Save the output to a file with utf-8 encoding.
# Small incomplete example of output with keynames instead of actual values:
# l10n.factionGroupLookup = {
# 	[locale] = {
#     -- Name_lang of ParentFactionID
# 		[ParentFactionID] = {
# 			[ID] = "Name_lang",
# 		},
#     }
# }

# Faction_enGB.csv:
# ReputationRaceMask[0],ReputationRaceMask[1],ReputationRaceMask[2],ReputationRaceMask[3],Name_lang,Description_lang,ID,ReputationIndex,ParentFactionID,Expansion,FriendshipRepID,Flags,ParagonFactionID,ReputationClassMask[0],ReputationClassMask[1],ReputationClassMask[2],ReputationClassMask[3],ReputationFlags[0],ReputationFlags[1],ReputationFlags[2],ReputationFlags[3],ReputationBase[0],ReputationBase[1],ReputationBase[2],ReputationBase[3],ReputationMax[0],ReputationMax[1],ReputationMax[2],ReputationMax[3],ParentFactionMod[0],ParentFactionMod[1],ParentFactionCap[0],ParentFactionCap[1]
# 0,0,0,0,"PLAYER, Human",,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,5
# 0,0,0,0,"PLAYER, Orc",,2,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,5
# 0,0,0,0,"PLAYER, Dwarf",,3,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,5
# 0,0,0,0,"PLAYER, Night Elf",,4,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,5
# 0,0,0,0,"PLAYER, Undead",,5,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,5
# 0,0,0,0,"PLAYER, Tauren ",,6,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,5,5
# This is an example of Faction_enGB.csv additional region files are below:
# Faction_deDE.csv
# Faction_enUS.csv
# Faction_esES.csv
# Faction_esMX.csv
# Faction_frFR.csv
# Faction_itIT.csv
# Faction_koKR.csv
# Faction_ptBR.csv
# Faction_ptPT.csv
# Faction_ruRU.csv
# Faction_zhCN.csv
# Faction_zhTW.csv

# It should also only save factions that are referenced in a lua file called wotlkQuestDB.lua.
# Either in requiredMinRep or requiredMaxRep or in the objectives table. If the faction is not referenced in any of those tables it should not be saved.
# faction(int) is the ID of the faction.

# QuestieDB.questKeys = {
#     ['name'] = 1, -- string
#     ['startedBy'] = 2, -- table
#         --['creatureStart'] = 1, -- table {creature(int),...}
#         --['objectStart'] = 2, -- table {object(int),...}
#         --['itemStart'] = 3, -- table {item(int),...}
#     ['finishedBy'] = 3, -- table
#         --['creatureEnd'] = 1, -- table {creature(int),...}
#         --['objectEnd'] = 2, -- table {object(int),...}
#     ['requiredLevel'] = 4, -- int
#     ['questLevel'] = 5, -- int
#     ['requiredRaces'] = 6, -- bitmask
#     ['requiredClasses'] = 7, -- bitmask
#     ['objectivesText'] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
#     ['triggerEnd'] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
#     ['objectives'] = 10, -- table
#         --['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
#         --['objectObjective'] = 2, -- table {{object(int), text(string)},...}
#         --['itemObjective'] = 3, -- table {{item(int), text(string)},...}
#         --['reputationObjective'] = 4, -- table: {faction(int), value(int)}
#         --['killCreditObjective'] = 5, -- table: {{{creature(int), ...}, baseCreatureID, baseCreatureText}, ...}
#     ['sourceItemId'] = 11, -- int, item provided by quest starter
#     ['preQuestGroup'] = 12, -- table: {quest(int)}
#     ['preQuestSingle'] = 13, -- table: {quest(int)}
#     ['childQuests'] = 14, -- table: {quest(int)}
#     ['inGroupWith'] = 15, -- table: {quest(int)}
#     ['exclusiveTo'] = 16, -- table: {quest(int)}
#     ['zoneOrSort'] = 17, -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
#     ['requiredSkill'] = 18, -- table: {skill(int), value(int)}
#     ['requiredMinRep'] = 19, -- table: {faction(int), value(int)}
#     ['requiredMaxRep'] = 20, -- table: {faction(int), value(int)}
#     ['requiredSourceItems'] = 21, -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
#     ['nextQuestInChain'] = 22, -- int: if this quest is active/finished, the current quest is not available anymore
#     ['questFlags'] = 23, -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
#     ['specialFlags'] = 24, -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
#     ['parentQuest'] = 25, -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
#     ['rewardReputation'] = 26, --table: {{faction(int), value(int)},...}, a list of reputation rewarded upon quest completion
#     ['extraObjectives'] = 27, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
#     ['requiredSpell'] = 28, -- int: quest is only available if character has this spellID
#     ['requiredSpecialization'] = 29, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
# }

# QuestieDB.questData = [[return {
# [1] = {"The \"Chow\" Quest (123)aa",nil,nil,1,4,0,nil,{"Kill Kobold Vermin, 2 of em."},nil,nil,nil,nil,nil,nil,nil,nil,15},
# [2] = {"Sharptalon's Claw",{nil,nil,{16305}},{{12696}},20,30,690,nil,{"Bring Sharptalon's Claw to Senani Thunderheart at Splintertree Post, Ashenvale."},nil,nil,16305,nil,{6383},nil,{23,24},nil,331,nil,nil,nil,nil,nil,nil,nil,nil,{{81,250}}},
# [5] = {"Jitters' Growling Gut",{{288}},{{272}},17,20,1101,nil,{"Speak with Chef Grual."},nil,nil,nil,nil,{163},nil,nil,nil,10,nil,nil,nil,nil,93,8,nil,nil,{{72,25}}},
# [6] = {"Bounty on Garrick Padfoot",{{823}},{{823}},2,5,1101,nil,{"Kill Garrick Padfoot and bring his head to Deputy Willem at Northshire Abbey."},nil,{nil,nil,{{182}}},nil,nil,{18},nil,nil,nil,9,nil,nil,nil,nil,nil,8,nil,nil,{{72,150}}},
# [7] = {"Kobold Camp Cleanup",{{197}},{{197}},1,2,1101,nil,{"Kill 10 Kobold Vermin, then return to Marshal McBride."},nil,{{{6}}},nil,nil,{783},nil,nil,nil,9,nil,nil,nil,nil,nil,8,nil,nil,{{72,250}}},
# [8] = {"A Rogue's Deal",{{6784}},{{5688}},1,5,690,nil,{"Deliver the Nondescript Letter to Innkeeper Renee in Tirisfal Glades."},nil,nil,7628,nil,nil,nil,nil,nil,154,nil,nil,nil,nil,nil,nil,nil,nil,{{68,25}}},
# [9] = {"The Killing Fields",{{233}},{{233}},8,15,1101,nil,{"Farmer Saldean wants you to kill 20 Harvest Watchers."},nil,{{{114}}},nil,nil,nil,nil,nil,nil,40,nil,nil,nil,nil,nil,8,nil,nil,{{72,250}}},
# [10] = {"The Scrimshank Redemption",{{7724}},{{7724}},39,48,0,nil,{"Discover the fate of Junior Surveyor Scrimshank, and bring either him or his surveying equipment to Senior Surveyor Fizzledowser in Gadgetzan."},nil,{nil,nil,{{8593}}},nil,nil,{82},nil,nil,nil,440,nil,nil,nil,nil,110,8,nil,nil,{{369,250}}},
# [11] = {"Riverpaw Gnoll Bounty",{{963}},{{963}},6,10,1101,nil,{"Bring 8 Painted Gnoll Armbands to Deputy Rainer at the Barracks."},nil,{nil,nil,{{782}}},nil,nil,{239},nil,nil,nil,12,nil,nil,nil,nil,nil,8,nil,nil,{{72,250}}},
# [12] = {"The People's Militia",{{234}},{{234}},9,12,1101,nil,{"Gryan Stoutmantle wants you to kill 15 Defias Trappers and 15 Defias Smugglers then return to him on Sentinel Hill."},nil,{{{504},{95}}},nil,nil,nil,nil,nil,nil,40,nil,nil,nil,nil,13,8,nil,nil,{{72,250}}},
# [13] = {"The People's Militia",{{234}},{{234}},9,14,1101,nil,{"Gryan Stoutmantle wants you to kill 15 Defias Pillagers and 15 Defias Looters and return to him on Sentinel Hill."},nil,{{{589},{590}}},nil,nil,{12},nil,nil,nil,40,nil,nil,nil,nil,14,8,nil,nil,{{72,250}}},
# [14] = {"The People's Militia",{{234}},{{234}},9,17,1101,nil,{"Gryan Stoutmantle wants you to kill 15 Defias Highwaymen, 5 Defias Pathstalkers and 5 Defias Knuckledusters then return to him on Sentinel Hill."},nil,{{{122},{121},{449}}},nil,nil,{13},nil,nil,nil,40,nil,nil,nil,nil,nil,8,nil,nil,{{72,350}}},
# [15] = {"Investigate Echo Ridge",{{197}},{{197}},2,3,1101,nil,{"Kill 10 Kobold Workers, then report back to Marshal McBride."},nil,{{{257}}},nil,nil,{7},nil,nil,nil,9,nil,nil,nil,nil,21,8,nil,nil,{{72,250}}},
# [16] = {"Give Gerard a Drink",{{255}},{{255}},1,1,1101,nil,nil,nil,{nil,nil,{{159}}},nil,nil,nil,nil,nil,nil,12,nil,nil,nil,nil,nil,8,1},
# [17] = {"Uldaman Reagent Run",{{1470}},{{1470}},38,42,1101,nil,{"Bring 12 Magenta Fungus Caps to Ghak Healtouch in Thelsamar."},nil,{nil,nil,{{8047}}},nil,nil,{2500},nil,nil,nil,1517,nil,nil,nil,nil,nil,8,nil,nil,{{47,250}}},
# [18] = {"Brotherhood of Thieves",{{823}},{{823}},2,4,1101,nil,{"Bring 12 Red Burlap Bandanas to Deputy Willem outside the Northshire Abbey."},nil,{nil,nil,{{752}}},nil,nil,{783},nil,nil,nil,9,nil,nil,nil,nil,nil,8,nil,nil,{{72,250}}},
# [19] = {"Tharil'zun",{{382}},{{382}},18,25,1101,nil,{"Bring Tharil'zun's Head to Marshal Marris in Redridge."},nil,{nil,nil,{{1260}}},nil,nil,{20},nil,nil,nil,44,nil,nil,nil,nil,nil,8,nil,nil,{{72,350}}},
# [20] = {"Blackrock Menace",{{382}},{{382}},18,21,1101,nil,{"Bring 10 Battleworn Axes to Marshal Marris in Lakeshire."},nil,{nil,nil,{{3014}}},nil,nil,nil,nil,nil,nil,44,nil,nil,nil,nil,19,8,nil,nil,{{72,250}}},

import csv
import os


listOfData = [
    {"expansion": "Classic", "DBC_DIR": "Classic", "questDBFilePath": f"..\\Database\\Classic\\classicQuestDB.lua"},
    {"expansion": "TBC", "DBC_DIR": "TbcClassic", "questDBFilePath": f"..\\Database\\TBC\\tbcQuestDB.lua"},
    {"expansion": "Wotlk", "DBC_DIR": "WotlkClassic", "questDBFilePath": f"..\\Database\\Wotlk\\WotlkQuestDB.lua"}
]

for data in listOfData:
    DBC_DIR = data["DBC_DIR"]
    questDBFilePath = data["questDBFilePath"]
    expansion = data["expansion"]


    locales = ['enGB', 'deDE', 'enUS', 'esES', 'esMX', 'frFR', 'itIT', 'koKR', 'ptBR', 'ptPT', 'ruRU', 'zhCN', 'zhTW']
    faction_lookup = {}
    factions = set()

    for locale in locales:
        with open(f'DBCDumper\out\\{DBC_DIR}\Faction\Faction_{locale}.csv', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            faction_lookup[locale] = {}
            for row in reader:
                faction_id = int(row['ID'])
                parent_faction_id = int(row['ParentFactionID'])
                # Set the UNKNOWN category to -1
                if parent_faction_id == 0:
                    parent_faction_id = -1
                # If a faction does not have a reputation_index it is not really of interest
                # Play around with this if you want to include factions that are potentially not used
                reputation_index = int(row['ReputationIndex'])
                if reputation_index == -1:
                    continue
                # Expansion = int(row['Expansion'])
                # if Expansion != 0:
                #     continue
                # All the factions that don't have Description_lang are not really of interest
                description = row['Description_lang']
                if description == '':
                    continue
                faction_name = row['Name_lang']
                if parent_faction_id in faction_lookup[locale]:
                    faction_lookup[locale][parent_faction_id][faction_id] = faction_name
                else:
                    faction_lookup[locale][parent_faction_id] = {faction_id: faction_name}
                factions.add(faction_id)

    used_factions = set()
    for faction_id in factions:
        for locale in locales:
            with open(questDBFilePath, encoding='utf-8') as lua_file:
                lua_code = lua_file.read()
                if "{"+str(faction_id) in lua_code:
                    used_factions.add(faction_id)
                    break

    # Create all directories for path "Localization\lookups\\{expansion}\lookupFactions"
    os.makedirs(f"DUMP_OUTPUT\Localization\lookups\\{expansion}\lookupFactions", exist_ok=True)

    for locale in locales:
        with open(f'DUMP_OUTPUT\Localization\lookups\\{expansion}\lookupFactions\\{locale}.lua', 'w', encoding='utf-8') as output_file:
            output_file.write("""if GetLocale() ~= "%s" then
    return
end

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

l10n.factionGroupLookup = {
""" % (locale))
            # sort by parent faction id, but put -1 (no parent) at the beginning
            faction_lookup[locale]=dict(sorted(faction_lookup[locale].items(), key=lambda item: item[0] if item[0] != -1 else -999999))
            for parent_faction_id, faction_dict in faction_lookup[locale].items():
                with open(f'DBCDumper\out\\{DBC_DIR}\Faction\Faction_{locale}.csv', newline='', encoding='utf-8') as csvfile:
                    reader = csv.DictReader(csvfile)
                    parent_faction_name = 'UNKNOWN'
                    for row in reader:
                        if int(row['ID']) == parent_faction_id:
                            parent_faction_name = row['Name_lang']
                            break
                output_file.write(f'    -- {parent_faction_name}\n')
                output_file.write(f'    [{parent_faction_id}] = {{\n')
                for faction_id, faction_name in faction_dict.items():
                    if faction_id in used_factions:
                        output_file.write(f'        [{faction_id}] = "{faction_name}",\n')
                output_file.write('    },\n')
            output_file.write('}\n')
        # output_file.write('}\n')


    with open (f'DUMP_OUTPUT\Localization\lookups\\{expansion}\lookupFactions\\lookupFactions.xml', 'w', encoding='utf-8') as output_file:
        output_file.write("""<Ui xsi:schemaLocation="http://www.blizzard.com/wow/ui/ ..\\FrameXML\\UI.xsd">
    <Script file="deDE.lua"/>
    <Script file="esES.lua"/>
    <Script file="esMX.lua"/>
    <Script file="frFr.lua"/>
    <Script file="koKR.lua"/>
    <Script file="ptBR.lua"/>
    <Script file="ruRU.lua"/>
    <Script file="zhCN.lua"/>
    <Script file="zhTW.lua"/>
</Ui>
""")