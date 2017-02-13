function Questie:OptionsForm_Init()
    QO_showlevel = getglobal("QuestieOptionsForm".."AlwaysShowLevelCheck")
    QO_showquests = getglobal("QuestieOptionsForm".."AlwaysShowQuestsCheck")
    QO_arrowenabled = getglobal("QuestieOptionsForm".."ArrowEnabledCheck")
    QO_boldcolors = getglobal("QuestieOptionsForm".."BoldColorsCheck")
    QO_maxlevelfilter = getglobal("QuestieOptionsForm".."MaxLevelFilterCheck")
    QO_maxshowlevel = getglobal("QuestieOptionsForm".."MaxShowLevelEdit")
    QO_minlevelfilter = getglobal("QuestieOptionsForm".."MinLevelFilterCheck")
    QO_minshowlevel = getglobal("QuestieOptionsForm".."MinShowLevelEdit")
    QO_showmapaids = getglobal("QuestieOptionsForm".."ShowMapAidsCheck")
    QO_showprofessionquests = getglobal("QuestieOptionsForm".."ShowProfessionQuestsCheck")
    QO_showtrackerheader = getglobal("QuestieOptionsForm".."ShowTrackerHeaderCheck")
    QO_showtooltips = getglobal("QuestieOptionsForm".."ShowToolTipsCheck")
    QO_trackerenabled = getglobal("QuestieOptionsForm".."TrackerEnabledCheck")
    QO_trackerlist = getglobal("QuestieOptionsForm".."TrackerListCheck")
    QO_trackerscale = getglobal("QuestieOptionsForm".."TrackerScaleEdit")
    QO_trackerbackground = getglobal("QuestieOptionsForm".."TrackerBackgroundCheck")
    QO_trackeralpha = getglobal("QuestieOptionsForm".."TrackerAlphaEdit")
    QO_resizeworldmap = getglobal("QuestieOptionsForm".."ResizeWorldmapCheck")
    QO_hideminimapicons = getglobal("QuestieOptionsForm".."HideMinimapIconsCheck")
    QO_hideobjectives = getglobal("QuestieOptionsForm".."HideObjectivesCheck")
    QO_corpsearrow = getglobal("QuestieOptionsForm".."CorpseArrowCheck")
    QO_clusterquests = getglobal("QuestieOptionsForm".."ClusterQuestsCheck")
    QO_versionlabel = getglobal("QuestieOptionsForm".."VersionLabel".."Label")
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

    DEFAULT_CHAT_FRAME:AddMessage("Questie Options Applied", 1, 0.75, 0);

    QuestieOptionsForm:Hide()
end
