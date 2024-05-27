local mangos = require('cataObjectDB')

local objectIds = {}
for objectId, data in pairs(mangos) do
    table.insert(objectIds, objectId)
end

local file = io.open("object_ids_complete.py", "w")
print("writing to object_ids_complete.py")
file:write("OBJECT_IDS_COMPLETE = [\n")
for i, objectId in ipairs(objectIds) do
    file:write("  " .. objectId)
    if i < #objectIds then
        file:write(",\n")
    end
end
file:write("\n]\n")
file:close()
print("done")
