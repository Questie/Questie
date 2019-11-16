-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker");
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords");
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");

QuestieOptions.tabs.advanced = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.advanced:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('ADV_TAB'); end,
        type = "group",
        order = 15,
        args = {
            map_options = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('ADV_SET'); end,
            },
            enableIconLimit = {
                type = "toggle",
                order = 2.1,
                name = function() return QuestieLocale:GetUIString('ENABLE_ICON_LIMIT'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_ICON_LIMIT_DESC'); end,
                width = "full",
                get = function (info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, QuestieLocale:GetUIString('DEBUG_ICON_LIMIT', value))
                end,
            },
            iconLimit = {
                type = "range",
                order = 2.2,
                name = function() return QuestieLocale:GetUIString('ICON_LIMIT'); end,
                desc = function() return QuestieLocale:GetUIString('ICON_LIMIT_DESC', optionsDefaults.global.iconLimit); end,
                width = "double",
                min = 10,
                max = 500,
                step = 10,
                disabled = function() return (not Questie.db.global.enableIconLimit); end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieOptionsUtils:Delay(0.5, QuestieQuest.SmoothReset, QuestieLocale:GetUIString('DEBUG_ICON_LIMIT', value))
                end,
            },
            seperatingHeader2 = {
                type = "header",
                order = 2.3,
                name = QuestieLocale:GetUIString('DEV_OPTIONS'),
            },
            debugEnabled = {
                type = "toggle",
                order = 4,
                name = function() return QuestieLocale:GetUIString('ENABLE_DEBUG'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_DEBUG_DESC'); end,
                width = "full",
                get = function () return Questie.db.global.debugEnabled; end,
                set = function (info, value)
                    Questie.db.global.debugEnabled = value
                    QuestieConfigCharacter = {}
                end,
            },
            debugEnabledPrint = {
                type = "toggle",
                order = 5,
                disabled = function() return not Questie.db.global.debugEnabled; end,
                name = function() return QuestieLocale:GetUIString('ENABLE_DEBUG').."-PRINT" end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_DEBUG_DESC').."-PRINT" end,
                width = "full",
                get = function () return Questie.db.global.debugEnabledPrint; end,
                set = function (info, value)
                    Questie.db.global.debugEnabledPrint = value
                end,
            },
            debugLevel = {
                type = "multiselect",
                values = {
                    [0] = "DEBUG_CRITICAL",
                    [1] = "DEBUG_ELEVATED",
                    [2] = "DEBUG_INFO",
                    [3] = "DEBUG_DEVELOP",
                    [4] = "DEBUG_SPAM",
                },
                order = 6,
                name = function() return QuestieLocale:GetUIString('DEBUG_LEVEL'); end,
                width = "normal",
                disabled = function() return not Questie.db.global.debugEnabled; end,
                get = function(state, key)
                    --Questie:Debug(DEBUG_SPAM, "Debug Key:", key, math.pow(2, key), state.option.values[key])
                    --Questie:Debug(DEBUG_SPAM, "Debug Level:", Questie.db.global.debugLevel, bit.band(Questie.db.global.debugLevel, math.pow(2, key)))
                    return bit.band(Questie.db.global.debugLevel, math.pow(2, key)) > 0
                end,
                set = function (info, value)
                    local currentValue = Questie.db.global.debugLevel
                    local flag = math.pow(2, value)
                    --Questie:Debug(DEBUG_SPAM, "Setting Debug:", currentValue, flag, bit.band(currentValue, flag)>0)
                    -- When current debug level is active, remove it
                    if (bit.band(currentValue, flag) > 0) then
                        Questie.db.global.debugLevel = bit.bxor(flag, currentValue)
                    -- When current debug level is inactive, add it
                    else
                        Questie.db.global.debugLevel = bit.bor(flag, currentValue)
                    end
                end,
            },
            showQuestIDs = {
                type = "toggle",
                order = 7,
                name = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_IDS'); end,
                desc = function() return QuestieLocale:GetUIString('ENABLE_TOOLTIPS_QUEST_LEVEL_IDS'); end,
                width = "full",
                get = function() return Questie.db.global.enableTooltipsQuestID; end,
                set = function (info, value)
                    Questie.db.global.enableTooltipsQuestID = value
                    QuestieTracker:Update()
                end
            },

            Spacer_A = QuestieOptionsUtils:Spacer(10),
            locale_header = {
                type = "header",
                order = 11,
                name = function() return QuestieLocale:GetUIString('LOCALE'); end,
            },
            Spacer_B = QuestieOptionsUtils:Spacer(12),
            locale_dropdown = {
                type = "select",
                order = 13,
                values = {
                    ['auto'] = QuestieLocale:GetUIString('LOCALE_DROP_AUTOMATIC'),
                    ['enUS'] = 'English',
                    ['esES'] = 'Español',
                    ['esMX'] = 'Español (México)',
                    ['ptBR'] = 'Português',
                    ['frFR'] = 'Français',
                    ['deDE'] = 'Deutsch',
                    ['ruRU'] = 'русский',
                    ['zhCN'] = '简体中文',
                    ['zhTW'] = '正體中文',
                    ['koKR'] = '한국어',
                },
                style = 'dropdown',
                name = function() return QuestieLocale:GetUIString('LOCALE_DROP'); end,
                get = function()
                    if not Questie.db.global.questieLocaleDiff then
                        return 'auto'
                    else
                        return QuestieLocale:GetUILocale(); 
                    end
                end,
                set = function(input, lang)
                    if lang == 'auto' then
                        local clientLocale = GetLocale()
                        QuestieLocale:SetUILocale(clientLocale)
                        Questie.db.global.questieLocale = clientLocale
                        Questie.db.global.questieLocaleDiff = false
                        return
                    end
                    QuestieLocale:SetUILocale(lang);
                    Questie.db.global.questieLocale = lang;
                    Questie.db.global.questieLocaleDiff = true;
                end,
            },
            Spacer_C = QuestieOptionsUtils:Spacer(20),
            reset_header = {
                type = "header",
                order = 21,
                name = function() return QuestieLocale:GetUIString('RESET_QUESTIE'); end,
            },
            Spacer_D = QuestieOptionsUtils:Spacer(22),
            reset_text = {
                type = "description",
                order = 23,
                name = function() return QuestieLocale:GetUIString('RESET_QUESTIE_DESC'); end,
                fontSize = "medium",
            },
            questieReset = {
                type = "execute",
                order = 24,
                name = function() return QuestieLocale:GetUIString('RESET_QUESTIE_BTN'); end,
                desc = function() return QuestieLocale:GetUIString('RESET_QUESTIE_BTN_DESC'); end,
                func = function (info, value)
                    -- update all values to default
                    for k,v in pairs(optionsDefaults.global) do
                       Questie.db.global[k] = v
                    end

                    -- only toggle questie if it's off (must be called before resetting the value)
                    if not Questie.db.char.enabled then
                        QuestieQuest:ToggleNotes();
                    end

                    Questie.db.char.enabled = optionsDefaults.char.enabled;
                    Questie.db.char.lowlevel = optionsDefaults.char.lowlevel;

                    Questie.db.profile.minimap.hide = optionsDefaults.profile.minimap.hide;

                    -- update minimap icon to default
                    if not Questie.db.profile.minimap.hide then
                        Questie.minimapConfigIcon:Show("MinimapIcon");
                    else
                        Questie.minimapConfigIcon:Hide("MinimapIcon");
                    end

                    -- update map / minimap coordinates reset
                    if not Questie.db.global.minimapCoordinatesEnabled then
                        QuestieCoords.ResetMinimapText();
                    end

                    if not Questie.db.global.mapCoordinatesEnabled then
                        QuestieCoords.ResetMapText();
                    end

                    -- Reset the show/hide on map
                    if Questie.db.global.mapShowHideEnabled then
                        Questie_Toggle:Show();
                    else
                        Questie_Toggle:Hide();
                    end

                    QuestieOptionsUtils:Delay(0.3, QuestieOptions.AvailableQuestRedraw, "minLevelFilter and maxLevelFilter reset to defaults");

                    QuestieNameplate:RedrawIcons();
                    QuestieMap:RescaleIcons();

                end,
            },
            Spacer_E = QuestieOptionsUtils:Spacer(30),
            github_text = {
                type = "description",
                order = 31,
                name = function() return Questie:Colorize(QuestieLocale:GetUIString('QUESTIE_DEV_MESSAGE'), 'purple'); end,
                fontSize = "medium",
            },
        },
    }
end
