---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class VoiceOverPlayButton
local VoiceOverPlayButton = QuestieLoader:CreateModule("VoiceOverPlayButton")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker") -- TODO: Remove this explicit dependency
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")

---Shows the stop icon while the quest's VoiceOver sound plays.
---@param playButton Button
local function _UpdateTexture(playButton)
    local button = VoiceOver.QuestOverlayUI.questPlayButtons[playButton.mode]
    local isPlaying = button and button.soundData and VoiceOver.SoundQueue:Contains(button.soundData)
    playButton:SetNormalTexture(isPlaying and "Interface\\Addons\\Questie\\Icons\\QuestLogStopButton" or "Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton")
end

---@param index number
---@param parent TrackerLineFrame
---@return Button
function VoiceOverPlayButton.New(index, parent)
    local playButton = CreateFrame("Button", "linePool.playButton" .. index, parent)
    playButton:SetFrameLevel(100)
    playButton:SetNormalTexture("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton")
    playButton:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight")

    function playButton:SetPlayButton(questId)
        if questId ~= self.mode then
            self.mode = questId

            if questId and TrackerUtils:IsVoiceOverLoaded() then
                _UpdateTexture(self)
                self:Show()
            else
                self.mode = nil
                self:Hide()
            end
        end
    end

    playButton:EnableMouse(true)
    playButton:RegisterForClicks("LeftButtonUp")

    playButton:SetScript("OnClick", function(self)
        if self.mode ~= nil then
            if TrackerUtils:IsVoiceOverLoaded() then
                local button = VoiceOver.QuestOverlayUI.questPlayButtons[self.mode]
                if button then
                    if not VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData then
                        local type, id = VoiceOver.DataModules:GetQuestLogQuestGiverTypeAndID(self.mode)
                        local title = QuestieCompat.GetQuestLogTitle(QuestieCompat.GetQuestLogIndexByID(self.mode))
                        VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData = {
                            event = VoiceOver.Enums.SoundEvent.QuestAccept,
                            questID = self.mode,
                            name = id and VoiceOver.DataModules:GetObjectName(type, id) or "Unknown Name",
                            title = title,
                            unitGUID = id and VoiceOver.Enums.GUID:CanHaveID(type) and VoiceOver.Utils:MakeGUID(type, id) or nil
                        }
                    end

                    local soundData = VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData
                    local isPlaying = VoiceOver.SoundQueue:Contains(soundData)

                    if not isPlaying then
                        VoiceOver.SoundQueue:AddSoundToQueue(soundData)
                        VoiceOver.QuestOverlayUI:UpdatePlayButtonTexture(self.mode)

                        local questId = self.mode
                        soundData.stopCallback = function()
                            VoiceOver.QuestOverlayUI:UpdatePlayButtonTexture(questId)
                            VoiceOver.QuestOverlayUI.questPlayButtons[questId].soundData = nil
                            if self.mode == questId then
                                _UpdateTexture(self)
                            end
                        end
                    else
                        VoiceOver.SoundQueue:RemoveSoundFromQueue(soundData)
                    end

                    _UpdateTexture(self)

                    -- Move the VoiceOverFrame below the DurabilityFrame if it's present and not already moved
                    if (Questie.db.profile.stickyDurabilityFrame and DurabilityFrame:IsVisible()) and select(5, VoiceOverFrame:GetPoint()) < -125 then
                        QuestieTracker:UpdateVoiceOverFrame()
                    end
                end
            end
        end
    end)

    playButton:Hide()

    return playButton
end
