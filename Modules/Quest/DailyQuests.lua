---@class DailyQuests
local DailyQuests = QuestieLoader:CreateModule("DailyQuests")
local Questie = _G.Questie

local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

-- Forward declarations
local nhcDailyIds, hcDailyIds, cookingDailyIds, fishingDailyIds, pvpDailyIds, everydayDailyIds


local nextCheck = -1 -- -1 is always smaller than GetTime()
local dailyResetTimer


---@param questId number
---@return nil
local function _HideDailyQuest(questId)
    QuestieMap:UnloadQuestFrames(questId)
    QuestieTooltips:RemoveQuest(questId)
end


---@param questId number
---@return nil
local function _ShowDailyQuest(questId)
    if (not QuestieMap.questIdFrames[questId]) then
        QuestieQuest:DrawDailyQuest(questId)
    end
end


--- Reset which daily quests are completed,
---  can freely be run also at not-daily-reset-time
--- And Show quests as necessary
--- Start Timer to reset again
---@return nil
local function _ResetEverydayDailyQuests()
    Questie:Debug(Questie.DEBUG_INFO, "[DailyQuests]: _ResetEverydayDailyQuests() - Okey to get run also at non-reset times")

    local dbCharCompletedQuests = Questie.db.char.complete

    for questId, _ in pairs(everydayDailyIds) do
        if not IsQuestFlaggedCompleted(questId) then
            -- Mark the quest uncompleted so it can be available again
            dbCharCompletedQuests[questId] = nil
            _ShowDailyQuest(questId)
        end
    end

    if dailyResetTimer then
        DailyQuests.StopDailyResetTimer()
    end
    Questie:Debug(Questie.DEBUG_DEVELOP, "[DailyQuests]: Creating new dailyResetTimer")
    -- +20s delay to try compensate server not doing reset at its announced time
    dailyResetTimer = C_Timer.NewTimer(C_DateAndTime.GetSecondsUntilDailyReset() + 20, _ResetEverydayDailyQuests)
end


--- Generate list of hidden dailies of type for today from possibleQuestIds
--- And update if quest is completed or not
--- And Show/Hide quest as necessary
---@param possibleQuestIds table<number, boolean>
---@param currentQuestId number|nil @today's daily quest. nil -> we don't know and show all
---@param type string @Which type of dailies we are checking. examples: "nhc" "hc" "cooking" "fishing"
---@return nil
local function _ResetHiddenDailyQuests(possibleQuestIds, currentQuestId, type)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[DailyQuests]: _ResetHiddenDailyQuests(  ) currentQuestId, type:", currentQuestId, type)

    local hiddenDailies = {}
    local dbCharCompletedQuests = Questie.db.char.complete

    for questId, _ in pairs(possibleQuestIds) do
        if not IsQuestFlaggedCompleted(questId) then
            -- If daily reset happens while online, mark old dailies uncompleted so those can be shown again
            dbCharCompletedQuests[questId] = nil
        end

        if questId == currentQuestId then
            -- Show today's daily quest
            _ShowDailyQuest(questId)
            hiddenDailies[questId] = nil
        else
            if (GetQuestLogIndexByID(questId) == 0) then
                -- If the quest is not in the questlog remove all frames
                _HideDailyQuest(questId)
            end
            -- Objectives & Turn-in are shown for all quests in the questlog -> safe to mark hidden
            hiddenDailies[questId] = true
        end
    end
    Questie.db.char.hiddenDailies[type] = hiddenDailies
end


---@param possibleQuestIds table<number, boolean>
---@param currentQuestId number @today's daily quest
---@param type string
---@return nil
local function _ResetHiddenIfRequired(possibleQuestIds, currentQuestId, type)
    if currentQuestId > 0 and (Questie.db.char.hiddenDailies[type][currentQuestId] or (not next(Questie.db.char.hiddenDailies[type]))) and (not IsQuestFlaggedCompleted(currentQuestId)) then
        _ResetHiddenDailyQuests(possibleQuestIds, currentQuestId, type)
    end
end


---@param message string
---@return number, number, number, number, number
local function _GetTodaysDailyIdsFromMessage(message)
    -- Each questId is followed by the timestamp from GetQuestResetTime(). We don't use that timestamp (yet)
    local _, _, nhcQuestId, _, hcQuestId, _, cookingQuestId, _, fishingQuestId, _, pvpQuestId, _ = strsplit(":", message)

    return tonumber(nhcQuestId) or 0,
        tonumber(hcQuestId) or 0,
        tonumber(cookingQuestId) or 0,
        tonumber(fishingQuestId) or 0,
        tonumber(pvpQuestId) or 0
end


--- This handles only non-random everyday dailies.
--- Does reset check ALSO when called.
---@return nil
function DailyQuests.StartDailyResetTimer()
    if Questie.IsTBC and Questie.db.char.showRepeatableQuests and QuestiePlayer:GetPlayerLevel() == 70 then
        _ResetEverydayDailyQuests()
    end
end


--- This handles only non-random everyday dailies.
---@return nil
function DailyQuests.StopDailyResetTimer()
    if dailyResetTimer then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[DailyQuests]: StopDailyResetTimer")
        dailyResetTimer:Cancel()
        dailyResetTimer = nil
    end
end


---@param message string
---@return nil
function DailyQuests:FilterDailies(message, _, _)
    if message and Questie.db.char.showRepeatableQuests and QuestiePlayer:GetPlayerLevel() == 70 then
        -- If the REPUTABLE message is empty, i.e contains "::::::::::" we don't count it as a check.
        if GetTime() < nextCheck or string.find(message, "::::::::::") then
            return
        end
        nextCheck = GetTime() + 10 -- seconds

        local nhcQuestId, hcQuestId, cookingQuestId, fishingQuestId, pvpQuestId = _GetTodaysDailyIdsFromMessage(message);

        _ResetHiddenIfRequired(nhcDailyIds, nhcQuestId, "nhc")
        _ResetHiddenIfRequired(hcDailyIds, hcQuestId, "hc")
        _ResetHiddenIfRequired(cookingDailyIds, cookingQuestId, "cooking")
        _ResetHiddenIfRequired(fishingDailyIds, fishingQuestId, "fishing")
        _ResetHiddenIfRequired(pvpDailyIds, pvpQuestId, "pvp")
    end
end

-- /run DailyQuests:FilterDailies("0:0:11364:0:11354:0:11377:0:11667:0:11340:0")
-- /run Questie.db.char.hiddenDailies = {nhc={},hc={},cooking={},fishing={},pvp={}}


---@param questId number
---@return boolean
function DailyQuests.IsHiddenDailyQuest(questId)
    local hiddenQuests = Questie.db.char.hiddenDailies
    return not not (hiddenQuests.nhc[questId] -- "not not" to convert to boolean
                or hiddenQuests.hc[questId]
                or hiddenQuests.cooking[questId]
                or hiddenQuests.fishing[questId]
                or hiddenQuests.pvp[questId])
end


---@param questId number
---@return boolean
function DailyQuests.IsDailyQuest(questId)
    return not not (nhcDailyIds[questId] -- "not not" to convert to boolean
                or hcDailyIds[questId]
                or cookingDailyIds[questId]
                or fishingDailyIds[questId]
                or pvpDailyIds[questId]
                or everydayDailyIds[questId])
end


nhcDailyIds = {
    [11364] = true,
    [11371] = true,
    [11376] = true,
    [11383] = true,
    [11385] = true,
    [11387] = true,
    [11389] = true,
    [11500] = true,
}

hcDailyIds = {
    [11354] = true,
    [11362] = true,
    [11363] = true,
    [11368] = true,
    [11369] = true,
    [11370] = true,
    [11372] = true,
    [11373] = true,
    [11374] = true,
    [11375] = true,
    [11378] = true,
    [11382] = true,
    [11384] = true,
    [11386] = true,
    [11388] = true,
    [11499] = true,
}

cookingDailyIds = {
    [11377] = true,
    [11379] = true,
    [11380] = true,
    [11381] = true,
}

fishingDailyIds = {
    [11665] = true,
    [11666] = true,
    [11667] = true,
    [11668] = true,
    [11669] = true,
}

pvpDailyIds = {
    [11335] = true,
    [11336] = true,
    [11337] = true,
    [11338] = true,
    [11339] = true,
    [11340] = true,
    [11341] = true,
    [11342] = true,
}

everydayDailyIds = {
    -- P = pvp, O = P2 Oggrila/Skettis, N = Netherwing
    -- EB = Event Brewfest, EH = Event Halloween, ES = Event mid Summer
    -- NOTE: Checked to be correct: P, O
    [10106] = true, --P: Hellfire Fortifications
    [10110] = true, --P: Hellfire Fortifications
    [11008] = true, --O: Fires Over Skettis
--    [11015] = true, --N: Netherwing Crystals
--    [11016] = true, --N: Nethermine Flayer Hide
--    [11017] = true, --N: Netherdust Pollen
--    [11018] = true, --N: Nethercite Ore
--    [11020] = true, --N: A Slow Death
    [11023] = true, --O: Bomb Them Again!
--    [11035] = true, --N: The Not-So-Friendly Skies...
    [11051] = true, --O: Banish More Demons
--    [11055] = true, --N: The Booterang: A Cure For The Common Worthless Peon
    [11066] = true, --O: Wrangle More Aether Rays!
--    [11076] = true, --N: Picking Up The Pieces...
--    [11077] = true, --N: Dragons are the Least of Our Problems
    [11080] = true, --O: The Relic's Emanation
    [11085] = true, --O: Escape from Skettis
--    [11086] = true, --N: Disrupting the Twilight Portal
--    [11097] = true, --N: The Deadliest Trap Ever Laid
--    [11101] = true, --N: The Deadliest Trap Ever Laid
--    [11131] = true, --EH: Stop the Fires!
--    [11219] = true, --EH: Stop the Fires!
--    [11293] = true, --EB: Bark for the Barleybrews!
--    [11294] = true, --EB: Bark for the Thunderbrews!
--    [11401] = true, --EH: Call the Headless Horseman
--    [11404] = true, --EH: Call the Headless Horseman
--    [11405] = true, --EH: Call the Headless Horseman
--    [11407] = true, --EB: Bark for Drohn's Distillery!
--    [11408] = true, --EB: Bark for T'chali's Voodoo Brewery!
--    [11496] = true, --S: The Sanctum Wards
    [11502] = true, --P: In Defense of Halaa
    [11503] = true, --P: Enemies, Old and New
    [11505] = true, --P: Spirits of Auchindoun
    [11506] = true, --P: Spirits of Auchindoun
--    [11513] = true, --S: Intercepting the Mana Cells
--    [11514] = true, --S: Maintaining the Sunwell Portal
--    [11515] = true, --S: Blood for Blood
--    [11516] = true, --S: Blast the Gateway
--    [11520] = true, --S: Discovering Your Roots
--    [11521] = true, --S: Rediscovering Your Roots
--    [11523] = true, --S: Arm the Wards!
--    [11524] = true, --S: Erratic Behavior
--    [11525] = true, --S: Further Conversions
--    [11532] = true, --S: Distraction at the Dead Scar
--    [11533] = true, --S: The Air Strikes Must Continue
--    [11535] = true, --S: Making Ready
--    [11536] = true, --S: Don't Stop Now....
--    [11537] = true, --S: The Battle Must Go On
--    [11538] = true, --S: The Battle for the Sun's Reach Armory
--    [11539] = true, --S: Taking the Harbor
--    [11540] = true, --S: Crush the Dawnblade
--    [11541] = true, --S: Disrupt the Greengill Coast
--    [11542] = true, --S: Intercept the Reinforcements
--    [11543] = true, --S: Keeping the Enemy at Bay
--    [11544] = true, --S: Ata'mal Armaments
--    [11545] = true, --S: A Charitable Donation
--    [11546] = true, --S: Open for Business
--    [11547] = true, --S: Know Your Ley Lines
--    [11548] = true, --S: Your Continued Support
--    [11691] = true, --ES: Summon Ahune
--    [11875] = true, --S: Gaining the Advantage
--    [11877] = true, --S: Sunfury Attack Plans
--    [11880] = true, --S: The Multiphase Survey
--    [11917] = true, --ES: Striking Back
--    [11921] = true, --ES: More Torch Tossing
--    [11924] = true, --ES: More Torch Catching
--    [11925] = true, --ES: More Torch Catching
--    [11926] = true, --ES: More Torch Tossing
--    [11947] = true, --ES: Striking Back
--    [11948] = true, --ES: Striking Back
--    [11952] = true, --ES: Striking Back
--    [11953] = true, --ES: Striking Back
--    [11954] = true, --ES: Striking Back
--    [12020] = true, --EB: This One Time, When I Was Drunk...
--    [12062] = true, --EB: Insult Coren Direbrew
}
