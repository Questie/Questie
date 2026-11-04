---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---Play button for the Spoken addon. Spoken_Quests exposes its environment as the VoiceOver global.
---@class SpokenPlayButton
local SpokenPlayButton = QuestieLoader:CreateModule("SpokenPlayButton")

local PLAY_TEXTURE = "Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton"
local STOP_TEXTURE = "Interface\\Addons\\Questie\\Icons\\QuestLogStopButton"

---Shows the stop icon while the quest's line is queued in Spoken.
---@param playButton Button
local function _UpdateTexture(playButton)
    local isQueued = VoiceOver.QuestOverlayUI:QueuedLine(playButton.mode) ~= nil
    playButton:SetNormalTexture(isQueued and STOP_TEXTURE or PLAY_TEXTURE)
end

---@param playButton Button
local function _Toggle(playButton)
    local questId = playButton.mode
    local queuedLine = VoiceOver.QuestOverlayUI:QueuedLine(questId)

    if queuedLine then
        VoiceOver.Player:Remove(queuedLine)
    else
        local giverType, giverId = VoiceOver.DataModules:GetQuestLogQuestGiverTypeAndID(questId)
        local soundData = {
            event = VoiceOver.Enums.SoundEvent.QuestAccept,
            questID = questId,
            name = giverId and VoiceOver.DataModules:GetObjectName(giverType, giverId) or "Unknown Name",
            title = QuestieCompat.GetQuestLogTitle(QuestieCompat.GetQuestLogIndexByID(questId)) or "",
            unitGUID = giverId and VoiceOver.Enums.GUID:CanHaveID(giverType) and VoiceOver.Utils:MakeGUID(giverType, giverId) or nil,
            unitIsObjectOrItem = giverId ~= nil and (not VoiceOver.Enums.GUID:IsCreature(giverType)),
            origin = "Questie's tracker Play button",
        }
        soundData.stopCallback = function()
            if playButton.mode == questId then
                _UpdateTexture(playButton)
            end
        end
        VoiceOver.Player:PlayNow(soundData)
    end

    _UpdateTexture(playButton)
end

---Spoken's voice packs load after the tracker is first drawn, so quests only then get their play button
---@param onVoicePacksLoaded function
function SpokenPlayButton.Initialize(onVoicePacksLoaded)
    Spoken:RegisterCallback("VOICE_PACKS_LOADED", onVoicePacksLoaded)
end

---@param questId QuestId
---@return boolean
local function _HasSound(questId)
    return VoiceOver.DataModules:PrepareSound({event = VoiceOver.Enums.SoundEvent.QuestAccept, questID = questId}) and true or false
end

---@param index number
---@param parent TrackerLineFrame
---@return Button
function SpokenPlayButton.New(index, parent)
    local playButton = CreateFrame("Button", "linePool.playButton" .. index, parent)
    playButton:SetFrameLevel(100)
    playButton:SetNormalTexture(PLAY_TEXTURE)
    playButton:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight")

    function playButton:SetPlayButton(questId)
        if questId and Questie.db.profile.trackerShowPlayButtons and _HasSound(questId) then
            self.mode = questId
            _UpdateTexture(self)
            self:Show()
        else
            self.mode = nil
            self:Hide()
        end
    end

    playButton:EnableMouse(true)
    playButton:RegisterForClicks("LeftButtonUp")

    playButton:SetScript("OnClick", function(self)
        if self.mode ~= nil then
            _Toggle(self)
        end
    end)

    playButton:Hide()

    return playButton
end
