QuestieLocale = {};
QuestieLocale.locale = {};
LangNameLookup= {};
LangQuestLookup = {};
LangObjectLookup = {};

local locale = 'enUS';

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
        local arg = {...};        
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
