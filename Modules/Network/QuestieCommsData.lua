QuestieComms.data = {}

--[i_1337][playerName][questId] = objective
local commsTooltipLookup = {}

--[playerName] = {
    --[questId] = {["i_1337"]=true,["o_1338"]=true,}
--}
local playerRegisteredTooltips = {}

--Totally removes a player from the tooltip lookups
function QuestieComms.data:RemovePlayer(playerName)
    for questId, tooltipList in pairs(playerRegisteredTooltips[playerName] or {}) do
        QuestieComms.data:RemoveQuestFromPlayer(questId, playerName);
    end
    if(playerRegisteredTooltips[playerName]) then
        playerRegisteredTooltips[playerName] = nil;
    end
end

function QuestieComms.data:RemoveQuestFromPlayer(questId, playerName)
    --First check if the player exists and if it has tooltip related quests.
    if(playerRegisteredTooltips[playerName] and playerRegisteredTooltips[playerName][questId]) then
        --Loop through the tooltips to find which should be removed
        for tooltip, active in pairs(playerRegisteredTooltips[playerName][questId]) do
            --Check if the registered tooltip exists and if the player exists in it.
            if(commsTooltipLookup[tooltip] and commsTooltipLookup[tooltip][playerName]) then
                --Does the questId we want to remove exist?
                if(commsTooltipLookup[tooltip][playerName][questId]) then
                    --Remove questID
                    commsTooltipLookup[tooltip][playerName][questId] = nil;
                    --Do we not have any quests left in the tooltip? If not remove it
                    if(QuestieLib:Count(commsTooltipLookup[tooltip][playerName]) == 0) then
                        commsTooltipLookup[tooltip][playerName] = nil;
                        --Are there any other players with this tooltip registered? If not remove it.
                        if(QuestieLib:Count(commsTooltipLookup[tooltip]) == 0) then
                            commsTooltipLookup[tooltip] = nil;
                        end
                    end
                end
            end
        end
        playerRegisteredTooltips[playerName][questId] = nil;
    end
end