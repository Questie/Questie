---@class GroupEventHandler
local GroupEventHandler = QuestieLoader:CreateModule("GroupEventHandler")

---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")

function GroupEventHandler.GroupRosterUpdate()
    local currentMembers = GetNumGroupMembers()
    -- Only want to do logic when number increases, not decreases.
    if QuestiePlayer.numberOfGroupMembers < currentMembers then
        -- Tell comms to send information to members.
        --Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST")
        QuestiePlayer.numberOfGroupMembers = currentMembers
    else
        -- We do however always want the local to be the current number to allow up and down.
        QuestiePlayer.numberOfGroupMembers = currentMembers
    end
end

function GroupEventHandler.GroupJoined()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[EVENT] GROUP_JOINED")
    local checkTimer
    --We want this to be fairly quick.
    checkTimer = C_Timer.NewTicker(0.2, function()
        local partyPending = UnitInParty("player")
        local isInParty = UnitInParty("party1")
        local isInRaid = UnitInRaid("raid1")
        if partyPending then
            if (isInParty or isInRaid) then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[EventHandler] Player joined party/raid, ask for questlogs")
                --Request other players log.
                Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
                checkTimer:Cancel()
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[EventHandler] Player no longer in a party or pending invite. Cancel timer")
            checkTimer:Cancel()
        end
    end)
end


function GroupEventHandler.GroupLeft()
    --Resets both QuestieComms.remoteQuestLog and QuestieComms.data
    QuestieComms:ResetAll()
end
