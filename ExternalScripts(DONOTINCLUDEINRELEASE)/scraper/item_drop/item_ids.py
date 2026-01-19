# https://www.wowhead.com/classic/items?filter=82;2;11507
# Before release the PTR link is required: https://www.wowhead.com/classic-pt/items?filter=82;2;11507
# On the PTR the substr starts at 41
# r = []
# Array.from(document.getElementsByClassName("listview-cleartext")).forEach(l => r.push(parseInt(l.href.substr(37, 6)))); r; // run for each page
# [...new Set(r)].sort();
ITEM_IDS = [
    159,182,723,725,729,730,731,732,737,738,739,740,742,743,750,752
]
