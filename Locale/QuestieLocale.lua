QuestieLocale = {}
QuestieLocale.locale = {}
QuestieLocale.questCategoryKeys = {}
LangItemLookup = {}
LangNameLookup = {}
LangObjectNameLookup = {}
LangObjectLookup = {}
LangQuestLookup = {}
LangContinentLookup = {}
LangZoneLookup = {}
LangZoneCategoryLookup = {}
LangQuestCategory = {}

-------------------------
--Import modules
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local locale = 'enUS'

local _GetUIStringNillable, _GetUIString

function QuestieLocale:PostBoot()
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
    -- Load continent, zone locales, and quest catagories
    LangContinentLookup = LangContinentLookup[locale] or LangContinentLookup["enUS"] or {}
    LangZoneLookup = LangZoneLookup[locale] or LangZoneLookup["enUS"] or {}
    LangZoneCategoryLookup = LangZoneCategoryLookup[locale] or LangZoneCategoryLookup["enUS"] or {}
    LangQuestCategory = LangQuestCategory[locale] or LangQuestCategory["enUS"] or {}
end

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

function QuestieLocale:FallbackLocale(lang)
    if not lang then
        return 'enUS'
    end

    if QuestieLocale.locale[lang] then
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

function QuestieLocale:SetUILocale(lang)
    if lang then
        locale = QuestieLocale:FallbackLocale(lang)
    else
        locale = QuestieLocale:FallbackLocale(GetLocale())
    end
end

function QuestieLocale:GetUILocale()
    return locale
end

function QuestieLocale:GetLocaleTable()
    if QuestieLocale.locale[locale] then
        return QuestieLocale.locale[locale]
    else
        return QuestieLocale.locale['enUS']
    end
end

function QuestieLocale:GetUIString(key, ...)
    local result, val = pcall(_GetUIString, key, ...)
    if result then
        return val
    else
        return tostring(key) .. ' ERROR: '.. val
    end
end

_GetUIString = function(key, ...)
    if key then
        -- convert all args to string
        local arg = {...}
        for i, v in ipairs(arg) do
            arg[i] = tostring(v)
        end

        local loc = QuestieLocale.locale

        if loc[locale] then
            if loc[locale][key] then
                return string.format(loc[locale][key], unpack(arg))
            else
                if loc['enUS'] and loc['enUS'][key] then
                    return string.format(loc['enUS'][key], unpack(arg))
                else
                    return tostring(key) ..' ERROR: '..tostring(locale)..' key missing!'
                end
            end
        else
            if loc['enUS'] and loc['enUS'][key] then
                return string.format(loc['enUS'][key], unpack(arg))
            else
                return tostring(key) ..' ERROR: enUS key missing!'
            end
        end
    end
end

-- bad copypasta: maybe we can implement this using args somehow but varargs makes that tough
function QuestieLocale:GetUIStringNillable(key, ...)
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

        local loc = QuestieLocale.locale

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

QuestieLocale.questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    DUNGEONS = 3,
    BATTLEGROUNDS = 4,
    CLASS = 5,
    PROFESSIONS = 6,
    EVENTS = 7,
}