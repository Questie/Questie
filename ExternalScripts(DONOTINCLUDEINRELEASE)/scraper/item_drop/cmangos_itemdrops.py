import mysql.connector
from collections import defaultdict

db_config = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "",
    "database": "wotlk-db"
}

query = "SELECT entry, item, ChanceOrQuestChance, comments FROM creature_loot_template WHERE ChanceOrQuestChance < 0;"

try:
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    cursor.execute(query)
    rows = cursor.fetchall()

    item_groups = defaultdict(lambda: {'comment': '', 'entries': {}})
    for row in rows:
        item_id = row['item']
        item_groups[item_id]['comment'] = row['comments']
        item_groups[item_id]['entries'][row['entry']] = abs(row['ChanceOrQuestChance'])

    with open("item_drop_data.lua", "w") as f:
        f.write("return {\n")

        sorted_items = sorted(item_groups.keys())

        for item_id in sorted_items:
            data = item_groups[item_id]
            f.write(f"    [{item_id}] = {{ -- {data['comment']}\n")

            sorted_entries = sorted(data['entries'].keys())
            for entry_id in sorted_entries:
                chance = data['entries'][entry_id]
                f.write(f"        [{entry_id}] = {chance},\n")

            f.write("    },\n")

        f.write("}\n")

    print(f"Success! Scraped {len(item_groups)} items into item_drop_data.lua")

except mysql.connector.Error as err:
    print(f"Error: {err}")
finally:
    if 'conn' in locals() and conn.is_connected():
        cursor.close()
        conn.close()