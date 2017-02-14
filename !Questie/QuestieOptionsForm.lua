local QO_FormName = "QuestieOptionsForm"

function Questie:OptionsForm_Init()
    QO_arrowenabled = getglobal(QO_FormName.."ArrowEnabledCheck")
    QO_showquests = getglobal(QO_FormName.."AlwaysShowQuestsCheck")
    QO_boldcolors = getglobal(QO_FormName.."BoldColorsCheck")
    QO_clusterquests = getglobal(QO_FormName.."ClusterQuestsCheck")
    QO_corpsearrow = getglobal(QO_FormName.."CorpseArrowCheck")
    QO_hideminimapicons = getglobal(QO_FormName.."HideMinimapIconsCheck")
    QO_hideobjectives = getglobal(QO_FormName.."HideObjectivesCheck")
    QO_maxlevelfilter = getglobal(QO_FormName.."MaxLevelFilterCheck")
    QO_maxshowlevel = getglobal(QO_FormName.."MaxShowLevelEdit")
    QO_minlevelfilter = getglobal(QO_FormName.."MinLevelFilterCheck")
    QO_minshowlevel = getglobal(QO_FormName.."MinShowLevelEdit")
    QO_resizeworldmap = getglobal(QO_FormName.."ResizeWorldmapCheck")
    QO_showmapaids = getglobal(QO_FormName.."ShowMapAidsCheck")
    QO_showprofessionquests = getglobal(QO_FormName.."ShowProfessionQuestsCheck")
    QO_showtooltips = getglobal(QO_FormName.."ShowToolTipsCheck")
    QO_showtrackerheader = getglobal(QO_FormName.."ShowTrackerHeaderCheck")
    QO_trackeralpha = getglobal(QO_FormName.."TrackerAlphaEdit")
    QO_trackerbackground = getglobal(QO_FormName.."TrackerBackgroundCheck")
    QO_trackerenabled = getglobal(QO_FormName.."TrackerEnabledCheck")
    QO_trackerlist = getglobal(QO_FormName.."TrackerListCheck")
    QO_trackerscale = getglobal(QO_FormName.."TrackerScaleEdit")
    QO_versionlabel = getglobal(QO_FormName.."VersionLabel".."Label")
end

function Questie:OptionsForm_Display()
    Questie:OptionsForm_Init()

    QO_arrowenabled:SetChecked(QuestieConfig["arrowEnabled"])

    QO_showquests:SetChecked(QuestieConfig["alwaysShowQuests"])

    QO_boldcolors:SetChecked(QuestieConfig["boldColors"])

    QO_corpsearrow:SetChecked(QuestieConfig["corpseArrow"])

    QO_clusterquests:SetChecked(QuestieConfig["clusterQuests"])

    QO_hideminimapicons:SetChecked(QuestieConfig["hideMinimapIcons"])

    QO_hideobjectives:SetChecked(QuestieConfig["hideObjectives"])

    QO_maxlevelfilter:SetChecked(QuestieConfig["maxLevelFilter"])

    QO_maxshowlevel:SetText(tostring(QuestieConfig["maxShowLevel"]))

    QO_minlevelfilter:SetChecked(QuestieConfig["minLevelFilter"])

    QO_minshowlevel:SetText(tostring(QuestieConfig["minShowLevel"]))

    QO_resizeworldmap:SetChecked(QuestieConfig["resizeWorldmap"])

    QO_showmapaids:SetChecked(QuestieConfig["showMapAids"])

    QO_showprofessionquests:SetChecked(QuestieConfig["showProfessionQuests"])

    QO_showtooltips:SetChecked(QuestieConfig["showToolTips"])

    QO_showtrackerheader:SetChecked(QuestieConfig["showTrackerHeader"])

    QO_trackeralpha:SetText(tostring(QuestieConfig["trackerAlpha"]))

    QO_trackerbackground:SetChecked(QuestieConfig["trackerBackground"])

    QO_trackerenabled:SetChecked(QuestieConfig["trackerEnabled"])

    QO_trackerlist:SetChecked(QuestieConfig["trackerList"])

    QO_trackerscale:SetText(tostring(QuestieConfig["trackerScale"]))

    QO_versionlabel:SetText("Version: " .. tostring(QuestieConfig["getVersion"]))

    QuestieOptionsForm:Show()
end

function Questie:OptionsForm_ApplyOptions()
    QuestieConfig.alwaysShowQuests = Questie:toboolean(QO_showquests:GetChecked())

    QuestieConfig.arrowEnabled = Questie:toboolean(QO_arrowenabled:GetChecked())

    QuestieConfig.boldColors = Questie:toboolean(QO_boldcolors:GetChecked())

    QuestieConfig.clusterQuests = Questie:toboolean(QO_clusterquests:GetChecked())

    QuestieConfig.corpseArrow = Questie:toboolean(QO_corpsearrow:GetChecked())

    QuestieConfig.hideMinimapIcons = Questie:toboolean(QO_hideminimapicons:GetChecked())

    QuestieConfig.hideObjectives = Questie:toboolean(QO_hideobjectives:GetChecked())

    QuestieConfig.maxLevelFilter = Questie:toboolean(QO_maxlevelfilter:GetChecked())

    QuestieConfig.maxShowLevel = QO_maxshowlevel:GetText()

    QuestieConfig.minLevelFilter = Questie:toboolean(QO_minlevelfilter:GetChecked())

    QuestieConfig.minShowLevel = QO_minshowlevel:GetText()

    QuestieConfig.showMapAids = Questie:toboolean(QO_showmapaids:GetChecked())

    QuestieConfig.showProfessionQuests = Questie:toboolean(QO_showprofessionquests:GetChecked())

    -- Compare opening values and values attempting to be set, if any are different a reload will be needed
    local CachedValues = {
        ["resizeWorldmap"] = QuestieConfig.resizeWorldmap,
        ["showToolTips"] = QuestieConfig.showToolTips,
        ["showTrackerHeader"] = QuestieConfig.showTrackerHeader,
        ["trackerAlpha"] = QuestieConfig.trackerAlpha,
        ["trackerBackground"] = QuestieConfig.trackerBackground,
        ["trackerEnabled"] = QuestieConfig.trackerEnabled,
        ["trackerList"] = QuestieConfig.trackerList, -- Changes list direction, true  = bottom>top, false = top>bottom
        ["trackerScale"] = QuestieConfig.trackerScale
    }


    QuestieConfig.resizeWorldmap = Questie:toboolean(QO_resizeworldmap:GetChecked())
    QuestieConfig.showToolTips = Questie:toboolean(QO_showtooltips:GetChecked())
    QuestieConfig.showTrackerHeader = Questie:toboolean(QO_showtrackerheader:GetChecked())
    QuestieConfig.trackerAlpha = QO_trackeralpha:GetText()
    QuestieConfig.trackerBackground = Questie:toboolean(QO_trackerbackground:GetChecked())
    QuestieConfig.trackerEnabled = Questie:toboolean(QO_trackerenabled:GetChecked())
    QuestieConfig.trackerList = Questie:toboolean(QO_trackerlist:GetChecked())
    QuestieConfig.trackerScale = QO_trackerscale:GetText()

    DEFAULT_CHAT_FRAME:AddMessage("Questie Options Applied", 1, 0.75, 0)

    local bDisplayWarning = false
    local WarningMessage = "|cFFFFFF00Some options require a ReloadUI to apply:|n|n"
    if(QuestieConfig.resizeWorldmap ~= CachedValues.resizeWorldmap) then
        WarningMessage = WarningMessage.."Resize World Map|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.showToolTips ~= CachedValues.showToolTips) then
        WarningMessage = WarningMessage.."Show Tool Tips|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.showTrackerHeader ~= CachedValues.showTrackerHeader) then
        WarningMessage = WarningMessage.."Show Tracker Header|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerAlpha ~= CachedValues.trackerAlpha) then
        WarningMessage = WarningMessage.."Tracker Alpha|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerBackground ~= CachedValues.trackerBackground) then
        WarningMessage = WarningMessage.."Tracker Background|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerEnabled ~= CachedValues.trackerEnabled) then
        WarningMessage = WarningMessage.."Tracker Enabled|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerList ~= CachedValues.trackerList) then
        WarningMessage = WarningMessage.."Tracker List|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerScale ~= CachedValues.trackerScale) then
        WarningMessage = WarningMessage.."Tracker Scale|n"
        bDisplayWarning = true
    end
    WarningMessage = WarningMessage.."|nDo you want to reload now or revert these settings?|r"

    if(bDisplayWarning) then
        StaticPopupDialogs["OPTIONS_WARNING_F"] = {
            text = WarningMessage,
            button1 = TEXT("Reload"),
            button2 = TEXT("Revert"),
            OnAccept = function()
                ReloadUI()
            end,
            OnCancel = function()
                -- Reset to cached values since user opted not to reloadui
                QuestieConfig.resizeWorldmap = CachedValues.resizeWorldmap
                QuestieConfig.showToolTips = CachedValues.showToolTips
                QuestieConfig.showTrackerHeader = CachedValues.showTrackerHeader
                QuestieConfig.trackerAlpha = CachedValues.trackerAlpha
                QuestieConfig.trackerBackground = CachedValues.trackerBackground
                QuestieConfig.trackerEnabled = CachedValues.trackerEnabled
                QuestieConfig.trackerList = CachedValues.trackerList
                QuestieConfig.trackerScale = CachedValues.trackerScale
                DEFAULT_CHAT_FRAME:AddMessage("Questie Options that required a UI Reload have been reverted", 1, 0.75, 0)
            end,
            timeout = 60,
            exclusive = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show("OPTIONS_WARNING_F")
    end

    Questie:Toggle()
    Questie:Toggle()

    QuestieOptionsForm:Hide()
end

function Questie:OptionsForm_SettingOnEnter(SettingsName)
    QuestieOptionsToolTip:SetOwner(this, "ANCHOR_RIGHT", -(this:GetWidth() / 2), 10)

    if(SettingsName == "ArrowEnabled") then
        QuestieOptionsToolTip:AddLine("Quest Arrow (default=true)", 1, 1, 0)

    elseif(SettingsName == "AlwaysShowQuests") then
        QuestieOptionsToolTip:AddLine("Always show quests and objectives (default=true)", 1, 1, 0)

    elseif(SettingsName == "BoldColors") then
        QuestieOptionsToolTip:AddLine("QuestTracker Alternate Colors (default=false)", 1, 1, 0)

    elseif(SettingsName == "ClusterQuests") then
        QuestieOptionsToolTip:AddLine("Cluster nearby quests together (default=true)", 1, 1, 0)

    elseif(SettingsName == "CorpseArrow") then
        QuestieOptionsToolTip:AddLine("Displays an arrow to your corpse (default=true)", 1, 1, 0)

    elseif(SettingsName == "HideMinimapIcons") then
        QuestieOptionsToolTip:AddLine("Hides quest starter icons on mini map only (default=false)", 1, 1, 0)

    elseif(SettingsName == "HideObjectives") then
        QuestieOptionsToolTip:AddLine("Objective Icons (default=false)", 1, 1, 0)

    elseif(SettingsName == "MaxLevelFilter") then
        QuestieOptionsToolTip:AddLine("Max-Level Filter (default=false)", 1, 1, 0)

    elseif(SettingsName == "MaxShowLevel") then
        QuestieOptionsToolTip:AddLine("Hides quests until <X> levels above players level (default=3)", 1, 1, 0)

    elseif(SettingsName == "MinLevelFilter") then
        QuestieOptionsToolTip:AddLine("Min-Level Filter (default=false)", 1, 1, 0)

    elseif(SettingsName == "MinShowLevel") then
        QuestieOptionsToolTip:AddLine("Hides quests <X> levels below players level (default=5)", 1, 1, 0)

    elseif(SettingsName == "ResizeWorldmap") then
        QuestieOptionsToolTip:AddLine("Resizes the Worldmap (default=false)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "ShowMapAids") then
        QuestieOptionsToolTip:AddLine("World/Minimap icons (default=true)", 1, 1, 0)

    elseif(SettingsName == "ShowProfessionQuests") then
        QuestieOptionsToolTip:AddLine("Profession quests (default=false)", 1, 1, 0)

    elseif(SettingsName == "ShowToolTips") then
        QuestieOptionsToolTip:AddLine("Always show quest and objective tool tips (default=true)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "ShowTrackerHeader") then
        QuestieOptionsToolTip:AddLine("Displays a header above the quest tracker (default=false)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "TrackerAlpha") then
        QuestieOptionsToolTip:AddLine("QuestTracker background alpha level (default=0.4)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "TrackerBackground") then
        QuestieOptionsToolTip:AddLine("QuestTracker background will always remain on (default=false)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "TrackerEnabled") then
        QuestieOptionsToolTip:AddLine("QuestTracker (default=true)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "TrackerList") then
        QuestieOptionsToolTip:AddLine("Lists quests [True] = Bottom->Up, [False] = Top->Down (default=false)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)

    elseif(SettingsName == "TrackerScale") then
        QuestieOptionsToolTip:AddLine("QuestTracker Size (default=1)", 1, 1, 0)
        QuestieOptionsToolTip:AddLine("Requires ReloadUI", 1, 0, 0)
    end

    QuestieOptionsToolTip:Show()
end

function Questie:OptionsForm_SettingOnLeave()
    QuestieOptionsToolTip:Hide()
end
