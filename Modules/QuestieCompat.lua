---@class QuestieCompat
QuestieCompat = {}

function QuestieCompat.SetResizeBounds(f, minX, minY, maxX, maxY)
    if Questie.IsWotlk then
        f:SetResizeBounds(minX, minY, maxX, maxY)
    else
        if minX and minX ~= 0 then
            f:SetMinResize(minX, minY)
        end
        if maxX and maxX ~= 0 then
            f:SetMaxResize(maxX, maxY)
        end
    end
end

function QuestieCompat.GetAvailableQuests()
    if Questie.IsWotlk then
        return C_GossipInfo.GetAvailableQuests()
    else
        return GetAvailableQuests()
    end
end

function QuestieCompat.GetActiveQuests()
    if Questie.IsWotlk then
        return C_GossipInfo.GetActiveQuests()
    else
        return GetActiveQuests()
    end
end

function QuestieCompat.SelectAvailableQuest(...)
    if Questie.IsWotlk then
        return C_GossipInfo.SelectAvailableQuest(...)
    else
        return SelectAvailableQuest(...)
    end
end

function QuestieCompat.SelectActiveQuests(...)
    if Questie.IsWotlk then
        return C_GossipInfo.SelectActiveQuests(...)
    else
        return SelectActiveQuests(...)
    end
end
