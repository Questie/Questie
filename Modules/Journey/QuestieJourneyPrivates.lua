---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local AceGUI = LibStub("AceGUI-3.0")

_QuestieJourney.containerCache = nil
_QuestieJourney.treeChache = nil


function _QuestieJourney:ShowJourneyTooltip()
    if GameTooltip:IsShown() then
        return
    end
    local button = self -- ACE is doing something stupid here. Don't add "self" as parameter, when you use it as "_QuestieJourney.ShowJourneyTooltip" as callback

    local qid = button:GetUserData('id')
    local quest = QuestieDB:GetQuest(tonumber(qid))
    if quest then
        GameTooltip:SetOwner(_G["QuestieJourneyFrame"], "ANCHOR_CURSOR")
        GameTooltip:AddLine("[".. quest.level .."] ".. quest.name)
        GameTooltip:AddLine("|cFFFFFFFF" .. _QuestieJourney:CreateObjectiveText(quest.Description))
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end
end

function _QuestieJourney:HideJourneyTooltip()
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end

function _QuestieJourney:JumpToQuest()
    QuestieSearchResults:JumpToQuest(self)
    _QuestieJourney:HideJourneyTooltip()
end

function _QuestieJourney:CreateObjectiveText(desc)
    local objText = ""

    if desc then
        if type(desc) == "table" then
            for i, v in ipairs(desc) do
                objText = objText .. v .. "\n"
            end
        else
            objText = objText .. tostring(desc) .. "\n"
        end
    else
        objText = Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_AUTO_QUEST'), 'yellow')
    end

    return objText
end

function _QuestieJourney:JourneySelectTabGroup(container, event, group)
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
    elseif group == "search" then
        QuestieSearchResults:DrawSearchTab(container)
        _QuestieJourney.lastOpenWindow = "search"
        return nil
    end
end

function _QuestieJourney:GetLevelDifficultyRanges(questLevel, questMinLevel)

    local red, orange, yellow, green, gray = 0,0,0,0,0

    -- Calculate Base Values
    red = questMinLevel
    orange = questLevel - 4
    yellow = questLevel - 2
    green = questLevel + 3

    -- Gray Level based on level range.
    if (questLevel <= 13) then
        gray =  questLevel + 6
    elseif (questLevel <= 39) then
        gray = (questLevel + math.ceil(questLevel / 10) + 5)
    else
        gray = (questLevel + math.ceil(questLevel / 5) + 1)
    end

    -- Double check for negative values
    if yellow <= 0 then
        yellow = questMinLevel
    end

    if orange < questMinLevel then
        orange = questMinLevel
    end

    if orange == yellow then
        orange = nil
    end

    if red == orange or not orange then
        red = nil
    end


    return red, orange, yellow, green, gray
end