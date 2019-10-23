QuestieOptions.tabs.nameplate = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.nameplate:Initialize()
    return {
        name = function() return QuestieLocale:GetUIString('NAMEPLATE_TAB'); end,
        type = "group",
        order = 14,
        args = {
            nameplate_options = {
                type = "header",
                order = 1,
                name = function() return QuestieLocale:GetUIString('NAMEPLATE_HEAD'); end,
            },
            nameplateEnabled = {
                type = "toggle",
                order = 3,
                name = function() return QuestieLocale:GetUIString('NAMEPLATE_TOGGLE'); end,
                desc = function() return QuestieLocale:GetUIString('NAMEPLATE_TOGGLE_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)

                    -- on false, hide current nameplates
                    if not value then
                        QuestieNameplate:HideCurrentFrames();
                    end
                end,
            },
            Spacer_A = QuestieOptionsUtils:Spacer(4),
            nameplateX = {
                type = "range",
                order = 5,
                name = function() return QuestieLocale:GetUIString('NAMEPLATE_X'); end,
                desc = function() return QuestieLocale:GetUIString('NAMEPLATE_X_DESC', optionsDefaults.global.nameplateX ); end,
                width = "normal",
                min = -200,
                max = 200,
                step = 1,
                disabled = function() return not Questie.db.global.nameplateEnabled; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieNameplate:RedrawIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            nameplateY = {
                type = "range",
                order = 5,
                name = function() return QuestieLocale:GetUIString('NAMEPLATE_Y'); end,
                desc = function() return QuestieLocale:GetUIString('NAMEPLATE_Y_DESC', optionsDefaults.global.nameplateY); end,
                width = "normal",
                min = -200,
                max = 200,
                step = 1,
                disabled = function() return not Questie.db.global.nameplateEnabled; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieNameplate:RedrawIcons()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            nameplateScale = {
                type = "range",
                order = 6,
                name = function() return QuestieLocale:GetUIString('NAMEPLATE_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('NAMEPLATE_SCALE_DESC', optionsDefaults.global.nameplateScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                disabled = function() return not Questie.db.global.nameplateEnabled; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieNameplate:RedrawIcons()
                end,

            },
            Spacer_B = QuestieOptionsUtils:Spacer(7),
            nameplateReset = {
                type = "execute",
                order = 8,
                name = function() return QuestieLocale:GetUIString('NAMEPLATE_RESET_BTN'); end,
                desc = function() return QuestieLocale:GetUIString('NAMEPLATE_RESET_BTN_DESC'); end,
                disabled = function() return not Questie.db.global.nameplateEnabled; end,
                func = function (info, value)
                    Questie.db.global.nameplateX = optionsDefaults.global.nameplateX;
                    Questie.db.global.nameplateY = optionsDefaults.global.nameplateY;
                    Questie.db.global.nameplateScale = optionsDefaults.global.nameplateScale;
                    QuestieNameplate:RedrawIcons();
                end,
            },
            Spacer_C = QuestieOptionsUtils:Spacer(9),
            targetframe_header = {
                type = "header",
                order = 20,
                name = function() return QuestieLocale:GetUIString('TARGET_HEAD'); end,
            },
            Spacer_D = QuestieOptionsUtils:Spacer(21),
            nameplateTargetFrameEnabled = {
                type = "toggle",
                order = 22,
                name = function() return QuestieLocale:GetUIString('TARGET_TOGGLE'); end,
                desc = function() return QuestieLocale:GetUIString('TARGET_TOGGLE_DESC'); end,
                width = "full",
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)

                    -- on false, hide current nameplates
                    if not value then
                        QuestieNameplate:HideCurrentTargetFrame();
                    else
                        QuestieNameplate:DrawTargetFrame();
                    end
                end,
            },
            Spacer_E = QuestieOptionsUtils:Spacer(23),
            nameplateTargetFrameX  = {
                type = "range",
                order = 24,
                name = function() return QuestieLocale:GetUIString('TARGET_X'); end,
                desc = function() return QuestieLocale:GetUIString('TARGET_X_DESC', optionsDefaults.global.nameplateTargetFrameX); end,
                width = "normal",
                min = -200,
                max = 200,
                step = 1,
                disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieNameplate:RedrawFrameIcon()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            nameplateTargetFrameY  = {
                type = "range",
                order = 24,
                name = function() return QuestieLocale:GetUIString('TARGET_Y'); end,
                desc = function() return QuestieLocale:GetUIString('TARGET_Y_DESC', optionsDefaults.global.nameplateTargetFrameY); end,
                width = "normal",
                min = -200,
                max = 200,
                step = 1,
                disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieNameplate:RedrawFrameIcon()
                    QuestieOptions:SetGlobalOptionValue(info, value)
                end,
            },
            nameplateTargetFrameScale  = {
                type = "range",
                order = 25,
                name = function() return QuestieLocale:GetUIString('TARGET_SCALE'); end,
                desc = function() return QuestieLocale:GetUIString('TARGET_SCALE_DESC', optionsDefaults.global.nameplateTargetFrameScale); end,
                width = "double",
                min = 0.01,
                max = 4,
                step = 0.01,
                disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled; end,
                get = function(info) return QuestieOptions:GetGlobalOptionValue(info); end,
                set = function (info, value)
                    QuestieOptions:SetGlobalOptionValue(info, value)
                    QuestieNameplate:RedrawFrameIcon()
                end,

            },
            Spacer_F = QuestieOptionsUtils:Spacer(26),
            targetFrameReset = {
                type = "execute",
                order = 27,
                name = function() return QuestieLocale:GetUIString('TARGET_RESET_BTN'); end,
                desc = function() return QuestieLocale:GetUIString('TARGET_RESET_BTN_DESC'); end,
                disabled = function() return not Questie.db.global.nameplateTargetFrameEnabled; end,
                func = function (info, value)
                    Questie.db.global.nameplateTargetFrameX = optionsDefaults.global.nameplateTargetFrameX;
                    Questie.db.global.nameplateTargetFrameY = optionsDefaults.global.nameplateTargetFrameY;
                    Questie.db.global.nameplateTargetFrameScale = optionsDefaults.global.nameplateTargetFrameScale;
                    QuestieNameplate:RedrawFrameIcon();
                end,
            },
        },
    }
end
