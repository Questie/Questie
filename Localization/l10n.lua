---@class l10n
---@field continentLookup table
---@field zoneLookup table
---@field zoneCategoryLookup table
---@field questCategoryLookup table
local l10n = QuestieLoader:CreateModule("l10n")
local _l10n = {}
l10n.translations = {}

l10n.itemLookup = {}
l10n.npcNameLookup = {}
l10n.objectNameLookup = {}
l10n.objectLookup = {}
l10n.questLookup = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local locale = 'enUS'
local supportedLocals = {
    ['enUS'] = true,
    ['esES'] = true,
    ['esMX'] = true,
    ['ptBR'] = true,
    ['frFR'] = true,
    ['deDE'] = true,
    ['ruRU'] = true,
    ['zhCN'] = true,
    ['zhTW'] = true,
    ['koKR'] = true,
}


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

function l10n:PostBoot()
    -- Create {['name'] = {ID, },} table for lookup of possible object IDs by name
    for id in pairs(QuestieDB.ObjectPointers) do
        local name = QuestieDB.QueryObjectSingle(id, "name")
        if name then -- We (meaning me, BreakBB) introduced Fake IDs for objects to show additional locations, so we need to check this
            local entry = l10n.objectNameLookup[name]
            if not entry then
                l10n.objectNameLookup[name] = { id }
            else
                entry[#entry+1] = id
            end
        end
    end
end

function _l10n:translate(key, ...)
    local args = {...}

    for i, v in ipairs(args) do
        args[i] = tostring(v);
    end

    local translationEntry = l10n.translations[key]
    if not translationEntry then
        Questie:Debug(Questie.DEBUG_ELEVATED, "ERROR: Translations for '" .. tostring(key) .. "' is missing completely!")
        return string.format(key, unpack(args))
    end

    local translationValue = translationEntry[locale]
    if (not translationValue) then
        Questie:Debug(Questie.DEBUG_ELEVATED, "ERROR: Translations for '" .. tostring(key) .. "' is missing the entry for language" , locale, "!")
        return string.format(key, unpack(args))
    end

    if translationValue == true then
        -- Fallback to enUS which is the key
        return string.format(key, unpack(args))
    end

    return string.format(translationValue, unpack(args))
end

setmetatable(l10n, { __call = function(_, ...) return _l10n:translate(...) end})

function _l10n:GetFallbackLocale(lang)
    if (not lang) then
        return 'enUS'
    end

    if supportedLocals[lang] then
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
        locale = _l10n:GetFallbackLocale(lang)
    else
        locale = _l10n:GetFallbackLocale(GetLocale())
    end
end

function l10n:GetUILocale()
    return locale
end
