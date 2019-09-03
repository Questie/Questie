
QuestieAuto_Questie = {...}

function QuestieAuto_QUEST_PROGRESS(event, ...)
    Questie:Debug(DEBUG_DEVELOP, event, ...)
    if IsQuestCompletable() then
        CompleteQuest()
    end
end

function QuestieAuto_ACCEPT_QUEST_GOSSIP(...)
    local MOP_INDEX_CONST = 7 -- was '5' in Cataclysm
    for i = 1, select("#", ...), MOP_INDEX_CONST do
        local title = select(i, ...)
        local isTrivial = select(i + 2, ...)
        local isRepeatable = select(i + 4, ...) -- complete status
        Questie:Debug(DEBUG_DEVELOP, "Accepting quest, Title:", title, "Trivial", isTrivial, "Repeatable", isRepeatable, "index", i)
        if( not isTrivial) then
            Questie:Debug(DEBUG_INFO, "Accepting quest, ", title)
            SelectGossipAvailableQuest(math.floor(i / MOP_INDEX_CONST) + 1)
        end
    end
end

function QuestieAuto_COMPLETE_QUEST_GOSSIP(...)
    local MOP_INDEX_CONST = 6 -- was '4' in Cataclysm
    for i = 1, select("#", ...), MOP_INDEX_CONST do
        local title = select(i, ...)
        local isComplete = select(i + 3, ...) -- complete status
        Questie:Debug(DEBUG_DEVELOP, "Completing quest, ", title, "Complete", isComplete, "index", i)
        if ( isComplete ) then
            Questie:Debug(DEBUG_INFO, "Completing quest, ", title)
            SelectGossipActiveQuest(math.floor(i / MOP_INDEX_CONST) + 1)
        end
    end
end

function QuestieAuto_GOSSIP_SHOW(event, ...)
    Questie:Debug(DEBUG_DEVELOP, event, ...)

    if Questie.db.char.autoaccept then
        ACCEPT_QUEST_GOSSIP(GetGossipAvailableQuests())
    end
    if Questie.db.char.autocomplete then
        COMPLETE_QUEST_GOSSIP(GetGossipActiveQuests())
    end
end

function QuestieAuto_QUEST_GREETING(event, ...)
    Questie:Debug(DEBUG_DEVELOP, event, GetNumActiveQuests(), ...)
    --Quest already taken
    if(Questie.db.char.autocomplete) then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            Questie:Debug(DEBUG_DEVELOP, quest, isComplete)
            if isComplete then
                SelectActiveQuest(index)
            end
        end
    end

    if(Questie.db.char.autoaccept) then
        for index = 1, GetNumAvailableQuests() do
            local isTrivial, isDaily, isRepeatable, isIgnored = GetAvailableQuestInfo(index)
            if (isIgnored) then return end -- Legion functionality
            if( not isTrivial and not isRepeatable) then
                local title = GetAvailableTitle(index)
                SelectAvailableQuest(index)
            end
        end
    end
end

function QuestieAuto_Questie:TurnInQuest(rewardIndex)
    --Maybe we want to do something smart?
    GetQuestReward(rewardIndex)
end

function QuestieAuto_QUEST_ACCEPT_CONFIRM(event, ...)
    --Escort stuff
    --if(Questie.db.char.autoaccept) then
    --    ConfirmAcceptQuest()
    --end
end

function QuestieAuto_QUEST_DETAIL(event, ...)
    Questie:Debug(DEBUG_DEVELOP, event, ...)
    if(Questie.db.char.autoaccept) then
        if QuestGetAutoAccept() then
            Questie:Debug(DEBUG_INFO, "Quest already accepted")
            local QuestFrameButton = _G["QuestFrameAcceptButton"];
            if(QuestFrameButton:IsVisible()) then
                Questie:Debug(DEBUG_INFO, "Blizzard auto-accept workaround")
                QuestFrameButton:Click("Accept Quest")
            else
                CloseQuest()
            end
        else
            Questie:Debug(DEBUG_INFO, "Questie Auto-Acceping quest")
            AcceptQuest()
        end
    end
end

-- I was forced to make decision on offhand, cloak and shields separate from armor but I can't pick up my mind about the reason...
function QuestieAuto_QUEST_COMPLETE(event, ...)
    Questie:Debug(DEBUG_DEVELOP, event, ...);
    -- blasted Lands citadel wonderful NPC. They do not trigger any events except quest_complete.
    --if not AllowedToHandle() then
    --    return
    --end

    local questname = GetTitleText()
    local numOptions = GetNumQuestChoices()
    Questie:Debug(DEBUG_DEVELOP, event, questname, numOptions, ...);

    if numOptions > 1 then
        Questie:Debug(DEBUG_DEVELOP, "Multiple rewards! ", numOptions);
        local function getItemId(typeStr)
            local link = GetQuestItemLink(typeStr, 1) --first item is enough
            return link and link:match("%b::"):gsub(":", "")
        end

        local itemID = getItemId("choice")
        if (not itemID) then
            Questie:Debug(DEBUG_DEVELOP, "Can't read reward link from server. Close NPC dialogue and open it again.");
            return
        end
        Questie:Debug(DEBUG_INFO, "Multiple rewards! Please choose appropriate reward!");

    else
        Questie:TurnInQuest(1)
        Questie:Debug(DEBUG_DEVELOP, "Completed quest!");
    end
end
