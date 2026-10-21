-------------------------
--Import modules.
-------------------------
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsDefaults
local QuestieOptionsDefaults = QuestieLoader:ImportModule("QuestieOptionsDefaults")
---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")

QuestieOptionsEngine.tabs.nameplate = { ... }
local optionsDefaults = QuestieOptionsDefaults:Load()

function QuestieOptionsEngine.tabs.nameplate:Initialize()
    return {
        title = "Nameplates",
        subtitle = "Nameplate Settings",
        order = 4,
        icon = 134510,
        items = {
            nameplate_options_group = {
                type = "container",
                order = 1,
                title = "Nameplate Icon Options",
                items = {
                    nameplateEnabled = {
                        type = "checkbox",
                        order = 1.1,
                        title = "Enable Nameplate Quest Objectives",
                        tooltip = "Enable or disable the quest objective icons over creature nameplates.",
                        width = "full",
                        get = function() return Questie.db.profile.nameplateEnabled end,
                        set = function(_, value)
                            Questie.db.profile.nameplateEnabled = value
                            if not value then
                                QuestieNameplate:HideCurrentFrames()
                            end
                        end,
                    },
                    nameplateX = {
                        type = "slider",
                        order = 1.2,
                        title = "Icon Position X",
                        tooltip = {"Where on the X axis the nameplate icon should be. (Default: %s)", optionsDefaults.profile.nameplateX},
                        width = "half",
                        min = -200,
                        max = 200,
                        step = 1,
                        enabled = function() return Questie.db.profile.nameplateEnabled end,
                        get = function() return Questie.db.profile.nameplateX end,
                        set = function(_, value)
                            QuestieNameplate.SetIconXPosition(value)
                            QuestieNameplate:RedrawIcons()
                        end,
                    },
                    nameplateY = {
                        type = "slider",
                        order = 1.3,
                        title = "Icon Position Y",
                        tooltip = {"Where on the Y axis the nameplate icon should be. (Default: %s)", optionsDefaults.profile.nameplateY},
                        width = "half",
                        min = -200,
                        max = 200,
                        step = 1,
                        enabled = function() return Questie.db.profile.nameplateEnabled end,
                        get = function() return Questie.db.profile.nameplateY end,
                        set = function(_, value)
                            QuestieNameplate.SetIconYPosition(value)
                            QuestieNameplate:RedrawIcons()
                        end,
                    },
                    nameplateScale = {
                        type = "slider",
                        order = 1.4,
                        title = "Nameplate Icon Scale",
                        tooltip = {"Scale the size of the quest icons on creature nameplates. (Default: %s)", optionsDefaults.profile.nameplateScale},
                        width = "full",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = function() return Questie.db.profile.nameplateEnabled end,
                        get = function() return Questie.db.profile.nameplateScale end,
                        set = function(_, value)
                            QuestieNameplate.SetIconScale(value)
                            QuestieNameplate:RedrawIcons()
                        end,
                    },
                },
            },
            targetframe_options_group = {
                type = "container",
                order = 2,
                title = "Target Frame Icon Options",
                items = {
                    nameplateTargetFrameEnabled = {
                        type = "checkbox",
                        order = 2.1,
                        title = "Enable Target Frame Quest Objectives",
                        tooltip = "Enable or disable the quest objective icons over creature target frame.",
                        width = "full",
                        get = function() return Questie.db.profile.nameplateTargetFrameEnabled end,
                        set = function(_, value)
                            Questie.db.profile.nameplateTargetFrameEnabled = value
                            if not value then
                                QuestieNameplate:HideCurrentTargetFrame()
                            else
                                QuestieNameplate:DrawTargetFrame()
                            end
                        end,
                    },
                    nameplateTargetFrameX = {
                        type = "slider",
                        order = 2.2,
                        title = "Icon Position X",
                        tooltip = {"Where on the X axis the nameplate icon should be. (Default: %s)", optionsDefaults.profile.nameplateTargetFrameX},
                        width = "half",
                        min = -300,
                        max = 300,
                        step = 1,
                        enabled = function() return Questie.db.profile.nameplateTargetFrameEnabled end,
                        get = function() return Questie.db.profile.nameplateTargetFrameX end,
                        set = function(_, value)
                            Questie.db.profile.nameplateTargetFrameX = value
                            QuestieNameplate:RedrawFrameIcon()
                        end,
                    },
                    nameplateTargetFrameY = {
                        type = "slider",
                        order = 2.3,
                        title = "Icon Position Y",
                        tooltip = {"Where on the Y axis the nameplate icon should be. (Default: %s)", optionsDefaults.profile.nameplateTargetFrameY},
                        width = "half",
                        min = -200,
                        max = 200,
                        step = 1,
                        enabled = function() return Questie.db.profile.nameplateTargetFrameEnabled end,
                        get = function() return Questie.db.profile.nameplateTargetFrameY end,
                        set = function(_, value)
                            Questie.db.profile.nameplateTargetFrameY = value
                            QuestieNameplate:RedrawFrameIcon()
                        end,
                    },
                    nameplateTargetFrameScale = {
                        type = "slider",
                        order = 2.4,
                        title = "Nameplate Icon Scale",
                        tooltip = {"Scale the size of the quest icons on creature nameplates. (Default: %s)", optionsDefaults.profile.nameplateTargetFrameScale},
                        width = "full",
                        min = 0.01,
                        max = 4,
                        step = 0.01,
                        enabled = function() return Questie.db.profile.nameplateTargetFrameEnabled end,
                        get = function() return Questie.db.profile.nameplateTargetFrameScale end,
                        set = function(_, value)
                            Questie.db.profile.nameplateTargetFrameScale = value
                            QuestieNameplate:RedrawFrameIcon()
                        end,
                    },
                },
            },
            nameplateReset = {
                type = "button",
                order = 3,
                title = "Reset Nameplates",
                btnLabel = "Reset Nameplates",
                tooltip = "Reset to default nameplate position and scale.",
                width = "half",
                align = "CENTER",
                enabled = function() return Questie.db.profile.nameplateEnabled end,
                func = function()
                    QuestieNameplate.SetIconPosition(
                        optionsDefaults.profile.nameplateX,
                        optionsDefaults.profile.nameplateY,
                        optionsDefaults.profile.nameplateScale
                    )
                    QuestieOptionsEngine:RefreshStates()
                end,
            },
            targetFrameReset = {
                type = "button",
                order = 4,
                title = "Reset Target Frame",
                btnLabel = "Reset Target Frame",
                tooltip = "Reset to default target frame position and scale.",
                width = "half",
                align = "CENTER",
                enabled = function() return Questie.db.profile.nameplateTargetFrameEnabled end,
                func = function()
                    Questie.db.profile.nameplateTargetFrameX = optionsDefaults.profile.nameplateTargetFrameX
                    Questie.db.profile.nameplateTargetFrameY = optionsDefaults.profile.nameplateTargetFrameY
                    Questie.db.profile.nameplateTargetFrameScale = optionsDefaults.profile.nameplateTargetFrameScale
                    QuestieNameplate:RedrawFrameIcon()
                    QuestieOptionsEngine:RefreshStates()
                end,
            },
        },
    }
end