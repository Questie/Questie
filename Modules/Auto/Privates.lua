---@type QuestieAuto
local QuestieAuto = QuestieLoader:ImportModule("QuestieAuto")
---@class QuestieAutoPrivate
---@field disallowedNPC table<NpcId, boolean>
---@field disallowedQuests table<QuestId, boolean>
local _QuestieAuto = QuestieAuto.private

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

function _QuestieAuto:AcceptQuestFromGossip(index, availableQuests, modulo)
    local title = availableQuests[index]
    local isTrivial = availableQuests[index + 2]
    local isRepeatable = availableQuests[index + 4]

    if _QuestieAuto:IsAllowedQuest() and ((not isTrivial) or Questie.db.char.acceptTrivial) then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Checking available quest: \"" .. title .. "\"",
                      "isTrivial", isTrivial, "isRepeatable", isRepeatable, "index",
                      index)
        SelectGossipAvailableQuest(math.floor(index / modulo) + 1)
    end
end

function _QuestieAuto:CompleteQuestFromGossip(index, availableQuests, modulo)
    local title = availableQuests[index]
    local isComplete = availableQuests[index + 3]

    if _QuestieAuto:IsAllowedQuest() and isComplete then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] Checking active quest: \"" .. title .. "\"", "index", index)
        SelectGossipActiveQuest(math.floor(index / modulo) + 1)
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieAuto] \"" .. title .. "\" is not complete. Index:", index)
    end
end

function _QuestieAuto:TurnInQuest(rewardIndex)
    Questie:Debug(Questie.DEBUG_DEVELOP, "Turn in!")

    -- We really want to disable this in instances, mostly to prevent retards from ruining groups.
    if (Questie.db.char.autocomplete and _QuestieAuto:IsAllowedNPC() and _QuestieAuto:IsAllowedQuest()) then
        GetQuestReward(rewardIndex)
    end
end

function _QuestieAuto:IsAllowedNPC()
    local npcGuid = UnitGUID("target") or nil
    local allowed = true
    if npcGuid then
        ---@type string, string, string, string, string, string
        local _, _, _, _, _, npcIDStr = strsplit("-", npcGuid)
        if npcIDStr then
            local npcId = tonumber(npcIDStr)
            if (_QuestieAuto.disallowedNPC[npcId] ~= nil) then
                allowed = false
            end
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieAuto] Is NPC-ID", npcId, "allowed:", allowed)
        end
    end

    return allowed
end

function _QuestieAuto:IsAllowedQuest()
    local questId = GetQuestID()
    local allowed = true
    if questId > 0 then
        if (_QuestieAuto.disallowedQuests[questId] ~= nil) then
            allowed = false
        end
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieAuto]", "Is questId", questId, "allowed:", allowed)
    end

    return allowed
end

local bindTruthTable = {
    ['shift'] = function()
        return IsShiftKeyDown()
    end,
    ['ctrl'] = function()
        return IsControlKeyDown()
    end,
    ['alt'] = function()
        return IsAltKeyDown()
    end,
    ['disabled'] = function() return false; end,
}

function _QuestieAuto:IsBindTrue(bind)
    return bind and bindTruthTable[bind]()
end
