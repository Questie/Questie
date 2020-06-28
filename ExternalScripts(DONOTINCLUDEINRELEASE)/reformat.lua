QuestieLocale = {};
QuestieLocale.locale = {};

languages = {'deDE', 'enUS', 'esES', 'esMX', 'frFR', 'koKR', 'ptBR', 'ruRU', 'zhCN', 'zhTW'}

for _, lang in pairs(languages) do
    dofile('../Locale/'..lang..'/config.lua')
end

function dump(tableToDump, fd, indent)
    for k, v in pairs(tableToDump) do
        local formatting = string.rep('    ', indent)
        if type(v) == "table" then
            fd:write(formatting .. "['" .. k .. "'] = {\n")
            dump(v, fd, indent+1)
            fd:write(formatting .. '},\n')
        elseif type(v) == "boolean" then
            fd:write(formatting .. "['" .. k .. "'] = " .. tostring(v) .. ',\n')
        else
            fd:write(formatting .. "['" .. k .. "'] = \"" .. string.gsub(string.gsub(v, '\n', '\\n'), '"', '\\"') .. "\",\n")
        end
    end
end

function dumpTable(fileName, tableName, tableToDump, indent)
    if indent == nil then indent = 1 end
    local file = io.open(fileName, 'w')
    file:write(tableName .. ' = {\n')
    dump(tableToDump, file, indent)
    file:write('},\n')
    file:close()
end

temp = {}

for lang, values in pairs(QuestieLocale.locale) do
    for k, v in pairs(values) do
        if temp[k] == nil then temp[k] = {} end
        temp[k][lang] = v
    end
end

dumpTable('Step.lua', 'local Locales', temp)

temp2 = {}

for k, values in pairs(temp) do
    if values['enUS'] == nil then
        print('Missing English key: '.. k)
    else
        key = values['enUS']
        temp2[key] = {}
        for lang, value in pairs(values) do
            if lang == 'enUS' then
                temp2[key][lang] = true
            elseif value == key then
                temp2[key][lang] = false
            else
                temp2[key][lang] = value
            end
        end
        for _, lang in pairs(languages) do
            if temp2[key][lang] == nil then temp2[key][lang] = false end
        end
    end
end

dumpTable('Locales.lua', 'local Locales', temp2)
