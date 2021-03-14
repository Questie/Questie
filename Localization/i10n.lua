i10n = {}
i10n.locale = {}
i10n.translations = {}

LangItemLookup = {}
LangNameLookup = {}
LangObjectNameLookup = {}
LangObjectLookup = {}
LangQuestLookup = {}
LangContinentLookup = {}
LangZoneLookup = {}
LangZoneCategoryLookup = {}
LangQuestCategory = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local locale = 'enUS'

i10n.questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    DUNGEONS = 3,
    BATTLEGROUNDS = 4,
    CLASS = 5,
    PROFESSIONS = 6,
    EVENTS = 7,
}

local _GetUIStringNillable

function i10n:PostBoot()
    -- Create {['name'] = {ID, },} table for lookup of possible object IDs by name
    for id in pairs(QuestieDB.ObjectPointers) do
        local name = QuestieDB.QueryObjectSingle(id, "name")
        if name then -- We (meaning me, BreakBB) introduced Fake IDs for objects to show additional locations, so we need to check this
            if not LangObjectNameLookup[name] then
                LangObjectNameLookup[name] = {}
            end
            table.insert(LangObjectNameLookup[name], id)
        end
    end

    LangContinentLookup = LangContinentLookup[locale] or LangContinentLookup["enUS"] or {}
    LangZoneLookup = LangZoneLookup[locale] or LangZoneLookup["enUS"] or {}
    LangZoneCategoryLookup = LangZoneCategoryLookup[locale] or LangZoneCategoryLookup["enUS"] or {}
    LangQuestCategory = LangQuestCategory[locale] or LangQuestCategory["enUS"] or {}
end

function i10n:Initialize()
    -- Load item locales
    for id, name in pairs(LangItemLookup[locale] or {}) do
        if QuestieDB.itemData[id] and name then
            QuestieDB.itemData[id][QuestieDB.itemKeys.name] = name
        end
    end

    -- data is {<questName>, {<questDescription>,...}, {<questObjective>,...}}
    for id, data in pairs(LangQuestLookup[locale] or {}) do
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
    for id, data in pairs(LangNameLookup[locale] or {}) do
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
    for id, name in pairs(LangObjectLookup[locale] or {}) do
        if QuestieDB.objectData[id] and name then
            QuestieDB.objectData[id][QuestieDB.objectKeys.name] = name
        end
    end
end

function i10n:FallbackLocale(lang)
    if not lang then
        return 'enUS'
    end

    if i10n.locale[lang] then
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

function i10n:SetUILocale(lang)
    if lang then
        locale = i10n:FallbackLocale(lang)
    else
        locale = i10n:FallbackLocale(GetLocale())
    end
end

function i10n:GetUILocale()
    return locale
end

function i10n:translate(key, ...)
    local args = {...}

    for i, v in ipairs(args) do
        args[i] = tostring(v);
    end

    local translationEntry = i10n.translations[key]
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

setmetatable(i10n, {__call = function(_, ...) return i10n:translate(...) end})

function i10n:GetUIStringNillable(key, ...)
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

        local loc = i10n.locale

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