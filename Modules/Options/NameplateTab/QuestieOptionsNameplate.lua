-------------------------
--Import modules.
-------------------------
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions");
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults");
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils");
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate");
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

QuestieOptions.tabs.nameplate = {...}
local optionsDefaults = QuestieOptionsDefaults:Load()


function QuestieOptions.tabs.nameplate:Initialize()
    return {
        name = function() return l10n('Nameplates'); end,
        type = "group",
        order = 5,
        args = {
            nameplate_options_group = {
                type = "group",
                order = 1,
                inline = true,
                name = " ",
                args = {
                    nameplate_options = {
                        type = "header",
                        order = 1.05,
                        name = function() return l10n('Nameplate Icon Options'); end,
                    },
                    nameplateDescSpacer = {
                        type = "description",
                        order = 1.06,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.4,
                        width = 0.4,
                        func = function() end,
                    },
                    nameplateEnabled = {
                        type = "toggle",
                        order = 1.1,
                        name = function() return l10n('Enable Nameplate Quest Objectives'); end,
                        desc = function() return l10n('Enable or disable the quest objective icons over creature nameplates.'); end,
                        descStyle = "inline",
                        width = 2.6,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            -- on false, hide current nameplates
                            if not value then
                                QuestieNameplate:HideCurrentFrames();
                            end
                        end,
                    },
                    Spacer_A = QuestieOptionsUtils:Spacer(1.2),
                    nameplateSpacerX = {
                        type = "description",
                        order = 1.25,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.3,
                        width = 0.3,
                        func = function() end,
                    },
                    nameplateX = {
                        type = "range",
                        order = 1.3,
                        name = function() return l10n('Icon Position X'); end,
                        desc = function() return l10n('Where on the X axis the nameplate icon should be. ( Default: %s )', optionsDefaults.profile.nameplateX ); end,
                        width = 1.2,
                        min = -200,
                        max = 200,
                        step = 1,
                        disabled = function() return not Questie.db.profile.nameplateEnabled; end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieNameplate:RedrawIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    nameplateSpacerY = {
                        type = "description",
                        order = 1.35,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.3,
                        width = 0.3,
                        func = function() end,
                    },
                    nameplateY = {
                        type = "range",
                        order = 1.4,
                        name = function() return l10n('Icon Position Y'); end,
                        desc = function() return l10n('Where on the Y axis the nameplate icon should be. ( Default: %s )', optionsDefaults.profile.nameplateY); end,
                        width = 1.2,
                        min = -200,
                        max = 200,
                        step = 1,
                        disabled = function() return not Questie.db.profile.nameplateEnabled; end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieNameplate:RedrawIcons()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    Spacer_C = QuestieOptionsUtils:Spacer(1.45),
                    nameplateSpacerScale = {
                        type = "description",
                        order = 1.46,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.3,
                        width = 0.3,
                        func = function() end,
                    },
                    nameplateScale = {
                        type = "range",
                        order = 1.5,
                        name = function() return l10n('Nameplate Icon Scale'); end,
                        desc = function() return l10n('Scale the size of the quest icons on creature nameplates. ( Default: %s )', optionsDefaults.profile.nameplateScale); end,
                        width = 2.7,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        disabled = function() return not Questie.db.profile.nameplateEnabled; end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieNameplate:RedrawIcons()
                        end,

                    },
                },
            },
            targetframe_options_group = {
                type = "group",
                order = 2,
                inline = true,
                name = " ",
                args = {
                    targetframe_header = {
                        type = "header",
                        order = 2,
                        name = function() return l10n('Target Frame Icon Options'); end,
                    },
                    targetplateDescSpacer = {
                        type = "description",
                        order = 2.06,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.4,
                        width = 0.4,
                        func = function() end,
                    },
                    nameplateTargetFrameEnabled = {
                        type = "toggle",
                        order = 2.1,
                        name = function() return l10n('Enable Target Frame Quest Objectives'); end,
                        desc = function() return l10n('Enable or disable the quest objective icons over creature target frame.'); end,
                        descStyle = "inline",
                        width = 2.6,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)

                            -- on false, hide current nameplates
                            if not value then
                                QuestieNameplate:HideCurrentTargetFrame();
                            else
                                QuestieNameplate:DrawTargetFrame();
                            end
                        end,
                    },
                    Spacer_E = QuestieOptionsUtils:Spacer(2.2),
                    targetframeSpacerX = {
                        type = "description",
                        order = 2.25,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.3,
                        width = 0.3,
                        func = function() end,
                    },
                    nameplateTargetFrameX  = {
                        type = "range",
                        order = 2.3,
                        name = function() return l10n('Icon Position X'); end,
                        desc = function() return l10n('Where on the X axis the nameplate icon should be. ( Default: %s )', optionsDefaults.profile.nameplateTargetFrameX); end,
                        width = 1.2,
                        min = -300,
                        max = 300,
                        step = 1,
                        disabled = function() return not Questie.db.profile.nameplateTargetFrameEnabled; end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieNameplate:RedrawFrameIcon()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    targetframeSpacerY = {
                        type = "description",
                        order = 2.35,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.3,
                        width = 0.3,
                        func = function() end,
                    },
                    nameplateTargetFrameY  = {
                        type = "range",
                        order = 2.4,
                        name = function() return l10n('Icon Position Y'); end,
                        desc = function() return l10n('Where on the Y axis the nameplate icon should be. ( Default: %s )', optionsDefaults.profile.nameplateTargetFrameY); end,
                        width = 1.2,
                        min = -200,
                        max = 200,
                        step = 1,
                        disabled = function() return not Questie.db.profile.nameplateTargetFrameEnabled; end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieNameplate:RedrawFrameIcon()
                            QuestieOptions:SetProfileValue(info, value)
                        end,
                    },
                    Spacer_G = QuestieOptionsUtils:Spacer(2.45),
                    targetframeSpacerScale = {
                        type = "description",
                        order = 2.46,
                        name = "",
                        desc = "",
                        image = "",
                        imageWidth = 0.3,
                        width = 0.3,
                        func = function() end,
                    },
                    nameplateTargetFrameScale  = {
                        type = "range",
                        order = 2.5,
                        name = function() return l10n('Nameplate Icon Scale'); end,
                        desc = function() return l10n('Scale the size of the quest icons on creature nameplates. ( Default: %s )', optionsDefaults.profile.nameplateTargetFrameScale); end,
                        width = 2.7,
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        disabled = function() return not Questie.db.profile.nameplateTargetFrameEnabled; end,
                        get = function(info) return QuestieOptions:GetProfileValue(info); end,
                        set = function (info, value)
                            QuestieOptions:SetProfileValue(info, value)
                            QuestieNameplate:RedrawFrameIcon()
                        end,

                    },
                },
            },
            Spacer_end = QuestieOptionsUtils:Spacer(2.5),
            resetSpacerPrefix = {
                type = "description",
                order = 3,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.55,
                width = 0.55,
                func = function() end,
            },
            nameplateReset = {
                type = "execute",
                order = 4,
                name = function() return l10n('Reset Nameplates'); end,
                desc = function() return l10n('Reset to default nameplate position and scale.'); end,
                width = 1,
                disabled = function() return not Questie.db.profile.nameplateEnabled; end,
                func = function (info, value)
                    Questie.db.profile.nameplateX = optionsDefaults.profile.nameplateX;
                    Questie.db.profile.nameplateY = optionsDefaults.profile.nameplateY;
                    Questie.db.profile.nameplateScale = optionsDefaults.profile.nameplateScale;
                    QuestieNameplate:RedrawIcons();
                end,
            },
            resetSpacerMid = {
                type = "description",
                order = 5,
                name = "",
                desc = "",
                image = "",
                imageWidth = 0.3,
                width = 0.3,
                func = function() end,
            },
            targetFrameReset = {
                type = "execute",
                order = 6,
                name = function() return l10n('Reset Target Frame'); end,
                desc = function() return l10n('Reset to default target frame position and scale.'); end,
                width = 1,
                disabled = function() return not Questie.db.profile.nameplateTargetFrameEnabled; end,
                func = function (info, value)
                    Questie.db.profile.nameplateTargetFrameX = optionsDefaults.profile.nameplateTargetFrameX;
                    Questie.db.profile.nameplateTargetFrameY = optionsDefaults.profile.nameplateTargetFrameY;
                    Questie.db.profile.nameplateTargetFrameScale = optionsDefaults.profile.nameplateTargetFrameScale;
                    QuestieNameplate:RedrawFrameIcon();
                end,
            },
        },
    }
end
