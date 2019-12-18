QuestieLocale = {};
QuestieLocale.locale = {};
LangItemLookup = {}
LangNameLookup= {};
LangObjectNameLookup = {};
LangObjectLookup = {};
LangQuestLookup = {};
LangContinentLookup = {}
LangZoneLookup = {}

-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local locale = 'enUS';

-- Initialize database tables with localization
function QuestieLocale:Initialize()
    -- Load item locales
    for id, name in pairs(LangItemLookup[locale] or {}) do
        if QuestieDB.itemData[id] and name then
            QuestieDB.itemData[id][QuestieDB.itemKeys.name] = name
        end
    end
    -- Load quest locales
    -- data is {<questName>, {<questDescription>,...}, {<questObjective>,...}}
    for id, data in pairs(LangQuestLookup[locale] or {}) do
        if QuestieDB.questData[id] then
            if data[1] then
                QuestieDB.questData[id][QuestieDB.questKeys.name] = data[1]
            end
            -- TODO add details text to questDB.lua (data[2])
            if data[3] then
                 -- needs to be saved as a table for tooltips to have lines
                 -- TODO: split string into ~80 char lines
                QuestieDB.questData[id][QuestieDB.questKeys.objectivesText] = data[3]
            end
        end
    end
    -- Load NPC locales
    for id, name in pairs(LangNameLookup[locale] or {}) do
        if QuestieDB.npcData[id] and name then
            QuestieDB.npcData[id][QuestieDB.npcKeys.name] = name
        end
    end
    -- Load object locales
    for id, name in pairs(LangObjectLookup[locale] or {}) do
        if QuestieDB.objectData[id] and name then
            QuestieDB.objectData[id][QuestieDB.objectKeys.name] = name
        end
    end
    -- Create {['name'] = {ID, },} table for lookup of possible object IDs by name
    for id, data in pairs(QuestieDB.objectData) do
        local name = data[QuestieDB.objectKeys.name]
        if name then -- We (meaning me, BreakBB) introduced Fake IDs for objects to show additional locations, so we need to check this
            if not LangObjectNameLookup[name] then
                LangObjectNameLookup[name] = {}
            end
            table.insert(LangObjectNameLookup[name], id)
        end
    end
    -- Load continent and zone locales
    LangContinentLookup = LangContinentLookup[locale] or LangContinentLookup["enUS"] or {}
    LangZoneLookup = LangZoneLookup[locale] or LangZoneLookup["enUS"] or {}
end

function QuestieLocale:FallbackLocale(lang)

    if not lang then
        return 'enUS';
    end

    if QuestieLocale.locale[lang] then
        return lang;
    elseif lang == 'enGB' then
        return 'enUS';
    elseif lang == 'enCN' then
        return 'zhCN';
    elseif lang == 'enTW' then
        return 'zhTW';
    elseif lang == 'esMX' then
        return 'esES';
    elseif lang == 'ptPT' then
        return 'ptBR';
    else
        return 'enUS';
    end
end

function QuestieLocale:SetUILocale(lang)
    if lang then
        locale = QuestieLocale:FallbackLocale(lang);
    else
        locale = QuestieLocale:FallbackLocale(GetLocale());
    end
end

function QuestieLocale:GetUILocale()
    return locale;
end

function QuestieLocale:GetLocaleTable()
    if QuestieLocale.locale[locale] then
        return QuestieLocale.locale[locale];
    else
        return QuestieLocale.locale['enUS'];
    end
end

function QuestieLocale:GetUIString(key, ...)
    local result, val = pcall(QuestieLocale._GetUIString, QuestieLocale, key, ...)
    if result then
        return val
    else
        return tostring(key) .. ' ERROR: '.. val;
    end
end

function QuestieLocale:_GetUIString(key, ...)
    if key then
        -- convert all args to string
        local arg = {...}
        for i, v in ipairs(arg) do
            arg[i] = tostring(v);
        end

        if QuestieLocale.locale[locale] then
            if QuestieLocale.locale[locale][key] then
                return string.format(QuestieLocale.locale[locale][key], unpack(arg))
            else
                if QuestieLocale.locale['enUS'] and QuestieLocale.locale['enUS'][key] then
                    return string.format(QuestieLocale.locale['enUS'][key], unpack(arg));
                else
                    return tostring(key) ..' ERROR: '..tostring(locale)..' key missing!';
                end
            end
        else
            if QuestieLocale.locale['enUS'] and QuestieLocale.locale['enUS'][key] then
                return string.format(QuestieLocale.locale['enUS'][key], unpack(arg));
            else
                return tostring(key) ..' ERROR: enUS key missing!';
            end
        end
    end
end
