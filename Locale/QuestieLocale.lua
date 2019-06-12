QuestieLocale = {...};
QuestieLocale.locale = {...};

local locale = 'en';

function QuestieLocale:SetLocale(lang)
    if lang then
        locale = lang;
    else
        locale = 'en';
    end
end

function QuestieLocale:GetLocale()
    return locale;
end

function QuestieLocale:GetLocaleTable()
    if QuestieLocale.locale[locale] then
        return QuestieLocale.locale[locale];
    else
        return QuestieLocale.locale['en'];
    end
end

function QuestieLocale:GetString(key)
    if key then
        if QuestieLocale.locale[locale] then
            if QuestieLocale.locale[locale][key] then
                return QuestieLocale.locale[locale][key];
            else
                return 'QUESTIE LOCALE ERROR';
        else
            if QuestieLocale.locale['en'][key] then
                return QuestieLocale.locale['en'][key];
            else
                return 'QUESTIE LOCALE ERROR';
            end
        end
    end
end

