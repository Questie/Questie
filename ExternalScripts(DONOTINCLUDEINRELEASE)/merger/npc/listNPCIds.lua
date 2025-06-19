local mangos = require('cataNpcDB')

local npcIds = {}
for npcId, data in pairs(mangos) do
    table.insert(npcIds, npcId)
end

local file = io.open("npc_ids_complete.py", "w")
print("writing to npc_ids_complete.py")
file:write("NPC_IDS_COMPLETE = [\n")
for i, npcId in ipairs(npcIds) do
    file:write("  " .. npcId)
    if i < #npcIds then
        file:write(",\n")
    end
end
file:write("\n]\n")
file:close()
print("done")
