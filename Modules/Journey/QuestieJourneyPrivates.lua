---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

_QuestieJourney.containerCache = nil
_QuestieJourney.treeCache = nil



function _QuestieJourney:HandleTabChange(container, group)
    if not _QuestieJourney.containerCache then
        _QuestieJourney.containerCache = container
    end

    container:ReleaseChildren()

    if group == "journey" then
        local treeGroup = _QuestieJourney.myJourney:DrawTab(container)
        _QuestieJourney.myJourney:ManageTree(treeGroup)
        _QuestieJourney.lastOpenWindow = "journey"
        return treeGroup
    elseif group == "zone" then
        _QuestieJourney.questsByZone:DrawTab(container)
        _QuestieJourney.lastOpenWindow = "zone"
        return nil
    elseif group == "faction" then
        _QuestieJourney.questsByFaction:DrawTab(container)
        _QuestieJourney.lastOpenWindow = "faction"
        return nil
    elseif group == "search" then
        QuestieSearchResults:DrawSearchTab(container)
        _QuestieJourney.lastOpenWindow = "search"
        return nil
    end
end


