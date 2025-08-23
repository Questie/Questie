---@class ChallengeModeTimer
local ChallengeModeTimer = QuestieLoader:CreateModule("ChallengeModeTimer")

---@class Label
---@field SetText fun(self: Label, text: string)
local timerLabel

function ChallengeModeTimer.Initialize()
    C_Timer.NewTicker(1, function()
        if (not timerLabel) then
            return
        end

        local timerString = ChallengeModeTimer.GetTimerString()
        timerLabel:SetText(timerString)
    end)
end

---@param label Label|nil
function ChallengeModeTimer.SetTimerLabel(label)
    timerLabel = label
end

---@return string @Returns the Challenge Mode timer in the format "MM:SS / MM:SS" with the appropriate color based on the elapsed time
function ChallengeModeTimer.GetTimerString()
    local _, elapsed = GetWorldElapsedTime(1)
    local _, instanceType, _, difficultyName, _, _, _, mapID = GetInstanceInfo()
    if instanceType ~= "none" and difficultyName == "Challenge Mode" then
        local mapTimes = C_ChallengeMode.GetChallengeModeMapTimes(mapID)

        local goldTime = mapTimes[3]
        local silverTime = mapTimes[2]
        local bronzeTime = mapTimes[1]

        local thresholdColor, thresholdTime
        if elapsed <= goldTime then
            thresholdColor = "F1E156"
            thresholdTime = goldTime
        elseif elapsed <= silverTime then
            thresholdColor = "C7B8BD"
            thresholdTime = silverTime
        elseif elapsed <= bronzeTime then
            thresholdColor = "DB8B34"
            thresholdTime = bronzeTime
        else
            thresholdColor = "845321"
            thresholdTime = 0
        end
        local currentMinutes = math.floor(elapsed / 60)
        local currentSeconds = math.floor(elapsed % 60)
        local targetMinutes = math.floor(thresholdTime / 60)
        local targetSeconds = math.floor(thresholdTime % 60)

        local currentTime = string.format("%02d:%02d / ", currentMinutes, currentSeconds)
        local targetTime = string.format("%02d:%02d", targetMinutes, targetSeconds)

        return Questie:Colorize(currentTime, "white") .. Questie:Colorize(targetTime, thresholdColor)
    end

    return Questie:Colorize("00:00 / 00:00", "white")
end

return ChallengeModeTimer
