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

    QuestieConfig.showTrackerHeader = Questie:toboolean(QO_showtrackerheader:GetChecked())

    QuestieConfig.showToolTips = Questie:toboolean(QO_showtooltips:GetChecked())

    QuestieConfig.trackerEnabled = Questie:toboolean(QO_trackerenabled:GetChecked())

    QuestieConfig.trackerList = Questie:toboolean(QO_trackerlist:GetChecked())

    QuestieConfig.trackerScale = QO_trackerscale:GetText()

    QuestieConfig.trackerBackground = Questie:toboolean(QO_trackerbackground:GetChecked())

    QuestieConfig.trackerAlpha = QO_trackeralpha:GetText()

    QuestieConfig.resizeWorldmap = Questie:toboolean(QO_resizeworldmap:GetChecked())

    QuestieConfig.hideMinimapIcons = Questie:toboolean(QO_hideminimapicons:GetChecked())

    QuestieConfig.hideObjectives = Questie:toboolean(QO_hideobjectives:GetChecked())

    QuestieConfig.corpseArrow = Questie:toboolean(QO_corpsearrow:GetChecked())

    QuestieConfig.clusterQuests = Questie:toboolean(QO_clusterquests:GetChecked())

    DEFAULT_CHAT_FRAME:AddMessage("Questie Options Applied", 1, 0.75, 0)

    Questie:Toggle()
    Questie:Toggle()

    QuestieOptionsForm:Hide()
end
