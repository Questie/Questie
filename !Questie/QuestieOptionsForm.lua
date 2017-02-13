local QO_FormName = "QuestieOptionsForm"

function Questie:OptionsForm_Init()
    QO_showlevel = getglobal(QO_FormName.."AlwaysShowLevelCheck")
    QO_showquests = getglobal(QO_FormName.."AlwaysShowQuestsCheck")
    QO_arrowenabled = getglobal(QO_FormName.."ArrowEnabledCheck")
    QO_boldcolors = getglobal(QO_FormName.."BoldColorsCheck")
    QO_maxlevelfilter = getglobal(QO_FormName.."MaxLevelFilterCheck")
    QO_maxshowlevel = getglobal(QO_FormName.."MaxShowLevelEdit")
    QO_minlevelfilter = getglobal(QO_FormName.."MinLevelFilterCheck")
    QO_minshowlevel = getglobal(QO_FormName.."MinShowLevelEdit")
    QO_showmapaids = getglobal(QO_FormName.."ShowMapAidsCheck")
    QO_showprofessionquests = getglobal(QO_FormName.."ShowProfessionQuestsCheck")
    QO_showtrackerheader = getglobal(QO_FormName.."ShowTrackerHeaderCheck")
    QO_showtooltips = getglobal(QO_FormName.."ShowToolTipsCheck")
    QO_trackerenabled = getglobal(QO_FormName.."TrackerEnabledCheck")
    QO_trackerlist = getglobal(QO_FormName.."TrackerListCheck")
    QO_trackerscale = getglobal(QO_FormName.."TrackerScaleEdit")
    QO_trackerbackground = getglobal(QO_FormName.."TrackerBackgroundCheck")
    QO_trackeralpha = getglobal(QO_FormName.."TrackerAlphaEdit")
    QO_resizeworldmap = getglobal(QO_FormName.."ResizeWorldmapCheck")
    QO_hideminimapicons = getglobal(QO_FormName.."HideMinimapIconsCheck")
    QO_hideobjectives = getglobal(QO_FormName.."HideObjectivesCheck")
    QO_corpsearrow = getglobal(QO_FormName.."CorpseArrowCheck")
    QO_clusterquests = getglobal(QO_FormName.."ClusterQuestsCheck")
    QO_versionlabel = getglobal(QO_FormName.."VersionLabel".."Label")
end

function Questie:OptionsForm_Display()
    Questie:OptionsForm_Init()

    QO_showlevel:SetChecked(QuestieConfig["alwaysShowLevel"])

    QO_showquests:SetChecked(QuestieConfig["alwaysShowQuests"])

    QO_arrowenabled:SetChecked(QuestieConfig["arrowEnabled"])

    QO_boldcolors:SetChecked(QuestieConfig["boldColors"])

    QO_maxlevelfilter:SetChecked(QuestieConfig["maxLevelFilter"])

    QO_maxshowlevel:SetText(tostring(QuestieConfig["maxShowLevel"]))

    QO_minlevelfilter:SetChecked(QuestieConfig["minLevelFilter"])

    QO_minshowlevel:SetText(tostring(QuestieConfig["minShowLevel"]))

    QO_showmapaids:SetChecked(QuestieConfig["showMapAids"])

    QO_showprofessionquests:SetChecked(QuestieConfig["showProfessionQuests"])

    QO_showtrackerheader:SetChecked(QuestieConfig["showTrackerHeader"])

    QO_showtooltips:SetChecked(QuestieConfig["showToolTips"])

    QO_trackerenabled:SetChecked(QuestieConfig["trackerEnabled"])

    QO_trackerlist:SetChecked(QuestieConfig["trackerList"])

    QO_trackerscale:SetText(tostring(QuestieConfig["trackerScale"]))

    QO_trackerbackground:SetChecked(QuestieConfig["trackerBackground"])

    QO_trackeralpha:SetText(tostring(QuestieConfig["trackerAlpha"]))

    QO_resizeworldmap:SetChecked(QuestieConfig["resizeWorldmap"])

    QO_hideminimapicons:SetChecked(QuestieConfig["hideMinimapIcons"])

    QO_hideobjectives:SetChecked(QuestieConfig["hideObjectives"])

    QO_corpsearrow:SetChecked(QuestieConfig["corpseArrow"])

    QO_clusterquests:SetChecked(QuestieConfig["clusterQuests"])

    QO_versionlabel:SetText("Version: " .. tostring(QuestieConfig["getVersion"]))

    QuestieOptionsForm:Show()
end

function Questie:OptionsForm_ApplyOptions()
    QuestieConfig.alwaysShowLevel = Questie:toboolean(QO_showlevel:GetChecked())

    QuestieConfig.alwaysShowQuests = Questie:toboolean(QO_showquests:GetChecked())

    QuestieConfig.arrowEnabled = Questie:toboolean(QO_arrowenabled:GetChecked())

    QuestieConfig.boldColors = Questie:toboolean(QO_boldcolors:GetChecked())

    QuestieConfig.maxLevelFilter = Questie:toboolean(QO_maxlevelfilter:GetChecked())

    QuestieConfig.maxShowLevel = QO_maxshowlevel:GetText()

    QuestieConfig.minLevelFilter = Questie:toboolean(QO_minlevelfilter:GetChecked())

    QuestieConfig.minShowLevel = QO_minshowlevel:GetText()

    QuestieConfig.showMapAids = Questie:toboolean(QO_showmapaids:GetChecked())

    QuestieConfig.showProfessionQuests = Questie:toboolean(QO_showprofessionquests:GetChecked())

    QuestieConfig.hideMinimapIcons = Questie:toboolean(QO_hideminimapicons:GetChecked())

    QuestieConfig.hideObjectives = Questie:toboolean(QO_hideobjectives:GetChecked())

    QuestieConfig.corpseArrow = Questie:toboolean(QO_corpsearrow:GetChecked())

    QuestieConfig.clusterQuests = Questie:toboolean(QO_clusterquests:GetChecked())


    -- Compare opening values and values attempting to be set, if any are different a reload will be needed
    local CachedValues = {
        ["trackerList"] = QuestieConfig.trackerList, -- Changes list direction, true  = bottom>top, false = top>bottom
        ["showTrackerHeader"] = QuestieConfig.showTrackerHeader,
        ["showToolTips"] = QuestieConfig.showToolTips,
        ["trackerEnabled"] = QuestieConfig.trackerEnabled,
        ["trackerScale"] = QuestieConfig.trackerScale,
        ["trackerAlpha"] = QuestieConfig.trackerAlpha,
        ["resizeWorldmap"] = QuestieConfig.resizeWorldmap,
        ["trackerBackground"] = QuestieConfig.trackerBackground
    }

    QuestieConfig.trackerList = Questie:toboolean(QO_trackerlist:GetChecked())
    QuestieConfig.showTrackerHeader = Questie:toboolean(QO_showtrackerheader:GetChecked())
    QuestieConfig.showToolTips = Questie:toboolean(QO_showtooltips:GetChecked())
    QuestieConfig.trackerEnabled = Questie:toboolean(QO_trackerenabled:GetChecked())
    QuestieConfig.trackerScale = QO_trackerscale:GetText()
    QuestieConfig.trackerAlpha = QO_trackeralpha:GetText()
    QuestieConfig.resizeWorldmap = Questie:toboolean(QO_resizeworldmap:GetChecked())
    QuestieConfig.trackerBackground = Questie:toboolean(QO_trackerbackground:GetChecked())

    DEFAULT_CHAT_FRAME:AddMessage("Questie Options Applied", 1, 0.75, 0)

    local bDisplayWarning = false
    local WarningMessage = "|cFFFFFF00The following settings will require a UI Reload to apply:|n|n"
    if(QuestieConfig.trackerList ~= CachedValues.trackerList) then
        WarningMessage = WarningMessage.."Tracker List|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.showTrackerHeader ~= CachedValues.showTrackerHeader) then
        WarningMessage = WarningMessage.."Show Tracker Header|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.showToolTips ~= CachedValues.showToolTips) then
        WarningMessage = WarningMessage.."Show Tool Tips|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerEnabled ~= CachedValues.trackerEnabled) then
        WarningMessage = WarningMessage.."Tracker Enabled|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerScale ~= CachedValues.trackerScale) then
        WarningMessage = WarningMessage.."Tracker Scale|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerAlpha ~= CachedValues.trackerAlpha) then
        WarningMessage = WarningMessage.."Tracker Alpha|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.resizeWorldmap ~= CachedValues.resizeWorldmap) then
        WarningMessage = WarningMessage.."Resize World Map|n"
        bDisplayWarning = true
    end
    if(QuestieConfig.trackerBackground ~= CachedValues.trackerBackground) then
        WarningMessage = WarningMessage.."Tracker Background|n"
        bDisplayWarning = true
    end
    WarningMessage = WarningMessage.."|nAre you sure you want to continue?|r"

    if(bDisplayWarning) then
        StaticPopupDialogs["OPTIONS_WARNING_F"] = {
            text = WarningMessage,
            button1 = TEXT(YES),
            button2 = TEXT(NO),
            OnAccept = function()
                ReloadUI()
            end,
            OnCancel = function()
                -- Reset to cached values since user opted not to reloadui
                QuestieConfig.trackerList = CachedValues.trackerList
                QuestieConfig.showTrackerHeader = CachedValues.showTrackerHeader
                QuestieConfig.showToolTips = CachedValues.showToolTips
                QuestieConfig.trackerEnabled = CachedValues.trackerEnabled
                QuestieConfig.trackerScale = CachedValues.trackerScale
                QuestieConfig.trackerAlpha = CachedValues.trackerAlpha
                QuestieConfig.resizeWorldmap = CachedValues.resizeWorldmap
                QuestieConfig.trackerBackground = CachedValues.trackerBackground
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
