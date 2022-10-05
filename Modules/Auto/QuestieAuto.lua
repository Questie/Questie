---@class QuestieAuto
---@field private private QuestieAutoPrivate
local QuestieAuto = QuestieLoader:CreateModule("QuestieAuto");
local _QuestieAuto = QuestieAuto.private
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local shouldRunAuto = true
local doneTalking = false

local cameFromProgressEvent = false
local isAllowedNPC = false
local lastAmountOfAvailableQuests = 0
local lastNPCTalkedTo
local doneWithAccept = false
local lastIndexTried = 1
local lastEvent

local MOP_INDEX_AVAILABLE = 7 -- was '5' in Cataclysm
local MOP_INDEX_COMPLETE = 6 -- was '4' in Cataclysm

 -- forward declarations
local _SelectAvailableQuest


local function ResetModifier()
    shouldRunAuto = true
    lastEvent = nil
end

function QuestieAuto:GOSSIP_SHOW(event, ...)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] GOSSIP_SHOW", event, ...)
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Modifier-Key down: Disabling QuestieAuto for now")
        return
    end
    lastEvent = "GOSSIP_SHOW"

    local availableQuests = {GetGossipAvailableQuests()}
    local currentNPC = UnitName("target")
    if lastNPCTalkedTo ~= currentNPC or #availableQuests ~= lastAmountOfAvailableQuests then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Greeted by a new NPC")
        lastNPCTalkedTo = currentNPC
        isAllowedNPC = _QuestieAuto:IsAllowedNPC()
        lastIndexTried = 1
        lastAmountOfAvailableQuests = #availableQuests
        doneWithAccept = false
    end

    if cameFromProgressEvent then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Last event was Progress")
        cameFromProgressEvent = false
        lastIndexTried = lastIndexTried + MOP_INDEX_AVAILABLE
    end

    if Questie.db.char.autoaccept and (not doneWithAccept) and isAllowedNPC then
        if lastIndexTried < #availableQuests then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Checking available quests from gossip")
            _QuestieAuto:AcceptQuestFromGossip(lastIndexTried, availableQuests, MOP_INDEX_AVAILABLE)
            return
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] DONE. Checked all available quests")
            doneWithAccept = true
            lastIndexTried = 1
        end
    end

    if Questie.db.char.autocomplete and isAllowedNPC then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Checking active quests from gossip")
        local completeQuests = {GetGossipActiveQuests()}

        for index=1, #completeQuests, MOP_INDEX_COMPLETE do
            _QuestieAuto:CompleteQuestFromGossip(index, completeQuests, MOP_INDEX_COMPLETE)
        end
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] DONE. Checked all complete quests")
    end
end

function QuestieAuto:QUEST_PROGRESS(event, ...)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] QUEST_PROGRESS", event, ...)
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    if Questie.db.char.autocomplete then
        if _QuestieAuto:IsAllowedNPC() and _QuestieAuto:IsAllowedQuest() then
            if IsQuestCompletable() then
                CompleteQuest()
                return
            else
                Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Quest not completeable. Index", lastIndexTried)
            end
        end

        -- Close the QuestFrame if no quest is completeable again
        if QuestFrameGoodbyeButton and lastEvent ~= nil then
            QuestFrameGoodbyeButton:Click()
        end
        cameFromProgressEvent = true
    end
    lastEvent = "QUEST_PROGRESS"
end

_SelectAvailableQuest = function (index)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Selecting available quest at index", index)
    SelectAvailableQuest(index)
end

function QuestieAuto:QUEST_ACCEPT_CONFIRM(event, ...)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] QUEST_ACCEPT_CONFIRM", event, ...)
    lastEvent = "QUEST_ACCEPT_CONFIRM"
    doneTalking = false
    -- Escort stuff
    if(Questie.db.char.autoaccept) then
       ConfirmAcceptQuest()
    end
end

function QuestieAuto:QUEST_GREETING(event, ...)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] QUEST_GREETING", event, GetNumActiveQuests(), ...)
    lastEvent = "QUEST_GREETING"
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    if cameFromProgressEvent then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Last event was Progress")
        cameFromProgressEvent = false
        lastIndexTried = lastIndexTried + 1
    end

    -- Quest already taken
    if (Questie.db.char.autocomplete) then
        for index = 1, GetNumActiveQuests() do
            local quest, isComplete = GetActiveTitle(index)
            Questie:Debug(Questie.DEBUG_DEVELOP, quest, isComplete)
            if isComplete then SelectActiveQuest(index) end
        end
    end

    if (Questie.db.char.autoaccept) then
        local availableQuestsCount = GetNumAvailableQuests()
        if lastIndexTried == 0 or lastIndexTried > availableQuestsCount then
            lastIndexTried = 1
        end
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] lastIndex:", lastIndexTried)
        if availableQuestsCount > 0 and lastIndexTried < availableQuestsCount then
            _SelectAvailableQuest(lastIndexTried)
        end
    end
end


function QuestieAuto:QUEST_DETAIL(event, ...)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] QUEST_DETAIL", event, ...)
    lastEvent = "QUEST_DETAIL"
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    -- We really want to disable this in instances, mostly to prevent retards from ruining groups.
    if (Questie.db.char.autoaccept and _QuestieAuto:IsAllowedNPC() and _QuestieAuto:IsAllowedQuest()) then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] INSIDE", event, ...)

        local questId = GetQuestID()
        local quest

        if questId and questId ~= 0 then
            quest = QuestieDB:GetQuest(questId)
        end

        if not quest then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] No quest object, retrying in 1 second")
            C_Timer.After(1, function()
                questId = GetQuestID()
                if questId and questId ~= 0 then
                    quest = QuestieDB:GetQuest(questId)
                    if not quest then
                        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] retry failed. Quest", questId, "might not be in the DB!")
                    elseif (not quest:IsTrivial()) or Questie.db.char.acceptTrivial then
                        Questie:Debug(Questie.DEBUG_INFO, "[QuestieAuto] Questie Auto-Acceping quest")
                        AcceptQuest()
                    end
                end
            end)

            return
        end

        if (not quest:IsTrivial()) or Questie.db.char.acceptTrivial then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieAuto] Questie Auto-Acceping quest")
            AcceptQuest()
        end
    end
end

-- I was forced to make decision on offhand, cloak and shields separate from armor but I can't pick up my mind about the reason...
function QuestieAuto:QUEST_COMPLETE(event, ...)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] QUEST_COMPLETE", event, ...)
    lastEvent = "QUEST_COMPLETE"
    doneTalking = false

    if (not shouldRunAuto) then
        return
    elseif _QuestieAuto:IsBindTrue(Questie.db.char.autoModifier) then
        shouldRunAuto = false
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Modifier-Key down: Disabling QuestieAuto for now")
        return
    end

    -- blasted Lands citadel wonderful NPC. They do not trigger any events except quest_complete.
    -- if not AllowedToHandle() then
    --    return
    -- end
    if (Questie.db.char.autocomplete) then

        local questname = GetTitleText()
        local numOptions = GetNumQuestChoices()
        Questie:Debug(Questie.DEBUG_DEVELOP, event, questname, numOptions, ...)

        if numOptions > 1 then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieAuto] Multiple rewards (" .. numOptions .. ")! Please choose appropriate reward!")
        else
            _QuestieAuto:TurnInQuest(1)
            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Completed quest!")
        end
    end
end

local _QuestFinishedCallback = function()
    if _QuestieAuto:AllQuestWindowsClosed() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] All quest windows closed! Resetting shouldRunAuto")
        ResetModifier()
    end
end

function QuestieAuto:QUEST_FINISHED()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] QUEST_FINISHED")

    C_Timer.After(0.5, _QuestFinishedCallback)
end

function _QuestieAuto:AllQuestWindowsClosed()
    if GossipFrame and (not GossipFrame:IsVisible())
            and GossipFrameGreetingPanel and (not GossipFrameGreetingPanel:IsVisible())
            and QuestFrameGreetingPanel and (not QuestFrameGreetingPanel:IsVisible())
            and QuestFrameDetailPanel and (not QuestFrameDetailPanel:IsVisible())
            and QuestFrameProgressPanel and (not QuestFrameProgressPanel:IsVisible())
            and QuestFrameRewardPanel and (not QuestFrameRewardPanel:IsVisible()) then
        return true
    end
    return false
end

--- The closingCounter needs to reach 1 for QuestieAuto to reset
--- Whenever the gossip frame is closed this event is called once, HOWEVER
--- when totally stop talking to an NPC this event is called twice.
--- Another special case is: If you run away from the NPC the event is called
--- just once.
function QuestieAuto:GOSSIP_CLOSED()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto][EVENT] GOSSIP_CLOSED")
    lastEvent = "GOSSIP_CLOSED"

    if doneTalking then
        doneTalking = false
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] We are done talking to an NPC! Resetting shouldRunAuto")
        shouldRunAuto = true
        lastEvent = nil
    else
        doneTalking = true
    end
end
