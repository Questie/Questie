---@class VoiceOverPlayButton
local VoiceOverPlayButton = QuestieLoader:CreateModule("VoiceOverPlayButton")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker") -- TODO: Remove this explicit dependency
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")

---@param index number
---@param parent LineFrame
---@return LineFrame
function VoiceOverPlayButton.New(index, parent)
    local playButton = CreateFrame("Button", "linePool.playButton" .. index, parent)
    playButton:SetWidth(20)
    playButton:SetHeight(20)
    playButton:SetHitRectInsets(2, 2, 2, 2)
    playButton:SetPoint("RIGHT", parent.label, "LEFT", -4, 0)
    playButton:SetFrameLevel(0)
    playButton:SetNormalTexture("Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton")
    playButton:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight")

    function playButton:SetPlayButton(questId)
        if questId ~= self.mode then
            self.mode = questId

            if questId and TrackerUtils:IsVoiceOverLoaded() then
                self:Show()
            else
                self.mode = nil
                self:SetAlpha(0)
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
                        local title = GetQuestLogTitle(GetQuestLogIndexByID(self.mode))
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

                        soundData.stopCallback = function()
                            VoiceOver.QuestOverlayUI:UpdatePlayButtonTexture(self.mode)
                            VoiceOver.QuestOverlayUI.questPlayButtons[self.mode].soundData = nil
                        end
                    else
                        VoiceOver.SoundQueue:RemoveSoundFromQueue(soundData)
                    end

                    isPlaying = button.soundData and VoiceOver.SoundQueue:Contains(button.soundData)
                    local texturePath = isPlaying and "Interface\\Addons\\Questie\\Icons\\QuestLogStopButton" or "Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton"
                    self:SetNormalTexture(texturePath)

                    -- Move the VoiceOverFrame below the DurabilityFrame if it's present and not already moved
                    if (Questie.db.profile.stickyDurabilityFrame and DurabilityFrame:IsVisible()) and select(5, VoiceOverFrame:GetPoint()) < -125 then
                        QuestieTracker:UpdateVoiceOverFrame()
                    end
                end
            end
        end
    end)

    playButton:SetAlpha(0)
    playButton:Hide()

    return playButton
end
