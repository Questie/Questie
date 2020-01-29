---@class QuestieAuto
local QuestieAuto = QuestieLoader:CreateModule("QuestieAuto");
local _QuestieAuto = QuestieAuto.private
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local shouldRunAuto = true
local doneTalking = false

local cameFromProgressEvent = false
local isAllowedNPC = false
local lastAmountOfAvailableQuests = 0
local lastNPCTalkedTo = nil
local doneWithAccept = false
local lastIndexTried = 1

local MOP_INDEX_AVAILABLE = 7 -- was '5' in Cataclysm
local MOP_INDEX_COMPLETE = 6 -- was '4' in Cataclysm

 -- forward declarations
local _SelectAvailableQuest

function QuestieAuto:GOSSIP_SHOW(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] GOSSIP_SHOW", event, ...)
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    local availableQuests = {GetGossipAvailableQuests()}
    local currentNPC = UnitName("target")
    if lastNPCTalkedTo ~= currentNPC or #availableQuests ~= lastAmountOfAvailableQuests then
        Questie:Debug("Greeted by a new NPC")
        lastNPCTalkedTo = currentNPC
        isAllowedNPC = _QuestieAuto:IsAllowedNPC()
        lastIndexTried = 1
        lastAmountOfAvailableQuests = #availableQuests
        doneWithAccept = false
    end

    if cameFromProgressEvent then
        Questie:Debug("Last event was Progress")
        cameFromProgressEvent = false
        lastIndexTried = lastIndexTried + MOP_INDEX_AVAILABLE
    end

    if Questie.db.char.autoaccept and (not doneWithAccept) and isAllowedNPC then
        if lastIndexTried < #availableQuests then
            Questie:Debug(DEBUG_DEVELOP, "Checking available quests from gossip")
            _QuestieAuto:AcceptQuestFromGossip(lastIndexTried, availableQuests, MOP_INDEX_AVAILABLE)
            return
        else
            Questie:Debug(DEBUG_DEVELOP, "DONE. Checked all available quests")
            doneWithAccept = true
            lastIndexTried = 1
        end
    end

    if Questie.db.char.autocomplete and isAllowedNPC then
        Questie:Debug(DEBUG_DEVELOP, "Checking active quests from gossip")
        local completeQuests = {GetGossipActiveQuests()}

        for index=1, #completeQuests, MOP_INDEX_COMPLETE do
            _QuestieAuto:CompleteQuestFromGossip(index, completeQuests, MOP_INDEX_COMPLETE)
        end
        Questie:Debug(DEBUG_DEVELOP, "DONE. Checked all complete quests")
    end
end

function QuestieAuto:QUEST_PROGRESS(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_PROGRESS", event, ...)
    doneTalking = false

    if not shouldRunAuto then
        Questie:Debug(DEBUG_DEVELOP, "shouldRunAuto = false")
        return
    end

    if Questie.db.char.autocomplete then
        if _QuestieAuto:IsAllowedNPC() and _QuestieAuto:IsAllowedQuest() then
            if IsQuestCompletable() then
                CompleteQuest()
                -- lastIndexTried = lastIndexTried - 1
                return
            else
                Questie:Debug("Quest not completeable. Skipping to next quest. Index:", lastIndexTried)
            end
        end

        -- Close the QuestFrame if no quest is completeable again
        if QuestFrameGoodbyeButton then
            QuestFrameGoodbyeButton:Click()
        end
        cameFromProgressEvent = true
    end
end

_SelectAvailableQuest = function (index)
    Questie:Debug(DEBUG_DEVELOP, "Selecting the " .. index .. ". available quest")
    SelectAvailableQuest(index)
end

function QuestieAuto:QUEST_ACCEPT_CONFIRM(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_ACCEPT_CONFIRM", event, ...)
    doneTalking = false
    -- Escort stuff
    if(Questie.db.char.autoaccept) then
       ConfirmAcceptQuest()
    end
end

function QuestieAuto:QUEST_GREETING(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_GREETING", event, GetNumActiveQuests(), ...)
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    -- Quest already taken
    if (Questie.db.char.autocomplete) then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            Questie:Debug(DEBUG_DEVELOP, quest, isComplete)
            if isComplete then SelectActiveQuest(index) end
        end
    end

    if (Questie.db.char.autoaccept) then
        if lastIndexTried == 0 then
            lastIndexTried = 1
        end
        Questie:Debug(DEBUG_DEVELOP, "lastIndex:", lastIndexTried)
        for index = lastIndexTried, GetNumAvailableQuests() do
            _SelectAvailableQuest(index)
            break
        end
    end
end


function QuestieAuto:QUEST_DETAIL(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_DETAIL", event, ...)
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    -- We really want to disable this in instances, mostly to prevent retards from ruining groups.
    if (Questie.db.char.autoaccept and _QuestieAuto:IsAllowedNPC() and _QuestieAuto:IsAllowedQuest()) then
        Questie:Debug(DEBUG_DEVELOP, "INSIDE", event, ...)

        local questId = GetQuestID()
        ---@type Quest
        local quest = QuestieDB:GetQuest(questId)

        if (not quest:IsTrivial()) or Questie.db.char.acceptTrivial then
            Questie:Debug(DEBUG_INFO, "Questie Auto-Acceping quest")
            AcceptQuest()
        end
    end
end

-- I was forced to make decision on offhand, cloak and shields separate from armor but I can't pick up my mind about the reason...
function QuestieAuto:QUEST_COMPLETE(event, ...)
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] QUEST_COMPLETE", event, ...)
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(DEBUG_DEVELOP, "Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    -- blasted Lands citadel wonderful NPC. They do not trigger any events except quest_complete.
    -- if not AllowedToHandle() then
    --    return
    -- end
    if (Questie.db.char.autocomplete) then

        local questname = GetTitleText()
        local numOptions = GetNumQuestChoices()
        Questie:Debug(DEBUG_DEVELOP, event, questname, numOptions, ...)

        if numOptions > 1 then
            Questie:Debug(DEBUG_INFO, "Multiple rewards (" .. numOptions .. ")! Please choose appropriate reward!")
        else
            _QuestieAuto:TurnInQuest(1)
            Questie:Debug(DEBUG_DEVELOP, "Completed quest!")
        end
    end
end

--- The closingCounter needs to reach 1 for QuestieAuto to reset
--- Whenever the gossip frame is closed this event is called once, HOWEVER
--- when totally stop talking to an NPC this event is called twice
function QuestieAuto:GOSSIP_CLOSED()
    Questie:Debug(DEBUG_DEVELOP, "[EVENT] GOSSIP_CLOSED")

    if doneTalking then
        doneTalking = false
        Questie:Debug(DEBUG_DEVELOP, "We are done talking to an NPC! Resetting shouldRunAuto")
        shouldRunAuto = true
    else
        doneTalking = true
    end
end

function QuestieAuto:ResetModifier()
    shouldRunAuto = true
end
