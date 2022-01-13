--[[
Flow:
-> QuestieValidateGameCache.StartCheck()
--> Wait for PLAYER_ENTERING_WORLD
---> Wait For QUEST_LOG_UPDATE (2x at login, 1x at reload)
----> Game cache should have all quests in it, data of each quest may be invalid.
      If data is invalid, Wait for next QUEST_LOG_UPDATE and check again.
-----> Game Cache ok. Call possible callback functions.
]]--

---@class QuestieValidateGameCache
local QuestieValidateGameCache = QuestieLoader:CreateModule("QuestieValidateGameCache")

local stringSub = string.sub
local GetNumQuestLogEntries, GetQuestLogTitle, GetQuestObjectives = GetNumQuestLogEntries, GetQuestLogTitle, C_QuestLog.GetQuestObjectives

local tpack = table.pack or function(...) return { n = select("#", ...), ... } end
local tunpack = table.unpack or unpack

-- 3 * (Max possible number of quests in game quest log)
-- This is a safe value, even smaller would be enough. Too large won't effect performance
local MAX_QUEST_LOG_INDEX = 75

local eventFrame
local numberOfQuestLogUpdatesToSkip

local cacheGood = false
local callbacks = {} -- example: { [1] = {func, {arg1, arg2, arg3}}, [2] = {func, {arg1, arg2}}, }

function QuestieValidateGameCache.IsCacheGood()
    return cacheGood
end

---@param func function @A function to call once cache is good.
---@param ... any @Possible arguments for function.
function QuestieValidateGameCache.AddCallback(func, ...)
    callbacks[#callbacks+1] = {func, tpack(...)}
end


local function DestroyEventFrame()
    if eventFrame then
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
        eventFrame:SetParent(nil)
        eventFrame = nil
    end
end

-- Called directly and OnEvent.
local function OnQuestLogUpdate()
    local numEntries, numQuests = GetNumQuestLogEntries()
    print("--> QuestieValidateGameCache.OnQuestLogUpdate() numEntries:", numEntries, "numQuests:", numQuests)

    if numberOfQuestLogUpdatesToSkip > 0 then
        numberOfQuestLogUpdatesToSkip = numberOfQuestLogUpdatesToSkip - 1
        print("--> QuestieValidateGameCache.OnQuestLogUpdate() Skipping event.")
        return
    end

    --[[
    -- Player can have 0 quests in questlog OR game's cache can have empty questlog while cache is invalid
    -- This is a workaround to wait and see if player really has 0 quests.
    -- Without cached information the first QLU does not have any quest log entries.
    -- After MAX_INIT_QUEST_LOG_TRIES tries we stop trying
    if numEntries == 0 then
        initQuestLogTries = initQuestLogTries + 1
        if initQuestLogTries < MAX_INIT_QUEST_LOG_TRIES then
            print("--> QuestieValidateGameCache.OnQuestLogUpdate()", GetTime(), "Game's quest log is empty. Tries:", initQuestLogTries.."/"..MAX_INIT_QUEST_LOG_TRIES)
            _WaitForGameCache_TryAgainAtEvent()
            return
        else
            print("--> QuestieValidateGameCache.OnQuestLogUpdate()", GetTime(), "Decide player has no quests for real.")
        end
    end
    ]]--

    local isGameCacheGood = true
    local goodQuestsCount = 0 -- for debug stats

    for i = 1, MAX_QUEST_LOG_INDEX do
        local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(i)
        if (not title) then
            break -- We exceeded the valid quest log entries
        end
        if (not isHeader) then
            local hasInvalidObjective -- for debug stats
            local objectiveList = GetQuestObjectives(questId)
            for _, objective in pairs(objectiveList) do -- objectiveList may be {} and that is validly cached quest in game log
                if (not objective.text) or stringSub(objective.text, 1, 1) == " " then
                    -- Game hasn't cached the quest fully yet
                    isGameCacheGood = false
                    hasInvalidObjective = true

                    -- No early "return false" here to force iterate whole quest log and speed up caching
                end
            end
            if not hasInvalidObjective then
                goodQuestsCount = goodQuestsCount + 1
            end
        end
    end

    if not isGameCacheGood then
        print("--> QuestieValidateGameCache.OnQuestLogUpdate()", GetTime(), "Game's quest log is not yet okey. Good quest: "..goodQuestsCount.."/"..numQuests)
        return
    end

    if goodQuestsCount ~= numQuests then
        -- This shouldn't be possible
        Questie:Error("Report this error! Game QuestLog cache is broken. Good quest: "..goodQuestsCount.."/"..numQuests) -- TODO fix message and add translations? translations might not be available?
        -- TODO should we stop whole addon loading progress?
    end

    print("--> QuestieValidateGameCache.OnQuestLogUpdate()", GetTime(), "Game's quest log is |cff00bc32".."OK".."|r. Good quest: "..goodQuestsCount.."/"..numQuests)

    DestroyEventFrame()

    cacheGood = true

    -- Call all callbacks
    while (#callbacks > 0) do
        local callback = table.remove(callbacks, 1)
        local func, args = tunpack(callback)
        print("--> QuestieValidateGameCache.OnQuestLogUpdate()", "Calling a callback.")
        func(tunpack(args))
    end
end

local function OnPlayerEnteringWorld(_, _, isInitialLogin, isReloadingUi)
    assert(isInitialLogin or isReloadingUi)

    numberOfQuestLogUpdatesToSkip = isReloadingUi and 0 or 1

    eventFrame:UnregisterAllEvents()
    eventFrame:SetScript("OnEvent", OnQuestLogUpdate)
    eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
end

-- MUST be started very early to count number of events firing.
function QuestieValidateGameCache.StartCheck()
    eventFrame = CreateFrame("Frame")
    eventFrame:SetScript("OnEvent", OnPlayerEnteringWorld)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end