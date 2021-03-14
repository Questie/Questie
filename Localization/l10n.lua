l10n = {}
l10n.locale = {}
l10n.translations = {}

l10n.itemLookup = {}
l10n.npcNameLookup = {}
l10n.objectNameLookup = {}
l10n.objectLookup = {}
l10n.questLookup = {}
l10n.continentLookup = {}
l10n.zoneLookup = {}
l10n.zoneCategoryLookup = {}
l10n.questCategoryLookup = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local locale = 'enUS'

l10n.questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    DUNGEONS = 3,
    BATTLEGROUNDS = 4,
    CLASS = 5,
    PROFESSIONS = 6,
    EVENTS = 7,
}

local _GetUIStringNillable

function l10n:PostBoot()
    -- Create {['name'] = {ID, },} table for lookup of possible object IDs by name
    for id in pairs(QuestieDB.ObjectPointers) do
        local name = QuestieDB.QueryObjectSingle(id, "name")
        if name then -- We (meaning me, BreakBB) introduced Fake IDs for objects to show additional locations, so we need to check this
            if not l10n.objectNameLookup[name] then
                l10n.objectNameLookup[name] = {}
            end
            table.insert(l10n.objectNameLookup[name], id)
        end
    end

    l10n.continentLookup = l10n.continentLookup[locale] or l10n.continentLookup["enUS"] or {}
    l10n.zoneLookup = l10n.zoneLookup[locale] or l10n.zoneLookup["enUS"] or {}
    l10n.zoneCategoryLookup = l10n.zoneCategoryLookup[locale] or l10n.zoneCategoryLookup["enUS"] or {}
    l10n.questCategoryLookup = l10n.questCategoryLookup[locale] or l10n.questCategoryLookup["enUS"] or {}
end

function l10n:Initialize()
    -- Load item locales
    for id, name in pairs(l10n.itemLookup[locale] or {}) do
        if QuestieDB.itemData[id] and name then
            QuestieDB.itemData[id][QuestieDB.itemKeys.name] = name
        end
    end

    -- data is {<questName>, {<questDescription>,...}, {<questObjective>,...}}
    for id, data in pairs(l10n.questLookup[locale] or {}) do
        if QuestieDB.questData[id] then
            if data[1] then
                QuestieDB.questData[id][QuestieDB.questKeys.name] = data[1]
            end
            -- TODO add details text to questDB.lua (data[2])
            if data[3] then
                -- needs to be saved as a table for tooltips to have lines
                if type(data[3]) == "string" then
                    QuestieDB.questData[id][QuestieDB.questKeys.objectivesText] = {data[3]}
                else
                    QuestieDB.questData[id][QuestieDB.questKeys.objectivesText] = data[3]
                end
            end
        end
    end
    -- Load NPC locales
    for id, data in pairs(l10n.npcNameLookup[locale] or {}) do
        if QuestieDB.npcData[id] and data then
            if type(data) == "string" then
                QuestieDB.npcData[id][QuestieDB.npcKeys.name] = data
            else
                QuestieDB.npcData[id][QuestieDB.npcKeys.name] = data[1]
                QuestieDB.npcData[id][QuestieDB.npcKeys.subName] = data[2]
            end
        end
    end
    -- Load object locales
    for id, name in pairs(l10n.objectLookup[locale] or {}) do
        if QuestieDB.objectData[id] and name then
            QuestieDB.objectData[id][QuestieDB.objectKeys.name] = name
        end
    end
end

function l10n:FallbackLocale(lang)
    if not lang then
        return 'enUS'
    end

    if l10n.locale[lang] then
        return lang
    elseif lang == 'enGB' then
        return 'enUS'
    elseif lang == 'enCN' then
        return 'zhCN'
    elseif lang == 'enTW' then
        return 'zhTW'
    elseif lang == 'esMX' then
        return 'esES'
    elseif lang == 'ptPT' then
        return 'ptBR'
    else
        return 'enUS'
    end
end

function l10n:SetUILocale(lang)
    if lang then
        locale = l10n:FallbackLocale(lang)
    else
        locale = l10n:FallbackLocale(GetLocale())
    end
end

function l10n:GetUILocale()
    return locale
end

function l10n:translate(key, ...)
    local args = {...}

    for i, v in ipairs(args) do
        args[i] = tostring(v);
    end

    local translationEntry = l10n.translations[key]
    if (not translationEntry) then
        return "ERROR: Translations for '" .. tostring(key) .. "' is missing completely!"
    end

    local translationValue = translationEntry[locale]
    if (not translationValue) then
        return "ERROR: Translations for '" .. tostring(key) .. "' is missing the entry for language " .. locale .. "!"
    end

    if translationValue == true or translationValue == false then
        -- Fallback to enUS which is the key
        return string.format(key, unpack(args))
    end

    return string.format(translationValue, unpack(args))
end

setmetatable(l10n, { __call = function(_, ...) return l10n:translate(...) end})

function l10n:GetUIStringNillable(key, ...)
    local result, val = pcall(_GetUIStringNillable, key, ...)
    if result then
        return val
    else
        return nil
    end
end

_GetUIStringNillable = function(key, ...)
    if key then
        -- convert all args to string
        local arg = {...}
        for i, v in ipairs(arg) do
            arg[i] = tostring(v)
        end

        local loc = l10n.locale

        if loc[locale] then
            if loc[locale][key] then
                return string.format(loc[locale][key], unpack(arg))
            else
                if loc['enUS'] and loc['enUS'][key] then
                    return string.format(loc['enUS'][key], unpack(arg))
                else
                    return nil
                end
            end
        else
            if loc['enUS'] and loc['enUS'][key] then
                return string.format(loc['enUS'][key], unpack(arg))
            else
                return nil
            end
        end
    end
end