local MAJOR, MINOR = "LibQuestXP-1.0", 7
local LibQuestXP = LibStub:NewLibrary(MAJOR, MINOR)

if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE then
    return -- Don't load for Retail
end

if not LibQuestXP then
    return -- already loaded and no upgrade necessary
end

local selectedQuestLogIndex = nil

local function hookSelectQuestLogEntry(questLogIndex)
    selectedQuestLogIndex = questLogIndex
end
hooksecurefunc("SelectQuestLogEntry", hookSelectQuestLogEntry)

function LibQuestXP:GetQuestInfo(questID)
    if LibQuestXPDB[questID] ~= nil then
        return LibQuestXPDB[questID]['xp'], LibQuestXPDB[questID]['level']
    end

    return 0, nil
end

function LibQuestXP:GetAdjustedXP(xp, qLevel)
    local charLevel = UnitLevel("player");
    if (charLevel == 60) then
        return 0;
    end

    local diffFactor = 2 * (qLevel - charLevel) + 20;
    if (diffFactor < 1) then
        diffFactor = 1;
    elseif (diffFactor > 10) then
        diffFactor = 10;
    end

    xp = xp * diffFactor / 10;
    if (xp <= 100) then
        xp = 5 * floor((xp + 2) / 5);
    elseif (xp <= 500) then
        xp = 10 * floor((xp + 5) / 10);
    elseif (xp <= 1000) then
        xp = 25 * floor((xp + 12) / 25);
    else
        xp = 50 * floor((xp + 25) / 50);
    end

    return xp;
end

function GetQuestLogRewardXP(questID)
    local title, qLevel, xp

    -- Try getting the quest from the quest log if no questID was provided
    if questID == nil and selectedQuestLogIndex ~= nil then
        title, qLevel, _, _, _, _, _, questID = GetQuestLogTitle(selectedQuestLogIndex)
    end

    -- Return 0 if quest ID is not found for some reason
    if (questID == nil) then return 0 end

    -- Get stored quest XP and quest level
    xp, qLevel = LibQuestXP:GetQuestInfo(questID)

    -- Return base XP if level information is not available
    if qLevel == nil then return xp end

    -- Return adjusted XP if all information are available
    -- print(questID, title, xp, LibQuestXP:GetAdjustedXP(xp, qLevel)); -- Debug
    return LibQuestXP:GetAdjustedXP(xp, qLevel)
end
