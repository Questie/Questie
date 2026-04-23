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

function _QuestieJourney:GetLevelDifficultyRanges(questLevel, questMinLevel)
    local charLevel = UnitLevel("player")
    local red, orange, yellow, green, gray

    -- Gray Level based on level range.
    if (questLevel ~= -1) then
        if (questLevel <= 5) then
            gray =  questLevel + 5
        elseif (questLevel <= 39) then
            gray = (questLevel + math.ceil(questLevel / 10) + 5)
        else
            gray = (questLevel + math.ceil(questLevel / 5) + 1)
        end
    end

    -- Calculate Base Values
    if questLevel == -1 then
        questLevel = (questMinLevel <= charLevel and charLevel) or (questMinLevel > charLevel and questMinLevel)
        if questMinLevel == questLevel then
            yellow = questLevel
        elseif questMinLevel ~= questLevel then
            yellow = questMinLevel .. "-" .. questLevel
        end
    else
        red = questMinLevel
        orange = questLevel - 4
        yellow = questLevel - 2
        green = questLevel + 3

        -- Double check for negative values
        if yellow <= 0 or yellow <= questMinLevel then
            yellow = questMinLevel
        end

        if orange and orange < questMinLevel then
            orange = questMinLevel
        end

        if orange == yellow then
            orange = nil
        end

        if red and (red == orange or not orange) then
            red = nil
        end

        if green and green < questMinLevel then
            green = questMinLevel
        end

        if gray and gray < questMinLevel then
            gray = questMinLevel
        end

    end

    return red, orange, yellow, green, gray
end
